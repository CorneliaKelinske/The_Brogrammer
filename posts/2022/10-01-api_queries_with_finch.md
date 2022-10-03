==title==
API queries with Finch

==author==
Cornelia Kelinske

==description==
I've been using HTTPoison as my HTTP client of choice ever since I learned how to do API queries with Elixir.
Lately, though, I've been hearing more about people using Finch for that purpose. So I went ahead and tried it out.


==tags==
coding, elixir, api_calls, finch

==body==

# 1. The set-up

The first thing that is good to know about Finch is that we want to add it to our supervision tree. Generate a new project with `mix new new_app --sup` command so that we get our `application.ex` file with the supervision tree automatically generated.

Then, as with all libraries, we need to head over to the [Finch documentation](https://hexdocs.pm/finch/Finch.html).

With the documentation open, we can then add Finch to our dependencies in the `mix.exs` file

```elixir
def deps do
    [
      {:finch, "~> 0.13.0"}  
    ]
```

run `mix deps.get` and add Finch to our supervision tree in the `application.ex` file

```elixir
children = [
  {Finch, name: NewApp.Finch}
] 
```

The important thing in this step is that we need to provide a `:name` when we add Finch to the list of children. I just name it  `WhatEverMyAppIsCalled.Finch`.

And now we are ready to query away.


# 2. Basic query (no params)


Next, the docs show us how to build and run a request to an API:

```elixir
Finch.build(:get, "https://hex.pm") |> Finch.request(MyFinch)
```

First, we use `build/5` to build our request, and then we pipe the request into `request/3`. 

Let's see how this works on a real API. 
Since laughing is healthy, we will use this one: https://api.chucknorris.io/.

The API docs tell us we can make a GET request to https://api.chucknorris.io/jokes/random to get a random joke, no query params or API key required. So let's do that:

```elixir
Finch.build(:get, "https://api.chucknorris.io/jokes/random") |> Finch.request(NewApp.Finch)
```

And that's our first basic API request. 
Two things that are important to note:

1. Always include the scheme in the URL that is passed into the `build` function. The scheme is the "https://" part (or could, in other cases, just be "http://"), so if we were to pass "api.chucknorris.io/jokes/random" into our function, our API call would not succeed.

2. This one is for people who like copying code from other projects or the docs (like me): make sure you pass the correct name into the `request/3` function. That means the name under which you added Finch to your supervision tree.



# 3. Adding a search param to the query


Now that we know how to run a basic query let's look at how we can pass query params, such as search terms, API keys etc., into our API request.

This is the step that tripped me up at first. Coming from HTTPoison, I thought I would have to pass in any query params as a keyword list somewhere in the `build/5` function. Spoiler! This is not the case.
Instead, we need to append any query params to our base URL. 

For our Chuck Norris API, a valid search URL would, for example, look like this: "https://api.chucknorris.io/jokes/search?query=cat"
To get cat-related Chuck Norris jokes, we would have to pass the entire URL as the second argument into our `build/5` function.

If our search term is the only param that we are adding to our request, we can probably get away with writing something like this:

```elixir
def query_api(thing_we_are_searching_for) do
  Finch.build(:get, "https://api.chucknorris.io/jokes/search?query=#{thing_we_are_searching_for}") |> Finch.request(NewApp.Finch)
end 
```

But what if we want to add more than that?


# 4. Adding several params 


When we are querying APIs, we will often have to add more than just a search term to our query string. A lot of APIs require an API key. Or we might be able to set a limit for how many results we want or filter the results based on a timestamp. 
Of course, we could just extend the `query_api/1` function above and pass in all the other params. 
But that would make for some really ugly code (at least in my opinion). So let's stay away from that.

Let's take a more dynamic approach instead!

I'm currently big into writing helper modules, so let's put our query builder functions into a helper module.

```elixir
defmodule NewApp.FinchHelpers do
  @moduledoc """
  Functions for building an API call through Finch
  """
  @type params :: %{api_key: String.t() | nil, q: String.t() | nil, limit: pos_integer} | []
  

  @spec build_query(params(), String.t()) :: Finch.Request.t()
  def build_query(params, url) do
    url
    |> append_params(params)
    |> String.trim_trailing("&")
    |> then(fn x -> Finch.build(:get, x) end)
  end

  def append_params(query, []) do
    query
  end

  def append_params(query, params) do
    Enum.reduce(params, "#{query}?", fn {k, v}, acc -> acc <> "#{k}=#{v}&" end)
  end
```

In this example, we are adding an API key, the query variable `q` and a limit to our URL. All the parameters are passed into our main `build_query/2` function in a map so that both keys and values can be used for building the query.

What I like to do in my main module is setting both the params and the base HTTP address as module attributes. That way, I can see at one glance what parameters my API requires, and if I need to make changes to the address, I can do so in one place.

Accordingly, my main module in the current example would look like this:

```elixir
defmodule NewApp.MainModule do

alias NewApp.FinchHelpers

  @url "https://somerandomurl"
  @params %{api_key: nil, q: nil, limit: nil}

  #Some other functions for decoding and returning the query results
   [...] 


  defp query_api(query, limit) do
    %{@params | api_key: api_key(), q: query, limit: limit}
    |> FinchHelpers.build_query(@url)
    |> Finch.request(NewApp.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} -> {:ok, body}
      {:ok, %Finch.Response{status: 401}} -> {:error, :api_key_not_found}
      error -> {:error, inspect(error)}
    end
  end

  defp api_key do
    Application.get_env(:giphy_scraper, :api_key)
  end
```

Note: I set the API key as an environmental variable in this case and am updating my params map with the values that I am passing into `query_api/2` and the API key.

And that's it!

Let's end this post with a Chuck Norris joke from https://api.chucknorris.io/ 

"Chuck Norris can play Angry Birds from a payphone"

