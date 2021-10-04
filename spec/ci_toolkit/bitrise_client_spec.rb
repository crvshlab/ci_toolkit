# frozen_string_literal: true

require "rspec"
require "ci_toolkit"

describe CiToolkit::BitriseClient do
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
    sut = described_class.new("dummy_token", "a3rewrew4s5", faraday)
    expect(sut.connection).not_to be nil
  end

  it "creates a pull request build" do
    faraday = instance_spy("faraday")
    sut = described_class.new("dummy_token", "a3rewrew4s5", faraday)
    sut.create_pull_request_build(123, "feature/my-pr", "some_commit_hash", "workflow_id_name")
    expect(faraday).to have_received(:post).with("/v0.1/apps/a3rewrew4s5/builds", create_pr_payload)
  end

  it "searches for pull request builds on the api" do
    faraday = instance_spy("faraday")
    sut = described_class.new("dummy_token", "a3rewrew4s5", faraday)
    sut.find_pull_request_builds(123, "feature/my-pr", "some_commit_hash")
    params = { branch: "feature/my-pr", pull_request_id: 123, status: 0 }
    expect(faraday).to have_received(:get).with("/v0.1/apps/a3rewrew4s5/builds", params)
  end

  it "finds pull request builds with the given commit hash" do
    faraday = instance_spy("faraday")
    allow(faraday).to receive(:get).and_return({ body: [{ commit_hash: "some_commit_hash" }] })
    sut = described_class.new("dummy_token", "a3rewrew4s5", faraday)
    builds = sut.find_pull_request_builds(123, "feature/my-pr", "some_commit_hash")
    expect(builds.length).to be_positive
  end

  it "returns empty array if it can't find builds" do
    faraday = instance_spy("faraday")
    allow(faraday).to receive(:get).and_return(nil)
    sut = described_class.new("dummy_token", "a3rewrew4s5", faraday)
    builds = sut.find_pull_request_builds(123, "feature/my-pr", "some_commit_hash")
    expect(builds).to eq []
  end

  it "aborts builds with a given commit hash" do
    faraday = instance_spy("faraday")
    allow(faraday).to receive(:get).and_return({ body: [{ commit_hash: "some_commit_hash", slug: "the_build_slug" }] })
    sut = described_class.new("dummy_token", "a3rewrew4s5", faraday)
    sut.abort_pull_request_builds(123, "feature/my-pr", "some_commit_hash")
    expect(faraday).to have_received(:post).with("/v0.1/apps/a3rewrew4s5/builds/the_build_slug/abort", abort_pr_payload)
  end
end
