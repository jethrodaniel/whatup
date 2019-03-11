# Inital Design

whatup is a simple server-based instant messaging application ustilitzing TCP sockets.

## Language

It is written in [Ruby](https://www.ruby-lang.org/en/), a general purpose OOP
programming language, similar to Python.

## Packaging, Installation

It is packaged as a [gem](https://guides.rubygems.org/), which is idiomatic Ruby way to publish code.

This allows for a very simple setup (as follows):

```
$ gem install whatup
```

## Command Line Interface

While the code is written in Ruby, the program interacts with the user via a
command line interface.

```
$ whatup
Commands:
  whatup client ...      # Perform client commands
  whatup hello           # Says hello
  whatup help [COMMAND]  # Describe available commands or one specific command
  whatup server ...      # Perform server commands
```

## Server

The server implements a basic TCP socket, and listens on port 9001 (or another
optional port) for requests, which will be routed to TCP sockets.

```
$ whatup server

Commands:
  whatup server help [COMMAND]  # Describe subcommands or one specific subcommand
  whatup server start           # Starts a server instance

$ whatup server help start

Usage:
  whatup server start

Options:
  [--port=N]
              # Default: 9001

Description:
  Starts a server instance on the specified port.
```

## Client

A client connects to the server via one of the server's TCP sockets.

```
$ whatup client

Commands:
  whatup client help [COMMAND]  # Describe subcommands or one specific subcommand
  whatup client start           # Starts a client instance

$ whatup client help start

Usage:
  whatup client start

Options:
  [--port=N]
              # Default: 9001

Description:
  Starts a client instance sending requests to the specified port.
```
