==title==
How to find your place, contribute and grow as a junior developer 

==author==
Cornelia Kelinske

==description==
If you know me or have been reading previous blog posts, you know that the past six months have been quite a wild ride for me: job hunt, first job,
no job and, finally, the second job. While there are a lot of things that I was able to learn during job number 1, this second job brings along its own challenges as I'm experiencing for the first time what it is like to work in an unfamiliar codebase. Luckily I was able to ask some extremely helpful and knowledgeable folks - big shout-out to everyone in the Groxio Elixir Chatt - for their advice. This post sums up their suggestions in 7 little nuggets of wisdom.

==tags==
career, job, junior, dev life


==body==

# A few words about my job


I'm once again working on a small team for a startup. This time, though, I'm the only junior. The app we're working on already exists as a legacy JavaScript app, and we are switching it over to Elixir. My teammate has built most of the Elixir app over the last year. He knows the codebase inside out. While he has designed the Elixir app for the most part by himself, he has gotten some advice from the third person on the team, a seasoned architect, who is now also there to support us. The launch date for the Elixir app is around the corner, so some pressure is building up, especially for my teammate. 

I've been there for a month and am starting to understand the codebase and the business better. But I'm also acutely aware of everything I don't know. So my biggest challenge right now is finding ways to contribute, learn and grow as a developer while respecting my teammates' time. 

And now, without further ado, here is the advice I got from my peers and mentors:


# 1. Breaking things down


This advice is almost generally applicable: break any task into smaller pieces if it seems too complex. Get started with the things you can do and then do some research and ask the questions on the remaining portions. Break tickets down into smaller tickets. It's easier to get yourself unblocked from small obstacles and easier to get answers to more targeted questions. In addition, by breaking things down, you will gain a clearer picture of the task at hand, and the individual steps can be your roadmap toward the solution.


# 2. Do some research before asking questions


You might even find the solution on your own. And if not, you will at least have a clearer understanding of the problem, and your team will see that you put in an effort. I might have mentioned this before, but I try to avoid asking questions that can be answered with "Read the error message" or "Let me google this for you."


# 3. Find a mentor


This is another solid piece of advice. I can't express how grateful I am for all the people who have mentored me in various ways.

If you are new to Elixir or programming and are still a bit unsure about the whole thing and maybe not confident to reach out to anyone, let me tell you: the Elixir community is amazing. Almost everybody I have met on my coding journey has been helpful and welcoming. On this note, feel free to [contact me](https://connie.codes/contact) if there is anything I can help you with.


# 4. Follow the routes 


Chances are the app you're working on is a Phoenix app. If so, following the routes is an excellent way to better understand the app. Likewise, if your application involves GraphQL, go to the GraphiQL page to look at the schemas, queries, etc.


# 5. Document


Whenever you have to ask questions for clarification around the codebase or the business logic, remember that other people who might join the company in the future will likely have similar questions. Finding a good way to document the answers to your questions is therefore a great way to contribute to the team. Maybe your team already has a place where things are documented and where you can add information. Or maybe you can create such a place. Another excellent way for documenting is adding moduledocs. I 'm also a big fan of dialyzer and find that adding typespecs is a great piece of documentation (if they are correct that is).


# 6. Don't wait for others to make decisions for you


Not all things are perfectly clear and straightforward in your day-to-day life as a developer. Features can be implemented one way or another, you might not be sure which function to use in a specific case, and sometimes the tickets you're working on are not entirely clear. Don't let situations like this become blockers for you though: of course, it is good to ask your team about preferences and for clarification. But don't hesitate to move forward if you don't get a timely response and don't expect others to make all decisions for you. Instead of asking, "we have 2 options; which one should I take?" and then waiting for a response, you could, for example, say: "We have two options. Option A looks better to me for this or that reason. I will go with option A, unless I hear otherwise". Another way to get things moving is to start a draft PR and ask a teammate for confirmation that you're on the right track before you go too deep down the rabbit hole.


# 7. Ask, "is this ticket ready to be worked on?" when grooming tickets


One of the things that I find challenging is asking the right questions and identifying potential problems with a ticket during grooming sessions. Often, a ticket looks pretty clear to me during the session, but all the questions arise once I start working on it. There have been multiple occasions where a 5-line ticket has turned into a ticket multiple times that size once I started asking questions. In those cases, I feel a bit silly for not having asked these questions earlier, and I also wonder why nobody else asked. I hope that this is something that I will get better at with time and experience, but in the meantime, I will ask myself - or maybe aloud - "is this ticket ready to be worked on?" when a ticket is about to be accepted. Asking this question is another great piece of advice. By asking it, I automatically think about how I would implement the ticket. But the question goes further and means: would somebody who isn't present in the grooming session be able to start working on the ticket? I used this tip in the last session, and it was my best grooming session yet.


