# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Validators::SoundEffectValidator do
  subject(:validator) { described_class.new }

  describe "#validate" do
    context "with valid parameters" do
      it "returns no errors" do
        result = validator.validate(
          prompt_text: "A thunderstorm sound",
          duration: 10,
          loop: true
        )

        expect(result[:errors]).to be_empty
      end

      it "returns no errors when duration is nil" do
        result = validator.validate(
          prompt_text: "A thunderstorm sound",
          duration: nil,
          loop: false
        )

        expect(result[:errors]).to be_empty
      end

      it "returns no errors for minimum duration" do
        result = validator.validate(
          prompt_text: "A beep",
          duration: 0.5,
          loop: false
        )

        expect(result[:errors]).to be_empty
      end

      it "returns no errors for maximum duration" do
        result = validator.validate(
          prompt_text: "A long sound",
          duration: 30,
          loop: false
        )

        expect(result[:errors]).to be_empty
      end
    end

    context "with invalid prompt_text" do
      it "returns error for empty prompt_text" do
        result = validator.validate(
          prompt_text: "",
          duration: nil,
          loop: false
        )

        expect(result[:errors][:prompt_text]).not_to be_nil
      end

      it "returns error for nil prompt_text" do
        result = validator.validate(
          prompt_text: nil,
          duration: nil,
          loop: false
        )

        expect(result[:errors][:prompt_text]).not_to be_nil
      end

      it "returns error for prompt_text exceeding max length" do
        long_text = "a" * 3001
        result = validator.validate(
          prompt_text: long_text,
          duration: nil,
          loop: false
        )

        expect(result[:errors][:prompt_text]).not_to be_nil
      end
    end

    context "with invalid duration" do
      it "returns error for duration below minimum" do
        result = validator.validate(
          prompt_text: "A sound",
          duration: 0.4,
          loop: false
        )

        expect(result[:errors][:duration]).not_to be_nil
      end

      it "returns error for duration above maximum" do
        result = validator.validate(
          prompt_text: "A sound",
          duration: 30.1,
          loop: false
        )

        expect(result[:errors][:duration]).not_to be_nil
      end
    end
  end
end
