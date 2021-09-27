# frozen_string_literal: true

require "json"
require "pathname"

# The coverage data in resultset.json from SimpleCov contains absolute file paths
# As that can confuse the sonarcloud sonar-scanner if it's running in a Docker for example
# In the block below we are transforming the absolute file paths to relative paths
puts "Transforming coverage/.resultset.json to sonar-scanner valid format in coverage/.resultset.sonar.json"
json = JSON.parse(File.read("coverage/.resultset.json"))
puts "Fixing file paths…"
json["RSpec"]["coverage"].transform_keys! do |file|
  path = Pathname.new(file).relative_path_from(Pathname.new(File.expand_path("."))).to_s
  path.slice! ".."
  path if ENV["CI"].nil?

  "/github/workspace/#{path}"
end
puts "Fixing json line information…"
json["RSpec"]["coverage"].transform_values! do |value|
  value["lines"]
end
File.write("coverage/.resultset.sonar.json", JSON.dump(json))
puts "Wrote new coverage json to coverage/.resultset.sonar.json"
