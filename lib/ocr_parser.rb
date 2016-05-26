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
    @lines.each_with_index do |line, index|
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

  def parse_tuples
    active_multiline_models = []
    match_lines do |line, matches|
      matches.each do |model|
        active_multiline_models.reject! do |active_multiline_model|
          active_multiline_model.terminators.include? model
        end
        if model.terminators != nil
          active_multiline_models.push( model )
        end
      end
      if matches.size == 0 && active_multiline_models.size == 0
        yield true, line, matches
      else
        yield false, line, matches
      end
    end
  end

  def parse
    tuples = []
    parse_tuples { | accept, line | tuples.push line if accept }
    tuples
  end

end
