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
      page.should have_css('.subheader.today', text: 'Today')
      page.should have_css('.today + .item', text: 'Happy Hour')
      page.should have_css('.subheader.tomorrow', text: 'Tomorrow')
      page.should have_css('.tomorrow + .item', text: 'Baseball')
      page.should have_css('.subheader.upcoming', text: 'Upcoming')
      page.should have_css('.upcoming + .item', text: 'Party')
    end

    within '.new_face' do
      page.should have_css('.subheader.today', text: 'Today')
      page.should have_css('.today + .item', text: 'Johnathon McKenzie')
      page.should have_css('.subheader.upcoming', text: 'Upcoming')
      page.should have_css('.upcoming + .item', text: 'Jane Doe')
    end

    within '.interesting' do
      page.should have_css('.item', text: 'Linus Torvalds')
      first('a[data-toggle]').click
      page.should have_selector('.in')
      page.should have_selector('code', text: 'inline code!')
      page.should have_link('www.links.com')
    end

    within '.win' do
      page.should have_css('.item', text: 'Tracker iOS 7 app')
    end

    visit presentation_standup_items_path(standup)

    within 'section.deck-current' do
      page.should have_content "Standup"
      page.should have_css('.countdown')
    end
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      page.should have_content "New faces"
      page.should have_content "Today"
      page.should have_content "Upcoming"
      page.should have_content "Johnathon McKenzie"
    end
    page.execute_script("$.deck('next')")

    find('section.deck-current').should have_content "Helps"
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      page.should have_content "Interestings"
      page.should have_content("Linux 3.2 out")
      page.should have_content("Linus Torvalds")
      page.should have_content("Rails 62 is out")
      page.should_not have_selector('.in')
      first('a[data-toggle]').click
      page.should have_selector('.in')
      page.should have_content("Check it out:")
      page.should have_link("www.links.com")
      page.should have_selector("code", text: "inline code!")
    end
    page.execute_script("$.deck('next')")

    find('section.deck-current').should have_content "Events"
    page.should have_css('section.deck-current', text: 'Today')
    page.should have_css('.today + ul li', text: 'Happy Hour')
    page.should have_css('section.deck-current', text: 'Tomorrow')
    page.should have_css('.tomorrow + ul li', text: 'Baseball')
    page.should have_css('section.deck-current', text: 'Upcoming')
    page.should have_css('.upcoming + ul li', text: 'Party')
    find('section.deck-current').should_not have_content "Meetup"
    find('section.deck-current').should_not have_content("Rails 62 is out")
    page.execute_script("$.deck('next')")

    find('section.deck-current').should have_content "Wins"
    page.should have_css('section.deck-current', text: 'Tracker iOS 7 app')
    find('section.deck-current').should_not have_content 'Happy Hour'
    find('section.deck-current').should_not have_content 'Baseball'
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      page.should_not have_content "Wins"
      page.should have_content "Woohoo"
      page.should have_css('img[src="http://example.com/bar.png"]')
    end

    all('.exit-presentation').first.click

    current_path.should == standup_items_path(standup)
  end

  it 'does not let you create wins if the feature flag is off' do
    ENV["ENABLE_WINS"] = 'false'

    login
    visit '/'
    click_link(standup.title)

    page.should_not have_css('a[data-kind="Win"] i')
  end

  it 'hides wins if there are none' do
    login
    visit presentation_standup_items_path(standup)

    within 'section.deck-current' do
      page.should have_content "Standup"
      page.should have_css('.countdown')
    end
    page.execute_script("$.deck('next')")

    find('section.deck-current').should have_content "New faces"
    page.execute_script("$.deck('next')")
    find('section.deck-current').should have_content "Helps"
    page.execute_script("$.deck('next')")
    find('section.deck-current').should have_content "Interestings"
    page.execute_script("$.deck('next')")
    find('section.deck-current').should have_content "Events"
    page.execute_script("$.deck('next')")

    within 'section.deck-current' do
      page.should_not have_content "Wins"
      page.should have_content "Woohoo"
    end
  end

  describe "the bottom navbar" do
    context "when the screen width starts at or above 737px" do
      it "locks to the bottom of the screen but unlocks whenever the width goes below 737px" do
        page.current_window.resize_to 737, 2000

        login
        visit '/'
        click_link(standup.title)

        page.find('div.content-wrapper').should have_css('.navbar-fixed-bottom')
        page.current_window.resize_to 736, 2000
        page.find('div.content-wrapper').should_not have_css('.navbar-fixed-bottom')
        page.current_window.resize_to 737, 2000
        page.find('div.content-wrapper').should have_css('.navbar-fixed-bottom')
      end
    end

    context "when the screen width starts below 737px" do
      it "is unlocked from the bottom of the screen but locks whenever the width goes above 737px" do
        page.current_window.resize_to 736, 2000

        login
        visit '/'
        click_link(standup.title)

        page.find('div.content-wrapper').should_not have_css('.navbar-fixed-bottom')
        page.current_window.resize_to 737, 2000
        page.find('div.content-wrapper').should have_css('.navbar-fixed-bottom')
        page.current_window.resize_to 736, 2000
        page.find('div.content-wrapper').should_not have_css('.navbar-fixed-bottom')
      end
    end
  end
end

def fill_date_selector_with(date)
  fill_in 'item_date', :with => date
  blur(page)
end
