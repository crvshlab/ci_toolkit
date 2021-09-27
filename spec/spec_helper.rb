# frozen_string_literal: true

require "simplecov"
require "simplecov-json"

SimpleCov.start do
  add_filter "spec"

  formatter SimpleCov::Formatter::JSONFormatter

  track_files "**/*.rb"
end
