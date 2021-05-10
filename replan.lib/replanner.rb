require_relative 'replan_codec'

class Replanner
  include ReplanHelper

  CURRENT_TIME_SEPARATOR_REGEX = /^~~~~~\n/

  def initialize
    @replan_codec = ReplanCodec.new
  end

  def execute(content, skip_only: false)
    dates = skip_only ? find_all_dates(content) : [find_first_date(content)]

    dates.each do |current_date|
      current_date_section = find_date_section(content, current_date)

      if !skip_only && current_date_section =~ CURRENT_TIME_SEPARATOR_REGEX
        raise "Found todo section!"
      end

      edited_current_date_section = current_date_section.dup

      replan_lines = find_replan_lines(current_date_section, skip_only: skip_only)

      # Since the replan entries are pushed to the top of the destination date, process them in reverse,
      # so that they will appear in the original order.
      #
      replan_lines.reverse.each do |replan_line|
        is_fixed, fixed_time, is_skipped, no_replan, planned_date = decode_planned_date(replan_line, current_date)

        insertion_date = find_preceding_or_existing_date(content, planned_date)

        if insertion_date != planned_date
          content = add_date_header(content, insertion_date, planned_date)
        end

        planned_line = compose_planned_line(replan_line, is_fixed, fixed_time, is_skipped, no_replan)

        print_planned_info(planned_date, planned_line)

        content = add_line_to_date_section(content, planned_date, planned_line)

        edited_replan_line = is_skipped ? '' : remove_replan(replan_line)

        edited_current_date_section = edited_current_date_section.sub(replan_line, edited_replan_line)
      end

      content = content.sub(current_date_section, edited_current_date_section)
    end

    content
  end

  private

  def find_replan_lines(section, skip_only:)
    section.lines.select { |line| @replan_codec.replan_line?(line, skip_only) }
  end

  # Return [is_fixed, fixed_time, is_skipped, no_replan, planned_date]
  #
  def decode_planned_date(line, current_date)
    is_fixed, fixed_time, is_skipped, encoded_period, next_occurrence_encoded_period = @replan_codec.extract_replan_tokens(line)

    print_replan_data(line, is_fixed, fixed_time, is_skipped, encoded_period, next_occurrence_encoded_period)

    if encoded_period.nil? && !is_skipped && next_occurrence_encoded_period.nil?
      raise "No encoded period find, but skipped & next occurrence are required!"
    end

    replan_value = next_occurrence_encoded_period || encoded_period

    displacement = case replan_value
      when /^\d+$/
        replan_value.to_i
      when /^\d+w$/
        7 * replan_value[0..-2].to_i
      when /^\d(\.\d)?m$/
        30 * replan_value[0..-2].to_f
      when /^\d(\.\d)?y$/
        365 * replan_value[0..-2].to_f
      else
        raise "Invalid replan value: #{next_occurrence_encoded_period.inspect}; line: #{line.inspect}"
      end

    [is_fixed, fixed_time, is_skipped, encoded_period.nil?, current_date + displacement]
  end

  def remove_replan(line)
    @replan_codec.remove_replan(line)
  end

  def compose_planned_line(line, is_fixed, fixed_time, is_skipped, no_replan)
    line = line.lstrip

    if !is_fixed
      # Remove the time.
      #
      line = line.sub(/(?<=^. )\d{1,2}:\d{2}. /, '')
    elsif fixed_time
      # Replace the time with the specified one.
      #
      line = line.sub(/(?<=^. )\d{1,2}:\d{2}. /, "#{fixed_time}. ")
    end

    line = @replan_codec.rewrite_replan(line, no_replan)

    # The rstrip() is for the no_replan case.
    #
    line.rstrip
  end

  def print_replan_data(line, is_fixed, fixed_time, is_skipped, encoded_period, next_occurrence_encoded_period)
    puts line.inspect
    puts "- is_fixed:            #{is_fixed}" if is_fixed
    puts "- fixed_time:          #{fixed_time}" if fixed_time
    puts "- is_skipped:          #{is_skipped}" if is_skipped
    puts "- encoded_period:      #{encoded_period}"
    puts "- n.e. encoded_period: #{next_occurrence_encoded_period}" if next_occurrence_encoded_period
  end

  def print_planned_info(planned_date, planned_line)
    puts "=> #{planned_date.strftime("%a %d/%b/%Y").upcase}: #{planned_line.inspect}", ""
  end
end
