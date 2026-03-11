/********************************************************************************
** Programa: INT049 - lista pedido X nota-fiscal
**
** Versao : 12 - 14/09
**
********************************************************************************/

{include/i-prgvrs.i INT049RP 2.06.00.001}  
{include/i_fnctrad.i}

{include/i-rpvar.i}
{include/i-rpcab.i}

/* {utp/ut-glob.i} */ 
def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{method/dbotterr.i} 
/*{cdp/cd0666.i}       Definicao da temp-table de erros */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    FIELD nr-pedido        AS CHAR FORMAT "x(20)".

DEF TEMP-TABLE tt-nota no-undo
    FIELD situacao              AS CHAR FORMAT "x(20)"
    FIELD nr-nota-fis           LIKE  nota-fiscal.nr-nota-fis        
    FIELD serie                 LIKE  nota-fiscal.serie             
    FIELD cod-estabel           LIKE  nota-fiscal.cod-estabel       
    FIELD cod-emitente          LIKE  emitente.cod-emitente         
    FIELD nome-abrev            LIKE  emitente.nome-abrev      
    FIELD dt-emis-nota          LIKE  nota-fiscal.dt-emis-nota  
    FIELD nr-pedcli             LIKE  nota-fiscal.nr-pedcli  
    FIELD estado                LIKE  emitente.estado  
    FIELD ped-codigo-n          LIKE  int-ds-pedido.ped-codigo-n
    FIELD dt-geracao            LIKE  int-ds-pedido.dt-geracao   
    FIELD hr-geracao            LIKE  int-ds-pedido.hr-geracao
    FIELD ped-cnpj-destino-s    LIKE  int-ds-pedido.ped-cnpj-destino-s
    FIELD ped-cnpj-origem-s     LIKE  int-ds-pedido.ped-cnpj-origem-s 
    FIELD ped-tipopedido-n      AS CHAR FORMAT "x(60)"
    FIELD desc-tipo-ped         AS CHAR.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.



def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.


def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEF VAR c-sit          AS CHAR NO-UNDO.
DEF VAR c-tipo         AS CHAR NO-UNDO.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first mgcad.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "INT049"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Listagem * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Listagem * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.
                         
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Inicializando..").

 run pi-elimina-tabelas.
 RUN pi-importa.

RUN pi-finalizar IN h-acomp.                       

{include/i-rpclo.i}   

return "OK":U.

procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   empty temp-table tt-nota.
end.        

procedure pi-importa:
    run pi-acompanhar in h-acomp (input "Lendo Pedidos").

    FOR EACH int-ds-pedido   NO-LOCK                   
       WHERE int-ds-pedido.ped-codigo-n = int(tt-param.nr-pedido):

          ASSIGN c-sit = "".
          IF int-ds-pedido.situacao <> 2 THEN
              ASSIGN c-sit = STRING(int-ds-pedido.situacao) + " - " + "Pendente".
          ELSE 
              ASSIGN c-sit = STRING(int-ds-pedido.situacao) + " - " + "Processado".

           ASSIGN c-tipo = "".
           CASE int-ds-pedido.ped-tipopedido-n:
               WHEN 1 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "TRANSFERENCIA DEPOSITO - FILIAL".
               WHEN 2 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "TRANSFERENCIA FILIAL - DEPOSITO".
               WHEN 3 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "BALANCO MANUAL FILIAL".
               WHEN 4 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "COMPRA FORNECEDOR - FILIAL".
               WHEN 5 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "COMPRA FORNECEDOR - DEPOSITO".
               WHEN 6 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "TRANSFERENCIA DEPOSITO - DEPOSITO".
               WHEN 7 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "ELETRONICO FORNECEDOR - FILIAL".
               WHEN 8 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "ELETRONICO DEPOSITO - FILIAL".
               WHEN 9 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "PBM FILIAL".
               WHEN 10 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "PBM DEPOSITO".
               WHEN 11 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "BALANCO MANUAL DEPOSITO".
               WHEN 12 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "BALANCO COLETOR FILIAL".
               WHEN 13 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "BALANCO COLETOR DEPOSITO".
               WHEN 14 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO".
               WHEN 15 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "DEVOLUCAO FILIAL - FORNECEDOR".                  
               WHEN 16 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "DEVOLUCAO DEPOSITO - FORNECEDOR".
               WHEN 17 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "TRANSFERENCIA DEPOSITO - DEPOSITO (COMERCIALIZAVEL)".
               WHEN 18 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "TRANSFERENCIA DEPOSITO - DEPOSITO (AVARIA)".
               WHEN 19 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "TRANSFERENCIA FILIAL - FILIAL".
               WHEN 31 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO)".                  
               WHEN 32 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "DEVOLUCAO FILIAL - FORNECEDOR (MED. CONTROLADO)".
               WHEN 33 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "TRANSFERENCIA FILIAL - FORNECEDOR (MED. CONTROLADO)".
               WHEN 35 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "BALAN€O GERAL CONTROLADOS FILIAL".
               WHEN 36 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "BALAN€O GERAL CONTROLADOS FILIAL".                  
               WHEN 37 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "ATIVO IMOBILIZADO DEPOSITO => FILIAL".
               WHEN 38 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "ESTORNO".
               WHEN 39 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "ATIVO IMOBILIZADO FILIAL => FILIAL".
               WHEN 46 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "RETIRADA FILIAL => PROPRIA FILIAL".
               WHEN 48 THEN ASSIGN c-tipo = string(int-ds-pedido.ped-tipopedido-n) + " - " + "SUBSTITUI€ÇO DE CUPOM".                  
          END CASE.

        FIND FIRST emitente NO-LOCK
             WHERE emitente.cgc = int-ds-pedido.ped-cnpj-destino-s NO-ERROR.

        IF AVAIL emitente THEN DO:
           FOR EACH nota-fiscal NO-LOCK
                 WHERE nota-fiscal.nr-pedcli = string(int-ds-pedido.ped-codigo-n)
                   AND nota-fiscal.cod-emitente = emitente.cod-emitente 
                   and nota-fiscal.idi-sit-nf-eletro <> 6
                   and nota-fiscal.idi-sit-nf-eletro <> 7:

                 CREATE tt-nota.
                 ASSIGN tt-nota.situacao            = c-sit
                        tt-nota.ped-tipopedido-n    = c-tipo
                        tt-nota.ped-codigo-n        = int-ds-pedido.ped-codigo-n       
                        tt-nota.dt-geracao          = int-ds-pedido.dt-geracao         
                        tt-nota.hr-geracao          = int-ds-pedido.hr-geracao         
                        tt-nota.ped-cnpj-destino-s  = int-ds-pedido.ped-cnpj-destino-s 
                        tt-nota.ped-cnpj-origem-s   = int-ds-pedido.ped-cnpj-origem-s
                        tt-nota.estado              = emitente.estado  
                        tt-nota.cod-emitente        = emitente.cod-emitente            
                        tt-nota.nome-abrev          = emitente.nome-abrev
                        tt-nota.nr-nota-fis         = nota-fiscal.nr-nota-fis          
                        tt-nota.serie               = nota-fiscal.serie                
                        tt-nota.cod-estabel         = nota-fiscal.cod-estabel
                        tt-nota.dt-emis-nota        = nota-fiscal.dt-emis-nota         
                        tt-nota.nr-pedcli           = nota-fiscal.nr-pedcli.  
           END.
        END.
    END. 

    FOR EACH int-ds-pedido-subs   NO-LOCK                   
       WHERE int-ds-pedido-subs.ped-codigo-n = int(tt-param.nr-pedido):

          ASSIGN c-sit = "".
          IF int-ds-pedido-subs.situacao <> 2 THEN
              ASSIGN c-sit = STRING(int-ds-pedido-subs.situacao) + " - " + "Pendente".
          ELSE 
              ASSIGN c-sit = STRING(int-ds-pedido-subs.situacao) + " - " + "Processado".

           ASSIGN c-tipo = "".
           CASE int-ds-pedido-subs.ped-tipopedido-n:
               WHEN 1 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "TRANSFERENCIA DEPOSITO - FILIAL".
               WHEN 2 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "TRANSFERENCIA FILIAL - DEPOSITO".
               WHEN 3 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "BALANCO MANUAL FILIAL".
               WHEN 4 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "COMPRA FORNECEDOR - FILIAL".
               WHEN 5 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "COMPRA FORNECEDOR - DEPOSITO".
               WHEN 6 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "TRANSFERENCIA DEPOSITO - DEPOSITO".
               WHEN 7 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "ELETRONICO FORNECEDOR - FILIAL".
               WHEN 8 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "ELETRONICO DEPOSITO - FILIAL".
               WHEN 9 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "PBM FILIAL".
               WHEN 10 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "PBM DEPOSITO".
               WHEN 11 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "BALANCO MANUAL DEPOSITO".
               WHEN 12 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "BALANCO COLETOR FILIAL".
               WHEN 13 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "BALANCO COLETOR DEPOSITO".
               WHEN 14 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO".
               WHEN 15 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "DEVOLUCAO FILIAL - FORNECEDOR".                  
               WHEN 16 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "DEVOLUCAO DEPOSITO - FORNECEDOR".
               WHEN 17 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "TRANSFERENCIA DEPOSITO - DEPOSITO (COMERCIALIZAVEL)".
               WHEN 18 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "TRANSFERENCIA DEPOSITO - DEPOSITO (AVARIA)".
               WHEN 19 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "TRANSFERENCIA FILIAL - FILIAL".
               WHEN 31 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO)".                  
               WHEN 32 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "DEVOLUCAO FILIAL - FORNECEDOR (MED. CONTROLADO)".
               WHEN 33 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "TRANSFERENCIA FILIAL - FORNECEDOR (MED. CONTROLADO)".
               WHEN 35 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "BALAN€O GERAL CONTROLADOS FILIAL".
               WHEN 36 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "BALAN€O GERAL CONTROLADOS FILIAL".                  
               WHEN 37 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "ATIVO IMOBILIZADO DEPOSITO => FILIAL".
               WHEN 38 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "ESTORNO".
               WHEN 39 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "ATIVO IMOBILIZADO FILIAL => FILIAL".
               WHEN 46 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "RETIRADA FILIAL => PROPRIA FILIAL".
               WHEN 48 THEN ASSIGN c-tipo = string(int-ds-pedido-subs.ped-tipopedido-n) + " - " + "SUBSTITUI€ÇO DE CUPOM".                  
          END CASE.

        FIND FIRST emitente NO-LOCK
             WHERE emitente.cgc = int-ds-pedido-subs.ped-cnpj-destino-s NO-ERROR.

        IF AVAIL emitente THEN DO:
           FOR EACH nota-fiscal NO-LOCK
                 WHERE nota-fiscal.nr-pedcli = string(int-ds-pedido-subs.ped-codigo-n)
                   AND nota-fiscal.cod-emitente = emitente.cod-emitente:
                 CREATE tt-nota.
                 ASSIGN tt-nota.situacao            = c-sit
                        tt-nota.ped-tipopedido-n    = c-tipo
                        tt-nota.ped-codigo-n        = int-ds-pedido-subs.ped-codigo-n       
                        tt-nota.dt-geracao          = int-ds-pedido-subs.dt-geracao         
                        tt-nota.hr-geracao          = int-ds-pedido-subs.hr-geracao         
                        tt-nota.ped-cnpj-destino-s  = int-ds-pedido-subs.ped-cnpj-destino-s 
                        tt-nota.ped-cnpj-origem-s   = int-ds-pedido-subs.ped-cnpj-origem-s
                        tt-nota.estado              = emitente.estado  
                        tt-nota.cod-emitente        = emitente.cod-emitente            
                        tt-nota.nome-abrev          = emitente.nome-abrev
                        tt-nota.nr-nota-fis         = nota-fiscal.nr-nota-fis          
                        tt-nota.serie               = nota-fiscal.serie                
                        tt-nota.cod-estabel         = nota-fiscal.cod-estabel
                        tt-nota.dt-emis-nota        = nota-fiscal.dt-emis-nota         
                        tt-nota.nr-pedcli           = nota-fiscal.nr-pedcli.  
           END.
        END.
    END. 

    FIND FIRST tt-nota NO-ERROR.

      IF AVAIL tt-nota THEN
          RUN gera-log.

    RUN pi-elimina-tabelas.
end.


procedure gera-log.

   run pi-acompanhar in h-acomp (input "Listando...").

    FOR EACH tt-nota:
        DISP  tt-nota.situacao            
             tt-nota.estado              
             tt-nota.cod-emitente        
             tt-nota.nome-abrev          
             tt-nota.ped-codigo-n        
             tt-nota.dt-geracao          
             tt-nota.hr-geracao          
             tt-nota.ped-cnpj-destino-s  
             tt-nota.ped-cnpj-origem-s     
             tt-nota.nr-nota-fis   
             tt-nota.serie         
             tt-nota.cod-estabel   
             tt-nota.dt-emis-nota  
             tt-nota.nr-pedcli  
             tt-nota.ped-tipopedido-n
             WITH WIDTH 555 STREAM-IO DOWN FRAME f-titulo.
                                 DOWN WITH FRAME f-titulo.  

    END.
end.

/* FIM DO PROGRAMA */







