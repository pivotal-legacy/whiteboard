require 'spec_helper'

describe "standups", type: :request do
  before do
    login
    visit '/'
    FactoryGirl.create(:standup, ip_addresses_string: "127.0.0.1/32")
  end

  it "creates new standups", js: true do
    find('h2').should have_content 'CHOOSE A STANDUP'
    click_link('New Standup')

    fill_in 'standup_title', with: "London"
    fill_in 'standup_subject_prefix', with: "[Standup][ENG]"
    select 'Mountain Time (US & Canada)', from: "standup_time_zone_name"
    fill_in 'standup_to_address', with: "all@pivotallabs.com"
    fill_in 'standup_closing_message', with: "Woohoo"
    fill_in 'standup_ip_addresses_string', with: "192.168.0.0/24\n\r192.168.1.5\n\r127.0.0.1"
    fill_in 'standup_start_time_string', with: '10:00am'
    fill_in 'standup_image_urls', with: 'http://example.com/bar.png'
    click_button 'Create Standup'

    visit '/'
    page.should have_content 'LONDON'
    click_link('London')

    current_page = current_url
    current_page.should match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)
    find('div.navbar-fixed-top').should have_content 'London Whiteboard'
    page.find('a.posts', text: 'Posts').click
    page.should have_content 'Current Post'
    click_link('Current Post')
    page.should have_content 'London Whiteboard'
    current_page.should match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)

    click_on 'Preferences'
    page.should have_css('input[value="London"]')
    page.should have_css('input[value="[Standup][ENG]"]')
    page.should have_css('input[value="all@pivotallabs.com"]')
    page.should have_css('input[value="Woohoo"]')
    page.should have_css('option[value="Mountain Time (US & Canada)"][selected]')
    page.should have_css('input[value="10:00am"]')

    within '.ip_addresses textarea' do
      page.should have_content('192.168.0.0/24')
      page.should have_content('192.168.1.5')
      page.should have_content('127.0.0.1')
    end
  end


  it "creates new standups does not automatically provide access, but provides instruction", js: true do
    find('h2').should have_content 'CHOOSE A STANDUP'
    click_link('New Standup')

    fill_in 'standup_title', with: "London"
    fill_in 'standup_subject_prefix', with: "[Standup][ENG]"
    select 'Mountain Time (US & Canada)', from: "standup_time_zone_name"
    fill_in 'standup_to_address', with: "all@pivotallabs.com"
    fill_in 'standup_closing_message', with: "Woohoo"
    fill_in 'standup_ip_addresses_string', with: "192.168.0.0/24\n\r192.168.1.5"
    fill_in 'standup_start_time_string', with: '10:00am'
    fill_in 'standup_image_urls', with: 'http://example.com/bar.png'

    expect(page).to have_content "Please remember to add your own IP (127.0.0.1) to the whitelist if you'd like to access this standup from your current location."

    click_button 'Create Standup'

    visit '/'
    page.should_not have_content 'LONDON'
  end
end
