   module parametri                                  ! programma che legge un file di testo ed estrae informazioni
   implicit none

   integer :: eXl           = 8      ! elementi X lettera   
   integer :: lung_parole   = 7      ! numero di lettere x parola
   integer :: num_simboli   = 3      ! numero simboli
   integer :: lung_seq               != lung_parole * eXl   !  numero di punti per parola =  eXl x lung_parole  
   integer :: Nd =4                  ! numero di discord da cercare
   integer :: N  =2000               ! lunghezza della present queue
   integer :: update_period  != N - lung_seq   ! 
   integer :: nmax=4    ! numero di analisi
   integer :: ncd       ! dimensione della coda_discord
   integer :: nnei=1      !numero di cluster vicini in cui cercare
   !integer :: brute       ! esegui un calcolo brute force, non uscire mai dal ciclo interno

   real (kind=8), dimension(:), allocatable :: serie , Dserie, D2serie
   real (kind=8), dimension(:,:), allocatable :: serie_composta ! i punti non sono in fila ma provengono da piccole sequenze una dopo l'altra
   integer , dimension(:), allocatable :: hub  ! quante volte la sequenza i-esima e' il vicino di una altra sequenza 
   real (kind=8), dimension(:), allocatable :: array_vincolo ! vincolo tra nnd(i+1) e nnd(i)
 
   integer , dimension(:), allocatable :: ordineCluster

   integer :: iarrivo =0
   integer :: nbin=1000         ! il file input.dat fa orverride di questo valore
   real (kind = 8) :: binsize   
   integer :: uscita
   real (kind = 8) :: inizioTempo, fineTempo
!--------------------------------------------
   !logical ::  useRandomSeed = .false. ! in generala riordina secondo un seme diverso ogni volta
   logical ::  useRandomSeed = .true. ! in generala riordina secondo un seme diverso ogni volta
   !logical :: gaussBreakpoints = .true. ! come definisce intervalli per trasformare r-punti in lettere
   logical :: gaussBreakpoints = .false. ! come definisce intervalli per trasformare r-punti in lettere

   logical :: forceBreakPoints = .false.
   !logical :: forceBreakPoints = .true.

   !logical :: risparmiaMemoria =.false.
   logical :: risparmiaMemoria =.true.

   !logical :: musax  =  .true.
   logical :: musax  =  .false.

   integer :: maxShuffle =1  ! parametro che ci dice quante diverse versioni degli r-punti ci sono

   logical :: verbose = .false.

   logical :: PA=.true.
   logical :: siNNDk = .false.
 
!--------------------------------------------

   integer :: primoNonPreso=1 ! prima sequenza non ancora assegnata ai cluster

   !integer, dimension(:), allocatable :: binNND
   real(kind =8), dimension(:), allocatable :: binNND

!   real (kind =8) , dimension(:), allocatable :: rbinNND !(versione double di binNND) 
   integer :: n_code_shadow    ! numero di code contenute in longStat, Tmax/ N

   integer  :: iOutVecc = 0        ! indice che gira sugli outlier
   integer  :: quantiVecchi = 100   ! quanti outlier tengo?  
   !real (kind =8),dimension(:,:), allocatable :: vecchiOutlier


   character (len=100) :: dettagliCalcolo
   character (len=1000) :: eseguibile


   integer  , dimension(:,:), allocatable :: distLoc  ! distanze locali relative a cluster(1,k1)

   integer :: num_simboli0 
   integer :: num_simboli1 

   integer, dimension(:), allocatable :: ordineRandomCluster
   integer, dimension(:), allocatable :: randomSequenze

   integer , dimension(:), allocatable :: discords   ! posizione di tutti i discord finora trovati 

   integer , dimension(:), allocatable :: cEu ! Cluster Euclideo in ingresso posizione inizio sequenza, in uscita indice di cluster Euclideo
   integer , dimension(:), allocatable :: percorsoAttuale 
   logical :: arriviDaUnoZero = .true.

   integer :: quanteVolteTot =0 

   character (len = 20) :: algoritmo
   logical   :: Znorm  ! fai la z-normalizzazione?

   integer , dimension(:,:), allocatable :: ordineTesteCode

   real (kind=8), dimension(:), allocatable :: NND, NND2, QNND
   real (kind=8), dimension(:,:), allocatable :: NNDk   
   integer :: kmax =3                                   ! numero di k-nearest neighbor in memoria

   integer , dimension(:), allocatable :: pos_discords  != -1000000000
   real (kind=8) , dimension(:), allocatable :: val_discords  != -1000000000
   !real(kind = 8) , dimension(Nd) :: NND

   real (kind = 8) :: Q1, Q3, IQ, delta = 3.d0  ! primo, terzo quartile e interquartile
   real (kind = 8) :: Q3tot, Q1tot, IQtot
   real (kind = 8) :: QM
 
   integer :: Tora     ! indice temporale al momento dell'ananlisi
   integer :: Tmax
   integer :: nfantasmi=0
   real(kind=8) :: chiamateAdistanza


   real (kind= 8) :: q, kappa

   real (kind =8) :: qsimb, ksimb

   real (kind =8) :: shrink = 1.d0

   real (kind =8), dimension (:,:,:) , allocatable :: longStat ! primo ingresso posizione, secondo percentuale, terzo coda
   real (kind =8), dimension (:,:,:) , allocatable :: longCdf  ! come longStat (sono pdf) ma Cdf 
    

   logical , dimension(:), allocatable :: seq_analizzata

   real (kind =8) :: ave , var  ! media e deviazione standard della NNDistica degli NND

   real (kind =8), dimension(:,:), allocatable :: bari

   integer, dimension(:,:), allocatable :: bariNei
   real (kind =8), dimension(:,:), allocatable :: bariMat


   real (kind =8), dimension(:,:), allocatable :: ghost
    integer                                    :: ighost
   integer , dimension(:,:), allocatable :: cluster, clusterP1, clusterD
   integer , dimension(:,:,:), allocatable :: clusterN
   integer, dimension(:,:), allocatable :: rCluster
   integer , parameter :: nRiordini =0
 
   integer , dimension(:), allocatable :: iniCluster, finCluster ! indice di inizio e fine in cluster (riordinato)
   integer , dimension(:), allocatable :: iniClusterP1, finClusterP1 ! indice di inizio e fine in cluster (riordinato)

   integer , dimension(:), allocatable :: posizioneCluster  ! dopo aver riordinato per dimensione cluster, il primo
                                                            ! cluster non e' piu' quello con posizioneRegistro =1!
                                                            ! input = posizioneREgistro , output = posizione ordine per
                                                            ! grandezza


   real (kind = 8), dimension(:), allocatable ::  r_punto
   integer, dimension(:), allocatable ::  s_punto

   real (kind = 8), dimension(:,:), allocatable :: sequenze_ristrette
   integer, dimension(:,:), allocatable         :: sequenze_simboliche
   real (kind =8), dimension(:), allocatable :: xpos

   real (kind = 8) :: bin = 0.2                 ! dimensione bin (scatole in cui metto i parametri) per pdf
   integer :: ngrande_min = 1000                ! minimo numero di segmenti della Pdf
   integer :: ngrande                           ! numero effettivo di segmenti della Pdf
   integer :: ngrande_max                       ! in tinE struttura... N/10  


   integer , dimension(:), allocatable :: posizioneRegistro
   integer , dimension(:), allocatable  :: seq_simb

   character (len=10), dimension(100) :: nomiPar !array con nomi parametri, alla posizione 1 c'e' il primo parm trovato, etc..

   integer, dimension (:), allocatable :: clusterSize_uso
   integer, dimension (:), allocatable :: pdf, ncdf, clusterSize 
   real (kind =8 ), dimension(:), allocatable ::  cdf, pos_lett





   integer, dimension(:), allocatable ::  registro_prima_osservazione
     
   integer , dimension(:), allocatable :: indice_crescita  !data una parola mi dice la probabilita' che dopo si cresca 
   integer :: indiceParole


   real (kind = 8), dimension(:), allocatable :: media 
   real (kind = 8), dimension(:,:), allocatable :: mediaN 

   real (kind = 8), dimension(:), allocatable ::mezzaMedia 

   real (kind = 8), dimension(:), allocatable :: val_medio
   real (kind = 8), dimension(:), allocatable :: dev_standard


   type dp                                   ! definisco dp come coppia reale e intero 
      real (kind =8):: discord
      integer       :: posizione
   end type dp

   type(dp), dimension(:), allocatable ::  coda_discord  ! dichiaro un array di tot oggetti di tipo dp


   type vdp
      real (kind=8)                            :: discord      ! valore dell'NND
      integer                                  :: posizione    ! posizione nella serie
      real (kind=8), dimension(:), allocatable :: sequenza     ! sequenza associata
   end type vdp

   type(vdp), dimension(:), allocatable :: coda_vecchi  ! qui posizione indica in che coda_discord 'e stato trovato


!--------------- per il TREE ----------------------------
!--------------- per il TREE ------------------------
   type node                                      ! definisce un nuovo tipo chiamato " node " (struttura del C)  
      integer, dimension(:), allocatable :: Ssequenza          ! contiene la sequenza che vogliamo controllare 
      integer :: quanti                           ! quanti oggetti trovati di un dato valore
      integer :: inizio                           ! posizione di partenza della PRIMA sequenza incontrata associata alla Ssequenza
      integer :: indiceCluster                    ! indice identificativo del cluster

      type (node),  pointer :: left=>null(), right=>null()   ! contiene 2 valori left e right. MA come fa a terminare? di base il puntatore e' nullo! )
   end type node
!---------------fine per il TREE ------------------------
!---------------fine per il TREE ------------------------

   contains
!------------------------------------------------

!------------------------------------------------------------------------------------------------------
!------------------------------------------------------------------------------------------------------
!------------------------------------------------------------------------------------------------------
  recursive subroutine inserisci (t, punto_partenza )     ! questa sub ha 2 argomenti, il nodo "t", la sequenza che deve essere messa nel tree e il punto di partenza della sequenza

      type (node), pointer :: t                                ! dice che l'oggetto in ingresso t e' un nodo
      integer, intent (in) :: punto_partenza                   ! prende come ingresso il punto di partenza della sequenza
      integer :: i                                             ! serve per i cicli 

!------- ricapitolo---------------------------------
!  registro_prima_osservazione(1) = 1   ! posizione inziale del primo   cluster 1
!  registro_prima_osservazione(2) = 4   ! posizione inziale del secondo cluster 4
!  registro_prima_osservazione(3) = 27  ! posizione inziale del terzo   cluster 27
!  registro_prima_osservazione(4) = 0   ! posizione inziale del quarto  cluster ... non ho ancora trovato il quarto cluster 


!  clusterSize_uso(1) = 332              ! grandezza del cluster 1
!  clusterSize_uso(2) =  45              ! grandezza del cluster 2
!  clusterSize_uso(1) = 101              ! grandezza del cluster 3


!  posizioneRegistro(33) = 3       ! la sequenza che comincia in 33 associata al cluster 3 
!  posizioneRegistro(34) = 75      ! la sequenza che comincia in 34           al cluster 75 
!  posizioneRegistro(35) = 98      ! la sequenza che comincia in 35           al cluster 98
!  posizioneRegistro(36) = 75      ! la sequenza che comincia in 36           al cluster 75  

!  indiceParole  = numero di cluster diversi trovati fino a quel momento (e poi totale), ed e' anche l'indice del cluster stesso


       !open (70)

       !close(70)
!---------------------------------------------------------------------------------------------------------------------------
!     TROVATA una NUOVA parola (aka cluster , aka ssequenza)
      if (.not. associated (t)) then                           !  Se il nodo non e' ancora stato visitato: HO trovato un nuovo cluster    
         allocate (t)                                          !  allocca l'area di memoria (altrimenti e' solo predisposto che esista, ma non e' alloccata
         allocate(t%Ssequenza(lung_parole) )                   ! allocca l'array associato alla sequenza 

         indiceParole =indiceParole +1                         ! ho trovato un nuovo cluster
         registro_prima_osservazione(indiceParole)=  punto_partenza ! il nuovo cluster e' osservato la prima volta qui
         clusterSize_uso(indiceParole) =0                       ! non riesco a capire perche' con 0 funge, dovrebbe essere 1!!!! (o che ho segato l'altro...)  
         posizioneRegistro(punto_partenza)  = indiceParole     ! al contrario la sequenza che comincia in punto_partenza e' nel cluster indiceParole

         t % Ssequenza = sequenze_simboliche(punto_partenza,:) !  il parametro Ssequenza dell'oggetto t, viene preso dall'ingresso della subroutine
         t % inizio = punto_partenza                           !  il parametro che indica da dove comincia la PRIMA sequenza che ha raggiunto questo nodo
         t % quanti  = 0                                       !  il parametro di questo nodo che indica quante sequenza sono associate a questa sequenza viene messo a 0
         t % indiceCluster = indiceParole !indiceParole        !  numero identificativo di questo cluster

         ! a questo punto, nel nodo e' stata messa una sequenza simbolica, alla sua destra o sinistra non c'e' nulla
         nullify (t % left)                                    ! nullifica l'ingresso left, 
         nullify (t % right)                                   ! nullifica l'ingresso right
      endif 
  


!-----  la s-sequenza e' arrivata su un nodo gia' associato ad un cluster (s-sequenza), controlla ora 3 possiblita':
!-----  la s-sequenza e' "piu' piccola" di quella del nodo, allora devo spostare la s-sequenza ad un nodo a sinistra
!-----  la s-sequenza e' "piu' grande " di quella del nodo, allora devo spostare la s-sequenza ad un nodo a destra
!-----  la s-sequenza e' "uguale"       a  quella del nodo, allora devo aggiornare gli array (per essempio dire che la grandezza del cluster deve aumentare di 1)

     if (associated (t))  then  ! se invece sono gia' stato in questo nodo                                  
        do i=1,  lung_parole    !  controlla gli elementi della sequenza passata in ingresso (da sinistra a dx in questo caso, che e' anche come noi paragoniamo numeri  
         
           if      ( sequenze_simboliche(punto_partenza,i) .lt. t % Ssequenza(i) ) then         !  se le "decine" della nuova sequenza sono piu' piccole di quella attuale 
                   call inserisci (t%left,  punto_partenza)  ! inserisci la sequenza in in gresso a sinistra (ordino dal piu' picccolo al piu' grande)
                   return                                         ! questo RETURN e' importantissimo, vuol dire che non continui ad eseguire la subroutine, quindi, p.es non aggiungi 1 a quanti! 
           else if ( sequenze_simboliche(punto_partenza,i) .gt. t % Ssequenza(i) ) then         ! idem per per le sequenze maggiori 
                   call inserisci (t%right, punto_partenza)
                   return  
           endif 
        enddo
!--------------- se arrivi qui, vuol dire che sei arrivato su una parola simbolica gia' trovata! (controllo comunque)
        if (all ( sequenze_simboliche(punto_partenza,:) .eq. t % Ssequenza(:)))  then 
         !indiceParole =indiceParole +1  ! non ho trovato un cluster in piu', questo deve rimanere commentato
         !registro_prima_osservazione( t % indiceCluster ) = punto_partenza        ! nota che muovendomi nel tree non posso sapere indiceParole... devo usare questo 
         clusterSize_uso( t% indiceCluster)  = clusterSize_uso(t%indiceCluster)+1         
         posizioneRegistro(punto_partenza)  =  t % indiceCluster  
!-----------------------------------------------------------------------------------------
         t % quanti = t % quanti+1                                      ! se sei arrivato fino a qui, allora tutti gli ingressi della sequenza sono uguali a quello attuale, aggiungi 1 al suo numero
        endif 

     endif  ! questo controlla che il nodo sia gia' associato

!---------------------------------------       



!---------------------------------------
   end subroutine inserisci

!------------------------------------------------------------------------------------------------------
!------------------------------------------------------------------------------------------------------
!------------------------------------------------------------------------------------------------------


   recursive subroutine read_tree (t)

      type (node), pointer :: t  ! A tree

      if (associated (t)) then               ! controlla un nodo, solo se e' stato raggiunto (e quindi associato)
         call read_tree (t % left)          ! chiama la funzione che scrive la sequenza alla sua sinistra (prima di passare al passo successivo devi finire questo!)
         !write(21,*) t%inizio, t%quanti,  'sequenza= ', t % Ssequenza  ! scrivi i parametri associati a questo nodo
         call read_tree (t % right)         ! chiama la funzione che scrive la sequenza alla sua destra 
      end if

   end subroutine read_tree

!------------------------------------------------------------------------------------------------------


     recursive subroutine LM_read_tree(t, sequenza)
     type (node), pointer :: t  ! A tree
     integer , dimension(lung_parole), intent(in) :: sequenza
     
      if (associated (t)) then               ! controlla un nodo, solo se e' stato raggiunto (e quindi associato)
         call LM_read_tree (t % left, sequenza)        ! chiama la funzione che scrive la sequenza alla sua sinistra (prima di passare al passo successivo devi finire questo!)
         if (all ( sequenza(:) .eq. t % Ssequenza(:)))  then 
           write(55,*)   t% indiceCluster, t%quanti, t%inizio        
           return   
         endif 

         !write(52,*) t%inizio, t%quanti,  'sequenza= ', t % Ssequenza  ! scrivi i parametri associati a questo nodo
         call LM_read_tree (t % right, sequenza)         ! chiama la funzione che scrive la sequenza alla sua destra 
      end if

     end subroutine LM_read_tree

!------------------------------------------------------------------------------------------------------
!------------------------------------------------------------------------------------------------------


     subroutine LM_costruisci_tree(t,punto_partenza)
     implicit none 
     integer :: i 
     integer, intent(in) :: punto_partenza
     type(node), pointer, intent(in) :: t   ! sempre annullare MA non nella dichiarazione!!!!!!
     !t => null()            ! annulla QUI

     if (allocated(clusterSize_uso) ) deallocate(clusterSize_uso)
     allocate (clusterSize_uso (N-lung_seq+1)) ! al piu' posso avere un cluster per ogni sequenza 

     clusterSize_uso= 0                   ! 
     posizioneRegistro = 0
     registro_prima_osservazione =  0   

     indiceParole = 0  ! all'inizio ci sono 0 cluster, devo trovarli, qui sotto calcola quanti sono
     !do i=1, N-lung_seq+1
         call LM_inserisci(t,punto_partenza)   ! inserisci la i-esima sequenza all'interno del tree
     !enddo  

     if (allocated(clusterSize) ) deallocate(clusterSize) 
     allocate (clusterSize(indiceParole) )   ! trovate da inserisci qui sopra 
     clusterSize = clusterSize_uso(1:indiceParole)    
 
     deallocate(clusterSize_uso) 

     end subroutine LM_costruisci_tree


!------------------------------------------------------------------------------------------------------
  recursive subroutine MU_inserisci (t, punto_partenza )     ! questa sub ha 2 argomenti, il nodo "t", la sequenza che deve essere messa nel tree e il punto di partenza della sequenza

      type (node), pointer :: t                                ! dice che l'oggetto in ingresso t e' un nodo
      integer, intent (in) :: punto_partenza                   ! prende come ingresso il punto di partenza della sequenza
      integer :: i                                             ! serve per i cicli 

!------- ricapitolo---------------------------------
!  registro_prima_osservazione(1) = 1   ! posizione inziale del primo   cluster 1
!  registro_prima_osservazione(2) = 4   ! posizione inziale del secondo cluster 4
!  registro_prima_osservazione(3) = 27  ! posizione inziale del terzo   cluster 27
!  registro_prima_osservazione(4) = 0   ! posizione inziale del quarto  cluster ... non ho ancora trovato il quarto cluster 


!  clusterSize_uso(1) = 332              ! grandezza primo   cluster  = 332
!  clusterSize_uso(2) =  45              ! grandezza secondo cluster  =  45
!  clusterSize_uso(3) = 101              ! grandezza terzo   cluster  = 101


!  posizioneRegistro(33) = 3       ! la sequenza che comincia in 33 associata al cluster 3 
!  posizioneRegistro(34) = 75      ! la sequenza che comincia in 34           al cluster 75 
!  posizioneRegistro(35) = 98      ! la sequenza che comincia in 35           al cluster 98
!  posizioneRegistro(36) = 75      ! la sequenza che comincia in 36           al cluster 75  

!  indiceParole  = numero di cluster diversi trovati fino a quel momento (e poi totale), ed e' anche l'indice del cluster stesso


       !open (70)

       !close(70)
!---------------------------------------------------------------------------------------------------------------------------
!     TROVATA una NUOVA parola (aka cluster , aka ssequenza)
      

      if (.not. associated (t)) then                           !  Se il nodo non e' ancora stato visitato: HO trovato un nuovo cluster    
         allocate (t)                                          !  allocca l'area di memoria (altrimenti e' solo predisposto che esista, ma non e' alloccata
         allocate(t%Ssequenza(lung_parole*maxShuffle) )                   ! allocca l'array associato alla sequenza 

         indiceParole =indiceParole +1                         ! ho trovato un nuovo cluster
         registro_prima_osservazione(indiceParole)=  punto_partenza ! il nuovo cluster e' osservato la prima volta qui
         clusterSize_uso(indiceParole) =0                       ! non riesco a capire perche' con 0 funge, dovrebbe essere 1!!!! (o che ho segato l'altro...)  
         posizioneRegistro(punto_partenza)  = indiceParole     ! al contrario la sequenza che comincia in punto_partenza e' nel cluster indiceParole

         t % Ssequenza = s_punto(:)                            !  il parametro Ssequenza dell'oggetto t, viene preso dall'ingresso della subroutine
         t % inizio = punto_partenza                           !  il parametro che indica da dove comincia la PRIMA sequenza che ha raggiunto questo nodo
         t % quanti  = 0                                       !  il parametro di questo nodo che indica quante sequenza sono associate a questa sequenza viene messo a 0
         t % indiceCluster = indiceParole !indiceParole        !  numero identificativo di questo cluster

         ! a questo punto, nel nodo e' stata messa una sequenza simbolica, alla sua destra o sinistra non c'e' nulla
         nullify (t % left)                                    ! nullifica l'ingresso left, 
         nullify (t % right)                                   ! nullifica l'ingresso right
      endif 
  


!-----  la s-sequenza e' arrivata su un nodo gia' associato ad un cluster (s-sequenza), controlla ora 3 possiblita':
!-----  la s-sequenza e' "piu' piccola" di quella del nodo, allora devo spostare la s-sequenza ad un nodo a sinistra
!-----  la s-sequenza e' "piu' grande " di quella del nodo, allora devo spostare la s-sequenza ad un nodo a destra
!-----  la s-sequenza e' "uguale"       a  quella del nodo, allora devo aggiornare gli array (per essempio dire che la grandezza del cluster deve aumentare di 1)

     if (associated (t))  then  ! se invece sono gia' stato in questo nodo                                  
        do i=1,  lung_parole*maxShuffle    !  controlla gli elementi della sequenza passata in ingresso (da sinistra a dx in questo caso, che e' anche come noi paragoniamo numeri  
         
           if      ( s_punto(i) .lt. t % Ssequenza(i) ) then         !  se le "decine" della nuova sequenza sono piu' piccole di quella attuale 
                   call MU_inserisci (t%left,  punto_partenza)  ! inserisci la sequenza in in gresso a sinistra (ordino dal piu' picccolo al piu' grande)
                   return                                         ! questo RETURN e' importantissimo, vuol dire che non continui ad eseguire la subroutine, quindi, p.es non aggiungi 1 a quanti! 
           else if ( s_punto(i) .gt. t % Ssequenza(i) ) then         ! idem per per le sequenze maggiori 
                   call MU_inserisci (t%right, punto_partenza)
                   return  
           endif 
        enddo
!--------------- se arrivi qui, vuol dire che sei arrivato su una parola simbolica gia' trovata! (controllo comunque)
        if (all ( s_punto(:) .eq. t % Ssequenza(:)))  then 
         clusterSize_uso( t% indiceCluster)  = clusterSize_uso(t%indiceCluster)+1         
         posizioneRegistro(punto_partenza)  =  t % indiceCluster  
!-----------------------------------------------------------------------------------------
         t % quanti = t % quanti+1                                      ! se sei arrivato fino a qui, allora tutti gli ingressi della sequenza sono uguali a quello attuale, aggiungi 1 al suo numero
        endif 

     endif  ! questo controlla che il nodo sia gia' associato

!---------------------------------------       

!---------------------------------------
   end subroutine MU_inserisci



!------------------------------------------------------------------------------------------------------
  recursive subroutine LM_inserisci (t, punto_partenza )     ! questa sub ha 2 argomenti, il nodo "t", la sequenza che deve essere messa nel tree e il punto di partenza della sequenza

      type (node), pointer :: t                                ! dice che l'oggetto in ingresso t e' un nodo
      integer, intent (in) :: punto_partenza                   ! prende come ingresso il punto di partenza della sequenza
      integer :: i                                             ! serve per i cicli 

!------- ricapitolo---------------------------------
!  registro_prima_osservazione(1) = 1   ! posizione inziale del primo   cluster 1
!  registro_prima_osservazione(2) = 4   ! posizione inziale del secondo cluster 4
!  registro_prima_osservazione(3) = 27  ! posizione inziale del terzo   cluster 27
!  registro_prima_osservazione(4) = 0   ! posizione inziale del quarto  cluster ... non ho ancora trovato il quarto cluster 


!  clusterSize_uso(1) = 332              ! grandezza primo   cluster  = 332
!  clusterSize_uso(2) =  45              ! grandezza secondo cluster  =  45
!  clusterSize_uso(3) = 101              ! grandezza terzo   cluster  = 101


!  posizioneRegistro(33) = 3       ! la sequenza che comincia in 33 associata al cluster 3 
!  posizioneRegistro(34) = 75      ! la sequenza che comincia in 34           al cluster 75 
!  posizioneRegistro(35) = 98      ! la sequenza che comincia in 35           al cluster 98
!  posizioneRegistro(36) = 75      ! la sequenza che comincia in 36           al cluster 75  

!  indiceParole  = numero di cluster diversi trovati fino a quel momento (e poi totale), ed e' anche l'indice del cluster stesso


       !open (70)

       !close(70)
!---------------------------------------------------------------------------------------------------------------------------
!     TROVATA una NUOVA parola (aka cluster , aka ssequenza)
      

      if (.not. associated (t)) then                           !  Se il nodo non e' ancora stato visitato: HO trovato un nuovo cluster    
         allocate (t)                                          !  allocca l'area di memoria (altrimenti e' solo predisposto che esista, ma non e' alloccata
         allocate(t%Ssequenza(lung_parole) )                   ! allocca l'array associato alla sequenza 

         indiceParole =indiceParole +1                         ! ho trovato un nuovo cluster
         registro_prima_osservazione(indiceParole)=  punto_partenza ! il nuovo cluster e' osservato la prima volta qui
         clusterSize_uso(indiceParole) =0                       ! non riesco a capire perche' con 0 funge, dovrebbe essere 1!!!! (o che ho segato l'altro...)  
         posizioneRegistro(punto_partenza)  = indiceParole     ! al contrario la sequenza che comincia in punto_partenza e' nel cluster indiceParole

         t % Ssequenza = s_punto(:)                            !  il parametro Ssequenza dell'oggetto t, viene preso dall'ingresso della subroutine
         t % inizio = punto_partenza                           !  il parametro che indica da dove comincia la PRIMA sequenza che ha raggiunto questo nodo
         t % quanti  = 0                                       !  il parametro di questo nodo che indica quante sequenza sono associate a questa sequenza viene messo a 0
         t % indiceCluster = indiceParole !indiceParole        !  numero identificativo di questo cluster

         ! a questo punto, nel nodo e' stata messa una sequenza simbolica, alla sua destra o sinistra non c'e' nulla
         nullify (t % left)                                    ! nullifica l'ingresso left, 
         nullify (t % right)                                   ! nullifica l'ingresso right
      endif 
  


!-----  la s-sequenza e' arrivata su un nodo gia' associato ad un cluster (s-sequenza), controlla ora 3 possiblita':
!-----  la s-sequenza e' "piu' piccola" di quella del nodo, allora devo spostare la s-sequenza ad un nodo a sinistra
!-----  la s-sequenza e' "piu' grande " di quella del nodo, allora devo spostare la s-sequenza ad un nodo a destra
!-----  la s-sequenza e' "uguale"       a  quella del nodo, allora devo aggiornare gli array (per essempio dire che la grandezza del cluster deve aumentare di 1)

     if (associated (t))  then  ! se invece sono gia' stato in questo nodo                                  
        do i=1,  lung_parole    !  controlla gli elementi della sequenza passata in ingresso (da sinistra a dx in questo caso, che e' anche come noi paragoniamo numeri  
         
           if      ( s_punto(i) .lt. t % Ssequenza(i) ) then         !  se le "decine" della nuova sequenza sono piu' piccole di quella attuale 
                   call LM_inserisci (t%left,  punto_partenza)  ! inserisci la sequenza in in gresso a sinistra (ordino dal piu' picccolo al piu' grande)
                   return                                         ! questo RETURN e' importantissimo, vuol dire che non continui ad eseguire la subroutine, quindi, p.es non aggiungi 1 a quanti! 
           else if ( s_punto(i) .gt. t % Ssequenza(i) ) then         ! idem per per le sequenze maggiori 
                   call LM_inserisci (t%right, punto_partenza)
                   return  
           endif 
        enddo
!--------------- se arrivi qui, vuol dire che sei arrivato su una parola simbolica gia' trovata! (controllo comunque)
        if (all ( s_punto(:) .eq. t % Ssequenza(:)))  then 
         clusterSize_uso( t% indiceCluster)  = clusterSize_uso(t%indiceCluster)+1         
         posizioneRegistro(punto_partenza)  =  t % indiceCluster  
!-----------------------------------------------------------------------------------------
         t % quanti = t % quanti+1                                      ! se sei arrivato fino a qui, allora tutti gli ingressi della sequenza sono uguali a quello attuale, aggiungi 1 al suo numero
        endif 

     endif  ! questo controlla che il nodo sia gia' associato

!---------------------------------------       

!---------------------------------------
   end subroutine LM_inserisci






!-------------------------------------------------------------------------------
!-------------------------------------------------------------------------------


subroutine nomeSub (nome)
implicit none 
character (len=*), intent(in) :: nome 
if (verbose) then 
  !write(*,*) 
  if (trim(nome) .eq. 'MU_sax') write(*,*) nome , ', maxShuffle=', maxShuffle
  if (trim(nome) .ne. 'MU_sax') write(*,*) nome 
endif  
end subroutine nomeSub


!-------------------------------------------------------------------------------



!-------------------------------------------------------------------------------







function gauss(x)
  real (kind=8) :: gauss
  real (kind=8), intent(in) :: x
  real (kind=8), parameter  :: pi = 2* asin(1.d0)

  gauss = 1/sqrt(2*pi) * exp (-x**2) 

end function gauss
  













!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
subroutine MergeP(A,NA,B,NB,C,NC)
 
   integer, intent(in) :: NA,NB,NC         ! Normal usage: NA+NB = NC
   integer, intent(in out) :: A(3,NA)        ! B overlays C(NA+1:NC)
   integer, intent(in)     :: B(3,NB)
   integer, intent(in out) :: C(3,NC)
 
   integer :: I,J,K
 
   I = 1; J = 1; K = 1;
   do while(I <= NA .and. J <= NB)
!      if (A(I) <= B(J)) then   PA
       if ( .not. maggiore (A(:,I), B(:,J)) ) then   ! PA 
         C(:,K) = A(:,I)
         I = I+1
      else
         C(:,K) = B(:,J)
         J = J+1
      endif
      K = K + 1
   enddo
   do while (I <= NA)
      C(:,K) = A(:,I)
      I = I + 1
      K = K + 1
   enddo
   return
 
end subroutine mergeP
!------------------------------------------------------------------------------------------------

!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
recursive subroutine MergeSortP(A,N,T) !  PA ok
 
   integer, intent(in) :: N
   integer, dimension(3,N), intent(in out) :: A
   integer, dimension(3,(N+1)/2), intent (out) :: T

 
   integer :: NA,NB 

   integer , dimension(3) :: V ! PA
 
   if (N < 2) return
   if (N == 2) then
!------------------------------------PA
!      if (A(3,1) > A(3,2))            then
      if (maggiore (A (:,1) , A(:,2) ) ) then   ! PA
         V = A(:,1)
         A(:,1) = A(:,2)
         A(:,2) = V
      endif
!----------------------------------- PA

      return
   endif      
   NA=(N+1)/2
   NB=N-NA
 
   call MergeSortP(A,NA,T)
   call MergeSortP(A(:,NA+1),NB,T)   ! PA
 

!   if (A(NA) > A(NA+1)) then       PA     
   if ( maggiore (A(:,NA), A(:,NA+1) ) ) then  !PA
      T(:,1:NA)=A(:,1:NA)
      call MergeP(T,NA,A(:,NA+1),NB,A,N)
   endif
   return
 
end subroutine MergeSortP

!  necessario per fare i confronti corretti su 3za e 2da colonna ----------------------
function maggiore (A,B)   !  PA
 logical :: maggiore  
 integer, dimension(3) :: A,B
 maggiore = .false.
 if (A(3) > B(3) ) maggiore =.true.
 if (A(3) == B(3) ) then
     if (A(2) > B(2) ) maggiore = .true.
 endif 
end function maggiore

!---------------------------------------------------------------------
! provo a fare un altro mergesort in modo tale che prenda l'array
! longStat ( 1 o 2, i,j)    1 ingresso: 1 e' la posizione: x
!                                       2 e' il numero di seq nel bin: y
!  
!                           2 ingresso: i: primo bin, secondo bin, terzo bin... 
!   
!                           3 ingresso: j: indice di coda, j=1 prima coda, j=2 seconda...
!
! voglio ora un nuovo array che venga ordinato in modo tale che ci siano solo 2 ingressi
!                           
!                           1 ingresso: 1 posizione
!                                       2 numero di seq del bin
!      
!                           2 ingresso: primo bin, secondo bin, terzo bin...

! Problema: meglio mettere in nuovo array in cui ho solo le x e le y
! In questo caso ho un array, non ordinato chiamato newLongStat
!           




!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
subroutine MergePNND(A,NA,B,NB,C,NC)
 
   integer, intent(in) :: NA,NB,NC         ! Normal usage: NA+NB = NC
   integer, intent(in out) :: A(3,NA)        ! B overlays C(NA+1:NC)
   integer, intent(in)     :: B(3,NB)
   integer, intent(in out) :: C(3,NC)
 
   integer :: I,J,K
 
   I = 1; J = 1; K = 1;
   do while(I <= NA .and. J <= NB)
!      if (A(I) <= B(J)) then   PA
       if ( .not. maggioreNND (A(:,I), B(:,J)) ) then   ! PA 
         C(:,K) = A(:,I)
         I = I+1
      else
         C(:,K) = B(:,J)
         J = J+1
      endif
      K = K + 1
   enddo
   do while (I <= NA)
      C(:,K) = A(:,I)
      I = I + 1
      K = K + 1
   enddo
   return
 
end subroutine mergePNND
!-------------- versioni modificate da PA per fare il sort sulla 3 e 2 colonna dell'array cluster
recursive subroutine MergeSortPNND(A,N,T) !  PA ok
 
   integer, intent(in) :: N
   integer, dimension(3,N), intent(in out) :: A
   integer, dimension(3,(N+1)/2), intent (out) :: T

 
   integer :: NA,NB 

   integer , dimension(3) :: V ! PA
 
   if (N < 2) return
   if (N == 2) then
!------------------------------------PA
!      if (A(3,1) > A(3,2))            then
      if (maggioreNND (A (:,1) , A(:,2) ) ) then   ! PA
         V = A(:,1)
         A(:,1) = A(:,2)
         A(:,2) = V
      endif
!----------------------------------- PA

      return
   endif      
   NA=(N+1)/2
   NB=N-NA
 
   call MergeSortP(A,NA,T)
   call MergeSortP(A(:,NA+1),NB,T)   ! PA
 

!   if (A(NA) > A(NA+1)) then       PA     
   if ( maggioreNND (A(:,NA), A(:,NA+1) ) ) then  !PA
      T(:,1:NA)=A(:,1:NA)
      call MergeP(T,NA,A(:,NA+1),NB,A,N)
   endif
   return
 
end subroutine MergeSortPNND

!  necessario per fare i confronti corretti su 3za,  2da e anche 1ma colonna ----------------------
function maggioreNND (A,B)   !  PA
 logical :: maggioreNND  
 integer, dimension(3) :: A,B
 maggioreNND = .false.
 if (A(3) > B(3) ) maggioreNND =.true.
 if (A(3) == B(3) ) then
     if (A(2) > B(2) ) maggioreNND = .true.
       if (A(3) == B(3) .and. A(2) == B(2) ) then
            if ( nnd(A(1)) > nnd(B(1) ) ) maggioreNND = .true.
       endif
 endif
end function maggioreNND

!---------------------------------------------------------------------
! provo a fare un altro mergesort in modo tale che prenda l'array
















!--------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------


















!-------------------------------------------------

SUBROUTINE Bubble_Sort_long(a1,a2) ! versione modificata per fare sort di longStatTot
  REAL (kind=8), INTENT(in out), DIMENSION(:) :: a1, a2 ! a1 le x e a2 le y
  REAL (kind=8):: temp1, temp2
  INTEGER :: i, j
  LOGICAL :: swapped
 
  DO j = SIZE(a1)-1, 1, -1
    swapped = .FALSE.
    DO i = 1, j
      IF (a1(i) > a1(i+1)) THEN 
!--------- parte per le x -------------- 
        temp1 = a1(i)
        a1(i) = a1(i+1)
        a1(i+1) = temp1
!--------- parte per le y --------------
        temp2 = a2(i)
        a2(i) = a2(i+1)
        a2(i+1) = temp2
!---------------------------------------           
        swapped = .TRUE.
      END IF
    END DO
    IF (.NOT. swapped) EXIT
  END DO
END SUBROUTINE Bubble_Sort_long
!------------------------------------------------




!---------------------------------------------------------------
!---------------------------------------------------------------------
subroutine Bubble_SortP(a)
  type(dp), INTENT(in out), DIMENSION(:) :: a ! PA erano real prima
  type(dp) :: temp                            ! idem 
  INTEGER :: i, j
  LOGICAL :: swapped
 

  DO j = SIZE(a)-1, 1, -1
    swapped = .FALSE.
    DO i = 1, j
!      IF (a(i) > a(i+1)) THEN
       if (a(i)%discord > a(i+1)%discord    ) then  ! PA
        temp = a(i)
        a(i) = a(i+1)
        a(i+1) = temp
        swapped = .TRUE.
      END IF
    END DO
    IF (.NOT. swapped) EXIT
  END DO

end subroutine Bubble_SortP
!-------------------------------------------------
subroutine Bubble_SortV(a)
  type(vdp), INTENT(in out), DIMENSION(:) :: a ! PA erano real prima
  type(vdp) :: temp                            ! idem 
  INTEGER :: i, j
  LOGICAL :: swapped
 

  DO j = SIZE(a)-1, 1, -1
    swapped = .FALSE.
    DO i = 1, j
!      IF (a(i) > a(i+1)) THEN
       if (a(i)%discord > a(i+1)%discord    ) then  ! PA
        temp = a(i)
        a(i) = a(i+1)
        a(i+1) = temp
        swapped = .TRUE.
      END IF
    END DO
    IF (.NOT. swapped) EXIT
  END DO

end subroutine Bubble_SortV

!-------------------------------------------------

SUBROUTINE Bubble_Sort(a)
  REAL (kind=8), INTENT(in out), DIMENSION(:) :: a
  REAL (kind=8):: temp
  INTEGER :: i, j
  LOGICAL :: swapped
 
  DO j = SIZE(a)-1, 1, -1
    swapped = .FALSE.
    DO i = 1, j
      IF (a(i) > a(i+1)) THEN
        temp = a(i)
        a(i) = a(i+1)
        a(i+1) = temp
        swapped = .TRUE.
      END IF
    END DO
    IF (.NOT. swapped) EXIT
  END DO
END SUBROUTINE Bubble_Sort
!------------------------------------------------




!------------------------------------------------
    subroutine aggiorna_coda_discord(idisc, ianal)
    implicit none
    integer, intent(in) :: ianal, idisc 
    integer :: i, j



!--------- deve controllare subtito se ci sono valori obsoleti prima di poter uscire dalla funzione
             do i=1, size(coda_discord) ! elimina i discord OBSOLETI     
                  if ( (Tora - coda_discord(i)%posizione) > Tmax  ) then
                       coda_discord(i)%posizione = 0 
                       coda_discord(i)%discord   = 0.d0
                  endif   
                  call Bubble_SortP( coda_discord) ! riordina dal piu' piccolo al piu' grande
             enddo
!-----------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------
!------------------- qui sotto la STATISTICA fa scartare i non-outlier -------------------------------
!-----------------------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------------------
!--------------------  creo array con gli outlier vecchi ---------------------------------------
!           if ( val_discords(idisc) > Q3+ delta*IQ)   then
!             iOutVecc = iOutVecc +1 
!             vecchiOutlier ( modulo( iOutVecc, quantiVecchi) , : ) &  ! numero di vecchi outlier, lunghezza sequenze
!             = serie(pos_discords(idisc):pos_discords(idisc)+eXl*lung_parole-1)
!           endif    
!--------------------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------------------
 
!-----------------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------------
!-------------- qui sotto aggiorno la coda discord ---------------------------------------------
!-----------------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------------

           !if ( val_discords(idisc) <  Q3tot +delta*IQtot ) return ! se non e' un outlier totale togli
            if ( val_discords(idisc) <  Q3+delta*IQ .and. algoritmo.eq.'sod')  return   ! prendo in considerazione solo gli outlier statistici
                                                                                        ! quando cerco i sod
             if (ianal == 1 .and. idisc <= ncd)  then  ! se stai analizzando la prima present_queue, metti tutti i discord (fino a capienza max della coda_discord)
                coda_discord(idisc)%discord    = val_discords(idisc)
                coda_discord(idisc)%posizione  = pos_discords(idisc)  + update_period * (ianal-1)
                write(28,*) pos_discords(idisc)  + update_period * (ianal-1),  val_discords(idisc)
                call Bubble_SortP( coda_discord) ! riordina dal piu' piccolo al piu' grande
             endif


             if (ianal > 1)  then
                  if (val_discords(idisc) .gt. coda_discord(1)%discord ) then
                         coda_discord( 1 )%discord   = val_discords(idisc)
                         coda_discord( 1 )%posizione = pos_discords(idisc) + update_period * (ianal-1)
                         write(28,*) pos_discords(idisc)  + update_period * (ianal-1),  val_discords(idisc)
                         call Bubble_SortP( coda_discord) ! riordina dal piu' piccolo al piu' grande
                  endif 
             endif



1344 format ( i9, 2x, F9.4 )
             !write(*,*) coda_discord(:)%discord

    end subroutine aggiorna_coda_discord
!------------------------------------------------




!------------------------------------------------

!------------------------------------------------



subroutine deriva ! calcola la derivata I e II della serie temporale
implicit none     ! la h non ci serve
integer :: i

if (.not.allocated(Dserie)) allocate (Dserie(N) , D2serie(N) )  ! 

do i=2, N-lung_Seq+1
      Dserie(i)  = serie(i+1)- serie(i) 
     D2serie(i) = serie(i+1)- 2*serie(i) + serie(i-1)  ! controllare
     write(66,*) i , serie(i), Dserie(i), D2serie(i)
enddo
Dserie(1)=Dserie(2)
D2serie(1) =D2serie(2)






end subroutine deriva


!------------------------------------------------
!------------------------------------------------



subroutine longStatistica(idisc, ianal) ! calcola la percentuale di punti che sono piu' discordi di lui
implicit none                                                ! fino ad ora ottenuta
integer ::i, j                                  
integer , intent(in) :: ianal , idisc
integer :: n_code
real (kind =8):: CDFxOut, CDFxOut0  ! per i quartili

integer :: indice1
real (kind =8), dimension(:,:), allocatable ::longStatTot ! metto su un array 2D longStat
real (kind =8), dimension(:,:), allocatable ::longCdfTot  
integer, dimension(:,:), allocatable :: OT
logical :: cercaQ1 = .true.
real (kind = 8) :: tot, norm, tot1, tot2
integer :: n_code_attuali  ! le code si riempiono man mano, potrebbero non essere tutte piene

!---------------------------------------------------------
!-   Devo calcolare Q3 e Q1 della statistica allargata
!-   per definire meglio gli outlier 
!-   ricordo che longStat(1 , .. ,..) e' il valore del discord
!-   invece      longStat(2 , .. ,..) e' la probabilita' associata

 if (idisc.eq.1)   then   ! evita di ricalcolare Q1tot e Q3tot per tutti i discord: la statistica e' la stessa
                          ! in realta' non e' vero, gli nnd si aggiornano cercando 

   if (ianal .lt. n_code_shadow )   n_code_attuali = ianal          ! all'inizio non tutte le code sono piene
   if (ianal .ge. n_code_shadow )   n_code_attuali = n_code_shadow  ! ricordo che va da 1 a n_code_shadow

   allocate (longStatTot(2, n_code_attuali*nbin) ) ! questo e' l'unione in linea
   allocate (longCdfTot(2 , n_code_attuali*nbin) ) ! posso quindi riscriverlo ogni volta con una lu ghezza diversa

   longStatTot = 0.d0     ! azzero sia lo NND (pdf)
   longCdfTot  = 0.d0     ! che questo che contiene la cdf



!   allocate ( longStat (2,1:n_code_shadow, 0:nbin) )

!  scrivi su file (barbaro)
!   do j=1, n_code_attuali
!     do i=1, nbin
!      write(40,*) longStat(1, j,i), longStat(2, j,i)   , j, n_code_attuali
!     enddo
!      write(40,*)
!   enddo
!   close(40)

!  qui riscrivo in forma differente l'array per un sort piu' facile
   indice1=0
   do j=1, n_code_attuali
     do i=1, nbin
      indice1= indice1+1
      longStatTot(1,indice1) = longStat(1,j,i) 
      longStatTot(2,indice1) = longStat(2,j,i) 
      !write(46,*) longStatTot(1,indice1), longStatTot(2, indice1), indice1
     enddo
   enddo
!----------------------------------------------

   call Bubble_Sort_long( longStatTot(1,:), longStatTot(2,:) )  ! riordino per cercare i quartili


! crea la cdf facendo la somma
   do i=1, n_code_attuali*nbin
      longCdfTot(1,i) =     longStatTot(1,i)
      longCdfTot(2,i) = sum(longStatTot(2,1:i)) / n_code_attuali   ! la normalizzazione e' corretta o serve un +-1?
   enddo

   !do i=1, n_code_attuali*nbin
   !   write(44,*) longCdfTot(1,i)  , longCdfTot(2,i) 
   !enddo



   do i=1, n_code_attuali*nbin
      if (i.lt. n_code_attuali*nbin ) then 

           if ((longCdfTot(2,i)-0.25d0)*(longCdfTot(2,i+1)-0.25d0) .lt. 0.d0  ) Q1tot =   longCdfTot(1,i+1) 
           if ((longCdfTot(2,i)-0.75d0)*(longCdfTot(2,i+1)-0.75d0) .lt. 0.d0  ) Q3tot =   longCdfTot(1,i+1) 

      endif 
   enddo



!call MergeSortP( longStatTot, size(longStatTot), OT)

 deallocate (longStatTot, longCdfTot)

! write(*,*)  Q3tot, Q1tot
 

  IQtot = Q3tot -Q1tot


endif !
!---------------------------------------------------------

end subroutine longStatistica



!---------------------------------------------------------------------









!------------------------------------------------
      subroutine strutturaPdf(massimo, minimo)
      implicit none
      real(kind = 8),  intent(in)::massimo, minimo

      ngrande = (massimo-minimo)/bin        !  numero di elementi del binning e' un tentativo
      ngrande_max  = (N-lung_seq+1)*10      !  mediamente c'e' un  pto per binning

      if (ngrande_min.gt.ngrande) then
          ngrande = ngrande_min
          bin =  ( (massimo-minimo)*1.d0 )/ ngrande
      endif

      if (ngrande.gt.ngrande_max) then
          ngrande = ngrande_max
          bin =  ( (massimo-minimo)*1.d0 )/ ngrande
      endif

      !write(*,*) ngrande, '<-------------'
      !stop 'numero grande qui'  

      if (ngrande.gt.2100000000) then
            write(*,*) " prendi bin piu' grande", bin, ngrande
            stop
      endif

      end subroutine strutturaPdf

!----------------------------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------------------------------------



!---------------------------------------------------------------------------------------------------


      subroutine TricavaPdf(array, ipar)  ! faccio la pdf dei valori di un array data una grandezza di binning
      implicit none                       ! questa funziona per tutti, sia Znorm che non Znrom
      integer , intent(in) ::ipar
      real (kind=8), dimension(:) :: array

      real (kind=8) :: massimo, minimo,  k, q
      real (kind=8) :: mediaZ
      integer ::  intero, i, j


      ! qui sto facendo con le medie che NON sono Znormalizzate. Devo quindi:
      ! moltiplico per tutti i punti per lettera (in questo modo ho solo la somma dei punti)
      ! ad ogni punto tolgo la media della parola (quindi tolgo la media per eXl
      ! poi divido per la sigma. A questo punto devo dividere per i punti per lettera eXl 
      ! e ho ottenuto una media dei punti Znormalizzati
      ! quindi non devo moltiplicare ne dividere per eXl!!!
 
      massimo = -1000000000.d0                      ! numero molto piccolo, tutti gli saranno sopra
      minimo  =  1000000000.d0                      ! numero molto grande tutti gli saranno sotto 

!======================  Znorm ===============================================  
      if (Znorm) then
      do i=1, N-eXl+1 ! gira su tutti le medie: N - eXl +1  
           do j= lung_seq-1,0, -1  
              
               if (i-j.lt.1)        cycle  ! non uscire dai limiti
               if (i-j.ge.N-lung_seq+1 ) cycle

               mediaZ =   ( media(i) - val_medio(i-j) ) / dev_standard(i-j)

               if ( mediaZ .gt. massimo )  massimo =  mediaZ     
               if ( mediaZ .lt. minimo  )  minimo  =  mediaZ     

              
           enddo
      enddo 
      endif
!====================== fine Znorm ============================================
      

!====================== non ZNorm ==================================================
      if (.not.Znorm) then
      do i=1, N-eXl+1 ! gira su tutti le medie: N - eXl +1  

               mediaZ =  media(i) 

               if ( mediaZ .gt. massimo )  massimo =  mediaZ     
               if ( mediaZ .lt. minimo  )  minimo  =  mediaZ                   
      enddo
      endif 
!====================== fine non ZNorm =============================================




      call strutturaPdf(massimo, minimo)           ! definisci ngrande e bin, che definiscono il numero di punti della pdf, xpos, cdf e ncdf

      if (.not.allocated(pdf)) &                   ! non farlo 2 volte
      allocate (pdf (0:ngrande+1), xpos (0:ngrande+1), cdf(0:ngrande+1) , ncdf(0:ngrande+1) )                ! numero di punti in cui binno 

      pos_lett(1) = minimo           ! estremi del parametro da cui estrarre le lettere
      pos_lett(num_simboli) = massimo 


      k        =  1.d0/bin                     ! scelgo che il punto piu' piccolo vada in bin/2 
      q        =  bin /2.d0 - minimo/bin       ! il punto piu' grande in N + bin/2
      pdf      = 0
  

      do i=1, N- eXl +1
        do j= lung_seq-1,0,-1

           if (i-j.lt.1)        cycle  ! non uscire dai limiti
           if (i-j.ge.N-lung_seq+1 ) cycle

           if (Znorm) mediaZ = ( media(i) - val_medio(i-j) ) / dev_standard(i-j)
           if (.not.Znorm) mediaZ = media(i)

           intero = mediaZ  * k +q              ! associo un intero al valore dell'array
           pdf( intero  ) =  pdf ( intero) +1    ! aggiungo un valore all'intervallo
        enddo 
      enddo        

      do i=1, ngrande
        xpos( i  ) =   (i*1.d0-q)/k            ! posizione
      enddo


      end subroutine TricavaPdf 




!----------------------------------------------------------------------------------------------------------------------

      subroutine ricavaPdf(array, ipar)  ! faccio la pdf dei valori di un array data una grandezza di binning
      implicit none
      integer , intent(in) ::ipar
      real (kind=8), dimension(:) :: array

      real (kind=8) :: massimo, minimo,  k, q
      integer ::  intero, i

      !character ( len = 40 ) :: nomefile
      ! nomefile =  "./files/pdf." // trim(nomiPar(ipar))
      ! open(unit=400, file=nomefile)
 
      massimo  = maxval(array)                     ! valore massimo del parametro 
      minimo   = minval(array)                     ! valore minimo  del parametro


      call strutturaPdf(massimo, minimo)           ! definisci ngrande e bin, che definiscono il numero di punti della pdf, xpos, cdf e ncdf


      if (.not.allocated(pdf)) &                   ! non farlo 2 volte
      allocate (pdf (0:ngrande+1), xpos (0:ngrande+1), cdf(0:ngrande+1) , ncdf(0:ngrande+1) )                ! numero di punti in cui binno 

      pos_lett(1) = minimo           ! estremi del parametro da cui estrarre le lettere
      pos_lett(num_simboli) = massimo 


      k        =  1.d0/bin                     ! scelgo che il punto piu' piccolo vada in bin/2 
      q        =  bin /2.d0 - minimo/bin       ! il punto piu' grande in N + bin/2
      pdf      = 0
  
      do i=1, size(array)
         intero = array(i) * k +q              ! associo un intero al valore dell'array
         pdf( intero  ) =  pdf ( intero) +1    ! aggiungo un valore all'intervallo
      enddo        

      do i=1, Ngrande
        xpos( i  ) =   (i*1.d0-q)/k            ! posizione
      enddo

!-------------------------------------------------
!      call ricavaCdf (ipar)
!-------------------------------------------------


      end subroutine ricavaPdf 

!----------------------------------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------------------------------
!-------------------------------------------------------------------------




!----------------------------------------------------------------------------------------------------------------------


      subroutine ricavaCdf (ipar)  !ottieni la cdf dalla pdf 
      implicit none
      integer, intent(in) :: ipar
      integer :: grandezza, i,j, contatore, inizio
      real (kind = 8) :: norm, q, k
      real (kind = 8) :: minimo,  coeffcdf 

      norm = sum(pdf)*1.d0  
      grandezza = size(pdf)
 
      minimo = minval(serie)


      k        =  1.d0/bin                     ! scelgo che il punto piu' piccolo vada in bin/2 
      q        =  bin /2.d0 - minimo/bin       ! il punto piu' grande in N + bin/2



!============== nuova  ============================
    !!  cdf = 0  
      cdf(0) = pdf(0) 
      do i=1, grandezza-1 
        cdf(i) = ( cdf(i-1) + pdf(i) ) 
      enddo
      cdf = cdf/norm
      ncdf= 10000* cdf                             ! versione intera della cfg
!============= fine nuova =========================

!=============== vecchia e lenta =============
    !  do i=0, grandezza-1 
    !     cdf(i) = sum(pdf(0:i) ) / norm 
    !    ncdf(i) = 10000 * cdf(i)               ! costruisco versione intera della cdf
    !  enddo
!============== fine vecchia e lenta =========

    ! do i=1,ngrande
    !   write(34,*)i, ncdf(i), 'vecchia' 
    ! enddo
 


      end subroutine ricavaCdf 

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------

     subroutine intervalli_simboli(ipar)  ! qui si trovano le posizioni sull'asse delle x della cdf
     implicit none                        ! dove finisce ogni simbolo. In questo modo, posso poi costruire
     real (kind= 8) :: coeffcdf           ! nella prossima subroutine le parole simboliche associate alle r-sequence
     integer :: contatore , inizio, i, j
     integer :: grandezza
     integer :: ipar 
      character ( len = 40 ) :: nomefile


      nomefile =  "./files/dove-lettere." // trim(nomiPar(ipar))
      open(unit=33, file=nomefile)

! ----- qui sotto trovo le posizioni, sull'intervallo dei valori del parametro, dove devo 
!       dividere per ottenere delle lettere simboliche approssimativamente della stessa probabilita'
!       occhio che le probabilita' delle singole lettere non sono esattamente le stesse! 


      coeffcdf = 1.d0/num_simboli  
      grandezza = size (pdf) 

      contatore = 0
      inizio = 1 

      do i=0, grandezza-1                             ! gira su tutte le posizioni possibili nella cdf
       do j=inizio, num_simboli                       ! gira su tutti i simboli
          if (  (ncdf(i)- coeffCdf*j*10000) * (ncdf(i)-coeffCdf*(j+1)*10000) .lt.0    ) then  ! gli intervalli non sono esatti, quindi cerco un intorno. Ho moltiplicato per 10000
             inizio = j+1                             ! la prossima volta cerca dal simbolo successivo
             contatore = contatore+1                  ! numero di simboli trovati
             pos_lett(contatore) = xpos(i)            ! fermo per parola simbolica, con alfabeto da 10 (il contatore dovrebbe fermarsi a 10)
             write(33, *) contatore , pos_lett(contatore), ncdf(i), cdf(i), xpos(i)
             exit
         endif 
       enddo
      enddo 
 
      close(33)

     end subroutine intervalli_simboli


!----------------------------------------------------------------------------------
     function cdfnorm(x)  ! cdf della gaussiana normalizzata secondo
!https://www.quora.com/How-do-I-find-the-CDF-of-Gaussian-distribution
     real (kind=8) :: cdfnorm
     real (kind=8), intent(in):: x

     cdfnorm =       0.5d0 + 0.5d0 * erf(x/sqrt(2.d0))

     end function cdfnorm



!-------------------------------------------------------------------------

     subroutine Gauss_intervalli_simboli(ipar)  ! qui si trovano le posizioni sull'asse delle x della cdf
     implicit none                        ! dove finisce ogni simbolo. In questo modo, posso poi costruire
     real (kind= 8) :: coeffcdf           ! nella prossima subroutine le parole simboliche associate alle r-sequence
     integer :: contatore , inizio, i, j
     integer :: grandezza
     integer :: ipar 
     real (kind=8) :: x, dx =0.001 , sq2=sqrt(2.d0)
      character ( len = 40 ) :: nomefile




      nomefile =  "./files/dove-lettere." // trim(nomiPar(ipar))
      !open(unit=33, file=nomefile)

! ----- qui sotto trovo le posizioni, sull'intervallo dei valori del parametro, dove devo 
!       dividere per ottenere delle lettere simboliche approssimativamente della stessa probabilita'
!       occhio che le probabilita' delle singole lettere non sono esattamente le stesse! 


      coeffcdf = 1.d0/num_simboli  
      grandezza = size (pdf) 

      contatore = 0
      inizio = 1 

      do i=-10000, 10000                                ! gira su tutte le posizioni possibili nella cdf
       x = i*dx                
       do j=inizio, num_simboli                       ! gira su tutti i simboli
          if (  ( (cdfnorm(x)- coeffCdf*j*1.d0) * (cdfnorm(x)-coeffCdf*(j+1)*10000.d0)) .lt.0.d0    ) then  ! gli intervalli non sono esatti, quindi cerco un intorno. Ho moltiplicato per 10000
             inizio = j+1                             ! la prossima volta cerca dal simbolo successivo
             contatore = contatore+1                  ! numero di simboli trovati
             pos_lett(contatore) = x            ! fermo per parola simbolica, con alfabeto da 10 (il contatore dovrebbe fermarsi a 10)
             write(56, *) contatore , pos_lett(contatore), cdfnorm(x)
             exit
         endif 
       enddo
      enddo 
 
      !close(33)


      !stop 'gddfg'

     end subroutine Gauss_intervalli_simboli
!--------------------------------------------------------------------------------------------




!--------------------------------------------------------------------------------------------

     subroutine da_media_a_simbolo(array, ipar)  ! trova la squenza simbolica dell'array dato in input
     implicit none                               ! occhio che la lunghezza simbolica e' quasi lunga quanto l'array stesso 
     integer, intent(in) :: ipar                 ! con uno scanning si ottiene 1ma media con p.es punti da 1 a 4, seconda 
     real (kind=8), dimension(:) :: array        ! media con punti da 2 a 5, etc... 
     integer :: i, j, inizio, fine

     seq_simb      = 0                           ! i simboli sono numeri in realta'! azzero i simboli

     fine = size (array)
     inizio = 1
     do i=1, fine                                ! gira su quasi tutto l'array  
        do j=1, num_simboli-1                    ! gira su tutte le possibili lettere che vanno da 0 a num_simboli-1
          if     ( array(i) .gt. pos_lett(j)  .and.  &
                   array(i) .le. pos_lett(j+1)  ) then 
                    seq_simb(i) = j                                  ! lettere associate ad ogni valore della serie temporale
                    if (array(i) .eq. pos_lett(1) )  seq_simb(i) = 1 ! caso speciale del minimo   
                    exit
          endif                     
        enddo
     enddo
   
     ! Quindi in pratica ad ogni punto della r-sequence ho associato un simbolo


     end subroutine da_media_a_simbolo
!--------------------------------------------------------------------------------------------




     subroutine ksimb_qsimb(array)
     implicit none
     real(kind=8), dimension(:) :: array
     integer :: inizio, fine
     real (kind=8):: massimo, minimo

     ! faccio trasformazione lineare e divido in intervalli equispaziati
     massimo = maxval(array)
     minimo  = minval(array)

     ksimb =    num_simboli*1.d0/(massimo-minimo)
     qsimb =    (-1.d0) * minimo*ksimb
      

     end subroutine ksimb_qsimb









!--------------------------------------------------------------------------------------------
     subroutine medie_varianze ! questa subroutine calcola il valore medio e la varianza di ogni    
     implicit none             ! sequenza all'interno della serie e le mette in un array
     integer :: i, j
     if (allocated ( val_medio) )  deallocate ( dev_standard,val_medio) 
       allocate(val_medio(N-lung_seq+1), dev_standard(N-lung_seq+1) )   
         

!----- per Z-normalization calcola valor medio di ogni sequenza -----------------
     val_medio = 0.d0
     val_medio(1)= sum( serie(1:lung_seq) )
     do i=2, N-lung_seq+1
        val_medio(i) = val_medio(i-1) + serie(i+lung_seq-1) - serie(i-1)  ! tolgo primo pezzo, aggiungo l'ultimo
     enddo 

     val_medio = val_medio/ lung_seq

!----- ora calcola la deviazione standard di ogni sequenza ----------------------
     dev_standard = 0.d0 
     do i=1,N-lung_seq+1
       do j=1, lung_seq
          dev_standard(i)  = dev_standard(i) + (serie(i+j-1)-val_medio(i))**2 
       enddo   
     enddo
!----------------  usata fino alla versione 144 -------------------
!     dev_standard = dev_standard / (lung_seq-1)  ! dividi per lung_seq-1 perche' e' un sample della popolazione
!------------------------------------------------------------------
!---------------- versione corretta secondo me, e che coincide con i valori ottenuti con SCAMP di Keogh
     dev_standard = dev_standard /  lung_seq  ! dividi per lung_seq-1 perche' e' un sample della popolazione
!------------------------------------------------------------------------------------------------------

     
     dev_standard = sqrt( dev_standard ) 

     end subroutine medie_varianze 

!--------------------------------------------------------------------------------- 

     subroutine MU_allocca_inizializza
     implicit none

     if(.not.allocated(r_punto)) allocate (r_punto(lung_parole*maxShuffle) )  ! r_punto associati alla sequenza che comincia in "punto_partenza"
     if(.not.allocated(s_punto)) allocate (s_punto(lung_parole*maxShuffle) )   

     if (allocated(clusterSize_uso) ) deallocate(clusterSize_uso)
     allocate (clusterSize_uso (N-lung_seq+1)) ! al piu' posso avere un cluster per ogni sequenza 

     clusterSize_uso= 0                   ! 
     posizioneRegistro = 0
     registro_prima_osservazione =  0   
     indiceParole = 0  ! all'inizio ci sono 0 cluster, devo trovarli, qui sotto calcola quanti sono

     if (.not.allocated(media)) allocate (media( N-eXl+1) )      

     end subroutine MU_allocca_inizializza  

!--------------------------------------------------------------------------------------

!---------------------------------------------------------------------------------
     subroutine LM_allocca_inizializza
     implicit none

     if(.not.allocated(r_punto)) allocate (r_punto(lung_parole) )  ! r_punto associati alla sequenza che comincia in "punto_partenza"
     if(.not.allocated(s_punto)) allocate (s_punto(lung_parole) )   

     if (allocated(clusterSize_uso) ) deallocate(clusterSize_uso)
     allocate (clusterSize_uso (N-lung_seq+1)) ! al piu' posso avere un cluster per ogni sequenza 

     clusterSize_uso= 0                   ! 
     posizioneRegistro = 0
     registro_prima_osservazione =  0   
     indiceParole = 0  ! all'inizio ci sono 0 cluster, devo trovarli, qui sotto calcola quanti sono

     if (.not.allocated(media)) allocate (media( N-lung_seq+1) )      

     end subroutine LM_allocca_inizializza  

!--------------------------------------------------------------------------------------

     subroutine LM_deallocca_e_alloccaCS   
 
     if (allocated(clusterSize) ) deallocate(clusterSize) 
     allocate (clusterSize(indiceParole) )   ! trovate da inserisci qui sopra 
     clusterSize = clusterSize_uso(1:indiceParole)    
 
     deallocate(clusterSize_uso) 

     end subroutine LM_deallocca_e_alloccaCS   

!---------------------------------------------------------------------------------

subroutine LM_crea_seq_simboliche (punto_partenza) !LM = low memory usage
implicit none                                      ! sia Znormalized che non Znromalized
integer, intent(in) :: punto_partenza
real (kind = 8) :: r_punto_znorm
integer :: i, j, k
        
        do k=1, lung_parole           ! gira sulla r-sequenza     

        if (Znorm ) &
        r_punto_znorm = ( r_punto(k)/eXl -  val_medio(punto_partenza) ) / dev_standard(punto_partenza)  !  

        if (.not.Znorm )  r_punto_znorm =  r_punto(k)/eXl  

          do j=1, num_simboli-1       ! gira su tutte i possibili simboli che vanno da 0 a num_simboli-1
       
!--------------------------------------------------------------------------------
!--------------------------------------------------------------------------------
              if (r_punto_znorm .lt. pos_lett(1) )  then 
                      s_punto(k) = 1
                      exit
              endif 
               
              if (r_punto_znorm .ge. pos_lett(j) .and. &
                  r_punto_znorm .lt. pos_lett(j+1) )  then 
                      s_punto(k) = j+1
                      exit
              endif 
          
              if (r_punto_znorm .ge. pos_lett(num_simboli-1) ) then 
                   s_punto(k) = num_simboli
                   exit
              endif 
!--------------------------------------------------------------------------------
!--------------------------------------------------------------------------------
          enddo
        enddo


       ! write(60,1990) punto_partenza , (s_punto(j),j=1, lung_parole) 
!1990 format(5i4)
       ! write(61,1991) punto_partenza , (r_punto(j),j=1, lung_parole) 
!1991 format(i6, 4F10.6)
         

end subroutine LM_crea_seq_simboliche

!----------------------------------------------------------------------------
subroutine MU_crea_seq_simboliche (punto_partenza) ! qui traformo gli r-punto in s-punto
implicit none                                       ! in modo che comprendano tutti gli r_punti
integer, intent(in) :: punto_partenza ! visto che creo varie versioni di r-punti (maxShuffle)
real (kind = 8) :: r_punto_znorm      ! lung_parole -> lung_parole *maxShuffle 
integer :: i, j, k                    ! sia Znorm che non Znorm
character (len=10) :: ql              ! quante lettere ci sono in formato carattere (p.es da 3 "numerico) a 3 "carattere"
character (len=100) :: formato
        
        do k=1, lung_parole *maxShuffle          ! gira sulla r-sequenza     
         
         if (Znorm) &
         r_punto_znorm = ( r_punto(k)/eXl -  val_medio(punto_partenza) ) / dev_standard(punto_partenza)  !  

         if (.not.Znorm) r_punto_znorm =  r_punto(k)/eXl

          do j=1, num_simboli-1       ! gira su tutte i possibili simboli che vanno da 0 a num_simboli-1
       
!--------------------------------------------------------------------------------
!--------------------------------------------------------------------------------
              if (r_punto_znorm .lt. pos_lett(1) )  then 
                      s_punto(k) = 1
                      exit
              endif 
               
              if (r_punto_znorm .ge. pos_lett(j) .and. &
                  r_punto_znorm .lt. pos_lett(j+1) )  then 
                      s_punto(k) = j+1
                      exit
              endif 
          
              if (r_punto_znorm .ge. pos_lett(num_simboli-1) ) then 
                   s_punto(k) = num_simboli
                   exit
              endif 
!--------------------------------------------------------------------------------
!--------------------------------------------------------------------------------
          enddo
        enddo


!write(ql,'(i8)') lung_parole
!formato  = "'(" // trim(adjustl(ql)) // "A10)'" 
!write(*,*) formato
!stop 'fsd'
!1990 format(formato)


       !write(60,1990) punto_partenza , (s_punto(j),j=1, lung_parole) 

1990 format (i6, 4i4)
       ! write(61,1991) punto_partenza , (r_punto(j),j=1, lung_parole) 
!1991 format(i6, 4F10.6)
         

end subroutine MU_crea_seq_simboliche


!----------------------------------------------------------------------------
     subroutine MU_mezza_media                     ! non prendo la media per una lettera, ma solo
     implicit none                                 ! su mezza lettera. A questo punto combinero'
                                                   ! in modi differenti le mezze lettere testa+coda.   
                                                   ! Alla fine avro' varie clusterizzazioni 
     integer :: i

    if (.not.allocated(mezzaMedia)) allocate (mezzaMedia (N-eXl/2+1)) 

   
    if (eXl.eq.1) mezzaMedia = serie/2 ! dovrebbe fare la media su MEZZA lettera, se eXl=1 la lettera contiene solo 1 punto
                ! quindi l'equivalente deve essere mezzo punto.  

    if (eXl.gt.1 ) then 
     ! ATTENTO queste non sono delle vere mezze medie, perche' non divido per eXl/2
     mezzaMedia(1) = sum(serie(1  :   eXl/2  )) ! la prima "mezza" media

     !le seguenti mezze medie sono ottenuti in successione dal primo
     do i=2,N-eXl/2+1  ! il punto 1 e' gia' fatto, la fine e' data da N - l'ultima mezza media +1
          mezzaMedia(i) =   mezzaMedia(i-1) & 
                - serie(i     -1       ) &  ! togli primo punto precedente
                + serie(i   +eXl/2-1   )    ! aggiungi nuovo ultimo punto corrente  
     enddo
    endif 




     end subroutine MU_mezza_media ! a questo punto ho tutte le mezze medie.
!----------------------------------------------------------------------------

!----------------------------------------------------------------------------
     subroutine MU_unisci_teste_code(punto_partenza)    ! non prendo la media per una lettera, ma solo
     implicit none                                 ! su mezza lettera. A questo punto combinero'
                                                   ! in modi differenti le mezze lettere testa+coda.   
                                                   ! Alla fine avro' varie clusterizzazioni 
     real(kind=8) :: testa, coda
     integer :: i, j, k, indice 
     integer, intent(in) :: punto_partenza
     real (kind=8), dimension(:,:), allocatable :: r_punto_mu

     allocate (r_punto_mu(lung_parole, maxShuffle))

     !k=1
     ! ATTENZIONE NON NORMALIZZO QUI GLI R_PUNTO, viene fatto nella subroutine dove vengono trasf in s_punto
     !do i=1, lung_parole  !giro sulle mezze medie di una parola sono 2*lung_parole
     !write(58,*) punto_partenza + (ordineTesteCode(2*i-1 ,k)-1)*eXl/2, & 
     !            punto_partenza + (ordineTesteCode(2*i   ,k)-1)*eXl/2
   !r_punto(i) =   mezzaMedia ( punto_partenza + (ordineTesteCode(2*i-1 ,k)-1)*eXl/2 ) & ! testa   
    !           +  mezzaMedia ( punto_partenza + (ordineTesteCode(2*i   ,k)-1)*eXl/2 )   ! coda   
     !enddo  

     
! qui sotto costruisco varie versioni (maxShuffle) di r_punto, nel ciclo successivo le metto una 
! dietro l'altra
    do k=1,maxShuffle
     do i=1, lung_parole  !giro sulle mezze medie di una parola sono 2*lung_parole
   r_punto_mu(i,k) =   mezzaMedia ( punto_partenza + (ordineTesteCode(2*i-1 ,k)-1)*eXl/2 ) & ! testa   
               +  mezzaMedia ( punto_partenza + (ordineTesteCode(2*i   ,k)-1)*eXl/2 )   ! coda   
     enddo 
    enddo  
    
   ! ATTENZIONE NON NORMALIZZO QUI GLI R_PUNTO, viene fatto nella subroutine dove vengono trasf in s_punto
    do k=1, maxShuffle
     do i=1,lung_parole
      indice = i+ (k-1)*lung_parole   ! li metto tutti in fila 
      r_punto( indice  )  = r_punto_mu(i,k)
     enddo
    enddo

    if (.not.risparmiaMemoria) then 
      write(70,*) (r_punto(j), j=1, size(r_punto)) 
    endif

     deallocate(r_punto_mu)

     end subroutine MU_unisci_teste_code
!----------------------------------------------------------------------------



!----------------------------------------------------------------------------
     subroutine MU_shuffle_teste_code ! questo costruisce vari ri-ordini di teste e code
     implicit none                    ! in modo che si possanmo costruire parole simboliche variate
     integer :: i, j, k
     integer , dimension(12) :: iseme        ! seme per random number generator
     integer :: uso
     real (kind=8) :: u     
 
      if (allocated(ordineTesteCode)) deallocate (ordineTesteCode)
      allocate (ordineTesteCode(2*lung_parole, maxShuffle)) ! deve contenere sia teste che code di tutte le lettere di una parola simbolica 

      do i=1,  2*lung_parole  ! costruisco delle mezze medie, ce ne sono quindi 2*lung_parole
       ordineTesteCode(i,:)=i ! all'inizio sono tutti in ordine
      enddo

      if (maxShuffle.gt.1) then         !se maxShuffle=1, allora copia LM_sax e non riordinare le mezze medie 
      iseme = 0
      if (useRandomSeed)  call date_and_time(values=iseme)  ! seme per generatore casuale
      call random_seed(put=iseme)       !
      
      do k=1, maxShuffle                ! gira su tutti i riordini
        do i=2*lung_parole, 1, -1       ! riordina a random le mezze medie che poi verranno appiccicate con 
            if (i.eq.0) cycle           ! questo ordine
            call random_number(u)
            j = FLOOR(i*u)              ! scelgo numero intero 0<= j<= i
            if (j.eq. 0) j=1    
            uso =  ordineTesteCode(i,k) ! faccio swap tra i e j 
            ordineTesteCode(i,k) = ordineTesteCode(j,k)  
            ordineTesteCode(j,k) = uso   
        enddo
      enddo 

      endif  


      do k=1,maxShuffle
        write(57,*)  (ordineTesteCode(i,k), i=1,2*lung_parole)
      enddo 

     end subroutine MU_shuffle_teste_code

!----------------------------------------------------------------------------


     subroutine LM_ricavaPdf ! costruisce le pdf degli rpunti, sia Znorm che non Znorm
     implicit none 
     integer :: i, j
     real (kind = 8) :: massimo=  - 1e12
     real (kind = 8) :: minimo=    1e12
     real (kind = 8) :: maxqui, minqui
     integer :: intero 
     real (kind = 8) :: k, q, mediaz
  
     do  i=1, N-lung_seq+1
        call LM_R_sequence(i)   ! costruisce r_punto

        if (Znorm) then      ! Znromazlizzato        
          maxqui = maxval ( ( r_punto(:)/eXl - val_medio(i))/dev_standard(i) )  ! gli r_punti sono "lung_parole"
          minqui = minval ( ( r_punto(:)/eXl - val_medio(i))/dev_standard(i) ) 
        endif 

        if (.not.Znorm) then              
          maxqui = maxval (  r_punto(:)/eXl  )  ! gli r_punti sono "lung_parole"
          minqui = minval (  r_punto(:)/eXl  ) 
        endif 

        if ( maxqui .gt. massimo)  massimo = maxqui
        if ( minqui .lt. minimo)  minimo = minqui

     enddo

      call strutturaPdf(massimo, minimo)           ! definisci ngrande e bin, che definiscono il numero di punti della pdf, xpos, cdf e ncdf

      if (.not.allocated(pdf)) &                   ! non farlo 2 volte
      allocate (pdf (0:ngrande+1), xpos (0:ngrande+1), cdf(0:ngrande+1) , ncdf(0:ngrande+1) )                ! numero di punti in cui binno 

      pos_lett(1) = minimo           ! estremi del parametro da cui estrarre le lettere
      pos_lett(num_simboli) = massimo 


      k        =  1.d0/bin                     ! scelgo che il punto piu' piccolo vada in bin/2 
      q        =  bin /2.d0 - minimo/bin       ! il punto piu' grande in N + bin/2
      pdf      = 0
  
      !write(*,*)minimo, massimo

      do i=1, N- lung_seq +1
        call LM_R_sequence(i)
        do j=1,lung_parole
         if (Znorm)      mediaZ = ( r_punto(j)/eXl - val_medio(i) ) / dev_standard(i)
         if (.not.Znorm) mediaZ =  r_punto(j)/eXl 

           intero = mediaZ  * k +q              ! associo un intero al valore dell'array
           !write(77,*) i,j, intero, mediaZ  
           !write(*,*) i,j, intero , mediaZ, massimo, minimo
           pdf( intero  ) =  pdf ( intero) +1    ! aggiungo un valore all'intervallo

        enddo  

      enddo        

      do i=1, ngrande
        xpos( i  ) =   (i*1.d0-q)/k            ! posizione
      enddo
 
     end subroutine LM_ricavaPdf
!----------------------------------------------------------------------------


!----------------------------------------------------------------------------


     subroutine lm_ricavaPdf_new ! costruisce le pdf degli rpunti, sia Znorm che non Znorm
     implicit none               ! idea, a me serve solo la cdf. Ordino tutti gli r-punti
     integer :: i, j             ! dal piu' piccolo al piu' grande.  Divido l'intervallo in  
     real (kind = 8) :: massimo=  - 1e12  ! in 1000 parti e aggiungo 1 ogni volta che un punto 
     real (kind = 8) :: minimo=    1e12   ! va nell'intervallo
     real (kind = 8) :: maxqui, minqui    ! 
     integer :: intero 
     real (kind = 8) :: k, q, mediaz


!---------------  cerca massimo e minimo tra gli rpunti -------------------- 
     do  i=1, N-lung_seq+1
        call LM_R_sequence(i)   ! costruisce r_punto

        if (Znorm) then      ! Znromazlizzato        
          maxqui = maxval ( ( r_punto(:)/eXl - val_medio(i))/dev_standard(i) )  ! gli r_punti sono "lung_parole"
          minqui = minval ( ( r_punto(:)/eXl - val_medio(i))/dev_standard(i) ) 
        endif 

        if (.not.Znorm) then              
          maxqui = maxval (  r_punto(:)/eXl  )  ! gli r_punti sono "lung_parole"
          minqui = minval (  r_punto(:)/eXl  ) 
        endif 

        if ( maxqui .gt. massimo)  massimo = maxqui
        if ( minqui .lt. minimo)   minimo  = minqui

     enddo
!-------------- fine ricerca massimo ----------------------------------------


      bin = abs(massimo - minimo )/1e6  ! costruisco la pdf in 1 000 000 punti   
      ngrande       = 1e6                     !


      if (.not.allocated(pdf)) &                   ! non farlo 2 volte
      allocate (pdf (0:ngrande+1), xpos (0:ngrande+1), cdf(0:ngrande+1) , ncdf(0:ngrande+1) )                ! numero di punti in cui binno 

      pos_lett(1) = minimo           ! estremi del parametro da cui estrarre le lettere
      pos_lett(num_simboli) = massimo 


      
      k        =  1.d0/bin                     ! scelgo che il punto piu' piccolo vada in bin/2 
      q        =  bin /2.d0 - minimo/bin       ! il punto piu' grande in N + bin/2
      pdf      = 0
  


      do i=1, N- lung_seq +1
        call LM_R_sequence(i)
        do j=1,lung_parole
         if (Znorm)      mediaZ = ( r_punto(j)/eXl - val_medio(i) ) / dev_standard(i)
         if (.not.Znorm) mediaZ =  r_punto(j)/eXl 

           intero = mediaZ  * k +q              ! associo un intero al valore dell'array
           pdf( intero  ) =  pdf ( intero) +1    ! aggiungo un valore all'intervallo

        enddo  

      enddo        

      do i=1, ngrande
        xpos( i  ) =   (i*1.d0-q)/k            ! posizione
      enddo
 
     end subroutine lm_ricavaPdf_new
!----------------------------------------------------------------------------





!----------------------------------------------------------------------------
     subroutine LM_R_sequence_composta(punto_partenza)  ! costruiso r_sequence che comincia in punto_partenza
     implicit none                             ! tengo in memoria questa r_sequence per il prossimo
     integer , intent(in) :: punto_partenza    ! punto. LM =  low memory usage, non tengo piu' in mem   
     integer :: i , j                          ! tutte le S-sequence
     
     !static :: r_punto 
     real (kind = 8) :: valore_medio_sequenza, dev_standard_sequenza

     !ATTENTO, questi non sono veramente gli R-punti perche' non divido per eXl!!! 
     ! ma lo tengo cosi' perche' e' piu' facile costruirli

     ! crea gli r-punti assicuati alla prima parola
     if (punto_partenza.eq.1)  then  ! gli r-punti della prima sequenza
       do i=1, lung_parole           ! gira sul numero di lettere di una parola
          r_punto(i) = sum(serie(1 + (i-1)*eXl  :   eXl + (i-1)*eXl  ))  ! questo crea gli r-punti della seq che comincia in punto_partenza    
       enddo                                                            ! occhio che non divido ORA per eXl
     endif

     
     ! i seguenti r-punti sono ottenuti in successione dal primo
     if (punto_partenza.gt.1) then  ! gli r-punti delle sequenza successve, basta togliere un valore e aggiungere 
        do i=1, lung_parole         ! quello dopo
          r_punto(i) = r_punto(i) - serie(punto_partenza     -1   + (i-1)*eXl ) & 
                                  + serie(punto_partenza   +eXl-1  +(i-1)*eXl)     
        enddo                                                    

     endif      

     media(punto_partenza) = r_punto(1) / eXl  ! server per i breakpont non gaussiani
  
     end subroutine LM_R_sequence_composta


!----------------------------------------------------------------------------
     subroutine LM_R_sequence(punto_partenza)  ! costruiso r_sequence che comincia in punto_partenza
     implicit none                             ! tengo in memoria questa r_sequence per il prossimo
     integer , intent(in) :: punto_partenza    ! punto. LM =  low memory usage, non tengo piu' in mem   
     integer :: i , j                          ! tutte le S-sequence
     
     !static :: r_punto 
     real (kind = 8) :: valore_medio_sequenza, dev_standard_sequenza

     !ATTENTO, questi non sono veramente gli R-punti perche' non divido per eXl!!! 
     ! ma lo tengo cosi' perche' e' piu' facile costruirli

     ! crea gli r-punti assicuati alla prima parola
     if (punto_partenza.eq.1)  then  ! gli r-punti della prima sequenza
       do i=1, lung_parole           ! gira sul numero di lettere di una parola
          r_punto(i) = sum(serie(1 + (i-1)*eXl  :   eXl + (i-1)*eXl  ))  ! questo crea gli r-punti della seq che comincia in punto_partenza    
       enddo                                                            ! occhio che non divido ORA per eXl
     endif

     
     ! i seguenti r-punti sono ottenuti in successione dal primo
     if (punto_partenza.gt.1) then  ! gli r-punti delle sequenza successve, basta togliere un valore e aggiungere 
        do i=1, lung_parole         ! quello dopo
          r_punto(i) = r_punto(i) - serie(punto_partenza     -1   + (i-1)*eXl ) & 
                                  + serie(punto_partenza   +eXl-1  +(i-1)*eXl)     
        enddo                                                    

     endif      

     media(punto_partenza) = r_punto(1) / eXl  ! server per i breakpont non gaussiani
  
     end subroutine LM_R_sequence


!----------------------------------------------------------------------------
     subroutine R_sequence(array)  ! faccio una media mobile della serie numerica
     implicit none                         ! 
     real (kind=8), dimension(:) :: array
     integer :: i,   fine
     integer :: k ,j

     fine = N - eXl +1      ! per fare la media su eXl lettere non posso andare fino in fondo

     if (allocated ( sequenze_ristrette) )  deallocate ( media, sequenze_ristrette, sequenze_simboliche, dev_standard,val_medio) 
  
     if (.not.allocated(media))  allocate (media( fine) )                              ! allocca array con tutte le medie!  la parola al posto i e' costituita da: media (i), media(i+eXl), media(i+2*eXl), ...
       allocate (sequenze_ristrette     ( N, lung_parole) )  ! il primo ingresso dice dove comincia la R_sequence, il secondo ci fa muovere tra i suoi punti
       allocate (sequenze_simboliche    ( N, lung_parole) )  ! il primo ingresso dice dove comincia la S_sequence, il secondo ci fa muovere tra i suoi simboli
       !allocate (mediaN (fine, eXl) )                          ! costruisco delle parole differenti 
     if (.not.allocated(val_medio))  allocate(val_medio(N-lung_seq+1), dev_standard(N-lung_seq+1) )   


!=============================================== nota che il numero di simboli e' quasi uguale
!=============================================== al numero di punti,  in quanto ogni simbolo contiene una media
! per esempio prendiamo lettere composte da 4 punti:
!----- 1234567890
!      ^--^        I media    e' anche il primo punto della prima R-sequence (che diventera' la prima lettera della I S-Sequence) 
!       ^--^      II media    
!        ^--^    III media    e' anche il prima punto della TERZA  R-sequence (che diventera' la prima lettera della III S-Sequence)
!         ^--^    IV media 
!          ^--^    V media    e' anche il secondo punto della prima R-sequence (che diventera' la seconda lettera della I S-sequence) 
!===============================================

     media = 0.d0  
     media(1) = sum(array(1:eXl))  ! primo punto  

     do i=1, fine-1  ! gira su tutte le parole possibili
          media( i+1 ) = media(i) -array(i) + array(i+eXl)  ! togli il primo elemento e aggiungi quello dopo   
     enddo

     media = media /eXl  ! abbiamo ora le lettere associate ad ogni punto
     ! per costruire le parole simboliche dobbiamo ricordarci che dobbiamo saltare da una media
     ! non alla successiva (di questo array), devono passare tanti posti quanti servono per fare
     ! una lettera! Nota altresi' che queste non sono ancora le lettere, ma solo le medie
     

!----- per Z-normalization calcola valor medio di ogni sequenza -----------------
     val_medio = 0.d0
     val_medio(1)= sum( array(1:lung_seq) )
     do i=2, N-lung_seq+1
        val_medio(i) = val_medio(i-1) + array(i+lung_seq-1) - array(i-1)  ! tolgo primo pezzo, aggiungo l'ultimo
     enddo 

     val_medio = val_medio/ lung_seq

!----- ora calcola la deviazione standard di ogni sequenza ----------------------
     dev_standard = 0.d0 
     do i=1,N-lung_seq+1
       do j=1, lung_seq
          dev_standard(i)  = dev_standard(i) + (array(i+j-1)-val_medio(i))**2 
       enddo   
     enddo
     dev_standard = dev_standard / (lung_seq-1)  ! dividi per lung_seq-1 perche' e' un sample della popolazione
     
     dev_standard = sqrt( dev_standard ) 

!--------------------------------------------------------------------------------- 


     !do i=1, N-lung_seq+1
     !   write(33,*) i, (  media(i+(j-1)*eXl),  j=1, lung_parole)
     !enddo
     !stop 'fsjihff'



! faccio altri tipi di medie (semplici), per esempio parole da 4 punti, sequenze da 12
!  123456789012|34567890
!  ............|........
!          1234 
!  4........123
!  34........12
!  234........1
!---------------|-----------
!  .........1234|
!  .4........123| 
!  .34........12|
!  .234........1|
!  Riassumendo prendo tutte le medie:
!  quella che comincia a lung_seq - eXl +1 
!  tolgo l'ultimo punto e aggiungo il punto lung_seq posti piu' indietro
!  
!  quella che comincia a lung_seq - eXl +2 
!  tolgo gli ultimi 2 punti
!  aggiungo il punto lung_seq piu' indietro e il successivo

     !mediaN = 0.d0  

     !do i=1, fine-1  ! gira su tutte le parole possibili
     !   do k=1, eXl
     !     mediaN( i+1, k ) = mediaN(i, k) -array(i-lung_seq+k) + array(i+eXl)  ! togli il primo elemento e aggiungi quello dopo   
     !   enddo
     !enddo

     end subroutine R_sequence


!----------------------------------------------------------



!----------------------------------------------------------

!--------------------------------------------------------------------


subroutine mod_Tcrea_seq_simboliche ! a mio avviso Zcrea_Seq_simboliche e' sbagliato
implicit none                       ! mette piu' simboli!!!!
integer :: i, j, k, k2


     do i=1, N-lung_seq+1             ! posso fare scanning della serie non fino al bordo per lunghezza successioni = lung_parole*eXl
        
        k2 = 0
        do k=1, lung_parole*eXl, eXl  ! gira sulla r-sequenza     
         k2= k2+1                     ! prima lettera della s-sequence, seconda, k2-esima lettera

         if (Znorm) &
         sequenze_ristrette(i,k2)      =   ( media(i+k-1) -  val_medio(i) ) / dev_standard(i)  ! 


         if (.not.Znorm) & 
         sequenze_ristrette(i,k2)      =    media(i+k-1)   ! 
 


          do j=1, num_simboli-1                    ! gira su tutte le possibili lettere che vanno da 0 a num_simboli-1
!-------------------------- come funziona---------------------------------------
!------ pos_lett(i) sono i breakpoint, i va da 1 a num_simboli-1
!------ prendiamo per esempio num_simboli=4, allora ci sono 3 breakpoint
!----------  pos_lett(1) ------ pos_lett(2) ------- pos_lett(3) --------------
!      1        |           2      |         3          |          4
! quindi tutti gli r-punti prima di pos_lett(1) hanno come lettera assiciata 1
! quelli tra i e i+1 hanno la lettera i+1
! quelli dopo pos_lett(num_simboli-1) hanno come lettera num_simboli -----------

              if (sequenze_ristrette(i,k2) .lt. pos_lett(1) )  then 
                      sequenze_simboliche(i,k2) =  1
                      exit
              endif 
               
              if ( sequenze_ristrette(i,k2) .ge. pos_lett(j) .and. &
                   sequenze_ristrette(i,k2) .lt. pos_lett(j+1) )  then 
                        sequenze_simboliche(i,k2)= j+1
                      exit
              endif 
          
              if ( sequenze_ristrette(i,k2) .ge. pos_lett(num_simboli-1) ) then 
                    sequenze_simboliche(i,k2) = num_simboli
                   exit
              endif                      
          enddo

        enddo

     enddo


end subroutine mod_Tcrea_seq_simboliche


!----------------------------------------------------------

subroutine Zcrea_seq_simboliche
implicit none
integer :: i, j, k, k2


     do i=1, N-lung_seq+1             ! posso fare scanning della serie non fino al bordo per lunghezza successioni = lung_parole*eXl
        
        k2 = 0
        do k=1, lung_parole*eXl, eXl  ! gira sulla r-sequenza     
         k2= k2+1                     ! prima lettera della s-sequence, seconda, k2-esima lettera

         !sequenze_ristrette(i,k2)      =  ( media(i+k-1) - eXl * val_medio(i) ) / dev_standard(i)  ! Z normalizzo gli r-punti
         ! spiegazione media = (x1 + x2+ ..+ xn)/eXl
         ! per fare le medie devo:  ( (x1-mu)/sigma + /(x2-mu)/sigma + .. + (xn-mu)/sigma ) / eXl    (divido perche'
         ! serve valore medio di questa quantita' 
         !                        = ( (x1+x2+..+xn)/eXl  - ( eXl * mu)/eXl ) / sigma
         !                        = (    media  - mu ) /sigma

         sequenze_ristrette(i,k2)      =   ( media(i+k-1) -  val_medio(i) ) / dev_standard(i)  ! 




          do j=1, num_simboli-1                    ! gira su tutte le possibili lettere che vanno da 0 a num_simboli-1
             if     ( sequenze_ristrette(i,k2) .gt. pos_lett(j)  .and.  &
                      sequenze_ristrette(i,k2) .le. pos_lett(j+1)  ) then 
                      sequenze_simboliche(i,k2) = j                                  ! lettere associate ad ogni valore della serie temporale
                      if (sequenze_ristrette(i,k2) .eq. pos_lett(1) )  sequenze_simboliche(i,k2) = 1 ! caso speciale del minimo   
                     exit
             endif                     
          enddo


        enddo

        !write(105,*) i, ( media(i+k-1), k=1, lung_parole*eXl, eXl) 
        !write(104,*) i, ( sequenze_ristrette(i,k2),k2=1, lung_parole), val_medio(i), dev_standard(i)
     enddo


end subroutine Zcrea_seq_simboliche


!----------------------------------------------------------
subroutine crea_seq_simboliche ! costruisco le sequenze simboliche e le R sequence
implicit none
    ! real (kind=8), dimension(:) :: array             ! la metto in un array? perche?  
     integer :: i, k, k2, fine

     fine = N- eXl +1

!=========================================
     call da_media_a_simbolo(media,1)  ! trasforma ogni media (=punti della r-sequence) in un simbolo, messi nell'array seq_simb
!=========================================

!----------- scrivi i valori della PAA  
     do i=1,fine-lung_parole*eXl-1  ! posso fare scanning della serie non fino al bordo per lunghezza successioni = lung_parole*eXl
       
        k2 =0 
        do k=1, lung_parole*eXl, eXl  ! 
         k2 = k2 + 1                                        ! indice
         sequenze_ristrette(i,k2)      =   media(i+k-1) 
         sequenze_simboliche(i,k2)     =  seq_simb(i+k-1) 
        enddo
     enddo
!---------- e mettili nelle parole reali, che poi vanno trasformate in simboliche


end subroutine crea_seq_simboliche


!----------------------------------------------------------------------------- 

     subroutine tree_trova_Cluster_size
     implicit none 
     integer :: i 
     type(node), pointer :: t   ! sempre annullare MA non nella dichiarazione!!!!!!

     t => null()            ! annulla QUI

     if (allocated(clusterSize_uso) ) deallocate(clusterSize_uso)
     allocate (clusterSize_uso (N-lung_seq+1)) ! al piu' posso avere un cluster per ogni sequenza 

     clusterSize_uso= 0                   ! 
     posizioneRegistro = 0
     registro_prima_osservazione =  0   

     indiceParole = 0  ! all'inizio ci sono 0 cluster, devo trovarli, qui sotto calcola quanti sono
     do i=1, N-lung_seq+1
         call inserisci(t,i)   ! inserisci la i-esima sequenza all'interno del tree
     enddo  

     if (allocated(clusterSize) ) deallocate(clusterSize) 
     allocate (clusterSize(indiceParole) )   ! trovate da inserisci qui sopra 
     clusterSize = clusterSize_uso(1:indiceParole)    
 
     deallocate(clusterSize_uso) 


!-------------- LEGENDA -----------------------------------------------------------
!    poszioneRegistro             input= indice di riga della serie temporale della parola;    OUPTUT= posizione nel registro della parola  
!    registro_prima_osservazione  input= indice di ritrovamento parole nuove              ;    OUTPUT= posizione nella serie temporale della parola  
!    clusterSize                  input= indice di ritrovamento parole nuove              ;    OUTPUT= numero di parole trovate
!    seq_simb                     input= indice di riga della serie temporale             ;    OUTPUT= simbolo associato a quell'ingresso 
!    nota che in questo caso il registro non e' necessario: abbiamo la posizione di primo ritrovamento, se voglio sapere 
!    a quale parola simbolica corrisponde, uso da 
!        seq_simb(registro_prima_osservazione(i))                   = primo simbolo   (della s-sequenza associata alla sequenza iniziante in i)
!        seq_simb(registro_prima_osservazione(i+eXl))               = secondo simbolo
!                         ...
!        seq_simb(registro_prima osservazione(i+eXl*(lung_parole-1) = ultimo simbolo
!    nota che lung_parole e' il numero di LETTERE contenute nella s-sequenza

!Esempi

!------------------------------------------------------------------------------------------------
!  posizioneRegistro (33) = 21 ! la sequenza che comincia nel punto 33 e' associata al cluster 21
!  posizioneRegistro (34) = 78 ! la sequenza che comincia nel punto 34 e' associata al cluster 78
!  posizioneRegistro (35) =  5 ! la sequenza che comincia nel punto 35 e' associata al cluster  5
!------------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------
!- registro_prima_osservazione(1) = 1   ! la posizione inziale del primo    cluster e'  1
!- registro_prima_osservazione(2) = 4   ! la posizione inziale del secondo  cluster e'  4
!- registro_prima_osservazione(3) = 27  ! la posizione inziale del terzo    cluster e' 27
!- registro_prima_osservazione(4) = 0   ! la posizione inziale del quarto   cluster e' ... non ho ancora trovato il quarto cluster  (in questo esempio)
!----------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------
!- clusterSize(1) = 1237                ! il primo   cluster contiene 1237 sequenze
!- clusterSize(2) =   12                ! il secondo cluster contiene   12 sequenze
!- clusterSize(3) =  659                ! il terzo   cluster contiene  659 sequenze
!----------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------
!- seq_simb(432)= 3                     ! la lettera che comincia nel punto 432 e'  3   (uso numeri invece che lettere)
!- seq_simb(433)= 1                     ! la lettera che comincia nel punto 433 e'  1
!- seq_simb(434)= 4                     ! la lettera che comincia nel punto 424 e'  4
!----------------------------------------------------------------------------------------------



 
     end subroutine tree_trova_Cluster_size 




!----------------------------------------------------------------------------

     subroutine trova_Cluster_Size(   seq)    ! trovo la grandezza di tutte le sequenze simboliche (lunghe "lung_parole") 
     implicit none                      ! qui a differenza di sopra non assegna i numeri alle parole ma la loro posizione 
     !integer, intent(in) :: ipar       ! di prima osservazione. E' molto piu' lento: PERCHE'??????
     integer :: i, j,   fine 
     integer (kind=8):: int_parola 
     integer, intent(in), dimension(:) :: seq
  

!-------------- LEGENDA -----------------------------------------------------------
!    poszioneRegistro             input= indice di riga della serie temporale della parola;    OUPTUT= posizione nel registro della parola  
!    registro_prima_osservazione  input= indice di ritrovamento parole nuove              ;    OUTPUT= posizione nella serie temporale della parola  
!    clusterSize                  input= indice di ritrovamento parole nuove              ;    OUTPUT= numero di parole trovate
!    seq_simb                     input= indice di riga della serie temporale             ;    OUTPUT= simbolo associato a quell'ingresso 
!    nota che in questo caso il registro non e' necessario: abbiamo la posizione di primo ritrovamento, se voglio sapere 
!    a quale parola simbolica corrisponde, uso da 
!        seq_simb(registro_prima_osservazione(i))                   = primo simbolo   (della s-sequenza associata alla sequenza iniziante in i)
!        seq_simb(registro_prima_osservazione(i+eXl))               = secondo simbolo
!                         ...
!        seq_simb(registro_prima osservazione(i+eXl*(lung_parole-1) = ultimo simbolo
!    nota che lung_parole e' il numero di LETTERE contenute nella s-sequenza

!Esempi

!------------------------------------------------------------------------------------------------
!  posizioneRegistro (33) = 21 ! la sequenza che comincia nel punto 33 e' associata al cluster 21
!  posizioneRegistro (34) = 78 ! la sequenza che comincia nel punto 34 e' associata al cluster 78
!  posizioneRegistro (35) =  5 ! la sequenza che comincia nel punto 35 e' associata al cluster  5
!------------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------
!- registro_prima_osservazione(1) = 1   ! la posizione inziale del primo    cluster e'  1
!- registro_prima_osservazione(2) = 4   ! la posizione inziale del secondo  cluster e'  4
!- registro_prima_osservazione(3) = 27  ! la posizione inziale del terzo    cluster e' 27
!- registro_prima_osservazione(4) = 0   ! la posizione inziale del quarto   cluster e' ... non ho ancora trovato il quarto cluster  (in questo esempio)
!----------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------
!- clusterSize(1) = 1237                ! il primo   cluster contiene 1237 sequenze
!- clusterSize(2) =   12                ! il secondo cluster contiene   12 sequenze
!- clusterSize(3) =  659                ! il terzo   cluster contiene  659 sequenze
!----------------------------------------------------------------------------------------------

!----------------------------------------------------------------------------------------------
!- seq_simb(432)= 3                     ! la lettera che comincia nel punto 432 e'  3   (uso numeri invece che lettere)
!- seq_simb(433)= 1                     ! la lettera che comincia nel punto 433 e'  1
!- seq_simb(434)= 4                     ! la lettera che comincia nel punto 424 e'  4
!----------------------------------------------------------------------------------------------

     fine = size (seq)-lung_seq+1 ! se le sequenze che cerco sono lunghe 10 e la serie 1000 posso cercare solo fino a 991  
     indiceParole = 0
     clusterSize_uso= 0                   ! 
     posizioneRegistro = 0
     registro_prima_osservazione =  0   
     
     do i=1, fine       ! giro sulle parole simbolica (tranne che sulle ultime lettere perche' lung parole e' fissa)
              
              if (  .not.giaTrovata2( i ) ) then                      ! ATTENZIONE ATTENZIONE ATTENZIONE qui crea clusterSize!  
                     indiceParole = indiceParole +1                   ! indice parole (aka cluster, aka s-sequence) nuove 
                     registro_prima_osservazione( indiceParole)  = i  ! collega gli indici alle parole
              endif
     enddo 


!-------------------------------------------------------------------------------------------

     write(69,*)  indiceParole
     if (allocated(clusterSize) ) deallocate(clusterSize) 
     allocate (clusterSize(indiceParole) ) 
     clusterSize = clusterSize_uso(1:indiceParole)    


     end subroutine trova_Cluster_Size

!--------------------------------------------------------------------------------------------


     subroutine new_trova_Cluster_Size     ! trovo la grandezza di tutte le sequenze simboliche (lunghe "lung_parole") 
     implicit none                      ! qui a differenza di sopra non assegna i numeri alle parole ma la loro posizione 
     !integer, intent(in) :: ipar       ! di prima osservazione. E' molto piu' lento: PERCHE'??????
     integer :: i, j
 

     indiceParole = 0
     clusterSize_uso= 0                   ! 
     posizioneRegistro = 0
     registro_prima_osservazione =  0   
     
     do i=1, N-lung_seq+1       ! giro sulle parole simbolica (tranne che sulle ultime lettere perche' lung parole e' fissa)
              
              if (  .not.giaTrovata2( i ) ) then                      ! ATTENZIONE ATTENZIONE ATTENZIONE qui crea clusterSize!  
                     indiceParole = indiceParole +1                   ! indice parole (aka cluster, aka s-sequence) nuove 
                     registro_prima_osservazione( indiceParole)  = i  ! collega gli indici alle parole
              endif
     enddo 


!-------------------------------------------------------------------------------------------

     if (allocated(clusterSize) ) deallocate(clusterSize) 
     allocate (clusterSize(indiceParole) ) 
     clusterSize = clusterSize_uso(1:indiceParole)    


     end subroutine new_trova_Cluster_Size  








      subroutine shuffleCluster
      implicit none
      integer , dimension(3) :: cluster_uso
      real (kind=8) :: u
      integer :: i,j  
      integer , dimension(12) :: iseme  

      iseme = 0
      if (useRandomSeed) &
      call date_and_time(values=iseme)  ! seme per generatore casuale
      call random_seed(put=iseme) 

!---------- knut shuffle ---------------
!- questo serve per minimizzare il problema del self match in preRiscaldamento
      do i=N-lung_seq+1, 1, -1
           if (i.eq.0) cycle
           call random_number(u)
           j = FLOOR(i*u)              ! scelgo numero intero 0<= j<= i
           if (j.eq. 0) j=1    
           cluster_uso = cluster(:,i)  ! faccio swap tra i e j 
           cluster(:,i) = cluster(:,j)  
           cluster(:,j) = cluster_uso   
      enddo
!---------------------------------------


      end subroutine shuffleCluster




!--------------------------------------------------------------------------------------------
      subroutine riordina_per_cluster(ianal) !uso il sort di mergesort (modificato) da rosetta code
      implicit none                   ! riordino prima per grandezza dei cluster  (cluster(3,:)
                                      ! poi perche' le linee contigue siano dello stesso cluster cluster(2,:) (e' l'indice di cluster)
      integer :: i 
      integer , dimension(:,:), allocatable :: OT
      integer , intent(in):: ianal
      integer :: indice, j , k, uso
      integer , dimension(3) :: cluster_uso
      integer , dimension(12) :: iseme        ! seme per random number generator
      real (kind=8) :: u
!      integer :: iSu=0, iGiu=0
!     integer , dimension(:,:), allocatable :: cluster_copia 


      do i=1, size(posizioneRegistro)                              ! la dimensione di posizione registro e' uguale al numero di sequenze che ho osservato
        if (posizioneRegistro(i) .ne. 0)  &                        ! non chiaro 
                     cluster(1,i) = i                              ! posizione originale della sequenza
                     cluster(2,i) = posizioneRegistro(i)           ! posizione del cluster nel registro... e' anche de facto l'indice con cui identifichiamo i cluster (o parole simboliche)  
                     cluster(3,i) = clusterSize( posizioneRegistro(i) )   ! numero di elementi nel cluster
        !endif
      enddo 
  
      if (allocated(ordineRandomCluster)) deallocate (ordineRandomCluster)
      allocate (ordineRandomCluster(maxval(posizioneRegistro)))

      do i=1, maxval(posizioneRegistro)
       ordineRandomCluster(i)=i
      enddo


 
      iseme = 0
      if (useRandomSeed) &  
      call date_and_time(values=iseme)  ! seme per generatore casuale
      call random_seed(put=iseme)       !
      

      do i=maxval(ordineRandomCluster), 1, -1
           if (i.eq.0) cycle
           call random_number(u)
           j = FLOOR(i*u)              ! scelgo numero intero 0<= j<= i
           if (j.eq. 0) j=1    
           uso =  ordineRandomCluster(i) ! faccio swap tra i e j 
           ordineRandomCluster(i) = ordineRandomCluster(j)  
           ordineRandomCluster(j) = uso   
      enddo

      !do i=1, maxval(posizioneRegistro)
      ! write(68,*) ordineRandomCluster(i)
      !enddo
!-------------------------------------------------------------------

                   if (algoritmo.eq.'mioHS'      .or. & 
                       algoritmo.eq.'very'       .or. &  
                       algoritmo.eq.'altro'      .or. &
                       algoritmo.eq.'qzaltro'      .or. &
                       algoritmo.eq.'hsStandard' .or. &
                       algoritmo.eq.'selfMatch'  .or. & 
                       algoritmo.eq.'sm_altro'  ) then ! esci appena sei sicuro che non possa essere discord

!---------- knut shuffle ---------------
!- questo serve per minimizzare il problema del self match in preRiscaldamento
      do i=N-lung_seq+1, 1, -1
           if (i.eq.0) cycle
           call random_number(u)
           j = FLOOR(i*u)              ! scelgo numero intero 0<= j<= i
           if (j.eq. 0) j=1    
           cluster_uso = cluster(:,i)  ! faccio swap tra i e j 
           cluster(:,i) = cluster(:,j)  
           cluster(:,j) = cluster_uso   
      enddo
!---------------------------------------
   endif


      if (allocated(randomSequenze)) deallocate (randomSequenze)
      allocate (randomSequenze(N-lung_seq+1))

      randomSequenze = cluster(1,:) 




!------------------------------------------------------------------------
!------------------------------------------------------------------------
   !if (algoritmo.eq.'mioHS'.or.algoritmo.eq.'very') then
   !cluster_copia = cluster
!---------- knut shuffle ---------------
!- questo serve per minimizzare il problema del self match in preRiscaldamento
   !cluster = 0
   !   do i=1,N-lung_seq+1

   !        if (i/2*2.eq.i) then ! i=pari
   !          cluster(:,i)  = cluster_copia(:,N -lung_seq+1- iGiu)
   !          iGiu= iGiu+1
   !        endif 

   !        cluster(:,2*i-1)  = cluster_copia(:,i)     ! metto il valore memorizzato prima 
   !   enddo

!---------------------------------------
   !endif
   !deallocate (cluster_copia)
!------------------------------------------------------------------------
!------------------------------------------------------------------------







!------   faccio un secondo knut shuffle per poter prendere piu' sequence ----------
!   if                 (algoritmo.eq.'mioHS'.or. & 
!                       algoritmo.eq.'very'  .or. &  
!                       algoritmo.eq.'altro' .or. &
!                       algoritmo.eq.'hsStandard' ) then ! esci appena sei sicuro che non possa essere discord

!     do i=1,nRiordini
!       clusterN(:,:,i) = cluster   ! faccio 10 copie
!     enddo


!---------- knut shuffle ---------------
!- questo serve per minimizzare il problema del self match in preRiscaldamento
!     do k=1,nRiordini
!       do i=N-lung_seq+1, 1, -1
!            if (i.eq.0) cycle
!            call random_number(u)
!            j = FLOOR(i*u)              ! scelgo numero intero 0<= j<= i
!            if (j.eq. 0) j=1    
!            cluster_uso = clusterN(:,i,k)  ! faccio swap tra i e j 
!            clusterN(:,i,k) = clusterN(:,j,k)  
!            clusterN(:,j,k) = cluster_uso   
!       enddo
!     enddo

!   endif
!---------------------------------------




!-----------------------------------------------------------------------------------



      if (.not. allocated(OT)) &   
      allocate (OT (3, size(cluster(3,:)))  ) 


      if (algoritmo.eq.'mioHS'     .or.  & 
          algoritmo.eq.'hsStandard'.or.  & 
          algoritmo.eq.'sod'       .or.  &
          algoritmo.eq.'selfMatch'   )   &
      call MergeSortP ( cluster, size(cluster(3,:)), OT)           ! riordino in modo che prima ci siano gli indici con 1 elemento, poi con 2, 3... 

      if ( algoritmo.eq.'very' .or.    &
           algoritmo.eq.'altro'.or.    &
           algoritmo.eq.'qzaltro'.or.    &
           algoritmo.eq.'sm_altro'      ) &
      call MergeSortPNND ( cluster, size(cluster(3,:)), OT)        ! in questo caso voglio che non mi rimetta in ordine le sequenze, ma solo i cluster 

 
!      do k=1,nRiordini
!        if (.not. allocated(OT))  allocate (OT (3, size(clusterN(3,:,1)))  ) 
!        call MergeSortP ( clusterN(:,:,k), size(clusterN(3,:,1)), OT)           ! riordino i cluster per il preRiscaldamento
!      enddo




      if (maxval(cluster(2,:)) .ge. N/3) then  ! ci sono troppi cluster HS non funge!
   write(*,*) "Attenzione: cambia i parametri  di SAX, perche' ci sono ", & 
              maxval(cluster(2,:)) , 'cluster non vuoti'
   write(*,*) "poco efficiente"    
      endif    
                                                                   ! a parita' di dimensione del cluster guardo un altro indice (non mi ricordo dovrei guardare MergeSortP 

      if (.not.risparmiaMemoria) then
       do i=1, size(cluster(3,:))
         if (ianal.eq.1) &
         write(110,*) cluster(1,i), cluster(2,i), cluster(3,i), ianal
       enddo  
      endif
      !write(*,*) eXl, lung_parole, num_simboli
      !stop 'giregf'

      end subroutine riordina_per_cluster
!--------------------------------------------------------------------------------------------


!--------------------------------------------------------------------------------------------


      subroutine riordina_per_clusterP1 ! sono i cluster calcolati con un simbolo in piu', in modo che
      implicit none                     ! io possa avere 2 cluster per ogni sequenza da analizzare.
                                        ! 
      integer :: i 
      integer , dimension(:,:), allocatable :: OT

      do i=1, size(posizioneRegistro)                              ! la dimensione di posizione registro e' uguale al numero di sequenze che ho osservato
        if (posizioneRegistro(i) .ne. 0) &
                     clusterP1(1,i) = i                              ! posizione originale della sequenza
                     clusterP1(2,i) = posizioneRegistro(i)           ! posizione del cluster nel registro... e' anche de facto l'indice con cui identifichiamo i cluster (o parole simboliche)  
             !NO    !clusterP1(3,i) = clusterSize( posizioneRegistro(i) )   ! numero di elementi nel cluster  
                     clusterP1(3,i) = 1       !  dato che voglio che sia solo il cluster per ordinare metto la dimensione =1 per tutti   

      enddo 

      if (.not. allocated(OT)) &   
      allocate (OT (3, size(cluster(3,:)))  ) 
      call MergeSortP ( clusterP1, size(clusterP1(3,:)), OT)           ! riordino in modo che prima ci siano gli indici con 1 elemento, poi con 2, 3... 

      !write(*,*) maxval(cluster(2,:))
 
      if (maxval(clusterP1(2,:)) .ge. N/3) then  ! ci sono troppi cluster HS non funge!
   write(*,*) "Attenzione: cambia i parametri  di HS, perche' ci sono ", & 
              maxval(clusterP1(2,:)) , 'cluster non vuoti'
   write(*,*) "poco efficiente"    
      endif    
                                                                   ! a parita' di dimensione del cluster guardo un altro indice (non mi ricordo dovrei guardare MergeSortP 
     if (.not.risparmiaMemoria)  then
      do i=1, size(clusterP1(3,:))
        write(111,*) clusterP1(1,i), clusterP1(2,i), clusterP1(3,i)
      enddo  
      close(111) 
     endif


      !stop 'fsfgs'

      end subroutine riordina_per_clusterP1
!--------------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------------


      subroutine riordina_per_clusterD  ! sono i cluster calcolati con un simbolo in piu', in modo che
      implicit none                     ! io possa avere 2 cluster per ogni sequenza da analizzare.
                                        ! 
      integer :: i , j
      integer , dimension(:,:), allocatable :: OT
      integer , dimension(3) :: cluster_uso  
      real (kind =8) :: u

      do i=1, size(posizioneRegistro)                              ! la dimensione di posizione registro e' uguale al numero di sequenze che ho osservato
        if (posizioneRegistro(i) .ne. 0) &
                     clusterD(1,i) = i                              ! posizione originale della sequenza
                     clusterD(2,i) = posizioneRegistro(i)           ! posizione del cluster nel registro... e' anche de facto l'indice con cui identifichiamo i cluster (o parole simboliche)  
                     clusterD(3,i) = clusterSize( posizioneRegistro(i) )   ! numero di elementi nel cluster  
                  !   clusterD(3,i) = 1       !  dato che voglio che sia solo il cluster per ordinare metto la dimensione =1 per tutti   

      enddo 


!---------- knut shuffle ---------------
!- questo serve per minimizzare il problema del self match in preRiscaldamento
      do i=N-lung_seq+1, 1, -1
           if (i.eq.0) cycle
           call random_number(u)
           j = FLOOR(i*u)              ! scelgo numero intero 0<= j<= i
           if (j.eq. 0) j=1    
           cluster_uso = clusterD(:,i)  ! faccio swap tra i e j 
           clusterD(:,i) = clusterD(:,j)  
           clusterD(:,j) = cluster_uso   
      enddo
!---------------------------------------




      if (.not. allocated(OT)) &   
      allocate (OT (3, size(cluster(3,:)))  ) 
      call MergeSortP ( clusterD, size(clusterD(3,:)), OT)           ! riordino in modo che prima ci siano gli indici con 1 elemento, poi con 2, 3... 

      !write(*,*) maxval(cluster(2,:))
 
      if (maxval(clusterD(2,:)) .ge. N/3) then  ! ci sono troppi cluster HS non funge!
   write(*,*) "Attenzione: cambia i parametri  di HS, perche' ci sono ", & 
              maxval(clusterD(2,:)) , 'cluster non vuoti'
   write(*,*) "poco efficiente"    
      endif    
                                                                   ! a parita' di dimensione del cluster guardo un altro indice (non mi ricordo dovrei guardare MergeSortP 

      do i=1, size(clusterD(3,:))
        write(111,*) clusterD(1,i), clusterD(2,i), clusterD(3,i)
      enddo  
      close(111) 
      !stop 'kgsfsf'

      end subroutine riordina_per_clusterD
!--------------------------------------------------------------------------------------------




       function mioModulo(i,n)  ! va da 1 a n
       integer :: mioModulo
       integer , intent(in) :: i, n
       integer :: iuso

       iuso = i   
       do while (iuso.gt. n)
         iuso = iuso -n 
       enddo 
       mioModulo= iuso     

       return
       end function mioModulo






 
!--------------------------------------------------------------------------------------------

       function giaTrovata2( indiceRiga)  ! decide se la parola word e' gia' stata trovata, costruisce la posizione nel registro e la clusterSize
       logical              :: giaTrovata2
       integer, intent(in) ::  indiceRiga   
       integer :: i, j, k
       integer,  dimension(lung_parole) :: word ! array che contiene la parola cercata. Se le lettere della parola cercata sono w1, w2, w3, ... ,wn 
       integer :: pos                                            !  allora word(1) = w1 , word(2)=w2,....  
 


!------- ricapitolo---------------------------------
!- registro_prima_osservazione(1) = 1   ! la posizione inziale del primo   (1)   cluster e'  1
!- registro_prima_osservazione(2) = 4   ! la posizione inziale del secondo (2)   cluster e'  4
!- registro_prima_osservazione(3) = 27  ! la posizione inziale del terzo   (3)   cluster e' 27
!- registro_prima_osservazione(4) = 0   ! la posizione inziale del quarto  (4)   cluster e' ... non ho ancora trovato il quarto cluster  (in questo esempio)


       word = sequenze_simboliche(indiceRiga,:)  ! la parola simbolica e' stata costruita in sub trasforma in simboli
      
       giaTrovata2 = .FALSE.   ! partiamo per ipotesi che non sia stata trovata  

       do i=1, size(registro_prima_osservazione)  ! nel registro_prima_osservazione ci sono le posizioni di tutte le parole nuove trovate, e vengono create accrescendo
            pos = registro_prima_osservazione(i) 

            if ( pos .eq. 0    ) then                        ! se vale 0 allora a questo numero non
              giaTrovata2 = .FALSE.                          ! sono ancora arrivato
              clusterSize_uso(i)  = clusterSize_uso(i)+1     ! potevo mettere 1...
              posizioneRegistro(indiceRiga) = i
              registro_prima_osservazione(i) = indiceRiga
              return
            endif  


        !    if (   all ( (seq_simb(pos: pos+lung_parole-1) - word ) .eq.0 ) )   then  ! confronta le parole, se tutti gli elementi sono uguali...
            if (   all ( (sequenze_simboliche(pos,:) - word ) .eq.0 ) )   then  ! confronta le parole, se tutti gli elementi sono uguali...
              giaTrovata2 = .TRUE.                                   ! questa sequenza e' gia' stata trovata!
              clusterSize_uso(i)  = clusterSize_uso(i)+1             ! aggiungi 1 alla pdf della parola simbolica i-esima (perche' la hai gia' trovata)
              posizioneRegistro(indiceRiga) = i                      ! si inserisce l'indice di inizio della parola e restituisce la posizione nel registro 
                                                        ! poi so quanto e' lunga e la ricostruisco
              return   
            endif 
!----------------------------------------------------------------------------
       enddo
       
       end function giaTrovata2
!-------------------------------------------------------------------------



   subroutine scrivi_Sod(idisc, present_queue)
   implicit none
   integer, intent(in) :: idisc, present_queue

   !  126 --- > sod_nomeAlgoritmo.dat 
          if (  val_discords(idisc) .ge. Q3+delta*IQ) &
          write(126,*) '*',pos_discords(idisc) + update_period * (present_queue-1),   val_discords(idisc)&
              , Q3+delta*IQ, Q3tot+delta*IQtot, Q3, IQ 

          if (  val_discords(idisc) .lt. Q3+delta*IQ) &
          write(126,*) ' ',pos_discords(idisc) + update_period * (present_queue-1),   val_discords(idisc)&
              , Q3+delta*IQ, Q3tot+delta*IQtot, Q3, IQ 
1480 format ( A1,i9,x,5(f10.5,3x) ) 
1481 format (  i9,x,5(f10.5,3x) ) 


   end subroutine scrivi_Sod
!-------------------------------------------------------------------------


   subroutine finaleVideo_e_chiudi
   implicit none
     write(*,*) char(13) 
     write(*,3200) '  Chiamate a distanza= ', chiamateAdistanza
3200 format (A21, f16.1)

     write(*,*)   ' primo Discord        = ',  & 
            pos_discords(  maxloc(val_discords(:)  )) , &
         ',  nnd=' ,  maxval( val_discords(:) ) 
 
   close(22)
   close(126)
   close(127)

   end subroutine finaleVideo_e_chiudi

!===============================================================

   subroutine costruisci_dettagliCalcolo ! crea una stringa con dettagli del calcolo
   implicit none
  
   character (len =4) :: cnum_simboli
   character (len =4) :: clung_parole
   character (len= 4) :: ceXl, cNd
   character (len=20) :: cN
   character (len=1)  :: cZnorm
   character (len=4)  :: versioneEseguibile
   character  (len=5)  :: cLung_seq
   character (len=10) :: cNmax


   write(cLung_seq   ,'(i5)') eXl*lung_parole
   write(ceXl        ,'(i4)') eXl      
   write(cnum_simboli,'(i4)') num_simboli
   write(clung_parole,'(i4)') lung_parole
   write(cNd         ,'(i4)') Nd 
   write(cN          ,'(i20)') N     
   write(cNmax       , '(i10)' ) nmax 


   if (Znorm) cZnorm = 'T'
   if (.not.Znorm) cZnorm = 'F'

   call get_command_argument(0,eseguibile)  ! prima era in avideoEfile 

   versioneEseguibile = trim(eseguibile( len_trim(eseguibile)-4 : len_trim(eseguibile)-2))

   dettagliCalcolo =                        '.' // &

                     trim(adjustl(cLung_seq)) // '.' // &
                     trim(adjustl(ceXl)) // '.' // &
                     trim(adjustl(clung_parole)) // '.' // &
                     trim(adjustl(cnum_simboli)) // '.' // &
                     trim(adjustl(cNd))          // '.' // & 
                     trim(adjustl(cN))           // '.' // &
                     trim(adjustl(cNmax))           // '.' // &
                     cZnorm                      // '.' // &
                     versioneEseguibile



   !write(*,*) trim(dettagliCalcolo) 
   ! write(*,*) len_trim(eseguibile) , trim(eseguibile( len_trim(eseguibile)-4 : len_trim(eseguibile)-2)) ! versione file
   ! write(*,*) cN // cZnorm 
   ! stop 'fnkfsf'


   end subroutine costruisci_dettagliCalcolo
  

!==============================================================


!-------------------------------------------------------------------------
   subroutine writesingolalimiti(ipar, serie)
   implicit none
   real (kind=8), dimension(:) :: serie

   integer, intent(in) :: ipar
   integer :: i, j


   character (len =4) :: cnum_simboli
   character (len =4) :: clung_parole
   character (len= 4) :: ceXl, cNd
   character ( len = 45 ) :: nomefile
   character (len =100)             :: nFmt 
   character (len =1) :: cifre  ! di quante cifre e' composto num_simboli

   write(ceXl        ,'(i4)') eXl      
   write(cnum_simboli,'(i4)') num_simboli
   write(clung_parole,'(i4)') lung_parole
   write(cNd         ,'(i4)') Nd 


   if (num_simboli .le. 10) cifre='1'
   if (num_simboli.gt.10.and. num_simboli .le. 100) cifre='2'
   if (num_simboli.gt.100.and. num_simboli .le. 1000) cifre='3'

   nFmt= "(i10,3x,f18.9,3x,i8,9x," // clung_parole // "(i" // cifre// ",x))"
   nFmt = trim(adjustl(nFmt))
   nomefile =  "./files/p"  // trim(nomiPar(ipar))   // ".nlett" // trim(adjustl(cnum_simboli)) // '.lungPar' & 
                           // trim(adjustl(clung_parole)) 


    !write(*,*) nomefile
    !stop 'fsfdsfl'

    if (.not.risparmiaMemoria)  then  ! scrivilo solo se non stai risparmiando
     open(unit=100, file=nomefile)
     do i= 1, size(serie)-lung_seq+1
       if (allocated(sequenze_simboliche)) then 
              write(100,nFmt) i, serie(i), clusterSize(posizioneRegistro(i)),   & 
                    (sequenze_simboliche(i,j), j=1, lung_parole)   ! ATTENTO 
       endif
     enddo
     close(100)
    endif 


   end subroutine writesingolalimiti

!-------------------------------------------------------------------------


subroutine Entropia
implicit none 
integer :: i
real(kind=8) :: shannon, p

shannon = 0.d0
do i=1, size(clusterSize)
  p = clusterSize(i)*1.d0/(N-lung_seq+1)
  shannon = shannon + p *log(p)
enddo
  write(*,*)
  write(*,*) ' Entropia di Shannon ', -shannon

end subroutine Entropia


 

!--------------------------------------------------------------------------------------------
end module parametri 


!--------------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------------

module hso
use parametri
implicit none 

integer :: Ntot=1000000 ! numero di righe della serie 

!real (kind=8), dimension(:), allocatable :: serie
integer ,dimension(:), allocatable :: pos_nei, pos_nei2
integer ,dimension(:,:), allocatable :: pos_neik
integer :: l 

!real (kind = 8) :: dist, dist0
real (kind =8 ) :: d1,d2,d3,d4, Ma, mi,  mean, sigma, uso
integer         :: iDiscord, jNeighbor, jNeighborLoc  ! posizione Discord, vicino, e vicino l
logical :: can_be_discord = .TRUE.
real(kind=8)  :: chiamateAdistanzaVecchio



contains 
!----------------------------------------------------------------------------

subroutine leggi_input
implicit none
integer :: i 

open(unit=21 , file ='input.dat')


   read(21,*) eXl               ! elementi X media   
   read(21,*) lung_parole       ! numero di lettere x parola
   read(21,*) num_simboli       ! numero simboli
   read(21,*) Nd                ! numero di discord da cercare
   read(21,*) N                 ! lunghezza della present queue
   read(21,*) nmax              ! numero di analisi
   read(21,*) ncd               ! numero elementi in coda_discord
   read(21,*) Tmax              ! distanza in passi massima prima dell'obsolescenza 
   read(21,*) nnei              ! numero di cluster vicini in cui estendere la ricerca
   read(21,*) nbin              ! numero di bin statistica seq simboliche
   read(21,*) Znorm             ! fai Z normalization? True or false
   read(21,*) algoritmo         ! esci subito dal ciclo interno come HS 


      lung_seq       = eXl * lung_parole          ! lung_parole * eXl    
      update_period  =  N - lung_seq  

      n_code_shadow  = Tmax / N         ! il numero di code e' uguale al tempo di obsolescenza diviso il numero di pti di una coda 
      if (n_code_shadow .le. 0 ) n_code_shadow =1 ! occhio modulo (n,0) da segmentation


    if (algoritmo .ne. 'brute'     .and. &
        algoritmo .ne. 'mioHS'     .and. &
        algoritmo .ne. 'sod'       .and. &
        algoritmo .ne. 'very'      .and. &
        algoritmo .ne. 'altro'     .and. &
        algoritmo .ne. 'qzaltro'     .and. &
        algoritmo .ne. 'selfMatch' .and. &
        algoritmo .ne. 'hsStandard'.and. &
        algoritmo .ne. 'sm_altro'      ) stop " Errore nel nome dell'algoritmo"
        !algoritmo .ne. 'hsStandard'     ) write(*,*) algoritmo, '------------------------------'


    if (.not.forceBreakPoints .and.algoritmo.eq.'hsStandard') gaussBreakPoints=.true. 
    if (.not.forceBreakPoints .and.algoritmo.eq.'altro')      gaussBreakPoints=.false. 
    if (.not.forceBreakPoints .and.algoritmo.eq.'qzaltro')      gaussBreakPoints=.false. 
    if (.not.forceBreakPoints .and.algoritmo.eq.'sm_altro')   gaussBreakPoints=.false. 
     
   !write(*,*) 'adfsssssssssssssssss' 

    if (gaussBreakPoints .and..not.Znorm) then
      write(*,*) '-------- ATTENZIONE ----------' 
      write(*,*) 'Usi breakpoint Gaussiani, ma i punti non sono z-normalizzati, non ha senso' 
      write(*,*) '-------- ATTENZIONE ----------' 
      stop       
    endif 


    if (algoritmo.eq. 'hsStandard' .and.   .not. gaussBreakpoints) then 
      write(*,*) '-------- ATTENZIONE ----------' 
      write(*,*) '-------- ATTENZIONE ----------' 
      write(*,*) 'con hsStandard si dovrebbero usare breakpoint Gaussiani!'
      write(*,*) '-------- ATTENZIONE ----------' 
      write(*,*) '-------- ATTENZIONE ----------' 
    endif
  

    !if (algoritmo .eq. 'sod' .and. risparmiaMemoria) &
    !    stop "Errore: LM non ancora implementato sod ZsaxP1 "
  
    !if (risparmiaMemoria .and. .not.Znorm ) &
    !    stop 'Errore: subroutine LM implementate solo per Znorm'

    !if (risparmiaMemoria.and. .not.gaussBreakPoints) &
    !    stop 'Errore: per la struttura del ciclo, quando si risparmia memoria, solo Gauss bp'
         

close(21)

end subroutine leggi_input
!-----------------------------------------------------------------------------


subroutine inizializza_1 ! inizializza alcuni valori
      implicit none
      integer :: i  
      coda_discord(:)%discord = 0.d0
      coda_discord(:)%posizione = 0


      coda_vecchi(:)%discord = 0.d0
      coda_vecchi(:)%posizione = 0
       
      do i=1, quantiVecchi
       coda_vecchi(i)%sequenza(:) = 0.d0
      enddo 

end subroutine inizializza_1




subroutine pre_leggi_serie
implicit none
integer :: conto, reason 


if (N.ne.-1) return ! controlla il file solo se N=-1 (non sai la lunghezza e lo vuoi tutto)
    reason=0
    conto=0
    do while (reason.eq.0) 
   ! do i=1,1000
      read(20,'(A)', iostat=reason) !primo
      conto=conto+1 
    enddo

    N= conto-1  
    nmax = 1     ! se fai tutta la serie, non puo' essserci piu' di una coda!
    rewind(20) ! riposizionati all'inizio del file
 
end subroutine pre_leggi_serie



!----------------------------------------------------------------------------
 subroutine leggi_serie(ianal) ! legge una present queue per volta
 implicit none 
 integer :: i, ianal, reason, numeroRighe, discMax, conto



    if (N.lt.2*lung_seq)   then
      write(uscita,*) 'Attenzione la serie temporale deve essere piu lunga di ', 2*lung_seq
      write(uscita,*) 'altrimenti le sequenze sono tutte in self match!' ! ricorda che se la serie e' lunga 20, e la sequenza
 !     10, allora da 11 a 20 non ci possono essere sequenze! e quelle da 1 a 11 sono in self match! 
      stop 
    endif 



do i=1, N    ! leggi N linee dal file
   read(20,*, iostat=reason )  serie(i)   ! leggi il file

   if (i.eq.1.and. ianal.eq.1)  then 
     write(nomiPar(1), '(F10.2)') serie(1)
     nomiPar(1) = trim(adjustl(nomiPar(1)))
   endif
   !write(*,*) nomiPar(1)
   !stop 'dafsfs '

! se reason =0 non ci sono problemi nella lettura
  if (reason > 0 ) then
     write(*,*) 'Problema di lettura alla riga', i  
     write(*,*) 'forse nel file ci sono dei valori non numerici?'
     write(*,*) 'Codice iostat', reason
     stop
  endif

  if (reason < 0) then
     write(*,*) char(13) ! carattere return
     !if (nmax.gt.1) then  
       if (ianal.eq.1) write(*,*) "Nessuna coda analizzata"
       write(*,*) "Raggiunta la fine del file, dopo aver letto", i-1, 'righe'
       write(*,*) "(servivano almeno", N, "righe per una coda in piu')"
       write(*,*) ""
     !endif 
     stop  
     !exit ! esci dal ciclo, ri-leggi dopo 
  endif  
enddo







!  if (reason < 0 .and. nmax.eq.1) then ! fai l'analisi di tutta la sequenza trovata
!     write(*,*) "ATTENZIONE volevi leggere", N ," righe"
!     write(*,*) "Ce ne sono solo          ", i-1
!     write(*,*) "Procedo alla analisi delle SOLE righe lette" 
!     rewind(20) ! torna indietro
!     N= i-1
!     do i=1, N    ! leggi N linee dal file
!          read(20,*,end = 1599)  serie(i)   ! leggi il file
!     enddo
!1599 continue  
!  endif 


 ! se i discord trovati fossero uno dietro l'altro
 ! ci starebbero N-lung_seq+1/ (lung_seq-1) discord
 ! se invece sono sparsi "male" lo spazio massimo potrebbe 
 ! essere la meta'! 
if (algoritmo.ne. 'sm_altro' .and. &
      algoritmo.ne. 'selfMatch'        ) then  ! per questi algoritmi il concetto di self match e' rimosso

      discMax =  ( N-lung_seq+1)*1.d0/(2*lung_seq)
      if (2* Nd *lung_seq .gt. N-lung_seq+1) then
        write(*,*) 'ATTENTO non ci sono abbastanza punti per trovare', Nd , 'discord'
        write(*,*)  'lunghi ', lung_seq,' punti, in una serie di ', N , 'punti'
        write(*,*)  'Diminuisci Nd a meno di ',  discMax
        stop
      endif  
endif


  do i=1,lung_seq
     backspace(20) ! torna indietro nell'unita' 20 di lung_seq linee
  enddo

  iarrivo = iarrivo + N - (eXl * lung_parole)





 end subroutine leggi_serie

!----------------------------------------------------------------------------




!----------------------------------------------------------------------------------------



    subroutine avideoEfile
    implicit none 
    integer :: numero_massimo_cluster,i
    character (len=1000) :: daAnalizzare
    integer :: cicloUscita   
    character (len=200) :: nomeFileDiscord

    numero_massimo_cluster = 1
    do i=1,lung_parole
       numero_massimo_cluster = numero_massimo_cluster * num_simboli
       if (numero_massimo_cluster .gt. N) then
              numero_massimo_cluster = N
              exit 
       endif 
    enddo

nomeFileDiscord = 'Discord_' // trim(algoritmo) // '.dat' // dettagliCalcolo
open (unit=22, file=nomeFileDiscord)
!open (unit=22, file='Discord.dat')


do cicloUscita =1,2

    if (cicloUscita.eq.1) uscita = 6
    if (cicloUscita.eq.2) uscita = 22
   

    write(uscita,*) 'lunghezza sequenze da analizzare  (lung_parole x eXl)  =', eXl * lung_parole 
    write(uscita,*) 'numero di punti per lettera                     (eXl)  =', eXl
    write(uscita,*) 'num. lettere della sequenza simbolica   (lung_parole)  =', lung_parole
    write(uscita,*) 'grandezza alfabeto PAA                  (num_simboli)  =', num_simboli
    write(uscita,*) 'Numero di possibili cluster: (num_simboli^lung_parole) =', numero_massimo_cluster 
    write(uscita,*) 'Lunghezza della present queue                     (N)  =', N
    write(uscita,*) 'Numero di discord cercati per coda               (Nd)  =', Nd
    write(uscita,*) "Numero di passi prima dell'obsolescenza        (Tmax)  =", Tmax  
    write(uscita,*) "Numero di cluster vicini dove ricercare        (nnei)  =", nnei
    write(uscita,*) "Numero bin della statistica seq simb           (nbin)  =", nbin 
!    write(*,'(A57,f7.3)') " Parametro di shrink                                    =", shrink 
    write(uscita,*) "Usa Z-normalization?                           (Znorm) =", Znorm
    write(uscita,*) "Usa seme random?                       (useRandomSeed) =", useRandomSeed        
    write(uscita,*) "Usa breakpoint Gaussiani?            (gaussBreakpoints)=", gaussBreakpoints             
    write(uscita,*) "Metodo risparmia memoria?            (risparmiaMemoria)=", risparmiaMemoria 
    write(uscita,*) "Multi SAX?                                      (musax)=", musax

    write(uscita,*) 
    if (algoritmo .eq. 'brute')  write(uscita,*)  " algoritmo:        brute - BRUTE FORCE (trova SOD)"
    if (algoritmo .eq. 'sod')    write(uscita,*)  " algoritmo:        sod   - (trova SOD)"
    if (algoritmo .eq. 'mioHS')  write(uscita,*)  " algoritmo:        mioHS - HOT SAX mia versione (SOD non hanno senso)"
    if (algoritmo .eq. 'very')   write(uscita,*)  " algoritmo:        Very HOT SAX - (SOD non hanno senso)"
    if (algoritmo .eq. 'altro')  write(uscita,*)  " algoritmo:        altro - (SOD non hanno senso)"
    if (algoritmo .eq. 'qzaltro')  write(uscita,*)  " algoritmo:        qzaltro - (SOD non hanno senso)"
    if (algoritmo .eq. 'sm_altro')  write(uscita,*)  " algoritmo:        sm_altro - (SOD non hanno senso)"
    if (algoritmo .eq. 'selfMatch')  write(uscita,*)  " algoritmo:       hsStandard_selfMatch - (SOD non hanno senso)"

    if (algoritmo .eq. 'hsStandard')  write(uscita,*)  " algoritmo:   hsStandard - HOT SAX originale  (SOD non hanno senso)"
    write(uscita,*) 

!    call get_command_argument(0,eseguibile)  ! ora si trova in sub costruisci_dettagliCalcolo 
    call get_command_argument(1,daAnalizzare) 

                                 write(uscita,*)  " eseguibile:        ", trim(adjustl(eseguibile))
                                 write(uscita,*) 
                                 write(uscita,*)  " file analizzato:   ", trim(adjustl(daAnalizzare))
                                 write(uscita,*) 





!944 format (A55, f7.3)
    !write(uscita,*) "clusterSize contiene il numero di occorrenze di ogni parola nuova"
    !write(uscita,*) "registro_parole_nuove indica la posizione di partenza"
    !write(uscita,*) "nella serie delle parole nuove"
    !write(uscita,*) "posizione_registro data la posizione di una parola, indica dove"
    !write(uscita,*) "si trova nel registro da cui si puo' ottenere la clusterSize" 


enddo  ! ciclo uscita

    end subroutine avideoEfile




!----------------------------------------------------------------------------------------
   subroutine allocca_iniziale
      implicit none
      integer :: i
      allocate ( seq_analizzata(N-lung_seq+1) )  ! se vero allora la sequenza e' gia' stata analizzata 
      allocate ( NND (N-lung_seq+1), NND2(N-lung_seq+1) , QNND(N-lung_seq+1))
      allocate ( serie(N) , pos_nei(N), pos_nei2(N)   )    ! present queue e posizione dei nearest neighbor 
      allocate (hub(N-lung_seq+1)) 
      allocate ( array_vincolo(N) ) 
      allocate ( cluster   (3,N-lung_seq+1))   ! indice identificativo del cluster, indice di posizione
      allocate ( clusterP1 (3,N-lung_seq+1))   ! indice identificativo del cluster, indice di posizione
      allocate ( clusterD (3,N-lung_seq+1))   ! indice identificativo del cluster, indice di posizione

      !allocate ( clusterN  (3,N-lung_seq+1, 10))! come sopra ma con 10 cluster diversi

      allocate ( iniCluster (0:N), finCluster(0:N) ) ! inizio e fine di ogni cluster
      allocate ( iniClusterP1 (0:N), finClusterP1(0:N) ) ! inizio e fine di ogni cluster

      allocate ( seq_simb(N) )
      allocate ( posizioneRegistro(N-lung_seq+1) ) 
      allocate ( registro_prima_osservazione(N), indice_crescita(N))  ! in questo modo non
      allocate ( pos_lett(1:num_simboli))   
      allocate ( pos_discords (Nd), val_discords(Nd) )
      allocate ( coda_discord(ncd))
      allocate ( ghost(lung_seq, 100000))


      allocate ( longStat (2,n_code_shadow, 0:nbin) )  ! la coda di partenza e' la 1
      allocate ( longCdf  (2,n_code_shadow, 0:nbin) )

      allocate ( binNND (0:nbin) )   


      !allocate ( vecchiOutlier ( 0:quantiVecchi , eXl*lung_parole ))  ! numero di vecchi outlier, lunghezza sequenze

      allocate (coda_vecchi(quantiVecchi))               ! allocco quandi vecchi tengo nella coda vecchi

      do i=1, quantiVecchi
       allocate (coda_vecchi(i)%sequenza(lung_seq)) ! gli dico quanto sono grandi le sequenze all'interno  
      enddo

      allocate (discords(Nd))


      !vecchiOutlier = 0.d0
      ghost = 0.d0
      pos_discords  = -1000000000
      val_discords  = 10000000.d0 
      longStat      = 0.d0 
      pos_nei2      = 0
      !discords = -10000000.d0

   end subroutine allocca_iniziale
!----------------------------------------------------------------------------------------
!----------------------------------------------------------------------------------------

   subroutine riallocca
      implicit none

      if (allocated( pos_lett) ) deallocate(pos_lett) 
      allocate ( pos_lett(1:num_simboli))   

      if (allocated (val_medio)) deallocate (val_medio)
      allocate (val_medio(N-lung_seq+1))


   end subroutine riallocca
!----------------------------------------------------------------------------------------



   subroutine deallocca
     
      if (allocated(pdf) )& 
      deallocate (pdf , xpos , cdf, ncdf )                ! numero di punti in cui binno
      if (allocated(media)) deallocate (media )   ! allocca array con tutte le lettere!  la parola al posto i costituita da media (i), media(i+eXl), media(i+2*eXl), ...
      if (allocated(sequenze_ristrette) ) deallocate (sequenze_ristrette      ) 
      if (allocated(sequenze_simboliche)) deallocate (sequenze_simboliche )
      if (allocated (bari) ) &   
      deallocate (bari, bariNei, bariMat)
      deallocate (val_medio, dev_standard)
   end subroutine deallocca

!----------------------------------------------------------------------------------------

function distanza(i,j)
implicit none
real (kind =8) :: distanza, tot
integer, intent(in) :: i, j
integer :: k

!if (abs(i-j).lt.lung_seq) stop 'errore self match!'

chiamateAdistanza= chiamateAdistanza+1
tot =0.d0
    do k=1, lung_seq
         tot = tot+ ( serie(i+k-1)  - serie(j+k-1) )**2   
    enddo

    distanza = sqrt(tot)
!if (chiamateAdistanza .eq. 1)  write(*,*) 'non uso distanza Euclidea ma d2'

end function distanza

!---------------------------------------------------------------------

function Zdistanza(i,j)
implicit none
real (kind =8) :: Zdistanza, tot, m1, m2, s1, s2, valore, costante, tot1, tot2
real (kind =8), dimension(lung_seq) :: seq1, seq2
integer, intent(in) :: i, j
integer :: k


!if (abs(i-j).lt.lung_seq) then 
!     call BACKTRACE             ! serve per capire chi ha chiamato questa funzione
!     write(*,*) i,j , abs(i-j)
!     stop 'errore self match!'
!endif 
chiamateAdistanza= chiamateAdistanza+1


!m1 = val_medio(i)     
!m2 = val_medio(j) 

!s1 = dev_standard(i)
!s2 = dev_standard(j)    
!    
! Formula intuitiva
   !tot =0.d0
   ! do k=1, lung_seq
   !      tot = tot+ ( (serie(i+k-1)-m1)/s1  - (serie(j+k-1)-m2)/s2 )**2 
   ! enddo


! uso la formula di Keogh:
! "Exploiting a novel algorithm and GPUs to break the ten quadrillion pairwise comparisons barrier for time series motifs and joins"
! formula (1) (usa il prodotto scalare!)

    tot2= sum(serie(i:i+lung_seq-1)*serie(j:j+lung_seq-1))
    !tot = 2*lung_seq *(1.d0- (tot2- lung_seq*m1*m2 )/(lung_seq*s1*s2 ))

    tot = 2*lung_seq *(1.d0- (tot2- lung_seq*val_medio(i)*val_medio(j) )/ &
           (lung_seq*dev_standard(i)*dev_standard(j) ))




    Zdistanza = sqrt(tot)





end function Zdistanza
!---------------------------------------------------------------------


function Zdistanza_2_troncato(i,j)  ! Znorm, Euclidea quadrata(2) (ovvero senza radice) tronco se maggiore della NND attuale
implicit none
real (kind =8) :: Zdistanza_2_troncato, tot, m1, m2, s1, s2
integer, intent(in) :: i, j
integer :: k


if (abs(i-j).lt.lung_seq) then 
     call BACKTRACE             ! serve per capire chi ha chiamato questa funzione
     write(*,*) i,j , abs(i-j)
     stop 'errore self match!'
endif 
chiamateAdistanza= chiamateAdistanza+1


m1 = val_medio(i)     
m2 = val_medio(j) 

s1 = dev_standard(i)
s2 = dev_standard(j)    


! ( (serie(i+k-1) -m1 )/s1   - (serie(j+k-1)-m2/s2 )**2
!  
!  

tot =0.d0
    do k=1, lung_seq

         tot = tot+ ( (serie(i+k-1)-m1)/s1  - (serie(j+k-1)-m2)/s2 )**2 
         
         if ( tot.gt.nnd(i) ) exit            
    enddo






end function Zdistanza_2_troncato




!---------------------------------------------------------------------



function distanza2(seq1,seq2)
implicit none
real (kind =8), dimension(:) :: seq1, seq2 
real (kind =8) :: distanza2, tot
integer :: k

chiamateAdistanza = chiamateAdistanza +1
    tot =0.d0
    do k=1, lung_seq
         tot = tot+ ( seq1(k)  - seq2(k) )**2   
    enddo
    distanza2 = sqrt(tot)
!if (chiamateAdistanza .eq. 1)  write(*,*) 'non uso distanza Euclidea ma d2'

end function distanza2

!------------------------------------------------------------



!---------------------------------------------------------------------







!---------------------------------------------------------------------



!---------------------------------------------------------------------
!---------------------------------------------------------------------

!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!------------------------------------------------------------------




   subroutine Situazione(i, idisc)
   implicit none
   integer, intent(in):: i, idisc
   integer :: iblock =40 


          !if (i.eq.1) write(*,77, advance='no') '  Percentuale Completamento                     '   
          if (i.eq.1.and.idisc.eq.1) write(*,77, advance='no') '  Percentuale Completamento                     '   

          if (i/(N/iblock)*(N/iblock).eq.i) write(*,81, advance='no') &
         !char(8),char(8), char(8), ((i*100)/N)/Nd, '%' !  char(13) riporta il carriage all'inizio della linea
         char(8), char(8), char(8), char(8), char(8), & 
         char(8),char(8), char(8), ((i*100)/N), '%', '(', idisc ,') ' !  char(13) riporta il carriage all'inizio della linea


!81 format (1a1,1a1,1a1,i2, A,$)  ! devi dirgli che il char(13) e' un solo carattere e quindi lui lo esegue, il $ non so a cosa seerve
81 format (8A1,i2, A,A,i2,A$)  ! devi dirgli che il char(13) e' un solo carattere e quindi lui lo esegue, il $ non so a cosa seerve
  
77 format (A)



!----------------------- scrivi anche nel file Discord... -----------------------------
          if (i.eq.1.and.idisc.eq.1) write(22,77, advance='no') '  Percentuale Completamento                     '   

          if (i/(N/iblock)*(N/iblock).eq.i) write(22,81, advance='no') &
         !char(8),char(8), char(8), ((i*100)/N)/Nd, '%' !  char(13) riporta il carriage all'inizio della linea
         char(8), char(8), char(8), char(8), char(8), & 
         char(8),char(8), char(8), ((i*100)/N), '%', '(', idisc ,') ' !  char(13) riporta il carriage all'inizio della linea
         flush(22)
!-----------------------------------------------------------------------------




   end subroutine Situazione


!------------------------------------------------------------------





!---------------------------------------------------------------------
subroutine sod(idisc, ianal) ! calcola HotSax invece che con dei goto con una variabile
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc


! ho un problema, ho ordinato secondo i cluster, ma se sono a meta' strada del
! cluster vorrei poter girare su tutto il cluster stesso. Ho bisogno quindi di
! sapere dove comincia  e dove finisce sto cluster.  Fatto nella subroutinE limiti_cluster
! e fare il ciclo interno a partire da dove comincia il cluster. Poi il ciclo interno continua
! da dove il cluster era finito.

! i cicli vengono suddivisi in cluster, nel senso che si gira sui cluster e poi sul loro contenuto

! la logica degli indici e' la seguente, ho riordinato l'indice di partenza di tutte le sequenze
! in una lista dove:
! cluster(1,i) e' l'indice di partenza della sequenza per come arriva, per esempio cluster(1,10)=243 
! dice che la decima sequenza nella mia lista e' la sequeunza 243 come ordine temporale
! cluster(2,i) e' l'indice del cluster
! cluster(3,i) dice quanto e' grande il cluster che si ottiene con cluster(2,i)

! iniCluster(  come valore si mette quello di cluster(2,i) ) indica in che riga della nuova lista pare il cluster
! finCluster  idem come sopra ma per la fine del clsuter. (ricorda che cluster(2,i) fornisce l'indice del cluster)
! excl  = cluster del ciclo esterno
! incl  = cluster del ciclo interno



if (siNNDk) then
  if (.not.allocated(NNDk)) allocate(NNDk(N-lung_seq+1, 0:kmax))          ! primi k neighbors
  if (.not.allocated(pos_neik)) allocate(pos_neik(N-lung_seq+1, kmax)) 

  if (idisc.eq.1) then  ! inizializza gli NND multipli e le posizioni dei vicini
    NNDk = 999999999.d0
    NNDk(:,0)= -1.d0
  endif 
endif


Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata

if(idisc == 1) then
  pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0!
  val_discords =0.d0
endif


if (idisc.eq.1) write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo


do excl=1, maxval(cluster(2,:))    ! gira sui cluster, partendo dai piu' piccoli, di granzezza 1  ! ciclo esterno
                                   ! parte dai piu' piccoli perche' l'array cluster e' stato ordinato per grandezza
   if (cluster(3,excl) .eq. 0 )   cycle ! per ragioni tecniche possono esserci cluster di 0 oggetti: evitali
   do  k1 = iniCluster(excl), finCluster(excl)  ! gira sulle sequenze all'interno del cluster (iniCluster di una sequenza, data nell'ordine di apparizione)


!============= LEGENDA ======================
!  dist = NND attuale della sequenza, occhio che migliora tra le varie subroutine
!  dist0  distanza calcolata in un ciclo di una singola subroutine tra la sequenza e un'altra sequenza
!  bestDist massimo valore degli NND tra tutte le sequenze calcolate fino a quel momento 
!  NND  = array che ad ogni sequenza  associa il valore dell'NND calcolato fino a quel momento
!============= fine LEGENDA =================

      can_be_discord = .TRUE.  ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist           = 100000000.d0   ! numero grande superiore a ogni possibile distanza
if(idisc.gt.1) dist  = nnd(cluster(1,k1)) ! altrimenti in tutti altri cluster arriva dist altissimo e prende come dist quello che ottiene in tutti altri cluster che e' > dell'attuale
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

if (nmax.eq.1)       call Situazione                     (k1, idisc) ! mi dice quanto manca alla fine, solo se cerco in un'unica coda
if (idisc.gt.1)      call velocizza_Nesimo_discord (      k1,  dist, bestDist)   ! evita di controllare ulteriormente se sai che non puo' essere discord per calcoli con 1mo discord
if (can_be_discord .and. idisc.eq.1)  & 
                     call sod_cluster_corrente     (excl, k1,  dist, bestDist)   ! controlla nel cluster corrente
if (can_be_discord .and. idisc.eq.1)  & 
                     call sod_cluster_correnteP1   (excl, k1,  dist, bestDist)   ! controlla nel cluster corrente (alternativo)
     
                     if (dist <= bestDist) then    ! se non puo' essere un discord evita di 
                         can_be_discord = .FALSE.  ! controllare anche su tutti gli altri cluster
                     endif 
if (can_be_discord)  call sod_tutti_altri_cluster   (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)

    
      if (dist.gt. bestDist .and. can_be_discord) then    ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                              ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = cluster(1,k1)                    ! best disc 
      endif 
      

      NND(cluster(1,k1)) = dist ! si segna il valore della NND approssimata
                                 ! relativa alla sequenza iniziante in cluster(1,k1)
      

!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------
   enddo

  ! if (chiamateAdistanza.gt.1000000) stop ' dfafdsj'

enddo
 

             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord

             call sod_pulisci_NND   ! evita gli spikes della NND (array NND, migliorando NND stessa) provare a mettere nel ciclo

            if (siNNDk) then
             call sod_pulisci_NNDk  ! fai come pulisi ma anche per il II vicino... k-mo visino
            endif

 
            do i=101423, 101423+10
              write(47,*) idisc, i, nnd(i), pos_nei(i)
            enddo
              write(47,*)

             if (idisc.eq.Nd) then 
               do i=1, size(NND)
                 ! write(127,*) i+ update_period * (ianal-1), NND(i), pos_nei(i), pos_nei2(i), NND2(i)
                  write(127,*) i+ update_period * (ianal-1), NND(i), & 
                      pos_nei(i)+ update_period * (ianal-1), pos_nei2(i), NND2(i)

                  if (siNNDk) & 
                  write(140,*)  i+ update_period * (ianal-1), NNDk(i,1), pos_neik(i,1), & 
                                NNDk(i,2), pos_neik(i,2),NNDk(i,3), pos_neik(i,3) 

                  if (.not.siNNDk)  write(140,*)  i+ update_period * (ianal-1)

               enddo
             endif


end subroutine sod

!---------------------------------------------------------------------




!---------------------------------------------------------------------


!---------------------------------------------------------------------
subroutine qzAltro(idisc, ianal) ! come altro ma cerco di diminuire gli if in time_for, time_back e tutti_altri
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc
integer, dimension(:,:), allocatable :: OT
real (kind=8) :: valoreGrande= 1.0e12
integer :: ivecchio, iora,incremento=0, esterno, prima
integer :: idove, iquanti
real (kind=8) :: chiamVecchio
integer :: conteggio=0
real (kind=8) , dimension(:), allocatable :: mediaMobile
integer :: largh
logical :: cambia
real(kind=8) :: start, finish

write(*,*) '---------------------QZ------------------'

cambia=.true.
prima =0
Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata


      if (.not. allocated(OT)) &   
      allocate (OT (3, size(cluster(3,:)))  )   !allocca OT per il merge, serve ogni volta che si fa il rearrangement

! qui riordino tenendo conto delle NND attuale nel caso di discord successivi
 if (idisc.gt.1)  then

      do i=1, size(rCluster(2,:))
         rCluster(1,i)  = 1                    ! non viene usato
         rCluster(2,i)  = i                    ! posizione
         rCluster(3,i)  = nnd(i) *10000 * (-1)  ! il valore di nnd approssimato (reso intero e negativo per l'ordine usato) 
         if (nnd(i).eq.valoreGrande ) rCluster(3,i) = 0.d0  
      enddo 

      !call cpu_time(start)
      call MergeSortP ( rCluster, size(rCluster(3,:)), OT) 
      !call cpu_time(finish)
      !write(65,*) finish-start 


  endif !------------ DISCORD SUCCESSIVI--------------------------- 

                                                ! perche' e' creato in questa subroutine 

  if(idisc == 1) then
      pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0! 
      val_discords =0.d0      ! potrei anche mettere un valore negativo   

      write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo
     
!----------------------------------------
     
      call A_preRiscaldamento 
      call A_pulisci_NND
     
!----------------------------------------
      if (.not.allocated(rCluster)) &         
      allocate (rCluster(3, size(cluster(1,:)) ))

      do i=1, size(rCluster(2,:))
         rCluster(1,i)  = 1                    ! non viene usato
         rCluster(2,i)  = i                    ! posizione
         rCluster(3,i)  = nnd(i) *1000 * (-1)  ! il valore di nnd approssimato (reso intero e negativo per l'ordine usato) 
         if (nnd(i).eq.valoreGrande ) rCluster(3,i) = 0.d0  
      enddo 

      !do i=1,size(rCluster(1,:))
      ! write(34,*) rCluster(2,i), rCluster(3,i), posizioneRegistro(rCluster(2,i)), nnd(rCluster(2,i) ) 
      !enddo


!------------ MEDIA MOBILE --------------------------
      if (allocated(mediaMobile)) deallocate (mediaMobile)
      allocate (mediaMobile (N-lung_seq+1))

      largh =lung_seq/2

      mediaMobile(1:largh/2) = nnd(1:largh/2)
      mediaMobile(N-lung_seq+1-largh/2:) = nnd(N-lung_seq+1-largh/2:)
      mediaMobile(largh/2+1) = sum(nnd(1:largh))   ! faccio le medie fino alla meta'

      do i=largh/2+2, N-lung_seq+1 - largh/2
        mediaMobile(i) =mediaMobile(i-1)- nnd(i-largh/2)+ nnd(i+largh/4) 
      enddo
!------------ MEDIA MOBILE --------------------------

      do i=1, size(rCluster(2,:))
         rCluster(3,i)  = -100*mediaMobile(i)
      enddo


      !call cpu_time(start)
      call MergeSortP ( rCluster, size(rCluster(3,:)), OT) 
      !call cpu_time(finish)
      !write(65,*) finish-start 




      deallocate (mediaMobile)

  endif   ! if idisc==1


esterno=0



chiamVecchio = chiamateAdistanza

do i = 1, size(rCluster(3,:)) ! gira su tutte le sequenze in ordine tale da essere le piu' probabili discotd
      

      k1 = rCluster(2,i)            ! quale sequenza usiamo
      excl = posizioneRegistro(k1)  ! a quale cluster appartiene      
 
      can_be_discord = .TRUE.       ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist = NND (k1)
     ! dist = 100000000.d0  
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

      esterno=esterno+1

      call Situazione(esterno,idisc)  ! scrive a video quanto abbiamo fatto

      !if (i.gt.1) &
                       call A_velocizza_Nesimo_discord (     k1,  dist, bestDist)   ! evita di controllare ulteriormente se sai che non puo' essere discord per calcoli con 1mo discord
  if (can_be_discord)  call A_cluster_corrente         (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente
  if (can_be_discord)  call qzA_tutti_altri_cluster      (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)!
  !if (can_be_discord)  call A_tutti_altri_cluster      (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)!



      if (dist.gt. bestDist .and. can_be_discord) then   ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                                ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = k1                      ! best disc 
      endif 


      NND(k1) = dist ! si segna il valore della NND approssimata
                     ! relativa alla sequenza iniziante in cluster(1,k1)


      call qzA_timeTopologyForward          (k1, bestDist)
      !call A_timeTopologyForward          (k1, bestDist)


      call qzA_timeTopologyBackward         (k1, bestDist)
      !call A_timeTopologyBackward         (k1, bestDist)



      if (can_be_discord)  then                     ! se sei arrivato in fondo ai calcoli di tutti gli altri cluster...
      !if (can_be_discord.or.(chiamateAdistanza-chiamVecchio).gt. N-lung_seq+1)  then                     ! se sei arrivato in fondo ai calcoli di tutti gli altri cluster...

!=================  standard ==========================
!goto 5218
          rCluster(3,:) = -1000 * NND(rCluster(2,:)) ! allora hai calcolato una distanza con tutte le sequenze
                                                     ! probabilmente l'ordine dei massimi e' cambiato   
                                                     ! il valore da usare come grandezza da mettere nella colonna 3
                                                     ! e' l'NND associato alla sequenza della colonna 2 (non sono in ordine!)

      
          rCluster(3,1:i) = -1000000000 ! le sequenze che hai gia' misurato vanno messe prima, in modo da non ri-misurarle

 
      !call cpu_time(start)      
          call MergeSortP ( rCluster, size(rCluster(3,:)), OT)   ! questo sort si basa sul terzo e poi sul secondo (forse e' meglio solo sul terzo)
      !call cpu_time(finish)
      !write(65,*) finish-start 
 

5218 continue 
!================= fine standard ======================

!================= medie mobili =======================
goto 5259      
      if (idisc.eq.1) then ! fallo solo per il primo discord    
        if (largh.ge.2)  largh = largh/3 ! cambia di volta in volta
        !if (cambia)  then
        !    largh = 10 
        !    cambia = .not.cambia 
        !else 
        !    largh = 0
        !    cambia= .not.cambia
        !endif
  
        write(*,*) 'media su', largh 

        if (.not.allocated(mediaMobile)) allocate (mediaMobile (N-lung_seq+1))
        mediaMobile(1:largh/2) = nnd(1:largh/2)
        mediaMobile(N-lung_seq+1-largh/2:) = nnd(N-lung_seq+1-largh/2:)
        mediaMobile(largh/2+1) = sum(nnd(1:largh))   ! faccio le medie fino alla meta'

       !largh = 10
       do j=largh/2+2, N-lung_seq+1 - largh/2
          !mediaMobile(j) =mediaMobile(j-1)- nnd(j-largh/2)+ nnd(j+largh/4) 

          !mediaMobile(j) = sum(nnd(  rCluster(2,j-largh/2) :  rCluster(2, j+largh/2)))/(largh+1)

          mediaMobile(j) = sum(nnd(  j-largh/2 :   j+largh/2))/(largh+1)

 
        !  write(47,*) j, nnd(j), mediaMobile(j), largh 
       enddo
 
        !stop 'fsljgdgf' 

       do j=1, size(rCluster(2,:))
          rCluster(3,j)  = -1000*mediaMobile( rCluster(2, j))
       enddo
       !do j=1, i
           rCluster(3,1:i) = -1000000000 ! le sequenze che hai gia' misurato vanno messe prima, in modo da non ri-misurarle
       !enddo 

      !do j=1, N-lung_seq+1
      !  write(49,*) j, rCluster(1,j), rCluster(2,j), rCluster(3,j)
      !enddo
      !stop 'fsfsojs' 

      call MergeSortP ( rCluster, size(rCluster(3,:)), OT)

      !do j=1, N-lung_seq+1
      !  write(49,*) j, rCluster(1,j), rCluster(2,j), rCluster(3,j)
      !enddo
      !stop 'fsfsojs' 
     endif
5259 continue  
!================= fine medie mobili ==================



          write(*,*)  i,  chiamateAdistanza-chiamVecchio
          write(22,*) i,  chiamateAdistanza-chiamVecchio
          flush(22)           
 
          chiamVecchio=chiamateAdistanza
        !endif       
      endif 




      
!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------

      prima = chiamateAdistanza
      !if (chiamateAdistanza.gt.50000000) then 
      !    write(*,*) chiamateAdistanza
      !    stop 'raggiunti 50M'
      !endif 
enddo   ! sulle i ordinate secondo il preRiscaldamento



             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord


           !write(127,5272) 1234567890, 1234.56789

             if (idisc.eq.Nd) then 
               do i=1, size(NND)
                  !write(127,*) i+ update_period * (ianal-1), NND(i), pos_nei(i), pos_nei2(i), NND2(i)
                  write(127,5272 ) i+ update_period * (ianal-1), NND(i), pos_nei(i)+update_period 
               enddo
             endif

5272 format(i12,1x, F9.4, 1x, i12)

end subroutine qzAltro
!---------------------------------------------------------------------

!---------------------------------------------------------------------
subroutine pulito_Altro(idisc, ianal) ! in questo caso non usa i cluster nel ciclo esterno ma i piu' probabili discord
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc
integer, dimension(:,:), allocatable :: OT
real (kind=8) :: valoreGrande= 1.0e12
integer :: ivecchio, iora,incremento=0, esterno, prima
integer :: idove, iquanti
real (kind=8) :: chiamVecchio
integer :: conteggio=0
real (kind=8) , dimension(:), allocatable :: mediaMobile
integer :: largh
logical :: cambia

cambia=.true.
prima =0
Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata


      if (.not. allocated(OT)) &   
      allocate (OT (3, size(cluster(3,:)))  )   !allocca OT per il merge, serve ogni volta che si fa il rearrangement

! qui riordino tenendo conto delle NND attuale nel caso di discord successivi
 if (idisc.gt.1)  then

      do i=1, size(rCluster(2,:))
         rCluster(1,i)  = 1                    ! non viene usato
         rCluster(2,i)  = i                    ! posizione
         rCluster(3,i)  = nnd(i) *10000 * (-1)  ! il valore di nnd approssimato (reso intero e negativo per l'ordine usato) 
         if (nnd(i).eq.valoreGrande ) rCluster(3,i) = 0.d0  
      enddo 

      call MergeSortP ( rCluster, size(rCluster(3,:)), OT) 

  endif !------------ DISCORD SUCCESSIVI--------------------------- 

                                                ! perche' e' creato in questa subroutine 

  if(idisc == 1) then
      pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0! 
      val_discords =0.d0      ! potrei anche mettere un valore negativo   

      write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo
     
!----------------------------------------
     
      call A_preRiscaldamento 
      call A_pulisci_NND
     
!----------------------------------------
      if (.not.allocated(rCluster)) &         
      allocate (rCluster(3, size(cluster(1,:)) ))

      do i=1, size(rCluster(2,:))
         rCluster(1,i)  = 1                    ! non viene usato
         rCluster(2,i)  = i                    ! posizione
         rCluster(3,i)  = nnd(i) *1000 * (-1)  ! il valore di nnd approssimato (reso intero e negativo per l'ordine usato) 
         if (nnd(i).eq.valoreGrande ) rCluster(3,i) = 0.d0  
      enddo 



!------------ MEDIA MOBILE --------------------------
      if (allocated(mediaMobile)) deallocate (mediaMobile)
      allocate (mediaMobile (N-lung_seq+1))

      largh =lung_seq/2

      mediaMobile(1:largh/2) = nnd(1:largh/2)
      mediaMobile(N-lung_seq+1-largh/2:) = nnd(N-lung_seq+1-largh/2:)
      mediaMobile(largh/2+1) = sum(nnd(1:largh))   ! faccio le medie fino alla meta'

      do i=largh/2+2, N-lung_seq+1 - largh/2
        mediaMobile(i) =mediaMobile(i-1)- nnd(i-largh/2)+ nnd(i+largh/4) 
      enddo
!------------ MEDIA MOBILE --------------------------

      do i=1, size(rCluster(2,:))
         rCluster(3,i)  = -100*mediaMobile(i)
      enddo
      call MergeSortP ( rCluster, size(rCluster(3,:)), OT) 
      deallocate (mediaMobile)

  endif   ! if idisc==1


esterno=0



chiamVecchio = chiamateAdistanza

do i = 1, size(rCluster(3,:)) ! gira su tutte le sequenze in ordine tale da essere le piu' probabili discotd
      

      k1 = rCluster(2,i)            ! quale sequenza usiamo
      excl = posizioneRegistro(k1)  ! a quale cluster appartiene      
 
      can_be_discord = .TRUE.       ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist = NND (k1)
     ! dist = 100000000.d0  
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

      esterno=esterno+1

      call Situazione(esterno,idisc)  ! scrive a video quanto abbiamo fatto

      !if (i.gt.1) &
                           call A_velocizza_Nesimo_discord (     k1,  dist, bestDist)   ! evita di controllare ulteriormente se sai che non puo' essere discord per calcoli con 1mo discord
      if (can_be_discord)  call A_cluster_corrente         (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente
      if (can_be_discord)  call qzA_tutti_altri_cluster      (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)!


      if (dist.gt. bestDist .and. can_be_discord) then   ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                                ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = k1                      ! best disc 
      endif 


      NND(k1) = dist ! si segna il valore della NND approssimata
                     ! relativa alla sequenza iniziante in cluster(1,k1)


      call qzA_timeTopologyForward          (k1, bestDist)
      call qzA_timeTopologyBackward         (k1, bestDist)


      !if (can_be_discord)  then                     ! se sei arrivato in fondo ai calcoli di tutti gli altri cluster...
      if (can_be_discord.or.(chiamateAdistanza-chiamVecchio).gt. N-lung_seq+1)  then                     ! se sei arrivato in fondo ai calcoli di tutti gli altri cluster...

!=================  standard ==========================
          rCluster(3,:) = -1000 * NND(rCluster(2,:)) ! allora hai calcolato una distanza con tutte le sequenze
                                                     ! probabilmente l'ordine dei massimi e' cambiato   
                                                     ! il valore da usare come grandezza da mettere nella colonna 3
                                                     ! e' l'NND associato alla sequenza della colonna 2 (non sono in ordine!)

      
          rCluster(3,1:i) = -1000000000 ! le sequenze che hai gia' misurato vanno messe prima, in modo da non ri-misurarle
          call MergeSortP ( rCluster, size(rCluster(3,:)), OT)   ! questo sort si basa sul terzo e poi sul secondo (forse e' meglio solo sul terzo)
 

5218 continue 
!================= fine standard ======================



          write(*,*)  i,  chiamateAdistanza-chiamVecchio
          write(22,*) i,  chiamateAdistanza-chiamVecchio
          flush(22)           
 
          chiamVecchio=chiamateAdistanza
        !endif       
      endif 

!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------

      prima = chiamateAdistanza
enddo   ! sulle i ordinate secondo il preRiscaldamento



             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord


           !write(127,5272) 1234567890, 1234.56789

             if (idisc.eq.Nd) then 
               do i=1, size(NND)
                  write(127,5272 ) i+ update_period * (ianal-1), NND(i), pos_nei(i)+update_period 
               enddo
             endif

5272 format(i12,1x, F9.4, 1x, i12)

end subroutine pulito_Altro
!---------------------------------------------------------------------

!---------------------------------------------------------------------
subroutine Altro(idisc, ianal) ! in questo caso non usa i cluster nel ciclo esterno ma i piu' probabili discord
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc
integer, dimension(:,:), allocatable :: OT
real (kind=8) :: valoreGrande= 1.0e12
integer :: ivecchio, iora,incremento=0, esterno, prima
integer :: idove, iquanti
real (kind=8) :: chiamVecchio
integer :: conteggio=0
real (kind=8) , dimension(:), allocatable :: mediaMobile
integer :: largh
logical :: cambia

cambia=.true.
prima =0
Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata


      if (.not. allocated(OT)) &   
      allocate (OT (3, size(cluster(3,:)))  )   !allocca OT per il merge, serve ogni volta che si fa il rearrangement

! qui riordino tenendo conto delle NND attuale nel caso di discord successivi
 if (idisc.gt.1)  then

      do i=1, size(rCluster(2,:))
         rCluster(1,i)  = 1                    ! non viene usato
         rCluster(2,i)  = i                    ! posizione
         rCluster(3,i)  = nnd(i) *10000 * (-1)  ! il valore di nnd approssimato (reso intero e negativo per l'ordine usato) 
         if (nnd(i).eq.valoreGrande ) rCluster(3,i) = 0.d0  
      enddo 

      call MergeSortP ( rCluster, size(rCluster(3,:)), OT) 

  endif !------------ DISCORD SUCCESSIVI--------------------------- 

                                                ! perche' e' creato in questa subroutine 

  if(idisc == 1) then
      pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0! 
      val_discords =0.d0      ! potrei anche mettere un valore negativo   

      write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo
     
!----------------------------------------
     
      call A_preRiscaldamento 
      call A_pulisci_NND
     
!----------------------------------------
      if (.not.allocated(rCluster)) &         
      allocate (rCluster(3, size(cluster(1,:)) ))

      do i=1, size(rCluster(2,:))
         rCluster(1,i)  = 1                    ! non viene usato
         rCluster(2,i)  = i                    ! posizione
         rCluster(3,i)  = nnd(i) *1000 * (-1)  ! il valore di nnd approssimato (reso intero e negativo per l'ordine usato) 
         if (nnd(i).eq.valoreGrande ) rCluster(3,i) = 0.d0  
      enddo 

      !do i=1,size(rCluster(1,:))
      ! write(34,*) rCluster(2,i), rCluster(3,i), posizioneRegistro(rCluster(2,i)), nnd(rCluster(2,i) ) 
      !enddo


!------------ MEDIA MOBILE --------------------------
      if (allocated(mediaMobile)) deallocate (mediaMobile)
      allocate (mediaMobile (N-lung_seq+1))

      largh =lung_seq/2

      mediaMobile(1:largh/2) = nnd(1:largh/2)
      mediaMobile(N-lung_seq+1-largh/2:) = nnd(N-lung_seq+1-largh/2:)
      mediaMobile(largh/2+1) = sum(nnd(1:largh))   ! faccio le medie fino alla meta'

      do i=largh/2+2, N-lung_seq+1 - largh/2
        mediaMobile(i) =mediaMobile(i-1)- nnd(i-largh/2)+ nnd(i+largh/4) 
      enddo
!------------ MEDIA MOBILE --------------------------

      do i=1, size(rCluster(2,:))
         rCluster(3,i)  = -100*mediaMobile(i)
      enddo
      call MergeSortP ( rCluster, size(rCluster(3,:)), OT) 
      deallocate (mediaMobile)

  endif   ! if idisc==1


esterno=0



chiamVecchio = chiamateAdistanza

do i = 1, size(rCluster(3,:)) ! gira su tutte le sequenze in ordine tale da essere le piu' probabili discotd
      

      k1 = rCluster(2,i)            ! quale sequenza usiamo
      excl = posizioneRegistro(k1)  ! a quale cluster appartiene      
 
      can_be_discord = .TRUE.       ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist = NND (k1)
     ! dist = 100000000.d0  
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

      esterno=esterno+1

      call Situazione(esterno,idisc)  ! scrive a video quanto abbiamo fatto

      !if (i.gt.1) &
                           call A_velocizza_Nesimo_discord (     k1,  dist, bestDist)   ! evita di controllare ulteriormente se sai che non puo' essere discord per calcoli con 1mo discord

      if (can_be_discord)  call A_cluster_corrente         (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente
      if (can_be_discord)  call qzA_tutti_altri_cluster      (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)!


      if (dist.gt. bestDist .and. can_be_discord) then   ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                                ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = k1                      ! best disc 
      endif 


      NND(k1) = dist ! si segna il valore della NND approssimata
                     ! relativa alla sequenza iniziante in cluster(1,k1)


      call qzA_timeTopologyForward          (k1, bestDist)  ! qzA_time... cycle solo su nnd(i+j) <= bestDist
      call qzA_timeTopologyBackward         (k1, bestDist)  !              " 


      !if (can_be_discord)  then                     ! se sei arrivato in fondo ai calcoli di tutti gli altri cluster...
      if (can_be_discord.or.(chiamateAdistanza-chiamVecchio).gt. N-lung_seq+1)  then                     ! se sei arrivato in fondo ai calcoli di tutti gli altri cluster...

!=================  standard ==========================
!goto 5218
          rCluster(3,:) = -1000 * NND(rCluster(2,:)) ! allora hai calcolato una distanza con tutte le sequenze
                                                     ! probabilmente l'ordine dei massimi e' cambiato   
                                                     ! il valore da usare come grandezza da mettere nella colonna 3
                                                     ! e' l'NND associato alla sequenza della colonna 2 (non sono in ordine!)

      
          rCluster(3,1:i) = -1000000000 ! le sequenze che hai gia' misurato vanno messe prima, in modo da non ri-misurarle

      !do j=1, N-lung_seq+1
      !  write(50,*) j, rCluster(1,j), rCluster(2,j), rCluster(3,j)
      !enddo
     ! stop 'fsfsojs' 

       
          call MergeSortP ( rCluster, size(rCluster(3,:)), OT)   ! questo sort si basa sul terzo e poi sul secondo (forse e' meglio solo sul terzo)
 

5218 continue 
!================= fine standard ======================

!================= medie mobili =======================
goto 5259      
      if (idisc.eq.1) then ! fallo solo per il primo discord    
        if (largh.ge.2)  largh = largh/3 ! cambia di volta in volta
        !if (cambia)  then
        !    largh = 10 
        !    cambia = .not.cambia 
        !else 
        !    largh = 0
        !    cambia= .not.cambia
        !endif
  
        write(*,*) 'media su', largh 

        if (.not.allocated(mediaMobile)) allocate (mediaMobile (N-lung_seq+1))
        mediaMobile(1:largh/2) = nnd(1:largh/2)
        mediaMobile(N-lung_seq+1-largh/2:) = nnd(N-lung_seq+1-largh/2:)
        mediaMobile(largh/2+1) = sum(nnd(1:largh))   ! faccio le medie fino alla meta'

       !largh = 10
       do j=largh/2+2, N-lung_seq+1 - largh/2
          !mediaMobile(j) =mediaMobile(j-1)- nnd(j-largh/2)+ nnd(j+largh/4) 

          !mediaMobile(j) = sum(nnd(  rCluster(2,j-largh/2) :  rCluster(2, j+largh/2)))/(largh+1)

          mediaMobile(j) = sum(nnd(  j-largh/2 :   j+largh/2))/(largh+1)

 
        !  write(47,*) j, nnd(j), mediaMobile(j), largh 
       enddo
 
        !stop 'fsljgdgf' 

       do j=1, size(rCluster(2,:))
          rCluster(3,j)  = -1000*mediaMobile( rCluster(2, j))
       enddo
       !do j=1, i
           rCluster(3,1:i) = -1000000000 ! le sequenze che hai gia' misurato vanno messe prima, in modo da non ri-misurarle
       !enddo 

      !do j=1, N-lung_seq+1
      !  write(49,*) j, rCluster(1,j), rCluster(2,j), rCluster(3,j)
      !enddo
      !stop 'fsfsojs' 

      call MergeSortP ( rCluster, size(rCluster(3,:)), OT)

      !do j=1, N-lung_seq+1
      !  write(49,*) j, rCluster(1,j), rCluster(2,j), rCluster(3,j)
      !enddo
      !stop 'fsfsojs' 
     endif
5259 continue  
!================= fine medie mobili ==================



          write(*,*)  i,  chiamateAdistanza-chiamVecchio
          write(22,*) i,  chiamateAdistanza-chiamVecchio
          flush(22)           
 
          chiamVecchio=chiamateAdistanza
        !endif       
      endif 




      
!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------

      prima = chiamateAdistanza
enddo   ! sulle i ordinate secondo il preRiscaldamento



             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord


           !write(127,5272) 1234567890, 1234.56789

             !if (idisc.eq.Nd) then 
             !  do i=1, size(NND)
             !     write(127,5272 ) i+ update_period * (ianal-1), NND(i), pos_nei(i)+update_period 
             !  enddo
             !endif

5272 format(i12,1x, F9.4, 1x, i12)

end subroutine Altro
!---------------------------------------------------------------------

!---------------------------------------------------------------------
subroutine SM_Altro(idisc, ianal) ! come Altro ma calcola anche distanze tra Self Match
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc
integer, dimension(:,:), allocatable :: OT
real (kind=8) :: valoreGrande= 1.0e12
integer :: ivecchio, iora,incremento=0, esterno, prima
integer :: idove, iquanti
real (kind=8) :: chiamVecchio
integer :: conteggio=0
real (kind=8) , dimension(:), allocatable :: mediaMobile
integer :: largh

prima =0
Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata


      if (.not. allocated(OT)) &   
      allocate (OT (3, size(cluster(3,:)))  )   !allocca OT per il merge, serve ogni volta che si fa il rearrangement
                                                ! perche' e' creato in questa subroutine 

  if(idisc == 1) then
      pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0! 
      val_discords =0.d0      ! potrei anche mettere un valore negativo   

      write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo
     
!----------------------------------------
     
      call SM_preRiscaldamento 
      call SM_pulisci_NND
     
!----------------------------------------
      if (.not.allocated(rCluster)) &         
      allocate (rCluster(3, size(cluster(1,:)) ))

      do i=1, size(rCluster(2,:))
         rCluster(1,i)  = 1                    ! non viene usato
         rCluster(2,i)  = i                    ! posizione
         rCluster(3,i)  = nnd(i) *1000 * (-1)  ! il valore di nnd approssimato (reso intero e negativo per l'ordine usato) 
         if (nnd(i).eq.valoreGrande ) rCluster(3,i) = 0.d0  
      enddo 

!------------ MEDIA MOBILE --------------------------
      if (allocated(mediaMobile)) deallocate (mediaMobile)
      allocate (mediaMobile (N-lung_seq+1))

      largh =lung_seq/2

      mediaMobile(1:largh/2) = nnd(1:largh/2)
      mediaMobile(N-lung_seq+1-largh/2:) = nnd(N-lung_seq+1-largh/2:)
      mediaMobile(largh/2+1) = sum(nnd(1:largh))   ! faccio le medie fino alla meta'

      do i=largh/2+2, N-lung_seq+1 - largh/2
        mediaMobile(i) =mediaMobile(i-1)- nnd(i-largh/2)+ nnd(i+largh/4) 
      enddo
!------------ MEDIA MOBILE --------------------------

      do i=1, size(rCluster(2,:))
         rCluster(3,i)  = -100*mediaMobile(i)
      enddo
      call MergeSortP ( rCluster, size(rCluster(3,:)), OT) 
      deallocate (mediaMobile)

  endif   ! if idisc==1


esterno=0



chiamVecchio = chiamateAdistanza

do i = 1, size(rCluster(3,:)) ! gira su tutte le sequenze in ordine tale da essere le piu' probabili discotd
      

      k1 = rCluster(2,i)            ! quale sequenza usiamo
      excl = posizioneRegistro(k1)  ! a quale cluster appartiene      
 
      can_be_discord = .TRUE.       ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist = NND (k1)
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

      esterno=esterno+1

      call Situazione(esterno,idisc)  ! scrive a video quanto abbiamo fatto

      !if (i.gt.1 .or.idisc.gt.1) &
                           call SM_velocizza_Nesimo_discord (     k1,  dist, bestDist, i, idisc)   ! evita di controllare ulteriormente se sai che non puo' essere discord per calcoli con 1mo discord
             
      if (can_be_discord)  call SM_cluster_corrente         (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente
      if (can_be_discord)  call SM_tutti_altri_cluster      (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)!



      if (dist.gt. bestDist .and. can_be_discord) then   ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                                ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = k1                      ! best disc 
      endif 


      NND(k1) = dist ! si segna il valore della NND approssimata
                     ! relativa alla sequenza iniziante in cluster(1,k1)


      call A_timeTopologyForward          (k1, bestDist)  !
      call A_timeTopologyBackward         (k1, bestDist)  ! 

      if (can_be_discord)  then                     ! se sei arrivato in fondo ai calcoli di tutti gli altri cluster...

          rCluster(3,:) = -1000 * NND(rCluster(2,:)) ! allora hai calcolato una distanza con tutte le sequenze
                                                     ! probabilmente l'ordine dei massimi e' cambiato
         
          do j=1, i
              rCluster(3,j) = -1000000000 ! le sequenze che hai gia' misurato vanno messe prima, in modo da non ri-misurarle
          enddo 
       
          call MergeSortP ( rCluster, size(rCluster(3,:)), OT)   ! questo sort si basa sul terzo e poi sul secondo (forse e' meglio solo sul terzo)

          write(*,*)  i,  chiamateAdistanza-chiamVecchio
          write(22,*) i,  chiamateAdistanza-chiamVecchio
          flush(22)           
 
          chiamVecchio=chiamateAdistanza
      endif 

      
!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------

      prima = chiamateAdistanza
enddo   ! sulle i ordinate secondo il preRiscaldamento



             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord

             if (idisc.eq.Nd) then 
               do i=1, size(NND)
                  write(127,*) i+ update_period * (ianal-1), NND(i), & 
                      pos_nei(i)+ update_period * (ianal-1), pos_nei2(i), NND2(i)
               enddo
             endif



end subroutine SM_Altro

!---------------------------------------------------------------------






!---------------------------------------------------------------------

subroutine veryHS(idisc, ianal) ! very hot sax, con warmup e  time topology
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc
integer, dimension(:,:), allocatable :: OT
real (kind=8) :: valoreGrande= 1.0e12
integer :: ivecchio, iora,incremento=0, esterno


Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata

if(idisc == 1) then
  pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0!
  val_discords =0.d0
endif


if (idisc.eq.1) write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo

!----------------------------------------
if (idisc.eq.1) call preRiscaldamento 
!if (idisc.eq.1) call shuffleCluster
!if (idisc.eq.1) call preRiscaldamento ! again??
if (idisc.eq.1) call V_pulisci_NND

!if (idisc.eq.1)  then
!    if (.not. allocated(OT))  allocate (OT (3, size(cluster(3,:)))  ) 
!    call MergeSortP ( cluster, size(cluster(3,:)), OT)     
!endif
!----------------------------------------

!----------------------------------------

esterno=0
do excl=1, maxval(cluster(2,:))    ! gira sulle sequenze, con l'ordine ottenuto tramite preRiscaldamento
   do  k1 = iniCluster(excl), finCluster(excl)  ! gira sulle sequenze all'interno del 

      can_be_discord = .TRUE.  ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist           = valoreGrande 

!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

esterno=esterno+1
                              call Situazione(esterno,idisc)
         !if (idisc.gt.1) &  
                              call V_velocizza_Nesimo_discord (     k1,  dist, bestDist)   ! evita di controllare ulteriormente se sai che non puo' essere discord per calcoli con 1mo discord
         if (can_be_discord)  call V_cluster_corrente         (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente
         !if (can_be_discord)  call Restanti_sequenze2      (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)!
         !if (can_be_discord)  call A_tutti_altri_cluster      (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)!
         if (can_be_discord)  call V_tutti_altri_cluster      (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)!


    
         if (dist.gt. bestDist .and. can_be_discord) then   ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                                ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = cluster(1,k1)                      ! best disc 
         endif 
      

         NND(cluster(1,k1)) = dist ! si segna il valore della NND approssimata
                                 ! relativa alla sequenza iniziante in cluster(1,k1)

         !if (can_be_discord) then 
                              call timeTopologyForward          (k1, bestDist)
                              call timeTopologyBackward         (k1, bestDist)
         !endif
      

!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------
  !write(35,*) chiamateAdistanza 
  enddo ! ciclo sulle sequenze
enddo   ! sulle i ordinate secondo il preRiscaldamento

             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord

             if (idisc.eq.Nd) then 
               !write(*,*) size(NND), N, lung_seq+1, 'fsfd'
               do i=1, size(NND)
                  !write(127,*) i+ update_period * (ianal-1), NND(i), pos_nei(i), pos_nei2(i), NND2(i)
                  write(127,*) i+ update_period * (ianal-1), NND(i), & 
                      pos_nei(i)+ update_period * (ianal-1), pos_nei2(i), NND2(i)
               enddo
             endif


             !do i=1,N-lung_seq+1
             !  hub(pos_nei(i)) = hub(pos_nei(i)) +1
             !enddo 
             



!write(*,*) ' ========================================================='
!write(126,1481) iDiscord + update_period * (ianal-1),  bestDist, Q3+delta*IQ, Q3tot+delta*IQtot  , Q3tot, Q1tot
!1481 format (  i9,x,5(f10.5,3x) ) 
!write(*,*) ' ========================================================='

end subroutine veryHS

!---------------------------------------------------------------------
!---------------------------------------------------------------------

!---------------------------------------------------------------------

subroutine motif1(idisc, ianal) ! cerca le 2 sequenze piu' vicine.
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc
integer :: esterno


!=================== IDEA =========================================
! Problema: qui devo cercare min_sequenze (min )
! non posso interrompere facilmente il cilco interno, perche' ogni altra sequenza
! potrebbe essere un minimo
! idea e' di simbolizzare sul singolo valore (non sulle medie) in modo
! da poter escludere con un calcolo se una sequenza non e' minimo.

! faccio SAX, 
! prendo una sequenza a caso nel cluster piu' grande e calcolo la sua nnd
! faccio nuovo sax, con P=1 e con discretizzazione tale che se anche 1 punto
! non si trova all'interno della stessa lettera, posso escluderlo.
! Ora ho eliminato altre sequenze, calcolo un nuovo sax con P=1 ma con una lunghezza
! minore  (meta'?)
! e cosi' via...

!============ qui sotto VECCHIO era in sub dei discord ===========================
! ho un problema, ho ordinato secondo i cluster, ma se sono a meta' strada del
! cluster vorrei poter girare su tutto il cluster stesso. Ho bisogno quindi di
! sapere dove comincia  e dove finisce sto cluster.  Fatto nella subroutinE limiti_cluster
! e fare il ciclo interno a partire da dove comincia il cluster. Poi il ciclo interno continua
! da dove il cluster era finito.

! i cicli vengono suddivisi in cluster, nel senso che si gira sui cluster e poi sul loro contenuto

! la logica degli indici e' la seguente, ho riordinato l'indice di partenza di tutte le sequenze
! in una lista dove:
! cluster(1,i) e' l'indice di partenza della sequenza per come arriva, per esempio cluster(1,10)=243 
! dice che la decima sequenza nella mia lista e' la sequeunza 243 come ordine temporale
! cluster(2,i) e' l'indice del cluster
! cluster(3,i) dice quanto e' grande il cluster che si ottiene con cluster(2,i)

! iniCluster(  come valore si mette quello di cluster(2,i) ) indica in che riga della nuova lista pare il cluster
! finCluster  idem come sopra ma per la fine del clsuter. (ricorda che cluster(2,i) fornisce l'indice del cluster)
! excl  = cluster del ciclo esterno
! incl  = cluster del ciclo interno

Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata

if(idisc == 1) then
  pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0!
  val_discords =0.d0
endif


if (idisc.eq.1) write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo



esterno=0
do excl=maxval(cluster(2,:)),1 ,-1 ! gira sui cluster, partendo dal piu' grande, di granzezza 1  ! ciclo esterno
                                   ! parte dai piu' piccoli perche' l'array cluster e' stato ordinato per grandezza
   if (cluster(3,excl) .eq. 0 )   cycle ! per ragioni tecniche possono esserci cluster di 0 oggetti: evitali
   do  k1 = iniCluster(excl), finCluster(excl)  ! gira sulle sequenze all'interno del cluster (iniCluster di una sequenza, data nell'ordine di apparizione)


!============= LEGENDA ======================
!  dist = NND attuale della sequenza, occhio che migliora tra le varie subroutine
!  dist0  distanza calcolata in un ciclo di una singola subroutine tra la sequenza e un'altra sequenza
!  bestDist massimo valore degli NND tra tutte le sequenze calcolate fino a quel momento 
!  NND  = array che ad ogni sequenza  associa il valore dell'NND calcolato fino a quel momento
!============= fine LEGENDA =================

      can_be_discord = .TRUE.  ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist           = 100000000.d0   ! numero grande superiore a ogni possibile distanza
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

esterno = esterno+1
                     call Situazione(esterno, idisc)                
if (can_be_discord)  call motif_cluster_corrente         (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente
if (can_be_discord)  call motif_tutti_altri_cluster   (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)


    
      if (dist.gt. bestDist .and. can_be_discord) then    ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                              ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = cluster(1,k1)                    ! best disc 
      endif 
      

      NND(cluster(1,k1)) = dist ! si segna il valore della NND approssimata
                                 ! relativa alla sequenza iniziante in cluster(1,k1)
      

!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------
   enddo

enddo

             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord

             if (idisc.eq.Nd) then 
               do i=1, size(NND)
                  write(127,*) i+ update_period * (ianal-1), NND(i), & 
                      pos_nei(i)+ update_period * (ianal-1), pos_nei2(i), NND2(i)
               enddo
             endif


end subroutine motif1

!---------------------------------------------------------------------



!---------------------------------------------------------------------

subroutine HSstandard(idisc, ianal) ! calcola HotSax invece che con dei goto con una variabile
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc
integer :: esterno

! ho un problema, ho ordinato secondo i cluster, ma se sono a meta' strada del
! cluster vorrei poter girare su tutto il cluster stesso. Ho bisogno quindi di
! sapere dove comincia  e dove finisce sto cluster.  Fatto nella subroutinE limiti_cluster
! e fare il ciclo interno a partire da dove comincia il cluster. Poi il ciclo interno continua
! da dove il cluster era finito.

! i cicli vengono suddivisi in cluster, nel senso che si gira sui cluster e poi sul loro contenuto

! la logica degli indici e' la seguente, ho riordinato l'indice di partenza di tutte le sequenze
! in una lista dove:
! cluster(1,i) e' l'indice di partenza della sequenza per come arriva, per esempio cluster(1,10)=243 
! dice che la decima sequenza nella mia lista e' la sequeunza 243 come ordine temporale
! cluster(2,i) e' l'indice del cluster
! cluster(3,i) dice quanto e' grande il cluster che si ottiene con cluster(2,i)

! iniCluster(  come valore si mette quello di cluster(2,i) ) indica in che riga della nuova lista pare il cluster
! finCluster  idem come sopra ma per la fine del clsuter. (ricorda che cluster(2,i) fornisce l'indice del cluster)
! excl  = cluster del ciclo esterno
! incl  = cluster del ciclo interno

Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata

if(idisc == 1) then
  pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0!
  val_discords =0.d0
endif


if (idisc.eq.1) write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo


!if (idisc.eq.1) call preRiscaldamento 
!if (idisc.eq.1) &

esterno=0
do excl=1, maxval(cluster(2,:))    ! gira sui cluster, partendo dai piu' piccoli, di granzezza 1  ! ciclo esterno
                                   ! parte dai piu' piccoli perche' l'array cluster e' stato ordinato per grandezza
   if (cluster(3,excl) .eq. 0 )   cycle ! per ragioni tecniche possono esserci cluster di 0 oggetti: evitali
   do  k1 = iniCluster(excl), finCluster(excl)  ! gira sulle sequenze all'interno del cluster (iniCluster di una sequenza, data nell'ordine di apparizione)

 !  write(69,*) k1 , cluster(1,k1),  iniCluster(excl), finCluster(excl)

!============= LEGENDA ======================
!  dist = NND attuale della sequenza, occhio che migliora tra le varie subroutine
!  dist0  distanza calcolata in un ciclo di una singola subroutine tra la sequenza e un'altra sequenza
!  bestDist massimo valore degli NND tra tutte le sequenze calcolate fino a quel momento 
!  NND  = array che ad ogni sequenza  associa il valore dell'NND calcolato fino a quel momento
!============= fine LEGENDA =================

      can_be_discord = .TRUE.  ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist           = 100000000.d0   ! numero grande superiore a ogni possibile distanza
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

esterno = esterno+1
                     call Situazione(esterno, idisc)                
if (idisc.gt.1)      &
                     call velocizza_Nesimo_discord (     k1,  dist, bestDist)   ! evita di controllare ulteriormente se sai che non puo' essere discord per calcoli con 1mo discord
if (can_be_discord)  call cluster_corrente         (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente
if (can_be_discord)  call HS_tutti_altri_cluster   (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)


    
      if (dist.gt. bestDist .and. can_be_discord) then    ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                              ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = cluster(1,k1)                    ! best disc 
      endif 
      

      NND(cluster(1,k1)) = dist ! si segna il valore della NND approssimata
                                 ! relativa alla sequenza iniziante in cluster(1,k1)
      

!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------
   enddo

enddo

             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord

             if (idisc.eq.Nd) then 
               do i=1, size(NND)
                  !write(127,*) i+ update_period * (ianal-1), NND(i), pos_nei(i), pos_nei2(i), NND2(i)
                  write(127,*) i+ update_period * (ianal-1), NND(i), & 
                      pos_nei(i)+ update_period * (ianal-1), pos_nei2(i), NND2(i)
               enddo
             endif

!write(*,*) ' ========================================================='
!write(126,1481) iDiscord + update_period * (ianal-1),  bestDist, Q3+delta*IQ, Q3tot+delta*IQtot  , Q3tot, Q1tot
!1481 format (  i9,x,5(f10.5,3x) ) 
!write(*,*) ' ========================================================='

end subroutine HSstandard

!---------------------------------------------------------------------




!---------------------------------------------------------------------

subroutine HSstandard_selfMatch(idisc, ianal)! come HSstandard, ma qui misura le distanze con i self match POSSIBILI
implicit none                                ! in pratica ho tolto i controlli al momento delle distanze in  
integer :: i, j, k, excl, incl, k1,k2 , k3   ! cluster corrente e tutti gli altri cluster (e nelle distanze)I
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc
integer :: esterno

! ho un problema, ho ordinato secondo i cluster, ma se sono a meta' strada del
! cluster vorrei poter girare su tutto il cluster stesso. Ho bisogno quindi di
! sapere dove comincia  e dove finisce sto cluster.  Fatto nella subroutinE limiti_cluster
! e fare il ciclo interno a partire da dove comincia il cluster. Poi il ciclo interno continua
! da dove il cluster era finito.

! i cicli vengono suddivisi in cluster, nel senso che si gira sui cluster e poi sul loro contenuto

! la logica degli indici e' la seguente, ho riordinato l'indice di partenza di tutte le sequenze
! in una lista dove:
! cluster(1,i) e' l'indice di partenza della sequenza per come arriva, per esempio cluster(1,10)=243 
! dice che la decima sequenza nella mia lista e' la sequeunza 243 come ordine temporale
! cluster(2,i) e' l'indice del cluster
! cluster(3,i) dice quanto e' grande il cluster che si ottiene con cluster(2,i)

! iniCluster(  come valore si mette quello di cluster(2,i) ) indica in che riga della nuova lista pare il cluster
! finCluster  idem come sopra ma per la fine del clsuter. (ricorda che cluster(2,i) fornisce l'indice del cluster)
! excl  = cluster del ciclo esterno
! incl  = cluster del ciclo interno

Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata

if(idisc == 1) then
  pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0!
  val_discords =0.d0
endif


if (idisc.eq.1) write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo


!if (idisc.eq.1) call preRiscaldamento 
!if (idisc.eq.1) &

esterno=0
do excl=1, maxval(cluster(2,:))    ! gira sui cluster, partendo dai piu' piccoli, di granzezza 1  ! ciclo esterno
                                   ! parte dai piu' piccoli perche' l'array cluster e' stato ordinato per grandezza
   if (cluster(3,excl) .eq. 0 )   cycle ! per ragioni tecniche possono esserci cluster di 0 oggetti: evitali
   do  k1 = iniCluster(excl), finCluster(excl)  ! gira sulle sequenze all'interno del cluster (iniCluster di una sequenza, data nell'ordine di apparizione)

!============= LEGENDA ======================
!  dist = NND attuale della sequenza, occhio che migliora tra le varie subroutine
!  dist0  distanza calcolata in un ciclo di una singola subroutine tra la sequenza e un'altra sequenza
!  bestDist massimo valore degli NND tra tutte le sequenze calcolate fino a quel momento 
!  NND  = array che ad ogni sequenza  associa il valore dell'NND calcolato fino a quel momento
!============= fine LEGENDA =================

      can_be_discord = .TRUE.  ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist           = 100000000.d0   ! numero grande superiore a ogni possibile distanza
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

esterno = esterno+1
                     call Situazione(esterno, idisc)                
if (idisc.gt.1)      &
                     call velocizza_Nesimo_discord_selfMatch (     k1,  dist, bestDist)   ! evita di controllare ulteriormente se sai che non puo' essere discord per calcoli con 1mo discord
if (can_be_discord)  call         cluster_corrente_selfMatch (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente
if (can_be_discord)  call   HS_tutti_altri_cluster_selfMatch (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)


    
      if (dist.gt. bestDist .and. can_be_discord) then    ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                              ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = cluster(1,k1)                    ! best disc 
      endif 
      

      NND(cluster(1,k1)) = dist ! si segna il valore della NND approssimata
                                 ! relativa alla sequenza iniziante in cluster(1,k1)
      
     !write(69,*) cluster(1,k1) , NND(cluster(1,k1)), excl, cluster(2,k1)
!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------
   enddo


enddo

             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord

             if (idisc.eq.Nd) then 
               do i=1, size(NND)
                  !write(127,*) i+ update_period * (ianal-1), NND(i), pos_nei(i), pos_nei2(i), NND2(i)
                  write(127,*) i+ update_period * (ianal-1), NND(i), & 
                      pos_nei(i)+ update_period * (ianal-1), pos_nei2(i), NND2(i)
               enddo
             endif

!write(*,*) ' ========================================================='
!write(126,1481) iDiscord + update_period * (ianal-1),  bestDist, Q3+delta*IQ, Q3tot+delta*IQtot  , Q3tot, Q1tot
!1481 format (  i9,x,5(f10.5,3x) ) 
!write(*,*) ' ========================================================='

end subroutine HSstandard_selfMatch







!---------------------------------------------------------------------
!---------------------------------------------------------------------

subroutine mioHS(idisc, ianal) ! calcola HotSax invece che con dei goto con una variabile
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist
integer, intent(in) :: ianal,idisc
integer :: esterno

! ho un problema, ho ordinato secondo i cluster, ma se sono a meta' strada del
! cluster vorrei poter girare su tutto il cluster stesso. Ho bisogno quindi di
! sapere dove comincia  e dove finisce sto cluster.  Fatto nella subroutinE limiti_cluster
! e fare il ciclo interno a partire da dove comincia il cluster. Poi il ciclo interno continua
! da dove il cluster era finito.

! i cicli vengono suddivisi in cluster, nel senso che si gira sui cluster e poi sul loro contenuto

! la logica degli indici e' la seguente, ho riordinato l'indice di partenza di tutte le sequenze
! in una lista dove:
! cluster(1,i) e' l'indice di partenza della sequenza per come arriva, per esempio cluster(1,10)=243 
! dice che la decima sequenza nella mia lista e' la sequeunza 243 come ordine temporale
! cluster(2,i) e' l'indice del cluster
! cluster(3,i) dice quanto e' grande il cluster che si ottiene con cluster(2,i)

! iniCluster(  come valore si mette quello di cluster(2,i) ) indica in che riga della nuova lista pare il cluster
! finCluster  idem come sopra ma per la fine del clsuter. (ricorda che cluster(2,i) fornisce l'indice del cluster)
! excl  = cluster del ciclo esterno
! incl  = cluster del ciclo interno

Tora = ianal*update_period + (N-update_period)  ! tempo attuale, contando anche le present queue vecchie

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
seq_analizzata  = .false.  ! a questo punto nessuna sequenza e' stata ancora analizzata

if(idisc == 1) then
  pos_discords =-1000000  ! altrimenti le sequenze iniziali hanno problemi, perche' sono poco distanti da 0!
  val_discords =0.d0
endif


if (idisc.eq.1) write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo


!if (idisc.eq.1) call preRiscaldamento 
!if (idisc.eq.1) &

esterno=0
do excl=1, maxval(cluster(2,:))    ! gira sui cluster, partendo dai piu' piccoli, di granzezza 1  ! ciclo esterno
                                   ! parte dai piu' piccoli perche' l'array cluster e' stato ordinato per grandezza
   if (cluster(3,excl) .eq. 0 )   cycle ! per ragioni tecniche possono esserci cluster di 0 oggetti: evitali
   do  k1 = iniCluster(excl), finCluster(excl)  ! gira sulle sequenze all'interno del cluster (iniCluster di una sequenza, data nell'ordine di apparizione)

 !  write(69,*) k1 , cluster(1,k1),  iniCluster(excl), finCluster(excl)

!============= LEGENDA ======================
!  dist = NND attuale della sequenza, occhio che migliora tra le varie subroutine
!  dist0  distanza calcolata in un ciclo di una singola subroutine tra la sequenza e un'altra sequenza
!  bestDist massimo valore degli NND tra tutte le sequenze calcolate fino a quel momento 
!  NND  = array che ad ogni sequenza  associa il valore dell'NND calcolato fino a quel momento
!============= fine LEGENDA =================

      can_be_discord = .TRUE.  ! in linea di principio qualsiasi sequenza puo' essere un discord
      dist           = 100000000.d0   ! numero grande superiore a ogni possibile distanza
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

esterno = esterno+1
                     call Situazione(esterno, idisc)                
if (idisc.gt.1)      &
                     call velocizza_Nesimo_discord (     k1,  dist, bestDist)   ! evita di controllare ulteriormente se sai che non puo' essere discord per calcoli con 1mo discord
if (can_be_discord)  call cluster_corrente        (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente
if (can_be_discord)  call cluster_correnteP1      (excl,k1,  dist, bestDist)   ! controlla nel cluster corrente (alternativo)

if (can_be_discord)  call cluster_vicini          (excl,k1,  dist, bestDist)     ! controlla negli nnei cluster vicini 
!if (can_be_discord)  call A_tutti_altri_cluster     (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)
!if (can_be_discord)  call Restanti_sequenze     (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)
if (can_be_discord)  call tutti_altri_cluster     (excl,k1,  dist, bestDist) ! controllo sugli altri cluster (HS originale gira a caso io al contrario)


    
      if (dist.gt. bestDist .and. can_be_discord) then    ! se sei arrivato fino a qui potresti essere un discord (se sei troppo vicino agli altri discord no...) 
             bestDist = dist                              ! e' la piu' grande di tutte. Quindi aggiorna la distanza del 
             iDiscord  = cluster(1,k1)                    ! best disc 
      endif 
      

      NND(cluster(1,k1)) = dist ! si segna il valore della NND approssimata
                                 ! relativa alla sequenza iniziante in cluster(1,k1)
      

!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------
   enddo


enddo

             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = bestDist ! NND del idisc-esimo discord

             if (idisc.eq.Nd) then 
               do i=1, size(NND)
                  !write(127,*) i+ update_period * (ianal-1), NND(i), pos_nei(i), pos_nei2(i), NND2(i)
                  write(127,*) i+ update_period * (ianal-1), NND(i), & 
                      pos_nei(i)+ update_period * (ianal-1), pos_nei2(i), NND2(i)
               enddo
             endif

!write(*,*) ' ========================================================='
!write(126,1481) iDiscord + update_period * (ianal-1),  bestDist, Q3+delta*IQ, Q3tot+delta*IQtot  , Q3tot, Q1tot
!1481 format (  i9,x,5(f10.5,3x) ) 
!write(*,*) ' ========================================================='

end subroutine mioHS

!---------------------------------------------------------------------





!----------------------------------------------------------------------------------------



!---------------------------------------------------------------------

subroutine brute(idisc, ianal) ! calcola HotSax invece che con dei goto con una variabile
implicit none
integer :: i, j, k, excl, incl, k1,k2 , k3
integer :: iDiscord, dove, posNeigh
real (kind=8) :: dist, dist0, bestDist, distDisc
integer, intent(in) :: ianal,idisc
logical :: evitaSelfMatch =.TRUE.
!

Tora = ianal*update_period + (N-update_period)  ! tempo attuale

!========================== RICORDA che l'indice delle sequenze e' dato da cluster(1,) ===============
bestDist = 0.d0
idiscord = 0

if(idisc == 1) then
  pos_discords =-10000000 ! per evitare problemi con sequenze vicino a 0 (ma in realta' con brute non ci sono problemi)
  val_discords =0.d0
endif

if (idisc.eq.1) write(126,*) ' cluster trovati',  maxval(cluster(2,:)), 'Fino a= ', iarrivo


!============= LEGENDA ======================
!  dist = NND attuale della sequenza, occhio che migliora tra le varie subroutine
!  dist0  distanza calcolata in un ciclo di una singola subroutine tra la sequenza e un'altra sequenza
!  bestDist massimo valore degli NND tra tutte le sequenze calcolate fino a quel momento 
!  NND  = array che ad ogni sequenza  associa il valore dell'NND calcolato fino a quel momento
!============= fine LEGENDA =================


if (idisc.eq.1) then 
  NND = 10000000.d0 ! inizializzo la nnd ad un valore piu' grande di quanto in realta' possibile
  discords = -1200022 ! l'inizializzazione va fatta una volta per coda, all'inizio posizione discord negativa: qualunque posizione positiva e' migliore
endif 

distDisc = 0.d0

!write(*,*) size(serie), size(serie) -(eXl*lung_parole-1)
!stop 'fgjdgfs'

if (idisc.eq.1) then  ! qui sotto calcolo la NND per tutte le sequenze --------------------
do excl=1, size(serie) -(eXl*lung_parole-1)  ! gira su tutte   le possibili sequenze, ciclo ESTERNO


    !if (excl.ne.54860) cycle
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------
!---------------------- ciclo interno -------------------------------------

   
    call Situazione(excl, idisc) 
    do incl = excl, size(serie) -(eXl*lung_parole-1)  ! gira su tutte   le possibili sequenze, ciclo INTERNO
    !do incl = 1, size(serie) -(eXl*lung_parole-1)  ! gira su tutte   le possibili sequenze, ciclo INTERNO


            if (evitaSelfMatch) then
              if (incl.eq.1) write(*,*) 'Non calcola distanza tra self Match'
              if (  abs( incl - excl ) .lt. lung_seq )  cycle   ! evita i self match
            else
              if (incl.eq.1) write(*,*) '_Calcola_ distanza tra self Match'
              if (  incl .eq. excl )  cycle   ! evita confronti con lo stesso
            endif 




            if (Znorm)       dist = Zdistanza ( incl, excl )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist =  distanza ( incl, excl )   ! usa distanza euclidea semplice




            if (dist .lt. NND(excl) ) then
                pos_nei(excl) = incl                    ! posizione del vicino 
                NND(excl) = dist                       ! se migliore del vicino finora, aggiorna 
            endif   
            if (dist .lt. NND(incl) ) then
                pos_nei(incl) = excl 
                NND(incl) =dist ! fallo anche per l'altra sequenza
            endif
   enddo ! incl

!---------------------- fine ciclo interno ---------------------------------
!---------------------- fine ciclo interno -------------------------------------
!---------------------- fine ciclo interno -------------------------------------

    !write(*,*) NND(excl)   
enddo ! excl



endif ! idisc ==1


!------------ Scrivo su file l'NND (se la faccio dopo la ricerca dei discord --------------

             if (idisc.eq.Nd) then 
               do i=1, size(NND)
                  !write(127,*) i+ update_period * (ianal-1), NND(i), pos_nei(i)
                  write(127,*) i+ update_period * (ianal-1), NND(i), & 
                      pos_nei(i)+ update_period * (ianal-1), pos_nei2(i), NND2(i)

               enddo
             endif


!------------ Qui cerco i discord dato che conosco NND
     if (evitaSelfMatch) then 
        do i=1,  size(serie) -(eXl*lung_parole-1)
           !if (evitaSelfMatch) then                           ! solo se voglio evitare i self match
            if ( any ( abs(discords- i) .lt. lung_seq) ) then ! qui controlla che non sia un self match. 
               dist  = 0.d0 
            else 
           !endif
               dist = NND(i)
               if (dist.gt.distDisc) then
                  distDisc = dist 
                  iDiscord = i
                  jNeighbor = jNeighborLoc 
               endif 
            endif 
        enddo  
     else 
!-------------------------------------------------------------------------------
        do i=1,  size(serie) -(eXl*lung_parole-1)
               dist = NND(i)
               if (dist.gt.distDisc) then
                  distDisc = dist 
                  iDiscord = i
                  jNeighbor = jNeighborLoc 
               endif 
        enddo
      endif 
!--------------------------------------------------------------------------------------------------------

             pos_discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             val_discords(idisc)  = distDisc ! NND del idisc-esimo discord


             discords(idisc)  = iDiscord ! posizione del idisc-esimo discord  
             






end subroutine brute
!---------------------------------------------------------------------
!---------------------------------------------------------------------



subroutine cluster_vicini(excl,k1,   dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(in) :: bestDist 
real(kind=8), intent(inout) ::  dist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2  !, contatore
       !contatore = 1 


       do k=1, nnei   
        incl = bariNei(excl,k) ! cerca sui "nnei" cluster vicini

! -------- questo if esclude la ricerca nei casi in cui i cluster vicini sono troppo lontani
! -------- e quindi non potrebbero contribuire alla diminiuzione della distanza con il vicino
!          if (distanza2 ( serie( cluster(1,k1) :  cluster(1,k1)+lung_seq )  , & 
!              bari(incl,:) ) .gt. dist*3 )  cycle ! evita i cluster che comunque sono piu' lontani della nnd attuale
!--------------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------------

           do k2 = iniCluster(incl), finCluster(incl)


            if (  abs( cluster(1,k1) - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match, la posizione di partenza delle sequenze deve essere piu' distante della lung delle sequenze
            !dist0 = distanza(cluster(1,k1) , cluster(1,k2))
            if (Znorm)       dist0 = Zdistanza ( cluster(1,k1) , cluster(1,k2)   )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1) , cluster(1,k2)   )   ! usa distanza euclidea semplice




!            contatore = contatore +1
            if (dist0 .lt. dist )   then
                    pos_nei2(cluster(1,k1)) = pos_nei(cluster(1,k1))        ! posizione secondo vicino
                    pos_nei(cluster(1,k1)) = cluster(1,k2)                  ! posizione del vicino 
                    dist=dist0

                   if (algoritmo.eq.'mioHS'.or. & 
                       algoritmo.eq.'very'  .or. &  
                       algoritmo.eq.'altro' .or. &  
                       algoritmo.eq.'qzaltro' .or. &  
                       algoritmo.eq.'hsStandard' ) then ! esci appena sei sicuro che non possa essere discord

                     if (dist <= bestDist) then    ! se non puo' essere un discord evita di 
                         can_be_discord = .FALSE.  ! controllare anche su tutti gli altri cluster
                         exit 
                     endif 
                   endif

            endif 
           enddo
       enddo
                  

                     if (dist <= bestDist) then    ! se non puo' essere un discord evita di 
                         can_be_discord = .FALSE.  ! controllare anche su tutti gli altri cluster
                     endif 

!       write(*,*) 'pesantezza cluster vicini', contatore 

end subroutine cluster_vicini


!---------------------------------------------------------------------


!---------------------------------------------------------------------
subroutine A_cluster_corrente(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) :: dist
real(kind=8), intent(in) :: bestDist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2
integer                :: salto
       
      !incl = excl  ! cluster interno = cluster esterno
       incl =posizioneCluster(excl)     
          !write(*,*) k1, incl , iniCluster(incl), finCluster(incl) 
          !write(*,*) incl, posizioneCluster(incl) 
          !stop 'sgdgd' 
         
  
          do k2 = iniCluster(incl), finCluster(incl)    ! gira sullo stesso cluster di k1

            

            seq_analizzata ( cluster(1, k2) ) = .TRUE.  ! questa e' analizzata (quando rifai con cluster_correnteP1, saltala) 

            if (  abs( k1 - cluster(1,k2) ) .le. lung_seq )  cycle   ! evita i self match

            if (Znorm)       dist0 = Zdistanza ( k1, cluster(1,k2) )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( k1, cluster(1,k2) )   ! usa distanza euclidea semplice

 
!-----------------------------------------------------------------------------------------

            if (dist0 .lt. NND(cluster(1,k2)) ) then           ! se e' piu' piccola aggiorna
                    NND(cluster(1,k2)) = dist0                 !
                    pos_nei(cluster(1,k2)) = k1     !
            endif  


            if (dist0 .lt. NND(k1) ) then           ! se e' piu' piccola aggiorna
                    NND(k1) = dist0                 !
                    pos_nei(k1) = cluster(1,k2)     !

            endif  
!------------------------------------------------------------------------------------------

            if (dist0 .lt. dist ) then                                  ! dist e' la NND attuale

                pos_nei(k1) = cluster(1,k2)                  ! posizione del vicino 
                dist=dist0 

                     if (dist <= bestDist) then    ! se non puo' essere un discord evita di 
                         can_be_discord = .FALSE.  ! controllare anche su tutti gli altri cluster
                         exit                      ! esci dal ciclo!
                     endif 


            endif
          enddo


end subroutine A_cluster_corrente
!
!---------------------------------------------------------------------


!---------------------------------------------------------------------
subroutine SM_cluster_corrente(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) :: dist
real(kind=8), intent(in) :: bestDist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2
integer                :: salto
       
       incl =posizioneCluster(excl)     
  
          do k2 = iniCluster(incl), finCluster(incl)    ! gira sullo stesso cluster di k1

            
            seq_analizzata ( cluster(1, k2) ) = .TRUE.  ! questa e' analizzata (quando rifai con cluster_correnteP1, saltala) 

            if (  abs( k1 - cluster(1,k2) ) .eq. 0 )  cycle   ! evita se stesso

            if (Znorm)       dist0 = Zdistanza ( k1, cluster(1,k2) )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( k1, cluster(1,k2) )   ! usa distanza euclidea semplice

!-----------------------------------------------------------------------------------------

            if (dist0 .lt. NND(cluster(1,k2)) ) then           ! se e' piu' piccola aggiorna
                    NND(cluster(1,k2)) = dist0                 !
                    pos_nei(cluster(1,k2)) = k1     !
            endif  


            if (dist0 .lt. NND(k1) ) then           ! se e' piu' piccola aggiorna
                    NND(k1) = dist0                 !
                    pos_nei(k1) = cluster(1,k2)     !

            endif  
!------------------------------------------------------------------------------------------

            if (dist0 .lt. dist ) then                                  ! dist e' la NND attuale

                pos_nei(k1) = cluster(1,k2)                  ! posizione del vicino 
                dist=dist0 

                     if (dist <= bestDist) then    ! se non puo' essere un discord evita di 
                         can_be_discord = .FALSE.  ! controllare anche su tutti gli altri cluster
                         exit                      ! esci dal ciclo!
                     endif 


            endif
          enddo


end subroutine SM_cluster_corrente
!
!---------------------------------------------------------------------




!---------------------------------------------------------------------





!---------------------------------------------------------------------
subroutine V_cluster_corrente(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) :: dist
real(kind=8), intent(in) :: bestDist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2
integer                :: salto
       
      incl = excl  ! cluster interno = cluster esterno
              
          do k2 = iniCluster(incl), finCluster(incl)    ! gira sullo stesso cluster di k1
          !do k2 = k1, finCluster(incl)    ! gira sullo stesso cluster di k1

           ! write(*,*) cluster(1,k2), 'corrente'

            seq_analizzata ( cluster(1, k2) ) = .TRUE.  ! questa e' analizzata (quando rifai con cluster_correnteP1, saltala) 

            if (  abs( cluster(1,k1) - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match

            !dist0                 = Zdistanza ( cluster(1,k1), cluster(1,k2))                     ! calcola la distanza 
            if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), cluster(1,k2) )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), cluster(1,k2) )   ! usa distanza euclidea semplice



            !if (gia(cluster(1,k1), cluster(1,k2) ) ) inutili=inutili+1  ! debugging
            !gia(cluster(1,k1), cluster(1,k2) ) = .true. ! debugging

 
!-----------------------------------------------------------------------------------------
            if (NND2(cluster(1,k1)) .gt. dist0  .and. & 
                 dist0 .gt. NND(cluster(1,k1))  .and. & 
                            NND(cluster(1,k1)).gt.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k1)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k1)) = cluster(1,k2)
            endif  

            if (NND2(cluster(1,k2)) .gt. dist0  .and. & 
                              dist0 .gt. NND(cluster(1,k2)) .and. & 
                              NND(cluster(1,k2)).ne.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k2)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k2)) = cluster(1,k1)
            endif  
!-----------------------------------------------------------------------------------------

            if (dist0 .lt. NND(cluster(1,k2)) ) then           ! se e' piu' piccola aggiorna
                    NND(cluster(1,k2)) = dist0                 !
                    pos_nei(cluster(1,k2)) = cluster(1,k1)     !
            endif  


            if (dist0 .lt. NND(cluster(1,k1)) ) then           ! se e' piu' piccola aggiorna
                    NND(cluster(1,k1)) = dist0                 !
                    pos_nei(cluster(1,k1)) = cluster(1,k2)     !

            endif  
!------------------------------------------------------------------------------------------

            if (dist0 .lt. dist ) then                                  ! dist e' la NND attuale

                pos_nei(cluster(1,k1)) = cluster(1,k2)                  ! posizione del vicino 
                dist=dist0 

                     if (dist <= bestDist) then    ! se non puo' essere un discord evita di 
                         can_be_discord = .FALSE.  ! controllare anche su tutti gli altri cluster
                         exit                      ! esci dal ciclo!
                     endif 


            endif
          enddo


end subroutine V_cluster_corrente
!
!---------------------------------------------------------------------
!---------------------------------------------------------------------


!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
subroutine cluster_corrente_selfMatch(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) :: dist
real(kind=8), intent(in) :: bestDist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2
integer                :: salto
integer                :: quanteCall
       
      quanteCall = 0 
      incl = excl  ! cluster interno = cluster esterno
              
          do k2 = iniCluster(incl), finCluster(incl)    ! gira sullo stesso cluster di k1

            seq_analizzata ( cluster(1, k2) ) = .TRUE.  ! questa e' analizzata (quando rifai con cluster_correnteP1, saltala) 

            if (  abs( cluster(1,k1) - cluster(1,k2) ) .eq. 0 )  cycle   ! evita se stessa.

            if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), cluster(1,k2) )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), cluster(1,k2) )   ! usa distanza euclidea semplice
            quanteCall = quanteCall +1
 
            
!-----------------------------------------------------------------------------------------
            if (NND2(cluster(1,k1)) .gt. dist0  .and. & 
                 dist0 .gt. NND(cluster(1,k1))  .and. & 
                            NND(cluster(1,k1)).gt.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k1)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k1)) = cluster(1,k2)
            endif  

            if (NND2(cluster(1,k2)) .gt. dist0  .and. & 
                              dist0 .gt. NND(cluster(1,k2)) .and. & 
                              NND(cluster(1,k2)).ne.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k2)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k2)) = cluster(1,k1)
            endif  
!-----------------------------------------------------------------------------------------

            if (dist0 .lt. dist ) then                                  ! dist e' la NND attuale

                pos_nei(cluster(1,k1)) = cluster(1,k2)                  ! posizione del vicino 
                dist=dist0 

                     if (dist <= bestDist) then    ! se non puo' essere un discord evita di 
                         can_be_discord = .FALSE.  ! controllare anche su tutti gli altri cluster
                         exit                      ! esci dal ciclo!
                     endif 

            endif
          enddo


end subroutine cluster_corrente_selfMatch!
!---------------------------------------------------------------------


!---------------------------------------------------------------------
subroutine motif_cluster_corrente(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) :: dist
real(kind=8), intent(in) :: bestDist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2
integer                :: salto
integer                :: quanteCall
       
      quanteCall = 0 
      incl = excl  ! cluster interno = cluster esterno
              
          do k2 = iniCluster(incl), finCluster(incl)    ! gira sullo stesso cluster di k1

            seq_analizzata ( cluster(1, k2) ) = .TRUE.  ! questa e' analizzata (quando rifai con cluster_correnteP1, saltala) 

            if (  abs( cluster(1,k1) - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match

            !dist0 = distanza(cluster(1,k1) , cluster(1,k2))                     ! calcola la distanza 
            if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), cluster(1,k2) )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), cluster(1,k2) )   ! usa distanza euclidea semplice
            quanteCall = quanteCall +1
 
            
!-----------------------------------------------------------------------------------------

            if (dist0 .lt. dist ) then                                  ! dist e' la NND attuale

                pos_nei(cluster(1,k1)) = cluster(1,k2)                  ! posizione del vicino 
                dist=dist0 



            endif
          enddo


end subroutine motif_cluster_corrente!
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
subroutine cluster_corrente(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) :: dist
real(kind=8), intent(in) :: bestDist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2
integer                :: salto
integer                :: quanteCall
       
      quanteCall = 0 
      incl = excl  ! cluster interno = cluster esterno
              
          do k2 = iniCluster(incl), finCluster(incl)    ! gira sullo stesso cluster di k1

            seq_analizzata ( cluster(1, k2) ) = .TRUE.  ! questa e' analizzata (quando rifai con cluster_correnteP1, saltala) 

            if (  abs( cluster(1,k1) - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match

            !dist0 = distanza(cluster(1,k1) , cluster(1,k2))                     ! calcola la distanza 
            if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), cluster(1,k2) )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), cluster(1,k2) )   ! usa distanza euclidea semplice
            quanteCall = quanteCall +1
 
            !write(*,*) posizioneRegistro( cluster(1,k1) ),  posizioneRegistro( cluster(1,k2))
            !write(74,*)  cluster(1,k1) , cluster(1,k2), dist0, excl,iniCluster(incl), finCluster(incl)
            
!-----------------------------------------------------------------------------------------
            if (NND2(cluster(1,k1)) .gt. dist0  .and. & 
                 dist0 .gt. NND(cluster(1,k1))  .and. & 
                            NND(cluster(1,k1)).gt.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k1)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k1)) = cluster(1,k2)
            endif  

            if (NND2(cluster(1,k2)) .gt. dist0  .and. & 
                              dist0 .gt. NND(cluster(1,k2)) .and. & 
                              NND(cluster(1,k2)).ne.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k2)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k2)) = cluster(1,k1)
            endif  
!-----------------------------------------------------------------------------------------

            !if (dist0 .lt. NND(cluster(1,k2)) ) then            ! se e' piu' piccola aggiorna
            !        NND(cluster(1,k2)) = dist0                 !
            !        pos_nei(cluster(1,k2)) = cluster(1,k1)     !
            !endif  


            if (dist0 .lt. dist ) then                                  ! dist e' la NND attuale

                pos_nei(cluster(1,k1)) = cluster(1,k2)                  ! posizione del vicino 
                dist=dist0 

                   if (algoritmo.eq.'mioHS'.or. & 
                       algoritmo.eq.'very'  .or. &  
                       algoritmo.eq.'altro' .or. &
                       algoritmo.eq.'qzaltro' .or. &
                       algoritmo.eq.'hsStandard' ) then ! esci appena sei sicuro che non possa essere discord

                     if (dist <= bestDist) then    ! se non puo' essere un discord evita di 
                         can_be_discord = .FALSE.  ! controllare anche su tutti gli altri cluster
                         exit                      ! esci dal ciclo!
                     endif 
                   endif


            endif
          enddo


end subroutine cluster_corrente!
!---------------------------------------------------------------------



!---------------------------------------------------------------------
subroutine sod_cluster_corrente(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) :: dist
real(kind=8), intent(in) :: bestDist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2
integer                :: salto
integer                :: quanteCall

   
      quanteCall = 0 
      incl = excl  ! cluster interno = cluster esterno
              
          do k2 = iniCluster(incl), finCluster(incl)    ! gira sullo stesso cluster di k1

            seq_analizzata ( cluster(1, k2) ) = .TRUE.  ! questa e' analizzata (quando rifai con cluster_correnteP1, saltala) 

            if (  abs( cluster(1,k1) - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match

            !dist0 = distanza(cluster(1,k1) , cluster(1,k2))                     ! calcola la distanza 
            if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), cluster(1,k2) )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), cluster(1,k2) )   ! usa distanza euclidea semplice
            quanteCall = quanteCall +1
 
!--------------------------------------------------------------------------------------------------

            if (siNNDk) then
             call riempi_NNDk(  cluster(1,k1), cluster(1,k2), dist0)  !k-esimo vicino
             call riempi_NNDk(  cluster(1,k2), cluster(1,k1), dist0)  !k-esimo vicino
            endif 
!--------------------------------------------------------------------------------------------------

            if (dist0 .lt. dist ) then                                  ! dist e' la NND attuale

                pos_nei(cluster(1,k1)) = cluster(1,k2)                  ! posizione del vicino 
                dist=dist0 

            endif

            if (dist0 .lt. nnd( cluster(1,k2))) then
                pos_nei(cluster(1,k2)) = cluster(1,k1)                  ! posizione del vicino 
                nnd( cluster(1,k2)) = dist0
            endif  


          enddo


end subroutine sod_cluster_corrente!
!---------------------------------------------------------------------



subroutine riempi_NNDk(sequenza1, sequenza2, dist0)
implicit none
integer, intent(in) :: sequenza1, sequenza2
real (kind=8), intent(in) :: dist0
integer :: i, j, k

            do i=1,kmax
               if (NNDk(sequenza1,i).gt. dist0 .and.      & ! il nuovo nnd e' piu' piccolo dell'attuale, ma piu'
                   NNDk(sequenza1,i-1).lt. dist0  ) then    ! grande del precedente. Nota che NNDk(i,0) = -1 
                    
                    NNDk(sequenza1, i+1:kmax) = NNDk(sequenza1, i:kmax-1)     !muovi punti dipo e espelli l'ultimo
                 pos_neik(sequenza1, i+1:kmax) = pos_neik(sequenza1,i:kmax-1) ! idem

                       NNDk(sequenza1,i) = dist0
                   pos_neik(sequenza1,i) = sequenza2
                   !write(100,*) sequenza1, (NNDk(sequenza1, k) , k=1,kmax), dist0
                   exit  ! non li deve copiare tutti
               endif 
            enddo


end subroutine riempi_NNDk


!---------------------------------------------------------------------
subroutine sod_cluster_correnteP1(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) :: dist
real(kind=8), intent(in) :: bestDist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2
integer                :: salto

      ! incl = excl  ! cluster interno = cluster esterno
      ! incl deve essere il cluster che contiene la sequenza che inizia in cluster(1,k1)
      ! nella seconda clusterizzazione

      !if (algoritmo.ne.'sod') return ! se vuoi fare solo hotsax, salta questa subroutine


      incl = posizioneRegistro( cluster(1, k1)  )  !     dato l'indice di inizio della sequenza cluster(1,k1), trovo il suo cluster, 
                                                   !     occhio che nella seconda trasformazione simbolica, il riordino e' fatto 
                                                   !     non sulla dimensione ma proprio sull'indice di cluster.

          !write(57,*) k1, cluster(1,k1), incl  
          

          do k2 = iniClusterP1(incl), finClusterP1(incl)  ! gira sullo stesso cluster di k1

            if ( seq_analizzata( clusterP1(1, k2)) )  then
                       seq_analizzata( clusterP1(1, k2)) = .FALSE. ! la prox volta potrebbe servire
                       cycle  ! non calcolare un'altra volta 
            endif 



            if (  abs( cluster(1,k1) - clusterP1(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match

            !dist0 = distanza(cluster(1,k1) , clusterP1(1,k2))
            if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), clusterP1(1,k2) )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), clusterP1(1,k2) )   ! usa distanza euclidea semplice

!--------------------------------------------------------------------------------------------

            if (siNNDk) then
              call riempi_NNDk(  cluster(1,k1), clusterP1(1,k2), dist0)  !k-esimo vicino
              call riempi_NNDk(  clusterP1(1,k2), cluster(1,k1), dist0)  !k-esimo vicino
            endif
!--------------------------------------------------------------------------------------------

            if (dist0 .lt. dist ) then
                pos_nei(cluster(1,k1)) = clusterP1(1,k2)                  ! posizione del vicino 
                dist=dist0 

            endif

            if (dist0 .lt. nnd( clusterP1(1,k2))) then
                pos_nei(clusterP1(1,k2)) = clusterP1(1,k1)                  ! posizione del vicino 
                nnd( clusterP1(1,k2)) = dist0
            endif  

          enddo

 
end subroutine sod_cluster_correnteP1
!---------------------------------------------------------------------







!---------------------------------------------------------------------
!---------------------------------------------------------------------
subroutine cluster_correnteP1(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) :: dist
real(kind=8), intent(in) :: bestDist
real(kind=8) :: dist0
integer                :: incl
integer                :: k, k2
integer                :: salto

      ! incl = excl  ! cluster interno = cluster esterno
      ! incl deve essere il cluster che contiene la sequenza che inizia in cluster(1,k1)
      ! nella seconda clusterizzazione




      if (algoritmo.ne.'sod') return ! se vuoi fare solo hotsax, salta questa subroutine


      incl = posizioneRegistro( cluster(1, k1)  )  !     dato l'indice di inizio della sequenza cluster(1,k1), trovo il suo cluster, 
                                                   !     occhio che nella seconda trasformazione simbolica, il riordino e' fatto 
                                                   !     non sulla dimensione ma proprio sull'indice di cluster.

          !write(57,*) k1, cluster(1,k1), incl  
          

          do k2 = iniClusterP1(incl), finClusterP1(incl)  ! gira sullo stesso cluster di k1

            if ( seq_analizzata( clusterP1(1, k2)) )  then
                       seq_analizzata( clusterP1(1, k2)) = .FALSE. ! la prox volta potrebbe servire
                       cycle  ! non calcolare un'altra volta 
            endif 

            
            !if (NND2(cluster(1,k1)) .gt. dist0  .and. dist0 .gt. NND(cluster(1,k1)) ) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente, ma non del max 
            !             NND2(cluster(1,k1)) = dist0 
            !             pos_nei2(cluster(1,k1)) = cluster(1,k2)
            !endif  



            if (  abs( cluster(1,k1) - clusterP1(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match

            !dist0 = distanza(cluster(1,k1) , clusterP1(1,k2))
            if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), clusterP1(1,k2) )   ! usa versione con z-normalizzazione
            if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), clusterP1(1,k2) )   ! usa distanza euclidea semplice



            if (dist0 .lt. dist ) then
                pos_nei(cluster(1,k1)) = clusterP1(1,k2)                  ! posizione del vicino 
                dist=dist0 

                   if (algoritmo.eq.'mioHS'.or. & 
                       algoritmo.eq.'very'  .or. &  
                       algoritmo.eq.'altro' .or. & ! esci appena sei sicuro che non possa essere discord
                       algoritmo.eq.'qzaltro' .or. & ! esci appena sei sicuro che non possa essere discord
                       algoritmo.eq.'hsStandard' ) then ! esci appena sei sicuro che non possa essere discord

                     if (dist <= bestDist) then    ! se non puo' essere un discord evita di 
                         can_be_discord = .FALSE.  ! controllare anche su tutti gli altri cluster
                         exit 
                     endif 
                   endif


            endif
          enddo

 
end subroutine cluster_correnteP1
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
subroutine SM_tutti_altri_cluster(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) ::  dist
real(kind=8), intent(in) ::  bestDist
real(kind=8)::  dist0
integer                :: incl, i
integer                :: k, k2
integer :: quanteVolte  , nelCluster=0 , nelCluster2
integer :: oldFin


quanteVolte = 0

      oldFin = 0


      do incl=1, maxval(cluster(2,:))       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 


         do k2 = iniCluster(incl), finCluster(incl) 

         if (posizioneRegistro(cluster(1,k2)) .eq. excl) exit  !

           if (  abs( k1 - cluster(1,k2) ) .lt. 1 )  cycle   ! evita se stessa

           if (Znorm)       dist0 = Zdistanza ( k1, cluster(1,k2) )   ! usa versione con z-normalizzazione
           if (.not.Znorm)  dist0 =  distanza ( k1, cluster(1,k2) )   ! usa distanza euclidea semplice

           quanteVolte = quanteVolte+1  
!-----------------------------------------------------------------------------------------
            if (NND2(k1) .gt. dist0  .and. & 
                 dist0 .gt. NND(k1)  .and. & 
                            NND(k1).gt.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(k1) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(k1) = cluster(1,k2)
            endif  

            if (NND2(cluster(1,k2)) .gt. dist0  .and. & 
                              dist0 .gt. NND(cluster(1,k2)) .and. & 
                              NND(cluster(1,k2)).ne.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k2)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k2)) = k1
            endif  
!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------

            if (dist0 .lt. NND(cluster(1,k2)) ) then           ! se e' piu' piccola aggiorna
                    NND(cluster(1,k2)) = dist0                 !
                    pos_nei(cluster(1,k2)) = k1     !
            endif  


            if (dist0 .lt. NND(k1) ) then           ! se e' piu' piccola aggiorna
                    NND(k1) = dist0                 !
                    pos_nei(k1) = cluster(1,k2)     !
            endif  
!------------------------------------------------------------------------------------------


           if (dist0 .lt. dist ) then
                    pos_nei(k1) = cluster(1,k2)                  ! posizione del vicino 
                    dist=dist0 
                   if (dist .lt. bestDist) then 
                       can_be_discord = .FALSE.
                       exit                       ! esci dal ciclo interno, sicuramente non e' un discord
                   endif 
           endif 


           if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)

         enddo
      enddo  
     

end subroutine SM_tutti_altri_cluster

!---------------------------------------------------------------------






!---------------------------------------------------------------------
subroutine A_tutti_altri_cluster(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) ::  dist
real(kind=8), intent(in) ::  bestDist
real(kind=8)::  dist0
integer                :: incl, i
integer                :: k, k2
integer :: quanteVolte  , nelCluster=0 , nelCluster2
integer :: oldFin


quanteVolte = 0



      ! k1   e' gia' l'indice della sequenza
      ! excl e' gia' l'indice del cluster della sequenza  

      oldFin = 0


      do incl=1, maxval(cluster(2,:))       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 
      !do incl=maxval(cluster(2,:)), 1, -1       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 

         !if (incl .eq. excl ) cycle   ! SBAGLIATO incl non e' l'indice del cluster ma e' un indice che gira dal primo
         !TROVATO all'ULTIMO. Devo usare invece l'indice di primo ritrovamento, che e' disponibile semplicemente
         !prendendo una sequenza in questo cluster e mettendo il suo valore nel registro! 
         ! con sod questo problema non si pone perche' gira sui cluster partendo dal piu' piccolo come
         ! nel caso del ciclo esterno

         do k2 = iniCluster(incl), finCluster(incl) 

         if (posizioneRegistro(cluster(1,k2)) .eq. excl) exit  !
         ! SPIEGAZIONE:   per sapere in quale cluster siamo (inteso quale e' l'indice di primo ritrovamento del cluster
         ! basta che prendo il primo elemento presente nel cluster e cerco la sua posizione nel Registro, se e' uguale
         ! al valore dell'indice del ciclo esterno allora sono uguali. 

           if (  abs( k1 - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match


           if (Znorm)       dist0 = Zdistanza ( k1, cluster(1,k2) )   ! usa versione con z-normalizzazione
           if (.not.Znorm)  dist0 =  distanza ( k1, cluster(1,k2) )   ! usa distanza euclidea semplice

           quanteVolte = quanteVolte+1  
!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------

            if (dist0 .lt. NND(cluster(1,k2)) ) then           ! se e' piu' piccola aggiorna
                    NND(cluster(1,k2)) = dist0                 !
                    pos_nei(cluster(1,k2)) = k1     !
            endif  


            if (dist0 .lt. NND(k1) ) then           ! se e' piu' piccola aggiorna
                    NND(k1) = dist0                 !
                    pos_nei(k1) = cluster(1,k2)     !
            endif  
!------------------------------------------------------------------------------------------



           if (dist0 .lt. dist ) then
                    pos_nei(k1) = cluster(1,k2)                  ! posizione del vicino 
                    dist=dist0 
                   if (dist .lt. bestDist) then 
                       can_be_discord = .FALSE.
                       exit                       ! esci dal ciclo interno, sicuramente non e' un discord
                       !return
                   endif 
           endif 


           if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)

         enddo


      enddo  
     
      !write(48,*) k1, quanteVolte , pos_nei(k1), nnd(k1), posizioneRegistro(k1), & 
      !        clusterSize( posizioneRegistro(k1) ), can_be_discord, bestDist


end subroutine A_tutti_altri_cluster

!---------------------------------------------------------------------


!---------------------------------------------------------------------
subroutine qzA_tutti_altri_cluster(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) ::  dist
real(kind=8), intent(in) ::  bestDist
real(kind=8)::  dist0
integer                :: incl, i
integer                :: k, k2
integer :: quanteVolte  , nelCluster=0 , nelCluster2
integer :: oldFin


quanteVolte = 0

      ! k1   e' gia' l'indice della sequenza
      ! excl e' gia' l'indice del cluster della sequenza  

      oldFin = 0


      do incl=1, maxval(cluster(2,:))       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 
      !do incl=maxval(cluster(2,:)), 1, -1       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 

         !if (incl .eq. excl ) cycle   ! SBAGLIATO incl non e' l'indice del cluster ma e' un indice che gira dal primo
         !TROVATO all'ULTIMO. Devo usare invece l'indice di primo ritrovamento, che e' disponibile semplicemente
         !prendendo una sequenza in questo cluster e mettendo il suo valore nel registro! 
         ! con sod questo problema non si pone perche' gira sui cluster partendo dal piu' piccolo come
         ! nel caso del ciclo esterno

         if (incl .eq. excl) cycle  ! 

         do k2 = iniCluster(incl), finCluster(incl) 

         !if (posizioneRegistro(cluster(1,k2)) .eq. excl) exit  !

         ! SPIEGAZIONE:   per sapere in quale cluster siamo (inteso quale e' l'indice di primo ritrovamento del cluster
         ! basta che prendo il primo elemento presente nel cluster e cerco la sua posizione nel Registro, se e' uguale
         ! al valore dell'indice del ciclo esterno allora sono uguali. 

           if (  abs( k1 - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match


           if (Znorm)       dist0 = Zdistanza ( k1, cluster(1,k2) )   ! usa versione con z-normalizzazione
           if (.not.Znorm)  dist0 =  distanza ( k1, cluster(1,k2) )   ! usa distanza euclidea semplice

           quanteVolte = quanteVolte+1  
!-----------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------

            if (dist0 .lt. NND(cluster(1,k2)) ) then           ! se e' piu' piccola aggiorna
                    NND(cluster(1,k2)) = dist0                 !
                    pos_nei(cluster(1,k2)) = k1     !
            endif  


            if (dist0 .lt. NND(k1) ) then           ! se e' piu' piccola aggiorna
                    NND(k1) = dist0                 !
                    pos_nei(k1) = cluster(1,k2)     !
            endif  
!------------------------------------------------------------------------------------------



           if (dist0 .lt. dist ) then
                    pos_nei(k1) = cluster(1,k2)                  ! posizione del vicino 
                    dist=dist0 
                   if (dist .lt. bestDist) then 
                       can_be_discord = .FALSE.
                       exit                       ! esci dal ciclo interno, sicuramente non e' un discord
                       !return
                   endif 
           endif 


           if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)

         enddo


      enddo  
     

end subroutine qzA_tutti_altri_cluster

!---------------------------------------------------------------------


!---------------------------------------------------------------------
!---------------------------------------------------------------------





!---------------------------------------------------------------------
subroutine V_tutti_altri_cluster(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) ::  dist
real(kind=8), intent(in) ::  bestDist
real(kind=8)::  dist0
integer                :: incl, i
integer                :: k, k2
integer :: quanteVolte  
quanteVolte = 0



      !do  incl=maxval(cluster(2,:)), 1, -1       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 
      do incl=1, maxval(cluster(2,:))       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 
      !do i=1, maxval(cluster(2,:))       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 
      !   incl = ordineRandomCluster(i)   ! oppure gira in ordine casuale


         if (incl .eq. excl ) cycle   ! non rifare 2 volte il giro sullo stesso cluster


         do k2 = iniCluster(incl), finCluster(incl) 
           if (  abs( cluster(1,k1) - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match

           !dist0                 = Zdistanza ( cluster(1,k1), cluster(1,k2))
           if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), cluster(1,k2) )   ! usa versione con z-normalizzazione
           if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), cluster(1,k2) )   ! usa distanza euclidea semplice


           quanteVolte = quanteVolte+1  
           quanteVoltetot=quanteVolteTot +1
!-----------------------------------------------------------------------------------------
            if (NND2(cluster(1,k1)) .gt. dist0  .and. & 
                 dist0 .gt. NND(cluster(1,k1))  .and. & 
                            NND(cluster(1,k1)).gt.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k1)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k1)) = cluster(1,k2)
            endif  

            if (NND2(cluster(1,k2)) .gt. dist0  .and. & 
                              dist0 .gt. NND(cluster(1,k2)) .and. & 
                              NND(cluster(1,k2)).ne.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k2)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k2)) = cluster(1,k1)
            endif  
!-----------------------------------------------------------------------------------------

          !  if (NND2(cluster(1,k1)) .gt. dist0   .and. dist0 .gt. NND(cluster(1,k1))) then     ! devo migliorare NND2 
          !               NND2(cluster(1,k1)) = dist0 
          !               pos_nei2(cluster(1,k1)) = cluster(1,k2)
          !  endif  

          !  if (NND2(cluster(1,k2)) .gt. dist0  .and. dist0 .gt. NND(cluster(1,k2))) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
          !               NND2(cluster(1,k2)) = dist0                            ! del valore corrente, ma non del max!
          !               pos_nei2(cluster(1,k2)) = cluster(1,k1)
          !  endif  

!-----------------------------------------------------------------------------------------

            if (dist0 .lt. NND(cluster(1,k2)) ) then           ! se e' piu' piccola aggiorna
                    NND(cluster(1,k2)) = dist0                 !
                    pos_nei(cluster(1,k2)) = cluster(1,k1)     !
            endif  


            if (dist0 .lt. NND(cluster(1,k1)) ) then           ! se e' piu' piccola aggiorna
                    NND(cluster(1,k1)) = dist0                 !
                    pos_nei(cluster(1,k1)) = cluster(1,k2)     !
            endif  
!------------------------------------------------------------------------------------------



           if (dist0 .lt. dist ) then
                    pos_nei(cluster(1,k1)) = cluster(1,k2)                  ! posizione del vicino 
                    dist=dist0 
                   if (dist .lt. bestDist) then 
                       can_be_discord = .FALSE.
                       exit                       ! esci dal ciclo interno, sicuramente non e' un discord
                       !return
                   endif 
           endif 


           if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)

         enddo

      enddo  
     
      write(48,*) cluster(1, k1), quanteVolte , pos_nei(cluster(1,k1)), nnd(cluster(1,k1)), can_be_discord, & 
                  clusterSize( posizioneRegistro(cluster(1,k1) ))

       !write(43,*) cluster(1,k1), cluster(2,k1),  NND(cluster(1,k1)), bestDist, pos_nei(cluster(1,k1)), &
       !            quanteVolte, quanteVolteTot 
       


end subroutine V_tutti_altri_cluster

!---------------------------------------------------------------------





!----------------------------------------------------------------------------------------------------------------------------





!---------------------------------------------------------------------
subroutine motif_tutti_altri_cluster(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) ::  dist
real(kind=8), intent(in) ::  bestDist
real(kind=8)::  dist0
integer                :: incl
integer                :: k, k2, sequenza, i
integer :: quanteVolte 
quanteVolte = 0


      do i=1, N-lung_seq+1
           sequenza  = randomSequenze (i) 

           if (posizioneRegistro(sequenza) .eq. excl) cycle  ! Hai gia' controllato il cluster corrente

           if (  abs( cluster(1,k1) - sequenza ) .lt. lung_seq )  cycle   ! evita i self match

           !dist0 = distanza(cluster(1,k1) , sequenza)
           if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), sequenza )   ! usa versione con z-normalizzazione
           if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), sequenza )   ! usa distanza euclidea semplice
           quanteVolte =quanteVolte+1

!-----------------------------------------------------------------------------------------

           if (dist0 .lt. dist ) then
                    pos_nei(cluster(1,k1)) = sequenza                  ! posizione del vicino 
                    dist=dist0 
                   if (dist .lt. bestDist) then 
                       can_be_discord = .FALSE.
                       exit                       ! esci dal ciclo interno, sicuramente non e' un discord
                       !return
                   endif 
           endif 
         !enddo
         if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)


      enddo  
     


end subroutine motif_tutti_altri_cluster

!---------------------------------------------------------------------



!---------------------------------------------------------------------
subroutine HS_tutti_altri_cluster(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) ::  dist
real(kind=8), intent(in) ::  bestDist
real(kind=8)::  dist0
integer                :: incl
integer                :: k, k2, sequenza, i
integer :: quanteVolte 
quanteVolte = 0

      !do incl=1, maxval(cluster(2,:))       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 
       !  if (incl .eq. excl ) cycle   ! non rifare 2 volte il giro sullo stesso cluster
       !  do k2 = iniCluster(incl), finCluster(incl) 


      do i=1, N-lung_seq+1
           sequenza  = randomSequenze (i) 

           if (posizioneRegistro(sequenza) .eq. excl) cycle  ! Hai gia' controllato il cluster corrente

           if (  abs( cluster(1,k1) - sequenza ) .lt. lung_seq )  cycle   ! evita i self match

           !dist0 = distanza(cluster(1,k1) , sequenza)
           if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), sequenza )   ! usa versione con z-normalizzazione
           if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), sequenza )   ! usa distanza euclidea semplice
           quanteVolte =quanteVolte+1

!-----------------------------------------------------------------------------------------
            if (NND2(cluster(1,k1)) .gt. dist0  .and. & 
                 dist0 .gt. NND(cluster(1,k1))  .and. & 
                            NND(cluster(1,k1)).gt.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k1)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k1)) = sequenza
            endif  

            if (NND2(sequenza) .gt. dist0  .and. & 
                              dist0 .gt. NND(sequenza) .and. & 
                              NND(sequenza).ne.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(sequenza) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(sequenza) = cluster(1,k1)
            endif  
!-----------------------------------------------------------------------------------------

          !  if (NND2(cluster(1,k1)) .gt. dist0   .and. dist0 .gt. NND(cluster(1,k1))) then     ! devo migliorare NND2 
          !               NND2(cluster(1,k1)) = dist0 
          !               pos_nei2(cluster(1,k1)) = sequenza
          !  endif  

          !  if (NND2(sequenza) .gt. dist0  .and. dist0 .gt. NND(sequenza)) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
          !               NND2(sequenza) = dist0                            ! del valore corrente, ma non del max!
          !               pos_nei2(sequenza) = cluster(1,k1)
          !  endif  


           if (dist0 .lt. dist ) then
                    pos_nei(cluster(1,k1)) = sequenza                  ! posizione del vicino 
                    dist=dist0 
                   if (dist .lt. bestDist) then 
                       can_be_discord = .FALSE.
                       exit                       ! esci dal ciclo interno, sicuramente non e' un discord
                       !return
                   endif 
           endif 
         !enddo
         if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)


      enddo  
     


end subroutine HS_tutti_altri_cluster

!---------------------------------------------------------------------




!---------------------------------------------------------------------
subroutine HS_tutti_altri_cluster_selfMatch(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) ::  dist
real(kind=8), intent(in) ::  bestDist
real(kind=8)::  dist0
integer                :: incl
integer                :: k, k2, sequenza, i
integer :: quanteVolte 
quanteVolte = 0


      do i=1, N-lung_seq+1
           sequenza  = randomSequenze (i) 

           if (posizioneRegistro(sequenza) .eq. excl) cycle  ! Hai gia' controllato il cluster corrente

           if (  abs( cluster(1,k1) - sequenza ) .eq. 0 )  cycle   ! evita se stessa

           if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), sequenza )   ! usa versione con z-normalizzazione
           if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), sequenza )   ! usa distanza euclidea semplice
           quanteVolte =quanteVolte+1

!-----------------------------------------------------------------------------------------
            if (NND2(cluster(1,k1)) .gt. dist0  .and. & 
                 dist0 .gt. NND(cluster(1,k1))  .and. & 
                            NND(cluster(1,k1)).gt.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k1)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k1)) = sequenza
            endif  

            if (NND2(sequenza) .gt. dist0  .and. & 
                              dist0 .gt. NND(sequenza) .and. & 
                              NND(sequenza).ne.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(sequenza) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(sequenza) = cluster(1,k1)
            endif  
!-----------------------------------------------------------------------------------------

           if (dist0 .lt. dist ) then
                    pos_nei(cluster(1,k1)) = sequenza                  ! posizione del vicino 
                    dist=dist0 
                   if (dist .lt. bestDist) then 
                       can_be_discord = .FALSE.
                       exit                       ! esci dal ciclo interno, sicuramente non e' un discord
                   endif 
           endif 
         if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)


      enddo  
     


end subroutine HS_tutti_altri_cluster_selfMatch

!---------------------------------------------------------------------







!---------------------------------------------------------------------
!---------------------------------------------------------------------
subroutine tutti_altri_cluster(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) ::  dist
real(kind=8), intent(in) ::  bestDist
real(kind=8)::  dist0
integer                :: incl
integer                :: k, k2
integer :: quanteVolte 
quanteVolte = 0

      !do incl=maxval(cluster(2,:)), 1, -1  ! gira sui cluster al contrario, da quelli piu' grossi a quelli piu' piccoli
      do incl=1, maxval(cluster(2,:))       ! oppure gira sui cluster da quelli piu' piccoli a quelli piu' grossi 

         if (incl .eq. excl ) cycle   ! non rifare 2 volte il giro sullo stesso cluster
         do k2 = iniCluster(incl), finCluster(incl) 
           if (  abs( cluster(1,k1) - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match

           !dist0 = distanza(cluster(1,k1) , cluster(1,k2))
           if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), cluster(1,k2) )   ! usa versione con z-normalizzazione
           if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), cluster(1,k2) )   ! usa distanza euclidea semplice
           quanteVolte =quanteVolte+1

!-----------------------------------------------------------------------------------------
            if (NND2(cluster(1,k1)) .gt. dist0  .and. & 
                 dist0 .gt. NND(cluster(1,k1))  .and. & 
                            NND(cluster(1,k1)).gt.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k1)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k1)) = cluster(1,k2)
            endif  

            if (NND2(cluster(1,k2)) .gt. dist0  .and. & 
                              dist0 .gt. NND(cluster(1,k2)) .and. & 
                              NND(cluster(1,k2)).ne.0.d0) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
                         NND2(cluster(1,k2)) = dist0                            ! del valore corrente, ma non del max!
                         pos_nei2(cluster(1,k2)) = cluster(1,k1)
            endif  
!-----------------------------------------------------------------------------------------

          !  if (NND2(cluster(1,k1)) .gt. dist0   .and. dist0 .gt. NND(cluster(1,k1))) then     ! devo migliorare NND2 
          !               NND2(cluster(1,k1)) = dist0 
          !               pos_nei2(cluster(1,k1)) = cluster(1,k2)
          !  endif  

          !  if (NND2(cluster(1,k2)) .gt. dist0  .and. dist0 .gt. NND(cluster(1,k2))) then     ! devo migliorare il II NND, quindi deve essere migliore del valore corrente 
          !               NND2(cluster(1,k2)) = dist0                            ! del valore corrente, ma non del max!
          !               pos_nei2(cluster(1,k2)) = cluster(1,k1)
          !  endif  


           if (dist0 .lt. dist ) then
                    pos_nei(cluster(1,k1)) = cluster(1,k2)                  ! posizione del vicino 
                    dist=dist0 
                   if (dist .lt. bestDist) then 
                       can_be_discord = .FALSE.
                       exit                       ! esci dal ciclo interno, sicuramente non e' un discord
                       !return
                   endif 
           endif 
         enddo
         if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)


      enddo  
     


end subroutine tutti_altri_cluster

!---------------------------------------------------------------------


!---------------------------------------------------------------------
subroutine sod_tutti_altri_cluster(excl,k1,  dist, bestDist)
implicit none
integer, intent(in)    :: k1, excl
real(kind=8), intent(inout) ::  dist
real(kind=8), intent(in) ::  bestDist
real(kind=8)::  dist0
integer                :: incl
integer                :: k, k2
integer :: quanteCall 
quanteCall = 0

      !do incl=maxval(cluster(2,:)), 1, -1  ! con 300_signal1.txt l'approccio a decrescere (con205 000) punti richiede 5M
      do incl=1, maxval(cluster(2,:))     ! di chiamate a distanza in piu' (su circa 480M) rispetto a quello da cluster piccoli agrandi

         if (incl .eq. excl ) cycle   ! non rifare 2 volte il giro sullo stesso cluster
         do k2 = iniCluster(incl), finCluster(incl) 
           if (  abs( cluster(1,k1) - cluster(1,k2) ) .lt. lung_seq )  cycle   ! evita i self match

           if (Znorm)       dist0 = Zdistanza ( cluster(1,k1), cluster(1,k2) )   ! usa versione con z-normalizzazione
           if (.not.Znorm)  dist0 =  distanza ( cluster(1,k1), cluster(1,k2) )   ! usa distanza euclidea semplice
           quanteCall = quanteCall +1 
!-----------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------------------

            if (siNNDk) then
              call riempi_NNDk(  cluster(1,k1), cluster(1,k2), dist0)  !k-esimo vicino
              call riempi_NNDk(  cluster(1,k2), cluster(1,k1), dist0)  !k-esimo vicino
            endif
!--------------------------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------------


            if (dist0 .lt. nnd( cluster(1,k2))) then
                pos_nei(cluster(1,k2)) = cluster(1,k1)                  ! posizione del vicino 
                nnd( cluster(1,k2)) = dist0
            endif  



           if (dist0 .lt. dist ) then
                    pos_nei(cluster(1,k1)) = cluster(1,k2)                  ! posizione del vicino 
                    dist=dist0               !      <============
                   if (dist .lt. bestDist) then 
                       can_be_discord = .FALSE.
                       exit                       ! esci dal ciclo interno, sicuramente non e' un discord
                   endif 
           endif 
          if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)
         enddo

         ! if (.not. can_be_discord) exit  ! non cercare negli altri cluster, non puo' essere discord (non crea problemi a sod, che non sfrutta questa sub piu' di hot sax)

      enddo  
     
      !write(59,*) cluster(1,k1), cluster(3,k1), quanteCall

end subroutine sod_tutti_altri_cluster

!---------------------------------------------------------------------








!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------

subroutine velocizza_Nesimo_discord_selfMatch (k1,   dist, bestDist) ! evita di controllare
implicit none                                         ! le sequenze per cui sappiamo gia' che non possono
integer, intent(in)    :: k1                          ! essere n-simo discord, o perche' sono troppo vicine  
real(kind=8) , intent (in) :: bestDist
real(kind=8), intent(inout) ::  dist
integer                :: incl
integer                :: k, k2
integer, dimension(Nd) :: array_pos_attuale


!--------------  ORIGINALE ----------------------------------------------
            array_pos_attuale = cluster(1,k1)                                     ! costruisco un array con la posizione attuale per confrontarlo, nella riga dopo, con tutti i discord trovati finora
            if ( any ( abs(pos_discords- array_pos_attuale) .eq. 0) ) then ! se sono vicino a qualunque dei discord precedenti, evita di controllare 
                    dist  = NND(cluster(1,k1))                                    ! in questo caso ri-usa la distanza che hai trovato prima (per ipotesi idisc > 1)
                    can_be_discord = .FALSE. 
            endif

            if (NND (cluster(1,k1) ) .lt. bestDist  ) then ! controlla nel registro delle NND approssimate (se sono gia' piu' piccole puoi uscire)
                    dist  = NND(cluster(1,k1) )            ! riutilizziamo come distanza quella gia' trovata
                    can_be_discord = .FALSE.
            endif  
!------------------------------------------------------------------------
end subroutine velocizza_Nesimo_discord_selfMatch 

!-------------------------------------------------------------------------

!---------------------------------------------------------------------
!---------------------------------------------------------------------

subroutine velocizza_Nesimo_discord (k1,   dist, bestDist) ! evita di controllare
implicit none                                         ! le sequenze per cui sappiamo gia' che non possono
integer, intent(in)    :: k1                          ! essere n-simo discord, o perche' sono troppo vicine  
real(kind=8) , intent (in) :: bestDist
real(kind=8), intent(inout) ::  dist
integer                :: incl
integer                :: k, k2
integer, dimension(Nd) :: array_pos_attuale


!--------------  ORIGINALE ----------------------------------------------
            array_pos_attuale = cluster(1,k1)                                     ! costruisco un array con la posizione attuale per confrontarlo, nella riga dopo, con tutti i discord trovati finora
            if ( any ( abs(pos_discords- array_pos_attuale) .lt. lung_seq) ) then ! se sono vicino a qualunque dei discord precedenti, evita di controllare 
                    dist  = NND(cluster(1,k1))                                    ! in questo caso ri-usa la distanza che hai trovato prima (per ipotesi idisc > 1)
                    can_be_discord = .FALSE. 
            endif

            if (NND (cluster(1,k1) ) .lt. bestDist  ) then ! controlla nel registro delle NND approssimate (se sono gia' piu' piccole puoi uscire)
                    dist  = NND(cluster(1,k1) )            ! riutilizziamo come distanza quella gia' trovata
                    can_be_discord = .FALSE.
                    !write(78,*) cluster(1,k1), NND( cluster(1,k1)) , bestDist
            endif

  
!------------------------------------------------------------------------
end subroutine velocizza_Nesimo_discord 

!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------

subroutine V_velocizza_Nesimo_discord (k1,   dist, bestDist) ! evita di controllare
implicit none                                         ! le sequenze per cui sappiamo gia' che non possono
integer, intent(in)    :: k1                          ! essere n-simo discord, o perche' sono troppo vicine  
real(kind=8) , intent (in) :: bestDist
real(kind=8), intent(inout) ::  dist
integer                :: incl
integer                :: k, k2
integer, dimension(Nd) :: array_pos_attuale


!--------------  ORIGINALE ----------------------------------------------
            array_pos_attuale = cluster(1,k1)                                     ! costruisco un array con la posizione attuale per confrontarlo, nella riga dopo, con tutti i discord trovati finora
            if ( any ( abs(pos_discords- array_pos_attuale) .lt. lung_seq) ) then ! se sono vicino a qualunque dei discord precedenti, evita di controllare 
                    dist  = NND(cluster(1,k1))                                    ! in questo caso ri-usa la distanza che hai trovato prima (per ipotesi idisc > 1)
                    can_be_discord = .FALSE. 
            endif

            if (NND (cluster(1,k1) ) .lt. bestDist  ) then ! controlla nel registro delle NND approssimate (se sono gia' piu' piccole puoi uscire)
                    dist  = NND(cluster(1,k1) )            ! riutilizziamo come distanza quella gia' trovata
                    can_be_discord = .FALSE.
            endif  


!------------------------------------------------------------------------
end subroutine V_velocizza_Nesimo_discord 

!-------------------------------------------------------------------------
subroutine A_velocizza_Nesimo_discord (k1,   dist, bestDist) ! evita di controllare
implicit none                                         ! le sequenze per cui sappiamo gia' che non possono
integer, intent(in)    :: k1                          ! essere n-simo discord, o perche' sono troppo vicine  
real(kind=8) , intent (in) :: bestDist
real(kind=8), intent(inout) ::  dist
integer                :: incl
integer                :: k, k2
integer, dimension(Nd) :: array_pos_attuale


!--------------  ORIGINALE ----------------------------------------------
            array_pos_attuale = k1                                     ! costruisco un array con la posizione attuale per confrontarlo, nella riga dopo, con tutti i discord trovati finora
            if ( any ( abs(pos_discords- array_pos_attuale) .lt. lung_seq) ) then ! se sono vicino a qualunque dei discord precedenti, evita di controllare 
                    dist  = NND(k1)                                    ! in questo caso ri-usa la distanza che hai trovato prima (per ipotesi idisc > 1)
                    can_be_discord = .FALSE. 
            endif

            if (NND (k1 ) .lt. bestDist  ) then ! controlla nel registro delle NND approssimate (se sono gia' piu' piccole puoi uscire)
                    dist  = NND(k1 )            ! riutilizziamo come distanza quella gia' trovata
                    can_be_discord = .FALSE.
            endif  


!------------------------------------------------------------------------
end subroutine A_velocizza_Nesimo_discord 
!-------------------------------------------------------------------------

!-------------------------------------------------------------------------
subroutine SM_velocizza_Nesimo_discord (k1,   dist, bestDist, inter , idisc) ! evita di controllare
implicit none                                         ! le sequenze per cui sappiamo gia' che non possono
integer, intent(in)    :: k1                          ! essere n-simo discord, o perche' sono troppo vicine  
real(kind=8) , intent (in) :: bestDist
real(kind=8), intent(inout) ::  dist
integer, intent(in) :: inter, idisc
integer                :: incl
integer                :: k, k2, j
integer, dimension(Nd) :: array_pos_attuale


!--------------  ORIGINALE ----------------------------------------------
           ! write(48,*) i, idisc     
            !if (inter.eq.2)   write(47,*) inter, idisc, (pos_discords(j), j=1,3)


            array_pos_attuale = k1                               ! costruisco un array con la posizione attuale per confrontarlo, nella riga dopo, con tutti i discord trovati finora
            if ( any ( abs(pos_discords- array_pos_attuale) .eq. 0) ) then ! se sono vicino a qualunque dei discord precedenti, evita di controllare 
                    dist  = NND(k1)                                    ! in questo caso ri-usa la distanza che hai trovato prima (per ipotesi idisc > 1)
                    can_be_discord = .FALSE.
            endif

            if (NND (k1 ) .lt. bestDist  ) then ! controlla nel registro delle NND approssimate (se sono gia' piu' piccole puoi uscire)
                    dist  = NND(k1 )            ! riutilizziamo come distanza quella gia' trovata
                    can_be_discord = .FALSE.
            endif  


!------------------------------------------------------------------------
end subroutine SM_velocizza_Nesimo_discord 


!-------------------------------------------------------------------------
!-------------------------------------------------------------------------

!-------------------------------------------------------------------------
subroutine T_velocizza_Nesimo_discord (k1,   dist, bestDist) ! evita di controllare
implicit none                                         ! le sequenze per cui sappiamo gia' che non possono
integer, intent(in)    :: k1                          ! essere n-simo discord, o perche' sono troppo vicine  
real(kind=8) , intent (in) :: bestDist
real(kind=8), intent(inout) ::  dist
integer                :: incl
integer                :: k, k2
integer, dimension(Nd) :: array_pos_attuale


!--------------  ORIGINALE ----------------------------------------------
            array_pos_attuale = clusterP1(1,k1)                                     ! costruisco un array con la posizione attuale per confrontarlo, nella riga dopo, con tutti i discord trovati finora
            if ( any ( abs(pos_discords- array_pos_attuale) .lt. lung_seq) ) then ! se sono vicino a qualunque dei discord precedenti, evita di controllare 
                    dist  = NND(clusterP1(1,k1))                                    ! in questo caso ri-usa la distanza che hai trovato prima (per ipotesi idisc > 1)
                    can_be_discord = .FALSE. 
            endif

            if (NND (clusterP1(1,k1) ) .lt. bestDist  ) then ! controlla nel registro delle NND approssimate (se sono gia' piu' piccole puoi uscire)
                    dist  = NND(clusterP1(1,k1) )            ! riutilizziamo come distanza quella gia' trovata
                    can_be_discord = .FALSE.
            endif  
!------------------------------------------------------------------------
end subroutine T_velocizza_Nesimo_discord 
!------------------------------------------------------------------------


!-----------------------------------------------------------------------------------------
subroutine SM_preRiscaldamento  ! faccio girare tra i cluster in modo da avere delle NND approx da cui partire
implicit none                ! ottenute con elementi dello stesso cluster, quindi potenzialmente piccole
real(kind=8):: distance      ! problema: ci sono molti self match!. Soluzione:  primo ---> ultimo ---> secondo ---> penultimo ....
integer :: i,j,k             ! serve funzione che calcoli, e per esempio eviti se ci sono cluster da 2 elementi


      NND = 100000000000.d0
    

      !write(*,*) N-lung_seq, 'preRiscaldamento'


      do i=1, N - lung_seq   ! siccome calcolo con successivo devo evitare di uscire   
       if (i+2 .gt. N-lung_seq+1) cycle
       if ( abs ( cluster(1,i) - cluster (1,i+1) ) .ge. 1) then  ! evita solo se stesso

         if (Znorm)       distance = Zdistanza ( cluster(1,i), cluster(1,i+1) )   ! usa versione con z-normalizzazione
         if (.not.Znorm)  distance =  distanza ( cluster(1,i), cluster(1,i+1) )   ! usa distanza euclidea semplice


         if ( NND (cluster(1,i)) .gt. distance .or. NND (cluster(1,i)) .eq. 0.d0 )  then
                     NND(cluster(1,i) )= distance
                     pos_nei( cluster(1,i) ) = cluster(1,i+1) 
         endif 
 
         if ( NND (cluster(1,i+1)) .gt. distance .or. NND (cluster(1,i)) .eq. 0.d0 ) then 
                     NND(cluster(1,i+1)) = distance 
                     pos_nei( cluster(1,i+1) ) = cluster(1,i)
         endif
        endif   

       if ( abs ( cluster(1,i) - cluster (1,i+1) ) .lt. lung_seq) then  ! se il successivo e' un self match

         if ( abs ( cluster(1,i) - cluster (1,i+2) ) .lt. lung_seq) then  ! ma il +2 funge...
          cycle  ! salta e non calcolare la distanza
         endif

       
         if (Znorm)       distance = Zdistanza ( cluster(1,i), cluster(1,i+2) )   ! usa versione con z-normalizzazione
         if (.not.Znorm)  distance =  distanza ( cluster(1,i), cluster(1,i+2) )   ! usa distanza euclidea semplice

         if ( NND (cluster(1,i+2)) .gt. distance .or. NND (cluster(1,i)) .eq. 0.d0 ) then 
                     NND(cluster(1,i+2)) = distance 
                     pos_nei( cluster(1,i+2) ) = cluster(1,i)
         endif
       endif  


      enddo  

      write(*,*) 'Pre riscaldamento', chiamateAdistanza

       

end subroutine SM_preRiscaldamento






!-----------------------------------------------------------------------------------------
subroutine A_preRiscaldamento  ! faccio girare tra i cluster in modo da avere delle NND approx da cui partire
implicit none                ! ottenute con elementi dello stesso cluster, quindi potenzialmente piccole
real(kind=8):: distance      ! problema: ci sono molti self match!. Soluzione:  primo ---> ultimo ---> secondo ---> penultimo ....
integer :: i,j,k             ! serve funzione che calcoli, e per esempio eviti se ci sono cluster da 2 elementi


      NND = 100000000000.d0
    

      !write(*,*) N-lung_seq, 'preRiscaldamento'


      do i=1, N - lung_seq   ! siccome calcolo con successivo devo evitare di uscire   
       if (i+2 .gt. N-lung_seq+1) cycle
       if ( abs ( cluster(1,i) - cluster (1,i+1) ) .ge. lung_seq) then  ! evita i self-match

         !distance = distanza ( cluster(1,i), cluster(1,i+1) ) 
         if (Znorm)       distance = Zdistanza ( cluster(1,i), cluster(1,i+1) )   ! usa versione con z-normalizzazione
         if (.not.Znorm)  distance =  distanza ( cluster(1,i), cluster(1,i+1) )   ! usa distanza euclidea semplice


         if ( NND (cluster(1,i)) .gt. distance .or. NND (cluster(1,i)) .eq. 0.d0 )  then
                     NND(cluster(1,i) )= distance
                     pos_nei( cluster(1,i) ) = cluster(1,i+1) 
         endif 
 
         if ( NND (cluster(1,i+1)) .gt. distance .or. NND (cluster(1,i)) .eq. 0.d0 ) then 
                     NND(cluster(1,i+1)) = distance 
                     pos_nei( cluster(1,i+1) ) = cluster(1,i)
         endif
        endif   

       if ( abs ( cluster(1,i) - cluster (1,i+1) ) .lt. lung_seq) then  ! se il successivo e' un self match

        if ( abs ( cluster(1,i) - cluster (1,i+2) ) .lt. lung_seq) then  ! ma il +2 funge...
           cycle  ! salta e non calcolare la distanza
        endif

       
         !distance = distanza ( cluster(1,i), cluster(1,i+2) ) 
         if (Znorm)       distance = Zdistanza ( cluster(1,i), cluster(1,i+2) )   ! usa versione con z-normalizzazione
         if (.not.Znorm)  distance =  distanza ( cluster(1,i), cluster(1,i+2) )   ! usa distanza euclidea semplice

         if ( NND (cluster(1,i+2)) .gt. distance .or. NND (cluster(1,i)) .eq. 0.d0 ) then 
                     NND(cluster(1,i+2)) = distance 
                     pos_nei( cluster(1,i+2) ) = cluster(1,i)
         endif
        endif  


      enddo  





      write(*,*) 'Pre riscaldamento', chiamateAdistanza


!-------- faccio un secondo calcolo con piu' parole:
!------------------------------------------------------------------------------------
!      do i=1, N - lung_seq   ! siccome calcolo con successivo devo evitare di uscire   
!        if ( abs ( clusterD(1,i) - clusterD (1,i+1) ) .le. lung_seq)  cycle  ! salta i self match e non calcolare la distanza
!    
!        distance = distanza ( clusterD(1,i), clusterD(1,i+1) ) 
!        if ( NND (clusterD(1,i)) .gt. distance .or. NND (clusterD(1,i)) .eq. 0.d0 )  then
!                    NND(clusterD(1,i) )= distance
!                    pos_nei( clusterD(1,i) ) = clusterD(1,i+1) 
!        endif  
!        if ( NND (clusterD(1,i+1)) .gt. distance .or. NND (clusterD(1,i)) .eq. 0.d0 ) then 
!                    NND(clusterD(1,i+1)) = distance 
!                    pos_nei( clusterD(1,i+1) ) = clusterD(1,i)
!        endif   
!      enddo  
!-------------------------------------------------------------------------------------





!-------------------------------------------------------------------------------------       
  !  do k=1,nRiordini
  !    do i=1, N - lung_seq   ! siccome calcolo con successivo devo evitare di uscire   
  !      if ( abs ( clusterN(1,i,k) - clusterN(1,i+1,k) ) .le. lung_seq)    cycle  ! evita self-match salta e non calcolare la distanza

  !       distance = distanza ( clusterN(1,i,k), clusterN(1,i+1,k) ) 

  !       if ( NND (clusterN(1,i,k)) .gt. distance )  then
  !                  NND(clusterN(1,i,k) )= distance
  !                  pos_nei( clusterN(1,i,k) ) = clusterN(1,i+1,k) 
  !      endif 
 
  !      if ( NND (clusterN(1,i+1,k)) .gt. distance ) then 
  !                  NND(clusterN(1,i+1,k)) = distance 
  !                  pos_nei( clusterN(1,i+1,k) ) = clusterN(1,i,k)
  !      endif  
  !    enddo  
  !  enddo  
!-------------------------------------------------------------------------------------

       

end subroutine A_preRiscaldamento


!-------------------------------------------------------------------------------------


!-----------------------------------------------------------------------------------------
subroutine preRiscaldamento  ! faccio girare tra i cluster in modo da avere delle NND approx da cui partire
implicit none                ! ottenute con elementi dello stesso cluster, quindi potenzialmente piccole
real(kind=8):: distance      ! problema: ci sono molti self match!. Soluzione:  primo ---> ultimo ---> secondo ---> penultimo ....
integer :: i,j,k             ! serve funzione che calcoli, e per esempio eviti se ci sono cluster da 2 elementi


      NND = 100000000000.d0
    

      !write(*,*) N-lung_seq, 'preRiscaldamento'


      do i=1, N - lung_seq   ! siccome calcolo con successivo devo evitare di uscire   
        if ( abs ( cluster(1,i) - cluster (1,i+1) ) .lt. lung_seq) then  ! evita i self-match
           cycle  ! salta e non calcolare la distanza
        endif

        !distance = distanza ( cluster(1,i), cluster(1,i+1) ) 
        if (Znorm)       distance = Zdistanza ( cluster(1,i), cluster(1,i+1) )   ! usa versione con z-normalizzazione
        if (.not.Znorm)  distance =  distanza ( cluster(1,i), cluster(1,i+1) )   ! usa distanza euclidea semplice


        if ( NND (cluster(1,i)) .gt. distance .or. NND (cluster(1,i)) .eq. 0.d0 )  then
                    NND(cluster(1,i) )= distance
                    pos_nei( cluster(1,i) ) = cluster(1,i+1) 
        endif 
 
        if ( NND (cluster(1,i+1)) .gt. distance .or. NND (cluster(1,i)) .eq. 0.d0 ) then 
                    NND(cluster(1,i+1)) = distance 
                    pos_nei( cluster(1,i+1) ) = cluster(1,i)
        endif   
      enddo  

      write(*,*) 'Pre riscaldamento', chiamateAdistanza


!-------- faccio un secondo calcolo con piu' parole:
!------------------------------------------------------------------------------------
!      do i=1, N - lung_seq   ! siccome calcolo con successivo devo evitare di uscire   
!        if ( abs ( clusterD(1,i) - clusterD (1,i+1) ) .le. lung_seq)  cycle  ! salta i self match e non calcolare la distanza
!    
!        distance = distanza ( clusterD(1,i), clusterD(1,i+1) ) 
!        if ( NND (clusterD(1,i)) .gt. distance .or. NND (clusterD(1,i)) .eq. 0.d0 )  then
!                    NND(clusterD(1,i) )= distance
!                    pos_nei( clusterD(1,i) ) = clusterD(1,i+1) 
!        endif  
!        if ( NND (clusterD(1,i+1)) .gt. distance .or. NND (clusterD(1,i)) .eq. 0.d0 ) then 
!                    NND(clusterD(1,i+1)) = distance 
!                    pos_nei( clusterD(1,i+1) ) = clusterD(1,i)
!        endif   
!      enddo  
!-------------------------------------------------------------------------------------





!-------------------------------------------------------------------------------------       
  !  do k=1,nRiordini
  !    do i=1, N - lung_seq   ! siccome calcolo con successivo devo evitare di uscire   
  !      if ( abs ( clusterN(1,i,k) - clusterN(1,i+1,k) ) .le. lung_seq)    cycle  ! evita self-match salta e non calcolare la distanza

  !       distance = distanza ( clusterN(1,i,k), clusterN(1,i+1,k) ) 

  !       if ( NND (clusterN(1,i,k)) .gt. distance )  then
  !                  NND(clusterN(1,i,k) )= distance
  !                  pos_nei( clusterN(1,i,k) ) = clusterN(1,i+1,k) 
  !      endif 
 
  !      if ( NND (clusterN(1,i+1,k)) .gt. distance ) then 
  !                  NND(clusterN(1,i+1,k)) = distance 
  !                  pos_nei( clusterN(1,i+1,k) ) = clusterN(1,i,k)
  !      endif  
  !    enddo  
  !  enddo  
!-------------------------------------------------------------------------------------

       

end subroutine preRiscaldamento


!-------------------------------------------------------------------------------------
!-------------------------------------------------



!---------------------------------------------------------------------

!---------------------------------------------------------------------


!---------------------------------------------------------------------

!---------------------------------------------------------------------

!---------------------------------------------------------------------

!---------------------------------------------------------------------

!---------------------------------------------------------------------


subroutine SM_pulisci_NND ! idea e' di controllare NND  e se ci sono dei salti controllare
implicit none           ! topologia: SAX tempo Euclidea
integer :: it=1         ! intervallo di ricerca (1 e' sufficiente, di solito si mette 10 per i sod)
integer :: i,j
real (kind=8) :: distance
integer :: quanteQui
!real (kind=8), dimension(:), allocatable :: nndCopia, pos_neiCopia 

quanteQui=0

do i=1, N-lung_seq-1 -it  ! gira su tutte le sequenze, (girare da sinistra o da destra cambia)!
!-------------- vicinanza  se l'NND della sequenza successiva e' calcolato lontano dalla presente e c'e' un salto, controlla i vicini del presente

!---------------------------------------------------------------------------------
!---------------------------------------------------------------------------------
!-------------- continuita'  ---------------------   controlla se il mio vicino e il vicino tra "it" passi sono contigui ma quelli centrali no, prova a vedere       
    do j =-it,it                             ! se si riesce a diminuire le distanza con i vicini "in mezzo"

         if (          i+j  .gt. N-lung_seq+1 .or. i+j .lt. 1 ) cycle   ! se esci dal limite superiore salta il calcolo
         if (  pos_nei(i)+j .gt. N-lung_seq+1                 ) cycle  ! evita di uscire dai limiti ??? ma lo avevo cercato anche prima
         if (  pos_nei(i)+j .lt. 1            .or. i+j .lt. 1 ) cycle  ! evita di uscire dai limiti
         !if (  abs( (i+j) - (pos_nei(i)+j)) .lt. lung_seq)        cycle  ! evita i self match
!---------- devo mettere un controllo per evitare di controllare ancora se pos+nei(i+j) non e' cambiato
!---------- dall'ultimo calcolo di idisc
       

         if ( pos_nei(i)+ j .ne.      pos_nei(i+  j)     ) then  ! controlla se vale la topologia, spostandomi di j posti trovo il vicino del j 
                                                                 ! commento dopo un po'. Qui sto semplicemente controllando che non valga gia' che
                                                                 ! il vicino del mio Tvicino sia mio Tvicino. Evito di fare calcoli inutili
                                                                 !distance = distanza ( i+j, pos_nei(i)+j )
             if (Znorm)       distance = Zdistanza ( i+j, pos_nei(i)+j )   ! usa versione con z-normalizzazione
             if (.not.Znorm)  distance =  distanza ( i+j, pos_nei(i)+j )   ! usa distanza euclidea semplice
             quanteQui = quanteQui+1 

             if (distance .lt. NND(i+j) ) then           ! seguente del mio vicino, ma lo e' quello dopo: strano
                 if (NND(i+j) .lt. distance)  then       ! se non e' identica alla NND attuale
                      NND2(i+j) = NND(i+j) 
                      pos_nei2(i+j) = pos_nei(i+j)        ! secondo vicino  
                 endif
 
                 NND (i+j) = distance                    ! aggiorna il valore della distanza del vicino 
                 pos_nei(i+j) = pos_nei(i)+j             ! aggiorno l'array delle posizioni dei vicini                   
             endif 


         endif 
    enddo 
enddo 

write(*,*) 'In pulisci       ', quanteQui*1.d0



end subroutine SM_pulisci_NND
!---------------------------------------------------------------------





!---------------------------------------------------------------------
subroutine A_pulisci_NND ! idea e' di controllare NND  e se ci sono dei salti controllare
implicit none           ! topologia: SAX tempo Euclidea
integer :: it=1         ! intervallo di ricerca (1 e' sufficiente, di solito si mette 10 per i sod)
integer :: i,j
real (kind=8) :: distance
integer :: quanteQui
!real (kind=8), dimension(:), allocatable :: nndCopia, pos_neiCopia 

!if allocated (nndCopia)     deallocate (nndCopia)
!if allocated (pos_neiCopia) deallocate (pos_neiCopia)

!allocate (nndCopia(size(nnd)) , pos_neiCopia(size(pos_nei)) )

!nndCopia     = nnd
!pos_neiCopia = pos_nei


quanteQui=0

do i=1, N-lung_seq-1 -it  ! gira su tutte le sequenze, (girare da sinistra o da destra cambia)!
!-------------- vicinanza  se l'NND della sequenza successiva e' calcolato lontano dalla presente e c'e' un salto, controlla i vicini del presente

!---------------------------------------------------------------------------------
!---------------------------------------------------------------------------------
!-------------- continuita'  ---------------------   controlla se il mio vicino e il vicino tra "it" passi sono contigui ma quelli centrali no, prova a vedere       
    do j =-it,it                             ! se si riesce a diminuire le distanza con i vicini "in mezzo"

         !if (i.gt.1 .and. j.lt.N-lung_seq+1) then
         !  if (nnd(i-1).le.nnd(i+1)) j=-1    ! (scegli quello di sinistra, e' piu' basso
         !  if (nnd(i-1).gt.nnd(i+1)) j= 1    !  scegli quello di destra e' piu' basso 
         !endif 

         !if (i.eq.1) j=1
         !if (i.eq.N-lung_seq+1) j=-1

 

         if (          i+j  .gt. N-lung_seq+1 .or. i+j .lt. 1 ) cycle   ! se esci dal limite superiore salta il calcolo
         if (  pos_nei(i)+j .gt. N-lung_seq+1                 ) cycle  ! evita di uscire dai limiti ??? ma lo avevo cercato anche prima
         if (  pos_nei(i)+j .lt. 1            .or. i+j .lt. 1 ) cycle  ! evita di uscire dai limiti
         if (  abs( (i+j) - (pos_nei(i)+j)) .lt. lung_seq)        cycle  ! evita i self match
!---------- devo mettere un controllo per evitare di controllare ancora se pos+nei(i+j) non e' cambiato
!---------- dall'ultimo calcolo di idisc
       

         if ( pos_nei(i)+ j .ne.      pos_nei(i+  j)     ) then  ! controlla se vale la topologia, spostandomi di j posti trovo il vicino del j 
                                                                 ! commento dopo un po'. Qui sto semplicemente controllando che non valga gia' che
                                                                 ! il vicino del mio Tvicino sia mio Tvicino. Evito di fare calcoli inutili
                                                                 !distance = distanza ( i+j, pos_nei(i)+j )
             if (Znorm)       distance = Zdistanza ( i+j, pos_nei(i)+j )   ! usa versione con z-normalizzazione
             if (.not.Znorm)  distance =  distanza ( i+j, pos_nei(i)+j )   ! usa distanza euclidea semplice
             quanteQui = quanteQui+1 

             if (distance .lt. NND(i+j) ) then           ! seguente del mio vicino, ma lo e' quello dopo: strano
                 if (NND(i+j) .lt. distance)  then       ! se non e' identica alla NND attuale
                      NND2(i+j) = NND(i+j) 
                      pos_nei2(i+j) = pos_nei(i+j)        ! secondo vicino  
                 endif
 
                 NND (i+j) = distance                    ! aggiorna il valore della distanza del vicino 
                 pos_nei(i+j) = pos_nei(i)+j             ! aggiorno l'array delle posizioni dei vicini                   
             endif 

             ! if (distance .lt. NND(pos_nei(i)+j) ) then           ! seguente del mio vicino, ma lo e' quello dopo: strano 
             !    NND (pos_nei(i)+j) = distance                    ! aggiorna il valore della distanza del vicino 
             !    pos_nei(pos_nei(i)+j) = i+j             ! aggiorno l'array delle posizioni dei vicini                   
             ! endif 





         endif 
    enddo 
enddo 

write(*,*) 'In pulisci       ', quanteQui*1.d0


!do i=1, N-lung_seq+1 
!   write(31,*) i, NND(i)
!enddo

end subroutine A_pulisci_NND
!---------------------------------------------------------------------



!---------------------------------------------------------------------

!---------------------------------------------------------------------
!---------------------------------------------------------------------


subroutine V_pulisci_NND ! idea e' di controllare NND  e se ci sono dei salti controllare
implicit none           ! topologia: SAX tempo Euclidea
integer :: it=1         ! intervallo di ricerca (1 e' sufficiente, di solito si mette 10 per i sod)
integer :: i,j
real (kind=8) :: distance
integer :: quanteQui

 !write(*,*) N-lung_seq-1-it, 'pulisci'

quanteQui=0

do i=1, N-lung_seq-1 -it  ! gira su tutte le sequenze, (girare da sinistra o da destra cambia)!
!-------------- vicinanza  se l'NND della sequenza successiva e' calcolato lontano dalla presente e c'e' un salto, controlla i vicini del presente

!---------------------------------------------------------------------------------
!---------------------------------------------------------------------------------
!-------------- continuita'  ---------------------   controlla se il mio vicino e il vicino tra "it" passi sono contigui ma quelli centrali no, prova a vedere       
    do j =-it,it                             ! se si riesce a diminuire le distanza con i vicini "in mezzo"
         if (          i+j  .gt. N-lung_seq+1 .or. i+j .lt. 1 ) cycle   ! se esci dal limite superiore salta il calcolo
         if (  pos_nei(i)+j .gt. N-lung_seq+1                 ) cycle  ! evita di uscire dai limiti ??? ma lo avevo cercato anche prima
         if (  pos_nei(i)+j .lt. 1            .or. i+j .lt. 1 ) cycle  ! evita di uscire dai limiti
         if (  abs( (i+j) - pos_nei(i)+j) .lt. lung_seq)        cycle  ! evita i self match
!---------- devo mettere un controllo per evitare di controllare ancora se pos+nei(i+j) non e' cambiato
!---------- dall'ultimo calcolo di idisc


             if ( pos_nei(i)+ j .ne.      pos_nei(i+  j)     ) then  ! controlla se vale la topologia, spostandomi di j posti trovo il vicino del j 
                                                             ! commento dopo un po'. Qui sto semplicemente controllando che non valga gia' che
                                                             ! il vicino del mio Tvicino sia mio Tvicino. Evito di fare calcoli inutili
                 !distance = distanza ( i+j, pos_nei(i)+j )
                 if (Znorm)       distance = Zdistanza ( i+j, pos_nei(i)+j )   ! usa versione con z-normalizzazione
                 if (.not.Znorm)  distance =  distanza ( i+j, pos_nei(i)+j )   ! usa distanza euclidea semplice
                 quanteQui = quanteQui+1 

                 if (distance .lt. NND(i+j) ) then           ! seguente del mio vicino, ma lo e' quello dopo: strano
                     if (NND(i+j) .lt. distance)  then       ! se non e' identica alla NND attuale
                         NND2(i+j) = NND(i+j) 
                         pos_nei2(i+j) = pos_nei(i+j)        ! secondo vicino  
                     endif
 
                     NND (i+j) = distance                    ! aggiorna il valore della distanza del vicino 
                     pos_nei(i+j) = pos_nei(i)+j             ! aggiorno l'array delle posizioni dei vicini                   
                  endif 

                 !if (distance .lt. NND(pos_nei(i)+j) ) then           ! seguente del mio vicino, ma lo e' quello dopo: strano 
                 !    NND (pos_nei(i)+j) = distance                    ! aggiorna il valore della distanza del vicino 
                 !    pos_nei(pos_nei(i)+j) = i+j             ! aggiorno l'array delle posizioni dei vicini                   
                 !endif 





             endif 
    enddo 
enddo 

write(*,*) 'In pulisci       ', quanteQui*1.d0


!do i=1, N-lung_seq+1 
!   write(31,*) i, NND(i)
!enddo

end subroutine V_pulisci_NND
!---------------------------------------------------------------------





!---------------------------------------------------------------------
!---------------------------------------------------------------------


subroutine sod_pulisci_NND ! idea e' di controllare NND  e se ci sono dei salti controllare
implicit none           ! topologia: SAX tempo Euclidea
integer :: it=10         ! intervallo di ricerca
integer :: i,j
real (kind=8) :: distance


do i=1, N-lung_seq-1 -it  ! gira su tutte le sequenze, (girare da sinistra o da destra cambia)!
!-------------- vicinanza  se l'NND della sequenza successiva e' calcolato lontano dalla presente e c'e' un salto, controlla i vicini del presente

!---------------------------------------------------------------------------------
!---------------------------------------------------------------------------------
!-------------- continuita'  ---------------------   controlla se il mio vicino e il vicino tra "it" passi sono contigui ma quelli centrali no, prova a vedere       
    do j =-it,it                             ! se si riesce a diminuire le distanza con i vicini "in mezzo"
         if (          i+j  .gt. N-lung_seq+1 .or. i+j .lt. 1 ) cycle   ! se esci dal limite superiore salta il calcolo
         if (  pos_nei(i)+j .gt. N-lung_seq+1                 ) cycle  ! evita di uscire dai limiti ??? ma lo avevo cercato anche prima
         if (  pos_nei(i)+j .lt. 1            .or. i+j .lt. 1 ) cycle  ! evita di uscire dai limiti
         if (  abs( (i+j) - pos_nei(i)+j) .lt. lung_seq)        cycle  ! evita i self match
!---------- devo mettere un controllo per evitare di controllare ancora se pos+nei(i+j) non e' cambiato
!---------- dall'ultimo calcolo di idisc


             if ( pos_nei(i)+ j .ne.      pos_nei(i+  j)     ) then  ! controlla se vale la topologia, spostandomi di j posti trovo il vicino del j 
                                                             ! commento dopo un po'. Qui sto semplicemente controllando che non valga gia' che
                                                             ! il vicino del mio Tvicino sia mio Tvicino. Evito di fare calcoli inutili
                     
                 !distance = distanza ( i+j, pos_nei(i)+j )
                 if (Znorm)       distance = Zdistanza ( i+j, pos_nei(i)+j )   ! usa versione con z-normalizzazione
                 if (.not.Znorm)  distance =  distanza ( i+j, pos_nei(i)+j )   ! usa distanza euclidea semplice


          if (siNNDk) then
            call riempi_NNDk(  i+j, pos_nei(i)+j , distance)  !k-esimo vicino
            call riempi_NNDk(  pos_nei(i)+j,  i+j,distance)  !k-esimo vicino
          endif
 

             if (i.eq.292)  write(35,*) i, i+j,   distance, NND(i+j)      

                 if (distance .lt. NND(i+j) ) then           ! seguente del mio vicino, ma lo e' quello dopo: strano
                     NND (i+j) = distance                    ! aggiorna il valore della distanza del vicino 
                     pos_nei(i+j) = pos_nei(i)+j             ! aggiorno l'array delle posizioni dei vicini                   
                  endif 



             endif 
    enddo 
enddo 



end subroutine sod_pulisci_NND

!---------------------------------------------------------------------

subroutine sod_pulisci_NNDk ! usato per time topology in funzione di tutti i primi
implicit none           ! vicini non solo il primo
integer :: it=10         
integer :: i,j, k
real (kind=8) :: distance


call nomeSub('sod_pulisci_NNDk')

do i=1, N-lung_seq-1 -it  ! gira su tutte le sequenze, (girare da sinistra o da destra cambia)!
!-------------- vicinanza  se l'NND della sequenza successiva e' calcolato lontano dalla presente e c'e' un salto, controlla i vicini del presente

!---------------------------------------------------------------------------------
!---------------------------------------------------------------------------------
!-------------- continuita'  ---------------------   controlla se il mio vicino e il vicino tra "it" passi sono contigui ma quelli centrali no, prova a vedere       
  do k=1, kmax
    do j =-it,it                             ! se si riesce a diminuire le distanza con i vicini "in mezzo"
         if (          i+j  .gt. N-lung_seq+1 .or. i+j .lt. 1 ) cycle   ! se esci dal limite superiore salta il calcolo
         if (  pos_neik( (i)+j,k) .gt. N-lung_seq+1                 ) cycle  ! evita di uscire dai limiti ??? ma lo avevo cercato anche prima
         if (  pos_neik( (i)+j,k) .lt. 1            .or. i+j .lt. 1 ) cycle  ! evita di uscire dai limiti
         if (  abs( (i+j) - pos_neik((i)+j,k)    ) .lt. lung_seq)        cycle  ! evita i self match
!---------- devo mettere un controllo per evitare di controllare ancora se pos+nei(i+j) non e' cambiato
!---------- dall'ultimo calcolo di idisc


             if ( pos_neik( (i)+ j,k) .ne.      pos_neik( (i+  j), k)     ) then  ! controlla se vale la topologia, spostandomi di j posti trovo il vicino del j 
                                                             ! commento dopo un po'. Qui sto semplicemente controllando che non valga gia' che
                                                             ! il vicino del mio Tvicino sia mio Tvicino. Evito di fare calcoli inutili
                     
                 if (Znorm)       distance = Zdistanza ( i+j, pos_neik( (i)+j , k) )   ! usa versione con z-normalizzazione
                 if (.not.Znorm)  distance =  distanza ( i+j, pos_neik( (i)+j , k) )   ! usa distanza euclidea semplice


          if (siNNDk) then
            call riempi_NNDk(  i+j, pos_neik( (i)+j ,k) , distance)  !k-esimo vicino
            call riempi_NNDk(  pos_neik( (i)+j, k),  i+j,distance)  !k-esimo vicino
          endif 
 
             endif 
    enddo 
 enddo  
enddo 




end subroutine sod_pulisci_NNDk

!---------------------------------------------------------------------


!-----------------------------------------------------------------------------------------
subroutine qzA_timeTopologyForward(k1, bestDist)
implicit none
integer , intent(in) :: k1
real(kind=8), intent(in) :: bestDist
integer :: i, j, iCoerence
real (kind =8):: distance
logical :: salta


 iCoerence = lung_seq 
 i=k1


do j=1, iCoerence ! in teoria vai dalla seq dove sei fino in fondo all'ultima seq

    if (i+j         .gt.N-lung_seq+1) return  ! sia con la seq che con il vicino 
    if (pos_nei(i)+j.gt.N-lung_seq+1) return  ! se sei arrivato al limite destro, finisci il ciclo

    if ((pos_nei(i)+j.eq. pos_nei(i+j))) return ! se i+j > N-lung_seq+1 questo NON deve essere chiamato
    if ( NND(i+j)    .lt. bestDist)      cycle  ! evita di farlo ma cerca oltre       


!    if ((pos_nei(i)+j.eq. pos_nei(i+j)).or. & ! se i+j > N-lung_seq+1 questo NON deve essere chiamato
!            (NND(i+j)    .lt. bestDist)) return !  



    if (     Znorm)   distance = Zdistanza ( i+j, pos_nei(i)+j )   ! usa versione con z-normalizzazione
    if (.not.Znorm)   distance =  distanza ( i+j, pos_nei(i)+j )   ! usa versione con z-normalizzazione


   if (distance .lt. NND(pos_nei(i)+j) ) then  ! devo lanciare questa sub, DOPO che bestDist e' stato aggiornato
       NND(pos_nei(i) + j)     =   distance
       pos_nei(pos_nei(i)+j) =   i+j
   endif 

   if (distance .lt. NND(i+j)) then  ! devo lanciare questa sub, DOPO che bestDist e' stato aggiornato
       NND(i+j)     =   distance
       pos_nei(i+j) = pos_nei(i)+j
   else

       if (.not.can_be_discord) return ! se la sequenza che hai appena analizzato non puo' essere un discord, allora ha un nnd basso! non serve continuare
       !return 
   endif


enddo
   

end subroutine qzA_timeTopologyForward
!-----------------------------------------------

!-----------------------------------------------------------------------------------------
subroutine qzA_timeTopologyBackward(k1, bestDist)
implicit none
integer , intent(in) :: k1
real(kind=8), intent(in) :: bestDist
integer :: i, j, iCoerence
real (kind =8):: distance
logical ::  salta


 iCoerence = lung_seq 
 i=k1

do j=1, iCoerence ! in teoria vai dalla seq dove sei fino in fondo all'ultima seq

    if (pos_nei(i)-j.lt.1) return
    if (i-j.lt.1)          return
    
!    if ((pos_nei(i)-j.eq. pos_nei(i-j) ) .or. &
!            (NND(i-j)    .lt. bestDist) )  return

     if  (pos_nei(i)-j.eq. pos_nei(i-j) )  return  ! non cercare oltre
     if        (NND(i-j)    .lt. bestDist) cycle   ! evita ma continua a cercare



    !salta = salta1 .or. salta2
    if (salta) return ! any of these conditions leads to exit the routine


   if (Znorm)        distance = Zdistanza ( i-j, pos_nei(i)-j )   ! usa versione con z-normalizzazione
   if (.not.Znorm)  distance =  distanza ( i-j, pos_nei(i)-j )   ! usa distanza euclidea semplice


   if (distance .lt. NND(pos_nei(i)-j) ) then  ! devo lanciare questa sub, DOPO che bestDist e' stato aggiornato
       NND(pos_nei(i) - j)     =   distance
       pos_nei(pos_nei(i)-j) =   i-j
   endif 


   if (distance .lt. NND(i-j)) then  ! devo lanciare questa sub, DOPO che bestDist e' stato aggiornato
       NND(i-j)     =   distance
       pos_nei(i-j) = pos_nei(i)-j
   else

       if (.not.can_be_discord) return ! se la sequenza che hai appena analizzato non puo' essere un discord, allora ha un nnd basso! non serve continuare
       !return
   endif


  
enddo
   

end subroutine qzA_timeTopologyBackward
!-----------------------------------------------




!---------------------------------------------------------------------
!-----------------------------------------------------------------------------------------
subroutine A_timeTopologyForward(k1, bestDist)
implicit none
integer , intent(in) :: k1
real(kind=8), intent(in) :: bestDist
integer :: i, j, iCoerence
real (kind =8):: distance

 iCoerence = lung_seq
 i=k1
 if (pos_nei(i).ge. N-lung_seq+1)  return ! non c'e' nulla dopo l'ultima (temporalmente) sequenza!


!if (.not.can_be_discord) return

do j=1, iCoerence ! in teoria vai dalla seq dove sei fino in fondo all'ultima seq


   !if (abs(i-54867).le.lung_seq) write(38,*)i, i+j

   if (pos_nei(i)+j.gt.N-lung_seq+1) exit  ! se sei arrivato al limite destro, finisci il ciclo
   if (i+j         .gt.N-lung_seq+1) exit  ! sia con la seq che con il vicino 
   if (pos_nei(i)+j.eq.pos_nei(i+j)) cycle ! e' gia' stata calcolata!
   if (NND(i+j) .lt.bestDist) then
       !write(58,*) i, i+j, NND(i+j)   
       cycle ! evita di calcolare se sai che comunque non e' un discord
   endif 

   if (Znorm)       distance = Zdistanza ( i+j, pos_nei(i)+j )   ! usa versione con z-normalizzazione
   if (.not.Znorm)  distance =  distanza ( i+j, pos_nei(i)+j )   ! usa distanza euclidea semplice


   if (distance .lt. NND(pos_nei(i)+j) ) then  ! devo lanciare questa sub, DOPO che bestDist e' stato aggiornato
       NND(pos_nei(i) + j)     =   distance
       pos_nei(pos_nei(i)+j) =   i+j
   endif 


   if (distance .lt. NND(i+j)) then  ! devo lanciare questa sub, DOPO che bestDist e' stato aggiornato
       NND(i+j)     =   distance
       pos_nei(i+j) = pos_nei(i)+j
       !write(45,*) i+j, NND(i+j) 
   else

       !if (can_be_discord.and. NND(i+j).gt.distance) write(54,*) i-j, NND(i-j)
       if (.not.can_be_discord) return ! se la sequenza che hai appena analizzato non puo' essere un discord, allora ha un nnd basso! non serve continuare
   endif


  
enddo
   

end subroutine A_timeTopologyForward
!-----------------------------------------------

!------------------------------------------------
subroutine A_timeTopologyBackward(k1, bestDist)
implicit none
integer , intent(in) :: k1
real(kind=8), intent(in) :: bestDist
integer :: i, j, iCoerence
real (kind =8):: distance

 iCoerence = lung_seq
 i=k1
 if (pos_nei(i).lt. lung_seq)  return ! non c'e' nulla prima (temporalmente)!

!if (.not.can_be_discord) return

do j=1, iCoerence ! in teoria vai dalla seq dove sei fino in fondo all'ultima seq

   !if (abs(i-54867).le.lung_seq) write(38,*)i, i-j

   if (pos_nei(i)-j.lt.1) exit 
   if (i-j.lt.1)          exit
   if (pos_nei(i)-j.eq.pos_nei(i-j)) cycle ! e' gia' stata calcolata!
   if (NND(i-j) .lt.bestDist) then
       cycle ! evita di calcolare se sai che comunque non e' un discord
   endif 

   if (Znorm)       distance = Zdistanza ( i-j, pos_nei(i)-j )   ! usa versione con z-normalizzazione
   if (.not.Znorm)  distance =  distanza ( i-j, pos_nei(i)-j )   ! usa distanza euclidea semplice


   if (distance .lt. NND(pos_nei(i)-j) ) then  ! devo lanciare questa sub, DOPO che bestDist e' stato aggiornato
       NND(pos_nei(i) - j)     =   distance
       pos_nei(pos_nei(i)-j) =   i-j
   endif 


   if (distance .lt. NND(i-j)) then  ! devo aggiornare questa sub Dopo che bestDist e' stato aggiornato
       NND(i-j)     =   distance
       pos_nei(i-j) = pos_nei(i)-j
       !write(46,*) i-j, NND(i-j) 
   else 

       !if (can_be_discord) write(54,*) i-j, NND(i-j)
       if (.not.can_be_discord) return ! sei arrivato dove la time tipology non funge piu! oppure hai trovato un nuovo discord!
   endif  
enddo



end subroutine A_timeTopologyBackward
!-----------------------------------------------








!-----------------------------------------------------------------------------------------
subroutine timeTopologyForward(k1, bestDist)
implicit none
integer , intent(in) :: k1
real(kind=8), intent(in) :: bestDist
integer :: i, j, iCoerence
real (kind =8):: distance

 iCoerence = lung_seq
 i=cluster(1,k1)
 if (pos_nei(i).ge. N-lung_seq+1)  return ! non c'e' nulla dopo l'ultima (temporalmente) sequenza!


 !if (.not.can_be_discord) return

do j=1, iCoerence ! in teoria vai dalla seq dove sei fino in fondo all'ultima seq


   if (pos_nei(i)+j.gt.N-lung_seq+1) exit  ! se sei arrivato al limite destro, finisci il ciclo
   if (i+j         .gt.N-lung_seq+1) exit  ! sia con la seq che con il vicino 
   if (NND(i+j) .lt.bestDist) cycle ! evita di calcolare se sai che comunque non e' un discord


   !                distance = Zdistanza ( i+j, pos_nei(i)+j ) 
   if (Znorm)       distance = Zdistanza ( i+j, pos_nei(i)+j )   ! usa versione con z-normalizzazione
   if (.not.Znorm)  distance =  distanza ( i+j, pos_nei(i)+j )   ! usa distanza euclidea semplice



   !if (distance .lt. bestDist) then  ! devo lanciare questa sub, DOPO che bestDist e' stato aggiornato
   if (distance .lt. NND(i+j)) then  ! devo lanciare questa sub, DOPO che bestDist e' stato aggiornato
       NND(i+j)     =   distance
       pos_nei(i+j) = pos_nei(i)+j
       write(45,*) i+j, NND(i+j) 
   else
       !if (can_be_discord.and. NND(i+j).gt.distance) write(54,*) i-j, NND(i-j)
       if (.not.can_be_discord) return ! se la sequenza che hai appena analizzato non puo' essere un discord, allora ha un nnd basso! non serve continuare
   endif  
enddo
   

end subroutine timeTopologyForward
!-----------------------------------------------

!------------------------------------------------
subroutine timeTopologyBackward(k1, bestDist)
implicit none
integer , intent(in) :: k1
real(kind=8), intent(in) :: bestDist
integer :: i, j, iCoerence
real (kind =8):: distance

 iCoerence = lung_seq
 i=cluster(1,k1)
 if (pos_nei(i).lt. lung_seq)  return ! non c'e' nulla prima (temporalmente)!

 !if (.not.can_be_discord) return

do j=1, iCoerence ! in teoria vai dalla seq dove sei fino in fondo all'ultima seq

   if (pos_nei(i)-j.lt.1) exit 
   if (i-j.lt.1)          exit
   if (NND(i-j) .lt.bestDist) cycle ! evita di calcolare se sai che comunque non e' un discord

   !                distance = Zdistanza ( i-j, pos_nei(i)-j ) 
   if (Znorm)       distance = Zdistanza ( i-j, pos_nei(i)-j )   ! usa versione con z-normalizzazione
   if (.not.Znorm)  distance =  distanza ( i-j, pos_nei(i)-j )   ! usa distanza euclidea semplice


   !if (distance .lt. bestDist) then  ! devo aggiornare questa sub Dopo che bestDist e' stato aggiornato
   if (distance .lt. NND(i-j)) then  ! devo aggiornare questa sub Dopo che bestDist e' stato aggiornato
       NND(i-j)     =   distance
       pos_nei(i-j) = pos_nei(i)-j
       write(46,*) i-j, NND(i-j) 
   else 

       !if (can_be_discord) write(54,*) i-j, NND(i-j)
       if (.not.can_be_discord) return ! sei arrivato dove la time tipology non funge piu! oppure hai trovato un nuovo discord!
   endif  
enddo



end subroutine timeTopologyBackward
!-----------------------------------------------







!---------------------------------------------------------------------
subroutine prossimoPuntoPartenza(seq_partenza)
implicit none 
integer , intent(out) :: seq_partenza
integer :: i

      do i= primoNonPreso, N-lung_seq+1  ! giro dal primo non preso in poi cercando le sequenze non assegnate 

           if (seq_partenza.eq.2158) then
               write(95,*)  i , cEu(i)
           endif 

          

           if (cEu(i) .eq. 0) then       ! per cercare il prossimo punto di partenza
                seq_partenza = i         ! la prima seq libera in ordine cronologico  
                primoNonPreso = i+1      ! la prox volta parto dal successivo che forse non e' ancora preso...
                exit                     ! non c'e' bisogno di restare nel ciclo abbiamo gia' trovato il prossimo punto di partenza   
           endif 
      enddo



end subroutine prossimoPuntoPartenza


!---------------------------------------------------------------------


subroutine rewindPercorsoAttuale(indiceCluster, seq_ora, passo)
implicit none
integer, intent(in)  :: seq_ora, indiceCluster 
integer, intent(out) :: passo
integer              :: i 

      do i=1, N-lung_seq+1                    ! in linea di principio il percorso attuale potrebbe essere tutta la serie
        if (percorsoAttuale(i) .ne. 0)  then  ! sono uguali a zero dove non sei ancora arrivato
            !write(*,*) percorsoAttuale(i), cEu(percorsoAttuale(i)), cEu(seq_ora)
            cEu (percorsoAttuale(i)) = cEu(seq_ora)  ! metti tutte le sequenze su cui hai girato nello stesso cluster di quella trovata adesso
        endif 
        if (percorsoAttuale(i) .eq. 0 )  then ! hai finito il percorso attuale
             percorsoAttuale (1:i) = 0        ! azzera il percorso attuale (non c'e' bisogno di azzerare tutto l'array ), ricomincio da capo
             passo = 0                        ! azzera il passo del percorso attuale
             exit                             ! esci dal ciclo 
        endif 
            
      enddo

end subroutine rewindPercorsoAttuale
!---------------------------------------------------------------------


subroutine continuaQuestoCluster(passo, seq_ora, seq_partenza, indiceCluster)
implicit none
integer, intent(inout) :: passo
integer, intent(in)    :: seq_ora
integer, intent(out)   :: seq_partenza
integer, intent(in)    :: indiceCluster



     passo = passo +1                      ! mi sono mosso di un passo
     percorsoAttuale(passo) = seq_ora      ! il percorso attuale comprende questa sequenza
     cEu (seq_ora)  = indiceCluster        ! la seq_ora appartiene al cluster indiceCluster
     seq_partenza = seq_ora                ! nuovo punto di partenza e' dove siamo arrivati ora

end subroutine continuaQuestoCluster
!---------------------------------------------------------------------


!---------------------------------------------------------------------
subroutine S_cluster_Euclidei ! costruisco i cluster Euclidei in questo modo
!                           prendo la prima sequenza: chiamo questo cluster il cluster 1
!                           prendo la sua vicina  Euclidea. 
!                           continuo con a prendere la successiva vicina Euclidea.
!                ci sono 3 possibilita'
!                1- finisco tutte le sequenze
!                1- sbatto su una sequenza che e' fa gia' parte del di un cluster DIVERso da quello attuale,
!                    allora tutte le sequenze di questo cammino faranno parte di quel clust4er
!                 2- sbatto su una sequenza di questo cammino. Allora riparto con un nuovo cluster dalla
!                prima sequenza non ancora assegnata ad un cluster, e aggiorno il numero di cluster con +1



!  nuova teoria  1     -> nei(1)
!              nei(1)  -> nei( nei(1) )
!              ...     -> ... 
!              ...     -> nei( .... (nei (1) )  )   



implicit none


integer , dimension(:), allocatable :: giaSelezionato
integer , dimension(:), allocatable :: GraClu

integer :: i, j
integer :: passo   
integer :: indiceCluster
integer :: seq_partenza, seq_ora
integer :: sequenzeAssegnate
integer :: indice
logical :: ricomincia = .false.




allocate ( cEu (N-lung_seq+1), percorsoAttuale(N-lung_seq+1), giaSelezionato(N-lung_seq+1) )

!write(*,*) 'cluster Euclidei ora'

call nomeSub('cluster_Euclidei')

indiceCluster   = 0
cEu             = 0  ! inizializzo l'array che contiene il nome (numero) del cluster a cui appartiene ogni sequenza
percorsoAttuale = 0       !   
passo           = 0                    
         ! dove mi trovo nel giro attuale
do i=1, N-lung_seq+1                  ! gira su tutte le sequenze

   if (cEu(i).ne.0) cycle             ! salta al prossimo
   seq_ora = i                        ! la sequenza ora e' quella da cui partiamo 
   passo =  1                         ! sono nel passo 1 nel giro attuale
   indiceCluster = indiceCluster +1   ! in teoria costruisco un nuovo cluster
   percorsoAttuale(1) = seq_ora       ! la nuova sequenza di partenza e' il primo passo del percorso Attuale (trovata sopra)
    
   do while (cEu(seq_ora) .eq. 0)      ! gira fino a che cadi su sequenze non ancora assegnate
     percorsoAttuale(passo) = seq_ora ! metto la seq attuale nel percorsoAttuale   
     cEu(seq_ora) = indiceCluster      ! assegno il nuovo indice di cluster alla sequenza
     passo = passo + 1                 ! passo alla prossima sequenza  
     seq_ora = iSeguente(seq_ora) ! trovo la prossima sequenza, adesso devi controllare cosa fare
   enddo

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
      if (cEu(seq_ora).ne. indiceCluster)  then  ! sono finito su un altro cluster gia' esistente
         call rewindPercorsoAttuale(indiceCluster, seq_ora, passo)          ! la variabile "passo" viene azzerata, il percorso attuale viene modificato su dove si e' arrivati      
         indiceCluster=indiceCluster-1           ! non ho trovato un nuovo cluster
      endif 


      if (cEu(seq_ora).eq. indiceCluster)  then  ! il serpente si mangia la coda, sono finito su una sequenza del cluster attuale 
         percorsoAttuale(1:passo) = 0   ! azzera percorso attuale
      endif 

  
     ! call prossimoPuntoPartenza(seq_partenza)           ! trova la prima sequenza di partenza libera

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------

enddo

!do i=1, N-lung_seq+1
!  write(31, *) i, cEu(i),  pos_nei(i)
!enddo


allocate (GraClu(maxval(cEu)))         ! per calcolare la GRAndezza dei CLUster
GraClu= 0                              ! azzero l'array
do i=1, N-lung_seq+1                   ! gira su tutte le sequenze
   if (cEu(i).eq.0) cycle              ! 
   GraClu( cEu(i) ) = GraClu(cEu(i))+1 ! 
enddo

do i =1, size(GraClu)
   write(38,*) i, GraClu(i), sum(GraClu)
enddo


do i=1, N-lung_seq+1 
  write(33, *) i, cEu(i), GraClu( cEu( i) ), pos_nei(i), nnd(i)
enddo

indice=0
do i=1,N-lung_seq+1
  if ( cEu(i) .eq. 18) then
      indice = indice+1
      do j=0, lung_seq-1 
        write(97,*) j+1, serie(i+j), indice, nnd(i), pos_nei(i)
      enddo
      write(97,*)
  endif

enddo





end subroutine S_cluster_Euclidei








!---------------------------------------------------------------------
subroutine cluster_Euclidei ! costruisco i cluster Euclidei in questo modo
!                           prendo la prima sequenza: chiamo questo cluster il cluster 1
!                           prendo la sua vicina  Euclidea. 
!                           continuo con a prendere la successiva vicina Euclidea.
!                ci sono 3 possibilita'
!                1- finisco tutte le sequenze
!                1- sbatto su una sequenza che e' fa gia' parte del di un cluster DIVERso da quello attuale,
!                    allora tutte le sequenze di questo cammino faranno parte di quel clust4er
!                 2- sbatto su una sequenza di questo cammino. Allora riparto con un nuovo cluster dalla
!                prima sequenza non ancora assegnata ad un cluster, e aggiorno il numero di cluster con +1



!  nuova teoria  1     -> nei(1)
!              nei(1)  -> nei( nei(1) )
!              ...     -> ... 
!              ...     -> nei( .... (nei (1) )  )   



implicit none


integer , dimension(:), allocatable :: giaSelezionato
integer , dimension(:), allocatable :: GraClu

integer :: i
integer :: passo   
integer :: indiceCluster
integer :: seq_partenza, seq_ora
integer :: sequenzeAssegnate

logical :: ricomincia = .false.




allocate ( cEu (N-lung_seq+1), percorsoAttuale(N-lung_seq+1), giaSelezionato(N-lung_seq+1) )

!write(*,*) 'cluster Euclidei ora'

call nomeSub('cluster_Euclidei')

sequenzeAssegnate = 0

indiceCluster =1
passo  =1

giaSelezionato = 0 
giaSelezionato(1) = 1

cEu    = 0  ! inizializzo l'array che contiene il nome (numero) del cluster a cui appartiene ogni sequenza
cEu(1) = 1  ! la prima sequenza appartiene al primo cluster

seq_partenza  = 1
seq_ora       = 1
primoNonPreso = 1  
percorsoAttuale =0
percorsoAttuale(1) = 1

arriviDaUnoZero = .true.


do while  (primoNonPreso .ne. N-lung_seq+1) ! gira fino a quando non hai assegnato tutte le sequenze 



!----------- cosa faccio se finisco su un altro cluster --------------------
!----------- se finisco su un altro cluster (quindi che e' gia' esistente) --
!----------- devo prendere tutte le sequenze nel percorso Attuale e riassegnarle
!----------- con il medesimo indice del cluster su cui siamo arrivati
!----------- devo quindi azzerare il percorso attuale e il passo 
!----------- devo definire come punto di partenza, uno successivo a quello
!----------- da cui siamo partiti nel percorsoAttuale
!----------- devo mantenere lo stesso numero di cluster non ne ho trovato uno nuovo
!
!----------- in "percorso attuale metto l'indice della sequenza dove arrivo di volta in volta.
!----------- in questo modo se 


  seq_ora = iSeguente(seq_partenza)     ! trovo la prossima sequenza, adesso devi controllare cosa fare


  write(94,*) primoNonPreso, seq_ora, cEu(seq_ora) , indiceCluster 

 

  !write(69,*) seq_ora
  !if (seq_ora .gt. N-lung_seq+1) cycle
  !if (seq_ora .le. 0) cycle

  if (cEu(seq_ora) .ne.0  )  then       ! vuol dire che sei arrivato su una sequenza che fa gia' parte di un cluster ci sono 2 possibilita', che sia il medesimo cluster dell'inizio o differente


      if (cEu(seq_ora).ne. indiceCluster)  then  ! sono finito su un altro cluster gia' esistente
         !write(35,*) seq_partenza, seq_ora, indiceCluster, 'arrivato su cluster esistente  ' ,  cEu(seq_ora)
         !if (cEu(seq_ora) .gt. indiceCLuster) write(39,*) seq_ora, indiceCluster, cEu(seq_ora), 'ciao'  
         call rewindPercorsoAttuale(indiceCluster, seq_ora, passo)          ! la variabile "passo" viene azzerata, il percorso attuale viene modificato su dove si e' arrivati      
      endif 


      if (cEu(seq_ora).eq. indiceCluster)  then  ! il serpente si mangia la coda, sono finito su una sequenza del cluster attuale 
         !write(35,*) seq_partenza, seq_ora, indiceCluster, 'arrivato su cluster di partenza' ,  cEu(seq_ora)
         percorsoAttuale(1:passo) = 0   ! azzera percorso attuale
         indiceCluster=indiceCluster+1 
      endif 

  
      arriviDaUnoZero = .false.                          ! hai sbattuto su un altro cluster, la nuova sequenza ora si trova con prossimoPunoPArtenza, non con iSequente!
      call prossimoPuntoPartenza(seq_partenza)           ! trova la prima sequenza di partenza libera
      percorsoAttuale(1) = seq_partenza                  ! la nuova sequenza di partenza e' il primo passo del percorso Attuale (trovata sopra)
      cEu(seq_partenza)  = indiceCluster                 ! 
 
  endif 


  if (cEu(seq_ora).eq. 0) then             ! sei arrivato su una sequenza non ancora assegnata 
      !write(35,*) seq_partenza,seq_ora,    indiceCluster, 'arrivato su sequenza libero     '  ,  cEu(seq_ora)
      call continuaQuestoCluster(passo, seq_ora, seq_partenza, indiceCluster)  ! assegna nuova seq_partenza, e assegna indice cluster dove sei arrivato
  endif 
!------------


enddo



allocate (GraClu(maxval(cEu)))         ! per calcolare la GRAndezza dei CLUster
GraClu= 0                              ! azzero l'array
do i=1, N-lung_seq+1                   ! gira su tutte le sequenze
   if (cEu(i).eq.0) cycle              ! 
   GraClu( cEu(i) ) = GraClu(cEu(i))+1 ! 
enddo

do i =1, size(GraClu)
   write(38,*) i, GraClu(i), sum(GraClu)
enddo



do i=1, N-lung_seq+1
  write(33, *) i, cEu(i), GraClu( cEu( i) ), pos_nei(i)
enddo




end subroutine cluster_Euclidei

!---------------------------------------------------------------------




!---------------------------------------------------------------------
function iSeguente(sequenza)
implicit none
integer :: iSeguente
integer, intent(in) :: sequenza

iSeguente  =  pos_nei(sequenza) ! l'indice della sequenza che segue


end function iSeguente


!---------------------------------------------------------------------

!---------------------------------------------------------------------

subroutine limiti_cluster ! l'array cluster(3,N) e' tale che in Cluster(2,:) ci sono gli indici dei cluster,
                          ! in cluster(1,:) i valori di inizio delle sequenze nella serie
                          ! voglio trovare dove cominciano e finiscono i cluster, per esempio il cluster 345
                          ! ottenuto con cluster(2,:)=345 e' tale comincia dalla riga 56 alla 69, ovvero
                          ! le righe cluster(1,56) hanno cluster(2,56)=345 .... fino a cluster(1,69) hanno cluster(2,69)=345
                           
implicit none
integer :: i, ivec, iora, indice, quantiCluster



!if (allocated(ordineCluster)) deallocate (ordineCluster)
!    allocate (ordineCluster(


finCluster = maxval(cluster(1,:))   ! non hanno senso valori negativi, quindi lo inizializzo cosi'

iniCluster    = -1   ! idem   
iniCluster(1) =  1   ! l'indice di partenza deve essere per forza 1   


indice =   0                     ! partiamo da 0

do i=1, N-lung_seq             ! occhio che indice =0 non ha significato serve solo per questo algoritmo

       if (cluster(2, i) .ne. cluster(2,i+1) )  then
             indice   = indice +1                   ! indice in ordine dei cluster trovati 
             finCluster(indice)   = i               ! e' l'ultimo
             if (i .ne. N-lung_seq+1) iniCluster(indice+1) = i+1             ! e' il primo  
       endif 
 
enddo


   quantiCluster = indice+1

!  indice+1  = numero di cluster trovati 

!dato che ho riordinato i cluster, il primo cluster trovato non e' quello con indice 1,
!etc. nell'array posizioneCluster voglio mettere come ingresso la posizione Registro e in uscita 
! l'ordine (dato dalla grandezza). Per esempio il cluster 34 si trova al 76mo posto per grandezza (piccolezza,
! dato che vado dai piu' piccoli ai piu' grandi)

  if (allocated(posizioneCluster)) deallocate(posizioneCluster)
  allocate (posizioneCluster(indice+1))

posizioneCluster = 0   
indice =0

do i=1, N-lung_seq             ! occhio che indice =0 non ha significato serve solo per questo algoritmo

       if (cluster(2, i) .ne. cluster(2,i+1) )  then
             indice   = indice +1                   ! indice in ordine dei cluster trovati 
             finCluster(indice)   = i               ! e' l'ultimo
             posizioneCluster ( posizioneRegistro(cluster(1,i)) ) = indice
       endif 
 
enddo

posizioneCluster( posizioneRegistro(cluster(1,i))) = indice+1

!do i=1, quantiCluster
     ! write(37,*) i, posizioneCluster(i) , iniCluster(i), finCluster(i)
!enddo


end subroutine limiti_cluster

!---------------------------------------------------------------------


!---------------------------------------------------------------------
subroutine limiti_clusterP1 ! qui mi da i limiti dei clusterP1, considerando che ora
                            ! clusterP1 e' ordinato secondo l'indice di cluster

integer :: i


finClusterP1 = maxval(clusterP1(1,:))   ! non hanno senso valori negativi, quindi lo inizializzo cosi'

iniClusterP1    = -1   ! idem   
iniClusterP1(1) =  1   ! l'indice di partenza deve essere per forza 1   


do i=1, N-lung_seq             ! occhio che indice =0 non ha significato serve solo per questo algoritmo

!    if (i <= N-lung_seq )  then
       if (clusterP1(2, i) .ne. clusterP1(2,i+1) )  then                                ! se cambia l'indice di cluster allora 
             finClusterP1( clusterP1(2,i)  )   = i                                      ! e' l'ultimo del precedente
             if (i .ne. N-lung_seq+1) iniClusterP1( clusterP1(2,i)  +1) = i+1             ! e' il primo del prossimo  
       endif 
!    endif    
 
enddo

!do i=1, size(finClusterP1)-1
! write(92,*) i, iniClusterP1(i), finClusterP1(i)
!enddo
! write(92,*)
  

end subroutine limiti_clusterP1


!---------------------------------------------------------------------


!---------------------------------------------------------------------


subroutine statistica(idisc, ianal)
implicit none
integer i,j
integer, intent(in) :: idisc , ianal
real (kind =8):: CDFxOut, CDFxOut0

!-------------------- converto per fare delle statistiche veloci ----------
!-------------------------------------------------------------------------- 
! facciamo una trasformazione lineare da un intervallo di valori  [mi, Ma]
! all'intervallo        [1,nbin]:
!
!       [mi,Ma] ---> [1,nbin]   (dove per esempio nbin=10)
! vedo [mi, Ma] asse x
!   e  [1 , nbin] asse y
!
! mi serve l'equazione della retta  y = mx + q 
!
! faccio passare una retta tra  i punti (mi,0) e (Ma,nbin)
! il coefficiente angolare e' quindi:    dy/dx =  (nbin-0)/(Ma-mi) = m
! per l'intercetta impongo che passi per (mi,0):    0 = m * mi +q 
! q = -(nbin-0)/(Ma-mi) * m
! 
! in questo modo posso fare la controimmagine di tutti gli interi sull'asse delle x
! questo crea una partizione di [mi,Ma], per esempio se fossero nbin=10 punti:
!
!          [mi, 1mo, 2do, 3zo, 4to, 5to, 6to, 7mo, 8vo, 9no, Ma]
! (nota che 0 va in mi, e 10 va in Ma)
!

!  se trasformo in valori interi:
!  tutti i valori su x tra [mi,1mo)  --> 0  
!  tutti i valori su x tra [1mo,2do) --> 1  
!  tutti i valori su x tra [2do,3zo) --> 2  
!                  ...
!  tutti i valori su x tra [9no,Ma)  --> 9
!  a questo punto posso aggiungere 1 (e quindi l'intervallo va da 1 a 10)
! 
!  resta una eccezione: il valore Ma viene mandato in 11, quindi devo trattarlo come tale

  Ma = Maxval(NND)
  mi = minval(NND)


  kappa =          (nbin)/(Ma-mi)
  q     =    - (nbin)*Mi/(Ma-mi)

  binNND = 0


  do i =1,size(NND)
       j  =  kappa *NND(i) + q  +1   ! il +1 serve per render l'intervallo 1, nbin   
       if (NND(i) .eq. Ma) j= nbin   ! eccezione, il massimo deve essere mandato in nbin
       if (NND(i) .eq. mi) j= 1      ! nel dubbio anche il minimo lo considero eccezionale
       binNND (j) = binNND(j)+1 
  enddo
!--------- fino a qui e' un binning, in cui sommo tutti i valori entro un certo intervallo
!--------- Se confronto deli binNND di diverse distribuzioni devo stare attento.
!--------- per normalizzare devo dividere per il delta x (la grandezza dei Bin= binsize = ((Ma-mi)*1.d0/nbin) ).
!--------- Se divido, ottengo una distribuzione normalizzata. Visto che quando confronto
!--------- le distribuzioni mi aspetto che siano come delle pdf, ha senso che divida prima di stamparle!


  binNND = binNND !/ ((Ma-mi)*1.d0/nbin)
  binsize = ((Ma-mi)*1.d0/nbin)



!-------- calcolo valor medio e varianza -----------------
   ave  = 0.d0
   do i=1,nbin
       ave = ave + (i-q)/kappa *  binNND(i)*1.d0/(N-lung_seq+1) 
   enddo

    ave = ave +   ((Ma-mi)*1.d0/nbin)  ! il punto di partenza e' a meta' strada dell'intervallo?

   var  = 0.d0
   do i=1, nbin   !    <  (x -<x>)**2 >  il valore e' la x il peso la y che devo moltiplicare poi
      var = var + ( ave -   (i-q)/kappa )**2 *  binNND(i)*1.d0/(N-lung_seq+1) 
   enddo
      var = sqrt(var )   
  !if (idisc.eq.1) write(200,*) ianal, ave , var
!---------------------------------------------------------




!-------- tutte le binNND -------------------------------

! rimpiazza i valori vecchi delle statistiche, tieni solo n_code_shadow 


    !write(63,*)ianal, n_code_shadow, mioModulo(ianal,n_code_shadow)

  do i=1, nbin
    longStat(1,mioModulo(ianal,n_code_shadow),i) =(i-q)/kappa  ! le code vanno dalla 1 alla n_code_shadow
  enddo

    longStat(2,mioModulo(ianal,n_code_shadow),:)  = binNND(:)*1.d0/(N-lung_seq+1) ! probabilita


 

  
!-------- calcolo valor medio e varianza -----------------
  ! ave  = 0.d0
  ! do i=1,nbin
  !     ave = ave + (i-q)/kappa *  binNND(i)*1.d0/(N-lung_seq+1) 
  ! enddo
  ! var  = 0.d0
  ! do i=1, nbin   !    <  (x -<x>)**2 >  il valore e' la x il peso la y che devo moltiplicare poi
  !    var = var + ( ave -   (i-q)/kappa )**2 *  binNND(i)*1.d0/(N-lung_seq+1) 
  ! enddo
  !    var = sqrt(var)   
  !if (idisc.eq.1) write(200,*) ianal, ave , var
!---------------------------------------------------------



!-   Devo calcolare Q3 e Q1 e quindi il valore per determinare se e'
!-   un outlier.
   CDFxOut0=0
   do i=1,nbin
       ! write(60+ianal,*) (i-q)/kappa,  sum(binNND(1:i))*1.d0/(N-lung_seq-1) ! CDF 
        CDFxOut =  sum(binNND(1:i))*1.d0/(N-lung_seq-1)
        if ( (CDFxOut-0.25d0)* (CDFxOUT0-0.25d0) .lt.0.d0) Q1 = (i-q)/kappa! I   quartile
                if ( (CDFxOut-0.5d0)* (CDFxOUT0-0.5d0) .lt.0.d0) QM = (i-q)/kappa! I   mediana
        if ( (CDFxOut-0.75d0)* (CDFxOUT0-0.75d0) .lt.0.d0) Q3 = (i-q)/kappa! III quartile
        CDFxOut0 = CDFxOut

   enddo
   IQ = Q3-Q1 ! interquartile

   
!if (idisc.eq.1)    write(200, *) ianal, QM , ave, var



end subroutine statistica


!---------------------------------------------------------------------

!---------------------------------------------------------------------

subroutine scrivi_riassunto(ianal)
   implicit none 
   integer :: i, ianal, j
   character (len=70) :: nomefile
   character (len =4) :: cnum_simboli
   character (len =4) :: clung_parole
   character (len =1) :: cifre  ! di quante cifre e' composto num_simboli
   character (len =20) :: cN  ! lunghezza serie 
   character (len =10) :: canal

   write(cnum_simboli,'(i4)') num_simboli
   write(clung_parole,'(i4)') lung_parole
   write(cN, '(i11)') N
   write(canal, '(i10)') ianal

   if (num_simboli .le. 10) cifre='1'
   if (num_simboli.ge. 10.and. num_simboli .le.  99) cifre='2'
   if (num_simboli.ge.100.and. num_simboli .le. 999) cifre='3'

  nomefile = './distNND/'  // 'NND_'   //  trim(nomiPar(1)) // '_'  //  trim(adjustl(algoritmo)) &
                         // "_nlett" // trim(adjustl(cnum_simboli)) // '_lungPar_' // trim(adjustl(clung_parole))      & 
                         // '_'//  trim(adjustl(cN)) // '_' // trim(adjustl(canal))



  open (unit =40, file=nomefile)

! occhio che divido per la larghezza dell'intervallo binsize, in modo che le distribuzioni
! siano confrontabili (altrimenti sembrano alte diverse...
!-------------------------------------------------------
   do i=1,nbin
       write(40,*) (i-q)/kappa,   (binNND(i)*1.d0/(N-lung_seq-1))/ binsize, &
                                  binNND(i), ianal , sum((binNND(1:i))*1.d0/(N-lung_seq-1))                  
   enddo
!-------------------------------------------------------
   close(40)





!----------- pdf dei punti ----------------------------------------
   nomefile =  "./files/pdf." // trim(nomiPar(1)) //  '_'// &
            trim(adjustl(cN)) // '_' // trim(adjustl(canal))

   open(unit=400, file=nomefile)

      do i=1, Ngrande
         write(400,*) xpos(i), pdf(i)*1.d0/ sum(pdf) , cdf(i), pdf(i)
      enddo

   close (400)
!-------------------------------------------------------------------




open (unit=124, file='coda_discord.dat')
  do i=size(coda_discord), 1, -1
   write(124,*) coda_discord(i)%posizione, coda_discord(i)%discord
  enddo
  write(124,*)
close(124)



!write(*,*) ' ========================================================='
!write(*,*) ' Posizione discord= ', iDiscord,  ' NND=',bestDist
!write(*,*) ' Posizione discord= ', iDiscord,  ' NND=',uso
!write(*,*) ' ========================================================='


if (nmax .gt. 1)     write(*,85, advance='no')' code analizzate', ianal &    ! se analizzi piu' di una coda
  ,char(8),char(8),char(8),char(8),char(8),  char(8),char(8),char(8),char(8),char(8) &
  ,char(8),char(8),char(8),char(8),char(8),  char(8),char(8),char(8),char(8),char(8) &
  ,char(8),char(8),char(8),char(8),char(8),  char(8),char(8),char(8),char(8),char(8) &
  ,char(8),char(8),char(8),char(8),char(8),  char(8),char(8),char(8),char(8),char(8) &
  ,char(8),char(8),char(8),char(8),char(8),  char(8),char(8),char(8),char(8),char(8) &
  ,char(8),char(8),char(8),char(8),char(8),  char(8),char(8),char(8),char(8),char(8) &
  ,char(8),char(8),char(8),char(8),char(8),  char(8),char(8),char(8),char(8),char(8) &
  ,char(8),char(8),char(8),char(8),char(8),  char(8),char(8),char(8),char(8),char(8)

     if (ianal.eq. nmax) write(*,'(A$)') char(13)   ! va a capo

!82 format (A,i5,5a1, A$) 
!83 format (  i5,5a1, A$) 

85 format (A16, i4, 80a1 )



end subroutine scrivi_riassunto

!---------------------------------------------------------------------


subroutine continuaAvideoEfile(idisc, ianal)
implicit none
integer, intent(in) :: idisc, ianal
integer :: i
     
    if (idisc.eq.1 .and. ianal.eq.1) chiamateAdistanzaVecchio =0.d0
!      n discord posiz      nnd  pos_vicino chiamate_a_dist  coda
!              1      9860     7.61923  14663           634107.    1



    if (idisc.eq.1.and.ianal.eq.1) write(22,*) 'n discord  sequenza         nnd seq_vicina   chiamate_a_dist  coda tot_chiamate'  


!   write(uscita,5342)    uscita e' fort.22

    write(22,5342) idisc, pos_discords(idisc)  + update_period * (ianal-1),  val_discords(idisc), &
                            pos_nei(pos_discords(idisc)), chiamateAdistanza -chiamateAdistanzaVecchio, & 
                           ianal, chiamateAdistanza
    chiamateAdistanzaVecchio = chiamateAdistanza  

5342 format(2i12,f20.5, i12,f18.0, i12, f18.0)
    if (idisc.eq.Nd) write(22,*) ' '



     if(idisc.eq.Nd ) then
                     call cpu_time(fineTempo) ! tempo esecuzione
                     write(22,*) 'Tempo esecuzione (s)',fineTempo-inizioTempo  & ! in Discord_algoritmo.dat
  ,'Include dalla lettura del file, SAX... al ritrovamento ultimo discord (no entropia, scrittura...)' 
     endif 

end subroutine continuaAvideoEfile


!---------------------------------------------------------------------
!---------------------------------------------------------------------
!---------------------------------------------------------------------
! provo a mettere un algoritmo di sorting, chiamato mergesort

subroutine Merge(A,NA,B,NB,C,NC)
 
   integer, intent(in) :: NA,NB,NC         ! Normal usage: NA+NB = NC
   integer, intent(in out) :: A(NA)        ! B overlays C(NA+1:NC)
   integer, intent(in)     :: B(NB)
   integer, intent(in out) :: C(NC)
 
   integer :: I,J,K
 
   I = 1; J = 1; K = 1;
   do while(I <= NA .and. J <= NB)
      if (A(I) <= B(J)) then
         C(K) = A(I)
         I = I+1
      else
         C(K) = B(J)
         J = J+1
      endif
      K = K + 1
   enddo
   do while (I <= NA)
      C(K) = A(I)
      I = I + 1
      K = K + 1
   enddo
   return
 
end subroutine merge
 
recursive subroutine MergeSort(A,N,T)
 
   integer, intent(in) :: N
   integer, dimension(N), intent(in out) :: A
   integer, dimension((N+1)/2), intent (out) :: T
 
   integer :: NA,NB,V
 
   if (N < 2) return
   if (N == 2) then
      if (A(1) > A(2)) then
         V = A(1)
         A(1) = A(2)
         A(2) = V
      endif
      return
   endif      
   NA=(N+1)/2
   NB=N-NA
 
   call MergeSort(A,NA,T)
   call MergeSort(A(NA+1),NB,T)
 
   if (A(NA) > A(NA+1)) then
      T(1:NA)=A(1:NA)
      call Merge(T,NA,A(NA+1),NB,A,N)
   endif
   return
 
end subroutine MergeSort

!---------------------------------------------------------------------


subroutine crea_dir ! crea le dir necessarie (se mancano)
implicit none
integer ::i
character(len=100) :: listaFiles
logical :: creaFiles, creaDistNND
  
 creaFiles  =.TRUE. ! di base costruisci le dir
 creaDistNND=.TRUE. ! 

 call system ('ls > lista.txt') 
 open (unit =30, file ='lista.txt')
   do i=1, 10000 ! la lista contiene meno di 10000 file e directory...
    read(30,*, end=2660) listaFiles
      if (trim(listaFiles).eq. 'files')   creaFiles  =.FALSE.  ! non c'e' bisogno di creare dir files
      if (trim(listaFiles).eq. 'distNND') creaDistNND=.FALSE.  ! idem  
   enddo
2660 continue
 close(30)
 call system ('rm lista.txt')

 if (creaFiles)   call system ('mkdir files')
 if (creaDistNND) call system ('mkdir distNND')

end subroutine crea_dir

!---------------------------------------------------------------------

subroutine confrontaCluster(A,B)
implicit none
integer ::i,j,indice
integer , dimension(:) :: A
integer , dimension(:) :: B


!integer , dimension(6) :: A
!integer , dimension(5) :: B
integer :: minimoB

A(1) = 1
A(2) = 4
A(3) = 15
A(4) = 17
A(5) = 20
A(6) = 28


B(1) = 2
B(2) = 3
B(3) = 4
B(4) = 20
B(5) = 29

!===================
!  1          2
!  4          3
!  15         4
!  17        20
!  20        29
!  28        30

minimoB = 1
indice = 0
do i=1, size(A)
 if (A(i).lt. minimoB) cycle ! evita di controllare se sei troppo piccolo
 do j=1, size(B)

   !write(*,*) A(i),B(j) 
   if (B(j) .lt. A(i)) cycle
   if (A(i) .eq. B(j))  then
       write(*,*) A(i) , 'trovato--------'
       exit  ! esci dal ciclo interno 
   endif 

   if (A(i) .lt. B(j)) then  ! la colonna b e' piu' grande
      minimoB = B(j)
      exit   ! esci dal ciclo interno   
   endif 
   

 enddo
enddo



end subroutine confrontaCluster
!---------------------------------------------------------------------

!---------------------------------------------------------------------
subroutine Zsax_Sequenze_composte(array,present_queue)
implicit none
integer, intent(in) :: present_queue
real(kind=8), dimension(:) :: array

     call nomeSub('Zsax_Sequenze_composte')
     call R_sequence(array)
     if (.not.gaussBreakPoints) then   ! se non usi i breakpoint Gaussiani, calcolali
        call TricavaPdf(array,1)                      
        call ricavaCdf (1)                          ! mi serve la cdf
        call intervalli_simboli(1)                  ! trova gli intervalli che definiscono i simboli
     endif  
     if ( gaussBreakpoints )   call Gauss_intervalli_simboli(1)                  ! trova gli intervalli che definiscono i simboli 
     call mod_Tcrea_seq_simboliche           ! versione corretta rispetto Zcrea_seq_simboliche 

     call tree_trova_Cluster_size
     call riordina_per_cluster(present_queue)    ! riordina l'array cluster con la logica, prima i piu' piccoli, poi nello stesso cluster
     call limiti_cluster    

end subroutine Zsax_Sequenze_composte


!---------------------------------------------------------------------











!---------------------------------------------------------------------
!subroutine musax(array, present_queue) ! implemento qui multi-sax
                                       ! calcolo varie sequenze simboliche associate a 1 sequenza
                                       ! invece di fare la media di tutti i punti di una parola
                                       ! spezzo din 2 parti la parola, testa e coda. Poi combino
                                       ! diverse teste e diverse code e a questo punto ho le rappresentazioni
                                       ! per fare la intersezione basta ordinare dove l'indice di cluster
                                       ! si comporta come la cifra di un sistema "decimale"
     ! call new_multi_r_sequence   
     ! uso le Gauss pdf (che e' piu' facile)
     ! Zcrea multi_sequenze simobliche
     ! call multi_riordina_per cluster 


! per potere gestire serie temporali lunghe non posso usare la struttura odierna
! dove si ha un array che contiene tutte le sequenze simboliche (inteso come 
! la sequenza simbolica della prima sequenza, quella della seconda, quella della terza
! anche se sono uguali tra loro.
! 
! quello che mi serve e' un array che contiene tutte le squenze simboliche trovate
! e un indice che data una sequenza mi mandi alla sequenza simbolica.
!
!  primo giro, controllo tutti gli r-punti e ottengo i valori minimi e massimi.
!  divido in 100 parti l'intervallo. Oppure uso i breakpoints gaussiani. 
! 
! quindi il processo deve essere continuo.
! leggo la prima sequenza
! la trasformo in r-sequenza
! la trasformo in una s-sequenza (con un tree)
! ottengo un indice delle sequenza  (1ma s-sequenza, 2da s-sequenza, 3za s-sequenza,....)
! aggiungo 1 al numero di sequenza associate alla s-sequenza
! ottengo l'indice che associa la sequnza alla s-sequenza (ovvero la 4324ma sequenza e' associata alla 12ma sequnza)

!---------------- NUOVA IDEA -------------------------------------------------
! vediamo un po'. Eseguo SAX normale, ad ogni sequenza associo un cluster.
! eseguo un nuovo SAX, ad ogni sequenza associo un altro cluster.
! costruisco una parola simbolica lunga composta della prima e seocnda parola simbolica qual'e' il vantaggio? 
! quando uso il tree e' equivalente a fare delle intersezioni! 
! a questo punto il numero del cluster e' un nuovo indice su cui posso costruire un tree !
! questo tree in pratica fa la intersezione dei vari cluster.

!end subroutine musax




!---------------------------------------------------------------------
subroutine Zsax(array,present_queue)
implicit none
integer, intent(in) :: present_queue
real(kind=8), dimension(:) :: array

     call nomeSub('Zsax')
     call R_sequence(array)
     if (.not.gaussBreakPoints) then   ! se non usi i breakpoint Gaussiani, calcolali
        call TricavaPdf(array,1)                      
        call ricavaCdf (1)                          ! mi serve la cdf
        call intervalli_simboli(1)                  ! trova gli intervalli che definiscono i simboli
     endif  
     !if (algoritmo.eq.'hsStandard' )&
     if ( gaussBreakpoints )   call Gauss_intervalli_simboli(1)                  ! trova gli intervalli che definiscono i simboli 
     !if ( gaussBreakpoints )   call sbagliato_intervalli_simboli(1) 
     !call Zcrea_seq_simboliche              ! costruisci seq simboliche e r-sequence (grande quasi quanto serie originale...pensaci) 
     call mod_Tcrea_seq_simboliche           ! versione corretta rispetto Zcrea_seq_simboliche 

     call tree_trova_Cluster_size
     !call trova_Cluster_Size(sequenze_simboliche(:,1))   ! costruisci le "sequence simboliche" (S_sequence) (non usa la sequenza, basta la posizione delle parole!)
     call riordina_per_cluster(present_queue)    ! riordina l'array cluster con la logica, prima i piu' piccoli, poi nello stesso cluster
     call limiti_cluster    

end subroutine Zsax


!---------------------------------------------------------------------

subroutine MU_sax( present_queue) ! questa sub e' di tipo low memory, quindi non costruisce sequenze_simboliche
                                 ! viene fatto sax multiplo. Ovvero non uso parole fatti di punti consecutivi
                                 ! ma punti divisi in teste e code. Se maxShuffle >1  ne costruisco varie di seq
     implicit none               ! simboliche e le uso per definire i cluster che vengono piu' piccoli   
     type(node), pointer :: t    ! rispetto a un sax normale. 
     integer, intent(in) :: present_queue
     integer :: j,i
     integer, dimension(lung_parole) :: seq_Test
     t => null()            ! annulla QUI

      !if (PA) call deriva
      !stop 'lifsjd'      

      call nomeSub('MU_sax')            ! scrivi a video che usi questa sub           
      call MU_allocca_inizializza      ! allocca e inizializza alcuni array usati poi  
      call MU_mezza_media              ! costruisce le mezze medie, ovvero mezzo r-punto (non normalizzato)
      call MU_shuffle_teste_code       ! crea array con posizioni random per teste e code
      call medie_varianze              ! calcola medie e varianze delle sequenze, per procedere poi alle distanze Znorm  
      call Gauss_intervalli_simboli(1) ! costruisce gli intervalli Gaussiani     

      do j=1,N-lung_seq+1  

       call MU_unisci_teste_code(j)    ! mette insieme teste e code, creando r-punto 
       call MU_crea_seq_simboliche(j) ! deve essere lanciato dopo LM_R_sequence, trasforma la r-sequenza in s-sequenza
       !lung_parole = lung_parole * maxShuffle
       call MU_inserisci(t,j)          ! inserisce la s-sequenza (associata alla sequenza in j) all'interno del tree
       !lung_parole = lung_parole/maxShuffle
      enddo

     call LM_deallocca_e_alloccaCS     ! deallocca alcuni array non piu' utili
     call riordina_per_cluster(present_queue)    ! riordina l'array cluster con la logica, prima i piu' piccoli, poi nello stesso cluster
     call limiti_cluster               ! trova i limiti dei cluster secondo il nuovo ordine. 
     
end subroutine MU_sax


!---------------------------------------------------------------------

!---------------------------------------------------------------------

subroutine PA_sax( present_queue) ! questa sub e' di tipo low memory, quindi non costruisce sequenze_simboliche
                                 ! viene fatto sax Physically Augmented o Paolo Avogadro. Costruisco parole simboliche
                                 ! che vengono fatte con la media dei punti della serie, ma anche della derivata e 
     implicit none               ! derivata seconda. In pratica una r-sequenza diventa 3 volte piu' lunga
     type(node), pointer :: t    ! rispetto a un sax normale. 
     integer, intent(in) :: present_queue
     integer :: j,i
     integer, dimension(lung_parole) :: seq_Test
     t => null()            ! annulla QUI

      call deriva                      ! costruisce derivata prima e seconda della serie 

      call nomeSub('PA_sax')            ! scrivi a video che usi questa sub           
      call MU_allocca_inizializza      ! allocca e inizializza alcuni array usati poi  
      call MU_mezza_media              ! costruisce le mezze medie, ovvero mezzo r-punto (non normalizzato)
      call MU_shuffle_teste_code       ! crea array con posizioni random per teste e code
      call medie_varianze              ! calcola medie e varianze delle sequenze, per procedere poi alle distanze Znorm  
      call Gauss_intervalli_simboli(1) ! costruisce gli intervalli Gaussiani     

      do j=1,N-lung_seq+1  

       call MU_unisci_teste_code(j)    ! mette insieme teste e code, creando r-punto 
       call MU_crea_seq_simboliche(j) ! deve essere lanciato dopo LM_R_sequence, trasforma la r-sequenza in s-sequenza
       !lung_parole = lung_parole * maxShuffle
       call MU_inserisci(t,j)          ! inserisce la s-sequenza (associata alla sequenza in j) all'interno del tree
       !lung_parole = lung_parole/maxShuffle
      enddo

     call LM_deallocca_e_alloccaCS     ! deallocca alcuni array non piu' utili
     call riordina_per_cluster(present_queue)    ! riordina l'array cluster con la logica, prima i piu' piccoli, poi nello stesso cluster
     call limiti_cluster               ! trova i limiti dei cluster secondo il nuovo ordine. 
     
end subroutine PA_sax


!---------------------------------------------------------------------







!---------------------------------------------------------------------
subroutine LM_sax( present_queue) ! questa sub fa sia Zsax che sax, ma non tengo in memoria tutto l'array sequenze_simboliche
                                   ! che e' estrememante oneroso, costruisco una parola per volta e la inserisco nel tree
                                   ! in questo modo ho le statistche per tutte le sequenze senza dover tenere le parole
     implicit none 
     type(node), pointer :: t   ! sempre annullare MA non nella dichiarazione!!!!!!
     integer, intent(in) :: present_queue
     integer :: j,i
     integer, dimension(lung_parole) :: seq_Test
     t => null()            ! annulla QUI
     

      call nomeSub('LM_Zsax')
      call LM_allocca_inizializza      ! allocca e inizializza alcuni array usati poi  
      call medie_varianze              ! calcola medie e varianze delle sequenze, per procedere poi alle distanze Znorm  
      if (.not.gaussBreakPoints)  then
        call LM_ricavaPdf                ! calcola max e min rpoint per breakpoints
        call ricavaCdf(1)
        call intervalli_simboli(1) 
      endif

      if (gaussBreakPoints) call Gauss_intervalli_simboli(1) ! costruisce gli intervalli Gaussiani     

      do j=1,N-lung_seq+1  
       call LM_R_sequence(j)           ! costruisce la r-sequenza associata alla sequenza che comincia in j    
       call LM_crea_seq_simboliche(j) ! deve essere lanciato dopo LM_R_sequence, trasforma la r-sequenza in s-sequenza
       call LM_inserisci(t,j)          ! inserisce la s-sequenza (associata alla sequenza in j) all'interno del tree
      enddo

     call LM_deallocca_e_alloccaCS     ! deallocca alcuni array non piu' utili
     call riordina_per_cluster(present_queue)    ! riordina l'array cluster con la logica, prima i piu' piccoli, poi nello stesso cluster
     call limiti_cluster               ! trova i limiti dei cluster secondo il nuovo ordine. 

    ! seq_Test(1)=2     
    ! seq_Test(2)=3     
    ! seq_Test(3)=2     
    ! seq_Test(4)=3     
    ! call LM_read_tree(t, seq_Test) ! con questa funzione posso ricavare le caratteristiche del cluster leggendo il tree

     
end subroutine LM_sax



!---------------------------------------------------------------------

subroutine LM_ZsaxP1(array,present_queue)
implicit none
integer, intent(in) :: present_queue
real(kind=8), dimension(:) :: array
integer :: j
type(node), pointer :: t   ! sempre annullare MA non nella dichiarazione!!!!!!
t => null()            ! annulla QUI


     call nomeSub('LM_ZsaxP1')
     call riallocca    
     call LM_allocca_inizializza
     call medie_varianze              ! calcola medie e varianze delle sequenze, per procedere poi alle distanze Znorm  

      if (.not.gaussBreakPoints)  then
        call LM_ricavaPdf                ! calcola max e min rpoint per breakpoints
        call ricavaCdf(1)
        call intervalli_simboli(1) 
      endif

      if (gaussBreakPoints) call Gauss_intervalli_simboli(1) ! costruisce gli intervalli Gaussiani     

      do j=1,N-lung_seq+1  
       call LM_R_sequence(j)           ! costruisce la r-sequenza associata alla sequenza che comincia in j    
       call LM_crea_seq_simboliche(j) ! deve essere lanciato dopo LM_R_sequence, trasforma la r-sequenza in s-sequenza
       call LM_inserisci(t,j)          ! inserisce la s-sequenza (associata alla sequenza in j) all'interno del tree
      enddo

     call LM_deallocca_e_alloccaCS     ! deallocca alcuni array non piu' utili
     call riordina_per_clusterP1     
     call limiti_clusterP1    

end subroutine LM_ZsaxP1




!---------------------------------------------------------------------

!---------------------------------------------------------------------

subroutine ZsaxP1(array,present_queue)
implicit none
integer, intent(in) :: present_queue
real(kind=8), dimension(:) :: array

     call nomeSub('ZsaxP1')
     call riallocca    
     call R_sequence(array)
     if (.not.gaussBreakPoints) then   ! se non usi i breakpoint Gaussiani, calcolali
      call TricavaPdf(array,1)                      
      call ricavaCdf (1)                          ! mi serve la cdf
      call intervalli_simboli(1)                  ! trova gli intervalli che definiscono i simboli 
     endif
     if ( gaussBreakpoints )   call Gauss_intervalli_simboli(1)                  ! trova gli intervalli che definiscono i simboli 
     call mod_Tcrea_seq_simboliche                    ! costruisci seq simboliche e r-sequence (grande quasi quanto serie originale...pensaci) 
     call tree_trova_Cluster_size
     !call trova_Cluster_Size(sequenze_simboliche(:,1))   ! costruisci le "sequence simboliche" (S_sequence) (non usa la sequenza, basta la posizione delle parole!)
     call riordina_per_clusterP1     
     call limiti_clusterP1    

end subroutine ZsaxP1




!---------------------------------------------------------------------

subroutine sax(array, present_queue)
     implicit none                    
     integer, intent(in):: present_queue 
     real (kind=8), dimension(:) :: array



     call nomeSub('sax')
     call R_sequence (array)                     ! costruisci i valori medi per le  "sequence ristrette" (R_sequence) con i punti della serie
     if (.not.gaussBreakPoints) then   ! se non usi i breakpoint Gaussiani, calcolali
       call ricavaPdf(array,1)                     ! per costruire simboli equiprobabili costruisci pdf dei valori medi che compongono le R_sequence
       call ricavaCdf (1)                          ! mi serve la cdf
       call intervalli_simboli(1)                  ! trova gli intervalli che definiscono i simboli 
     endif 
     if ( gaussBreakpoints )   call Gauss_intervalli_simboli(1)                  ! trova gli intervalli che definiscono i simboli 
     !if ( gaussBreakpoints )   call sbagliato_intervalli_simboli(1) 
     call crea_seq_simboliche                    ! costruisci seq simboliche e r-sequence (grande quasi quanto serie originale...pensaci)
     call tree_trova_Cluster_size 
     !call trova_Cluster_Size(sequenze_simboliche(:,1))   ! costruisci le "sequence simboliche" (S_sequence) (non usa la sequenza, basta la posizione delle parole!)
     call riordina_per_cluster(present_queue)    ! riordina l'array cluster con la logica, prima i piu' piccoli, poi nello stesso cluster
     call limiti_cluster    


end subroutine sax

!----------------------------------------------

subroutine saxP1(array, present_queue)
     implicit none                    
     integer, intent(in):: present_queue 
     real (kind=8), dimension(:) :: array

     call riallocca                     ! riallocca alcuni array se cambi le eXl e lung_parole 
     call R_sequence (serie)            ! rifai R_sequence della serie letta con i nuovi parametri
     if (.not.gaussBreakPoints) then   ! se non usi i breakpoint Gaussiani, calcolali
       call ricavaPdf(serie,1)            ! calcola i nuovi limiti con 1 simbolo in piu'
       call ricavaCdf (1)                 !
       call intervalli_simboli(1)         ! trova gli intervalli che definiscono i simboli 
     endif 
     if ( gaussBreakpoints )   call Gauss_intervalli_simboli(1)                  ! trova gli intervalli che definiscono i simboli 
     call crea_seq_simboliche 
     call tree_trova_Cluster_size
     !call trova_Cluster_Size        (  sequenze_simboliche(:,1) )   
     call riordina_per_clusterP1        ! qui li devo mettere in ordine di indice di cluster non in ordine di grandezza      
     call limiti_clusterP1


end subroutine saxP1

!----------------------------------------------



!------------------------------------------------------------------------------



!---------------------------------------------------------------------
end module hso


program statdist ! provo ad implementare una specie di HOTSAX in fortran 
                 ! originariamente questo codice prendeva una serie temporale e calcola i discord con un algoritmo
                 ! di tipo brute force, ovvero fa un doppio ciclo e si calcola la distanza tra ogni 
                 ! sequenza lunga l (evitando i self-match). A questo punto calcola quale sequenza
                 ! ha il closest neighbor piu' lontano (e' il loop interno) e fa una statistica
                 ! basata sulle distanze.  A occhio una statistica sulle distanze, visto che sono
                 ! calcolate con distanza euclidea come somma dei quadrati delle differneze dobrebbe
                 ! seguire una statistica simile ad un chiquadro!
use parametri
use hso
!use iso_fortran_env
implicit none
integer :: idisc
integer :: present_queue  ! indice della present queue
real(kind=8) , dimension(5)  ::  ics
integer :: j, newi
character (len=1000) :: daAnalizzare
! evita i self match con il cluster attuale e anche con quello piu' vicino, e con i baricentri
character (len=200) :: nomeSod, nomeAnomalie, nomeNND


chiamateAdistanza=0
ighost =0
!nomiPar(1) ='miaSerie'

   call get_command_argument(1,daAnalizzare)   ! trova il secondo argomento, che e' il nome del file da analizzare 
   !open (unit=20, file='daAnalizzare.dat'   )
   open (unit=20, file=daAnalizzare)

   call crea_dir         ! crea le dir necessarie 
   call leggi_input      ! i dati per tutto  

   call pre_leggi_serie  ! trova la lunghezza totale delf file
   call allocca_iniziale ! allocca vari array con i dati della serie
   call inizializza_1    ! dopo avere alloccato inizializza alcuni valori
   call costruisci_dettagliCalcolo ! stringa contenente parametri calcolo, per nome file
   call avideoEfile           ! mostra a video i parametri del codice


   num_simboli0= num_simboli
   num_simboli1= num_simboli+1

   nomeSod = 'sod_' // trim(algoritmo) // '.dat'  // dettagliCalcolo
   nomeNND = 'NND_' // trim(algoritmo) // '.dat'  // dettagliCalcolo
   nomeAnomalie = 'anomalieTrovate_' // trim(algoritmo) // '.dat'  // dettagliCalcolo

              open (unit=126, file=nomeSod)
              open (unit=127, file=nomeNND)
              open (unit= 28, file=nomeAnomalie ) 

   do present_queue =1, nmax!                    ! gira su tutti i batch da analizzare
     
     NND  = 0.d0                                ! gli NND approssimati vanno riazzerati per ogni present queue analizzata
     NND2 = 10000000000.d0                      ! numero grande 
     num_simboli = num_simboli0

     call cpu_time(inizioTempo)
     call leggi_serie(present_queue)             ! leggi la serie da analizzare


!------------ LEGENDA ARRAY UTILI ------------------
!       registro_prima_osservazione( indice del cluster )  = punto di inizio sequenza dove il cluster e' stato trovato la prima volta
!       clusterSize_uso            ( indice del cluster )  = grandezza del cluster (numero di sequenze che contiene)      
!       posizioneRegistro     (punto di inizio sequenza )  = indice del cluster (=  posizione nel registro di prima osservazione )
!       l'array cluster e' ordinato :prima il punto 3 (GRANDEZZA CLUSTER), poi il punto 2 (INDICE DEL CLUSTER)
!       quindi sequenze di uno stesso cluster sono una dietro l'altra! 
!       cluster( 1 , indice generico che gira va da 1 al numero tot di sequenza ) =  punto di inizio di una sequenza
!       cluster( 2 , indice generico che gira va da 1 al numero tot di sequenza ) =  indice del cluster             associato alla sequenza che comincia in cluster(1,i)  
!       cluster( 3 , indice generico che gira va da 1 al numero tot di sequenza ) =  numero di elementi del cluster associato alla sequenza che comincia in cluster(1,i) 
!       media (punto nella serie) = media dei punti da "punto nella serie" fino a "punto nella serie" + eXl (elementi per lettera)
!
!       se ho un cluster SizeCluster quante lettere devo aggiungere ottenere dei cluster di circa 100 elementi?
!      
!       SizeCluster  =  100  = dimensione media dei sottocluster voluti
!       -----------
!       c**lettXparola


!----------------------------------    SAX -----------------------------------------------------
!----------------------------------    SAX -----------------------------------------------------
!----------------------------------    SAX -----------------------------------------------------

! LEGENDA:
! MU_sax = sax Multiplo, mUltiplicita' data da maxShuffle
! Zsax, prima versione tengo in memoria le sequenze simboliche 
! LM_sax, low memory, NON memorizzo le sequenze simboliche NON scrivo grossi file
! ZsaxP1, come Zsax ma con alfabeto +_1  
! LM_ZsaxP1 come LM_sax, con alfabeto+1 

!---------------------------------------------------- nonZnorm  |  Znorm  | Gauss Bp  | Exp. Bp |  risparmia Memoria?      
     if (musax)  call MU_sax(present_queue)         !     X     !    X    !    X      !    O    !         X

     if (.not.risparmiaMemoria .and. .not. musax) & !     X     |    X    |    X      |    X    |         O  
       call Zsax(serie, present_queue)              !           !         !           !         !
                                                    !           !         !           !         !
     if (     risparmiaMemoria .and. .not.musax) &  !     X     |    X    |    X      |    X    |         X                           
       call LM_sax(present_queue) ! sax 
     
     if (algoritmo .eq. 'sod') then ! serve solo se cerco SOD 
       num_simboli = num_simboli0+1 !  
 
if (.not.risparmiaMemoria) call ZsaxP1(serie, present_queue) !  X!   X    !    X      !    X    !         O
if (     risparmiaMemoria) call LM_ZsaxP1(serie, present_queue)!X!   X    !    X      !    X    !         X
     endif 

!=================================  FINE SAX ====================================================
!=================================  FINE SAX ====================================================
!=================================  FINE SAX ====================================================

     !write(*,*) distanza(9492,9491)
     !stop 'fssfsgfs'
    

     !!call motif1 (1, present_queue) 
     !stop 'ljsff'

     do idisc =1,Nd                              ! cerca I discord, II discord, ..., Nd-esimo discord                    
                                                                                                   !            lung_seq =100   |  lung_seq= 3000
                                                                                                   !bruteforce   ~       x NxN
         if (algoritmo.eq.     'brute') call brute     (idisc, present_queue) ! usa algoritmo smart bruteforce   ~  1/2  x NxN
         if (algoritmo.eq.       'sod') call sod       (idisc, present_queue) ! usa sod                          ~  200  x N 
         if (algoritmo.eq.'hsStandard') call HSstandard(idisc, present_queue) ! usa algoritmo HOT SAX standard   ~10-100 x N    |       1000 x N  
         if (algoritmo.eq.     'mioHS') call mioHS     (idisc, present_queue) ! usa algoritmo mio HS, piu' veloce~ 5- 50 x N            
         if (algoritmo.eq.      'very') call veryHS    (idisc, present_queue) ! usa algoritmo smart              ~   20  x N
         if (algoritmo.eq.     'altro') call Altro     (idisc, present_queue) ! usa algoritmo piu' veloce        ~   10  x N    |         10 x N
         if (algoritmo.eq.     'qzaltro') call qzAltro     (idisc, present_queue) ! usa algoritmo piu' veloce        ~   10  x N    |         10 x N
         !if (algoritmo.eq.     'altro') call pulito_Altro     (idisc, present_queue) ! usa algoritmo piu' veloce        ~   10  x N    |         10 x N
         if (algoritmo.eq.     'sm_altro') call SM_Altro     (idisc, present_queue) ! usa algoritmo piu' veloce        ~   10  x N    |         10 x N
         if (algoritmo.eq. 'selfMatch') call HSstandard_selfMatch(idisc, present_queue)
          

                             call continuaAvideoEfile  (idisc, present_queue)  ! scrivi in unita 22 i discord
                             call statistica           (idisc, present_queue)  ! fai NND distribution
                             call longStatistica       (idisc, present_queue)  ! mantieni le vecchie NND distribution 
                             call aggiorna_coda_discord(idisc, present_queue)  ! aggiorna coda discord
                             call scrivi_Sod           (idisc, present_queue)  ! scrivi il file sod_"algoritmo".dat 
     enddo
 

     longStat (1,:,:) = shrink * longStat(1,:,:)  ! i valori vecchi diventano meno importanti
     coda_discord(:)%discord = coda_discord(:)%discord *shrink
     

                             call writesingolalimiti(1, serie) 
                             call Entropia 
 if (algoritmo.ne.'sm_altro')call scrivi_riassunto(present_queue) ! scrivi a file i risultati
                             call deallocca
   enddo   ! ciclo sulle  code

   call finaleVideo_e_chiudi


!     write(*,*) 'per fare reshuffling dei cluster, prendi il valore, e aggiungi un numero'
!     write(*,*) 'random piccolo 10-20 (magari basato sulla grandezza media dei cluster'
!     Write(*,*) ' in questo modo ogni volta si ha un ordine diverso per i cluster piccoli'
!     write(*,*) ' e questo puo velocizzare'




end program statdist

