# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::GithubPr do
  it "should provide a title" do
    client = spy("client")
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    allow(client).to receive(:pull_request).and_return({ title: "The PR title" })
    expect(sut.title).to be "The PR title"
    expect(client).to have_received(:pull_request).with("crvshlab/v-app-ios", 100)
  end

  it "should provide lines of code changed" do
    client = spy("client")
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    allow(client).to receive(:pull_request).and_return({ additions: 10, deletions: 10 })
    expect(sut.lines_of_code_changed).to be 20
  end

  it "should have comments" do
    client = spy("client")
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    allow(client).to receive(:issue_comments).and_return([{ body: "This is the comment text" }])
    expect(sut.comments).to eq ["This is the comment text"]
  end

  it "should add a comment" do
    client = spy("client")
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    sut.comment("my new text")
    expect(client).to have_received(:add_comment).with("crvshlab/v-app-ios", 100, "my new text")
  end

  it "should delete a comment with text" do
    client = spy("client")
    allow(client).to receive(:issue_comments).and_return([{ body: "example text", id: 12_345 }])
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    sut.delete_comment_containing_text("example text")
    expect(client).to have_received(:issue_comments).with("crvshlab/v-app-ios", 100)
    expect(client).to have_received(:delete_comment).with("crvshlab/v-app-ios", 12_345)
  end

  it "should not delete a comment if it can't find the text" do
    client = spy("client")
    allow(client).to receive(:issue_comments).and_return(
      [{ body: "other text", id: 12_345 },
       { body: nil, id: 12_346 },
       { id: 12_347 }]
    )
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    sut.delete_comment_containing_text("example text")
    expect(client).to have_received(:issue_comments).with("crvshlab/v-app-ios", 100)
    expect(client).not_to have_received(:delete_comment).with("crvshlab/v-app-ios", 12_345)
  end

  it "should provide labels" do
    client = spy("client")
    allow(client).to receive(:labels_for_issue).and_return([{ name: "Label name" }])
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    expect(sut.labels).to eq ["Label name"]
  end

  it "should create a pull request" do
    client = spy("client")
    allow(client).to receive(:pull_request).and_return({ head: { sha: "commit_sha"} })
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    sut.create_status(
      "success",
      "Your check name",
      "https://pathtomoreinformation.aboutyour.check",
      "Your status description"
    )
    expect(client).to have_received(:pull_request).with("crvshlab/v-app-ios", 100)
    expect(client).to have_received(:create_status)
  end

  it "should find the build types from PR comments" do
    client = spy("client")
    allow(client).to receive(:labels_for_issue).and_return([{ name: "WIP" }])
    allow(client).to receive(:issue_comments).and_return([{ body: "Acceptance PreProd build" }])
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    expect(sut.build_types).to eq ["Acceptance PreProd"]
  end

  it "should find the build types from PR labels" do
    client = spy("client")
    allow(client).to receive(:issue_comments).and_return([{ body: "Just a comment" }])
    allow(client).to receive(:labels_for_issue).and_return([{ name: "Acceptance PreProd build" }])
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    expect(sut.build_types).to eq ["Acceptance PreProd"]
  end

  it "should know if PR is labeled as infrastructure work" do
    client = spy("client")
    allow(client).to receive(:labels_for_issue).and_return([{ name: "Infra" }])
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    expect(sut.infrastructure_work?).to be true
  end

  it "should know if PR has a title showing infrastructure work" do
    client = spy("client")
    allow(client).to receive(:pull_request).and_return({ title: "[INFRA]" })
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    expect(sut.infrastructure_work?).to be true
  end

  it "should know if PR is labeled as work in progress" do
    client = spy("client")
    allow(client).to receive(:pull_request).and_return({ title: "The PR title" })
    allow(client).to receive(:labels_for_issue).and_return([{ name: "WIP" }])
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    expect(sut.work_in_progress?).to be true
  end

  it "should know if PR has a title showing work in progress" do
    client = spy("client")
    allow(client).to receive(:pull_request).and_return({ title: "[WIP]" })
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    expect(sut.work_in_progress?).to be true
  end

  it "should know if the PR is big" do
    client = spy("client")
    sut = CiToolkit::GithubPr.new(100, "crvshlab/v-app-ios", client)
    allow(client).to receive(:pull_request).and_return({ additions: 250, deletions: 251 })
    expect(sut.big?).to be true
  end
end
