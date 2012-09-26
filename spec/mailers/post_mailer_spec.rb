require 'spec_helper'

describe PostMailer do
  describe 'send_to_all' do
    let(:post) { create(:post, items: [create(:item, title: '"Winning"',description: 'Like this & like "that"')]) }
    let(:destination) { Faker::Internet.email }
    let(:mail) { PostMailer.send_to_all(post, destination) }

    it 'sets the title to be the posts title' do
      mail.subject.should == post.title_for_email
    end

    it 'sets the from address' do
      mail.from.should == ["noreply@pivotallabs.com"]
    end

    it 'renders the items in the body of the message' do
      mail.body.should include(post.items.first.title)
    end

    it 'includes a link to the whiteboard app' do
      mail.body.should include(root_url)
    end

    it 'properly deals with & and " by not escaping them' do
      mail.body.should include('"Winning"')
      mail.body.should include('Like this & like "that"')
    end

    it 'delivers to the specified address' do
      mail.to.should == [destination]
    end
  end
end
