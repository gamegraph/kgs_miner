require 'net/http'
require 'uri'
require_relative 'cache/cache'
require_relative 'cache/connection'
require_relative 'games'
require_relative 'parser'
require_relative 'msg_queues'

module KgsMiner
  class Main
    def initialize
      @mqs = MsgQueues.new
      ccon = Cache::Connection.new
      @url_cache = Cache::MonthUrlCache.new ccon
      @uname_cache = Cache::UsernameCache.new ccon, read_only: true
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
      puts sprintf "unique: %d usersnames", usernames.length
      discovered_names = @uname_cache.discover(usernames)
      puts sprintf "discovered: %d usersnames", discovered_names.length
      @mqs.enq_usernames_to_request(discovered_names)
    end

    def get url
      Net::HTTP.get URI('http://www.gokgs.com/' + url)
    end

    def sleep_rand
      min = ENV['NAPTIME_MIN'].to_i || 30
      max = ENV['NAPTIME_MAX'].to_i || 60
      sleep rand (min..max)
    end

    def process_month url
      puts "month url: #{url}"
      if not valid_month_url?(url)
        puts "skip url: invalid"
        false
      elsif requested_recently?(url)
        puts "skip url: requested recently"
        false
      else
        games = Parser.new(get(url)).games
        process_games games
        @url_cache << url
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

    def requested_recently? url
      @url_cache.hit? url
    end

    def valid_month_url? url
      /^gameArchives\.jsp
        \?user=[a-zA-Z0-9]+
        &year=[0-9]+
        &month=[0-9]+$/x =~ url
    end
  end
end

# Tell ruby not to buffer stdout
# https://github.com/ddollar/foreman/wiki/Missing-Output
$stdout.sync = true

KgsMiner::Main.new.run
