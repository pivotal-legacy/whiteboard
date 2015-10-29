module MockAuth
  def login
    allow_any_instance_of(ApplicationController).to receive(:session).and_return({logged_in: true, username: nil})
  end
end
