require_relative "../lib/data_files/repl"

task :"data_files" do |t|
  unless Dir.exist?(File.join(Dir.pwd, 'data'))
    puts 'Could not find data directory in working directory.'
    exit
  end

  data_files = DataFiles::REPL.new(Dir.pwd)
  data_files.prompt
end
