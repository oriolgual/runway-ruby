# frozen_string_literal: true

require_relative "errors"
require_relative "validators/uploads_validator"

module RunwayML
  class Uploads
    VALID_TYPES = [ "ephemeral" ].freeze
    SUPPORTED_EXTENSIONS = {
      # Image extensions
      "jpg" => "image/jpeg",
      "jpeg" => "image/jpeg",
      "png" => "image/png",
      "webp" => "image/webp",
      # Video extensions
      "mp4" => "video/mp4",
      "mov" => "video/quicktime",
      "mkv" => "video/x-matroska",
      "webm" => "video/webm",
      "3gp" => "video/3gpp",
      "ogv" => "video/ogg",
      "avi" => "video/x-msvideo",
      "flv" => "video/x-flv",
      "mpg" => "video/mpeg",
      "mpeg" => "video/mpeg",
      # Audio extensions
      "mp3" => "audio/mpeg",
      "wav" => "audio/wav",
      "flac" => "audio/flac",
      "m4a" => "audio/mp4",
      "aac" => "audio/aac",
      "ogg" => "audio/ogg",
      "weba" => "audio/webp"
    }.freeze

    def initialize(client:)
      @client = client
    end

    def create_ephemeral(file_or_path, filename: nil)
      if file_or_path.is_a?(String)
        # It's a file path
        unless File.exist?(file_or_path)
          raise ValidationError, { file_path: "file does not exist" }
        end
        file_path = file_or_path
        filename ||= File.basename(file_path)
      elsif file_or_path.respond_to?(:read)
        # It's a File object or StringIO
        filename ||= file_or_path.respond_to?(:path) ? File.basename(file_or_path.path) : "upload"
      else
        raise ValidationError, { file: "must be a file path string or File-like object" }
      end

      errors = {}

      # Validate filename
      validator = Validators::UploadsValidator.new
      result = validator.validate(filename: filename)
      errors.merge!(result[:errors])

      raise ValidationError, errors unless errors.empty?

      # Request upload URL from API
      response = client.post("uploads", { filename: filename, type: "ephemeral" })

      response["runwayUri"]
    end

    private

    attr_reader :client
  end
end
