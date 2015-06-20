Lita::Adapters::Gitter
======================

[![Gem Version](https://badge.fury.io/rb/lita-gitter.svg)](http://badge.fury.io/rb/lita-gitter)
[![Build Status](https://travis-ci.org/braiden-vasco/lita-gitter.svg)](https://travis-ci.org/braiden-vasco/lita-gitter)
[![Coverage Status](https://coveralls.io/repos/braiden-vasco/lita-gitter/badge.svg)](https://coveralls.io/r/braiden-vasco/lita-gitter)

[Gitter](https://gitter.im) adapter for the [Lita](https://lita.io) chat bot.

Usage
-----

At first, see the documentation for Lita: https://docs.lita.io/

### Installation

Add **lita-gitter** to your Lita instance's Gemfile:

```ruby
gem 'lita-gitter', '~> 0.1.0'
```

### Preparation

Go to https://developer.gitter.im/apps, sign in if you are not already
signed in, and remember your token.

Then go to https://gitter.im/api/v1/rooms, find needed room by it's name
and remember room ID which precedes room name.

### Configuration

#### Required attributes

- `token` (String) - Secret token of Gitter user
- `room_id` (String) - Room ID

#### Example

This is an example `lita_config.rb` file:

```ruby
Lita.configure do |config|
  config.robot.name = 'Lita'
  config.robot.mention_name = 'lita'

  config.robot.adapter = :gitter

  config.adapters.gitter.token   = 'LpMMyGbceCbUNl4ldRHfzjzb9a48F5WZYbgtBWoi'
  config.adapters.gitter.room_id = 'Q5cjBQ9BwrNdK0JcicI9AYbL'
end
```
