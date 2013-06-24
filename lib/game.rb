require 'json'

module KgsMiner
  class Game

    attr_reader :white, :black, :date, :result

    def initialize white, black, date, result
      @white = white
      @black = black
      @date = date
      @result = result
    end

    def usernames
      [white, black]
    end

    def to_hash
      {white: white, black: black, date: date, result: result}
    end

    def to_json
      JSON[to_hash]
    end
  end
end
