# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::AppConfig do
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

  it "should provide the xcodeproj filename" do
    sut = CiToolkit::AppConfig.new
    expect(sut.xcode_project_filename).to eq "SmartLife.xcodeproj"
  end

  it "should provide the xcworkspace filename" do
    sut = CiToolkit::AppConfig.new
    expect(sut.xc_workspace_filename).to eq "SmartLife.xcworkspace"
  end

  it "should provide the xcarchive filename" do
    sut = CiToolkit::AppConfig.new
    expect(sut.xc_archive_filename).to eq "SmartLife.xcarchive"
  end

  it "should provide the ipa filename" do
    sut = CiToolkit::AppConfig.new
    expect(sut.ipa_filename).to eq "SmartApp.ipa"
  end

  it "should provide the dSYM zip filename" do
    sut = CiToolkit::AppConfig.new
    expect(sut.dsym_zip_filename).to eq "SmartApp.app.dSYM.zip"
  end

  it "should provide the version from a release branch" do
    git = spy("git")
    allow(git).to receive(:branch).and_return("release/1.5")
    sut = CiToolkit::AppConfig.new("SmartApp", "SmartLife", git)
    expect(sut.version).to eq "1.5"
  end

  it "should provide the version from the latest tag if the branch doesn't hold a valid version" do
    git = spy("git")
    allow(git).to receive(:branch).and_return("feature/abc")
    allow(git).to receive(:latest_tag).and_return("1.2.3")
    sut = CiToolkit::AppConfig.new("SmartApp", "SmartLife", git)
    expect(sut.version).to eq "1.2.3"
  end

  it "should throw an error if the version can't be found" do
    git = spy("git")
    allow(git).to receive(:branch).and_return("feature/abc")
    allow(git).to receive(:latest_tag).and_return("tag")
    sut = CiToolkit::AppConfig.new("SmartApp", "SmartLife", git)
    expect { sut.version }.to raise_error StandardError
  end

  it "should provide a build tag name by supplying the build number" do
    git = spy("git")
    allow(git).to receive(:branch).and_return("release/1.2.3")
    sut = CiToolkit::AppConfig.new("SmartApp", "SmartLife", git)
    expect(sut.tag_name(1234)).to eq "1.2.3-build.1234"
  end

  it "should provide a release tag without a build number" do
    git = spy("git")
    allow(git).to receive(:branch).and_return("release/1.2.3")
    sut = CiToolkit::AppConfig.new("SmartApp", "SmartLife", git)
    expect(sut.tag_name).to eq "1.2.3"
  end
end
