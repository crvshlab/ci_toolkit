# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::AppConfig do
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

  it "provides the xcodeproj filename" do
    sut = described_class.new
    expect(sut.xcode_project_filename).to eq "SmartLife.xcodeproj"
  end

  it "provides the xcworkspace filename" do
    sut = described_class.new
    expect(sut.xc_workspace_filename).to eq "SmartLife.xcworkspace"
  end

  it "provides the xcarchive filename" do
    sut = described_class.new
    expect(sut.xc_archive_filename).to eq "SmartLife.xcarchive"
  end

  it "provides the ipa filename" do
    sut = described_class.new
    expect(sut.ipa_filename).to eq "SmartApp.ipa"
  end

  it "provides the dSYM zip filename" do
    sut = described_class.new
    expect(sut.dsym_zip_filename).to eq "SmartApp.app.dSYM.zip"
  end

  it "provides the version from a release branch" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("release/1.5")
    sut = described_class.new("SmartApp", "SmartLife", git)
    expect(sut.version).to eq "1.5"
  end

  it "provides the version from the latest tag if the branch doesn't hold a valid version" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("feature/abc")
    allow(git).to receive(:latest_tag).and_return("1.2.3")
    sut = described_class.new("SmartApp", "SmartLife", git)
    expect(sut.version).to eq "1.2.3"
  end

  it "throws an error if the version can't be found" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("feature/abc")
    allow(git).to receive(:latest_tag).and_return("tag")
    sut = described_class.new("SmartApp", "SmartLife", git)
    expect { sut.version }.to raise_error StandardError
  end

  it "provides a build tag name by supplying the build number" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("release/1.2.3")
    sut = described_class.new("SmartApp", "SmartLife", git)
    expect(sut.tag_name(1234)).to eq "1.2.3-build.1234"
  end

  it "provides a release tag without a build number" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("release/1.2.3")
    sut = described_class.new("SmartApp", "SmartLife", git)
    expect(sut.tag_name).to eq "1.2.3"
  end
end
