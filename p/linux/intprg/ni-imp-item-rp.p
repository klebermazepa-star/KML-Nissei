/********************************************************************************
**
**  Programa - NI-IMP-ITEM-RP.P - Validaá∆o Item UF
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-ITEM-RP 2.00.00.000 } 

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

DEF TEMP-TABLE tt-item
    FIELD it-codigo LIKE item.it-codigo.

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

run pi-inicializar in h-acomp (input "Validaá∆o Item").

EMPTY TEMP-TABLE tt-item.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-item.
   IMPORT DELIMITER ";" tt-item.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-item: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-item WHERE 
         tt-item.it-codigo <> "" BREAK BY tt-item.it-codigo:

    IF LAST-OF(tt-item.it-codigo) THEN DO:
       assign i-cont = i-cont + 1.

       run pi-acompanhar in h-acomp (input "Validando: " + string(tt-item.it-codigo) + " - " + string(i-cont)).

       /*FIND FIRST item-uf WHERE 
                  item-uf.it-codigo = tt-item.it-codigo NO-LOCK NO-ERROR.
       IF NOT AVAIL item-uf THEN DO:
          CREATE tt-erro.
          ASSIGN tt-erro.it-codigo = tt-item.it-codigo
                 tt-erro.descricao = "Item n∆o cadastrado na ITEM-UF (CD0904A)".
       END.*/

       FIND FIRST int-ds-ncm-produto WHERE
                  int-ds-ncm-produto.produto = INT(tt-item.it-codigo) NO-LOCK NO-ERROR.
       IF NOT AVAIL int-ds-ncm-produto THEN DO:
          CREATE tt-erro.
          ASSIGN tt-erro.it-codigo = tt-item.it-codigo
                 tt-erro.descricao = "Item n∆o cadastrado na Tabela de Integraá∆o (INT-DS-NCM-PRODUTO)".
       END.
    END.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Validaá∆o Item UF (CD0904A)"
       c-programa     = "NI-IMP-ITEM-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro BY tt-erro.it-codigo:
    disp tt-erro with width 300 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}





