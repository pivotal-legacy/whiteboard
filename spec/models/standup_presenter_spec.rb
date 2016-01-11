require 'rails_helper'
require 'fileutils'

describe StandupPresenter do
  let(:standup) { double(foo: 'bar', closing_message: '', image_urls: '') }
  subject { StandupPresenter.new(standup) }

  it 'delegates methods to standup' do
    expect(subject.foo).to eq 'bar'
  end

  context 'when standup object does not have a closing message' do
    it 'picks a closing message' do
      allow(Time).to receive_message_chain(:zone, :today, :wday).and_return(4)
      expect(StandupPresenter::STANDUP_CLOSINGS).to include(subject.closing_message)
    end

    it 'should remind us when its Floor Friday' do
      allow(Time).to receive_message_chain(:zone, :today, :wday).and_return(5)
      expect(subject.closing_message).to eq "STRETCH! It's Floor Friday!"
    end
  end

  context 'when standup object does have a closing message and image urls are blank' do
    let(:standup) { double(closing_message: 'Yay!') }

    it 'returns the standup closing message' do
      expect(subject.closing_message).to eq 'Yay!'
    end
  end

  context "when the standup has posts that have been e-mailed" do
    before do
      allow(standup).to receive(:last_email_time).and_return(Time.local(2001, 01, 01, 12, 00))
    end

    it "returns the last email time message" do
      expect(subject.last_email_time_message).to eq("Last standup email sent: 12:00PM Monday Jan 1, 2001")
    end
  end

  context "when the standup DOES NOT have posts that have been e-mailed" do
    before do
      allow(standup).to receive(:last_email_time).and_return(nil)
    end

    it "does not return a last email time message" do
      expect(subject.last_email_time_message).to be_nil
    end
  end

  context "when the standup DOES NOT have posts" do
    before do
      allow(standup).to receive(:last_email_time).and_return(nil)
    end

    it "does not return a last email time message" do
      expect(subject.last_email_time_message).to be_nil
    end
  end

  context "when standup does NOT have one click post enabled" do
    before do
      allow(standup).to receive(:one_click_post?).and_return(false)
    end

    it "returns the create post confirmation message for the multi-step post flow" do
      expect(subject.create_post_confirm_message).to eq "This will clear the board and create a new one for tomorrow, you can always get back to this post under the \"Posts\" menu in the header. Continue?"
    end

    it "returns the create post button text for the multi-step post flow" do
      expect(subject.create_post_button_text).to eq "Create Post"
    end

    it "returns the create post sender placeholder" do
      expect(subject.create_post_sender_field_placeholder).to eq("Blogger Name(s)")
    end

    it "returns the crete post subject placeholder" do
      expect(subject.create_post_subject_field_placeholder).to eq("Post Title (eg: Best Standup Ever)")
    end
  end

  context "when standup has one click post enabled" do
    before do
      allow(standup).to receive(:one_click_post?).and_return(true)
    end

    it "returns the create post confirmation message for the 1-click flow" do
      expect(subject.create_post_confirm_message).to eq "You are about to send today's stand up email. Continue?"
    end

    it "returns the create post button text for the 1-click flow" do
      expect(subject.create_post_button_text).to eq "Send Email"
    end

    it "returns the create post sender placeholder" do
      expect(subject.create_post_sender_field_placeholder).to eq("Standup host(s)")
    end

    it "returns the crete post subject placeholder" do
      expect(subject.create_post_subject_field_placeholder).to eq("Email subject")
    end
  end

  describe '#closing_image' do
    let(:image_urls) {
      ['http://example.com/bar.png', 'http://example.com/baz.png']
    }
    let!(:standup) { FactoryGirl.create(:standup, image_urls: image_urls.join("\n"), image_days: ['Mon', 'Tue']) }

    context 'when the day is selected' do
      before do
        Timecop.travel(Time.zone.local(2013, 9, 2, 12, 0, 0)) #monday
      end

      after do
        Timecop.return
      end

      context 'when the directory contains files' do
        it 'returns an image url from the list of image urls' do
          expect(image_urls).to include subject.closing_image
        end

        it 'does not return the same image 100 times in a row' do
          images = []
          100.times do
            images << subject.closing_image
          end

          expect(images.uniq.length).to eq 2
        end
      end
    end

    context 'when the day is not selected' do
      before do
        Timecop.travel(Time.zone.local(2013, 9, 4, 12, 0, 0)) #wednesday
      end

      after do
        Timecop.return
      end

      it 'returns nil' do
        expect(subject.closing_image).to be_nil
      end
    end
  end
end
