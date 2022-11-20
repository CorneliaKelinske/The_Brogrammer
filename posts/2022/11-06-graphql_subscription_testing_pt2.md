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

In [part 1](https://connie.codes/post/graphql_subscription_setup), we learned how to set up subscriptions. In [part 2](https://connie.codes/post/graphql_subscription_testing_pt.1), we looked at how we can test subscriptions that are automatically triggered by the corresponding mutation. Now, in this part 3, we will go one step further and test manually triggered subscriptions. If you are brave and bear with me 'til the end, I will throw in a little extra tidbit of knowledge. 


# 2. The test

Since we have already set up our `ChannelCase` and `SubscriptionCase` ([here](https://connie.codes/post/graphql_subscription_testing_pt.1)]), we can dive straight into our test. So what are we testing? If we go back to [part 1](https://connie.codes/post/graphql_subscription_setup), we can see that at the very end we set up a subscription that is manually triggered when an auth token is generated.

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

Just like in the test for mutation-triggered subscriptions, we need to build a "doc" (document) for the subscription. We also need to set up a user, for whom the auth token will be generated. 


