# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::AppStoreConnectApiKey do
  it "should have valid defaults" do
    sut = CiToolkit::AppStoreConnectApiKey.new
    expect(sut.content).to eq ENV["APP_STORE_CONNECT_API_KEY_CONTENTS"]
    expect(sut.issuer_id).to eq "69a6de72-6702-47e3-e053-5b8c7c11a4d1"
    expect(sut.id).to eq "C8S4S9T8H4"
  end
end
