# frozen_string_literal: true

require "rspec"
require "ci_toolkit"

Payload = Struct.new(:body)

describe CiToolkit::BitriseClient do
  find_pr_build_response = Payload.new({ "data" => [
                                         { "commit_hash" => "some_commit_hash", "slug" => "the_build_slug" }
                                       ] })
  create_pr_payload = {
    hook_info: { type: "bitrise" },
    build_params: {
      branch: "feature/my-pr",
      branch_dest: "develop",
      pull_request_id: 123,
      workflow_id: "workflow_id_name",
      commit_hash: "some_commit_hash"
    }
  }
  abort_pr_payload = {
    abort_reason: "Aborting due to other build failed for pull request 123"
  }

  it "has a connection" do
    faraday = instance_spy("faraday")
    sut = described_class.new({ build_number: 654, token: "dummy_token", app_slug: "a3rewrew4s5" }, faraday)
    expect(sut.connection).not_to be nil
  end

  it "creates a pull request build" do
    faraday = instance_spy("faraday")
    sut = described_class.new({ build_number: 654, token: "dummy_token", app_slug: "a3rewrew4s5" }, faraday)
    sut.create_pull_request_build(123, "feature/my-pr", "some_commit_hash", "workflow_id_name")
    expect(faraday).to have_received(:post).with("/v0.1/apps/a3rewrew4s5/builds", create_pr_payload)
  end

  it "searches for pull request builds on the api" do
    faraday = instance_spy("faraday")
    sut = described_class.new({ build_number: 654, token: "dummy_token", app_slug: "a3rewrew4s5" }, faraday)
    sut.find_pull_request_builds(123, "feature/my-pr", "some_commit_hash")
    params = { branch: "feature/my-pr", pull_request_id: 123, status: 0 }
    expect(faraday).to have_received(:get).with("/v0.1/apps/a3rewrew4s5/builds", params)
  end

  it "finds pull request builds with the given commit hash" do
    faraday = instance_spy("faraday")
    allow(faraday).to receive(:get).and_return(Payload.new({ "data" => [{ "commit_hash" => "some_commit_hash" }] }))
    sut = described_class.new({ build_number: 654, token: "dummy_token", app_slug: "a3rewrew4s5" }, faraday)
    builds = sut.find_pull_request_builds(123, "feature/my-pr", "some_commit_hash")
    expect(builds.length).to be_positive
  end

  it "returns empty array if it can't find builds" do
    faraday = instance_spy("faraday")
    allow(faraday).to receive(:get).and_return(Payload.new({ data: [] }))
    sut = described_class.new({ build_number: 654, token: "dummy_token", app_slug: "a3rewrew4s5" }, faraday)
    builds = sut.find_pull_request_builds(123, "feature/my-pr", "some_commit_hash")
    expect(builds).to eq []
  end

  it "aborts builds with a given commit hash" do
    faraday = instance_spy("faraday")
    allow(faraday).to receive(:get).and_return(find_pr_build_response)
    sut = described_class.new({ build_number: 654, token: "dummy_token", app_slug: "a3rewrew4s5" }, faraday)
    sut.abort_pull_request_builds(123, "feature/my-pr", "some_commit_hash")
    expect(faraday).to have_received(:post).with("/v0.1/apps/a3rewrew4s5/builds/the_build_slug/abort", abort_pr_payload)
  end

  it "filters builds by commit and the build number" do
    sut = described_class.new({ build_number: 342, token: "some_token" }, double)
    builds = sut.filter_builds_by_commit([{ "commit_hash" => "the_hash", "build_number" => 342 }], "the_hash")
    expect(builds.length).to be 0
  end

  it "configures the connection if no faraday is provided" do
    sut = described_class.new({ build_number: 342, token: "some_token" }, nil)
    expect(sut.connection).not_to be nil
  end
end
