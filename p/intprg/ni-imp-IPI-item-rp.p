/********************************************************************************
**
**  Programa - NI-IMP-IPI-ITEM-RP.P - Atualizaá∆o do IPI dos Itens
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-IPI-ITEM-RP 2.00.00.000 } 

DISABLE TRIGGERS FOR LOAD OF item-uf.

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

DEF TEMP-TABLE tt-ipi-item
    FIELD it-codigo    LIKE item.it-codigo
    FIELD aliquota-ipi AS DEC.

DEF TEMP-TABLE tt-erro
    FIELD it-codigo LIKE item.it-codigo
    FIELD descricao AS CHAR FORMAT "x(40)" COLUMN-LABEL "Descriá∆o".

DEF VAR i-cont        AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp       AS HANDLE                   NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Atualizaá∆o IPI do Item").

EMPTY TEMP-TABLE tt-ipi-item.
EMPTY TEMP-TABLE tt-erro.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-ipi-item.
   IMPORT DELIMITER ";" tt-ipi-item.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-ipi-item: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-ipi-item WHERE 
         tt-ipi-item.it-codigo <> "" BREAK BY tt-ipi-item.it-codigo:
    FIND FIRST ITEM WHERE
               ITEM.it-codigo = tt-ipi-item.it-codigo NO-ERROR.
    IF NOT AVAIL ITEM THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.it-codigo = tt-ipi-item.it-codigo
              tt-erro.descricao = "Item n∆o cadastrado no Datasul".
       NEXT.
    END.

    ASSIGN ITEM.aliquota-ipi = tt-ipi-item.aliquota-ipi.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Atualizaá∆o do IPI dos Itens"
       c-programa     = "NI-IMP-IPI-ITEM-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro BY tt-erro.it-codigo:
    disp tt-erro with width 300 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}





