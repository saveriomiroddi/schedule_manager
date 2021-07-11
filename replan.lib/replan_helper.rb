require 'date'

require_relative "shared_constants"

module ReplanHelper
  include SharedConstants

  DATE_HEADER_TEMPLATE = '    %a %d/%b/%Y'
  private_constant :DATE_HEADER_TEMPLATE

  # Matches day_word, day_number, month, [year]
  #
  # Minor simplification handling the slash preceding the year.
  #
  DATE_HEADER_REGEX = %r(^(    (\S{3}) (\d{2})/(\w{3})/?(\d{4})?))
  private_constant :DATE_HEADER_REGEX

  ##################################################################################################
  # FINDING
  ##################################################################################################

  def find_header_matches(content)
    matches = content.scan(DATE_HEADER_REGEX)

    matches.empty? ? raise("No dates found!") : matches
  end

  # Convenience method. Raises an error if the date is greater than the current date!
  #
  def find_first_date(content)
    first_header = find_header_matches(content).first
    first_date = convert_header_to_date(first_header)

    raise "First date is in the future!" if first_date > Date.today

    first_date
  end

  def find_all_dates(content)
    headers = find_header_matches(content)
    headers.map(&method(:convert_header_to_date))
  end

  # After getting the value, check if it matches the date, to know if it's an existing entry!
  #
  #===
  #
  # This method could use `header_matches`, however, since `content` is modified, `header_matches` should
  # be kept in sync, which is easy to forget. Performance is not a concern, so this takes the safe route.
  #
  def find_preceding_or_existing_date(content, date)
    header_matches = find_header_matches(content)
    header_dates = header_matches.map(&method(:convert_header_to_date))

    raise "Target date is earlier than then the first available!" if date < header_dates.first

    header_dates.each_cons(2) do |previous_date, next_date|
      if previous_date >= next_date
        raise "Inconsistent consecutive dates found!: #{previous_date}, #{next_date}"
      end

      return previous_date if previous_date <= date && date < next_date
    end

    header_dates.last
  end

  # Includes the trailing (separating) newline.
  #
  def find_date_section(content, date)
    today_header = convert_date_to_header(date)
    today_section_regex = /^#{Regexp.escape(today_header)}.*?^\n/m

    content[today_section_regex] || raise("Section not found for date: #{date}")
  end

  ##################################################################################################
  # MODIFICATION
  ##################################################################################################

  def add_new_date_section(content, preceding_date, new_date)
    preceding_date_header = convert_date_to_header(preceding_date)
    preceding_date_section_regex = /^(#{Regexp.escape(preceding_date_header)}.*?^\n)/m

    new_date_header = convert_date_to_header(new_date)

    raise "Preceding date (#{preceding_date}) not found!" if content !~ preceding_date_section_regex

    new_date_section = <<~TXT
      #{new_date_header}
      #{TIME_BRACKETS_SEPARATOR}
      #{TIME_BRACKETS_SEPARATOR}
      #{TIME_BRACKETS_SEPARATOR}
      #{TIME_BRACKETS_SEPARATOR}

    TXT

    content.sub(preceding_date_section_regex, "\\1#{new_date_section}")
  end

  # Line is added as first in the section.
  #
  # new_line: doesn't matter if it ends with a newline or note.
  #
  def add_line_to_date_section(content, date, new_line)
    date_header = convert_date_to_header(date)
    date_header_regex = /^(#{Regexp.escape(date_header)}.*\n)/

    # Line is too semantically ambiguous, so handle any case.
    #
    new_line = new_line.sub(/\n?$/, "\n")

    content.sub(date_header_regex, "\\1#{new_line}")
  end

  ##################################################################################################
  # DATA CONVERSION
  ##################################################################################################

  def convert_header_to_date(header_match)
    _, _, day_number, month_word, year = header_match

    day_number = day_number.to_i
    year = year.to_i

    month_number = Date.parse(month_word).month

    Date.new(year, month_number, day_number)
  end

  def convert_date_to_header(date)
    date.strftime(DATE_HEADER_TEMPLATE).upcase
  end
end
