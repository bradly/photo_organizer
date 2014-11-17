#!/usr/bin/env ruby
import_dir_path = '~/Desktop/PrintResolution'

class PhotoOrganizer
  require 'fileutils'
  require 'mini_exiftool'

  VALID_EXTENSIONS = %w(jpg jpeg raw mov avi)

  def initialize(import_dir_path)
    @import_dir_path = File.expand_path(import_dir_path)

    unless File.exists?(@import_dir_path)
      puts "#{@import_dir_path} not found"
      exit 1
    end

    @sorted_dir_path = File.expand_path('/Volumes/Untitled/sorted_photos')
  end

  def organize
    maybe_create_sort_dir

    #Dir.foreach(@import_dir_path) do |path|
    @skip = true
    Dir.glob(File.join(@import_dir_path, '**', '*')) do |path|
      #@skip = false if path.match('Picks/sc007d21f4')
      #next if @skip
      organize_path(path)
    end
  end

  def organize_path(path)
    return unless importable?(path)

    begin
      exif = MiniExiftool.new path
      create_date = exif.create_date
      if create_date.nil?
        puts "No create date for #{path}"
        move_to_unsorted(path)
        return 
      end

      if create_date == false
        puts "Create date false #{path}"
        move_to_unsorted(path)
        return 
      end
    rescue => ex
      puts "Error: #{ex.class.to_s} #{path}"
      return
    end

    begin
      year = create_date.year.to_s
      month = create_date.strftime('%m')
    rescue => ex
      puts "Error: Couldn't parse time for #{create_date} - #{ex.class.to_s} #{path}"
      move_to_unsorted(path)
      return
    end

    destination_base_path = File.join(@sorted_dir_path, year, month)
    FileUtils.mkdir_p destination_base_path
    destination_path = File.join(destination_base_path, filename(path, create_date))

    if File.exists?(destination_path)
      puts "#{destination_path} already exists"
      return
    end

    puts "#{path} -> #{destination_path}"

    #puts "FileUtils.cp #{path}, #{destination_path}"
    FileUtils.cp path, destination_path
  end

  def move_to_unsorted(path)

  def filename(path, time)
    size = File.size(path)
    parts = path.split('/')[-1].split('.')

    new_parts  = parts[0..-2]
    new_parts << size
    new_parts << parts[-1]

    base_name = new_parts.join('.')

    "#{time.strftime('%F_%H-%M-%S-%L')}_#{base_name}"
  end

  def importable?(path)
    path != '.' &&
      path != '..' &&
      self.class::VALID_EXTENSIONS.include?(path_extension(path))
  end

  def path_extension(path)
    path.split('.').last.downcase
  end

  def maybe_create_sort_dir
    FileUtils.mkdir_p @sorted_dir_path
    FileUtils.mkdir_p unsorted_dir_path
  end

  def unsorted_dir_path
    @unsorted_dir_path ||= File.join(@sorted_dir_path, 'unsorted')
  end

end

#import_dir_path = ARGV[1] || '~/Pictures'
#import_dir_path = ARGV[1] || '~/dreamhost/backups/Modified'
#import_dir_path = '/Volumes/Untitled/Pictures'
puts "import dir path: #{import_dir_path}"

photo_organizer = PhotoOrganizer.new(import_dir_path)
photo_organizer.organize
