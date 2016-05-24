# @author Joris J. van Zundert

# All models should implement two methods: {Model#matches} and {Model#parse}.
# The method {Model#matches} should accept a single text line as input and
# should return false or true. False means that the model does not fit the given
# line.
#
# Thus if a method {FootNote#matches} is called on a model amed Footnote and it
# returns falls, this means the given text is not a footnote.
#
# The method {Model#visit} takes a multiline [String] and returns an
# [Array<Object>] that for each line holds a value of either the model's name
# if the model fits that line, or NIL if not.
class Model

  attr_accessor :line_context

  # Determines if the model matches a line of text.
  # @param line [String] assumed to be a single line of text
  # @return [Boolean, true] if the model fits the give string 'line'.
  def matches( line )
    false
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


# Matches a line containing only numbers. 'o' (lower case letter o) is also
# accepted as the OCR frequently misreads 0 for o.
class Numbers < Model

  def matches( line )
    line.match( /^[\do]+$/ ) != nil
  end

end


# Matches an empty line.
class Empty < Model

  def matches( line )
    line.match( /^\s*$/ ) != nil
  end

end


# Matches a line that is likely to be english. Uses a list of English stopwords
# (of which a number of words are taken out as they might be Middledutch as
# well). A word that may be English or Middledutch will count towards English at
# a weight of 0.4 (instead of the ful 1.0). A (default) threshold regulates that
# if more than 20% of the words in a line are recognized as English stopwords,
# the line is probably English.
class English < Model

  def initialize
    @may_be_middle_dutch = [ "an", "as", "been", "by", "have", "he", "her", "here", "i", "in", "is", "me", "mine", "no", "so", "over", "was", "we" ]
    @hints = [ "prologue" ]
    @stopwords = File.read( './fixtures/stopwords_en.txt' ).split( "\n" ) - @may_be_middle_dutch + @hints
    @threshold = 0.2
  end

  # Sets threshold, 0.2 (20%) by default.
  # @param new_threshold [Real] ratio of English words needed to classify a line as
  # English
  def threshold=( new_threshold )
    @threshold = new_threshold
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
    score/tokens.size()
  end

  def above_treshold( line )
    score( line ) > @threshold
  end

  def matches( line )
    match = above_treshold( line )
    if @line_context != nil && !match
      empty_model = Empty.new
      if !empty_model.matches( line )
        # Post correction, if in between two english matches, it probably should be matched too
        prev = @line_context.previous_lines.reject { |line| empty_model.matches( line ) }
        succ = @line_context.next_lines.reject { |line| empty_model.matches( line ) }
        previous_matches = above_treshold( prev[0] ) if prev.size > 0
        next_matches = above_treshold( succ[0] ) if succ.size > 0
        match = true if (previous_matches && next_matches)
      end
    end
    match
  end

end


class LineContext

  attr_reader :previous_lines
  attr_reader :next_lines

  def initialize( lines, index )
    reversed_index = lines.size - index
    @previous_lines = lines.reverse()[reversed_index,10]
    @next_lines = lines[index+1,10]
  end

end
