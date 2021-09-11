require 'rspec'
require 'date'

require_relative '../../../replan.lib/relister.rb'

# Very basic.
#
describe Relister do
  it "Should allow missing dates (sections)" do
    date_header = Date.today.strftime('%a %d/%b/%Y').upcase

    test_content = <<~TXT
          #{date_header}
      - test (replan 1)

    TXT

    expect {
      subject.execute(test_content)
    }.not_to raise_error
  end

  it "Should allow non-replan `*` lines" do
    date_header = Date.today.strftime('%a %d/%b/%Y').upcase

    test_content = <<~TXT
          #{date_header}
      * some event

    TXT

    expect {
      subject.execute(test_content)
    }.not_to raise_error
  end
end # describe Relister
