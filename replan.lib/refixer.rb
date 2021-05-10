# Fixes the day in existing headers.
#
class Refixer
  include ReplanHelper

  def execute(content)
    header_matches = find_header_matches(content)

    mistaken_dates_data = header_matches.inject({}) do |mistaken_dates_data, header_match|
      check_header!(header_match, mistaken_dates_data)
    end

    content = fix_headers(mistaken_dates_data, content)

    if mistaken_dates_data.empty?
      puts "No fixes required!", ""
    end

    content
  end

  private

  # Returns mistaken_dates_data.
  #
  # mistaken_dates_data: {"original_header" => "expected_day_word"}
  #
  def check_header!(header_match, mistaken_dates_data)
    computed_date = convert_header_to_date(header_match)
    original_header, header_day_word, _, _, _ = header_match

    expected_day_word = computed_date.strftime("%a").upcase

    if expected_day_word != header_day_word
      mistaken_dates_data = mistaken_dates_data.merge(original_header => expected_day_word)
    end

    mistaken_dates_data
  end

  def fix_headers(mistaken_dates_data, content)
    mistaken_dates_data.inject(content) do |current_content, (original_header, expected_day_word)|
      puts "- #{original_header.strip} -> #{expected_day_word}"

      fixed_header = original_header.sub(/\S{3}/, expected_day_word)

      current_content.sub(/^#{Regexp.escape(original_header)}/, fixed_header)
    end
  end
end
