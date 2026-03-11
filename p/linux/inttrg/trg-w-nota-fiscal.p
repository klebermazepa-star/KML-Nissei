/***************************************************************************************
**   Programa: trg-w-nota-fiscal.p - Trigger de write para a tabela nota-fiscal
**             Zerar o saldo do pedido de venda relacionado à nota fiscal
**   Data....: Dezembro/2015
***************************************************************************************/

def new global shared var c-seg-usuario as char no-undo.

DEF PARAM BUFFER b-nota-fiscal     FOR nota-fiscal.
DEF PARAM BUFFER b-old-nota-fiscal FOR nota-fiscal.

DEFINE TEMP-TABLE RowErrors NO-UNDO
    FIELD ErrorSequence    AS INTEGER
    FIELD ErrorNumber      AS INTEGER
    FIELD ErrorDescription AS CHARACTER
    FIELD ErrorParameters  AS CHARACTER
    FIELD ErrorType        AS CHARACTER
    FIELD ErrorHelp        AS CHARACTER
    FIELD ErrorSubType     AS CHARACTER.

DEFINE TEMP-TABLE tt-ped-venda NO-UNDO LIKE ped-venda
       field r-rowid as rowid.
def temp-table tt-ped-venda-aux  no-undo like tt-ped-venda.

def var bo-ped-venda     as handle no-undo.
def var bo-ped-venda-can as handle no-undo.
def var bo-ped-venda-com as handle no-undo.
def var l-ok             as logical no-undo.

def buffer b-docum-est   for docum-est.
DEF BUFFER b-movto-estoq FOR movto-estoq.

{cep/ceapi001.i}    /* Definicao de temp-table do movto-estoq */
{cdp/cd0666.i}      /* Definicao da temp-table de erros */

DEFINE VARIABLE l-erro      AS LOGICAL     NO-UNDO.


/* transferindo número do pedido para cabeçalho da nota - evita nota sem pedido em caso de queda de processamento */
if  trim(b-nota-fiscal.nr-pedcli) = ""
then do:
    /* NFS NFT */
    if  b-nota-fiscal.esp-docto >= 22 and
        b-nota-fiscal.esp-docto <= 23 then do:
        for each it-nota-fisc fields(nr-pedcli) no-lock of nota-fiscal where it-nota-fisc.nr-pedcli <> "":
            assign b-nota-fiscal.nr-pedcli = it-nota-fisc.nr-pedcli.
            leave.
        end.
    end.
    /* NFD NFE */
    if  b-nota-fiscal.esp-docto >= 20 and
        b-nota-fiscal.esp-docto <= 21 then do:
        for each docum-est no-lock where 
            docum-est.serie-docto  = b-nota-fiscal.serie        and
            docum-est.nro-docto    = b-nota-fiscal.nr-nota-fis  and
            docum-est.cod-emitente = b-nota-fiscal.cod-emitente and
            docum-est.nat-operacao = b-nota-fiscal.nat-operacao:
            for each item-doc-est fields (nr-pedcli) no-lock of docum-est where item-doc-est.nr-pedcli <> "":
                assign b-nota-fiscal.nr-pedcli = item-doc-est.nr-pedcli.
                for each it-nota-fisc of b-nota-fiscal where it-nota-fisc.nr-pedcli = "":
                    assign it-nota-fisc.nr-pedcli = item-doc-est.nr-pedcli.
                end.
                leave.
            end.
        end.
    end.
end.

/* nota sendo cancelada */
IF b-nota-fiscal.dt-cancela     <> ? AND
   b-old-nota-fiscal.dt-cancela  = ? THEN DO:

    FOR FIRST int_ds_pedido WHERE
        int_ds_pedido.ped_codigo_n = int64(b-nota-fiscal.nr-pedcli)
        query-tuning(no-lookahead):
        IF int_ds_pedido.ped_tipopedido_n <> 1 AND
           int_ds_pedido.ped_tipopedido_n <> 8 THEN DO:
            ASSIGN int_ds_pedido.situacao = if int_ds_pedido.situacao <> 3 /* 3- nao reabrir no cancelamento */
                                            then 1 else 2.
        END.

        /* 28/07/2017 - In¡cio Tratar Itens de nota de balan‡o cancelada */
        IF  int_ds_pedido.situacao         = 1 AND /* Pendente */
           (int_ds_pedido.ped_tipopedido_n = 3  OR /* BALANCO MANUAL FILIAL */
            int_ds_pedido.ped_tipopedido_n = 11 OR /* BALANCO MANUAL DEPOSITO */
            int_ds_pedido.ped_tipopedido_n = 12 OR /* BALANCO COLETOR FILIAL */
            int_ds_pedido.ped_tipopedido_n = 13 OR /* BALANCO COLETOR DEPOSITO */
            int_ds_pedido.ped_tipopedido_n = 14 OR /* BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO */  
            int_ds_pedido.ped_tipopedido_n = 31 OR /* BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO) */  
            int_ds_pedido.ped_tipopedido_n = 35 OR /* BALAN€O GERAL CONTROLADOS DEPOSITO */  
            int_ds_pedido.ped_tipopedido_n = 36)   /* BALAN€O GERAL CONTROLADOS FILIAL */  
        THEN DO:
            FOR EACH it-nota-fisc OF b-nota-fiscal NO-LOCK:
                FOR FIRST int_ds_pedido_produto EXCLUSIVE-LOCK 
                    WHERE int_ds_pedido_produto.ped_codigo_n  = int_ds_pedido.ped_codigo_n
                      AND int_ds_pedido_produto.ppr_produto_n = INT(it-nota-fisc.it-codigo):
                    ASSIGN int_ds_pedido_produto.nen_notafiscal_n = 0.
                END.
            END.
            RELEASE int_ds_pedido_produto.
        END.
        /* 28/07/2017 - Fim Tratar Itens de nota de balan‡o cancelada */
    END.
    FOR FIRST int_ds_pedido_subs WHERE
        int_ds_pedido_subs.ped_codigo_n = int64(b-nota-fiscal.nr-pedcli)
        query-tuning(no-lookahead):
        IF int_ds_pedido_subs.ped_tipopedido_n <> 1 AND
           int_ds_pedido_subs.ped_tipopedido_n <> 8 THEN DO:
            ASSIGN int_ds_pedido_subs.situacao = if int_ds_pedido_subs.situacao <> 3 /* 3- nao reabrir no cancelamento */
                                                 then 1 else 2.
        END.
    END.
    
    /* devolução */
    if b-nota-fiscal.ind-tip-nota = 8 and
       b-nota-fiscal.esp-docto = 20 then do:

        for first docum-est 
            fields (cod-estabel nro-docto serie-docto nat-operacao cod-emitente) 
            no-lock where 
            docum-est.serie-docto  = b-nota-fiscal.serie and
            docum-est.nro-docto    = b-nota-fiscal.nr-nota-fis and
            docum-est.cod-emitente = b-nota-fiscal.cod-emitente and
            docum-est.nat-operacao = b-nota-fiscal.nat-operacao
            query-tuning(no-lookahead): end.
        if not avail docum-est then next.
        for first estabelec fields (cgc)
            no-lock where estabelec.cod-estabel = docum-est.cod-estabel
            query-tuning(no-lookahead): end.

        for each devol-cli of docum-est
            query-tuning(no-lookahead):
            delete devol-cli.
        end.
        l-ok = no.
        if b-nota-fiscal.cod-estabel <> "973" then do:
            for each cst_fat_devol WHERE
                     cst_fat_devol.cod_estabel  = docum-est.cod-estabel  AND
                     cst_fat_devol.serie_docto  = docum-est.serie-docto  AND
                     cst_fat_devol.nro_docto    = docum-est.nro-docto    AND
                     cst_fat_devol.cod_emitente = docum-est.cod-emitente AND 
                     cst_fat_devol.nat_operacao = docum-est.nat-operacao query-tuning(no-lookahead):
                for each int_ds_devolucao_cupom where
                    int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev and
                    int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc
                    query-tuning(no-lookahead):
                     /* reabrir somente se situacao de pedido for 2 - processado. 3 - marcado para não reabrir no cancelamento */
                    assign int_ds_devolucao_cupom.situacao = if int_ds_devolucao_cupom.situacao <> 3 and int_ds_devolucao_cupom.situacao <> 8
                                                             then 1 else int_ds_devolucao_cupom.situacao.
                    l-ok = yes.
                end.
                if l-ok then delete cst_fat_devol.
            end.
            for each item-doc-est no-lock of docum-est
                query-tuning(no-lookahead):
                if item-doc-est.nr-pedcli <> "" then do:
                    for each cst_fat_devol where 
                        cst_fat_devol.cod_estabel = docum-est.cod-estabel   and
                        cst_fat_devol.serie_docto = item-doc-est.serie-docto and
                        cst_fat_devol.nro_docto   = item-doc-est.nr-pedcli
                        query-tuning(no-lookahead):
    
                        if not can-find(first b-docum-est no-lock where
                                        b-docum-est.cod-estabel = cst_fat_devol.cod_estabel and
                                        b-docum-est.serie-docto = cst_fat_devol.serie_docto and
                                        b-docum-est.nro-docto   = cst_fat_devol.nro_docto   and
                                        b-docum-est.nro-docto  <> docum-est.nro-docto) then do:
                            for each int_ds_devolucao_cupom where
                                int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev and
                                int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc
                                query-tuning(no-lookahead):
                                /* reabrir somente se situacao de pedido for 2 - processado. 3 - marcado para não reabrir no cancelamento */
                                assign int_ds_devolucao_cupom.situacao = if int_ds_devolucao_cupom.situacao <> 3 and int_ds_devolucao_cupom.situacao <> 8
                                                                         then 1 else int_ds_devolucao_cupom.situacao.
                                l-ok = yes.
                            end.
                            if l-ok then delete cst_fat_devol.
                        end.
                    end.
                end.
                else do:
                    if item-doc-est.nro-comp <> "" then
                    for each cst_fat_devol where 
                        cst_fat_devol.cod_estabel = docum-est.cod-estabel   and
                        cst_fat_devol.serie_comp  = item-doc-est.serie-comp and
                        cst_fat_devol.nro_comp    = item-doc-est.nro-comp
                        query-tuning(no-lookahead):
    
                        if not can-find(first b-docum-est no-lock where
                                        b-docum-est.cod-estabel = cst_fat_devol.cod_estabel and
                                        b-docum-est.serie-docto = cst_fat_devol.serie_docto and
                                        b-docum-est.nro-docto   = cst_fat_devol.nro_docto   and
                                        b-docum-est.nro-docto  <> docum-est.nro-docto) then do:
    
                            for each int_ds_devolucao_cupom where
                                int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev and
                                int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc
                                query-tuning(no-lookahead):
                                /* reabrir somente se situacao de pedido for 2 - processado. 3 - marcado para não reabrir no cancelamento */
                                assign int_ds_devolucao_cupom.situacao = if int_ds_devolucao_cupom.situacao <> 3 and int_ds_devolucao_cupom.situacao <> 8
                                                                         then 1 else int_ds_devolucao_cupom.situacao.
                                l-ok = yes.
                            end.
                            if l-ok then delete cst_fat_devol.
                        end.
                    end.
                end.
            end. /* item-doc-est */
        end. /* cod-estabel <> "973" */
    end. /* tipo-nota = 8 */

    /* Inicio SM 135 Estorno Custo Cont bil, ICMS Transf Estadual */
    if b-nota-fiscal.esp-docto = 23 /* NFT */ then
    FOR EACH   it-nota-fisc fields (nat-operacao) OF b-nota-fiscal NO-LOCK
        WHERE  it-nota-fisc.vl-icms-it  > 0
          AND (it-nota-fisc.cd-trib-icm = 1   /* Tributado */
           OR  it-nota-fisc.cd-trib-icm = 4) /* Reduzido  */
          and (it-nota-fisc.nat-operacao BEGINS "1152" or
               it-nota-fisc.nat-operacao BEGINS "5152"):

        /*
        FOR FIRST  natur-oper NO-LOCK
            WHERE  natur-oper.nat-operacao = it-nota-fisc.nat-operacao
              AND  natur-oper.transf       = YES
              AND (natur-oper.nat-operacao BEGINS "1152"
               OR  natur-oper.nat-operacao BEGINS "5152"):
        */
            FOR EACH  movto-estoq NO-LOCK
                WHERE movto-estoq.serie         = b-nota-fiscal.serie 
                  AND movto-estoq.nro-docto     = b-nota-fiscal.nr-nota-fis   
                  AND movto-estoq.cod-emitente  = b-nota-fiscal.cod-emitente
                  AND movto-estoq.nat-operacao  = it-nota-fisc.nat-operacao
                  AND movto-estoq.esp-docto     = 22
                  AND movto-estoq.tipo-trans    = 2
                  AND movto-estoq.cod-prog-orig = "trnfssm135":
        
                FOR each b-movto-estoq EXCLUSIVE-LOCK
                    WHERE ROWID(b-movto-estoq) = ROWID(movto-estoq):
                    DELETE b-movto-estoq.
                END.
            END.
        /*
        END.
        */
    END.
    /* Fim SM 135 Estorno Custo Cont bil, ICMS Transf Estadual */
END.


/* Inicio SM 135 Estorno Custo Cont bil, ICMS Transf Estadual */
IF  b-nota-fiscal.idi-sit-nf-eletro      = 3 AND /* Uso Autorizado */
    b-nota-fiscal.dt-confirm             = ? AND
    b-old-nota-fiscal.dt-confirm        <> ? and
    b-nota-fiscal.esp-docto              = 23 /* NFT */
THEN DO:
    FOR EACH   it-nota-fisc fields (nat-operacao) OF b-nota-fiscal NO-LOCK
        WHERE  it-nota-fisc.vl-icms-it  > 0
          AND (it-nota-fisc.cd-trib-icm = 1   /* Tributado */
           OR  it-nota-fisc.cd-trib-icm = 4) /* Reduzido  */
          and (it-nota-fisc.nat-operacao BEGINS "1152" or
               it-nota-fisc.nat-operacao BEGINS "5152"):

        /*
        FOR FIRST  natur-oper NO-LOCK
            WHERE  natur-oper.nat-operacao = it-nota-fisc.nat-operacao
              AND  natur-oper.transf       = YES
              AND (natur-oper.nat-operacao BEGINS "1152"
               OR  natur-oper.nat-operacao BEGINS "5152"):
        */
            FOR EACH  movto-estoq NO-LOCK
                WHERE movto-estoq.serie         = b-nota-fiscal.serie 
                  AND movto-estoq.nro-docto     = b-nota-fiscal.nr-nota-fis   
                  AND movto-estoq.cod-emitente  = b-nota-fiscal.cod-emitente
                  AND movto-estoq.nat-operacao  = it-nota-fisc.nat-operacao
                  AND movto-estoq.esp-docto     = 22
                  AND movto-estoq.tipo-trans    = 2
                  AND movto-estoq.cod-prog-orig = "trnfssm135":
        
                FOR each b-movto-estoq EXCLUSIVE-LOCK
                    WHERE ROWID(b-movto-estoq) = ROWID(movto-estoq):
                    DELETE b-movto-estoq.
                END.
            END.
        /*
        END.
        */
    END.
END.


IF  b-nota-fiscal.idi-sit-nf-eletro      = 3 AND /* Uso Autorizado */
    b-nota-fiscal.dt-confirm            <> ? AND
    b-old-nota-fiscal.dt-confirm         = ? and
    b-nota-fiscal.esp-docto              = 23 /* NFT */
THEN DO:
    ASSIGN l-erro = NO.
    DO TRANS ON ERROR UNDO, LEAVE:

        FOR FIRST estabelec fields (ct-icms-ft) NO-LOCK
            WHERE estabelec.cod-estabel = b-nota-fiscal.cod-estabel: END.

        FOR EACH   it-nota-fisc fields (nat-operacao it-codigo vl-icms-it)
             OF b-nota-fiscal NO-LOCK
            WHERE  it-nota-fisc.vl-icms-it  > 0
              AND (it-nota-fisc.cd-trib-icm = 1   /* Tributado */
               OR  it-nota-fisc.cd-trib-icm = 4)  /* Reduzido  */ 
              and (it-nota-fisc.nat-operacao BEGINS "1152" or
                   it-nota-fisc.nat-operacao BEGINS "5152"):
            
            for first item fields (un) OF it-nota-fisc no-lock: end.

            /*
            FOR FIRST  natur-oper NO-LOCK
                WHERE  natur-oper.nat-operacao = it-nota-fisc.nat-operacao
                  AND  natur-oper.transf       = YES
                  AND (natur-oper.nat-operacao BEGINS "1152"
                   OR  natur-oper.nat-operacao BEGINS "5152"):
            */
                EMPTY TEMP-TABLE tt-erro.
                EMPTY TEMP-TABLE tt-movto.

                CREATE tt-movto.
                ASSIGN tt-movto.cod-versao-integ  = 1
                       tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel
                       tt-movto.serie             = b-nota-fiscal.serie
                       tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis
                       tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente
                       tt-movto.nat-operacao      = it-nota-fisc.nat-operacao
                       tt-movto.it-codigo         = it-nota-fisc.it-codigo
                       tt-movto.quantidade        = 0
                       tt-movto.valor-nota        = 0
                       tt-movto.valor-mat-m[1]    = it-nota-fisc.vl-icms-it
                       tt-movto.valor-icm         = 0
                       tt-movto.valor-ipi         = 0 
                       tt-movto.valor-mob-p[1]    = 0       
                       tt-movto.valor-ggf-p[1]    = 0    
                       tt-movto.conta-contabil    = ""  
                       tt-movto.ct-codigo         = estabelec.ct-icms-ft 
                       tt-movto.sc-codigo         = "" 
                       tt-movto.esp-docto         = 22 /* NFS   */
                       tt-movto.tipo-trans        = 2 /* Sa¡da */
                       tt-movto.cod-prog-orig     = "trnfssm135"
                       tt-movto.dt-trans          = TODAY                       
                       tt-movto.un                = ITEM.un.

                IF  b-nota-fiscal.cod-estabel = "973" 
                THEN 
                    ASSIGN tt-movto.cod-depos = b-nota-fiscal.cod-estabel.
                ELSE     
                    ASSIGN tt-movto.cod-depos = "LOJ". 

                RUN cep/ceapi001.p (INPUT-OUTPUT TABLE tt-movto,
                                    INPUT-OUTPUT TABLE tt-erro,
                                    INPUT NO).

                IF CAN-FIND (FIRST tt-erro)
                THEN DO:
                    ASSIGN l-erro = YES.
                    UNDO, LEAVE.
                END.
            /*
            END. /* FOR FIRST  natur-oper NO-LOCK */
            */
        END. /* FOR EACH it-nota-fisc OF b-nota-fiscal NO-LOCK, */
    END. /* DO TRANS ON ERROR UNDO, LEAVE: */
END. /* IF  b-nota-fiscal.idi-sit-nf-eletro      = 3 AND */
/* Fim SM 135 Estorno Custo Cont bil, ICMS Transf Estadual */


/* 28/07/2017 - In¡cio Tratar Itens de nota de balan‡o emitida */
IF b-nota-fiscal.idi-sit-nf-eletro     <> 1 AND
   b-old-nota-fiscal.idi-sit-nf-eletro  = 1 and
  (b-nota-fiscal.nat-operacao begins "5927" or
   b-nota-fiscal.nat-operacao begins "6927" or
   b-nota-fiscal.nat-operacao begins "1949" or
   b-nota-fiscal.nat-operacao begins "2949" or
   b-nota-fiscal.nat-operacao begins "5949" or
   b-nota-fiscal.nat-operacao begins "6949") 
THEN DO:
    FOR FIRST int_ds_pedido fields (ped_tipopedido_n) NO-LOCK 
        WHERE int_ds_pedido.ped_codigo_n = int64(b-nota-fiscal.nr-pedcli)
        query-tuning(no-lookahead):

        IF  int_ds_pedido.ped_tipopedido_n = 3  OR /* BALANCO MANUAL FILIAL */
            int_ds_pedido.ped_tipopedido_n = 11 OR /* BALANCO MANUAL DEPOSITO */
            int_ds_pedido.ped_tipopedido_n = 12 OR /* BALANCO COLETOR FILIAL */
            int_ds_pedido.ped_tipopedido_n = 13 OR /* BALANCO COLETOR DEPOSITO */
            int_ds_pedido.ped_tipopedido_n = 14 OR /* BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO */  
            int_ds_pedido.ped_tipopedido_n = 31 OR /* BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO) */  
            int_ds_pedido.ped_tipopedido_n = 35 OR /* BALAN€O GERAL CONTROLADOS DEPOSITO */  
            int_ds_pedido.ped_tipopedido_n = 36    /* BALAN€O GERAL CONTROLADOS FILIAL */  
        THEN DO:
            FOR EACH it-nota-fisc OF b-nota-fiscal NO-LOCK:
                FOR each int_ds_pedido_produto EXCLUSIVE-LOCK 
                    WHERE int_ds_pedido_produto.ped_codigo_n  = int_ds_pedido.ped_codigo_n
                      AND int_ds_pedido_produto.ppr_produto_n = INT(it-nota-fisc.it-codigo):
                    ASSIGN int_ds_pedido_produto.nen_notafiscal_n = INT(b-nota-fiscal.nr-nota-fis).
                END.
            END.
            RELEASE int_ds_pedido_produto.
        END.
    END.
END.
/* 28/07/2017 - Fim Tratar Itens de nota de balan‡o emitida */


/*
/* evitar leitura para cupons */
if  b-nota-fiscal.nome-ab-cli <> "" and
    b-nota-fiscal.nr-pedcli  <> "" then
    FIND FIRST int-ds-natur-oper WHERE
               int-ds-natur-oper.nat-operacao = b-nota-fiscal.nat-operacao NO-LOCK NO-ERROR.
IF AVAIL int-ds-natur-oper THEN DO:

   IF int-ds-natur-oper.canc-sdo-ped-venda = YES THEN DO:

      FIND FIRST ped-venda WHERE
                 ped-venda.nome-abrev = b-nota-fiscal.nome-ab-cli AND
                 ped-venda.nr-pedcli  = b-nota-fiscal.nr-pedcli NO-LOCK NO-ERROR.
      IF AVAIL ped-venda THEN DO:

         if not valid-handle(bo-ped-venda-can) or
            bo-ped-venda-can:type <> "PROCEDURE":U or
            bo-ped-venda-can:file-name <> "dibo/bodi159can.p" then
            run dibo/bodi159can.p persistent set bo-ped-venda-can.

         run setUserLog in bo-ped-venda-can (input c-seg-usuario).
         run validateCancelation in bo-ped-venda-can (input ROWID(ped-venda),
                                                      output table Rowerrors).
         if  session:set-wait-state("") then.

         if can-find(first RowErrors) then DO: /* Tratar os erros */
            /*run pi-ShowMessage.*/
         END.

         if not can-find(first RowErrors
                         where RowErrors.ErrorSubType = "Error") then do:

            if  session:set-wait-state("general") then.

            run inputReopenQuotation in bo-ped-venda-can(input NO).
            run updateCancelation in bo-ped-venda-can(input ROWID(ped-venda),
                                                      input "Zerar Saldo Transferencia" /*c-desc-motivo*/,
                                                      input TODAY,
                                                      input 1 /*i-cod-motivo*/).

            run getRowErrors in bo-ped-venda-can (output table RowErrors). /* Tratar os erros */
            if can-find(first RowErrors) then do:
               /*run pi-ShowMessage.*/
            end.

            if not valid-handle(bo-ped-venda) or
               bo-ped-venda:type <> "PROCEDURE":U or
               bo-ped-venda:file-name <> "dibo/bodi159.p" then
               run dibo/bodi159.p persistent set bo-ped-venda.

            run reloadOrder in bo-ped-venda(input ROWID(ped-venda),
                                            output table tt-ped-venda-aux).

            if  return-value = "OK":U then do:
                find first tt-ped-venda-aux NO-ERROR.
                buffer-copy tt-ped-venda-aux to tt-ped-venda.
                delete tt-ped-venda-aux.

                /* caso o pedido precise mudar para atendido total deve completar o pedido novamente*/
                find first tt-ped-venda no-error.

                if tt-ped-venda.cod-sit-ped = 3 then do:
                
                   if not valid-handle(bo-ped-venda-com) or
                       bo-ped-venda-com:type <> "PROCEDURE":U or
                       bo-ped-venda-com:file-name <> "dibo/bodi159com.p":U then
                         run dibo/bodi159com.p persistent set bo-ped-venda-com.
                         
                   run createMPLog    in bo-ped-venda-com(input no).
                   run createMPLog    in bo-ped-venda-com(input yes).
                   
                end.
            end.
         end.

         IF VALID-HANDLE(bo-ped-venda-can)  THEN DO:
            delete procedure bo-ped-venda-can.
            assign bo-ped-venda-can = ?.
         end.        

         IF VALID-HANDLE(bo-ped-venda)  THEN DO:
            delete procedure bo-ped-venda.
            assign bo-ped-venda = ?.
         end.        

         IF VALID-HANDLE(bo-ped-venda-com)  THEN DO:
            delete procedure bo-ped-venda-com.
            assign bo-ped-venda-com = ?.
         end. 

         if  session:set-wait-state("") then.

      end.
   END.
END.
*/
RETURN "OK".
