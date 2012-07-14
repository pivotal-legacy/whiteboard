require 'spec_helper'

describe ItemsController do
  it "routes presentation" do
    get("standups/2/items/presentation").should route_to("items#presentation", standup_id: '2')
  end
end
