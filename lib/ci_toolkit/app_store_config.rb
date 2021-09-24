# frozen_string_literal: true

module CiToolkit
  # Utility class that provides information about configuration values required to build for the App Store
  AppStoreConfig = Struct.new(:target,
                              :app_identifier,
                              :team_id,
                              :keychain_access_group_id,
                              :entitlements_file,
                              :scheme,
                              :provisioning_profile_name,
                              :build_configuration,
                              :app_store_connect_team_id,
                              :itc_provider) do
    def initialize(target = "SmartLife",
                   app_identifier = "com.vodafone.smartlife",
                   team_id = "GE7TB7Z856",
                   keychain_access_group_id = %w[GE7TB7Z856.* com.apple.token],
                   entitlements_file = "Sources/SmartLifeStore.entitlements",
                   scheme = "SmartLife",
                   provisioning_profile_name = "match AppStore com.vodafone.smartlife",
                   build_configuration = "Store",
                   app_store_connect_team_id = "308481",
                   itc_provider = "VodafoneGroupTradingLimited")
      super
    end
  end
end
