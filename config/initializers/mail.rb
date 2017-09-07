require 'json'


def find_mailer_credentials(user_provided_services)
  for ups in user_provided_services

    if ups.include? "name"
      service_name = ups['name']
      if service_name.eql? "whiteboard-mailer"
        credentials = ups["credentials"]
        return credentials
      end
    end
  end
  nil
end


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
  elsif vcap_services.include? "user-provided"
    # After starting your cloud foundry app run:
    # cf files [app-name] logs/env.log to see the VCAP_SERVICES vars
    credentials = find_mailer_credentials(vcap_services["user-provided"])

    if credentials.nil?
      Rails.logger.info "whiteboard-mailer service not present, mailer not configured"
    else
      Rails.logger.info "whiteboard-mailer exists"

      ActionMailer::Base.smtp_settings = {
          :address => credentials['hostname'],
          :port => '587',
          :authentication => :login,
          :user_name => credentials['username'],
          :password => credentials['password'],
          :enable_starttls_auto => true,
          :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
      }
    end

  else
    Rails.logger.info "mail service not present, mailer not configured"
  end
end
