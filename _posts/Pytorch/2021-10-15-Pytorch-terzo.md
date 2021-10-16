---
published: false
categories: italiano
tags:
  - Python
  - DeepLearning
  - Neural Nets
  - Cuda
maths: 1
comments_id: 15
toc: 1
---

# PyTorch e Deep Learning
**[primo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-primo.md %})**
# Tensor Basics 
**[primo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-primo.md %})**
# Gradient Calculation con Autograd 
**[secondo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-secondo.md %})**
# Backpropagation - teorie ed esempi 
**[secondo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-secondo.md %})**
# Gradient Descent con Autograd e Backpropagation 
**[secondo post]({{ site.baseurl }}{% link _posts/Pytorch/2021-10-15-Pytorch-secondo.md %})**

# LOSS e OPTIMIZER di PyTorch
qui vediamo qualche esempio di:
- LOSS function (criterion)
- Optimizer, ovvero le metodologie che vengono usate per fare l'update dei pesi per migliorare la loss (dato che devo minimizzare la loss sto facendo una ottimizzazione, o minimizzazione nel dettaglio!)

Questo codice e' molto simile al precedente. La differenza e' nell'optimizaer, ovvero che strategia viene portata avanti per minimizzare le LOSS. In pratica ci sono varie funzioni che prendono come argomento il gradiente rispetto ad un tensore e minimizzano la funzione.

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

-  **model = nn.Linear(input_size, output_size)**  modello lineare, ha 2 argomenti i parametri in ingresso e in uscita.
- **X = torch.tensor([[1], [2], [3], [4]])** occhio al formato [1] = prima riga, [2] =seconda riga, [3] = terza riga, [4]= quarta riga. X.shape = 4 righe, 1 colonna.
- ATTENTO: **optimizer = torch.optim.SGD(model.parameters(), lr=learning_rate)** all'ottimizzatore da in pasto un parametro, il learning rate.


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
Qui viene definito il dataloader. Supponi di avere un classificatore di immagini. In ingresso prende una immagine e  in uscita mi dice a che classe appartiene (per esempio gatto-cane). Non posso fare il training su una sola immagine, altrimenti farei un overfit. Quello che normalmente si fa e' passare dei batch, fare il training e poi fare il trainig su nuovi batch. In alcuni casi in modo incrementale, ovvero batch successivi includono quelli precedenti.

Secondo Python Engineer e' anche vero il contrario. Se do tutto il training data fare delle gradient calculations (backpropagation) diventa computazionalemtne oneroso.

**Osservazione** di natura `notazionale`, di solito Loeber nelle istanze che crea, usa il medesimo nome della funzione/classe di Torch, ma con tutte le lettere minuscole. Per esmpio, in PyTorch esiste `Dataset` e lui chiama la sua istanza: `dataset` (minuscolo). Mi pare un'ottima convenzione che aiuta a ricordare i nomi delle funzioni, metodi e classi.


- si fa un loop (esterno) su tutte le epoch
- per ogni epoch si fa un loop (interno) su tutti i batch 
- l'ottimizzazione viene fatta **solo** sul batch


- **epoch** un passo forward e un backward di **TUTTI** i campioni del training.
- **batch** un sottoinsieme di elementi del training dataset
- **batch_size** numero di campioni di training in un forward/backward pass.
- **numero di iterazioni** numero di passi, ogni passo(forward/backward) usa "batch_size" campioni

Per esempio:
- 100 campioni
- batch_size=20
- 5 iterazioni  formano  1 epoch

I DataLoader sono **CLASSI** fanno la computazione del batch (la gestiscono).
Vengono ereditati da "torch.utils.data import DataLoader.

1. implmentano un Dataset custom (voluto dall'utente)
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
in torchvision ci sono gia' molti dataset disponibili che consentono di fare molti esperiemnti.
Le classi Dataset e Dataloader invece sono in `torch.utils.data`

- un Dataset e' `subscriptable` (ovvero posso fare mioDataset[1] e ottengo l'oggetto al secondo posto del dataset
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
