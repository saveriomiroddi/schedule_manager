require 'English'

class ReplanCodec
  # The keywords are checked in the decoding stage.
  #
  # When changing anything here, search the occurrences of REPLAN_REGEX, and carefully examine them.
  #
  REPLAN_REGEX = Regexp.new(
    '\(replan' +
    '( (?:(f)(\d?\d:\d\d)?)?(s)?)?' +  # $2 (fixed), $3 (fixed time), $4 (skipped)
    '( \d+(?:\.\d+)?[wmy]?)?'       +  # $5 (encoded period)
    '( in (\d+(?:\.\d+)?[wmy]?))?'  +  # $7 (next occurrence encoded period)
    '\)'
  )
  private_constant :REPLAN_REGEX

  def extract_replan_tokens(line)
    # We don't verify the match here; if it fails, it's a programmatic error, and the problem is evident.
    #
    match = line.match(REPLAN_REGEX)

    is_fixed                       = match[2]
    fixed_time                     = match[3]
    is_skipped                     = match[4]
    encoded_period                 = match[5]&.lstrip
    next_occurrence_encoded_period = match[7]&.sub(' in ', '')

    [is_fixed, fixed_time, is_skipped, encoded_period, next_occurrence_encoded_period]
  end

  def replan_line?(line)
    if line =~ REPLAN_REGEX
      true
    elsif line =~ /replan/
      # Make sure ill-formed lines are caught.
      #
      raise("Line with invalid `replan`: #{line}")
    else
      false
    end
  end

  def skipped_event?(line)
    line.match(REPLAN_REGEX) && !!$LAST_MATCH_INFO[4]
  end

  def remove_replan(line)
    # The regex doesn't include the preceding whitespace, so it must be removed separately.
    #
    line.sub(REPLAN_REGEX, '').sub(/ +$/, '')
  end

  def rewrite_replan(line, no_replan)
    line.sub(REPLAN_REGEX) do |_|
      # Other groups are used to compute the next occurrence.
      #
      fixed_keyword = $LAST_MATCH_INFO[2]&.[](0) # don't include the time
      encoded_period = $LAST_MATCH_INFO[5]

      if no_replan
        ""
      else
        replan_section = "(replan"
        replan_section += " #{fixed_keyword}" if fixed_keyword
        replan_section += encoded_period

        replan_section + ")"
      end
    end
  end
end # class ReplanCodec
