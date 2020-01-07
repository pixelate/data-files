# frozen_string_literal: true

# Base class for data querying and manipulation.
class ActiveData
  def self.all
    data
  end

  def self.first
    data.first
  end

  def self.last
    data.last
  end

  def self.data
    class_variable_get(:@@data)
  end
end
