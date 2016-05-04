require 'rails_helper'

describe "creating a standup post from the whiteboard", js: true do
  let!(:standup) { FactoryGirl.create(:standup, time_zone_name: 'Pacific Time (US & Canada)', title: 'Camelot', subject_prefix: "[Standup][CO]") }
  let!(:timezone) { ActiveSupport::TimeZone.new(standup.time_zone_name) }
  let!(:item) { FactoryGirl.create(:item, kind: 'Interesting', date: timezone.today, title: "So so interesting", standup: standup) }

  before do
    login
  end

  def verify_on_items_page
    expect(page).to have_css('h2', text: 'NEW FACES')
    expect(page).to have_css('h2', text: 'HELPS')
    expect(page).to have_css('h2', text: 'INTERESTINGS')
    expect(page).to have_css('h2', text: 'EVENTS')
  end

  before do
    visit '/'
    click_link(standup.title)

    expect(page).to have_content("So so interesting")

    fill_in "Standup host(s)", with: "Me"
    fill_in "Email subject", with: "empty post"

    @message = accept_confirm do
      click_on "Send Email"
    end
  end

  it "emails and archives the e-mail in 1 step when the user creates the post" do
    verify_on_items_page

    expect(@message).to eq("You are about to send today's stand up email. Continue?")
    expect(page).to have_content('Successfully sent Standup email!')
    expect(page).to have_content('News, Articles, Tools, Best Practices, etc')
    expect(page).to_not have_content('So so interesting')
  end
end

