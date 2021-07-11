require 'rspec'

require_relative '../../../replan.lib/replanner.rb'

# Very basic.
#
describe Replanner do
  it "Should raise an error if the todo section separator is found" do
    test_content = <<~TXT
          SUN 11/JUL/2021
      - foo
      ~~~~~
      - bar

    TXT

    expect { subject.execute(test_content, true) }.to raise_error("Found todo section!")
  end
end # describe Replanner
