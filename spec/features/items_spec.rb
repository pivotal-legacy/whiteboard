require 'spec_helper'

describe "items", type: :request, js: true do
  let!(:standup) { FactoryGirl.create(:standup, title: 'San Francisco', subject_prefix: "[Standup][SF]") }
  let!(:other_standup) { FactoryGirl.create(:standup, title: 'New York') }

  before do
    login
    visit '/'
    click_link(standup.title)

    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Fred Flintstone"
    select 'New York', :from => 'item[standup_id]'
    click_button 'Create New Face'

    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Johnathon McKenzie"
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create New Face'

    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Jane Doe"
    fill_in 'item_date', :with => 5.days.from_now.to_date.strftime("%Y-%m-%d")
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create New Face'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Meetup"
    fill_in 'item_date', :with => 5.days.from_now.to_date.strftime("%Y-%m-%d")
    select 'New York', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Party"
    fill_in 'item_date', :with => 5.days.from_now.to_date.strftime("%Y-%m-%d")
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Interesting"] i').click
    fill_in 'item_title', :with => "Linux 3.2 out"
    fill_in 'item_author', :with => "Linus Torvalds"
    fill_in 'item_description', with: "Check it out!"
    click_button 'Create Item'
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
    find('section.deck-current').should have_content("Linux 3.2 out")
    find('section.deck-current').should have_content("Linus Torvalds")
    find('section.deck-current').should_not have_selector('.in')
    find('section.deck-current a[data-toggle]').click
    find('section.deck-current').should have_selector('.in')
    page.execute_script("$.deck('next')")

    find('section.deck-current').should have_content "Events"
    find('section.deck-current').should have_content "Party"
    find('section.deck-current').should_not have_content "Meetup"
    page.execute_script("$.deck('next')")

    find('section.deck-current').should_not have_content "Events"
    find('section.deck-current').should have_content "Woohoo"

    all('.exit-presentation').first.click

    current_path.should == standup_items_path(standup)
  end
end
