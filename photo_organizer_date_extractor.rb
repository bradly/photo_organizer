require 'mini_exiftool'

class PhotoOrganizerDateExtractor < File

  def initialize(path, config)
    @path   = path
    @config = config
  end

  def create_date
    verify_type extract_date
  end

  def extract_date
    date = MiniExiftool.new(@path).create_date
  rescue => ex
    @config.logger "#{ex.class} Error: Couldn't parse time for #{@path}"
    return false
  end

  def verify_type(date)
    unless date && date.is_a?(Time)
      @config.logger "Missing or invalid create_date for #{@path} - #{date.class} #{date}"
      return false
    end
    date
  end

end
