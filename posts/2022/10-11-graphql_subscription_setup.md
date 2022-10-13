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


# 2. Subscription set-up - the vanilla variety

