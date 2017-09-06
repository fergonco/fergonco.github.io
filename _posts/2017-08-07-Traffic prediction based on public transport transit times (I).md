---
layout: post
title: 'Traffic prediction based on public transport transit times (I)'
date: 2017-08-07
---

In the last months I have been working on a project to predict the traffic on the area where I live. This is the first post of a series that will cover all aspects of the project. In this one I give just the context.

I live currently in Pays de Gex, France, a stripe of land that runs along the border with the Geneva canton in Switzerland. I will summarize the socioeconomic details by saying that salaries and prices are much higher in Geneva than in Pays de Gex (like multiplying by 3, to get an idea), and many people working at CERN or UN are living in the cheaper Pays de Gex and commute every day to go to work. The opposite happens outside of working hours, when people in Geneva come to Pays de Gex for shopping, refueling, etc.

In the following map you can see Geneva, which is surrounded by France except by the Vaud canton at the northeast. Blue represents more or less water: Lehman lake and Rhône river. There is a brown mountain chain going from northeast to southwest: the Jura mountains (which give name to the Jurassic period). And there is the Pays de Gex between the Jura mountains and the Geneva canton.

![](/assets/tpg/pays-de-gex.jpg)

All the commutes between Pays de Gex and Geneva are done, therefore, through the border between France and Switzerland, which in most cases has just one lane and looks like this ([image source](http://naukas.com/2010/10/26/como-cruzar-la-frontera-franco-suiza-todos-los-dias/)):

![](/assets/tpg/frontera_cern.jpg)

I don't have a picture but you can imagine hundreds of cars passing by at the same hour and maybe a policeman stopping the row every now and then.

From my personal perspective, it is a very nice area where nature is gorgeous and weather is acceptable (I come from Valencia, Spain, and I have a high standard regarding weather!). But somehow humans didn't manage well to set the rules there and they spend a lot of energy and time in their cars going here and there.

In my case, I rarely go to the Swiss side but there are cases when I cannot avoid it. For example if I am flying, Geneva airport is 43 minutes by bus:

![](/assets/tpg/prediction-tpg.png)

But the way to the airport crosses the border, so if you are going at the same time as hundreds of other cars, it can actually take 20 to 30 minutes more, which can be quite inconvenient if you are taking a flight!

After experiencing personally some episodes of this type I decided to build something to observe and predict the state of the border passages. And this is what I did:

Geneva public transport system, [TPG](http://tpg.ch/), offers a REST API that allows querying the arrival time from their vehicles to each stop. Normally there is a relation between traffic congestion and the time for the bus to get from one stop to the other, and in this case the relation is really strong because TPG public transport does not have a dedicated lane in Pays de Gex.

As the following image shows, there are three TPG lines servicing in Pays de Gex: F, O and Y (recently I learned there are more!).

![](/assets/tpg/tpg-lines.jpg)

It came to my mind that I can have a near real-time traffic map by registering the time elapsed between a bus reaching two stops. Furthermore, if I keep a historic of all these data, along with weather conditions and work and school holidays I may be able to build a model and predict the traffic for the roads the buses use.

You can see the real-time map here: [http://fergonco.org/border-rampage/](http://fergonco.org/border-rampage/).

Next posts will deal with the technical details about:

* How do I gather the data and the problems I run into.
* How I am visualizing the gathered data.
* Analysis of the gathered data and prediction.


