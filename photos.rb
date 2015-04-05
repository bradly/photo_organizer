#!/usr/bin/env ruby

require 'fileutils'
require 'mini_exiftool'

IMPORT_DIR_PATH = '~/Pictures' # Change this to the directory of photos you want to import.
SORTED_DIR_PATH = '/Volumes/Untitled 1/sorted_photos' # Change this to the location of where you want your organized files

class PhotoOrganizer
  VALID_EXTENSIONS = %w(.jpg .jpeg .raw .mov)

  def initialize(import_dir_path, sorted_dir_path)
    @sorted_dir_path   = File.expand_path(sorted_dir_path)
    @import_dir_path   = File.expand_path(import_dir_path)
    @unsorted_dir_path = File.join(@sorted_dir_path, 'unsorted')
    assert_import_dir_path_exists!
    create_sort_dirs
  end

  def organize
    paths_for_import.each do |path|
      organize_path(path)
    end
  end

  private

  def assert_import_dir_path_exists!
    unless File.exists?(@import_dir_path)
      puts "#{@import_dir_path} not found"
      exit 1
    end
  end

  def create_sort_dirs
    begin
      FileUtils.mkdir_p @sorted_dir_path
    rescue Errno::EACCES
      puts "There was an error accessing #@sorted_dir_path. Please make sure you have permissions to the directory."
      exit 1
    end

    begin
      FileUtils.mkdir_p @unsorted_dir_path
    rescue Errno::EACCES
      puts "There was an error accessing #@unsorted_dir_path. Please make sure you have permissions to the directory."
      exit 1
    end
  end

  def paths_for_import
    Dir.glob(File.join(@import_dir_path, '**', '*'))
  end

  def organize_path(path)
    return unless importable?(path)

    create_date = exif_create_date(path)

    if create_date
      copy_file(path, destination_path(path, create_date))
    else
      move_to_unsorted(path)
    end
  end

  def importable?(path)
    extension = File.extname(path)
    VALID_EXTENSIONS.include?(extension.downcase)
  end

  def exif_create_date(path)
    timestamp = MiniExiftool.new(path).create_date

    if timestamp.nil? || timestamp == false || !timestamp.is_a?(Time)
      puts "Missing or invalid create_date for #{path} - #{timestamp}"
      return false
    end

    timestamp
  rescue => ex
    puts "#{ex.class} Error: Couldn't parse time for #{path}"
    return false
  end

  def destination_path(path, create_date)
    year, month = create_date.strftime('%Y'), create_date.strftime('%m')

    destination_base_path = File.join(@sorted_dir_path, year, month)

    FileUtils.mkdir_p(destination_base_path)
    File.join(destination_base_path, filename(path, create_date))
  end

  def copy_file(path, destination_path)
    if File.exists?(destination_path)
      puts "#{destination_path} already exists"
      return
    end

    puts "#{path} -> #{destination_path}"
    FileUtils.cp path, destination_path
  end

  def move_to_unsorted(path)
    destination_path = File.join(unsorted_dir_path, filename(path))
    copy_file(path, destination_path)
  end

  # filename format it {DATETIME}_{ORIGNIAL_FILENAME}.{FILE_SIZE_IN_BYTES}.{EXTENTION}
  # so img001.jpg would become 1981-07-22_05-44-23-000_img001.736289.jpg
  def filename(path, time = nil)
    name  = File.basename(path, '.*')
    #img001
    name << ".#{File.size(path)}#{File.extname(path)}"
    #img001.9378249837.jpg
    name.prepend("#{time.strftime('%F_%H-%M-%S-%L')}_") if time
    #2008-03-11_08-55-23-000_img001.9378249837.jpg
    name
  end
end

PhotoOrganizer.new(IMPORT_DIR_PATH, SORTED_DIR_PATH).organize
