class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    session[:logged_in] = true
    session[:username] = request.env.fetch('omniauth.auth').fetch('info').fetch('name')
    redirect_to '/'
  end

  def destroy
    session[:logged_in] = false
  end

  def new
  end

  def require_login
  end
end
