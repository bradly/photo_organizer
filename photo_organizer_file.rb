require 'fileutils'
require_relative 'photo_organizer_date_extractor'

class PhotoOrganizerFile < File

  VALID_EXTENSIONS = %w(.jpg .jpeg .raw .mov).freeze

  def initialize(path, config)
    @config = config
    super(path)
  end

  def organize
    return false unless importable?
    create_date ? move_to_sorted : move_to_unsorted
  end

  # 2008-03-11_08-55-23-000_img001.9378249837.jpg
  def new_filename
    name = basename('.*') + '.' + size.to_s + extname
    name.prepend(create_date.strftime('%F_%H-%M-%S-%L') + '_') if create_date
    name
  end

  def sorted_destination_path
    year, month = create_date.strftime('%Y'), create_date.strftime('%m')
    File.join(@config.destination_base_path(year, month), new_filename)
  end

  def move_to_sorted
    year, month = create_date.strftime('%Y'), create_date.strftime('%m')
    FileUtils.mkdir_p(@config.destination_base_path(year, month))
    copy_to sorted_destination_path
  end

  def move_to_unsorted
    unsorted_destination_path = File.join(@config.unsorted_base_path, new_filename)
    copy_to unsorted_destination_path
  end

  def copy_to(destination_path)
    if File.exists?(destination_path)
      @config.logger "#{destination_path} already exists"
      return false
    end

    @config.logger "#{path} -> #{destination_path}"
    FileUtils.cp(path, destination_path) unless DEBUG
  end

  def importable?
    VALID_EXTENSIONS.include?(self.extname.downcase)
  end

  def create_date
    return @create_date unless @create_date.nil?
    @create_date = PhotoOrganizerDateExtractor.new(path, @config).create_date
  end

  def basename(*args)
    self.class.send(__method__, self.path, *args)
  end

  def extname(*args)
    self.class.send(__method__, self.path, *args)
  end

end
