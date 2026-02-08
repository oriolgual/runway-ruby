# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Validators::VoiceIsolationValidator do
  let(:validator) { described_class.new }

  describe "#validate" do
    context "with valid parameters" do
      it "returns no errors for https URL" do
        result = validator.validate(audio_uri: "https://example.com/audio.mp3")

        expect(result[:errors]).to be_empty
      end

      it "returns no errors for runway URI" do
        result = validator.validate(audio_uri: "runway://audio123")

        expect(result[:errors]).to be_empty
      end

      it "returns no errors for data URI" do
        result = validator.validate(audio_uri: "data:audio/mpeg;base64,abc123")

        expect(result[:errors]).to be_empty
      end
    end

    context "with invalid audio_uri" do
      it "returns error for nil audio_uri" do
        result = validator.validate(audio_uri: nil)

        expect(result[:errors][:audio_uri]).to include("cannot be empty")
      end

      it "returns error for empty audio_uri" do
        result = validator.validate(audio_uri: "")

        expect(result[:errors][:audio_uri]).to include("cannot be empty")
      end

      it "returns error for invalid URI format" do
        result = validator.validate(audio_uri: "invalid://audio.mp3")

        expect(result[:errors][:audio_uri]).to include("must be a valid")
      end

      it "returns error for too short URI" do
        result = validator.validate(audio_uri: "https://a")

        expect(result[:errors][:audio_uri]).to include("at least 13 characters")
      end

      it "returns error for https URL that's too long" do
        long_url = "https://" + "a" * 2050
        result = validator.validate(audio_uri: long_url)

        expect(result[:errors][:audio_uri]).to include("2048 characters")
      end

      it "returns error for runway URI that's too long" do
        long_uri = "runway://" + "a" * 5000
        result = validator.validate(audio_uri: long_uri)

        expect(result[:errors][:audio_uri]).to include("5000 characters")
      end

      it "returns error for data URI that's too long" do
        long_data_uri = "data:audio/mpeg;base64," + "a" * 16777216
        result = validator.validate(audio_uri: long_data_uri)

        expect(result[:errors][:audio_uri]).to include("16777216 characters")
      end
    end
  end
end
