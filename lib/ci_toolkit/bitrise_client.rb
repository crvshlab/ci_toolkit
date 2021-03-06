# frozen_string_literal: true

require "faraday_middleware"
require "faraday"

module CiToolkit
  # client to use with the Bitrise API
  class BitriseClient
    API_VERSION = "v0.1"
    attr_reader :connection

    # noinspection Metrics/ParameterLists
    def initialize(options = {
      build_number: ENV["BITRISE_BUILD_NUMBER"],
      token: ENV["BITRISE_TOKEN"],
      app_slug: ENV["BITRISE_APP_SLUG"],
      build_slug: ENV["BITRISE_BUILD_SLUG"]
    },
                   faraday = nil)
      @build_number = options[:build_number].to_i
      @token = options[:token]
      @app_slug = options[:app_slug]
      @build_slug = options[:build_slug]
      @connection = faraday || create_connection
    end

    def create_connection
      connection = Faraday.new(
        url: "https://api.bitrise.io",
        headers: { "Content-Type" => "application/json", "Authorization" => @token }
      )
      connection.use Faraday::Request::UrlEncoded
      connection.use Faraday::Request::Retry
      connection.use FaradayMiddleware::EncodeJson
      connection.use FaradayMiddleware::ParseJson
      connection.use FaradayMiddleware::FollowRedirects

      connection
    end

    def create_pull_request_build(pull_request, branch, commit, workflow)
      @connection.post("/#{API_VERSION}/apps/#{@app_slug}/builds", {
                         hook_info: { type: "bitrise" },
                         build_params: {
                           branch: branch,
                           branch_dest: "develop",
                           pull_request_id: pull_request,
                           workflow_id: workflow,
                           commit_hash: commit
                         }
                       })
    end

    def abort_pull_request_builds(pull_request, branch, commit = nil)
      find_pull_request_builds(pull_request, branch, commit).each do |build|
        next if build["slug"] == @build_slug

        @connection.post("/#{API_VERSION}/apps/#{@app_slug}/builds/#{build["slug"]}/abort", {
                           abort_reason: "Aborting due to other build failed for pull request #{pull_request}"
                         })
      end
    end

    def find_pull_request_builds(pull_request, branch, commit = nil)
      response = @connection.get("/#{API_VERSION}/apps/#{@app_slug}/builds", {
                                   branch: branch,
                                   pull_request_id: pull_request.to_i,
                                   status: 0 # status: 0 == not finished
                                 })
      builds = response.body["data"] || []
      builds = filter_builds_by_commit(builds, commit) unless commit.nil?
      builds
    end

    def filter_builds_by_commit(builds, commit)
      builds&.select! { |build| build["commit_hash"] == commit && build["build_number"] != @build_number }
      builds || []
    end
  end
end
