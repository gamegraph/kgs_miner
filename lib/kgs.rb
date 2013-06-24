require 'net/http'
require 'uri'

module KgsMiner
  module Kgs
    def self.get url
      Net::HTTP.get URI('http://www.gokgs.com/' + url)
    end

    def self.valid_month_url? url
      /^gameArchives\.jsp
        \?user=[a-zA-Z0-9]+
        &year=[0-9]+
        &month=[0-9]+$/x =~ url
    end
  end
end
