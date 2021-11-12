---
published: false
---
# Time series anomaly detection

A time series is just a collection of ordered points. Sometimes there is a time stamp associated but it is no necessary. Often times one expects the interval between two points to be constant in time, however it
is not so rare to find gaps between points. I am going to detail here some solutions regarding time series
that suppose the abasence of gaps between the points. I am also going to suppose that the time series is univariate. 

What does it mean? Simply speaking, imagine that you have a sensor that detects the temperature of a room
every 10 s. This gives rise to a univariate time series. If there is also a second sensor that determines 
the pressure inside the room at each time interval you have a multi-variate time series (bi-variate).

In the example abobe the sensor is going to give rise to about 3 million points in one year (I like to remember that the number of seconds of one year is about $\pi * 10^7$. 

What can you do of all these points?
If you open them in a graph (for example with Matplotlib or Gnuplot) you can hardly understand anything.
You need to zoom the graph in a particular position in order to understand what is going on. This is a problem. You do not know in advance where are the "interesting" spots of the time series and you need 
some guidance to find them. Time series often times present a certain degree of repetitivity. 

You can see this "boringness" of time series in many ways, some of them are extremely interesing from the
algortmic point of view some others are simpler.
For example you know that phoenomena show a certain degree of repetition. Let's go back to the temperature
sensor we introduced earlier. We know that the temprature might be linked to the time of the day. During the night it might fall, while during the day it might increase (although AC units are thought to diminish these variations...).

Let's consider another example, your heart rate. The beats are similar to each other. They are not identical
to each other but indeed they are similar, that's the reason why a doctor can read a cardiogram: it contains way less information than you think. The doctor can go and check for anomalies and strange beats, simply because most of them exibit a normal behavior. 

From normality stems anomaly. 

It might seem an obvious statement, but it becomes essentially useless to search for anomalies in an environment where there is no normal behavior. Think of a time series composed of points produced with 
a pseudo-random generator. 




Enter text in [Markdown](http://daringfireball.net/projects/markdown/). Use the toolbar above, or click the **?** button for formatting help.
