/********************************************************************************
**
**  Programa - NI-IMP-REDUTOR-ABC-RP.P - Importa‡Æo Redutor ABC - Item
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-REDUTOR-ABC 2.00.00.000 } 

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

DEF TEMP-TABLE tt-redutor
    FIELD it-codigo  AS CHAR    
    FIELD redutor    AS DEC.
                                             
DEF VAR i-cont      AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp     AS HANDLE                   NO-UNDO.
DEF VAR l-erro      AS LOGICAL                  NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo Redutor ABC Item").

EMPTY TEMP-TABLE tt-redutor.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-redutor.
   IMPORT DELIMITER ";" tt-redutor.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-redutor: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-redutor WHERE
         tt-redutor.it-codigo <> "":

    assign i-cont = i-cont + 1
           l-erro = NO.

    FOR EACH item-uf WHERE
             item-uf.it-codigo = tt-redutor.it-codigo AND
             item-uf.estado    = "PR":

        run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-redutor.it-codigo) + " - " + string(i-cont)).

        ASSIGN item-uf.perc-red-sub             = tt-redutor.redutor
               item-uf.val-perc-reduc-tab-pauta = tt-redutor.redutor.
    END.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo Redutor ABC"
       c-programa     = "NI-IMP-REDUTOR-ABC".

{include/i-rpcab.i}

view frame f-cabec.

view frame f-rodape.    

{include/i-rpclo.i}





