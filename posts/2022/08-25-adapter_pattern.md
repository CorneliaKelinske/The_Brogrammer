==title==
Same, same, but different - using Behaviour for writing re-usable and adaptable code 

==author==
Cornelia Kelinske

==description==
I recently worked on an assignment where I had to periodically fetch data from different APIs and store it in a unified format in a database. In order to avoid duplication and to only write one GenServer module for handling the API calls and database operations, I used Behaviour aka the **Adapter Pattern.


==tags==
coding, elixir, otp

==body==

# 1. The task at hand


I had to query a number of different APIs to obtain event data and persist it in a database. I live in Canada, so let's say the events are hockey games (DISCLAIMER: I know nothing about hockey!). We want to get information on the home team, the away team and the start time. To keep things simple, we are just going to query 2 APIs for this example. They both return the information we want, however API A is returning it in this format:

```
[ { "home_team": "Edmonton Oilers", "away_team": "Vancouver Canucks", "start_at": "2022-11-19T09:00:00Z"} ]
```

while API B is returning this:

```
[ { "teams": "Edmonton Oilers" - "Vancouver Canucks", "start_at": "2022-11-19T09:00:00Z"} ]
```
