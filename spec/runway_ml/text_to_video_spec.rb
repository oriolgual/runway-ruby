# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::TextToVideo do
  let(:client) { RunwayML.test_client }
  let(:text_to_video) { described_class.new(client: client) }

  describe "#create" do
    context "with valid veo3.1 parameters" do
      it "validates and posts with audio parameter" do
        expected_params = {
          model: "veo3.1",
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 6,
          audio: false
        }
        client.inject_response(:post, "text_to_video", params: expected_params, response: { "id" => "task-123" })

        result = text_to_video.create(
          model: "veo3.1",
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 6,
          audio: false
        )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq("task-123")
        expect(client).to have_been_called_with(method: :post, path: "text_to_video", params: expected_params)
      end

      it "omits audio when not provided" do
        expected_params = {
          model: "veo3.1",
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 6
        }
        client.inject_response(:post, "text_to_video", params: expected_params, response: { "id" => "task-124" })

        text_to_video.create(
          model: "veo3.1",
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 6
        )

        expect(client).to have_been_called_with(method: :post, path: "text_to_video", params: expected_params)
      end
    end

    context "with valid veo3 parameters" do
      it "validates and posts with exact duration" do
        expected_params = {
          model: "veo3",
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 8
        }
        client.inject_response(:post, "text_to_video", params: expected_params, response: { "id" => "task-456" })

        text_to_video.create(
          model: "veo3",
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 8
        )

        expect(client).to have_been_called_with(method: :post, path: "text_to_video", params: expected_params)
      end
    end

    context "with invalid model" do
      it "raises ValidationError" do
        expect {
          text_to_video.create(
            model: "invalid_model",
            prompt_text: "A beautiful sunset",
            ratio: "1280:720",
            duration: 6
          )
        }.to raise_error(RunwayML::ValidationError, /model.*must be one of/)
      end
    end

    context "with invalid ratio" do
      it "raises ValidationError" do
        expect {
          text_to_video.create(
            model: "veo3.1",
            prompt_text: "A beautiful sunset",
            ratio: "999:999",
            duration: 6
          )
        }.to raise_error(RunwayML::ValidationError, /ratio/)
      end
    end

    context "with invalid duration for veo3" do
      it "raises ValidationError for non-exact duration" do
        expect {
          text_to_video.create(
            model: "veo3",
            prompt_text: "A beautiful sunset",
            ratio: "1280:720",
            duration: 6
          )
        }.to raise_error(RunwayML::ValidationError, /duration.*must be exactly 8/)
      end
    end

    context "with empty prompt text" do
      it "raises ValidationError" do
        expect {
          text_to_video.create(
            model: "veo3.1",
            prompt_text: "",
            ratio: "1280:720",
            duration: 6
          )
        }.to raise_error(RunwayML::ValidationError, /prompt_text/)
      end
    end

    context "with audio provided for veo3" do
      it "raises ValidationError" do
        expect {
          text_to_video.create(
            model: "veo3",
            prompt_text: "A beautiful sunset",
            ratio: "1280:720",
            duration: 8,
            audio: true
          )
        }.to raise_error(RunwayML::ValidationError, /audio.*not supported/)
      end
    end
  end
end
