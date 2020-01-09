# frozen_string_literal: true

# Base class for data querying and manipulation.
module DataFiles
  class ActiveData
    attr_reader :errors

    def self.all
      data.collect do |item|
        new(item)
      end
    end

    def self.first
      new(data.first)
    end

    def self.last
      new(data.last)
    end

    def self.where(conditions)
      all.select do |item|
        selected = true
        conditions.each do |key, value|
          selected = false if item.send(key) != value
        end
        selected
      end
    end

    def self.find_by(conditions)
      results = where(conditions)
      if results.size.positive?
        results.first
      else
        nil
      end
    end

    def self.save_all
      sort_by_primary_key
      item_attributes = all.collect(&:attributes)

      File.open("data/#{name.downcase}s.yml", 'w') do |file|
        file.write(item_attributes.to_yaml)
      end
    end

    def self.data
      class_variable_get(:@@data)
    end

    def self.data=(value)
      class_variable_set(:@@data, value)
    end

    def self.attributes
      class_variable_get(:@@attributes)
    end

    def self.types
      class_variable_get(:@@types)
    end

    def self.sort_by_primary_key
      self.data = data.sort_by do |item|
        primary_key_value = item.values.first
        if primary_key_value.is_a? String
          primary_key_value.downcase
        else
          primary_key_value
        end
      end
    end

    def initialize(attrs = {})
      attrs.each { |key, value| send("#{key}=", value) }
    end

    def attributes
      attributes_hash = {}
      self.class.attributes.each do |attr|
        attributes_hash[attr] = send(attr) unless attr == '_id'
      end
      attributes_hash
    end

    def to_s
      joined_attributes = self.class.attributes.collect do |attr|
        val = send(attr)
        val = "\"#{val}\"" if val.is_a? String
        "#{attr}: #{val.nil? ? 'nil' : val}"
      end.join(', ')

      "#<#{self.class} #{joined_attributes}>"
    end

    def inspect
      to_s
    end

    def valid?
      @errors = []

      primary_key = self.class.attributes.first
      primary_key_values = self.class.data.collect do |item|
        { item['_id'] => item[primary_key] }
      end

      primary_key_values.each do |item|
        item.each do |key, value|
          if key != @_id && value == send(primary_key)
            @errors << "#{self.class.name} with #{primary_key} #{send(primary_key)} already exists"
          end
        end
      end

      attributes.each do |key, value|
        unless self.class.types[key].include?(value.class.name)
          @errors << type_validation_error_message(key, self.class.types[key])
        end
      end

      @errors.size.zero?
    end

    def save
      return false unless valid?

      strip

      self.class.data = self.class.data.map do |item|
        if item['_id'] == @_id
          attributes.merge('_id' => @_id)
        else
          item
        end
      end

      if @_id.nil?
        @_id = next_id
        self.class.data << attributes.merge('_id' => @_id)
      end

      self.class.save_all
      true
    end

    def strip
      self.class.attributes.each do |attr|
        send("#{attr}=", send(attr).strip) if send(attr).is_a? String
      end
      self
    end

    private

    def type_validation_error_message(attr, class_names)
      allowed_types = class_names.map do |class_name|
        class_name.gsub('Class', '').downcase
      end

      "#{attr} must be #{allowed_types.sort.join(', ')}".sub(/.*\K, /, ' or ')
    end

    def next_id
      self.class.data.collect { |item| item['_id'] }.compact.max + 1
    end
  end
end
