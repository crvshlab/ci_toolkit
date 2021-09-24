# frozen_string_literal: true

module CiToolkit
  # Utility class to parse a Jira ticket from a string
  class Jira
    def initialize(
      github_pr = CiToolkit::GithubPr.new,
      git = CiToolkit::Git.new,
      ticket_regex_keys = ENV["SUPPORTED_JIRA_PROJECT_KEYS_REGEX"]
    )
      @github_pr = github_pr
      @git = git
      @ticket_regex_keys = ticket_regex_keys
    end

    def ticket
      parse_ticket(@github_pr.title) || parse_ticket(@git.branch)
    end

    private

    def parse_ticket(string)
      matches = string.match(ticket_regex)
      key = matches&.[](:project_key)
      number = matches&.[](:ticket_number)
      "#{key}-#{number}" unless key.nil? || key.empty? || number.nil? || number.empty?
    end

    def ticket_regex
      /.*?(?<project_key>#{@ticket_regex_keys})[- ]?(?<ticket_number>[0-9]+)/i
    end
  end
end
