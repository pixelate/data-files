# frozen_string_literal: true

require_relative 'lib/data_files.rb'

unless Dir.exist?(File.join(Dir.pwd, 'data'))
  puts 'Could not find data directory in working directory.'
  exit
end

data_files = DataFiles.new(Dir.pwd)
data_files.prompt
