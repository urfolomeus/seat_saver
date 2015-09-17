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

![Phoenix start page](http://i.imgur.com/DYDYlJL.png)


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

  ![Phoenix with Elm](http://i.imgur.com/SuZIMwD.png)


## 3. Simplifying the Phoenix templates

I decided to cut away some of the cruft to make it easier to see what was going on. See the diff for details.


## 4.Expanding Elm a bit

Now we put our basic app structure in place in *web/elm/SeatSaver.elm*. See the diff for details.

The demo app is a basic seat reservation system, like you'd use to book a seat on a flight. We've defined a Seat type to represent the seat and whether or not it is occupied. For now we just create an initialModel with two seats so that we can see that everything is wired together correctly. We then have a simple View that displays the string representation of each seat in an unordered list. The main function pipes the model to the view.

With those changes made you should see something like this:

  ![Moar Elm](http://i.imgur.com/SH9AeKR.png)


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

  ![Data API](http://i.imgur.com/5qUC0Nl.png)


## 6. Sending the initial seat data to the Elm app

We'll implement the initial loading of seat data by setting up an incoming port in Elm, making an AJAX request within *web/static/js/app.js* and then sending the resulting JSON data over the port to Elm. Ports allow you to send data between Elm and JavaScript. We'll send any errors to the browser console for now. This is just a halfway point until the next section when we introduce channels.

See the diff for the details.

You should now see the following in your browser:

![Getting initial seats via ports](http://i.imgur.com/gbzIr8b.png)


## 7. Adding Phoenix channels

What's the point of all this FRP goodness on the Elm side if we can't take advantage with some real time goodness on the Phoenix side?

1. Use the mix generators to create a quick scaffold for the seats channel.

  ```bash
  mix phoenix.gen.channel Seat seats
  ```

2. Add the given channel line to *web/channels/user_socket.ex*.

  ```elixir
  defmodule SeatSaver.UserSocket do
    use Phoenix.Socket

    ## Channels
    # channel "rooms:*", SeatSaver.RoomChannel
    channel "seats:lobby", SeatSaver.SeatChannel

    ...
  end
  ```

3. And run `mix test` again to make sure we've not broken anything (should be 17 passing tests).

4. Change the *web/channels/seat_channel.ex* file to the following:

  ```elixir
  defmodule SeatSaver.SeatChannel do
    use SeatSaver.Web, :channel

    def join("seats:planner", payload, socket) do
      {:ok, socket}
    end
  end
  ```

5. Change lines 54-57 of the *web/static/js/socket.js* file to the following:

  ```javascript
  socket.connect()

  // Now that you are connected, you can join channels with a topic:
  let channel = socket.channel("seats:planner", {})
  ```

6. Now uncomment the `import socket from "./socket"` line in *web/static/js/app.js* to enable sockets on the JavaScript side.
7. Visiting [http://localhost:4000](http://localhost:4000) again, it should look like this.

  ![Joined channel successfully](http://i.imgur.com/2PdLQPS.png)

8. But we can do better than this. Let's load the initial application state (i.e. the list of seats) from the database into the Elm app. We'll start off by modifying our Seat model to be able to encode to JSON. At the very bottom of the *web/models/seat.ex* file, after the module definition add:

  ```elixir
  defimpl Poison.Encoder, for: SeatSaver.Seat do
    def encode(model, opts) do
      %{id: model.id,
        seatNo: model.seat_no,
        occupied: model.occupied} |> Poison.Encoder.encode(opts)
    end
  end
  ```

9. Open *web/channels/seat_channel.ex* and change it to the following:

  ```elixir
  defmodule SeatSaver.SeatChannel do
    use SeatSaver.Web, :channel

    import Ecto.Query

    alias SeatSaver.Seat

    def join("seats:planner", payload, socket) do
      seats = (from s in Seat, order_by: [asc: s.seat_no]) |> Repo.all
      {:ok, seats, socket}
    end
  end
  ```

10. Now replace the XHR code in *web/static/js/app.js* with:

  ```javascript
  let channel = socket.channel("seats:planner", {})
  channel.join()
    .receive("ok", seats => { elmApp.ports.seats.send(seats); })
    .receive("error", resp => { console.log("Unable to join", resp) })
  ```

11. And comment out those same lines in *web/static/js/socket.js*
12. Visiting [http://localhost:4000](http://localhost:4000) again, it should look like this.

  ![Load data when joining channel]()


## 8. Reserving a seat - interop with JavaScript

Ok, so now we are able to load our initial model over channels when we join. Let's expand this so that we can reserve a seat over channels too. We'll start with the outgoing request.

In order to convert click events in the View into events that JavaScript can process we need three things:

  1. A Mailbox in our Elm application to send click events to. A Mailbox in Elm allows us to send values to a Signal. You can read more about them on the [Elm Reactivity Guide](http://elm-lang.org/guide/reactivity).
  2. An outgoing Port in our  Elm application that will send any values that appear on the Mailbox out to JavaScript.
  3. A subscriber to that port in our JavaScript that attaches a callback function that should fire whenever a value is received on that port.

Open the *web/elm/SeatSaver.elm* file.

1. Let's set up the Mailbox first. This needs to receive Seat records so the definition looks like this:

  ```elm
  -- SIGNALS

  seatsToUpdate : Signal.Mailbox Seat
  seatsToUpdate =
    Signal.mailbox (Seat 0 False)
  ```

2. Now we can send click events to this Mailbox by passing it's address into the View from the `main` function.

  ```elm
  main =
    Signal.map (view seatsToUpdate.address) model
  ```

3. And then using it in the View.

  ```elm
  -- VIEW

  view : Signal.Address Seat -> Model -> Html
  view address model =
    ul [ ] ( List.map (seatItem address) model )


  seatItem : Signal.Address Seat -> Seat -> Html
  seatItem address seat =
    li [ onClick address seat ] [ text (toString seat) ]
  ```

4. We'll need to add an import for the `HTML.Events` module so that we can access the onclick` function.

  ```elm
  import Html.Events exposing (..)
  ```

5. We need an outgoing port that will let us watch for values appearing on the Mailbox's signal and send them out to JavaScript.

  ```elm
  -- PORTS

  ...

  port updateSeat : Signal Seat
  port updateSeat =
    seatsToUpdate.signal
  ```

6. The last piece of the puzzle is to subscribe to this port in our *web/static/js/app.js* file.

  ```javascript
  elmApp.ports.updateSeat.subscribe(function (seat) {
    console.log(seat);
  });
  ```

7. We'll start by just outputting what we get to the console so we can take a peek. If you fire up a Phoenix server and visit [http://localhost:4000](http://localhost:4000) you should see something that looks like this:

  ![Interop no clicks yet]()

8. Clicking on any of the seats should output that Seat's JSON representation to the console.

  ![Interop with clicks]()

So we are now able to send a seat's data out to JavaScript when we click on it. In the next section we'll link that up to a channel so that we can send the seat data to the server to be persisted.


## 9. Reserving a seat - setting up the channel

We now have a port hooked up from our Elm app. We can take the data that is sent to us on this port and push it onto the channel so that we can send it to the server.

1. Add the following to your *web/channels/seat_channel.ex* file.

  ```elixir
  def handle_in("request_seat", payload, socket) do
    # sanity check out to the log in case things go awry!
    IO.puts {:request_seat, payload} |> inspect

    # fetch the requested seat from the database
    seat = Repo.get!(SeatSaver.Seat, payload["seatNo"])

    # create an update that will mark the seat as occupied
    seat_params = %{"occupied" => true}
    changeset = SeatSaver.Seat.changeset(seat, seat_params)

    # run the update, if it was successful broadcast the seat that
    # was occupied to all subscribers, otherwise reply to the originator
    # with an error
    case Repo.update(changeset) do
      {:ok, seat} ->
        broadcast socket, "occupied", payload
        {:noreply, socket}
      {:error, changeset} ->
        {:reply, {:error, %{message: "Something went wrong"}}, socket}
    end
  end
  ```

2. Now we need to push to this handler from *web/static/js/app.js* and handle any error replies we get. For the purposes of this demo we'll just log them to the console.

  ```javascript
  elmApp.ports.updateSeat.subscribe(function (seat) {
    var seatNo = seat.seatNo
    console.log('Requesting seat ' + seatNo)
    channel.push("request_seat", {seatNo: seatNo})
           .receive("error", payload => {
              console.log(payload.message);
           })
  });
  ```

3. And we also need to listen for broadcasts on the channel that tell us when the seat has been occupied. For now we'll just log this to the console too.

  ```javascript
  channel.on("occupied", payload => {
    console.log('occupied seat', payload);
  });
  ```

4. If we fire up a server, visit [http://localhost:4000](http://localhost:4000) and click on any of the seatItems we should see something like the following:

  ![Updating a seat via channels - browser]()

5. If you check your database too, your should see that the associated record has been updated too!

  ![Updating a seat via channels - database]()
