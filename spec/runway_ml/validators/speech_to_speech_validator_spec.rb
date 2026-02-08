# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Validators::SpeechToSpeechValidator do
  subject(:validator) { described_class.new }

  describe "#validate" do
    context "with valid parameters" do
      it "returns no errors with audio media" do
        result = validator.validate(
          media: { type: "audio", uri: "https://example.com/audio.mp3" },
          voice: { type: "runway-preset", presetId: "Maggie" },
          remove_background_noise: false
        )

        expect(result[:errors]).to be_empty
      end

      it "returns no errors with video media" do
        result = validator.validate(
          media: { type: "video", uri: "https://example.com/video.mp4" },
          voice: { type: "runway-preset", presetId: "Noah" },
          remove_background_noise: true
        )

        expect(result[:errors]).to be_empty
      end
    end

    context "with invalid media" do
      it "returns error when media is nil" do
        result = validator.validate(
          media: nil,
          voice: { type: "runway-preset", presetId: "Maggie" },
          remove_background_noise: false
        )

        expect(result[:errors][:media]).not_to be_nil
      end

      it "returns error with invalid media type" do
        result = validator.validate(
          media: { type: "invalid", uri: "https://example.com/audio.mp3" },
          voice: { type: "runway-preset", presetId: "Maggie" },
          remove_background_noise: false
        )

        expect(result[:errors][:media]).not_to be_nil
      end

      it "returns error with empty media uri" do
        result = validator.validate(
          media: { type: "audio", uri: "" },
          voice: { type: "runway-preset", presetId: "Maggie" },
          remove_background_noise: false
        )

        expect(result[:errors][:media]).not_to be_nil
      end
    end

    context "with invalid voice" do
      it "returns error when voice is nil" do
        result = validator.validate(
          media: { type: "audio", uri: "https://example.com/audio.mp3" },
          voice: nil,
          remove_background_noise: false
        )

        expect(result[:errors][:voice]).not_to be_nil
      end

      it "returns error with invalid voice type" do
        result = validator.validate(
          media: { type: "audio", uri: "https://example.com/audio.mp3" },
          voice: { type: "invalid", presetId: "Maggie" },
          remove_background_noise: false
        )

        expect(result[:errors][:voice]).not_to be_nil
      end

      it "returns error with invalid preset ID" do
        result = validator.validate(
          media: { type: "audio", uri: "https://example.com/audio.mp3" },
          voice: { type: "runway-preset", presetId: "InvalidVoice" },
          remove_background_noise: false
        )

        expect(result[:errors][:voice]).not_to be_nil
      end
    end

    context "with invalid remove_background_noise" do
      it "returns error when not a boolean" do
        result = validator.validate(
          media: { type: "audio", uri: "https://example.com/audio.mp3" },
          voice: { type: "runway-preset", presetId: "Maggie" },
          remove_background_noise: "true"
        )

        expect(result[:errors][:remove_background_noise]).not_to be_nil
      end
    end
  end
end
