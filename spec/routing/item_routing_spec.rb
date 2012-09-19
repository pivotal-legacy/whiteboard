require 'spec_helper'

describe ItemsController do
  it "routes presentation" do
    get("standups/2/items/presentation").should route_to("items#presentation", standup_id: '2')
  end

  it "routes new" do
    get("standups/1/items/new").should route_to("items#new", standup_id: '1')
  end

  it "routes creates" do
    post("items").should route_to("items#create")
  end
end
