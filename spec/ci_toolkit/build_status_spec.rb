# frozen_string_literal: true

require "rspec"
require "ci_toolkit"

env = CiToolkit::BitriseEnv.new

describe CiToolkit::BuildStatus do
  it "starts a build status for the given amount of builds" do
    github = instance_spy("github")
    sut = described_class.new("Builds", github)
    sut.start(4)
    expect(github).to have_received(:create_status).with("pending", "Builds", env.app_url, "Finished building 0/4")
  end

  it "starts with immediate success if 0 builds are provided" do
    github = instance_spy("github")
    sut = described_class.new("Builds", github)
    sut.start(0)
    expect(github).to have_received(:create_status).with("success", "Builds", env.build_url, "No builds assigned")
  end

  it "increments the build counter" do
    github = instance_spy("github")
    allow(github).to receive(:get_status).and_return({ description: "Finished building 0/4" })
    sut = described_class.new("Builds", github)
    sut.increment
    expect(github).to have_received(:create_status).with("pending", "Builds", env.app_url, "Finished building 1/4")
  end

  it "increments the build counter and succeeds" do
    github = instance_spy("github")
    allow(github).to receive(:get_status).and_return({ description: "Finished building 3/4" })
    sut = described_class.new("Builds", github)
    sut.increment
    expect(github).to have_received(:create_status).with("success", "Builds", env.app_url, "Finished building 4/4")
  end
end
