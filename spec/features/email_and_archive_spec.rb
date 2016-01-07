require 'rails_helper'

describe "creating a standup post from the whiteboard", js: true do
  let!(:item) { FactoryGirl.create(:item, kind: 'Interesting', title: "So so interesting") }

  before do
    login
  end

  def verify_on_items_page
    expect(page).to have_css('h2.title', text: 'NEW FACES')
    expect(page).to have_css('h2.title', text: 'HELPS')
    expect(page).to have_css('h2.title', text: 'INTERESTINGS')
    expect(page).to have_css('h2.title', text: 'EVENTS')
  end

  context "when standup is configured for 1-click email & archive" do
    let!(:standup) { FactoryGirl.create(:standup, title: 'Camelot', subject_prefix: "[Standup][CO]", one_click_post: true, items: [item]) }

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
      expect(page).to_not have_content('So so interesting')
    end
  end

  context "when standup is NOT configured for 1-click email & archive" do
    let!(:standup) { FactoryGirl.create(:standup, title: 'Camelot', subject_prefix: "[Standup][CO]", one_click_post: false, items: [item]) }

    before do
      visit '/'
      click_link(standup.title)

      expect(page).to have_content("So so interesting")

      fill_in "Standup host(s)", with: "Me"
      fill_in "Email subject", with: "empty post"

      @message = accept_confirm do
        click_on "Create Post"
      end
    end

    it "requires the user to individually review, send e-mail and then archive" do
      expect(@message).to eq('This will clear the board and create a new one for tomorrow, you can always get back to this post under the "Posts" menu in the header. Continue?')
      expect(page).to have_content("So so interesting")

      accept_confirm do
        click_on "Send Email"
      end

      expect(page).to have_content("This email was sent at")
      expect(page).to_not have_css('a.btn', text: 'Send Email')

      click_on "Archive Post"

      verify_on_items_page
      expect(page).to_not have_content('So so interesting')
    end
  end

end
