# frozen_string_literal: true

require "base64"
require "stringio"

module RunwayML
  class ImageProcessor
    def self.process(prompt_image, errors)
      new.process(prompt_image, errors)
    end

    def process(prompt_image, errors)
      return prompt_image if prompt_image.nil?

      if io_like?(prompt_image)
        convert_io_to_data_uri(prompt_image, errors)
      elsif prompt_image.is_a?(String) && looks_like_file_path?(prompt_image)
        load_file_path(prompt_image, errors)
      elsif prompt_image.is_a?(Array)
        process_array_format(prompt_image, errors)
      else
        prompt_image
      end
    end

    private

    def process_array_format(prompt_image, errors)
      return prompt_image unless prompt_image.is_a?(Array)

      processed_items = prompt_image.map do |item|
        next item unless item.is_a?(Hash)

        uri = item[:uri] || item["uri"]
        next item unless uri

        converted_uri = if io_like?(uri)
          convert_io_to_data_uri(uri, errors)
        elsif uri.is_a?(String) && looks_like_file_path?(uri)
          load_file_path(uri, errors)
        else
          uri
        end

        next item unless converted_uri

        item = item.dup
        if item.key?(:uri)
          item[:uri] = converted_uri
        else
          item["uri"] = converted_uri
        end
        item
      end

      processed_items
    end

    def load_file_path(path, errors)
      file = File.open(path, "rb")
      result = convert_io_to_data_uri(file, errors)
      file.close
      result
    rescue Errno::ENOENT
      errors[:prompt_image] = "file not found: #{path}"
      nil
    rescue => e
      errors[:prompt_image] = "error reading file: #{e.message}"
      nil
    end

    def looks_like_file_path?(string)
      return false unless string.is_a?(String)

      # If it starts with a known URI scheme, it's not a file path
      return false if string.start_with?("https://", "http://", "runway://", "data:")

      # Check if it's a file that exists
      File.exist?(string)
    end

    def io_like?(object)
      object.is_a?(File) || object.is_a?(StringIO) ||
        (object.respond_to?(:read) && object.respond_to?(:rewind))
    end

    def convert_io_to_data_uri(io, errors)
      io.rewind if io.respond_to?(:rewind)
      content = io.read
      io.rewind if io.respond_to?(:rewind)

      content_type = detect_content_type(io, content)
      unless content_type
        errors[:prompt_image] = "unable to detect image type. Supported formats: JPEG, PNG, WebP"
        return nil
      end

      encoded = Base64.strict_encode64(content)
      "data:#{content_type};base64,#{encoded}"
    end

    def detect_content_type(io, content)
      # Try to detect from file path if it's a File object
      if io.is_a?(File) && io.respond_to?(:path)
        ext = File.extname(io.path).downcase
        case ext
        when ".jpg", ".jpeg"
          return "image/jpeg"
        when ".png"
          return "image/png"
        when ".webp"
          return "image/webp"
        end
      end

      # Detect from magic bytes
      return nil if content.nil? || content.empty?

      if content.start_with?("\xFF\xD8\xFF".b)
        "image/jpeg"
      elsif content.start_with?("\x89PNG\r\n\x1A\n".b)
        "image/png"
      elsif content.start_with?("RIFF".b) && content[8..11] == "WEBP".b
        "image/webp"
      end
    end
  end
end
