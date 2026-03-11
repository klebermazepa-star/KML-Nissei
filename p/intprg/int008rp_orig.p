/******************************************************************************
**
**       PROGRAMA: int008rp.p
**
**       DATA....: 08/2016
**
**       OBJETIVO: Integra‡Æo Pedido de compra (Emergencial)
**                 
**       VERSAO..: 2.06.001
** 
******************************************************************************/
{include/i-prgvrs.i int008rp 2.12.00.001} 

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i int008rp INT}
&ENDIF
 
{include/i_fnctrad.i}
{utp/ut-glob.i}

DEFINE temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as CHAR format "x(35)":U
    field usuario          as CHAR format "x(12)":U
    field data-exec        as DATE
    field hora-exec        as INTEGER
    FIELD dt-periodo-ini   AS DATE FORMAT "99/99/9999"
    FIELD dt-periodo-fim   AS DATE FORMAT "99/99/9999"
    FIELD cod-estabel-ini  AS INT 
    FIELD cod-estabel-fim  AS INT
    FIELD nr-pedido-ini    AS INTEGER
    FIELD nr-pedido-fim    AS INTEGER.

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9":U
    field exemplo          as character format "x(30)":U
    index id ordem.

DEFINE TEMP-TABLE ttcotacao-item NO-UNDO LIKE cotacao-item
       field r-rowid as rowid.

def temp-table tt-raw-digita NO-UNDO
        field raw-digita as raw.

DEF TEMP-TABLE tt-aux
    FIELD r-item-fornec-umd AS ROWID.

DEF BUFFER b-tt-digita           FOR tt-digita.
DEF buffer b-int-ds-ped-compra   for int-ds-ped-compra. 
def buffer b-int-ds-ordem-compra for int-ds-ordem-compra.
DEF BUFFER b-int-ds-ped-compr    FOR int-ds-ped-compr.
DEF BUFFER b-item                FOR ITEM.

&GLOBAL-DEFINE hDBOTable         h-boin295

{METHOD/dbotterr.i}
{inbo/boin295.i ttpedido-compr}

DEF TEMP-TABLE tt-cotacao-item-bo LIKE cotacao-item
FIELD r-rowid AS ROWID.

DEF TEMP-TABLE tt-ordem-compra-bo LIKE ordem-compra
FIELD r-rowid AS ROWID.


DEF TEMP-TABLE tt-prazo-compra-bo LIKE prazo-compra
FIELD r-rowid AS ROWID.


{cdp/cdcfgmat.i}
{ccp/ccapi202.i}
{cdp/cdapi300.i1}
{ccp/ccapi207.i}
{cdp/cd4300.i3} 
{cdp/cd0666.i}
 
def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param no-error.

{include/i-rpvar.i}
 
DEFINE VARIABLE {&hDBOTable}  AS HANDLE NO-UNDO.
DEFINE VARIABLE h-boin274     AS HANDLE NO-UNDO.
DEFINE VARIABLE h-boin356     AS HANDLE NO-UNDO.
DEFINE VARIABLE h-boin082vl   AS HANDLE NO-UNDO.
DEFINE VARIABLE h-boin274sd    AS HANDLE NO-UNDO.
DEFINE VARIABLE h-boin356ca    AS HANDLE NO-UNDO.
DEFINE VARIABLE h-boin082sd    AS HANDLE NO-UNDO.
DEFINE VARIABLE h-boin274vl    AS HANDLE NO-UNDO.


def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.
DEF NEW GLOBAL SHARED VAR i-ep-codigo-usuario  LIKE mgcad.empresa.ep-codigo NO-UNDO.
DEF VAR h-acomp    AS HANDLE  NO-UNDO.

def var l-item                  as logical no-undo.
def var i-num-pedido            like pedido-compr.num-pedido no-undo.
def var c-formato-cgc           as char no-undo.
def var l-modulo-ge             as log  no-undo.
def var l-nr-processo-sensitive as log  no-undo.
def var l-responsavel-sensitive as log  no-undo.
def var c-end-cobranca-aux      like pedido-compr.end-cobranca no-undo.
def var c-end-entrega-aux       like pedido-compr.end-entrega  no-undo.
def var i-cod-mensagem          like pedido-compr.cod-mensagem no-undo.
def var i-cond-pagto            as int  no-undo.
DEF VAR fi-cod-estab            LIKE estabelec.cod-estabel       NO-UNDO.
DEF VAR fi-requisitante         LIKE pedido-compr.responsavel    NO-UNDO.    
DEF VAR fi-mo-codigo            LIKE moeda.mo-codigo             NO-UNDO.
DEF VAR fi-cod-comprado         LIKE item-uni-estab.cod-comprado NO-UNDO.
DEF VAR fi-tp-despesa           LIKE ordem-compra.tp-despesa     NO-UNDO. 
DEF VAR c-contato               LIKE cont-emit.nome              NO-UNDO.  
DEF VAR i-num-ordem             LIKE ordem-compra.numero-ordem   NO-UNDO.
DEF VAR c-cod-comprado          like ordem-compra.cod-comprado   NO-UNDO.
def var c-un                    like item.un                     no-undo. 
def var i-cod-emitente          like emitente.cod-emitente       no-undo.
def var c-cgc                   as   char                        no-undo.
def var de-preco-fornec         like int-ds-ordem-compra.preco-fornec   no-undo.
def var de-preco-unit           like int-ds-ordem-compra.preco-unitario no-undo.
DEF VAR r-cotacao-item          AS   ROWID                              NO-UNDO.
DEF VAR l-inclui-item-fornec    AS   LOGICAL                            NO-UNDO.
DEF VAR i-num-ordem-aux         LIKE ordem-compra.numero-ordem          NO-UNDO.
DEF VAR r-item-fornec-umd       AS ROWID                                NO-UNDO.

DEF VAR c-discard               AS CHAR                          NO-UNDO. 
DEF VAR i-discard               AS INTEGER                       NO-UNDO.
DEF VAR l-discard               AS LOGICAL                       NO-UNDO.

run utp/ut-acomp.p persistent set h-acomp.

IF VALID-HANDLE(h-acomp) THEN
   run pi-inicializar in h-acomp (input "INT008 - Integra‡Æo Pedidos").

FIND FIRST param-global NO-ERROR.

FIND FIRST mgcad.empresa NO-LOCK WHERE
           empresa.ep-codigo = param-global.empresa-prin NO-ERROR.

if avail empresa then 
       assign c-empresa   = string(empresa.ep-codigo). 

{utp/ut-liter.i INTEGRA€ÇO_PEDIDO_COMPRA * r }
assign c-sistema  = return-value.

RUN inbo/boin274.p   PERSISTENT SET h-boin274.
RUN inbo/boin295.p   PERSISTENT SET h-boin295.
RUN inbo/boin356.p   PERSISTENT SET h-boin356.
RUN inbo/boin082vl.p PERSISTENT SET h-boin082vl.
RUN inbo/boin274sd.p PERSISTENT SET h-boin274sd.
RUN inbo/boin356ca.p PERSISTENT SET h-boin356ca.
RUN inbo/boin082sd.p PERSISTENT SET h-boin082sd. 
RUN inbo/boin274vl.p PERSISTENT SET h-boin274vl.

FIND FIRST tt-param NO-ERROR.

IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "INT008rp.txt"
           tt-param.destino = 2
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME
           tt-param.dt-periodo-ini  = 10/01/2016 
           tt-param.dt-periodo-fim  = TODAY 
           tt-param.cod-estabel-ini = 0  
           tt-param.cod-estabel-fim = 999 
           tt-param.nr-pedido-ini   = 0 
           tt-param.nr-pedido-fim   = 999999999.  
                    
{include/i-rpout.i}
           
PUT "Pedidos Integrados" SKIP (1).

PUT "Pedido Totvs  Pedido Sysfarma" SKIP.
PUT "------------  ---------------" SKIP.

/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\log-int008rp.txt".
log-manager:log-entry-types= "4gltrace".
*/

EMPTY TEMP-TABLE tt-aux.

for EACH int-ds-ped-compra WHERE  
         int-ds-ped-compra.cod-estabel     >= tt-param.cod-estabel-ini  AND 
         int-ds-ped-compra.cod-estabel     <= tt-param.cod-estabel-fim  AND
         int-ds-ped-compra.data-pedido     >= tt-param.dt-periodo-ini   AND 
         int-ds-ped-compra.data-pedido     <= tt-param.dt-periodo-fim   AND
         int-ds-ped-compra.num-pedido-orig >= tt-param.nr-pedido-ini    AND  
         int-ds-ped-compra.num-pedido-orig <= tt-param.nr-pedido-fim    AND
         int-ds-ped-compra.num-pedido-orig  <> ?                        and    
         int-ds-ped-compra.situacao         = 1:   /* Pendente */

    IF int-ds-ped-compra.cod-estabel = 973 THEN
       ASSIGN int-ds-ped-compra.situacao = 9. 
    ELSE
       ASSIGN int-ds-ped-compra.situacao = 2. 
              
END.
     
for EACH int-ds-ped-compra no-lock WHERE  
         int-ds-ped-compra.cod-estabel     >= tt-param.cod-estabel-ini  AND 
         int-ds-ped-compra.cod-estabel     <= tt-param.cod-estabel-fim  AND
         int-ds-ped-compra.data-pedido     >= tt-param.dt-periodo-ini   AND 
         int-ds-ped-compra.data-pedido     <= tt-param.dt-periodo-fim   AND
         int-ds-ped-compra.num-pedido-orig >= tt-param.nr-pedido-ini    AND  
         int-ds-ped-compra.num-pedido-orig <= tt-param.nr-pedido-fim    AND
         int-ds-ped-compra.num-pedido-orig  <> ? and    
         int-ds-ped-compra.situacao         = 9:   
                           
    FOR FIRST pedido-compr NO-LOCK WHERE
              pedido-compr.num-pedido = int-ds-ped-compra.num-pedido-orig:

    END.

    IF AVAIL pedido-compr THEN DO:
       DO TRANS: 
           FOR EACH b-int-ds-ped-compra where
                    b-int-ds-ped-compra.num-pedido-orig = int-ds-ped-compra.num-pedido-orig AND
                   (b-int-ds-ped-compra.situacao        = 9 OR b-int-ds-ped-compra.situacao = 1):         
               ASSIGN b-int-ds-ped-compra.situacao = 2.
           END.
       END.
       NEXT. /* Desconsidera pedidos j  cadastrados */
    END.

    IF VALID-HANDLE(h-acomp) THEN
       RUN pi-acompanhar IN h-acomp(INPUT "Pedido Sysfarma :" + STRING(int-ds-ped-compra.num-pedido-orig)).
    
    empty temp-table ttpedido-compr.
    empty temp-table tt-versao-integr.      
    empty temp-table tt-erro.         
            
    assign c-cgc = string(int-ds-ped-compra.cnpj-cpf) no-error.

    FOR first emitente no-lock where
              emitente.cgc = c-cgc and
              emitente.identific <> 1 :
    END.
    
    IF NOT AVAIL emitente 
    THEN DO:

        assign c-cgc = "*" + string(int-ds-ped-compra.cnpj-cpf) + "*" no-error.

        FOR first emitente no-lock where
                  emitente.cgc matches c-cgc and
                  emitente.identific <> 1 :
        END.

    END.

    if avail emitente then                     
       assign i-cod-emitente = emitente.cod-emitente.   
    else 
       assign i-cod-emitente = 0.          
    
    IF int-ds-ped-compra.cod-cond-pag < 200 THEN DO:
       create tt-erro.
       assign tt-erro.cd-erro  = 51
              tt-erro.mensagem = "Condi‡Æo de Pagamento " + STRING(int-ds-ped-compra.cod-cond-pag) + " inv lida para gera‡Æo de Pedido de Compra no Datasul.". 
    END.

    assign l-item = no.
       
    for each int-ds-ordem-compra no-lock where
             int-ds-ordem-compra.num-pedido-orig = int-ds-ped-compra.num-pedido-orig,
        first item no-lock where
              item.it-codigo = string(int-ds-ordem-compra.it-codigo) :  
      
        assign l-item = yes.

        IF item.cod-obsoleto > 1 
        THEN DO:
            create tt-erro.
            assign tt-erro.cd-erro  = 49
                   tt-erro.mensagem = "Item :" + STRING(item.it-codigo) + " est  obsoleto.". 
    
        END.
         
        for first item-uni-estab fields(cod-estabel it-codigo cod-obsoleto) where 
                  item-uni-estab.cod-estabel = string(int-ds-ped-compra.cod-estabel,"999") and 
                  item-uni-estab.it-codigo   = item.it-codigo: 
        end.
    
        if avail item-uni-estab and
                 item-uni-estab.cod-obsoleto > 1 
        THEN DO:
              create tt-erro.
              assign tt-erro.cd-erro  = 50
                     tt-erro.mensagem = "Item :" + STRING(item.it-codigo) + " est  obsoleto para o estabelecimento " + STRING(item-uni-estab.cod-estabel). 
        END.  

    end.

    if l-item = no 
    then do:
       create tt-erro.
       assign tt-erro.cd-erro  = 48
              tt-erro.mensagem = "Pedido " + STRING(int-ds-ped-compra.num-pedido-orig) + " nÆo possui itens.".  
    end. 
        
    FIND FIRST emitente NO-LOCK WHERE
               emitente.cod-emitente = i-cod-emitente AND  
               emitente.cod-emitente > 0 NO-ERROR.
    IF NOT AVAIL emitente 
    THEN DO:
       create tt-erro.
       assign tt-erro.cd-erro  = 47
              tt-erro.mensagem = "Fornecedor " + STRING(i-cod-emitente) + " nÆo cadastrado. CNPJ: " + string(int-ds-ped-compra.cnpj-cpf).     
    end.
    
    if not can-find(first tt-erro)
    then do: 
             
        CREATE ttpedido-compr.
        
        /* RUN geraNumeroPedidoCompra IN {&hDBOTable} (output i-num-pedido). */

        ASSIGN i-num-pedido = int-ds-ped-compra.num-pedido-orig. 
        RUN preparaPedidoCompra IN {&hDBOTable} (output c-formato-cgc,
                                                 output l-modulo-ge,
                                                 output c-end-cobranca-aux,
                                                 output c-end-entrega-aux,
                                                 output i-cod-mensagem,
                                                 output c-seg-usuario,
                                                 output i-cond-pagto).

        IF (int-ds-ped-compra.cod-cond-pag = ? OR  
            int-ds-ped-compra.cod-cond-pag = 0)  
        THEN
           ASSIGN i-cond-pagto = i-cond-pagto.
        ELSE 
           ASSIGN i-cond-pagto = int-ds-ped-compra.cod-cond-pag.
        
        assign ttpedido-compr.num-pedido       = i-num-pedido
               ttpedido-compr.end-cobranca     = c-end-cobranca-aux
               ttpedido-compr.end-entrega      = c-end-entrega-aux
               ttpedido-compr.cod-mensagem     = i-cod-mensagem
               ttpedido-compr.responsavel      = c-seg-usuario
               ttpedido-compr.cod-cond-pag     = i-cond-pagto
               ttpedido-compr.l-tipo-ped       = 1
               ttpedido-compr.natureza         = 1
               ttpedido-compr.emergencial      = YES    
               ttpedido-compr.data-pedido      = int-ds-ped-compra.data-pedido 
               fi-cod-estab                    = string(int-ds-ped-compra.cod-estabel,"999")
               fi-requisitante                 = c-seg-usuario
               fi-mo-codigo                    = 0
               ttpedido-compr.end-entrega      = fi-cod-estab 
               ttpedido-compr.end-cobranca     = fi-cod-estab
               ttpedido-compr.cod-emitente     = i-cod-emitente /* informado na tabela tutorial */
               ttpedido-compr.cod-emit-terc    = ttpedido-compr.cod-emitente /* emitente entrega */ 
               ttpedido-compr.cod-transp       = 99999     
               ttpedido-compr.cod-mensagem     = 2
               ttpedido-compr.cod-estab-gestor = ""
               ttpedido-compr.comentarios      = "Integrado automaticamente".
               
               
        for each int-ds-ordem-compra no-lock where
                 int-ds-ordem-compra.num-pedido-orig = int-ds-ped-compra.num-pedido-orig,
            first item no-lock where
                  item.it-codigo = string(int-ds-ordem-compra.it-codigo) :  
                 
              /* Foi pedido para retirar essa a ativa‡Æo dos itens obsoletos em 10/02/2017
              
                 FOR FIRST b-item WHERE
                           b-item.it-codigo = STRING(int-ds-ordem-compra.it-codigo):

                  IF b-item.cod-obsoleto > 1 
                  THEN DO:
                     ASSIGN b-item.cod-obsoleto = 1. /* Ativo */
                  END.

              END.

              RELEASE b-item.

              for first item-uni-estab fields(cod-estabel it-codigo cod-obsoleto) where 
                        item-uni-estab.cod-estabel = fi-cod-estab and 
                        item-uni-estab.it-codigo   = item.it-codigo: 
              end.

              if avail item-uni-estab and
                 item-uni-estab.cod-obsoleto > 1 
              THEN DO:
                  ASSIGN item-uni-estab.cod-obsoleto = 1.  /* Ativo */
              END.
              
              RELEASE item-uni-estab.
              */

              find item-fornec no-lock where 
                   item-fornec.it-codigo    = string(int-ds-ordem-compra.it-codigo) and
                   item-fornec.cod-emitente = ttpedido-compr.cod-emitente no-error.
              if NOT available item-fornec then do:                                                              
                 create item-fornec.
                 assign item-fornec.it-codigo    = string(int-ds-ordem-compra.it-codigo)
                        item-fornec.cod-emitente = ttpedido-compr.cod-emitente
                        item-fornec.item-do-forn = "" /* int-ds-ordem-compra.item-do-forn */ 
                        item-fornec.unid-med-for = item.un
                        item-fornec.fator-conver = 1
                        item-fornec.num-casa-dec = 0
                        item-fornec.ativo        = YES
                        item-fornec.cod-cond-pag = ttpedido-compr.cod-cond-pag
                        item-fornec.classe-repro = 3
                        item-fornec.aval-insp    = 5
                        OVERLAY(item-fornec.char-1,1,1) = "2"  /*Tributacao PIS Isento*/
                        OVERLAY(item-fornec.char-1,8,1) = "2". /*Tributacao COFINS Isento*/
              end.       

              FIND FIRST item-fornec-umd WHERE 
                         item-fornec-umd.it-codigo    = string(int-ds-ordem-compra.it-codigo) AND
                         item-fornec-umd.cod-emitente = ttpedido-compr.cod-emitente           AND
                         item-fornec-umd.unid-med-for = "CX" NO-LOCK NO-ERROR.
              IF NOT AVAIL item-fornec-umd THEN DO:
                 CREATE item-fornec-umd.
                 ASSIGN item-fornec-umd.it-codigo    = string(int-ds-ordem-compra.it-codigo)
                        item-fornec-umd.cod-emitente = ttpedido-compr.cod-emitente          
                        item-fornec-umd.unid-med-for = "CX"
                        item-fornec-umd.log-ativo    = YES.

                 CREATE tt-aux.
                 ASSIGN tt-aux.r-item-fornec-umd = ROWID(item-fornec-umd).
              END.
                 
              FIND FIRST item-fornec-umd WHERE 
                         item-fornec-umd.it-codigo    = string(int-ds-ordem-compra.it-codigo) AND
                         item-fornec-umd.cod-emitente = ttpedido-compr.cod-emitente           AND
                         item-fornec-umd.unid-med-for = "UN" NO-LOCK NO-ERROR.
              IF NOT AVAIL item-fornec-umd THEN DO:
                 CREATE item-fornec-umd.
                 ASSIGN item-fornec-umd.it-codigo    = string(int-ds-ordem-compra.it-codigo)
                        item-fornec-umd.cod-emitente = ttpedido-compr.cod-emitente          
                        item-fornec-umd.unid-med-for = "UN"
                        item-fornec-umd.log-ativo    = YES.

                 CREATE tt-aux.
                 ASSIGN tt-aux.r-item-fornec-umd = ROWID(item-fornec-umd).
              END.

              for first item-fornec-estab where 
                        item-fornec-estab.it-codigo    = string(int-ds-ordem-compra.it-codigo) and
                        item-fornec-estab.cod-emitente = ttpedido-compr.cod-emitente and
                        item-fornec-estab.cod-estabel  = fi-cod-estab:
              end.          
              if NOT available item-fornec-estab THEN DO:
                 CREATE item-fornec-estab.
                 ASSIGN item-fornec-estab.it-codigo    = string(int-ds-ordem-compra.it-codigo)
                        item-fornec-estab.cod-emitente = ttpedido-compr.cod-emitente 
                        item-fornec-estab.cod-estabel  = fi-cod-estab.
              END.
              assign item-fornec-estab.ativo = if avail item-fornec then item-fornec.ativo else no.
        end.            
                 
        bloco:     
        DO TRANS: 

            FIND FIRST ttpedido-compr NO-LOCK NO-ERROR.
            /* Pedido de Compra */
            run emptyRowErrors in {&hDBOTable}.
            run setConstraintMain in {&hDBOTable}.
            run openQueryStatic in {&hDBOTable} (input "Main").
            run setRecord in {&hDBOTable} (input table ttpedido-compr).
            ASSIGN ttpedido-compr.num-pedido       = i-num-pedido.
            
            run createRecord in {&hDBOTable}.
            run getRowErrors in {&hDBOTable} ( output table RowErrors ).
            
            IF CAN-FIND(FIRST RowErrors) THEN DO:
        
               FOR EACH RowErrors where
                        rowErrors.ErrorSubType = "Error":
                    
                  create tt-erro.
                  assign tt-erro.cd-erro  = rowErrors.ErrorNumber
                         tt-erro.mensagem = rowErrors.ErrorDescription.   
                     
               END.  
        
               UNDO bloco, LEAVE bloco. 
        
                 
            END. 
            ELSE DO:
        
                FIND FIRST ttpedido-compr NO-ERROR.                           

                for each int-ds-ordem-compra no-lock where
                         int-ds-ordem-compra.num-pedido-orig = int-ds-ped-compra.num-pedido-orig:                                                            
                           
                    empty temp-table ttcotacao-item.
                    empty temp-table tt-cotacao-item-bo.           
                                                   
                    IF VALID-HANDLE(h-acomp) THEN
                      RUN pi-acompanhar IN h-acomp(INPUT "Item :" + STRING(int-ds-ordem-compra.it-codigo)).
                         
                         
                      FIND FIRST ITEM NO-LOCK WHERE
                                 ITEM.it-codigo = string(int-ds-ordem-compra.it-codigo) NO-ERROR.

                    /*******
                          
                                ASSIGN fi-cod-comprado = item.cod-comprado. /* Geyson pediu para deixar fixo */
                
                            find item-uni-estab where 
                                 item-uni-estab.cod-estabel = fi-cod-estab  and
                                 item-uni-estab.it-codigo   = string(int-ds-ordem-compra.it-codigo) no-lock no-error.
                            if  avail item-uni-estab then
                                ASSIGN fi-cod-comprado = item-uni-estab.cod-comprado.
                                
                            if fi-cod-comprado = "" then 
                               assign fi-cod-comprado = "super".
                               
                    ****************/
                             
                    ASSIGN fi-cod-comprado = "013191"
                           fi-requisitante = "013191". 

                    for first cont-emit NO-LOCK where 
                              cont-emit.cod-emitente = ttpedido-compr.cod-emitente:
                         
                        ASSIGN c-contato = cont-emit.nome.
            
                    end.        
            
                    for first emitente fields (tp-desp-padrao) no-lock where
                              emitente.cod-emitente = ttpedido-compr.cod-emitente:
                       
                        ASSIGN fi-tp-despesa = emitente.tp-desp-padrao.
               
                    end.    

                    FOR first tipo-rec-desp NO-LOCK where 
                              tipo-rec-desp.tp-codigo = fi-tp-despesa :
                    END.
                    if not available tipo-rec-desp 
                    then do:
                       ASSIGN fi-tp-despesa = 399. 
                    END.
                  
                    empty temp-table tt-ordem-compra-bo.   
                    
                    assign de-preco-fornec = 0
                           de-preco-unit   = 0.    
                    
                    if int-ds-ordem-compra.preco-fornec <= 0 then 
                       assign de-preco-fornec = 0.01.
                    else 
                       assign de-preco-fornec = int-ds-ordem-compra.preco-fornec.
                       
                    if int-ds-ordem-compra.preco-unitario <= 0 then 
                       assign de-preco-unit = 0.01.
                    else 
                       assign de-preco-unit = int-ds-ordem-compra.preco-unitario.     
                    
                    create tt-ordem-compra-bo.
                    assign /* tt-ordem-compra-bo.ind-tipo-movto = 1 */
                           tt-ordem-compra-bo.numero-ordem   = i-num-ordem 
                           tt-ordem-compra-bo.num-pedido     = ttpedido-compr.num-pedido
                           tt-ordem-compra-bo.cod-emitente   = ttpedido-compr.cod-emitente
                           tt-ordem-compra-bo.mo-codigo      = fi-mo-codigo
                           tt-ordem-compra-bo.it-codigo      = string(int-ds-ordem-compra.it-codigo)   /* tabela tutorial */                                                  
                           tt-ordem-compra-bo.cod-estabel    = fi-cod-estab
                           tt-ordem-compra-bo.data-emissao   = ttpedido-compr.data-pedido
                           tt-ordem-compra-bo.requisitante   = fi-requisitante
                           tt-ordem-compra-bo.cod-comprado   = fi-cod-comprado
                           tt-ordem-compra-bo.qt-solic       = int-ds-ordem-compra.qt-solic          /* tabela tutorial */
                           tt-ordem-compra-bo.preco-fornec   = de-preco-fornec                       /* tabela tutorial */
                           tt-ordem-compra-bo.preco-unit     = de-preco-unit                         /* tabela tutorial */
                           tt-ordem-compra-bo.pre-unit-for   = de-preco-unit                         /* tabela tutorial */
                           tt-ordem-compra-bo.tp-despesa     = fi-tp-despesa 
                           /* tt-ordem-compra-bo.l-split        = no  */
                           tt-ordem-compra-bo.situacao       = 1
                           tt-ordem-compra-bo.cod-cond-pag   = ttpedido-compr.cod-cond-pag
                           tt-ordem-compra-bo.cod-transp     = ttpedido-compr.cod-transp
                           tt-ordem-compra-bo.aliquota-iss   = 0
                           tt-ordem-compra-bo.aliquota-ipi   = 0
                           tt-ordem-compra-bo.aliquota-icm   = 0
                           tt-ordem-compra-bo.contato        = c-contato
                           tt-ordem-compra-bo.data-cotacao   = ttpedido-compr.data-pedido
                           tt-ordem-compra-bo.data-pedido    = ttpedido-compr.data-pedido
                           tt-ordem-compra-bo.ep-codigo      = i-ep-codigo-usuario
                           tt-ordem-compra-bo.nr-dias-taxa   = 0
                           tt-ordem-compra-bo.impr-ficha     = no
                           tt-ordem-compra-bo.taxa-finan     = no
                           tt-ordem-compra-bo.qt-acum-nec    = tt-ordem-compra-bo.qt-solic.
            
                    run buscaInfOrdemLeaveItem in h-boin274sd (input tt-ordem-compra-bo.it-codigo,
                                                               input tt-ordem-compra-bo.cod-estabel,
                                                               input tt-ordem-compra-bo.num-pedido,                                                              
                                                               output c-cod-comprado ,
                                                               output tt-ordem-compra-bo.ct-codigo,
                                                               output tt-ordem-compra-bo.sc-codigo,
                                                               output tt-ordem-compra-bo.dep-almoxar,
                                                               output fi-tp-despesa).
                   
                    assign tt-ordem-compra-bo.conta-contabil = tt-ordem-compra-bo.ct-codigo + tt-ordem-compra-bo.sc-codigo
                           tt-ordem-compra-bo.dep-almoxar    = "973".  /* Foi solicitado para fixar Dep¢sito = 973 em fun‡Æo de processar apenas Pedidos do Estabelecimento 973 */
                                                                                                                                                  
                    empty temp-table tt-prazo-compra-bo.     
                    
                    create tt-prazo-compra-bo.
                    assign tt-prazo-compra-bo.numero-ordem   = i-num-ordem 
                           tt-prazo-compra-bo.parcela        = 1
                           tt-prazo-compra-bo.quantidade     = tt-ordem-compra-bo.qt-solic
                           tt-prazo-compra-bo.un             = item.un
                           tt-prazo-compra-bo.data-entrega   = tt-ordem-compra-bo.data-emissao
                           tt-prazo-compra-bo.situacao       = tt-ordem-compra-bo.situacao
                           tt-prazo-compra-bo.data-alter     = tt-ordem-compra-bo.data-emissao
                           tt-prazo-compra-bo.it-codigo      = tt-ordem-compra-bo.it-codigo
                           tt-prazo-compra-bo.qtd-a-ped-forn = tt-prazo-compra-bo.quantidade
                           tt-prazo-compra-bo.qtd-do-forn    = tt-prazo-compra-bo.quantidade
                           tt-prazo-compra-bo.qtd-sal-forn   = tt-prazo-compra-bo.quantidade
                           tt-prazo-compra-bo.quant-saldo    = tt-prazo-compra-bo.quantidade
                           tt-prazo-compra-bo.quantid-orig   = tt-prazo-compra-bo.quantidade.
                           
                    run calculaProximaParcelaPrazoCompra in h-boin356ca (input tt-ordem-compra-bo.numero-ordem,
                                                                         input tt-ordem-compra-bo.it-codigo,
                                                                         input tt-ordem-compra-bo.cod-estabel,
                                                                         output tt-prazo-compra-bo.parcela,
                                                                         output c-un,
                                                                         output tt-prazo-compra-bo.data-entrega).
                    
                    run emptyRowObject in h-boin082sd.

                    run preparaCotacaoOrdemCompraPedEmerg in h-boin082sd (input  tt-ordem-compra-bo.numero-ordem,  
                                                                          input  ttpedido-compr.num-pedido, 
                                                                          input  tt-ordem-compra-bo.cod-emitente,  
                                                                          input  tt-ordem-compra-bo.it-codigo,
                                                                          input  tt-ordem-compra-bo.cod-estabel,
                                                                          input  tt-ordem-compra-bo.qt-solic,
                                                                          input  tt-prazo-compra-bo.data-entrega,  
                                                                          input-output fi-cod-comprado,
                                                                          output l-discard,
                                                                          output l-discard,
                                                                          output l-discard,
                                                                          output l-discard,
                                                                          output l-discard,
                                                                          output l-discard,  
                                                                          output table ttcotacao-item).

                    FOR FIRST ttcotacao-item WHERE
                              ttcotacao-item.cod-emitente = tt-ordem-compra-bo.cod-emitente:
                         
                        CREATE tt-cotacao-item-bo.
                        BUFFER-COPY ttcotacao-item TO tt-cotacao-item-bo.
                        ASSIGN tt-cotacao-item-bo.preco-fornec   = tt-ordem-compra-bo.preco-fornec
                               tt-cotacao-item-bo.preco-unit     = tt-ordem-compra-bo.preco-fornec
                               tt-cotacao-item-bo.pre-unit-for   = tt-ordem-compra-bo.pre-unit-for                                          
                               tt-cotacao-item-bo.cod-transp     = ttpedido-compr.cod-transp   
                               tt-cotacao-item-bo.hora-atualiz   = STRING(TIME,"HH:MM")
                               tt-cotacao-item-bo.cod-comprado   = fi-cod-comprado
                               tt-cotacao-item-bo.cot-aprovada   = YES
                               tt-cotacao-item-bo.contato        = c-contato
                               tt-cotacao-item-bo.usuario        = c-seg-usuario. 
                           
                        assign tt-cotacao-item-bo.un  = if avail item-fornec then item-fornec.unid-med-for else item.un.
                             
                    END.

                    release ordem-compra.                                                        
                    
                    DO WHILE not AVAIL ordem-compra:               
                                                                   
                            run emptyRowErrors  IN h-boin274.      
                            run emptyRowErrors  IN h-boin274vl.
                            RUN openQuery       IN h-boin274 (INPUT 1).
                            RUN openQueryStatic IN h-boin274vl ("Main":U).

                            /* run geraNumeroOrdemPedEmerg in h-boin274sd (output i-num-ordem,
                                                                           output table RowErrors). 

                            RUN ccp/ccapi333.p(INPUT NO,
                                               OUTPUT i-num-ordem).*/

                            FIND FIRST int-ds-nr-ordem NO-LOCK NO-ERROR.
                            IF AVAIL int-ds-nr-ordem THEN DO:
                               ASSIGN i-num-ordem = int-ds-nr-ordem.nr-ordem-compra + 1.
                               FIND FIRST int-ds-nr-ordem EXCLUSIVE-LOCK NO-ERROR.
                               ASSIGN int-ds-nr-ordem.nr-ordem-compra = i-num-ordem.
                               RELEASE int-ds-nr-ordem.
                            END.

                            FOR EACH tt-ordem-compra-bo:
                               ASSIGN tt-ordem-compra-bo.numero-ordem = i-num-ordem.
                            END.

                            run validatecreatePedEmerg in h-boin274vl (input table tt-ordem-compra-bo,
                                                                       input l-inclui-item-fornec ,  /* gera relacionamento item x fornec? */
                                                                       output  l-inclui-item-fornec, /* chama tela de manut cc0105? */
                                                                       output table Rowerrors,
                                                                       output i-num-ordem-aux).

                            IF NOT CAN-FIND(FIRST RowErrors) 
                            THEN DO:

                                RUN setRecord      IN h-boin274 (INPUT TABLE tt-ordem-compra-bo).
                                RUN createRecord   IN h-boin274.
                                run getRowErrors   in h-boin274( output table RowErrors).
                            
                            END.

                            IF NOT CAN-FIND(FIRST RowErrors) 
                            THEN DO:
                                             
                                FOR EACH tt-prazo-compra-bo:
                                    ASSIGN  tt-prazo-compra-bo.numero-ordem = i-num-ordem.
                                END.
        
                                /* Criando as parcelas da ordem de compra */
                                     run emptyRowErrors in h-boin356.
                                     RUN openQuery      IN h-boin356 (INPUT 1).
                                     RUN setRecord      IN h-boin356 (INPUT TABLE tt-prazo-compra-bo).
                                     RUN createRecord   IN h-boin356.
                                     run getRowErrors   in h-boin356 (output table RowErrors).
                                     
                                    find first ordem-compra WHERE
                                               ordem-compra.numero-ordem = i-num-ordem no-lock no-error.                                                                                       
        
                            END.
                            ELSE DO:
                            
                                  
                                FOR FIRST RowErrors WHERE
                                          rowErrors.ErrorNumber = 24 AND 
                                          rowErrors.ErrorDescription BEGINS "Ordem Compra":                                              
                                                                                        
                                END.
    
                                IF AVAIL RowErrors THEN DO:
                               
                                    /* run geraNumeroOrdemPedEmerg in h-boin274sd (output i-num-ordem,
                                                                                   output table RowErrors). 

                                     RUN ccp/ccapi333.p(INPUT NO,
                                                        OUTPUT i-num-ordem).*/
                                            
                                     FIND FIRST int-ds-nr-ordem NO-LOCK NO-ERROR.
                                     IF AVAIL int-ds-nr-ordem THEN DO:
                                        ASSIGN i-num-ordem = int-ds-nr-ordem.nr-ordem-compra + 1.
                                        FIND FIRST int-ds-nr-ordem EXCLUSIVE-LOCK NO-ERROR.
                                        ASSIGN int-ds-nr-ordem.nr-ordem-compra = i-num-ordem.
                                        RELEASE int-ds-nr-ordem.
                                     END.

                                     find FIRST ordem-compra no-lock WHERE
                                                ordem-compra.numero-ordem = i-num-ordem no-error. 
                                       
    
                                END.
                                ELSE DO:
                                   find first ordem-compra WHERE
                                              ordem-compra.numero-ordem > 0 no-lock no-error.                                          
                                END.
                                
                            END.       
                        
                    END. /* Do While */
                    
                    
                    FOR FIRST tt-ordem-compra-bo:                
                    END.

                    IF NOT CAN-FIND(FIRST RowErrors) 
                    THEN DO:
                         
                       FOR EACH tt-cotacao-item-bo:

                          ASSIGN tt-cotacao-item-bo.numero-ordem = i-num-ordem.
                               
                       END.

                       run emptyRowErrors in  h-boin082vl.

                       RUN createUpdateCotacaoItem IN h-boin082vl (INPUT TABLE tt-cotacao-item-bo,
                                                 INPUT tt-ordem-compra-bo.it-codigo,
                                                 INPUT yes,
                                                 INPUT "super",
                                                 INPUT yes,
                                                 INPUT no,
                                                 INPUT-OUTPUT r-cotacao-item,
                                                 OUTPUT l-inclui-item-fornec,
                                                 OUTPUT TABLE rowErrors).

                    END.                                 
                    
                    for each RowErrors: 

                       RUN _insertErrorManual IN {&hDBOTable} (INPUT rowErrors.ErrorNumber,
                                                               INPUT "EMS":U,
                                                               INPUT "ERROR":U,
                                                               INPUT rowErrors.ErrorDescription,
                                                               input "",
                                                               input "").
                    end.
                    
                    FOR EACH tt-prazo-compra-bo:
                    
                       for FIRST prazo-compra WHERE 
                                 prazo-compra.numero-ordem = tt-prazo-compra-bo.numero-ordem AND
                                 prazo-compra.it-codigo    = tt-prazo-compra-bo.it-codigo AND
                                 prazo-compra.parcela      = tt-prazo-compra-bo.parcela  :
                       end.
                                 
                       IF AVAIL prazo-compra THEN
                       DO:
                         ASSIGN prazo-compra.qtd-sal-forn = prazo-compra.quantid-orig.
                         ASSIGN prazo-compra.qtd-do-forn  = prazo-compra.quantid-orig.
                       END.

                       RELEASE prazo-compra.
                    END.
                     
                    run getRowErrors in {&hDBOTable} (output table RowErrors ).
                    
                    FOR FIRST tt-ordem-compra-bo:
                                     
                    END.
            
                    IF NOT CAN-FIND(FIRST rowerrors where
                                          rowErrors.ErrorSubType = "Error") 
                    THEN DO:
                        /* aprovacao eletronica */
            
                        For FIRST ordem-compra NO-LOCK WHERE
                                  ordem-compra.numero-ordem = tt-ordem-compra-bo.numero-ordem :
                        end.          
                        IF AVAIL ordem-compra 
                        THEN DO:
                        
                          for first b-int-ds-ordem-compra where
                                     rowid(b-int-ds-ordem-compra) = rowid(int-ds-ordem-compra) :
                          end.
                                     
                          if avail b-int-ds-ordem-compra then 
                             assign b-int-ds-ordem-compra.numero-ordem = tt-ordem-compra-bo.numero-ordem.
                           
                          release b-int-ds-ordem-compra.
                                                              
                          RUN aprovaAddOrdemCompraPedidos in h-boin274vl (INPUT  rowid(ordem-compra),
                                                                          OUTPUT TABLE RowErrors).   
                        END.
                                 
                    END.
                         
                    FOR FIRST tt-ordem-compra-bo:
                    END.
                             
                    IF CAN-FIND(FIRST RowErrors where
                                      rowErrors.ErrorSubType = "Error" AND 
                                      rowErrors.ErrorNumber  <> 16760) 
                    THEN DO:                                         
                        
                        FOR EACH RowErrors where
                                 rowErrors.ErrorSubType = "Error" AND 
                                 rowErrors.ErrorNumber  <> 16760: 

                            create tt-erro.
                            assign tt-erro.cd-erro  = rowErrors.ErrorNumber
                                   tt-erro.mensagem = rowErrors.ErrorDescription + " Pedido: " + string(tt-ordem-compra-bo.num-pedido) + 
                                                                                   " Ordem: " + string(tt-ordem-compra-bo.numero-ordem) +
                                                                                   " Item: " + string(tt-ordem-compra-bo.it-codigo).  
                              
                        END. 
                    
                        UNDO bloco, LEAVE bloco. 
                    END.  
                    ELSE DO:
                        
                        FOR FIRST ordem-compra WHERE
                                  ordem-compra.numero-ordem = tt-ordem-compra-bo.numero-ordem:
                
                            ASSIGN ordem-compra.situacao = 2.
                
                            FOR EACH prazo-compra WHERE 
                                     prazo-compra.numero-ordem = ordem-compra.numero-ordem:
                
                                ASSIGN prazo-compra.situacao = 2.
                                          
                            END.
                        END.  
                    END.                    
                end. /* int-ds-ordem-compra */
            END.
        END.  /* do trans */ 
    END. /* can find erro */
    
    do trans:
        if can-find (first tt-erro) 
        then do:
           find first tt-erro no-error.                  
                    
           RUN intprg/int999.p (INPUT "PCOMPR", 
                                INPUT string(int-ds-ped-compra.num-pedido-orig),
                                INPUT tt-erro.mensagem + " Pedido: " + string(int-ds-ped-compra.num-pedido-orig) + " Estab.: " + string(int-ds-ped-compra.cod-estabel) + 
                                                         " CNPJ: " + string(int-ds-ped-compra.cnpj-cpf), 
                                INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                INPUT c-seg-usuario).  
               
        end.
        else do:
            find first ttpedido-compr no-error.                                 
                       
            for first b-int-ds-ped-compra where
                     rowid(b-int-ds-ped-compra) = rowid(int-ds-ped-compra) :
                     
            end.
            if avail b-int-ds-ped-compra 
            then DO:
            
               assign b-int-ds-ped-compra.situacao   = 2
                      b-int-ds-ped-compra.num-pedido = ttpedido-compr.num-pedido.

               PUT b-int-ds-ped-compra.num-pedido     AT 01 
                   int-ds-ped-compra.num-pedido-orig  AT 15 SKIP.

            END.            
            release b-int-ds-ped-compra. 
            
            RUN intprg/int999.p (INPUT "PCOMPR", 
                                INPUT string(int-ds-ped-compra.num-pedido-orig),
                                INPUT "Registro Integrado -" + " Pedido: " + string(int-ds-ped-compra.num-pedido-orig) + " Estab.: " + string(int-ds-ped-compra.cod-estabel) + 
                                                               " CNPJ: " + string(int-ds-ped-compra.cnpj-cpf),
                                INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                                INPUT c-seg-usuario). 
                        
        end. 
    end.
    
    empty temp-table tt-erro.
    
    if valid-handle({&hDBOTable}) then   
      run emptyRowErrors in {&hDBOTable}.
    
    
 end.  /* ped-compra */                      

/* log-manager:close-log(). */ 

    DELETE PROCEDURE h-boin274.
    DELETE PROCEDURE h-boin274sd.
    DELETE PROCEDURE h-boin356.
    DELETE PROCEDURE h-boin082vl.
    DELETE PROCEDURE h-boin082sd.

    ASSIGN h-boin274   = ?
           h-boin274sd = ?
           h-boin356   = ?
           h-boin082vl = ?
           h-boin082sd = ?.

{include/i-rpclo.i}

FOR EACH tt-aux:
    FIND item-fornec-umd WHERE ROWID(item-fornec-umd) = tt-aux.r-item-fornec-umd NO-ERROR.
    IF AVAIL item-fornec-umd THEN
       DELETE item-fornec-umd.
END.

IF VALID-HANDLE(h-acomp) THEN
 RUN pi-finalizar IN h-acomp.
 
RETURN "OK":U.

 
