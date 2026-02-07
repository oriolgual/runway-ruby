# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunwayML::BadRequestError do
  describe "validation error parsing" do
    it "formats validation errors nicely" do
      error_response = {
        "error" => "Validation of body failed",
        "issues" => [
          {
            "code" => "invalid_type",
            "path" => [ "promptImage" ],
            "message" => "Invalid input: expected string, received undefined"
          },
          {
            "code" => "invalid_value",
            "path" => [ "ratio" ],
            "message" => "Invalid option: expected one of \"1280:720\"|\"720:1280\""
          }
        ]
      }

      error = described_class.new(400, error_response, "Bad Request", {})

      expect(error.message).to include("400 Bad Request - Validation failed:")
      expect(error.message).to include("promptImage: Invalid input: expected string, received undefined")
      expect(error.message).to include("ratio: Invalid option: expected one of")
      expect(error.validation_issues).to be_an(Array)
      expect(error.validation_issues.size).to eq(2)
    end

    it "handles errors without issues" do
      error_response = {
        "error" => "Some other error"
      }

      error = described_class.new(400, error_response, "Bad Request", {})

      expect(error.message).to include("400")
      expect(error.validation_issues).to eq([])
    end

    it "handles nil error response" do
      error = described_class.new(400, nil, "Bad Request", {})

      expect(error.message).to include("400")
    end
  end
end
