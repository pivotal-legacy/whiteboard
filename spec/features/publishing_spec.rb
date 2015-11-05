require 'rails_helper'

describe "publishing", js: true do
  let!(:standup) { FactoryGirl.create(:standup, title: 'Camelot', subject_prefix: "[Standup][CO]") }

  before do
    login
    visit '/'

    allow_any_instance_of(WordpressService).to receive(:minimally_configured?).and_return(true)
  end

  it "does not allow publishing to blog and email when no public content" do
    expect_any_instance_of(WordpressService).to_not receive(:send!)
    click_link(standup.title)

    fill_in "Blogger Name(s)", with: "Me"
    fill_in "Post Title (eg: Best Standup Ever)", with: "empty post"

    page.evaluate_script('window.confirm = function() { return true; }')
    click_on "Create Post"

    expect(page).to have_content("Please update these items with any new information from standup:")

    expect(page).to have_css('p[disabled="disabled"]', text: 'Send Email')
    within('#publish', text: 'Please double check this email for accuracy.') do
      expect(page).to have_content("There is no content to publish")
    end

    expect(page).to have_css('p[disabled="disabled"]', text: 'Post Blog Entry')
    within('#publish', text: 'Please double check the blog post.') do
      expect(page).to have_content("There is no content to publish")
    end

    within "div.block.header", text: "NEW FACES" do
      find("i").click
    end

    fill_in "item_title", with: "John Doe"

    click_on "Create New Face"

    expect(find_link("Send Email")).to be
    expect(page).to have_css('p[disabled="disabled"]', text: 'Post Blog Entry')
  end

  it "allows reposting if error returned from wordpress" , js: true do
    expect_any_instance_of(WordpressService).to receive(:send!).and_raise(XMLRPC::FaultException.new(123, "Wrong size. Was 180, should be 131"))
    click_link(standup.title)


    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Happy Hour"
    fill_in 'item_date', :with => Time.zone.today
    select 'Camelot', from: 'item[standup_id]'
    click_on 'Post to Blog'
    click_button 'Create Item'

    fill_in "Blogger Name(s)", with: "Me"
    fill_in "Post Title (eg: Best Standup Ever)", with: "empty post"

    page.evaluate_script('window.confirm = function() { return true; }')
    click_on "Create Post"

    click_on 'Post Blog Entry'

    within '.alert.alert-danger' do
      expect(page).to have_content('Wrong size. Was 180, should be 131')
    end

    expect(page).to_not have_content("This entry was posted at")
    expect(page).to have_css('a', text: 'Post Blog Entry')
  end

  it "shows the URL the post was published to" , js: true do
    expect_any_instance_of(WordpressService).to receive(:send!).and_return("best-post-eva")
    click_link(standup.title)


    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Happy Hour"
    fill_in 'item_date', :with => Time.zone.today
    select 'Camelot', from: 'item[standup_id]'
    click_on 'Post to Blog'
    click_button 'Create Item'

    fill_in "Blogger Name(s)", with: "Me"
    fill_in "Post Title (eg: Best Standup Ever)", with: "empty post"

    page.evaluate_script('window.confirm = function() { return true; }')
    click_on "Create Post"

    click_on 'Post Blog Entry'

    expect(page).to have_content("This entry was posted at")
    expect(page).to have_css('a', text: 'best-post-eva')
  end
end
