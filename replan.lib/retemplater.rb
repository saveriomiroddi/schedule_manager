require_relative "replan_helper"
require_relative "shared_constants"

# Fill the next date (first date + 1) with the template.
#
class Retemplater
  include ReplanHelper
  include SharedConstants

  # template: String (filename) or IO (content).
  #
  def initialize(template)
    @template = template.respond_to?(:read) ? template.read : IO.read(template)
  end

  # TODO: This logic should be implemented by multiple invocations to ReplanHelper#add_line_to_date_section,
  # in order to use a single logic to add entries to a date (it's inefficient, but it doesn't matter).
  #
  def execute(content)
    next_date = find_first_date(content) + 1
    next_date_section = find_date_section(content, next_date)

    # A terminating blank line is considered part of a date section. For simplicity, we strip it.
    #
    next_date_time_brackets = next_date_section
      .split(/^#{TIME_BRACKETS_SEPARATOR}/, -1)
      .slice(0..-2)

    if next_date_time_brackets.empty?
      # TODO: The purpose of this is to avoid inappropriate additions. It's somewhat confusing, and
      # most importantly, inconsistent (it prevents merging the code as described in the TODO above);
      # a clean solution is to check if the next section of code (after the space) has a correct date
      # header.
      #
      # When this happens, the template is added between the current and the next date sections, rather
      # than in the next date section. See test suite.
      #
      raise "Fix Retemplater bug when no time brackets are found (see code comment)!"
    elsif next_date_time_brackets.size > TIME_BRACKETS_COUNT
      raise "Too many time brackets found in date #{next_date}: #{next_date_time_brackets.size}"
    else
      missing_brackets = TIME_BRACKETS_COUNT - next_date_time_brackets.size
      next_date_time_brackets += [''] * missing_brackets
    end

    template_time_brackets = @template
      .split(/^#{TIME_BRACKETS_SEPARATOR}/, -1)
      .slice(0..-2)

    raise "Unexpected number of time brackets found in the template: #{template_time_brackets.size}" if template_time_brackets.size != TIME_BRACKETS_COUNT

    new_date_section = next_date_time_brackets
      .zip(template_time_brackets)
      .map { |next_date_bracket, template_bracket| next_date_bracket + template_bracket }
      .join(TIME_BRACKETS_SEPARATOR)
      .concat(TIME_BRACKETS_SEPARATOR)
      .concat("\n")

    content.sub(next_date_section, new_date_section)
  end
end
