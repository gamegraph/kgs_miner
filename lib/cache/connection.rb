require 'delegate'
require 'pg'
require 'uri'

module KgsMiner
  module Cache
    class Connection < DelegateClass(PG::Connection)
      def initialize
        super PG.connect config
      end

      private

      def config
        uri = URI.parse ENV['DATABASE_URL']
        {
          host: uri.host,
          dbname: uri.path[1..-1],
          user: uri.user,
          password: uri.password
        }
      end
    end
  end
end
