require 'spec_helper'

describe Item do
  let(:item) { build_stubbed(:item) }

  describe "associations" do
    it { should belong_to(:post) }
    it { should belong_to(:standup) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:standup) }
  end

  describe "kind" do
    describe "should allow valid kinds - " do
      ['New face', 'Help', 'Interesting'].each do |kind|
        it kind do
          item.kind = kind
          item.should be_valid
        end
      end
    end

    it "should not allow other kinds" do
      item.kind = "foobar"
      item.should_not be_valid
    end
  end

  describe "defaults" do
    it "defaults public to false" do
      Item.new.public.should == false
    end
  end

  describe ".events_on_or_after" do
    subject { Item.events_on_or_after(date)['Event'] }

    let(:date) { Date.parse('1/1/1970') }
    let!(:event_before_date) { create(:item, date: (date - 1.day), kind: 'Event') }
    let!(:event_after_date) { create(:item, date: (date + 1.day), kind: 'Event') }
    let!(:event_on_date) { create(:item, date: (date), kind: 'Event') }

    it { should_not include event_before_date }
    it { should include event_on_date }
    it { should include event_after_date }

    it "orders the events by date" do
      subject.should == [event_on_date, event_after_date]
    end
  end
end
