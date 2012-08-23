require 'spec_helper'

describe "items", type: :request, js: true do
  let!(:standup) { FactoryGirl.create(:standup) }
  before do
    mock_omniauth
    visit '/auth/google_apps/callback'
    visit '/'
    click_link(standup.title)
    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Johnathon McKenzie"
    click_button 'Create New Face'
    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Party"
    fill_in 'item_date', :with => 5.days.from_now.to_date.strftime("%Y-%m-%d")
    click_button 'Create Item'
  end

  it "happy path blog post" do
    find('a[data-kind=Help] i').click
    fill_in 'item_title', :with => "IE8 doesn't work"
    fill_in 'item_description', :with => "No, srsly.  It doesn't work"
    click_button 'Create Item'

    current_url.should match(/http:\/\/127\.0\.0\.1:\d*\//)

    page.execute_script "$.rails.confirm = function() { return true; }"
    fill_in 'post_title', with: 'Epic Standup'
    click_button 'create-post'

    find('a[data-kind=Interesting] i').click
    fill_in 'item_title', :with => "Rubymine 5.0 is Out"
    find("button:contains('Public')").click
    click_button 'Create Item'

    fill_in 'post_from', with: 'Matthew'
    click_button 'Update'

    find('.email_post').should have_content("From: Matthew")
    find('.email_post').should have_content("Johnathon McKenzie")
    find('.email_post').should have_content("IE8 doesn't work")
    find('.email_post').should have_content("Rubymine 5.0 is Out")
    find('.email_post').should have_content("Party")

    find('.blog_post').should_not have_content("Johnathon McKenzie")
    find('.blog_post').should_not have_content("IE8 doesn't work")
    find('.blog_post').should have_content("Rubymine 5.0 is Out")

    click_link 'Archive The Post'

    current_url.should match(/http:\/\/127\.0\.0\.1:\d*\//)

    find('a.posts').click
    click_link 'Archived Posts'

    find('table').should have_content "Epic Standup"
  end

  it 'deck.js for standup' do
    visit presentation_standup_items_path(standup)
    find('section.deck-current').should have_content "Standup"
    page.execute_script("$.deck('next')")
    find('section.deck-current').should have_content "New faces"
    find('section.deck-current').should have_content "Johnathon McKenzie"
    page.execute_script("$.deck('next')")
    find('section.deck-current').should have_content "Helps"
    page.execute_script("$.deck('next')")
    find('section.deck-current').should have_content "Interestings"
    page.execute_script("$.deck('next')")
    find('section.deck-current').should have_content "Events"
    find('section.deck-current').should have_content "Party"
    page.execute_script("$.deck('next')")
    find('section.deck-current').should_not have_content "Events"
  end
end
