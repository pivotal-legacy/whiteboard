require 'rails_helper'

describe SessionsController do
  it 'routes to logout' do
    expect(get('/logout')).to route_to('sessions#destroy')
  end

  it 'routes to create' do
    expect(post('/auth/saml/callback')).to route_to(:controller => 'sessions', :action => 'create')
  end
end
