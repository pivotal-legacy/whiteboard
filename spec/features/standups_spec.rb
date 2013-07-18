require 'spec_helper'

describe "standups", type: :request, js: true do
  before do
    login
    visit '/'
  end

  it "creates new standups", js: true do
    with_authorized_ips({london: [IPAddr.new("127.0.0.1/32")]}) do
      find('h2').should have_content 'CHOOSE A STANDUP'
      click_link('New Standup')

      fill_in 'standup_title', with: "London"
      fill_in 'standup_subject_prefix', with: "[Standup][ENG]"
      select 'london', from: "standup_ip_key"
      fill_in 'standup_to_address', with: "all@pivotallabs.com"
      fill_in 'standup_closing_message', with: "Woohoo"
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
    end
  end
end
