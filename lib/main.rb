require_relative 'games'
require_relative 'parser'
require_relative 'msg_queues'

module KgsMiner
  class Main
    def initialize
      @mqs = MsgQueues.new
    end

    def run
      while true do
        games = []
        @mqs.poll_docq do |msg|
          games = Parser.new(msg.body).games
          @mqs.enq_players Games.uniq_usernames_in games
          @mqs.enq_games games
        end
        sleep 60
      end
    end
  end
end

# Tell ruby not to buffer stdout
# https://github.com/ddollar/foreman/wiki/Missing-Output
$stdout.sync = true

KgsMiner::Main.new.run
