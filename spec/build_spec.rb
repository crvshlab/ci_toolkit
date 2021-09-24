# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::Build do
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  it "should provide a valid build url" do
    config = CiToolkit::BuildConfig.new({ build_url: "https://the.build.url" })
    sut = CiToolkit::Build.new(double, config)
    expect(sut.url).to eq "https://the.build.url"
  end

  it "should provide a valid build number" do
    config = CiToolkit::BuildConfig.new({ build_number: 1234 })
    sut = CiToolkit::Build.new(double, config)
    expect(sut.number).to eq 1234
  end

  it "should provide if build is a PR" do
    config = CiToolkit::BuildConfig.new({ build_number: 1234 }, true)
    sut = CiToolkit::Build.new(double, config)
    expect(sut.from_pull_request?).to eq true
  end

  it "should provide show that the build is not a PR if not specified" do
    config = CiToolkit::BuildConfig.new
    sut = CiToolkit::Build.new(double, config)
    expect(sut.from_pull_request?).to eq false
  end

  it "should provide if build is a cron job" do
    config = CiToolkit::BuildConfig.new(nil, nil, true)
    sut = CiToolkit::Build.new(double, config)
    expect(sut.from_cron_job?).to eq true
  end

  it "should provide show that the build is not a cron job if not specified" do
    config = CiToolkit::BuildConfig.new
    sut = CiToolkit::Build.new(double, config)
    expect(sut.from_cron_job?).to eq false
  end

  it "should provide if build is from develop" do
    git = CiToolkit::Git.new(nil, "develop")
    sut = CiToolkit::Build.new(git, double)
    expect(sut.from_develop?).to eq true
  end

  it "should provide show that the build is not from develop if not specified" do
    git = CiToolkit::Git.new
    sut = CiToolkit::Build.new(git, double)
    expect(sut.from_develop?).to eq false
  end

  it "should provide if build is from release" do
    git = CiToolkit::Git.new(nil, "release/1.1.1")
    sut = CiToolkit::Build.new(git, double)
    expect(sut.from_release?).to eq true
  end

  it "should provide show that the build is not from release if not specified" do
    git = CiToolkit::Git.new
    sut = CiToolkit::Build.new(git, double)
    expect(sut.from_release?).to eq false
  end

  it "should provide if build is from master" do
    git = CiToolkit::Git.new(nil, "master")
    sut = CiToolkit::Build.new(git, double)
    expect(sut.from_master?).to eq true
  end

  it "should provide show that the build is not from master if not specified" do
    git = CiToolkit::Git.new
    sut = CiToolkit::Build.new(git, double)
    expect(sut.from_master?).to eq false
  end
end
