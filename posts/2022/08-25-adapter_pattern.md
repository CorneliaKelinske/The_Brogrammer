==title==
Same, same, but different - using Behaviour for writing re-usable and adaptable code 

==author==
Cornelia Kelinske

==description==
I recently worked on an assignment where I had to periodically fetch data from different APIs and store it in a unified format in a database. In order to avoid duplication and to only write one GenServer module for triggering the API calls and database operations, I used Behaviour aka the Adapter Pattern.


==tags==
coding, elixir, otp, behaviour

==body==

# 1. The task at hand


We need to write some code that allows us to periodically query a number of different APIs to obtain event data and persist it in a database. I live in Canada, so let's say the events are hockey games (DISCLAIMER: I know nothing about hockey!). We want to get information on the home team, the away team and the start time. To keep things simple, we are just going to query 2 APIs for this example. They both return the information we want, however API A is returning it in this format:

```
[ { "home_team": "Edmonton Oilers", "away_team": "Vancouver Canucks", "start_at": "2022-11-19T09:00:00Z", "created_at": "2018-12-19T09:00:00Z"} ]
```

while API B is returning this:

```
[ { "teams": "Edmonton Oilers" - "Vancouver Canucks", "start_at": "2022-11-19T09:00:00Z", "created_at": "2018-12-19T09:00:00Z" } ]
```
In addition, API B allows us to pass in a `last_checked_at` search parameter, so that we are able to fetch only match data created after the time when we last checked, thus avoiding the retrieval of large amounts of duplicate data.


# 2. The puzzle pieces


Before I start writing any code, I like to think about which pieces I will need to put in place to complete the task.
In the case of our hockey games, we will need a supervised process that ensures that the APIs are queried periodically, code for making the API calls, code for standardizing the return data and last but not least the database components, namely a table and a schema for the match data.


# 3. Arranging the pieces


Now that we have an idea of what pieces we will need, let's figure out how to put them together. The database side is not different from any other project, so we'll just consider it done. 

Next up is our process. We could use a task that triggers the API calls, stores the fetched data in the database and then calls itself again after we run `Process.sleep/1` with the required amount n of milliseconds. However, since the API calls and data processing operations also take a small amount of time, we would end up querying the API not every n milliseconds, but instead every n milliseconds + the time required to do all the other stuff.
A GenServer is more reliable, since we can utilize `Process.send_after/4` to have the GenServer call itself reliably every n milliseconds.

Since the GenServer is doing the same things for both APIs, we can start the same GenServer for both of them; all we have to do is register the two instances of our GenServer under different names.

We also need code for calling our APIs. I decided to make one API module per API. The reason for this is that, while the two API modules have the same job (calling the API, fetching JSON data, decoding JSON data, standardizing data, returning standardized to the GenServer), they are operating under different circumstances: different HTTP addresses, plus the fact that API B also takes in the additional search parameter. 





