# frozen_string_literal: true

module CiToolkit
  # The configuration used with class Build
  class AppConfig
    def initialize(
      app_name = "SmartApp",
      project_name = "SmartLife",
      git = CiToolkit::Git.new
    )
      @app_name = app_name
      @project_name = project_name
      @git = git
    end

    def xcode_project_filename
      "#{@project_name}.xcodeproj"
    end

    def xc_workspace_filename
      "#{@project_name}.xcworkspace"
    end

    def xc_archive_filename
      "#{@project_name}.xcarchive"
    end

    def ipa_filename
      "#{@app_name}.ipa"
    end

    def dsym_zip_filename
      "#{@app_name}.app.dSYM.zip"
    end

    def version
      version = @git.branch.split("/").last
      return version if !version.nil? && Gem::Version.correct?(version)

      return @git.latest_tag if Gem::Version.correct?(@git.latest_tag)

      raise StandardError, "Incorrect version supplied. You need to build from a valid \
release branch with semantic versioning, eg. release/x.y.z"
    end

    def tag_name(build_number = nil)
      return "#{version}-build.#{build_number}" if build_number

      version.to_s
    end
  end
end
