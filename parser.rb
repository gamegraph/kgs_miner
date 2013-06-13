#!/usr/bin/env ruby

require 'nokogiri'
require 'pp'

games = []

doc = Nokogiri::HTML(open('kgs.xhtml'))
t = doc.css('table.grid').first
rows = t.css('tr').to_a
rows.shift
rows.each do |r|
  cells = r.css('td')
  white = cells[1].css('a').first.text
  black = cells[2].css('a').first.text
  timestamp = cells[4].text
  result = cells[6].text
  games.push({white: white, black: black, timestamp: timestamp, result: result})
end

pp games
