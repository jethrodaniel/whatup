# whatup

whatup is a simple server-based instant messaging application

**Note**: this is very much a work-in-progress, and will be until version `1.0.0`

## Installation

Assuming you have Ruby `2.6.1` installed,

```
$ gem install whatup
```

If you don't have Ruby `2.6.1` installed, see [here](docs/installing_ruby.md)
for some brief instructions.

## Usage

```
$ whatup

Commands:
  whatup client ...      # Perform client commands
  whatup hello           # Says hello
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

