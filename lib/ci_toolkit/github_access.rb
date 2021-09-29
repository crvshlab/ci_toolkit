# frozen_string_literal: true

require "octokit"
require "jwt"

module CiToolkit
  # Utility class that provides an access token that can be used with the Github API
  class GithubAccess
    # stack = Faraday::RackBuilder.new do |builder|
    #   builder.response :logger
    #   builder.use Octokit::Response::RaiseError
    #   builder.adapter Faraday.default_adapter
    # end
    # Octokit.middleware = stack

    def initialize(app_id = ENV["CRVSH_BOT_GITHUB_APP_ID"], private_key = ENV["CRVSH_BOT_GITHUB_APP_PRIVATE_KEY"])
      @app_id = app_id.to_i
      @private_key = private_key
      @client = Octokit::Client.new(bearer_token: jwt_token, auto_paginate: true)
    end

    def create_token
      return unless (installation_id = find_app_installation)

      @client.create_app_installation_access_token(
        installation_id,
        { accept: Octokit::Preview::PREVIEW_TYPES[:integrations] }
      )[:token]
    end

    private

    def find_app_installation
      @client.find_app_installations(
        { accept: Octokit::Preview::PREVIEW_TYPES[:integrations] }
      ).select { |installation| installation[:app_id] == @app_id }.first[:id]
    end

    def jwt_token
      JWT.encode(
        {
          iat: Time.now.to_i,
          exp: Time.now.to_i + (9 * 60),
          iss: @app_id
        },
        OpenSSL::PKey::RSA.new(@private_key),
        "RS256"
      )
    end
  end
end
