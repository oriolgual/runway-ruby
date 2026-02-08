# frozen_string_literal: true

require "spec_helper"
require "runway_ml/client"
require_relative "shared_client_examples"
require "net/http"

RSpec.describe RunwayML::Client do
  let(:api_secret) { "test-api-key" }
  let(:client) { described_class.new(api_secret: api_secret) }

  before do
    # Mock Net::HTTP for each method
    allow(Net::HTTP).to receive(:start).and_wrap_original do |m, *args, &block|
      http = double("Net::HTTP")
      allow(http).to receive(:request) do |request|
        case request
        when Net::HTTP::Post
          instance_double("Net::HTTPResponse", body: '{"result":"posted"}', is_a?: true)
        when Net::HTTP::Get
          instance_double("Net::HTTPResponse", body: '{"result":"gotten"}', is_a?: true)
        when Net::HTTP::Delete
          instance_double("Net::HTTPResponse", body: '{"result":"deleted"}', is_a?: true)
        else
          raise "Unexpected request type"
        end
      end
      block.call(http)
    end
  end

  it_behaves_like "RunwayML client API"
end
