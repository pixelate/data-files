# frozen_string_literal: true

module DataFiles
  # Provides attribute value autocompletion for the ActiveData methods where and find_by.
  class Autocompletion
    ALLOWED_METHODS = %w[where find_by'].freeze
    REGEX_OPENING_PARENTHESIS_OR_WHITESPACE = /\(|\s/.freeze

    ParsedInput = Struct.new(:klass_name, :method_name, :attribute_name, :attribute_value) do
      def valid?
        klass_name && method_name && attribute_name
      end
    end

    def initialize
      Readline.completion_append_character = ''
      Readline.completion_proc = proc do
        parsed = parse_input(Readline.line_buffer)

        if parsed.valid?
          suggestions(
            parsed.klass_name,
            parsed.method_name,
            parsed.attribute_name,
            parsed.attribute_value
          )
        else
          []
        end
      end
    end

    def parse_input(input)
      klass_name, remainder = input.split('.')
      method_name, attribute_name, attribute_value = remainder&.split(REGEX_OPENING_PARENTHESIS_OR_WHITESPACE)

      klass_name = klass_name&.split('=')&.last&.strip
      attribute_name = attribute_name&.sub(':', '')&.strip
      attribute_value = attribute_value&.sub('"', '')&.sub('\'', '')

      ParsedInput.new(klass_name, method_name, attribute_name, attribute_value)
    end

    def suggestions(klass_name, method_name, attribute_name, attribute_value)
      return [] unless Object.const_defined?(klass_name)
      return [] unless ALLOWED_METHODS.include?(method_name)

      values = Object.const_get(klass_name).data.collect do |item|
        item[attribute_name]
      end

      if attribute_value
        values.select { |value| value.to_s.start_with?(attribute_value) }
      else
        values
      end
    end
  end
end
