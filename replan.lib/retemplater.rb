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
      .chomp
      .split(/^#{TIME_BRACKETS_SEPARATOR}/)

    raise "Unexpected number of time brackets found in the next date: #{next_date_time_brackets.size}" if next_date_time_brackets.size != TIME_BRACKETS_COUNT

    # Normalize the ending new lines.
    #
    template_time_brackets = @template
      .rstrip
      .concat("\n")
      .split(/^#{TIME_BRACKETS_SEPARATOR}/)

    raise "Unexpected number of time brackets found in the template: #{template_time_brackets.size}" if template_time_brackets.size != TIME_BRACKETS_COUNT

    new_date_sectin = next_date_time_brackets
      .zip(template_time_brackets)
      .map { |next_date_bracket, template_bracket| next_date_bracket + template_bracket }
      .join(TIME_BRACKETS_SEPARATOR)
      .concat(TIME_BRACKETS_SEPARATOR)
      .concat("\n")

    content.sub(next_date_section, new_date_sectin)
  end
end
