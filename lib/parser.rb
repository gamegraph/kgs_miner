#!/usr/bin/env ruby

require_relative 'game_table_row'
require 'nokogiri'

module KgsMiner
  class Parser
    def initialize str
      puts sprintf "parser rcd: %d bytes", str.bytesize
      @doc = Nokogiri::HTML str
    end

    def games
      return [] unless has_game_table?
      games = game_table_rows.map &:to_game
      puts sprintf "parsed: %d games", games.length
      games
    end

    def has_game_table?
      if all_text.include? "did not play any games during"
        puts "parser: no game table"
        false
      else
        true
      end
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
