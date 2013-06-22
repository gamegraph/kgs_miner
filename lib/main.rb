require 'net/http'
require 'uri'
require_relative 'cache'
require_relative 'games'
require_relative 'parser'
require_relative 'msg_queues'

module KgsMiner
  class Main
    def initialize
      @mqs = MsgQueues.new
      @cache = Cache.new
    end

    def run
      while true do
        req_sent = false
        @mqs.deq_kmonq { |msg| req_sent = process_month(msg.body) }
        sleep_rand if req_sent
      end
    end

    private

    def sleep_rand
      min = ENV['NAPTIME_MIN'].to_i || 30
      max = ENV['NAPTIME_MAX'].to_i || 60
      sleep rand (min..max)
    end

    def valid_month_url? url
      /^gameArchives\.jsp
        \?user=[a-zA-Z0-9]+
        &year=[0-9]+
        &month=[0-9]+$/x =~ url
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
        @mqs.enq_players Games.uniq_usernames_in games
        @mqs.enq_games games
        @cache << url
        true
      end
    end

    def get url
      Net::HTTP.get URI('http://www.gokgs.com/' + url)
    end

    def requested_recently? url
      @cache.hit? url
    end
  end
end

# Tell ruby not to buffer stdout
# https://github.com/ddollar/foreman/wiki/Missing-Output
$stdout.sync = true

KgsMiner::Main.new.run
