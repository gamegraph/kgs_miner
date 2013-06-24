require 'net/http'
require 'uri'

module KgsMiner
  module Kgs
    def self.get url
      Net::HTTP.get URI('http://www.gokgs.com/' + url)
    end

    def self.valid_month_url? url
      /^gameArchives\.jsp
        \?( # the query string contains ..
          user=[a-zA-Z0-9]+| # a user name, or
          year=[0-9]+| # a year, or
          month=[0-9]+| # a month, or
          oldAccounts=[yt]| # that flag, or
          & # an ampersand
        ){5,7} # and it must have 5..7 of the above, the oldAccounts flag is optional
        $/x =~ url
    end
  end
end
