# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Client do
  let(:api_secret) { "test-api-key" }
  let(:client) { described_class.new(api_secret: api_secret) }

  describe "#post" do
    context "when SSL verification fails" do
      it "raises SSLError with helpful message" do
        uri = URI("https://api.dev.runwayml.com/v1/test")

        allow(URI).to receive(:new).and_return(uri)
        allow(Net::HTTP).to receive(:start).and_raise(
          OpenSSL::SSL::SSLError.new("SSL_connect returned=1 errno=0 state=error: certificate verify failed")
        )

        expect {
          client.post("test", {})
        }.to raise_error(RunwayML::SSLError, /SSL verification failed.*certificate verify failed/)
      end
    end

    context "when network errors occur" do
      it "raises APIConnectionError for socket errors" do
        uri = URI("https://api.dev.runwayml.com/v1/test")

        allow(URI).to receive(:new).and_return(uri)
        allow(Net::HTTP).to receive(:start).and_raise(SocketError.new("Failed to open TCP connection"))

        expect {
          client.post("test", {})
        }.to raise_error(RunwayML::APIConnectionError, /Failed to open TCP connection/)
      end

      it "raises APIConnectionError for timeouts" do
        uri = URI("https://api.dev.runwayml.com/v1/test")

        allow(URI).to receive(:new).and_return(uri)
        allow(Net::HTTP).to receive(:start).and_raise(Net::OpenTimeout.new)

        expect {
          client.post("test", {})
        }.to raise_error(RunwayML::APIConnectionError)
      end
    end
  end
end
