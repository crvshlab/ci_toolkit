# frozen_string_literal: true

require "ci_toolkit"

sut = CiToolkit::GithubAccess.new(
  ENV["CRVSH_BOT_GITHUB_APP_ID"],
  ENV["CRVSH_BOT_GITHUB_APP_PRIVATE_KEY"]
)

describe CiToolkit::GithubAccess do
  it "should provide a valid token" do
    token = sut.create_token
    expect(token).not_to be_empty
    expect(token&.length).to be 40
  end
end
