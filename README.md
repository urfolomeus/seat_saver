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


## 2. Adding Elm

1. Shutdown the Phoenix server (Ctrl+c twice) so Brunch doesn't build whilst we're setting things up.
2. In the terminal, at the root of the *seat_saver* project we just created, do the following:

  ```bash
    # create a folder for our Elm project inside the web folder
    mkdir web/elm
    cd web/elm

    # install the core and html Elm packages (leave off the -y if you want to see what's happening)
    elm package install -y
    elm package install evancz/elm-html -y
  ```

3. Create a file called *SeatSaver.elm* in the *web/elm* folder and add the following:

  ```elm
  module SeatSaver where

  import Html exposing (..)
  import Html.Attributes exposing (..)


  main =
    view


  view =
    div [ class "jumbotron" ]
      [ h2 [ ] [ text "Hello from Elm!" ]
      , p [ class "lead" ]
        [ text "the best of functional programming in your browser" ]
      ]
  ```

4. Now let's set up Brunch to automatically build the Elm file for us whenever we save changes to it.
5. Add [elm-brunch](https://github.com/madsflensted/elm-brunch) to your *package.json* directly after the `"brunch": <version>` line.

  ```javascript
  {
    ...
    "dependencies": {
      "brunch": "^1.8.5",
      "elm-brunch": "^0.3.0",
      "babel-brunch": "^5.1.1",
      ...
    }
  }
  ```

6. Run `npm install`.
7. Edit your *brunch-config.json* file as follows, making sure that `elmBrunch` is the first plugin:

  ```javascript
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      ...
      "test/static",
      "web/elm/SeatSaver.elm"
    ],
    ...
  },

  ...

  plugins: {
    elmBrunch: {
      elmFolder: 'web/elm',
      mainModules: ['SeatSaver.elm'],
      outputFolder: '../static/vendor'
    },
    ...
  },
  ```

8. Change *web/templates/page/index.html.eex* to the following

  ```html.eex
  <div class="jumbotron">
    <h2>Welcome to Phoenix!</h2>
    <p class="lead">A productive web framework that<br />does not compromise speed and maintainability.</p>
  </div>

  <div id="elm-main">
  </div>
  ```

9. And add the following to *web/static/js/app/js*:

  ```JavaScript
  ...
  var elmDiv = document.getElementById('elm-main'),
      elmApp = Elm.embed(Elm.SeatSaver, elmDiv);
  ```

10. Firing up the Phoenix server again should build the Elm file and output the JavaScript to *web/static/vendor/seatsaver.js* (which will in turn get compiled into *priv/static/js/app.js*).

  ```bash
  cd ../..
  iex -S mix phoenix.server
  ```

11. If you point your browser to [http://localhost:4000](http://localhost:4000) now you should see something like this:

  ![Phoenix with Elm](https://www.dropbox.com/s/wv52p28uy7g73k3/Screenshot%202015-09-15%2019.48.30.png?dl=0)


## 3. Simplifying the Phoenix templates

I decided to cut away some of the cruft to make it easier to see what was going on. See the diff for details.


## 4.Expanding Elm a bit

Now we put our basic app structure in place in *web/elm/SeatSaver.elm*. See the diff for details.

The demo app is a basic seat reservation system, like you'd use to book a seat on a flight. We've defined a Seat type to represent the seat and whether or not it is occupied. For now we just create an initialModel with two seats so that we can see that everything is wired together correctly. We then have a simple View that displays the string representation of each seat in an unordered list. The main function pipes the model to the view.

With those changes made you should see something like this:

  ![](https://www.dropbox.com/s/tidr8ucql49h535/Screenshot%202015-09-15%2020.06.57.png?dl=0)


## 5. Building a basic seat API in Phoenix

Rather than hardwire the seats we want to get them from the database. We'll start by creating a simple data API in the Phoenix app.

1. Use the built-in Phoenix mix tasks to build a seats endpoint.

  ```bash
  mix phoenix.gen.json Seat seats seat_no:integer occupied:boolean
  ```

2. Now follow the instructions it gives and make the following adjustment to the *web/router.ex* file

  ```elixir
  defmodule SeatSaver.Router do
    use SeatSaver.Web, :router

    ...

    # Other scopes may use custom stacks.
    scope "/api", SeatSaver do
      pipe_through :api

      resources "/seats", SeatController, except: [:new, :edit]
    end
  end
  ```

3. Migrate the database and run the tests to make sure that nothing is broken (you should have 14 passing tests).

  ```bash
  mix ecto.migrate
  mix test
  ```

4. Let's make a couple of tweaks to make things a bit easier on ourselves. Change `seat_no` to `seatNo` in *web/views/seat_view.ex* and *test/controllers/seat_controller_test.exs* as follows:

  ```elixir
  # web/views/seat_view.ex:12
  def render("seat.json", %{seat: seat}) do
    %{id: seat.id,
      seatNo: seat.seat_no,
      occupied: seat.occupied}
  end

  # test/controllers/seat_controller_text.exs:18
  test "shows chosen resource", %{conn: conn} do
    seat = Repo.insert! %Seat{}
    conn = get conn, seat_path(conn, :show, seat)
    assert json_response(conn, 200)["data"] == %{"id" => seat.id,
      "seatNo" => seat.seat_no,
      "occupied" => seat.occupied}
  end
  ```

5. Now we need to add some seat data. We can use the *priv/repo/seeds.exs* file for this. Add the following to end of that file:

  ```elixir
  SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 1, occupied: false})
  SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 2, occupied: false})
  SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 3, occupied: false})
  ```

6. Run `mix run priv/repo/seeds.exs` to apply the seeds and then fire up the Phoenix server (if you don't already have it running). You should see the following at [http://localhost:4000/api/seats](http://localhost:4000/api/seats)

  !{}(https://www.dropbox.com/s/kbsox5gof0b8ikr/Screenshot%202015-09-15%2020.30.32.png?dl=0)
