require 'spec_helper'

describe Item do
  let(:item) { build_stubbed(:item) }

  describe "default_scope" do
    let!(:furthest_item) { create(:item, date: 5.days.from_now) }
    let!(:closest_item) { create(:item, date: 1.days.from_now) }
    let!(:middlest_item) { create(:item, date: 3.days.from_now) }
    let!(:no_date_item) { create(:item, date: nil) }

    it "should bring them back in date asc order" do
      expect(Item.all).to match_array([no_date_item, closest_item, middlest_item, furthest_item])
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
      ['New face', 'Help', 'Interesting', 'Event'].each do |kind|
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

  describe "date" do
    it "does not allow a past date for a New face" do
      face = Item.new(date: 2.days.ago, kind: "New face")

      expect(face.errors[:date]).to include "cannot be in the past"
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

    let(:post) { create(:post) }
    let(:event_with_post) { create(:item, date: (date), kind: 'Event', standup: standup) }

    before do
      post.items << event_with_post
    end

    it { should_not include event_before_date }
    it { should include event_on_date }
    it { should include event_after_date }

    it "orders the events by date" do
      subject.should == [event_on_date, event_after_date]
    end

    it "does not include events that have a post_id set" do
      subject.should_not include event_with_post
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
    let!(:event_tomorrow) { create(:item, date: Date.tomorrow, kind: 'Event', standup: standup) }

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

    it "does not include events in the future" do
      should_not include event_tomorrow
    end

    it "includes events from today" do
      should include event_today
    end

    it "combines all of the above" do
      should =~ [item_with_no_post_id, item_not_bumped, item_for_today, item_with_no_date, event_today]
    end

    it "does not include items for other standups" do
      should_not include item_for_different_standup
    end
  end

  describe "relative_date" do
    let(:today) { 5.days.ago.to_date }
    let(:tomorrow) { 4.days.ago.to_date }

    let(:standup) do
      standup = Standup.new
      standup.stub(:date_today).and_return(today)
      standup.stub(:date_tomorrow).and_return(tomorrow)
      standup
    end

    it 'returns :today for an event taking place today' do
      item = Item.new do |item|
        item.date = today
        item.standup = standup
      end

      item.relative_date.should == :today
    end

    it 'returns :tomorrow for an event taking place tomorrow' do
      item = Item.new do |item|
        item.date = tomorrow
        item.standup = standup
      end

      item.relative_date.should == :tomorrow
    end

    it 'returns :upcoming for an event taking place after tomorrow' do
      item = Item.new do |item|
        item.date = 10.days.from_now.to_date
        item.standup = standup
      end

      item.relative_date.should == :upcoming
    end
  end

  describe '.orphans' do
    it 'returns all unposted interestings and helps' do
      old_help = FactoryGirl.create(:item, kind: 'Help', date: 2.days.ago)
      interesting = FactoryGirl.create(:item, kind: 'Interesting')

      Item.orphans.should == {'Help' => [old_help], 'Interesting' => [interesting]}
    end

    it 'returns items in date asc order' do
      interesting = FactoryGirl.create(:item, kind: 'Interesting')
      old_interesting = FactoryGirl.create(:item, kind: 'Interesting', date: 2.days.ago)

      Item.orphans.should == {'Interesting' => [old_interesting, interesting]}
    end
  end

  describe '.orphans' do
    it 'returns the non-event items that are not in the past' do
      item = FactoryGirl.create(:item, kind: 'Help')
      FactoryGirl.create(:item, kind: 'Event')
      FactoryGirl.create(:item, kind: 'Help', date: Date.yesterday)

      Item.orphans.length.should == 1
    end
  end
end
