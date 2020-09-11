# miniflux-sanity

![Download counter for the RubyGem](https://img.shields.io/gem/dtv/miniflux_sanity)

👩‍💻 A Ruby command-line utility to mark older entries as read on your Miniflux app. Defaults to items older than a conservative 30 days. Switch to ~1 day and run daily to wake up to a fresh feed.

⭐ Star the project if you like it and want to send some internet support. 🥰

![A screenshot from my Terminal showcasing the utility in action](./assets/miniflux-sanity_cli_v0.2.0.png)

## Motivation

If I haven't read something in the preceding week, it's unlikely I ever will. Miniflux doesn't offer an _archive_ option so we mark entries as read instead. All it really does is offer me a saner overview of "unread" items at the top.

As is usually the case for me, I wanted to build something meaningful as I pick up Ruby again. This was a small use-case that was a good first challenge to tackle.

The code is admittedly not perfect. I welcome any constructive criticism or feedback, more so if you are a Ruby enthusiast.

## Feature-set

- Uses token authentication
- Supports cloud and self-hosted Miniflux apps
- Configurable number of days before which to mark items as read
- Resumes marking as read if interrupted

## Usage

You must have Ruby available on your system/shell.

Install by running `gem install miniflux_sanity`.

All command line options can be viewed by running `miniflux_sanity --help`.

## To-do

- [ ] Unit testing
- [ ] Resume fetching if command crashes in between
- [ ] Optionally, if an item is starred _and_ unread, don't mark it as read.
    - This could lend itself to a nice workflow where my "to-read" can be starred while scanning through items.

## Goals

- Get comfortable with Ruby's syntax
- Work with `Class`, `Module`, `dotenv` etc.
- Work with `JSON`
- Work with Ruby's `File` API
- Interact with an API using an HTTP library

## Development

The Ruby version is specified in `.ruby-version`. `rbenv` is able to read and set the correct local version in your shell.

- `git clone git@github.com:hirusi/miniflux-sanity.git`
- `cd miniflux-sanity`
- `cp .env.template .env`
- Update the `.env` file as required.
    - You'll need a token from your Miniflux app under `Settings > API Keys -> Create a new API key`
- Install the dependencies: `bundle`
- Run the utility: `bundle exec ruby main.rb`

If you have a Docker setup to contribute using Alpine OS as its base, I'd be very happy to merge your PR.
