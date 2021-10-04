# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::Build do
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

  it "provides a valid build url" do
    env = CiToolkit::BitriseEnv.new({ build_url: "https://the.build.url" })
    sut = described_class.new(double, env)
    expect(sut.url).to eq "https://the.build.url"
  end

  it "provides a valid build number" do
    env = CiToolkit::BitriseEnv.new({ build_number: 1234 })
    sut = described_class.new(double, env)
    expect(sut.number).to eq 1234
  end

  it "provides if build is a PR" do
    env = CiToolkit::BitriseEnv.new({ pull_request_number: 1234 })
    sut = described_class.new(double, env)
    expect(sut.from_pull_request?).to eq true
  end

  it "show that the build is not a PR if not specified" do
    env = CiToolkit::BitriseEnv.new
    sut = described_class.new(double, env)
    expect(sut.from_pull_request?).to eq false
  end

  it "provides if build is a cron job" do
    env = CiToolkit::BitriseEnv.new({ build_from_cron_job: true })
    sut = described_class.new(double, env)
    expect(sut.from_cron_job?).to eq true
  end

  it "provides show that the build is not a cron job if not specified" do
    env = CiToolkit::BitriseEnv.new
    sut = described_class.new(double, env)
    expect(sut.from_cron_job?).to eq false
  end

  it "provides if build is from develop" do
    env = CiToolkit::BitriseEnv.new({ git_branch: "develop" })
    git = CiToolkit::Git.new(nil, env)
    sut = described_class.new(git, double)
    expect(sut.from_develop?).to eq true
  end

  it "provides show that the build is not from develop if not specified" do
    git = CiToolkit::Git.new
    sut = described_class.new(git, double)
    expect(sut.from_develop?).to eq false
  end

  it "provides if build is from release" do
    env = CiToolkit::BitriseEnv.new({ git_branch: "release/1.1.1" })
    git = CiToolkit::Git.new(nil, env)
    sut = described_class.new(git, double)
    expect(sut.from_release?).to eq true
  end

  it "provides show that the build is not from release if not specified" do
    git = CiToolkit::Git.new
    sut = described_class.new(git, double)
    expect(sut.from_release?).to eq false
  end

  it "provides if build is from master" do
    env = CiToolkit::BitriseEnv.new({ git_branch: "master" })
    git = CiToolkit::Git.new(nil, env)
    sut = described_class.new(git, double)
    expect(sut.from_master?).to eq true
  end

  it "provides show that the build is not from master if not specified" do
    git = CiToolkit::Git.new
    sut = described_class.new(git, double)
    expect(sut.from_master?).to eq false
  end

  it "provides the version from a release branch" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("release/1.5")
    sut = described_class.new(git, double)
    expect(sut.version).to eq "1.5"
  end

  it "provides the version from the latest tag if the branch doesn't hold a valid version" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("feature/abc")
    allow(git).to receive(:latest_tag).and_return("1.2.3")
    sut = described_class.new(git, double)
    expect(sut.version).to eq "1.2.3"
  end

  it "throws an error if the version can't be found" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("feature/abc")
    allow(git).to receive(:latest_tag).and_return("tag")
    sut = described_class.new(git, double)
    expect { sut.version }.to raise_error StandardError
  end

  it "provides a build tag name by supplying the build number" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("release/1.2.3")
    sut = described_class.new(git, double)
    expect(sut.tag_name(1234)).to eq "1.2.3-build.1234"
  end

  it "provides a release tag without a build number" do
    git = instance_spy("git")
    allow(git).to receive(:branch).and_return("release/1.2.3")
    sut = described_class.new(git, double)
    expect(sut.tag_name).to eq "1.2.3"
  end
end
