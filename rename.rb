#!/usr/bin/env ruby

require 'fileutils'
require 'mini_exiftool'

@sorted_dir_path = File.expand_path('/Volumes/Untitled/sorted_photos')

VALID_EXTENSIONS = %w(jpg jpeg raw mov avi)

Dir.glob(File.join(@sorted_dir_path, '**', '*')) do |path|
  next unless VALID_EXTENSIONS.include?(path.split('.')[-1].downcase)
  next if path.split('/')[-1][0..1] == '20'

  exif = MiniExiftool.new path
  create_date = exif.create_date

  next if create_date.nil?

  parts = path.split('/')

  new_parts  = parts[0..-2]
  new_parts << "#{create_date.strftime('%F_%H-%M-%S-%L')}_#{parts[-1]}"

  new_path = new_parts.join('/')
  puts new_path
  FileUtils.mv(path, new_path)
end
