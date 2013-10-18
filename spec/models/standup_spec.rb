require 'spec_helper'

describe Standup do
  describe 'associations' do
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:posts).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:to_address) }

    it "should validate the format of the standup time" do
      standup = FactoryGirl.build(:standup)
      standup.should be_valid

      standup.start_time_string = "9:00 am"
      standup.should be_valid

      standup.start_time_string = "09:10 AM"
      standup.should be_valid

      standup.start_time_string = "10:00"
      standup.should_not be_valid

      standup.start_time_string = "23:00"
      standup.should_not be_valid
    end
  end

  it 'has a closing message' do
    standup = FactoryGirl.create(:standup, closing_message: 'Yay')
    standup.closing_message.should == 'Yay'
  end

  describe "#ip_addresses" do
    context "when separated by newline characters" do
      it "should convert the string to an array of IPAddr objects" do
        standup = Standup.new(ip_addresses_string: "127.0.0.1/24\r\n168.2.1.3/8\r\n\r\n")

        standup.ip_addresses.should == [IPAddr.new("127.0.0.1/24"), IPAddr.new("168.2.1.3/8")]
      end
    end

    context "when separated by carriage returns" do
      it "should convert the string to an array of IPAddr objects" do
        standup = Standup.new(ip_addresses_string: "127.0.0.1/24\r168.2.1.3/8\r\r")

        standup.ip_addresses.should == [IPAddr.new("127.0.0.1/24"), IPAddr.new("168.2.1.3/8")]
      end
    end

    context "when separated by white spaces" do
      it "should convert the string to an array of IPAddr objects" do
        standup = Standup.new(ip_addresses_string: "127.0.0.1/24\t168.2.1.3/8\t\t")

        standup.ip_addresses.should == [IPAddr.new("127.0.0.1/24"), IPAddr.new("168.2.1.3/8")]
      end
    end

    context "when separated by commas" do
      it "should convert the string to an array of IPAddr objects" do
        standup = Standup.new(ip_addresses_string: "127.0.0.1/24, 168.2.1.3/8, \r\t\t")

        standup.ip_addresses.should == [IPAddr.new("127.0.0.1/24"), IPAddr.new("168.2.1.3/8")]
      end
    end
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
        @standup.date_today.should == @utc_yesterday
      end
    end

    describe "#date_tomorrow" do
      it "returns the date based on the time zone" do
        @standup.date_tomorrow.should == @utc_today
      end
    end

    describe "#next_standup_date" do
      context "when the standup is today" do
        it "returns date and time as an integer" do
          standup_beginning_of_day = @standup.time_zone.now.beginning_of_day

          @standup.start_time_string = "5:00pm"
          @standup.next_standup_date.should == standup_beginning_of_day + 17.hours
        end
      end

      context "when the standup is tomorrow" do
        it "returns date and time as an integer" do
          standup_beginning_of_day = @standup.time_zone.now.beginning_of_day

          @standup.start_time_string = "8:00am"
          @standup.next_standup_date.should == standup_beginning_of_day + 1.day + 8.hour
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
          ip_addresses_string: "127.0.0.1",
          start_time_string: "9:00am",
          image_urls: 'http://example.com/bar.png',
          image_days: '["M"]'
      )
    }.to_not raise_exception
  end

  it 'serializes the image_days array for storage in the db' do
    standup = create(:standup, image_days: ['mon', 'tue'])
    standup.image_days.should == ['mon', 'tue']
  end
end
