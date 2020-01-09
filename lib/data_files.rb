# frozen_string_literal: true

require_relative 'data-files/repl.rb'

unless Dir.exist?(File.join(Dir.pwd, 'data'))
  puts 'Could not find data directory in working directory.'
  exit
end

data_files = DataFiles::REPL.new(Dir.pwd)
data_files.prompt
