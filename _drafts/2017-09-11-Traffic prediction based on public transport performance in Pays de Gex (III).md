---
layout: post
title: 'Traffic prediction based on public transport performance in Pays de Gex (III): Data analysis and prediction'
date: 2017-09-11
---

This is the third part of the series on the project about traffic prediction. You can see it online here: [http://fergonco.org/border-rampage/](http://fergonco.org/border-rampage/).

In the [previous post]({{ site.baseurl }}{% post_url 2017-09-04-Traffic prediction based on public transport performance in Pays de Gex (II) %}) I introduced the process gathering data from public transport. 

In this one I will show the process of analyzing the data and generating predictions, in blue on the following diagram.

![](/assets/tpg/dfd0.png)

## Public transport network

Before we analyze the data we have to explain how the database is organized: how the public transport network data is stored in the database and how the real time data the system gathers references this network.

All the network data is provided by [OpenStreetMap](http://openstreetmap.org/). The Overpass API allows to download an XML file containing the nodes and paths that form the road network in that area:

	wget 'http://overpass-api.de/api/map?bbox=5.9627,46.2145,6.1287,46.2782' -O network.osm.xml

OpenStreetMap not only has the information about the roads but it also has the routes that the TPG services follow (Remember TPG stands for Transports Publics Genevois, the public transport company in Geneva). I made a program that, along with some manual information about the service lines, parses this information and generates the following three tables:

* The first one, *OSMSegment*, contains all the segments that form the TPG service routes:

  	 id | startnode  |  endnode   |     geom      
  	----+------------+------------+---------------
  	  1 | 3735051668 |  429658525 | LineString(42.23...
  	  2 |  768498823 | 3606163490 | LineString(42.24...
  	  3 | 3606163601 | 1549433399 | LineString(42.23...
  	  4 | 3790832523 | 3735051668 | LineString(42.22...
  	  5 | 3606163490 |  768498820 | LineString(42.21...
  	  6 |  932144719 |   35422066 | LineString(42.24...
  	  7 |  308047791 |   35422067 | LineString(42.25...
  	  8 | 1191965235 |  895572292 | LineString(42.21...
  	  9 |   35422062 | 1191965235 | LineString(42.23...
  	 10 | 3790832520 | 3790832523 | LineString(42.23...

![](/assets/osmsegment.png)

* The second one, *TPGStopRoute*, contains an entry for each pair of consecutive stops in a service line, along with the distance between them. Note that the start and end stop codes are not unique because there may be two lines with the same consecutive stops but with a different route between them. Hence the *line* field.

  	 id  | line | starttpgcode | endtpgcode |     distance      
  	-----+------+--------------+------------+-------------------
  	  72 | Y    | POLT         | PAGN       | 0.747157007209657
  	 103 | F    | LMLD         | ZIMG       | 0.685551031729394
  	 104 | F    | ZIMG         | LMLD       | 0.685551031729394
  	 105 | Y    | ZIMG         | PRGM       |  1.36371355797978
  	 106 | Y    | PRGM         | ZIMG       |   1.3855137325742
  	 107 | O    | PRGM         | SIGN       | 0.933634195084444
  	 108 | O    | SIGN         | PRGM       | 0.939506323487253
  	 110 | Y    | RENF         | SIGN       |  1.24229383530575
  	 112 | Y    | BLDO         | RENF       | 0.383096769721964
  	 125 | Y    | AREN         | PXPH       |  0.75218625106547

* The last one supports a many-to-many relationship between these two tables: for each pair of stops in specific a service line we associate a list of OSM segments.

![](/assets/tpgstoproute.png)

You can see the many-to-many relationship in the following diagram:

![](/assets/tpg/network-database-model.png)

## Gathered data and the unit of analysis

Having all the routes between two stops in the *TPGStopRoute* table, the data gathering process just fills a table with a foreign key to it. This table is called *Shift* and it contains data like this:

	   id   | seconds |  sourceshiftid  |   timestamp   | vehicleid | route_id 
	--------+---------+-----------------+---------------+-----------+----------
	 188508 |      77 | 1-4-2017+185220 | 1493643974000 | 185220    |      103
	 188509 |     144 | 1-4-2017+185221 | 1493644119000 | 185221    |      105
	 188510 |     112 | 1-4-2017+185222 | 1493644231000 | 185222    |      107
	 188470 |     138 | 1-4-2017+185082 | 1493642592000 | 185082    |      112
	 188471 |     144 | 1-4-2017+185083 | 1493642735000 | 185083    |      110
	 188472 |      75 | 1-4-2017+185084 | 1493642811000 | 185084    |      108
	 188473 |     119 | 1-4-2017+185085 | 1493642931000 | 185085    |      106
	 188477 |      93 | 1-4-2017+185319 | 1493643128000 | 185319    |      125
	 188474 |      80 | 1-4-2017+185086 | 1493643011000 | 185086    |      104
	 188466 |      39 | 1-4-2017+185015 | 1493642567000 | 185015    |       72

Each entry represents a vehicle reaching a stop and it contains the *timestamp* when it happened, the number of *seconds* elapsed since the previous stop and the *route_id*, which points to the *TPGStopRoute* and provides information about the exact route the vehicle followed.

Thus, as one could have expected from the beginning, the gathered information associates the **same data to all segments between two stops**. With the TPG API it is as far as one can go because we don't know what happens when the vehicle is between two stops. We just know that it reaches a stop.

I could have used this, the route between two stops, as the unit of the analysis. But I didn't because I have plans to add some private vehicle GPS tracks that could refine the data collected through the TPG API.

Therefore, the unit of the analysis is the OSM segment. There will many segments where the data gathered is exactly the same but I ignored it, expecting one day to refine the data we get as input.

## Data preparation

The process to prepare the data involves:

* Filtering out some obvious data errors.
* Removing duplicates introduced in some early version of the data gathering process.
* Calculating speed for each shift between stops.
* Generating variables: workday in France, workday in Switzerland, day of week, etc.

I use [R](https://www.r-project.org) for the statistics calculations and probably I could have managed to do the previous process with it. But I am not so proficient with its data structures and functions so I implemented it in Java. This is a tedious process and I think it is good to use a language you know well.

At the end of this process I got a CSV file containing a row for each shift and for each shift a column for all the variables I wanted to consider. This I could easily consume from R. The list of variables included in the CSV are:

* speed: speed between the two stops that contain this segment.
* timestamp: when was the speed measured.
* minutesDay: minutes since midnight.
* weekday: day of the week.
* holidayfr: binary, indicating if it is holiday in France.
* holidaych: binary, indicating if it is holiday in the Geneva canton.
* schoolfr: binary, indicating if children have school in France.
* schoolch: binary, indicating if children have school in the Geneva canton.
* humidity: the last registered humidity.
* pressure: the last registered pressure
* temperature: the last registered temperature.
* weather: A code indicating the type of weather (cloudy, sunny, rain, etc.) in the last weather measure.

I didn't mentioned before, but the gathering process also gathers data from the [OpenWeatherMap](http://openweathermap.org/) API each few hours.

## A look at the data

In order to take a look at the data I chose a segment whose pattern I know well: the one I always take to go to Geneva. And this was one at the CERN border, direction to Geneva:

![](/assets/eda-path.png)

Based on my experience, the pattern should be clear: on busy days it collapses in the mornings to go to work and the rest of the day is more or less free. Producing some charts more or less confirms this pattern.

First, the speed density plot shows two modes and is skewed to lower speeds.

![](/assets/eda/density.png)

I already expected the skew, due to the traffic jams in the morning, but the two modes were a bit surprising. A look to the density plot per day sheds some light:

![](/assets/eda/density-per-day.png)

To no one surprise, the speeds Saturdays and Sundays are, in general, higher and this is producing the second mode.

Another variable that could have some relation was the weather. I grouped cloudy and sunny weather together because I don't think it has an effect and left all the other weather conditions. I started to gather data at the end of the winter, so there is few data about adverse weather conditions. With a bit of imagination one could see bigger skew by rain or slower speeds by mist, fog and drizzle. But definitely there is not enough data.

![](/assets/eda/histograms-per-weather.png)

And of course, the time of the day is relevant. The next plot shows how the speeds drop between 7am and 10am. The time is expressed in minutes since midnight.

![](/assets/eda/minutesday.png)

Surprisingly, other variables didn't correlate with *speed*, like school holidays. Probably it is the case early in the year, when the weather is not so good, but now, specially during the summer, it has a strong influence. On the next iteration I should try to include some of these variables in the model.

## Model

The model I am using is wrong because I am using linear regression and speed is not a linear combination of the time of the day. But there were other aspects of the project that require my time, like data gathering, or visualization) and I decided to go for *anything*. And *anything* was a linear model with this equation (R notation, * means interactions between the variables):

	speed = minutesDay * weekday + weekday * weather

A residual plot would show, as expected, that they are not normal:

![](/assets/eda/residuals.png)

In the next iteration I should use some modeling technique that accommodates for the non linear relation between *minutesDay* and speed.

## Generating predictions

In order to get a map with predicted speeds I had to automate two processes.

The first one runs just once and would generate a model for each OSMSegment:

1. For each OSM segment
   1. Prepare the data for the segment
   1. Make R build a model
   1. Store the model in the *OSMSegment* table (we have a bytea field for this)

The second one takes the models and generate the forecasts based on the values of the variables we know:

1. For each OSM segment
   1. Get its model from the database
   1. Build a dataset with the variables we know: day of the week, weather, etc.
   1. Ask R to provide a forecast with the retrieved model and the generated dataset
   1. Store the forecast in the database

Sounds simple but it wasn't. There were several things that made implementing these two processes complicated. The two main difficulties were:

* Model size. *lm* function in R, which generates a linear model, produces objects whose size is around 500kb. Multiply this by 4000 OSM segments and you get 2 Gigabytes.

  But actually, in order to reuse the model I just need the coefficients that I multiply with the variable values to get the speed, so there had to be a way to keep the models much smaller.

  And, indeed, [there is a way](https://www.r-bloggers.com/trimming-the-fat-from-glm-models-in-r/), with the only problem that it involves the *glm* function (instead of *lm*) and I had to adapt the R script. Finally I ended up with 15Kb models, which was much better.

* R script. Both processes are executed from Java as new system processes. Initially I called the R script for each OSM segment. Launching 4000 processes is a bit slow so I changed the R script to deal with all the segments in one execution. This time, although it is still a lot of computation, the performance was enough to let the server run it each half an hour or so. Maybe using some R Java API like [rJava](https://www.rforge.net/rJava/) could improve performance even more.

## Next steps

The process is working but it took so much effort to have the whole system running that I finished the bare minimum and there are many things I can do to improve it.

* The first one is to improve modelling.

  * As said before, linear modelling does not adapt to this problem. I have transformed the *minutesDay* variable to show some linearity with speed but this is a particular case for each segment and difficult to automatize it. So, I'll apply more advanced techniques.

  * Now that I have a good understanding of the data it is a good opportunity to start digging into machine learning techniques and see how it compares to other more classical techniques.

  * I will Investigate further thee relation between holidays and speed and include them in the model.

* Next, I would like to validate the predictions. Currently, I do this by opening the map and turning from the latest measure to the first forecast to see that the map does not change much. It does not look bad but of course this is not a very strict evaluation method. I would like to analyze the deviations between forecast speeds and actually measured ones.

* And finally, and quite far in the future, I would like to include GPS tracks to have a finer map. Maybe find relations between public transport and private GPS tracks and extend the map to areas not covered by public transport.

## Lessons learned

Just one, but important: Data gathering is key for the success of the project and it is very easily to get noise, errors, etc. in your data. It is important to check the data gathering process early: do some cleaning on the data and some exploratory analysis that would show if there are weird data.
