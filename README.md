# REPL for Middleman Data Files

Written during Lab Week in January 2020 at Mynewsdesk.

This interactive shell allows users to manipulate [Middleman Data Files](https://middlemanapp.com/advanced/data-files/) with an API similar to ActiveRecord.

Given a file located in `data/games.yml` in a Middleman project directory, we can query our data in different ways:

```
> Game.first
#<Game title: "1001 Spikes", url: "https://www.nicalis.com/games/1001spikes", year: 2014, id: 1>

> Game.last
#<Game title: "Zip Zap", url: "http://www.kamibox.de/zipzap", year: 2016, id: 440>

> Game.find_by(title: "Another World")
#<Game title: "Another World", url: "http://www.anotherworld.fr/anotherworld_uk/", year: 1991, id: 32>
  
> Game.where(year: 1991)
[#<Game title: "Another World", url: "http://www.anotherworld.fr/anotherworld_uk/", year: 1991, id: 4>, #<Game title: "Commander Keen in Goodbye, Galaxy", url: "http://legacy.3drealms.com/keen4/", year: 1991, id: 6>]

> Game.all.count
10
```

We can add new items to our data file:

```
> game = Game.new(title: "Super Mario Maker 2", year: 2019, url: "https://www.nintendo.com/games/detail/super-mario-maker-2-switch/")
#<Game title: "Super Mario Maker 2", url: "https://www.nintendo.com/games/detail/super-mario-maker-2-switch/", year: 2019, id: nil>
> game.save
true
```

The new item will be inserted into `games.yml` ordered by its primary key. The first key in an array is considered the primary key, in our example the primary key is `title`.
