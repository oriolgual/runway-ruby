# frozen_string_literal: true

namespace :spec do
  desc "Analyze SDK spec coverage against OpenAPI"
  task :coverage do
    require File.expand_path("../../runway_ml", __FILE__)
    require File.expand_path("../../runway_ml/openapi_spec_loader", __FILE__)
    require File.expand_path("../../runway_ml/spec_coverage_analyzer", __FILE__)

    puts "\nLoading OpenAPI specification..."
    RunwayML::SpecCoverageAnalyzer.print_coverage_report
  end

  desc "Validate SDK against OpenAPI contract"
  task :validate do
    require File.expand_path("../../runway_ml", __FILE__)
    require File.expand_path("../../runway_ml/openapi_spec_loader", __FILE__)
    require File.expand_path("../../runway_ml/contract_validator", __FILE__)
    require File.expand_path("../../runway_ml/validator_builder", __FILE__)

    puts "\nRunning OpenAPI contract validation..."
    puts "This ensures all SDK methods match the OpenAPI spec.\n"

    # Run RSpec on the contract tests
    system("rspec spec/runway_ml/openapi_contract_spec.rb -f progress")
  end
end

desc "Run OpenAPI contract tests"
task "openapi:contract": "spec:validate"

desc "Check SDK spec coverage"
task "openapi:coverage": "spec:coverage"
