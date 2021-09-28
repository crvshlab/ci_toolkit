# frozen_string_literal: true

require "simplecov"
require "simplecov-json"

SimpleCov.start do
  add_filter "spec"
  add_filter "transform_coverage_data.rb"
  add_filter "lib/ci_toolkit/version.rb"

  formatter SimpleCov::Formatter::JSONFormatter

  track_files "**/*.rb"
end
