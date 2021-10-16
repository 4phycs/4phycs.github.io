---
published: false
categories: italiano
tags:
  - Python
  - DeepLearning
  - Neural Nets
  - Cuda
maths: 1
comments_id: 16
toc: 1
---


# Installazione  **[PyTorch 1]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-primo.md %})**.

# PyTorch e Deep Learning
**[primo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-primo.md %})**
# Tensor Basics
**[primo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-primo.md %})**

# ChainRule e Autograd 
Il pacchetto `Autograd` fornisce differenziazione automatica per le operazioni (funzioni) sui tensori:<br>
**requires_grad=True** <br>
Immagina un **tensore** come una semplice variabile (multidimensionale) che entra in un grafo computazionale. Alla fine del grafo ho uno scalare (in genere) e voglio sapere come dipende questo scalare dal un particolare tensore, allora devo usare Autograd.
$$
\displaystyle
L(z(x)): R^n \rightarrow R  
$$




## Teoria ed esempio di un grafo computazionale 
Per esempio:
- costruisco un tensore x  (1D con 3 ingressi random)
- costruisco un tensore y funzione di x: **y=x+2** 
- costruisco un tensore z funzione di y: **z= 3y$^2$**
- ATTENTO il gradiente si puo' calcolare solo se alla fine si hanno dei valori SCALARI (altrimenti ho un numero di gradienti pari alle componenti del vettore). La logica e' chiara, alla fine io voglio vedere come varia una funzione di LOSS rispetto ai parametri che metto nella rete neurale. La LOSS e' una funzione scalare e quindi non sono state implementate delle variazioni per funzioni vettoriali.
- calcolo quindi il valore medio di **u=\<z\>** (per avere uno scalare)

$
{\bf x}=
\left(
 x_1 \\
 x_2 \\
 x_3
\right)
$
$
\left(
\mycolv{C_1\\C_2} 
\right)
$
$
{\bf y}=
\left(
\begin{eqnarray}
 y_1 \\
 y_2 \\
 y_3
\end{eqnarray}
\right)
$
$
=
\left(
\begin{eqnarray}
 x_1+2 \\
 x_2+2 \\
 x_3+2
\end{eqnarray}
\right)
$

$
{\bf z}
=
\left(
\begin{eqnarray}
 3y_1^2 \\
 3y_2^2 \\
 3y_3^2
\end{eqnarray}
\right)
$
$
=
\left(
\begin{eqnarray}
 3(x_1+2)^2 \\
 3(x_2+2)^2 \\
 3(x_3+2)^2
\end{eqnarray}
\right)
$
$
=
\left(
\begin{eqnarray}
 3(x_1^2+4x_1+4) \\
 3(x_2^2+4x_2+4) \\
 3(x_3^2+4x_3+4)
\end{eqnarray}
\right)
$




$
\displaystyle
u = \frac{1}{3}\sum_{i=1}^3z_i = \frac{1}{3} \sum 3y_i^2  =  \sum y_i^2 \mbox{  Derivata parziale}  \Rightarrow  \frac{\partial u}{\partial y_k} = 2 y_k
$

Se voglio conoscere la dipendenza di ${\bf u}$ da parte di ${\bf x}$, dal punto di vista matematico devo calcolare la derivata parziale di u rispetto a x:  

$
\displaystyle \frac{ \partial u } {\partial x_j} = \frac{\partial u}{\partial y_i} \frac{\partial y_i}{\partial x_j} 
$ (indici ripetuti sono sommati)

$
\displaystyle
 \frac{\partial u}{\partial y_k} = 2 y_k = 2(x_k+2)
$

$
\displaystyle
 \frac{\partial y_k}{\partial x_j} = \delta_{kj}
$

Quindi:
$
\displaystyle \frac{ \partial u } {\partial x_k} = 2(x_k+2)
$

Se il valore del tensore ${\bf x_0} = (1, 1, 1)$, alora il gradiente rispetto alla variaibile x della funzione u e' un vettore che vale:

$
\nabla_x u |_{x_0} = 
=
\left(
\begin{eqnarray}
 2(x_1+2) \\
 2(x_2+2) \\
 2(x_3+2)
\end{eqnarray}
\right)
$
$
=
\left(
\begin{eqnarray}
 6 \\
 6 \\ 
 6 
\end{eqnarray}
\right)
$

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
- costruisco una funzoine che fa il backward pass
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

# Gradient Calculation con Autograd 
**[secondo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-secondo.md %})**
# Backpropagation - teorie ed esempi 
**[secondo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-secondo.md %})**
# Gradient Descent con Autograd e Backpropagation 
**[secondo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-secondo.md %})**
# Training Pipeline: Model, Loss, e Optimizer 
**[terzo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-secondo.md %})**

# Regressione Lineare 
# Regressione Logistica 
# Dataset e DataLoader - Batch Training 
# Dataset Transforms 
# Softmax e Cross Entropy 
# Activation Functions 
# Feed-Forward Neural Network 
# Convolutional Neural Network 
# Transfer Learning 
# How to use TensorBoard 
# Saving and loading Models 
# Create and Deploy A Deep Learning App - PyTorch Model Deployment with Flask 
# RNN Tutorial- Name Classification Using a Recurrent 
# RNN & LSTM & GRU Recurrent Neural Nets 
# Lightning Tutorial Lightweight PyTorch Wrapper for ML 
# LR Scheduler - Adjust the learning Rate for Better Results

    
    