# frozen_string_literal: true

module CiToolkit
  # Provides utility for a build
  class Build
    def initialize(
      git = CiToolkit::Git.new,
      config = CiToolkit::BuildConfig.new
    )
      @git = git
      @config = config
    end

    def url
      @config.build_url
    end

    def number
      @config.build_number || Time.now.to_i.to_s
    end

    def from_pull_request?
      @config.for_pull_request?
    end

    def from_develop?
      !!(@git.branch =~ /^develop$/)
    end

    def from_release?
      !!(@git.branch =~ %r{^release/.*})
    end

    def from_master?
      !!(@git.branch =~ /^master$/)
    end

    def from_cron_job?
      @config.for_cron_job?
    end
  end
end
