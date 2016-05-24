require "test/unit"
require_relative "../lib/ocr_parse_models"
require_relative "../lib/ocr_parser"

class TestModels < Test::Unit::TestCase

  def test_all_caps_model
    all_caps_model = AllCaps.new
    assert_true( all_caps_model.matches( "ALL, CAPS" ) )
    assert_true( all_caps_model.matches( "90 ALL CAPS" ) )
    assert_false( all_caps_model.matches( "not ALL CAPS" ) )
    assert_false( all_caps_model.matches( "90 not ALL CAPS" ) )
    assert_false( all_caps_model.matches( "00" ) )
  end

  def test_foot_note_model
    foot_note = "6 It has been suggested that"
    foot_note_long_linenumber = "126 It has been suggested that"
    foot_note_multi_linenumber  = "42-48 The initially harmonious"
    non_foot_note = "lem completed Arnout’s unﬁnished work. However, "
    numbers = "123"
    numbers_o = "12o3"
    foot_note_model = FootNote.new
    assert_true( foot_note_model.matches( foot_note ) )
    assert_true( foot_note_model.matches( foot_note_long_linenumber ) )
    assert_true( foot_note_model.matches( foot_note_multi_linenumber ) )
    assert_false( foot_note_model.matches( non_foot_note ) )
    assert_false( foot_note_model.matches( numbers ) )
    assert_false( foot_note_model.matches( numbers_o ) )
  end

  def test_numbers_only_model
    numbers_only_model = Numbers.new
    assert_true( numbers_only_model.matches( "231" ) )
    assert_true( numbers_only_model.matches( "23o1" ) )
    assert_false( numbers_only_model.matches( "Babilonien" ) )
    assert_false( numbers_only_model.matches( "231 Babilonien" ) )
    assert_false( numbers_only_model.matches( "Babilo23nien" ) )
  end

  def test_empty_model
    empty_model = Empty.new
    assert_true( empty_model.matches( " " ) )
    assert_true( empty_model.matches( "   \t\t" ) )
    assert_true( empty_model.matches( "\t" ) )
    assert_false( empty_model.matches( "Babilonien" ) )
    assert_false( empty_model.matches( "    231 Babilonien" ) )
  end

end


class TestLineContext < Test::Unit::TestCase

  def test_line_context
    asert(false)
  end

end


class TestEnglishModel < Test::Unit::TestCase

  def test_english_model
    english_model = English.new
    # match 'to', 'at', and 'this'
    score = english_model.score( "to urge at this beginning" )
    assert_equal( 3/5.0, score )
    match = english_model.matches( "to urge at this beginning" )
    assert_true( match )
    # interpunction should be ignored, but not on don't
    score = english_model.score( "who don't thinks." )
    assert_equal( 2.0/3, score )
    score = english_model.score( ".,:;?!who?;:'‘’ don't thinks”." )
    assert_equal( 2.0/3, score )
    # match 'who', 'he' (0.4), 'it', and 'all'
    score = english_model.score( "who always thinks he knows it all." )
    assert_equal( 3.4/7, score )
    match = english_model.matches( "who always thinks he knows it all." )
    assert_true( match )
    english_model.threshold = 0.5
    match = english_model.matches( "who always thinks he knows it all." )
    assert_false( match )
    english_model.threshold = 0.2
    score = english_model.score( "die gherne pleghen der eeren" )
    assert_equal( 0, score )
    match = english_model.matches( "die gherne pleghen der eeren" )
    assert_false( match )
    score = english_model.score( "Hi hadde te hove so vele mesdaen" )
    assert_equal( 0.4/7, score )
    match = english_model.matches( "Hi hadde te hove so vele mesdaen" )
    assert_false( match )
  end

  def test_english_multiline
    lines = [ "this is an english line\n" ]
    lines.push( "die door een Nederlandse wordt gevolgd\n" )
    lines.push( "that is followed by yet another english line\n" )
    english_model = English.new
    assert_true( english_model.matches( lines[0] ) )
    assert_false( english_model.matches( lines[1] ) )
    assert_true( english_model.matches( lines[2] ) )
    line_context = LineContext.new( lines, 1 )
    english_model.line_context = line_context
    assert_true( english_model.matches( lines[0] ) )
    assert_true( english_model.matches( lines[1] ) )
    assert_true( english_model.matches( lines[2] ) )
    lines = [ "Maar dit is wel Nederlands\n" ]
    lines.push( "die door een Nederlandse wordt gevolgd\n" )
    lines.push( "that is followed by yet another english line\n" )
    line_context = LineContext.new( lines, 1 )
    english_model.line_context = line_context
    assert_false( english_model.matches( lines[0] ) )
    assert_false( english_model.matches( lines[1] ) )
    assert_true( english_model.matches( lines[2] ) )
  end

  def test_english_not_enough_context
    lines = [ "Dit is een Nederlandse regel\n" ]
    lines.push( "that is followed by another english line\n" )
    line_context = LineContext.new( lines, 0 )
    english_model = English.new
    assert_false( english_model.matches( lines[0] ) )
    assert_true( english_model.matches( lines[1] ) )
    english_model.line_context = line_context
    assert_false( english_model.matches( lines[0] ) )
    assert_true( english_model.matches( lines[1] ) )
  end

end


class TestIntegration < Test::Unit::TestCase

  def test_small_text
    small_text = OCRParser.new
    small_text.text = "THIS IS AN ALL CAPS LINE\nThis is not"
    small_text.models = [ AllCaps.new ]
    result = []
    small_text.match_lines{ |line, matches| result << [line, matches] }
    assert_equal( [["THIS IS AN ALL CAPS LINE", [AllCaps]], ["This is not", []]], result )
  end

  def test_another_small_text
    small_text = OCRParser.new
    small_text.text = "THIS IS AN ALL CAPS LINE\n123 This is footnote"
    small_text.models = [ AllCaps.new, FootNote.new ]
    result = []
    small_text.match_lines{ |line, matches| result << [line, matches] }
    assert_equal( [["THIS IS AN ALL CAPS LINE", [AllCaps]], ["123 This is footnote", [FootNote]]], result )
  end

end
