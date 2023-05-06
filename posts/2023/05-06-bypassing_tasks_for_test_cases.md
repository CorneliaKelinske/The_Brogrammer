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

Let's say we have to write an `Oban.Job` that periodically retrieves a list of thousands of user IDs and queries an external API for some kind of
information on these user IDs, in order to further process said information.

First bottleneck: API calls


# 2. How do mock API responses?



# 3. How do we solve the task problem?
