# frozen_string_literal: true

require "ci_toolkit"
require "rspec"

describe CiToolkit::GithubBot do
  creds = CiToolkit::GithubBot::Credentials.new(123)

  it "provides a valid token" do
    client = instance_spy("client")
    allow(client).to receive(:create_app_installation_access_token).and_return({ token: "23fdasfk43kjkk" })

    sut = described_class.new(creds, client)
    expect(sut.create_token).to eq "23fdasfk43kjkk"
  end

  it "finds the app installation" do
    client = instance_spy("client")
    allow(client).to receive(:find_app_installations).and_return([{ app_id: 123 }])

    described_class.new(creds, client).create_token
    expect(client).to have_received(:find_app_installations)
  end
end
