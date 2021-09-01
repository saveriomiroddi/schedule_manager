require 'English'
require_relative 'input_helper'

class ReplanCodec
  # The keywords are checked in the decoding stage.
  #
  # When changing anything here, search the occurrences of REPLAN_REGEX, and carefully examine them.
  #
  REPLAN_REGEX = Regexp.new(
    '\(replan' +
    '( (?:(f)(\d?\d:\d\d)?)?(s)?(u)?)?' + # $2 (fixed), $3 (fixed time), $4 (skipped), $5 (update)
    '( \d+(?:\.\d+)?[wmy]?)?'       +  # $6 (encoded period)
    '( in (\d+(?:\.\d+)?[wmy]?))?'  +  # $8 (next occurrence encoded period)
    '\)'
  )
  private_constant :REPLAN_REGEX

  def initialize(input_helper: InputHelper.new)
    @input_helper = input_helper
  end

  def extract_replan_tokens(line)
    # We don't verify the match here; if it fails, it's a programmatic error, and the problem is evident.
    #
    line.match(REPLAN_REGEX)

    is_fixed                       = $LAST_MATCH_INFO[2]
    fixed_time                     = $LAST_MATCH_INFO[3]
    is_skipped                     = $LAST_MATCH_INFO[4]
    to_update                      = $LAST_MATCH_INFO[5]
    encoded_period                 = $LAST_MATCH_INFO[6]&.lstrip
    next_occurrence_encoded_period = $LAST_MATCH_INFO[8]&.sub(' in ', '')

    [is_fixed, fixed_time, is_skipped, to_update, encoded_period, next_occurrence_encoded_period]
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
    !!(line.match(REPLAN_REGEX) && $LAST_MATCH_INFO[4])
  end

  def remove_replan(line)
    # The regex doesn't include the preceding whitespace, so it must be removed separately.
    #
    line.sub(REPLAN_REGEX, '').sub(/ +$/, '')
  end

  def rewrite_replan(line, no_replan)
    # There's not "String#split_at"-like method in Ruby. There are lots of clever alternatives, but
    # they're not worth.
    #
    replan_i = line.index(REPLAN_REGEX)
    description, replan = line[0...replan_i], [replan_i..]

    # Other groups are used to compute the next occurrence.
    #
    fixed_keyword = $LAST_MATCH_INFO[2]&.[](0) # don't include the time
    update_keyword = $LAST_MATCH_INFO[5]
    encoded_period = $LAST_MATCH_INFO[6]

    if no_replan
      description
    else
      keywords = " #{fixed_keyword}#{update_keyword}".rstrip
      replan_section = "(replan#{keywords}#{encoded_period}"

      if update_keyword
        description_prefix = description[...2]
        # The description has a space before the replan, so we need to remove it and readd it.
        #
        description_body = description[2...-1]
        description_body = @input_helper.ask("Enter the new description:", prefill: description_body)

        description = "#{description_prefix}#{description_body} "
      end

      description + replan_section + ")"
    end
  end
end # class ReplanCodec
