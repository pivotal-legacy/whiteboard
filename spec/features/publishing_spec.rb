require 'spec_helper'

describe "publishing", type: :request, js: true, inaccessible: true do
  let!(:standup) { FactoryGirl.create(:standup, title: 'Camelot', subject_prefix: "[Standup][CO]") }

  before do
    mock_omniauth
    visit '/auth/google_apps/callback'
    visit '/'

    WordpressService.any_instance.stub(:minimally_configured?).and_return(true)
    WordpressService.any_instance.should_not_receive(:send!)
  end

  it "does not allow publishing to blog and email when no public content" do
    click_link(standup.title)

    fill_in "Blogger Name(s)", with: "Me"
    fill_in "Post Title (eg: Best Standup Ever)", with: "empty post"

    page.evaluate_script('window.confirm = function() { return true; }')
    click_on "Create Post"

    page.should have_content("Please update these items with any new information from standup:")

    page.should have_css('p[disabled="disabled"]', text: 'Send Email')
    within('div', text: 'Please double check this email for accuracy.') do
      page.should have_content("There is no content to publish")
    end

    page.should have_css('p[disabled="disabled"]', text: 'Post Blog Entry')
    within('div', text: 'Please double check the blog post.') do
      page.should have_content("There is no content to publish")
    end

    within "div.block.header", text: "NEW FACES" do
      find("i").click
    end

    fill_in "item_title", with: "John Doe"

    click_on "Create New Face"

    find_link("Send Email").should be
    page.should have_css('p[disabled="disabled"]', text: 'Post Blog Entry')
  end
end
