# frozen_string_literal: true

describe CiToolkit::BuildConfig do
  it "provides the build number" do
    sut = described_class.new({ build_number: 12_345 })
    expect(sut.build_number).to eq 12_345
  end

  it "provides the build url" do
    sut = described_class.new({ build_url: "https://theurlto.thebuild.com" })
    expect(sut.build_url).to eq "https://theurlto.thebuild.com"
  end

  it "correctlies show if build is for a pull request" do
    sut = described_class.new({}, true)
    expect(sut.for_pull_request?).to eq true
  end

  it "correctlies show if build is for a cron job" do
    sut = described_class.new({}, true, true)
    expect(sut.for_cron_job?).to eq true
  end
end
