require 'rspec'
require 'stringio'

require_relative '../../../replan.lib/retemplater.rb'

# Very basic.
#
describe Retemplater do
  it "Should raise an error if the todo section separator is found" do
    source_content = <<~TXT
          SAT 10/JUL/2021
      -----
      -----
      -----
      -----

          SUN 11/JUL/2021
      - foo0
      -----
      - bar0
      -----
      - baz0
      -----
      - qux0
      -----

    TXT

    # Terminating blank lines test the normalization.
    #
    template = StringIO.new <<~TXT
      - foo1
      -----
      - bar1
      -----
      - baz1
      -----
      - qux1
      -----

    TXT


    expected_content = <<~TXT
          SAT 10/JUL/2021
      -----
      -----
      -----
      -----

          SUN 11/JUL/2021
      - foo0
      - foo1
      -----
      - bar0
      - bar1
      -----
      - baz0
      - baz1
      -----
      - qux0
      - qux1
      -----

    TXT

    actual_content = described_class.new(template).execute(source_content)

    expect(actual_content).to eql(expected_content)
  end
end # describe Retemplater
