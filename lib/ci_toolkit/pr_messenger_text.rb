# frozen_string_literal: true

module CiToolkit
  # Utilities to create markdown text from build messages
  class PrMessengerText
    def initialize(
      build = CiToolkit::Build.new,
      app_url = ENV["BITRISE_APP_URL"]
    )
      @build = build
      @app_url = app_url
    end

    def for_new_build(name, version_name, tag)
      "#### New `#{name}` build deployed 🚀\nVersion **#{version_name}** with
        build number **#{@build.number}** on tag **#{tag}** deployed
        from [this](#{@build.url}) build"
    end

    def for_build_failure(reason)
      "#### Build failed ⛔️\n#{body(reason.to_s)}"
    end

    def for_duplicated_files_report(report)
      "#{duplicated_files_title}\n#{body(report)}"
    end

    def for_lint_report(report)
      "#{lint_report_title}\n#{body(report)}"
    end

    def duplicated_files_title
      warning_with_message("There are duplicated files found")
    end

    def lint_report_title
      "#### Swiftlint report 🕵️‍♀️"
    end

    def big_pr_warning_title
      warning_with_message("Big PR")
    end

    def work_in_progress_title
      "PR is Work in Progress 🚧"
    end

    def warning_with_message(message)
      "Warning: #{message} ⚠️"
    end

    def create_duplicate_files_report(finder)
      report = ""
      finder.duplicate_groups.each do |dups|
        report = "#{report}\n#{dups.join("\n")}\n"
      end
      report
    end

    def footer
      "###### 🔮 _Comment via [CI](#{@app_url}) on build [#{@build.number}](#{@build.url})_"
    end

    def body(text)
      formatted_text = "```\n#{text}\n```"
      formatted_text = "<details>\n<summary>Details</summary>\n\n#{formatted_text}\n</details>" if text.lines.count > 6
      "#{formatted_text}\n"
    end
  end
end
