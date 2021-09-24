# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::GithubPr do
  it "provides a title" do
    client = instance_spy("client")
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    allow(client).to receive(:pull_request).and_return({ title: "The PR title" })
    expect(sut.title).to be "The PR title"
    expect(client).to have_received(:pull_request).with("crvshlab/v-app-ios", 100)
  end

  it "provides lines of code changed" do
    client = instance_spy("client")
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    allow(client).to receive(:pull_request).and_return({ additions: 10, deletions: 10 })
    expect(sut.lines_of_code_changed).to be 20
  end

  it "has comments" do
    client = instance_spy("client")
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    allow(client).to receive(:issue_comments).and_return([{ body: "This is the comment text" }])
    expect(sut.comments).to eq ["This is the comment text"]
  end

  it "adds a comment" do
    client = instance_spy("client")
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    sut.comment("my new text")
    expect(client).to have_received(:add_comment).with("crvshlab/v-app-ios", 100, "my new text")
  end

  it "deletes a comment with text" do
    client = instance_spy("client")
    allow(client).to receive(:issue_comments).and_return([{ body: "example text", id: 12_345 }])
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    sut.delete_comment_containing_text("example text")
    expect(client).to have_received(:issue_comments).with("crvshlab/v-app-ios", 100)
    expect(client).to have_received(:delete_comment).with("crvshlab/v-app-ios", 12_345)
  end

  it "does not delete a comment if it can't find the text" do
    client = instance_spy("client")
    allow(client).to receive(:issue_comments).and_return(
      [{ body: "other text", id: 12_345 },
       { body: nil, id: 12_346 },
       { id: 12_347 }]
    )
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    sut.delete_comment_containing_text("example text")
    expect(client).to have_received(:issue_comments).with("crvshlab/v-app-ios", 100)
    expect(client).not_to have_received(:delete_comment).with("crvshlab/v-app-ios", 12_345)
  end

  it "provides labels" do
    client = instance_spy("client")
    allow(client).to receive(:labels_for_issue).and_return([{ name: "Label name" }])
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    expect(sut.labels).to eq ["Label name"]
  end

  it "creates a pull request" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request).and_return({ head: { sha: "commit_sha" } })
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    sut.create_status(
      "success",
      "Your check name",
      "https://pathtomoreinformation.aboutyour.check",
      "Your status description"
    )
    expect(client).to have_received(:pull_request).with("crvshlab/v-app-ios", 100)
    expect(client).to have_received(:create_status)
  end

  it "finds the build types from PR comments" do
    client = instance_spy("client")
    allow(client).to receive(:labels_for_issue).and_return([{ name: "WIP" }])
    allow(client).to receive(:issue_comments).and_return([{ body: "Acceptance PreProd build" }])
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    expect(sut.build_types).to eq ["Acceptance PreProd"]
  end

  it "finds the build types from PR labels" do
    client = instance_spy("client")
    allow(client).to receive(:issue_comments).and_return([{ body: "Just a comment" }])
    allow(client).to receive(:labels_for_issue).and_return([{ name: "Acceptance PreProd build" }])
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    expect(sut.build_types).to eq ["Acceptance PreProd"]
  end

  it "knows if PR is labeled as infrastructure work" do
    client = instance_spy("client")
    allow(client).to receive(:labels_for_issue).and_return([{ name: "Infra" }])
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    expect(sut.infrastructure_work?).to be true
  end

  it "knows if PR has a title showing infrastructure work" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request).and_return({ title: "[INFRA]" })
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    expect(sut.infrastructure_work?).to be true
  end

  it "knows if PR is labeled as work in progress" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request).and_return({ title: "The PR title" })
    allow(client).to receive(:labels_for_issue).and_return([{ name: "WIP" }])
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    expect(sut.work_in_progress?).to be true
  end

  it "knows if PR has a title showing work in progress" do
    client = instance_spy("client")
    allow(client).to receive(:pull_request).and_return({ title: "[WIP]" })
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    expect(sut.work_in_progress?).to be true
  end

  it "knows if the PR is big" do
    client = instance_spy("client")
    sut = described_class.new(100, "crvshlab/v-app-ios", client)
    allow(client).to receive(:pull_request).and_return({ additions: 250, deletions: 251 })
    expect(sut.big?).to be true
  end
end
