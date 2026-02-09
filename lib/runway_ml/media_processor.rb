# frozen_string_literal: true

require "base64"
require "stringio"

module RunwayML
  class MediaProcessor
    # Processes media files, optionally uploading them to Runway
    # If auto_upload is true (default), local files/StringIO are uploaded and converted to runway URIs
    # If auto_upload is false, converts them to data URIs instead
    def self.process(media, errors, client: nil, auto_upload: true)
      new(client: client).process(media, errors, auto_upload: auto_upload)
    end

    def initialize(client: nil)
      @client = client
    end

    def process(media, errors, auto_upload: true)
      return media if media.nil?

      if auto_upload && @client
        process_with_upload(media, errors)
      else
        process_without_upload(media, errors)
      end
    end

    private

    attr_reader :client

    # ======================
    # WITH UPLOAD PROCESSING
    # ======================

    def process_with_upload(media, errors)
      case media
      when Array
        process_array_with_upload(media, errors)
      when Hash
        process_hash_with_upload(media, errors)
      when String, File, StringIO
        convert_to_runway_uri(media, errors)
      else
        media
      end
    end

    def process_array_with_upload(items, errors)
      items.map do |item|
        case item
        when Hash
          process_hash_with_upload(item, errors)
        when String, File, StringIO
          convert_to_runway_uri(item, errors) || item
        else
          item
        end
      end
    end

    def process_hash_with_upload(item, errors)
      return item unless item.is_a?(Hash)

      item = item.dup
      uri = item[:uri] || item["uri"]

      return item unless uri.is_a?(String) || uri.respond_to?(:read) || (uri.is_a?(String) && looks_like_file_path?(uri))

      converted_uri = convert_to_runway_uri(uri, errors)
      return item unless converted_uri

      if item.key?(:uri)
        item[:uri] = converted_uri
      else
        item["uri"] = converted_uri
      end

      item
    end

    def convert_to_runway_uri(media, errors)
      return media if media.nil?

      # If it's already a URI, return as-is
      if media.is_a?(String) && (media.start_with?("https://", "http://", "runway://", "data:"))
        return media
      end

      # Check if it's a file path
      if media.is_a?(String) && looks_like_file_path?(media)
        upload_file(media, errors)
      # Check if it's a file-like object
      elsif media.respond_to?(:read)
        upload_io(media, errors)
      else
        media
      end
    end

    def upload_file(path, errors)
      return nil if client.nil?

      begin
        uploads = Uploads.new(client: client)
        uploads.create_ephemeral(path)
      rescue ValidationError => e
        errors[:media] = "Failed to upload file: #{e.message}"
        nil
      rescue => e
        errors[:media] = "Error uploading file: #{e.message}"
        nil
      end
    end

    def upload_io(io, errors)
      return nil if client.nil?

      begin
        # Determine a good filename
        filename = if io.respond_to?(:path)
          File.basename(io.path)
        else
          # For StringIO without a path, infer the extension from content type
          content_type = infer_content_type_for_io(io)
          ext = infer_extension_for_content_type(content_type)
          "upload#{ext}"
        end

        uploads = Uploads.new(client: client)
        uploads.create_ephemeral(io, filename: filename)
      rescue ValidationError => e
        errors[:media] = "Failed to upload file: #{e.message}"
        nil
      rescue => e
        errors[:media] = "Error uploading file: #{e.message}"
        nil
      end
    end

    def infer_content_type_for_io(io)
      io.rewind if io.respond_to?(:rewind)
      content = io.read
      io.rewind if io.respond_to?(:rewind)

      detect_from_magic_bytes(content) || "application/octet-stream"
    end

    def infer_extension_for_content_type(content_type)
      {
        "image/jpeg" => ".jpg",
        "image/png" => ".png",
        "image/webp" => ".webp",
        "audio/mpeg" => ".mp3",
        "audio/wav" => ".wav",
        "audio/flac" => ".flac",
        "audio/mp4" => ".m4a",
        "audio/aac" => ".aac",
        "audio/ogg" => ".ogg",
        "audio/webp" => ".weba",
        "video/mp4" => ".mp4",
        "video/quicktime" => ".mov",
        "video/x-matroska" => ".mkv",
        "video/webm" => ".webm",
        "video/3gpp" => ".3gp",
        "video/ogg" => ".ogv",
        "video/x-msvideo" => ".avi",
        "video/x-flv" => ".flv",
        "video/mpeg" => ".mpg"
      }[content_type] || ".mp3"  # Default to mp3 for unknown audio
    end

    # ========================
    # WITHOUT UPLOAD PROCESSING
    # ========================

    def process_without_upload(media, errors)
      case media
      when Array
        process_array_without_upload(media, errors)
      when Hash
        process_hash_without_upload(media, errors)
      when String, File, StringIO
        convert_to_data_uri(media, errors)
      else
        media
      end
    end

    def process_array_without_upload(items, errors)
      items.map do |item|
        case item
        when Hash
          process_hash_without_upload(item, errors)
        when String, File, StringIO
          convert_to_data_uri(item, errors) || item
        else
          item
        end
      end
    end

    def process_hash_without_upload(item, errors)
      return item unless item.is_a?(Hash)

      item = item.dup
      uri = item[:uri] || item["uri"]

      return item unless uri.is_a?(String) || uri.respond_to?(:read) || (uri.is_a?(String) && looks_like_file_path?(uri))

      converted_uri = convert_to_data_uri(uri, errors)
      return item unless converted_uri

      if item.key?(:uri)
        item[:uri] = converted_uri
      else
        item["uri"] = converted_uri
      end

      item
    end

    def convert_to_data_uri(media, errors)
      # If it's already a URI, return as-is
      if media.is_a?(String) && (media.start_with?("https://", "http://", "runway://", "data:"))
        return media
      end

      # Check if it's a file path
      if media.is_a?(String) && looks_like_file_path?(media)
        load_file_to_data_uri(media, errors)
      # Check if it's a file-like object
      elsif media.respond_to?(:read)
        convert_io_to_data_uri(media, errors)
      else
        media
      end
    end

    def load_file_to_data_uri(path, errors)
      file = File.open(path, "rb")
      result = convert_io_to_data_uri(file, errors)
      file.close
      result
    rescue Errno::ENOENT
      errors[:media] = "file not found: #{path}"
      nil
    rescue => e
      errors[:media] = "error reading file: #{e.message}"
      nil
    end

    def convert_io_to_data_uri(io, errors)
      io.rewind if io.respond_to?(:rewind)
      content = io.read
      io.rewind if io.respond_to?(:rewind)

      content_type = detect_content_type(io, content)
      unless content_type
        errors[:media] = "unable to detect media type"
        return nil
      end

      encoded = Base64.strict_encode64(content)
      "data:#{content_type};base64,#{encoded}"
    end

    # =======================
    # CONTENT TYPE DETECTION
    # =======================

    def detect_content_type(io, content)
      # Try to detect from file path if it's a File object
      if io.is_a?(File) && io.respond_to?(:path)
        ext = File.extname(io.path).downcase
        mime_type = mime_type_for_extension(ext)
        return mime_type if mime_type
      end

      # Detect from magic bytes
      detect_from_magic_bytes(content)
    end

    def detect_from_magic_bytes(content)
      return nil if content.nil? || content.empty?

      if content.start_with?("\xFF\xD8\xFF".b)
        "image/jpeg"
      elsif content.start_with?("\x89PNG\r\n\x1A\n".b)
        "image/png"
      elsif content.start_with?("RIFF".b) && content[8..11] == "WEBP".b
        "image/webp"
      elsif content.start_with?("\xFF\xFB".b) || content.start_with?("\xFF\xFA".b)
        "audio/mpeg"
      elsif content.start_with?("RIFF".b) && content[8..11] == "WAVE".b
        "audio/wav"
      elsif content.start_with?("ftyp".b)
        "video/mp4"
      end
    end

    def mime_type_for_extension(ext)
      {
        ".jpg" => "image/jpeg",
        ".jpeg" => "image/jpeg",
        ".png" => "image/png",
        ".webp" => "image/webp",
        ".mp3" => "audio/mpeg",
        ".wav" => "audio/wav",
        ".flac" => "audio/flac",
        ".m4a" => "audio/mp4",
        ".aac" => "audio/aac",
        ".ogg" => "audio/ogg",
        ".weba" => "audio/webp",
        ".mp4" => "video/mp4",
        ".mov" => "video/quicktime",
        ".mkv" => "video/x-matroska",
        ".webm" => "video/webm",
        ".3gp" => "video/3gpp",
        ".ogv" => "video/ogg",
        ".avi" => "video/x-msvideo",
        ".flv" => "video/x-flv",
        ".mpg" => "video/mpeg",
        ".mpeg" => "video/mpeg"
      }[ext]
    end

    # ============
    # HELPERS
    # ============

    def looks_like_file_path?(string)
      return false unless string.is_a?(String)

      # If it starts with a known URI scheme, it's not a file path
      return false if string.start_with?("https://", "http://", "runway://", "data:")

      # Check if it's a file that exists
      File.exist?(string)
    end
  end
end
