# frozen_string_literal: true

module CiToolkit
  # Data class for the app store connect api key
  class AppStoreConnectApiKey
    attr_reader :content, :issuer_id, :id

    def initialize(
      content = ENV["APP_STORE_CONNECT_API_KEY_CONTENTS"],
      issuer_id = "69a6de72-6702-47e3-e053-5b8c7c11a4d1",
      id = "C8S4S9T8H4"
    )
      @content = content
      @issuer_id = issuer_id
      @id = id
    end
  end
end
