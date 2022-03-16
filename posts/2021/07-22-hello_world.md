==title==
Where to start?

==author==
Cornelia Kelinske

==description==
From translating to writing code. The beginning of my coding journey.


==tags==
personal,coding, brostuff

==body==

My coding journey began with a friendly ....  

                                
# "Hello World"  


... printed in Python way back in 2018. My husband, who at that time worked as an HVAC mechanic, had just discovered programming for himself and
challenged me to try it as well. What can I say? I am very competitive and at some point said jokingly that one day I would be better at programming than him. 
(Needless to say, that day has not come yet, but I might have out-pythoned him, simply because I stuck with it for longer.)
At first, the reason why I enjoyed coding was not so much the fact that I could use my code to actually do stuff (because, to be honest, I really didn't), 
but the pure problem-solving aspect of it. 


For the next few years, I kept coding on the back-burner. I tried to fit a short session in every day, but my translation business was thriving and I didn't have any
real coding goals or projects. I completed the Complete Python Bootcamp on [udemy](https://www.udemy.com/), taught by Colt Steele, an amazing teacher (check out his YouTube
channel: (https://www.youtube.com/c/ColtSteeleCode), and I kept solving the exercises on the [exercism](https://exercism.io/) Python track, but at that time, my relationship to code was certainly lacking passion.

And then something happened: I actually used Python to build something, namely an MRV calculator. For everyone who is not familiar with the whole strength training 
vocabulary:
MRV stands for Maximum Recoverable Volume. It means the maximum number of hard working sets that you can do each week and that your body can recover from so you can still build muscle and get stronger. It is really well explained in the [Scientific Principles of Strength Training](https://www.youtube.com/watch?v=k7_kCLHOl_0&list=PL1rSl6Pd49IlsiAgFRWNI1ruDGNrMJ092) video series by Juggernaut Training systems, which was in fact the inspiration for my little project. Fun fact: when I started using the Juggernaut AI training spreadsheets for my lifting, I compared the numbers that I got out of my MRV calculator with the MRV values listed for me in the excel files, and lo and behold, they did match!  

And here, without further ado, the MRV calculator in HORRIBLE python spaghetti code...



```
#variables
gender = input("What is your gender? [m/f] ")
weight = int(input("What is your weight in pounds? [number only] "))
height = int(input("How tall are you in cm? [number only] "))
exp = int(input("For how many years have you been strength training? [number only] "))
age = int(input("How old are you? [number only] "))
diet = input("How is your diet? \na: poor \nb: average \nc: good \n[a b or c] ")
sleep = int(input("How many hours of sleep do you usually get? [number only] "))
stress = input("How much stress do you experience in your daily life? \na: a lot \nb: average \nc: not much \n[a b or c] ")
recov = input("How is your recovery?  \na: poor \nb: average \nc: good \n [a b or c] ")

Hyper_MRV_av = {"Hypertrophy Squat:" : 13, "Hypertrophy Bench:" : 17, "Hypertrophy Deadlift:" : 9}
Strength_MRV_av = {"Strength Squat:" : 9, "Strength Bench:" : 12, "Strength Deadlift:" : 6}
Peak_MRV_av = {"Peaking Squat:" : 5, "Peaking Bench:" : 6, "Peaking Deadlift:" : 3}

phases = [Hyper_MRV_av, Strength_MRV_av, Peak_MRV_av]

print("Your MRVs are as follows:")

for phase in phases:
    for lift, MRV in phase.items():
        if gender == "f":
            MRV +=5
        else:
            MRV = MRV

        if weight < 148:
            MRV += 4
        elif weight in range(148, 165):
            MRV += 2
        elif weight in range(165,221):
            MRV -=2
        else:
            MRV -=4

        if height < 160:
            MRV += 2
        elif height in range (160,176):
            MRV += 1
        elif height in range (176, 191):
            MRV -= 1
        else:
            MRV -=2

        if exp < 4 or exp in range (9, 13):
            MRV = MRV
        elif exp in range (4, 9):
            MRV += 2
        else:
            MRV -= 2

        if age < 19:
            MRV += 2
        elif age in range (19, 30):
            MRV += 1
        elif age in range (30, 40):
            MRV = MRV
        elif age in range (40, 50):
            MRV -= 2
        else:
            MRV -=4

        if diet == "a":
            MRV -= 3
        elif diet == "b":
            MRV = MRV
        else:
            MRV += 1

        if sleep < 6:
            MRV -= 3
        elif sleep > 8:
            MRV += 1
        else:
            MRV = MRV

        if stress == "a":
            MRV -= 3
        elif stress == "b":
            MRV = MRV
        else:
            MRV += 1

        if recov == "a":
            MRV -= 3
        elif recov == "b":
            MRV = MRV
        else:
            MRV += 1
        
        print(lift, MRV)

```

While this code is not pretty, it gave me my first little taste of what it feels like to use code for something that I am passionate about.

Fast forward to 2020/2021: I saw drastic changes in my translation business. On the one hand, the overall number of translation jobs declined significantly and, on the other,
there was a massive shift away from typical translation jobs, where I would receive a source text and translate it into another language, to MTPE (machine translation post editing) jobs, where I would receive a source file along with a machine translation of said file, and edit the machine translation.
Of course, MTPE had been around for quite some time and there had been some MTPE jobs here and there, but literally within months, the majority of my translation requests turned into MTPE requests. I might elaborate on my thoughts on machine translation in a separate post some time, but I am generally open-minded towards MT and believe that for some text types, MT can actually be on par with human translation. Yet, there are text types and jobs, for which it is not suited and thus ends up causing the translator more work than an actual translation while paying about half the price.

The other drastic change that occurred for me in early 2021 was that I fell in love. With Elixir. My husband had been bugging me over and over to stop fiddling around with Python and front-end stuff (Colt Steele also has a Web Developer Bootcamp for HTML, CSS, Javascript on udemy) and to learn Elixir. 
I knew two things: I wanted to leave the sinking ship of my translation business while it was still afloat and I would not be able to get a job with python. So I started on Elixir.
It was amazing. To me, FP (functional programming) appears much more intuitive and logical than OOP (Object-Oriented Programming).
I am having a lot of fun with it.

For the past few months, I have accepted hardly any translation jobs at all and have instead focused on learning Elixir and actually working on my own projects.
The first project is this little website. The other one is something that I am creating for my son. But it is still early stages, which is why I am keeping it secret for now.

To conclude with, I can say that at the current stage of my coding journey, I am feeling more passionate about coding every day, I am excited about learning more and putting my code to use. And I am grateful for having a husband who is able to mentor me and to bring home the bacon while I am getting up to speed.  





