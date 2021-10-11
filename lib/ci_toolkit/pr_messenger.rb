# frozen_string_literal: true

module CiToolkit
  # Sends messages to a Github PR for predefined build events
  class PrMessenger
    def initialize(
      github_pr = CiToolkit::GithubPr.new,
      messenger_text = CiToolkit::PrMessengerText.new
    )
      @github_pr = github_pr
      @messenger_text = messenger_text
      @is_connected = !@github_pr.nil?
    end

    def send_build_deployed(name, version_name, tag)
      send(@messenger_text.for_new_build(name, version_name, tag))
    end

    def send_ci_failed(reason)
      delete_ci_failed
      send(@messenger_text.for_build_failure(reason))
    end

    def delete_ci_failed
      delete(@messenger_text.build_failure_title)
    end

    def send_duplicate_files_report(finder)
      delete_duplicate_files_report
      report = @messenger_text.create_duplicate_files_report(finder)
      send(@messenger_text.for_duplicated_files_report(report))
      report
    end

    def delete_duplicate_files_report
      delete(@messenger_text.duplicated_files_title)
    end

    def send_lint_report(report)
      delete_lint_report
      send(@messenger_text.for_lint_report(report))
      report
    end

    def delete_lint_report
      delete(@messenger_text.lint_report_title)
    end

    def send_realm_modified_warning
      delete_realm_modified_warning
      send(@messenger_text.realm_modified_warning_title)
    end

    def delete_realm_modified_warning
      delete(@messenger_text.realm_modified_warning_title)
    end

    def send_big_pr_warning
      delete_big_pr_warning
      send(@messenger_text.big_pr_warning_title)
      @messenger_text.big_pr_warning_title
    end

    def delete_big_pr_warning
      delete(@messenger_text.big_pr_warning_title)
    end

    def send_work_in_progress
      delete_work_in_progress
      send(@messenger_text.work_in_progress_title)
      @messenger_text.work_in_progress_title
    end

    def delete_work_in_progress
      delete(@messenger_text.work_in_progress_title)
    end

    private

    def send(message)
      return unless @is_connected

      @github_pr.comment("#{message}\n#{@messenger_text.footer}")
    end

    def delete(message)
      return unless @is_connected

      @github_pr.delete_comments_including_text(message)
    end
  end
end
