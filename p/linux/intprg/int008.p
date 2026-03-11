
/******************************************************************************
**
**       PROGRAMA: int008
**
**       DATA....: 02/2016
**
**       OBJETIVO: Integraá∆o Pedido de compra (Emergencial)
**                 
**       VERSAO..: 2.06.001
** 
******************************************************************************/

&GLOBAL-DEFINE hDBOTable         hboin295

{intprg/int-rpw.i} 

/* {utp/ut-glob.i} */
def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.
DEF NEW GLOBAL SHARED VAR i-ep-codigo-usuario  LIKE mgcad.empresa.ep-codigo NO-UNDO.

{METHOD/dbotterr.i}
{inbo/boin295.i ttpedido-compr}

{cdp/cdcfgmat.i}
{ccp/ccapi202.i}
{cdp/cdapi300.i1}
{ccp/ccapi207.i}
{cdp/cd4300.i3} 
{cdp/cd0666.i}

DEFINE TEMP-TABLE ttcotacao-item NO-UNDO LIKE cotacao-item
       field r-rowid as rowid.

DEFINE VARIABLE {&hDBOTable}  AS HANDLE NO-UNDO.
DEFINE VARIABLE hboin274sd    AS HANDLE NO-UNDO.
DEFINE VARIABLE hboin356ca    AS HANDLE NO-UNDO.
DEFINE VARIABLE hboin082sd    AS HANDLE NO-UNDO.
DEFINE VARIABLE hboin274vl    AS HANDLE NO-UNDO.

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

DEF VAR c-discard               AS CHAR                          NO-UNDO. 
DEF VAR i-discard               AS INTEGER                       NO-UNDO.
DEF VAR l-discard               AS LOGICAL                       NO-UNDO.


def buffer b-int-ds-ped-compra   for int-ds-ped-compra. 
def buffer b-int-ds-ordem-compra for int-ds-ordem-compra.

RUN inbo/boin295.p   PERSISTENT SET hboin295.
RUN inbo/boin274sd.p PERSISTENT SET hboin274sd.
RUN inbo/boin356ca.p PERSISTENT SET hboin356ca.
RUN inbo/boin082sd.p PERSISTENT SET hboin082sd. 
RUN inbo/boin274vl.p PERSISTENT SET hboin274vl.

for EACH int-ds-ped-compra no-lock where /*
         int-ds-ped-compra.num-pedido-orig = 10000002 and */  
         int-ds-ped-compra.situacao = 1:   /* Pendente */
          
    empty temp-table ttpedido-compr.      
    empty temp-table tt-erro.         
            
    assign c-cgc = "*" + string(int-ds-ped-compra.cnpj-cpf) + "*" no-error.
             
    find first emitente no-lock where
               emitente.cgc matches c-cgc no-error.
    if avail emitente then                     
       assign i-cod-emitente = emitente.cod-emitente.   
    else 
       assign i-cod-emitente = 0.   

    FIND FIRST emitente NO-LOCK WHERE
               emitente.cod-emitente = i-cod-emitente AND  
               emitente.cod-emitente > 0 NO-ERROR.
    IF AVAIL emitente 
    THEN DO:
             
        CREATE ttpedido-compr.
        
        RUN geraNumeroPedidoCompra IN {&hDBOTable} (output i-num-pedido).
        
        RUN preparaPedidoCompra IN {&hDBOTable} (output c-formato-cgc,
                                                 output l-modulo-ge,
                                                 output c-end-cobranca-aux,
                                                 output c-end-entrega-aux,
                                                 output i-cod-mensagem,
                                                 output c-seg-usuario,
                                                 output i-cond-pagto).
        
        assign ttpedido-compr.num-pedido       = i-num-pedido
               ttpedido-compr.end-cobranca     = c-end-cobranca-aux
               ttpedido-compr.end-entrega      = c-end-entrega-aux
               ttpedido-compr.cod-mensagem     = i-cod-mensagem
               ttpedido-compr.responsavel      = c-seg-usuario
               ttpedido-compr.cod-cond-pag     = i-cond-pagto
               ttpedido-compr.emergencial      = YES    
               ttpedido-compr.data-pedido      = TODAY 
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
                 
              find item-fornec where 
                   item-fornec.it-codigo    = string(int-ds-ordem-compra.it-codigo) and
                   item-fornec.cod-emitente = ttpedido-compr.cod-emitente exclusive-lock no-error.
              if NOT available item-fornec then do:                                             
                 
                  create item-fornec.
                  assign item-fornec.it-codigo    = string(int-ds-ordem-compra.it-codigo)
                         item-fornec.cod-emitente = ttpedido-compr.cod-emitente
                         item-fornec.item-do-forn = "" /* int-ds-ordem-compra.item-do-forn */ 
                         item-fornec.unid-med-for = item.un
                         item-fornec.fator-conver = 1
                         item-fornec.num-casa-dec = 0
                         item-fornec.ativo        = no
                         item-fornec.cod-cond-pag = ttpedido-compr.cod-cond-pag
                         item-fornec.classe-repro = 3
                         item-fornec.aval-insp    = 5
                         OVERLAY(item-fornec.char-1,1,1) = "2"  /*Tributacao PIS Isento*/
                         OVERLAY(item-fornec.char-1,8,1) = "2". /*Tributacao COFINS Isento*/
              end.       
                 
        end.            
                 
        DO TRANS :
                /* Pedido de Compra */
                run emptyRowErrors in {&hDBOTable}.
                run setConstraintMain in {&hDBOTable}.
                run openQueryStatic in {&hDBOTable} (input "Main").
                run setRecord in {&hDBOTable} (input table ttpedido-compr).
                run createRecord in {&hDBOTable}.
                run getRowErrors in {&hDBOTable} ( output table RowErrors ).
        
                IF CAN-FIND(FIRST RowErrors) THEN DO:
        
                   FOR EACH RowErrors where
                            rowErrors.ErrorSubType = "Error":
                        
                      create tt-erro.
                      assign tt-erro.cd-erro  = rowErrors.ErrorNumber
                             tt-erro.mensagem = rowErrors.ErrorDescription.     
                                
                      DISP RowErrors
                           WITH WIDTH 333.
                     
                   END.  
        
                   UNDO, LEAVE.
        
                     
                END. 
                ELSE DO:
        
                     FIND FIRST ttpedido-compr NO-ERROR.
                    
                      DISP ttpedido-compr.num-pedido
                           ttpedido-compr.end-cobranca   
                           ttpedido-compr.end-entrega 
                           ttpedido-compr.cod-mensagem
                           ttpedido-compr.responsavel 
                           ttpedido-compr.cod-cond-pag
                           ttpedido-compr.emergencial 
                           ttpedido-compr.cod-cond-pag
                           ttpedido-compr.end-entrega 
                           ttpedido-compr.end-cobranca 
                           ttpedido-compr.cod-emitente 
                           ttpedido-compr.cod-emit-terc
                            WITH WIDTH 333.   
                     
                    for each int-ds-ordem-compra no-lock where
                             int-ds-ordem-compra.num-pedido-orig = int-ds-ped-compra.num-pedido-orig:                                                            
        
                        FIND FIRST ITEM NO-LOCK WHERE
                                   ITEM.it-codigo = string(int-ds-ordem-compra.it-codigo) NO-ERROR. 
                        if avail item then
                            ASSIGN fi-cod-comprado = item.cod-comprado. 
            
                        find item-uni-estab where 
                             item-uni-estab.cod-estabel = fi-cod-estab  and
                             item-uni-estab.it-codigo   = string(int-ds-ordem-compra.it-codigo) no-lock no-error.
                        if  avail item-uni-estab then
                            ASSIGN fi-cod-comprado = item-uni-estab.cod-comprado.
                            
                        if fi-cod-comprado = "" then 
                           assign fi-cod-comprado = "super".
                                 
                        for first cont-emit NO-LOCK where 
                                  cont-emit.cod-emitente = ttpedido-compr.cod-emitente:
                             
                            ASSIGN c-contato = cont-emit.nome.
            
                        end.        
            
                        for first emitente fields (tp-desp-padrao) no-lock where
                                  emitente.cod-emitente = ttpedido-compr.cod-emitente:
                           
                            ASSIGN fi-tp-despesa = emitente.tp-desp-padrao.
                   
                        end.    
            
                        run geraNumeroOrdemPedEmerg in hboin274sd (output i-num-ordem,
                                                                   output table RowErrors).
                        
                        /* assign i-num-ordem = i-num-ordem + 100. */
                                  
                        empty temp-table tt-ordem-compra.       
                        
                        create tt-ordem-compra.
                        assign tt-ordem-compra.ind-tipo-movto = 1
                               tt-ordem-compra.numero-ordem   = i-num-ordem 
                               tt-ordem-compra.num-pedido     = ttpedido-compr.num-pedido
                               tt-ordem-compra.cod-emitente   = ttpedido-compr.cod-emitente
                               tt-ordem-compra.mo-codigo      = fi-mo-codigo
                               tt-ordem-compra.it-codigo      = string(int-ds-ordem-compra.it-codigo)   /* tabela tutorial */                                                  
                               tt-ordem-compra.cod-estabel    = fi-cod-estab
                               tt-ordem-compra.data-emissao   = ttpedido-compr.data-pedido
                               tt-ordem-compra.requisitante   = fi-requisitante
                               tt-ordem-compra.cod-comprado   = fi-cod-comprado
                               tt-ordem-compra.qt-solic       = int-ds-ordem-compra.qt-solic          /* tabela tutorial */
                               tt-ordem-compra.preco-fornec   = int-ds-ordem-compra.preco-fornec      /* tabela tutorial */
                               tt-ordem-compra.preco-unit     = int-ds-ordem-compra.preco-unitario    /* tabela tutorial */
                               tt-ordem-compra.pre-unit-for   = int-ds-ordem-compra.preco-unitario    /* tabela tutorial */
                               tt-ordem-compra.tp-despesa     = fi-tp-despesa
                               tt-ordem-compra.l-split        = no
                               tt-ordem-compra.situacao       = 1
                               tt-ordem-compra.cod-cond-pag   = ttpedido-compr.cod-cond-pag
                               tt-ordem-compra.cod-transp     = ttpedido-compr.cod-transp
                               tt-ordem-compra.aliquota-iss   = 0
                               tt-ordem-compra.aliquota-ipi   = 0
                               tt-ordem-compra.aliquota-icm   = 0
                               tt-ordem-compra.contato        = c-contato
                               tt-ordem-compra.data-cotacao   = ttpedido-compr.data-pedido
                               tt-ordem-compra.data-pedido    = ttpedido-compr.data-pedido
                               tt-ordem-compra.ep-codigo      = i-ep-codigo-usuario
                               tt-ordem-compra.nr-dias-taxa   = 0
                               tt-ordem-compra.impr-ficha     = no
                               tt-ordem-compra.taxa-finan     = no
                               tt-ordem-compra.qt-acum-nec    = tt-ordem-compra.qt-solic.
            
                        run buscaInfOrdemLeaveItem in hboin274sd (input tt-ordem-compra.it-codigo,
                                                                  input tt-ordem-compra.cod-estabel,
                                                                  input tt-ordem-compra.num-pedido,                                                              
                                                                  output c-cod-comprado ,
                                                                  output tt-ordem-compra.ct-codigo,
                                                                  output tt-ordem-compra.sc-codigo,
                                                                  output tt-ordem-compra.dep-almoxar,
                                                                  output tt-ordem-compra.tp-despesa).
                               
                        assign tt-ordem-compra.conta-contabil = tt-ordem-compra.ct-codigo + tt-ordem-compra.sc-codigo.                                 
                                                            
                        find item-fornec-estab where 
                             item-fornec-estab.it-codigo    = tt-ordem-compra.it-codigo and
                             item-fornec-estab.cod-emitente = ttpedido-compr.cod-emitente and
                             item-fornec-estab.cod-estabel  = fi-cod-estab exclusive-lock no-error.
                        if NOT available item-fornec-estab THEN DO:
                            CREATE item-fornec-estab.
                            ASSIGN item-fornec-estab.it-codigo    = tt-ordem-compra.it-codigo
                                   item-fornec-estab.cod-emitente = ttpedido-compr.cod-emitente 
                                   item-fornec-estab.cod-estabel  = fi-cod-estab.
                        END.
                        assign item-fornec-estab.ativo = no.
                        
                        /* Verificar como vai ficar esse relacionamento */   
                        
                                                                  
                        empty temp-table tt-prazo-compra.     
                        create tt-prazo-compra.
                        assign tt-prazo-compra.ind-tipo-movto = 1
                               tt-prazo-compra.numero-ordem   = i-num-ordem 
                               tt-prazo-compra.parcela        = 1
                               tt-prazo-compra.quantidade     = tt-ordem-compra.qt-solic
                               tt-prazo-compra.un             = item.un
                               tt-prazo-compra.data-entrega   = tt-ordem-compra.data-emissao
                               tt-prazo-compra.situacao       = tt-ordem-compra.situacao
                               tt-prazo-compra.data-alter     = tt-ordem-compra.data-emissao
                               tt-prazo-compra.it-codigo      = tt-ordem-compra.it-codigo
                               tt-prazo-compra.qtd-a-ped-forn = tt-prazo-compra.quantidade
                               tt-prazo-compra.qtd-do-forn    = tt-prazo-compra.quantidade
                               tt-prazo-compra.qtd-sal-forn   = tt-prazo-compra.quantidade
                               tt-prazo-compra.quant-saldo    = tt-prazo-compra.quantidade
                               tt-prazo-compra.quantid-orig   = tt-prazo-compra.quantidade.
                               
                        run calculaProximaParcelaPrazoCompra in hboin356ca (input tt-ordem-compra.numero-ordem,
                                                                            input tt-ordem-compra.it-codigo,
                                                                            input tt-ordem-compra.cod-estabel,
                                                                            output tt-prazo-compra.parcela,
                                                                            output c-un,
                                                                            output tt-prazo-compra.data-entrega).
                      
                        run preparaCotacaoOrdemCompraPedEmerg in hboin082sd (input  tt-ordem-compra.numero-ordem,  
                                                                             input  ttpedido-compr.num-pedido, 
                                                                             input  tt-ordem-compra.cod-emitente,  
                                                                             input  tt-ordem-compra.it-codigo,
                                                                             input  tt-ordem-compra.cod-estabel,
                                                                             input  tt-ordem-compra.qt-solic,
                                                                             input  tt-prazo-compra.data-entrega,  
                                                                             input-output fi-cod-comprado,
                                                                             output l-discard,
                                                                             output l-discard,
                                                                             output l-discard,
                                                                             output l-discard,
                                                                             output l-discard,
                                                                             output l-discard,  
                                                                             output table ttcotacao-item).
            
                        FOR EACH ttcotacao-item:
                            CREATE tt-cotacao-item.
                            BUFFER-COPY ttcotacao-item TO tt-cotacao-item.
                            ASSIGN tt-cotacao-item.preco-fornec   = tt-ordem-compra.preco-fornec
                                   tt-cotacao-item.preco-unit     = tt-ordem-compra.preco-fornec
                                   tt-cotacao-item.pre-unit-for   = tt-ordem-compra.pre-unit-for
                                   tt-cotacao-item.un             = item.un  
                                   tt-cotacao-item.cod-transp     = ttpedido-compr.cod-transp   
                                   tt-cotacao-item.hora-atualiz   = STRING(TIME,"HH:MM")
                                   tt-cotacao-item.cod-comprado   = fi-cod-comprado
                                   tt-cotacao-item.ind-tipo-movto = 1 
                                   tt-cotacao-item.cot-aprovada   = YES
                                   tt-cotacao-item.contato        = c-contato
                                   tt-cotacao-item.usuario        = c-seg-usuario. 
                                                                     
                            DISP tt-cotacao-item EXCEPT motivo char-2
                                 WITH WIDTH 333 1 COL.               
                                 
                        END.
                      
                        
                            create tt-versao-integr.
                            assign tt-versao-integr.cod-versao-integracao = 001
                                   tt-versao-integr.ind-origem-msg        = 01.
                            
                            run ccp/ccapi302.p (input  table tt-versao-integr,
                                                output table tt-erros-geral,
                                                input  table tt-ordem-compra,
                                                input  table tt-prazo-compra,        
                                                input  table tt-cotacao-item,
                                                     &if defined(bf_mat_despesa_fase_II) &then
                                                     input table tt-desp-cotacao-item,
                                                     &endif
                                                     &if '{&bf_mat_versao_ems}' >= '2.04' &then
                                                     input table tt-matriz-rat-med,
                                                    &endif
                                                input "INPUT").
                            
                            for each tt-erros-geral:
            
                                RUN _insertErrorManual IN {&hDBOTable} (INPUT tt-erros-geral.cod-erro,
                                                                        INPUT "EMS":U,
                                                                        INPUT "ERROR":U,
                                                                        INPUT tt-erros-geral.des-erro,
                                                                        input "",
                                                                        input "").
                            end.
                                
                            run getRowErrors in {&hDBOTable} (output table RowErrors ).
                
                            IF NOT CAN-FIND(FIRST rowerrors where
                                                  rowErrors.ErrorSubType = "Error") 
                            THEN DO:
                                /* aprovacao eletronica */
            
                                FIND FIRST ordem-compra NO-LOCK WHERE
                                           ordem-compra.numero-ordem = tt-ordem-compra.numero-ordem NO-ERROR.
                                IF AVAIL ordem-compra THEN DO:
                                
                                  find first b-int-ds-ordem-compra exclusive-lock where
                                             rowid(b-int-ds-ordem-compra) = rowid(int-ds-ordem-compra) no-error.
                                  if avail b-int-ds-ordem-compra then 
                                     assign b-int-ds-ordem-compra.numero-ordem = i-num-ordem.
                                   
                                  release b-int-ds-ordem-compra.
                                                                      
                                  RUN aprovaAddOrdemCompraPedidos in hboin274vl (INPUT  rowid(ordem-compra),
                                                                                  OUTPUT TABLE RowErrors).   
                                END.
                                
                                IF not CAN-FIND(FIRST RowErrors) 
                                THEN DO:
                                
                                  
                                     
                                end.                
                            END.
            
                            IF CAN-FIND(FIRST RowErrors where
                                              rowErrors.ErrorSubType = "Error") 
                            THEN DO:
                
                               FOR EACH RowErrors where
                                        rowErrors.ErrorSubType = "Error":                           
                        
                                   create tt-erro.
                                   assign tt-erro.cd-erro  = rowErrors.ErrorNumber
                                          tt-erro.mensagem = rowErrors.ErrorDescription.
                                             
                               
                                   DISP RowErrors.errornumber
                                        rowErrors.ErrorSubType 
                                        RowErrors.errordescription FORMAT "x(100)"      
                                                                        
                                        WITH WIDTH 333.
                                        
                                        
                                     
                               END. 
                
                                UNDO, LEAVE. 
                            END.  
                            ELSE DO:
                               
                               FOR FIRST ordem-compra EXCLUSIVE-LOCK WHERE
                                         ordem-compra.numero-ordem = tt-ordem-compra.numero-ordem:
                
                                   ASSIGN ordem-compra.situacao = 2.
                
                                   FOR EACH prazo-compra EXCLUSIVE-LOCK WHERE 
                                            prazo-compra.numero-ordem = ordem-compra.numero-ordem:
                
                                       ASSIGN prazo-compra.situacao = 2.
                                                 
                                   END.
                               END.  
                            END.
                            
                    end.
                    
                END.
        
        END.  /* do trans */

    END. /* avail emitente */
    ELSE DO:
        create tt-erro.
        assign tt-erro.cd-erro  = 47
               tt-erro.mensagem = "Fornecedor " + STRING(i-cod-emitente) + " n∆o cadastrado.".  
    END.

    do trans :
        if can-find (first tt-erro) 
        then do:
           find first tt-erro no-error.                  
                    
           RUN intprg/int999.p (INPUT "PCOMPR", 
                                INPUT string(int-ds-ped-compra.num-pedido-orig),
                                INPUT tt-erro.mensagem ,
                                INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                INPUT c-seg-usuario).  
               
        end.
        else do:
            find first ttpedido-compr no-error.                                 
                       
            find first b-int-ds-ped-compra exclusive-lock where
                        rowid(b-int-ds-ped-compra) = rowid(int-ds-ped-compra) no-error.
            if avail b-int-ds-ped-compra then 
               assign b-int-ds-ped-compra.situacao   = 2
                      b-int-ds-ped-compra.num-pedido = ttpedido-compr.num-pedido.
                        
            release b-int-ds-ped-compra. 
            
            RUN intprg/int999.p (INPUT "PCOMPR", 
                                INPUT string(int-ds-ped-compra.num-pedido-orig),
                                INPUT "Integrado" ,
                                INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                                INPUT c-seg-usuario).       

            FIND FIRST int-ds-ext-emitente NO-LOCK WHERE
                       int-ds-ext-emitente.cod-emitente = i-cod-emitente NO-ERROR.
            IF AVAIL int-ds-ext-emitente /* AND  
                     int-ds-ext-emitente.gera-nota retirar coment†rio */
            THEN DO:

               RUN intprg/int008a.p (INPUT ttpedido-compr.num-pedido,
                                           int-ds-ped-compra.num-pedido-orig).

            END.   
                        
        end. 
   end.
    
 end.  /* ped-compra */                      
