#!/usr/bin/env ruby

require_relative 'photo_organizer'
require_relative 'photo_organizer_config'
require_relative 'photo_organizer_file'

IMPORT_DIR_PATH = '~/Pictures/Photos Library.photoslibrary/Masters' # Change this to the directory of photos you want to import.
SORTED_DIR_PATH = '/Volumes/Untitled/sorted_photos' # Change this to the location of where you want your organized files
DEBUG = false

PhotoOrganizer.new(IMPORT_DIR_PATH, SORTED_DIR_PATH).organize_all
