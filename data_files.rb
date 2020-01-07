# frozen_string_literal: true

require_relative 'lib/data_files.rb'

MIDDLEMAN_DIRECTORY = '/Users/andreaszecher/Projects/polylists-static'
data_files = DataFiles.new(MIDDLEMAN_DIRECTORY)
data_files.prompt
