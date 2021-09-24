# frozen_string_literal: true

module CiToolkit
  # Provides utility for a build
  class BuildConfig
    attr_reader :build_number, :build_url

    def initialize(
      options = { build_number: ENV["BITRISE_BUILD_NUMBER"], build_url: ENV["BITRISE_BUILD_URL"] },
      for_pull_request = !ENV["BITRISE_PULL_REQUEST"].nil?,
      for_cron_job = !ENV["BITRISE_SCHEDULED_BUILD"].nil?
    )
      @build_number = options&.[](:build_number)
      @build_url = options&.[](:build_url)
      @for_pull_request = for_pull_request
      @for_cron_job = for_cron_job
    end

    def for_pull_request?
      @for_pull_request
    end

    def for_cron_job?
      @for_cron_job
    end
  end
end
