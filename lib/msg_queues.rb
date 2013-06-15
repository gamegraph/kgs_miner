require 'aws/sqs'

module KgsMiner
  class MsgQueues
    def initialize
      sqs = AWS::SQS.new aws_cred
      @docq = sqs.queues.named('gagra_kgs_docs')
      @kpq = sqs.queues.named('gagra_kgs_players')
      @gameq = sqs.queues.named('gagra_games')
      @playerq = sqs.queues.named('gagra_players')
    end

    def poll_docq
      @docq.poll(idle_timeout: 3) do |msg|
        yield msg
      end
    end

    def enq_games games
      return if games.empty?
      @gameq.send_message JSON[games.map(&:to_hash)]
      puts sprintf "enqueued: %d games", games.length
    end

    def enq_players usernames
      return if usernames.empty?
      players = usernames.map { |un| {kgs_username: un} }
      @playerq.send_message JSON[players]
      puts sprintf "enqueued: %d players", usernames.length
      @kpq.send_message JSON[usernames]
      puts sprintf "enqueued: %d kgs usernames", usernames.length
    end

    private

    def aws_cred
      {
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      }
    end
  end
end
