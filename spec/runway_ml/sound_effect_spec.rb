# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::SoundEffect do
  let(:client) { RunwayML.test_client }
  let(:sound_effect) { described_class.new(client: client) }

  describe "#create" do
    context "with valid parameters" do
      it "validates and posts with all parameters" do
        expected_params = {
          model: "eleven_text_to_sound_v2",
          promptText: "A thunderstorm with heavy rain",
          duration: 10,
          loop: true
        }
        client.inject_response(:post, "sound_effect", params: expected_params, response: { "id" => "task-sound-123" })

        result = sound_effect.create(
          model: "eleven_text_to_sound_v2",
          prompt_text: "A thunderstorm with heavy rain",
          duration: 10,
          loop: true
        )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq("task-sound-123")
        expect(client).to have_been_called_with(method: :post, path: "sound_effect", params: expected_params)
      end

      it "omits duration when not provided" do
        expected_params = {
          model: "eleven_text_to_sound_v2",
          promptText: "A thunderstorm with heavy rain",
          loop: false
        }
        client.inject_response(:post, "sound_effect", params: expected_params, response: { "id" => "task-sound-124" })

        result = sound_effect.create(
          model: "eleven_text_to_sound_v2",
          prompt_text: "A thunderstorm with heavy rain"
        )

        expect(result).to be_a(RunwayML::Task)
        expect(result.id).to eq("task-sound-124")
        expect(client).to have_been_called_with(method: :post, path: "sound_effect", params: expected_params)
      end

      it "uses loop default as false when not provided" do
        expected_params = {
          model: "eleven_text_to_sound_v2",
          promptText: "Ocean waves on a beach",
          loop: false
        }
        client.inject_response(:post, "sound_effect", params: expected_params, response: { "id" => "task-sound-125" })

        sound_effect.create(
          model: "eleven_text_to_sound_v2",
          prompt_text: "Ocean waves on a beach"
        )

        expect(client).to have_been_called_with(method: :post, path: "sound_effect", params: expected_params)
      end

      it "accepts minimum duration" do
        expected_params = {
          model: "eleven_text_to_sound_v2",
          promptText: "A beep sound",
          duration: 0.5,
          loop: false
        }
        client.inject_response(:post, "sound_effect", params: expected_params, response: { "id" => "task-sound-126" })

        sound_effect.create(
          model: "eleven_text_to_sound_v2",
          prompt_text: "A beep sound",
          duration: 0.5
        )

        expect(client).to have_been_called_with(method: :post, path: "sound_effect", params: expected_params)
      end

      it "accepts maximum duration" do
        expected_params = {
          model: "eleven_text_to_sound_v2",
          promptText: "A very long sound",
          duration: 30,
          loop: false
        }
        client.inject_response(:post, "sound_effect", params: expected_params, response: { "id" => "task-sound-127" })

        sound_effect.create(
          model: "eleven_text_to_sound_v2",
          prompt_text: "A very long sound",
          duration: 30
        )

        expect(client).to have_been_called_with(method: :post, path: "sound_effect", params: expected_params)
      end
    end

    context "with invalid model" do
      it "raises ValidationError" do
        expect {
          sound_effect.create(
            model: "invalid_model",
            prompt_text: "A thunderstorm with heavy rain"
          )
        }.to raise_error(RunwayML::ValidationError, /model/)
      end
    end

    context "with invalid prompt_text" do
      it "raises ValidationError when prompt_text is empty" do
        expect {
          sound_effect.create(
            model: "eleven_text_to_sound_v2",
            prompt_text: ""
          )
        }.to raise_error(RunwayML::ValidationError, /prompt_text/)
      end

      it "raises ValidationError when prompt_text is nil" do
        expect {
          sound_effect.create(
            model: "eleven_text_to_sound_v2",
            prompt_text: nil
          )
        }.to raise_error(RunwayML::ValidationError, /prompt_text/)
      end

      it "raises ValidationError when prompt_text exceeds max length" do
        long_text = "a" * 3001
        expect {
          sound_effect.create(
            model: "eleven_text_to_sound_v2",
            prompt_text: long_text
          )
        }.to raise_error(RunwayML::ValidationError, /prompt_text/)
      end
    end

    context "with invalid duration" do
      it "raises ValidationError when duration is below minimum" do
        expect {
          sound_effect.create(
            model: "eleven_text_to_sound_v2",
            prompt_text: "A sound",
            duration: 0.4
          )
        }.to raise_error(RunwayML::ValidationError, /duration/)
      end

      it "raises ValidationError when duration exceeds maximum" do
        expect {
          sound_effect.create(
            model: "eleven_text_to_sound_v2",
            prompt_text: "A sound",
            duration: 30.1
          )
        }.to raise_error(RunwayML::ValidationError, /duration/)
      end
    end
  end
end
