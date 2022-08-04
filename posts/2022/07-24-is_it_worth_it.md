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
- reading (and understanding) documentation
- reading typespecs
- installing and using different libraries with the help of the documentation and typespecs. 
As a result, I also discovered:


# 2. The value of good typespecs and documentation

I greatly appreciate when a library comes with clear instructions and examples. For somebody who is still at the beginning of their coding journey it can be rather frustrating and discouraging when the documentation for a library they intend to use to solve a problem and to make life easier is incomplete or unclear, thus turning the would-be solution to the original problem into yet another problem.

As far as typespecs are concerned, I might have identified my first developer cat peeve: missing return types! I want to know what comes out of the function! I also want to know the error return! Please and thank you! 


# 3. Some frontendy stuff 

I got to play around with both Bulma and Tailwind CSS (and discovered that House Music and front end work are an excellent pair).
While I was initially drawn to Bulma (which I used for this website), I ended up falling in love with Tailwind (which I used for The Little Thinker's Space).

In my completely subjective opinion, the initial effort required to create a decent looking page is smaller for Bulma,
but, spending a bit more time getting into Tailwind initially is worth it, as customization and future maintainability is much easier with Tailwind. Furthermore, with Phoenix 1.6 getting Tailwind running is a piece of cake. And, my favorite thing about Tailwind: as all the default CSS is removed, you will not spend way too much time trying to figure out why your formatting is not looking the way it should, only to find out that your custom CSS is clashing with some default code.


# 4. Planning the big picture


# 5. Breaking it down into smaller steps (and losing the fear of writing the first line)


# 6. Dealing with setbacks


# 7. Refactoring


# 8. Different ways of deploying (heroku and digital ocean vs fly.io)


# 9. Don't touch the docker file (unless you absolute have to)


# 10. Version upgrade


# 10. Others might not share the excitement - and that's okay