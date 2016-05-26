require "test/unit"
require "csv"
require_relative "../lib/ocr_parser"

class TestParser < Test::Unit::TestCase

  def test_parser_to_gold_standard
    gold_standard = CSV.read( "fixtures/gold_standard.csv" )
    text = OCRParser.new
    text.load_text( 'fixtures/Bouwman_ Of Reynaert the Fox_42-52.txt' )
    text.models = [ Empty.new, Numbers.new, FootNote.new, AllCaps.new, English.new ]
    i = 0
    text.parse_tuples do | accept, line |
      assert_equal( gold_standard[i], [ "#{accept ? "A" : "I"}", line ] )
      i += 1
    end
  end

  def test_parser
    text = OCRParser.new
    text.load_text( "fixtures/Bouwman_ Of Reynaert the Fox_42-52.txt" )
    text.models = [ Empty.new, Numbers.new, FootNote.new, AllCaps.new, English.new ]
    i = 0
    lines = text.parse()
    assert_equal( "Willem die Madocke maecte, [192va,22]", lines[0] )
    assert_equal( "daer hi dicken omme waecte,", lines[1] )
  end

end
