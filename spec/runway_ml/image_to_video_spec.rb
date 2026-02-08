# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::ImageToVideo do
  let(:client) { RunwayML.test_client }
  let(:image_to_video) { described_class.new(client: client) }

  describe "#create" do
    context "with valid gen4_turbo parameters" do
      it "validates and posts to the API" do
        expected_params = {
          model: "gen4_turbo",
          promptImage: "https://example.com/image.jpg",
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 5
        }
        client.inject_response(:post, "image_to_video", params: expected_params, response: { "id" => "123" })

        result = image_to_video.create(
          model: "gen4_turbo",
          prompt_image: "https://example.com/image.jpg",
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 5
        )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq("123")
        expect(client).to have_been_called_with(method: :post, path: "image_to_video", params: expected_params)
      end

      it "includes optional seed parameter" do
        expected_params = {
          model: "gen4_turbo",
          promptImage: "https://example.com/image.jpg",
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 5,
          seed: 12345
        }
        client.inject_response(:post, "image_to_video", params: expected_params, response: { "id" => "task-123" })

        image_to_video.create(
          model: "gen4_turbo",
          prompt_image: "https://example.com/image.jpg",
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 5,
          seed: 12345
        )
        expect(client).to have_been_called_with(method: :post, path: "image_to_video", params: expected_params)
      end

      it "includes content moderation settings" do
        expected_params = {
          model: "gen4_turbo",
          promptImage: "https://example.com/image.jpg",
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 5,
          contentModeration: { publicFigureThreshold: "low" }
        }
        client.inject_response(:post, "image_to_video", params: expected_params, response: { "id" => "task-123" })

        image_to_video.create(
          model: "gen4_turbo",
          prompt_image: "https://example.com/image.jpg",
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 5,
          public_figure_threshold: "low"
        )
        expect(client).to have_been_called_with(method: :post, path: "image_to_video", params: expected_params)
      end
    end

    context "with valid veo3.1 parameters" do
      it "validates and posts with audio parameter" do
        expected_params = {
          model: "veo3.1",
          promptImage: "https://example.com/image.jpg",
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 6,
          audio: false
        }
        client.inject_response(:post, "image_to_video", params: expected_params, response: { "id" => "task-456" })

        image_to_video.create(
          model: "veo3.1",
          prompt_image: "https://example.com/image.jpg",
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 6,
          audio: false
        )
        expect(client).to have_been_called_with(method: :post, path: "image_to_video", params: expected_params)
      end
    end

    context "with valid veo3 parameters" do
      it "validates and posts with exact duration" do
        expected_params = {
          model: "veo3",
          promptImage: "https://example.com/image.jpg",
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 8
        }
        client.inject_response(:post, "image_to_video", params: expected_params, response: { "id" => "task-789" })

        image_to_video.create(
          model: "veo3",
          prompt_image: "https://example.com/image.jpg",
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 8
        )
        expect(client).to have_been_called_with(method: :post, path: "image_to_video", params: expected_params)
      end
    end

    context "with invalid model" do
      it "raises ValidationError" do
        expect {
          image_to_video.create(
            model: "invalid_model",
            prompt_image: "https://example.com/image.jpg",
            prompt_text: "A beautiful sunset",
            ratio: "1280:720",
            duration: 5
          )
        }.to raise_error(RunwayML::ValidationError, /model.*must be one of/)
      end
    end

    context "with invalid ratio for gen4_turbo" do
      it "raises ValidationError" do
        expect {
          image_to_video.create(
            model: "gen4_turbo",
            prompt_image: "https://example.com/image.jpg",
            prompt_text: "A beautiful sunset",
            ratio: "999:999",
            duration: 5
          )
        }.to raise_error(RunwayML::ValidationError, /ratio/)
      end
    end

    context "with invalid duration for gen4_turbo" do
      it "raises ValidationError for duration out of range" do
        expect {
          image_to_video.create(
            model: "gen4_turbo",
            prompt_image: "https://example.com/image.jpg",
            prompt_text: "A beautiful sunset",
            ratio: "1280:720",
            duration: 20
          )
        }.to raise_error(RunwayML::ValidationError, /duration/)
      end
    end

    context "with invalid duration for veo3" do
      it "raises ValidationError for non-exact duration" do
        expect {
          image_to_video.create(
            model: "veo3",
            prompt_image: "https://example.com/image.jpg",
            prompt_text: "A beautiful sunset",
            ratio: "1280:720",
            duration: 5
          )
        }.to raise_error(RunwayML::ValidationError, /duration.*must be exactly 8/)
      end
    end

    context "with empty prompt text" do
      it "raises ValidationError" do
        expect {
          image_to_video.create(
            model: "gen4_turbo",
            prompt_image: "https://example.com/image.jpg",
            prompt_text: "",
            ratio: "1280:720",
            duration: 5
          )
        }.to raise_error(RunwayML::ValidationError, /prompt_text/)
      end
    end

    context "with invalid seed" do
      it "raises ValidationError for seed out of range" do
        expect {
          image_to_video.create(
            model: "gen4_turbo",
            prompt_image: "https://example.com/image.jpg",
            prompt_text: "A beautiful sunset",
            ratio: "1280:720",
            duration: 5,
            seed: -1
          )
        }.to raise_error(RunwayML::ValidationError, /seed/)
      end
    end

    context "with prompt_image as array for gen4_turbo" do
      it "validates and posts with first position" do
        expected_params = {
          model: "gen4_turbo",
          promptImage: [ { uri: "https://example.com/image.jpg", position: "first" } ],
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 5
        }
        client.inject_response(:post, "image_to_video", params: expected_params, response: { "id" => "task-abc" })

        image_to_video.create(
          model: "gen4_turbo",
          prompt_image: [ { uri: "https://example.com/image.jpg", position: "first" } ],
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 5
        )
        expect(client).to have_been_called_with(method: :post, path: "image_to_video", params: expected_params)
      end
    end

    context "with prompt_image as array with first and last for veo3.1" do
      it "validates and posts with both positions" do
        expected_params = {
          model: "veo3.1",
          promptImage: [
            { uri: "https://example.com/first.jpg", position: "first" },
            { uri: "https://example.com/last.jpg", position: "last" }
          ],
          promptText: "A beautiful sunset",
          ratio: "1280:720",
          duration: 6
        }
        client.inject_response(:post, "image_to_video", params: expected_params, response: { "id" => "task-def" })

        image_to_video.create(
          model: "veo3.1",
          prompt_image: [
            { uri: "https://example.com/first.jpg", position: "first" },
            { uri: "https://example.com/last.jpg", position: "last" }
          ],
          prompt_text: "A beautiful sunset",
          ratio: "1280:720",
          duration: 6
        )
        expect(client).to have_been_called_with(method: :post, path: "image_to_video", params: expected_params)
      end
    end

    context "with invalid prompt_image array for veo3.1" do
      it "raises ValidationError for only last frame" do
        expect {
          image_to_video.create(
            model: "veo3.1",
            prompt_image: [ { uri: "https://example.com/image.jpg", position: "last" } ],
            prompt_text: "A beautiful sunset",
            ratio: "1280:720",
            duration: 6
          )
        }.to raise_error(RunwayML::ValidationError, /cannot generate with only a last frame/)
      end
    end
  end
end
