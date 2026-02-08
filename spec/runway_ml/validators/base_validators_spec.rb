# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::Validators::RatioValidator do
  describe "#validate" do
    it "accepts valid ratio" do
      validator = described_class.new(valid_ratios: [ "16:9", "4:3" ])
      errors = {}
      validator.validate("16:9", errors)
      expect(errors).to be_empty
    end

    it "rejects invalid ratio" do
      validator = described_class.new(valid_ratios: [ "16:9", "4:3" ])
      errors = {}
      validator.validate("21:9", errors)
      expect(errors[:ratio]).to include("must be one of")
    end
  end
end

RSpec.describe RunwayML::Validators::PromptTextValidator do
  describe "#validate" do
    context "when required" do
      it "rejects empty text" do
        validator = described_class.new(max_length: 100, required: true)
        errors = {}
        validator.validate("", errors)
        expect(errors[:prompt_text]).to eq("cannot be empty")
      end
    end

    context "when not required" do
      it "accepts empty text" do
        validator = described_class.new(max_length: 100, required: false)
        errors = {}
        validator.validate("", errors)
        expect(errors).to be_empty
      end
    end

    it "rejects text exceeding max length" do
      validator = described_class.new(max_length: 10, required: true)
      errors = {}
      validator.validate("a" * 20, errors)
      expect(errors[:prompt_text]).to include("must be at most 10 characters")
    end

    it "accepts text within max length" do
      validator = described_class.new(max_length: 100, required: true)
      errors = {}
      validator.validate("Hello world", errors)
      expect(errors).to be_empty
    end
  end
end

RSpec.describe RunwayML::Validators::DurationValidator do
  describe "#validate" do
    context "with valid_values" do
      it "accepts valid value" do
        validator = described_class.new(valid_values: [ 5, 10 ])
        errors = {}
        validator.validate(5, errors)
        expect(errors).to be_empty
      end

      it "rejects invalid value" do
        validator = described_class.new(valid_values: [ 5, 10 ])
        errors = {}
        validator.validate(7, errors)
        expect(errors[:duration]).to include("must be one of")
      end
    end

    context "with range" do
      it "accepts value in range" do
        validator = described_class.new(range: 2..10)
        errors = {}
        validator.validate(5, errors)
        expect(errors).to be_empty
      end

      it "rejects value out of range" do
        validator = described_class.new(range: 2..10)
        errors = {}
        validator.validate(15, errors)
        expect(errors[:duration]).to include("must be between")
      end
    end

    context "with exact value" do
      it "accepts exact value" do
        validator = described_class.new(exact: 8)
        errors = {}
        validator.validate(8, errors)
        expect(errors).to be_empty
      end

      it "rejects non-exact value" do
        validator = described_class.new(exact: 8)
        errors = {}
        validator.validate(6, errors)
        expect(errors[:duration]).to eq("must be exactly 8")
      end
    end
  end
end

RSpec.describe RunwayML::Validators::SeedValidator do
  describe "#validate" do
    it "accepts seed in range" do
      validator = described_class.new(range: 0..100)
      errors = {}
      validator.validate(50, errors)
      expect(errors).to be_empty
    end

    it "rejects seed out of range" do
      validator = described_class.new(range: 0..100)
      errors = {}
      validator.validate(200, errors)
      expect(errors[:seed]).to include("must be between")
    end

    it "accepts nil seed" do
      validator = described_class.new(range: 0..100)
      errors = {}
      validator.validate(nil, errors)
      expect(errors).to be_empty
    end
  end
end

RSpec.describe RunwayML::Validators::ImageUriValidator do
  let(:validator) { described_class.new }

  describe "#validate" do
    it "accepts valid HTTPS URL" do
      errors = {}
      validator.validate("https://example.com/image.jpg", errors)
      expect(errors).to be_empty
    end

    it "rejects HTTPS URL exceeding max length" do
      errors = {}
      long_url = "https://example.com/" + ("a" * 2100)
      validator.validate(long_url, errors)
      expect(errors[:prompt_image]).to include("must be at most 2048 characters")
    end

    it "accepts valid Runway URI" do
      errors = {}
      validator.validate("runway://abc123", errors)
      expect(errors).to be_empty
    end

    it "accepts valid data URI with JPEG" do
      errors = {}
      validator.validate("data:image/jpeg;base64,/9j/4AAQSkZJRg==", errors)
      expect(errors).to be_empty
    end

    it "rejects data URI with GIF" do
      errors = {}
      validator.validate("data:image/gif;base64,R0lGODlh", errors)
      expect(errors[:prompt_image]).to include("GIF images are not supported")
    end

    it "rejects URI shorter than 13 characters" do
      errors = {}
      validator.validate("short", errors)
      expect(errors[:prompt_image]).to eq("URI must be at least 13 characters")
    end

    it "rejects invalid URI scheme" do
      errors = {}
      validator.validate("ftp://example.com/image.jpg", errors)
      expect(errors[:prompt_image]).to include("must be a valid HTTPS URL")
    end
  end
end
