# frozen_string_literal: true

require "faraday_middleware"
require "faraday"

module CiToolkit
  # client to use with the Bitrise API
  class BitriseClient
    HOST = "https://api.bitrise.io"
    API_VERSION = "v0.1"
    attr_reader :connection

    def initialize(token, app_slug, faraday = Faraday.new)
      @token = token
      @app_slug = app_slug
      @connection = faraday
      configure_connection
    end

    def configure_connection
      return unless @connection.nil?

      @connection = Faraday.new(
        url: base_url,
        headers: { "Content-Type" => "application/json", "Authorization" => @token }
      )
      @connection.use Faraday::Request::UrlEncoded
      @connection.use Faraday::Request::Retry
      @connection.use FaradayMiddleware::ParseJson
      @connection.use FaradayMiddleware::EncodeJson
      @connection.use FaradayMiddleware::FollowRedirects
    end

    def create_pull_request_build(pull_request, branch, commit, workflow)
      @connection.post("/apps/#{@app_slug}/builds", {
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

    def abort_pull_request_builds(pull_request, branch, commit)
      find_pull_request_builds(pull_request, branch, commit).each do |build|
        @connection.post("/apps/#{@app_slug}/builds/#{build[:slug]}/abort", {
                           abort_reason: "Aborting due to other build failed for pull request #{pull_request}"
                         })
      end
    end

    def find_pull_request_builds(pull_request, branch, commit)
      builds = @connection.get("/apps/#{@app_slug}/builds", {
                                 branch: branch,
                                 pull_request_id: pull_request.to_i,
                                 status: 0 # status: 0 == not finished
                               })
      builds&.select! { |build| build[:commit_hash] == commit }
      builds || []
    end

    def base_url
      "#{HOST}/#{API_VERSION}"
    end
  end
end
