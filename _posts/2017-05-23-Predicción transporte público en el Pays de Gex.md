---
layout: post
title: 'Predicción transporte público en el Pays de Gex'
date: 2017-05-23
---

In the last months I have been working on a project to predict the traffic on the area where I live. This a series of posts that will cover the following aspects of the project:

* Purpose of the project and workflow
* Implementation of the visualization
* Prediction

I live currently in Pays de Gex, a stripe of land along the border between France and the Geneva canton, in Switzerland. I will summarize the socioeconomic details by saying that salaries and prices are much higher in Geneva than in Pays de Gex, and many people working at CERN or UN are living in Pays de Gex and commute every day to go to work. The opposite happens outside of working hours, when people in Geneva come to Pays de Gex for shopping, refueling, etc. All these commutes take place through the border between France and Switzerland, which are normally just one lane wide and suppose a bottleneck, even more when border police is controlling.

[Bild mit Pays de Gex, Canton de Geneve und grenze]

From my personal perspective, it is a very nice area where nature is gorgeous and weather is acceptable (I come from Valencia, Spain, and I have a high standard regarding weather!). I can just put some boots on and go out to climb Le Reculet and do pictures like these:
[Bild von neues Jahr]
but somehow humans didn't manage well to set the rules there and they spend a lot of energy and time in their cars going here and there.

I rarely go to the swiss side but there are cases when you cannot avoid it. For example if you are flying, Geneva airport is 45 minutes by bus...

![](/assets/prediction-tpg.png)
[Reduce size]
... but this bus is crossing the border! So actually it can take 20 to 30 minutes more, depending on some variables that we'll see later. So I decided to investigate what I could do, and it was this:

Geneva public transport system, [TPG](http://tpg.ch/), offers a REST API that allows querying the arrival time from their vehicles to each stop. Normally there is a relation between the time for the bus to get from one stop to the other, and in this case the relation is really strong because TPG public transport does not have a dedicated lane in Pays de Gex. As the following image shows, there are three TPG lines servicing in Pays de Gex: F, O and Y.

[Bild from Y O und F]

It came to my mind that I can have a near realtime traffic map by registering the time ellapsed between a bus reaching two stops. Furthermore, if I keep a historic of all these data, along with weather conditions and work and school hollidays I may be able to build a model and predict the traffic for this issue.

The system consists of:

- Data gatherer process: Querying regularly the TPG and weather API's. [REFERENCE Posts]
- PostgreSQL/PostGIS database, That keeps the information gathered from the APIs 
- GeoServer. Shows a map using the last data gathered.



Next posts [UPDATE line 9]:

* Data gatherer (with references to other posts)
* Data model: Open Street Map usage and line
* Viewer: update materialized, watchdog, etc.
* EDA
* Prediction
