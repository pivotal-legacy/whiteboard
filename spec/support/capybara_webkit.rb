Capybara::Webkit.configure do |config|
  # Silently return an empty 200 response for any requests to unknown URLs.
  config.block_unknown_urls
end
