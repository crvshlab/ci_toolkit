# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::Build do
  it "provides a valid build url" do
    config = CiToolkit::BuildConfig.new({ build_url: "https://the.build.url" })
    sut = described_class.new(double, config)
    expect(sut.url).to eq "https://the.build.url"
  end

  it "provides a valid build number" do
    config = CiToolkit::BuildConfig.new({ build_number: 1234 })
    sut = described_class.new(double, config)
    expect(sut.number).to eq 1234
  end

  it "provides if build is a PR" do
    config = CiToolkit::BuildConfig.new({ build_number: 1234 }, true)
    sut = described_class.new(double, config)
    expect(sut.from_pull_request?).to eq true
  end

  it "provides show that the build is not a PR if not specified" do
    config = CiToolkit::BuildConfig.new
    sut = described_class.new(double, config)
    expect(sut.from_pull_request?).to eq false
  end

  it "provides if build is a cron job" do
    config = CiToolkit::BuildConfig.new(nil, nil, true)
    sut = described_class.new(double, config)
    expect(sut.from_cron_job?).to eq true
  end

  it "provides show that the build is not a cron job if not specified" do
    config = CiToolkit::BuildConfig.new
    sut = described_class.new(double, config)
    expect(sut.from_cron_job?).to eq false
  end

  it "provides if build is from develop" do
    git = CiToolkit::Git.new(nil, "develop")
    sut = described_class.new(git, double)
    expect(sut.from_develop?).to eq true
  end

  it "provides show that the build is not from develop if not specified" do
    git = CiToolkit::Git.new
    sut = described_class.new(git, double)
    expect(sut.from_develop?).to eq false
  end

  it "provides if build is from release" do
    git = CiToolkit::Git.new(nil, "release/1.1.1")
    sut = described_class.new(git, double)
    expect(sut.from_release?).to eq true
  end

  it "provides show that the build is not from release if not specified" do
    git = CiToolkit::Git.new
    sut = described_class.new(git, double)
    expect(sut.from_release?).to eq false
  end

  it "provides if build is from master" do
    git = CiToolkit::Git.new(nil, "master")
    sut = described_class.new(git, double)
    expect(sut.from_master?).to eq true
  end

  it "provides show that the build is not from master if not specified" do
    git = CiToolkit::Git.new
    sut = described_class.new(git, double)
    expect(sut.from_master?).to eq false
  end
end
