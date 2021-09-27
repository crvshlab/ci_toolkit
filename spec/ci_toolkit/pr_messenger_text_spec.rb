# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::PrMessengerText do
  env = CiToolkit::BitriseEnv.new({ build_number: 1234, build_url: "https://build.url" })
  build = CiToolkit::Build.new(nil, env)

  it "provides text for new build" do
    sut = described_class.new(build, env)
    expect(sut.for_new_build("Prod", "4006 latest prod", "4.3.1"))
      .to include "4006 latest prod", "4.3.1", build.url, build.number.to_s
  end

  it "provides text for build failure" do
    sut = described_class.new(build, env)
    expect(sut.for_build_failure("CI gods are not on your side")).to include "CI gods are not on your side"
  end

  it "provides text duplicated files report" do
    sut = described_class.new(build, env)
    expect(sut.for_duplicated_files_report("You have 2 duplicates")).to include "You have 2 duplicates",
                                                                                sut.duplicated_files_title
  end

  it "provides text lint report" do
    sut = described_class.new(build, env)
    expect(sut.for_lint_report("You have 30 lint violations")).to include "You have 30 lint violations",
                                                                          sut.lint_report_title
  end

  it "provides formatted footer" do
    sut = described_class.new(build, env)
    expect(sut.footer).to include "https://build.url", build.number.to_s, build.url
  end

  it "provides shortened body with text with more than 6 lines" do
    sut = described_class.new(build, env)
    expect(sut.body("1\n2\n3\n4\n5\n6\n7\n")).to include "1\n2\n3\n4\n5\n6\n7\n", "<summary>"
  end

  it "provides shortened body with given text" do
    sut = described_class.new(build, env)
    expect(sut.body("this is my text")).to include "this is my text"
  end

  it "provides duplicate files report" do
    finder = instance_spy("duplicate_files_finder")
    allow(finder).to receive(:duplicate_groups).and_return([%w[dup/at/path/to/file_b1 dup/at/path/to/file_b2]])
    sut = described_class.new(build, env)
    expect(sut.create_duplicate_files_report(finder)).to include "dup/at/path/to/file_b1\ndup/at/path/to/file_b2"
  end
end
