require_relative 'game_table_row'
require 'nokogiri'

module KgsMiner
  class Parser

    SORRY_MSGS = [
      "there are no games in the archives",
      "did not play any games during"
    ]

    def initialize str
      puts sprintf "parser rcd: %d bytes", str.bytesize
      @doc = Nokogiri::HTML str
    end

    def games
      return [] unless has_game_table?
      games = game_table_rows.select(&:game?).map &:to_game
      puts sprintf "parsed: %d games", games.length
      games
    end

    def has_game_table?
      if has_sorry_message?
        puts "parser: no game table"
        false
      else
        true
      end
    end

    def has_sorry_message?
      txt = all_text
      SORRY_MSGS.any? { |sorry| txt.include?(sorry) }
    end

    private

    def all_text
      @doc.xpath("//text()").to_s
    end

    def game_table
      @doc.css('table.grid').first
    end

    def game_table_rows
      rows = game_table.css('tr').to_a
      rows.shift # header
      rows.map { |row| GameTableRow.new(row) }
    end
  end
end
