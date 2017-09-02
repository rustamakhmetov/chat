require 'rails_helper'

Capybara.server = :puma
Capybara.javascript_driver = :webkit
Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  config.include AcceptanceMacros, type: :feature
  config.include WaitForAjax, type: :feature
  config.include OmniauthMacros, type: :feature

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, :sphinx => true) do
    # For tests tagged with Sphinx, use deletion (or truncation)
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end