require 'spec_helper'

describe "standups", type: :request, js: true do
  before do
    mock_omniauth
    visit '/auth/google_apps/callback'
    visit '/'
  end

  it "creates new standups" do
    page.should have_content 'Choose a Standup'
    click_link('New Standup')

    fill_in 'standup_title', with: "London"
    fill_in 'standup_subject_prefix', with: "[Standup][ENG]"
    fill_in 'standup_to_address', with: "all@pivtoallabs.com"
    click_button 'Create Standup'

    current_page = current_url
    current_page.should match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)
    page.should have_content 'London'
    click_link('London')
    current_page.should match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)
  end
end
