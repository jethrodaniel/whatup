# Inital Design

whatup is a simple server-based instant messaging application utilizing TCP sockets.

## Language

It is written in [Ruby](https://www.ruby-lang.org/en/), a general purpose OOP
programming language, similar to Python.

## Packaging, Installation

It is packaged as a [gem](https://guides.rubygems.org/), which is the idiomatic Ruby way to publish code.

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

When the server recieves a client connection, it starts a new thread and assigns a unique id
to the client by a random number and a user provided name.

Multiple clients can connect, since the server starts a new thread for each connection.

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

When the client connects, it is asked to provide a username, which will be
combined with a random number to produce a unique identifier for the client.

The client, when connected, can ask the server for a list of other connected
clients, and can then choose to chat with any other client.

```
$ whatup client

Commands:
  whatup client connect         # Connects a new client instance to a server
  whatup client help [COMMAND]  # Describe subcommands or one specific subcommand

$ whatup client help start

Usage:
  whatup client connect

Options:
  [--ip=IP]
              # Default: localhost
  [--port=N]
              # Default: 9001

Description:
  Starts a client instance sending requests to the specified ip and port.
```

For example,

```
$ whatup client connect --ip 12.345.67.890 --port 9001

Connecting to ...
Connected successfully to ..

Please enter your username:

> john_doe

Congrats, your username is `john_doe#123`!

Type `help` for a list of available commands.

> help

  list  # See a list of clients you can chat with
  chat  # Starts a chat with the specified client
  exit  # Closes your connection with the server

> list

  1. jane_doe#123
  2. mary#321

>  chat 1

You're now chatting with `jane_doe#123`. Say hi! See `.help` for help.

john_doe#123> hi
jane_doe#123> hey, I'm jane doe!
john_doe#123> .exit

Diconnected from `jane_doe#123`.

> exit

Goodbye!
```


