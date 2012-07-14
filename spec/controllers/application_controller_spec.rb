require 'spec_helper'

describe StandupsController do
  it "does not redirect to login if coming from an authorized ip" do
    with_authorized_ips({sf: [IPAddr.new("127.0.0.1/32")]}) do
      request.env['HTTP_X_FORWARDED_FOR'] = '127.0.0.1'
      get :index
      response.should_not be_redirect
    end
  end
end
