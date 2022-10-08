require 'rspec'
require 'date'

require_relative '../../../replan.lib/relister.rb'

# WATCH OUT! Relister starts from tomorrow's date, so `Date + 1` must be used.
#
describe Relister do
  # Close to the week change - trickier case :)
  #
  let(:reference_date) { Date.new(2022, 10, 8) }

  let(:first_date_header) { (Date.today + 1).strftime('%a %d/%b/%Y').upcase }
  let(:second_date_header) { (Date.today + 2).strftime('%a %d/%b/%Y').upcase }

  around :each do |example|
    Timecop.freeze(reference_date) do
      example.run
    end
  end

  it "Should allow missing dates (sections)" do
    test_content = <<~TXT
          #{first_date_header}
      - test (replan 1)

    TXT

    expect {
      subject.execute(test_content)
    }.not_to raise_error
  end

  it "Should not print the separator if the first event is after the first day" do
    test_content = <<~TXT
          #{first_date_header}

          #{second_date_header}
      * some event

    TXT

    expected_output = <<~TXT
          #{second_date_header}
      * some event

    TXT

    expect {
      subject.execute(test_content)
    }.to output(expected_output).to_stdout
  end

  it "Should allow non-replan `*` lines" do
    test_content = <<~TXT
          #{first_date_header}
      * some event
      * other event (replan 1)

    TXT

    expected_output = <<~TXT
          #{first_date_header}
      * some event
      * other event 

      =====

    TXT

    expect {
      subject.execute(test_content)
    }.to output(expected_output).to_stdout
  end
end # describe Relister
