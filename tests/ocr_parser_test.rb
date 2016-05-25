require "test/unit"
require "csv"
require_relative "../lib/ocr_parser"

class TestParser < Test::Unit::TestCase

  def test_parser
    gold_standard = CSV.read( "fixtures/gold_standard.csv" )
    text = OCRParser.new
    text.load_text( 'editions/Bouwman, André/Of Reynaert the Fox_ Text and /Bouwman_ Of Reynaert the Fox.txt' )
    text.models = [ Empty.new, Numbers.new, FootNote.new, AllCaps.new, English.new ]
    i = 0
    text.parse_tuples do | accept, line |
      assert_equal( gold_standard[i], [ "#{accept ? "A" : "I"}", line ] )
      i += 1
    end
  end

end
