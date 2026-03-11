/********************************************************************************
**
**  Programa - NI0305RP.P - Importa‡Æo do Custo Unit rio dos Itens
**
********************************************************************************/ 

{include/i-prgvrs.i NI0305RP 2.00.00.000 } 

define temp-table tt-param
    field destino          as integer
    field arq-destino      as char
    field arq-entrada1     as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as INTEGER
    FIELD atualiza         AS LOGICAL.

def temp-table tt-raw-digita                      
    field raw-digita      as raw.                 

DEF VAR i-cont  AS INT    NO-UNDO.

DEFINE TEMP-TABLE tt-importa
    field it-codigo     as char
    FIELD cod-estabel   AS CHAR
    field preco-base    like item-uni-estab.preco-base
    field preco-ul-ent  like item-uni-estab.preco-ul-ent.

DEF VAR h-acomp       AS HANDLE                   NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo Custo Unit rio").

EMPTY TEMP-TABLE tt-importa.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-importa.
   IMPORT DELIMITER ";" tt-importa.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Importando Registros: " + string(i-cont,">>>,>>>,>>9")).
END. 
    
INPUT CLOSE.
  
{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo do Custo Unit rio dos Itens"
       c-programa     = "NI0305RP".

{include/i-rpcab.i}

view frame f-cabec.
view frame f-rodape.    

ASSIGN i-cont = 0.

FOR EACH tt-importa NO-LOCK:    
        
    for each item-uni-estab WHERE 
             item-uni-estab.cod-estabel = TRIM(STRING(tt-importa.cod-estabel, "999")) AND
             item-uni-estab.it-codigo   = tt-importa.it-codigo:

        ASSIGN i-cont = i-cont + 1.

        run pi-acompanhar in h-acomp (input "Processando Item: " + item-uni-estab.it-codigo + " - " + string(i-cont,">>>,>>>,>>9")).
    
        disp item-uni-estab.it-codigo
             item-uni-estab.preco-base   COLUMN-LABEL "Pre‡o Base Datasul"
             item-uni-estab.preco-ul-ent COLUMN-LABEL "Pre‡o Ult. Ent. Datasul"
             tt-importa.preco-base       COLUMN-LABEL "Pre‡o Base Novo"
             tt-importa.preco-ul-ent     COLUMN-LABEL "Pre‡o Ult. Ent. Novo"
             WITH STREAM-IO NO-BOX DOWN WIDTH 132 FRAME f-importa.

        IF tt-param.atualiza = YES THEN DO:
           ASSIGN item-uni-estab.preco-base   = tt-importa.preco-base
                  item-uni-estab.preco-ul-ent = tt-importa.preco-ul-ent.
        END.
    END.
END.

run pi-finalizar in h-acomp.

{include/i-rpclo.i}





