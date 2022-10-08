require_relative 'adjusted_date_wday'
require_relative 'relister'
require_relative 'replan_codec'
require_relative 'replan_helper'

require 'English'
require 'stringio'

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

# Simple listing of the main events
#
class Relister
  include ReplanHelper
  using AdjustedDateWday

  DEFAULT_DAYS_LISTED = 21
  EVENTS_REGEX = /^\s*\*/

  def initialize
    @replan_codec = ReplanCodec.new
  end

  def execute(content)
    formatter = TextFormatter.new

    interval_start = Date.today + 1
    interval_end = interval_start + DEFAULT_DAYS_LISTED - 1

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
