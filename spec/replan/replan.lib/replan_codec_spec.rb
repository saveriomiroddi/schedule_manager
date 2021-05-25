require 'rspec'

require_relative '../../../replan.lib/replan_codec.rb'

describe ReplanCodec do
  # Basic.
  #
  context "token extraction" do
    it 'for string with all the functionalities' do
      tokens = subject.extract_replan_tokens('(replan f13:33s 2w in 3m)')

      expect(tokens[0]).to eql('f')
      expect(tokens[1]).to eql('13:33')
      expect(tokens[2]).to eql('s')
      expect(tokens[3]).to eql('2w')
      expect(tokens[4]).to eql('3m')
    end

    it 'for interval-only' do
      tokens = subject.extract_replan_tokens('(replan 1)')

      expect(tokens[0]).to be(nil)
      expect(tokens[1]).to be(nil)
      expect(tokens[2]).to be(nil)
      expect(tokens[3]).to eql('1')
      expect(tokens[4]).to be(nil)
    end
  end

  context 'replan line detection' do
    it 'should detect a replan line in standard mode' do
      expect(subject.replan_line?('(replan 1)', false)).to be_truthy
      expect(subject.replan_line?('(replan s)', false)).to be_truthy
    end

    it 'should detect a replan line in skip-only mode' do
      expect(subject.replan_line?('(replan 1)', true)).to be_falsey
      expect(subject.replan_line?('(replan s)', true)).to be_truthy
    end

    it 'should detect a invalid replan line' do
      expect {
        subject.replan_line?('replan', false)
      }.to raise_error("Line with invalid `replan`: replan")
    end

    it 'should detect a non-replan line' do
      expect(subject.replan_line?('repla', false)).to be(false)
    end
  end

  context 'skipped events detection' do
    it 'should detect a skipped event' do
      expect(subject.skipped_event?('(replan s 1)')).to be(true)
    end

    it 'should detect a non-replan line' do
      expect(subject.skipped_event?('repla')).to be_falsey
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
  end
end # describe ReplanCodec
