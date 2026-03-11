/********************************************************************************
**
**  Programa - NI-IMP-IPI-NCM-RP.P - Atualizaá∆o do IPI dos Itens
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-IPI-NCM-RP 2.00.00.000 } 

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

DEF TEMP-TABLE tt-ipi-ncm
    FIELD ncm          AS CHAR
    FIELD aliquota-ipi AS DEC.

DEF TEMP-TABLE tt-erro
    FIELD ncm       AS CHAR FORMAT "x(35)" 
    FIELD descricao AS CHAR FORMAT "x(60)" COLUMN-LABEL "Descriá∆o".

DEF VAR i-cont        AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp       AS HANDLE                   NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Atualizaá∆o IPI da NCM").

EMPTY TEMP-TABLE tt-ipi-ncm.
EMPTY TEMP-TABLE tt-erro.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-ipi-ncm.
   IMPORT DELIMITER ";" tt-ipi-ncm.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-ipi-ncm: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-ipi-ncm WHERE 
         tt-ipi-ncm.ncm <> "" BREAK BY tt-ipi-ncm.ncm:
    FIND FIRST classif-fisc WHERE
               classif-fisc.class-fiscal = tt-ipi-ncm.ncm NO-ERROR.
    IF NOT AVAIL classif-fisc THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.ncm       = tt-ipi-ncm.ncm
              tt-erro.descricao = "Classificaá∆o Fiscal (NCM) n∆o cadastrada no Datasul".
       NEXT.
    END.

    ASSIGN classif-fisc.aliquota-ipi  = tt-ipi-ncm.aliquota-ipi.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Atualizaá∆o do IPI das NCMs"
       c-programa     = "NI-IMP-IPI-NCM-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro BY tt-erro.ncm:
    disp tt-erro with width 300 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}





