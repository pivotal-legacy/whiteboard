source 'https://rubygems.org'

ruby '2.6.2'

gem 'rails', '~> 5.2.0'

gem "bootsnap", ">= 1.1.0", require: false
gem 'mysql2', '~> 0.5.2'
gem 'unicorn'
gem 'jquery-rails'
gem 'omniauth-saml'
gem 'github-markdown', require: 'github/markdown'
gem 'sass-rails'
gem 'compass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'font-awesome-sass-rails'
gem 'newrelic_rpm'
gem 'sentry-raven'
gem 'responders', '~> 3.0'
gem 'nokogiri', '1.10.3'
gem 'loofah', '2.2.3'
gem 'rails-html-sanitizer', '1.1.0'

group :development, :production do
  gem 'rails_12factor'
end

group :test, :development do
  gem 'launchy'
  gem 'letter_opener'
  gem 'foreman'
  gem 'fakefs', :require => 'fakefs/safe'
  gem 'dotenv-rails'
  gem 'pry-rails'
  gem 'byebug'
end

group :test do
  gem 'database_cleaner'
  gem 'timecop'
  gem 'minitest'
  gem 'rspec-rails', '~> 3.8'
  gem 'shoulda-matchers', '~> 4.1'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'codeclimate-test-reporter', require: nil
  gem 'selenium-webdriver'
  gem 'rails-controller-testing'
end

group :development do
  gem 'auto_tagger'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen'
end
