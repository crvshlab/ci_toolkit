# frozen_string_literal: true

module CiToolkit
  # Provides utility for a build
  class Build
    def initialize(
      git = CiToolkit::Git.new,
      env = CiToolkit::BitriseEnv.new
    )
      @git = git
      @env = env
    end

    def url
      @env.build_url
    end

    def number
      @env.build_number || Time.now.to_i.to_s
    end

    def from_pull_request?
      @env.build_from_pr?
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
      @env.build_from_cron_job?
    end

    def version
      version = @git.branch.split("/").last
      return version if !version.nil? && Gem::Version.correct?(version)

      return @git.latest_tag if Gem::Version.correct?(@git.latest_tag)

      raise StandardError, "Incorrect version supplied. You need to build from a valid \
release branch with semantic versioning, eg. release/x.y.z"
    end

    def tag_name(build_number = nil)
      return version.to_s if version.include?("-build.") || build_number.nil?

      "#{version}-build.#{build_number}"
    end
  end
end
