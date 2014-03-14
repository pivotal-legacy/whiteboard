require 'spec_helper'

describe "Adding new faces", js: true do
  it "doesn't allow start dates in the past" do
    standup = FactoryGirl.create(:standup, ip_addresses_string: "127.0.0.1/32")

    login
    visit '/'

    click_on standup.title
    find(:css, '[data-kind="NewFace"]').click
    fill_in "item[title]", with: "Jane"

    fill_in "item[date]", with: "2010-01-01"

    find(:css, '[name="item[date]"]').click
    find(:css, 'td.day', text: '11').click

    find_field("item[date]").value.should == "2010-01-01"

    click_on "Create New Face"

    page.should have_content "Please choose a date in present or future"
    #page.should have_content "Create New Face" #TODO: as of 2014-02-05, this captures a bug.
  end
end
