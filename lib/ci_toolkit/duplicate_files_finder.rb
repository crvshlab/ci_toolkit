# frozen_string_literal: true

require "pathname"

module CiToolkit
  # Finds duplicate files based on md5 hash
  class DuplicateFilesFinder
    BASE_DIR = File.expand_path("./")

    def initialize(
      relative_search_path = nil,
      whitelisted_files = if File.exist?("duplicate_files_whitelist.txt")
                            File.readlines(
                              "duplicate_files_whitelist.txt",
                              chomp: true
                            )
                          else
                            []
                          end,
      excluded_dirs = ["vendor"]
    )
      @whitelisted_files = whitelisted_files || []
      @search_path = relative_search_path
      @excluded_dirs = excluded_dirs || []
      @duplicated_files = []
      duplicate_map = files_mapped_to_md5_checksum
      duplicate_map.each { |md5, duplicates| @duplicated_files << duplicates if duplicate_map[md5].count > 1 }
    end

    def duplicate_groups
      @duplicated_files
    end

    private

    def files_mapped_to_md5_checksum
      md5_file_map = {}
      all_files_in_project.each do |file|
        md5 = Digest::MD5.hexdigest(File.read(file))
        files = md5_file_map[md5] || (md5_file_map[md5] = [])
        relative_path = Pathname.new(file).relative_path_from(Pathname.new(BASE_DIR)).to_s
        files << relative_path unless @whitelisted_files.include?(relative_path)
      end
      md5_file_map
    end

    def all_files_in_project
      search_dir = ""
      search_dir = "#{@search_path}/" if @search_path
      puts "BASE_DIR: #{BASE_DIR}, search_dir: #{search_dir}"
      files = Dir.glob("#{BASE_DIR}/#{search_dir}**/*")
      puts "files1: #{files}"
      files.reject! do |f|
        File.symlink?(f) || File.directory?(f) || File.size?(f).nil?
      end
      puts "files2: #{files}"
      @excluded_dirs.each do |dir|
        files.reject! { |f| f[%r{#{dir}/}] }
      end
      files
    end
  end
end
