require 'rack/test'

ENV['APP_ENV'] = 'test'

RSpec.configure do |config|
  config.filter_run_including :focus
  config.filter_run_excluding :disabled
  config.filter_run_excluding :slow

  config.fail_fast = true
  config.run_all_when_everything_filtered = true

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.include Rack::Test::Methods
end

module Rack
  class MockResponse
    def json
      JSON.parse(body)
    end
  end
end
