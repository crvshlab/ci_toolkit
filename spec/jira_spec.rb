# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::Jira do
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  it "should provide a valid ticket" do
    pr = spy("github_pr")
    git = spy("git")
    allow(pr).to receive(:title).and_return("[LAL-123] the pr title")
    sut = CiToolkit::Jira.new(pr, git, "lal|vv|thir|wig|td")
    expect(sut.ticket).to eq "LAL-123"
  end

  it "ticket should be nil if none exists" do
    pr = spy("github_pr")
    git = spy("git")
    allow(pr).to receive(:title).and_return("the pr title")
    sut = CiToolkit::Jira.new(pr, git, "lal|vv|thir|wig|td")
    expect(sut.ticket).to be_nil
  end
end
