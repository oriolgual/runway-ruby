# frozen_string_literal: true

require "spec_helper"
require "stringio"
require "tempfile"

RSpec.describe RunwayML::MediaProcessor do
  let(:client) { RunwayML.test_client }

  describe ".process" do
    context "with auto_upload enabled" do
      it "uploads file paths and returns runway URI" do
        temp_file = Tempfile.new([ "test", ".mp3" ])
        temp_file.write("fake audio data")
        temp_file.close

        errors = {}

        # Mock the uploads API call
        client.inject_response(
          :post,
          "uploads",
          params: { filename: File.basename(temp_file.path), type: "ephemeral" },
          response: {
            "uploadUrl" => "https://example.com/upload",
            "fields" => {},
            "runwayUri" => "runway://uploads/audio123"
          }
        )

        result = RunwayML::MediaProcessor.process(
          temp_file.path,
          errors,
          client: client,
          auto_upload: true
        )

        expect(result).to eq("runway://uploads/audio123")
        expect(errors).to be_empty

        temp_file.unlink
      end

      it "uploads File objects and returns runway URI" do
        temp_file = Tempfile.new([ "test", ".mp4" ])
        temp_file.write("fake video data")
        temp_file.close

        errors = {}

        client.inject_response(
          :post,
          "uploads",
          params: { filename: File.basename(temp_file.path), type: "ephemeral" },
          response: {
            "uploadUrl" => "https://example.com/upload",
            "fields" => {},
            "runwayUri" => "runway://uploads/video123"
          }
        )

        File.open(temp_file.path, "rb") do |file|
          result = RunwayML::MediaProcessor.process(
            file,
            errors,
            client: client,
            auto_upload: true
          )

          expect(result).to eq("runway://uploads/video123")
          expect(errors).to be_empty
        end

        temp_file.unlink
      end

      it "uploads StringIO and returns runway URI" do
        io = StringIO.new("fake audio data")
        errors = {}

        client.inject_response(
          :post,
          "uploads",
          params: { filename: "upload.mp3", type: "ephemeral" },
          response: {
            "uploadUrl" => "https://example.com/upload",
            "fields" => {},
            "runwayUri" => "runway://uploads/stringio123"
          }
        )

        result = RunwayML::MediaProcessor.process(
          io,
          errors,
          client: client,
          auto_upload: true
        )

        expect(result).to eq("runway://uploads/stringio123")
        expect(errors).to be_empty
      end

      it "does not upload existing runway URIs" do
        errors = {}

        result = RunwayML::MediaProcessor.process(
          "runway://existing/uri",
          errors,
          client: client,
          auto_upload: true
        )

        expect(result).to eq("runway://existing/uri")
      end

      it "does not upload HTTPS URLs" do
        errors = {}

        result = RunwayML::MediaProcessor.process(
          "https://example.com/audio.mp3",
          errors,
          client: client,
          auto_upload: true
        )

        expect(result).to eq("https://example.com/audio.mp3")
      end

      it "processes array of items with auto-upload" do
        temp_file = Tempfile.new([ "test", ".mp3" ])
        temp_file.write("fake audio")
        temp_file.close

        errors = {}

        client.inject_response(
          :post,
          "uploads",
          params: { filename: File.basename(temp_file.path), type: "ephemeral" },
          response: {
            "uploadUrl" => "https://example.com/upload",
            "fields" => {},
            "runwayUri" => "runway://uploads/audio123"
          }
        )

        items = [
          temp_file.path,
          "https://example.com/existing.mp3"
        ]

        result = RunwayML::MediaProcessor.process(
          items,
          errors,
          client: client,
          auto_upload: true
        )

        expect(result[0]).to eq("runway://uploads/audio123")
        expect(result[1]).to eq("https://example.com/existing.mp3")

        temp_file.unlink
      end

      it "processes hash with media URI auto-upload" do
        temp_file = Tempfile.new([ "test", ".mp4" ])
        temp_file.write("fake video")
        temp_file.close

        errors = {}

        client.inject_response(
          :post,
          "uploads",
          params: { filename: File.basename(temp_file.path), type: "ephemeral" },
          response: {
            "uploadUrl" => "https://example.com/upload",
            "fields" => {},
            "runwayUri" => "runway://uploads/video123"
          }
        )

        media_hash = { uri: temp_file.path }

        result = RunwayML::MediaProcessor.process(
          media_hash,
          errors,
          client: client,
          auto_upload: true
        )

        expect(result[:uri]).to eq("runway://uploads/video123")

        temp_file.unlink
      end
    end

    context "with auto_upload disabled" do
      it "converts file to data URI instead of uploading" do
        temp_file = Tempfile.new([ "test", ".mp3" ])
        temp_file.write("fake audio data")
        temp_file.close

        errors = {}

        result = RunwayML::MediaProcessor.process(
          temp_file.path,
          errors,
          client: client,
          auto_upload: false
        )

        # Should return a data URI
        expect(result).to start_with("data:")

        temp_file.unlink
      end

      it "returns existing URIs as-is" do
        errors = {}

        result = RunwayML::MediaProcessor.process(
          "runway://existing/uri",
          errors,
          client: client,
          auto_upload: false
        )

        expect(result).to eq("runway://existing/uri")
      end
    end

    context "with no client" do
      it "falls back to data URI conversion when auto_upload is true but no client" do
        temp_file = Tempfile.new([ "test", ".mp3" ])
        temp_file.write("fake audio data")
        temp_file.close

        errors = {}

        result = RunwayML::MediaProcessor.process(
          temp_file.path,
          errors,
          client: nil,
          auto_upload: true
        )

        # Should fall back to data URI
        expect(result).to start_with("data:")

        temp_file.unlink
      end
    end

    context "with nil input" do
      it "returns nil" do
        errors = {}

        result = RunwayML::MediaProcessor.process(
          nil,
          errors,
          client: client,
          auto_upload: true
        )

        expect(result).to be_nil
      end
    end
  end
end
