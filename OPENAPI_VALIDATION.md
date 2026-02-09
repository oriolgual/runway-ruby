# OpenAPI Contract Validation

This document describes how to validate the RunwayML Ruby SDK against the OpenAPI specification.

## Quick Start

### Check Spec Compliance

```bash
bundle exec rake spec:coverage
```

Shows which endpoints are defined in the spec and which SDK methods implement them.

### Run Contract Tests

```bash
bundle exec rake spec:validate
```

Validates that SDK requests and responses conform to the OpenAPI spec.

## Tools

### OpenAPI Spec Loader

Fetches and caches the official OpenAPI spec from GitHub.

```ruby
# Load the spec
spec = RunwayML::OpenAPISpecLoader.load_spec

# Force reload
spec = RunwayML::OpenAPISpecLoader.load_spec(force_reload: true)

# Get endpoint schemas
schema = RunwayML::OpenAPISpecLoader.get_request_schema("POST", "/v1/text_to_video")
schema = RunwayML::OpenAPISpecLoader.get_response_schema("POST", "/v1/text_to_video")
```

### Contract Validator

Validates requests and responses against OpenAPI schemas.

```ruby
validator = RunwayML::ContractValidator.new

result = validator.validate_request("POST", "/v1/text_to_video", {
  "promptText" => "A beautiful sunset",
  "ratio" => "1280:720",
  "duration" => 8,
  "model" => "veo3.1"
})

puts result[:valid] ? "Valid" : "Invalid: #{result[:errors].join(', ')}"
```

### Spec Coverage Analyzer

Analyzes SDK completeness.

```ruby
# Print human-readable report
RunwayML::SpecCoverageAnalyzer.print_coverage_report
```

## Critical Endpoints Monitored

| Endpoint                       | SDK Class            | Method   |
| ------------------------------ | -------------------- | -------- |
| POST /v1/text_to_video         | TextToVideo          | create   |
| POST /v1/image_to_video        | ImageToVideo         | create   |
| POST /v1/text_to_speech        | TextToSpeech         | create   |
| POST /v1/speech_to_speech      | SpeechToSpeech       | create   |
| POST /v1/sound_effect          | SoundEffect          | create   |
| POST /v1/voice_isolation       | VoiceIsolation       | create   |
| POST /v1/voice_dubbing         | VoiceDubbing         | create   |
| POST /v1/character_performance | CharacterPerformance | create   |
| POST /v1/video_to_video        | VideoToVideo         | create   |
| POST /v1/text_to_image         | TextToImage          | create   |
| GET /v1/tasks/{id}             | Task                 | retrieve |
| DELETE /v1/tasks/{id}          | Task                 | delete   |
| GET /v1/organization           | Organization         | retrieve |
| POST /v1/uploads               | Uploads              | create   |

## Automatic Drift Detection

Three GitHub Actions workflows automatically monitor spec compliance:

- **spec-compliance.yml** - Daily check that SDK remains 100% compliant
- **spec-validation.yml** - Validates contracts on every PR
- **spec-update-alert.yml** - Weekly alert when upstream spec changes

See `.github/workflows/` for details.

## References

- [RunwayML API Docs](https://docs.dev.runwayml.com)
- [OpenAPI Specification](https://spec.openapis.org/oas/v3.1.0)
- [RunwayML OpenAPI Spec](https://github.com/runwayml/openapi)
