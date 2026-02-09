# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Validators::UploadsValidator do
  let(:validator) { described_class.new }

  describe "#validate" do
    context "with valid filename" do
      it "accepts mp4 file" do
        result = validator.validate(filename: "video.mp4")
        expect(result[:errors]).to be_empty
      end

      it "accepts png file" do
        result = validator.validate(filename: "image.png")
        expect(result[:errors]).to be_empty
      end

      it "accepts mp3 file" do
        result = validator.validate(filename: "audio.mp3")
        expect(result[:errors]).to be_empty
      end

      it "accepts case-insensitive extensions" do
        result = validator.validate(filename: "VIDEO.MP4")
        expect(result[:errors]).to be_empty
      end

      it "accepts minimum length filename" do
        result = validator.validate(filename: "abc.mp4")
        expect(result[:errors]).to be_empty
      end

      it "accepts maximum length filename" do
        filename = "a" * 251 + ".mp4"
        result = validator.validate(filename: filename)
        expect(result[:errors]).to be_empty
      end
    end

    context "with invalid filename" do
      it "returns error for empty filename" do
        result = validator.validate(filename: "")
        expect(result[:errors][:filename]).to include("cannot be empty")
      end

      it "returns error for non-string filename" do
        result = validator.validate(filename: 12345)
        expect(result[:errors][:filename]).to include("must be a string")
      end

      it "returns error for filename too short" do
        result = validator.validate(filename: "ab")
        expect(result[:errors][:filename]).to include("between 3 and 255")
      end

      it "returns error for filename too long" do
        filename = "a" * 252 + ".mp4"
        result = validator.validate(filename: filename)
        expect(result[:errors][:filename]).to include("between 3 and 255")
      end

      it "returns error for unsupported extension" do
        result = validator.validate(filename: "file.xyz")
        expect(result[:errors][:filename]).to include("valid extension")
      end

      it "returns error for missing extension" do
        result = validator.validate(filename: "file")
        expect(result[:errors][:filename]).to include("valid extension")
      end
    end
  end
end
