require 'rspec/collection_matchers'
require 'rack/test'
require_relative '../app'

ENV['APP_ENV'] = 'test'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.fail_fast = true
  config.run_all_when_everything_filtered = true

  config.filter_run_including :focus
  config.filter_run_excluding :disabled
  config.filter_run_excluding :slow

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.include Rack::Test::Methods

  def app
    Sudoku::App
  end
end

module Rack
  class MockResponse
    def json
      JSON.parse(body)
    end
  end
end
