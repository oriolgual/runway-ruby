# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Validators::VoiceDubbingValidator do
  let(:validator) { described_class.new }

  describe "#validate" do
    context "with valid parameters" do
      it "returns no errors" do
        result = validator.validate(
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "es",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors]).to be_empty
      end

      it "returns no errors with all optional parameters" do
        result = validator.validate(
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "fr",
          disable_voice_cloning: true,
          drop_background_audio: false,
          num_speakers: 3
        )

        expect(result[:errors]).to be_empty
      end

      it "accepts runway URI" do
        result = validator.validate(
          audio_uri: "runway://audio123",
          target_lang: "de",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors]).to be_empty
      end

      it "accepts data URI" do
        result = validator.validate(
          audio_uri: "data:audio/mpeg;base64,abc123",
          target_lang: "ja",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors]).to be_empty
      end
    end

    context "with invalid audio_uri" do
      it "returns error for nil audio_uri" do
        result = validator.validate(
          audio_uri: nil,
          target_lang: "es",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors][:audio_uri]).to include("cannot be empty")
      end

      it "returns error for empty audio_uri" do
        result = validator.validate(
          audio_uri: "",
          target_lang: "es",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors][:audio_uri]).to include("cannot be empty")
      end

      it "returns error for invalid URI format" do
        result = validator.validate(
          audio_uri: "invalid://audio.mp3",
          target_lang: "es",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors][:audio_uri]).to include("must be a valid")
      end

      it "returns error for too short URI" do
        result = validator.validate(
          audio_uri: "https://a",
          target_lang: "es",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors][:audio_uri]).to include("at least 13 characters")
      end
    end

    context "with invalid target_lang" do
      it "returns error for nil target_lang" do
        result = validator.validate(
          audio_uri: "https://example.com/audio.mp3",
          target_lang: nil,
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors][:target_lang]).to include("cannot be empty")
      end

      it "returns error for empty target_lang" do
        result = validator.validate(
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors][:target_lang]).to include("cannot be empty")
      end

      it "returns error for invalid target_lang" do
        result = validator.validate(
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "invalid",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors][:target_lang]).to include("must be one of")
      end
    end

    context "with invalid optional parameters" do
      it "returns error for non-boolean disable_voice_cloning" do
        result = validator.validate(
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "es",
          disable_voice_cloning: "yes",
          drop_background_audio: nil,
          num_speakers: nil
        )

        expect(result[:errors][:disable_voice_cloning]).to include("boolean")
      end

      it "returns error for non-boolean drop_background_audio" do
        result = validator.validate(
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "es",
          disable_voice_cloning: nil,
          drop_background_audio: "yes",
          num_speakers: nil
        )

        expect(result[:errors][:drop_background_audio]).to include("boolean")
      end

      it "returns error for non-integer num_speakers" do
        result = validator.validate(
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "es",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: "two"
        )

        expect(result[:errors][:num_speakers]).to include("integer")
      end

      it "returns error for negative num_speakers" do
        result = validator.validate(
          audio_uri: "https://example.com/audio.mp3",
          target_lang: "es",
          disable_voice_cloning: nil,
          drop_background_audio: nil,
          num_speakers: -1
        )

        expect(result[:errors][:num_speakers]).to include("between")
      end
    end
  end
end
