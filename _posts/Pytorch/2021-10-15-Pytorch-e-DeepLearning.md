---
title: DeepLearning con Pytorch
published: true
categories: italiano
tags:
  - Python
  - DeepLearning
  - Neural Nets
  - Cuda
maths: 1
comments_id: 13
toc: 1
---
# PyTorch e Deep Learning

## Introduzione a queste note

Queste sono le mie note (Paolo Avogadro) su PyTorch e reti neurali in genere. La maggior parte del materiale e' una traduzione delle  lezioni di **[Python Engineer](https://www.youtube.com/channel/UCbXgNpp0jedKWcQiULLbDTA)** (Patrick Loeber):


Le lezioni di Python Engineer contengono dei riassunti di teoria, ma per capire a fondo il motivo di quello che viene fatto e' bene avere una solida base di come funzionano le reti neurali. Per una buona introduzione teorica che permetta di capire meglio la logica dietro le scelte di programmazione e di modellazione delle reti neurali consiglio questo **[corso introduttivo](https://www.youtube.com/watch?v=5tvmMX8r_OM&ab_channel=AlexanderAmini)** del MIT.  

In alcuni casi ho preso direttamente i codici di Patrick Loeber (forniti nei link alle sue lezioni), ma nella maggior parte dei casi li ho riscritti (sempre seguendo il video), quindi potrebbero esserci delle piccole differenze. Questo e' anche dovuto al fatto che questi codici sono pensati per girare all'interno di un notebook, mentre Python Engineer usa Vstudio Code.  Per esempio, quando Patrick vuole mostrare alcuni grafici tramite Matplotlib deve lanciare dei comandi che non servono qui. 
Piu' di una volta mi e' capitato avere dei problemi con i codici. Spesso il motivo era una mia errata comprensione dei  video che dava luogo a degli errori non facilmente notabili,  nonostante questo segno questi errori (tra i commenti) perche' sono utili esempi di cosa si puo' sbagliare.

Il valore aggiunto portato da me riguarda principalmente 4 cose:

1. Il lavoro di traduzione che mi obbliga a pensare mentre scrivo il codice. Alle volte, mantengo i termini inglesi perche' mi consentono di ricordare le keyword e la sintassi.

2. Ove lo ritengo utile aggiungo dei test e delle prove per capire meglio quello che sta succedendo.

3. Ho inoltre aggiunto alcune mie considerazioni personali, utili per me per ricordare e capire meglio certe cose. 

4. Ho messo un contesto e una cornice iniziale di teorina e notazioni che leghi insieme le varie lezioni.

Queste note sono pensate per potere essere navigate tramite un indice interattivo. Nel Jupyter Notebook dove sono state scritte ho ottenuto l'indice tramite: `jupyter-navbar.` Ho semplicemente scaricato lo zip da https://github.com/shoval/jupyter-navbar e (dopo avere decompresso) ho fatto girare da Babun con python2.7 il file setup.py (questo perche' lo sto facendo girare in Windows 10). In questo modo, a sinistra appare il panel con l'indice. 

## Disclaimer
Eventuali errori di queste note sono da attribuire solo a me. 
Sono appunti personali di cui non assicuro il funzionamento (o la pericolosita').
Ci sono vari problemi di traduzine dal Jupyter notebook su cui sono gli originali e questi,
dato che in Markdown alcuni effetti non sono possibili e mancano delle immagini.



## Indice delle lezioni di Python-Engineer
I codici possono essere scaricati **[qui](https://github.com/python-engineer/pytorchTutorial)**. Qui indico le lezioni di Python Engineer, la loro durata e i capitoli corrispondenti in questo notebook.

1. [Istallazione](https://www.youtube.com/watch?v=EMXfZB8FVUA&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&ab_channel=PythonEngineer)     5:45 
2. [Tensor Basics](https://www.youtube.com/watch?v=exaWOE8jvy8&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=2) 18:28
3. [Gradient Calculation con Autograd](https://www.youtube.com/watch?v=DbeIqrwb_dE&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=3) 15:54
4. [Backpropagation - teorie ed esempi](https://www.youtube.com/watch?v=3Kb0QS6z7WA&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=4) 13:13   (molto ben fatto)
5. [Gradient Descent con Autograd e Backpropagation](https://www.youtube.com/watch?v=E-I2DNVzQLg&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=5) 17:31
6. [Training Pipeline: Model, Loss, e Optimizer](https://www.youtube.com/watch?v=VVDHU_TWwUg&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=6)  14:16
7. [Regressione Lineare](https://www.youtube.com/watch?v=YAJ5XBwlN4o&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=7)   12:11
8. [Regressione Logistica](https://www.youtube.com/watch?v=OGpQxIkR4ao&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=8) 18:22
9. [Dataset e DataLoader - Batch Training](https://www.youtube.com/watch?v=PXOzkkB5eH0&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=9) 15:27   (importante da rivedere)
10. [Dataset Transforms](https://www.youtube.com/watch?v=X_QOZEko5uE&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=10)  10:43
11. [Softmax e Cross Entropy](https://www.youtube.com/watch?v=7q7E91pHoW4&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=11) 18:17
12. [Activation Functions](https://www.youtube.com/watch?v=3t9lZM7SS7k&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=12) 10:00
13. [Feed-Forward Neural Network](https://www.youtube.com/watch?v=oPhxf2fXHkQ&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=13) 21:34
14. [Convolutional Neural Network](https://www.youtube.com/watch?v=pDdP0TFzsoQ&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=14) 22:07
15. [Transfer Learning](https://www.youtube.com/watch?v=K0lWSB2QoIQ&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=15) 14:55
16. [How to use TensorBoard](https://www.youtube.com/watch?v=VJW9wU-1n18&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=16) 25:41 
17. [Saving and loading Models](https://www.youtube.com/watch?v=9L9jEOwRrCg&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=17) 18:24
18. [Create and Deploy A Deep Learning App - PyTorch Model Deployment with Flask](https://www.youtube.com/watch?v=bA7-DEtYCNM&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=18)  41:52
19. [RNN Tutorial- Name Classification Using a Recurrent](https://www.youtube.com/watch?v=WEV61GmmPrk&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=19) 38:57
20. [RNN & LSTM & GRU Recurrent Neural Nets](https://www.youtube.com/watch?v=0_PgWWmauHk&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=20) 15:52
21. [Lightning Tutorial Lightweight PyTorch Wrapper for ML](https://www.youtube.com/watch?v=Hgg8Xy6IRig&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=21) 28:02
22. [LR Scheduler - Adjust the learning Rate for Better Results](https://www.youtube.com/watch?v=81NJgoR5RfY&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=22) 13:29 




## Altre fonti utili
Un **[articolo](http://karpathy.github.io/2015/05/21/rnn-effectiveness/)** interssante (suggerito proprio da Python Engineer) sulle RNN e' quello di Andrej Karpathy (ora a Tesla). 


Altri appunt utili possono essere trovati **[qui](https://atcold.github.io/pytorch-Deep-Learning/en/week11/11-1/)**

Altro **[corso]( https://www.cs.toronto.edu/~lczhang/360/)* molto interessante (da cui Python Engineer ha preso spunto, per esempio per l'**autoencoder**.





```python
import torch
import numpy as np
```

## Lingo -  Utilia
Qui metto un po' di keyword che possono risultare utili:


- **super()**  metodo che viene usato quando si costruisce una classe ereditandola da un'altra e consente di usare i metodi della classe genitore. 
- **tensor**   e' una matrice con in aggiunta dei metodi che sono propri di PyTorch, e' il tipo fondamentale di PyTorch (il capitolo Tensor Basics e' fatto proprio per dare una introduzione)
- **_** Un metodo il cui nome termina con un underscore vuole dire che lavora **inplace**
- **Dataset**  e' una classe di *torch.utils.data* dove viene messo il dataset che serve alla rete neurale
- **DataLoader** e' una classe di *torch.utils.data*, serve per dividere il dataset in batch da dare in pasto alla rete
- **epoch** <br> un passo forward e un backward di **TUTTI** i campioni del training
- **batch_size** numero di campioni di training in un forward/backward pass
- **numero di iterazioni** numero di passi, dove in ogni passo(forward/backward) si usa un batch di campioni ( di dimensione "batch_size")
- **criterion** e' il *criterio* (la funzione) che usiamo per generare la Loss (per esempio, cross_entropy).Nota che la loss e' il singolo valore ottenuto (in genere), mentre il criterio e' il tipo di funzione che, ottenuti come argomenti i valori predetti e quelli corretti fornisce il valore. In queste note uso in modo "liberale" i termini loss e criterion, normalmente questo non dovrebbe creare problemi.
- **learning rate** in generale si ottimizzano i pesi della rete usando una tecnica tipo **discesa del gradiente**. La loss e' una funzione da $R^n \rightarrow R$ (dove n e' il numero di pesi usati). Se calcolo il gradiente allora conosco la massima pendenza e mi posso muovere lungo quella direzione per cercare il minimo (ma nel verso opposto). Di quanto mi muovo? la grandezza di questo passo verso il possibile minimo e' data dal learning rate. Il prolema di come variare il learning rate e' fondamentale per poter ottenere delle buone convergenze.
- **Grafo computazionale**, immagina di mettere tutte le operazioni fatte per ottenere i risultati della rete neurale. In pratica stai costruendo una funzione $R^n \rightarrow R^m$. Questa funzione puo' essere vista come una serire di passi, ognuno indipendente dall'altro. Per esempio se hai una rete neurale con vari hidden layer, ogni passaggo ad un layer e' diverso, ci sono poi delle funzioni non lineari applicate ecc. La tua funzione Loss e' quindi una funzione di funzione:F(x) = f(g(h(x)))  (ho messo solo 3 funzioni per esempio ma sono in genere di piu'). Quando vorrai calcolare il gradiente rispetto ai parametri dovrai usare una chain rule e spesso questo viene visualizzato come un grafo con vari passi. 

## Domande

- viene piu' volte consigliato di non fare fare la somma quando si fa backpropagation perche' viene fatta in automatico.
Ci sono vari modi per evitare questo (devo indicare quali sono i video).


## Pipeline
Lo scopo e' costruire un codice tramite Pytorch che impari a fare qualcosa. Qui sotto indico la pipeline (la serie di passi) che serve per ottenere questo risultato. Attenzione: con il wrapper `Pytorch-Lightning`, alcuni di questi passi possono essere saltati e diventa quindi piu' semplice ottenre un modello funzionante.

- si importano i dati in `dataset` (sia per il training che per il test)
- i dataset vengono trasformati per migliorarne le caratteristiche tramite delle funzioni `transformations` (per esempio si possono normalizzare le informazioni)
- si costruisce i `dataloader` per dare al modello dei batch (sia per train che per test)
- si eredita un `nn.Model` (ricordati di mettere il *super*) dove vengono inseriti i vari strati della rete nella funzione `__init__`. 
- nel modello si inserisce anche un metodo `forward` (ATTENTO il nome deve porprio essere `forward`, si sta facendo un overload di un metodo gia' esistente in nn.Model!) dove vengono proprio implementati i passi uno dopo l'altro. Questo e' il cosiddetto `grafo computazionale`
- nota che il modello ereditato e' "callable" ovvero posso usarlo come una funzione a cui do in pasto qualcosa... in pratica i batch di dati. 
- si istanzia il modello passando solo `pochi parametri` come: dimensione input, dimensione hidden e dimensione output!
- Quando si chiama l'istanza del nostro modello personalizzato inserendo un batch, viene chiamata la funzone `forward` a cui e' passato il batch.
- si fa un ciclo esterno sulle Epoche (ogni epoca e' divisa in batch)
- si fa un ciclo interno su tutti i batch (infornate) di ogni epoca.
- si istanzia una funzione chiamata `criterion` (spesso chiamiamo l'istanza proprio `criterion`) che viene usata per ottenre la loss. Il criterio e' la forma generale della loss (per esempio cross-entropy), mentre la Loss e' l'istanza particolare associata al criterio.
- la `loss` e' una funzione sia delle predizioni $\hat y$ che dei valori noti $y$. Si usano delle notazioni che rimandano con precisione alle funzioni e gli stimatori, per esempio l'input e' dato dalla $x$, l'output e' dato dalla $\hat{y}$ (questa scrittura assomiglia a quella di uno stimatore di un'osservabile di una distribuzione)
Il risultato di applicare il criterion a questi dati produce un numero (la loss) che quantifica la qualita' della predizione. Nota che a questo punto ho una fun
- `empirical loss` e' la **media** delle varie loss ottenute da un batch, in pratica quindi la discesa del gradiente viene fatta sull'empirical loss 
- `optimizer.zero_grad()` serve per evitare che tutte le azioni (per esempio l'optimizer) vengno considerate parte del grafo computazionale 
- `loss.backward()`    fa la backpropagation in modo da ottenere i gradienti rispetto ai pesi (stiamo cercando un minimo rispetto della loss dove le variabili sono i pesi)  
- `optimizer.step()`   e' il modo in cui ci si muove (con un passo di grandezza `learning_rate`) sul landscape dato dalla loss per cercare il minimo, per esempio usando la tecnica chiamata SGD (stochastic gradient descent). 

Una osservazione sui batch (supportata dalla prima lecture del MIT intorno al min 47).
Cosa significa dare in pasto un batch alla mia (feed forward) rete neurale?
Immagina la rete neurale smplicemente come una funzione di:
- ${\bf x_i}$ : sono gli input, per esempio i pixel di una foto. Nel seguito supporro' che sia una sola variabile
- ${\bf w}$ i *pesi*,  anche qui per semplicita' si ha un  solo peso.

Con i valori in uscita (output) e i valori veri (noti nel training set) otteniamo una funzione di Loss.
Questa funzione e' $\displaystyle L = f(x,w)$

A questo punto pensa al modello piu' semplice del mondo in cui ho un solo peso $w$.  in questo caso $L = x \cdot w^2$ (nota che i pesi possono entrare in modo non lineare). Se passo 2 vettori di input diversi (per esempio 2 immagini) allora ho 2 funzioni di loss diverse:
- $L(x_1,w) = x_1 \cdot w^2 +x_1\cdot w$  (una quadratica in funzione di y, dove $x_1$ e' un prametro)
- $L(x_2,w) = x_2 \cdot  w^2 +x_2\cdot w$

Noi ora cambiamo prospettiva, dato che vogliamo minimizzare la loss in funzione dei pesi, considero ora:
- $x_i$ sono i parametri
- w  sono le variabili 

La `average loss`: $L=L_1 +L_2$ e' ora una funzione di $y$.
Per trovare il minimo, uno dei modi piu' interessanti e' muoversi nella direzione di massima pendenza (gradient) verso valori piu' bassi (basta ricordare le utilissime note di Valentina di analisi 2 sulle approssimazioni lineari di funzioni da $R^n \rightarrow R$. In questo caso calcolo la derivata parziale della loss rispetto al peso: $\frac{\partial}{\partial w}$. Se i pesi sono tanti, allora calcolo il gradiente e ottengo quindi una direzione verso cui muovermi.

In questo esempio banale le loss sono due parabole centrate in zero e non e' interessante, il minimo si ottiene mettendo $w=0$. Se prendiamo un caso appena piu' complicato, dove la loss e' la somma di due parabole non centrate in zero otteniamo una curva con vari minimi.  Nota che il profilo della funzinoe `Loss empirica` non e' identico a quello della loss del singolo imput e noi siamo intressati ad un minimo globale per tutto il batch.

## Overfitting

Come evitare l'overfitting durange la fase di training? I casi reali si riferiscono a delle funzioni che sono multidimensionali con una dimensionalita' enorme (migliaia o centinaia di migliaia di parametri). Questo implica che la superficie su cui facciamo la minimizzazione, data dalla Loss avra' molti minimi locali. Noi siamo interessati ad un minimo globale che non abbia una forte dipendenza dagli input iniziali, ma vada bene per un vasto range di casi.

Per evitare l'overfitting per esempio ci sono delle regolarizzazioni:
- `Regularization 1`: metodo **dropout**, si spengono random dei neuroni (guarda 5.3)
https://www.youtube.com/watch?v=5tvmMX8r_OM&t=1008s&ab_channel=AlexanderAmini
In ogni iterazione si fanno dei dropout differenti (scelti in modo random) in modo da ottenere diversi percorsi "neuronali". Avendo spento alcuni dei neuroni diventa anche piu' facile fare il training in quanto il numero di parametri per la backpropagation diminiuisce.
-`Regularization 2`: **Early Stopping**, fermare il fit dei parametri prima che raggiunga il minimio. Se si guardano le curve che indicano l'errore del training e della validation, al crescere delle iterazioni tendono a scendere. La curva del training pero' continua a scendere anche quando la validazione ha smesso di scendere. A quel punto sto overfittando.






# Tensor Basics 
Gli oggetti chiave di PyTorch sono i **tensor**. 


- un tensor non e' un **tensore** della matematica (funzionale lineare, con proprieta' di trasformazione)!
- un tensor e' una matrice di dimensione variabile (1D, 2D, 3D, ...)
- un tensor ha associati dei metodi particolari che servono durante il training di un neural network
- le convenzioni sono simili a quelle di Numpy (per esempio riguardo lo **slicing**)
- E' spesso utile cambiare la **forma** del tensore (per esempio con il metodo **.view()**)
- E' spesso utile cambiare il **tipo** degli oggetti contenuti nel tensore **dtype=torch.float16**. Nota che Torch ha i suoi tipi.

comandi utili:



```python
x = torch.empty(1)       # scalar   NON inizializzato
x = torch.empty(3)       # vector, 1D
x = torch.empty(2,3)     # matrice 2D con 2 righe e 3 colonne
x = torch.empty(2,2,3)   # matrice 3D 
x = torch.empty(2,2,2,3) # matrice 4D 
```

## Costruire tensori (Random, 0, e 1 e custom) 
- **torch.empty(5,3)** per avere un tensore **NON** inizializzato
- **torch.rand(5,3)** per costruire un tensore pieno di numeri **Random** U (0,1)
- **torch.zeros(5,3)**  per avere un tensore pieno di **0**
- **torch.ones(5,3)** per avere un tensore pieno di **1**
- **torch.tensor([1,2,3])** per creare un tensore, a partire da una `lista`
- **x.size()** ci dice la forma del tensore (numero di righe, colonne, ecc)
- **dtype=torch.float16** per esempio  **float32** default


```python
x = torch.rand(5, 3)                       # numeri RANDOM intervallo [0,1]
x = torch.zeros(5, 3)                      # zeri
x = torch.ones(5, 3)                       # gli ingressi sono tutti uno
x = torch.zeros(5, 3, dtype=torch.float16) # specifico il tipo
x = torch.tensor([5.5, 3])  # con questa scrittura si inizializza il tensore inserendo i valori in una lista. Questo
                            # determina automaticamente anche il numero di righe e colonne
```

## Attributi/metodi dei tensori
- x.size()      &emsp;    numero di **righe** e **colonne**  
- x.dtype       &emsp;    **tipo** degli oggetti contenuti 
- x[1]          &emsp;&emsp; &emsp;      fai uno **slicing** ottieni un **TENSORE**
- x[1].item()   &ensp;    **estrai** un valore: otteni un **FLOAT** (o quello che e' il tipo degli oggetti nel tensore)
- x.mean()      &emsp;    e' un metodo che calcola la media di TUTTI gli ingressi (non importa se il tensore e' 2D, ottieni uno scalare)


```python
print(x.size() )         # dimmi il numero di righe e colonne  
print(x.dtype )          # dimmi il tipo degli oggetti contenuti 
print(x[1])              # questo e' un TENSORE
print(x[1].item())       # questo e' un FLOAT
type(x[1].item())        # infatti...
```

    torch.Size([2])
    torch.float32
    tensor(3.)
    3.0





    float




```python
g= torch.tensor([[1.,2,3,4], [2., 4,6,8]])
print(g.mean(), g.size())
```

    tensor(3.7500) torch.Size([2, 4])


## requires_grad=True,  operazioni tra tensori e slicing

- **requires_grad=True** se si inserisce questo argomento nella creazione di un tensore, allora, durante il processo di ottimizzazione PyTorch calcolera' il gradiente (derivata parziale rispetto a questo tensore). Nota che questa opzione e' accesa di default 

Le `operazioni` di base tra tensori sono ottenute con dei metodi indicati con **3** lettere, **minuscole**:  <br>
- torch.sub(x,y)  &ensp;  oppure    &emsp;  - (fa la sottrazione tra x e y e la restituisce)
- torch.add()      &emsp;  oppure    &emsp;  +
- torch.div()      &emsp;  oppure    &emsp;  /
- torch.mul()      &emsp;  oppure    &emsp;  *
- **requires_grad=True** se voglio che PyTorch calcoli il gradiente (derivata parziale) rispetto a questo tensore rispetto al grafo computazionale.
- tutti i casi in cui il metodo finisce con un underscore _ lavorano **INPLACE**



```python
x = torch.tensor([5.5, 3], requires_grad=True)

y = torch.rand(2, 2)   # costruiamo 2 tensori random 2D
x = torch.rand(2, 2)   # costruiamo 2 tensori random 2D

# ADDIZIONI 
z = x + y
z = torch.add(x,y)
y.add_(x)                   # INPLACE   <=====================


# SOTTRAZIONI
z = x - y
z = torch.sub(x, y)

# MOLTIPLICAZIONI
z = x * y
z = torch.mul(x,y)

# DIVISIONI
z = x / y
z = torch.div(x,y)

# Slicing restituisce dei sotto-tensori (ma sempre di tipo tensor)
x = torch.rand(5,3)
print(x)
print(x[:, 0])  # tutte le righe, colonna 0
print(x[1, :])  # riga 1, tutte le colonne 
print(x[1,1])   # elemento  1, 1

# Se voglio ottenere il valore di un ingresso devo usare il metodo .item() (vale per 1 solo valore)
print(x[1,1].item())
```

    tensor([[0.7356, 0.5790, 0.3409],
            [0.1011, 0.1175, 0.8874],
            [0.5814, 0.6688, 0.1503],
            [0.7797, 0.6233, 0.0940],
            [0.5445, 0.1418, 0.8160]])
    tensor([0.7356, 0.1011, 0.5814, 0.7797, 0.5445])
    tensor([0.1011, 0.1175, 0.8874])
    tensor(0.1175)
    0.11745560169219971


## IMPORTANTE: Cambiare la forma di un tensore view()!
con il metodo **view** si cambia la forma di un tensore. Questo e' particolarmente utile quando si fanno per esempio le reti convoluzionali. In una fully connected layer io vedo l'ingresso come un verttore 1D. Se faccio la convoluzione devo ridare una forma 2D. 

- con **view(3,4)** cambio la forma. Semplicemente si mette il numero di righe (3 nell'esempio) e colonne(4 nell'esempio) voluto! 
- **NON** lavora inplace
- il valore **-1** e' un jolly: torch automaticamente determina il numero di righe (per esempio) se io scrivo solo il numero di colonne. Per esempio **x.view(-1,8)** allora torch mettera' come numero di colonne, il numero di ingressi diviso per 8.


```python
x = torch.randn(4, 4)                 # costruisco un tensore2D: 4x4 
y = x.view(16)                        # lo trasformo in 1D: 16x1
z = x.view(-1, 8)                     # Voglio ora un tensore2D, con 8 colonne a partire da quello di prima 
                                      # il -1 indica che in questa dimensione sceglie torch AUTOMATICAMENTE!
w = x.view(2,2,-1,2)    
print(x.size(), y.size(), z.size(), w.size())
```

    torch.Size([4, 4]) torch.Size([16]) torch.Size([2, 8]) torch.Size([2, 2, 2, 2])


## Reshape
questo e' un altro metodo che serve per modificare la forma di un tensore. 
Reshape **puo'** resituire sia una **copy** che una **view**

## Numpy,  Tensori e GPU
vediamo come passare da un `ndarray` (Numpy) ad un tensore e viceversa.

- **.numpy()** e' un **metodo di torch** per trasformare un tensor $\rightarrow$ ndarray (di numpy). **ATTENZIONE** usando questo metodo cosi': *b = torch.numpy(a)*
si ottiene b, che e' un ndarray, ma i suoi valori sono presi da a. NON e' un oggetto completamente nuovo. Se modifico "a", anche "b" cambia! 
- **.from_numpy()** e' un **metodo di torch** per trasformare un ndarray $\rightarrow$ tensor  
- **attenzione** se il tensore e' sulla GPU e lo trasformo in NUMPY anche il trasformato resta sulla GPU
- esiste un oggetto che dice dove deve essere il tensore: **device=torch.device("cuda")**, nota che il nome scelto in questo caso serve a ricordarci che l'argomento perche' e' identico
- **.to()** per muovere un tensore da un posto all'altro basta il metodo: **x=x.to(device)**
- numpy non e' in grado di gestire tensori sulla GPU
- **torch.cuda.is_available()** per sapere se CUDA e' disponibile, e' BOOL


```python
# Numpy
# Convertiamo un TENSORE in un ndarray di Numpy
a = torch.ones(5)    # a e' un TENSORE (Torch)
b = a.numpy()        # b e' un ndarray (Numpy)  (occhio che  .numpy e' un metodo dei TENSORI)

a.add_(1)            # cambiamo a
print('a=',a)            
print('b=',b)        # anche b e' cambiato <================ ATTENTO



# numpy to torch with .from_numpy(x)
a = np.ones(5)
b = torch.from_numpy(a)
print(a)
print(b)

# again be careful when modifying
a += 1
print(a)
print(b)

# by default all tensors are created on the CPU,
# but you can also move them to the GPU (only if it's available )
if torch.cuda.is_available():
    device = torch.device("cuda")          # a CUDA device object
    print("Cuda e' disponibile!!\n")
    y = torch.ones_like(x, device=device)  # directly create a tensor on GPU
    x = x.to(device)                       # or just use strings ``.to("cuda")``
    z = x + y
    # z = z.numpy() # not possible because numpy cannot handle GPU tenors
    # move to CPU again
    z.to("cpu")       # ``.to`` can also change dtype together!
    # z = z.numpy()
```

    a= tensor([2., 2., 2., 2., 2.])
    b= [2. 2. 2. 2. 2.]
    [1. 1. 1. 1. 1.]
    tensor([1., 1., 1., 1., 1.], dtype=torch.float64)
    [2. 2. 2. 2. 2.]
    tensor([2., 2., 2., 2., 2.], dtype=torch.float64)
    Cuda e' disponibile!!
    


## Funzioni Custom sui tensori:
guarda la risposta di  msd15213 al link:
**[link](https://stackoverflow.com/questions/46509039/pytorch-define-custom-function)**

molto meglio **[questo](https://stackoverflow.com/questions/55765234/pytorch-custom-activation-functions)**

## Tensori avanzato
- un tensore puo' essere **[contiguous](https://stackoverflow.com/questions/26998223/what-is-the-difference-between-contiguous-and-non-contiguous-arrays/26999092#26999092)**

# ChainRule e Autograd 
Il pacchetto `Autograd` fornisce differenziazione automatica per le operazioni (funzioni) sui tensori:<br>
**requires_grad=True** <br>
Immagina un **tensore** come una semplice variabile (multidimensionale) che entra in un grafo computazionale. Alla fine del grafo ho uno scalare (in genere) e voglio sapere come dipende questo scalare dal un particolare tensore, allora devo usare Autograd.
$$
\displaystyle
L(z(x)): R^n \rightarrow R  
$$




## Introduzione ai grafi computazionali 
Per esempio:
- costruisco un tensore x  (1D con 3 ingressi random)
- costruisco un tensore y funzione di x: **y=x+2** 
- costruisco un tensore z funzione di y: **z= 3y$^2$**
- ATTENTO il gradiente si puo' calcolare solo se alla fine si hanno dei valori SCALARI (altrimenti ho un numero di gradienti pari alle componenti del vettore). La logica e' chiara, alla fine io voglio vedere come varia una funzione di LOSS rispetto ai parametri che metto nella rete neurale. La LOSS e' una funzione scalare e quindi non sono state implementate delle variazioni per funzioni vettoriali.
- calcolo quindi il valore medio di **u=\<z\>** (per avere uno scalare)

$$
{\bf x}=
\left(
\begin{eqnarray}
 x_1 \\
 x_2 \\
 x_3
\end{eqnarray}
\right)
$$

$$
{\bf y}=
\left(
\begin{eqnarray}
 y_1 \\
 y_2 \\
 y_3
\end{eqnarray}
\right)
$$
$$
=
\left(
\begin{eqnarray}
 x_1+2 \\
 x_2+2 \\
 x_3+2
\end{eqnarray}
\right)
$$

$$
{\bf z}
=
\left(
\begin{eqnarray}
 3y_1^2 \\
 3y_2^2 \\
 3y_3^2
\end{eqnarray}
\right)
$$
$$
=
\left(
\begin{eqnarray}
 3(x_1+2)^2 \\
 3(x_2+2)^2 \\
 3(x_3+2)^2
\end{eqnarray}
\right)
$$
$$
=
\left(
\begin{eqnarray}
 3(x_1^2+4x_1+4) \\
 3(x_2^2+4x_2+4) \\
 3(x_3^2+4x_3+4)
\end{eqnarray}
\right)
$$




$$
\displaystyle
u = \frac{1}{3}\sum_{i=1}^3z_i = \frac{1}{3} \sum 3y_i^2  =  \sum y_i^2 \mbox{  Derivata parziale}  \Rightarrow  \frac{\partial u}{\partial y_k} = 2 y_k
$$

Se voglio conoscere la dipendenza di ${\bf u}$ da parte di ${\bf x}$, dal punto di vista matematico devo calcolare la derivata parziale di u rispetto a x:  

$$
\displaystyle \frac{ \partial u } {\partial x_j} = \frac{\partial u}{\partial y_i} \frac{\partial y_i}{\partial x_j} 
$$ (indici ripetuti sono sommati)

$$
\displaystyle
 \frac{\partial u}{\partial y_k} = 2 y_k = 2(x_k+2)
$$

$$
\displaystyle
 \frac{\partial y_k}{\partial x_j} = \delta_{kj}
$$

Quindi:
$$
\displaystyle \frac{ \partial u } {\partial x_k} = 2(x_k+2)
$$

Se il valore del tensore ${\bf x_0} = (1, 1, 1)$, alora il gradiente rispetto alla variaibile x della funzione u e' un vettore che vale:

$$
\nabla_x u |_{x_0} = 
=
\left(
\begin{eqnarray}
 2(x_1+2) \\
 2(x_2+2) \\
 2(x_3+2)
\end{eqnarray}
\right)
$$
$$
=
\left(
\begin{eqnarray}
 6 \\
 6 \\ 
 6 
\end{eqnarray}
\right)
$$

Pensala cosi': C'e' una funzione di molte variabili che vengono combinate passo passo. Queste variabili pensale come proprio i pesi della rete neurale. Alla fine noi vogliamo minimizzare la **LOSS**. Quindi prendiamo il gradiente per trovare la pendenza massima e scendiamo lungo il gradiente di queste variabili con piccoli passi, sperando di raggiungere un buon minimo (occhio che la cosa non e' garantita banalmente in quanto non siamo in un caso semplice di un solo massimo, potremmo finire in un minimo locale!).


**Attenzione** 

Quando si fa il **.backward()** i valori dei gradienti vengono ACCUMULATI nell'attributo **.grad**


```python
x = torch.ones(3, requires_grad=True)   #  x = [x_1, x_2, x_3] = [1, 1, 1]
y = x + 2                               #  y = [y_1, y_2, y_3]      

##### Occhio y e' funzione di x, che ha requires_grad=True. Quindi ha come attributo grad_fn
print(y.grad_fn)
z = y * y * 3                           #  z = [3 y_1^2, 3 y_2^2, 3 y_3^2] Lavorano sul singolo ingresso!
z = z.mean()                            #  zmean = 1/3 ( 3 y_1^2 +  3 y_2^2 + 3 y_3^2 )      calcolo la media

z.backward()                            # back propagation 
print(x.grad)                           # dz/dx = dz/ dy * dy/dx CALCOLATO nel valore corrente delle x
```

    <AddBackward0 object at 0x000001EE446B2BB0>
    tensor([6., 6., 6.])


Se l'output non e' uno scalare si devono specificare gli argomenti per il *metodo* **.backward()**, non mi e' chiaro come questi argomenti vengano usati.


```python
#x = torch.randn(3, requires_grad=True)     # tensore 1D
x = torch.tensor([1.1,1.1, 1.1], requires_grad=True)     # tensore 1D

y = x * 2                                  # altro tensore 1D
for _ in range(10):                        
    y = y * 2                              # y * y * y * ... * y (10 volte +1 del passo precedente)  = x * 2**11

print(y)
print(y.shape)
v = torch.tensor([0.1, 1.0, 0.0001], dtype=torch.float32)

y.backward(v)         # qui ho specificato che voglio il gradiente rispetto a ... v? non chiaro forse fa derivata direzionale

print(x.grad)
```

    tensor([2252.8000, 2252.8000, 2252.8000], grad_fn=<MulBackward0>)
    torch.Size([3])
    tensor([2.0480e+02, 2.0480e+03, 2.0480e-01])


## Stop tracking
- Supponiamo di volere fare un'update dei pesi durante il loop del training. 
- questo implica fare delle nuove funzioni sui pesi (le update), e quindi quando si fa  la back propagation si rischia che questa tenga conto anche delle update! Bisogna quindi dire al TENSORE di non tenere conto delle update. Ovvero si deve dire al TENSORE che deve essere tracciato **solo** lungo il **network computazionale** 

(**non del tutto chiaro devo fare esperimenti**)

- **x.requires_grad_(False)**  (nota l'underscore **_** finale per INPLACE)
- **x.detach()**    
- wrap in **with torch.no_grad():**


Se si usa il metodo **.zero_()** questo riempie il gradiente prima di un nuovo passo di ottimizzazione.


```python
a = torch.randn(2, 2)         # qui NON accendiamo il requires_grad
print(a.requires_grad)        # e appunto se controlliamo da': False
b = ((a * 3) / (a - 1))       # costruisco un nuovo Tensore b
print(b.grad_fn)              # e per qusto non c'e' l'attributo grad_fn che indica che c'e' una gradiente

a.requires_grad_(True)        # accendiamo INPLACE(_) il gradiente  
print(a.requires_grad)        # ora il risultato e' True
b = (a * a).sum()             # creiamo uno scalare b con sum() fa la somma del Tensore. 
print(b.grad_fn)              #  

# .detach(): get a new Tensor with the same content but no gradient computation:
a = torch.randn(2, 2, requires_grad=True)
print(a.requires_grad)
b = a.detach()
print(b.requires_grad)

# wrap in 'with torch.no_grad():'
a = torch.randn(2, 2, requires_grad=True)
print(a.requires_grad)
with torch.no_grad():
    print((x ** 2).requires_grad) # qui ho fatto un'altra funzione con x ma non contribuisce al gradiente!
```

    False
    None
    True
    <SumBackward0 object at 0x000001A0C4C411F0>
    True
    False
    True
    False



```python
# -------------
# backward() accumulates the gradient for this tensor into .grad attribute.
# !!! We need to be careful during optimization !!!
# Use .zero_() to empty the gradients before a new optimization step!
weights = torch.ones(4, requires_grad=True)

for epoch in range(3):
    # just a dummy example
    model_output = (weights*3).sum()
    model_output.backward()
    
    print(weights.grad)

    # optimize model, i.e. adjust weights...
    with torch.no_grad():                 # quando faccio l'ottimizzazione dei valori del tensore
        weights -= 0.1 * weights.grad     # non voglio che facciano parte del grafo computazionale!  

    # this is important! It affects the final weights & output
    weights.grad.zero_()   # se non azzeri c'e' accumulo (?)

print(weights)
print(model_output)

# Optimizer has zero_grad() method
# optimizer = torch.optim.SGD([weights], lr=0.1)
# During training:
# optimizer.step()
# optimizer.zero_grad()
```

    tensor([3., 3., 3., 3.])
    tensor([3., 3., 3., 3.])
    tensor([3., 3., 3., 3.])
    tensor([0.1000, 0.1000, 0.1000, 0.1000], requires_grad=True)
    tensor(4.8000, grad_fn=<SumBackward0>)


# Backpropagation
un esempio semplice di backpropagation.
- costruisco un tensore 0D x=1  (e' il `predictor`)
- costruisco un tensore 0D y=2  (e' la funzione obiettivo)
- costruisco un tensore 0D w=1  (sono i pesi che voglio ottimizzare)
- calcolo le y_predicted =w*x
- calcolo la LOSS (y_predicted-y)$^2$  (tutto questo e' il forward pass)
- calcolo la BACKPROPAGATION (stando attento a non farla entrare nel grafo computazionale)
- azzero i gradienti e ripeto varie epoche


```python
x = torch.tensor(1.0)                          # costruisco un tensore 0D (1 oggetto): i predictors
y = torch.tensor(2.0)                          # un altro tensore 0D:                  la risposta ESATTA

w = torch.tensor(1.0, requires_grad=True)      # questo tensore ha accesa la condizione requires_grad, i PESI

# FORWARD PASS
y_predicted = w * x                            # costruisco un grafo computazionale, ora y =w*x, la risposta CALCOLATA 
loss = (y_predicted - y)**2                    # la funzione di LOSS 
print(loss)

# BACKWARD PASS dLoss/dw                       # calcolo la dipendenza della LOSS in funzione dei PESI
loss.backward()                               
#print(w.grad)

# A questo punto voglio fare una update dei PESI per cercare di fare predizioni migliori

# 
# l'update dei PESI NON deve entrare nel grafo computazionale
with torch.no_grad():
    w -= 0.01 * w.grad      # mi muovo lungo la direzione di massima crescita... al negativo di un passetto

w.grad.zero_()              # NON dimenticare di azzerare i gradienti 


# FORWARD PASS
y_predicted = w * x                            # nuovo forward pass 
loss = (y_predicted - y)**2                    # nuova funzione di LOSS 
print(loss)

############# faccio ora un ciclo ################
for epoch in range(100):
    with torch.no_grad():
        w -= 0.01 * w.grad      # mi muovo lungo la direzione di massima crescita... al negativo di un passetto

    w.grad.zero_()              # AZZERO i gradienti

    y_predicted = w * x                            # nuovo forward pass 
    loss = (y_predicted - y)**2                    # nuova funzione di LOSS 
    loss.backward()                                # backward! se non lo faccio il gradiente e' stato azzerato! 
    if (int(epoch/10)*10==epoch):
        print(loss, i)
```

    tensor(1., grad_fn=<PowBackward0>)
    tensor(0.9604, grad_fn=<PowBackward0>)
    tensor(0.9604, grad_fn=<PowBackward0>) 99
    tensor(0.6412, grad_fn=<PowBackward0>) 99
    tensor(0.4281, grad_fn=<PowBackward0>) 99
    tensor(0.2858, grad_fn=<PowBackward0>) 99
    tensor(0.1908, grad_fn=<PowBackward0>) 99
    tensor(0.1274, grad_fn=<PowBackward0>) 99
    tensor(0.0850, grad_fn=<PowBackward0>) 99
    tensor(0.0568, grad_fn=<PowBackward0>) 99
    tensor(0.0379, grad_fn=<PowBackward0>) 99
    tensor(0.0253, grad_fn=<PowBackward0>) 99


# Discesa del gradiente Manuale
proviamo ora con un esempio 1D (prima era 0D) con una regressione lineare.

- i vari passi vengono calcolati MANUALMENTE senza usare Torch
- costruisco una funzione che fa il forward pass
- costruisco una funzione che fa il backward pass
- calcolo il gradiente (senza autograd)

La cosa interessante e' che qui ho un array in ingresso.
Prendo tutti i valori dell'array di ingresso e con essi faccio il training tutti insieme (calcolo infatti la LOSS su tutti).
Poi il passo forward lo faccio su uno scalare! per vedere se la predizione funziona


```python
import numpy as np 

# Regressione Lineare 
# f = w * x 

# here : f = 2 * x
X = np.array([1, 2, 3, 4], dtype=np.float32)   # PREDICTORS
Y = np.array([2, 4, 6, 8], dtype=np.float32)   # OBIETTIVO

w = 0.0                                        # pesi (ma non e' un tensore...) 

# MODEL OUTPUT 
def forward(x):
    return w * x                               # FORWARD PASS

# LOSS MSE
def loss(y, y_pred):                           # LOSS MSE  
    return ((y_pred - y)**2).mean()            # uso un metodo dei tensori .mean()

# J = MSE = 1/N * (w*x - y)**2
# dJ/dw = 1/N * 2x(w*x - y)
def gradient(x, y, y_pred):                    # calcolo il gradiente  
    return np.dot(2*x, y_pred - y).mean()

print(f'Predizione prima del training: f(5) = {forward(5):.3f}')

# Training
learning_rate = 0.01
n_iters = 20

for epoch in range(n_iters):
    
    y_pred = forward(X)               # FORWARD
    l = loss(Y, y_pred)               # LOSS
    
    dw = gradient(X, Y, y_pred)       # GRADIENTE (senza autograd) 
    w -= learning_rate * dw           # UPDATE   

    if epoch % 2 == 0:
        print(f'epoch {epoch+1}: w = {w:.3f}, loss = {l:.8f}')
     
print(f'Predizione dopo il training: f(5) = {forward(5):.3f}')

```

    Prediction before training: f(5) = 0.000
    epoch 1: w = 1.200, loss = 30.00000000
    epoch 3: w = 1.872, loss = 0.76800019
    epoch 5: w = 1.980, loss = 0.01966083
    epoch 7: w = 1.997, loss = 0.00050332
    epoch 9: w = 1.999, loss = 0.00001288
    epoch 11: w = 2.000, loss = 0.00000033
    epoch 13: w = 2.000, loss = 0.00000001
    epoch 15: w = 2.000, loss = 0.00000000
    epoch 17: w = 2.000, loss = 0.00000000
    epoch 19: w = 2.000, loss = 0.00000000
    Prediction after training: f(5) = 10.000


# Discesa del gradiente Autograd
come il punto precedente ma usando Autograd

- **ATTENZIONE** il print non legge bene il formato dei "tensori", devo usare il metodo **.item()** per ottenere il valore.
- **.backward()** va fatto sulla loss
- **.grad**  e' automaticamente ottenuto come parametro del tensore (per esempio dei pesi)


```python
import numpy as np 
import torch

# Regressione Lineare 
# f = w * x 

# here : f = 2 * x
X = np.array([1, 2, 3, 4], dtype=np.float32)   # PREDICTORS
Y = np.array([2, 4, 6, 8], dtype=np.float32)   # OBIETTIVO

#Nota che posso vedere sia dal punto di vista spaziale che temporale.
# dal punto di vista temporale passo alla mia rete neurale un predictor per volta
# (ma non e' manco piu' un vettore).
# dal punto di vista spaziale, passo tutti i predictor e ottengo tutti gli obiettivi.


# trasformo in TENSORI (avrei potuto direttamente usare torch.tensor(), ma cosi' uso from_numpy())

X = torch.from_numpy(X)                        # autograd non serve
Y = torch.from_numpy(Y)                        # neanche qui 

w = torch.tensor([0.0], requires_grad=True)    # pesi: accendo Autograd  

# MODEL OUTPUT 
def forward(x):
    return w * x                               # FORWARD PASS

# LOSS MSE
def loss(y, y_pred):                           # LOSS MSE  
    return ((y_pred - y)**2).mean()            # mean() e' un metodo dei tensori

print(f'Predizione prima del training: f(5) = {forward(5).item():.3f}')

# Parametri del Training
learning_rate = 0.01
n_iters = 50

for epoch in range(n_iters):
    
    y_pred = forward(X)               # FORWARD
    LOSS = loss(Y, y_pred)            # LOSS
    LOSS.backward()                   # BACKPROPAGATION (Autograd) 
    
    with torch.no_grad():
        w -= learning_rate * w.grad   # UPDATE   
    w.grad.zero_()                    # AZZERO i gradienti
        
    if epoch % 10 == 0:
        print(f'epoch {epoch+1}: w = {w.item():.3f}, loss = {LOSS.item():.8f}')
        #print(w)    
#print(f'Predizione dopo il training: f(5) = {forward(5):.3f}')

```

    Predizione prima del training: f(5) = 0.000
    epoch 1: w = 0.300, loss = 30.00000000
    epoch 11: w = 1.665, loss = 1.16278565
    epoch 21: w = 1.934, loss = 0.04506890
    epoch 31: w = 1.987, loss = 0.00174685
    epoch 41: w = 1.997, loss = 0.00006770


# LOSS e OPTIMIZER di PyTorch
Qqui vediamo qualche esempio di:
- `LOSS` function (ovvero il criterion)
- `Optimizer`, ovvero le metodologie che vengono usate per fare l'update dei pesi per migliorare la loss (dato che devo minimizzare la loss sto facendo una ottimizzazione, o minimizzazione nel dettaglio!)

Questo codice e' molto simile al precedente. La differenza e' nell'optimizer, ovvero che strategia viene portata avanti per minimizzare le LOSS. In pratica ci sono varie funzioni che prendono come argomento il gradiente rispetto ad un tensore e minimizzano la funzione.

Passi:
1. si disegna il modello
2. si costruiscono la **loss** e l'**optimizer**
3. si fa un loop di training

Consideriamo un grafo computazionale ancora del tipo linear regression.

**optimizer.step()** e' il metodo che ci fa muovere tra i parametri secondo l'algoritmo di ottimizzazione.


```python
import torch
import torch.nn as nn

# Linear regression
# f = w * x 

# here : f = 2 * x

# 0) Training samples
X = torch.tensor([1, 2, 3, 4], dtype=torch.float32)
Y = torch.tensor([2, 4, 6, 8], dtype=torch.float32)

w = torch.tensor(0.0, dtype=torch.float32, requires_grad=True)   # weights

def forward(x):
    return w * x

print(f'Prediction before training: f(5) = {forward(5).item():.3f}')

# 2) Define loss and optimizer    
learning_rate = 0.01               # questo viene passato come parmetro all'optimizer
n_iters = 100


loss = nn.MSELoss()                # e' una funzione predefinita di Torch  

optimizer = torch.optim.SGD([w], lr=learning_rate)  # Optimizer ha come parameri di imput [w] (pesi) e lr=learning_rate

for epoch in range(n_iters):       # TRAINING LOOP
    y_predicted = forward(X)       # FORWARD 
    l = loss(Y, y_predicted)       # LOSS     
    l.backward()                   # Backward (e' un metodo sul tensore dato dalla loss) 

    optimizer.step()               # Optimizer, uso il metodo .step() 

    optimizer.zero_grad()          # azzera i gradienti usati per l'ottimizzatore

    if epoch % 10 == 0:
        print('epoch ', epoch+1, ': w = ', w, ' loss = ', l)

print(f'Prediction after training: f(5) = {forward(5).item():.3f}')

```

    Prediction before training: f(5) = 0.000
    epoch  1 : w =  tensor(0.3000, requires_grad=True)  loss =  tensor(30., grad_fn=<MseLossBackward>)
    epoch  11 : w =  tensor(1.6653, requires_grad=True)  loss =  tensor(1.1628, grad_fn=<MseLossBackward>)
    epoch  21 : w =  tensor(1.9341, requires_grad=True)  loss =  tensor(0.0451, grad_fn=<MseLossBackward>)
    epoch  31 : w =  tensor(1.9870, requires_grad=True)  loss =  tensor(0.0017, grad_fn=<MseLossBackward>)
    epoch  41 : w =  tensor(1.9974, requires_grad=True)  loss =  tensor(6.7705e-05, grad_fn=<MseLossBackward>)
    epoch  51 : w =  tensor(1.9995, requires_grad=True)  loss =  tensor(2.6244e-06, grad_fn=<MseLossBackward>)
    epoch  61 : w =  tensor(1.9999, requires_grad=True)  loss =  tensor(1.0176e-07, grad_fn=<MseLossBackward>)
    epoch  71 : w =  tensor(2.0000, requires_grad=True)  loss =  tensor(3.9742e-09, grad_fn=<MseLossBackward>)
    epoch  81 : w =  tensor(2.0000, requires_grad=True)  loss =  tensor(1.4670e-10, grad_fn=<MseLossBackward>)
    epoch  91 : w =  tensor(2.0000, requires_grad=True)  loss =  tensor(5.0768e-12, grad_fn=<MseLossBackward>)
    Prediction after training: f(5) = 10.000


# Modelli di PyTorch
qui vediamo come usare i modelli preinstallati di pytorch.

-  **model = nn.Linear(input_size, output_size)**  modello lineare, ha 2 argomenti: i parametri in ingresso e in uscita.
- **X = torch.tensor([[1], [2], [3], [4]])** occhio al formato [1] = prima riga, [2] =seconda riga, [3] = terza riga, [4]= quarta riga. X.shape = 4 righe, 1 colonna.
- ATTENTO: **optimizer = torch.optim.SGD(model.parameters(), lr=learning_rate)** all'ottimizzatore da' in pasto un parametro, il learning rate.


```python
import torch
import torch.nn as nn

# Linear regression
# f = w * x 

# here : f = 2 * x

# 0) Training samples, watch the shape!
X = torch.tensor([[1], [2], [3], [4]], dtype=torch.float32)
Y = torch.tensor([[2], [4], [6], [8]], dtype=torch.float32)

n_samples, n_features = X.shape                            # 4 righe, 1 colonna. 4 osservazioni 1 sola FEATURE (predictor)
print(f'#samples: {n_samples}, #features: {n_features}')
print(X.shape)
```

    #samples: 4, #features: 1
    torch.Size([4, 1])



```python
# 0) create a test sample
X_test = torch.tensor([5], dtype=torch.float32)        # costruisco un nuovo punto per testare

# 1) Design Model, the model has to implement the forward pass!
# Here we can use a built-in model from PyTorch
input_size = n_features                                
output_size = n_features

# we can call this model with samples X
model = nn.Linear(input_size, output_size)             # modello di PyTorch

'''
class LinearRegression(nn.Module):
    def __init__(self, input_dim, output_dim):
        super(LinearRegression, self).__init__()
        # define diferent layers
        self.lin = nn.Linear(input_dim, output_dim)

    def forward(self, x):
        return self.lin(x)

model = LinearRegression(input_size, output_size)
'''

print(f'Prediction before training: f(5) = {model(X_test).item():.3f}')


learning_rate = 0.01                       # learning rate
n_iters = 100                              # numero iterazioni  

loss = nn.MSELoss()                        # funzione loss  
optimizer = torch.optim.SGD(model.parameters(), lr=learning_rate)

# 3) Training loop
for epoch in range(n_iters):
    # predict = forward pass with our model
    y_predicted = model(X)

    # loss
    l = loss(Y, y_predicted)

    # calculate gradients = backward pass
    l.backward()

    # update weights
    optimizer.step()

    # zero the gradients after updating
    optimizer.zero_grad()

    if epoch % 10 == 0:
        [w, b] = model.parameters() # unpack parameters
        print('epoch ', epoch+1, ': w = ', w[0][0].item(), ' loss = ', l)

print(f'Prediction after training: f(5) = {model(X_test).item():.3f}')
```

# Dataset e DataLoader 
Qui viene definito il dataloader. Supponi di avere un classificatore di immagini. 
In ingresso prende una immagine e  in uscita mi dice a che classe appartiene (per esempio gatto-cane).
 Non posso fare il training su una sola immagine, altrimenti farei un overfit. Quello che normalmente 
si fa e': passare dei batch (infornate di immagini), fare il training e poi fare il trainig su nuovi batch. 
In alcuni casi in modo incrementale, ovvero batch successivi includono quelli precedenti.

Secondo Python Engineer e' anche vero il contrario. Se passp tutti i dati di training, allora fare delle gradient 
calculations (backpropagation) diventa computazionalemtne oneroso.

**Osservazione** di natura `notazionale`, di solito Loeber nelle istanze che crea, usa il medesimo 
nome della funzione/classe di Torch, ma con tutte le lettere minuscole. Per esmpio, in PyTorch 
esiste `Dataset` e lui chiama la sua istanza: `dataset` (minuscolo). Mi pare un'ottima 
convenzione che aiuta a ricordare i nomi delle funzioni, metodi e classi.


- si fa un loop (esterno) su tutte le epoch
- per ogni epoch si fa un loop (interno) su tutti i batch 
- l'ottimizzazione viene fatta **solo** sul batch

Lingo:
- **epoch** un passo forward e un backward di **TUTTI** i campioni del training.
- **batch** un sottoinsieme di elementi del training dataset
- **batch_size** numero di campioni di training in un forward/backward pass.
- **numero di iterazioni** numero di passi, ogni passo(forward/backward) usa "batch_size" campioni

Per esempio:
- 100 campioni
- batch_size=20
- 5 iterazioni  formano  1 epoch

I DataLoader sono **CLASSI**, fanno la computazione del batch (la gestiscono).
Vengono ereditati da "torch.utils.data import DataLoader.

1. implementano un Dataset custom (voluto dall'utente)
2. inherit Dataset
3. implement **\_\_init\_\_**, **\_\_getitem\_\_**, e **\_\_len\_\_**






```python
import torch
import torchvision  
from   torch.utils.data import Dataset, DataLoader 

import numpy as np
import math
```


```python
class WineDataset(Dataset):           # Eredito dalla classe "Dataset" di torch.utils.data

    def __init__(self):               # metodo __init__, inizializza, leggi ecc 
        xy = np.loadtxt('./data/wine/wine.csv', delimiter=',', dtype=np.float32, skiprows=1)
        self.n_samples = xy.shape[0]      # definisce attributo n_samples = numero di righe

        # Costruisci due attributi: sono i dati di training e le labels (come tensori) 
        self.x_data = torch.from_numpy(xy[:, 1:])  # size [n_samples, n_features]
        self.y_data = torch.from_numpy(xy[:, [0]]) # size [n_samples, 1] (la colonna zero sono gli obiettivi)

    # support indexing such that dataset[i] can be used to get i-th sample
    def __getitem__(self, index):                     # questo mi fa scegliere i pezzi del dataset
        return self.x_data[index], self.y_data[index]

    # chiamando len(dataset) si ottiene la size 
    def __len__(self):
        return self.n_samples
    
dataset = WineDataset()  # carico il dataset
#first_data = dataset[0]
#features, labels = first_data
```

In questo dataset ci sono 3 categorie di  vino e sono la prima colonna del dataset. Tutte le altre colonne sono le features. Quindi nella classe sopra ho diviso mettendo [0] per le label.
A questo punto l'oggetto dataset contiene varie proprieta'.

Ora costruisco un dataloader, prendendo la classe che esiste gia' in Torch. <br>
Dato che ho gia' importato l'oggetto DataLoader da `torch.utils.data`, basta che gli passo
i parametri corretti.


## Dataset
In torchvision ci sono gia' molti dataset disponibili che consentono di fare molti esperiemnti.
Le classi Dataset e Dataloader invece sono in `torch.utils.data`

- un Dataset e' `subscriptable` (ovvero se si chiama mioDataset e faccio mioDataset[1], ottengo l'oggetto al secondo posto del dataset)
- nel dataset (solitamente) ci sono sia i `dati` che le `label`
- **non** riesco a trasformare un dataset in una funzione iteratrice



## DataLoader

- un  DataLoader **non** e' `subscriptable`, ma posso trasformarlo in un iteratore tramite `iter` e accedere quindi ai pezzi uno per volta (saranno i batch)
- uso la funzione iter() per trasformare il dataloader in una funzione iteratrice (da mettere nei loop) (ho creato una nuova funzione che e' l'iteratore del dataloader)
- a questo punto posso prendere i vari pezzi
- **Attenzione** se faccio `data=dataiter.next()` ci possono essere dei problemi e il sistema puo' non avere abbastanza memoria, per risolvere il problema si deve mettere:
`num_workers= 0`  (e non 2 come nell'esempio).
https://stackoverflow.com/questions/60101168/pytorch-runtimeerror-dataloader-worker-pids-15332-exited-unexpectedly

Argomenti di un Dataloader:
- `dataset= mio_dataset()`  `mio_dataset` e' un oggetto ereditato da `dataset` (usa dataset come nome standard, in modo da ricordare)
- `batch_size = 4`             (oppure crea una variabile batch_size)           
- `shuffle=True`               (fa shuffling, non chiaro in quali circostanze usare, la logica vuole che quando si costruiscono i train e validation sets si facciano dei sampling random. Per questo si fa lo shuffling all'interno del dataset        
- `num_workers`                (occhio che se metto 4 come nel tutorial mi da errore: devo mettere 0)


```python

batch_size = 4
num_workers = 0

dataloader = DataLoader(dataset=dataset, batch_size = batch_size, shuffle = True, num_workers = num_workers)
dataiter = iter(dataloader)  # trasformato in una funzione iteratrice
data = dataiter.next()        # prendo il prossimo oggetto (il primo)
#data = next(dataiter)
#features, labels = data
#print(features, labels)
```

A questo punto fa un training loop finto per provare a vedere come funge.

- `Attento` in enumerate non mette la funzione iteratrice ma il `dataloader`.
- ho provato a fare iterare su data ma da' errore: too many values to unpack (expected 2)
- occhio la cella sotto funge anche con dataiter solo se prima faccio girare la cella sopra.


```python
#for i, j in enumerate(dataloader):
#    print(i,j)
dataloader
```




    <torch.utils.data.dataloader.DataLoader at 0x216799d3670>




```python
#for i, j in enumerate(dataset):
#    print(i,j)    
id = iter(dataset)
id.next()
```


    ---------------------------------------------------------------------------

    AttributeError                            Traceback (most recent call last)

    <ipython-input-33-4dc6e5e585ab> in <module>
          2 #    print(i,j)
          3 id = iter(dataset)
    ----> 4 id.next()
    

    AttributeError: 'iterator' object has no attribute 'next'



```python
num_epochs = 2
total_samples = len(dataset)
n_iterations = math.ceil(total_samples/batch_size) # ceil altrimenti arrotonda per difetto
#n_iterations 

for epoch in range(num_epochs):   # giro tra le epoche
    for i, (inputs, labels) in enumerate(dataloader):    # qui ha passato il dataloader
        if (i+1)%5 == 0:
            #print( f'epoch {epoch+1}/{num_epochs}, step {i+1}/{n_iterations}, inputs {inputs.shape}' ) 
            pass  # se non voglio stampare altrimenti decommenta sopra
        
# Idea mia, e se invece di usare un enumerate usassi data (che e' una funzione iteratrice?)

#j=0
#for epoch in range(num_epochs):   # giro tra le epoche
#    for inputs, labels in dataiter:   # qui ha passato il data (iteratrice)
#        j=j+1
#        print(j)
#        if (j+1)%5 == 0:
#            print( f'epoch {epoch+1}/{num_epochs}, step {j+1}/{n_iterations}, inputs {inputs.shape}' )    

# dataset pre-installati:

#torchvision.datasets.MNIST()  # occhio che e'  M N I S T
# fashion-mnist
# cifar
# coco
```

# Dataset Transforms

In pratica si deve passare un argomento `transform` alla classe associata al dataset. 



Documentazione sulle possibili trasformazioni:
https://pytorch.org/docs/stable/torchvision/transforms.html

riassunto delle trasformazioni (UTILE, lo fa Python engineer):

Quando carichi un dataset da `torchvision` puoi usare l'argomento: download=True!





Traformazioni sulle `Immagini`:
- CenterCrop, Grayscale, Pad, RandomAffine, RandomCrop, RandomHorizontalFlip, RandomRotation, Resize, Scale

Sui `Tensori`:
- LinearTransformation, Normalize, RandomErasing

`Conversion`:
-ToPILImage: da tensore o ndarray  (PILI = Pillow image)
-ToTensor: da numpy.ndarray o PILImage

Generic:
- lambda 

`Custom:`
- Si puo' scrivere una propria classe

Trasformazioni `composte multiple`:
- composed = transforms.Compose( [Rescale(256] , RandomCrop(224)] )  

- torchvision.transforms.ReScale(256)     # occhio che qui ha messo S maiuscola
- torchvision.transforms.ToTensor()

**Trasformazioni** <br>
Ora prendo la classe usata sopra per i dataset e aggiungo un argomento: transform,
che specifica quali trasformazioni posso applicare!

- va passato qualcosa al momento della creazione della classe dataset
- viene fatto un esempio con una `trasformazione custom`, usando una **classe**
- ho un problema, mi dice che, al contrario del codice del corso, WineDataset non ha l'attributo transform. in particolare succede se faccio: 
dataset = WineDataset(transform =ToTensor())
dataset[0] <- qui e' il problema





```python
import torch
import torchvision

from torch.utils.data import Dataset
import numpy as np

#dataset = torchvision.datasets.MNIST(root='./data', download= True, transform=torchvision.transforms.ToTensor())

class WineDataset(Dataset):
    def __init__(self,transform=None):   # posso anche non passare transform, di default = None
        xy = np.loadtxt('./data/wine/wine.csv', delimiter=',', dtype=np.float32, skiprows=1)
        self.n_samples = xy.shape[0] 

        self.x = xy[:, 1:]
        self.y = xy[:,[0]]  # NOTA che scrivo [0]
        
        self.transform = transform # quando chiamo la trasformazione dall'istanza.
    
    def __getitem__(self, index):            # questo mi prende lo specifico dato alla posizione index
        #return self.x[index], self.y[index]  # non ritorna l'oggetto, ma voglio trasformare!
        sample =  self.x[index], self.y[index]  # costruisco l'oggetto
        if self.transform:                      # se e' presente
             sample = self.tranform(sample)
                
        return sample                           # lo metto qui in modo che ritorni qualcosa comunque  

    def __len__(self):
        return n_samples

    
############## trasformazione custom ###############
############## abbiamo bisogno di un metodo chiamato __call__
class ToTensor:
    def __call__(self, sample):   ##############  FONDAMENTALE ########## 
        inputs, targets = sample
        return torch.from_numpy(inputs), torch.from_numpy(targets)
    
    

#dataset = WineDataset(transform =None)
#dataset = WineDataset(transform=ToTensor)
#dataset = WineDataset(transform = ToTensor())
#dataset[0]

#first_data = dataset[0]        ################### NON FUNGE #################
#features, labels  = first_data
#print(type(features), type(labels))


##  posso fare trasoformazioni multiple:

class MulTransform:
    def __init__(self, factor):
        self.factor = factor
        
    def __call__(self, sample):
        inputs, targets = sample
        inputs *= self.factor
        return inputs, target

composed = torchvision.transforms.Compose([ToTensor(), MulTransform(2)])

dataset = WineDataset (transform = composed)
#first_data = dataset[0]     ###################### NON FUNGE #####################
```

# Softmax e Cross-Entropy Loss
Queste sono tra le funzioni piu' comuni per "schiacciare i risultati" (un po' come la logit(p) =ln(p/1-p) =ln(odds) )

`Softmax`:
$$
\displaystyle S(y_i) = \frac{e^{y_i}}{\sum e^{y_i}}
$$
I risultati vanno quindi tra 0 e 1.
A denominatore sembra una funzione di ripartizione (ma i valori non sono negativi).

Chiaramente $ \sum S(y_i) =1$ quindi le $S(y_i)$ possono essere interpretate come delle `probabilita'`. 
Per questo vengono applicate come layer in uscita dopo l'ultimo strato in modo che ad ognuna delle classi sia associata una probabilita'.
![cane]({{ site.baseurl }}/images/posts/pytorch/softmax.png)

- Se fossero solo **2 le classi** come nella regressione logistica si userebbe la **sigmoid** function (che e' la versione non generalizzata ma con solo 2 classi in pratica):
$$
Sigmoid(x) = \frac{1}{1+e^{-x}}
$$


- Come Loss si potrebbe usare la `nn.BCELoss()`  (binary cross entropy loss). In questo caso pero' BISOGNA implementare la sigmoide dopo l'ultimo strato.

- La cross entropy di Pytorch implementa gia' la **softmax** dall'ultimo strato, per questo bisogna evitare di applicare la softmax un'altra volta!



```python
import numpy as np
import torch.nn as nn
import torch
import matplotlib.pyplot as plt


def softmax(x):                                       # costruisco una softmax di un ARRAY x
    return np.exp(x)/ np.sum(  np.exp(x) , axis = 0)  # ho tutti gli elementi

def sigmoid(x):
    return 1./(1.+np.exp(-x))

x = np.array([2.,1.,0.1])

print(softmax(x))

########## qui uso una softmax gia' presente in Torch
x  = torch.tensor([2.,1.0,0.1])
outputs = torch.softmax(x, dim=0)  # devo specificare la dimensione dove giro
print(outputs)

x= [i-500 for i in range(1000)]
x = np.array(x)
x = x *0.01
exp = np.exp(x)
x  =torch.from_numpy(x)
y = torch.softmax(x, dim=0 )
#y = sigmoid(x)
plt.plot(x,y)
plt.plot(x, sigmoid(x))
#x
```

    [0.65900114 0.24243297 0.09856589]
    tensor([0.6590, 0.2424, 0.0986])





    [<matplotlib.lines.Line2D at 0x2165c85f910>]



![png]({{ site.baseurl }}/images/posts/pytorch/output_52_2.png)


## Cross-Entropy Loss
La Cross-Entropy Loss e' una funzione di Loss, che  viene spesso combinata alla soft-max.

Come la maggior parte delle funzioni di Loss trasforma i valori ottenuti (output) e le label in un
singolo valore. Dato ci sono 2 vettori N-dimensionali:
- il vettore calcolato (a partire dall'input) $\hat{Y}= [0.7, 0.2, 0.1]$ Gli ingressi devono poter essere interpretabili come probabilita', ergo devono essere nel range (0,1]. Questo e' il motivo per cui gli si danno in pasto dei valori che sono gia' stati convertiti con delle Softmax.
- e quello osservato $Y= [1,0,0]$ (**One-Hot Encoded** labels) `dubbio`, ma cosi' facendo non e' manco piu' una somma! tutte le $Y_i$ vengono azzerate tranne 1. E' vero solo se faccio un oggetto per volta. Se faccio un batch di oggetti e quindi sommo i risultati (per ottenere la empirical loss), avro' piu' di un valore diverso da 0.


la `Cross Entropy Loss` viene definita come:
$$
D(\hat{Y}, Y) = - \frac{1}{N} \sum Y_i \cdot log(\hat{Y}_i)
$$
Nota che la Cross-Entropy loss restituisce valori [0,1]. 

**Migliore** la predizione, piu' **bassa** e' la Loss. <br>

**Domanda**: come ottengo questa formula a partiere dall'entropia di `Shannon`?

Quindi e' un'entropia di Shannon ma in cui da un lato inserisco i valori osservati e quelli ottenuti. Chiaramente serve che le Y e $\hat{Y}$ siano in un range [0,1] se voglio ottenere dei risultati simili all'entropia di Shannon.

**Attenzione**  nel codice del video, Loeber non segue la definizione in quanto **non** divide per il numero di oggetti, non so perche'. Quindi i risultati che ottiene non sono nel range [0,1]


```python
def cross_entropy(actual, predicted):       # sono 2 array N-dim
    loss = -(np.sum( actual * np.log(predicted) ))  /len(actual)
    return loss

y = np.array([1,0,0])
y_pred_good = np.array([0.7,0.1,0.1])
y_pred_bad  = np.array([0.1,0.4,0.5])

l1  = cross_entropy(y, y_pred_good)
l2  = cross_entropy(y, y_pred_bad)

print(f'Loss1 : {l1:.4f}')
print(f'Loss2 : {l2:.4f}')

      
```

    Loss1 : 0.1189
    Loss2 : 0.7675


## CrossEntropyLoss
la funzione nn.CrossEntropyLoss **usa gia'**:<br>
`nn.LogSoftMax -> nn.NLLLos`  (negative log likelihood loss)

Per questo `NON` le (a nn.LogSoftMax) si devono dare in pasto i vettori codificati tramite:

- One Hot encoding (**NO**)
- Softmax (**NO**)


La funzione di Loss in PyTorch consente di avere samples multipli. <br>
Ovvero si ha una loss per il primo sample, una per il secondo sample, ecc in pratica viene un vettore di loss.


```python
######## QUI usiamo la cross entropy embedded in Torch

Y = torch.tensor([0])  # questa e' la classe corretta e' UN Solo valore

#qui sotto la dimensione e' n_samples x n_classes =  1 x 3  (in questo caso)
## e' un ARRAY di ARRAY
Y_pred_good = torch.tensor( [  [ 2.0, 1.0, 0.1] ] )  # e' buona perche' la classe 0 ha il valore maggiore

Y_pred_bad = torch.tensor( [  [ 0.5, 2.0, 0.3] ] )   # e' cattiva perche' il valore maggiore e' per la classe 1

loss = nn.CrossEntropyLoss()  # istanzio la funzione

print(loss (Y_pred_good, Y ).item())
print(loss (Y_pred_bad , Y ).item())

### per ottenere le predizioni:

_, pred1 = torch.max (Y_pred_good, 1)  # il secondo ingresso e' la dimensione dove gira?
_, pred2 = torch.max (Y_pred_bad, 1)

print(pred1)
print(pred2)

############## sample multipli ###########################

Y = torch.tensor([2,0,1])   # vettore 3 (n_samples)

                            # vettore n_labels x n_samples
Y_pred_good = torch.tensor( [  [ 0.1, 1.0, 2.1] ,
                               [ 2.0, 1.0, 0.1] ,
                               [ 0.1, 3.0, 0.1] ] )

Y_pred_bad = torch.tensor( [  [ 2.1, 1.0, 0.1] ,
                               [ 0.1, 1.0, 2.1] ,
                               [ 0.1, 3.0, 0.1] ] ) 

print(loss (Y_pred_good, Y ).item())
print(loss (Y_pred_bad , Y ).item())

_, pred1 = torch.max (Y_pred_good, 1)  # il secondo ingresso e' la dimensione dove gira?
_, pred2 = torch.max (Y_pred_bad, 1)
print(pred1)
print(pred2)

```

    0.4170299470424652
    1.840616226196289
    tensor([0])
    tensor([1])
    0.3018244206905365
    1.6241613626480103
    tensor([2, 0, 1])
    tensor([0, 2, 1])


## Esempio Applicazione di Softmax 
- un solo hidden layer con `hidden_size` nodi
- `input_size` e' per esempio il num di punti dell'immagine
- `num_classes` e' il numero di possibili classi in uscita (output_size)




```python
import torch 
import numpy as np
import torch.nn as nn

class NeuralNet2(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(NeuralNet2, self).__init__()   # questo serve per ereditare il costruttore?
        self.linear1 = nn.Linear(input_size, hidden_size)        #   
        self.relu = nn.ReLU()                                    # metodo nuovo 
        self.linear2 = nn.Linear(hidden_size, num_classes)       # altro metodo che prende 2 arg   

    def forward(self, x):            # devo passare l'input: x
        out = self.linear1(x)
        out = self.relu(out)
        out = self.linear2(out)
        # NON USARE softmax, e' gia' messa nella Loss che usiamo popi
        return(out)
       
model = NeuralNet2(input_size=28*28, hidden_size=5, num_classes=3)  # istanzio il modello
criterion = nn.CrossEntropyLoss()                                   # Applica gia' la Softmax di default.

        
################# Classificazione binaria ############################
# num_classes = 1   # il risultato vale un numero da [0,1]
# model = NeuralNet1(input_size = 28*28, hidden_size = 5)
# critetrion = nn.BCELoss()
```

# Activation Function
https://www.youtube.com/watch?v=3t9lZM7SS7k&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=12&ab_channel=PythonEngineer

- ReLU  rectified linear unit _/  

Le funzioni di attivazione vengono applicate dopo avere fatto il prodotto scalare e si applicano a tutti i neuroni/nodi (hidden).

Nel video  dice che se non mettiamo delle funzioni di attivazione si ha un gigantesco livello lineare (il disegno e' in un certo senso sbagliato, quello al minuto 1:15). All'inizio pensavo sbagliasse, ma ripensandoci ha completamente ragione. Per esempio supponiamo che ci siano solo due variabili di ingresso (x,y) e 2 nodi nel primo hidden layer: 
- $a_1x+b_1y$ 
- $c_1x+d_1y$ 

(evito i bias che tanto sono costanti). A questo punto mettiamo un secondo hidden layer con 2 nodi e ottengo:
- $a_2(a_1x+b_1y) + b_2(c_1x+d_1y)$  $\rightarrow$   $(a_2 a_1 +  b_2 c_1) x+(a_2 b_1 + b_2 d_1)y $
- $c_2(a_1x+b_1y) + d_2(c_1x+d_1y)$  $\rightarrow$   $(c_2 a_1 +  d_2 c_1) x+(c_2 b_1 + d_2 d_1)y $

Non ho mai termini quadratici o cubici in x o y. 
Se non ci fossero le funzioni di attivazione sarebbe proprio un modello lineare, in cui non avrebbe nemmeno senso mettere tanti nodi al primo hidden layer (e tantomeno mettere piu' di un layer!)

Alla fine del capitolo successivo (il 13) ho provato a fare un modello senza funzioni di attivazione. I risultati sono interessanti.




In ogni caso le funzioni lineari applicate dopo ogni layer migliorano le prestazioni.

- Step function $\displaystyle f(x)= \begin{cases} 0 & \text{if } x < 0  \\ 
                                      1 & \text{if } x\ge 0\end{cases}$
- Sigmoid `nn.Sigomoid` $\displaystyle f(x) = \frac{1}{1+e^{-x}}$  
- Tanh  `nn.TanH`   $\displaystyle f(x) = \frac{2}{1+e^{-2x}} -1$  
- ReLU  `nn.ReLU`   $\displaystyle f(x)= \begin{cases} 0 & \text{if } x < 0  \\ 
                                      x & \text{if } x\ge 0\end{cases}$
- Leacky ReLU `nn.LeakyReLU` $\displaystyle f(x)= \begin{cases} ax & \text{if } x < 0  \\ 
                                      x & \text{if } x\ge 0\end{cases}$  con $a < 1$
- Softmax `nn.Softmax`  $\displaystyle S(y_i) = \frac{e^y_i}{ \sum_i e^{y_i}}$ 


Sono disponibili anche come funzioni di Torch, ma in questo caso i nomi sono tutti in `minuscolo`:
- `nn.ReLU()`  $\leftrightarrow$ `torch.relu()`
- `nn.Sigmoid()`  $\leftrightarrow$ `torch.sigmoid()`
- `nn.Softmax()`  $\leftrightarrow$ `torch.softmax()`
- `nn.TanH()`  $\leftrightarrow$ `torch.tanh()`

In alcuni casi le funzioni non sono disponibili da Torch,
ma si deve passare da torch.nn.functional:

- F.relu()
- F.leaky_relu()



```python
import torch 
import numpy as np
import torch.nn as nn
import torch.nn.functional as F

# opzione 1: creare un modulo nn 
class NeuralNet1(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(NeuralNet1, self).__init__()   # questo serve per ereditare il costruttore?
        self.linear1 = nn.Linear(input_size, hidden_size)        #   
        self.relu = nn.ReLU()                                    # metodo nuovo 
        self.linear2 = nn.Linear(hidden_size, 1)       # altro metodo che prende 2 arg 
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):            # devo passare l'input: x
        out = self.linear1(x)
        out = self.relu(out)
        out = self.linear2(out)
        out = self.sigmoid(out)
        return out 
    
    
        
# opzione 2: usare le funzioni di attivazione di Torch 
class NeuralNet2(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(NeuralNet2, self).__init__()   # questo serve per ereditare il costruttore?
        self.linear1 = nn.Linear(input_size, hidden_size)        #   
        self.linear2 = nn.Linear(hidden_size, 1)       # altro metodo che prende 2 arg 

    def forward(self, x):                     # devo passare l'input: x
        out = torch.relu(self.linear1(x))     # ho usato le funzioni di torch
        out = torch.sigmoid(self.linear2(out))
        return out 
                            
```

# Feed Forward Neural Network
Questo e' il primo esempio di rete neurale funzionante. Nota che qui NON vengono fatti i passaggi preliminari per conoscere la struttura del datset, per vedere se le classi sono bilanciate, o per fare delle trasformazioni. L'ipotesi di partenza e' che il dataset sia ok.

`Scopo`:<br>
- costruire una fully connected neural network con 1 hidden layer (Feed Forward: una volta fatto il passo il lavoro e' finito).
- per il riconoscimento di immagini del dataset MNIST  (sono i numeri da 0 a 9 scritti a mano da varie persone, in immagini 28 x28 pixel con un solo canale di colore)

`Metodo`:<br>

0. Dataset e Dataloader:
 - Si importa un dataset, per esempio: `torchvision.datasets.MNIST(...)`
 - Si creano 2 dataloader, uno per il train e uno per il test, per esempio: `torch.utils.data.DataLoader(...)`
1. Costruzione e istanziazione del modello:
 - si importa la classe `nn.Model`, a cui si devono poter passare come parametri le dimensioni dei tensori iniziali, hidden e output...
 - in nn.Model, all'interno del metodo `__init__` si costruiscono i metodi e gli attributi che serviranno al grafo computazionale (per esempio `self.l1= nn.Linear`, `self.n_output= n_output`...)
 - in nn.Model si definiscono anche le ReLU, SoftMax, ecc  `self.relu= nn.ReLU()`
 - eventualmente gli oggetti vengono mandati sul device: `.to(device)`
 - in nn.Model si costruisce il metodo `forward()` (il nome deve essere proprio forward) in cui si mettono i vari passaggi costruire il `grafo computazionale`
 - Finita la costruzione del modello se ne fa un'istanza passando come argomenti i valori corretti delle dimensioni dei tensori
 - si usa il metodo per mandare il modello sulla GPU: `modello = NeuralNet(input_size,...).to(device)`  in modo che sia sulla `GPU` 
 
2. Scelta della funzione di loss (`criterion`) e del metodo di ottimizzazione (`optimizer`)
 - si sceglie una funzione di loss (che per esempio possiamo chiamare `criterion`) (occhio che la CrossEntropy include gia' softmax)
 - si applica `optimizer.zero_grad()` per evitare che l'ottimizzatore entri nel grafo computazionale
 - ci si ricorda di  
 - `loss.backwards()` costruisce i gradienti rispetto ai pesi (che hanno autograd =True) tramite la chain rule. Il gradiente della loss serve poi per l'ottimizzazione
 - si sceglie una funzione di ottimizzazione `optimizer`:  SGD, Adam, ... : per esempio: `optimizer = torch.optim.Adam(model.parameters(), lr = learning_rate)` Nota che bisogna passare i parametri del modello che vengono ottenuti tramite `model.parameters()`, perche' l'ottimizzatore sappia cosa deve modificare.
 - `optimizer.step()` fa un passo nella direzione dell'ottimizzazione in funzione del learning rate.
 
3. Loop sulle epoche e sui batch.
 - si fa un loop sulle epoche (sceglo io quante).
 - si fa un loop per tutti i batch di ogni epoca.
 - con `enumerate` si spacchettano le immagini e le label dal dataloader.
 - si usa `view` o `reshape` per trasformare gli oggetti in 1D (il risultato e' lo stesso)
 - **NON chiaro**, che differnza c'e' tra passare un'immagine e un batch di immagini al modello? come viene gestito?
 - **NON** si chiama `forward`, ma si passano gli oggetti da classificare al `modello` (perche' il modello nn.Model ha gia' implementato un metodo `__call__` e questo in pratica fa si che quando si chiami il modello come se fosse una funzione, allora si fa entrare in azione il metodo `forward`) 
 - si crea una `loss= criterion(output, labels)`  (posso comodamente cambiare la loss cambiando il criterio)
 - `optimizer.zero_grad()` ci si assicura che la backpropagation e l'ottimizzazione non modifichino i gradienti. Si evita quindi che entrino nel grafo computazionale.
 - si costruisce la chain rule con:  `loss.backward()`
 - si ottimizzano i pesi usando un metodo del criterio di ottimizzazione: `criterion.step()`
 
4. Si fa la validazione del modello tramite il test set
 - in questo caso si vuole evitare che i gradienti vengano fatti: `with torch.no_grad()`
 - si fanno i loop su tutti i batch (non ha senso sulle epoche) del test dataloader
 - si usano delle metriche, per esempio l'`accuracy`.
 
 
 
Note: 
- Per supporto `GPU` si costruisce un oggetto device come alla riga 8
- piu' tardi si fara' un push to device, ottenuto sia per il modello che per i tensori tramite il metodo `.to(device)` (con l'oggetto device opportunamente definito prima, riga 8.
- Occhio che **non esiste** "transform.ToTensor" ma "transforms".ToTensor con una **s** dopo transform!!!! python mi dava errore: non esiste transform, ma l'errore era una semplice dimenticanza.
- nota che la prima volta che carico il dataset ci mette un po', la seconda volta MOLTO meno (lo mette da qualche parte in memoria forse)


All'inizio ci serve l'oggetto `Module` preso da `nn`. Questo oggetto e' una specie di contenitore che connette le varie parti di una rete neurale. 

Un layer fully connected da nn.Module ha bisogno di 3 parametri:
- `input size` (numero di punti dell'immagine)
- `hidden size` (numero di nodi nascosti)
- `output size` (in questo caso sono le classi in uscita che voglio trovare).

Ricordiamoci di chiamare il metodo `super`. Questo mi consente di poter usare i metodi della superclass (la classe che ho ereditato) senza dover riscriverli da zero. Una buona spiegazione: https://realpython.com/python-super/

Il metodo forward ha 2 argomenti: `self` e `x`
- self serve perche' siamo dentro la classe e vogliamo accedere a tutti gli della istanza
- x e' invece l'immagine (il batch di immagini) che vogliamo catalogare

posso prendere invece che self.relu   nn.ReLU ? (provare)

- Non applico la softmax alla fine perche' la cross entropy 
ha gia' la softmax incorporata



Forward pass: ho un problema mi dice che non sono allineati gli oggetti
su cpu e gpu, in particolare dice che :
- out e' su CPU
- il tensore passato come argomento uno al modello e' su CPU
- ma lui se li aspetta sulla GPU

`RISOLTO`: dovevo usare il metodo to.(device) quando istanziavo il modello! (riga 17 del modello)
Attento che lui nel video non lo faceva (probabilmente perche' ha piu' volte detto che il suo laptop non ha supporto GPU, quindi ovunque lui mandi qualcosa su device, resta su cpu)!

Nel seguito, prima spezzo in varie celle i passaggi, e poi per ultimo costruisco una cella con tutti i passaggi congiunti in modo da avere un luogo dove fare qualche esperimento.


```python
import torch
import torch.nn as nn
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt
%matplotlib inline

# device config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')   # device, dove mandare i vari oggetti 

# Hyper parametri 
input_size = 28*28    #  =784 sono le dimensioni delle immagini
hidden_size  = 1000   #  scelto da me, e' la dimensione della hidden layer
num_classes = 10      #  devo classificare immagini di numeri da 0 a 9, quindi la dimensione dell'output =10
num_epochs = 2        #  faccio 2 giri completi sul dataset di train
batch_size = 100      #  questo no so come sia stato scelto, comunque posso modificare
learning_rate = 0.001 #  piccolo (potrei poi usare delle funzioni per cambiare questo parametro durante l'evoluzione)

#carico i dataset MNIST
#  root e' dove viene messo il dataset quando viene caricato 
#  gli diciamo poi che e' un dataset usato per il _training_
#  Occhio che poi quando facciamo train=False per costruire il dataset di test, lui splitta automaticamente
#  mi domando in quale percentuale. 
#  Trasformiamo le immagini facendo diventare le immagini in tensori
#  lo scarico se non e' gia' nella dir data

train_dataset = torchvision.datasets.MNIST(root= './data/', train= True, 
                                           transform =transforms.ToTensor(),
                                          download = True)

test_dataset = torchvision.datasets.MNIST(root= './data/', train= False, 
                                           transform =transforms.ToTensor(),
                                          download = False) # ho gia' scaricato tutto con il train_datast


# costruisco i dataloader:
#DataLoader necessita di almeno 2 parametri:
#  il nome del dataset
#  il la dimensione del batch
#  poi si fa shuffle = True/False

train_loader = torch.utils.data.DataLoader(dataset= train_dataset, batch_size = batch_size, shuffle=True)

test_loader = torch.utils.data.DataLoader (dataset=  test_dataset, batch_size = batch_size, shuffle=False)

## guardiamo un batch dei dati:

examples =  iter(train_loader)
samples, labels = examples.next()

print(samples.shape, labels.shape)
### nota che la dimensione dei sample e' la seguente
# 100  = numero di immagini nel batch (se non metti batch_size, di default vale 1)
#   1  = numero di canali solitamente i colori
#  28  =  numero di ingressi sull'asse delle x
#  28  = numero di ingressi sull'asse delle y
```

    torch.Size([100, 1, 28, 28]) torch.Size([100])


qui disegno i sample, ricorda che subplot, indica la struttra, righe e colonne e poi l'indice dice quale di questi e'.


```python
for i in range(6):
    plt.subplot(2,3,i+1)     # i primi parametri indicano 2 righe e 3 colonne, e poi il numero dell'immagine corrente.
    plt.imshow(samples[i][0], cmap= 'gray')  # occhio che c'e' solo samples[i][0], le label sono state messe in labels.

```


![png]({{ site.baseurl }}/images/posts/pytorch/output_64_0.png)


## il Modello


```python
# qui costruisco il modello: e' una classe

class NeuralNet(nn.Module):                                    # lo chiamo NeuralNet e lo importo da nn.Module
    def __init__(self, input_size, hidden_size, num_classes):  # il costruttore
        super(NeuralNet, self).__init__()                      # super per ereditare da nn.Module
        self.l1 = nn.Linear(input_size, hidden_size)           # L MAIUSCOLA per Linear
        self.relu = nn.ReLU()                                  # funzione di attivazione ReLU 
        self.l2 = nn.Linear(hidden_size, num_classes)          # secondo(ultimo) strato fully connected
       
    def forward (self, x):    # l'argomento self indica che viene lanciato su se stessi, la x e' il batch di immagini
        out = self.l1(x)      # sfrutto il metodo self.l1 a cui ho gia' dato dei parametri prima
        out = self.relu(out)  # ReLU non aveva bisogno di parametri: posso prendere nn.ReLU ?
        out = self.l2(out)
        return out            # DEVE restituire qualcosa: l'output
    

# qui creo una istanza del modello:
model = NeuralNet(input_size, hidden_size, num_classes).to(device)
```

## Criterion e Optimizer
- Qui sotto costruisco la funzione di **LOSS** 
- Poi costruisco l'**optimizer**, ovvero il metodo che mi "aggiusta" i pesi della rete neurale secondo determinati schemi. Attento, devo passare degli argomeni all'optimizer.
In particolare c'e' un metodo del modello che si chiama `model.parameters()`


```python
criterion  = nn.CrossEntropyLoss()                                    # non ha bisogno di parametri
optimizer = torch.optim.Adam(model.parameters(), lr = learning_rate)  # qui devo passare i parametri del modello!
```

## Training loop
Qui sotto faccio il training che e' composto da un loop esterno `epoch` e uno interno sui `batch` della singola epoch.

`Osservazioni`:

- Il loop sui batches e' fatto in modo interessante, con `enumerate(dataloader)`. In questo modo ho un indice che mi dice in quale batch sono, inoltre ho creato una tupla contenente sia l'immagine che la corrispondente label (tra tonde)
- devo mandare sia le immagini che le label sul device `.to(device)` 
- uso il modello, non uso il metodo del modello (se faccio model.forward() cosa succede? niente funziona allo stesso modo!)


```python
n_total_steps = len(train_loader)

for epoch in range(num_epochs):                  # Loop sulle epochs
   # for steps in range(n_total_steps):           # loops sui batches 
   for i, (images,labels) in enumerate (train_loader):   # loop sui batch     
        # 100, 1, 28, 28  (batch, canali, x, y) forma del tensore images
        # 100, 28x28=784  forma voluta dall'hidden layer
        images = images.reshape(-1, 28*28).to(device)     #usando reshape con il -1
        labels = labels.to(device)
        
        # forward pass
        # print (images.is_cuda)        
        outputs = model (images)        #  non chiama il metodo forward: perche'?
        loss = criterion(outputs, labels)
                 
        # backward pass
        optimizer.zero_grad()   # non voglio che vengano inseriti nel backward pass
        loss.backward()          #  <========  fa tutto lui, calcola chain rule
        optimizer.step()         # aggiorna i pesi
        
        if (i+1) % 100 ==0:
            print(f'epoch {epoch+1} / {num_epochs}, step {i+1}/{n_total_steps}, loss= {loss.item():.4f}')        
```

    epoch 1 / 2, step 100/600, loss= 0.3839
    epoch 1 / 2, step 200/600, loss= 0.2682
    epoch 1 / 2, step 300/600, loss= 0.1468
    epoch 1 / 2, step 400/600, loss= 0.1664
    epoch 1 / 2, step 500/600, loss= 0.0730
    epoch 1 / 2, step 600/600, loss= 0.1700
    epoch 2 / 2, step 100/600, loss= 0.0749
    epoch 2 / 2, step 200/600, loss= 0.2193
    epoch 2 / 2, step 300/600, loss= 0.1413
    epoch 2 / 2, step 400/600, loss= 0.0539
    epoch 2 / 2, step 500/600, loss= 0.0470
    epoch 2 / 2, step 600/600, loss= 0.0669


## Test Loop
qui calcolo l'accuracy con i dati di test.

- La funzione `torch.max` restituisce: valori e l'indice. Noi vogliamo l'indice che e' la classe.
- per calcolare il numero totale di immagini processate, conto il numero di righe in labels.
- per ogni predizione corretta aggiungo 1 "sum()" e estraggo dal tensore con item() (non chiarissimo il sum). 
- nota la scrittura con l'  ==, quindi facciamo una specie di if "online"


```python
with torch.no_grad():    
    n_correct = 0         # numero di predizioni azzeccate
    n_samples = 0         # ? 
    for images, labels in test_loader:
        images = images.reshape(-1, 28*28).to(device)
        labels = labels.to(device)
        
        outputs = model(images)   # qui il modello e' gia' trainato!
        
        _, predictions = torch.max(outputs,1) # prendo la classe che ha il valore massimo
        n_samples += labels.shape[0]          # numero di samples nel batch corrente (nell'ultimo sono diversi spesso)
        n_correct += (predictions == labels).sum().item()
        
    acc = 100.0  * n_correct / n_samples # accuratezza in percentuale
    print(f'accuracy ={acc}')
```

    accuracy =97.07


## Prove sul modello
In questa cella faccio le mie varianti in modo da poter capire meglio i vari passaggi. 


```python
import numpy as np
import torch
import torch.nn as nn
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt
%matplotlib inline

# device config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
#device = torch.device('cpu')

# Hyper parametri 
input_size = 28*28    #  =784 sono le dimensioni delle immagini
hidden_size  = 2000   #  scelto da me
num_classes = 10      #  devo classificare immagini di numeri
num_epochs = 1        #  quanti giri completi vengono fatti
batch_size = 100        #  questo no so come sia stato scelto
learning_rate = 0.001 #  piccolo

train_dataset = torchvision.datasets.MNIST(root= './data/', train= True, 
                                           transform =transforms.ToTensor(),
                                          download = True)

test_dataset = torchvision.datasets.MNIST(root= './data/', train= False, 
                                           transform =transforms.ToTensor(),
                                          download = False) # ho gia' scaricato tutto con il train_datast

train_loader = torch.utils.data.DataLoader(dataset= train_dataset, batch_size = batch_size, shuffle=True)

test_loader = torch.utils.data.DataLoader (dataset=  test_dataset, batch_size = batch_size, shuffle=False)

### nota che la dimensione dei sample e' la seguente
# 100  = numero di immagini nel batch (se non metti batch_size, di default vale 1)
#   1  = numero di canali solitamente i colori
#  28  =  numero di ingressi sull'asse delle x
#  28  = numero di ingressi sull'asse delle y

def myActiv(x):    # e' difficile costruire delle funzioni di attivazioni CUSTOM (vedi sopra)
    #return 1. +x/10. + 0.5*(x/10.)**2+1./6.*(x/10.)**3
    return  -3*x**2+4*x-1
        

############  MODELLO ####################
# qui costruisco il modello: e' una classe

class NeuralNet(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(NeuralNet, self).__init__()
        self.l1 = nn.Linear(input_size, hidden_size)  # L MAIUSCOLA
        self.relu = nn.ReLU()
        self.sigmoid= nn.Sigmoid()
        self.softplus = nn.Softplus()
        self.my = myActiv
        self.l2 = nn.Linear(hidden_size, num_classes)
       
    def forward (self, x):
        out = self.l1(x)      # sfrutto il metodo self.l1 a cui ho gia' dato dei parametri prima
        out = self.relu(out)  # ReLU non aveva bisogno di parametri: posso prendere nn.ReLU ?
        #out = self.sigmoid(out)
        #out = self.softplus(out)
        #out = self.my(out)
        out = self.l2(out)
        return out            # DEVE restituire qualcosa


############### ISTANZIO MODELLO ########
model = NeuralNet(input_size, hidden_size, num_classes).to(device)

############### CRITERION E OPTIMIZER ###
criterion  = nn.CrossEntropyLoss()   # non ha bisogno di parametri
optimizer = torch.optim.Adam(model.parameters(), lr = learning_rate)       # qui devo passare i parametri del modello!

############### TRAINING LOOP ############
n_total_steps = len(train_loader)


tot =0 # PA
for epoch in range(num_epochs):                  # Loop sulle epoch  
   for i, (images,labels) in enumerate (train_loader):   # loop sui batch, uso enumerate cosi' so in che batch sono     
        # 100, 1, 28, 28  (batch, canali, x, y) forma del tensore images
        # 100, 28x28=784  forma voluta dall'hidden layer
        images = images.reshape(-1, 28*28).to(device)     #usando reshape con il -1
        labels = labels.to(device)
              
        #outputs = model (images)        #  non chiama il metodo forward: perche' nn.Model ha il __call__!
        outputs = model.forward(images)        #  non chiama il metodo forward: perche' nn.Model ha il __call__!
        
        loss = criterion(outputs, labels)

        tot = tot+1 # PA per fare delle modifiche sul Learning Rate
        if (tot%200 == 0):
            learning_rate = learning_rate *0.8
            print(f'Learning rate {learning_rate}')
            optimizer = torch.optim.Adam(model.parameters(), lr = learning_rate)
        
        
        # backward pass
        optimizer.zero_grad()   # non voglio che vengano inseriti nel backward pass
        loss.backward()          #  <========  fa tutto lui, calcola chain rule
        optimizer.step()         # aggiorna i pesi
        
        if (i+1) % 100 ==0:
            print(f'Epoch {epoch+1} / {num_epochs}, step {i+1}/{n_total_steps}, loss= {loss.item():.4f}')        

            
############ TEST LOOP #################
with torch.no_grad():    
    n_correct = 0         # numero di predizioni azzeccate
    n_samples = 0         # ? 
    for images, labels in test_loader:
        images = images.reshape(-1, 28*28).to(device)
        labels = labels.to(device)
        
        outputs = model(images)   # qui il modello e' gia' trainato!
        
        _, predictions = torch.max(outputs,1) # prendo la classe che ha il valore massimo
        n_samples += labels.shape[0]          # numero di samples nel batch corrente (nell'ultimo sono diversi spesso)
        n_correct += (predictions == labels).sum().item()
        
    acc = 100.0  * n_correct / n_samples # accuratezza in percentuale
    print(f'accuracy ={acc}')            
```

    Epoch 1 / 1, step 100/600, loss= 0.2884
    Learning rate 0.0008
    Epoch 1 / 1, step 200/600, loss= 0.1714
    Epoch 1 / 1, step 300/600, loss= 0.1254
    Learning rate 0.00064
    Epoch 1 / 1, step 400/600, loss= 0.1586
    Epoch 1 / 1, step 500/600, loss= 0.1043
    Learning rate 0.0005120000000000001
    Epoch 1 / 1, step 600/600, loss= 0.0829
    accuracy =97.06


## Prova senza funzioni di attivazione: e' un modello lineare!
Questi sono i risultati ottenuti quando elimino la activation function e lascio solo il
modello lineare sottostante, dove c'e' il primo passo la fully connected tra le immagini e lo strato hidden
e dallo strato hidden all'output. I risultati sono in funzione di vari parametri variati.
Con questo dataset i risultati non sono male, si hanno delle  buone accuracy a condizione che 
il numero di neuroni sia paragonabile (anche 4 e' sufficiente!) al numero di possibili output.

Nota pero' che comunque ho la softmax finale per la cross entropy come loss.

- senza attivazione: accuracy = 91.28    hidden_size  =2000 epoch =1
- senza attivazione: accuracy = 90.69    hidden_size  =10   epoch =1
- senza attivazione: accuracy = 92.54    hidden_size  =10   epoch =4
- senza attivazione: accuracy = 38.22    hidden_size  =1    epoch =4
- senza attivazione: accuracy = 41.95    hidden_size  =1    epoch =14
- senza attivazione: accuracy = 67.53    hidden_size  =2    epoch =4
- senza attivazione: accuracy = 86.04    hidden_size  =4    epoch =4


```python
import numpy as np
import torch
import torch.nn as nn
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt
%matplotlib inline

# device config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
#device = torch.device('cpu')

# Hyper parametri 
input_size = 28*28    #  =784 sono le dimensioni delle immagini
hidden_size  = 4      #  scelto da me
num_classes = 10      #  devo classificare immagini di numeri
num_epochs = 4        #  quanti giri completi vengono fatti
batch_size = 100        #  questo no so come sia stato scelto
learning_rate = 0.001 #  piccolo

train_dataset = torchvision.datasets.MNIST(root= './data/', train= True, 
                                           transform =transforms.ToTensor(),
                                          download = True)

test_dataset = torchvision.datasets.MNIST(root= './data/', train= False, 
                                           transform =transforms.ToTensor(),
                                          download = False) # ho gia' scaricato tutto con il train_datast

train_loader = torch.utils.data.DataLoader(dataset= train_dataset, batch_size = batch_size, shuffle=True)

test_loader = torch.utils.data.DataLoader (dataset=  test_dataset, batch_size = batch_size, shuffle=False)

### nota che la dimensione dei sample e' la seguente
# 100  = numero di immagini nel batch (se non metti batch_size, di default vale 1)
#   1  = numero di canali solitamente i colori
#  28  =  numero di ingressi sull'asse delle x
#  28  = numero di ingressi sull'asse delle y

def myActiv(x):    # e' difficile costruire delle funzioni di attivazioni CUSTOM (vedi sopra)
    #return 1. +x/10. + 0.5*(x/10.)**2+1./6.*(x/10.)**3
    return  -3*x**2+4*x-1
        

############  MODELLO ####################
# qui costruisco il modello: e' una classe

class NeuralNet(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(NeuralNet, self).__init__()
        self.l1 = nn.Linear(input_size, hidden_size)  # L MAIUSCOLA
        self.l2 = nn.Linear(hidden_size, num_classes)
       
    def forward (self, x):
        out = self.l1(x)      # sfrutto il metodo self.l1 a cui ho gia' dato dei parametri prima
        #out = self.relu(out)  # ReLU non aveva bisogno di parametri: posso prendere nn.ReLU ?
        out = self.l2(out)
        return out            # DEVE restituire qualcosa


############### ISTANZIO MODELLO ########
model = NeuralNet(input_size, hidden_size, num_classes).to(device)

############### CRITERION E OPTIMIZER ###
criterion  = nn.CrossEntropyLoss()   # non ha bisogno di parametri
optimizer = torch.optim.Adam(model.parameters(), lr = learning_rate)       # qui devo passare i parametri del modello!

############### TRAINING LOOP ############
n_total_steps = len(train_loader)

for epoch in range(num_epochs):                  # Loop sulle epoch  
   for i, (images,labels) in enumerate (train_loader):   # loop sui batch, uso enumerate cosi' so in che batch sono     
        # 100, 1, 28, 28  (batch, canali, x, y) forma del tensore images
        # 100, 28x28=784  forma voluta dall'hidden layer
        images = images.reshape(-1, 28*28).to(device)     #usando reshape con il -1
        labels = labels.to(device)
              
        outputs = model (images)        #  non chiama il metodo forward: perche'?
        loss = criterion(outputs, labels)
                 
        # backward pass
        optimizer.zero_grad()   # non voglio che vengano inseriti nel backward pass
        loss.backward()          #  <========  fa tutto lui, calcola chain rule
        optimizer.step()         # aggiorna i pesi
        
        if (i+1) % 100 ==0:
            print(f'epoch {epoch+1} / {num_epochs}, step {i+1}/{n_total_steps}, loss= {loss.item():.4f}')        

            
############ TEST LOOP #################
with torch.no_grad():    
    n_correct = 0         # numero di predizioni azzeccate
    n_samples = 0         # ? 
    for images, labels in test_loader:
        images = images.reshape(-1, 28*28).to(device)
        labels = labels.to(device)
        
        outputs = model(images)   # qui il modello e' gia' trainato!
        
        _, predictions = torch.max(outputs,1) # prendo la classe che ha il valore massimo
        n_samples += labels.shape[0]          # numero di samples nel batch corrente (nell'ultimo sono diversi spesso)
        n_correct += (predictions == labels).sum().item()
        
    acc = 100.0  * n_correct / n_samples # accuratezza in percentuale
    print(f'accuracy ={acc}')            
```

    epoch 1 / 4, step 100/600, loss= 1.4573
    epoch 1 / 4, step 200/600, loss= 1.0294
    epoch 1 / 4, step 300/600, loss= 0.8547
    epoch 1 / 4, step 400/600, loss= 0.6365
    epoch 1 / 4, step 500/600, loss= 0.4938
    epoch 1 / 4, step 600/600, loss= 0.6704
    epoch 2 / 4, step 100/600, loss= 0.5902
    epoch 2 / 4, step 200/600, loss= 0.4542
    epoch 2 / 4, step 300/600, loss= 0.5579
    epoch 2 / 4, step 400/600, loss= 0.7067
    epoch 2 / 4, step 500/600, loss= 0.4833
    epoch 2 / 4, step 600/600, loss= 0.6566
    epoch 3 / 4, step 100/600, loss= 0.6494
    epoch 3 / 4, step 200/600, loss= 0.4046
    epoch 3 / 4, step 300/600, loss= 0.7297
    epoch 3 / 4, step 400/600, loss= 0.3742
    epoch 3 / 4, step 500/600, loss= 0.4305
    epoch 3 / 4, step 600/600, loss= 0.4805
    epoch 4 / 4, step 100/600, loss= 0.6506
    epoch 4 / 4, step 200/600, loss= 0.3813
    epoch 4 / 4, step 300/600, loss= 0.3637
    epoch 4 / 4, step 400/600, loss= 0.6228
    epoch 4 / 4, step 500/600, loss= 0.5557
    epoch 4 / 4, step 600/600, loss= 0.5079
    accuracy =86.55


# Convolutional Neural Network

Lezione del MIT sulle CNN: https://www.youtube.com/watch?v=AjtX1N_VT9E&ab_channel=AlexanderAmini

Lezione estesa:
https://www.youtube.com/watch?v=AjtX1N_VT9E&list=PLtBw6njQRU-rwp5__7C0oIVt26ZgjG9NI&index=3&ab_channel=AlexanderAmini

Materiale della lezione:
http://introtodeeplearning.com​


qui vediamo degli esempi specifici riguardo le reti convoluzionali. 
- L'esempio e' basato sul dataset CIFAR-10.
- 10 classi, 6000 immagini per classe.
- ogni immagine sono 32 x 32
- ogni immagine ha 3 canali
- 50 000 immagini di training e 10 000 immagini di test 
- Il dataset sembra gia' essere diviso in batches 

`Problema` ho implementato fino a criterion ma ho un errore quando istanzio il modello (prima di averlo riempito...
forse e' per quello). `'ConvNet' object has no attribute '_modules'`

-Domanda: Non mi e' chiaro come vengano gestiti i casi di 3 canali di colore. Come faccio ad associarli a una singola immagine?
-Risposta. Posso pensare i 3 canli come un'immagine una sopra l'altra. Le convoluzioni applicano in modo indipendente ai 3 canali, ma alla fine quando faccio un flatten li metto tutti in un unico tensore 1D (forse)

Regola del numero di punti restanti in funzione di una convoluzione/ pooling,
- w  = larghezza dell'`immagine`.
- F  = larghezza del `filtro`
- P  = larghezza del `padding`
- S  = stride 

Risultato (minuto 14:00 del tutorial 14): 
$$
\frac{W-F+2P}{S}+1
$$
(in questo caso P =0 dato che non ho padding, e S=1 in quanto il kernel si muove di un quadretto per volta)
<!---
![convoluzione]({{ site.baseurl }}/images/posts/pytorch/convoluzione.png)
-->
<img src="{{ site.baseurl }}/images/posts/pytorch/convoluzione.png" alt="drawing" width="600"/>
(nota che i quadrati colorati successivi sono un po' piu' piccoli per evitare sovrapposizioni ma riguardano 
tutti i punti delle celle che toccano)
Ora viene implementata una rete neurale con la seguente (immagine da internet, non penso sia di Loeber) struttura:

<img src="{{ site.baseurl }}/images/posts/pytorch/auto-convolution.jpeg" alt="drawing" width="600"/>

- conv + relu
- pooling
- conv + relu
- pooling
- fully connected
- fully connected
- fully connected





## Come misurare le dimensioni dei tensori in uscita

Quando si hanno delle convoluzioni o dei pooling, la dimensione dei tensori in uscita non
e' facilissima da calcolare al volo, fortunatamente esiste una formula semplice.

1. In torch le convoluzioni `nn.Conv2d(3,6,5)` hanno 3 parametri:

- il primo parametro e' il numero di **canali in ingresso** (per esempio 3, associati a r g b).
- il secondo parametro e' il numero di **canali in USCITA**, nell'esempio sopra 6. Cosa significa? significa che ho preso 6 
kernel differenti (riempiti con valori random) e li ho applicati tutti e 6 (ipotesi mia)!
- il terzo parametro e' la **dimensione del kernel**

- ci sono i canali (in entrata di solito sono i colori, in uscita non hanno questo significato, in quanto possono cambiare.

2. I max pooling hanno 2 parametri, per esempio: `nn.MaxPool2d(2,2)`:
- la dimensione del kernel
- lo stride

Riassumendo si usa la formula **(w - f +2p )/s +1** sia per convoluzione che per pooling:
- prima convoluzione (kernel 5 x 5) passo da 3 canali 32 x 32 a   : (32-5-0)/1+1  = 28 x 28   ( 6 canali ,scelto da me) 
- primo pooling (kernel 2 x 2) con stride 2 passo da 6 canali 28 x 28 -> (28-2-0)/2 + 1 = 14 x 14 ( 6 canali, non modificabile)
- seconda convoluzione (kernel 5 x5) passo da 6 canali 14 x 14 a -> (14 - 5 -0)/1+1 = 10 x 10 (16 canali, scelto da me)
- secondo pooling (kernel 2 x 2) passp da 16 canali 10 x 10 a -> (10-2 -0)/2 +1 = 5 x 5 (16 canali non modificabile)

Quindi quando faccio un flatten alla fine ottengo: 5 x 5 x 16  **esatto** come nel video!

In grassetto metto i valori che scelgo io (per esempio i canali di ouput con la convolione)

<!---
|   operazione  |    kernel     |  Stride  |  canali input | figura input |  canali output |  figura output |
| ------------- | ------------- | -------- | ------------- | ------------ | -------------- | -------------- |   
| I convoluzione  |     5 x 5     |     1    |       3       |   32 x 32    |       **6**      |  (32-5-0)/1+1 =28 |
| I max pooling   |     2 x 2     |     2    |       6       |   28 x 28    |         6      |  (28-2-0)/2+1 =14 |
| II convoluzione  |     5 x 5     |     1    |      6        |  14 x 14    |      **16**      |  (14-5-0)/1+1 =10 |
| II max pooling   |     2 x 2     |     2    |     16       |   10 x 10    |        16      |  (10-2-0)/2+1 = 5 |
--->





|   operazione    |  canali input | canali output|   kernel     |  Stride  | figura input  |  figura output    |
| -------------   | ------------- |--------------|------------- | -------- | ------------  | --------------    |   
| I convoluzione  |   **3**       |      **6**   |  **5** x 5   |     1    |   32 x 32     |  (32-5-0)/1+1 =28 |
| I max pooling   |       6       |        6     |  **2** x 2   |   **2**  |   28 x 28     |  (28-2-0)/2+1 =14 |
| II convoluzione |   **6**       |     **16**   |  **5** x 5   |     1    |  14 x 14      |  (14-5-0)/1+1 =10 |
| II max pooling  |     16        |       16     |  **2** x 2   |   **2**  |   10 x 10     |  (10-2-0)/2+1 = 5 |


   
**Osservazione**
- alla funzione di convoluzione vengono passati come argomenti solo: i `canali di ingresso`, `canali di uscita` e la `dimensione del kernel`, per esempio: `nn.Conv2d(3,6,5)`
- `Non` si passa la dimensione delle figure, viene presa in automatico!
- alla funzione di max pool invece si passano solo: la `dimensione del kernel` e `dimensione della stride`:`nn.MaxPool2d(2,2)`


`Problemi:`

- ho provato ha mettere dei valori custom degli strati finali fully connected, non mi prende hidden_size2,
ma se metto un valore preciso lo prende... perche? Il motivo era che avevo messo queste quantita' dentro la classe
indentando. Se le metto fuori, vengono prese come variabili globali!




```python
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt
%matplotlib inline

# device config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Hyper parametri 
input_size = 32*32    #  =1024 sono le dimensioni delle immagini
num_classes = 10      #  devo classificare immagini di numeri
num_epochs = 6        #  quanti giri completi vengono fatti
batch_size = 4        #  questo no so come sia stato scelto
learning_rate = 0.001 #  piccolo
hidden_size1  = 220   #  scelto da me
hidden_size2  = 184   #  scelto da me 

transform =  transforms.Compose( [transforms.ToTensor(), transforms.Normalize( (0.5,0.5,0.5), (0.5,0.5,0.5)  )  ] )


train_dataset = torchvision.datasets.CIFAR10(root= './data/', train= True, 
                                           transform =transform,            # uso le trasformazioni indicate sopra
                                          download = True)

test_dataset = torchvision.datasets.CIFAR10(root= './data/', train= False, 
                                           transform =transform,
                                          download = False) # ho gia' scaricato tutto con il train_datast

train_loader = torch.utils.data.DataLoader(dataset= train_dataset, batch_size = batch_size, shuffle=True)

test_loader = torch.utils.data.DataLoader (dataset=  test_dataset, batch_size = batch_size, shuffle=False)

# Pytorch lavora con numeri, qui assegno i nomi corrispondenti
#             0       1       2       3      4      5       6       7       8        9 
classes = ('plane', 'car', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck')

def imshow(img):
    img = img /2 + 0.5 # "denormalizza" forse per avere dei colori migliori
    npimg = img.numpy()
    plt.imshow(np.transpose(npimg, (1,2,0)))


######### MODELLO ###############

class ConvNet(nn.Module):

    
    def __init__(self):
        super(ConvNet, self).__init__()
        self.conv1  = nn.Conv2d(3, 6, 5)     # input channel size, output channel size,  Kernel size 5 (5x5)
        self.pool   = nn.MaxPool2d(2,2)      # kernel size, stride  (e' un quadrato 4x4 diviso in 4 parti 2x2)
        self.conv2  = nn.Conv2d(6, 16, 5)    # input channel size = out di prima = 6, scelgo l'out= 16 e kernel size 5 (5x5)  
        self.fc1    = nn.Linear(16*5*5, hidden_size1) # fully connected (spiegato dopo) ingresso, e 120 in uscita
        self.fc2    = nn.Linear(hidden_size1, hidden_size2)     # in ingresso prende l'uscita del precedente e in output un tensor 1D con 84 ingressi
        self.fc3    = nn.Linear(hidden_size2, 10)      # in uscita ho solo le 10 classi di oggetti (riga 38)            
        
    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))  #  MaxPool(ReLU(convoluzione(immagine))
        x = self.pool(F.relu(self.conv2(x)))  #  MaxPool(ReLU(convoluzione( ))
        x = x.view(-1, 16*5*5)                #  metto l'immagine processata in un vettore 1D
        x = F.relu(self.fc1(x))               #  ReLU(fc())
        x = F.relu(self.fc2(x))               #  ReLU(fc())
        x = self.fc3(x)                       #  qui non faccio la ReLU, perche' poi nella cross entropy c'e' softmax
        return x



model = ConvNet().to(device)                  # metto sul device    
    
criterion = nn.CrossEntropyLoss()             # serve per fare la LOSS, include la softmax per l'ultimo strato
optimizer = torch.optim.SGD(model.parameters(), lr = learning_rate)
    
n_total_steps  = len(train_loader)
for epoch in range(num_epochs):
    for i, (images, labels) in enumerate(train_loader):
        # forma [4, 3, 32, 32] -> [4, 3, 1024]       4 immagini, 3 canali di colore, 32 x 32 
        # input layer: 3 canali di input, 6 canali di uscita, 5 kernel size
        images = images.to(device)
        labels = labels.to(device)
        
        # forward
        outputs = model(images)
        loss = criterion(outputs, labels)
        
        # backward e ottimizzazione dei pesi
        optimizer.zero_grad()
        loss.backward()              # chain rule
        optimizer.step()             # step di ottimizzazione dato il learning rate
        
        if (i+1) % 1000 ==0:
            print(f'epoch {epoch+1} / {num_epochs}, step {i+1}/{n_total_steps}, loss= {loss.item():.4f}')     
print("Training Terminato")

# qui faccio la fase di testing:

with torch.no_grad():
    n_correct = 0
    n_samples = 0
    n_class_correct = [0 for i in range(10)]  # e' una lista uso una list-comprehension
    n_class_samples = [0 for i in range(10)]  # non chiaro cosa sia questo
    
    for images, labels in test_loader:
        images = images.to(device)
        labels = labels.to(device)

        outputs = model(images)
        
        _, predicted = torch.max(outputs, 1)
        n_samples += labels.size(0)      # non serve una quadra?
        n_correct += (predicted == labels).sum().item()       # questa da capire bene 
        
        for i in range (batch_size):
            label = labels[i]        # gira nel batch, label della singola immagine
            pred = predicted[i]      # guarda la riga 90
            
            if (label == pred):
                n_class_correct[label] += 1  # fa un istogramma
            n_class_samples [label] +=1      # ne ho trovsata una un piu' della classe label
    
    acc = 100.0 * n_correct / n_samples      # percentuale di corrette sul totale dei sample
    print(f'Accuracy  = {acc}:.4f')
        
    for i in range(10):
        acc = 100.0 *n_class_correct[i]/ n_class_samples[i]  # accuracy della singola classe
        print(f'Accuracy della classe {classes[i]}: {acc} %'  )
    
        
```

    Files already downloaded and verified
    epoch 1 / 6, step 1000/12500, loss= 2.3000
    epoch 1 / 6, step 2000/12500, loss= 2.3080
    epoch 1 / 6, step 3000/12500, loss= 2.3117
    epoch 1 / 6, step 4000/12500, loss= 2.2834
    epoch 1 / 6, step 5000/12500, loss= 2.2788
    epoch 1 / 6, step 6000/12500, loss= 2.2987
    epoch 1 / 6, step 7000/12500, loss= 2.2965
    epoch 1 / 6, step 8000/12500, loss= 2.3122
    epoch 1 / 6, step 9000/12500, loss= 2.1770
    epoch 1 / 6, step 10000/12500, loss= 2.2453
    epoch 1 / 6, step 11000/12500, loss= 1.9151
    epoch 1 / 6, step 12000/12500, loss= 2.1131
    epoch 2 / 6, step 1000/12500, loss= 2.2575
    epoch 2 / 6, step 2000/12500, loss= 1.6527
    epoch 2 / 6, step 3000/12500, loss= 1.3318
    epoch 2 / 6, step 4000/12500, loss= 1.4340
    epoch 2 / 6, step 5000/12500, loss= 2.3746
    epoch 2 / 6, step 6000/12500, loss= 1.9364
    epoch 2 / 6, step 7000/12500, loss= 2.1739
    epoch 2 / 6, step 8000/12500, loss= 2.1157
    epoch 2 / 6, step 9000/12500, loss= 1.5521
    epoch 2 / 6, step 10000/12500, loss= 1.7367
    epoch 2 / 6, step 11000/12500, loss= 1.6836
    epoch 2 / 6, step 12000/12500, loss= 1.8475
    epoch 3 / 6, step 1000/12500, loss= 1.7431
    epoch 3 / 6, step 2000/12500, loss= 2.2294
    epoch 3 / 6, step 3000/12500, loss= 2.5908
    epoch 3 / 6, step 4000/12500, loss= 1.4687
    epoch 3 / 6, step 5000/12500, loss= 1.6939
    epoch 3 / 6, step 6000/12500, loss= 1.4162
    epoch 3 / 6, step 7000/12500, loss= 1.5874
    epoch 3 / 6, step 8000/12500, loss= 1.5107
    epoch 3 / 6, step 9000/12500, loss= 1.7396
    epoch 3 / 6, step 10000/12500, loss= 1.6814
    epoch 3 / 6, step 11000/12500, loss= 2.7111
    epoch 3 / 6, step 12000/12500, loss= 1.9274
    epoch 4 / 6, step 1000/12500, loss= 1.4081
    epoch 4 / 6, step 2000/12500, loss= 1.0557
    epoch 4 / 6, step 3000/12500, loss= 1.9581
    epoch 4 / 6, step 4000/12500, loss= 1.2325
    epoch 4 / 6, step 5000/12500, loss= 2.0073
    epoch 4 / 6, step 6000/12500, loss= 1.1686
    epoch 4 / 6, step 7000/12500, loss= 2.1211
    epoch 4 / 6, step 8000/12500, loss= 1.8252
    epoch 4 / 6, step 9000/12500, loss= 1.3711
    epoch 4 / 6, step 10000/12500, loss= 0.7326
    epoch 4 / 6, step 11000/12500, loss= 1.5150
    epoch 4 / 6, step 12000/12500, loss= 1.2301
    epoch 5 / 6, step 1000/12500, loss= 1.7059
    epoch 5 / 6, step 2000/12500, loss= 1.4075
    epoch 5 / 6, step 3000/12500, loss= 1.5126
    epoch 5 / 6, step 4000/12500, loss= 1.4504
    epoch 5 / 6, step 5000/12500, loss= 1.7903
    epoch 5 / 6, step 6000/12500, loss= 1.4010
    epoch 5 / 6, step 7000/12500, loss= 1.5074
    epoch 5 / 6, step 8000/12500, loss= 1.0711
    epoch 5 / 6, step 9000/12500, loss= 0.9101
    epoch 5 / 6, step 10000/12500, loss= 1.4603
    epoch 5 / 6, step 11000/12500, loss= 1.5229
    epoch 5 / 6, step 12000/12500, loss= 1.2879
    epoch 6 / 6, step 1000/12500, loss= 0.9052
    epoch 6 / 6, step 2000/12500, loss= 1.2526
    epoch 6 / 6, step 3000/12500, loss= 1.0965
    epoch 6 / 6, step 4000/12500, loss= 1.1149
    epoch 6 / 6, step 5000/12500, loss= 1.2192
    epoch 6 / 6, step 6000/12500, loss= 1.1820
    epoch 6 / 6, step 7000/12500, loss= 1.4098
    epoch 6 / 6, step 8000/12500, loss= 1.8098
    epoch 6 / 6, step 9000/12500, loss= 1.0243
    epoch 6 / 6, step 10000/12500, loss= 1.3008
    epoch 6 / 6, step 11000/12500, loss= 0.9658
    epoch 6 / 6, step 12000/12500, loss= 1.0129
    Training Terminato
    Accuracy  = 52.13:.4f
    Accuracy della classe plane: 49.5 %
    Accuracy della classe car: 71.5 %
    Accuracy della classe bird: 49.9 %
    Accuracy della classe cat: 33.7 %
    Accuracy della classe deer: 29.7 %
    Accuracy della classe dog: 32.7 %
    Accuracy della classe frog: 78.4 %
    Accuracy della classe horse: 50.6 %
    Accuracy della classe ship: 69.7 %
    Accuracy della classe truck: 55.6 %


# Transfer Learning
In questo paragrafro viene spiegato come usare parzialmente dei modelli gia' "trainati" per fare dei nuovi compiti simili.
Curiosamente questo sembra funzionare molto bene.
Dico curiosamente perche' non e' chiaro il motivo per cui una rete neurale che ha un training su degli oggetti possa andare bene anche su degli oggetti differenti. A meno che, in qualche modo, si siano imparate delle caratteristiche generali dal primo training.

Quello che e' davvero potente e' che modificando l'ultimo layer posso cambiare 
il numero di valori in uscita. Con Resnet18 ci sono 1000 classi in uscita. Cambio l'ultimo layer e 
me ne servono solo 2 in uscita: no problem!

- per esempio faccio il training per un modello che classifica **uccelli** e **gatti**
- con una piccola modifica gli faro' classificare **api**  e **cani**

`Osservazione`
- gli **uccelli** hanno caratteristiche in comune alle **api** (non mi pare scelto a caso!)
- i **cani** hanno caratteristiche in comune ai **gatti** (anche questo non mi pare a caso)

Quindi il transfer learning, intuitivamente, funziona bene quando le modifiche da fare sono piccole (e' un pensiero mio).

Si cambia solo l'ultimo strato **fully connected** (rispetto al caso precedente gli ultimi 3 strati),
questo e' infatti lo `strato di classificazione`. Gli strati precedenti tramite le convoluzioni e i pooling dovrebbero estrarre le caratteristiche dei vari oggetti.

- Intuitivamente mi viene da dire che gli strati convoluzionali prendono i "pezzi" (p.es le ali, le zampe, ecc, ma nella realta' prendono dettagli molto piu' piccoli)
- gli strati finali mettono insieme questi pezzi elementari.
- quindi mi viene da dire che dovrebbe bastare 1 strato fully connected.
- in realta' nel video di 3blue1brown si vede che non e' molto chiaro cosa venga preso nei vari passaggi.

In questo caso vediamo anche come caricare un modello gia' "trainato" (devo trovare un nome migliore...ma dire con i pesi ottimizzati e' lungo e anche modello ottimizzato non mi piace):<br>
**Resnet18NN**
- basato sul **Imagenet database** (con piu' di 1 000 000 immagni)
- ha 18 strati
- classifica oggetti di 1000 categorie.

Attenzione che qui fa una cosa leggemente diversa da quanto fatto finora, dove si costruisce il modello e lo si lancia da un loop.

In questo caso costruisce una funzione



## Image Folder
Costruire un folder dove mettere le immagini che devono servire per train e test. <br>
Il folder che contiene le immagini che vogliamo usare come nuovo training ha il seguente formato:
- train
  - ants
  - bees
  
- val
  - ants
  - bees

Quindi se la struttura e' questa chiamando `datasets.Imagefolder` posso leggere e trasformare in un dataset.
Posso inoltre usare l'attributo `classes`.



## Scheduler 
- E' una funzione che modifica il learning rate durante il training per ottimizzare la discesa dei gradienti.



## Fine Tuninig
tengo tutto il modello pre-trainato ma modifico solo l'ultimo layer 


## Domande
per come e' scritto il codice sembra che in varie epoche i modelli siano diversi, non ci sia un aggiornamento continuo. In pratica fa una deepcopy del miglior modello (ma io dovrei salvare, altrimenti perdo tutto e devo rifare)

Non riesco a trovare il modello!? dove lo ha caricato? Non lo ha ancora caricato!


- `model.train()`  metodo che fa il training? 



## Tempo
- se freezo il train tranne l'ultimo layer ci mette 1:42 s
- se re-train tutto il modello ci ha messo circa 2:14 s

(ricorda che partiva gia' trainato)


## Train() e Eval()
sono due metodi associati al modello che precedentemente non avevo usato


```python
# prendo e modifico il codice di prima secondo quanto scritto nella lezione 14
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.optim import lr_scheduler  # nuovo non ancora  caricato prima
import torchvision
#import torchvision.transforms as transforms
from torchvision import datasets, models, transforms  # 
import matplotlib.pyplot as plt
import time                      # per controllare l'orario
import os                        # per interagire con l'os
import copy                      # per fare una deep copy del modello che e' un oggetto complesso (non vogliamo shallow copy)
import sys                       # per bloccare (c'e' una funzione tipo  stop del fortran)
%matplotlib inline

# device config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

mean = np.array([0.485, 0.456, 0.406])   # queste non so come sono state scelte
std = np.array([0.229, 0.224, 0.225])    # idem


# Hyper parametri 
input_size = 32*32    #  =1024 sono le dimensioni delle immagini
num_classes = 10      #  devo classificare immagini di numeri
num_epochs = 6        #  quanti giri completi vengono fatti
batch_size = 4        #  questo no so come sia stato scelto
learning_rate = 0.001 #  piccolo
hidden_size1  = 220   #  scelto da me
hidden_size2  = 184   #  scelto da me 


# qui faccio un dizionario che contiene le trasformazioni da applicare
data_transforms = {
    'train': transforms.Compose([transforms.RandomResizedCrop(224), 
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize(mean,std)])
    ,
    'val': transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean,std)
    ])
}

# import data
data_dir = 'data/hymenoptera_data'         # dove ci sono le api? Imenotteri
sets  = ['train', 'val']                   # lista che contiene mi sa che poi non lo usa


# Questo sotto e' da pensare un momento
# e' una list comprehension (in un dictionary)
# dove in realta' ci sono 2 directory, poteva mettere il path... e forse scriveva meno.
# in ogni caso la parte che non mi e' chiarissima sono i : dopo la x
# no e' banale: e' un dictionary e la x sono le chiavi e le datasets.Image... sono i valori
# tutti ottenuti con una list comprehension finale
image_datasets= {x:datasets.ImageFolder( os.path.join(data_dir, x), data_transforms[x] )
                 for x in ['train', 'val'] }

dataloaders  = {x: torch.utils.data.DataLoader(image_datasets[x],
                    batch_size = batch_size,
                    shuffle= True,
                    num_workers= 0) for x in  ['train', 'val']}


dataset_sizes  = {x: len(image_datasets[x]) for x in ['train', 'val']}
class_names  = image_datasets['train'].classes      # .classes e' un attributo 

print(class_names)
#sys.exit()                      # per fermare qui


######### funzione che contiene il training loop  ##############

def train_model(model, criterion, optimizer, scheduler, num_epochs=25): 
    since = time.time()     # penso chen questo sia il momento d'inizio

    best_model_wts = copy.deepcopy(model.state_dict())  # fa una deep copy del modello
    best_acc = 0.0                                      # 
    
    for epoch in range(num_epochs):
        print(f'Epoch {epoch}/{num_epochs-1}')
        print('-'* 10)                             # disegna una riga orizzontale
        
        # In ogni epoca si ha una fase di training e validation:
        for phase in ['train', 'val']:
            if phase== 'train':
                model.train()              # set model to train mode  #######################
            else:
                model.eval()               # set model to evaluation mode
            
            running_loss = 0.0             # in qualche modo voglio vedere live se il training va bene
            running_corrects =0
            

            for inputs, labels in dataloaders[phase]:       # distinguo tra le fasi train/val
                inputs = inputs.to(device)
                labels = labels.to(device)
            
                ################  forward pass
                with torch.set_grad_enabled(phase == 'train'):
                    outputs =  model(inputs)
                    _, preds = torch.max(outputs, 1)
                    loss = criterion(outputs,labels)
            
                ################ backward pass
                    if phase == 'train':
                        optimizer.zero_grad()      # non mi seve quando faccio l'ottimizzazione
                        loss.backward()            # chain rule
                        optimizer.step()           # mi muovo in funzione del gradiente
                 
                running_loss += loss.item() * inputs.size(0)
                running_corrects += torch.sum(preds==labels.data)  
            
            if phase =='train':
                scheduler.step()    # =========================  questo aggiorna il learning_rate
            
            epoch_loss =running_loss / dataset_sizes[phase]
            epoch_acc = running_corrects.double() / dataset_sizes[phase]
            
            print(f'{phase} Loss: {epoch_loss:.4f}  Acc: {epoch_acc:.4f} ')

            # deep copy model
            
            if phase =='val' and epoch_acc > best_acc:
                best_acc = epoch_acc
                best_model_wts = copy.deepcopy(model.state_dict())   # questo copia il dizionario associato al miglior modello
        
        print()
    time_elapsed = time.time() -since
    print(f'Training completato in {time_elapsed//60:.0f}  minuti {time_elapsed%60:.0f}s ')
           
    model.load_state_dict(best_model_wts)    
    return model    
        
######### importiamo il MODELLO ############### 

model = models.resnet18(pretrained=True )       # qui il modello e' importato da torchvision e lo mette nella cache

# se voglio bloccare tutti i parametri tranne quelli dell'ultimo layer basta che 
# li blocco:!

for param in model.parameters():
    param.requires_grad = False     # non fa il gradiente!

num_ftrs = model.fc.in_features                 # ho preso il layer fully connected (ultimo) e queste sono le input features?

# ora creo un nuovo layer e lo assegno come ultimo layer. 
# come faccio a sapere che l'ultimo layer si chiama `fc`?

model.fc = nn.Linear(num_ftrs, 2)  # ho solo 2 classi in uscita.  DI DEFAULT ha requires_grad = True
model.to(device)                    

criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.SGD(model.parameters(), lr=0.001 )   # occhio che lui aveva importato in modo diverso e chiama solo optim.SGD

############ SCHEDULER che fa una update del lr #######

step_lr_scheduler = lr_scheduler.StepLR(optimizer, step_size=7, gamma=0.1) # ogni 7 epoch lr =lr*gamma (diventa 1/10)

#for epoch in range(100):
#    train()   # optimizer.step()
#    evaluate()
#    scheduler.Step()
    
model = train_model(model, criterion, optimizer, step_lr_scheduler, num_epochs=20)

# qui alla fine ho trovato il modello ottimale, e potrei salvarlo volendo.

```

    ['ants', 'bees']
    Epoch 0/19
    ----------
    train Loss: 0.6456  Acc: 0.6230 
    val Loss: 0.5187  Acc: 0.8039 
    
    Epoch 1/19
    ----------
    train Loss: 0.5606  Acc: 0.7049 
    val Loss: 0.4390  Acc: 0.8627 
    
    Epoch 2/19
    ----------
    train Loss: 0.5181  Acc: 0.7623 
    val Loss: 0.4065  Acc: 0.8301 
    
    Epoch 3/19
    ----------
    train Loss: 0.4886  Acc: 0.7910 
    val Loss: 0.3304  Acc: 0.8954 
    
    Epoch 4/19
    ----------
    train Loss: 0.4584  Acc: 0.8197 
    val Loss: 0.3134  Acc: 0.8954 
    
    Epoch 5/19
    ----------
    train Loss: 0.4822  Acc: 0.7623 
    val Loss: 0.2991  Acc: 0.9085 
    
    Epoch 6/19
    ----------
    train Loss: 0.4221  Acc: 0.8115 
    val Loss: 0.2734  Acc: 0.9216 
    
    Epoch 7/19
    ----------
    train Loss: 0.4034  Acc: 0.8156 
    val Loss: 0.2741  Acc: 0.9216 
    
    Epoch 8/19
    ----------
    train Loss: 0.3629  Acc: 0.8852 
    val Loss: 0.2734  Acc: 0.9216 
    
    Epoch 9/19
    ----------
    train Loss: 0.4139  Acc: 0.8197 
    val Loss: 0.2570  Acc: 0.9216 
    
    Epoch 10/19
    ----------
    train Loss: 0.4058  Acc: 0.8402 
    val Loss: 0.2794  Acc: 0.9085 
    
    Epoch 11/19
    ----------
    train Loss: 0.4000  Acc: 0.8238 
    val Loss: 0.2611  Acc: 0.9346 
    
    Epoch 12/19
    ----------
    train Loss: 0.4265  Acc: 0.8156 
    val Loss: 0.2510  Acc: 0.9346 
    
    Epoch 13/19
    ----------
    train Loss: 0.3911  Acc: 0.8648 
    val Loss: 0.2729  Acc: 0.9085 
    
    Epoch 14/19
    ----------
    train Loss: 0.4748  Acc: 0.7787 
    val Loss: 0.2668  Acc: 0.9216 
    
    Epoch 15/19
    ----------
    train Loss: 0.3790  Acc: 0.8443 
    val Loss: 0.2865  Acc: 0.9020 
    
    Epoch 16/19
    ----------
    train Loss: 0.3815  Acc: 0.8730 
    val Loss: 0.2611  Acc: 0.9412 
    
    Epoch 17/19
    ----------
    train Loss: 0.3946  Acc: 0.8197 
    val Loss: 0.2722  Acc: 0.9020 
    
    Epoch 18/19
    ----------
    train Loss: 0.4166  Acc: 0.8525 
    val Loss: 0.2828  Acc: 0.9085 
    
    Epoch 19/19
    ----------
    train Loss: 0.3790  Acc: 0.8484 
    val Loss: 0.2649  Acc: 0.9216 
    
    Training completato in 1  minuti 42s 


# Tensorboard

https://pytorch.org/docs/stable/tensorboard.html

installazione, io ho usato conda: `conda install -c conda-forge/label/cf202003 tensorboard`


Tensorboard e' un metodo per visualizzare tramite delle dashboard visibili da browser:
- il grafo computazionale
- l'evoluzione dei parametri (Loss, accuracy, ecc...)
- nota che e' sviluppato per Tensorflow (ma funge anche con Pytorch)
- visualizzare istogrammi dei **pesi** e dei **bias**
- visualizzare immagini, testi, audio (eh si lavora anche con quelli)
- fare un profiling dei programmi di TensorFlow
- `Project embeddings in lower dimensional spaces`   ?????

Viene usato il codice del tutorial numero **13** (il riconoscimento delle immagini dei numeri da 0 a 9). Da quel codice ho tolto quasi tutti i commenti in modo che i commenti rimanenti siano solo per 
l'utilizzo di tensorboard

- Quando si lancia Tensorboard bisogna specificare il path dove verranno salvati i logfile. Di default vengono messi nella directory chiamata `run` (suppongo che sia una sottodir dell'installazione di Tensorboard

- per fare partire Tensorboad (dalla dir dove si e' lanciato il Python):  <br>
`tensorboard --logdir=runs` <br>
a questo punto si apre un browser alla pagina: <br>
`http://localhost:6006`

(CTRL+C = quit)

- La prima cosa che si fa e' essenzialmente istanziare un `writer`: `writer=SummaryWriter('runs/mnist')` (riga 12).
Il writer  in pratica scrive dei valori in formato JSON (controllare) con specifiche che tensorboard va a leggere nella dir runs e, note le chiavi le mette nella dashboard.

In pratica a quanto capisco, il writer scrive i dati in un formato particolare che viene poi
letto da tensorboard e mandato nella dashboard al localhost:6006. Questo e' il motivo per cui l'oggetto fondamentale e' un writer che ha dei vari metodi in grado di scrivere le informazioni dei vari oggetti in modo che Tensorboard le interpreti correttamente.



**I Esempio** di utilizzo: visualizzo i dati nel browser, consiste di 3 passi (piu' l'istanza del writer appena fatta):

1. Costruisco una griglia di immagini `img_grid  = torchvision.utils.make_grid(example_data)` (usando le utility di torchvision)
2. Do in pasto la griglia al writer, tramite il metodo add_image:  `writer.add_image('Immagini di Mnist', img_grid)`,
il primo argomento una label per la image grid, il secondo e' la griglia stessa
3. uso il metodo `writer.close()` per assicurarmi che tutti i dati siano mandati


**II Esempio** di utilizzo: visualizzo il grafo computazionale. Consiste di 2 passi. 
1. uso il metodo   `writer.add_graph(model, examples_data.reshape(-1,28*28).to(device))`,quindi il primo argomento e' il modello e il secondo sono ancora gli esempio (che ho flattenato). Attento, dato che sto mettendo tutto sul device, devo farlo anche per quanto riguarda examples_data, nel video non viene fatto! (questo perche' il notebook usato non ha una scheda grafica dedicata e quindi sono comunque tutti sull'host.
2. chiudo il writer per assicurarmi che tutti i dati vengano passati: `writer.close()`

Nota che dopo avere scritto l'esempio II,  appare una seconda scelta in tensorboard (in alto), chiamata graph. Si vede quindi il grafo computazionale che viene visualizzato. Con dei doppi click si aprono nel dettaglio i grafi!


**III Esempio** di utilizzo: mando la loss e la accuracy durante l'esecuzione. Consiste di 2 passi. Vogliamo la loss media durante il training, quindi aggiungo delle variabili al mdoello.
1. uso un nuovo metodo: `writer.add_scalar('Training loss', running_loss/100, epoch* n_total_steps + i)`
Nota che ho definito prima delle nuove quantita' da mandare al writer tramite add_scalar

**Attento** se continuo a fare girare la rete neurale nel notebook, i dati in Tensorboard si accumulano a quelli dei run precedenti. Devo trovare un modo per azzerare i dati.
`Soluzione`:<br>
devi rinominare la dir  dove vengono salvati i dati per ogni run diverso. In questo modo si avranno delle righe di colore diverso per ogni run. Altrimenti provo ad andare a cancellare il contenuto della dir `runs/mnist` (occhio che e' una cartella che viene creata nella stessa dir di dove gira il python!) (magari esiste un metodo migliore devo investigare). Ho cancellato tutto ma non funge... ok funge, li teneva in memoria! ho riavviato tensorboard ed e' sparito tutto. La cosa curiosa e' che aprendo gli eventi sembrano vuoti... Solo il primo contiene molti valori, il resto sono gli incrementi sul primo direi.

**Attento** quando ci sono degli scalari (dei grafici) di default Tensorboard aggiunge una linea di smoothing (e' nella modale(?) subito a sinistra).


**IV Eempio** di utilizzo: aggiungere una precision e recall curve (riguarda le note sulla confusoin matrix per le definizioni esatte). Esiste un metodo apposta per aggiungere la precision. Guarda il link: pytorch.org/docs/stable/tensorboard.html




```python
import numpy as np
import torch
import torch.nn as nn
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt
%matplotlib inline

from torch.utils.tensorboard import SummaryWriter   ##############  TENSORBOARD
import sys 
import torch.nn.functional as F

##### costruisco un writer ####################
writer  =SummaryWriter('runs/mnist') # come argomento serve la dir dove vanno salvati i file
#####    fine writer   ########################


device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

input_size = 28*28    
hidden_size  = 100    
num_classes = 10      
num_epochs = 2        
batch_size = 100      
learning_rate = 0.001 

train_dataset = torchvision.datasets.MNIST(root= './data/', train= True , transform =transforms.ToTensor(), download = True)
test_dataset  = torchvision.datasets.MNIST(root= './data/', train= False, transform =transforms.ToTensor(), download = False) # 

train_loader = torch.utils.data.DataLoader(dataset= train_dataset, batch_size = batch_size, shuffle=True)
test_loader = torch.utils.data.DataLoader (dataset=  test_dataset, batch_size = batch_size, shuffle=False)

examples = iter(test_loader)
examples_data, examples_targets = examples.next()
#for i in range(6):
#    plt.subplot(2,3,i+1)
#    plt.imshow(example_data[i][0], cmap='gray')

    
img_grid  = torchvision.utils.make_grid(examples_data)
writer.add_image('Immagini di Mnist' , img_grid)    
writer.close()     # questo assicura che tutti gli output sono flushati
#sys.exit()    # per non dover fare tutto il training    

############  MODELLO ####################
class NeuralNet(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(NeuralNet, self).__init__()
        self.l1 = nn.Linear(input_size, hidden_size)  
        self.relu = nn.ReLU()
        self.l2 = nn.Linear(hidden_size, num_classes)
       
    def forward (self, x):
        out = self.l1(x)       
        out = self.relu(out)   
        out = self.l2(out)
        return out             

############### ISTANZIO MODELLO, Back e Forw ########
model = NeuralNet(input_size, hidden_size, num_classes).to(device)
criterion  = nn.CrossEntropyLoss()   # non ha bisogno di parametri
optimizer = torch.optim.Adam(model.parameters(), lr = learning_rate)        


######  Aggiungo un altro grafo alla dashboard di Tensorboard,
###### ora uso il metodo     add_graph   (prima ho usato add_image)
writer.add_graph(model, examples_data.reshape(-1,28*28).to(device))
writer.close()
#sys.exit()

############### TRAINING LOOP ############
n_total_steps = len(train_loader)


running_loss = 0.0      # questo e' il valore aggiornato in tempo reale
running_correct = 0     # idem

for epoch in range(num_epochs):                           
   for i, (images,labels) in enumerate (train_loader):         
        images = images.reshape(-1, 28*28).to(device)     
        labels = labels.to(device)
              
        outputs = model (images)                           
        loss = criterion(outputs, labels)
                 
        optimizer.zero_grad()     
        loss.backward()            
        optimizer.step()          
        
################ da mandare a TENSORBOARD ####################        
        running_loss += loss.item()  # aggiorno il totale
        _, predicted  =torch.max(outputs.data, 1)
        running_correct += (predicted == labels).sum().item()
################ ##################### ########################        
        
        
        if (i+1) % 100 ==0:
            #print(f'epoch {epoch+1} / {num_epochs}, step {i+1}/{n_total_steps}, loss= {loss.item():.4f}')        

############## qui aggiungo alla dashboard un nuovo oggetto TENSORBOARD ######
            writer.add_scalar('Training loss', running_loss/100, epoch* n_total_steps + i)
            writer.add_scalar('Accuracy', running_correct/100, epoch* n_total_steps + i) 
            running_loss = 0.0     # riazzero
            running_correct = 0    # riazzero
            writer.close()
######################################################            
            
            

        
        
        
################ per Tensorboard ########################
labels2 = []   #occhio che aveva gia' definito labels sotto, ho messo un 2 Tensorboard
preds = []
#########################################################
        
############ TEST LOOP #################
with torch.no_grad():    
    n_correct = 0         
    n_samples = 0           
    for images, labels in test_loader:
        images = images.reshape(-1, 28*28).to(device)
        labels = labels.to(device)
        
        outputs = model(images)    
        
        _, predictions = torch.max(outputs,1)  
        n_samples += labels.shape[0]           
        n_correct += (predictions == labels).sum().item()
        
        class_predictions = [F.softmax(output, dim=0) for output in outputs]  # ho bisogno di probabilita', quindi serve softmax
        preds.append(class_predictions)
        labels2.append(predicted)   # per TENSORBOARD
        
    preds = torch.cat ([torch.stack(batch) for batch in preds ]) # tensorboard 2D oggetto 1000, 1
    labels2 = torch.cat(labels2)   # Tensorboard concateno le liste in un oggetto 1D        1000
    
    classes = range(10)   # tutte le possibili classi  0-9  Tensorboard
    for i in classes:
        labels_i = labels2 == i    # Tensorboard    non chiaro cosa fa
        preds_i = preds[:,i]      # Tensorboard 
        writer.add_pr_curve(str(i), labels_i, preds_i, global_step =0) # TEnsorboard
        writer.close()       # chiudo il writer
    
    
    acc = 100.0  * n_correct / n_samples       
    print(f'accuracy ={acc}')            
```

    accuracy =95.03


# I/O Saving and Loading Models
https://www.youtube.com/watch?v=9L9jEOwRrCg&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=17&ab_channel=PythonEngineer

Un modello viene salvato come un dictionary.

i 3 metodi da ricordare:
1. `torch.save(arg, PATH)` posso salvare tensor, model o dictiionary  (e posso usare Pickle)
2. `torch.load(PATH)`
3. `model.load_state_dict(arg)`
 
Ci sono 2 modi per salvare un modello: il modo `lazy` e modo `raccomandato` 

1. lazy: usando `torch.save(arg, PATH)` e poi carico il modello con `model =torch.load(PATH)`
A questo punto si usa:<br>
`model.eval()` in questo modo si entra in modalita' evaluation (da controllare)

Il difetto del metodo lazy e' che i dati "serializzati" (intende compressi con pickle) seguono esattamente la classe e la struttura di quando sono salvati.

2. modo raccomandato: basta salvare **SOLO** i parametri del modello stesso: <br>
`torch.save(model.state_dict(), PATH)` 

A questo punto devo creare un nuovo modello, e poi importare i parametri: <br>
`model= Model(*args, **kwargs)`<br>
`model.load_state_dict(torch.load(PATH))` <br>
`model.eval()`<br>    
    

- i modelli vengono salvati in file che hanno come estensione `pth`

Salviamo anche i checkpoint:<br>
un check point e' un dizionario di dizionari!
- i parametri del modello sono un dizionario
- i parametri dell'optimizer sono un dizionario
 -....
 
 Quindi quello che facciamo e' un dizionario in cui la prima key e' "model" e associamo
 il dizionario del modello, poi la chiave "optimizer" e il dizionario dell'ottimizzatore.
 Alla fine quando abbiamo bisogno usiamo checkpoint["model"] e lui mi restituisce il dizionario
 con i parametri del modello (o se ho scritto optimizer, quelli dell'ottimizzatore).







```python
######## LAZY method #################

import torch
import torch.nn as nn

class Model(nn.Module):  # eredita un oggetto nn.Module
    def __init__(self , n_input_features):
        super(Model, self).__init__()
        self.linear = nn.Linear(n_input_features, 1)

    def forward(self, x):
        y_pred = torch.sigmoid(self.linear(x))
        return y_pred
        
model =  Model(n_input_features=6)


######## SALVO IL MODELLO ############
FILE = "model.pth"       # solitamente i modelli hanno come estensione pth ?
torch.save(model, FILE)     

######## CARICO IL MODELLO ###########
model = torch.load(FILE)
model.eval()

for param in model.parameters():
    print(param)
```

    Parameter containing:
    tensor([[-0.3695,  0.2621,  0.0619, -0.2925, -0.3088, -0.2284]],
           requires_grad=True)
    Parameter containing:
    tensor([-0.2680], requires_grad=True)



```python
########## Metodo raccomandato ###########

import torch
import torch.nn as nn

class Model(nn.Module):  # eredita un oggetto nn.Module
    def __init__(self , n_input_features):
        super(Model, self).__init__()
        self.linear = nn.Linear(n_input_features, 1)

    def forward(self, x):
        y_pred = torch.sigmoid(self.linear(x))
        return y_pred
        
model =  Model(n_input_features=6)
#for param in model.parameters():
#    print('Prima',param)

######## SALVO IL MODELLO ############
FILE = "model-raccomandato.pth"       # solitamente i modelli hanno come estensione pth ?
torch.save(model.state_dict(), FILE)  # salvo solo i parametri del modello   

######## Prima devo definire un modello #####
loaded_model = Model(n_input_features=6)        # creo un modello con la stessa struttura
loaded_model.load_state_dict(torch.load(FILE))  # carico i parametri
loaded_model.eval()                             # setto il modello in eval mode.


#for param in loaded_model.parameters():
#    print('Dopo', param)
```




    Model(
      (linear): Linear(in_features=6, out_features=1, bias=True)
    )




```python
############# Check point  ####################

import torch
import torch.nn as nn

class Model(nn.Module):  # eredita un oggetto nn.Module
    def __init__(self , n_input_features):
        super(Model, self).__init__()
        self.linear = nn.Linear(n_input_features, 1)

    def forward(self, x):
        y_pred = torch.sigmoid(self.linear(x))
        return y_pred
        
model =  Model(n_input_features=6)
learning_rate = 0.01
optimizer = torch.optim.SGD(model.parameters(), lr= learning_rate)

print(optimizer.state_dict())

####### CHECK point ######

checkpoint  = {         # e' un dizionario
    "epoch":90,         # per esempio siamo alla epoca 90
    "model_state": model.state_dict(),
    "optim_state": optimizer.state_dict()
}

torch.save(checkpoint, "checkpoint.pth")

#  a questo punto posso caricare:

loaded_checkpoint  =torch.load("checkpoint.pth")
epoch  =loaded_checkpoint["epoch"] 
model = Model(n_input_features=6)

optimizer = torch.optim.SGD(model.parameters(), lr=0) # mettiamo 0 e poi carichiamo la corretta lr
model.load_state_dict(checkpoint["model_state"])
optimizer.load_state_dict(checkpoint["optim_state"])

print(optimizer.state_dict())




```

    {'state': {}, 'param_groups': [{'lr': 0.01, 'momentum': 0, 'dampening': 0, 'weight_decay': 0, 'nesterov': False, 'params': [0, 1]}]}
    {'state': {}, 'param_groups': [{'lr': 0.01, 'momentum': 0, 'dampening': 0, 'weight_decay': 0, 'nesterov': False, 'params': [0, 1]}]}


## Salvare modelli da GPU
Minuto 16 circa.

Gli esempi sopra fungono se tutt il modello e' tenuto sulla CPU (sia per load che train, validation).

**map_location**
argomento di `load_state_dict(PATH, map_location=device)`

non e' chiaro cosa intenda per *save on GPU* (io salvo su disco! magari intende che il modello e' sulla GPU e poi lo metto su disco)



```python
import torch
import torch.nn as nn

# SAVE sulla GPU, load sulla CPU

device = torch.device("cuda")
model.to(device)
torch.save(model.state_dict(), PATH)


device =torch.device("cpu")
model = Model(*args, **kwargs)
model.load_state_dict(torch.load(PATH, map_location=device))

#####################################

# SAVE sulla GPU, load sulla GPU

device = torch.device("cuda")
model.to(device)
torch.save(model.state_dict(), PATH)


device =torch.device("cpu")
model = Model(*args, **kwargs)
model.load_state_dict(torch.load(PATH))
model.to(device)                      


#####################################

# SAVE sulla CPU, load sulla GPU


torch.save(model.state_dict(), PATH)


device =torch.device("cuda")
model = Model(*args, **kwargs)
model.load_state_dict(torch.load(PATH, map_location="cuda:0")  # 0 e' per la GPU zerp
model.to(device)                        
                      
                      
                      
                      
```

# Creare e deployare un modello pytorch con Flask
questo lo salto per ora.

# Recurrent Neural Network

Url di riferimento: https://www.youtube.com/watch?v=WEV61GmmPrk&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=19&ab_channel=PythonEngineer

Note e Slide: https://github.com/python-engineer/pytorch-examples


Lezione interessante del MIT sulle RNN
https://www.youtube.com/watch?v=qjrad0V0uJE&ab_channel=AlexanderAmini

© Alexander Amini and Ava Soleimany  <br>
MIT 6.S191: Introduction to Deep Learning <br>
IntroToDeepLearning.com <br>


`Attenzione` alla notazione: il **hidden-tensor** non e' un **hidden layer** del modello! E' un tensore che viene usato per la predizione ma non e' l'input!

`Nota` descrivo con qualche immagine in piu' le RNN, LSTM e RCU nel prossimo capitolo.

`Scopo`: costruire una rete neurale ricorrente RNN, che prenda una dopo l'altra le singole lettere di un nome (ogni lettera sara' un input) e alla fine dell'ultima lettera dica a quale lingua appartiene il nome

- usiamo batch di dimensione 1  qui (1 lettera)

`LOGICA`
- un nome e' una sequenza di lettere.
- ogni lettera vine trasformata in un tensore-lettera che diventa `parte` dell'input della rete neurale.
- Perche' ho scritto solo `parte` dell'input? Perche' l'input e' una concatenazione di un tensore-lettera e un tensore-hidden!
- la rete neurale restituisce in output a quale lingua appartiene la lettera ... ma dato che in input c'e' anche il tensore-hidden modificato dallo strato lineare (**hidden tensor**), c'e' memoria delle lettere precedenti, quindi ha senso dire la lingua di appartenenza di una sola lettera: c'e' comunque la memoria derivante dalle altre lettere ottenuta tramite il tensore hidden! 
- come secondo output la rete neurale emette anche un nuovo tensore-hidden (che verra' usato al passo successivo, concatenandolo al  tensore-lettera successivo)
- alla fine della parola mi deve dire di che lingua stiamo parlando.

Le parole sono spezzate in modo da diventare sequenze di tensori, secondo la logica **one-hot encoderd**. Supponiamo di avere un alfabeto di 6 lettere: `a, e, i, o, u, l.`
    La parola `aiuola` diventa la seguente sequenza di tensori 1D contennti 6 ingressi:
    
**a**= 
$\left( \begin{array}{c}
   {\bf 1}  \\
   0  \\
   0  \\ 
   0  \\
   0  \\
   0  \\
   \end{array} \right)$
,$~~~$**i**= 
$\left( \begin{array}{c}
   0  \\
   0  \\
   {\bf 1}  \\ 
   0  \\
   0  \\
   0  \\
   \end{array} \right)$
,$~~~$**u**= 
$\left( \begin{array}{c}
   0  \\
   0  \\
   0  \\ 
   0  \\
   {\bf 1}  \\
   0  \\
   \end{array} \right)$ 
,$~~~$**o**= 
$\left( \begin{array}{c}
   0  \\
   0  \\
   0  \\ 
   {\bf 1}  \\
   0  \\
   0  \\
   \end{array} \right)$ 
,$~~~$**l**= 
$\left( \begin{array}{c}
   0  \\
   0  \\
   0  \\ 
   0  \\
   0  \\
  {\bf 1}  \\
   \end{array} \right)$ 
,$~~~$**a**= 
$\left( \begin{array}{c}
  {\bf 1}  \\
   0  \\
   0  \\ 
   0  \\
   0  \\
   0  \\
   \end{array} \right)$ 
   
Il tensore hidden invece ha una dimensione che fissiamo noi (nell'esempio 128), al passo 0 viene inizializzato con tutti 0, 
ma ai passi successivi si popola perche' lo strato lineare che costruisce le versioni successive del tensore hidden prende in ingresso sia il tensore combinato che il tensore della lettera. Per esempio se la lettera passata e' la $a$ e il tensore-hidden e':<br>
**hidden** = 
$\left( \begin{array}{c}
  {\bf 0.3}  \\
   0.23  \\
   \dots  \\ 
   0.29  \\
   0.52  \\
   0.11  \\
   \end{array} \right)$ 
$\begin{array}{c}
   1  \\
   2  \\
   \dots  \\ 
   126  \\
   127  \\
   128  \\
   \end{array}$    
Allora il **tensore-combinato** = 
$\left(\begin{array}{c}
     {\bf a}  \\
    {\bf hidden}  \\
   \end{array} \right)$ =
$\left( \begin{array}{c}
   {\bf 1}  \\
   0  \\
   0  \\ 
   0  \\
   0  \\
   0  \\
  {\bf 0.3}  \\
   0.23  \\
   \dots  \\ 
   0.29  \\
   0.52  \\
   0.11  \\
   \end{array} \right)$ 
(in questo esempio  il tensore combinato ha dimensione 6 + 128 (perche' in questo esempio l'alfabeto per  l'one-hot encoring contiene solo *aeioul*, mentre la dimensione del tensore combinato nel video di Python Engineer e' 57 +128, perche' l'alfabeto da lui usato contiene tutte le maiuscole, le minuscole e alcuni segni di punteggiatura.



![cane]({{ site.baseurl }}/images/posts/pytorch/rnn-nomi-lingue.png)

`Osservazione`
Il tensore che viene dato in pasto alla fully connected layer e' la versione concatenata di: 
- one-shot encoded  (che ha dim 57 nel nostro caso, le maiuscole, minuscole e qualche segno di punteggiatura
- hidden tensor (che ha dimensione 128, perche' lo abbiamo scelto noi). 

Questo tensore concatenato viene dato in pasto anche ad un'altra fully connected layer in modo da mantenere la
memoria di quanto e' successo.


Nel video del MIT si dice che per fare il training di una RNN si usano la cosiddetta: `BPTT` (Backpropagation through time)
occhio che nel nostro caso non mi pare che si faccia.  Nel dettaglio la backpropagation si fa sulla loss soltanto, e quindi l'hidden tensor e' considerato come un input non come un peso. Per questo non mi e' chiaro come venga aggiornato il tensore dei pesi che ho chiamato W2 nell'immagine.



`PROBLEMI`

- ho provato a mandare tutto sul device CUDA ma rallenta! sospetto che sia perche' copio sul device di volta in volta.
Il tempo che impiega (su 5000 passi) e' 23 s col device e 13 sulla cpu! Vediamo se riesco ad evitare di copiare le cose in GPU ogni passaggio per velocizzare il calcolo. Mettendo line_tensor e hidden prima ho guadagnao, ora sono 20 s (comunque piu' lento che con la CPU)


- Che strano: rifacendolo andare qualche giorno successivo ci mette 307 secondi! (sulla CPU) e se provo a farlo andare sulla GPU dice che ci sono problemiperche' alcune cose sono su CPU e altre su GPU.  Seguendo le indicazioni ho messo line_tensor.to(device) e ora sembra fungere linea 188.

- ho inserito tutto fino a quando fa "whole sequence/name" ma ottengo un errore non ben chiaro:
"IndexError: Dimension out of range (expected to be in range of [-1, 0], but got 1)". Errore trovato: avevo scritto 
`inout_tensor` invece che `input_tensor`

- Il tensore in uscita ha dimensione 128 invece che 18 (il numero di lingue) e non capisco perche'! Chiaro avevo scritto: 
`self.i2o = nn.Linear(input_size + hidden_size , hidden_size)` che quindi mi dava come dimensione di uscita del layer lineare `hidden_size` invece che `output_size`!  


`Note`:
Nella lezione si fa uso di funzioni di aiuto "helper functions" (io all'inizio capivo alpha-functions...). Python Engineer le mette in un modulo, mentre io le ho riscritte all'inizio del codice qui sotto 


```python
# dati https://download.pytorch.org/tutorial/data.zip

import io
import os
import unicodedata
import string
import glob       # ?

import torch
import random


#  Helper Functions

# Alfabeto minuscolo e maiuscolo
ALL_LETTERS = string.ascii_letters + ".,;''"   # insieme delle lettere e della punteggiatura usata
N_LETTERS  = len(ALL_LETTERS)

# converti un UNICODE in ASCII grazie a https://www.stackoverflow.com/a/518232/2809427
# in pratica trasforma le lettere accentate in lettere NON accentate
def unicode_to_ascii(s):
    return ''.join( c for c in unicodedata.normalize('NFD',s) if unicodedata.category(c) != "Mn" and c in ALL_LETTERS)

# costuisce un dizionario "category_lines" e una lista di nomi per le varie lingue
def load_data():
    category_lines = {}     # dizionario
    all_categories = [] 

    def find_files(path):
        return glob.glob(path)    # glob??? The glob module finds all the pathnames matching a specified pattern according to ...
    
    # leggi un file e spezzalo in linee
    def read_lines(filename):
        lines = io.open(filename, encoding='utf-8').read().strip().split('\n')
        return [unicode_to_ascii(line) for line in lines]
    
    for filename in find_files('data/names/*.txt'):
        category = os.path.splitext(os.path.basename(filename))[0]
        all_categories.append(category)
    
        lines = read_lines(filename)
        category_lines[category]  =lines
        
    return category_lines, all_categories
        
# trova l'indice di posizione associato ad una lettera nalla parola

def letter_to_index(letter):
    return ALL_LETTERS.find(letter)

# trasforma una lettera in un tensore 1 x n letters (tensore riga)

def letter_to_tensor(letter):
    tensor =torch.zeros(1, N_LETTERS)  
    tensor[0][letter_to_index(letter)]=1
    return tensor

# trasforma una linea in una <line_length x 1 x n_letters>
# o un array hon-hot letter

def line_to_tensor(line):
    tensor = torch.zeros(len(line), 1, N_LETTERS)
    for i, letter in enumerate(line):
        tensor[i][0][letter_to_index(letter)]=1
    return tensor

def random_training_example(category_lines, all_categories):
    
    def random_choice(a):
        random_idx = random.randint(0,len(a)-1)
        return a[random_idx]
    
    category = random_choice(all_categories)
    line =random_choice(category_lines[category])
    category_tensor = torch.tensor([all_categories.index(category)], dtype=torch.long)
    line_tensor = line_to_tensor(line)
    return category, line, category_tensor, line_tensor


###############################################################################
###############################################################################
###############################################################################
#print(ALL_LETTERS)
#category_lines , all_categories = load_data()
#print(category_lines['Italian'][:5])
#print(letter_to_tensor('J'))                # trasforma la lettera J (maiuscola) in un tensore one-hot encoding (sono 1D con 57 ingressi)
#print(line_to_tensor('Jones').size())       # Jones contiene 5 lettere, ognuna e' trasformata in un tensore 1D con 57 ingressi 

#test = line_to_tensor('Jones')
#print(test)
##################  ok sopra funge correttamente   ###################


# ho gia'importato torch sopra
import torch.nn  as nn
import matplotlib.pyplot as plt
import time

# from utils import ALL_LETTERS, N_LETTERS # qui non serve perche' fanno gia' parte di questo listato
# from load_data, letter_to_tensor, ...  

#device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
device = torch.device('cpu')


# esiste gia' un RNN in Torch, qui pero' lo creiamo da zero.

class RNN(nn.Module):  
    def __init__(self, input_size, hidden_size, output_size):
        super(RNN, self).__init__()
        
        self.hidden_size = hidden_size
        self.i2h = nn.Linear(input_size + hidden_size , hidden_size)   # ricorda che servono solo le dimensioni: dim tensore combinato, dim uscita
        self.i2o = nn.Linear(input_size + hidden_size , output_size)   # input 2 output
        self.softmax = nn.LogSoftmax(dim=1) # input ha dimensione 1,57, quindi softmax sulle colonne
        
    
    def forward (self, input_tensor, hidden_tensor):
        combined = torch.cat((input_tensor, hidden_tensor ),1)   #concatena input tensor e hidden tensor: nuova dimensione= input_size+hidden_size

        hidden = self.i2h(combined)      # qui spara fuori l'oggetto hidden, i pesi di questo layer non sono l'oggetto hidden!
        output = self.i2o(combined)      # qui indica la guess riguardo la nazione
        output = self.softmax(output)    # qui usa la softmax per ottenere valori di probabilita'
        return output, hidden            # restituisce sia l'output che l'hidden per il prossimo passo
    
    def init_hidden(self):                             # inizializza lo hidden_tensor alla dimensione hidden_size
        return torch.zeros(1, self.hidden_size)


category_lines, all_categories = load_data()  # chiave valore, nazione chiave, nome valore, e poi tutte le nazioni
n_categories = len(all_categories)
#print(n_categories)

n_hidden  =128   # selto da me
rnn = RNN(N_LETTERS, n_hidden, n_categories).to(device)  # qui ho inizializzato il modello, servono i parametri del costruttore



# likelyhood di ogni nazione, vogliamo l'indice della categoria massima
def category_from_output(output):
    category_idx  = torch.argmax(output).item()
    return all_categories[category_idx]
    
#print(category_from_output(output))
#print(output)

####### facciamo il training ######
criterion = nn.NLLLoss()      # negative log likelihood loss
learning_rate = 0.005         #
optimizer = torch.optim.SGD(rnn.parameters(), lr=learning_rate)

#  funzione helper che fa il training metto il tensore e la sua label
def train(line_tensor, category_tensor):    

    hidden = rnn.init_hidden().to(device)                    # azzero l'hidden tensor iniziale
    #        hidden = hidden.to(device)
    #line_tensor = line_tensor.to(device)
    for i in range (line_tensor.size()[0]): 
        # lunghezza del nome
        #l2d = line_tensor[i].to(device)
        
#        output, hidden = rnn(l2d, hidden)
        output, hidden = rnn(line_tensor[i], hidden)  # inserisco i 2 tensori di input: lettera one-shot e hidden
     
    category_tensor = category_tensor.to(device)
    #output = output.to(device) # inventato da me ma da comunque errore
    loss = criterion(output, category_tensor)
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()
    

    return output, loss.item()




current_loss = 0
all_losses  = []
plot_steps, print_steps = 100000, 100000
n_iters = 100000


since = time.time()     # il momento d'inizio
for i in range (n_iters):
    category, line, category_tensor, line_tensor = random_training_example(category_lines, all_categories)
    
    line_tensor = line_tensor.to(device)
    
    output, loss = train(line_tensor, category_tensor)
    current_loss += loss
    
    if (i+1)% plot_steps == 0:
        all_losses.append(current_loss /plot_steps)
        current_loss =0
        
    if (i+1)% print_steps ==0:
        guess = category_from_output (output)
        correct = "Corretto" if guess == category else f" Sbagliato ( {category})"
        print (f'{i} {i/n_iters*100} {loss:.4f} {line}/{guess}{correct}  ' )
        
        
    if (i+1)% 100000 ==0:
        print('Tempo impiegato ', time.time() -since)   
        
        
#plt.figure()
#plt.plot(all_losses)

#############  data una stringa in ingresso 
def predict(input_line):
    print(f'\n> {input_line}')                        # la riscrive 
    with torch.no_grad(): 
        line_tensor  = line_to_tensor(input_line)     # trasforma in un tensore
        
        hidden = rnn.init_hidden()                    # crea lo stato iniziale vuoto da dare in pasto
        
        for i in range (line_tensor.size()[0]):       # gira sui tensori one-hot encoded
            output, hidden = rnn(line_tensor[i], hidden)   # usa la rete neurale, uno dietro l'altro, cosi' hidden si aggiorna
            
        guess = category_from_output(output)          # Ottiene dal numero il nome della nazione
        print(guess)                                  # stampa il nome della nazione 
    
            
########## qui si imparano molte cose #######
while True:
    sentence = input("Inserisci un nome (quit per terminare)")      # scrive a video
    if sentence  == 'quit':                     # esci dal ciclo se scrivi quit
        break
    predict(sentence)                           # usa la rete neurale e scrivi la predizione

```

    99999 99.99900000000001 1.3037 Woo/Chinese Sbagliato ( Korean)  
    Tempo impiegato  319.30727434158325
    Inserisci un nome (quit per terminare)quit


# RNN, GRU e LSTM 

url: https://www.youtube.com/watch?v=0_PgWWmauHk&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=20&ab_channel=PythonEngineer

nn.RNN: https://pytorch.org/docs/stable/generated/torch.nn.RNN.html

Stanford: https://stanford.edu/~shervine/teaching/cs-230/cheatsheet-recurrent-neural-networks
Questa e' probabilmente la guida piu' precisa, la matematica usa delle notazioni diverse dalle altre due (per esempio l'hidden tensor viene indicato con a), masuppongo che sia la piu' affidabile.


Una guida illustrata su LSTM e GRU: https://towardsdatascience.com/illustrated-guide-to-lstms-and-gru-s-a-step-by-step-explanation-44e9eb85bf21 qui cerca di non mettere la matematica, ma ci sono delle gif animate.

Qui indica anche un po' di matematica: http://dprogrammer.org/rnn-lstm-gru  ma sospetto che le formule non corrispondano alle immagini (ha preso le immagini da qualche parte e le formule altrove). Di buono mette anche le formule per la backpropagation!



Qui usiamo i moduli gia' creati per Long Short Term Memory e per GRU. Si prende come punto di partenza il tutorial 13.

Invece che guardare a tutta una immagine per volta vogliamo prendere una `sequenza` di righe

Usiamo Architettura Many to 1 (molti input e un solo output)

Commentando e decommentando le parti con GRU e LSTM si ottengono tutte e 3 le architetture.
 In realta' sono solo 2 le righe che vanno cambiate tra GRU e RNN e 3 per LSTM (si deve mettere anche la cella)! 

Nel codice qui sotto si fa una sorta di estensione rispetto al lavoro fatto nel capitolo 13 (Feed Forward NN )

`RNN` di torch.nn.RNN e' una Elman: 
$$
\large
\displaystyle
h_t = \tanh\left( \frac{} {} 
  W_{ih} x_t +b_{ih}  + W_{hh} h_{t-1}+b_hh 
  \right)
$$
- $h_t$ hidden state al tempo $t$
- $h_{t-1}$ hidden state al tempo $t-1$ (eh... abbastanza ovvio)
- $x_t$ input al tempo $t$
- $W_{ih}$ sono i **pesi** che contribuiscono a $h_t$ dal tensore di input $x_t$ 
- $b_{ih}$ sono i `bias` che contribuiscono a $h_t$ dal tensore di input
- $W_{hh}$ sono i **pesi** che contribuiscono a 
- $b_{hh}$ sono i `bias` (non chiaro perche' vengano distinti rispetto a b_{ih}, alla fine sono delle costanti...
- $x_t$ vettore di input al tempo t
- $\hat{y}_t$ vettore di output al tempo t 
- $y_t$ le label vere (ground truth) al tempo t


$$
\large
\displaystyle
\hat y_t = 
  W_{hy} h_t +b_{hy}
$$

`Empirical Loss`:
- Quando si ha una RNN si hanno diversi output per ognuno dei "tempi" t
- Si sommano i valori delle loss.

ok a questo punto pero' dovrebbero anche esserci i pesi per l'output, nella formula sopra vedo solo l'equazione per l'hidden state.

Vediamo un grafico per **LSTM**:
![LSTM]({{ site.baseurl }}/images/posts/pytorch/LSTM.jpg)



```python
import numpy as np
import torch
import torch.nn as nn
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt
%matplotlib inline

# device config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
#device = torch.device('cpu')

# Hyper parametri 
#input_size = 28*28    #  =784 sono le dimensioni delle immagini
hidden_size  = 128   #  scelto da me
num_classes = 10      #  devo classificare immagini di numeri
num_epochs = 2        #  quanti giri completi vengono fatti
batch_size = 100        #  questo no so come sia stato scelto
learning_rate = 0.001 #  piccolo

input_size = 28        # singolo input e' la riga     RNN
sequence_length =28    # ci sono 28 righe             RNN
num_layers = 2         # di default =1                RNN



train_dataset = torchvision.datasets.MNIST(root= './data/', train= True, 
                                           transform =transforms.ToTensor(),
                                          download = True)

test_dataset = torchvision.datasets.MNIST(root= './data/', train= False, 
                                           transform =transforms.ToTensor(),
                                          download = False) # 

train_loader = torch.utils.data.DataLoader(dataset= train_dataset, batch_size = batch_size, shuffle=True)

test_loader = torch.utils.data.DataLoader (dataset=  test_dataset, batch_size = batch_size, shuffle=False)

### nota che la dimensione dei sample e' la seguente
# 100  = numero di immagini nel batch (se non metti batch_size, di default vale 1)
#   1  = numero di canali solitamente i colori
#  28  =  numero di ingressi sull'asse delle x
#  28  = numero di ingressi sull'asse delle y
        

############  MODELLO ####################

class RNN(nn.Module):   
    def __init__(self, input_size, hidden_size, num_layers, num_classes):
        super(RNN, self).__init__()
        self.num_layers = num_layers     # RNN
        self.hidden_size = hidden_size   # RNN
        #self.rnn = nn.RNN(input_size, hidden_size, num_layers, batch_first=True)  # RNN , l'ordine e' importante batch set first dimension RNN
        #self.gru = nn.GRU(input_size, hidden_size, num_layers, batch_first=True)  # GRU 
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)  # LSTM         
        
        # x -> batch_size, seq, input_size
        self.fc = nn.Linear(hidden_size, num_classes) # RNN questo e' per l'ultimo passo della sequenza per avere la classificazione
       
    
    # RNN da documentazione ora servono 2 input, uno e' lo stato e l'altro e' l'hidden state
    def forward (self, x): 
        h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(device)  # RNN numero di layer, batch size, hidden size
        
        c0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(device)  # LSTM initial cell  
        
        
        #out, _ = self.rnn(x, h0) # RNN restituisce 2 outputs, uno out e hidden state per step n
        #out, _ = self.gru(x, h0) # GRU restituisce 2 outputs, uno out e hidden state per step n       
        out, _ = self.lstm(x, (h0,c0)) # LSTM restituisce 2 outputs, uno out e hidden state per step n       
        
        # RNN batch_size, sequence_length, hidden_size
        
        # RNN vogliamo l'hidden state dell'ultimo step
        # RNN out (N, 28, 28)
        out = out[:, -1, :]  # RNN serve solo l'ultimo time step quindi metto -1 e tutte le feature dell'hidden size
        # RNN out(N, 128)
        out = self.fc (out)  # RNN
        return out
        
        

############### ISTANZIO MODELLO, Loss, optimizer  ########
model = RNN(input_size, hidden_size, num_layers,  num_classes).to(device)
criterion  = nn.CrossEntropyLoss()                                         # 
optimizer = torch.optim.Adam(model.parameters(), lr = learning_rate)       # 
n_total_steps = len(train_loader)



for epoch in range(num_epochs):                          #   
   for i, (images,labels) in enumerate (train_loader):   #      
        # 100, 1, 28, 28  (batch, canali, x, y) forma del tensore images
        # 100, 28x28=784  forma voluta dall'hidden layer
        images = images.reshape(-1, sequence_length, input_size).to(device)     # Ora vogliamo solo righe e tante.
        labels = labels.to(device)
              
        outputs = model (images)        #  non chiama il metodo forward: perche'?
        loss = criterion(outputs, labels)
                 
        # backward pass
        optimizer.zero_grad()    # 
        loss.backward()          # 
        optimizer.step()         # 
        
        if (i+1) % 100 ==0:
            print(f'epoch {epoch+1} / {num_epochs}, step {i+1}/{n_total_steps}, loss= {loss.item():.4f}')        

            
############ TEST LOOP e' identico a RNN e FeedForward! #################
with torch.no_grad():    
    n_correct = 0         # numero di predizioni azzeccate
    n_samples = 0         # ? 
    for images, labels in test_loader:
        images = images.reshape(-1,sequence_length, input_size).to(device)
        labels = labels.to(device)
        
        outputs = model(images)               # qui il modello e' gia' trainato!
        
        _, predictions = torch.max(outputs,1) # prendo la classe che ha il valore massimo
        n_samples += labels.shape[0]          # numero di samples nel batch corrente (nell'ultimo sono diversi spesso)
        n_correct += (predictions == labels).sum().item()
        
    acc = 100.0  * n_correct / n_samples # accuratezza in percentuale
    print(f'accuracy ={acc}')            
```

    epoch 1 / 2, step 100/600, loss= 0.9440
    epoch 1 / 2, step 200/600, loss= 0.5394
    epoch 1 / 2, step 300/600, loss= 0.3369
    epoch 1 / 2, step 400/600, loss= 0.1903
    epoch 1 / 2, step 500/600, loss= 0.2440
    epoch 1 / 2, step 600/600, loss= 0.1913
    epoch 2 / 2, step 100/600, loss= 0.1267
    epoch 2 / 2, step 200/600, loss= 0.1024
    epoch 2 / 2, step 300/600, loss= 0.0285
    epoch 2 / 2, step 400/600, loss= 0.1911
    epoch 2 / 2, step 500/600, loss= 0.1058
    epoch 2 / 2, step 600/600, loss= 0.1007
    accuracy =97.46


# PyTorch Lightning

https://www.youtube.com/watch?v=Hgg8Xy6IRig&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=21&ab_channel=PythonEngineer

PyTorch Lightning  e' un wrapper per velocizzare la scrittura di reti neurali, con Pytorch.

Sito di Pytorch Lightning
https://www.pytorchlightning.ai/

Per istallarlo: `conda install pytorch-lightning -c conda-forge`


**Non** e' piu' necessario:
- model.train() (ovvero settare il modello  in  training mode)
- model.eval()  (ovvero settare il modello  in  evaluation mode)
- definire una `device` e fare model.to(device)  si puo' "sconnettere" la GPU facilmente
- optimizer.zero_grad()  
- loss.backwards()
- optimizer.step()
- with torch.nograd()
- x= x.detach

**Bonus**
- stampa consigli e aiuti!
- supporto Tensorboard: viene costruito un folder chiamato `lightning_logs`.
Per usare tensorboard `tensorboard  --logdir lightning_logs`  (e' il nome della dir creata in automatico, nel video fa un errore e scrive log_dir)



A questo punto per fare inspecting del training, creiamo un altro dict.


Usiamo il codice del tutorial 13 e lo modifichiamo per PyTorch Lightning.

`Suggerimenti`:
-suggerisce di usare il metodo `validation_epoch_end()` per accumulare statistiche. Nota che nel video Loeber copia i metodi dal sito e li modifica per l'occasione. Questo metodo viene poi piazzato all'interno del modello





`Domande`:
mi viene GPU present = True, used False, devo accendere l'uso della GPU. Si va nel metodo `Trainer` e si mette: `trainer=Trainer(gpus=1, max_epochs=num_epochs, fast_dev_run =True)`. Ok ho controllato e ora la GPU e' presente e usata... ma il tempo di esecuzione praticamente non cambia!
- Si puo' usare anche una TPU e anche un `distributed backend` una DDP
- Si puo' passare a precisione 16 bit
- in Trainer si puo' mettere anche il karg: `auto_lr_find =True` per il learning rate
- in Trainer si puo' mettere anche il karg: `deterministic =True` per riprodurre esattamente i risultati
- in Trainer si puo' mettere anche il karg: `gradient_clip_val =0.3` (un numero tra 0 e 1 per fare clipping dei gradienti)

`Problemi`:<br>
- nel video si vede la loss che scende in basso a dx mentre per me e' un NAN. Ok il problema era che non facevo "ritornare" nulla dal metodo `training_step` che invece deve restituire un dict della forma {'loss':loss}, che viene preso direttamente dal PL e mostrato nella barra sotto 
- non vedo apparire la fase di validazione con una barra che si riempie (nel video c'e')
- mi da il seguente warning: UserWarning: The {log:dict keyword} was deprecated in 0.9.1 and will be removed in 1.0.0
Please use self.log(...) inside the lightningModule instead.
#log on a step or aggregate epoch metric to the logger and/or progress bar (inside LightningModule)
self.log('train_loss', loss, on_step=True, on_epoch=True, prog_bar=True)
  warnings.warn(*args, **kwargs)
- In tensor borad non riesco a trovare train_loss (e' uno scalare ma non lo trovo)


```python
import numpy as np
import torch
import torch.nn as nn
import torchvision
import torchvision.transforms as transforms
import matplotlib.pyplot as plt
import time

import torch.nn.functional as F 

import pytorch_lightning as pl # PL
from pytorch_lightning import Trainer 

%matplotlib inline

# device config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')


# Hyper parametri 
input_size = 28*28      #  =784 sono le dimensioni delle immagini
hidden_size  = 500      #  scelto da me
num_classes = 10        #  devo classificare immagini di numeri
num_epochs = 2          #  quanti giri completi vengono fatti
batch_size = 100        #  questo non so come sia stato scelto
learning_rate = 0.001   #  piccolo

#train_dataset = torchvision.datasets.MNIST(root= './data/', train= True, transform =transforms.ToTensor(), download = True)
#test_dataset = torchvision.datasets.MNIST(root= './data/', train= False, transform =transforms.ToTensor(), download = False) # ho gia' scaricato tutto con il train_datast

#train_loader = torch.utils.data.DataLoader(dataset= train_dataset, batch_size = batch_size, shuffle=True)
#test_loader = torch.utils.data.DataLoader (dataset=  test_dataset, batch_size = batch_size, shuffle=False)


############  MODELLO ####################


#class NeuralNet(nn.Module):             #vecchi
class LitNeuralNet(pl.LightningModule):  # nome scelto da noi, pl.LightningModule e' la versione super di nn.Module    
    def __init__(self, input_size, hidden_size, num_classes):
        super(LitNeuralNet, self).__init__()
        self.input_size = input_size
        self.l1 = nn.Linear(input_size, hidden_size)  
        self.relu = nn.ReLU()
        self.l2 = nn.Linear(hidden_size, num_classes)
       
    def forward (self, x):    # x e' l'input.
        out = self.l1(x)      # 
        out = self.relu(out)  # 
        out = self.l2(out)
        return out            # 

    
    def training_step(self, batch, batch_idx):  # PL non uso piu' i loop!!!! 
        #x,y = batch           # unpack
        images, labels  =batch # PL unpack
        images = images.reshape(-1,28*28)   # non e' piu' necessairo to(device)
        
        #y_hats = self(x)     # ????
        outputs  = self(images)  # PL questo e' il forward pass! usiamo self perche' usiamo direttamente questo modulo
        
        #loss = F.cross_entropy(y_hat, y)
        loss =F.cross_entropy(outputs, labels)
        
        tensorboard_logs = {'train_loss':loss}    # devo metterlo anche nel validatio_epoch_end
        return {'loss':loss, 'log':tensorboard_logs}   # PL i nomi delle chiavi sono FISSI: e' log non Log
        #return {'loss': loss}
    
    
    
    def configure_optimizers(self):  # PL ma il nome e' fissato da PL? penso di si'
        #optimizer = torch.optim.Adam(self.parameters(), lr = learning_rate)  # non ho capito se serve o no...   
        return torch.optim.Adam(self.parameters(), lr= 0.001)  #  PL self e' l'istanza del modello
    
    def train_dataloader(self):
        #dataset = MNIST(os.getcwd(), train=True, download=True, transform =transforms.ToTensor())
        #loader = DataLoader (dataset, batch_size= 32, num_workers=1, shuffle=True)   #lui ha messo num_workers = 4
        train_dataset = torchvision.datasets.MNIST(root= './data/', train= True, transform =transforms.ToTensor(), download = True)
        train_loader = torch.utils.data.DataLoader(dataset= train_dataset, batch_size = batch_size, num_workers=4, shuffle=True)
        return train_loader
    
    # il nome deve essere questo!
    def val_dataloader(self):
        val_dataset = torchvision.datasets.MNIST(root= './data/', train= False, transform =transforms.ToTensor(), download = False) # ho gia' scaricato tutto con il train_datast
        val_loader = torch.utils.data.DataLoader (dataset= val_dataset, batch_size = batch_size, num_workers=4, shuffle=False)
        return val_loader    
    
    
    # questo viene eseguito dopo ogni epoch di validazione
    def validation_epoch_end(self, outputs):
        avg_loss = torch.stack([x['val_loss'] for x in outputs]).mean()
     
        tensorboard_logs  = {'tavg_val_loss': avg_loss} # PL per ora non lo guardiamo
        return {'tavg_val_loss': avg_loss, 'log':tensorboard_logs}
        #return {'val_loss': avg_loss}    
    

start = time.time()
#trainer = Trainer(max_epochs = num_epochs, fast_dev_run = False)  # PL Trainer e' importato da PL
trainer = Trainer(gpus=1,max_epochs = num_epochs, fast_dev_run = False)  # PL Trainer e' importato da PL

model = LitNeuralNet(input_size, hidden_size, num_classes)        # PL istanzio il modello  
trainer.fit(model)                                                # faccio il training sul modello
print("Tempo training+test= ", time.time()-start)    
    

```

    GPU available: True, used: True
    TPU available: None, using: 0 TPU cores
    
      | Name | Type   | Params
    --------------------------------
    0 | l1   | Linear | 392 K 
    1 | relu | ReLU   | 0     
    2 | l2   | Linear | 5.0 K 
    --------------------------------
    397 K     Trainable params
    0         Non-trainable params
    397 K     Total params
    1.590     Total estimated model params size (MB)



    HBox(children=(HTML(value='Training'), FloatProgress(value=1.0, bar_style='info', layout=Layout(flex='2'), max…


    
    Tempo training+test=  12.651966094970703


# LR Scheduler
url di riferimento: https://www.youtube.com/watch?v=81NJgoR5RfY&list=PLqnslRFeH2UrcDBWF5mfPGpqQDSta6VK4&index=22&ab_channel=PythonEngineer

Vediamo come sfruttare le funzioni di Pytorch che automaticamente modificano il learning rate per ottenere dei risultati ottimali.

Spesso (intuitivamente) si vuole diminuire il `Learning Rate`. La logica a mio avviso e' la seguente, quando mi avvicino al minimo se non diminuisco il LR rischio di saltare da una parte all'altra del minimo stesso.

Per questo si usa uno scheduler.
Onestamente non mi pare ultra necessario, uno puo' costruire delle funzioni custom che facciano la cosa ogni volta.  Anzi se uso una funzione che non ho scritto io c'e' la possibilita' che io non controlli perfertamente.

Una interessante e' che si riduce solo se una certa metrica ha raggiunto un plateau.



`Osservazioni`
- in python // e' floor division.


# Autoencoder

https://www.youtube.com/watch?v=zp8clK9yCro&t=1075s&ab_channel=PythonEngineer

Un autoencoder e' una rete neurale che cerca di "riassumere i tratti principali dell'input. L'idea e' molto sempice, 
Pensiamo a delle immagini. Si prende e si fanno vari strati che hanno via via meno parametri. A quel punto si fanno i passi inversi (letteralemente) in modo da riottenere un medesimo numero di valori finali. Come funzione di Loss si usa una MSE. E' intuitivo. se ho una immagine in ingresso voglio vedere la STESSA immagine in uscita (o almeno avvicinarmi)

Risorsa da cui sono in pratica presi i codici:
https://www.cs.toronto.edu/~lczhang/360/lec/w05/autoencoder.html

Qui il corso da cui sono prese i codici particolari dell'autoencoder:
https://www.cs.toronto.edu/~lczhang/360/



## Senza convoluzioni


```python
import torch
import torch.nn as nn  
import torch.optim as optim
from torchvision import datasets, transforms
import matplotlib.pyplot as plt

transform = transforms.ToTensor()
mnist_data = datasets.MNIST(root='./data', train=True, download=True, transform=transform)
data_loader = torch.utils.data.DataLoader(dataset =mnist_data,
                                         batch_size=64, shuffle=True)

type(mnist_data[1])
len(mnist_data[59999][0][0])
type(mnist_data[59999][0][0].numpy())
mnist_data[59999][0][0].numpy().size
```




    784




```python
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu') 
dataiter  = iter(data_loader)
images, labels = dataiter.next()
```


```python
class Autoencoder (nn.Module):
    def __init__(self):
        super().__init__()
        # N= 784 (28x28)
        self.encoder = nn.Sequential(      # funzione di pytorch che fa andare uno dopo l'altro varie funzioni
            nn.Linear(28*28,128),           # numero di punti in ingresso (28*28) e neuroni in uscita(128)
            nn.ReLU(()), 
            nn.Linear(128,64),              
            nn.ReLU(()),             
            nn.Linear(64,12),               
            nn.ReLU(()),             
            nn.Linear(12,6),                # 
        )
        
        self.decoder = nn.Sequential(      # funzione di pytorch che fa andare uno dopo l'altro varie funzioni
            nn.Linear(6,12),           # numero di punti in ingresso (28*28) e neuroni in uscita(128)
            nn.ReLU(()), 
            nn.Linear(12,64),              
            nn.ReLU(()),             
            nn.Linear(64,128),               
            nn.ReLU(()),             
            nn.Linear(128,28*28)                # 
        )
        
    
    def forward (self,x):
        encoded = self.encoder(x)
        decoded = self.decoder(encoded)
        return decoded
```


```python
model = Autoencoder ().to(device)
criterion = nn.MSELoss()
optimizer  = torch.optim.Adam(model.parameters(), lr= 1e-3 , weight_decay = 1e-5)
```


```python
num_epochs = 10
outputs = []  
for epoch in range(num_epochs):
    for (img, _) in data_loader:
        img   = img.reshape(-1,28*28).to(device)
        recon = model(img).to(device)
        loss = criterion(recon, img)
        
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        
        
    print(f'Epoch: {epoch+1}, Loss:{loss.item():.4f}')
    outputs.append((epoch, img, recon))
```

    Epoch: 1, Loss:0.0426
    Epoch: 2, Loss:0.0405
    Epoch: 3, Loss:0.0284
    Epoch: 4, Loss:0.0297
    Epoch: 5, Loss:0.0298
    Epoch: 6, Loss:0.0283
    Epoch: 7, Loss:0.0273
    Epoch: 8, Loss:0.0265
    Epoch: 9, Loss:0.0249
    Epoch: 10, Loss:0.0265


ci sono dei problemi di visualizzazione rispetto al codice scritto da Python Engineer. Riguardando un po' 
la struttura ho trovato la soluzione


```python
#print(len(outputs[0]) )
outputs[1][2].shape
varie = outputs[0][2].detach().reshape(-1,28*28).numpy()
u=varie[0,:].reshape(28,28)
u.shape
plt.imshow(u)
#plt.imshow(outputs[0][2].detach().reshape(-1,28*28).numpy())
```




    <matplotlib.image.AxesImage at 0x1d0474e0730>




![png]({{ site.baseurl }}/images/posts/pytorch/output_105_1.png)



```python
for k in range(0, num_epochs,4):
    plt.figure(figsize= (9,2))
    plt.gray() 
    imgs  = outputs[k][1].detach().numpy()
    recon = outputs[k][2].detach().numpy()
    
    for i, item in enumerate(imgs):
        if i>=9:break               # prendi solo le prime 9
        plt.subplot(2,9,i+1)
        item = item.reshape(-1,28*28)
        plt.imshow(item[0].reshape(28,28))
    
    for i, item in enumerate(recon):
        if i>=9:break               # prendi solo le prime 9
        plt.subplot(2,9,9+i+1)
        item = item.reshape(-1,28*28)
        plt.imshow(item[0].reshape(28,28))
```


![png]({{ site.baseurl }}/images/posts/pytorch/output_106_0.png)



![png]({{ site.baseurl }}/images/posts/pytorch/output_106_1.png)



![png]({{ site.baseurl }}/images/posts/pytorch/output_106_2.png)


## Con Convoluzioni
qui sotto prendo un modello migliore, che sfrutti le convoluzioni e riesca a dare dei risultati piu' precisi nella ricostruzione. 


```python
import torch
import torch.nn as nn  
import torch.optim as optim
from torchvision import datasets, transforms
import matplotlib.pyplot as plt

transform = transforms.ToTensor()
mnist_data = datasets.MNIST(root='./data', train=True, download=True, transform=transform)
data_loader = torch.utils.data.DataLoader(dataset =mnist_data,
                                         batch_size=64, shuffle=True)
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu') 
dataiter  = iter(data_loader)
images, labels = dataiter.next()
```


```python
class Autoencoder (nn.Module):
    def __init__(self):
        super().__init__()
        # N= 784 (28x28)
        self.encoder = nn.Sequential(      # funzione di pytorch che fa andare uno dopo l'altro varie funzioni
            nn.Conv2d(1, 16, 3, stride=2, padding =1),    # canali input, output, kernel, stride, padding | N 16 14 14
            nn.ReLU(()), 
            nn.Conv2d(16,32, 3, stride=2, padding =1),    # N 32 7  7         
            nn.ReLU(()),             
            nn.Conv2d(32,64, 7 )    # N 64  1  1 (64 parametri in uscita)             
        )
        
        self.decoder = nn.Sequential(      # funzione di pytorch che fa andare uno dopo l'altro varie funzioni
            nn.ConvTranspose2d(64, 32, 7),   # N 32 7 7   
            nn.ReLU(()), 
            nn.ConvTranspose2d(32, 16, 3, stride=2, padding =1, output_padding=1),   # N 16 14 14                 
            nn.ReLU(()),             
            nn.ConvTranspose2d(16,  1, 3, stride=2, padding =1, output_padding=1),   # N 1 28 28                  
            nn.Sigmoid()             
        )
        
    
    def forward (self,x):
        encoded = self.encoder(x)
        decoded = self.decoder(encoded)
        return decoded
    
# nn.MaxPool2d  e  nn.MaxUnpool2d    
```


```python
model = Autoencoder ()   .to(device)
criterion = nn.MSELoss()
optimizer  = torch.optim.Adam(model.parameters(), lr= 1e-3 , weight_decay = 1e-5)
```


```python
num_epochs = 10
outputs = []  
for epoch in range(num_epochs):
    for (img, _) in data_loader:
        img   = img.to(device)          #.to(device)
        #recon = model(img)             #.to(device)
        recon = model (img).to(device)
        loss = criterion(recon, img)
        
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        
        
    print(f'Epoch: {epoch+1}, Loss:{loss.item():.4f}')
    outputs.append((epoch, img, recon))
```

    Epoch: 1, Loss:0.0097
    Epoch: 2, Loss:0.0062
    Epoch: 3, Loss:0.0047
    Epoch: 4, Loss:0.0039
    Epoch: 5, Loss:0.0036
    Epoch: 6, Loss:0.0035
    Epoch: 7, Loss:0.0028
    Epoch: 8, Loss:0.0030
    Epoch: 9, Loss:0.0031
    Epoch: 10, Loss:0.0027



```python
for k in range(0, num_epochs,4):
    plt.figure(figsize= (9,2))
    plt.gray() 
    imgs  = outputs[k][1].cpu().detach().numpy()
    recon = outputs[k][2].cpu().detach().numpy()
    
    for i, item in enumerate(imgs):
        if i>=9:break               # prendi solo le prime 9
        plt.subplot(2,9,i+1)
        item = item.reshape(-1,28*28)
        plt.imshow(item[0].reshape(28,28))
    
    for i, item in enumerate(recon):
        if i>=9:break               # prendi solo le prime 9
        plt.subplot(2,9,9+i+1)
        item = item.reshape(-1,28*28)
        plt.imshow(item[0].reshape(28,28))
```


![png]({{ site.baseurl }}/images/posts/pytorch/output_112_0.png)



![png]({{ site.baseurl }}/images/posts/pytorch/output_112_1.png)



![png]({{ site.baseurl }}/images/posts/pytorch/output_112_2.png)


## My Playground


- nota che quando fai andare prima il modello lineare e poi quello convoluzionale due volte i parametri continuano ad aggiornarsi, quindi la seconda volta ottieni dei valori piu' precisi!
- per esempio provo a mettere un parametro: min_par che indica il numero minimo di parametri (nell'esempio e' 64, io provo 32, ecc



```python
import torch
import torch.nn as nn  
import torch.optim as optim
from torchvision import datasets, transforms
import matplotlib.pyplot as plt

transform = transforms.ToTensor()
mnist_data = datasets.MNIST(root='./data', train=True, download=True, transform=transform)
data_loader = torch.utils.data.DataLoader(dataset =mnist_data,
                                         batch_size=64, shuffle=True)
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu') 
dataiter  = iter(data_loader)
images, labels = dataiter.next()
```


```python
min_par=4

class Autoencoder (nn.Module):
    def __init__(self):
        super().__init__()
        # N= 784 (28x28)
        self.encoder = nn.Sequential(      # funzione di pytorch che fa andare uno dopo l'altro varie funzioni
            nn.Conv2d(1, 16, 3, stride=2, padding =1),    # canali input, output, kernel, stride, padding | N 16 14 14
            nn.ReLU(()), 
            nn.Conv2d(16,32, 3, stride=2, padding =1),    # N 32 7  7         
            nn.ReLU(()),             
            nn.Conv2d(32,min_par, 7 )    # N 64  1  1 (64 parametri in uscita)             
        )
        
        self.decoder = nn.Sequential(      # funzione di pytorch che fa andare uno dopo l'altro varie funzioni
            nn.ConvTranspose2d(min_par, 32, 7),   # N 32 7 7   
            nn.ReLU(()), 
            nn.ConvTranspose2d(32, 16, 3, stride=2, padding =1, output_padding=1),   # N 16 14 14                 
            nn.ReLU(()),             
            nn.ConvTranspose2d(16,  1, 3, stride=2, padding =1, output_padding=1),   # N 1 28 28                  
            nn.Sigmoid()             
        )
        
    
    def forward (self,x):
        encoded = self.encoder(x)
        decoded = self.decoder(encoded)
        return decoded
    
# nn.MaxPool2d  e  nn.MaxUnpool2d    
```


```python
model = Autoencoder ()   .to(device)
criterion = nn.MSELoss()
optimizer  = torch.optim.Adam(model.parameters(), lr= 1e-3 , weight_decay = 1e-5)
```


```python
num_epochs = 10
outputs = []  
for epoch in range(num_epochs):
    for (img, _) in data_loader:
        img   = img.to(device)          #.to(device)
        #recon = model(img)             #.to(device)
        recon = model (img).to(device)
        loss = criterion(recon, img)
        
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        
        
    print(f'Epoch: {epoch+1}, Loss:{loss.item():.4f}')
    outputs.append((epoch, img, recon))
```

    Epoch: 1, Loss:0.0467
    Epoch: 2, Loss:0.0362
    Epoch: 3, Loss:0.0390
    Epoch: 4, Loss:0.0337
    Epoch: 5, Loss:0.0352
    Epoch: 6, Loss:0.0327
    Epoch: 7, Loss:0.0348
    Epoch: 8, Loss:0.0359
    Epoch: 9, Loss:0.0347
    Epoch: 10, Loss:0.0356



```python
for k in range(0, num_epochs,4):
    plt.figure(figsize= (9,2))
    plt.gray() 
    imgs  = outputs[k][1].cpu().detach().numpy()
    recon = outputs[k][2].cpu().detach().numpy()
    
    for i, item in enumerate(imgs):
        if i>=9:break               # prendi solo le prime 9
        plt.subplot(2,9,i+1)
        item = item.reshape(-1,28*28)
        plt.imshow(item[0].reshape(28,28))
    
    for i, item in enumerate(recon):
        if i>=9:break               # prendi solo le prime 9
        plt.subplot(2,9,9+i+1)
        item = item.reshape(-1,28*28)
        plt.imshow(item[0].reshape(28,28))
```


![png]({{ site.baseurl }}/images/posts/pytorch/output_118_0.png)



![png]({{ site.baseurl }}/images/posts/pytorch/output_118_1.png)



![png]({{ site.baseurl }}/images/posts/pytorch/output_118_2.png)
