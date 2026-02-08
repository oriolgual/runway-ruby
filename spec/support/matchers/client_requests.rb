# frozen_string_literal: true

RSpec::Matchers.define :have_been_called_with do |expected_request|
  match do |client|
    @actual_requests = client.respond_to?(:requests) ? client.requests : []
    @actual_requests.any? do |request|
      expected_request.all? { |key, value| request[key] == value }
    end
  end

  failure_message do |client|
    actual = client.respond_to?(:requests) ? client.requests : []
    "expected client to have been called with #{expected_request.inspect}, but got #{actual.inspect}"
  end

  failure_message_when_negated do |client|
    actual = client.respond_to?(:requests) ? client.requests : []
    "expected client not to have been called with #{expected_request.inspect}, but got #{actual.inspect}"
  end
end
