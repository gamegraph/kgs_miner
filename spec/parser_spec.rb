require_relative '../lib/parser.rb'

describe KgsMiner::Parser do
  it 'parses html game table' do
    path = File.join([File.dirname(__FILE__)], '/input/1.xhtml')
    g = KgsMiner::Parser.new(File.read(path)).games
    g.should have(2).games
    g[0].white.should == "jared"
  end
end
