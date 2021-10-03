require 'rspec'

require_relative '../../../replan.lib/replan_codec.rb'

describe ReplanCodec do
  # Basic.
  #
  context "token extraction" do
    it 'for string with all the functionalities' do
      tokens = subject.extract_replan_tokens('(replan f13:33suU 2w in 3m)')

      expect(tokens).to eql(OpenStruct.new(
        fixed: 'f',
        fixed_time: '13:33',
        skip: 's',
        update: 'u',
        update_full: 'U',
        interval: '2w',
        next: '3m',
      ))
    end

    it 'for string with next->weekday' do
      tokens = subject.extract_replan_tokens('(replan wed)')

      expect(tokens).to eql(OpenStruct.new(
        fixed: nil,
        fixed_time: nil,
        skip: nil,
        update: nil,
        update_full: nil,
        interval: nil,
        next: 'wed',
      ))
    end

    it 'for interval-only' do
      tokens = subject.extract_replan_tokens('(replan 1)')

      expect(tokens).to eql(OpenStruct.new(
        fixed: nil,
        fixed_time: nil,
        skip: nil,
        update: nil,
        update_full: nil,
        interval: '1',
        next: nil,
      ))
    end

    it 'for non-replan skip event' do
      tokens = subject.extract_replan_tokens('(replan s in 14)')

      expect(tokens).to eql(OpenStruct.new(
        fixed: nil,
        fixed_time: nil,
        skip: 's',
        update: nil,
        update_full: nil,
        interval: nil,
        next: '14',
      ))
    end
  end

  context 'replan line detection' do
    it 'should detect a replan line' do
      expect(subject.replan_line?('(replan 1)')).to be_truthy
    end

    it 'should detect a invalid replan line' do
      expect {
        subject.replan_line?('replan')
      }.to raise_error("Line with invalid `replan`: replan")
    end

    it 'should raise an error when trying to parse a non-replan line' do
      expect {
        expect {
          subject.extract_replan_tokens('abc')
        }.to raise_error("Trying to parse replan on a non-replan line")
      }.to output(%Q{Error on line "abc"\n}).to_stderr
    end

    it 'should detect a non-replan line' do
      expect(subject.replan_line?('repla')).to be(false)
    end
  end

  context 'skipped events detection' do
    it 'should detect a skipped event' do
      expect(subject.skipped_event?('(replan s 1)')).to be(true)
    end

    it 'should detect a non-skipped event' do
      expect(subject.skipped_event?('(replan 1)')).to be(false)
    end
  end

  it 'should remove the replan string' do
    expect(subject.remove_replan('myevent (replan 1)')).to eql('myevent')
  end

  context 'rewriting the replan string' do
    it 'should remove it in remove mode' do
      expect(subject.rewrite_replan('myevent (replan 1)', true)).to eql('myevent ')
    end

    it 'should rewrite a fixed replan' do
      expect(subject.rewrite_replan('myevent (replan f13:00s 5 in 6)', false)).to eql('myevent (replan f 5)')
    end

    it 'should rewrite a non-fixed replan' do
      expect(subject.rewrite_replan('myevent (replan s 5 in 6)', false)).to eql('myevent (replan 5)')
    end

    it 'should update a replan description' do
      expect_any_instance_of(InputHelper)
        .to receive(:ask)
        .with("Enter the new description:", prefill: "myevent")
        .and_return("yourevent")

        expect(subject.rewrite_replan('- myevent (replan u 1w)', false)).to eql('- yourevent (replan u 1w)')
    end

    it 'should update (full) a replan description' do
      expect_any_instance_of(InputHelper)
        .to receive(:ask)
        .with("Enter the new description:", prefill: "myevent (replan U 1w)")
        .and_return("yourevent (replan U 2w)")

        expect(subject.full_update_line('- myevent (replan U 1w)')).to eql('- yourevent (replan U 2w)')
    end
  end
end # describe ReplanCodec
