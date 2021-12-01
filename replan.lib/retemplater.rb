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

  def execute(content)
    next_date = find_first_date(content) + 1
    next_date_section = find_date_section(content, next_date)

    # A terminating blank line is considered part of a date section. For simplicity, we strip it.
    #
    next_date_time_brackets = next_date_section
      .split(/^#{TIME_BRACKETS_SEPARATOR}/, -1)
      .slice(0..-2)

    if next_date_time_brackets.empty?
      # When this happens, the template is added between the current and the next date sections, rather
      # than in the next date section.
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
