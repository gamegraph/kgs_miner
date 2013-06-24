require 'aws/sqs'
require 'json'

module KgsMiner
  class MsgQueues
    def initialize
      sqs = AWS::SQS.new aws_cred
      @kmonq = sqs.queues.named('gagra_kgs_months')
      @kpq = sqs.queues.named('gagra_kgs_players')
      @gameq = sqs.queues.named('gagra_games')
      @playerq = sqs.queues.named('gagra_players')
    end

    def deq_kmonq
      @kmonq.receive_message { |msg| yield msg }
    end

    def enq_games games
      gms = games.dup
      until gms.empty? do
        batch = gms.shift(10)
        serialized_games = batch.map { |g| JSON[g.to_hash] }
        @gameq.batch_send *serialized_games
        puts sprintf "enqueued: %d games", serialized_games.length
      end
    end

    def enq_players usernames
      serialized = usernames.map { |un| JSON[{kgs_username: un}] }
      enq_in_batches serialized, @playerq
      puts sprintf "enqueued: %d players", serialized.length
    end

    def enq_usernames_to_request usernames
      enq_in_batches usernames, @kpq
      puts sprintf "enqueued: %d kgs usernames", usernames.length
    end

    private

    def enq_in_batches usernames, queue
      uns = usernames.dup
      until uns.empty? do
        queue.batch_send *uns.shift(10)
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
