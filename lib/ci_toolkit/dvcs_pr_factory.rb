# frozen_string_literal: true

module CiToolkit

  class DvcsPrFactory
    SERVICES = {
      "gitlab" => CiToolkit::GitlabPr,
      "github" => CiToolkit::GithubPr
    }

    private_constant :SERVICES

    def self.create(bitrise_env = CiToolkit::BitriseEnv.new)
      service = ENV["DVCS_SERVICE"]
      (SERVICES[service.to_s.downcase] || CiToolkit::DvcsPr).new bitrise_env
    end
  end
end
