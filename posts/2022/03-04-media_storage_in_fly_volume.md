==title==
How to use fly volume storage for media uploads

==author==
Cornelia Kelinske

==description==
I recently deployed my latest Phoenix project with the help of fly.io and decided to use a Fly volume for
storing the multimedia files uploaded via the app. Read on to find out what I learned.


==tags==
coding

==body==

# 1. The problem


In the last [post](https://connie.codes/post/media_upload_to_database), I described how I stored image and video uploads for 
a small-scale phoenix app as binary directly in the database. I have since deployed said app on [fly.io](https://fly.io/) and quickly realized that while my storage solution worked well for images, video files were a different story. I was able to upload and display videos without issue when I was using the app in production on my computer, but on mobile devices, videos would either not load properly and be jumpy or the wheel of death would appear and spin indefinitely. I had also added some more complexity to my code by compressing uploads prior to their storage and that, in combination with the storage as binary, was more than the server was able to handle. 


# 2. The solution


After the initial impulse to delete the app and throw my computer out of the window ([The Dark Side of becoming a web developer](https://connie.codes/post/the_dark_side)), my first thought was to use Amazon S3 storage. But in a lucky turn of events I discovered that fly.io actually offers a persistent storage option in the form of data volumes that can be easily connected to your app (https://fly.io/blog/persistent-storage-and-fast-remote-builds/). The initial set-up takes less than 5 minutes. You just have to follow the instructions [here](https://fly.io/docs/reference/volumes/). Everything worked. I logged into the remote console and created a file in my volume, which was still available after I had redeployed my app.


# 3. Where things got tricky 


It all seemed very straightforward until I tried to display the videos and images stored in the volume in my templates. Nothing showed. "Ah, of course", I thought, "the files are in the wrong folder. It has to do with `Plug.Static`. They need to be in the `priv/static directory`." I then set the storage path for my uploads accordingly. To this end, I used an environment variable that I set in my `prod.exs` file like so:

```
config :my_app, data_path: "priv/static/data"
```

I changed the section in the `fly.toml` file that mounts the volume in the app from the default destination to this:

```
[[mounts]]
  source="my_app_data"
  destination="/priv/static/data"
```

And last but not least, I added the data folder to the "only" line in the `Plug.Static` set-up in the `endpoint.ex` file:

```
plug Plug.Static,
    at: "/",
    from: :my_app,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt data)
```

It worked. Locally. But not in production. A rather intense time (I'm not going to say how much) of me trying to figure out what the heck was going on ensued. There were two aspects to this problem that did not make sense to me whatsoever. Especially in combination with each other. 

1. Why did it work in development and not in production?
2. If something was wrong with my static path (I figured that the problem had something to do with `Plug.Static`), why were other   images such as my background image and icons that were saved in my `priv/static/images` folder displayed in production without any problems?


# 4. The solution (for the solution)


I did a lot of online research. I tried to configure my `Plug.Static` differently. I tried to add a second `Plug.Static`. All efforts were in vain. Eventually I came across this thread: https://community.fly.io/t/how-do-i-configure-a-phoenix-app-to-store-and-serve-uploaded-images-via-a-fly-io-volume/3379

After reading this, I decided to look at the filesystem of my deployed app again. I used the `fly ssh console` command in my terminal to log into the app. I "cd-ed" from my top-level directory all the way into the `priv/static/directory`. There I noticed something interesting: the image folder did not contain the images that were stored in said folder locally on my computer (such as the background image). This discovery is when things finally clicked into place. I went all the way up into the top-level directory. From there, I went down the path described in the aforementioned thread: `app/lib/my_app-version.number/priv/static/`. Lo and behold, the image folder in this directory contained all the images that were in my `static/images` folder in development! 

Bingo! I changed the configuration in my `prod.exs` file to

```
config :my_app, data_path: "app/lib/my_app-version.number/priv/static/data"
```

and the mount in my `fly.toml` to

```
[[mounts]]
  source="my_app_data"
  destination="/app/lib/my_app-version.number/priv/static/data"
```

and voilà: my images and videos were finally displayed in production.


# The takeaway


In an app deployed via fly.io, the static path is no longer just `priv/static/` but instead `app/lib/my_app-version.number/priv/static`. Any images or videos that are uploaded via the deployed app in order to be served in the templates via `Plug.Static` will therefore have to be stored in this nested `priv/static` directory.


