require 'fileutils'

class PhotoOrganizer

  def initialize(import_base_path, sorted_base_path)
    @config = PhotoOrganizerConfig.new(import_base_path, sorted_base_path)
    create_sort_dirs
  end

  def organize_all
    file_paths_to_import.each do |path|
      PhotoOrganizerFile.new(path, @config).organize
    end
  end

  private
  def file_paths_to_import
    Dir.glob(File.join(@config.import_base_path, '**', '*'))
  end

  def create_sort_dirs
    FileUtils.mkdir_p @config.sorted_base_path
    FileUtils.mkdir_p @config.unsorted_base_path
  rescue Errno::EACCES
    @config.logger "There was an error accessing #{@config.sorted_base_path} or #{@config.unsorted_base_path}. Please make sure you have permissions to these directories."
    exit 1
  end

end
