---
title: MapReduce, Calcolo Parallelo, UNIMIB 
categories: italiano
tags: [Paolo, MapReduce, Calcolo Parallelo]
maths: 1
comments_id: 19
bigimg:
---

*  **[MapReduce a.a. 2019-2020]({{ site.baseurl }}/assets/mpi_74.pdf)**, in queste diapositive mostro un paio di modi
  per fare il prodotto matrice-matrice tramite MapReduce; in pratica ho fatto un adattamento e traduzione di quanto fatto da
 http://www.norstad.org  
 (Attenzione, il sito originale non sembre piu' raggiungibile, probabilmente tramite quei servizi che contengono un archivio di internet e' possibile trovarne una copia). 
Queste diapositive sono state usate durante il corso di "Sistemi di Calcolo Parallelo" tenuto persso il DISCo UNIMIB.

Durante il corso  ho usato inoltre due adattamenti di 
Python notebook: 

* **[HADOOP Streaming]({{ site.baseurl }}/assets/MapReduce-02-Hadoop_PA.ipynb)**, qui viene introdotto come usare degli eseguibili scritti
 nel linguaggio preferito per usare  Hadoop (invece che dover usare Java)


* **[MRJob]({{ site.baseurl }}/assets/MapReduce-04-MRJob_PA.ipynb)**, per utilizzare delle semplici classi di Python per
 job di tipo MapReduce anche complessi (e testarli facilmente in locale, senza dover installare Hadoop)

che avevo ricevuto durante le lezioni del CINECA del 2015, eventuali errori su queste versioni modificate sono miei e non da imputare agli autori dei notebook
originali.


A chi e' rivolto `MapReduce`? 

Una premessa: questa e' l'ultima parte del corso, prima introduco **[MPI]({{ site.baseurl }}{% link _posts/Paolo/2020-02-09-MPI-18-19.md %})**,
 poi **[OpenMP]({{ site.baseurl }}{% link _posts/Paolo/2020-02-09-OpenMP-18-19.md %})** 
e **[CUDA]({{ site.baseurl }}{% link _posts/Paolo/2020-05-26-Cuda.md %})**
, infine passo  HADOOP/MapReduce.

I primi 3 argomenti sono pertinenti per chi e' interessato a fare High Performance Computing. Richiedono di imparare 
nuove API, capire nel dettaglio come e' fatto l'hardware sottostante e scrivere dei codici abbastanza complessi.

Se invece lo scopo e' quello di utilizzare hardware (quasi) commerciale e di cercare di evitare
le problematiche legate ad imparare un nuovo linguaggio, allora ha senso pensare in termini di Hadoop/Mapreduce.

L'ipotesi di lavoro e' che si abbia a che fare con grandi moli di dati (che devono essere distribuiti su computer distinti).

L'idea e' proprio quella di facilitare buona parte della comunicazione necessaria quando si ha a che fare con
tante macchine che lavorano in parallelo. Per questo, molto del lavoro e' fatto dal filesystem distribuito (nel caso di HADOOP
si chiama HDFS). Il cuore di un calcolo MapReduce e' di utilizzare coppie `chiave-valore`.
Il compito/algoritmo da eseguire in parallelo deve poter essere spezzato in 2 fasi una di seguito all'altra, chiamate:

* `Map`

* `Reduce`

Durante la fase di Map, tanti computer in parallelo eseguono il medesimo compito (chiamato Mapping). 
Il risultato dell'esecuzione di ogni Mapper e' l'emissione di molte coppie chiave-valore (intermedie). 
Si suppone quindi che la prima parte dell'algoritmo da parallelizzare possa essere eseguito senza comunicazione
tra i vari Mapper. Essi fanno tutti la stessa cosa ma con parti diverse di dato (HDFS assegna i pezzi del dato senza un ordine particolare).
 Le coppie chiave-valore prodotte dai Mapper
vengono ridistribuite (**shuffling**) da HDFS ai Reducer, in un modo particolare: ogni reducer riceve **solo** coppie chiave-valore
che abbiano la stessa chiave.

Tutta la comunicazione di un job MapReduce si riassume quindi nella fase di `shuffling`!

A questo punto tutti i Reducer lavorano con i dati ottenuti ed emettono a loro volta coppie chiave-valore (il risultato finale del calcolo MapReduce).
Tutti i Reducer fanno esattamente lo stesso algoritmo, ma ognuno ha dei dati diversi opportunamente re-distribuiti tramite l'uso di coppie
chiave-valore.

Il `difficile` di un job  MapReduce e' proprio nel trovare le giuste coppie chiave-valore intermedie emesse dai Mapper che consentano di fare arrivare
ai Reudcer i dati corretti.

