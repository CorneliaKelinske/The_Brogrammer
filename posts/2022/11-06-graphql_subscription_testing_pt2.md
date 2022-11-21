==title==
GrapQL subscriptions with Absinthe - beyond basic testing

==author==
Cornelia Kelinske

==description==
This is part 3 of a 3-part series on setting up and testing GraphQL subscriptions with Absinthe.

==tags==
coding, elixir, graphql, absinthe, subscriptions

==body==

# 1. Previously on this blog

In [part 1](https://connie.codes/post/graphql_subscription_setup), we learned how to set up subscriptions. In [part 2](https://connie.codes/post/graphql_subscription_testing_pt.1), we looked at how we can test subscriptions that are automatically triggered by the corresponding mutation. In this part 3, we will go one step further and test manually triggered subscriptions. If you are brave and bear with me 'til the end, I will throw in a little extra tidbit of knowledge. 


# 2. The test

Since we have already set up our `ChannelCase` and `SubscriptionCase` ([here](https://connie.codes/post/graphql_subscription_testing_pt.1)]), we can dive straight into our test. So what are we testing? If we go back to [part 1](https://connie.codes/post/graphql_subscription_setup), we can see that at the very end, we set up a subscription that is manually triggered when an auth token is generated.

We can test this subscription like this:

```elixir
defmodule MyAppWeb.Schema.Subscriptions.AuthTokenTest do
  use MyAppWeb.SubscriptionCase
  import MyApp.UserFixtures, only: [user: 1]
  alias MyApp.TokenCache

  @auth_token_generated_doc """
  subscription AuthTokenGenerated($user_id: ID!) {
    authTokenGenerated(user_id: $user_id) {
      user_id
      token
      timestamp
    }
  }
  """

  @token "FakeToken"
  @timestamp DateTime.utc_now()

  setup :user

  describe "@auth_token_generated" do
    test "broadcasts when an auth_token for the given ID is generated", %{
      socket: socket,
      user: %{id: id}
    } do
      string_id = to_string(id)
      ref = push_doc(socket, @auth_token_generated_doc, variables: %{"user_id" => string_id})

      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      TokenCache.put(id, %{token: @token, timestamp: @timestamp})
      assert_push("subscription:data", data)

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "authTokenGenerated" => %{
                     "timestamp" => timestamp,
                     "token" => @token,
                     "user_id" => ^string_id
                   }
                 }
               }
             } = data

      assert {:ok, @timestamp, 0} === DateTime.from_iso8601(timestamp)
    end
  end
end
```

Like in the test for mutation-triggered subscriptions, we need to build a "doc" (document) for the subscription. We also need to set up a user for whom the auth token will be generated. We pass both the `socket` and the `user` into the context map of our test and then start testing by pushing the subscription doc to the socket and asserting that the subscription ID is returned. Since our subscription requires the `argument` of `user_id` we have to pass in `%{"user_id" => string_id}` under the `variables` key in `push_doc/3`.

Next, we need to trigger our subscription. We do so by calling `TokenCache.put/2`, where the subscription is triggered.
With the subscription triggered, the remainder of the test is identical to what we would do in case of a mutation-triggered subscription.

No big deal!


# 3. Random info

As mentioned in [part 2](https://connie.codes/post/graphql_subscription_testing_pt.1), the only part of the context that `push_doc/3` passes on is whatever is under the `variables` key. 
I became acutely aware of this fact when I implemented an `auth_plug` for the mutations, requiring authentication via a secret key in the HTTP header. The corresponding auth middleware looked like this:

```elixir
defmodule MyAppWeb.Middlewares.Authentication do
  @moduledoc false
  @behaviour Absinthe.Middleware
  @impl Absinthe.Middleware

  alias MyAp.Config

  @secret_key Config.secret_key()

  @spec call(Absinthe.Resolution.t(), any) :: Absinthe.Resolution.t()
  def call(%{context: %{secret_key: secret_key}} = resolution, _) do
    case secret_key do
      @secret_key -> resolution
      _ -> Absinthe.Resolution.put_result(resolution, {:error, "unauthenticated"})
    end
  end

  def call(resolution, _) do
    Absinthe.Resolution.put_result(resolution, {:error, "Please enter a secret key"})
  end
end
```

I didn't run into any problems in my mutation tests where I was able to pass through the secret key as an option under the `context` key in the `Absinthe.run/3` function:

```elixir
Absinthe.run(@create_user_doc, Schema,
                 variables: %{
                   "name" => "Molly",
                   "email" => "molly@example.com"               
                 },
                 context: %{secret_key: @secret_key}
               )
```

But I had to find a workaround for the subscription test, where I had no way to pass through the secret key along with the mutation doc in `push_doc/3`. Yet, I needed to get the `@create_user_doc` - that I pushed up to trigger the subscription - successfully past the authorization middleware. Eventually, I decided to bypass authorization in case of subscription tests by adding a second function head for  `Authentication.call/2` in the authentication middleware:

```elixir
 # This matches on what is pushed in the subscription tests
  if Mix.env() === :test do
    def call(%{context: %{pubsub: MyAppWeb.Endpoint}} = resolution, _) do
      resolution
    end
  end
```

Since the mutation tests do not use `SubscriptionCase`, `%{pubsub: MyAppWeb.Endpoint}` key is only present in the context of the subscription tests so that authorization is still checked during the mutation tests.



