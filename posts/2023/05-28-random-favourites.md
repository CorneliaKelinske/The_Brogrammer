==title==
Random favourites 

==author==
Cornelia Kelinske

==description==
Here are 4 random things I've discovered that are making my developer life easier, more enjoyable and - yes - prettier.



==tags==
dev_life, personal



==body==


# 1. Graphite

[Graphite](https://graphite.dev/) is probably the tool that has made the biggest difference for me over the last few months. It makes it super easy
to stack PRs on top of each other and allows you to sync the whole stack at once if there are changes somewhere lower down the stack, including the base 
branch. I like working incrementally, breaking tasks down into smaller PRs that build on top of each other. While teammates usually appreciate it when they don't
have to review thousands of lines of code at once, the downside to my preferred modus operandi is that I would often see myself blocked, as I was waiting for a review, since stacking up
too many branches manually on GitHub can be quite a pain. 

With Graphite, I branch my first PR off the repo's main branch, start tracking this stack and can then add further PRs on top via the command line.
If somebody makes changes to the base branch, or if I make changes further down in my stack, I just have to navigate (in the terminal) into the lower-level branch with the changes and
run a single command, which then updates all the higher-up branches in one go.
In case of merge conflicts, you'll get a prompt to solve them, just as you would do with GitHub. But I also noticed that Graphite is better at resolving merge conflicts successfully 
on its own. 

One thing to be aware of: don't loose track of the order in which your PRs need to be merged. Technically, you should be good because GitHub shows you clearly what branch you're on and what branch the
current branch is coming from. But especially if you have a larger stack and multiple PRs get approved at once, it is possible to lose track or be too merge crazy. Trust me, I know what I'm talking about and it wasn't fun!
The other thing I had to learn the hard way: always rebase from the bottom when you merge in a branch. This ensures that merged branches get deleted from your stack, and you won't accidentally merge higher-up PRs into PRs that have already been merged and
shouldn't even be there anymore.

And last but not least: depending on how your team works, it might also be a good idea to let your teammates know that you're stacking PRs, so they can be more aware of merge order as well. While I assume that, usually, people don't merge
other people's PRs, there might be situations where you need an admin merge or where a teammate oversteps their boundaries and merges your PRs without being asked to do so.


# 2. Pink-Cat-Boo

I'm a sucker for a good VS Code theme and love trying different ones. In the past, I gravitated towards dark blue themes such as "Winter is Coming" and "Night Owl." But I wanted something a bit more fun and more pink (because why not?!). And that's how I came across "Pink-Cat-Boo." It's cute; it's pretty;, it makes me a happier programmer.

![Pink-Cat-Boo VS Code Theme.](boo.png "Pretty")


# 3. Crontab guru

Here is another helpful tool I recently discovered: [crontab guru](https://crontab.guru/). This one is a lifesaver when you want to schedule a cron job and you're not quite sure how the syntax works.


# 4. Lofi Girl

And last but not least: [Lofi Girl](https://www.youtube.com/watch?v=jfKfPfyJRdk). Beat to relax and study. The perfect coding music. And unlike all the "deep focus" playlists I found elsewhere, this one actually works for me. 
I don't lose focus, and it doesn't make me aggressive. Apparently, the livestream has been around since 2017. I'm disappointed that I only found out about this now.
Here is a link to a [Wikipedia article](https://en.wikipedia.org/wiki/Lofi_Girl).

You can even create your own avatar:

![My Lofi Girl Avatar.](lofi.png "Lofi")

 
