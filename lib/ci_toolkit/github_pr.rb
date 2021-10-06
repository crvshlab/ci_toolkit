# frozen_string_literal: true

require "octokit"

module CiToolkit
  # Can be used to retrieve information about a PR on Github via the Github API
  class GithubPr
    def initialize(
      env = CiToolkit::BitriseEnv.new,
      build_types = ENV["BUILD_TYPES"]&.split(/,/) || ["BluetoothDemo", "Acceptance PreProd", "Acceptance Prod",
                                                       "Latest Prod", "Latest PreProd", "Mock"],
      client = Octokit::Client.new
    )
      @pr_number = env.pull_request_number
      @repo_slug = env.repository_path
      @commit_sha = env.git_commit
      @_client = client
      @build_types = build_types
      @access = CiToolkit::GithubAccess.new
    end

    def title
      client.pull_request(@repo_slug, @pr_number).[](:title) || ""
    end

    def number
      @pr_number
    end

    def lines_of_code_changed
      pr = client.pull_request(@repo_slug, @pr_number)
      pr[:additions] + pr[:deletions]
    end

    def comments
      client.issue_comments(@repo_slug, @pr_number).map { |item| item[:body] }
    end

    def comment(text)
      client.add_comment(@repo_slug, @pr_number, text[0...65_500]) # github comment character limit is 65536
    end

    def delete_comments_including_text(text)
      comments = find_comments_including_text(text)
      comments.each { |comment| delete_comment(comment[:id]) unless comment.nil? }
    end

    def delete_comment(comment_id)
      client.delete_comment(@repo_slug, comment_id)
    end

    def find_comments_including_text(text)
      comments = []
      client.issue_comments(@repo_slug, @pr_number).map do |item|
        comments << item if item[:body]&.include? text
      end
      comments
    end

    def labels
      client.labels_for_issue(@repo_slug, @pr_number).map { |item| item[:name] }
    end

    def create_status(state, context, target_url, description)
      client.create_status(
        @repo_slug,
        @commit_sha,
        state,
        { context: context, target_url: target_url, description: description }
      )
    end

    def get_status(context)
      client.statuses(@repo_slug, @commit_sha).each do |status|
        return status if status[:context] == context
      end
    end

    def build_types
      types = []
      @build_types.each do |type|
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

    private

    def client
      @_client = Octokit::Client.new if @_client.nil?
      @_client.access_token = @access.create_token if @_client.access_token.nil?

      @_client
    end
  end
end
