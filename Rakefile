require "bundler/gem_tasks"
require "rake/testtask"
require_relative "lib/data_files/repl"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :"data_files" do |t|
  unless Dir.exist?(File.join(Dir.pwd, 'data'))
    puts 'Could not find data directory in working directory.'
    exit
  end

  data_files = DataFiles::REPL.new(Dir.pwd)
  data_files.prompt
end
