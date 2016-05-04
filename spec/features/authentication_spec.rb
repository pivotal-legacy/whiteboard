require 'rails_helper'

describe 'Authenticating', type: :feature do
  describe 'Logging Out' do
    before do
      log_in_to_okta('email@blah.com')
      visit '/login'
      click_on 'Log in with Okta'
    end

    it 'allows you to log out' do
      expect(page).to have_content('Whiteboard')
      click_on 'Log Out'
      expect(page).to have_content('You have been logged out.')
    end

    context 'after logging out' do
      before do
        click_on 'Log Out'
      end

      it 'provides a button to log back in' do
        expect(page).to have_content('Log in with Okta')
      end
    end
  end

  context 'from a non-whitelisted ip' do
    describe 'Logging In' do
      before do
        log_in_to_okta('email@blah.com')
      end

      it 'allows you to log in and view the dashboard' do
        visit '/login'
        expect(page).to have_content('Log in with Okta')
        click_on 'Log in with Okta'
        expect(page).to have_content('Whiteboard')
        expect(page).to have_content('Choose a Standup')
      end
    end
  end

  context 'from a whitelisted ip' do
    describe 'logging in' do
      before do
        page.driver.header('X-Forwarded-For', '50.194.143.46')
        ENV['IP_WHITELIST'] = '50.194.143.46'
      end

      it 'should not force user to authenticate' do
        visit '/'
        expect(page).not_to have_content('Log in with Okta')
        expect(page).to have_content('Choose a Standup')
      end
    end
  end

  context 'with no ips in the whitelist' do
    describe 'logging in' do
      before do
        log_in_to_okta('pauliepivot@pivotal.io')
        ENV['IP_WHITELIST'] = nil
      end

      it 'should not break, but instead allow you to log in and view the dashboard' do
        visit '/login'
        expect(page).to have_content('Log in with Okta')
        click_on 'Log in with Okta'
        expect(page).to have_content('Whiteboard')
        expect(page).to have_content('Choose a Standup')
      end
    end
  end
end
