require 'fileutils'

class PhotoOrganizerConfig

  attr_reader :sorted_base_path, :import_base_path, :unsorted_base_path

  def initialize(import_base_path, sorted_base_path)
    @sorted_base_path   = File.expand_path(sorted_base_path)
    @import_base_path   = File.expand_path(import_base_path)
    @unsorted_base_path = File.join(@sorted_base_path, 'unsorted')
    assert_import_base_path_exists!
  end

  def destination_base_path(year, month)
    File.join(@sorted_base_path, year, month)
  end

  def logger(message)
    puts "[Photo Organizer #{Time.now} #{DEBUG ? 'DEBUG' : ''}] #{message}"
  end

  private
  def assert_import_base_path_exists!
    unless File.exists?(@import_base_path)
      logger "#{@import_base_path} not found"
      exit 1
    end
  end

end
