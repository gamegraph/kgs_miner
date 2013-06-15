require_relative 'game'
require 'time'

module KgsMiner
  class GameTableRow
    def initialize row
      @cells = row.css 'td'
    end

    def to_game
      Game.new white, black, time.to_date, result
    end

    private

    def black
      @cells[2].css('a').first.text.split(' ').first
    end

    def result
      @cells[6].text.split('+').first
    end

    # Note that strptime format is different from strftime. :cry:
    # http://pubs.opengroup.org/onlinepubs/009695399/functions/strptime.html
    def time
      Time.strptime @cells[4].text, '%D %I:%M %p'
    end

    def white
      @cells[1].css('a').first.text.split(' ').first
    end
  end
end
