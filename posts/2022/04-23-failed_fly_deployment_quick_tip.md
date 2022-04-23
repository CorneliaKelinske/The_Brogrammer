==title==
Easy fix for failed deployment on fly.io

==author==
Cornelia Kelinske

==description==
I am a big fan of fly.io and am using them for all my deployed projects (including this site). Over the last weeks,
I have been deploying and re-deploying quite a bit and once in a while deployment failed for no obvious reason.
Here is a quick (potential) fix that has worked for me.


==tags==
coding

==body==

# 1. What the heck is going on?!


A few weeks ago I deployed an app on [fly.io](https://fly.io/) for the first time. I loved the whole deployment experience so much that I moved this site over to fly.io as well. From what I understand from the few apps that I have deployed in my, at this point, still young developer life, it can take a while to get the initial deployment right. There might be programs that need to be installed on the deployment server, there are secret keys and lines of code have to be in a certain place in the Dockerfile. However, once the first production version is successfully deployed, small future changes can usually be pushed up without any issues (unless you do something crazy that requires changes to the Dockerfile). Or so I thought...

And then this happened: I had made a teeny tiny change to a project (something like writing a new blog post), I typed in my `fly deploy` command and I left to make some coffee. To my surprise, I came back to a message in my terminal that informed me that the deployment had failed. Since I knew that there had been no major change to my app since the last successful deployment, I just assumed that there must have been some kind of glitch and typed in `fly deploy` again. Albert Einstein said "Die Definition von Wahnsinn ist, immer wieder das Gleiche zu tun und andere Ergebnisse zu erwarten" or, for all non-German speakers: "The definition of insanity is doing the same thing over and over again and expecting a different result." He was proven right yet again. My deployment failed for the second time. I did, however, notice that the error message (YES, I AM READING MY ERROR MESSAGES NOW) had changed. It still did not make any sense to me.


# 2. A quick fix


It took me a while to figure out what was going on, but the fix I found is surprisingly easy: I deleted my fly-builder and redeployed. As part of that redeployment, a new builder was created and my app was deployed successfully.
When I encountered the same issue of a surprise failure to deploy with a different app, my fix worked again.

Will it work for you? Time to find out. Here is a comprehensive list of the 3(!) commands you will need:

1. `flyctl list apps` gives you a list of all your apps including your builder. 

2. `flyctl destroy [BUILDERNAME] ` destroys the builder.

3. `fly deploy` deploys your app (at least if this was indeed the solution to your deployment problem)

Good luck!

