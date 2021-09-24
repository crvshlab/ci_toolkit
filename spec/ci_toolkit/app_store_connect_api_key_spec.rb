# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::AppStoreConnectApiKey do
  it "has valid content default" do
    sut = described_class.new
    expect(sut.content).to eq ENV["APP_STORE_CONNECT_API_KEY_CONTENTS"]
  end

  it "has valid issuer id default" do
    sut = described_class.new
    expect(sut.issuer_id).to eq "69a6de72-6702-47e3-e053-5b8c7c11a4d1"
  end

  it "has valid id default" do
    sut = described_class.new
    expect(sut.id).to eq "C8S4S9T8H4"
  end
end
