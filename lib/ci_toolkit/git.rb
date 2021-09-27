# frozen_string_literal: true

module CiToolkit
  # Utility class to provide information about git related data
  class Git
    def initialize(dir = nil, env = CiToolkit::BitriseEnv.new)
      @branch = env.git_branch
      @dir = dir
    end

    def latest_tag
      describe = "git describe --abbrev=0"
      return `#{describe}`.gsub("\n", "") unless @dir

      `cd #{@dir} && #{describe}`.gsub("\n", "")
    end

    def branch
      return @branch unless @branch.nil?

      git_branch_cmd = "git branch --show-current"
      return `cd #{@dir} && #{git_branch_cmd}`.gsub(/\s+/, "") unless @dir.nil?

      `#{git_branch_cmd}`.gsub(/\s+/, "")
    end

    def infrastructure_branch?
      !(branch =~ %r{infra/}).nil?
    end
  end
end
