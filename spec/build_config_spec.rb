# frozen_string_literal: true

describe CiToolkit::BuildConfig do
  it "should provide the build number" do
    sut = CiToolkit::BuildConfig.new({ build_number: 12_345 })
    expect(sut.build_number).to eq 12_345
  end

  it "should provide the build url" do
    sut = CiToolkit::BuildConfig.new({ build_url: "https://theurlto.thebuild.com" })
    expect(sut.build_url).to eq "https://theurlto.thebuild.com"
  end

  it "should correctly show if build is for a pull request" do
    sut = CiToolkit::BuildConfig.new({}, true)
    expect(sut.for_pull_request?).to eq true
  end

  it "should correctly show if build is for a cron job" do
    sut = CiToolkit::BuildConfig.new({}, true, true)
    expect(sut.for_cron_job?).to eq true
  end
end
