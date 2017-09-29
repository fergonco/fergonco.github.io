---
layout: post
title: 'Yet another way to increase INSERT performance in PostgreSQL'
date: 2017-09-29
---

In this post I will show a way to improve the performance when doing many inserts on a PostgreSQL database. The database server is a PostgreSQL 9.3.14 instance running in a Docker container with the PostGIS extension installed. The data used for the tests consists of around 330.000 records containing small geometries (lines of just two points). The particularity of using PostGIS geometries is not very relevant for the tests, it is just the data and setup I had at hand.

There are several methods to insert data in a PostgreSQL database efficiently. Tweaking Postgresql parameters can be effective if you know how. Removing indices before the insertion and building them again afterwards also helps. The same can be done with constraints, taking care that the data does not violate them! And the *COPY* statement is also an efficient way to do insertions.

I recently discovered another method that is similar to *COPY* in the sense that it just changes the syntax to insert the data, but that requires a very small syntactic change. It takes advantage of the fact that *INSERT* statements allow to include several records in one single statement:

	INSERT INTO <table> VALUES (record1), (record2), ..., (recordN);

In order to get the speed up, the test will compare the time taken to insert the data with this syntax with the time to insert the data using one *INSERT* per record. A test will load two files, each of them containing the same data, which consists of around 330.000 records. The first one, *manyinserts.sql* contains one insert per record and looks so:

	BEGIN;
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499326067094, 31.5639523033815,11.460813, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499326967094, 31.9051328361529,11.456651, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499327867094, 32.2274189752126,11.453045, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499328767094, 32.5336403079748,11.449911, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499329667094, 32.8259836166461,11.447187, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499330567094, 33.1061804492532,11.44482, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499331467094, 33.3756296870072,11.44277, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499332367094, 33.6354806887716,11.441004, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499333267094, 33.8866914846482,11.439491, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES(1499334167094, 34.1300706021326,11.4382105, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326));
	...
	COMMIT;

The second file, *oneinsert.sql* takes advantage of the mentioned *INSERT* syntax and will issue just one statement:

	BEGIN;
	INSERT INTO mytable (millis,speed,predictionerror,geom) VALUES
	(1499326067094, 31.5639523033815,11.460813, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	(1499326967094, 31.9051328361529,11.456651, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	(1499327867094, 32.2274189752126,11.453045, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	(1499328767094, 32.5336403079748,11.449911, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	(1499329667094, 32.8259836166461,11.447187, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	(1499330567094, 33.1061804492532,11.44482, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	(1499331467094, 33.3756296870072,11.44277, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	(1499332367094, 33.6354806887716,11.441004, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	(1499333267094, 33.8866914846482,11.439491, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	(1499334167094, 34.1300706021326,11.4382105, ST_GeomFromText('LINESTRING (6.0641721 46.3374997, 6.0638603 46.3373874)', 4326)),
	...;
	COMMIT;

The test is inserting the data in this table:

	test=> \d mytable
					 Table "public.mytable"
		 Column      |           Type            | Modifiers 
	-----------------+---------------------------+-----------
	 millis          | bigint                    | 
	 speed           | double precision          | 
	 predictionerror | double precision          | 
	 geom            | geometry(LineString,4326) | 

Executing with one INSERT per record it takes 1m 21s:

	$ time psql -h localhost -U user -d test -f manyinserts.sql
	BEGIN
	INSERT 0 1
	INSERT 0 1
	...
	INSERT 0 1
	INSERT 0 1
	INSERT 0 1
	COMMIT

	real	1m21.256s
	user	0m9.844s
	sys	0m8.172s

Executing the script with just one INSERT for all records takes just 15s:

	$ time psql -h localhost -U user -d test -f oneinsert.sql
	BEGIN
	INSERT 0 330624
	COMMIT

	real	0m14.772s
	user	0m0.496s
	sys	0m0.184s

Which gives a speed up of 81s/15s = 5.4.

It is surprising the amount of overhead that a SQL statement has. And we have to take into account that in both cases there is a cost associated to the parsing of the geometry text. Without it, both cases should get their execution time reduced, resulting on a higher speed up, shouldn't it?

