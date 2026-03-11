/********************************************************************************
**
**  Programa - NI-IMP-MENSAGEM-RP.P - Importa‡Æo Mensagens
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-MENSAGEM 2.00.00.000 } 

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

DEF TEMP-TABLE tt-msg
    FIELD origem        AS CHAR    
    FIELD mensagem      AS CHAR.
                                             
DEF VAR i-cont      AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp     AS HANDLE                   NO-UNDO.
DEF VAR l-erro      AS LOGICAL                  NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo EAN Item").

EMPTY TEMP-TABLE tt-msg.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-msg.
   IMPORT DELIMITER ";" tt-msg.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-msg: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-msg WHERE
         tt-msg.origem <> "":

    assign i-cont = i-cont + 1
           l-erro = NO.

    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-msg.origem) + " - " + string(i-cont)).

    CREATE int-ds-msg-usuario.
    ASSIGN int-ds-msg-usuario.origem      = tt-msg.origem
           int-ds-msg-usuario.cod-usuario = "*"
           int-ds-msg-usuario.mensagem    = tt-msg.mensagem.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo Mensagens"
       c-programa     = "NI-IMP-MENSAGEM".

{include/i-rpcab.i}

view frame f-cabec.

view frame f-rodape.    

{include/i-rpclo.i}





