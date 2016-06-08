require 'open-uri'

module AnnotationGenerator

  def AnnotationGenerator.get_sentences
    if @sentences == nil
      @sentences = []
      text = ""

      # NOTE: this will require poppler be installed#
      # File variant so we don't hurt the OAPserver so much
      File.open( File.join( File.dirname(__FILE__), "../notebook/resources/340003.pdf"), "rb" ) do |url_source|
      # Use this open-uri::open variant for real
      #open( "http://www.oapen.org/download?type=document&docid=340003" ) do |url_source|
        IO.popen( "pdftotext - -", mode='r+') do |io|
          io.write url_source.read
          io.close_write
          text << io.read
        end
      end

      # We can do with setting a title for the source manually for now.
      @annotations_source = "Bouwman, A. & Besamusca, B., 2009. Of Reynaert the Fox: Text and Facing Translation of the Middle Dutch Beast Epic Van den vos Reynaerde, Amsterdam: Amsterdam University Press. Available at: http://www.oapen.org/search?identifier=340003 [Accessed November 20, 2015]."

      # Next thing I hold equivalent to scholarly 'only reading the introduction'.
      end_index = text.index( /39\s+Text, translation and note/ )

      # We don't need line breaks…
      text = text[0..end_index].gsub( "\n", " " )

      # Split text into sentences.
      each_sentence( text ) { |sentence| @sentences.push( sentence ) }

      # There's weird whitespace artefacst in the text at line beginnings,
      # let's remove those.
      @sentences.map!{ |sentence| sentence.gsub( /^[^\p{Word}]*/, "") }
    end
    @sentences.clone
  end

  # Split into sentences.
  # Crude! NLTK might perform better, but this serves to demonstrate the point.
  # Reduces the amount of errors in splitting the text
  # into sentences by marking as much as possible periods
  # that are related to acronymic or other non sentence ending use.
  def AnnotationGenerator.each_sentence( text, report_analytics=false )
    sentence = ""
    while text.match( /(\S+)\.(\s+\S+\s+)/ ) != nil do
      last_match = Regexp.last_match
      sentence << last_match.pre_match
      score_parts = []
      # +2 control characters
      score_parts.push( last_match[0].match( /[\u0006\u0010\u0011\u0012\u0013\u0015\u000E]+/ ) != nil ? 2 : 0 )
      # +2 period is followed by a whitespace and Captial UNLESS ms. or cf.
      score_parts.push( ( (last_match[1].match( /\b[Mm]s|[\bCc]f/ ) == nil) && (last_match[0].match( /\S+\.\s+\p{Lu}/ ) != nil) ) ? 2 : 0  )
      # +1 Most likely page reference
      score_parts.push( last_match[0].match( /\(\d+-\d+\)/ ) != nil ? 1 : 0 )
      # +1.5 Most likely sentence followed by footnote or page number
      score_parts.push( last_match[0].match( /\d+.\.\s+\d+/ ) != nil ? 1.5 : 0 )
      # -1/n chars: the shorter the more likely it is a acronym
      score_parts.push( -1.0/last_match[0].match( /(\S+)\./ )[1].size )
      # -1 period is followed by a whitespace and lower case
      score_parts.push( last_match[0].match( /\S+\.\s+\p{Ll}/ ) != nil ? -1 : 0 )
      # -1 no vowls
      score_parts.push( ( last_match[0].match( /(\S+)\./ )[1].scan( /\w/ ) & "aeiou".scan( /\w/ ) ).size == 0 ? -1 : 0 )
      score = 0
      score_parts.each { |score_part| score+=score_part }
      sentence << last_match[1] << "."
      if report_analytics
        yield [sentence, score, score_parts, last_match[0] ]
      end
      if score > -0.2
        yield sentence if !report_analytics
        sentence = ""
      end
      text = last_match[2] << last_match.post_match
    end
  end

  def AnnotationGenerator.get_annotations_for( str )
    sentences = get_sentences
    sentences.reject! { |sentence| sentence.downcase.match( /#{str}\b/ ) == nil }
    sentences.map! { |sentence| Annotation.new( sentence, @annotations_source ) }
  end

end


class Annotation

  attr_accessor :text
  attr_accessor :source

  def initialize( text, source )
    @text = text
    @source = source
  end

end
