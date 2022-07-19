# Anoubis
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'anoubis'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install anoubis
```

## Configuration parameters

This configuration parameters can be placed at files config/application.rb for global configuration or config/environments/<environment>.rb for custom environment configuration.

```ruby
config.graylog_server = '127.0.0.1' # Graylog server (By default set as '127.0.0.1') (*optional)
config.graylog_port = 12201 # Graylog server port (By default set as 12201) (*optional)
config.graylog_facility = 'Graylog' # Graylog source identifier (By default set as 'Graylog') (*optional)
config.anoubis_redis_host = '127.0.0.1' # Redis server host (By default set as '127.0.0.1') (*optional)
config.anoubis_redis_port = 6379 # Redis server port (By default set as 6379) (*optional)
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
