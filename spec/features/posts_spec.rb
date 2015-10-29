require 'rails_helper'

describe "posts" do
  let!(:standup) { FactoryGirl.create(:standup, title: 'San Francisco') }

  describe "archived posts" do
    let!(:archived_post) { FactoryGirl.create(:post, standup: standup, title: "Archived Post", archived: true) }
    let!(:item) { FactoryGirl.create(:item, title: "I am helping people", post_id: archived_post.id) }

    before do
      login
      visit '/standups/1/posts/archived'
    end

    describe "clicking on a post" do
      before do
        click_link('Archived Post')
      end

      it "displays the name of the post" do
        expect(page).to have_content "Archived Post"
      end

      it "displays items in a post" do
        expect(page).to have_content "I am helping people"
      end
    end
  end
end
