# RunwayML Ruby SDK

Ruby client for the [RunwayML API](https://docs.dev.runwayml.com/). Generate videos from images using state-of-the-art AI models like Gen-4 Turbo and Veo 3.1.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add runway-ruby
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install runway-ruby
```

## Setup

1. Create a developer account following [Runway's guide](https://docs.dev.runwayml.com/guides/setup/)
2. Create an API key
3. Set your API key as an environment variable:

```bash
export RUNWAY_API_SECRET='your-api-key-here'
```

## Table of Contents

- [Usage](#usage)
  - [Basic Image-to-Video Generation](#basic-image-to-video-generation)
  - [Text-to-Video Generation](#text-to-video-generation)
  - [Character Performance](#character-performance)
  - [Sound Effect Generation](#sound-effect-generation)
  - [Speech-to-Speech Conversion](#speech-to-speech-conversion)
  - [Text-to-Speech Generation](#text-to-speech-generation)
  - [Voice Dubbing](#voice-dubbing)
  - [Voice Isolation](#voice-isolation)
  - [Uploading Media Files](#uploading-media-files)
  - [Organization Information](#organization-information)
  - [Task Object](#task-object)
  - [Using Local Image Files](#using-local-image-files)
  - [Using File Objects or StringIO](#using-file-objects-or-stringio)
  - [Automatic File Uploads](#automatic-file-uploads)
  - [Using Data URIs](#using-data-uris)
- [Supported Models](#supported-models)
- [Supported Image Formats](#supported-image-formats)
- [Validation](#validation)
- [Error Handling](#error-handling)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Usage

### Basic Image-to-Video Generation

Generate a video from an image URL:

```ruby
require 'runway_ml'

# Create a new image-to-video task using the "gen4_turbo" model
begin
  task = RunwayML.image_to_video(
    model: 'gen4_turbo',
    prompt_image: 'https://upload.wikimedia.org/wikipedia/commons/8/85/Tour_Eiffel_Wikimedia_Commons_(cropped).jpg',
    prompt_text: 'A timelapse on a sunny day with clouds flying by',
    ratio: '1280:720',
    duration: 5
  )

  puts "Task created with ID: #{task.id}"
  # => Task created with ID: 497f6eca-6276-4993-bfeb-53cbbbba6f08

  # Wait for the task to finish (polls the API and updates the task attributes)
  task.wait_for_output
  task.status # => "SUCCEEDED"
  task.output # => ["https://..."]
rescue RunwayML::ValidationError => e
  puts "Validation failed: #{e.message}"
rescue RunwayML::Error => e
  puts "Error: #{e.message}"
end
```

The method returns a `RunwayML::Task` object with the task ID. You can use this ID to check the status of your video generation.

### Text-to-Video Generation

Generate a video from a text prompt without requiring an image:

```ruby
# Create a new text-to-video task using the "veo3.1" model
task = RunwayML.text_to_video(
  model: 'veo3.1',
  prompt_text: 'A cute bunny hopping in a meadow',
  ratio: '1280:720',
  duration: 8
).wait_for_output

task.status # => "SUCCEEDED"
task.output # => ["https://..."]
```

The text-to-video method works similarly to image-to-video, but generates videos directly from text descriptions without requiring an input image. This is useful for creating videos from scratch based on creative prompts.

### Character Performance

Control a character's facial expressions and body movements using a reference video. Apply a performer's movements to a character image or video:

```ruby
require 'runway_ml'

# Create a character performance task using an image character
begin
  task = RunwayML.character_performance(
    model: 'act_two',
    character: {
      type: 'image',
      uri: 'https://example.com/character.jpg'
    },
    reference: {
      type: 'video',
      uri: 'https://example.com/performance.mp4'
    },
    ratio: '1280:720'
  )

  puts "Task created with ID: #{task.id}"
  # => Task created with ID: 497f6eca-6276-4993-bfeb-53cbbbba6f08

  # Wait for the task to finish
  task.wait_for_output
  task.status # => "SUCCEEDED"
  task.output # => ["https://..."]
rescue RunwayML::ValidationError => e
  puts "Validation failed: #{e.message}"
rescue RunwayML::Error => e
  puts "Error: #{e.message}"
end
```

You can also use a video as the character input instead of an image:

```ruby
task = RunwayML.character_performance(
  model: 'act_two',
  character: { type: 'video', uri: 'https://example.com/character_video.mp4' },
  reference: { type: 'video', uri: 'https://example.com/performance.mp4' },
  ratio: '1280:720',
  body_control: true,
  expression_intensity: 3,
  seed: 12345
).wait_for_output
```

**Character Performance Parameters:**

- `model` - Required. Must be `'act_two'`
- `character` - Required. An image or video of your character. Must contain a visually recognizable face
  - `type`: Either `'image'` or `'video'`
  - `uri`: HTTPS URL, Runway URI, or data URI
- `reference` - Required. A video containing the performance to apply to the character (3-30 seconds)
  - `type`: Must be `'video'`
  - `uri`: HTTPS URL, Runway URI, or data URI
- `ratio` - Required. Output resolution: `'1280:720'`, `'720:1280'`, `'960:960'`, `'1104:832'`, `'832:1104'`, or `'1584:672'`
- `body_control` - Optional. Boolean to enable body movement (default: false)
- `expression_intensity` - Optional. 1-5 scale for expression intensity (default: 3)
- `seed` - Optional. Random seed for reproducibility (0-4294967295)
- `public_figure_threshold` - Optional. Content moderation threshold: `'auto'` or `'low'`

### Sound Effect Generation

Generate sound effects from text descriptions:

```ruby
# Create a new sound effect task
task = RunwayML.sound_effect(
  model: 'eleven_text_to_sound_v2',
  prompt_text: 'A thunderstorm with heavy rain',
  duration: 10,
  loop: true
).wait_for_output

task.status # => "SUCCEEDED"
task.output # => ["https://..."]
```

**Sound Effect Parameters:**

- `model` - Required. Must be `'eleven_text_to_sound_v2'`
- `prompt_text` - Required. A text description of the sound effect (1-3000 characters)
- `duration` - Optional. The duration of the sound effect in seconds (0.5-30). If not provided, the duration will be determined automatically based on the text description
- `loop` - Optional. Whether the output sound effect should be designed to loop seamlessly (default: false)

### Speech-to-Speech Conversion

Convert speech from one voice to another in audio or video files:

```ruby
# Convert speech in an audio file to a different voice
audio_task = RunwayML.speech_to_speech(
  model: 'eleven_multilingual_sts_v2',
  media: { type: 'audio', uri: 'https://example.com/audio.mp3' },
  voice: { type: 'runway-preset', presetId: 'Maggie' }
).wait_for_output

audio_task.status # => "SUCCEEDED"
```

You can also convert speech in video files:

```ruby
# Convert speech in a video file to a different voice
video_task = RunwayML.speech_to_speech(
  model: 'eleven_multilingual_sts_v2',
  media: { type: 'video', uri: 'https://example.com/video.mp4' },
  voice: { type: 'runway-preset', presetId: 'Noah' },
  remove_background_noise: true
).wait_for_output
```

**Available Voice Presets:**

The following preset voices are available: Maya, Arjun, Serene, Bernard, Billy, Mark, Clint, Mabel, Chad, Leslie, Eleanor, Elias, Elliot, Grungle, Brodie, Sandra, Kirk, Kylie, Lara, Lisa, Malachi, Marlene, Martin, Miriam, Monster, Paula, Pip, Rusty, Ragnar, Xylar, Maggie, Jack, Katie, Noah, James, Rina, Ella, Mariah, Frank, Claudia, Niki, Vincent, Kendrick, Myrna, Tom, Wanda, Benjamin, Kiana, Rachel

**Supported Audio Formats:**

The gem supports the following audio formats for speech-to-speech conversion:

- **MP3** (`.mp3`) - MPEG-1/2 Layer 3 codec
- **WAV** (`.wav`) - PCM (uncompressed) codec
- **FLAC** (`.flac`) - FLAC (lossless) codec
- **M4A** (`.m4a`) - AAC or ALAC codec
- **AAC** (`.aac`) - AAC (raw) codec

### Text-to-Speech Generation

Generate speech from text descriptions using various voice presets:

```ruby
require 'runway_ml'

# Generate speech from text
task = RunwayML.text_to_speech(
  model: 'eleven_multilingual_v2',
  prompt_text: 'The quick brown fox jumps over the lazy dog',
  voice: {
    type: 'runway-preset',
    presetId: 'Leslie'
  }
).wait_for_output

task.status # => "SUCCEEDED"
task.output # => ["https://..."]
```

You can also generate speech with different voices:

```ruby
# Generate speech with a different voice
task = RunwayML.text_to_speech(
  model: 'eleven_multilingual_v2',
  prompt_text: 'Hello, this is a test of the text-to-speech system',
  voice: {
    type: 'runway-preset',
    presetId: 'Noah'
  }
).wait_for_output

task.status # => "SUCCEEDED"
task.output # => ["https://..."]
```

**Text-to-Speech Parameters:**

- `model` - Required. Must be `'eleven_multilingual_v2'`
- `prompt_text` - Required. A text description of the speech to generate (1-1000 characters)
- `voice` - Required. The voice preset to use for the generated speech
  - `type`: Must be `'runway-preset'`
  - `presetId`: One of the available voice IDs (see list below)

**Available Voice Presets:**

The following preset voices are available: Maya, Arjun, Serene, Bernard, Billy, Mark, Clint, Mabel, Chad, Leslie, Eleanor, Elias, Elliot, Grungle, Brodie, Sandra, Kirk, Kylie, Lara, Lisa, Malachi, Marlene, Martin, Miriam, Monster, Paula, Pip, Rusty, Ragnar, Xylar, Maggie, Jack, Katie, Noah, James, Rina, Ella, Mariah, Frank, Claudia, Niki, Vincent, Kendrick, Myrna, Tom, Wanda, Benjamin, Kiana, Rachel

### Voice Dubbing

Dub audio content to a target language while optionally preserving the original voice characteristics:

```ruby
require 'runway_ml'

# Dub audio to Spanish
task = RunwayML.voice_dubbing(
  model: 'eleven_voice_dubbing',
  audio_uri: 'https://example.com/audio.mp3',
  target_lang: 'es'
).wait_for_output

task.status # => "SUCCEEDED"
task.output # => ["https://..."]
```

You can customize the dubbing process with additional options:

```ruby
# Dub audio with custom options
task = RunwayML.voice_dubbing(
  model: 'eleven_voice_dubbing',
  audio_uri: 'https://example.com/audio.mp3',
  target_lang: 'fr',
  disable_voice_cloning: true,      # Use generic voice instead of cloning
  drop_background_audio: true,      # Remove background audio
  num_speakers: 2                   # Specify number of speakers
).wait_for_output
```

**Voice Dubbing Parameters:**

- `model` - Required. Must be `'eleven_voice_dubbing'`
- `audio_uri` - Required. HTTPS URL, Runway URI, or data URI containing the audio to dub
- `target_lang` - Required. The target language code (e.g., "es" for Spanish, "fr" for French). Supported languages: en, hi, pt, zh, es, fr, de, ja, ar, ru, ko, id, it, nl, tr, pl, sv, fil, ms, ro, uk, el, cs, da, fi, bg, hr, sk, ta
- `disable_voice_cloning` - Optional. Boolean. Set to true to use a generic voice instead of cloning the original voice
- `drop_background_audio` - Optional. Boolean. Set to true to remove background audio from the dubbed output
- `num_speakers` - Optional. Integer (0-9007199254740991). The number of speakers in the audio. If not provided, it will be detected automatically

### Voice Isolation

Isolate the voice from background audio. Audio duration must be greater than 4.6 seconds and less than 3600 seconds:

```ruby
require 'runway_ml'

# Isolate voice from audio
task = RunwayML.voice_isolation(
  model: 'eleven_voice_isolation',
  audio_uri: 'https://example.com/audio.mp3'
).wait_for_output

task.status # => "SUCCEEDED"
task.output # => ["https://..."]
```

You can also use Runway URIs or data URIs:

```ruby
# Using a Runway URI
task = RunwayML.voice_isolation(
  model: 'eleven_voice_isolation',
  audio_uri: 'runway://audio123'
).wait_for_output

# Using a data URI
require 'base64'
audio_data = File.binread('audio.mp3')
data_uri = "data:audio/mpeg;base64,#{Base64.strict_encode64(audio_data)}"

task = RunwayML.voice_isolation(
  model: 'eleven_voice_isolation',
  audio_uri: data_uri
).wait_for_output
```

**Voice Isolation Parameters:**

- `model` - Required. Must be `'eleven_voice_isolation'`
- `audio_uri` - Required. HTTPS URL, Runway URI, or data URI containing the audio. Duration must be > 4.6 seconds and < 3600 seconds

### Uploading Media Files

Upload media files to RunwayML for use in generation requests. Uploaded files are temporary and will be automatically expired after a period of time:

```ruby
require 'runway_ml'

# Upload a video file
uploads = RunwayML.uploads
runway_uri = uploads.create_ephemeral('path/to/video.mp4')

puts "Upload successful!"
puts "Runway URI: #{runway_uri}"
# => Runway URI: runway://uploads/abc123...

# Use the runway_uri in your generation requests
task = RunwayML.image_to_video(
  model: 'gen4_turbo',
  prompt_image: runway_uri,
  prompt_text: 'Add motion effects to the video',
  ratio: '1280:720',
  duration: 5
).wait_for_output
```

You can also upload with a custom filename:

```ruby
# Upload with a custom filename
runway_uri = uploads.create_ephemeral('path/to/video.mp4', filename: 'my-custom-video.mp4')
```

And upload from File objects or StringIO:

```ruby
# Upload from a File object
File.open('video.mp4', 'rb') do |file|
  runway_uri = uploads.create_ephemeral(file, filename: 'video.mp4')
end

# Upload from StringIO
require 'stringio'

video_data = StringIO.new(File.binread('video.mp4'))
runway_uri = uploads.create_ephemeral(video_data, filename: 'video.mp4')
```

**Supported file types for uploads:**

- **Images:** JPG, JPEG, PNG, WebP
- **Videos:** MP4, MOV, MKV, WebM, 3GP, OGV, AVI, FLV, MPG, MPEG
- **Audio:** MP3, WAV, FLAC, M4A, AAC, OGG, WebA

### Organization Information

Get information about your organization's usage and credit balance:

```ruby
require 'runway_ml'

# Get organization details
organization = RunwayML.organization
info = organization.retrieve

puts "Credit balance: #{info.credit_balance}"
puts "Monthly spend limit: #{info.max_monthly_credit_spend}"
puts "Tier: #{info.tier}"
```

Query usage data for your organization by model and day (up to 90 days of data):

```ruby
# Get usage data for the last 30 days
usage = organization.usage

# Access usage by model
puts usage.models # => { "gen4_turbo" => [...], "veo3.1" => [...] }

# Query specific date range
usage = organization.usage(
  start_date: '2026-01-01',
  before_date: '2026-02-08'
)

puts usage.by_model # => { ... }
puts usage.to_h     # => Returns full usage data as hash
```

**Organization Methods:**

- `retrieve()` - Returns `OrganizationInfo` with tier, credit balance, and current usage
  - `credit_balance` - Current credit balance for the organization
  - `tier` - Tier information including max monthly credit spend
  - `usage` - Current usage data broken down by models
  - `max_monthly_credit_spend()` - Maximum monthly credits available for this tier
  - `tier_models()` - Models included in this tier
  - `usage_models()` - Current usage by model

- `usage(start_date:, before_date:)` - Returns `UsageInfo` with usage breakdown
  - `start_date` - Optional. ISO-8601 date (YYYY-MM-DD) for query start. Defaults to 30 days before current date
  - `before_date` - Optional. ISO-8601 date (YYYY-MM-DD) for query end (not inclusive). Defaults to 30 days after start date
  - `models()` - Returns usage data by model
  - `by_model()` - Alias for models()
  - `to_h()` - Returns full usage data as hash

### Task Object

The API returns a `RunwayML::Task` object which provides convenient methods to manage your task:

```ruby
# Create a new task
task = RunwayML.image_to_video(...)

# Get task information
task.id        # => "497f6eca-6276-4993-bfeb-53cbbbba6f08"
task.status    # => "IN_PROGRESS" (IN_PROGRESS, QUEUED, FAILED, SUCCEEDED)

# Wait for the task to complete (polls API by default every 2 seconds)
task.wait_for_output

# Get the results
task.status      # => "SUCCEEDED"
task.output      # => ["https://..."]
task.failure_code # => "SOME_ERROR" (FAILED)
task.output       # => ["https://..."] (SUCCEEDED)

# Delete a task
task.delete     # => true/false
```

### Using Local Image Files

The gem makes it easy to work with local files - just pass a file path and it will automatically be converted to a data URI:

```ruby
require 'runway_ml'

# Simply pass the file path - the gem handles the conversion
task = RunwayML.image_to_video(
  model: 'gen4_turbo',
  prompt_image: 'path/to/your/image.jpg',  # Local file path
  prompt_text: 'A timelapse on a sunny day with clouds flying by',
  ratio: '1280:720',
  duration: 5
)
```

### Using File Objects or StringIO

You can also pass File objects or StringIO directly:

```ruby
# Using a File object
File.open('image.jpg', 'rb') do |file|
  task = RunwayML.image_to_video(
    model: 'gen4_turbo',
    prompt_image: file,
    prompt_text: 'A timelapse on a sunny day with clouds flying by',
    ratio: '1280:720',
    duration: 5
  )
end

# Using StringIO
require 'stringio'

image_data = StringIO.new(File.binread('image.jpg'))
task = RunwayML.image_to_video(
  model: 'gen4_turbo',
  prompt_image: image_data,
  prompt_text: 'A timelapse on a sunny day with clouds flying by',
  ratio: '1280:720',
  duration: 5
)
```

### Automatic File Uploads

For generation methods that accept media parameters (audio, images, or videos), the SDK automatically uploads local files, File objects, and StringIO to Runway when you pass them as parameters. This happens transparently without requiring manual upload steps:

**Supported for all media-accepting methods:**

- Voice Dubbing, Voice Isolation, Speech-to-Speech
- Image-to-Video, Text-to-Video, Character Performance
- Any method that accepts `audio_uri` or media parameters

```ruby
require 'runway_ml'

# Automatically uploads the local audio file internally
task = RunwayML.voice_dubbing(
  model: 'eleven_voice_dubbing',
  audio_uri: 'path/to/audio.mp3',  # Local file - automatically uploaded!
  target_lang: 'es'
).wait_for_output

# Works with File objects too
File.open('audio.mp3', 'rb') do |file|
  task = RunwayML.voice_isolation(
    model: 'eleven_voice_isolation',
    audio_uri: file  # Automatically uploaded!
  ).wait_for_output
end

# And with StringIO
require 'stringio'

audio_data = StringIO.new(File.binread('audio.mp3'))
task = RunwayML.speech_to_speech(
  model: 'eleven_multilingual_sts_v2',
  media: { type: 'audio', uri: audio_data },  # Automatically uploaded!
  voice: { type: 'runway-preset', presetId: 'Noah' }
).wait_for_output

# Works with any supported file type (images, videos, audio)
video_data = StringIO.new(File.binread('video.mp4'))
task = RunwayML.speech_to_speech(
  model: 'eleven_multilingual_sts_v2',
  media: { type: 'video', uri: video_data },  # Also auto-uploaded!
  voice: { type: 'runway-preset', presetId: 'Noah' }
).wait_for_output

# Image-to-Video with automatic image upload
task = RunwayML.image_to_video(
  model: 'gen4_turbo',
  prompt_image: 'path/to/image.jpg',  # Local file - automatically uploaded!
  prompt_text: 'A timelapse on a sunny day',
  ratio: '1280:720',
  duration: 5
).wait_for_output

# Image-to-Video with optional audio file
task = RunwayML.image_to_video(
  model: 'veo3.1',
  prompt_image: 'path/to/image.jpg',
  prompt_text: 'A walk through the forest',
  ratio: '16:9',
  duration: 10,
  audio: 'path/to/music.mp3'  # Also automatically uploaded!
).wait_for_output

# Text-to-Video with automatic audio upload
task = RunwayML.text_to_video(
  model: 'veo3.1',
  prompt_text: 'A cute bunny hopping in a meadow',
  ratio: '1280:720',
  duration: 8,
  audio: 'path/to/background.wav'  # Automatically uploaded!
).wait_for_output

# Character Performance with automatic media upload
task = RunwayML.character_performance(
  model: 'act_two',
  character: { type: 'image', uri: 'path/to/character.jpg' },  # Auto-uploaded!
  reference: { type: 'video', uri: 'path/to/reference.mp4' },  # Auto-uploaded!
  ratio: '1280:720'
).wait_for_output
```

**Disabling Automatic Uploads:**

If you want to disable automatic uploads and use local files as data URIs instead, pass `auto_upload: false`:

```ruby
# Convert to data URI instead of uploading
task = RunwayML.voice_dubbing(
  model: 'eleven_voice_dubbing',
  audio_uri: 'path/to/audio.mp3',
  target_lang: 'es',
  auto_upload: false  # Uses data URI instead
).wait_for_output

# Also works for image/video methods
task = RunwayML.image_to_video(
  model: 'gen4_turbo',
  prompt_image: 'path/to/image.jpg',
  prompt_text: 'A timelapse',
  ratio: '1280:720',
  duration: 5,
  auto_upload: false  # Uses data URI instead
).wait_for_output
```

Note: Automatic uploads are enabled by default for all media parameters in Voice Dubbing, Voice Isolation, Speech-to-Speech, Image-to-Video, Text-to-Video, Character Performance, and related methods.

### Using Data URIs

You can manually create base64-encoded data URIs if needed:

```ruby
require 'runway_ml'
require 'base64'

# Read and encode the image file
image_buffer = File.binread('example.png')
data_uri = "data:image/png;base64,#{Base64.strict_encode64(image_buffer)}"

# Create a new image-to-video task
task = RunwayML.image_to_video(
  model: 'gen4_turbo',
  prompt_image: data_uri,
  prompt_text: 'A timelapse on a sunny day with clouds flying by',
  ratio: '1280:720',
  duration: 5
)
```

### Supported Models

The gem supports the following AI models for video generation, character control, sound effect generation, and speech conversion:

- `gen4_turbo` - Fast generation with flexible parameters (Image-to-Video)
- `veo3.1` - High-quality with audio support and optional end frames (Image/Text-to-Video)
- `veo3.1_fast` - Faster variant of Veo 3.1 (Image/Text-to-Video)
- `gen3a_turbo` - Alternative model with different aspect ratios (Image-to-Video)
- `veo3` - Stable model with 8-second duration (Image/Text-to-Video)
- `act_two` - Character performance control (Character Performance)
- `eleven_text_to_sound_v2` - Sound effect generation from text (Sound Effects)
- `eleven_multilingual_sts_v2` - Speech-to-speech conversion (Speech-to-Speech)
- `eleven_multilingual_v2` - Text-to-speech generation (Text-to-Speech)
- `eleven_voice_dubbing` - Voice dubbing to different languages (Voice Dubbing)
- `eleven_voice_isolation` - Voice isolation from background audio (Voice Isolation)

Each model has different capabilities, supported ratios, and parameters. Refer to the [RunwayML API documentation](https://docs.dev.runwayml.com/api) for model-specific requirements.

### Supported Image Formats

The gem supports the following image formats:

- **JPEG** (`.jpg`, `.jpeg`)
- **PNG** (`.png`)
- **WebP** (`.webp`)

GIF images are not supported.

### Validation

The gem performs comprehensive client-side validation before making API calls:

```ruby
# Example with Image-to-Video
begin
  task = RunwayML.image_to_video(
    model: 'gen4_turbo',
    prompt_image: 'image.jpg',
    prompt_text: '',  # Invalid: empty text
    ratio: '999:999',  # Invalid: unsupported ratio
    duration: 100  # Invalid: out of range
  )
rescue RunwayML::ValidationError => e
  puts e.message
  # => Validation failed:
  #      - prompt_text: cannot be empty
  #      - ratio: must be one of: 1280:720, 720:1280, 1104:832, 832:1104, 960:960, 1584:672
  #      - duration: must be between 2 and 10 seconds

  # Access individual errors
  puts e.errors
  # => { prompt_text: "cannot be empty", ratio: "must be one of: ...", ... }
end

# Example with Character Performance
begin
  task = RunwayML.character_performance(
    model: 'act_two',
    character: { type: 'invalid', uri: 'image.jpg' },  # Invalid type
    reference: { type: 'video', uri: 'https://example.com/performance.mp4' },
    ratio: '999:999'  # Invalid: unsupported ratio
  )
rescue RunwayML::ValidationError => e
  puts e.errors
  # => { character: "...", ratio: "must be one of: ..." }
end
```

### Error Handling

The gem provides several error classes for handling different failure scenarios. All errors inherit from `RunwayML::Error`:

```ruby
begin
  task = RunwayML.image_to_video(
    model: 'gen4_turbo',
    prompt_image: 'image.jpg',
    prompt_text: 'A beautiful scene',
    ratio: '1280:720',
    duration: 5
  )
rescue RunwayML::Error => e
  puts "Error: #{e.message}"
end
```

**Available Error Classes:**

- `RunwayML::ValidationError` - Client-side parameter validation failed
- `RunwayML::BadRequestError` - API validation errors (includes formatted validation issues)
- `RunwayML::AuthenticationError` - Invalid or missing API key
- `RunwayML::RateLimitError` - Too many requests (includes `retry_after`)
- `RunwayML::SSLError` - SSL certificate verification failed
- `RunwayML::APIConnectionError` - Network connectivity issues
- `RunwayML::APIError` - Other API errors

The gem performs client-side validation before making API calls (raises `ValidationError`), but the API may also perform additional server-side validation (raises `BadRequestError` with detailed error information).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/oriolgual/runway-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
