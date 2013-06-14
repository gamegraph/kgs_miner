#!/usr/bin/env ruby

require_relative 'game_table_row'
require 'nokogiri'

module KgsMiner
  class Parser
    def initialize str
      @str = str
    end

    def games
      game_table_rows.map &:to_hash
    end

    private

    def doc
      Nokogiri::HTML @str
    end

    def game_table
      doc.css('table.grid').first
    end

    def game_table_rows
      rows = game_table.css('tr').to_a
      rows.shift # header
      rows.map { |row| GameTableRow.new(row) }
    end
  end
end
