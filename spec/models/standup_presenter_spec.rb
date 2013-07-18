require 'spec_helper'

describe StandupPresenter do
  let(:standup) { double(foo: 'bar', closing_message: '') }
  subject { StandupPresenter.new(standup) }

  it 'delegates methods to standup' do
    subject.foo.should == 'bar'
  end

  context 'when standup object does not have a closing message' do
    it 'picks a closing message' do
      Date.stub_chain(:today, :wday).and_return(4)
      subject.stub(:rand) { 0 }
      subject.closing_message.should == 'STRETCH!'
    end

    it 'picks a closing message (2)' do
      Date.stub_chain(:today, :wday).and_return(2)
      subject.stub(:rand) { 2 }
      subject.closing_message.should == 'STRETCH!!!!!'
    end

    it 'should remind us when its Floor Friday' do
      Date.stub_chain(:today, :wday).and_return(5)
      subject.closing_message.should == "STRETCH! It's Floor Friday!"
    end
  end

  context 'when standup object does have a closing message' do
    let(:standup) { double(closing_message: 'Yay!') }

    it 'returns the standup closing message' do
      subject.closing_message.should == 'Yay!'
    end
  end

end