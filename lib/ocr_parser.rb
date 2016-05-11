require_relative "ocr_parse_models"

# OCRParser takes a text (OCRParser.new.text="a text" or .load_text( text )) and splits it on line breakds.
# Each line is matched to all the models provided. A Model tests if a line of text fits that model or not.
class OCRParser

  def text=( text )
    @text = text
    @lines = text.split( "\n" )
  end

  def load_text( file_path )
    self.text = File.read( file_path )
  end

  def each_line
    @lines.each_with_index do |item, index|
      if index == 0
        yield item, nil, @lines[1]
      elsif index == @lines.size - 1
        yield item, @lines[-2], nil
      else
        yield item, @lines[index-1], @lines[index+1]
      end
    end
  end

  def each_line_with_context
    @lines.each_with_index do |line,index|
      yield line, @lines[(index-10)..(index-1)].reverse, @lines[(index+1)..(index+10)]
    end
  end

  def match_lines( models )
    matches = []
    models.each { |model| matches.push( model.parse( self ) ) }
    matches = matches.transpose
    @lines.each_with_index do |line, index|
      matches[index] = [line, matches[index].compact]
    end
    matches
  end

  def parse_to_annotated_array
    models = [ Empty.new, Numbers.new, FootNote.new, AllCaps.new, English.new ]
    result = []
    context = Context.new
    matchinfo = match_lines( models )
    matchinfo.each do |lineinfo|
      matches = lineinfo[1]
      line = lineinfo[0]
      if matches.include?( FootNote )
        context.pop
        context.push( FootNote )
      end
      if matches.include?( AllCaps )
        context.pop
      end
      if context.last != FootNote
        if matches.size() == 0
          result.push( [ "A", line, matches ] )
        else
          result.push( [ "I", line, matches ] )
        end
      else
        result.push( [ "I", line, matches ] )
      end
    end
    result
  end

  def parse
    raw = parse_to_annotated_array()
    raw.reject! { |annotated_line| annotated_line[0] == "I" }
    raw.map! { |annotated_line| annotated_line[1] }
  end

end

class ParseLine

  attr_reader :line
  attr_reader :accepted

  def initialize( line, accepted )
    @line = line
    @accepted = accepted
  end

end

class Context

  def initialize
    @context = []
  end

  def push( state )
    @context.push( state )
  end

  def pop
    @context.pop
  end

  def last
    @context.last
  end

end
