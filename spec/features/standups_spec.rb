require 'rails_helper'

describe "standups", :js do
  before do
    login
    visit '/'
    FactoryGirl.create(:standup)

    expect(find('h2')).to have_content 'CHOOSE A STANDUP'
    click_link('New Standup')

    fill_in 'standup_title', with: "London"
    fill_in 'standup_subject_prefix', with: "[Standup][ENG]"
    select 'Mountain Time (US & Canada)', from: "standup_time_zone_name"
    fill_in 'standup_to_address', with: "all@pivotallabs.com"
    fill_in 'standup_closing_message', with: "Woohoo"
    fill_in 'standup_start_time_string', with: '10:00am'
    fill_in 'standup_image_urls', with: 'http://example.com/bar.png'
    check 'standup_one_click_post'
    click_button 'Create Standup'

    click_link('All Standups')
    expect(page).to have_content 'LONDON'
    click_link('London')
  end

  it "creates new standups", js: true do
    current_page = current_url
    expect(current_page).to match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)
    expect(find('.navbar-fixed-top')).to have_content 'London Whiteboard'

    page.find('a.btn.btn-navbar').click if page.has_css?('.btn.btn-navbar')
    page.find('a.posts', text: 'Posts').click
    expect(page).to have_content 'Current Post'
    click_link('Current Post')
    expect(page).to have_content 'London Whiteboard'
    expect(current_page).to match(/http:\/\/127\.0\.0\.1:\d*\/standups\/\d*/)

    click_on_preferences(page)
    expect(page).to have_css('input[value="London"]')
    expect(page).to have_css('input[value="[Standup][ENG]"]')
    expect(page).to have_css('input[value="all@pivotallabs.com"]')
    expect(page).to have_css('input[value="Woohoo"]')
    expect(page).to have_css('option[value="Mountain Time (US & Canada)"][selected]')
    expect(page).to have_css('input[name="standup[one_click_post]"][checked="checked"]')
    expect(page).to have_css('input[value="10:00am"]')
  end

  it "allows you to delete existing standups", js: true do
    click_on_preferences(page)
    click_on 'Delete Standup'

    expect(current_url).to match(/http:\/\/127\.0\.0\.1:\d*\/standups$/)
    expect(page).to_not have_content 'London Whiteboard'
  end

  it 'takes you to the last standup you viewed' do
    visit '/'
    click_link('London')

    visit '/'
    expect(page).to have_content('London Whiteboard')
  end

  it 'does not take you to a standup that no longer exists' do
    visit standup_path(1238)

    expect(page).to have_content('A standup with the ID 1238 does not exist.')
  end

  it 'does not take you to a previously viewed standup that no longer exists' do
    london_standup = Standup.last
    london_standup.id = 1230
    london_standup.save

    visit '/'
    expect(page).not_to have_content('London')
    expect(page).to have_content('Whiteboard')
  end
end
