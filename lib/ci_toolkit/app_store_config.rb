# frozen_string_literal: true

module CiToolkit
  # Utility class that provides information about configuration values required to build for the App Store
  class AppStoreConfig
    attr_reader :target,
                :app_identifier,
                :team_id,
                :keychain_access_group_id,
                :entitlements_file,
                :scheme,
                :provisioning_profile_name,
                :build_configuration,
                :app_store_connect_team_id,
                :itc_provider

    def initialize(
      options = {
        target: "SmartLife",
        app_identifier: "com.vodafone.smartlife",
        team_id: "GE7TB7Z856",
        keychain_access_group_id: %w[GE7TB7Z856.* com.apple.token],
        entitlements_file: "Sources/SmartLifeStore.entitlements",
        scheme: "SmartLife",
        provisioning_profile_name: "match AppStore com.vodafone.smartlife",
        build_configuration: "Store",
        app_store_connect_team_id: "308481",
        itc_provider: "VodafoneGroupTradingLimited"
      }
    )
      @target = options.[](:target)
      @app_identifier = options.[](:app_identifier)
      @team_id = options.[](:team_id)
      @keychain_access_group_id = options.[](:keychain_access_group_id)
      @entitlements_file = options.[](:entitlements_file)
      @scheme = options.[](:scheme)
      @provisioning_profile_name = options.[](:provisioning_profile_name)
      @build_configuration = options.[](:build_configuration)
      @app_store_connect_team_id = options.[](:app_store_connect_team_id)
      @itc_provider = options.[](:itc_provider)
    end
  end
end
