# frozen_string_literal: true

require "runway_ml"
require "runway_ml/test_client"
require "securerandom"
require_relative "support/matchers/client_requests"

# Helper method to generate valid UUIDs for tests
def test_uuid
  SecureRandom.uuid
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    RunwayML.client_class = RunwayML::TestClient
    RunwayML.test_client = RunwayML::TestClient.new
  end

  config.after do
    RunwayML.test_client&.reset!
    RunwayML.test_client = nil
  end
end
