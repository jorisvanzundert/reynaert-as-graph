require "test/unit"
require_relative "../lib/annotation_generator"

class TestOOModel < Test::Unit::TestCase

  def test_generator
    annotations = AnnotationGenerator.get_annotations_for( "willem" )
    # But not those about "Willem de Vreese"…
    annotations.reject! { |annotation| annotation.text.downcase.match( /willem de vreese/ ) != nil }
    assert_equal( 33, annotations.size )
  end

end
