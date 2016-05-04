require 'rails_helper'

describe "items", js: true do
  let!(:standup) { FactoryGirl.create(:standup, title: 'San Francisco', subject_prefix: "[Standup][SF]", closing_message: 'Woohoo', image_urls: 'http://example.com/bar.png', image_days: ['Mon']) }
  let!(:other_standup) { FactoryGirl.create(:standup, title: 'New York') }
  let(:timezone) { ActiveSupport::TimeZone.new(standup.time_zone_name) }
  let(:date_today) { timezone.now.strftime("%Y-%m-%d") }
  let(:date_tomorrow) { (timezone.now + 1.day).strftime("%Y-%m-%d") }
  let(:date_five_days) { (timezone.now + 5.days).strftime("%Y-%m-%d") }

  before do
    Timecop.travel(Time.zone.local(2013, 9, 2, 12, 0, 0)) #monday
    ENV["ENABLE_WINS"] = 'true'
  end

  after do
    Timecop.return
  end

  it 'setup and deck.js for standup' do
    login
    visit '/'
    click_link(standup.title)

    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Fred Flintstone"
    select 'New York', :from => 'item[standup_id]'
    click_button 'Create New Face'

    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Johnathon McKenzie"
    fill_date_selector_with date_today
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create New Face'

    find('a[data-kind="New face"] i').click
    fill_in 'item_title', :with => "Jane Doe"
    fill_date_selector_with date_five_days
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create New Face'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Meetup"
    fill_date_selector_with date_five_days
    select 'New York', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Party"
    fill_date_selector_with date_five_days
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Happy Hour"
    fill_date_selector_with date_today
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    fill_in 'item_title', :with => "Baseball"
    fill_date_selector_with date_tomorrow
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create Item'

    find('a[data-kind="Interesting"] i').click
    fill_in 'item_title', :with => "Linux 3.2 out"
    fill_in 'item_author', :with => "Linus Torvalds"
    fill_in 'item_description', with: "Check it out: `inline code!` and www.links.com"
    click_button 'Create Item'

    find('a[data-kind="Event"] i').click
    click_button('Interesting')
    fill_in 'item_title', :with => "Rails 62 is out"
    fill_in 'item_author', :with => "DHH"
    fill_in 'item_description', with: "Now with more f-bombs"
    click_button 'Create Item'

    find('a[data-kind="Win"] i').click
    click_button('Win')
    fill_in 'item_title', :with => "Tracker iOS 7 app"
    fill_in 'item_author', :with => "Tracker team"
    fill_in 'item_description', with: "In the app store now! New and shiny!"
    select 'San Francisco', from: 'item[standup_id]'
    click_button 'Create Item'

    visit '/'
    click_link(standup.title)

    within '.event' do
      expect(page).to have_css('.block-subheader', text: 'TODAY')
      expect(page).to have_css('.today + .item', text: 'Happy Hour')
      expect(page).to have_css('.block-subheader', text: 'TOMORROW')
      expect(page).to have_css('.tomorrow + .item', text: 'Baseball')
      expect(page).to have_css('.block-subheader', text: 'UPCOMING')
      expect(page).to have_css('.upcoming + .item', text: 'Party')
    end

    within '.new_face' do
      expect(page).to have_css('.block-subheader', text: 'TODAY')
      expect(page).to have_css('.today + .item', text: 'Johnathon McKenzie')
      expect(page).to have_css('.block-subheader', text: 'UPCOMING')
      expect(page).to have_css('.upcoming + .item', text: 'Jane Doe')
    end

    within '.interesting' do
      expect(page).to have_css('.item', text: 'Linus Torvalds')
      first('a[data-toggle]').click
      expect(page).to have_selector('.in')
      expect(page).to have_selector('code', text: 'inline code!')
      expect(page).to have_link('www.links.com')
    end

    within '.win' do
      expect(page).to have_css('.item', text: 'Tracker iOS 7 app')
    end

    visit presentation_standup_items_path(standup)

    within 'section.deck-current' do
      expect(page).to have_content "Standup"
      expect(page).to have_css('.countdown')
    end
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      expect(page).to have_content "New faces"
      expect(page).to have_content "Today"
      expect(page).to have_content "Upcoming"
      expect(page).to have_content "Johnathon McKenzie"
    end
    page.execute_script("$.deck('next')")

    expect(find('section.deck-current')).to have_content "Helps"
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      expect(page).to have_content "Interestings"
      expect(page).to have_content("Linux 3.2 out")
      expect(page).to have_content("Linus Torvalds")
      expect(page).to have_content("Rails 62 is out")
      expect(page).to_not have_selector('.in')
      first('a[data-toggle]').click
      expect(page).to have_selector('.in')
      expect(page).to have_content("Check it out:")
      expect(page).to have_link("www.links.com")
      expect(page).to have_selector("code", text: "inline code!")
    end
    page.execute_script("$.deck('next')")

    expect(find('section.deck-current')).to have_content "Events"
    expect(page).to have_css('section.deck-current', text: 'Today')
    expect(page).to have_css('.today + ul li', text: 'Happy Hour')
    expect(page).to have_css('section.deck-current', text: 'Tomorrow')
    expect(page).to have_css('.tomorrow + ul li', text: 'Baseball')
    expect(page).to have_css('section.deck-current', text: 'Upcoming')
    expect(page).to have_css('.upcoming + ul li', text: 'Party')
    expect(find('section.deck-current')).to_not have_content "Meetup"
    expect(find('section.deck-current')).to_not have_content("Rails 62 is out")
    page.execute_script("$.deck('next')")

    expect(find('section.deck-current')).to have_content "Wins"
    expect(page).to have_css('section.deck-current', text: 'Tracker iOS 7 app')
    expect(find('section.deck-current')).to_not have_content 'Happy Hour'
    expect(find('section.deck-current')).to_not have_content 'Baseball'
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      expect(page).to_not have_content "Wins"
      expect(page).to have_content "Woohoo"
      expect(page).to have_css('img[src="http://example.com/bar.png"]')
    end

    all('.exit-presentation').first.click

    expect(current_path).to eq standup_items_path(standup)
  end

  it 'does not let you create wins if the feature flag is off' do
    ENV["ENABLE_WINS"] = 'false'

    login
    visit '/'
    click_link(standup.title)

    expect(page).to_not have_css('a[data-kind="Win"] i')
  end

  it 'hides wins if there are none' do
    login
    visit presentation_standup_items_path(standup)

    within 'section.deck-current' do
      expect(page).to have_content "Standup"
      expect(page).to have_css('.countdown')
    end
    page.execute_script("$.deck('next')")

    expect(find('section.deck-current')).to have_content "New faces"
    page.execute_script("$.deck('next')")
    expect(find('section.deck-current')).to have_content "Helps"
    page.execute_script("$.deck('next')")
    expect(find('section.deck-current')).to have_content "Interestings"
    page.execute_script("$.deck('next')")
    expect(find('section.deck-current')).to have_content "Events"
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      expect(page).to_not have_content "Wins"
      expect(page).to have_content "Woohoo"
    end
  end
end

def fill_date_selector_with(date)
  fill_in 'item_date', :with => date
  blur(page)
end
