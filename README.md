# whatup

whatup is a simple server-based instant messaging application

**Note**: this is very much a work-in-progress, and will be until version `1.0.0`

Check it out on [rubygems.org](https://rubygems.org/gems/whatup).

[![Build Status](https://travis-ci.com/jethrodaniel/whatup.svg?branch=dev)](https://travis-ci.com/jethrodaniel/whatup)
[![Maintainability](https://api.codeclimate.com/v1/badges/e5356174302d82cf67cb/maintainability)](https://codeclimate.com/github/jethrodaniel/whatup/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/test_coverage)](https://codeclimate.com/github/codeclimate/codeclimate/test_coverage)
[![Gem Version](https://badge.fury.io/rb/whatup.svg)](https://badge.fury.io/rb/whatup)

## Installation

Assuming you have Ruby 2.4 or greater installed,

```
$ gem install whatup
```

If you don't have Ruby installed, see [here](docs/installing_ruby.md) for some
brief instructions.

## Usage

```
$ whatup

Commands:
  whatup -v, --version   # Output the version
  whatup client ...      # Perform client commands
  whatup help [COMMAND]  # Describe available commands or one specific command
  whatup server ...      # Perform server commands
```

## Development

To run the program's command line interface

```
$ ruby -I./lib ./exe/whatup
```

To run the tests

```
$ bundle exec rspec
```

We have a git hook to automatically run the code linter before committing.

Set it up as follows

```
$ git config core.hooksPath '.git_hooks'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/jethrodaniel/whatup>.

## License

Free as in beer - our [license](https://github.com/jethrodaniel/whatup/blob/master/LICENSE) is [MIT](https://opensource.org/licenses/MIT).

## About

This was part of a school project - see the [course site](http://www.cs.memphis.edu/~kanyang/COMP3825-sp19.html) for details.

## Citations

The following were instrumental in understanding the usage of threads for socket input:

- [Socket Programming in Ruby](https://code.likeagirl.io/socket-programming-in-ruby-f714131336fd),Chopra, Neha. Code Like A Girl. (19 Sept. 2017)
- [Ruby TCP Chat](www.sitepoint.com/ruby-tcp-chat/), Benitez, Simon. Sitepoint. (13 Jan. 2014)
