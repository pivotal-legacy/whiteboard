require 'spec_helper'

describe ApplicationHelper do
  describe "#close_standup" do
    it "picks a closing" do
      Date.stub_chain(:today, :wday).and_return(4)
      helper.should_receive(:rand).and_return(0)
      helper.standup_closing.should == "STRETCH!"
    end

    it "should remind us when its Floor Friday" do
      Date.stub_chain(:today, :wday).and_return(5)
      helper.standup_closing.should == "STRETCH! It's Floor Friday!"
    end
  end

  describe "#pending_post_count" do
    let(:standup) { create(:standup) }
    let(:other_standup) { create(:standup) }

    before { create(:post, standup: standup) }

    it "can count" do
      helper.pending_post_count(standup).should == 1
    end

    it "doesn't count unassociated standups" do
      helper.pending_post_count(other_standup).should == 0
    end
  end

  describe "#show_or_edit_post_path" do
    it "links to edit if not archived" do
      post = create(:post)
      helper.show_or_edit_post_path(post).should == edit_post_path(post)
    end

    it "links to show if archived" do
      post = create(:post, archived: true)
      helper.show_or_edit_post_path(post).should == post_path(post)
    end
  end
end
