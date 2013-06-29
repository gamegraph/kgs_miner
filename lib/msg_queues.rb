require 'aws/sqs'
require 'json'

module KgsMiner
  class MsgQueues
    def initialize
      sqs = AWS::SQS.new aws_cred
      @gameq = sqs.queues.named('gagra_games')
    end

    def enq_games games
      serialized = games.map &:to_json
      enq_in_batches serialized, @gameq
      puts sprintf "enqueued: %d games", serialized.length
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
