require 'spec_helper'

describe "publishing", type: :request, inaccessible: true do
  let!(:standup) { FactoryGirl.create(:standup, title: 'Camelot', subject_prefix: "[Standup][CO]") }

  before do
    login
    visit '/'

    WordpressService.any_instance.stub(:minimally_configured?).and_return(true)
  end

  it "does not allow publishing to blog and email when no public content" do
    WordpressService.any_instance.should_not_receive(:send!)
    click_link(standup.title)

    fill_in "Blogger Name(s)", with: "Me"
    fill_in "Post Title (eg: Best Standup Ever)", with: "empty post"

    page.evaluate_script('window.confirm = function() { return true; }')
    click_on "Create Post"

    page.should have_content("Please update these items with any new information from standup:")

    page.should have_css('p[disabled="disabled"]', text: 'Send Email')
    within('div.well', text: 'Please double check this email for accuracy.') do
      page.should have_content("There is no content to publish")
    end

    page.should have_css('p[disabled="disabled"]', text: 'Post Blog Entry')
    within('div.well', text: 'Please double check the blog post.') do
      page.should have_content("There is no content to publish")
    end

    find('a[data-kind="NewFace"] i').click

    fill_in "item_title", with: "John Doe"

    click_on "Create New Face"

    find_link("Send Email").should be
    page.should have_css('p[disabled="disabled"]', text: 'Post Blog Entry')
  end

  it "allows reposting if error returned from wordpress" , js: true do
    WordpressService.any_instance.should_receive(:send!).and_raise(XMLRPC::FaultException.new(123, "Wrong size. Was 180, should be 131"))
    click_link(standup.title)


    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Happy Hour"
    fill_in 'item_date', :with => Date.today
    select 'Camelot', from: 'item[standup_id]'
    click_on 'Post to Blog'
    click_button 'Create Event'

    fill_in "Blogger Name(s)", with: "Me"
    fill_in "Post Title (eg: Best Standup Ever)", with: "empty post"

    page.evaluate_script('window.confirm = function() { return true; }')
    click_on "Create Post"

    click_on 'Post Blog Entry'

    page.driver.browser.switch_to.alert.accept

    within '.alert.alert-error' do
      page.should have_content('Wrong size. Was 180, should be 131')
    end

    page.should_not have_content("This entry was posted at")
    page.should have_css('a', text: 'Post Blog Entry')
  end


  it "shows the URL the post was published to" , js: true do
    WordpressService.any_instance.should_receive(:send!).and_return("best-post-eva")
    click_link(standup.title)


    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Happy Hour"
    fill_in 'item_date', :with => Date.today
    select 'Camelot', from: 'item[standup_id]'
    click_on 'Post to Blog'
    click_button 'Create Event'

    fill_in "Blogger Name(s)", with: "Me"
    fill_in "Post Title (eg: Best Standup Ever)", with: "empty post"

    page.evaluate_script('window.confirm = function() { return true; }')
    click_on "Create Post"

    click_on 'Post Blog Entry'

    page.driver.browser.switch_to.alert.accept

    page.should have_content("This entry was posted at")
    page.should have_css('a', text: 'best-post-eva')
  end
end
