# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Validators::TextToSpeechValidator do
  subject(:validator) { described_class.new }

  describe "#validate" do
    context "with valid parameters" do
      it "returns no errors" do
        result = validator.validate(
          prompt_text: "The quick brown fox",
          voice: { type: "runway-preset", presetId: "Leslie" }
        )

        expect(result[:errors]).to be_empty
      end

      it "returns no errors for minimum length prompt" do
        result = validator.validate(
          prompt_text: "a",
          voice: { type: "runway-preset", presetId: "Leslie" }
        )

        expect(result[:errors]).to be_empty
      end

      it "returns no errors for maximum length prompt" do
        result = validator.validate(
          prompt_text: "a" * 1000,
          voice: { type: "runway-preset", presetId: "Leslie" }
        )

        expect(result[:errors]).to be_empty
      end
    end

    context "with invalid prompt_text" do
      it "returns error for empty prompt_text" do
        result = validator.validate(
          prompt_text: "",
          voice: { type: "runway-preset", presetId: "Leslie" }
        )

        expect(result[:errors][:prompt_text]).not_to be_nil
      end

      it "returns error for nil prompt_text" do
        result = validator.validate(
          prompt_text: nil,
          voice: { type: "runway-preset", presetId: "Leslie" }
        )

        expect(result[:errors][:prompt_text]).not_to be_nil
      end

      it "returns error for prompt_text exceeding max length" do
        long_text = "a" * 1001
        result = validator.validate(
          prompt_text: long_text,
          voice: { type: "runway-preset", presetId: "Leslie" }
        )

        expect(result[:errors][:prompt_text]).not_to be_nil
      end
    end

    context "with invalid voice" do
      it "returns error when voice is nil" do
        result = validator.validate(
          prompt_text: "Hello",
          voice: nil
        )

        expect(result[:errors][:voice]).not_to be_nil
      end

      it "returns error with invalid voice type" do
        result = validator.validate(
          prompt_text: "Hello",
          voice: { type: "invalid", presetId: "Leslie" }
        )

        expect(result[:errors][:voice]).not_to be_nil
      end

      it "returns error with invalid preset ID" do
        result = validator.validate(
          prompt_text: "Hello",
          voice: { type: "runway-preset", presetId: "InvalidVoice" }
        )

        expect(result[:errors][:voice]).not_to be_nil
      end
    end
  end
end
