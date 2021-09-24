# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::AppStoreConfig do
  it "instantiates" do
    sut = described_class.new
    expect(sut).not_to be_nil
  end

  it "has the right target default" do
    sut = described_class.new
    expect(sut.target).to eq "SmartLife"
  end

  it "has the right app identifier default" do
    sut = described_class.new
    expect(sut.app_identifier).to eq "com.vodafone.smartlife"
  end

  it "has the right team id default" do
    sut = described_class.new
    expect(sut.team_id).to eq "GE7TB7Z856"
  end

  it "has the right keychain access group id default" do
    sut = described_class.new
    expect(sut.keychain_access_group_id).to eq %w[GE7TB7Z856.* com.apple.token]
  end

  it "has the right entitlements file default" do
    sut = described_class.new
    expect(sut.entitlements_file).to eq "Sources/SmartLifeStore.entitlements"
  end

  it "has the right scheme default" do
    sut = described_class.new
    expect(sut.scheme).to eq "SmartLife"
  end

  it "has the right provisioning profile name default" do
    sut = described_class.new
    expect(sut.provisioning_profile_name).to eq "match AppStore com.vodafone.smartlife"
  end

  it "has the right build configuration default" do
    sut = described_class.new
    expect(sut.build_configuration).to eq "Store"
  end

  it "has the right app store connect team id default" do
    sut = described_class.new
    expect(sut.app_store_connect_team_id).to eq "308481"
  end

  it "has the right itc provider default" do
    sut = described_class.new
    expect(sut.itc_provider).to eq "VodafoneGroupTradingLimited"
  end
end
