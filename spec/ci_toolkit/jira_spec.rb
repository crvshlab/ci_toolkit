# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::Jira do
  it "provides a valid ticket" do
    pr = instance_spy("github_pr")
    git = instance_spy("git")
    allow(pr).to receive(:title).and_return("[LAL-123] the pr title")
    sut = described_class.new(pr, git, "lal|vv|thir|wig|td")
    expect(sut.ticket).to eq "LAL-123"
  end

  it "ticket should be nil if none exists" do
    pr = instance_spy("github_pr")
    git = instance_spy("git")
    allow(pr).to receive(:title).and_return("the pr title")
    sut = described_class.new(pr, git, "lal|vv|thir|wig|td")
    expect(sut.ticket).to be_nil
  end
end
