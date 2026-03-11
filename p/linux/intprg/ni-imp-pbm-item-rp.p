/*********************************************************************************
**
**  Programa - NI-IMP-PBM-ITEM-RP.P - Importa‡Æo PBM do Item
**
*********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-PBM-ITEM-RP 2.00.00.000 } 

disable triggers for load of it-carac-tec.
disable triggers for load of it-res-carac.

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

def temp-table tt-pbm
    FIELD c-forn  AS CHAR
    FIELD c-item  AS CHAR
    FIELD c-desc  AS CHAR
    FIELD c-grupo AS CHAR
    FIELD c-sit   AS CHAR
    FIELD c-prog  AS CHAR
    FIELD c-site  AS CHAR
    FIELD c-oper  AS CHAR
    FIELD c-dscto AS CHAR
    FIELD c-pbm   AS CHAR
    FIELD c-min   AS CHAR
    FIELD c-max   AS CHAR.

DEF VAR h-acomp AS HANDLE          NO-UNDO.
def var i-cont as int format ">>>,>>>,>>9".

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo PBM Item").

EMPTY TEMP-TABLE tt-pbm.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".

assign i-cont = 0.
 
REPEAT:  
   CREATE tt-pbm.
   IMPORT DELIMITER ";" tt-pbm.  

   assign i-cont = i-cont + 1.

   run pi-acompanhar in h-acomp (input "Criando tt-pbm: " + string(tt-pbm.c-item) + " - " + string(i-cont)).

END. 
    
INPUT CLOSE.

ASSIGN i-cont = 0.

FOR EACH tt-pbm:

    assign i-cont = i-cont + 1.

    run pi-acompanhar in h-acomp (input "Importando PBM Item: " + string(tt-pbm.c-item) +  " - " + string(i-cont)).
   
    FOR EACH it-carac-tec WHERE 
             it-carac-tec.it-codigo = tt-pbm.c-item AND
             it-carac-tec.cd-folha  = "CADITEM":

        IF it-carac-tec.cd-comp = "360" THEN DO:
           FIND FIRST ITEM WHERE 
                      ITEM.it-codigo = tt-pbm.c-item NO-LOCK NO-ERROR.
           IF AVAIL ITEM THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.it-codigo = tt-pbm.c-item AND
                         it-res-carac.cd-folha  = "CADITEM"     AND
                         it-res-carac.cd-comp   = "360"         AND 
                         it-res-carac.nr-tabela = 360           NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 CREATE it-res-carac.
                 ASSIGN it-res-carac.it-codigo  = tt-pbm.c-item
                        it-res-carac.cd-folha   = "CADITEM"    
                        it-res-carac.cd-comp    = "360"        
                        it-res-carac.nr-tabela  = 360          
                        it-res-carac.sequencia  = 10
                        it-carac-tec.observacao = "S-SIM".
              END.  
              ELSE
                 ASSIGN it-res-carac.sequencia  = 10
                        it-carac-tec.observacao = "S-SIM".
           END.
        END.
    END.
END.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo PBM do Item"
       c-programa     = "NI-IMP-PBM-ITEM-RP".

{include/i-rpcab.i}

view frame f-cabec.

view frame f-rodape.    

{include/i-rpclo.i}
