# frozen_string_literal: true

module CiToolkit
  # Use this to create an instance of Dvcs implementation based on the service type
  # set in an environment value called DVCS_SERVICW with value of gitlab or github
  class DvcsPrFactory
    SERVICES = {
      "gitlab" => CiToolkit::GitlabPr,
      "github" => CiToolkit::GithubPr
    }.freeze

    private_constant :SERVICES

    def self.create(bitrise_env = CiToolkit::BitriseEnv.new)
      service = ENV["DVCS_SERVICE"]
      (SERVICES[service.to_s.downcase] || CiToolkit::DvcsPr).new bitrise_env
    end
  end
end
