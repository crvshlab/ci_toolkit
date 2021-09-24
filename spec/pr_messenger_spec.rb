# frozen_string_literal: true

require "ci_toolkit"

describe CiToolkit::PrMessenger do
  it "sends build deployed" do
    pr = instance_spy("github_pr")
    text = instance_spy("pr_messenger_text")
    sut = described_class.new(pr, text)
    sut.send_build_deployed("build name", "version name")
    expect(text).to have_received(:for_new_build).with("build name", "version name")
    expect(pr).to have_received(:comment)
  end

  it "sends ci failed" do
    pr = instance_spy("github_pr")
    text = instance_spy("pr_messenger_text")
    sut = described_class.new(pr, text)
    sut.send_ci_failed("failure reason")
    expect(text).to have_received(:for_build_failure).with("failure reason")
    expect(pr).to have_received(:comment)
  end

  it "sends duplicate files report" do
    pr = instance_spy("github_pr")
    text = instance_spy("pr_messenger_text")
    finder = double
    sut = described_class.new(pr, text)
    sut.send_duplicate_files_report(finder)
    expect(pr).to have_received(:delete_comment_containing_text)
    expect(text).to have_received(:create_duplicate_files_report).with(finder)
    expect(text).to have_received(:for_duplicated_files_report)
    expect(pr).to have_received(:comment)
  end

  it "deletes duplicate files report" do
    pr = instance_spy("github_pr")
    text = CiToolkit::PrMessengerText.new
    sut = described_class.new(pr, text)
    sut.delete_duplicate_files_report
    expect(pr).to have_received(:delete_comment_containing_text).with(text.duplicated_files_title)
  end

  it "sends the lint report" do
    pr = instance_spy("github_pr")
    text = instance_spy("pr_messenger_text")
    report = double
    sut = described_class.new(pr, text)
    sut.send_lint_report(report)
    expect(pr).to have_received(:delete_comment_containing_text)
    expect(text).to have_received(:for_lint_report).with(report)
    expect(pr).to have_received(:comment)
  end

  it "deletes the lint report" do
    pr = instance_spy("github_pr")
    text = CiToolkit::PrMessengerText.new
    sut = described_class.new(pr, text)
    sut.delete_lint_report
    expect(pr).to have_received(:delete_comment_containing_text).with(text.lint_report_title)
  end

  it "sends big PR warning" do
    pr = instance_spy("github_pr")
    text = instance_spy("pr_messenger_text")
    sut = described_class.new(pr, text)
    sut.send_big_pr_warning
    expect(pr).to have_received(:delete_comment_containing_text)
    expect(text).to have_received(:big_pr_warning_title).exactly(2).times
    expect(pr).to have_received(:comment)
  end

  it "deletes big PR warning" do
    pr = instance_spy("github_pr")
    text = CiToolkit::PrMessengerText.new
    sut = described_class.new(pr, text)
    sut.delete_big_pr_warning
    expect(pr).to have_received(:delete_comment_containing_text).with(text.big_pr_warning_title)
  end

  it "sends work in progress warning" do
    pr = instance_spy("github_pr")
    text = instance_spy("pr_messenger_text")
    sut = described_class.new(pr, text)
    sut.send_work_in_progress
    expect(pr).to have_received(:delete_comment_containing_text)
    expect(text).to have_received(:work_in_progress_title).exactly(2).times
    expect(pr).to have_received(:comment)
  end

  it "deletes big PR warning" do
    pr = instance_spy("github_pr")
    text = CiToolkit::PrMessengerText.new
    sut = described_class.new(pr, text)
    sut.delete_work_in_progress
    expect(pr).to have_received(:delete_comment_containing_text).with(text.work_in_progress_title)
  end
end
