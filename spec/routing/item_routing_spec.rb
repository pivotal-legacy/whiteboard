require 'rails_helper'

describe ItemsController do
  it "routes presentation" do
    expect(get("standups/2/items/presentation")).to route_to("items#presentation", standup_id: '2')
  end

  it "routes new" do
    expect(get("standups/1/items/new")).to route_to("items#new", standup_id: '1')
  end

  it "routes creates" do
    expect(post("items")).to route_to("items#create")
  end
end
