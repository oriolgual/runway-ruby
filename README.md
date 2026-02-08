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
require 'runway_ml'

# Create a new text-to-video task using the "veo3.1" model
begin
  task = RunwayML.text_to_video(
    model: 'veo3.1',
    prompt_text: 'A cute bunny hopping in a meadow',
    ratio: '1280:720',
    duration: 8
  )

  puts "Task created with ID: #{task.id}"
  # => Task created with ID: 497f6eca-6276-4993-bfeb-53cbbbba6f08
rescue RunwayML::ValidationError => e
  puts "Validation failed: #{e.message}"
rescue RunwayML::Error => e
  puts "Error: #{e.message}"
end
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
  character: {
    type: 'video',
    uri: 'https://example.com/character_video.mp4'
  },
  reference: {
    type: 'video',
    uri: 'https://example.com/performance.mp4'
  },
  ratio: '1280:720',
  body_control: true,  # Enable body movement in addition to facial expressions
  expression_intensity: 3,  # 1-5 scale for expression intensity
  seed: 12345
)
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
require 'runway_ml'

# Create a new sound effect task
begin
  task = RunwayML.sound_effect(
    model: 'eleven_text_to_sound_v2',
    prompt_text: 'A thunderstorm with heavy rain',
    duration: 10,
    loop: true
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

**Sound Effect Parameters:**

- `model` - Required. Must be `'eleven_text_to_sound_v2'`
- `prompt_text` - Required. A text description of the sound effect (1-3000 characters)
- `duration` - Optional. The duration of the sound effect in seconds (0.5-30). If not provided, the duration will be determined automatically based on the text description
- `loop` - Optional. Whether the output sound effect should be designed to loop seamlessly (default: false)

### Task Object

The `RunwayML::Task` object represents a video generation task:

```ruby
task = RunwayML.image_to_video(...)

# Access the task ID
task.id  # => "497f6eca-6276-4993-bfeb-53cbbbba6f08"

# Convert to hash
task.to_h  # => { id: "497f6eca-6276-4993-bfeb-53cbbbba6f08" }

# String representation
task.to_s  # => "#<RunwayML::Task id=497f6eca-6276-4993-bfeb-53cbbbba6f08>"

# Fetch task details
task.retrieve
task.status     # => "PENDING"
task.created_at # => "2024-06-27T19:49:32.334Z"

# Wait for task completion (updates task attributes)
task.wait_for_output
task.status # => "SUCCEEDED"
task.output # => ["https://..."]

# Status-specific fields
task.progress     # => 0.42 (RUNNING)
task.failure      # => "Something went wrong" (FAILED)
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

The gem supports the following AI models for video generation, character control, and sound effect generation:

- `gen4_turbo` - Fast generation with flexible parameters (Image-to-Video)
- `veo3.1` - High-quality with audio support and optional end frames (Image/Text-to-Video)
- `veo3.1_fast` - Faster variant of Veo 3.1 (Image/Text-to-Video)
- `gen3a_turbo` - Alternative model with different aspect ratios (Image-to-Video)
- `veo3` - Stable model with 8-second duration (Image/Text-to-Video)
- `act_two` - Character performance control (Character Performance)
- `eleven_text_to_sound_v2` - Sound effect generation from text (Sound Effects)

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
