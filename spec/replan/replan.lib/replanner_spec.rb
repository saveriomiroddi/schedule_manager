require 'rspec'
require 'timecop'

require_relative '../../../replan.lib/replanner.rb'

module ReplannerSpecHelper
  CURRENT_DATE = Date.new(2021, 9, 20)

  # A simpler (UX-wise, not code-wise) implementation is to automatically gather the current_date
  # from the first header in the test_content, although this may be a bit too magical.
  #
  def assert_replan(test_content, expected_next_date_section, current_date: CURRENT_DATE)
    result = Timecop.freeze(current_date) do
      subject.execute(test_content)
    end

    expect(result).to include(expected_next_date_section)
  end
end

describe Replanner do
  include ReplannerSpecHelper

  before :all do
    raise "Remove the Date.parse stubbing!" if Gem.loaded_specs['timecop'].version >= Gem::Version.new('0.10')
  end

  it "Should replan a 10+ 'm' date" do
    test_content = <<~TXT
        MON 20/SEP/2021
    - foo (replan 10m)

    TXT

    expected_updated_content = <<~TXT
        SUN 17/JUL/2022
    - foo (replan 10m)
    TXT

    assert_replan(test_content, expected_updated_content)
  end

  it "Should replan a last weekday of month interval" do
    test_content = <<~TXT
        MON 20/SEP/2021
    - foo (replan -thu)

    TXT

    expected_next_date_section = <<~TXT
        MON 20/SEP/2021
    - foo

        THU 30/SEP/2021
    - foo (replan -thu)
    TXT

    assert_replan(test_content, expected_next_date_section)
  end # context "Interpolations"

  context "first weekday of month interval" do
    context "without number specifier" do
      # This behavior may be changed.
      #
      it "Should replan on the same month when available" do
        test_content = <<~TXT
            WED 01/SEP/2021
        - foo (replan +thu)

        TXT

        expected_next_date_section = <<~TXT
            WED 01/SEP/2021
        - foo

            THU 02/SEP/2021
        - foo (replan +thu)
        TXT

        assert_replan(test_content, expected_next_date_section, current_date: Date.new(2021, 9, 1))
      end

      it "Should replan on the same month when not available" do
        test_content = <<~TXT
            MON 27/SEP/2021
        - foo (replan +mon)

        TXT

        expected_next_date_section = <<~TXT
            MON 27/SEP/2021
        - foo

            MON 04/OCT/2021
        - foo (replan +mon)
        TXT

        assert_replan(test_content, expected_next_date_section, current_date: Date.new(2021, 9, 27))
      end
    end # context "without number specifier" do

    context "with number specifier" do
      it "Should replan on the same month when available" do
        test_content = <<~TXT
            WED 01/SEP/2021
        - foo (replan +2wed)

        TXT

        expected_next_date_section = <<~TXT
            WED 01/SEP/2021
        - foo

            WED 08/SEP/2021
        - foo (replan +2wed)
        TXT

        assert_replan(test_content, expected_next_date_section, current_date: Date.new(2021, 9, 1))
      end
    end # context "with number specifier" do
  end # context "last numbered day of month interval"

  context "last numbered day of month interval" do
    # This behavior may be changed.
    #
    it "Should replan on the same month when available" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan -1)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021
      - foo

          THU 30/SEP/2021
      - foo (replan -1)
      TXT

      assert_replan(test_content, expected_next_date_section)
    end

    it "Should replan on the next month when not available" do
      test_content = <<~TXT
          THU 30/SEP/2021
      - foo (replan -1)

      TXT

      expected_next_date_section = <<~TXT
          THU 30/SEP/2021
      - foo

          SUN 31/OCT/2021
      - foo (replan -1)
      TXT

      assert_replan(test_content, expected_next_date_section, current_date: Date.new(2021, 9, 30))
    end
  end # context "last numbered day of month interval"

  it "Should add the replanned lines to the same time bracket as the original" do
    test_content = <<~TXT
        MON 20/SEP/2021
    - foo1 (replan 7)
    -----
    - foo1 (replan 7)
    - foo2 (replan 7)
    -----
    - foo3 (replan 7)
    -----
    - foo4 (replan 7)
    -----

        MON 27/SEP/2021
    - bar1
    -----
    - bar2
    -----
    -----
    - bar4
    -----

    TXT

    expected_updated_content = <<~TXT
        MON 27/SEP/2021
    - foo1 (replan 7)
    - bar1
    -----
    - foo1 (replan 7)
    - foo2 (replan 7)
    - bar2
    -----
    - foo3 (replan 7)
    -----
    - foo4 (replan 7)
    - bar4
    -----
    TXT

    assert_replan(test_content, expected_updated_content)
  end

  it "Should add missing brackets, when adding replan lines" do
    test_content = <<~TXT
        MON 20/SEP/2021
    - foo1 (replan 7)
    -----
    - foo1 (replan 7)
    -----
    -----
    -----

        MON 27/SEP/2021
    - foo

    TXT

    expected_updated_content = <<~TXT
        MON 27/SEP/2021
    - foo1 (replan 7)
    - foo
    -----
    - foo1 (replan 7)
    -----
    -----
    -----
    TXT

    assert_replan(test_content, expected_updated_content)
  end

  context "Interpolations" do
    it "Should apply {{date}}" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo ()(xxx){{date}} (replan 2)

      TXT

      expected_updated_content = <<~TXT
          MON 20/SEP/2021
      - foo ()(xxx)

          WED 22/SEP/2021
      - foo ()(mon/20){{date}} (replan 2)
      TXT

      assert_replan(test_content, expected_updated_content)
    end
  end

  context "skip" do
    it "Should skip a replan" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan s 2)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021

          WED 22/SEP/2021
      - foo (replan 2)
      TXT

      assert_replan(test_content, expected_next_date_section)
    end

    it "Should skip an update, without updating the line" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan su 2)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021

          WED 22/SEP/2021
      - foo (replan u 2)
      TXT

      expect_any_instance_of(InputHelper)
        .not_to receive(:ask)

      assert_replan(test_content, expected_next_date_section)
    end

    # The reason is that the user may want to change the day.
    #
    it "Should prompt for changes when skipping an update full" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan sU thu)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021

          WED 22/SEP/2021
      - foo (replan U wed)
      TXT

      expect_any_instance_of(InputHelper)
        .to receive(:ask)
        .with("Enter the new description:", prefill: "foo (replan sU thu)")
        .and_return("foo (replan sU wed)")

      assert_replan(test_content, expected_next_date_section)
    end
  end # context "skip"

  context "once scheduling" do
    it "Should schedule a task once in the future, with number of days" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - 12:30. foo (replan o in 2)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021

          WED 22/SEP/2021
      - foo
      TXT

      assert_replan(test_content, expected_next_date_section)
    end

    it "Should schedule a task once in the future, with a weekday" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - 12:30. foo (replan o wed)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021

          WED 22/SEP/2021
      - foo
      TXT

      assert_replan(test_content, expected_next_date_section)
    end

    it "Should schedule a task once in the future, with a plus weekday" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - 12:30. foo (replan o wed+)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021

          WED 29/SEP/2021
      - foo
      TXT

      assert_replan(test_content, expected_next_date_section)
    end


    it "Should schedule a task once in the future, with number of weeks" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - 12:30. foo (replan o in 1w)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021

          MON 27/SEP/2021
      - foo
      TXT

      assert_replan(test_content, expected_next_date_section)
    end
  end

  context "timestamp handling" do
    it "Should remove the timestamp, if there isn't a fixed one" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - 12:30. foo (replan 2)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021
      - 12:30. foo

          WED 22/SEP/2021
      - foo (replan 2)
      TXT

      assert_replan(test_content, expected_next_date_section)
    end

    context "fixed timestamp" do
      it "Should copy the timestamp from line time, if it's the only one" do
        # This is a variation of the standard time description, which is useful for intervals.
        #
        test_content = <<~TXT
            MON 20/SEP/2021
        - 12:30-13:00. foo (replan f 2)

        TXT

        expected_next_date_section = <<~TXT
            MON 20/SEP/2021
        - 12:30-13:00. foo

            WED 22/SEP/2021
        - 12:30-13:00. foo (replan f 2)
        TXT

        assert_replan(test_content, expected_next_date_section)
      end

      it "Should copy the timestamp from replan time, if it's the only one" do
        # This is a variation of the standard time description, which is useful for intervals.
        #
        test_content = <<~TXT
            MON 20/SEP/2021
        - foo (replan f12:00 2)

        TXT

        expected_next_date_section = <<~TXT
            MON 20/SEP/2021
        - foo

            WED 22/SEP/2021
        - 12:00. foo (replan f 2)
        TXT

        assert_replan(test_content, expected_next_date_section)
      end

      it "Should give priority to the replan timestamp" do
        test_content = <<~TXT
            MON 20/SEP/2021
        - 12:30. foo (replan f14:00 2)

        TXT

        expected_next_date_section = <<~TXT
            MON 20/SEP/2021
        - 12:30. foo

            WED 22/SEP/2021
        - 14:00. foo (replan f 2)
        TXT

        assert_replan(test_content, expected_next_date_section)
      end

      it "Should require a timestamp" do
        test_content = <<~TXT
            MON 20/SEP/2021
        - foo (replan f 2)

        TXT

        expect { subject.execute(test_content) }.to raise_error('Fixed timestamp is set, but no timestamp is provided: "- foo (replan f 2)"')
      end
    end # context "fixed timestamp"
  end # context "timestamp handling"

  # Other update-related functionality are in the other contexts.
  #
  context 'update (replan line)' do
    it "Should update the replan line on update" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (xxx){{date}} (replan u 3)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021
      - foobar (xxx)

          THU 23/SEP/2021
      - foobar (mon/20){{date}} (replan u 3)
      TXT

      expect_any_instance_of(InputHelper)
        .to receive(:ask)
        .with("Enter the new description:", prefill: "foo (xxx){{date}}")
        .and_return("foobar (xxx){{date}}")

      assert_replan(test_content, expected_next_date_section)
    end

    it "Should update the replan line on full update" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan U 3)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021
      - foobar

          THU 23/SEP/2021
      - foobar (replan U 3)
      TXT

      expect_any_instance_of(InputHelper)
        .to receive(:ask)
        .with("Enter the new description:", prefill: "foo (replan U 3)")
        .and_return("foobar (replan U 3)")

      assert_replan(test_content, expected_next_date_section)
    end
  end # context 'update (replan line)'

  context 'next' do
    context 'field weekday support' do
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
        - foo (replan sun)
        TXT

        assert_replan(test_content, expected_next_date_section)
      end

      it "Should set the day in the following week, when the weekday matches the current day" do
        test_content = <<~TXT
            MON 20/SEP/2021
        - foo (replan mon)

        TXT

        expected_next_date_section = <<~TXT
            MON 27/SEP/2021
        - foo (replan mon)
        TXT

        assert_replan(test_content, expected_next_date_section)
      end

      it "Should add one week, when the day is in the current week" do
        test_content = <<~TXT
            MON 20/SEP/2021
        - foo (replan sun+)

        TXT

        expected_next_date_section = <<~TXT
            SUN 03/OCT/2021
        - foo (replan sun+)
        TXT

        assert_replan(test_content, expected_next_date_section)
      end

      # In order to avoid confusion, the `+` always add one week.
      #
      it "Should add one week, when the day is in the next week" do
        test_content = <<~TXT
            MON 20/SEP/2021
        - foo (replan mon+)

        TXT

        expected_next_date_section = <<~TXT
            MON 04/OCT/2021
        - foo (replan mon+)
        TXT

        assert_replan(test_content, expected_next_date_section)
      end

      it "Should consider the event recurring, if it's update full with interval" do
        test_content = <<~TXT
            MON 20/SEP/2021
        - foo (replan U 2)

        TXT

        expected_next_date_section = <<~TXT
            MON 20/SEP/2021
        - bar

            WED 22/SEP/2021
        - bar (replan U 2)
        TXT

        expect_any_instance_of(InputHelper)
          .to receive(:ask)
          .with("Enter the new description:", prefill: "foo (replan U 2)")
          .and_return("bar (replan U 2)")

        assert_replan(test_content, expected_next_date_section)
      end

      it "Should consider the event recurring, if it's update full with weekday but not interval" do
        test_content = <<~TXT
            MON 20/SEP/2021
        - foo (replan U sun)

        TXT

        expected_next_date_section = <<~TXT
            MON 20/SEP/2021
        - bar

            WED 22/SEP/2021
        - bar (replan U wed)
        TXT

        expect_any_instance_of(InputHelper)
          .to receive(:ask)
          .with("Enter the new description:", prefill: "foo (replan U sun)")
          .and_return("bar (replan U wed)")

        assert_replan(test_content, expected_next_date_section)
      end
    end # context 'weekday support'

    it "Should copy an update full with interval and numeric next" do
      test_content = <<~TXT
          MON 20/SEP/2021
      - foo (replan U 3 in 2)

      TXT

      expected_next_date_section = <<~TXT
          MON 20/SEP/2021
      - foo

          WED 22/SEP/2021
      - foo (replan U 3 in 2)
      TXT

      expect_any_instance_of(InputHelper)
        .to receive(:ask)
        .with("Enter the new description:", prefill: "foo (replan U 3 in 2)")
        .and_return("foo (replan U 3 in 2)")

      assert_replan(test_content, expected_next_date_section, )
    end
  end # context 'next'
end # describe Replanner
