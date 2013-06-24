require 'pg'
require 'uri'

module KgsMiner
  module Cache
    class Base
      def initialize conn, opts = {}
        @conn = conn
        @read_only = opts[:read_only] || false
      end

      def discover strs
        in_clause = 1.upto(strs.length).map { |i| "$" + i.to_s }.join(', ')
        qry = "select #{column} from #{table} where #{column} in (#{in_clause})"
        rslt = @conn.exec_params qry, strs
        (Set.new(strs) - rslt.field_values(column)).to_a
      end

      def hit? str
        qry = "select * from #{table} where url = $1 limit 1"
        rslt = @conn.exec_params qry, [str]
        rslt.ntuples == 1
      end

      def << str
        raise "Cache is readonly" if @read_only
        begin
          @conn.exec_params "insert into #{table} (#{column}) values ($1)", [str]
        rescue PG::Error => e
          unless e.message.to_s.include? 'violates unique constraint'
            raise e
          end
        end
      end
    end

    class MonthUrlCache < Base
      def table() 'kgs_month_urls'.freeze end
      def column() 'url'.freeze end
    end

    class UsernameCache < Base
      def table() 'kgs_usernames'.freeze end
      def column() 'un'.freeze end
    end
  end
end
