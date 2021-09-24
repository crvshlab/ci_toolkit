# frozen_string_literal: true

require "octokit"

module CiToolkit
  # Can be used to retrieve information about a PR on Github via the Github API
  class GithubPr

    def initialize(
      pr_number = ENV["BITRISE_PULL_REQUEST"],
      repo_slug = "#{ENV["BITRISEIO_GIT_REPOSITORY_OWNER"] || "crvshlab"}/#{ENV["BITRISEIO_GIT_REPOSITORY_SLUG"]}",
      client = Octokit::Client.new(access_token: CiToolkit::GithubAccess.new.create_token)
    )
      @pr_number = pr_number
      @repo_slug = repo_slug
      @client = client
    end

    def title
      @client.pull_request(@repo_slug, @pr_number).[](:title)
    end

    def lines_of_code_changed
      pr = @client.pull_request(@repo_slug, @pr_number)
      pr.[](:additions) + pr.[](:deletions)
    end

    def comments
      @client.issue_comments(@repo_slug, @pr_number).map { |item| item[:body] }
    end

    def comment(text)
      @client.add_comment(@repo_slug, @pr_number, text)
    end

    def delete_comment_containing_text(text)
      comment = find_comment_containing_text(text)
      delete_comment(comment[:id]) unless comment.nil?
    end

    def delete_comment(comment_id)
      @client.delete_comment(@repo_slug, comment_id)
    end

    def find_comment_containing_text(text)
      comment = nil
      @client.issue_comments(@repo_slug, @pr_number).map do |item|
        comment = item if item[:body]&.include? text
      end
      comment
    end

    def labels
      @client.labels_for_issue(@repo_slug, @pr_number).map { |item| item[:name] }
    end

    def create_status(state, context, target_url, description)
      ref = @client.pull_request(@repo_slug, @pr_number).[](:head).[](:sha)
      @client.create_status(
        @repo_slug,
        ref,
        state,
        { context: context, target_url: target_url, description: description }
      )
    end

    def build_types
      types = []
      ["Acceptance PreProd", "Acceptance Prod", "Latest Prod", "Latest PreProd", "Mock"].each do |type|
        types.push(type) if comments.include?("#{type} build") || labels.include?("#{type} build")
      end
      types
    end

    def infrastructure_work?
      !(title =~ /\[infra\]/i).nil? || labels.include?("Infra")
    end

    def work_in_progress?
      title.include?("[WIP]") || labels.include?("WIP")
    end

    def big?
      lines_of_code_changed > 500
    end
  end
end
