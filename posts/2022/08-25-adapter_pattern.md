==title==
Same, same, but different - using Behaviour for writing reusable and adaptable code 

==author==
Cornelia Kelinske

==description==
I recently worked on an assignment where I had to periodically fetch data from different APIs and store it in a unified format in a database. In order to avoid duplication and to only write one GenServer module for triggering the API calls and database operations, I used Behaviour, aka the Adapter Pattern.


==tags==
coding, elixir, otp, Behaviour

==body==

# 1. The task at hand


We need to write some code that allows us to periodically query a number of different APIs to obtain event data and persist it in a database. I live in Canada, so let's say the events are hockey games (DISCLAIMER: I know nothing about hockey!). We want to get information on the home team, the away team and the start time. To keep things simple, we will only query 2 APIs for this example. They both return the information we want; however, API A is returning it in this format:

```
[ { "home_team": "Edmonton Oilers", "away_team": "Vancouver Canucks", "start_at": "2022-11-19T09:00:00Z", "created_at": "2018-12-19T09:00:00Z"} ]
```

while API B is returning this:

```
[ { "teams": "Edmonton Oilers" - "Vancouver Canucks", "start_at": "2022-11-19T09:00:00Z", "created_at": "2018-12-19T09:00:00Z" } ]
```
In addition, API B allows us to pass in a `last_checked_at` search parameter, which gives us the option to only fetch match data created after the time we last checked, thus avoiding the retrieval of large amounts of duplicate data.


# 2. The puzzle pieces


Before I start writing any code, I like to think about which pieces I will need to put in place to complete the task.
In the case of our hockey games, we will need a supervised process that ensures that the APIs are queried periodically, code for making the API calls, code for standardizing the return data and last but not least the database components, namely a table and a schema for the match data.


# 3. Arranging the pieces


Now that we know what pieces we need, let's figure out how to put them together. The database side is not different from any other project, so we'll just consider it done. 

Next up is our process. We could use a task that triggers the API calls, stores the fetched data in the database and then calls itself again after we run `Process.sleep/1` with the required amount n of milliseconds. However, since the API calls and data processing operations also take a small amount of time, we would end up querying the API not every n milliseconds but instead every n milliseconds + the time required to do all the other stuff.
A GenServer is more reliable since we can utilize `Process.send_after/4` to have the GenServer call itself reliably every n milliseconds.

Since the GenServer is doing the same things for both APIs, we can start the same GenServer twice; all we have to do is register the two instances of our GenServer under different names.

We also need code for calling our APIs. I decided to create one API module per queried API. While the two API modules have the same job (calling the API, fetching JSON data, decoding JSON data, standardizing data, returning standardized to the GenServer), they are operating under different circumstances: different HTTP addresses, plus the fact that API B also takes in the additional search parameter. 

This is the big moment: enter Behaviour.

Since we assume that both our API modules will perform the same actions and send data in the same unified format back to the GenServer, we can go one step further and not just assume but require that they do so. 
To this end, we can use another module to define the desired Behaviour and implement said Behaviour in our API modules. Now, we cannot only be sure that our existing API modules act in a certain way, but we can also easily add further API modules in the future. All we have to do is implement the same Behaviour for them, thus ensuring that we don't accidentally add a rogue API module that acts different from the rest and risks bringing down its associated GenServer.

But enough with the talk. Let's look at some code!


# 4. The code


**General organization**

```

lib
│   ├── my_app
│   │   ├── application.ex
│   │   ├── config.ex
│   │   ├── match_data_processors
│   │   │   ├── apis
│   │   │   │   ├── client.ex
│   │   │   │   ├── api_a.ex
│   │   │   │   ├── api_b.ex
│   │   │   │   
│   │   │   └── helpers
│   │   │       └── processing_helpers.ex
│   │   ├── matches
│   │   │   └── match.ex
│   │   ├── matches.ex
│   │   ├── match_handler.ex

```

The `match_handler.ex` file is the GenServer module, `match.ex` and `matches.ex` define our the match `Ecto.Schema` and the corresponding context module, and we can also see the `client.ex` (this is where the Behaviour is defined), our two API modules and a `processing_helpers.ex` file, which contains some helper functions accessed by both API modules.


**GenServer**

First stop: `application.ex`, where the GenServer is added to the Supervision tree:

```
defmodule MyApplication.Application do
  
  use Application

  @impl true
  def start(_type, _args) do
    children = [MyApp.Repo] ++ match_handlers()

    
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  if Mix.env() === :test do
    def match_handlers do
      []
    end
  else
    @api_modules MyApp.Config.api_modules()
    def match_handlers do
      Enum.map(
        @api_modules,
        &Supervisor.child_spec({MyApp.MatchHandler, &1}, id: &1)
      )
    end
  end
end
Footer
```
We are defining our `match_handlers` aka the GenServers for our APIs by `Enum.mapping` over our available API_modules and calling `Supervisor.child_spec/2` on them, where we set the respective API_module as the GenServer module's ID.
We can then add the `match_handlers` to our list of children in the `start/2` function. 

Second stop: the actual GenServer module, `match_handler.ex`:

```
defmodule MyApp.MatchHandler do
  
  use GenServer
  
  alias MyApp.Matches

  # Client

  @spec start_link( module()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(api_module) do
    GenServer.start_link(__MODULE__, api_module, name: :"match_handler#{inspect(api_module)}")
  end

  # Server

  @impl GenServer
  def init(api_module) do
    Process.send(self(), :match_query, [])
    {:ok, api_module.initial_state()}
  end

  @impl GenServer
  def handle_info(
        :match_query,
        %{api_module: api_module} = state
      ) do
    Process.send_after(self(), :match_query, 30_000)

    case api_module.fetch_and_standardize_match_data(state) do
      [...] #This is where the database interactions as well as any error logging happens. In all cases, we return:

     {:noreply, state}
    end
  end
end
```

There is not a lot to say here. One thing worth pointing out is that we are getting the initial state of our GenServer from the
API module. This allows us to pattern match on the api_module in our `handle_info` function and to pass any search params we might have around as part of the state as well.


**API_modules**

Here is the example of API Module B:
```
defmodule MyApp.MatchDataProcessors.Apis.API_B do

  alias MyApp.MatchDataProcessors.Apis.Client
  alias MyAPP.MatchDataProcessors.Helpers.ProcessingHelpers

  @behaviour Client

  @impl Client
  @spec initial_state :: %{
          api_module: MyAPp.MatchDataProcessors.Apis.API_B,
          params: %{last_checked_at: nil}
        }
  def initial_state, do: %{api_module: __MODULE__, params: %{last_checked_at: nil}}

  @http_address "https:///api_b"

  @impl Client
  @spec fetch_and_standardize_match_data(Client.state()) ::
          {:ok, [ProcessingHelpers.match_data()], Client.state()} | {:error, atom() | String.t()}
  def fetch_and_standardize_match_data(%{params: %{last_checked_at: last_checked_at}} = state) do
    state = Map.put(state, :last_checked_at, DateTime.utc_now())

    with {:ok, body} <- request_matches(last_checked_at),
         {:ok, matches} <- ProcessingHelpers.decode_json(body) do
      matches = ProcessingHelpers.standardize(:fastball, matches)
      {:ok, matches, state}
    end
  end

  defp request_matches(last_checked_at) do
    params =
      case last_checked_at do
        nil ->
          []

        _ ->
          last_checked_at = DateTime.to_unix(last_checked_at)
          [last_checked_at: last_checked_at]
      end

    case HTTPoison.get(@http_address, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 503}} -> {:error, :not_available}
      {:ok, %HTTPoison.Response{status_code: 400}} -> {:error, :invalid_request}
      error -> {:error, error}
    end
  end
end
```

Here, we can see our Behaviour in action. We adopt the desired Behaviour by setting the `@behaviour` module attribute to our'
`Client` module (where the Behaviour is defined) and implement it for the two public functions through `@impl Client`. 


**The Behaviour**

The `Client` module defines the Behaviour, in other words, the contract that the API modules that implement the Behaviour must adhere to:

```
defmodule MyApp.MatchDataProcessors.Apis.Client do
  
  alias MyApp.MatchDataProcessors.Helpers.ProcessingHelpers

  @type state :: %{api_module: module(), params: map()}

  @callback fetch_and_standardize_match_data(state()) ::
              {:ok, [match :: ProcessingHelpers.match_data()], state()} | {:error, any}

  @callback initial_state :: state
end
```

The`@callback` directive and the typespec signature specify what arguments the corresponding functions in the API modules are to take and what they are to return.
And that is it.

# Final thoughts


![You are missing out on a mediocre Mr. Spock meme](done.jpg "Mr. Spock knows what's up")
