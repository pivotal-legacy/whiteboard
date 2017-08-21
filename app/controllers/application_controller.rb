class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login
  before_action :set_raven_context

  def require_login
    if ENV['IP_WHITELIST']
      mapper = IpFencer.new(hydrate_ips)
      redirect_to '/login' unless session[:logged_in] || mapper.authorized?(request.remote_ip)
    else
      redirect_to '/login' unless session[:logged_in]
    end
  end

  def hydrate_ips
    ips = ENV['IP_WHITELIST'].split(',')

    ips.map do |ip|
      begin
        addr = IPAddr.new(ip)
      rescue
        puts "SKIPPING INVALID IP: #{ip}"
        next
      end
      addr
    end
  end

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_hash, url: request.url)
  end

end
