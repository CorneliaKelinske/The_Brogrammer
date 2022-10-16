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

The app is organized like this:

```
my_app_web   
├── resolvers
│   ├── some_resolver.ex 
│   └── user.ex
├── router.ex
├── schema
│   ├── mutations
│   │   ├── some_mutation.ex
│   │   └── user.ex
│   ├── queries
│   │   ├── some_query.ex
│   │   └── user.ex
│   └── subscriptions
│       └── user.ex
|── types
|   ├── some_type.ex
|   └── user.ex 
├── schema.ex

```

So the mutations, queries and types are defined in separate modules and I import them and their fields into the `schema.ex` file, which looks like this:

```elixir
defmodule MyAppWeb.Schema do
  @moduledoc false
  use Absinthe.Schema  

  import_types MyAppWeb.Types.SomeType
  import_types MyAppWeb.Types.User 
  import_types GraphqlApiWeb.Schema.Queries.SomeQuery  
  import_types GraphqlApiWeb.Schema.Queries.User  
  import_types GraphqlApiWeb.Schema.Mutations.SomeMutation
  import_types GraphqlApiWeb.Schema.Mutations.User 
  import_types GraphqlApiWeb.Schema.Subscriptions.User

  query do
    import_fields :some_query_queries   
    import_fields :user_queries   
  end

  mutation do
    import_fields :some_mutations_mutations
    import_fields :user_mutations
  end

  subscription do    
    import_fields :user_subscriptions
  end
end
```

With this out of the way, let's get started!


# 3. Subscription set-up - underlying infrastructure

As in most cases, it is worth checking out the [hex.docs](https://hexdocs.pm/absinthe/subscriptions.html) first.
Based on those and on what I have learned in the course plus some personal experience, I have come up with the following steps for the basic set-up:

First, we need to add some dependencies (if we are running an app as described in 2. above we'll already have those): 

```elixir
{:absinthe, "~> 1.6"},
{:absinthe_plug, "~> 1.5"},
{:absinthe_phoenix, "~> 2.0.0"}
```

Then we have to create a `user_socket.ex` file (it goes into the `my_app_web_folder`) and put this piece of code in it:

```elixir
defmodule MyAppWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket,
   schema: MyAppWeb.Schema
 def connect(_params, socket) do
  {:ok, socket}
 end
 def id(_socket), do: nil
end     
```

Note: this is the most basic `UserSocket`. If you look into the [hex.docs](https://hexdocs.pm/absinthe/subscriptions.html), you'll see how you can put your current user into the socket.

The next step is one that I have forgotten many times, so don't forget to do this! We are heading over to `endpoint.ex` to add our `UserSocket`. When you open the file, you'll see (probably on line 2) `use Phoenix.Endpoint`. Right below, we add this:

```elixir
use Absinthe.Phoenix.Endpoint
socket "/socket", MyAppWeb.UserSocket,
  websocket: true,
  longpoll: false
```

At this point, we should also make sure our `UserSocket` is included in our router for our GraphiQL route like so:

```elixir
if Mix.env() === :dev do
  forward "/graphiql", Absinthe.Plug.GraphiQL,
    schema: GraphqlApiWeb.Schema,
    socket: GraphqlApiWeb.UserSocket,
    interface: :playground
end
```

And last but not least, we need to tweak our `application.ex` file and add `Absinthe.Subsription` to the list of children:

```elixir    
children =
    [
     {Absinthe.Subscription, [MyAppWeb.Endpoint]}
    ]
```

# 4. Creating a subscription - vanilla variety

Now that everything we need to run our subscription successfully is in place, it is time to write the subscription itself.
Here is the simplest version, a subscription without any arguments, where we subscribe to the `create_user` mutation:

```elixir
defmodule MyAppWeb.Schema.Subscriptions.User do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    @desc "Broadcasts newly created user"
    field :created_user, :user do
      config fn _, _ -> {:ok, topic: "new user"} end

      trigger :create_user, topic: fn _ -> "new user" end
    end
  end
end
```











