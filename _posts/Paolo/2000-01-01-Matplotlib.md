---
title: 'Matplotlib - appunti'
categories: italiano
tags:
  - Paolo
  - Python
maths: 1
comments_id: 25
bigimg: null
published: true
toc: 1
date: 2021-11-07T00:00:00.000Z
---


# Matplotlib

Queste sono le mie (Paolo Avogadro) note, basate su questo 
**[video](https://www.youtube.com/watch?v=wB9C0Mz9gSo&ab_channel=DerekBanas)** di Derek Banas. Oltre agli esempi suggeriti aggiungo dei miei test e considerazioni.
Qualunque errore e' esclusivamente dovuto ad una mia erronea interpretazione dei comandi. Lo scopo di queste note non e' di
presentare esempi perfettamente funzionanti, ma serve a me come spunto per ricordare i comandi di Matplotlib, e il modello mentale che io ho sul pacchetto.
 La versione originale di queste note ha la forma di un Jupyter Notebook
e quindi possono esserci dei riferimenti ai notebook all'interno del testo

Cerco di ricostruire gli esempi presentati e fare delle piccole varianti per capire meglio. Queste note suppongono che ci sia una certa conoscenza di base di come fare i grafici al computer, per esempio partendo da **Gnuplot**.

Notazione:
- cerco di usare l'evidenziatore per i `comandi`
- cerco di usare il **grassetto** per i termini principali

Micro-riassunto: 

Ci sono 2 modi principali per fare un grafico:
1. modo veloce: con le funzioni di plotting, per esempio: `plt.plot(x_1, y_1)` (dove x_1 e x_2 sono due oggetti contenenti lo stesso numero di variabili). Si possono inoltre aggiungere delle funzioni per controllare le label, il titolo ecc.
 
2. modo esteso: 
 - prima si definisce una **figure**, per esempio: `fig_1 = plt.figure(figsize=(5,4), dpi =100);` pensa alla figure come un'immagine bianca. 
 - poi si costruisce uno (o piu') axes (assi) con un **metodo** delle **figure**: `axes_1 = fig_1.add_axes([0.1,0.1,0.9,0.9])` (dove specifichiamo la posizione degli assi all'interno della figura). Gli assi determineranno la posizione del grafico. Per esempio se hai un solo quadrante per il tuo grafico puoi immaginare gli assi come un rettangolo (vuoto all'interno).   
 - A questo punto si fa partire un grafico, usando un **metodo** degli **assi**, per esempio: `axes_1.plot(x_1,y_1);`  Nota che questi metodi sono in pratica le stesse funzioni del punto 1 (solo che vengono chiamati come metodi dell'asse). 

**Nota**
- se **non** sei in un *jupyter notebook* dovrai usare un `plt.show()` 
- se sei su un notebook invece, serve un *magic command* (e' una di quelle cose decorate con il percentuale),  ci sono vari di questi comandi, tra cui:
  1. `%matplotlib inline`   (questo fa apparire delle immagini png statiche nel notebook)
  2. `%matplotlib notebook` (si possono fare zoom delle immagini)
  3. `%matplotlib tk`  (tkinter GUI)



Una lista di termini utili:

- `alpha=0.75` definisce la **trasparenza** 
- `lw=2`  larghezza delle **linee** del grafico
- `ls ='-.'` **line style**, se e' una linea continua, oppure trattino e punto, ecc...
- `marker = 'o'` marker sono i **punti** di gnuplot. Cosa viene messo nei punti? in questo caso dei cerchietti =o) 
- `markersize=7` la **grandezza** dei punti
- `markerfacecolor ='y'` il colore dell'interno dei punti
- `markeredgecolor='k'` il colore dei contorni dei punti 
- `markeredgewidth=2` la larghezza del contorno dei punti
- `projection='3d'` argomento per quando si creano degli **assi** e devono avere un **3D**
- `goog_df = pd.read_csv('GOOG.csv', index_col = 0, parse_dates=True)` trasforma del **testo in datetime**!
- `facecolor` e' il colore dello sfondo di un'immagine

Metodi di FIGURE:

- `fig.tight_layout()` oppure,  `plt.tight_layout()` serve per **evitare sovrapposizioni** per esempio i numeri degli assi trasbordino
- `fig_3.savefig('ultimoPlot.png')` **salvare a file** una figura!


Metodi degli Assi

- `plt.xticks(np.linspace(0,5,5), ('Tom', 'Dick', 'Harry', 'Sally', 'Sue'))`  **tics** (o **ticks**) sull'asse x. Per non avere ticks: `plt.xticks([])` (non ho messo nulla nella lista = **non** ci sono ticks) 
- `axes_3.set_xlim([0,3])`  definisce i **limiti sull'asse x** (set xlim[1:100])
- `axes_4.set_xlabel('temp')`               **label degli assi**   
- `axes_3.grid(False, color='r', dashes=(0,2,1,2))` mette una **griglia sullo sfondo**, occhio che *color* e' il colore della griglia non dello sfondo. `plt.grid(False)` e `plt.grid(b=None)` tolgono la griglia
- `axes_3.set_facecolor('w')` colore dello **sfondo** (bianco in questo caso)
- `axes_4.set_title('da Pandas: IceCream')` **titolo**
- `axes_1.legend(loc =0 )`                      # Loc=0 e' la migliore location scelta da lui`   

Tipi di disegno (possono essere chiamati come metodi degli assi o funzioni plt):

- `axes_4.plot(x_2, y_2)`  disegno **standard** in cui ci sono i punti e posso unirli, cambiarli ecc.
- `plt.bar(x_2, y_2, width=1.5);` **barchart** (come istogramma ma sulle x possono essere categorici)
- `plt.stem(x_2, y_2, '-.')` **impulsi**, interessante si puo' indicare il tipo di linea
- `plt.hist(arr3ok, bins= 7, density=True, stacked =False);` **istogrammi** (raggruppa i valori sull'asse delle x in bins)
- `plt.pie()` piechart **TORTE** (gurada sotto perche' servono un po' di dettagli)
- `axes_13.scatter(dr_arr, test_arr,  s=cc_arr_sm, c=color_arr, alpha=0.2 )` **scatterplot** valori sull'asse delle x, y, dimensione punti, colori dei punti, trasparenza)
-  `axes_9.scatter3D(x_3,y_3,z_3, c=z_3, cmap='Blues');` **scatterplot 3D**
- `axes_9.contour3D(x_4,y_4,z_4, 20, cmap='Blues');` **3D** contorno, curve di livello, **isoipse**
- `axes_9.plot_wireframe(x_4,y_4,z_4, cmap='Blues');` **wireframe** e' il grafico **3D** standard di gnuplot, collega tutti i punti
- `axes_9.plot_surface(x_4,y_4,z_4, rstride=1, cstride=1,  cmap='Blues', edgecolor='r');` **3D**, collega i punti e colora le tegole








**Consiglio**:
in un Jupyter notebook usa **shift-tab** su una funzione per vederne la sua descrizione (prima devi cliccare sulla cella e poi avere il cursore sulla funzione stessa). 


**Consiglio** questo [articolo](https://www.dataquest.io/blog/jupyter-notebook-tips-tricks-shortcuts/) contiene trucchi su jupyter notebook e alternative a Matplotlib. 


```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
%matplotlib inline
#%matplotlib notebook
%reload_ext autoreload
%autoreload 2             
```

# Functional Plot
Cominciamo con un'immagine semplice in cui
- c'e' il titolo: `plt.title('ciao')`
- ci sono i nomi degli asssi:  `plt.xlabel('Days')`
- c'e' un grafico:  `plt.plot(x_1, y_1)`

Quando faccio un disegno, voglio che tutte le coordinate x siano in un contenitore (lo stesso vale per le coordinate y).
Questi "contenitori" devono contenere lo stesso numero di oggetti, altrimenti per un punto avrei solo la coordinata x o solo la y... quindi mi manca il punto!


```python
x_1 = np.linspace(0,5,10)  # genera un Numpy array con 10 float equispaziati tra 0 e 5
y_1 = x_1 **2              # genera un Numpy array che e' il quadrato del primo 
plt.plot(x_1, y_1);
plt.title('ciao');
plt.xlabel('Days');
plt.ylabel('Days squared');
#plt.show()                  # se non siamo in jupyter notebook
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_3_0.png)



`Domanda`: posso passare delle **liste** ad un `plt.plot()`? 

`Risposta`: si' certo! posso anche graficare delle liste che contengano delle **stringhe**. Se il contenitore di stringhe e' una lista, allora esiste un ordine per le stringhe e questo ordine verra' usato nella visualizzazione. Per un `set` invece non esiste un ordine e si ha un errore *TypeError: unhashable type: 'set'*


```python
l1= [1,2,3,4]
l2= [3,4,5,6]
l3= ['a','b','e','d']
d1 = {"apple", "banana", "cherry"}
plt.plot(l1,l3);
#plt.plot(l1,d1)   # non funge!
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_5_0.png)
    


# plt.subplot() molti grafici in modo veloce
Qui vediamo come mettere piu' di un grafico vicino all'altro. Nel dettaglio usando `subplot` potremo costuire una **griglia**, in ogni casella della griglia verra' messo un grafico.

Il comando `plt.subplot(1,2,1)` fa questo tipo di lavoro. 
1. il primo argomento e' il numero di **righe** della griglia (in questo caso c'e' solo una riga)
2. il secondo argomento e' il numero di **colonne** della griglia .
3. il terzo argomento e' l'indice del grafico. L'indice ci dice in quale casella della griglia stiamo mettendo il subplot. L'ordine seguito e' lo stesso che si ha quando si legge: da SINISTRA a DESTRA da SOPRA a SOTTO.

Vediamo un esempio:


```python
# nota che se anche il terzo argomento e' 2 il grafico appare al primo posto, perche'
# non ce ne sono 2! E' un po' come se cadesse a sinistra se ci sono dei buchi?
plt.subplot(1,2,2)        # questo ci dice che abbiamo una riga e 2 colonne
plt.plot(x_1,y_1, 'r');   # r = red 
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_7_0.png)
    



```python
plt.subplot(1,2,1)        # questo ci dice che abbiamo una riga e 2 colonne
plt.plot(x_1,y_1, 'r')    # r = red 
plt.subplot(1,2,2)        # se metto 1 mi sovrappone con il primo ma mi dice che c'e' qualcosa di strano
plt.plot(x_1,y_1, 'b')
```




    [<matplotlib.lines.Line2D at 0x2de659e5c40>]




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_8_1.png)
    



```python
plt.subplot(2,2,1)        # 
plt.plot(x_1,y_1, 'r')    #  
plt.subplot(2,2,2)        # 
plt.plot(x_1, y_1-y_1**2, 'b')
plt.subplot(2,2,4)
plt.plot(x_1, -y_1, 'g');
plt.tight_layout()              # evita sovrapposizione dei numeri dei grafici!
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_9_0.png)
    


# Figure e axes 
- Una **figure** e' un oggetto su cui poi si mette il grafico  (lo vedo come la tela bianca su cui fare il disegno)
- contiene tutti i 'plot elements'
- puo' contenere molti **axes** (assi), che in pratica sono gli assi che definiscono il disegno vero e proprio, in quanto i punti sono riferiti agli assi.
- posso definire la sua larghezza e lunghezza in **inch** (inch=2.54 cm), probabilmente posso cambiare scala: `figsize=(5,4)`
- posso anche definire la risoluzione in dpi 
- **ATTENTO** se definisci il numero di dpi, quando lo visualizzi come un png, questo definisce la dimensione della figura a video! quindi sembra che figsize non funzioni!


```python
fig_1 = plt.figure(figsize=(5,4), dpi =100);
```


    <Figure size 500x400 with 0 Axes>


## Axes

L'oggetto **axes** (come indica il nome) identifica la posizione, la forma, e tutte le caratteristiche degli ASSI di un grafico. Se non facciamo esplicitamente un grafico, ci saranno solo le due fracce perpendicolari (gli assi) con dentro nulla. Possiamo i **plot** (grafici) sono dei **metodi** degli assi! La logica e' quindi che siano un oggetto in funzione di dove sono gli assi (e ha senso, quando uno fa un grafico su un foglio, prima disegna gli assi, e poi puo' definire la posizione dei punti che compongono il grafico. In questo senso quindi il plot e' stato definito come un metodo di un axes.
Nota che posso mettere piu' di un **axes** su una singola **figure**. Anche questo e' intuitivo, posso mettere 2 grafici sullo stesso foglio, poi i punti di un grafico saranno riferiti ad un paio di assi e quelli del secondo ad un altro paio di assi. Gli assi definiscono il sistema di riferimento "inerziale" che determina la posizione dei punti!

Gli assi vengono costruiti su una `figure` tramite questo metodo: 

`axes_1 = fig_1.add_axes([0.1,0.1,0.9,0.9])`

Significa che `axes_1` sara' un rettangolo il cui:
- punto in basso a sx ha coordinate 0.1, 0.1 (rispetto a fig_1). Ovvero, la figure e' un rettangolo, anche gli axes sono un rettangolo, il cui punto in basso a sinistra si trova nelle coordinate che sono il 10% delle x e il 10% delle y del punto in basso a sx della figure.
- punto in alto a dx ha coordinate 0.9,0.9 (rispetto a fig_1)
In questo modo ho un grafico che e' piu' piccolo del "canvas" definito da fig_1.

- (nel video) non e' chiaro come ha fatto l'esponente 2 sulla x. Io devo usare i comandi Latex

**Attenzione**, io avevo messo il comando `fig_1 = plt.figure(figsize=(5,4), dpi =100)` in una cella diversa 
da dove facevo il axes.plot. Per questo non vedevo nulla!! Bisogna creare la figura nella stessa cella di Jupyter!

Quindi ricapitolando:
- creo un oggetto `figura`    ( me lo immagino come un foglio bianco di una certa dimensione)
- creo un oggetto `axes` che e' ottenuto da un metodo della `figura`  ( e' il grafico vero e proprio, definito dagli assi sopra, sotto e destra e sinistra. Al suo interno posso poi mettere dei disegni tramite il metodo plot)
- tramite metodi di `axes` aggiungo delle caratteristiche come le label
- tra i **metodi** di un axes c'e' `plot` (e altri tipi di grafico che potrei fare direttamente con plt). Chiamando un metodo che disegna da un axes, il grafico viene messo su questo axes.
- posso aggiungere piu' di un grafico sullo stesso axes, basta chiamare piu' volte un metodo che disegna sull'axes.
- nota che si deve fare un axes.plot per ognuno dei disegni che voglio compaiano nella figura!


```python
fig_1 = plt.figure(figsize=(5,4), dpi =100) # istanzio una FIGURA chiamata 'fig_1' 
axes_1 = fig_1.add_axes([0.1,0.1,0.9,0.9])  # istanzio un AXES (axes_1), della figura 'fig_1'
axes_1.set_xlabel('Days new')               # LABEL degli assi
axes_1.set_ylabel('Days squared new')       # LABEL degli assi
axes_1.set_title('Ciao new')                # TITOLO degli assi
axes_1.plot(x_1, y_1, label = 'x/x$^2$')    #  GRAFICO 1  (all'interno di axes_1)
axes_1.plot(y_1, x_1, label = 'x^2/x')      #  GRAFICO 2  (all'interno di axes_1)
axes_1.legend(loc =0 )                      # Loc=0 e' la migliore location scelta da lui
# 1=alt dx; 2=alto sx; 3=basso sx, 4 basso dx 
# oppure si fornisce una tupla di x e y dall'angolo in basso a sinistra
tu = (0.3, 0.4) # (tupla) questi valori sono in frazione rispetto alla grandezza totale, vedi sotto 
axes_1.legend(loc=tu );  # posizione della legenda
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_13_0.png)
    


## Molte curve: versione veloce
se devo fare un grafico veloce, basta che passo le x e y di tutti i grafici in ordine 
al plot, in questo modo verranno visualizzati tutti! Se non metto `color='black'` di default le due curve avranno colori diversi


```python
plt.plot(x_1, y_1, x_1, y_1/3);                   # disegna le 2 funzioni 
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_15_0.png)
    


## Axes innestati
Voglio ora inserire piu' di un `axes` nella stessa figura. In pratica aggiungo un axes all'esempio precedente.

Per fare questo devo creare un altro axes, proprio perche' in questo caso
i dati si riferiscono ad assi diverse che devono essere definite.

Ricapitolando:

- nell'esempio sopra ci sono una curva  blu e una arancione, sono comunque riferite allo stesso axes. Questi axes vanno da 0 a 25 (circa).
- se voglio inserire una **figura nuova**, i punti di questa figura saranno riferiti a un nuovo sistema di assi, ho quindi bisogno di inserire questi nuovi assi, creando un nuovo oggetto axes (con un nome diverso)
- dovro' quindi indicare dove si collocano questi nuovi assi rspetto alla `figure` 
- dovro' anche indicare la loro grandezza, anche in questo caso rispetto alla `figure`


**Testo nella figura**
- per inserire un testo nel disegno si usa il metodo `text` di `axes`.
- Le coordinate sono riferite all'`axes` e partono dal **basso** a **sinistra**. 
- Nota che nel disegno sotto ho 2 axes, e il messaggio e' riferito ad `axes_2`. Questo e' ovvio perche' e' chiamato come un metodo di questo axes 
- Nota inoltre che `axes_2.text(0,40,'message')` fa uscire dal disegno, in quanto per il disegno l'asse delle y arriva solo fino a circa 25!


nell'esempio di qui sotto:
- il primo axis contiene due curve
- il secondo axis contiene una curva


```python
fig_1 = plt.figure(figsize=(5,4), dpi =100)     # FIGURA 1
assi_1 = fig_1.add_axes([0.1,0.1,0.9,0.9])      # ASSI_1 
assi_1.set_xlabel('Days new')           
assi_1.set_ylabel('Days squared new')
assi_1.set_title('Ciao new')
assi_1.plot(x_1, y_1, label = 'x/x$^2$')        #  GRAFICO 1 (degli "ASSI_1")
assi_1.plot(y_1, x_1, label = 'x^2/x')          #  GRAFICO 2 (degli "ASSI_1")
assi_1.legend(loc =0 )                          # Loc=0 e' la migliore location scelta da lui

########   costruisco i secondi assi #####################
assi_2 = fig_1.add_axes([0.45, 0.45,0.4,0.3])   # ASSE 2
assi_2.set_xlabel('Days new')                      
assi_2.set_ylabel('Days squared new')
assi_2.set_title('Ciao dentro')
assi_2.plot(x_1, y_1, 'r')  #  GRAFICO 2        # GRAFICO 1 (degli "ASSI_2")  


#assi_2.text(0,40, 'Message')  # testo
assi_2.text(0,40, 'Message')  # testo

```




    Text(0, 40, 'Message')




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_18_1.png)
    


# subplots() Una griglia di grafici

**OCCHIO**:  `plt.subplots()`$\neq$`plt.subplot()` (il primo termina in **s**)

Il singolo comando `subplots` in pratica costruisce 2 oggetti:
- una **figure**
- una **array di assi** (ma un array di numpy puo' contenere degli oggetti strani? non erano solo numeri? no! basta che in tutti gli oggetti siano dello stesso tipo:  omogeneita' degli array).
- devo quindi descrivere/inizializzare ognuno dei possibili axes dell'array, altrimenti ho solo gli assi senza nessun disegno dentro.

In pratica e' una specie di scorciatoia per ordinare facilmente degli axis in una figure in modo che siano esattamente alle posizioni della griglia che viene definita con il comando, per esempio indicando il numero di colonne e di righe. Altrimenti avrei potuto istanziare una figura, e istanziare tanti axes stando attento a metterli nel posto giusto all'interno della figura.  

**Attenzione** se voglio mettere degli axes aggiuntivi (oltre all'array di axes iniziale), posso farlo, occhio pero' che si riferiranno tutti alla `figure` per quanto riguarda la posizione e non avranno un particolare ordinamento o forma. Dovro' essere io a stare attento a metterli nel posto corretto e con la forma corretta!


- il comando `plt.tight_layout()` aiuta a non fare sovrapporre le label.
 
- Attento che devi usare il nome della figura corretto `fig_2`
- Attento: **non** usare un nome gia' usato per un altro axes, come `axes_2`
- Attento: la dimensione del subplot e' riferita al figsize, non all'axes di cui e' subplot. Per questo trasborda!
- Attento: se costruisci un nuovo axes viene messo **sopra** l'axis genitore, e per questo lo (puo') coprire. 
- Di default un axes **non** e' trasparente!


```python
fig_2 , axes_2 = plt.subplots(figsize=(8,4), nrows=1, ncols= 3) 
plt.tight_layout()                    # evita la sovrapposizione delle label
axes_2[1].set_title('Plot 2')
axes_2[1].set_xlabel('x')
axes_2[1].set_ylabel('x quadro')
axes_2[1].plot(x_1, y_1)

# Nuovo AXES che non fa parte dell'array creato con   subplots

axes_3 = fig_2.add_axes([0.45, 0.45,0.4,0.4])
axes_3.set_xlabel('Days new')
axes_3.set_ylabel('Days squared new')
axes_3.set_title('Ciao straripante')
axes_3.plot(x_1, y_1, 'r')  #  GRAFICO 2

axes = fig_2.add_axes ([0.085,0.15,0.2,0.7])
axes.plot(x_1,y_1, 'co')
axes.set_title('Dentro')
```




    Text(0.5, 1.0, 'Dentro')




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_20_1.png)
    



```python
f , a = plt.subplots(figsize=(8,4), nrows=1, ncols= 3) 
plt.tight_layout()          

############ Axes Centrale ###############
a[1].set_title('Centrale')
a[1].set_xlabel('x')
a[1].set_ylabel('x quadro')
a[1].plot(x_1, y_1)

############ Axes Ciao Dentro ############
a1 = f.add_axes([0.45, 0.45,0.4,0.4])
a1.set_xlabel('Days now')
a1.set_ylabel('Days squared new')
a1.set_title('Tra centro e sinistra')
a1.plot(x_1, y_1, 'r')  #  GRAFICO 2 della figura centrale

############ Axes Sinistro ###############
a[0].set_title('Sinistra')
a[0].set_xlabel('x')
a[0].set_ylabel('x quadro')
a[0].plot(x_1, -y_1,'g')

############ Axes Piccolo sinistra  ######
a0 = f.add_axes([0.1, 0.25,0.2,0.2])
a0.set_xlabel('Days old')
a0.set_ylabel('Days squared new')
a0.set_title('Piccolo Sinistra')
a0.plot(x_1, y_1, 'r')  #  GRAFICO 2 della figura centrale
```




    [<matplotlib.lines.Line2D at 0x2de66e3a190>]




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_21_1.png)
    


# Colori e Apparenza
I colori di default sono:
- r = red
- c = cyan
- m = magenta
- y = yellow
- k = black
- w = white

Inoltre

- color="0.75" crea un 75% gray  (e' una percentuale di black)
- si possono usare i colori con hexcodes   color="#eeefff"
- si possono usare i colori tipo color="burlywood" che si trovano a https://en.wikipedia.org/wiki/Web_colors

- `lw` come gnuplot, ma devo mettere l'uguale, p.es. `lw=2`
- ls '-.'  si trovano qui: https://matplotlib.org/3.1.0/gallery/lines_bars_and_markers/linestyles.html
- marker sono i **punti**: https://matplotlib.org/3.3.3/api/markers_api.html
- markersize = grandezza del punto
- markerfacecolor = colore di riempimento del punto
- makeredgecolor  = colore del bordo del punto


```python
fig_3 = plt.figure(figsize=(6,4))
axes_3  = fig_3.add_axes([0,0,1,1])
axes_3.plot(x_1, y_1, color='navy', alpha=0.75, lw=2, ls ='-.', marker = 'o', 
           markersize=7, markerfacecolor ='y', markeredgecolor='k', markeredgewidth=2)
```




    [<matplotlib.lines.Line2D at 0x2de66eaa970>]




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_23_1.png)
    


# Grandezza degli assi e background
I comandi per gestire gli assi  assomigliano a quelli di gnuplot, ma solo un po' piu' "verbose", in cui
si deve scrivere di piu'.

Possimo anche mettere una griglia e il background color.

- axes_3.`set_xlim([0,3])`                           limiti asse x
- axes_3.`grid(True, color='0.6', dashes=(5,2,1,2))` caratteristiche della griglia (**NON** dello sfondo!), dashes mette delle linee tratteggiate attraverso il disegno. Quindi qui sono le righe che partono da un tic e arrivano dall'altra parte del disegno  
- axes_3.`set_facecolor('#FAEBD7')`                  colore di sfondo 



```python
fig_3 = plt.figure(figsize=(3,4) )
axes_3  = fig_3.add_axes([0,0,1,1])
axes_3.plot(x_1, y_1, color='navy', alpha=0.75, lw=2, ls ='-.', marker = 'o', 
           markersize=7, markerfacecolor ='y', markeredgecolor='k', markeredgewidth=2)

axes_3.set_xlim([0,3])
axes_3.set_ylim([0,25])

#axes_3.grid(True, color='0.6', dashes=(5,2,1,2))   # mettiamo una griglia non lasciamo vuoto 
axes_3.grid(False, color='r', dashes=(0,2,1,2)) 

#axes_3.set_facecolor('#FAEBD7')
axes_3.set_facecolor('w')

```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_25_0.png)
    


# Salvare una figura a file
strano quando lavoravo con Seaborn sembrave che il save dovesse avvenire nella stessa cella dove si faceva il disegno.
- Basta mettere il nome dell'estensione e lui salva correttamente nel formato corrispondente


```python
fig_3.savefig('ultimoPlot.png')
```

# Pandas
Qui usiamo l'ICE CREAM data table (che diventera' un DataFrame). Ho copiato il dataframe del video.

- **Assegno** dei nomi alle colonne del csv, mentre leggo il file: `ics_df = pd.read_csv('icecream.csv', names=['temps', 'sales'])`  . Nota che io ho usato i nomi sales  e temps (temperatures). Lui li aveva con la prima lettera in maiuscolo. Temp e' in Farenheit, e sales e' in unita' di gelato.

- Se non usassi il parametro `names=...` lui prenderebbe la prima riga e la trasformerebbe nei nomi delle colonne (e i valori della prima riga non sarebbero accessibili)! 

- **Osservazione**: il metodo dei DataFrame `sort_values(by='temps')` lavora **inplace**, quindi modifica il df!


```python
ics_df = pd.read_csv('icecream.csv', names=['temps', 'sales'])
ics_df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>temps</th>
      <th>sales</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>37</td>
      <td>292</td>
    </tr>
    <tr>
      <th>1</th>
      <td>40</td>
      <td>228</td>
    </tr>
    <tr>
      <th>2</th>
      <td>49</td>
      <td>324</td>
    </tr>
    <tr>
      <th>3</th>
      <td>61</td>
      <td>376</td>
    </tr>
    <tr>
      <th>4</th>
      <td>72</td>
      <td>440</td>
    </tr>
  </tbody>
</table>
</div>



Attento `sort_values()` lavora **inplace**


```python
ics_df = ics_df.sort_values(by='temps')  # LAVORA INPLACE
```

A questo punto lui fa delle cose che sembrano non necessarie.  Prende e converte il *DataFrame* in un *array* di Numpy.
Poi prende e scrive le x e le y da questo array di numpy. In effetti ho notato in una sezione sotto che alle volte e' davvero meglio avere dei numpy array invece che i dataframe, in particolare per evitare dei valori strani sull'asse delle x. 


```python
#   con numpy array ###############
#  np_arr = ics_df.values    # prende solo i valori, rimuove le etichette
#  x_2 = np_arr[:,0]         # seleziono colonna 0
#  y_2 = np_arr[:,1]         # seleziono colonna 1  
###################################
```


```python
# Alternativa:
x_2 = ics_df.temps # non sono array di np, ma serie di Pandas vanno bene lo stesso
y_2 = ics_df.sales # ricorda puoi usare l nome di una colonna per selezionare tutta le colonna come se fosse un attributo

#x_2 = np.array(ics_df.temps) # NON serve... ora, ma in alcuni casi si'
#y_2 = np.array(ics_df.sales) # NON serve... ora, ma in alcuni casi si'
```

ok ma fino a qui, dove ha usto il fatto che sia Pandas?


```python
fig_4 = plt.figure(figsize=(6,4))
axes_4 = fig_4.add_axes([0,0,1,1])  # prendo tutto lo spazio, dall'angolo in basso a sx a quello in alto a dx
axes_4.set_title('da Pandas: IceCream')
axes_4.set_xlabel('temp')
axes_4.set_ylabel('sales')
axes_4.plot(x_2, y_2, marker='+');  # ho messo sui punti le crocette come in Gnuplot
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_36_0.png)
    


# Annotare la figura
Se voglio mettere delle annotazioni nel grafico, come per esempio delle frecce, devo usare un metodo degli axes chiamato `annotate`. Vediamo nel dettaglio il comando:
`axes_4.annotate('Good Month', xy=(83, 536), xytext=(60,520), arrowprops= dict(facecolor='black', shrink=0.0, width=0.5))`

- `'Good Month'` e' il testo che viene inserito
- `xy=(83,536)`  e' il punto di arrivo della freccia
- `xytext=(60,520)` e' il punto di partenza del testo **orizzontale**

All'interno di `arrowprops` si hanno vari parametri (si deve passare un dizionario con tutti gli argomenti)

- `facecolor`= 'black'
- `shrink=0.5`   indica quanto piu' corta deve essere la freccia, rispetto alla lunghezza massima che va dalla fine del testo al punto di arrivo della freccia.
- `width=0.5` possiamo anche allargare la larghezza


```python
fig_4 = plt.figure(figsize=(6,4))
axes_4 = fig_4.add_axes([0,0,1,1])  # prendo tutto lo spazio, dall'angolo in basso a sx a quello in alto a dx
axes_4.set_title('da Pandas: IceCream')
axes_4.set_xlabel('temp')
axes_4.set_ylabel('sales')
axes_4.plot(x_2, y_2)
axes_4.annotate('Good Month', xy=(83, 536), xytext=(60,520),
                arrowprops= dict(facecolor='black', shrink=0.0, width=0.5))
```




    Text(60, 520, 'Good Month')




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_38_1.png)
    


# bar() Barchart sotto il grafico
`bar()`  e' un metodo di `plt`

Se voglio fare aggiungere anche le barchart sotto il grafico, basta disegnare ANCHE loro!

**Attento** ho fatto 2 plot:
1. il primo e' dato da `axes_4.plot(x_2, y_2)` ed e' passato come un **metodo** degli assi
2. il secondo e' un grafico *veloce* ed e' una **funzione** di matplotlib: `plt.bar(x_2, y_2, width=1.5);`



```python
fig_4 = plt.figure(figsize=(6,4))
axes_4 = fig_4.add_axes([0,0,1,1])  # prendo tutto lo spazio, dall'angolo in basso a sx a quello in alto a dx
axes_4.set_title('da Pandas: IceCream')
axes_4.set_xlabel('temp')
axes_4.set_ylabel('sales')
axes_4.plot(x_2, y_2)
axes_4.annotate('Good Month', xy=(83, 536), xytext=(60,520),
                arrowprops= dict(facecolor='black', shrink=0.0, width=0.5))
plt.bar(x_2, y_2, width=1.5);
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_40_0.png)
    


## Impulsi stem()   e proprieta' setp() 
In gnuplot mettevo *with impulses* quando volevo che il grafico avesse delle linee verticali che partono dall'asse x e raggiungono ogni punto. Il comando descritto qui sopra `bar()` non e' l'ideale per ottenere questo risultato in quanto la larghezza dell'impulso puo' creare problemi, meglio usare la funzione:

`plt.stem()`

mentre posso decidere di colorare l'asse sotto tramite la funzione set property:

`plt.setp()`

Questa funzione puo' essere usata per vari oggetti!


```python
fig_4 = plt.figure(figsize=(6,4))
axes_4 = fig_4.add_axes([0,0,1,1])  # prendo tutto lo spazio, dall'angolo in basso a sx a quello in alto a dx
axes_4.set_title('da Pandas: IceCream')
axes_4.set_xlabel('temp')
axes_4.set_ylabel('sales')
axes_4.plot(x_2, y_2)
axes_4.annotate('Good Month', xy=(83, 536), xytext=(60,520),
                arrowprops= dict(facecolor='black', shrink=0.0, width=0.5))
markerline, stemlines, baseline = plt.stem(x_2, y_2, '-.')
plt.setp(baseline, 'color', 'r', 'linewidth', 2)
```




    [None, None]




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_42_1.png)
    


# TeX - regular expressions
possiamo usare Latex per scriver formule matematiche usando per esempio $\frac{1}{2}$

- **IMPORTANTE** nota che nel tutorial ha usato: `r'$\alpha \beta \gamma$'`  non ha semplicemente messo '' perche' cosi' prende le `regular expression`,
come il dollaro e lo slash.
 
Ovvero la scrittura  r'ciao $\frac{2}{3}' crea una stringa che pero' ha delle regular expression che vengono valutate ed eseguite.


- basta poi ricordare i comandi di Latex
- il metodo `.text` degli 'axes' mette ha all'inizio le coordinate (separate da una virgola), poi una virgola con il testo da inserire.


```python
fig_5 = plt.figure(figsize=(5,4), dpi=100)
axes_5 = fig_5.add_axes([0.1, 0.1, 0.9, 0.9])                       # costruisco un axes

axes_5.text(0,23, r'$\alpha~ \beta~ \gamma ~ \frac{1}{2} ~\Sigma$') # prima le coordinate del testo, poi il testo

axes_5.plot(x_1, y_1)
```




    [<matplotlib.lines.Line2D at 0x2de66ff15e0>]




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_44_1.png)
    


# Istogrammi plt.hist() 

Alcuni argomenti utili per gli istogrammi:

- `stacked=True`
- 






Simuliamo probabilita' di lancio di 2 dadi. Ci sono 11 possibili valori per la somma:
- 1+1 =2  I
- 1+2 =3  II
- 1+3 =4  III
- 1+4 =5  IV
- 1+5 =6  V
- 1+6 =7  VI
- 2+6 =8  VII  (nota che tutti gli altri valori di (2+qualcosa) danno dei risultati gia' ottenuti)
- 3+6 =9  VIII
- 4+6 =10 IX
- 5+6 =11 X
- 6+6 =12 XI
Come altri parametri:
- `density=True` mostra la frequenza di ogni bin (se e' falso mostra il conteggio)
- `stacked=True` cosa fa?

**Attento**: ricorda che il numero di `bins` puo' portare a risultati MOLTO fuorvianti. Per esempio se scegliamo `bins=7` otteniamo un oggetto bicefalo attorno al centro. Se invece scegliamo `bins=11` otteniamo una campana!


```python
arr_1 = np.random.randint(1,7,5000) # genera 5000 numeri interi tra 1 e 6
arr_2 = np.random.randint(1,7,5000) # genera 5000 numeri interi tra 1 e 6
arr_3 =arr_1+arr_2
```


```python
arr3ok = arr_3
plt.hist(arr3ok, bins= 7, density=True, stacked =False);
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_47_0.png)
    



```python
plt.hist(arr_3, bins= 11, density=True, stacked =True);
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_48_0.png)
    


## ax[0].hist() Axes e istogrammi

Qui sotto provo a combinare axes e istogrammi.
- Ho supposto di poter usare il metodo `hist()` direttamente su un asse invece che dover usare un `plt.hist`, ovvero:
`axes.hist(...)`

Funge!


```python
fig , ax = plt.subplots(figsize=(8,4), nrows=1, ncols= 2) 
#plt.tight_layout()          
ax[0].hist( arr_3, bins= 11, density=True, stacked =True);
ax[1].hist( arr_3, bins= 11, density=False, stacked =False);
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_50_0.png)
    


altri argomenti che si possono passare:
- `Range` deve essere una **tupla** con il range di cui si e' interessati
- `cumulative =True`  costruisce la **CDF** (cumulative distribution function) dati i valori. Attento non me lo prendeva (diceva qualcosa riguardo l'oggetto kernel). Non ho lanciato tutte le altre celle, ma solo quelle iniziali con gli header e quelle della cella Istogramma
- `histtype= 'step'` genera un grafo con le linee (ma vuoto)
- `color = 'orange'` colora  di arancione...
- `orientation = 'horizontal'`  gira di 90 gradi l'istogramma
posso combinare anche due istogrammi insieme come con gli altri plot.


```python
plt.hist(arr_3, bins= 11, density=True, stacked =True, cumulative=True,
         histtype='step', color='blue', orientation= 'horizontal');
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_52_0.png)
    


# Bar charts

Che differenza c'e' tra un grafo a barre e un istogramma? de facto nell'istogramma si mettono le frazioni e le "barre" sono attaccate l'una all'altra. In un bar chart invece si hanno i numeri e le barre non sono attaccate l'una all'altra, questo perche' sull'asse delle x spesso **non si hanno dei valori numerici**, ma categorici (come nell'esempio riportato sotto, dove l'ordine delle colonne e' sostanzialmente arbitrario).

Per un grafo a barre, si chiama la funzione seguente:

`plt.bar(spc, m_eng,width=larghezza, label='maschi', edgecolor ='k')`

- il **primo** argomento contiene la **lista/tupla** con i **nomi** che appaiono sull'asse delle x (dato che spesso lo usiamo per variabili categoriche dobbiamo indicare le label), oppure le **posizioni** delle barre (se ho le posizioni dovro' poi aggiungere le label sull'asse)
- **Attento** se nella prima tupla ci sono dei nomi, allora le loro posizioni sono equispaziate automaticamente. Se io aggiungo un altro bar chart, questo secondo viene messo dopo quelle gia' esistenti.
- **Attento** se invece nella prima tupla ci sono dei float (che quindi definisce la posizione delle barre), allora facendo un secondo plot, quest'ultimo segue le proprie posizioni.
- **Attento** pui mettere 2 bar chart, uno con variabili categoriche e uno con float. Le posizioni delle categoriche sono messe automaticamente in integer (che partono quindi da zero). Nell'esempio qui sotto, la barra di *nuclear* ha posizione sull'asse delle x uguale a 0, *hydro* e' in posizione 1, ...
- il **secondo** argomento contiene l'array che con le **altezze** della barchart 
- yerr ???  serve per la barra che indica l'**errore**, ed e' un array che deve contenere tanti oggetti quante sono le barre
- **width**  larghezza della barra (altrimenti da' errore? )
- label non la vedo... scritta forse bisogna attivarla. Anche nel video non fungeva



```python
## energia francese
x = ['nuclear', 'hydro', 'coal', 'gas', 'solar', 'wind', 'other']
per_1 = [71,10,3,7,2,4,3]   # percentuale
variance = [8,3,1,3,1,2,1]  # varianza per anno

plt.bar(x, per_1, color='purple',yerr=variance, label='prova')  
```




    <BarContainer object of 7 artists>




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_54_1.png)
    



```python
## energia francese
x = ['nuclear', 'hydro', 'coal', 'gas', 'solar', 'wind', 'other']
per_1 = [71,10,3,7,2,4,3]   # percentuale
variance = [8,3,1,3,1,2,1]  # varianza per anno
plt.bar(x, per_1, color='purple',yerr=variance, label='prova')  
y = [el + '   ' for el in x]
z = ['test1', 'test2', 'test3']
z2 = [1, 2, 10]
per_2 = [34,43,21]
plt.bar(z2, per_2, color='red', label='prova') 
```




    <BarContainer object of 3 artists>




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_55_1.png)
    



```python
y
```




    ['nuclear   ',
     'hydro   ',
     'coal   ',
     'gas   ',
     'solar   ',
     'wind   ',
     'other   ']



## Bar Chart affiancate
Qui sotto mettiamo due bar chart affiancate una da parte all'altra. In questo modo possiamo confrontare dati diversi.
E' fondamentale che la posizione dell'array che definisce l'asse delle x della seconda bar chart sia spostato rispetto all'asse delle x della prima bar chart di una quantita' tale da non fare sovrapporre (a meno di volerlo). Per esempio di puo' usare lo stesso array maggiorato della larghezza della barchart!


```python
m_eng = (76,85,86,88,93)  # percentuale maschi ingegneri
f_eng = (24,15,14,12,7)   # femmine

spc = np.arange(5)
larghezza =0.45
plt.bar(spc    , m_eng,width=larghezza, label='maschi', edgecolor ='k')
plt.bar(spc+larghezza, f_eng,width=larghezza, label='femmine', edgecolor ='k')
#plt.xticks(spc + larghezza/2, ('Aero', 'Chem', 'Civil', 'Elect', 'Mec'))
plt.xticks(spc   , ('Aero', 'Chem', 'Civil', 'Elect', 'Mec')) ;   # altrimenti lo mette a meta' strada del primo istogramma
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_58_0.png)
    


## Bar Chart impilate (stacked)

Qui mettiamo le barre una sopra l'altra.

Diamo un'occhiata alla list comprehension che viene usata:

`ind = [x for x, _ in enumerate(t_type)]`

- `enumerate` restituisce delle coppie: posizione, oggetto. 
- Non ci serve l'oggetto ma solo la posizione, qunidi non spreco una variabile y, metto _
- Prendi tutte le posizioni che ci sono nell'oggetto t_type
- questa volta la label e' apparsa nella legenda.

**ATTENTO**
- il parametro `bottom` dice cosa c'e' sotto di questa barchart. In particolare possiamo indicare un array, o anche una somma di array come nell'esempio di cui sotto. Se mettiamo un array che viene disegnato nella barchart, allora stiamo in pratica impilando il nuovo barchart sopra quello dell'altro array






```python
#############   DATI ######################
t_type= ['kind', 'elem', 'sec', 'special']
print(type(t_type))
m_teach = np.array([2,20,44,14])
f_teach = np.array([98,80,56,86])
n_teach = np.array([12,14,13,15])

ind = [x for x,_ in enumerate(t_type)]  # list comprehension. Vedi sopra per come si legge


plt.bar(ind, n_teach, width=larghezza, label='nuovo', bottom=f_teach+m_teach) # posso metterne piu' di uno sotto
plt.bar(ind, m_teach, width=larghezza, label='maschi', bottom=f_teach) # posso metterne piu' di uno sotto
plt.bar(ind, f_teach, width=larghezza, label='femmine')
plt.legend(loc='lower right');   # non ideale....
#plt.legend(loc=0);                # manco questo... 
```

    <class 'list'>
    


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_60_1.png)
    


# Torte - Pie chart,  plt.pie()

Vediamo i diagrammi a torta.
Per questi si usa il comando:

`wedges, texts, autotexts = plt.pie(poke_num, explode=explode, labels=types, colors=colors,
                                  autopct='%1.0f%%', shadow=True,
                                  startangle=140, textprops =dict(color='w'))`
                                  
Dal punto di vista sintattico la funzione `pie()` restituisce 3 oggetti:
1. le `wedges` (gli spicchi o cunei del diagramma a torta).
2. i `texts`
3. gli `autotext`

In questo caso abbiamo prima costruito la `figure`, poi gli `axes` ed infine abbiamo chiamato la funzione `pie`.
E' un po' diverso dal solito quando si usava un metodo dell'axes.


                                 
- Nota che in un diagramma a torta, intuitivamente, i valori di larghezza (angolo) associati ad ogni fetta vengono convertiti in percentuali dell'angolo giro. Questo perche' ci si aspetta che tutti i valori di un array riempiano **tutto** il cerchio.

- `explode` a questa keyword si deve passare un array di float con tanti ingressi quante sono le fette. Il valore di ogni ingresso dice di quanto viene "estratta" la fetta alla posizione corrispondente, vedi l'esempio sotto.

- nell'esempio sotto ci sono 2 array: `types` e `pole_num`, questi devono avere il medesimo numero di ingressi.

- `labels=types` e' un parametro che indica le etichette associate ad ogni fetta

- `autopct` indica come vengono arrotondati i numeri associati alle larghezze, gli si deve passare come valore una stringa che indica un formato.

- `shadow=true` e' il parametro che dice se mettiamo l'ombra

- `colori` ha usato un trucco notevole, ha fatto scrivere dei valori in formato RGB tramite il generatore di numeri casuali. Tre numeri indicano un colore, e lui indicando il range dei colori tra [0, 0.5] ha fatto si' che vengono scuri. Ha scelto i colori scuri perche' la scritta viene in bianco!

- Occhio, avevo fatto un errore di sintassi ma non semplice da osservare. Nell'array `types` che contiene dei nomi tra virgolette, in un caso, quando andavo a capo ho dimenticato di mettere una **virgola** tra un nome e l'altro e lui mi ha preso solo uno dei nomi

- `bbox_to_anchor = (1,0,0.5,1)` serve per spostare di 1 e 1/2 a destra della piechart (???)


```python
import random
fig_6  = plt.figure(figsize=(8,5))
axes_6 = fig_6.add_axes([0.1,0.1,0.9,0.9])

#Vogliamo un diagramma a torte
types = ['water', 'normal', 'flying', 'grass', 'psychic','bug',
        'fire', 'poison', 'ground','rock','fighting', 'dark', 'steel',  
        'electric','dragon','fairy','ghost','ice']

poke_num =[133, 109, 101, 98, 85, 77, 68, 66, 65, 60, 57, 54, 53, 51, 50, 50, 46, 40]

colors = []
for i in range(18):         # per il testo bianco genero i coloi delle fette in modo che siano scuri
    rgb = (random.uniform(0,.5) , random.uniform(0,.5) , random.uniform(0,.5)  )
    colors.append(rgb)
    
explode = [0] * 18     # ho creato una lista di 18 zeri (non mi ricordavo questo modo!)
explode[0] = 0.2       # esplodi la prima fetta ma solo di 0.2

#print(len(types));
#print(len(poke_num));

wedges, texts, autotexts = plt.pie(poke_num, explode=explode, labels=types, colors=colors,
                                  autopct='%1.0f%%', shadow=True,
                                  startangle=140, textprops =dict(color='w'))

plt.legend(wedges, types, loc='right', bbox_to_anchor = (1,0,0.5,1)); #  sposto dalla piechart
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_62_0.png)
    


# Serie Temporali

Qui vediamo come fare un grafico con una serie temporale in cui i vari punti sono etichettati con un **timestamp**.
Puo' essere necessario togliere dei giorni particolari e risulta piu' comodo sapere la data piuttosto che trovare il punto corrispondente della time series.

Il database usato viene da Yahoo riguardo i dati di google, GOOG.csv. (non e' esattamente come mostrato nel video ma si trova in fretta). Per trovarlo cerca con google "yahoo google stock", seleziona le date e fai download (nota che la frequenza e' giornaliera).


All'inizio si carica il file con `read_csv` di Pandas, poi si trasforma la tabella in un array di numpy (sono tutti valori numerici). Lui usa un metodo dei DataFrame di Pandas che io non uso mai: `tp_numpy()`. Io invece faccio semplicemente `np.array()`. 


Ho provato a fare un giro piu' semplice, cercando di plottare i dati direttamwente DAL DataFrame, di cui seleziono le colonne volute (ma avendo prima selezionato le righe, vedi sotto). Sfortunatamente sull'asse delle x vengono dei valori sballati come tics, il grafico e' pero' corretto. Questo e' probabilmente il motivo per cui lui preferisce trasformare tutto in array di Numpy.

**Scrubbing data**: per esempio vogliamo togliere alcune vacanze, ha controllato due date che sono vacanze e vuole escluderlo.
Usa `datetime`. La funzione `datetime.datetime(2020,5,25)` crea una data in un oggetto specifico, che puo' poi essere trasformato a seconda delle esigenze, p.es g/m/a  o m/g/a ecc. 

Poi **costruisce** un array di date che vanno da una data iniziale ad una finale, tramite un metodo di pandas: `pd.bdate_range`, si puo' passare il parametro frequency `freq ='C'` in questo caso, ma no so cosa sia il valore 'C'!

`holidays` e' il nome di un altro parametro che appunto corrisponde alle vacanze e possiamo passare un array/tupla contentente dei dati in formato `datetime` che vengono riconosciuti. **ATTENTO** la mia versione non riconosce questo parametro. Ho riscritto tutto e ora funge.

**Problema**: non so quando ha preso lui le date da Yahoo, io ho piu' giorni.

**Problema2** se uso tutti questi giorni, i tics che vengono segnati sono troppi e sotto l'asse viene un guazzabuglio di linee. Devo modificare per ottenere le date corrette.



```python
import datetime
```


```python
goog_data = pd.read_csv('GOOG.csv')    # IMPORTO il file GOOG.csv che ho salvato nella dir corrente
goog_data_np = goog_data.to_numpy()    # trasformo in np.array
#goog_data_np =np.array(goog_data)     # modo alternativo di trasformare
goog_cp = goog_data_np[:,4]

holidays = [datetime.datetime(2020,5,25)  , datetime.datetime(2020,8,19) ] # creo una lista con due date che saranno vacanze

date_arr = pd.bdate_range(start ='5/20/2020' ,
                            end ='8/19/2020' , 
                           freq ='C', 
                       holidays = holidays) 

date_arr_np = date_arr.to_numpy()
goog_data.head(3)
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Date</th>
      <th>Open</th>
      <th>High</th>
      <th>Low</th>
      <th>Close</th>
      <th>Adj Close</th>
      <th>Volume</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2019-08-21</td>
      <td>1193.150024</td>
      <td>1199.000000</td>
      <td>1187.430054</td>
      <td>1191.250000</td>
      <td>1191.250000</td>
      <td>740700</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2019-08-22</td>
      <td>1194.069946</td>
      <td>1198.011963</td>
      <td>1178.579956</td>
      <td>1189.530029</td>
      <td>1189.530029</td>
      <td>947500</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2019-08-23</td>
      <td>1181.989990</td>
      <td>1194.079956</td>
      <td>1147.750000</td>
      <td>1151.290039</td>
      <td>1151.290039</td>
      <td>1687000</td>
    </tr>
  </tbody>
</table>
</div>



## Selezionare righe secondo delle date

Seguo questo esempio per selezionare le date:
https://stackoverflow.com/questions/29370057/select-dataframe-rows-between-two-dates

Creo una mask per selezionare le date che voglio e che devono seguire quelle indicate nel `bdate_range`.
In pratica creo una **maschera**, ovvero un array di **bool** che poi posso passare a loc!
In questo modo solo gli ingressi in cui la maschera e' vera vengono selezionati.

- **Problema I**: devo paragonare delle date... in formati magari diversi
- **Soluzione I** uso `pd.to_datetime()` che e' una goduriosa funzione di Pandas che converte una stringa in un oggetto di tipo `datetime`. Questo oggetto e' una data ed e' possibile paragonare due datetime per vedere chi viene prima o dopo! Questa funzione e' particolarmente VANTAGGIOSA in quanto riconosce tanti tipi diversi di formato in cui possiamo scrivere una data e li converte i un unico oggetto!
- **Alternativa** usa `parse_dates` (vedi il Finance Module)



Una volta ottenuto un modo per paragonare le date posso creare una lista con valori `booleani` in cui seleziono le date (basta un loop), chiamo questo oggetto **maschera**

- **Problema II** la maschera cosi' creata non e' un oggetto iterabile che si possa mettere nel metodo `loc` di pandas. Devo tasformarlo in un oggetto non iterabile
- **Soluzione II** basta costruire una funzione che prende come input qualcosa e quando lo sputa in output gli metto un `tuple` davanti!
- **DUBBIO** ehi ma nel codice non ho usato la tupla, anzi se dove faccio finanza metto la tupla mi da errore, sembra che una Series di pandas vada bene

Attenzione pero' la maschera cosi' creata e' un oggetto **mutabile** e questo non puo' essere usato come ingresso della funzione loc (di PANDAS) perche' questa necessita oggetti immutabili da cui puo' estrarre una hashtable.


link utili:

loc: https://stackoverflow.com/questions/29370057/select-dataframe-rows-between-two-dates

to_datetime: https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.to_datetime.html

convertire lista in tupla: https://www.geeksforgeeks.org/python-convert-a-list-into-a-tuple/


```python
# PROBLEMA  I
# qui sotto prendo la colonna Date del dataFrame
# poi converto i valori ivi contenuti in un oggetto di tipo datetime con to_datetime
# a questo punto li paragono ai valori entro cui voglio che siano le date, sempre
# sfruttando la funzione di pandas pd.to_datetime

mask = (   ( pd.to_datetime(goog_data['Date']) >= pd.to_datetime('5/20/2020')) 
         & ( pd.to_datetime(goog_data['Date']) <= pd.to_datetime('8/19/2020')) )



# PROBLEMA II
# l'oggetto mask non  e' di tipo immutabile e quindi non puo' essere usato come iteratore
# devo trasformarlo in unoggetto immutabile

def convert(list): 
    return tuple(list) 

mask_t= convert(mask)

#print(type(mask_t) , 'tipo maschera')    # controllo
#print(len(goog_data.loc[mask]))          # controllo che i due oggetti abbiano lo stesso numero di righe  

new = goog_data.loc[mask]   # loc NON lavora inplace <===================
new_np = new.to_numpy()
goog_cp = new_np[:,4]       #  


# PROBLEMA III 
# Costruisco un array con le date corrispondenti in modo che io possa poi disegnarle

fig_7 = plt.figure(figsize=(8,5))  # creiamo la figura/canvas come al solito
axes_7 = fig_7.add_axes([0.1,0.1, 0.9, 0.9])  # il grafico non copre tutta la figura, lasciamo un po' di padding
plt.plot(date_arr_np, goog_cp);

#plt.plot(new.Date, new.Close) # questo fa vedere sbagliato i tics sotto

```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_67_0.png)
    


# Tabelle

Questo non e' cosi' interessante, la cosa che trovo piu' utile e' come girare le date sull'asse delle x.
Copio il pezzo di notebook scritto da Banas qui sotto:


```python
# Format column data to 2 decimals
goog_data['Open'] = pd.Series([round(val, 2) for val in goog_data['Open']], 
                              index = goog_data.index)
goog_data['High'] = pd.Series([round(val, 2) for val in goog_data['High']], 
                              index = goog_data.index)
goog_data['Low'] = pd.Series([round(val, 2) for val in goog_data['Low']], 
                              index = goog_data.index)
goog_data['Close'] = pd.Series([round(val, 2) for val in goog_data['Close']], 
                              index = goog_data.index)
goog_data['Adj Close'] = pd.Series([round(val, 2) for val in goog_data['Adj Close']], 
                              index = goog_data.index)

# Get most recent last 5 days of stock data
stk_data = goog_data[-5:]
stk_data

# Define headers
col_head = ('Date','Open','High','Low','Close','Adj Close','Volume')

stk_data_np = stk_data.to_numpy()
stk_data_np

# Add padding around cells in table
plt.figure(linewidth=2, tight_layout={'pad':.5}, figsize=(5,3))

# Get rid of axes and plot box
axes_8 = plt.gca()
axes_8.get_xaxis().set_visible(False)
axes_8.get_yaxis().set_visible(False)
plt.box(on=None)

# np.full returns an array filled with 0.1
# cm is a colormap object we are using to use a default blue color
# matplotlib.org/3.1.0/tutorials/colors/colormaps.html
ccolors = plt.cm.Blues(np.full(len(col_head), 0.2))

# Receives data, loc, list of column headers, column header color as array of colors
# You can also add rowLabel, rowColours, rowLoc: Text alignment
the_table = plt.table(cellText=stk_data_np, loc='center', colLabels=col_head,
                     colColours=ccolors)
# Set table font size
the_table.set_fontsize(14)
the_table.scale(3, 2.5)

```

    C:\ProgramData\Anaconda3\lib\site-packages\IPython\core\pylabtools.py:132: UserWarning: Tight layout not applied. The left and right margins cannot be made large enough to accommodate all axes decorations. 
      fig.canvas.print_figure(bytes_io, **kw)
    


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_69_1.png)
    


# ScatterPlot
Qui ci sono dei dati relativi al Coronavirus.
E' importante che ci sia uniformita' di grandezza per quanto riguarda gli array che vanno plottati:
- ci sono 26 nazioni
- ci sono 26 tassi di mortalita'
- ci sono 26 valori di casi confermati giornalieri
- ci sono 26 dimensioni dei punti

Nota che i questo caso non costruisco la **figura** e poi gli **assi**. Questo perche' viene fatto automaticamente dal comando `plt.scatter`. Ci sono 2 vie per ottenere lo stesso grafico:
1. costruisco la fig, e gli assi e uso scatter come metodo sull'asse creato
2. uso plt.scatter e lui automaticamente crea gli assi!


Argomenti dello **scatterplot**:
- prima si mettono i valori dell'asse delle x (e' un `np.array`)
- poi l'array per i valori dell'asse delle y (anche questo un `np.array` lungo quanto quello sopra)
- s  per size (dei punti): NON e' come gnuplot che accettava le abbreviazioni, qui il parametro si chiama SOLO s!
- c  per color (dei punti)
- alpha e' in pratica il livello di trasparenza, in questo caso e' fondamentale in quanto alcuni punti andranno a sovrapporsi




```python
# Numpy array con i nomi delle nazioni
cnt_arr = np.array(['Australia','Brazil','Canada','Chile','France','Germany','Greece',
                   'Iceland','India','Iran','Italy','Mexico','New Zealand','Nigeria',
                   'Norway','Pakistan','Peru','Russia','Saudi Arabia','Singapore',
                   'South Africa','Spain','Sweden','Turkey','UK','US'])
# Tasso mortalita per 100k casi Coronavirus
dr_arr = np.array([1.8,53,24.5,56.5,45.4,11.2,2.2,
                   2.8,4,24.6,58.6,46.3,.5,.5,
                   4.9,2.9,83.3,11,10.4,.5,
                   21.5,61.6,56.9,7.3,62.4,52.9])
# Numero giornaliero di casi confermati (Tests)
test_arr = np.array([110,7197,600,1862,1636,1103,35,
                   10,295,1658,1226,2490,8,243,
                   48,1395,1101,4447,1443,280,
                   2830,1602,447,1205,1546,24988])
# Dimensione del punto dei casi confermati
cc_arr = np.array([24236,3456652,125408,390037,256534,229706,7684,
                   2035,2836925,350279,255278,537031,1654,50488,
                   10162,290445,549321,935066,302686,56031,
                   596060,370867,85411,253108,323008,5529824])

cc_arr_sm = cc_arr/1000 # rimpicciolisce a dimensione dei punti (?)
color_arr= np.random.rand(26)

# Se faccio questi sotto vengono aggiunti ad una figura aggiuntiva, non al mio scatterplot
# questo perche' ho provato ad usare la strada per cui prima faccio la figura, aggiungo gli assi
# e il disegno viene con un metodo!
#plt.title('Mortalita per 100k vs. Casi confermati')
#plt.xlabel('Mortalita per 100k')
#plt.ylabel('Casi confermati')
#plt.scatter(dr_arr, test_arr, s=cc_arr_sm, c=color_arr,alpha=0.5 )
#plt.figure(figsize=(8,5))


fig_13 = plt.figure(figsize=(8,5))
axes_13 = fig_13.add_axes([0.1,0.1,0.9,0.9])
axes_13.set_xlabel('Mortalita per 100k')
axes_13.set_ylabel('Casi confermati')
axes_13.set_title('Mortalita per 100k vs. Casi confermati')

axes_13.scatter(dr_arr,       # valori sull'asse delle x
                test_arr,     # valori sull'asse delle y
                s=cc_arr_sm,  # valori che indicano la dimensione dei punti
                c=color_arr,  # colori di ogni punto
                alpha=0.2 );  # trasparenza 1 = no trasparenza, 0 = completamente trasparente
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_71_0.png)
    


# 3D 

- `from mpl_toolkits import mplot3d`  abbiamo bisogno di importare questo modulo
- `projection='3d'`  quando si costruisce la figura si aggiunge questo parametro
- `fig_9 = plt.figure(figsize=(8,5), dpi=100)` dpi=100 stranamente sembra avere un effetto sulla dimensione della figura, mentre sembra non prendere il parametro figsize! Probabilmente questo e' dovuto al fatto che con `%matplotlib inline` mi mette le figure come dei png, cambiando il numero di punti questo cambia la dimensione dell'immagine a schermo. Per esempio dpi=100 e' circa un terzo della figura con dpi=300
- `scatter3D` la funzione per uno scatterplot 3D 
- `c= z_3` se uso questo parametro per i colori, allora quelli piu' in alto (asse z) avranno una sfumatura differente da quelli in basso


## Scatter3D


```python
from mpl_toolkits import mplot3d

fig_9 = plt.figure(figsize=(6,5), dpi=100)
axes_9 = fig_9.add_axes([0.1,0.1,0.9,0.9], projection='3d')   # mette degli assi 3D

z_3 = 40 *np.random.random(100)            # random:  sample dalla [0,1) uniforme
x_3 = np.sin(z_3) * np.random.randn(100)   # randn
y_3 = np.cos(z_3) * np.random.randn(100)   # randn: sample dalla N(0,1)

#axes_9.scatter3D(x_3,y_3,z_3, cmap='Blues');
axes_9.scatter3D(x_3,y_3,z_3, c=z_3, cmap='Blues');


```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_73_0.png)
    


## Contour3D

In questo caso ho bisogno di una funzione `z =z(x,y)` questo perche' lui deve poter sapere la altezza in ogni punto.

- per costruire una griglia rettangolare devo usare `np.meshgrid`:  `x_4, y_4  = np.meshgrid(x_4, y_4)` occhio che se non metto questo comando mi dice che c'e' un errore!? Il motivo e' semplice. meshgrid prende in ingresso due array 1 dimensionali e restituisce due array 2 dimensionali. In pratica ha fatto un prodotto cartesizano per ognuno dei punti del primo array creando una coppia con quelli del secondo array (e viceversa per il secondo array). Questo perche' contour3D si aspetta delle matrici per le x e le y e anche le z, in quanto per ogni x e y c'e'uno z. Per capire meglio fai fare print(x_4) prima e dopo meshgrid e vedi la differenza.



- Angolo di vista, per cambiare: `axes_9.view_init(45, 55)`. questo sposta l'angolo di vista di 45 gradi e lo ruota di 55
- il 4to parametro indica il numero di linee. In pratica quante fette parallele al piano xy che vengono visualizzate, se metto 80 sono tante, se metto 20 sono poche 


```python
fig_9 = plt.figure(figsize=(6,5), dpi=100)
axes_9 = fig_9.add_axes([0.1,0.1,0.9,0.9], projection='3d')

def get_z (x,y):
    return np.sin(np.sqrt(x**2+y**2))

x_4 = np.linspace(-6,6,30)
y_4 = np.linspace(-6,6,30)

#print(x_4)   
x_4, y_4  = np.meshgrid(x_4, y_4)
#print(x_4)


z_4 = get_z(x_4, y_4)

axes_9.set_xlabel('x')
axes_9.set_ylabel('y')
axes_9.set_zlabel('z')

axes_9.view_init(35, 30)  # angolo di visione, angolo di rotazione
axes_9.contour3D(x_4,y_4,z_4, 20, cmap='Blues');
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_75_0.png)
    


## WireFrame e surface
In questo caso vengono connessi tutti i punti da un segmento.
-`plot_wireframe(x_4,y_4,z_4, cmap='Blues')` in questo caso non devo passare il numero di tagli paralleli all'asse xy, quindi non ha il 4to parametro.

- `edgecolor ='none'` non colora i segmenti di collegamento (il wireframe)



```python
fig_9 = plt.figure(figsize=(6,5), dpi=100)
axes_9 = fig_9.add_axes([0.1,0.1,0.9,0.9], projection='3d')
axes_9.view_init(35, 30)  # angolo di visione, angolo di rotazione
#axes_9.plot_wireframe(x_4,y_4,z_4, cmap='Blues');

axes_9.plot_surface(x_4,y_4,z_4, rstride=1, cstride=1,  cmap='Blues', edgecolor='r');

```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_77_0.png)
    


# Finance Module

per installare ho fatto:
- anaconda prompt 
- pip install mpl_finance
- pip install --upgrade mplfinance   # upgrade

questo modulo fa vedere le candele giapponesi ecc.


- posso cambiare il nome dell'index: `goog_df.index.name='Date'` a questo punto l'index non si chiama piu' index ma Date! 
mi pare di capire che questo sia necessario perche' la libreria prenda correttamente il dataframe.


## Candele giapponesi
- Attento se prendi tante date, non riesci a vedere le candele! devono essere poche per essere visibili.

## trendlines
possiamo mettere automaticamente delle medie mobili con il parametro:
-`type='ohlc', mav=4`  # che significa che mette Open High Low Close e  la media mobile basata sui precedenti 4 punti,nota che possiamo tenere come type 'candle' (ma si vede meno bene)

- altri tipi di medie mobili. `mav=(3,5,7)` e' bene usare dispari, quindi fa vedere 3 medie mobili basate sui 3, 5 e 7 gg precedenti
- il parametro `volume=True` va vedere i volumi giornalieri 
- mostrare non-tading days: `show_nontrading=True`


## parse_dates
- `parse_dates=true` vuol dire che non prende le date come delle semplici stringhe ma le legge come date, infatti ora sono in formato Timestamp






```python
import mplfinance as mpf

goog_df = pd.read_csv('GOOG.csv', index_col = 0, parse_dates=True)
#type(goog_df.index[0])
goog_df.index.name='Date'

#goog_df = pd.read_csv('GOOG.csv')
goog_df.head(3)
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Open</th>
      <th>High</th>
      <th>Low</th>
      <th>Close</th>
      <th>Adj Close</th>
      <th>Volume</th>
    </tr>
    <tr>
      <th>Date</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>2019-08-21</th>
      <td>1193.150024</td>
      <td>1199.000000</td>
      <td>1187.430054</td>
      <td>1191.250000</td>
      <td>1191.250000</td>
      <td>740700</td>
    </tr>
    <tr>
      <th>2019-08-22</th>
      <td>1194.069946</td>
      <td>1198.011963</td>
      <td>1178.579956</td>
      <td>1189.530029</td>
      <td>1189.530029</td>
      <td>947500</td>
    </tr>
    <tr>
      <th>2019-08-23</th>
      <td>1181.989990</td>
      <td>1194.079956</td>
      <td>1147.750000</td>
      <td>1151.290039</td>
      <td>1151.290039</td>
      <td>1687000</td>
    </tr>
  </tbody>
</table>
</div>




```python
mask = (   ( pd.to_datetime(goog_df.index) >= pd.to_datetime('5/20/2020')) 
         & ( pd.to_datetime(goog_df.index) <= pd.to_datetime('8/19/2020')) )

new = goog_df.loc[mask]   # 
#mpf.plot(new, type='line')     # normali linee
#mpf.plot(new, type='candle')   # candele giapponesi
#mpf.plot(new, type='ohlc', mav=4)   # open high low close + moving average
mpf.plot(new, type='ohlc', mav=(3,5,7), volume=True, show_nontrading=True)   # open high low close + moving average
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_80_0.png)
    


# Heatmap
ho un array 2 dimensionale e voglio mostrarlo con dei colori invece che dei numeri.

- `symptoms` sono i 4 tipi di malattia a cui si riferiscono i dati (dyspnea = short of breath)
- `dates sono` i giorni in cui sono state fatte le osservazioni (sono 9 giorni)
- `symp_per` sono il numero di pazienti per giorno per malattia e' un array 4x9

Nota: pensavo che la heatmap di default mettesse delle righe bianche **in mezzo** alle caselle risultando molto poco chiara! in realta' e' una delle opzioni lasciate dal finance module!!!! (se faccio girare prima la casella sotto le righe bianche in mezzo non ci sono!)
 
- Per la heatmap si deve usare `subplots()` (non figure)
- Cosa fa il comando? prende la matrice che ha 0,3 righe, e 0,8 colonne. Per ognuna delle righe e delle colonne scrive un colore associato al numero dell'ingresso dell'array da disegnare.



```python
symptoms = ["Coronavirus","Influenza","Pneumonia","Dyspnea"]
dates = ["Jun28","Jul05","Jul12","Jul19","Jul26","Aug02","Aug09","Aug16","Aug21"]
symp_per = np.array([[5.2, 5.5, 5.7, 5.6, 5.3, 5.1, 5.0, 4.9, 5.3],
                    [3.5, 4.0, 4.3, 3.9, 3.5, 3.2, 2.7, 2.2, 2.0],
                    [1.8, 2.2, 2.3, 2.2, 2.1, 1.9, 1.7, 1.4, 1.3],
                    [1.0, 1.1, 1.1, 1.0, 0.9, 0.8, 0.8, 0.8, 0.7]])
```


```python
fig_10 , axes_10 = plt.subplots()
im= axes_10.imshow(symp_per, cmap='Wistia')
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_83_0.png)
    


## tics

non chiaro perche' all'inizio metta un np.arange, dato che abbiamo gia' un array con dates e symptoms:
- ok: `axes_10.set_xtics(np.arange(len(dates))` qui definisce la distanza (posizione) che devono avere i tics sulla mappa.
- `axes_10.set_xticlabels(dates)` questo definisce cosa ci deve essere nei ticks
- occhio che ticks ha la k
- occhio i ticks vanno assegnati **DOPO** avere definito la figura e l'axes
- giro i ticks di 45 gradi! `plt.setp(axes_10.get_xticklabels(), rotation=45, ha='right', rotation_mode='anchor')` (non chiaro l'anchor cosa faccia)



```python
fig_10 , axes_10 = plt.subplots()
im= axes_10.imshow(symp_per, cmap='Wistia')

axes_10.set_xticks(np.arange(len(dates)))       # posizione tics sull'asse x
axes_10.set_yticks(np.arange(len(symptoms)))    # posizione tics sull'asse y
                  
axes_10.set_xticklabels(dates)                 # cosa viene mostrato ad ogni tic dell'asse x 
axes_10.set_yticklabels(symptoms)                 # cosa viene mostrato ad ogni tic dell'asse x 
                  
plt.setp(axes_10.get_xticklabels(), rotation=45, ha='right');                  

```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_85_0.png)
    


## Numeri nelle caselle
metto qui anche i numeri dentro le caselle. Nota che usa un costrutto che non ho mai usato prima, chiama un metodo dell'axes dentro una funzione di matplotlib.

-`plt.setp(axes_10.get_xticklabels(), rotation=45, ha='right'); `
- chiama





```python
fig_10 , axes_10 = plt.subplots()
im= axes_10.imshow(symp_per, cmap='Wistia')

axes_10.set_xticks(np.arange(len(dates)))       # posizione tics sull'asse x
axes_10.set_yticks(np.arange(len(symptoms)))    # posizione tics sull'asse y
                  
axes_10.set_xticklabels(dates)                 # cosa viene mostrato ad ogni tic dell'asse x 
axes_10.set_yticklabels(symptoms)                 # cosa viene mostrato ad ogni tic dell'asse x 
                  
plt.setp(axes_10.get_xticklabels(), rotation=45, ha='right'); 

for i in range(len(symptoms)):
    for j in range(len(dates)):
        text = axes_10.text(j,i, symp_per[i,j], ha='center', va='center', color='k', fontweight='bold')


```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_87_0.png)
    


# Riempire le aree tra curve

ci sono ottimi esempi al sito di matplotlib:

https://matplotlib.org/3.1.1/gallery/lines_bars_and_markers/fill_between_demo.html

il metodo degli assi `fill_between()` permette di riempire quello che c'e' tra una curva e l'altra.


```python
x = np.arange(0.0, 2, 0.01)           # le x
y1 = np.sin(2 * np.pi * x)            # y1 = la funzione seno
y2 = 1.2 * np.sin(4 * np.pi * x)      # y2 = funzione seno piu' larga e con maggiore frequenza
```


```python
fig, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)  

ax1.fill_between(x, 0, y1)          # riempie tra 0 e y1
ax1.set_ylabel('TRA y1 e 0')

ax2.fill_between(x, y1, 1)          # riempie tra y1 e 1 (quello che c'e' sopra y1) 
ax2.set_ylabel('TRA y1 e 1')  

ax3.fill_between(x, y1, y2)         # quello che c'e' TRA y1 e sotto y2
ax3.set_ylabel('TRA y1 e y2')
ax3.set_xlabel('x')
```




    Text(0.5, 0, 'x')




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_90_1.png)
    


si possono mettere ulteriori condizioni per dare dei colori diversi tra le curve.
In particolare si aggiungono dei parametri logici.




```python
fig, (ax, ax1) = plt.subplots(2, 1, sharex=True)       # costruisce subplots
ax.plot(x, y1, x, y2, color='black')                   # disegna le 2 funzioni 
ax.fill_between(x, y1, y2, where=y2 >= y1, facecolor='green', interpolate=True)
ax.fill_between(x, y1, y2, where=y2 <= y1, facecolor='red', interpolate=True)
ax.set_title('fill between where')

# Test support for masked arrays.
y2 = np.ma.masked_greater(y2, 1.0)
ax1.plot(x, y1, x, y2, color='black')
ax1.fill_between(x, y1, y2, where=y2 >= y1,
                 facecolor='green', interpolate=True)
ax1.fill_between(x, y1, y2, where=y2 <= y1,
                 facecolor='red', interpolate=True)
ax1.set_title('Now regions with y2>1 are masked')
```




    Text(0.5, 1.0, 'Now regions with y2>1 are masked')




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_92_1.png)
    


# Ticks
Al comando ticks possono essere passati degli argomenti per specificare:
- `rotation = 45` ruota di 45 gradi
- se il primo ingresso e' un np.array allora quelli sono i ticks (le posizioni)
- se il secondo ingresso e' una tupla, allora alle varie posizioni dei ticks vengono messi i valori della tupla
- `fontsize=24` viene passato

come al solito puoi passare piu' di un parametro basta che sia separato dalla virgola!


```python
plt.plot(x_1,y_1)
#plt.xticks(np.linspace(0,5,100))
#plt.xticks(np.arange(15))
#plt.xticks(np.arange(5), ('Tom', 'Dick', 'Harry', 'Sally', 'Sue'))
#plt.grid(False, color='r', dashes=(0,2,1,2)) 
plt.grid(False) 
#plt.grid(b=None)
degrees = 45
plt.xticks(rotation=degrees)           # Rotazione dei ticks 
mioArray= np.array([1,2,3,4,8])
#plt.xticks(np.linspace(0,5,5), ('Tom', 'Dick', 'Harry', 'Sally', 'Sue'))
plt.grid(True)                         # presenza della grid 
plt.xticks(fontsize=24)                # GRANDEZZA FONT
plt.xticks(mioArray, ('Gino', 'Pino', 'Mino', 'Tino', 'Asdrubale'));
```


    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_94_0.png)
    


# Animazioni
Testo di riferimento:  https://riptutorial.com/Download/matplotlib-it.pdf

Lo ho scaricato ed e' nella dir.

- Bisogna importare anche la parte del package che fa animazioni.
- Bisogna usare il metodo `set_data()` che assegna i valori delle x e y di un grafico



```python
%matplotlib notebook
import matplotlib.animation as animation
```


```python
TWOPI = 2*np.pi
fig, ax = plt.subplots()                    # costruiamo una figura e un array di assi
t = np.arange(0.0, TWOPI, 0.001)            # t =array di posizioni 
s = np.sin(t)                               # y = sin(t) 
l = plt.plot(t, s)                          # grafico  
ax = plt.axis([0,TWOPI,-1,1])               # assi

redDot, = plt.plot([0], [np.sin(0)], 'ro')  # l'oggetto "redDot" disegna il punto rosso, all'inizio e' in zero

def animate(i):                             # questa funzione modifica i parametri del punto rosso
 redDot.set_data(i, np.sin(i))              # quindi il resto del grafico resta invariato!  
 return redDot,

# create animation using the animate() function
myAnimation = animation.FuncAnimation(fig, animate, frames=np.arange(0.0, TWOPI, 0.01), \
 interval=1, blit=True, repeat=True)
```


    <IPython.core.display.Javascript object>



<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAhwAAAFoCAYAAAAcpSI2AAAAAXNSR0IArs4c6QAAIABJREFUeF7snXd8HMX5xp+9IstykXvv1u3J3ZYhphmMwXRiurGxTfkBIYTqAAkdAhiIQ0lCMRAguGEILVTTO6G44np7cpd7QXKRZenu9veZPcmcZUm3d5q92z09+w9YOzvlmXfe+d67szMKeFEBKkAFqAAVoAJUwGIFFIvzZ/ZUgApQASpABagAFQCBg0ZABagAFaACVIAKWK4AgcNyiVkAFaACVIAKUAEqQOCgDVABKkAFqAAVoAKWK0DgsFxiFkAFqAAVoAJUgAoQOGgDVIAKUAEqQAWogOUKEDgsl5gFUAEqQAWoABWgAgQO2gAVoAJUgApQASpguQIEDsslZgFUgApQASpABagAgYM2QAWoABWgAlSACliuAIHDcolZABWgAlSAClABKkDgoA1QASpABagAFaAClitA4LBcYhZABagAFaACVIAKEDhoA1SAClABKkAFqIDlChA4LJeYBVABKkAFqAAVoAIEDtoAFaACVIAKUAEqYLkCBA7LJWYBVIAKUAEqQAWoAIGDNkAFqAAVoAJUgApYrgCBw3KJWQAVoAJUgApQASpA4KANUAEqQAWoABWgApYrQOCwXGIWQAWoABWgAlSAChA4aANUgApQASpABaiA5QoQOCyXmAVQASpABagAFaACBA7aABWgAlSAClABKmC5AgQOyyVmAVSAClABKkAFqACBgzZABagAFaACVIAKWK4AgcNyiVkAFaACVIAKUAEqQOCgDVABKkAFqAAVoAKWK0DgsFxiFkAFqAAVoAJUgAoQOGgDVIAKUAEqQAWogOUKEDgsl5gFUAEqQAWoABWgAgQO2gAVoAJUgApQASpguQIEDsslZgFUgApQASpABagAgYM2QAWoABWgAlSACliuAIHDcolZABWgAlSAClABKkDgoA1QASpABagAFaAClitA4LBcYhZABagAFaACVIAKEDhoA1SAClABKkAFqIDlCjgGOFRVnQRgoKZpl9Sgisvn8z2qKMoEAGFFUR4JBAIPV6ar657lArMAKkAFqAAVoAJUALA9cOTl5TVyu9136Lp+G4DpNQGH3++/Xtf1sV6v97SysrJWbrf7YwCXa5r2aV33aABUgApQASpABahAahSwPXCoqvoygGaKohTp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" width="432">


## Mio test di animazione
vorrei fare estendere la funzione seno, in modo che ad ogni frame sia moltiplicata per una diversa ampiezza.
Attenzione: ho provato a farlo girare molte volte e non andava. Ho resettato il kernel e ora sembra fungere.
Mi viene il dubbio che il problema fosse connesso a qualche cella che avevo lasciato attiva.

- Curiosamente se metto i limiti degli assi il grafico non appare! **Errore** Ax e' un array di assi! 
- `interval=1`  rallenta l'esecuzione del programma
- frames sono tutti i vari prarametri che andranno a definire i frame

possiamo ingrandire o diminuire la dimensione dei limiti:
https://stackoverflow.com/questions/53423868/matplotlib-animation-how-to-dynamically-extend-x-limits




```python
TWOPI = 2*np.pi
#fig, ax = plt.subplots()                    # costruiamo una figura e un array di assi

fig = plt.figure()
ax = fig.add_subplot(111, autoscale_on=False, xlim=(0, 6.29), ylim=(-2, 2))


#ax = plt.axis([0,TWOPI,-1,1])              # ATTENTO assi QUESTO BLOCCA set_xlim
#ax.set_xlim([0,TWOPI])                     # ERRORE ax non e' un asse ma una tupla di assi!  
#ax.set_ylim([-1,1])                        # ERRORE    

t = np.arange(0.0, TWOPI, 0.001)            # t =array di posizioni 
s = np.sin(t)  
# y = sin(t) 
plt.grid(False)

new = plt.plot(t, t)                        # bisettrice
second = plt.plot(t,s/2)
curva, = plt.plot(t, s)                     # grafico  
#ax = plt.axes(xlim=(0, 10), ylim=(-1, 1))


def animate(A):                             # questa funzione modifica i parametri del punto rosso
 curva.set_ydata(A *np.sin(t))              # quindi il resto del grafico resta invariato!  
 #print(A*np.sin(t))
 return curva,

frames1 = np.arange(0.0,1.0,0.001)
frames2 = np.arange(1.0,0.0,-0.001)
frames = np.concatenate((frames1, frames2), axis=None)

# create animation using the animate() function
#myAnimation = animation.FuncAnimation(fig, animate, frames = np.arange(0.0, 1.0, 0.001), \
# interval=10, blit=True, repeat=True)

myAnimation = animation.FuncAnimation(fig, animate, frames = frames, \
 interval=1, blit=True, repeat=True)
```


    <IPython.core.display.Javascript object>



<img src="data:," width="0">


## Slider interattivo
possiamo modificare la figura tramite uno slider interattivo!
In questo caso non uso la funzione animate, perche' la modifica viene fatta in base a cosa tocco sullo slider.


```python
from matplotlib.widgets import Slider
TWOPI = 2*np.pi
fig, ax = plt.subplots()

A0 = .5                                       # valore iniziale ampiezza 
t = np.arange(0.0, TWOPI, 0.001)              # x del grafico 
s = A0*np.sin(t)                              # y del grafico  (iniziale)

l, = plt.plot(t, s, lw=2)                     # grafico (da capire la virgola)

ax = plt.axis([0,TWOPI,-1,1])                 # assi (che non verranno toccate) ??? 
axamp = plt.axes([0.25, .03, 0.50, 0.02])     # non chiaro axIs e axEs

# Slider
samp = Slider(axamp, 'Amp', 0, 1, valinit=A0) # SLIDER interattivo, si chiama  "samp"

def update(val):
 # amp is the current value of the slider
 amp = samp.val                               # valore corrente dello slider
 # update curve
 l.set_ydata(amp*np.sin(t))                   # fai update delle y della curva  
 # redraw canvas while idle
 fig.canvas.draw_idle()                       

samp.on_changed(update)                       # ridisegna la figura se muoviamo lo slider

#plt.show()

```


    <IPython.core.display.Javascript object>



<img src="data:image/png;base64,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" width="432">





    0



# Foto
Vediamo come mostrare una immagine. Si passa un array 2D e questo viene convertito automaticamente, assegnando ai valori un colore. Per esempio: 


```python
immagine = np.array([ [1,0,0,0,1,0,0,0,1],
                      [0,0,0,0,1,0,0,0,0],
                      [0,0,0,0,1,0,0,0,0],
                      [0,0,0,0,1,0,0,0,0],
                      [0,0,0,0,1,0,0,0,0],
                      [1,0,0,0,1,0,0,0,1]])

plt.imshow(immagine)
```




    <matplotlib.image.AxesImage at 0x2de6a38e640>




    
![png]({{ site.baseurl }}/images/posts/Matplotlib_images/Matplotlib_PA_103_1.png)
    


# Unpacking
questo non e' strettamente connesso con matplotlib....


```python
numbers = [1, 2, 3, 4, 5, 6]
first, *rest = numbers       # multiple assignment
print(rest)
print(first)

d = dict(a=5,b=2,c=4)

```

    [2, 3, 4, 5, 6]
    1
    

# enumerate()


```python
for o,_ in enumerate(d):
    print(o)                # stampa l'ordine degli oggetti
```

    0
    1
    2
    


```python
for _, o in enumerate(d):
    print(o)                # stampa le chiavi del dizionario
```

    a
    b
    c
    


```python
for _, o in enumerate(d):
    print(d[o])              # stampa i valori del dizionario
```

    5
    2
    4
    


```python
for o in enumerate(d):
    print(o)              # stampa le NUOVE coppie chiave-chiave vecchia costruite da enumerate()
```

    (0, 'a')
    (1, 'b')
    (2, 'c')
    


```python

```
