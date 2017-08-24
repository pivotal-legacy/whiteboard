ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'simplecov'

SimpleCov.start
Capybara.javascript_driver = :webkit
Capybara.default_driver = :webkit

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

require 'spec_helper'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = false

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Choose one or more libraries:
    with.library :rails
  end
end