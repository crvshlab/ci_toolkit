# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::Git do
  before do
    `rm -rf git_test`
    `mkdir git_test`
    `cd git_test && git init --initial-branch=main`
    `cd git_test && touch test.txt`
    `cd git_test && git add test.txt`
    `cd git_test && git commit -am "Initial commit"`
    `cd git_test && git tag -a 0.1 -m "First tag"`
  end

  after do
    `rm -rf git_test`
  end

  it "provides the latest tag" do
    sut = described_class.new("git_test")
    expect(sut.latest_tag).to eq "0.1"
  end

  it "provides the latest tag in current dir" do
    sut = described_class.new
    git_tag = `git describe --abbrev=0`.gsub("\n", "")
    expect(sut.latest_tag).to eq git_tag
  end

  it "provides the current branch" do
    sut = described_class.new("git_test")
    expect(sut.branch).to eq "main"
  end

  it "provides the current branch in current dir" do
    sut = described_class.new(nil)
    expect(sut.branch).to eq "main"
  end

  it "provides the current branch from branch name" do
    env = CiToolkit::BitriseEnv.new({ git_branch: "the-branch" })
    sut = described_class.new(nil, env)
    expect(sut.branch).to eq "the-branch"
  end

  it "correctly recognizes an infrastructure branch" do
    env = CiToolkit::BitriseEnv.new({ git_branch: "infra/branch" })
    sut = described_class.new(nil, env)
    expect(sut.infrastructure_branch?).to be true
  end

  it "correctly recognizes an non infrastructure branch" do
    env = CiToolkit::BitriseEnv.new({ git_branch: "feature/branch" })
    sut = described_class.new(nil, env)
    expect(sut.infrastructure_branch?).to be false
  end
end
