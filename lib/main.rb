require 'aws/sqs'
require_relative 'parser'
require 'pp'

# Tell ruby not to buffer stdout
# https://github.com/ddollar/foreman/wiki/Missing-Output
$stdout.sync = true

def aws_cred
  {
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  }
end

sqs = AWS::SQS.new aws_cred
docq = sqs.queues.named('docs_kgs')

while true do
  begin
    docq.poll(idle_timeout: 3) do |msg|
      puts sprintf "q msg rcd: %d bytes", msg.body.bytesize
      pp KgsMiner::Parser.new(msg.body).games
    end
  rescue
    $stderr.puts "excp during q poll: $!"
  end
  sleep 30
end
