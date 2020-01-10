# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/data_files/autocompletion.rb'

class AutocompletionTest < Minitest::Test
  def setup
    @autocompletion = DataFiles::Autocompletion.new
  end

  def test_parse_input_with_assignment
    parsed = @autocompletion.parse_input('game = Game.where(title: "Fire')
    assert parsed.valid?
    assert_equal 'Game', parsed.klass_name
    assert_equal 'where', parsed.method_name
    assert_equal 'title', parsed.attribute_name
    assert_equal 'Fire', parsed.attribute_value
  end

  def test_parse_input_with_value_with_parenthesis_with_double_quotes
    parsed = @autocompletion.parse_input('Game.where(title: "Fire')
    assert parsed.valid?
    assert_equal 'Game', parsed.klass_name
    assert_equal 'where', parsed.method_name
    assert_equal 'title', parsed.attribute_name
    assert_equal 'Fire', parsed.attribute_value
  end

  def test_parse_input_with_value_without_parenthesis_with_double_quotes
    parsed = @autocompletion.parse_input('Game.where title: "Fire')
    assert parsed.valid?
    assert_equal 'Game', parsed.klass_name
    assert_equal 'where', parsed.method_name
    assert_equal 'title', parsed.attribute_name
    assert_equal 'Fire', parsed.attribute_value
  end

  def test_parse_input_with_value_with_parenthesis_with_single_quotes
    parsed = @autocompletion.parse_input('Game.where(title: \'Fire')
    assert parsed.valid?
    assert_equal 'Game', parsed.klass_name
    assert_equal 'where', parsed.method_name
    assert_equal 'title', parsed.attribute_name
    assert_equal 'Fire', parsed.attribute_value
  end

  def test_parse_input_with_value_without_parenthesis_with_single_quotes
    parsed = @autocompletion.parse_input('Game.where title: \'Fire')
    assert parsed.valid?
    assert_equal 'Game', parsed.klass_name
    assert_equal 'where', parsed.method_name
    assert_equal 'title', parsed.attribute_name
    assert_equal 'Fire', parsed.attribute_value
  end

  def test_parse_input_with_parenthesis
    parsed = @autocompletion.parse_input('Game.where(title: ')
    assert parsed.valid?
    assert_equal 'Game', parsed.klass_name
    assert_equal 'where', parsed.method_name
    assert_equal 'title', parsed.attribute_name
    assert_nil parsed.attribute_value
  end

  def test_parse_input_without_parenthesis
    parsed = @autocompletion.parse_input('Game.where title: ')
    assert parsed.valid?
    assert_equal 'Game', parsed.klass_name
    assert_equal 'where', parsed.method_name
    assert_equal 'title', parsed.attribute_name
    assert_nil parsed.attribute_value
  end

  def test_parse_input_klass_and_method_only
    parsed = @autocompletion.parse_input('Game.where')
    refute parsed.valid?
    assert_equal 'Game', parsed.klass_name
    assert_equal 'where', parsed.method_name
    assert_nil parsed.attribute_name
    assert_nil parsed.attribute_value
  end

  def test_parse_input_klass_only
    parsed = @autocompletion.parse_input('Game')
    refute parsed.valid?
    assert_equal 'Game', parsed.klass_name
    assert_nil parsed.method_name
    assert_nil parsed.attribute_name
    assert_nil parsed.attribute_value
  end
end
