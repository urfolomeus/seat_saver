# Notes

This a demo app that uses [Phoenix](http://www.phoenixframework.org/) to serve data and [Elm](http://elm-lang.org) to display it in the browser. The following are the notes on how to repeat this yourself. There will be blog post out soon that goes into a bit more detail, so the instructions that follow are pretty bare bones.

Each of the numbered headers should have an associated commit if you want to have a look at the diffs.

## Versions

* Erlang/OTP 18
* Elixir 1.0.5
* Phoenix 1.0.1
* Elm 0.15.1


## Prerequisites

* You'll need to have Postgres installed and running (or see [the Ecto guide](http://www.phoenixframework.org/docs/ecto-models) if you want to try using something else)
* You'll also need to have [Erlang, Elixir and Phoenix installed](http://www.phoenixframework.org/docs/installation)
* Finally, you'll need to have [Elm installed](http://elm-lang.org/install)


## 1. Creating a Phoenix project

Open a terminal and navigate to where you want to create the project. Then do the following;

```bash
mix phoenix.new seat_saver
cd seat_saver

# Create the database for the project
mix ecto.create

# Run the tests to check that everything went according to plan (should be 4 passing)
mix test

# Fire up the Phoenix server and visit http://localhost:4000 in your browser
iex -S mix phoenix.server
```

You should see something like this:

![Phoenix start page](https://www.dropbox.com/s/18lpc1gxl8cw8kb/Screenshot%202015-09-15%2019.07.20.png?dl=0)
