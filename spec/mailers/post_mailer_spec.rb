require 'spec_helper'

describe PostMailer do
  describe 'send_to_all' do
    let(:standup) { create(:standup, to_address: "them@example.com") }
    let(:post) { create(:post, standup: standup, items: [create(:item, title: '"Winning"',description: 'Like this & like "that"')]) }
    let(:mail) { PostMailer.send_to_all(post) }

    it "sets the to address from the post's standup" do
      mail.to.should == ["them@example.com"]
    end

    it 'sets the title to be the posts title' do
      mail.subject.should == post.title_for_email
    end

    it 'sets the from address' do
      mail.from.should == ["noreply@pivotallabs.com"]
    end

    it 'renders the items in the body of the message' do
      mail.body.should include(post.items.first.title)
    end

    it 'properly deals with & and " by not escaping them' do
      mail.body.should include('"Winning"')
      mail.body.should include('Like this & like "that"')
    end
  end
end
