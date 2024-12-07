==title==
How to configure your database on fly.io for connection with DataGrip

==author==
Cornelia Kelinske

==description==
I have some apps (including this one) deployed on [fly.io](https://fly.io/). It's very convenient and deploying is easy. However, I was struggling a bit when I wanted to connect DataGrip to the production database of my latest app. This post is for anyone who finds themselves in a similar situation, including future me. 


==tags==
coding, elixir, fly.io, datagrip, database

==body==

# 1. The goal

I'm currently working on building a [web app](https://women-in-tech-vic.fly.dev/) for my [Women in Tech Victoria](https://www.meetup.com/women-in-tech-victoria/) meetup group.
As far as passion projects go, this one is a bit more ambitious, since people in the not-so-far future will likely use it.
Therefore, I decided to hook up my DataGrip to the production database so I would have easy access to production data. Fly.io has [documentation](https://fly.io/docs/postgres/connecting/connecting-external/),
however, there were a few hick-ups along the way.


# 2. The starting point

My app is a vanilla LiveView app with a Postgres database. When you create your database in the app before you first deploy,
Fly will automatically create a database app for your application. What's important, though, is that the database for
your web app is deployed separately, in its own container. 
 

# 3. Allocating an IP address

By default, your database app is created with a private IP address only. But to connect to an external service, such as DataGrip, you need a public IP address. Following the [Fly Docs](https://fly.io/docs/postgres/connecting/connecting-external/), I ran

```
fly ips list --app <pg-app-name>
```
to double-check my IP addresses. (If you're not sure what the name of your `pg-app` is, you
can find it on your Fly dashboard, but I believe it is usually just the name of your main application with `db` appended.) Running this command will 
also show you whether your app supports IPv6. 

Once I had confirmed the lack of a public IP address, I ran

```
fly ips allocate-v6 --app <pg-app-name>
```
to allocate an IPv6 address. If your app supports IPv6, I suggest
you go with an IPv6 address. At the time of writing, IPv4 addresses cost $2 per month, unless you go with a shared address.


# 4. Configuring and redeploying the database app 

To configure your database app for connections with external services, you need a `fly.toml` file. You can pull one down from
Fly by running 
```
fly config save --app <pg-app-name>
```
This is where you have to be careful: if this command is run inside the main 
LiveView app, it overwrites the `fly.toml` in there. Since the database app is deployed separately, you need to handle it separately from your main app.
I created a separate directory and ran the command from there. The `fly.toml` that I pulled down, already had the correct configuration:

```
[[services]]
  internal_port = 5432 # Postgres instance
  protocol = "tcp"

[[services.ports]]
  handlers = ["pg_tls"]
  port = 5432

```

Once again following along with the docs, I checked which version of Postgres I was running via this command:

```
fly image show --app <pg-app-name>
```

Next up was the deploy command, but this is where I had to stray from the docs. The command provided there led to a `Could not find image` error.
It took me a while to find out that I had to run this

```
fly deploy --app women-in-tech-vic-db --image flyio/postgres-flex:16
```
instead. Also, make sure you're running this command from within
the directory with the Postgres `fly.toml`. You can verify the newly deployed configuration by running: 

```
fly services list
```

 This should give you:

```
Services
PROTOCOL        PORTS                   FORCE HTTPS
TCP             5432 => 5432 [PG_TLS]   False
TCP             5433 => 5433 [PG_TLS]   False
```


# 5. Accessing the database via psql

At this point, you should be able to access your Postgres database via psql, using this command:

```
psql "sslmode=require host=<pg-app-name>.fly.dev dbname=<db name> user=<username>"
```

You will get prompted for your password.

There are a few gotchas:
*   `dbname`: it's not postgres! It's the name of your Postgres app without the "-db" part and with underscores. So, for example, for my `women-in-tech-vic-db` app, the database name is `women_in_tech_vic`
*   `username`: postgres
*   Password for postgres: you can find that one out by sshing into the fly console (`fly ssh console`) of your database app and then running `echo $OPERATOR_PASSWORD`

Once you have successfully accessed the database via psql in your terminal, you have all you need to set up your DataGrip connection.
I use a `.pgpass` file for authentication, and so the info that I enter into DataGrip is as follows:

*   Host: `<pg-app-name>.fly.dev`
*   Port: 5432
*   Database: `<pg_app_name>` without the "db" and underscores (see above)
*   User: postgres
*   Authentication: pgpass

And my `.pgpass` file looks like so:

```
<pg-app-name>.fly.dev:5432:`<pg_app_name>:postgres:<PASSWORD>
```

Time to play with some production data! 

![This is where you should see a crazy scientist picture](mouahahah-rire-diabolique.gif "MOUAHAHAH")










