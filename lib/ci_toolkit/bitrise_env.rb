# frozen_string_literal: true

module CiToolkit
  # Bitrise constants
  # noinspection RubyTooManyInstanceVariablesInspection
  class BitriseEnv
    attr_reader :build_number, :build_url,
                :pull_request_number,
                :app_url,
                :git_branch,
                :app_slug,
                :git_commit

    def initialize(options = {
      build_number: ENV["BITRISE_BUILD_NUMBER"],
      build_url: ENV["BITRISE_BUILD_URL"],
      pull_request_number: ENV["BITRISE_PULL_REQUEST"],
      build_from_cron_job: !ENV["BITRISE_SCHEDULED_BUILD"].nil?,
      repository_owner: ENV["BITRISEIO_GIT_REPOSITORY_OWNER"] || "crvshlab",
      repository_slug: ENV["BITRISEIO_GIT_REPOSITORY_SLUG"],
      app_url: ENV["BITRISE_APP_URL"],
      app_slug: ENV["BITRISE_APP_SLUG"],
      git_branch: ENV["BITRISE_GIT_BRANCH"],
      git_commit: ENV["BITRISE_GIT_COMMIT"],
      api_token: ENV["BITRISE_TOKEN"]
    })
      @build_number = options[:build_number]
      @build_url = options[:build_url]
      @pull_request_number = options[:pull_request_number]
      @build_from_cron_job = options[:build_from_cron_job]
      @repository_owner = options[:repository_owner]
      @repository_slug = options[:repository_slug]
      @app_url = options[:app_url]
      @app_slug = options[:app_slug]
      @git_branch = options[:git_branch]
      @git_commit = options[:git_commit]
    end

    def build_from_pr?
      !pull_request_number.nil?
    end

    def build_from_cron_job?
      @build_from_cron_job
    end

    def repository_path
      "#{@repository_owner}/#{@repository_slug}"
    end
  end
end
