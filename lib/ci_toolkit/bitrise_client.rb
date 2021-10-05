# frozen_string_literal: true

require "faraday_middleware"
require "faraday"

module CiToolkit
  # client to use with the Bitrise API
  class BitriseClient
    API_VERSION = "v0.1"
    attr_reader :connection

    def initialize(token = ENV["BITRISE_TOKEN"], app_slug = ENV["BITRISE_APP_SLUG"], faraday = nil)
      @token = token
      @app_slug = app_slug
      @connection = faraday
      configure_connection
      @connection&.use Faraday::Response::Logger, nil, { headers: true, bodies: true }
    end

    def configure_connection
      return unless @connection.nil?

      @connection = Faraday.new(
        url: "https://api.bitrise.io",
        headers: { "Content-Type" => "application/json", "Authorization" => @token }
      )
      @connection.use Faraday::Request::UrlEncoded
      @connection.use Faraday::Request::Retry
      @connection.use FaradayMiddleware::ParseJson
      @connection.use FaradayMiddleware::EncodeJson
      @connection.use FaradayMiddleware::FollowRedirects
    end

    def create_pull_request_build(pull_request, branch, commit, workflow)
      @connection&.post("/#{API_VERSION}/apps/#{@app_slug}/builds", {
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
        @connection&.post("/#{API_VERSION}/apps/#{@app_slug}/builds/#{build[:slug]}/abort", {
                            abort_reason: "Aborting due to other build failed for pull request #{pull_request}"
                          })
      end
    end

    def find_pull_request_builds(pull_request, branch, commit)
      response = @connection&.get("/#{API_VERSION}/apps/#{@app_slug}/builds", {
                                    branch: branch,
                                    pull_request_id: pull_request.to_i,
                                    status: 0 # status: 0 == not finished
                                  })
      puts "Response:\n"
      puts response.inspect

      builds = response[:response_body][:data]
      filter_builds_by_commit(builds, commit)
    end

    def filter_builds_by_commit(builds, commit)
      puts "Builds:\n"
      puts builds.inspect
      builds&.select! { |build| build[:commit_hash] == commit }
      builds || []
    end
  end
end
