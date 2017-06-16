---
layout: post
title: 'Traffic prediction based on public transport performance in Pays de Gex (I)'
date: 2017-06-19
---

In the last months I have been working on a project to predict the traffic on the area where I live. This is the first post of a series that will cover all aspects of the project. In this one I give just the context.

I live currently in Pays de Gex, a stripe of land along the border between France and the Geneva canton, in Switzerland. I will summarize the socioeconomic details by saying that salaries and prices are much higher in Geneva than in Pays de Gex (like multiplying by 3, to get an idea), and many people working at CERN or UN are living in the cheaper Pays de Gex and commute every day to go to work. The opposite happens outside of working hours, when people in Geneva come to Pays de Gex for shopping, refueling, etc.

In the following map you can see Geneva surrounded by France except by the Vaud canton, at the northeast. Blue represents more or less water: Lehman lake and Rhône river. There is a brown mountain chain going from northeast to southwest: the Jura mountains (which give name to the Jurassic period). And there is the Pays de Gex between the Jura mountains and the Geneva canton.

![](/assets/pays-de-gex.jpg)

Note that Pays de Gex has two roads connecting it with the rest of France, one going down with the Rhône and the other going through the Jura. All the other roads connect with Switzerland, specially with the Geneva canton.

So basically there is a lot of people commuting through the border between France and Switzerland, which in almost all cases has just one lane and looks like this ([image source](http://naukas.com/2010/10/26/como-cruzar-la-frontera-franco-suiza-todos-los-dias/)):

![](/assets/frontera_cern.jpg)

From my personal perspective, it is a very nice area where nature is gorgeous and weather is acceptable (I come from Valencia, Spain, and I have a high standard regarding weather!). I can just put some boots on and go out to climb Le Reculet and do pictures like these:

![](/assets/reculet.jpg)

but somehow humans didn't manage well to set the rules there and they spend a lot of energy and time in their cars going here and there.

I rarely go to the swiss side but there are cases when you cannot avoid it. For example if I am flying, Geneva airport is 45 minutes by bus:

![](/assets/prediction-tpg.png)

... but this bus is crossing the border! So actually it can take 20 to 30 minutes more. So I decided to investigate what I could do, and it was this:

Geneva public transport system, [TPG](http://tpg.ch/), offers a REST API that allows querying the arrival time from their vehicles to each stop. Normally there is a relation between the time for the bus to get from one stop to the other, and in this case the relation is really strong because TPG public transport does not have a dedicated lane in Pays de Gex. As the following image shows, there are three TPG lines servicing in Pays de Gex: F, O and Y (recently I learned there are more!).

![](/assets/tpg-lines.jpg)

It came to my mind that I can have a near real-time traffic map by registering the time elapsed between a bus reaching two stops. Furthermore, if I keep a historic of all these data, along with weather conditions and work and school holidays I may be able to build a model and predict the traffic for the roads the buses use.

Next posts will be more technical and I'll write about:

* How do I gather the data and the problems I run into.
* How I am visualizing the gathered data.
* Analysis of the gathered data and prediction.


