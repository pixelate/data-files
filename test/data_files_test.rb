# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/data_files.rb'

class ActiveDataTest < Minitest::Test
  DataFiles.new(File.join(Dir.pwd, 'test'))

  def test_all
    all_games = Game.all
    assert_equal 10, all_games.count
    assert all_games.first.is_a? Game
  end

  def test_first
    game = Game.first
    assert game.is_a? Game
    assert_equal 'A Light In Chorus', game.title
    assert_equal 'http://www.alightinchorus.com', game.url
    assert_nil game.year
  end

  def test_last
    game = Game.last
    assert game.is_a? Game
    assert_equal 'Xenon 2: Megablast', game.title
    assert_equal 'http://www.bitmap-brothers.co.uk/our-games/past/xenon2.htm', game.url
    assert_equal 1989, game.year
  end

  def test_where
    assert_equal 2, Game.where(year: 1991).count
    assert_equal 1, Game.where(year: nil).count
    assert_equal 'Firewatch', Game.where(title: 'Firewatch', year: 2016).first.title
    assert_equal 0, Game.where(title: 'Firewatch', year: 2000).count
  end
end
