require "test/unit"
require "csv"
require_relative "../lib/ocr_parser"

class TestParser < Test::Unit::TestCase

  def test_parser
    gold_standard = CSV.read( "fixtures/gold_standard.csv" )
    text = OCRParser.new
    text.load_text( 'editions/Bouwman, André/Of Reynaert the Fox_ Text and /Bouwman_ Of Reynaert the Fox.txt' )
    text.models = [ Empty.new, Numbers.new, FootNote.new, AllCaps.new, English.new ]
    parsed = text.parse_to_annotated_array()
    mismatches = []
    for i in 0..gold_standard.size - 1
      if gold_standard[i] != parsed[i][0..1]
        mismatches.push( parsed[i].inspect() << " should be: " << gold_standard[i].inspect() )
      end
    end
    if mismatches.size() > 0
      puts mismatches
    end
    assert_equal( 0, mismatches.size() )
  end

end
