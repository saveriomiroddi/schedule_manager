require_relative 'replan_codec'
require_relative 'replan_helper'
require_relative 'shared_constants'

require 'date'

class Replanner
  include ReplanHelper
  include SharedConstants

  def initialize
    @replan_codec = ReplanCodec.new
  end

  # check_todo: if true and a todo section is found, an error is raised.
  #
  def execute(content, check_todo)
    dates = find_all_dates(content)

    dates.each_with_index do |current_date, date_i|
      current_date_section = find_date_section(content, current_date)

      if check_todo && current_date_section =~ TODO_SECTION_SEPARATOR_REGEX
        raise "Found todo section!"
      end

      edited_current_date_section = current_date_section.dup

      replan_lines = find_replan_lines(current_date_section)

      # Since the replan entries are pushed to the top of the destination date, process them in reverse,
      # so that they will appear in the original order.
      #
      replan_lines.reverse.each do |replan_line|
        next if date_i > 0 && !@replan_codec.skipped_event?(replan_line)

        replan_data = decode_replan_data(replan_line)

        if replan_data.update_full
          replan_line = full_update_line(replan_line)
          replan_data = decode_replan_data(replan_line)
        end

        planned_date = decode_planned_date(replan_data, current_date, replan_line)

        insertion_date = find_preceding_or_existing_date(content, planned_date)

        if insertion_date != planned_date
          content = add_new_date_section(content, insertion_date, planned_date)
        end

        planned_line = compose_planned_line(replan_line, replan_data)

        content = add_line_to_date_section(content, planned_date, planned_line)

        edited_replan_line = replan_data.skip ? '' : remove_replan(replan_line)

        edited_current_date_section = edited_current_date_section.sub(replan_line, edited_replan_line)
      end

      # No-op if no changes have been performed (see conditional before change block).
      #
      content = content.sub(current_date_section, edited_current_date_section)
    end

    content
  end

  private

  def find_replan_lines(section)
    section.lines.select { |line| @replan_codec.replan_line?(line) }
  end

  def decode_replan_data(line)
    replan_data = @replan_codec.extract_replan_tokens(line)

    if replan_data.interval.nil? && replan_data.skip.nil? && replan_data.next.nil?
      raise "No period found (required by the options): #{line}"
    end

    replan_data
  end

  def full_update_line(line)
    @replan_codec.full_update_line(line)
  end

  def decode_planned_date(replan_data, current_date, line)
    replan_value = replan_data.next || replan_data.interval

    displacement = case replan_value
      when /^\d+$/
        replan_value.to_i
      when /^\d+w$/
        7 * replan_value[0..-2].to_i
      when /^\d(\.\d)?m$/
        30 * replan_value[0..-2].to_f
      when /^\d(\.\d)?y$/
        365 * replan_value[0..-2].to_f
      when /^\w{3}$/
        # This is (currently) valid for `next` only

        parsed_next = Date.parse(replan_value)

        # When parsing weekdays, the date in the current week is always returned, which for Ruby starts
        # on Sunday, so we need to adjust.
        # A weekday that matches the current day results in the same weekday on the following week.
        #
        diff_with_current = parsed_next - current_date
        diff_with_current += 7 if diff_with_current <= 0
        diff_with_current
      else
        raise "Invalid replan value: #{replan_value.inspect}; line: #{line.inspect}"
      end

    current_date + displacement
  end

  def remove_replan(line)
    @replan_codec.remove_replan(line)
  end

  def compose_planned_line(line, replan_data)
    line = line.lstrip

    if !replan_data.fixed
      # Remove the time.
      #
      line = line.sub(/(?<=^. )\d{1,2}:\d{2}. /, '')
    elsif replan_data.fixed_time
      # Replace the time with the specified one.
      #
      line = line.sub(/(?<=^. )\d{1,2}:\d{2}. /, "#{replan_data.fixed_time}. ")
    end

    line = @replan_codec.rewrite_replan(line, replan_data.interval.nil?)

    # The rstrip() is for the no_replan case.
    #
    line.rstrip
  end
end
