# frozen_string_literal: true

RSpec.describe RunwayML do
  it "has a version number" do
    expect(RunwayML::VERSION).not_to be nil
  end

  describe ".client" do
    it "creates a client with the provided API secret" do
      client = RunwayML.client(api_secret: "test-key")
      expect(client).to be_a(RunwayML::Client)
    end

    it "uses ENV['RUNWAY_API_SECRET'] by default" do
      ENV["RUNWAY_API_SECRET"] = "env-key"
      client = RunwayML.client
      expect(client).to be_a(RunwayML::Client)
    ensure
      ENV.delete("RUNWAY_API_SECRET")
    end
  end

  describe ".image_to_video" do
    it "creates a video task without instantiating a client" do
      # Mock the HTTP client's post method
      allow_any_instance_of(RunwayML::Client).to receive(:post).and_return({ "id" => "123" })

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
    end

    it "uses ENV['RUNWAY_API_SECRET'] by default" do
      ENV["RUNWAY_API_SECRET"] = "env-key"
      allow_any_instance_of(RunwayML::Client).to receive(:post).and_return({ "id" => "456" })

      result = RunwayML.image_to_video(
        model: "gen4_turbo",
        prompt_image: "https://example.com/image.jpg",
        prompt_text: "A beautiful sunset",
        ratio: "1280:720",
        duration: 5
      )

      expect(result).to be_a(RunwayML::Task)
      expect(result.id).to eq("456")
    ensure
      ENV.delete("RUNWAY_API_SECRET")
    end
  end
end
