# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::GithubPr do
  env = CiToolkit::BitriseEnv.new({ pull_request_number: 100, repository_owner: "org", repository_slug: "repo" })

  it "provides a title" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:pull_request).and_return({ title: "The PR title" })
    expect(sut.title).to be "The PR title"
  end

  it "provides lines of code changed" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:pull_request).and_return({ additions: 10, deletions: 10 })
    expect(sut.lines_of_code_changed).to be 20
  end

  it "has comments" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:issue_comments).and_return([{ body: "This is the comment text" }])
    expect(sut.comments).to eq ["This is the comment text"]
  end

  it "adds a comment" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    sut.comment("my new text")
    expect(client).to have_received(:add_comment).with("org/repo", 100, "my new text")
  end

  it "deletes a comment with text" do
    client = instance_spy("client")
    allow(client).to receive(:issue_comments).and_return([{ body: "example text", id: 12_345 }])
    sut = described_class.new(env, [], client)
    sut.delete_comments_including_text("example text")
    expect(client).to have_received(:delete_comment).with("org/repo", 12_345)
  end

  it "checks for files modified in the realm module" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request_files).and_return([{ filename: "cache/realm" }])
    sut = described_class.new(env, [], client)
    expect(sut).to be_realm_module_modified
  end

  it "correctly identifies that the realm module was not modified" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request_files).and_return([{ filename: "a_different_file_name.jpg" }])
    sut = described_class.new(env, [], client)
    expect(sut).not_to be_realm_module_modified
  end

  it "does not error if the file doesn't have a filename" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request_files).and_return([{}])
    sut = described_class.new(env, [], client)
    expect(sut).not_to be_realm_module_modified
  end

  it "does not delete a comment if it can't find the text" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    sut.delete_comments_including_text("example text")
    expect(client).not_to have_received(:delete_comment).with("crvshlab/v-app-ios", 12_345)
  end

  it "provides labels" do
    client = instance_spy("client")
    allow(client).to receive(:labels_for_issue).and_return([{ name: "Label name" }])
    sut = described_class.new(env, [], client)
    expect(sut.labels).to eq ["Label name"]
  end

  it "creates a status check" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    sut.create_status("success", "Your check name",
                      "https://target.url", "Your status description")
    expect(client).to have_received(:create_status)
  end

  it "finds the build types from PR comments" do
    client = instance_spy("client")
    allow(client).to receive(:labels_for_issue).and_return([{ name: "WIP" }])
    allow(client).to receive(:issue_comments).and_return([{ body: "build1 build" }])
    sut = described_class.new(env, %w[build1 build2], client)
    expect(sut.build_types).to eq %w[build1]
  end

  it "finds the build types from PR labels" do
    client = instance_spy("client")
    allow(client).to receive(:issue_comments).and_return([{ body: "Just a comment" }])
    allow(client).to receive(:labels_for_issue).and_return([{ name: "build2 build" }])
    sut = described_class.new(env, %w[build1 build2], client)
    expect(sut.build_types).to eq ["build2"]
  end

  it "knows if PR is labeled as infrastructure work" do
    client = instance_spy("client")
    allow(client).to receive(:labels_for_issue).and_return([{ name: "Infra" }])
    sut = described_class.new(env, [], client)
    expect(sut.infrastructure_work?).to be true
  end

  it "knows if PR has a title showing infrastructure work" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request).and_return({ title: "[INFRA]" })
    sut = described_class.new(env, [], client)
    expect(sut.infrastructure_work?).to be true
  end

  it "knows if PR is labeled as work in progress" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request).and_return({ title: "The PR title" })
    allow(client).to receive(:labels_for_issue).and_return([{ name: "WIP" }])
    sut = described_class.new(env, [], client)
    expect(sut.work_in_progress?).to be true
  end

  it "knows if PR has a title showing work in progress" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request).and_return({ title: "[WIP]" })
    sut = described_class.new(env, [], client)
    expect(sut.work_in_progress?).to be true
  end

  it "knows if the PR is big" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:pull_request).and_return({ additions: 250, deletions: 251 })
    expect(sut.big?).to be true
  end

  it "finds comment containing text" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:issue_comments).and_return([{ body: "This is a comment with some text" }])
    expect(sut.find_comments_including_text("This is a comment")).to eq([{ body: "This is a comment with some text" }])
  end

  it "does not find comment a comment if there is no comment containing the search text" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:issue_comments).and_return([{ body: nil }])
    expect(sut.find_comments_including_text("This is a comment")).to eq []
  end

  it "provides the correct pull request number" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    expect(sut.number).to eq 100
  end

  it "gets the status of a check" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:statuses).and_return([{ context: "check context" }])
    expect(sut.get_status("check context")).not_to be_nil
  end

  it "provides a nil status if there is no check with the given context" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:statuses).and_return([{ context: "check context" }])
    expect(sut.get_status("a different context")).to be_nil
  end
end
