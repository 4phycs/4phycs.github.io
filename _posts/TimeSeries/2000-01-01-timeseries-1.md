---
title: Time series analysis 1
published: false
maths: 1
tags: 
  - Machine Learning
  - Time series
categories: English
toc: 1
date: 2021-11-12
---
# Time series analysis 1: introduction 

This is going to be the first post regarding time series analysis. This post contains:
- An inttroduction regarding time series 
- The terminology and the initial definitions that will be used in all the other posts.
- The Table of contents of all the posts regarding time series analysis

## Introduction to time series
A time series is just a collection of ordered points, like this:

3.4   7.2   5.2  2.5   5.3   7.1  0.4  ...

Sometimes there is a timestamp associated to each point but it is 
not necessary. 
Often times one expects the time interval between two points to be constant in time, however it
is not so rare to find gaps between points. 

2014-Mar-29 18:02:24.250        29.25  
2014-Mar-29 18:02:40.250        28.05  
2014-Mar-29 18:02:56.250        27.897  
2014-Mar-29 18:03:12.250        24.717  
2014-Mar-29 18:03:44.250        21.364  
2014-Mar-29 18:04:00.250        27.179  
2014-Mar-29 18:04:16.250        28  
2014-Mar-29 18:04:32.250        26.825  
2014-Mar-29 18:04:48.254        26.675  
2014-Mar-29 18:05:04.250        26.43  

I am going to detail here some solutions regarding time series
that suppose the abasence of gaps between the points. I am also going to suppose that the time series is `univariate`. 
What does it mean? Simply speaking, imagine that you have a sensor that detects the temperature of a room
every 10 s. This gives rise to a univariate time series. If there is also a second sensor that determines 
the temperature at a different place in the room at each time interval you have a multi-variate time series (bi-variate in this case).
You can have as many as "sensors" as you wish.

In the example above, the sensor is going to give rise to about 3 million points in one year 
(I like to remember that the number of seconds of one year is about $\pi \cdot 10^7$ s). 

What can you do of all these points?
If you open them in a graph (for example with Matplotlib or Gnuplot) you can hardly understand anything.
You need to zoom the graph in a particular position in order to understand what is going on. This is a problem. You do not know in advance where are the "interesting" spots of the time series and you need 
some guidance to find them. 

Let's now take into account that time series often times present a certain degree of repetitivity. 

You can see this "boringness" of time series in many ways, some of them are extremely interesing from the
algortmic point of view.
In some cases, this repetitivity has a simple reason. Let's go back to the temperature
sensor we introduced earlier. We know that the temprature might be linked to the time of the day. During the night it might fall, while during the day it might increase (although AC units are thought to diminish these variations...).

Let's consider another example, your heart rate. The beats are similar to each other. They are not identical
to each other but indeed they are similar.
The fact that heart beat are similar is why a doctor **can** read a cardiogram. If there was no "repetition" the doctor would have
to examine each spot of the graph, and there would be no clear time scale. It would be 
essentially impossible to understand what is going on. The doctor can check for strange beats, 
simply because most of them exibit a normal behavior. 

`Anomaly` stems from **normality**. 

It might seem an obvious statement, but it becomes essentially useless to search for anomalies in an environment where there is no normal behavior. Think of a time series composed of points produced with 
a pseudo-random generator. You could probably measure average quantities and treat the single points as samples from a distribution but 
there would be no "structure".

An anomaly is an observation that differs substantially from the others. This is essentially the "definition" of 
anomaly you can find in resarch articles on the subject. It is estremely vague. 
However it tells us that anomaly detection is specific form of machine learning where one perfoms classification. There are 
just two classes:
- the normal observations:     this should be by far the most common class
- the anomalous observations: very few examples (if any) of this class should be known

In time series an observation is related to a sequence of the time series. What is a sequence? a set of successive points. For example
all the sets of 10 successive points (we can see later that an observation is related to a sequence but it is not necessarily the sequence itself). 
How many sequences of length s are there in a time series containing N points? it is very easy: N-s+1. You can see it simply by the fact
that at the tail of the time series, in the last 9 points you cannot have sequences. 
  It is about time to introduce a few definitions that will help during the rest of this brief discussion:

## Terminology

- The `length` of the `time series` is denoted with the capital $N$.
- We will denote the `points` of the time series as $p_j$ where $j \in [1,N]$ defines the order of the observation, for example $p_1$
  is the first point observed, $p_{100}$ is the 100th point observed and so on.
- A `sequence` is a series points one after the other. For example thit is a sequence of 4 points: $p_{10}, p_{11},
  p_{12}, p_{13}$. We denote the sequence by the time of its first point, for example, the above sequence is $10$, and its length $s=4$ 
- The length of a `sequence` is denoted with the lowercase letter $s$. If a sequence contains 10 points, then $s=10$.
- The `distance` between two sequences (sequence $l$ and sequence $m$ in this case) is just the Euclidean distance:
 $$ 
 \displaystyle
 d(l,m) = \sqrt{ \sum_{k=0}^{s-1} \left( p_{l+k}  - p_{m+k}  \right)^2}
 $$
When are two sequences similar to each other? Simply when the distance between them is small. At contrary when two sequences have a very high euclidean distance
one can say that the two sequences are very different.
- You can calculate the distance among all the couples of sequences. Just imagine a matrix with N rows and N columns. We
  instert the value of the distance between sequence $i$ and sequence $j$ is in the entry $M_{ij} = d(i,j)$. Clearly this takes $N^2$ distance calculations.
Some of these distances are rather useless: for example we know that the distance of a sequence with itself is 0. In some other cases no calculation is needed:
the distance is a symmetric function $M_{i,j}= M_{j,i}$.
- The `nearest neighbor` of sequence $j$ is a sequence denoted with $ngh(j)$
- The `nearest neighbor distance` of sequence j is denoted with  $nnd(j) = d\left(\frac{}{} j, ngh(j) \right)$. This might seem a bit convoluted
  but it is easy: the nearest neighbor distance of sequence $j$ is just the distance between $j$ and its nearest neighbor $ngh(j)$



## Discord
If I see the set of all possible sequences as vectors in space, I can consider that the isolated points, 
those that are fare away from all the others could be considered as anomalies. 

This idea was first formalized in the [this article]().
Take all the sequences and consider their nearest neighbor, i.e. the other function of the time series where there is the minimum distance. 



In order to have normality one should define some form of similarity. A very intuitive definition is given by the 


Let's consider a very famous definition of anomaly: discord. 
A discord is the sequence 











Enter text in [Markdown](http://daringfireball.net/projects/markdown/). Use the toolbar above, or click the **?** button for formatting help.
