require 'rails_helper'

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
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:standup) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:standup) }

    context 'New Faces' do
      let(:item) { build(:new_face) }

      context 'when new' do
        let(:yesterday)  { (Time.zone.today - 1.day).to_time }

        it 'should disallow a past creation date' do
          Timecop.freeze('2001-01-01 09:00') do
            item = build(:new_face, date: yesterday)
            expect(item).to_not be_valid
          end
        end
      end

      context 'when updating' do
        before do
          Timecop.freeze('2014-04-14 08:22:33') do
            item.save!
          end
        end

        it 'should allow a past creation date' do
          Timecop.freeze('2014-04-28 14:42:11') do
            item.post_id = 1
            expect(item).to be_valid
          end
        end
      end
    end
  end

  describe "kind" do
    describe "should allow valid kinds - " do
      ['Help', 'Interesting', 'Event', 'Win'].each do |kind|
        it kind do
          item.kind = kind
          expect(item).to be_valid
        end
      end
    end

    describe "New face" do
      it "is valid with a date in the future" do
        item.kind = 'New face'
        item.date = Time.zone.tomorrow
        expect(item).to be_valid
      end
    end

    it "should not allow other kinds" do
      item.kind = "foobar"
      expect(item).to_not be_valid
    end
  end

  describe "defaults" do
    it "defaults public to false" do
      expect(Item.new.public).to eq false
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

    it { is_expected.to_not include event_before_date }
    it { is_expected.to include event_on_date }
    it { is_expected.to include event_after_date }

    it "orders the events by date" do
      expect(subject).to eq [event_on_date, event_after_date]
    end

    it "does not include events that have a post_id set" do
      expect(subject).to_not include event_with_post
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

    let!(:item_for_today) { create(:item, date: Time.zone.today, kind: "Help", standup: standup) }
    let!(:item_with_no_date) { create(:item, date: nil, kind: "Help", standup: standup) }
    let!(:item_for_tomorrow) { create(:item, date: Time.zone.tomorrow, kind: "Help", standup: standup) }

    let!(:item_for_different_standup) { create(:item, date: nil, kind: "Help", standup: other_standup) }

    let!(:event_today) { create(:item, date: Time.zone.today, kind: 'Event', standup: standup) }
    let!(:event_tomorrow) { create(:item, date: Time.zone.tomorrow, kind: 'Event', standup: standup) }

    it "includes item with no post id" do
      expect(subject).to include item_with_no_post_id
      expect(subject).to_not include item_with_post_id
    end

    it "includes non-bumped items" do
      expect(subject).to include item_not_bumped
      expect(subject).to_not include bumped_item
    end

    it "includes items with dates, but only for today" do
      expect(subject).to include item_for_today
      expect(subject).to_not include item_for_tomorrow
      expect(subject).to include item_with_no_date
    end

    it "does not include events in the future" do
      expect(subject).to_not include event_tomorrow
    end

    it "includes events from today" do
      expect(subject).to include event_today
    end

    it "combines all of the above" do
      expect(subject).to match_array [item_with_no_post_id, item_not_bumped, item_for_today, item_with_no_date, event_today]
    end

    it "does not include items for other standups" do
      expect(subject).to_not include item_for_different_standup
    end
  end

  describe "relative_date" do
    let(:today) { 5.days.ago.to_date }
    let(:tomorrow) { 4.days.ago.to_date }

    let(:standup) do
      standup = Standup.new
      allow(standup).to receive(:date_today).and_return(today)
      allow(standup).to receive(:date_tomorrow).and_return(tomorrow)
      standup
    end

    it 'returns :today for an event taking place today' do
      item = Item.new do |item|
        item.date = today
        item.standup = standup
      end

      expect(item.relative_date).to eq :today
    end

    it 'returns :tomorrow for an event taking place tomorrow' do
      item = Item.new do |item|
        item.date = tomorrow
        item.standup = standup
      end

      expect(item.relative_date).to eq :tomorrow
    end

    it 'returns :upcoming for an event taking place after tomorrow' do
      item = Item.new do |item|
        item.date = 10.days.from_now.to_date
        item.standup = standup
      end

      expect(item.relative_date).to eq :upcoming
    end
  end

  describe '.orphans' do
    it 'returns all unposted interestings and helps' do
      old_help = FactoryGirl.create(:item, kind: 'Help', date: 2.days.ago)
      interesting = FactoryGirl.create(:item, kind: 'Interesting')

      expect(Item.orphans).to eq({'Help' => [old_help], 'Interesting' => [interesting]})
    end

    it 'returns items in date asc order' do
      interesting = FactoryGirl.create(:item, kind: 'Interesting')
      old_interesting = FactoryGirl.create(:item, kind: 'Interesting', date: 2.days.ago)

      expect(Item.orphans).to eq({'Interesting' => [old_interesting, interesting]})
    end
  end

  describe '.orphans' do
    it 'returns the non-event items that are not in the past' do
      item = FactoryGirl.create(:item, kind: 'Help')
      FactoryGirl.create(:item, kind: 'Event')
      FactoryGirl.create(:item, kind: 'Help', date: Date.yesterday)

      expect(Item.orphans.length).to eq 1
    end
  end
end
