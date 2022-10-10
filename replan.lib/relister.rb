require_relative 'adjusted_date_wday'
require_relative 'relister'
require_relative 'replan_codec'
require_relative 'replan_helper'

require 'date'
require 'English'
require 'stringio'
require 'json'

class TextFormatter
  def initialize
    @buffer = StringIO.new
  end

  def add_delimiter
    @buffer.puts "====="
    @buffer.puts
  end

  def start_date(date)
    @buffer.puts(date)
  end

  def add_event(title)
    @buffer.puts(title)
  end

  def end_date
    @buffer.puts
  end

  def finalize
    @buffer.string
  end
end

# Format:
#
# [
#   {"date": "<YYYY-mm-dd>", "title": "<title>"},
#   ...
# ]
#
class JsonFormatter
  EXPECTED_DATE_FORMAT = %r{^ +[A-Z]{3} (\d{2}/[A-Z]{3}/\d{4})\n$}
  EXPECTED_TITLE_FORMAT = /^([!*]) (.+)\n/

  def initialize
    @data = []
    @current_date = nil
  end

  def add_delimiter
    # do nothing!
  end

  def start_date(raw_date)
    raise "Invalid date: #{raw_date.inspect}" if raw_date !~ EXPECTED_DATE_FORMAT
    @current_date = Date.parse($LAST_MATCH_INFO[1])
  end

  def add_event(raw_title)
    raise "Invalid title: #{raw_title.inspect}" if raw_title !~ EXPECTED_TITLE_FORMAT
    @data << {date: @current_date.strftime("%F"), title: $LAST_MATCH_INFO[2], type: $LAST_MATCH_INFO[1]}
  end

  def end_date
    @current_date = nil
  end

  def finalize
    JSON.pretty_generate(@data)
  end
end

# Simple listing of the main events
#
class Relister
  include ReplanHelper
  using AdjustedDateWday

  DEFAULT_DAYS_LISTED = 21
  EVENTS_REGEX = /^\s*[*!]/

  def initialize
    @replan_codec = ReplanCodec.new
  end

  def execute(content, json:)
    interval_start = Date.today + 1

    formatter_class, interval_end = if json
      [JsonFormatter, find_last_date(content)]
    else
      [TextFormatter, interval_start + DEFAULT_DAYS_LISTED - 1]
    end

    formatter = formatter_class.new

    (interval_start..interval_end).inject(nil) do |previous_date, date|
      if previous_date && date.adjusted_wday < previous_date.adjusted_wday
        formatter.add_delimiter
      end

      section = find_date_section(content, date, allow_not_found: true)

      next if section.nil?

      header = section.lines.first
      events = section.lines.grep(EVENTS_REGEX)

      if events.empty?
        previous_date
      else
        formatter.start_date(header)

        events.each do |event|
          if !@replan_codec.replan_line?(event)
            formatter.add_event(event.lstrip)
          elsif !skipped_event?(event)
            formatter.add_event(event.lstrip.sub(/ \(replan.*\)$/, ''))
          end
        end

        formatter.end_date

        date
      end
    end

    output = formatter.finalize

    print output
  end

  private

  def skipped_event?(line)
    @replan_codec.skipped_event?(line)
  end
end # class Relister
