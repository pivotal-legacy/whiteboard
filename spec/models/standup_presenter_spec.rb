require 'spec_helper'
require 'fileutils'

describe StandupPresenter do
  let(:standup) { double(foo: 'bar', closing_message: '', image_urls: '') }
  subject { StandupPresenter.new(standup) }

  it 'delegates methods to standup' do
    subject.foo.should == 'bar'
  end

  context 'when standup object does not have a closing message' do
    it 'picks a closing message' do
      Date.stub_chain(:today, :wday).and_return(4)
      StandupPresenter::STANDUP_CLOSINGS.should include(subject.closing_message)
    end

    it 'should remind us when its Floor Friday' do
      Date.stub_chain(:today, :wday).and_return(5)
      subject.closing_message.should == "STRETCH! It's Floor Friday!"
    end
  end

  context 'when standup object does have a closing message and image urls are blank' do
    let(:standup) { double(closing_message: 'Yay!') }

    it 'returns the standup closing message' do
      subject.closing_message.should == 'Yay!'
    end
  end

  describe '#closing_image' do
    let(:image_urls) {
      ['http://example.com/bar.png', 'http://example.com/baz.png']
    }
    let!(:standup) { FactoryGirl.create(:standup, image_urls: image_urls.join("\n"), image_days: ['Mon', 'Tue']) }

    context 'when the day is selected' do
      before do
        Timecop.travel(Time.local(2013, 9, 2, 12, 0, 0)) #monday
      end

      after do
        Timecop.return
      end

      context 'when the directory contains files' do
        it 'returns an image url from the list of image urls' do
          image_urls.should include subject.closing_image
        end

        it 'does not return the same image 100 times in a row' do
          images = []
          100.times do
            images << subject.closing_image
          end

          images.uniq.length.should == 2
        end
      end
    end

    context 'when the day is not selected' do
      before do
        Timecop.travel(Time.local(2013, 9, 4, 12, 0, 0)) #wednesday
      end

      after do
        Timecop.return
      end

      it 'returns nil' do
        subject.closing_image.should be_nil
      end
    end
  end
end
