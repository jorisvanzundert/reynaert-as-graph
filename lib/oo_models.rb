require "json"
require_relative "annotation_generator"

class Text

  attr_accessor :first_verse

  def initialize( str )
    @first_verse = Verse.new( str )
  end

  def as_text
    @first_verse.as_text
  end

  def as_json
    json = "{ \"nodes\": [ "
    json << @first_verse.as_json
    json << "] }"
    json
  end

end


class Verse

  attr_accessor :first_word
  attr_accessor :next_verse

  def initialize( str )
    m = str.match( /\n/ )
    if m != nil
      index = str.match( /\n/ ).end(0)
      @first_word = Word.new( str[ 0..index-2 ] )
      if str[ index..-1 ].size > 0
        @next_verse = Verse.new( str[ index..-1 ] )
      end
    else
      @first_word = Word.new( str )
    end
  end

  def as_text
    @first_word.as_text
    if @next_verse != nil
      print "\n"
      @next_verse.as_text
    end
  end

  def as_json( pos=0 )
    sub_json = @first_word.as_json( pos )
    json = sub_json[0]
    if @next_verse != nil
      json << ", "
      json << @next_verse.as_json(sub_json[1])
    end
    json
  end

end


class Word

  attr_accessor :surface
  attr_accessor :next_word
  attr_accessor :denotation

  def initialize( str )
    m = str.match( / / )
    if m != nil
      index = str.match( / / ).end(0)
      @surface = str[ 0..index-2 ]
      @next_word = Word.new( str[ index..-1 ] )
    else
      @surface = str
    end
    # This is utterly simplisitic, yet I have not better
    # idea at the moment…
    # Probably this should be done by models such as Person.
    # E.g. Person would determine if this Word is that Person.
    # That would also allow for competing interpretations btw.
    if surface.downcase == "willem"
      @denotation = Person.new( "Willem" )
      @denotation.annotations = AnnotationGenerator.get_annotations_for( "willem" )
    end
  end

  def as_text
    print @surface
    if @next_word != nil
      print " "
      @next_word.as_text
    end
  end

  def as_json( pos=0 )
    json = "{ \"src\": \"Bouwman\", \"wrd\": \"#{@surface}\", \"x\": 0, \"y\": #{pos}"
    if @denotation != nil
      json << ", \"denotation\": " << @denotation.as_json
    end
    json << " }"
    pos += 1
    if @next_word != nil
      json << ", "
      sub_json = @next_word.as_json( pos )
      json << sub_json[0]
      pos = sub_json[1]
    end
    [json,pos]
  end

end


class Person

  attr_accessor :name
  attr_accessor :annotations

  def initialize( name )
    @name = name
  end

  def as_json
    annotations_json = "{ \"class\": \"#{Person}\", \"name\": \"#{@name}\", \"annotations\": [ "
    annotations.each do |annotation|
      annotations_json << "{ \"annotation\": #{annotation.text.to_json}, \"source\": #{annotation.source.to_json} }, "
    end
    annotations_json = annotations_json[0..-3] << " ] }"
  end

end
