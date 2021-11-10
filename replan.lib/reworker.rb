require 'English'

require_relative 'replan_helper'

# Compute the work for the current day, and add it to the next.
#
class Reworker
  include ReplanHelper
  include SharedConstants

  # New line is inserted after this.
  #
  INSERTION_POINT_PATTERN = /^( +)(- RSS, email\n)/

  # Valid reduction/intervals:
  #
  # - 666, 66h, 66.66h
  # - -666, -66h, -66.66h
  #
  # That part of the regexp is for the lulz, and in order to easily understand it, after `-?\d+`, read
  # it from `h)?` backwards.
  #
  WORK_TASK_PATTERN = /^( *)[-~]( \d+:\d+\.)? work( -?\d+((\.\d+)?h)?)?$/

  ADDED_TASK_TEMPLATE = "- lpimw -t ye '%s' # -c half|off\n"

  # - (start_time, end_time, reduction) and (interval) are two mutually exclusive groups
  #
  # - end_time is set when the next entry is found
  # - reduction is optional
  #
  WorkEntry = Struct.new(:original_line, :indentation, :start_time, :end_time, :reduction, :interval) do
    def self.from(hash)
      hash.each_with_object(self.new) do |(key, value), entry|
        entry[key] = value
      end
    end

    def to_s
      if interval
        interval
      else
        "#{start_time}-#{end_time} #{reduction}".rstrip
      end
    end

    def inspect
      original_line.inspect
    end
  end

  def execute(content)
    current_date = find_first_date(content)
    current_date_section = find_date_section(content, current_date)

    work_times = extract_work_times(current_date_section)

    next_date = current_date + 1
    next_date_section = find_date_section(content, next_date)

    new_next_date_section = add_lpim_to_next_day(next_date_section, work_times)

    content.sub(next_date_section, new_next_date_section)
  end

  def extract_work_times(section)
    work_entries = []

    # Having the current entry simplifies the logic, rather than inspecting the last work_entries values
    # to understand if it's current or not.
    #
    current_work_entry = nil

    entries = section.rstrip.lines[1..] # skip header

    entries.each do |line|
      work_line_match = line.match(WORK_TASK_PATTERN)

      if work_line_match
        raise "Work entries can\'t follow each other! (previous: #{current_work_entry.inspect})" if current_work_entry

        indentation, start_time, interval_or_reduction = work_line_match[1..3]

        start_time = start_time&.lstrip&.chomp('.')
        interval_or_reduction = interval_or_reduction&.lstrip

        case interval_or_reduction
        when /^-/
          reduction = interval_or_reduction
        when //
          interval = interval_or_reduction
        end

        if interval
          # In this case, we don't need a closing entry.
          #
          work_entries << WorkEntry.from(
            original_line: line.strip,
            indentation:   indentation,
            interval:      interval
          )
        else
          current_work_entry = WorkEntry.from(
            original_line: line.strip,
            indentation:   indentation,
            start_time:    start_time,
            reduction:     reduction,
          )
        end
      else
        raise "Invalid work line format: #{line.strip.inspect}" if line.include?("work")
        next if current_work_entry.nil? # skip lines precending the first work line
        next if line == TIME_BRACKETS_SEPARATOR

        indentation, start_time = line.match(/^( *)[-.~*]( \d+:\d+\.)?/)[1..]

        start_time = start_time&.lstrip&.chomp('.')

        work_entry_indentation = current_work_entry.indentation

        # Ignore deeper indented lines.
        #
        if indentation.size < work_entry_indentation.size
          raise "Missing closing entry for work entry #{current_work_entry.inspect}"
        elsif indentation.size == work_entry_indentation.size
          current_work_entry.end_time = start_time || raise("Subsequent entry has no time! (previous: #{current_work_entry.inspect})")
          work_entries << current_work_entry
          current_work_entry = nil
        end
      end
    end

    raise "Missing closing entry for work entry #{current_work_entry.inspect}" if current_work_entry

    work_entries.join(', ')
  end

  def add_lpim_to_next_day(section, work_times)
    raise "Found lpim in next day!" if section =~ /\blpimw\b/
    raise "Insertion point not found!" if section !~ INSERTION_POINT_PATTERN

    section.sub(INSERTION_POINT_PATTERN) do |match|
      "#{$LAST_MATCH_INFO[0]}#{$LAST_MATCH_INFO[1]}" + ADDED_TASK_TEMPLATE % work_times
    end
  end
end
