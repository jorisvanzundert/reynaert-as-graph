# All models should implement two methods: matches and parse.
# The method matches should accept a single text line as input and should return false or true.
# False means that the model does not fit the given line. Thus if a method .matches( line) called on a model
# named Footnote returns falls, this means the given text is not a footnote.
#
# does this header
# ============
#
# The methods 'parse' takes a multiline string and returns an array that for each line holds
# a value of either the model's name if the model fits that line, or NIL if not.
class Model

  # Returns true if the model fits the give string 'line'.
  # 'line' is assumed to be a single line of text.
  def matches( line )
    false
  end

  # Parses a multiline text and returns an array contained per line
  # a value of either the model's name (class) or NIL if the model
  # saw no fit with the given line.
  def parse( text )
    matches = []
    text.each_line do |line|
      if matches( line )
        matches.push( self.class )
      else
        matches.push( nil )
      end
    end
    matches
  end

end

# Matches a line that only contains capitals.
class AllCaps < Model

  def matches( line )
    # string.match( /^[^a-z]+$/ ) != nil
    # string.match( /^[\p{Lu}+|\s]+$/ ) != nil
    !!line.match( /[[:upper:]]/ ) && !!!line.match( /[[:lower:]]/ )
  end

end

# Matches a line starting with at least one digit, followed by a dash or a space.
class FootNote < Model

  def matches( line )
    line.match( /^\d+(-| )(.+)$/ ) != nil
  end

end

# Matches a line containing only numbers.
# 'o' is also accepted as the OCR frequently misreads 0 for o.
class Numbers < Model

  def matches( line )
    line.match( /^[\do]+$/ ) != nil
  end

end

# Matches an empty line
class Empty < Model

  def matches( line )
    line.match( /^\s*$/ ) != nil
  end

end

# Matches a line that is likely to be english.
# Uses a list of English stopwords (of which a number of words are taken out as they might be Middledutch as well).
# A word that may be English or Middledutch will count towards English at a weight of 0.4 (instead of the ful 1.0).
# A (default) treshold regulates that if more than 20% of the words in a line are recognized as English stopwords, the line is probably English.
class English < Model

  def initialize
    @may_be_middle_dutch = [ "an", "as", "been", "by", "have", "he", "her", "here", "i", "in", "is", "me", "mine", "no", "so", "over", "was", "we" ]
    @hints = [ "prologue" ]
    @stopwords = File.read( './fixtures/stopwords_en.txt' ).split( "\n" ) - @may_be_middle_dutch + @hints
    @treshold = 0.2
  end

  # Sets treshold, 0.2 (20%) by default.
  def treshold=( new_treshold )
    @treshold = new_treshold
  end

  def strip_embracing_punctuation( token )
    return token.gsub(/[\.:;'“‘’”?!\(\),]+$|^[\.:;'“‘’”?!\(\),]+/, '')
  end

  def score( string )
    score = 0.0
    tokens = string.split( /\s+/ )
    tokens.each do |token|
      stripped = strip_embracing_punctuation( token )
      score += 1.0 if @stopwords.include?( stripped.downcase )
      score += 0.4 if @may_be_middle_dutch.include?( stripped.downcase )
    end
    if string.eql?("Prologue")
      puts "score: #{score}"
    end
    score/tokens.size()
  end

  def matches( line )
    score( line ) > @treshold
  end

  def parse( text )
    matches=[]
    text.each_line_with_context do | line, prev, succ |
      if matches( line )
        matches.push( self.class )
      else
        empty_model = Empty.new
        if !empty_model.matches( line )
          # Post correction, if in between two english matches, it probably should be matched too
          prev.reject! { |line| empty_model.matches( line ) }
          succ.reject! { |line| empty_model.matches( line ) }
          previous_matches = matches( prev[0] ) if prev.size > 0
          next_matches = matches( succ[0] ) if succ.size > 0
          if previous_matches && next_matches
            matches.push( self.class )
          else
            matches.push( nil )
          end
        else
          matches.push( nil )
        end
      end
    end
    matches
  end

end
