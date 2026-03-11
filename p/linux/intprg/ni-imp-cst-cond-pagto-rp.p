/********************************************************************************
**
**  Programa - NI-IMP-CST-COND-PAGTO-RP.P - Importa‡Æo tabela CST-COND-PAGTO
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-CST-COND-PAGTO-RP 2.00.00.000 } 

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

DEF TEMP-TABLE tt-cst-cond-pagto
    FIELD cod-cond-pag   LIKE cond-pagto.cod-cond-pag
    FIELD modo-devolucao LIKE cst-cond-pagto.modo-devolucao.

DEF VAR i-cont       AS INT FORMAT ">>>,>>9"   NO-UNDO.
DEF VAR h-acomp      AS HANDLE                 NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo CST-COND-PAGTO").

EMPTY TEMP-TABLE tt-cst-cond-pagto.

FOR EACH cst-cond-pagto:
    DELETE cst-cond-pagto.
END.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-cst-cond-pagto.
   IMPORT DELIMITER ";" tt-cst-cond-pagto NO-ERROR.  

   assign i-cont = i-cont + 1.

   run pi-acompanhar in h-acomp (input "Criando tt-cst-cond-pagto: " + string(tt-cst-cond-pagto.cod-cond-pag) + " - " + string(i-cont)).
END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.

for each tt-cst-cond-pagto:

    assign i-cont = i-cont + 1.

    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-cst-cond-pagto.cod-cond-pag) + " - " + string(i-cont)).

    FIND FIRST cond-pagto WHERE
               cond-pagto.cod-cond-pag = tt-cst-cond-pagto.cod-cond-pag NO-ERROR.
    IF AVAIL cond-pagto THEN DO:
       CREATE cst-cond-pagto.
       ASSIGN cst-cond-pagto.cod-cond-pag   = tt-cst-cond-pagto.cod-cond-pag
              cst-cond-pagto.modo-devolucao = IF tt-cst-cond-pagto.modo-devolucao = "1" THEN 
                                                 "Dinheiro" 
                                              ELSE 
                                                 IF tt-cst-cond-pagto.modo-devolucao = "2" THEN
                                                    "Cartao"
                                                 ELSE "Nenhum".
    END.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo CST-COND-PAGTO"
       c-programa     = "NI-IMP-CST-COND-PAGTO-RP".

{include/i-rpcab.i}

view frame f-cabec.

view frame f-rodape.    

{include/i-rpclo.i}





