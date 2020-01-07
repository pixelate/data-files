# frozen_string_literal: true

# Base class for data querying and manipulation.
class ActiveData
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

  def self.data
    class_variable_get(:@@data)
  end

  def self.attributes
    class_variable_get(:@@attributes)
  end

  def initialize(attrs = {})
    attrs.each { |key, value| send("#{key}=", value) }
  end

  def to_s
    joined_attributes = self.class.attributes.collect do |attr|
      val = send(attr)
      val = "\"#{val}\"" if val.is_a? String
      "#{attr}: #{val || 'nil'}"
    end.join(', ')

    "#<#{self.class} #{joined_attributes}>"
  end

  def inspect
    to_s
  end
end
