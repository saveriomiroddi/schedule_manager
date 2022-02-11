require 'rspec'
require 'tempfile'

require_relative '../../../replan.lib/remover.rb'

describe Remover do
  it "should raise an error if the current date section includes a todo marker" do
    content = <<~TXT
        MON 20/SEP/2021
    - foo
    ~~~~~
    - baz

    TXT

    phony_schedule_file = Tempfile.create('schedule')
    phony_archive_file = Tempfile.create('archive')

    expect { subject.execute(phony_schedule_file, phony_archive_file, content) }.to raise_error("Found todo section into current date (2021-09-20) section!")
  end
end # describe Remover
