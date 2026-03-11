/********************************************************************************
**
**  Programa - NI-IMP-PEDIDO-BALANCO.P - Importa‡Æo Pedidos de Balan‡o
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-PEDIDO-BALANCO 2.00.00.000 } 

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

DEF TEMP-TABLE tt-pedido
    FIELD it-codigo   AS CHAR   
    FIELD de-contagem AS DEC
    FIELD de-saldo    AS DEC.
                                             
DEF VAR i-cont      AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp     AS HANDLE                   NO-UNDO.
DEF VAR l-erro      AS LOGICAL                  NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo Pedido Balan‡o").

EMPTY TEMP-TABLE tt-pedido.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  

   CREATE tt-pedido.
   IMPORT DELIMITER ";" tt-pedido.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-pedido: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0
       l-erro = NO.
                                                                                               
for each tt-pedido:

    assign i-cont = i-cont + 1.

    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-pedido.it-codigo) + " - " + string(i-cont)).

end.

FOR FIRST int-ds-pedido WHERE
          int-ds-pedido.ped-codigo-n = 500000 NO-LOCK:
END.
IF AVAIL int-ds-pedido THEN DO:
   ASSIGN l-erro = YES.
   run pi-finalizar in h-acomp.
   MESSAGE "Pedido nr. 500000 j  cadastrado"
       VIEW-AS ALERT-BOX INFO BUTTONS OK.
END.
ELSE DO:
   CREATE int-ds-pedido.
   ASSIGN int-ds-pedido.ped-codigo-n       = 500000
          int-ds-pedido.ped-tipopedido-n   = 35       
          int-ds-pedido.dt-geracao         = 12/01/2017
          int-ds-pedido.situacao           = 1
          int-ds-pedido.ped-cnpj-origem-s  = "79430682025540"
          int-ds-pedido.ped-cnpj-destino-s = "79430682025540"
          int-ds-pedido.ped-dataentrega-d  = 12/01/2017
          l-erro                           = NO.

   FOR EACH tt-pedido WHERE 
            tt-pedido.it-codigo <> "":

       run pi-acompanhar in h-acomp (input "Criando Itens Pedido: " + string(tt-pedido.it-codigo) + " - " + string(i-cont)).

       CREATE int-ds-pedido-produto.
       ASSIGN int-ds-pedido-produto.ped-codigo-n     = 500000
              int-ds-pedido-produto.ppr-produto-n    = INT(tt-pedido.it-codigo)
              int-ds-pedido-produto.ppr-quantidade-n = de-contagem.

       CREATE int-ds-pedido-retorno.
       ASSIGN int-ds-pedido-retorno.ped-codigo-n         = 500000
              int-ds-pedido-retorno.ppr-produto-n        = INT(tt-pedido.it-codigo)
              int-ds-pedido-retorno.rpp-quantidade-n     = tt-pedido.de-contagem
              int-ds-pedido-retorno.rpp-qtd-inventario-n = tt-pedido.de-saldo
              int-ds-pedido-retorno.rpp-caixa-n          = 0
              int-ds-pedido-retorno.rpp-lote-s           = ""
              int-ds-pedido-retorno.rpp-validade-d       = ?.
   END.
   run pi-finalizar in h-acomp.
END.

IF l-erro = NO THEN
   MESSAGE "Pedido de Balan‡o nr. 500000 criado com sucesso"
           VIEW-AS ALERT-BOX INFO BUTTONS OK.



