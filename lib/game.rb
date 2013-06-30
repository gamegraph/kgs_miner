require 'json'

module KgsMiner
  class Game

    attr_reader :white, :black, :date, :result

    # KGS usernames are case-insensitively unique.  KGS itself
    # keeps track of the current capitalization of a username,
    # but we don't care, thus we `downcase` here and in our database.
    def initialize white, black, date, result
      @white = white.downcase
      @black = black.downcase
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
