require "test/unit"
require_relative "../lib/oo_models"

class TestOOModel < Test::Unit::TestCase

  def test_verse
    str = "verse line 1\nverse line 2\nverse line 3\nverse line 4\nverse line 5\n"
    text = Text.new( str )
    assert_equal( "verse", text.first_verse.first_word.surface )
    assert_equal( "line", text.first_verse.first_word.next_word.surface )
    assert_equal( "1", text.first_verse.first_word.next_word.next_word.surface )
    assert_equal( nil, text.first_verse.first_word.next_word.next_word.next_word )
    assert_equal( "verse", text.first_verse.next_verse.first_word.surface )
    assert_equal( "2", text.first_verse.next_verse.first_word.next_word.next_word.surface )
  end

  def test_json
    str = "verse line 1\nverse line 2\nverse line 3\nverse line 4\nverse line 5\n"
    text = Text.new( str )
    expected = "{ \"nodes\": [ { \"src\": \"Bouwman\", \"wrd\": \"verse\", \"x\": 0, \"y\": 0 }, { \"src\": \"Bouwman\", \"wrd\": \"line\", \"x\": 0, \"y\": 1 }, { \"src\": \"Bouwman\", \"wrd\": \"1\", \"x\": 0, \"y\": 2 }, { \"src\": \"Bouwman\", \"wrd\": \"verse\", \"x\": 0, \"y\": 3 }, { \"src\": \"Bouwman\", \"wrd\": \"line\", \"x\": 0, \"y\": 4 }, { \"src\": \"Bouwman\", \"wrd\": \"2\", \"x\": 0, \"y\": 5 }, { \"src\": \"Bouwman\", \"wrd\": \"verse\", \"x\": 0, \"y\": 6 }, { \"src\": \"Bouwman\", \"wrd\": \"line\", \"x\": 0, \"y\": 7 }, { \"src\": \"Bouwman\", \"wrd\": \"3\", \"x\": 0, \"y\": 8 }, { \"src\": \"Bouwman\", \"wrd\": \"verse\", \"x\": 0, \"y\": 9 }, { \"src\": \"Bouwman\", \"wrd\": \"line\", \"x\": 0, \"y\": 10 }, { \"src\": \"Bouwman\", \"wrd\": \"4\", \"x\": 0, \"y\": 11 }, { \"src\": \"Bouwman\", \"wrd\": \"verse\", \"x\": 0, \"y\": 12 }, { \"src\": \"Bouwman\", \"wrd\": \"line\", \"x\": 0, \"y\": 13 }, { \"src\": \"Bouwman\", \"wrd\": \"5\", \"x\": 0, \"y\": 14 }] }"
    assert_equal( expected, text.as_json )
  end

end
