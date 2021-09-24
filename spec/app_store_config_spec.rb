# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::AppStoreConfig do
  it "should instantiate" do
    sut = CiToolkit::AppStoreConfig.new
    expect(sut).not_to be_nil
  end

  it "should have valid defaults" do
    sut = CiToolkit::AppStoreConfig.new
    expect(sut.target).to eq "SmartLife"
    expect(sut.app_identifier).to eq "com.vodafone.smartlife"
    expect(sut.team_id).to eq "GE7TB7Z856"
    expect(sut.keychain_access_group_id).to eq %w[GE7TB7Z856.* com.apple.token]
    expect(sut.entitlements_file).to eq "Sources/SmartLifeStore.entitlements"
    expect(sut.scheme).to eq "SmartLife"
    expect(sut.provisioning_profile_name).to eq "match AppStore com.vodafone.smartlife"
    expect(sut.build_configuration).to eq "Store"
    expect(sut.app_store_connect_team_id).to eq "308481"
    expect(sut.itc_provider).to eq "VodafoneGroupTradingLimited"
  end
end
