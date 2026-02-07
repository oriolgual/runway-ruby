# frozen_string_literal: true

module RunwayML
  class Error < StandardError
  end

  class APIError < Error
    attr_reader :status, :headers, :error

    def initialize(status, error, message, headers)
      @status = status
      @headers = headers
      @error = error
      super(make_message(status, error, message))
    end

    def self.generate(status, error_response, message, headers)
      return APIConnectionError.new(message: message) unless status && headers

      case status
      when 400
        BadRequestError.new(status, error_response, message, headers)
      when 401
        AuthenticationError.new(status, error_response, message, headers)
      when 403
        PermissionDeniedError.new(status, error_response, message, headers)
      when 404
        NotFoundError.new(status, error_response, message, headers)
      when 409
        ConflictError.new(status, error_response, message, headers)
      when 422
        UnprocessableEntityError.new(status, error_response, message, headers)
      when 429
        RateLimitError.new(status, error_response, message, headers)
      when 500..599
        InternalServerError.new(status, error_response, message, headers)
      else
        new(status, error_response, message, headers)
      end
    end

    private

    def make_message(status, error, message)
      msg = if error.is_a?(Hash) && error["message"]
              error["message"]
      elsif error
              error.to_s
      else
              message
      end

      if status && msg
        "#{status} #{msg}"
      elsif status
        "#{status} status code (no body)"
      elsif msg
        msg
      else
        "(no status code or body)"
      end
    end
  end

  class APIConnectionError < APIError
    def initialize(message: nil, cause: nil)
      @cause = cause
      super(nil, nil, message || "Connection error.", nil)
    end

    attr_reader :cause
  end

  class APIConnectionTimeoutError < APIConnectionError
    def initialize(message: nil)
      super(message: message || "Request timed out.")
    end
  end

  class SSLError < APIConnectionError
    def initialize(message: nil, cause: nil)
      ssl_message = "SSL verification failed: #{message}. " \
                    "This may be due to outdated SSL certificates on your system. " \
                    "Try updating your system's SSL certificates or OpenSSL installation."
      super(message: ssl_message, cause: cause)
    end
  end

  class BadRequestError < APIError
    def initialize(status, error, message, headers)
      @validation_issues = extract_validation_issues(error) if error.is_a?(Hash)
      super
    end

    attr_reader :validation_issues

    private

    def extract_validation_issues(error)
      return [] unless error["issues"].is_a?(Array)

      error["issues"].map do |issue|
        {
          path: issue["path"]&.join(".") || "unknown",
          message: issue["message"] || "Invalid value",
          code: issue["code"]
        }
      end
    end

    def make_message(status, error, message)
      return super unless @validation_issues&.any?

      base = "400 Bad Request - Validation failed:\n"
      issues_msg = @validation_issues.map do |issue|
        "  - #{issue[:path]}: #{issue[:message]}"
      end.join("\n")

      base + issues_msg
    end
  end

  class AuthenticationError < APIError
  end

  class PermissionDeniedError < APIError
  end

  class NotFoundError < APIError
  end

  class ConflictError < APIError
  end

  class UnprocessableEntityError < APIError
  end

  class RateLimitError < APIError
    def retry_after
      headers&.[]("retry-after")&.to_i || headers&.[]("x-ratelimit-reset")&.to_i
    end
  end

  class InternalServerError < APIError
  end

  class ValidationError < Error
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super(format_message)
    end

    private

    def format_message
      "Validation failed:\n" + errors.map { |field, message| "  - #{field}: #{message}" }.join("\n")
    end
  end
end
