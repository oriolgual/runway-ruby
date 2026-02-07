# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe RunwayML::ImageProcessor do
  let(:processor) { described_class.new }

  describe "#process" do
    it "returns nil for nil input" do
      errors = {}
      result = processor.process(nil, errors)
      expect(result).to be_nil
    end

    it "returns string URL as-is" do
      errors = {}
      url = "https://example.com/image.jpg"
      result = processor.process(url, errors)
      expect(result).to eq(url)
    end

    context "with file path" do
      it "converts valid image file to data URI" do
        Tempfile.create([ "test_image", ".jpg" ]) do |file|
          # Write a minimal JPEG header
          file.write("\xFF\xD8\xFF\xE0\x00\x10JFIF")
          file.rewind

          errors = {}
          result = processor.process(file.path, errors)

          expect(result).to start_with("data:image/jpeg;base64,")
          expect(errors).to be_empty
        end
      end

      it "detects PNG from file extension" do
        Tempfile.create([ "test_image", ".png" ]) do |file|
          file.write("\x89PNG\r\n\x1A\n")
          file.rewind

          errors = {}
          result = processor.process(file.path, errors)

          expect(result).to start_with("data:image/png;base64,")
          expect(errors).to be_empty
        end
      end

      it "handles file not found" do
        # Create a path that looks like a file but doesn't exist
        # The processor won't try to load it unless File.exist? returns true
        # So this test verifies the error handling when a file can't be opened
        Tempfile.create([ "test", ".jpg" ]) do |file|
          path = file.path
          file.close
          File.unlink(path) # Delete the file but keep the path

          errors = {}
          result = processor.process(path, errors)

          # Since file doesn't exist, File.exist? returns false, so it's treated as a string
          expect(result).to eq(path)
          expect(errors).to be_empty
        end
      end
    end

    context "with File object" do
      it "converts File to data URI" do
        Tempfile.create([ "test_image", ".jpg" ]) do |file|
          file.write("\xFF\xD8\xFF\xE0\x00\x10JFIF")
          file.rewind

          errors = {}
          result = processor.process(File.open(file.path, "rb"), errors)

          expect(result).to start_with("data:image/jpeg;base64,")
          expect(errors).to be_empty
        end
      end
    end

    context "with StringIO object" do
      it "converts StringIO to data URI" do
        string_io = StringIO.new("\xFF\xD8\xFF\xE0\x00\x10JFIF".dup.force_encoding("ASCII-8BIT"))

        errors = {}
        result = processor.process(string_io, errors)

        expect(result).to start_with("data:image/jpeg;base64,")
        expect(errors).to be_empty
      end

      it "handles unsupported image format" do
        string_io = StringIO.new("not an image".dup.force_encoding("ASCII-8BIT"))

        errors = {}
        result = processor.process(string_io, errors)

        expect(result).to be_nil
        expect(errors[:prompt_image]).to include("unable to detect image type")
      end
    end

    context "with array of image URIs" do
      it "processes array items" do
        errors = {}
        array = [
          { uri: "https://example.com/first.jpg", position: "first" },
          { uri: "https://example.com/last.jpg", position: "last" }
        ]

        result = processor.process(array, errors)

        expect(result).to eq(array)
      end

      it "converts file paths in array" do
        Tempfile.create([ "test_image", ".jpg" ]) do |file|
          file.write("\xFF\xD8\xFF\xE0\x00\x10JFIF")
          file.rewind

          errors = {}
          array = [ { uri: file.path, position: "first" } ]

          result = processor.process(array, errors)

          expect(result[0][:uri]).to start_with("data:image/jpeg;base64,")
          expect(result[0][:position]).to eq("first")
        end
      end
    end
  end

  describe "content type detection" do
    it "detects JPEG from magic bytes" do
      string_io = StringIO.new("\xFF\xD8\xFF\xE0\x00\x10JFIF".dup.force_encoding("ASCII-8BIT"))
      errors = {}
      result = processor.process(string_io, errors)
      expect(result).to include("data:image/jpeg")
    end

    it "detects PNG from magic bytes" do
      string_io = StringIO.new("\x89PNG\r\n\x1A\n".dup.force_encoding("ASCII-8BIT"))
      errors = {}
      result = processor.process(string_io, errors)
      expect(result).to include("data:image/png")
    end

    it "detects WebP from magic bytes" do
      # Minimal WebP header: "RIFF" + size + "WEBP"
      string_io = StringIO.new("RIFF\x00\x00\x00\x00WEBP".dup.force_encoding("ASCII-8BIT"))
      errors = {}
      result = processor.process(string_io, errors)
      expect(result).to include("data:image/webp")
    end
  end
end
