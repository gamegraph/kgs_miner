require 'aws/sqs'
require 'json'

module KgsMiner
  class MsgQueues
    def initialize
      sqs = AWS::SQS.new aws_cred
      @kmonq = sqs.queues.named('gagra_kgs_months')
      @gameq = sqs.queues.named('gagra_games')
      @playerq = sqs.queues.named('gagra_players')
    end

    def deq_kmonq
      @kmonq.receive_message do |msg|
        puts "month url: #{msg.body}"
        yield msg
      end
    end

    def enq_games games
      serialized = games.map &:to_json
      enq_in_batches serialized, @gameq
      puts sprintf "enqueued: %d games", serialized.length
    end

    def enq_players usernames
      serialized = usernames.map { |un| JSON[{kgs_username: un}] }
      enq_in_batches serialized, @playerq
      puts sprintf "enqueued: %d players", serialized.length
    end

    private

    def enq_in_batches messages, queue
      msgs = messages.dup
      until msgs.empty? do
        queue.batch_send *msgs.shift(10)
      end
    end

    def aws_cred
      {
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      }
    end
  end
end
