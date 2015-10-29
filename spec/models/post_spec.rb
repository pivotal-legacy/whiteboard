require 'rails_helper'

describe Post do
  describe 'associations' do
    it { is_expected.to belong_to(:standup) }

    it { is_expected.to have_many(:items) }
    it { is_expected.to have_many(:public_items) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:standup) }
    it { is_expected.to validate_presence_of(:title) }
  end

  describe "#adopt_all_items" do
    let(:standup) { create(:standup) }

    it "adopts all items not associated with a post" do
      old_post = create(:post)
      claimed_item = create(:item, post: old_post)
      unclaimed_item = create(:item, standup: standup)

      post = create(:post, standup: standup)
      post.adopt_all_the_items

      expect(post.items).to eq [unclaimed_item]
    end

    it "does not adopt bumped items" do
      old_post = create(:post)
      claimed_item = create(:item, post: old_post)
      unclaimed_item = create(:item, standup: standup)
      bumped_item = create(:item, bumped: true, standup: standup)

      post = create(:post, standup: standup)
      post.adopt_all_the_items

      expect(post.items).to eq [unclaimed_item]
    end

    it "does not adopt items with a date after today" do
      item_for_today = create(:item, date: Date.today, standup: standup)
      item_for_tomorrow = create(:item, date: Date.tomorrow, standup: standup)

      post = create(:post, standup: standup)
      post.adopt_all_the_items

      expect(post.items).to eq [item_for_today]
    end

    it "adopts items only for same standup" do
      other_standup = create(:standup)

      item_for_other_standup = create(:item, standup: other_standup)
      unclaimed_item = create(:item, standup: standup)

      post = create(:post, standup: standup)
      post.adopt_all_the_items

      expect(post.items).to eq [unclaimed_item]
    end
  end

  describe '#title_for_email' do
    context 'when there is a subject prefix set' do
      let(:standup) { create(:standup, subject_prefix: '[Standup][SF]') }

      it 'prepends the subject_prefix and date' do
        post = create(:post, standup: standup, title: "With Feeling", created_at: Time.parse("2012-06-02 12:00:00 -0700"))
        expect(post.title_for_email).to eq "#{standup.subject_prefix} 06/02/12: With Feeling"
      end
    end

    context 'when there is no subject prefix set' do
      let(:standup) { create(:standup, subject_prefix: nil) }

      it 'prepends [Standup] and the date' do
        post = create(:post, standup: standup, title: "With Feeling", created_at: Time.parse("2012-06-02 12:00:00 -0700"))
        expect(post.title_for_email).to eq "[Standup] 06/02/12: With Feeling"
      end
    end
  end

  describe '#title_for_blog' do
    it 'prepends the data' do
      post = create(:post, title: "With Feeling", created_at: Time.parse("2012-06-02 12:00:00 -0700"))
      expect(post.title_for_blog).to eq "06/02/12: With Feeling"
    end
  end

  describe '#deliver_email' do
    it "sends an email" do
      post = create(:post, items: [create(:item)])
      post.deliver_email
      expect(ActionMailer::Base.deliveries.last.to).to eq [post.standup.to_address]
    end

    it "raises an error if you send it twice" do
      post = create(:post, items: [create(:item)])
      post.deliver_email
      expect(ActionMailer::Base.deliveries.last.to).to eq [post.standup.to_address]
      expect { post.deliver_email }.to raise_error("Duplicate Email")
    end
  end

  describe '#items_by_type' do
    it "orders by created_at asc" do
      post = create(:post)
      items = [create(:item, created_at: Time.now), create(:item, created_at: 2.days.ago)]
      post.items = items
      expect(post.items_by_type['Help']).to eq items.reverse
    end

    it "merges events without overriding today's event" do
      post = create(:post)
      post.items = [create(:event, created_at: Time.now, standup_id: post.standup.id)]

      future_item = create(:event, created_at: Date.tomorrow, standup_id: post.standup.id)
      expect(post.items_by_type['Event']).to eq post.items + [future_item]
    end
  end

  describe "#publishable_content?" do
    it "returns false when no content items and no events" do
      post = create(:post)
      expect(post.publishable_content?).to eq false
    end

    it "returns false when no public content items or public event" do
      post = create(:post, items: [create(:item, created_at: Time.now, public: false)])
      create(:event, date: 1.day.from_now.to_date, public: false)
      expect(post.publishable_content?).to eq false
    end

    it "returns true when there are public content items" do
      post = create(:post, items: [create(:item, created_at: Time.now, public: true)])
      expect(post.publishable_content?).to eq true
    end

    it "returns true when there are public events" do
      post = create(:post, items: [create(:item, created_at: Time.now, public: false)])
      create(:event, date: 1.day.from_now.to_date, public: true, standup: post.standup)
      expect(post.publishable_content?).to eq true
    end
  end

  describe "#emailable_content?" do
    it "returns false when no content items and no events" do
      post = create(:post)
      expect(post.emailable_content?).to eq false
    end

    it "returns true with a private content item" do
      post = create(:post, items: [create(:item, created_at: Time.now, public: false)])
      expect(post.emailable_content?).to eq true
    end

    it "returns true with a private event" do
      post = create(:post, items: [])
      create(:event, date: 1.day.from_now.to_date, public: false, standup: post.standup)
      expect(post.emailable_content?).to eq true
    end

    it "returns true when there are public content items" do
      post = create(:post, items: [create(:item, created_at: Time.now, public: true)])
      expect(post.emailable_content?).to eq true
    end

    it "returns true when there are public events" do
      post = create(:post, items: [])
      create(:event, date: 1.day.from_now.to_date, public: true, standup: post.standup)
      expect(post.emailable_content?).to eq true
    end
  end

  describe "#public_url" do
    it 'exists when blog service is defined and has a blog_post_id' do
      @fakeWordpress = double("wordpress service", :"minimally_configured?" => true, :"public_url" => 'http://example.com')
      allow(Rails.application.config).to receive(:blogging_service) { @fakeWordpress }

      post = Post.new
      post.blog_post_id = 'some-thing'
      expect(post.public_url).to eq('http://example.com/some-thing')
    end

    it 'returns an empty string when blog service is not defined' do
      @fakeWordpress = double("wordpress service", :"minimally_configured?" => false)
      allow(Rails.application.config).to receive(:blogging_service) { @fakeWordpress }

      post = Post.new
      post.blog_post_id = 'some-thing'
      expect(post.public_url).to eq('')
    end

    it 'returns an empty string when blog_post_id is not defined ' do
      @fakeWordpress = double("wordpress service", :"minimally_configured?" => true, :"public_url" => 'http://example.com')
      allow(Rails.application.config).to receive(:blogging_service) { @fakeWordpress }

      post = Post.new
      expect(post.public_url).to eq('')
    end
  end
end
