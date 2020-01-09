# frozen_string_literal: true

require 'date'
require 'readline'
require 'yaml'
require_relative 'active_data.rb'

# Loads all yaml files in given directory, creates ActiveData subclass
# for each file and provides an interactive shell.
module DataFiles
  class REPL
    def initialize(directory)
      @klass_names = []
      parse_data(directory)
    end

    def parse_data(directory)
      Dir.foreach(File.join(directory, 'data')) do |filename|
        next unless filename.end_with?('.yml')

        filepath = File.join(directory, 'data', filename)
        key = File.basename(filepath, File.extname(filepath))
        data = load_yaml(filepath)

        klass_name = key.capitalize.delete_suffix('s')
        create_class(klass_name, data)
      end
    end

    def create_class(klass_name, data)
      @klass_names << klass_name

      types = parse_types(data)
      klass = Class.new(ActiveData) do
        class_variable_set(:@@data, data)
        class_variable_set(:@@attributes, data.first.keys)
        class_variable_set(:@@types, types)
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

    private

    def load_yaml(filepath)
      YAML
        .safe_load(File.read(filepath), [Date])
        .map
        .each_with_index { |item, index| item.merge('_id' => index + 1) }
    end

    def parse_types(data)
      types = {}
      data.first.keys.each do |attr|
        types[attr] = data.collect { |item| item[attr].class.name }
        types[attr] << 'TrueClass' if types[attr].include?('FalseClass')
        types[attr] << 'FalseClass' if types[attr].include?('TrueClass')
        types[attr].uniq!
      end
      types
    end
  end
end
