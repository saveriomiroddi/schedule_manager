require 'rspec'
require 'stringio'

require_relative '../../../replan.lib/retemplater.rb'

describe Retemplater do
  let(:current_day) {
    <<~TXT
          SAT 10/JUL/2021
      -----
      -----
      -----
      -----
    TXT
  }

  # Returning a StringIO makes things confusing, due to the cursor positioning on R/W.
  #
  let(:template) {
    <<~TXT
      -----
      - bar1
      -----
      - baz1
      -----
      - qux1
      -----
    TXT
  }

  it "Should fill the next day with the template" do
    source_content = <<~TXT
      #{current_day}

          SUN 11/JUL/2021
      - foo0
      -----
      - bar0
      -----
      - baz0
      -----
      -----

    TXT

    # Terminating blank lines test the normalization.
    #
    padded_template = template + "\n\n"

    expected_content = <<~TXT
      #{current_day}

          SUN 11/JUL/2021
      - foo0
      -----
      - bar0
      - bar1
      -----
      - baz0
      - baz1
      -----
      - qux1
      -----

    TXT

    actual_content = described_class.new(StringIO.new(padded_template)).execute(source_content)

    expect(actual_content).to eql(expected_content)
  end

  it "Should fill the missing separators" do
    source_content = <<~TXT
      #{current_day}

          SUN 11/JUL/2021
      -----
      -----
      -----

    TXT

    expected_content = <<~TXT
      #{current_day}

          SUN 11/JUL/2021
      -----
      - bar1
      -----
      - baz1
      -----
      - qux1
      -----

    TXT

    actual_content = described_class.new(StringIO.new(template)).execute(source_content)

    expect(actual_content).to eql(expected_content)
  end

  it "Should raise an error if too many time brackets are found" do
    source_content = <<~TXT
      #{current_day}

          SUN 11/JUL/2021
      -----
      -----
      -----
      -----
      -----

    TXT

    expect {
      described_class.new(StringIO.new(template)).execute(source_content)
    }.to raise_error("Too many time brackets found in date 2021-07-11: 5")
  end

  it "Should raise an error if there is an unexpected space" do
    source_content = <<~TXT
      #{current_day}

          SUN 11/JUL/2021
      - foo

      -----
      -----
      -----
      -----

          MON 12/JUL/2021
      - foo

    TXT

    # Without this error checking, it results in this:
    #
    #     -----
    #     -----
    #     -----
    #     -----
    #
    #
    #     -----
    #     - bar1
    #     -----
    #     - baz1
    #     -----
    #     - qux1
    #     -----
    #
    #     -----
    #     -----
    #     -----
    #     -----
    #
    expect {
      described_class.new(StringIO.new(template)).execute(source_content)
    }.to raise_error("Fix Retemplater bug when no time brackets are found (see code comment)!")
  end
end # describe Retemplater
