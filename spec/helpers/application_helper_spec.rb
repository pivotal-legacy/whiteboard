require 'rails_helper'

describe ApplicationHelper do
  describe "#pending_post_count" do
    let(:standup) { create(:standup) }
    let(:other_standup) { create(:standup) }

    before { create(:post, standup: standup) }

    it "can count" do
      expect(helper.pending_post_count(standup)).to eq 1
    end

    it "doesn't count unassociated standups" do
      expect(helper.pending_post_count(other_standup)).to eq 0
    end
  end

  describe "#show_or_edit_post_path" do
    it "links to edit if not archived" do
      post = create(:post)
      expect(helper.show_or_edit_post_path(post)).to eq edit_post_path(post)
    end

    it "links to show if archived" do
      post = create(:post, archived: true)
      expect(helper.show_or_edit_post_path(post)).to eq post_path(post)
    end
  end

  describe "#format_title" do
    subject { helper.format_title(item) }

    context "the item is an event" do
      let(:item) { Item.new(kind: "Interesting", title: "Not Interesting", date: Time.zone.tomorrow) }
      it { is_expected.to eq "#{item.date.strftime("%A(%m/%d)")}: #{item.title}" }
    end

    context "the item is not an event" do
      context "the item does not have a date" do
        let(:item) { Item.new(kind: "Interesting", title: "Not Interesting") }
        it { is_expected.to eq item.title }
      end

      context "the item does have a date" do
        let(:item) { Item.new(kind: "Interesting", title: "Not Interesting", date: Time.zone.tomorrow) }
        it { is_expected.to eq "#{item.date.strftime("%A(%m/%d)")}: #{item.title}" }
      end
    end
  end

  describe "#date_label" do
    describe "when there is not a date" do
      let(:item) { create(:item, kind: "Help") }

      it "returns nothing" do
        label = helper.date_label(item)
        expect(label).to be_blank
      end
    end

    describe "when there is a date" do
      describe "when passed an Event" do
        it "displays day of week" do
          event = create(:item, kind: "Event", date: Date.new(2012, 11, 05))
          label = helper.date_label(event)
          expect(label).to eq "Monday: "
        end
      end

      describe "when passed an Item that is not an Event" do
        let(:item) { create(:item, kind: "Help") }

        describe "when the date is <= today" do
          before do
            item.date = Date.yesterday
          end

          it "returns nothing" do
            label = helper.date_label(item)
            expect(label).to be_blank
          end
        end

        describe "when the date is in the future" do

          before do
            Timecop.freeze(Time.zone.local(2012,11,05, 20,00))
            item.date = Date.new(2012, 11, 07)
          end

          after { Timecop.return }

          it "returns the day of the week" do
            label = helper.date_label(item)
            expect(label).to eq "Wednesday: "
          end
        end

        describe "when the date is more than a week away" do
          before do
            Timecop.freeze(Time.zone.local(2012,11,04, 20,00))
            item.date = Date.new(2012, 11, 22)
          end

          after { Timecop.return }

          it "displays the date rather than the day name" do
            label = helper.date_label(item)
            expect(label).to eq "11/22: "
          end
        end
      end
    end
  end

  describe "#wordpress_enabled?" do
    it "returns true if the app's blogging service is minimally configured" do
      allow(Rails.application.config.blogging_service).to receive(:minimally_configured?).and_return(true)
      expect(helper.wordpress_enabled?).to eq true
    end

    it "returns false otherwise" do
      allow(Rails.application.config.blogging_service).to receive(:minimally_configured?).and_return(false)
      expect(helper.wordpress_enabled?).to eq false
    end
  end
end
