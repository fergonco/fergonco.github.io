---
layout: post
title: 'Logging sql commands on a docker postgresql instance'
date: 2017-02-27
---

When you have an application that queries big tables in your database it may happen that some inefficiency querying the database can slow down the whole application a lot. In this cases it is useful to get a log of the queries the database is receiving.

I had this issue while publishing with GeoServer road segments with speed attributes that change over time depending on traffic. The table has a lot of records and the application was struggling. In order to log the queries you just have to set *log_statement* to 'all' in *postgresql.conf*. But this time the PostgreSQL instance was in a docker container running the [Kartoza PostGIS image](https://hub.docker.com/r/kartoza/postgis/) so you don't have direct access to the *postgresql.conf*.

What I did was this:

1. Start Kartoza docker container
2. Copy their *postgresql.conf* to some folder, with this command:

```
docker cp <container>:/etc/postgresql/9.3/main/postgresql.conf /var/pg/postgresql.conf
```

3. Edit log_statement
4. Start the container again, this time mapping your own *postgresql.conf* file with `-v /var/pg/postgresql.conf:/etc/postgresql/9.3/main/postgresql.conf`

This allowed me to see easily that the web application was querying all the temporal instances of the speed measures at startup, which was killing the database server. Now it is fixed and I hope to post about the application soon.

