# @author Joris J. van Zundert

require_relative "ocr_parser"
require_relative "oo_models"

file_path = File.join( File.dirname(__FILE__), "../fixtures/Bouwman_ Of Reynaert the Fox.txt" )
text_parser = OCRParser.new
text_parser.load_text( file_path )
text_parser.models = [ Empty.new, Numbers.new, FootNote.new, AllCaps.new, English.new ]
parsed_text = text_parser.parse()
text = Text.new( parsed_text.join( "\n" ) )
File.open( File.join( File.dirname(__FILE__), "../notebook/resources/visualization_data.json" ), "w" ) do |file|
  file.write( text.as_json )
end
puts text.as_json
