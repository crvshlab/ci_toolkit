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
    sut = described_class.new("lib")
    expect(sut.duplicate_groups).to eq %w[]
  end

  it "does not find duplicates that are whitelisted" do
    `echo "This is the text" >> lib/whitelisted.txt`
    `echo "This is the text" >> lib/whitelisted1.txt`
    sut = described_class.new(".", nil, ["vendor"])
    expect(sut.duplicate_groups).to eq %w[]
    `rm -rf lib/whitelisted.txt lib/whitelisted1.txt`
  end

  it "initializes with an empty whitelist if whitelisted_files is empty" do
    sut = described_class.new(".", nil, ["vendor"])
    expect(sut.duplicate_groups).to eq %w[]
  end

  it "does not fail when excluded_dirs is nil" do
    expect { described_class.new(nil, nil, ["vendor"]) }.not_to raise_error
  end

  it "does handle an invalid whitelist.text" do
    expect { described_class.new(nil, "lib/whitelisting.txt", ["vendor"]) }.not_to raise_error
  end

  it "does load provided whitelist file" do
    expect { described_class.new(nil, "duplicate_files_whitelist.txt", ["vendor"]) }.not_to raise_error
  end

  it "does not fail whithout whitelist file" do
    whitelist = File.read("duplicate_files_whitelist.txt")
    `rm -rf duplicate_files_whitelist.txt`
    expect { described_class.new('.', "duplicate_files_whitelist.txt", ["vendor"]) }.not_to raise_error
    `echo #{whitelist} >> duplicate_files_whitelist.txt`
  end
end
