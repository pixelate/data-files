# frozen_string_literal: true

require 'readline'
require 'yaml'
require_relative 'active_data.rb'

# Loads all yaml files in given directory and creates ActiveData subclass
# for each file.
class DataFiles
  def initialize(directory)
    @klass_names = []
    load_yaml(directory)
  end

  def load_yaml(directory)
    Dir.foreach(File.join(directory, 'data')) do |filename|
      next unless filename.end_with?('.yml')

      filepath = File.join(directory, 'data', filename)
      key = File.basename(filepath, File.extname(filepath))
      data = YAML
        .safe_load(File.read(filepath))
        .map
        .each_with_index { |item, index| item.merge(id: index + 1) }

      klass_name = key.capitalize.delete_suffix('s')
      create_class(klass_name, data)
    end
  end

  def create_class(klass_name, data)
    @klass_names << klass_name
    klass = Class.new(ActiveData) do
      class_variable_set(:@@data, data)
      class_variable_set(:@@attributes, data.first.keys)
      attr_accessor(*data.first.keys)
    end

    Object.const_set(klass_name, klass)
  end

  def prompt
    initial_prompt
    read_input
  end

  def initial_prompt
    puts 'Available data models:'
    @klass_names.sort.each do |klass_name|
      puts " - #{klass_name}"
    end
  end

  def read_input
    bnd = binding
    while (input = Readline.readline('> ', true))
      begin
        puts bnd.eval(input).to_s
      rescue StandardError => e
        puts "\e[31m#{e.class}:\e[0m #{e.message}"
      end
    end
  end
end
