require 'rails_helper'

describe PostMailer do
  describe 'send_to_all' do
    let(:post) { create(:post, items: [create(:item, title: '"Winning"',description: 'Like this & like "that"')]) }
    let(:destination) { Faker::Internet.email }
    let(:from_address) { 'noreply@fakedomain.io' }
    let(:mail) { PostMailer.send_to_all(post, destination, from_address, post.standup_id) }

    it 'sets the title to be the posts title' do
      expect(mail.subject).to eq post.title_for_email
    end

    it 'sets the from address' do
      expect(mail.from).to eq [from_address]
    end

    it 'renders the items in the body of the message' do
expect(mail.text_part.body).to include(post.items.first.title)
    end

    it 'includes a link to the standup' do
expect(mail.text_part.body).to include(standup_items_url(post.standup))
    end

    it 'properly deals with & and " by not escaping them' do
expect(mail.text_part.body).to include('"Winning"')
expect(mail.text_part.body).to include('Like this & like "that"')
    end

    it 'delivers to the specified address' do
      expect(mail.to).to eq [destination]
    end
  end
end
