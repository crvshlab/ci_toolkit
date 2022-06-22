# frozen_string_literal: true

require "ci_toolkit"

private

def parse(json)
  body = JSON.parse(json)
  Gitlab::ObjectifiedHash.new(body)
end

describe CiToolkit::GitlabPr do
  env = CiToolkit::BitriseEnv.new({ pull_request_number: 100, repository_owner: "org", repository_slug: "repo" })

  it "provides a title" do
    obj = parse(JSON.unparse(title: "The PR title"))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:merge_request).and_return(obj)
    expect(sut.title).to eq "The PR title"
  end

  it "provides lines of code changed" do
    obj =  parse(JSON.unparse(changes_count: 20))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:merge_request).and_return(obj)
    expect(sut.lines_of_code_changed).to be 20
  end

  it "has comments" do
    obj = parse(JSON.unparse(body: "This is the comment text"))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:merge_request_notes).and_return([obj])
    expect(sut.comments).to eq ["This is the comment text"]
  end

  it "adds a comment" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    sut.comment("my new text")
    expect(client).to have_received(:create_merge_request_note).with("org/repo", 100, "my new text")
  end

  it "deletes a comment with text" do
    client = instance_spy("client")
    allow(client).to receive(:merge_request_notes).and_return([parse(JSON.unparse(body: "example text", id: 12_345))])
    sut = described_class.new(env, [], client)
    sut.delete_comments_including_text("example text")
    expect(client).to have_received(:delete_merge_request_note).with("org/repo", 100, 12_345)
  end

  it "checks for files modified in the realm module" do
    obj = parse(JSON.unparse(changes: [old_path: "cache/realm"]))
    client = instance_spy("client")
    allow(client).to receive(:merge_request_changes).and_return(obj)
    sut = described_class.new(env, [], client)
    expect(sut).to be_realm_module_modified
  end

  it "correctly identifies that the realm module was not modified" do
    obj = parse(JSON.unparse(changes: [old_path: "fastlane/files"]))
    client = instance_spy("client")
    allow(client).to receive(:merge_request_changes).and_return(obj)
    sut = described_class.new(env, [], client)
    expect(sut).not_to be_realm_module_modified
  end

  it "does not error if the file doesn't have a filename" do
    obj = parse(JSON.unparse(changes: []))
    client = instance_spy("client")
    allow(client).to receive(:merge_request_changes).and_return(obj)
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
    obj = parse(JSON.unparse(labels: ["Label name"]))
    client = instance_spy("client")
    allow(client).to receive(:merge_request).and_return(obj)
    sut = described_class.new(env, [], client)
    expect(sut.labels).to eq ["Label name"]
  end

  it "creates a status check" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    sut.create_status("success", "Your check name",
                      "https://target.url", "Your status description")
    expect(client).to have_received(:update_commit_status)
  end

  it "finds the build types from PR comments" do
    client = instance_spy("client")
    allow(client).to receive(:merge_request).and_return(parse(JSON.unparse(labels: ["WIP"])))
    allow(client).to receive(:merge_request_notes).and_return([parse(JSON.unparse(body: "build1 build"))])
    sut = described_class.new(env, %w[build1 build2], client)
    expect(sut.build_types).to eq %w[build1]
  end

  it "finds the build types from PR labels" do
    client = instance_spy("client")
    allow(client).to receive(:merge_request_notes).and_return([parse(JSON.unparse(body: "Just a comment"))])
    allow(client).to receive(:merge_request).and_return(parse(JSON.unparse(labels: ["build2 build"])))
    sut = described_class.new(env, %w[build1 build2], client)
    expect(sut.build_types).to eq ["build2"]
  end

  it "knows if PR is labeled as infrastructure work" do
    obj = parse(JSON.unparse(title: "title", labels: ["Infra"]))
    client = instance_spy("client")
    allow(client).to receive(:merge_request).and_return(obj)
    sut = described_class.new(env, [], client)
    expect(sut.infrastructure_work?).to be true
  end

  it "knows if PR has a title showing infrastructure work" do
    obj = parse(JSON.unparse(title: "[INFRA]"))
    client = instance_spy("client")
    allow(client).to receive(:merge_request).and_return(obj)
    sut = described_class.new(env, [], client)
    expect(sut.infrastructure_work?).to be true
  end

  it "knows if PR is labeled as work in progress" do
    obj = parse(JSON.unparse(title: "The PR title", labels: ["WIP"]))
    client = instance_spy("client")
    allow(client).to receive(:merge_request).and_return(obj)
    sut = described_class.new(env, [], client)
    expect(sut.work_in_progress?).to be true
  end

  it "knows if PR has a title showing work in progress" do
    obj = parse(JSON.unparse(title: "[WIP]"))
    client = instance_spy("client")
    allow(client).to receive(:merge_request).and_return(obj)
    sut = described_class.new(env, [], client)
    expect(sut.work_in_progress?).to be true
  end

  it "knows if the PR is big" do
    obj =  parse(JSON.unparse(changes_count: "501"))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:merge_request).and_return(obj)
    expect(sut.big?).to be true
  end

  it "finds comment containing text" do
    obj = parse(JSON.unparse(body: "This is a comment with some text"))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:merge_request_notes).and_return([obj])
    expect(sut.find_comments_including_text("This is a comment")).to eq([obj])
  end

  it "does not find comment a comment if there is no comment containing the search text" do
    obj = parse(JSON.unparse(body: nil))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:merge_request_notes).and_return([obj])
    expect(sut.find_comments_including_text("This is a comment")).to eq []
  end

  it "provides the correct pull request number" do
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    expect(sut.number).to eq 100
  end

  it "gets the status of a check" do
    obj = parse(JSON.unparse(name: "check context"))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:commit_status).and_return([obj])
    expect(sut.get_status("check context")).not_to be_nil
  end

  it "provides a nil status if there is no check with the given context" do
    obj = parse(JSON.unparse(name: "check context"))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:commit_status).and_return([obj])
    expect(sut.get_status("a different context")).to be_nil
  end

  it "gets the description of a commit status" do
    obj = parse(JSON.unparse(description: "Building description", name: "check context"))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:commit_status).and_return([obj])
    expect(sut.get_status_description("check context")).to eq "Building description"
  end

  it "gets nil for description of a commit status" do
    obj = parse(JSON.unparse(description: nil, name: "check context"))
    client = instance_spy("client")
    sut = described_class.new(env, [], client)
    allow(client).to receive(:commit_status).and_return([obj])
    expect(sut.get_status_description("check context")).to be_nil
  end
end
