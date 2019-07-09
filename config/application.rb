require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if !Rails.env.test? && !Rails.env.development?
  Raven.configure do |config|
#   Sentry will read the SENTRY_DSN environment variable to set the DSN
  end
end

module Whiteboard
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.action_mailer.default_url_options = {:host => ENV["WHITEBOARD_MAILER_URL"]}

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.assets.initialize_on_precompile = false
    config.assets.paths << Rails.root.join("lib", "assets", "deck-js")
    config.assets.precompile += %w(deck.js deck.css)
  end
end
