# frozen_string_literal: true

require "spec_helper"
require "stringio"
require "tempfile"

RSpec.describe RunwayML::Uploads do
  let(:client) { RunwayML.test_client }
  let(:uploads) { described_class.new(client: client) }

  describe "#create_ephemeral" do
    context "with valid file path" do
      it "validates filename and returns runway URI" do
        temp_file = Tempfile.new([ "test", ".mp4" ])
        temp_file.write("fake video data")
        temp_file.close

        expected_post_params = {
          filename: File.basename(temp_file.path),
          type: "ephemeral"
        }

        expected_runway_uri = "runway://uploads/12345"

        client.inject_response(
          :post,
          "uploads",
          params: expected_post_params,
          response: {
            "uploadUrl" => "https://example.com/upload",
            "fields" => { "key" => "value" },
            "runwayUri" => expected_runway_uri
          }
        )

        result = uploads.create_ephemeral(temp_file.path)

        expect(result).to eq(expected_runway_uri)
        expect(client).to have_been_called_with(method: :post, path: "uploads", params: expected_post_params)

        temp_file.unlink
      end

      it "uses provided filename instead of file path" do
        temp_file = Tempfile.new([ "test", ".mp4" ])
        temp_file.write("fake video data")
        temp_file.close

        expected_post_params = {
          filename: "custom-name.mp4",
          type: "ephemeral"
        }

        client.inject_response(
          :post,
          "uploads",
          params: expected_post_params,
          response: {
            "uploadUrl" => "https://example.com/upload",
            "fields" => {},
            "runwayUri" => "runway://uploads/12345"
          }
        )

        uploads.create_ephemeral(temp_file.path, filename: "custom-name.mp4")

        expect(client).to have_been_called_with(method: :post, path: "uploads", params: expected_post_params)

        temp_file.unlink
      end
    end

    context "with File object" do
      it "validates and uploads from File object" do
        temp_file = Tempfile.new([ "test", ".mp3" ])
        temp_file.write("fake audio data")
        temp_file.close

        expected_post_params = {
          filename: File.basename(temp_file.path),
          type: "ephemeral"
        }

        client.inject_response(
          :post,
          "uploads",
          params: expected_post_params,
          response: {
            "uploadUrl" => "https://example.com/upload",
            "fields" => {},
            "runwayUri" => "runway://uploads/audio123"
          }
        )

        File.open(temp_file.path, "rb") do |file|
          result = uploads.create_ephemeral(file)
          expect(result).to eq("runway://uploads/audio123")
        end

        temp_file.unlink
      end
    end

    context "with StringIO object" do
      it "validates and uploads from StringIO" do
        io = StringIO.new("fake image data")

        expected_post_params = {
          filename: "upload.png",
          type: "ephemeral"
        }

        client.inject_response(
          :post,
          "uploads",
          params: expected_post_params,
          response: {
            "uploadUrl" => "https://example.com/upload",
            "fields" => {},
            "runwayUri" => "runway://uploads/image123"
          }
        )

        result = uploads.create_ephemeral(io, filename: "upload.png")
        expect(result).to eq("runway://uploads/image123")
      end
    end

    context "with supported file extensions" do
      %w[mp4 mov webm mp3 wav png jpg jpeg flac].each do |ext|
        it "accepts #{ext} extension" do
          temp_file = Tempfile.new([ "test", ".#{ext}" ])
          temp_file.write("fake data")
          temp_file.close

          client.inject_response(
            :post,
            "uploads",
            params: { filename: File.basename(temp_file.path), type: "ephemeral" },
            response: {
              "uploadUrl" => "https://example.com/upload",
              "fields" => {},
              "runwayUri" => "runway://uploads/#{ext}"
            }
          )

          result = uploads.create_ephemeral(temp_file.path)
          expect(result).to match(/runway:\/\//)

          temp_file.unlink
        end
      end
    end

    context "with invalid file path" do
      it "raises validation error for non-existent file" do
        expect {
          uploads.create_ephemeral("/non/existent/file.mp4")
        }.to raise_error(RunwayML::ValidationError, /file does not exist/)
      end
    end

    context "with invalid filename" do
      it "raises validation error for empty filename" do
        io = StringIO.new("data")
        expect {
          uploads.create_ephemeral(io, filename: "")
        }.to raise_error(RunwayML::ValidationError)
      end

      it "raises validation error for filename too short" do
        io = StringIO.new("data")
        expect {
          uploads.create_ephemeral(io, filename: "x.m")
        }.to raise_error(RunwayML::ValidationError)
      end

      it "raises validation error for filename too long" do
        io = StringIO.new("data")
        long_name = "a" * 256 + ".mp4"
        expect {
          uploads.create_ephemeral(io, filename: long_name)
        }.to raise_error(RunwayML::ValidationError)
      end

      it "raises validation error for unsupported extension" do
        io = StringIO.new("data")
        expect {
          uploads.create_ephemeral(io, filename: "file.xyz")
        }.to raise_error(RunwayML::ValidationError)
      end
    end

    context "with invalid input type" do
      it "raises validation error for unsupported type" do
        expect {
          uploads.create_ephemeral(12345)
        }.to raise_error(RunwayML::ValidationError)
      end
    end
  end
end
