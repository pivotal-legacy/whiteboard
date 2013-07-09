require 'spec_helper'

describe "standups", type: :request, js: true, inaccessible: true do
  before do
    mock_omniauth
    visit '/auth/google_apps/callback'
    visit '/'
  end

  it "creates new standups", js: true do
    with_authorized_ips({london: [IPAddr.new("127.0.0.1/32")]}) do
      find('h2').should have_content 'CHOOSE A STANDUP'
      click_link('New Standup')

      fill_in 'standup_title', with: "London"
      fill_in 'standup_subject_prefix', with: "[Standup][ENG]"
      select 'london', from: "standup_ip_key"
      fill_in 'standup_to_address', with: "all@pivtoallabs.com"
      click_button 'Create Standup'

      current_page = current_url
      current_page.should match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)
      find('div.navbar-fixed-top').should have_content 'London Whiteboard'
      page.find('a.posts', text: 'Posts').click
      click_link('Current Post')
      current_page.should match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)
    end
  end
end
