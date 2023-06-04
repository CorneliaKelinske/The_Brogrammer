==title==
Mocking API calls within other processes

==author==
Cornelia Kelinske

==description==
I've been working a lot with external APIs and, as a result, with sandboxing and mocking API responses for test cases.
These mocks work great unless your production code outsources the API call to a separate task, which means
another process. In those cases, the mock response set in the test is assigned to the parent process, and the test will throw an error because it 
cannot find the mock for that API call. Here is a little workaround I found:


==tags==
coding, elixir, testing

==body==

# 1. What are we testing?


Let's say we want to implement a function that periodically retrieves a list of thousands of user IDs (e.g. from a .tsv file) and then queries an external API for information
on these IDs. Our function has to make one API call per ID. Once all the information is retrieved, it will be processed and stored in a database or cache.
Our code might look like this:

```elixir
  def our_function do
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
  
# 2. How can we test this code?


Now that we've written the code and likely ran it in `:dev`, we want to be good developers and write solid tests for it. But there are a few things we need to consider
before we write the tests:

1. How do we want to handle the call to the external API?
2. How do we handle the call to `Task.async_stream/3` in our production code if we use a mocking strategy for the API call where the mock is set for the specific test process?

# 3. Testing calls to external APIs 


While, in some cases, it can be a good idea to have some optional tests that hit the live API, I would say it's generally a good idea to avoid hitting an external API
by default every time we run the test suite.
There are several mocking options available in Elixir.
At my place of work, we have been using a combination of [TeslaMock](https://hexdocs.pm/tesla/Tesla.Mock.html) and [SandboxRegistry](https://hexdocs.pm/sandbox_registry/SandboxRegistry.html).
While explaining how exactly this sandboxing/mocking strategy works is  worth a blog post of its own, let me sum it up in one sentence:
We start a test sandbox (similar to what happens with Postgres queries when we use `DataCase` in tests) that is hit by the API calls in test mode, and we set mock responses for these API
calls in our tests.

The gotcha is that the mock response is set for the respective test process. This means that when, in the production code, the call to the external API is outsourced to another process - which is 
exactly what happens when we call `Task.async_stream/3` - our test will fail because the process calling the API won't find the mock response.
Therefore, we need to find a way to bypass this call when we're running our main function `our_function/0` in `:test`.


# 4. Bypassing `Task.async_stream/3` 


Here is a little hack that I've been finding very useful for such situations in which I want a function
to behave differently in the `:test` environment:
I write different function definitions depending on the environment.

In our example, we can do something like this:

```elixir

  def our_function do
    user_ids = SomeOtherModule.get_user_ids()

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

  

  if Mix.env() === :test do
    defp async_stream(enum, func, _opts) do
      enum
      |> Stream.map(func)
      |> Enum.map(&{:ok, &1})
    end
  else 
    defdelegate async_stream(enum, func, opts), to: Task
  end
end

```

Now, we can successfully set a mock response in our test, since the sandboxed API call is now happening in the same process.
We're good to go ... or are we?

# 5. Reducing the amount of test data

Another thing we likely want to consider in our test setup is the amount of data we are testing. Do we really want to run thousands of user IDs through our test?
And, while we're at it: do we really want to hit the external API with thousands of calls when we're running our code in `:dev`? My answer to this question is "no."
Luckily, we already have a nice workaround in place: instead of calling `SomeOtherModule.get_user_ids/0` in the main function, we can call a 
private function `user_ids/0` for which we can once again write environment-dependent function definitions. To modify the behavior of `our_function/0` for development as well, we just have to 
modify our `if` statement:

 
```elixir

  def our_function do
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
Now we don't need to wait for our test suite to run through thousands of IDs, and, since we use the same function definition for `:dev` as well, we
are also no longer hitting the external API with a thousand requests when we want to run our code in `:dev`.


