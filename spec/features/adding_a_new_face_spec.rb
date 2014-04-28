require 'spec_helper'

describe "Adding new faces", js: true do
  let!(:standup) { FactoryGirl.create(:standup, ip_addresses_string: "127.0.0.1/32") }
  let(:timezone) { ActiveSupport::TimeZone.new(standup.time_zone_name) }
  let(:date_five_days) { timezone.now + 5.days }

  it "doesn't allow start dates in the past" do
    login
    visit '/'

    click_on standup.title
    page.execute_script("$('a[data-kind=\"New face\"]')[0].click()")

    fill_in "item[title]", with: "Jane"

    fill_in "item[date]", with: "2010-01-01"

    find(:css, '[name="item[date]"]').click
    find(:css, 'td.day', text: '11').click
    find_field("item[date]").value.should == "2010-01-01"

    hide_date_picker

    click_on "Create New Face"

    page.should have_content "Please choose a date in present or future"
    #page.should have_content "Create New Face" #TODO: as of 2014-02-05, this captures a bug.
  end

  def hide_date_picker
    find('body').click
  end

  it "allows yesterday's new faces to post today" do
    new_face = FactoryGirl.create(:new_face, standup: standup)

    Timecop.travel(date_five_days) do
      login
      visit '/'

      click_on standup.title
      fill_in 'post[from]', with: 'Capybara'
      fill_in 'post[title]', with: 'Test Cases Rule'

      find('#create-post').click

      page.driver.browser.switch_to.alert.accept

      page.should_not have_content "Unable to create post"
      current_path.should_not eq(standup_items_path(standup))

      post = Post.last
      post.items.should =~ [new_face]
    end
  end
end
