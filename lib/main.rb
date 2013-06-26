require_relative 'activerecords/kgs_month_url'
require_relative 'activerecords/kgs_username'
require_relative 'games'
require_relative 'kgs'
require_relative 'parser'
require_relative 'msg_queues'

module KgsMiner
  class Main
    def initialize
      @mqs = MsgQueues.new
      ActiveRecord::Base.establish_connection ENV.fetch 'DATABASE_URL'
    end

    def run
      while true do
        req_sent = false
        @mqs.deq_kmonq { |msg| req_sent = process_month(msg.body) }
        sleep_rand if req_sent
      end
    end

    private

    def discover_and_enqueue_new_usernames usernames
      known = KgsUsername.where('un in (?)', usernames).to_a.map(&:un)
      discovered = (Set.new(usernames) - known).to_a
      puts sprintf "discovered: %d usernames", discovered.length
      KgsUsername.import_newly_discovered(discovered)
    end

    def sleep_rand
      min = ENV['NAPTIME_MIN'].to_i || 30
      max = ENV['NAPTIME_MAX'].to_i || 60
      sleep rand (min..max)
    end

    def process_month url
      if not Kgs.valid_month_url?(url)
        puts "skip url: invalid"
        false
      elsif KgsMonthUrl.exists? url: url
        puts "skip url: requested recently"
        false
      else
        games = Parser.new(Kgs.get(url)).games
        process_games games
        KgsMonthUrl.create! url: url
        puts "done with that url!"
        true
      end
    end

    def process_games games
      return if games.empty?
      usernames = Games.uniq_usernames_in(games)
      discover_and_enqueue_new_usernames(usernames)
      @mqs.enq_players(usernames)
      @mqs.enq_games(games)
    end
  end
end

# Tell ruby not to buffer stdout
# https://github.com/ddollar/foreman/wiki/Missing-Output
$stdout.sync = true

KgsMiner::Main.new.run
