require 'English'

require_relative 'input_helper'
require_relative 'replan_parser'

class ReplanCodec
  # Used only to match the presence of the replan; the content is parsed by the parser
  #
  # Also invalid replans are matched (without data), which are checked only on actualy replanning; this
  # allows to convenient store placeholder replans in the future.
  #
  # The keywords are checked in the decoding stage.
  #
  REPLAN_REGEX = /\((replan.*)\)/
  private_constant :REPLAN_REGEX

  def initialize(input_helper: InputHelper.new)
    @input_helper = input_helper
  end

  # Returns an Openstruct with fields:
  #
  # - fixed      : `f` (optional)
  # - fixed_time : `HH:MM` (also sets :fixed; optional)
  # - skip       : `s` (optional)
  # - update     : `u` (optional)
  # - interval   : interval format
  # - next       : interval format (optional)
  #
  def extract_replan_tokens(line, allow_placeholder: false)
    replan_content = line[REPLAN_REGEX, 1]

    if allow_placeholder && replan_content == 'replan'
      OpenStruct.new
    else
      ReplanParser.new.parse(replan_content)
    end
  rescue => error
    raise "Error on line #{line.inspect}: #{error}"
  end

  def replan_line?(line)
    if line =~ REPLAN_REGEX
      # See REPLAN_REGEX comment.
      #
      true
    elsif line =~ /replan/
      # Make sure replans without parentheses (potential mistakes) are caught.
      #
      raise("Line with invalid `replan`: #{line}")
    else
      false
    end
  end

  def skipped_event?(line)
    !extract_replan_tokens(line, allow_placeholder: true).skip.nil?
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

    replan_data = ReplanParser.new.parse($LAST_MATCH_INFO[1])

    if no_replan
      description
    else
      keywords = " #{replan_data.fixed}#{replan_data.update}".rstrip
      replan_section = "(replan#{keywords} #{replan_data.interval}"

      if replan_data.update
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
