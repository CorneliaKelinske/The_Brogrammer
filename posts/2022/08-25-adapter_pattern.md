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


I was asked to query a number of different APIs to obtain data and persist it in a database. Let