# @author Joris J. van Zundert

require_relative "ocr_parse_models"

# OCRParser takes a text and splits it on line breaks.
# Each line is matched to all the models provided.
# A Model tests if a line of text fits that model or not.
class OCRParser

  # @param models [Array<Model>] the models to match against each line of the text
  attr_accessor :models

  # @param text [String] the text to be parsed as a string
  def text=( text )
    @text = text
    @lines = text.split( "\n" )
  end

  # @param file_path [String] the path to the file having the text to be parsed
  def load_text( file_path )
    self.text = File.read( file_path )
  end

  def match_lines
    @lines.each_with_index do |line,index|
      matches = []
      @models.each do |model|
        model.line_context = LineContext.new( @lines, index )
        if model.matches( line )
          matches.push( model.class )
        end
      end
      yield line, matches
    end
  end

  # This needs to be adjusted (and that adjustment should go into the notebook).
  # The problem is that the knowledge that the footnote model may stretch
  # multiple lines is now embeddd in this method, but it should be knowledge
  # of the model and that can be 'handed' to the parser.
  def parse_to_annotated_array
    result = []
    context = []
    match_lines do |line, matches|
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
