# Add missing headers for the next number of days.
#
class Readder
  include ReplanHelper

  DEFAULT_DAYS_TO_ADD = 91

  def execute(content, days: DEFAULT_DAYS_TO_ADD)
    dates_added = 0
    first_date = find_first_date(content)
    end_date = first_date + DEFAULT_DAYS_TO_ADD

    (first_date..end_date).each do |current_date|
      insertion_date = find_preceding_or_existing_date(content, current_date)

      if insertion_date != current_date
        content = add_new_date_section(content, insertion_date, current_date)
        dates_added += 1
      end
    end

    if dates_added > 0
      puts "Added #{dates_added} date(s)!", ""
    end

    content
  end
end
