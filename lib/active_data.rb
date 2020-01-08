# frozen_string_literal: true

# Base class for data querying and manipulation.
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

  def self.save_all
    item_attributes = all.map(&:strip).collect(&:attributes)

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

  def initialize(attrs = {})
    attrs.each { |key, value| send("#{key}=", value) }
  end

  def attributes
    attributes_hash = {}
    self.class.attributes.each do |attr|
      attributes_hash[attr] = send(attr) unless attr == 'id'
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
    attributes.each do |key, value|
      unless self.class.types[key].include?(value.class.name)
        @errors << validation_error_message(key, self.class.types[key])
      end
    end

    errors.size.zero?
  end

  def save
    return false unless valid?

    self.class.data = self.class.data.map do |item|
      if item['id'] == id
        attributes.merge(id: id)
      else
        item
      end
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

  def validation_error_message(attr, class_names)
    allowed_types = class_names.map do |class_name|
      class_name.gsub('Class', '').downcase
    end

    "#{attr} must be #{allowed_types.sort.join(', ')}".sub(/.*\K, /, ' or ')
  end
end
