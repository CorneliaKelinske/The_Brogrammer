==title==
GrapQL subscriptions with Absinthe - the set-up

==author==
Cornelia Kelinske

==description==
This is part 1 of a 3-part series on setting up and testing GraphQL subscriptions with Absinthe.

==tags==
coding, elixir, graphql, absinthe, subscriptions

==body==

# 1. Why am I writing this post?

I have been taking the (Learn Elixir)[https://learn-elixir.dev/] course, where a lot of the assignments involve the use of GraphQL and Absinthe. And what can I say, I like it. However, the one part that I found a bit more difficult was dealing with subscriptions.
While writing and testing queries and mutations is well-documented and discussed in a number of resources, information on setting up and, in particular, testing subscriptions is harder to come by. I have spent quite a bit of time on this topic and, as a result, have developed a solid love-hate relationship with those subscriptions. 
But to answer the question as to why am I writing this post, or rather this 3-part series: for future reference! Everything I know about subscriptions in one place. So let's get started!


# 2. About the underlying app

Before we dive into the subscription set-up, I will describe briefly what kind of app we are working in.

Let's assume we have a Phoenix app with a GraphQL/Absinthe backend. We are using [GraphiQL](https://hexdocs.pm/absinthe_plug/Absinthe.Plug.GraphiQL.html), so we can play around with our queries, mutations and subscriptions.

Our app has users and we are using GraphQL queries to query users based on certain criteria and mutations to do things such as create or update users.
All the usual stuff.

With this out of the way, let's get started!


# 3. Subscription set-up - the vanilla variety

As in most cases, it is worth checking out the corresponding [hex.docs](https://hexdocs.pm/absinthe/subscriptions.html) first.
Based on those and on what I have learned in the course plus some personal experience, I have come up with the following steps for the basic set-up:

1. We need to add some dependencies (if we are running an app as described in 2. above we already have those): 
    ```elixir
    {:absinthe, "~> 1.6"},
	{:absinthe_plug, "~> 1.5"},
	{:absinthe_phoenix, "~> 2.0.0"}
    ```






