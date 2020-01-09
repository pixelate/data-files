# REPL for Middleman Data Files

Written during Lab Week in January 2020 at Mynewsdesk.

This interactive shell allows users to manipulate [Middleman Data Files](https://middlemanapp.com/advanced/data-files/) with an API similar to ActiveRecord.

## Querying data

Given a file located in `data/games.yml` in a Middleman project directory, we can query our data in different ways:

```ruby
> Game.first
#<Game title: "A Light In Chorus", url: "http://www.alightinchorus.com", year: nil, _id: 1>

> Game.last
#<Game title: "Xenon 2: Megablast", url: "http://www.bitmap-brothers.co.uk/our-games/past/xenon2.htm", year: 1989, _id: 11>

> Game.find_by(title: "Another World")
#<Game title: "Another World", url: "http://www.anotherworld.fr/anotherworld_uk/", year: 1991, _id: 4>
  
> Game.where(year: 1991)
[#<Game title: "Another World", url: "http://www.anotherworld.fr/anotherworld_uk/", year: 1991, _id: 4>, #<Game title: "Commander Keen in Goodbye, Galaxy", url: "http://legacy.3drealms.com/keen4/", year: 1991, _id: 7>]

> Game.all.count
10
```

The internal `_id` attribute is ephemeral and can change between different sessions. It is not saved to the YAML file. It can however be used for querying:

```ruby
> Game.find_by(_id: 12)
#<Game title: "Super Mario Maker 2", url: "https://www.nintendo.com/games/detail/super-mario-maker-2-switch/", year: 2019, _id: 12>
```

## Creating new data

We can add new items to our data file:

```ruby
> game = Game.new(title: "Super Mario Maker 2", year: 2019, url: "https://www.nintendo.com/games/detail/super-mario-maker-2-switch/")
#<Game title: "Super Mario Maker 2", url: "https://www.nintendo.com/games/detail/super-mario-maker-2-switch/", year: 2019, _id: nil>

> game.save
true

> game
#<Game title: "Super Mario Maker 2", url: "https://www.nintendo.com/games/detail/super-mario-maker-2-switch/", year: 2019, _id: 12>
```

## Normalizing data

Items will ordered in the YAML file by their primary key. The first key in the array in the YAML file is considered the primary key.

In our example the primary key is `title`:

```yaml
---
- title: A Light In Chorus
  url: http://www.alightinchorus.com
  year: 
```

Leading and trailing whitespace is automatically removed from string attributes on `save`:

```ruby
> game = Game.new(title: " Bubble Bobble ")
#<Game title: " Bubble Bobble ", url: nil, year: nil, _id: nil>

> game.save
true

> game
#<Game title: "Bubble Bobble", url: nil, year: nil, _id: 11>
```
