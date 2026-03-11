/********************************************************************************
**
**  Programa - NI-IMP-EAN-ITEM.P - Importaá∆o EAN Item
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-EAN-ITEM 2.00.00.000 } 

define temp-table tt-param
    field destino          as integer
    field arq-destino      as char
    field arq-entrada1     as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer.

def temp-table tt-raw-digita                      
    field raw-digita      as raw.                 

DEF TEMP-TABLE tt-ean-item
    FIELD it-codigo     LIKE int-ds-ean-item.it-codigo    
    FIELD codigo-ean    LIKE int-ds-ean-item.codigo-ean   
    FIELD lote-multiplo LIKE int-ds-ean-item.lote-multiplo
    FIELD altura        LIKE int-ds-ean-item.altura       
    FIELD largura       LIKE int-ds-ean-item.largura      
    FIELD profundidade  LIKE int-ds-ean-item.profundidade 
    FIELD peso          LIKE int-ds-ean-item.peso         
    FIELD data-cadastro LIKE int-ds-ean-item.data-cadastro
    FIELD principal     AS   CHAR. 
                                             
DEF TEMP-TABLE tt-erro
    FIELD desc-erro AS CHAR FORMAT "x(50)".

DEF VAR i-cont      AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp     AS HANDLE                   NO-UNDO.
DEF VAR l-erro      AS LOGICAL                  NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importaá∆o EAN Item").

EMPTY TEMP-TABLE tt-ean-item.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-ean-item.
   IMPORT DELIMITER ";" tt-ean-item.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-ean-item: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-ean-item WHERE
         tt-ean-item.it-codigo <> "":

    assign i-cont = i-cont + 1
           l-erro = NO.

    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-ean-item.it-codigo) + " - " + string(i-cont)).

    FOR FIRST ITEM WHERE
              ITEM.it-codigo = tt-ean-item.it-codigo NO-LOCK:
    END.
    IF NOT AVAIL ITEM THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.desc-erro = "Item " + tt-ean-item.it-codigo + " n∆o cadastrado."
              l-erro            = YES.
    END.

    FOR FIRST int-ds-ean-item WHERE
              int-ds-ean-item.codigo-ean = tt-ean-item.codigo-ean NO-LOCK:
    END.
    IF AVAIL int-ds-ean-item THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.desc-erro = "EAN " + string(tt-ean-item.codigo-ean) + " j† cadastrado."
              l-erro            = YES.
    END.

    FOR FIRST int-ds-ean-item WHERE
              int-ds-ean-item.it-codigo  = tt-ean-item.it-codigo AND
              int-ds-ean-item.codigo-ean = tt-ean-item.codigo-ean NO-LOCK:
    END.
    IF AVAIL int-ds-ean-item THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.desc-erro = "EAN " + string(tt-ean-item.codigo-ean) + " j† cadastrado para o Item " + tt-ean-item.it-codigo
              l-erro            = YES.
    END.

    IF l-erro = NO THEN DO:
       CREATE int-ds-ean-item.
       ASSIGN int-ds-ean-item.it-codigo     = tt-ean-item.it-codigo
              int-ds-ean-item.codigo-ean    = tt-ean-item.codigo-ean
              int-ds-ean-item.lote-multiplo = tt-ean-item.lote-multiplo
              int-ds-ean-item.altura        = tt-ean-item.altura 
              int-ds-ean-item.largura       = tt-ean-item.largura
              int-ds-ean-item.profundidade  = tt-ean-item.profundidade
              int-ds-ean-item.peso          = tt-ean-item.peso
              int-ds-ean-item.data-cadastro = tt-ean-item.data-cadastro
              int-ds-ean-item.principal     = IF tt-ean-item.principal = "S" THEN YES ELSE NO. 
    END.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importaá∆o EAN Item"
       c-programa     = "NI-IMP-EAN-ITEM".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro:
    disp tt-erro.desc-erro COLUMN-LABEL "Descriá∆o Erro"
         with width 132 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}





