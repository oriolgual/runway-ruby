# frozen_string_literal: true

require "spec_helper"
require "runway_ml/test_client"
require_relative "shared_client_examples"

RSpec.describe RunwayML::TestClient do
  let(:client) { described_class.new }

  before do
    client.inject_response(:post, "test/post", params: { foo: "bar" }, response: { "result" => "posted" })
    client.inject_response(:get, "test/get", response: { "result" => "gotten" })
    client.inject_response(:delete, "test/delete", response: { "result" => "deleted" })
  end

  it_behaves_like "RunwayML client API"
end
