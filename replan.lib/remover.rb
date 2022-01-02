require 'fileutils'
require 'tmpdir'

class Remover
  include ReplanHelper

  def execute(schedule_filename, archive_filename, content)
    current_date_section = remove_section_from_schedule(schedule_filename, content)
    add_section_to_archive(archive_filename, current_date_section)
  end

  def remove_section_from_schedule(schedule_filename, content)
    schedule_copy = Dir::Tmpname.create(['schedule', '.txt']) { }
    FileUtils.cp(schedule_filename, schedule_copy)

    current_date = find_first_date(content)
    current_date_section = find_date_section(content, current_date)

    raise "Found `replan` token into current date (#{current_date}) section!" if current_date =~ /\breplan\b/

    content = content.sub(current_date_section, "")
    IO.write(schedule_filename, content)

    current_date_section
  end

  def add_section_to_archive(archive_filename, current_date_section)
    new_content = current_date_section

    if File.exists?(archive_filename)
      new_content += IO.read(archive_filename)
    end

    IO.write(archive_filename, new_content)
  end
end
