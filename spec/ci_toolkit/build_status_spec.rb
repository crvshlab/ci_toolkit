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

  it "increments the build counter for github" do
    github = instance_spy("github")
    allow(github).to receive(:get_status_description).with("Builds").and_return("Finished building 0/4")
    sut = described_class.new("Builds", github)
    sut.increment(CiToolkit::DvcsPrUtil.status_state_pending("github"))
    expect(github).to have_received(:create_status).with("pending", "Builds", env.app_url, "Finished building 1/4")
  end

  it "increments the build counter for gitlab" do
    github = instance_spy("github")
    allow(github).to receive(:get_status_description).with("Builds").and_return("Finished building 0/4")
    sut = described_class.new("Builds", github)
    sut.increment(CiToolkit::DvcsPrUtil.status_state_pending("gitlab"))
    expect(github).to have_received(:create_status).with("running", "Builds", env.app_url, "Finished building 1/4")
  end

  it "increments the build counter and succeeds" do
    github = instance_spy("github")
    allow(github).to receive(:get_status_description).with("Builds").and_return("Finished building 3/4")
    sut = described_class.new("Builds", github)
    sut.increment
    expect(github).to have_received(:create_status).with("success", "Builds", env.app_url, "Finished building 4/4")
  end

  it "updates commit status of github with error" do
    github = instance_spy("github")
    sut = described_class.new("Builds", github)
    sut.error(CiToolkit::DvcsPrUtil.status_state("github"))
    expect(github).to have_received(:create_status).with("error", "Builds", env.app_url, "Building failed")
  end

  it "updates commit status of gitlab with failed" do
    github = instance_spy("github")
    sut = described_class.new("Builds", github)
    sut.error(CiToolkit::DvcsPrUtil.status_state("gitlab"))
    expect(github).to have_received(:create_status).with("failed", "Builds", env.app_url, "Building failed")
  end
end
