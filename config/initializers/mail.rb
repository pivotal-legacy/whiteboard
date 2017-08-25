require 'json'

if ENV['SMTP_RELAY'].present?

  smtp_relay = ENV['SMTP_RELAY']

  ActionMailer::Base.smtp_settings = {
      :address => smtp_relay,
  }

elsif ENV['VCAP_SERVICES'].present?

  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])

  if vcap_services.include? "sendgrid"
    # After starting your cloud foundry app run:
    # cf files [app-name] logs/env.log to see the VCAP_SERVICES vars
    credentials = vcap_services["sendgrid"][0]['credentials']

    ActionMailer::Base.smtp_settings = {
        :address => credentials['hostname'],
        :port => '587',
        :authentication => :plain,
        :user_name => credentials['username'],
        :password => credentials['password'],
        :domain => 'cfapps.io'
    }
  else
    Rails.logger.info "Send grid not present, mailer not configured"
  end
end
