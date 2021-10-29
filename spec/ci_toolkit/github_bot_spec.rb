# frozen_string_literal: true

require "ci_toolkit"
require "rspec"

describe CiToolkit::GithubBot do
  it "provides a valid token" do
    creds = instance_spy("credentials")
    client = instance_spy("client")
    allow(client).to receive(:create_app_installation_access_token).and_return({ token: "23fdasfk43kjkk" })

    sut = described_class.new(creds, client)
    expect(sut.create_token).to eq "23fdasfk43kjkk"
  end
end
