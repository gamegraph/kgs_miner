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
      uns = usernames.dup
      until uns.empty? do
        batch = uns.shift(10)
        enq_player_batch(batch)
        enq_kp_batch(batch)
      end
    end

    private

    def aws_cred
      {
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      }
    end

    def enq_kp_batch usernames
      @kpq.batch_send *usernames
      puts sprintf "enqueued: %d kgs usernames", usernames.length
    end

    def enq_player_batch usernames
      serialized_players = usernames.map { |un| JSON[{kgs_username: un}] }
      @playerq.batch_send *serialized_players
      puts sprintf "enqueued: %d players", serialized_players.length
    end
  end
end
