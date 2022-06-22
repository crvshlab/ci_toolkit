# frozen_string_literal: true

module CiToolkit
  # allows to have a combined build status for all builds that are triggered for a pull request
  # it uses the description of the status check on Github to parse the number of builds remaining and total
  class BuildStatus
    def initialize(
      context = "Builds",
      github = CiToolkit::DvcsPrFactory.create(CiToolkit::BitriseEnv.new),
      env = CiToolkit::BitriseEnv.new
    )
      @context = context
      @github = github
      @env = env
    end

    def start(num_builds)
      state = "pending"
      target_url = @env.app_url
      desc = "Finished building 0/#{num_builds}"
      if num_builds.zero?
        state = "success"
        desc = "No builds assigned"
        target_url = @env.build_url
      end

      @github.create_status(state, @context, target_url, desc)
    end

    def increment
      counter = load_counter
      return if counter.nil?

      num_finished = counter[:num_finished] + 1
      num_total = counter[:num_total]

      state = "pending"
      state = "success" if num_finished == num_total

      @github.create_status(state, @context, @env.app_url, "Finished building #{num_finished}/#{num_total}")
    end

    def error
      @github.create_status("error", @context, @env.app_url, "Building failed")
    end

    private

    def load_counter
      status = @github.get_status(@context)
      return if status.nil?

      description = status[:description]
      build_counter = description[%r{(\d/\d)}] || "0/0"
      { num_finished: build_counter.split("/")[0].to_i, num_total: build_counter.split("/")[1].to_i }
    end
  end
end
