==title==
Bypassing tasks for test cases

==author==
Cornelia Kelinske

==description==
I've been working a lot with external APIs and, as a result, with sandboxing and/or mocking API responses for test cases.
These mocks work great, unless your production code outsources the API call to a separate task, which means
another process. In those cases, the mock response set in the test is assigned to the parent process, and the test will throw an error because it 
cannot find the mock for the outsourced API call. Here is a little workaround I found:


==tags==
coding, elixir, testing

==body==

# 1. What are we testing?

Let's say we have to implement an `Oban.Worker` that periodically retrieves a list of thousands of user IDs (e.g. from a .tsv file) and then queries an external API for information
on these IDs. Our worker has to make one API call per ID. Once all the information is retrieved, the worker will process it and store it in a database or cache.
Our code might look like this:

```elixir
use Oban.Worker,
    max_attempts: 3,
    queue: :user_info_scraper

  @impl true
  def perform(_job) do
    user_ids = SomeOtherModule.get_user_ids()

    user_ids
    |> Task.async_stream(
      fn id ->
      #get_info/1 is where the call to the external API happens
        case get_info(id) do
          {:ok, info} ->
            {id, info}

          {:error, error} ->
            {id, inspect(error)}
        end
      end,
      timeout: 30_000,
      ordered: false
    )
    #... imagine a couple more reducer functions here, and ultimately:
    |> put_it_all_into_the_cache(stuff_that_we_want_to_store)
  end
```
  
# 2. What are the tricky parts we need to consider?

Now that we've written the code and likely ran it in `:dev`, we want to be good developers and write some solid tests for it. But there are a pitfalls when it comes to testing this code.

 1. we want to keep our tests trim and slim and fast; iterating ove thousands of user IDs is likely not a good idea
 2. we need to decide how to deal with the call to the external API? Do we want to mock responses, and if so, how?

# 3. Solving the easy question: restricting the number of of user IDs 

Here is a little hack that I've been finding very useful for situations in which I want a function
to behave differently in the `:test` and `:dev' environments:
I write different function definitions depending on the environment.
In our example, I would call a private `user_ids/0` function (instead of `SomeOtherModule.get_user_ids/0`) from within the main `perform/1` function and
define `user_ids/0` as follows:

```elixir

 if Mix.env() in [:test, :dev] do
    defp user_ids do
      Enum.take(SomeOtherModule.get_user_ids, 10)
    end    
  else
    defp user_ids do
      SomeOtherModule.get_user_ids()
    end    
  end
end

```

Now we don't need to wait for our test suite to run through thousands of IDs and, since we use the same function definition for `:dev` as well, we
are also no longer hitting the external API with a thousand requests when we want to run our code in `:dev`.


# 4. On to the harder one: testing calls to the external API

 
```elixir
defmodule UserInfoScraper do
 

  use Oban.Worker,
    max_attempts: 3,
    queue: :user_info_scraper

  @impl true
  def perform(_job) do
    user_ids = user_ids()

    user_ids
    |> async_stream(
      fn id ->
        case get_info(id) do
          {:ok, info} ->
            {id, info}

          {:error, error} ->
            {id, inspect(error)}
        end
      end,
      timeout: 30_000,
      ordered: false
    )
    #... imagine a couple more reducer functions here, and ultimately:
    |> put_it_all_into_the_cache(stuff_that_we_want_to_store)
  end

  

  if Mix.env() in [:test, :dev] do
    defp _user_ids do
      Enum.take(SomeOtherModule.get_user_ids, 10)
    end

    defp async_stream(enum, func, _opts) do
      enum
      |> Stream.map(func)
      |> Enum.map(&{:ok, &1})
    end
  else
    defp user_ids do
      Accounts.get_user_ids
    end

    defdelegate async_stream(enum, func, opts), to: Task
  end
end

```
First bottleneck: API calls


# 2. How do mock API responses?



# 3. How do we solve the task problem?
