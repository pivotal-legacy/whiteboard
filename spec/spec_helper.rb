RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.before(:all, type: :feature) do
    current_window = Capybara.current_window
    current_window.resize_to(2000, 2000)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each, :type => :feature) do |example|
    if example.exception
      artifact = save_page
      puts "\"#{example.description}\" failed. Page saved to #{artifact}"
    end
  end

  config.render_views

  config.include FactoryGirl::Syntax::Methods
  config.include MockAuth, :type => :feature

  def click_on_preferences(page)
    page.find('a.btn.btn-navbar').click if page.has_css?('.btn.btn-navbar')
    click_on 'Preferences'
  end

  def blur(page)
    page.find(:css, 'body').click
  end
end
