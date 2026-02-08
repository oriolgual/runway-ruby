# frozen_string_literal: true

require "spec_helper"

RSpec.shared_examples "RunwayML client API" do
  let(:post_path) { "test/post" }
  let(:get_path) { "test/get" }
  let(:delete_path) { "test/delete" }
  let(:post_params) { { foo: "bar" } }
  let(:post_response) { { "result" => "posted" } }
  let(:get_response) { { "result" => "gotten" } }
  let(:delete_response) { { "result" => "deleted" } }

  describe "#post" do
    it "returns the injected or real response" do
      expect(client.post(post_path, post_params)).to eq(post_response)
    end
  end

  describe "#get" do
    it "returns the injected or real response" do
      expect(client.get(get_path)).to eq(get_response)
    end
  end

  describe "#delete" do
    it "returns the injected or real response" do
      expect(client.delete(delete_path)).to eq(delete_response)
    end
  end
end
