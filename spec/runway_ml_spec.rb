# frozen_string_literal: true

RSpec.describe RunwayML do
  it "has a version number" do
    expect(RunwayML::VERSION).not_to be nil
  end

  describe ".client" do
    it "creates a client with the provided API secret" do
      client = RunwayML.client(api_secret: "test-key")
      expect(client).to be_a(RunwayML::TestClient)
    end

    it "uses ENV['RUNWAY_API_SECRET'] by default" do
      ENV["RUNWAY_API_SECRET"] = "env-key"
      client = RunwayML.client
      expect(client).to be_a(RunwayML::TestClient)
    ensure
      ENV.delete("RUNWAY_API_SECRET")
    end
  end

  describe ".image_to_video" do
    it "creates a video task without instantiating a client" do
      client = RunwayML.test_client
      params = {
        model: "gen4_turbo",
        promptImage: "https://example.com/image.jpg",
        promptText: "A beautiful sunset",
        ratio: "1280:720",
        duration: 5
      }
      client.inject_response(:post, "image_to_video", params: params, response: { "id" => "123" })

      result = RunwayML.image_to_video(
        api_secret: "test-key",
        model: "gen4_turbo",
        prompt_image: "https://example.com/image.jpg",
        prompt_text: "A beautiful sunset",
        ratio: "1280:720",
        duration: 5
      )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq("123")
      expect(client).to have_been_called_with(method: :post, path: "image_to_video", params: params)
    end

    it "uses ENV['RUNWAY_API_SECRET'] by default" do
      ENV["RUNWAY_API_SECRET"] = "env-key"
      client = RunwayML.test_client
      params = {
        model: "gen4_turbo",
        promptImage: "https://example.com/image.jpg",
        promptText: "A beautiful sunset",
        ratio: "1280:720",
        duration: 5
      }
      client.inject_response(:post, "image_to_video", params: params, response: { "id" => "456" })

      result = RunwayML.image_to_video(
        model: "gen4_turbo",
        prompt_image: "https://example.com/image.jpg",
        prompt_text: "A beautiful sunset",
        ratio: "1280:720",
        duration: 5
      )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq("456")
      expect(client).to have_been_called_with(method: :post, path: "image_to_video", params: params)
    ensure
      ENV.delete("RUNWAY_API_SECRET")
    end
  end

  describe ".text_to_video" do
    it "creates a video task without instantiating a client" do
      client = RunwayML.test_client
      params = {
        model: "veo3.1",
        promptText: "A beautiful sunset",
        ratio: "1280:720",
        duration: 6,
        audio: true
      }
      client.inject_response(:post, "text_to_video", params: params, response: { "id" => "789" })

      result = RunwayML.text_to_video(
        api_secret: "test-key",
        model: "veo3.1",
        prompt_text: "A beautiful sunset",
        ratio: "1280:720",
        duration: 6,
        audio: true
      )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq("789")
      expect(client).to have_been_called_with(method: :post, path: "text_to_video", params: params)
    end

    it "uses ENV['RUNWAY_API_SECRET'] by default" do
      ENV["RUNWAY_API_SECRET"] = "env-key"
      client = RunwayML.test_client
      params = {
        model: "veo3",
        promptText: "A beautiful sunset",
        ratio: "1280:720",
        duration: 8
      }
      client.inject_response(:post, "text_to_video", params: params, response: { "id" => "790" })

      result = RunwayML.text_to_video(
        model: "veo3",
        prompt_text: "A beautiful sunset",
        ratio: "1280:720",
        duration: 8
      )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq("790")
      expect(client).to have_been_called_with(method: :post, path: "text_to_video", params: params)
    ensure
      ENV.delete("RUNWAY_API_SECRET")
    end
  end
end
