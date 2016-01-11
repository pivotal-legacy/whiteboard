require 'rails_helper'

describe Standup do
  describe 'associations' do
    it { is_expected.to have_many(:items).dependent(:destroy) }
    it { is_expected.to have_many(:posts).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:to_address) }

    it "should validate the format of the standup time" do
      standup = FactoryGirl.build(:standup)
      expect(standup).to be_valid

      standup.start_time_string = "9:00 am"
      expect(standup).to be_valid

      standup.start_time_string = "09:10 AM"
      expect(standup).to be_valid

      standup.start_time_string = "10:00"
      expect(standup).to_not be_valid

      standup.start_time_string = "23:00"
      expect(standup).to_not be_valid
    end
  end

  it 'has a closing message' do
    standup = FactoryGirl.create(:standup, closing_message: 'Yay')
    expect(standup.closing_message).to eq 'Yay'
  end

  describe "dates" do
    before do
      @utc_today = Time.new(2012, 1, 1).utc.to_date
      @utc_yesterday = @utc_today - 1.day

      @standup = FactoryGirl.create(:standup, closing_message: 'Yay')
      @standup.time_zone_name = "Pacific Time (US & Canada)"
      Timecop.freeze(@utc_today)
    end

    after do
      Timecop.return
    end

    describe "#date_today" do
      it "returns the date based on the time zone" do
        expect(@standup.date_today).to eq @utc_yesterday
      end
    end

    describe "#date_tomorrow" do
      it "returns the date based on the time zone" do
        expect(@standup.date_tomorrow).to eq @utc_today
      end
    end

    describe "#time_zone_name_iana" do
      it "returns IANA format of the time zone" do
        expect(@standup.time_zone_name_iana).to eq "America/Los_Angeles"
      end
    end

    describe "#next_standup_date" do
      context "when the standup is today" do
        it "returns date and time as an integer" do
          standup_beginning_of_day = @standup.time_zone.now.beginning_of_day

          @standup.start_time_string = "5:00pm"
          expect(@standup.next_standup_date).to eq standup_beginning_of_day + 17.hours
        end
      end

      context "when the standup is tomorrow" do
        it "returns date and time as an integer" do
          standup_beginning_of_day = @standup.time_zone.now.beginning_of_day

          @standup.start_time_string = "8:00am"
          expect(@standup.next_standup_date).to eq standup_beginning_of_day + 1.day + 8.hour
        end
      end
    end
  end

  it "allows mass assignment" do
    expect {
      Standup.new(
          title: "Berlin",
          to_address: "berlin+standup@pivotallabs.com",
          subject_prefix: "[FOO]",
          closing_message: "Go Running.",
          time_zone_name: "Mountain Time (US & Canada)",
          start_time_string: "9:00am",
          image_urls: 'http://example.com/bar.png',
          image_days: '["M"]',
          one_click_post: true
      )
    }.to_not raise_exception
  end

  it 'serializes the image_days array for storage in the db' do
    standup = create(:standup, image_days: ['mon', 'tue'])
    expect(standup.image_days).to eq ['mon', 'tue']
  end

  describe "#last_email_time" do
    context "when there are no posts" do
      let (:standup_with_no_posts) { create(:standup) }

      it "is nil" do
        expect(standup_with_no_posts.last_email_time).to be_nil
      end
    end

    context "when there are posts" do
      let (:last_email_time) { Time.local(2016, 1, 1, 19, 42) }
      let (:last_emailed_post) { create(:post, sent_at: last_email_time) }
      let (:standup_with_posts) { create(:standup, posts: [
        create(:post, sent_at: last_email_time - 1),
        last_emailed_post,
        create(:post, sent_at: last_email_time - 1),
        create(:post, sent_at: nil)
      ])}

      it "is the time the most recently emailed post was emailed" do
        expect(standup_with_posts.last_email_time).to eq(last_email_time)
      end
    end
  end
end
