require 'rspec'
require 'timecop'

require_relative '../../../replan.lib/replanner.rb'

# Very basic.
#
describe Replanner do
  before :all do
    raise "Remove the Date.parse stubbing!" if Gem.loaded_specs['timecop'].version >= Gem::Version.new('0.10')
  end

  it "Should raise an error if the todo section separator is found" do
    test_content = <<~TXT
          SUN 11/JUL/2021
      - foo
      ~~~~~
      - bar

    TXT

    expect { subject.execute(test_content, true) }.to raise_error("Found todo section!")
  end

  context '"next" field weekday support' do
    # "current" is intended the european way.
    #
    it "Should set the day in the current week, accounting the semantic different with Ruby's start of the week" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan sun)

      TXT

      # This also ensures that the picked Sunday is the following one.
      #
      expected_next_date_section = <<~TXT
          SUN 26/SEP/2021
      - foo
      TXT

      allow(Date).to receive(:parse).and_wrap_original do |m, *args|
        if args == ['sun']
          Date.new(2021, 9, 26)
        else
          m.call(*args)
        end
      end

      result = Timecop.freeze(Date.new(2021, 9, 20)) do
        subject.execute(test_content, true)
      end

      expect(result).to include(expected_next_date_section)
    end

    it "Should set the day in the following week, when the weekday matches the current day" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan mon)

      TXT

      expected_next_date_section = <<~TXT
          MON 27/SEP/2021
      - foo
      TXT

      allow(Date).to receive(:parse).and_wrap_original do |m, *args|
        if args == ['mon']
          Date.new(2021, 9, 27)
        else
          m.call(*args)
        end
      end

      result = Timecop.freeze(Date.new(2021, 9, 20)) do
        subject.execute(test_content, true)
      end

      expect(result).to include(expected_next_date_section)
    end

    it "Should consider the event recurring, if it's update full with interval" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan U 2)

      TXT

      expected_next_date_section = <<~TXT
          WED 22/SEP/2021
      - bar (replan U 2)
      TXT

      expect_any_instance_of(InputHelper)
        .to receive(:ask)
        .with("Enter the new description:", prefill: "foo (replan U 2)")
        .and_return("bar (replan U 2)")

      allow(Date).to receive(:parse).and_wrap_original do |m, *args|
        if args == [2]
          Date.new(2021, 9, 22)
        else
          m.call(*args)
        end
      end

      result = Timecop.freeze(Date.new(2021, 9, 20)) do
        subject.execute(test_content, true)
      end

      expect(result).to include(expected_next_date_section)
    end

    it "Should consider the event recurring, if it's update full with weekday but not interval" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan U sun)

      TXT

      expected_next_date_section = <<~TXT
          WED 22/SEP/2021
      - foo (replan U wed)
      TXT

      expect_any_instance_of(InputHelper)
        .to receive(:ask)
        .with("Enter the new description:", prefill: "foo (replan U sun)")
        .and_return("foo (replan U wed)")

      allow(Date).to receive(:parse).and_wrap_original do |m, *args|
        if args == ['wed']
          Date.new(2021, 9, 22)
        else
          m.call(*args)
        end
      end

      result = Timecop.freeze(Date.new(2021, 9, 20)) do
        subject.execute(test_content, true)
      end

      expect(result).to include(expected_next_date_section)
    end
  end # context '"next" field weekday support'
end # describe Replanner
