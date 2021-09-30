# frozen_string_literal: true

require "pathname"

module CiToolkit
  # Finds duplicate files based on md5 hash
  class DuplicateFilesFinder
    def initialize(
      relative_search_path = nil,
      whitelist_file = nil,
      exclusion_patterns = []
    )
      @base_dir = select_base_dir(relative_search_path)
      @whitelisted_files = create_whitelist_from_file(whitelist_file) || []
      @exclusion_patterns = exclusion_patterns || []
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
        relative_path = Pathname.new(file).relative_path_from(Pathname.new(@base_dir)).to_s
        files << relative_path unless @whitelisted_files.include?(relative_path)
      end
      md5_file_map
    end

    def all_files_in_project
      files = Dir.glob("#{@base_dir}/**/*")
      puts "Files after glob:\n#{files}"
      files.reject! do |f|
        !File.exist?(f) || File.symlink?(f) || File.directory?(f) || File.size?(f).nil?
      end
      @exclusion_patterns.each do |pattern|
        files.reject! { |f| f[/#{pattern}/] }
      end
      files
    end

    def select_base_dir(relative_search_path)
      if !relative_search_path.nil? && Dir.exist?(relative_search_path)
        File.expand_path(relative_search_path)
      else
        File.expand_path(Dir.pwd).gsub("/fastlane")
      end
    end

    def create_whitelist_from_file(whitelist_file)
      if !whitelist_file.nil? && File.exist?(whitelist_file)
        File.readlines(whitelist_file, chomp: true)
      elsif File.exist? "duplicate_files_whitelist.txt"
        File.readlines("duplicate_files_whitelist.txt", chomp: true)
      end
    end
  end
end
