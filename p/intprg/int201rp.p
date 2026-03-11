/********************************************************************************
** Programa: INT201 - Envio pre‡os de Itens p/ Procfit:
**
** Versao : 12 - 24/02/2018 - Alessandro V Baccin
**
********************************************************************************/

/* include de controle de versao */
{include/i-prgvrs.i INT201RP 2.12.03.AVB}
{cdp/cdcfgdis.i}

/* definiçao das temp-tables para recebimento de parametros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field it-codigo-ini    as char
    field it-codigo-fim    as char.

def temp-table tt-raw-digita
        field raw-digita	as raw.


/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
if tt-param.arquivo = "" then 
assign tt-param.arquivo = "INT201.txt"
       tt-param.destino = 3
       tt-param.data-exec = TODAY
       tt-param.hora-exec = TIME.

/* include padrao para variáveis de relatório  */
{include/i-rpvar.i}


/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
def buffer b-item-uni-estab for item-uni-estab.

def var h-acomp         as handle no-undo.
def var i-it-codigo     as integer no-undo.
def var i-ind           as integer no-undo.

form with frame f-rel width 550 stream-io down.

/* include com a definiçao da frame de cabeçalho e rodapé */
{include/i-rpcab.i}

/* bloco principal do programa */

find first tt-param no-lock no-error.
assign c-programa       = "INT201RP"
       c-versao         = "2.12"
       c-revisao        = ".03.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Envio Pre‡os Transferˆncia->Procfit".

/* ----- inicio do programa ----- */
for first param-global no-lock query-tuning(no-lookahead): end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock
    query-tuning(no-lookahead): end.
assign c-empresa = mgadm.empresa.razao-social.

if tt-param.arquivo <> "" then do:
    {include/i-rpout.i}
    view frame f-cabec.
    view frame f-rodape.
end.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Processando").

for each item fields (it-codigo) no-lock where 
    item.cod-obsoleto < 2 and 
    item.ind-item-fat and
    item.it-codigo >= tt-param.it-codigo-ini and
    item.it-codigo <= tt-param.it-codigo-fim
    query-tuning(no-lookahead):
    assign i-it-codigo = ?.
    assign i-it-codigo = int64(item.it-codigo) no-error.
    if i-it-codigo <> ? then do:

        for each estabelec fields (cod-estabel cgc) no-lock,
            each cst-estabelec fields (cod-estabel) no-lock of estabelec 
            where cst-estabelec.dt-fim-operacao >= today
            query-tuning(no-lookahead):

            for each item-uni-estab fields (it-codigo  cod-estabel
                                            preco-base preco-ul-ent 
                                            data-base  data-ult-ent)
                no-lock where 
                item-uni-estab.it-codigo    = item.it-codigo and
                item-uni-estab.cod-estabel  = estabelec.cod-estabel
                query-tuning(no-lookahead):

                i-ind = i-ind + 1.
                if i-ind mod 200 = 0 then
                    RUN pi-acompanhar in h-acomp (input "Item: " + item.it-codigo +
                                                        " Est: " + estabelec.cod-estabel).
                
                find int-dp-preco-item exclusive-lock where 
                    int-dp-preco-item.pri-cnpj-origem-s = estabelec.cgc and
                    int-dp-preco-item.pri-produto-n = i-it-codigo no-error.

                if not avail int-dp-preco-item then do:
                    create  int-dp-preco-item.
                    assign  int-dp-preco-item.pri-cnpj-origem-s = estabelec.cgc
                            int-dp-preco-item.pri-produto-n     = i-it-codigo
                            int-dp-preco-item.ID_SEQUENCIAL     = ?.
                end.
                assign  int-dp-preco-item.pri-cod-estabel-s  = estabelec.cod-estabel.
                if  int-dp-preco-item.pri-precobase-n    <> item-uni-estab.preco-base   or
                    int-dp-preco-item.pri-precoentrada-n <> item-uni-estab.preco-ul-ent or
                    int-dp-preco-item.pri-database-d     <> item-uni-estab.data-base    or
                    int-dp-preco-item.pri-dataentrada-d  <> item-uni-estab.data-ult-ent or
                    item-uni-estab.preco-base   = 0 or
                    item-uni-estab.preco-ul-ent = 0 
                then do:

                    assign  int-dp-preco-item.pri-precobase-n    = item-uni-estab.preco-base
                            int-dp-preco-item.pri-precoentrada-n = item-uni-estab.preco-ul-ent
                            int-dp-preco-item.pri-database-d     = item-uni-estab.data-base
                            int-dp-preco-item.pri-dataentrada-d  = item-uni-estab.data-ult-ent.
    
                    if  int-dp-preco-item.pri-precobase-n    = 0 or
                        int-dp-preco-item.pri-precoentrada-n = 0 then do:
                        for each b-item-uni-estab 
                            fields (preco-base data-base
                                    preco-ul-ent data-ult-ent)
                            no-lock where 
                            b-item-uni-estab.it-codigo   = item.it-codigo and
                            b-item-uni-estab.cod-estabel = "973"
                            query-tuning(no-lookahead):
    
                            if int-dp-preco-item.pri-precobase-n = 0 then
                                assign  int-dp-preco-item.pri-precobase-n = b-item-uni-estab.preco-base
                                        int-dp-preco-item.pri-database-d  = b-item-uni-estab.data-base.
    
                            if int-dp-preco-item.pri-precoentrada-n = 0 then
                                assign  int-dp-preco-item.pri-precoentrada-n = b-item-uni-estab.preco-ul-ent
                                        int-dp-preco-item.pri-dataentrada-d  = b-item-uni-estab.data-ult-ent.
                        end.
    
                    end.
    
                    for each item-estab fields (val-unit-mat-m[1] mensal-ate) no-lock where 
                        item-estab.cod-estabel = item-uni-estab.cod-estabel and
                        item-estab.it-codigo   = item-uni-estab.it-codigo
                        query-tuning(no-lookahead):
                        assign  int-dp-preco-item.pri-precomedio-n = item-estab.val-unit-mat-m[1]
                                int-dp-preco-item.pri-datamedio-d  = item-estab.mensal-ate.
                    end.
                    if int-dp-preco-item.pri-precomedio-n = 0 then do:
                        for each item-estab fields (val-unit-mat-m[1] mensal-ate) no-lock where 
                            item-estab.cod-estabel = "973" and
                            item-estab.it-codigo   = item-uni-estab.it-codigo
                            query-tuning(no-lookahead):
                            assign  int-dp-preco-item.pri-precomedio-n = item-estab.val-unit-mat-m[1]
                                    int-dp-preco-item.pri-datamedio-d  = item-estab.mensal-ate.
                        end.
                    end.
                    assign  int-dp-preco-item.tipo-movto    = 1                       
                            int-dp-preco-item.dt-geracao    = today                   
                            int-dp-preco-item.hr-geracao    = string(time,"HH:MM:SS")
                            int-dp-preco-item.ENVIO_STATUS  = 1.

                    /*
                    display int-dp-preco-item.pri-cod-estabel-s
                            int-dp-preco-item.pri-produto-n
                            int-dp-preco-item.pri-precomedio-n
                            int-dp-preco-item.dt-geracao
                            int-dp-preco-item.hr-geracao
                        with frame f-rel.
                    down with frame f-rel.
                    */

                    release int-dp-preco-item.
                
                end.
            end.
        end.
    end.
end.

run pi-finalizar in h-acomp.

if tt-param.arquivo <> "" then do:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i }
end.
/* elimina BO's */
return "OK".

