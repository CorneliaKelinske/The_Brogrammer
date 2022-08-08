==title==
Is it worth it? Or: What I learned from creating my own projects

==author==
Cornelia Kelinske

==description==
One piece of advice that is offered to aspiring new web developers is to leave the safe haven of tutorials and to
build own projects. I have followed this advice and can answer the title question with "Yes" (what a surprise!).
Here are 10 things I learned along the way.


==tags==
coding, personal

==body==


The valuable insights that I am sharing in this post are based on my work on these projects:
  - -- this website 
  - -- The Little Thinker's Space (a photo/video sharing app I built for my son; (https://the-little-thinkers-space.fly.dev/)) 
  - -- ex_robo_cop (a light-weight captcha library; https://hexdocs.pm/ex_robo_cop/README.html)

But now, without further ado, here is what I have learned:

# 1. Using different libraries


Especially The Little Thinker's Space was a great opportunity to work with various libraries and to 
practice everything that comes along with it:
- -- reading (and understanding) documentation
- -- reading typespecs
- -- installing and using different libraries with the help of the documentation and typespecs. 
As a result, I also discovered:


# 2. The value of good typespecs and documentation


I greatly appreciate when a library comes with clear instructions and examples. For somebody who is still at the beginning of their coding journey it can be rather frustrating and discouraging when the documentation for a library they intend to use to solve a problem and to make life easier is incomplete or unclear, thus turning the would-be solution to the original problem into yet another problem.

As far as typespecs are concerned, I might have identified my first developer cat peeve: missing return types! I want to know what comes out of the function! I also want to know the error return! Please and thank you! 


# 3. Some frontendy stuff 


I got to play around with both Bulma and Tailwind CSS (and discovered that House Music and front end work are an excellent pair).
While I was initially drawn to Bulma (which I used for this website), I ended up falling in love with Tailwind (which I used for The Little Thinker's Space).

In my completely subjective opinion, the initial effort required to create a decent looking page is smaller for Bulma,
but, spending a bit more time getting into Tailwind initially is worth it, as customization and future maintainability is much easier with Tailwind. Furthermore, with Phoenix 1.6 getting Tailwind running is a piece of cake. And, my favorite thing about Tailwind: as all the default CSS is removed, you will not spend way too much time trying to figure out why your formatting is not looking the way it should, only to find out that your custom CSS is clashing with some of the original, default CSS.


# 4. Planning the big picture


Creating your own project means you first of all have to know what it is you want to create. It also means you are the one who has to think about how to get to the final product.

I like using a mixture of mind mapping and random note taking when I am sorting through my ideas for a project. Once I have a rough idea of what I want my application to look like, I start thinking about the components I will need (database, controllers, templates) and the specific functionality I would like to provide in my app (e.g. video uploads).

As a last step, I will also outline a rough road map and figure out where I will start building.

I will then move on to:


# 5. Breaking it down into smaller steps (and losing the fear of writing the first line)


In the course of working on my projects, I have made it a habit to write tickets for myself. Once I have done all the steps described in point 4. above, I will pick the first piece of my project that I want to write and I break it down into smaller steps and I write myself tickets for each step (I am using [Shortcut](https://shortcut.com), a project management app for this, but even just a simple to-do list would probably do).

For example, let's assume I want to have a database table for users. Each user has a a name and an email. I will write myself a ticket that will look a bit like this:
- -- checkout branch
- -- create migration
- -- add unique index to email
- -- create Ecto.Schema
- -- add validations
- -- run mix check
- -- commit 
- -- merge
- -- pull

Thanks to this strategy, I already have a plan in place by the time I start writing the actual code and I'm not going in blindly.
And, what's even more valuable to me: by making my first step something as simple and easy as checking out my branch, I can trick myself into getting started on the task and/or project without procrastinating. 

Prior to adopting this approach of planning big steps and breaking them down into smaller ones, I sometimes froze a little, when the task at hand appeared to be huge and my coding ability small.


# 6. Dealing with setbacks


As described in points 5. and 6., I have process and I have a plan. But this does not mean that everything will go according to said plan. In fact, more times than not, the initial plan will have to be adjusted, slightly tweaked or, in some cases, even be thrown overboard.
And that's okay. I think handling setbacks is an important part of being a developer.

Here are some of the setbacks I have encountered in the course of my personal projects and ways to handle them:

- -- failing tests: read the error message! Make sure you remembered to re-assign the variables (because immutability).
- -- something works locally but crashes the production server: find a way to reduce the data load (caches, file compression etc.)
- -- you want to do something, but can't find a good library: build your own library 
- -- you find yourself at a dead end: take a break, go for a thinking walk (or whatever works for you) and start again fresh
- -- something seems to be way beyond your ability: don't hesitate to ask somebody more experienced for help


In short, don't give up! It's okay to pivot and to find workarounds. Find something that works. It can always be refactored and made prettier later.


# 7. Refactoring


# 8. Different ways of deploying (heroku and digital ocean vs fly.io)


# 9. Don't touch the docker file (unless you absolute have to)


# 10. Version upgrade


# 10. Others might not share the excitement - and that's okay