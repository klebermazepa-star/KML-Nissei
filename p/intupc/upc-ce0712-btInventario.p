def new global shared var r-rowid-upc-ce0712      AS ROWID no-undo.
def new global shared var c-it-codigo      AS CHAR no-undo.
def new global shared var c-dt-saldo      AS DATE no-undo.
def new global shared var c-cod-estabel      AS CHAR NO-UNDO.
def new global shared var c-cod-depos      AS CHAR no-undo.

def var h-acomp as handle no-undo.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.

RUN pi-inicializar IN h-acomp (INPUT 'Processando...').

//OUTPUT TO VALUE ("U:\InventarioGeral-" + string(c-dt-saldo) + ".csv").
OUTPUT TO VALUE ("U:\InventarioGeral.csv").
PUT UNFORMATTED '"Item";"Estabelecimento";"Deposito";"Lote";' SKIP.

DEFINE TEMP-TABLE ttInventario NO-UNDO
    FIELD it-codigo   AS CHARACTER
    FIELD cod-estabel AS CHARACTER
    FIELD cod-depos   AS CHARACTER.


    
    
FOR EACH inventario NO-LOCK 
    WHERE inventario.dt-saldo = c-dt-saldo
      BREAK BY inventario.it-codigo:

    IF FIRST-OF(inventario.it-codigo) THEN DO:
    
    
        CREATE ttInventario.
        ASSIGN ttInventario.it-codigo   = inventario.it-codigo
               ttInventario.cod-estabel = inventario.cod-estabel
               ttInventario.cod-depos   = inventario.cod-depos.
        
    END.

END.

     
FOR EACH ttInventario :

    

    .MESSAGE  ttInventario.it-codigo  SKIP
         ttInventario.cod-estabel SKIP
         ttInventario.cod-depos SKIP 
         c-dt-saldo
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    FOR EACH saldo-estoq NO-LOCK                                 
        WHERE  saldo-estoq.it-codigo    = ttInventario.it-codigo   
        AND    saldo-estoq.cod-estabel  = ttInventario.cod-estabel 
        AND    saldo-estoq.cod-depos    = ttInventario.cod-depos:
        
        FIND FIRST inventario
            WHERE inventario.it-codigo         = saldo-estoq.it-codigo
              AND inventario.cod-estabel       = saldo-estoq.cod-estabel
              AND inventario.cod-depos         = saldo-estoq.cod-depos
              AND inventario.lote              = saldo-estoq.lote
              AND inventario.dt-saldo          = c-dt-saldo NO-ERROR.
        
        
        IF NOT AVAIL inventario THEN
        DO:
        
               .MESSAGE saldo-estoq.it-codigo   SKIP
                        saldo-estoq.cod-estabel  SKIP
                        saldo-estoq.cod-depos    SKIP
                        saldo-estoq.lote
                       
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
            CREATE inventario.
            ASSIGN inventario.it-codigo         = saldo-estoq.it-codigo
                   inventario.cod-estabel       = saldo-estoq.cod-estabel
                   inventario.cod-depos         = saldo-estoq.cod-depos
                   inventario.lote              = saldo-estoq.lote
                   inventario.qtidade-atu       = 0  //Criar sempre com 0
                   inventario.dt-saldo          = c-dt-saldo
                   inventario.dt-ult-entra      = saldo-estoq.data-ult-ent
                   inventario.dt-ult-saida      = ?
                   inventario.situacao          = 4
                   inventario.val-apurado[1]    = ?
                   inventario.nr-ficha          = nr-ficha
                   inventario.cod-confte-contag-1 = "RPW"
                   inventario.dt-atualiza       = ?
                   inventario.ind-sit-invent-wms    = 1
                   .
             
            EXPORT DELIMITER ";" saldo-estoq.it-codigo  
                                 saldo-estoq.cod-estabel
                                 saldo-estoq.cod-depos  
                                 saldo-estoq.lote . 
            
        END.
        
    END.    
   
   
   
   
END.

run pi-finalizar in h-acomp.
OS-COMMAND NO-WAIT VALUE("U:\InventarioGeral.csv").


    
    
/*

Table: saldo-estoq

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod-estabel                 char       im  x(5)
cod-depos                   char       im  x(3)
lote                        char       im  x(40)
it-codigo                   char       im  x(16)
qtidade-ini                 deci-4     m   ->>>,>>>,>>9.9999
qtidade-atu                 deci-4     m   ->>>,>>>,>>9.9999
data-ult-ent                date           99/99/9999
dt-vali-lote                date       i   99/99/9999
dt-ul-contag                date           99/99/9999
qtidade-fin                 deci-4     m   ->>>,>>>,>>9.9999
cod-refer                   char       im  x(8)
qt-aloc-prod                deci-4         >>>>,>>9.9999
qt-alocada                  deci-4         >>>>,>>9.9999
qt-aloc-ped                 deci-4         >>>>,>>9.9999
concentracao                deci-4     m   >>>9,9999
rendimento                  deci-4     m   >>>9,9999
cd-referencia               char           x(4)
cod-localiz                 char       im  x(20)
dt-fabric                   date           99/99/9999
char-1                      char           x(100)
char-2                      char           x(100)
dec-1                       deci-8         ->>>>>>>>>>>9.99999999
dec-2                       deci-8         ->>>>>>>>>>>9.99999999
int-1                       inte           ->>>>>>>>>9
int-2                       inte           ->>>>>>>>>9
log-1                       logi           Sim/NÆo
log-2                       logi           Sim/NÆo
data-1                      date           99/99/9999
data-2                      date           99/99/9999
check-sum                   char           x(20)
num-id-saldo-estoq          inte       im  >>>,>>>,>>9
qt-mensal-ate               deci-4         ->>>,>>>,>>9.9999
per-ppm                     deci-4         >>>>,>>9.9999
qtd-transi                  deci-4         ->>>,>>>,>>9.9999
log-reg-zero                logi       im  Sim/NÆo
qtidade-ini-geren           deci-4         ->>>,>>>,>>9.9999



Table: inventario

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
it-codigo                   char       im  x(16)
cod-estabel                 char       im  x(5)
cod-depos                   char       im  x(3)
lote                        char       im  x(40)
qtidade-atu                 deci-4     m   ->>>>,>>>,>>9.9999
dt-saldo                    date       im  99/99/9999
dt-ult-entra                date           99/99/9999
dt-ult-saida                date           99/99/9999
valor-final                 deci-4     m   ->>>>,>>>,>>9.9999
valor-contab                deci-4     m   >>>>,>>>,>>9.9999
val-apurado                 deci-4[3]      >>>>,>>>,>>9.9999
situacao                    inte       m   >9
dt-atualiza                 date           99/99/9999
nr-ficha                    inte       im  >>>>,>>9
cod-localiz                 char       im  x(20)
valor-mat-p                 deci-4[3]      >>>>,>>>,>>9.9999
valor-mat-o                 deci-4[3]      >>>>,>>>,>>9.9999
valor-mat-m                 deci-4[3]      >>>>,>>>,>>9.9999
valor-mob-m                 deci-4[3]      >>>>,>>>,>>9.9999
valor-mob-o                 deci-4[3]      >>>>,>>>,>>9.9999
valor-mob-p                 deci-4[3]      >>>>,>>>,>>9.9999
valor-ggf-p                 deci-4[3]      >>>>,>>>,>>9.9999
valor-ggf-m                 deci-4[3]      >>>>,>>>,>>9.9999
valor-ggf-o                 deci-4[3]      >>>>,>>>,>>9.9999
char-1                      char           x(100)
char-2                      char           x(100)
dec-1                       deci-8         ->>>>>>>>>>>9.99999999
dec-2                       deci-8         ->>>>>>>>>>>9.99999999
int-1                       inte           ->>>>>>>>>9
int-2                       inte           ->>>>>>>>>9
log-1                       logi           Sim/NÆo
log-2                       logi           Sim/NÆo
data-1                      date           99/99/9999
data-2                      date           99/99/9999
check-sum                   char           x(20)
impressa                    logi       m   Sim/NÆo
cod-refer                   char       im  X(8)
ind-sit-invent-wms          inte           9
cod-confte-contag-1         char           x(30)
cod-confte-contag-2         char           x(30)
cod-confte-contag-3         char           x(30)
cdn-agrup                   inte       i   >>>,>>>,>>9
*/
