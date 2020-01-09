# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/data-files/repl.rb'

class ActiveDataTest < Minitest::Test
  def setup
    DataFiles::REPL.new(File.join(Dir.pwd))
  end

  def teardown
    Object.send(:remove_const, 'Game')
    Object.send(:remove_const, 'List')
  end

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

  def test_find_by
    assert_equal 'Firewatch', Game.find_by(title: 'Firewatch').title
    assert_nil Game.find_by(title: 'Non-exisitant')
  end

  def test_sort_by_primary_key
    Game.data.shuffle!
    Game.sort_by_primary_key
    assert_equal 'A Light In Chorus', Game.first.title
    assert_equal 'Xenon 2: Megablast', Game.last.title
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

  def test_unique_primary_key_validation_for_new_item
    game = Game.new(title: 'A Light In Chorus')
    refute game.valid?
    assert game.errors.include?('Game with title A Light In Chorus already exists')
  end

  def test_unique_primary_key_validation_for_existing_item
    game = Game.last
    game.title = 'A Light In Chorus'
    refute game.valid?
    assert game.errors.include?('Game with title A Light In Chorus already exists')
  end

  def test_save
    Game.stub :write_yaml, true do
      assert_equal 10, Game.all.count

      game = Game.new(title: 'Super Mario Maker 2')
      game.save

      assert_equal 11, Game.all.count
      assert_includes Game.data.collect { |item| item['title'] }, 'Super Mario Maker 2'

      game.year = 2019
      game.save

      assert_equal 11, Game.all.count
      assert_equal 2019, Game.find_by(title: 'Super Mario Maker 2').year

      invalid_game = Game.new
      invalid_game.save
      assert invalid_game.errors.any?
      assert_equal 11, Game.all.count
    end
  end
end
