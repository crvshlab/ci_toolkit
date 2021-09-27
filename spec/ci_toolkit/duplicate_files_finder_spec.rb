# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::DuplicateFilesFinder do
  it "finds duplicate files" do
    `echo "This is the text" >> lib/test.txt`
    `echo "This is the text" >> lib/test1.txt`
    sut = described_class.new("lib")
    expect(sut.duplicate_groups.length).to be 1
    `rm -rf lib/test.txt lib/test1.txt`
  end

  it "does not find duplicates" do
    sut = described_class.new
    expect(sut.duplicate_groups).to eq %w[]
  end

  it "does not find duplicates that are whitelisted" do
    `echo "This is the text" >> lib/whitelisted.txt`
    `echo "This is the text" >> lib/whitelisted1.txt`
    sut = described_class.new("lib")
    expect(sut.duplicate_groups).to eq %w[]
    `rm -rf lib/whitelisted.txt lib/whitelisted1.txt`
  end

  it "initializes with an empty whitelist if the duplicate_files_whitelist.txt does not exist" do
    whitelist = File.read("duplicate_files_whitelist.txt")
    `rm -rf duplicate_files_whitelist.txt`
    sut = described_class.new
    expect(sut.duplicate_groups).to eq %w[]
    File.write("duplicate_files_whitelist.txt", whitelist)
  end
end
