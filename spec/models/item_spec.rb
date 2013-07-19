require 'spec_helper'

describe Item do
  let(:item) { build_stubbed(:item) }

  describe "default_scope" do
    let!(:furthest_item) { create(:item, date: 5.days.from_now) }
    let!(:closest_item) { create(:item, date: 1.days.from_now) }
    let!(:middlest_item) { create(:item, date: 3.days.from_now) }
    let!(:no_date_item) { create(:item, date: nil) }

    it "should bring them back in date asc order" do
      Item.all.should == [no_date_item, closest_item, middlest_item, furthest_item]
    end
  end

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
    subject { Item.events_on_or_after(date, standup)['Event'] }

    let(:standup) { create(:standup) }
    let(:date) { Date.parse('1/1/1970') }
    let!(:event_before_date) { create(:item, date: (date - 1.day), kind: 'Event', standup: standup) }
    let!(:event_after_date) { create(:item, date: (date + 1.day), kind: 'Event', standup: standup) }
    let!(:event_on_date) { create(:item, date: (date), kind: 'Event', standup: standup) }

    it { should_not include event_before_date }
    it { should include event_on_date }
    it { should include event_after_date }

    it "orders the events by date" do
      subject.should == [event_on_date, event_after_date]
    end
  end

  describe "#for_post" do
    subject { Item.for_post(standup) }
    let!(:standup) { FactoryGirl.create(:standup, title: 'San Francisco', subject_prefix: "[Standup][SF]") }
    let!(:other_standup) { FactoryGirl.create(:standup, title: 'New York') }

    let!(:post) { create(:post, standup: standup) }
    let!(:item_with_no_post_id) { create(:item, post_id: nil, kind: "Help", standup: standup) }
    let!(:item_with_post_id) { create(:item, post_id: post.id, kind: "Help", standup: standup) }

    let!(:item_not_bumped) { create(:item, bumped: false, kind: "Help", standup: standup) }
    let!(:bumped_item) { create(:item, bumped: true, kind: "Help", standup: standup) }

    let!(:item_for_today) { create(:item, date: Date.today, kind: "Help", standup: standup) }
    let!(:item_with_no_date) { create(:item, date: nil, kind: "Help", standup: standup) }
    let!(:item_for_tomorrow) { create(:item, date: Date.tomorrow, kind: "Help", standup: standup) }

    let!(:item_for_different_standup) { create(:item, date: nil, kind: "Help", standup: other_standup) }

    let!(:event_today) { create(:item, date: Date.today, kind: 'Event', standup: standup) }

    it "includes item with no post id" do
      should include item_with_no_post_id
      should_not include item_with_post_id
    end

    it "includes non-bumped items" do
      should include item_not_bumped
      should_not include bumped_item
    end

    it "includes items with dates, but only for today" do
      should include item_for_today
      should_not include item_for_tomorrow
      should include item_with_no_date
    end

    it "does not include events" do
      should_not include event_today
    end

    it "combines all of the above" do
      should =~ [item_with_no_post_id, item_not_bumped, item_for_today, item_with_no_date]
    end

    it "does not include items for other standups" do
      should_not include item_for_different_standup
    end
  end

  describe "relative_date" do
    it 'returns :today for an event taking place today' do
      item = Item.new(date: Date.today)
      item.relative_date.should == :today
    end

    it 'returns :tomorrow for an event taking place tomorrow' do
      item = Item.new(date: Date.tomorrow)
      item.relative_date.should == :tomorrow
    end

    it 'returns :upcoming for an event taking place after tomorrow' do
      item = Item.new(date: 2.days.from_now.to_date)
      item.relative_date.should == :upcoming
    end
  end
end
