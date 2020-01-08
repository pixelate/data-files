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

  def test_attributes
    attributes = Game.last.attributes
    assert attributes.is_a? Hash
    assert_equal 'Xenon 2: Megablast', attributes['title']
    assert_equal 'http://www.bitmap-brothers.co.uk/our-games/past/xenon2.htm', attributes['url']
    assert_equal 1989, attributes['year']
  end

  def test_strip
    game = Game.new(
      title: 'A Short History of the Gaze ',
      url: ' http://molleindustria.org/historyOfTheGaze/',
      year: 2016
    ).strip

    assert_equal 'A Short History of the Gaze', game.title
    assert_equal 'http://molleindustria.org/historyOfTheGaze/', game.url
    assert_equal 2016, game.year
  end

  def test_valid?
    game = Game.new
    refute game.valid?

    game.title = 'Future Unfolding'
    game.url = 'https://www.futureunfolding.com'
    game.year = 2000
    assert game.valid?

    game.title = nil
    game.url = 10
    game.year = 'Nineteen-Ninety-Nine'
    refute game.valid?
    assert game.errors.include?('title must be string')
    assert game.errors.include?('url must be nil or string')
    assert game.errors.include?('year must be integer or nil')

    list = List.new
    refute list.valid?

    list.title = '1991'
    list.user = 'andreaszecher'
    list.slug = '1991'
    list.ordered = false
    list.featured = true
    list.published_at = Date.new(2020, 1, 8)
    list.games = [
      { 'title' => 'Another World' },
      { 'title' => 'Commander Keen in Goodbye, Galaxy' }
    ]
    assert list.valid?

    list.ordered = nil
    list.games = 'Another World; Commander Keen in Goodbye, Galaxy'
    list.published_at = 'Monday'
    refute list.valid?
    assert list.errors.include?('ordered must be false or true')
    assert list.errors.include?('published_at must be date')
    assert list.errors.include?('games must be array')
  end
end
