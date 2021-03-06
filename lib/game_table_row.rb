require_relative 'game'
require 'time'

module KgsMiner
  class GameTableRow
    def initialize row
      @cells = row.css 'td'
      assert_cell_count @cells
    end

    def game?
      %w[ranked free].include? type
    end

    def to_game
      Game.new white, black, time.to_date, result
    end

    private

    def assert_cell_count cells
      unless [6,7].include? cells.length
        raise "Unexpected cell count: #{@cells.length}"
      end
    end

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

    def type
      @cells[-2].text.downcase
    end

    def white
      @cells[1].css('a').first.text.split(' ').first
    end
  end
end
