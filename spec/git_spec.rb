# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::Git do
  before(:all) do
    `rm -rf git_test`
    `mkdir git_test`
    `cd git_test && git init --initial-branch=main`
    `cd git_test && touch test.txt`
    `cd git_test && git add test.txt`
    `cd git_test && git commit -am "Initial commit"`
    `cd git_test && git tag -a 0.1 -m "First tag"`
  end

  after(:all) do
    `rm -rf git_test`
  end

  it "should provide the latest tag" do
    sut = CiToolkit::Git.new("git_test")
    expect(sut.latest_tag).to eq "0.1"
  end

  it "should provide the latest tag in current dir" do
    sut = CiToolkit::Git.new
    git_tag = `git describe --abbrev=0`.gsub("\n", "")
    expect(sut.latest_tag).to eq git_tag
  end

  it "should provide the current branch" do
    sut = CiToolkit::Git.new("git_test")
    expect(sut.branch).to eq "main"
  end

  it "should provide the current branch in current dir" do
    sut = CiToolkit::Git.new(nil, nil)
    expect(sut.branch).to eq "main"
  end

  it "should provide the current branch from branch name" do
    sut = CiToolkit::Git.new(nil, "the-branch")
    expect(sut.branch).to eq "the-branch"
  end

  it "should correctly recognize an infrastructure branch" do
    sut = CiToolkit::Git.new(nil, "infra/branch")
    expect(sut.infrastructure_branch?).to be true
    sut = CiToolkit::Git.new(nil, "feature/branch")
    expect(sut.infrastructure_branch?).to be false
  end
end
