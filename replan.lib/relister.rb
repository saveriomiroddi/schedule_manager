require_relative 'adjusted_date_wday'
require_relative 'relister'
require_relative 'replan_codec'
require_relative 'replan_helper'

require 'English'

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
    interval_start = Date.today + 1
    interval_end = interval_start + DEFAULT_DAYS_LISTED - 1

    (interval_start..interval_end).inject(nil) do |previous_date, date|
      if previous_date && date.adjusted_wday < previous_date.adjusted_wday
        puts "====="
        puts
      end

      section = find_date_section(content, date, allow_not_found: true)

      next if section.nil?

      header = section.lines.first
      events = section.lines.grep(EVENTS_REGEX).select(&@replan_codec.method(:replan_line?))

      if !events.empty?
        puts header

        events.each do |event|
          if !skipped_event?(event)
            puts event.lstrip.sub(/\(replan.*\)$/, '')
          end
        end

        puts
      end

      date
    end
  end

  private

  def skipped_event?(line)
    @replan_codec.skipped_event?(line)
  end
end # class Relister
