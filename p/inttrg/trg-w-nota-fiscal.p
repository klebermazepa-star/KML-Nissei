/***************************************************************************************
**   Programa: trg-w-nota-fiscal.p - Trigger de write para a tabela nota-fiscal
**             Zerar o saldo do pedido de venda relacionado à nota fiscal
**   Data....: Dezembro/2015
***************************************************************************************/
def new global shared var c-seg-usuario as char no-undo.


def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.


DEF PARAM BUFFER b-nota-fiscal     FOR nota-fiscal.
DEF PARAM BUFFER b-old-nota-fiscal FOR nota-fiscal.

DEFINE TEMP-TABLE RowErrors NO-UNDO
    FIELD ErrorSequence    AS INTEGER
    FIELD ErrorNumber      AS INTEGER
    FIELD ErrorDescription AS CHARACTER
    FIELD ErrorParameters  AS character
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
def var de-st-entrada    as decimal no-undo.
def var de-icm-entrada   as decimal no-undo.

DEFINE TEMP-TABLE tt-bonificados NO-UNDO
    FIELD it-codigo AS CHAR
    FIELD sequencia AS INT.

{cep/ceapi001.i}    /* Definicao de temp-table do movto-estoq */
{cdp/cd0666.i}      /* Definicao da temp-table de erros */

def buffer b-docum-est   for docum-est.
DEF BUFFER b-movto-estoq FOR movto-estoq.
def buffer btt-movto     for tt-movto.

DEF BUFFER b-emitente    FOR ems2mult.emitente.

DEFINE VARIABLE l-erro      AS LOGICAL     NO-UNDO.

DEFINE VARIABLE i-niv-trib-icms AS INTEGER     NO-UNDO.
DEFINE VARIABLE l-sub           AS LOGICAL     NO-UNDO.

DEFINE VARIABLE de-vl-bonificacao AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-vl-importados AS DECIMAL     NO-UNDO.
DEFINE VARIABLE c-estabel        AS CHAR        NO-UNDO.



/* KML Consultoria Guilherme Nichele - 13/06/2024 - Criar tabela de altera‡Æo para leitura do BI */


IF v_cdn_empres_usuar = "1" THEN DO: // somente nissei

    FIND FIRST b-nota-fiscal NO-ERROR.

    //c-estabel = b-nota-fiscal.cod-estabel.
    
    IF AVAIL b-nota-fiscal THEN
     DO:
        
        CREATE esp-alteracao-bi.
        ASSIGN esp-alteracao-bi.tabela = "nota-fiscal"
               esp-alteracao-bi.dt-alteracao = TODAY
               esp-alteracao-bi.cod-estabel = b-nota-fiscal.cod-estabel
               esp-alteracao-bi.serie = b-nota-fiscal.serie
               esp-alteracao-bi.nr-nota-fis = b-nota-fiscal.nr-nota-fis.
                   
             
     END.





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

    /* inicio cancelamento de nota */
    IF b-nota-fiscal.dt-cancela     <> ? AND
       b-old-nota-fiscal.dt-cancela  = ? THEN DO:

        FOR FIRST int_ds_pedido WHERE
            int_ds_pedido.ped_codigo_n = int64(b-nota-fiscal.nr-pedcli):

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
            int_ds_pedido_subs.ped_codigo_n = int64(b-nota-fiscal.nr-pedcli):

            IF int_ds_pedido_subs.ped_tipopedido_n <> 1 AND
               int_ds_pedido_subs.ped_tipopedido_n <> 8 THEN DO:
                ASSIGN int_ds_pedido_subs.situacao = if int_ds_pedido_subs.situacao <> 3 /* 3- nao reabrir no cancelamento */
                                                     then 1 else 2.
            END.
        END.
        
        /* devolu‡Æo */
        if b-nota-fiscal.ind-tip-nota = 8 and
           b-nota-fiscal.esp-docto = 20 then do:

            for first docum-est 
                fields (cod-estabel nro-docto serie-docto nat-operacao cod-emitente) 
                no-lock where 
                docum-est.serie-docto  = b-nota-fiscal.serie and
                docum-est.nro-docto    = b-nota-fiscal.nr-nota-fis and
                docum-est.cod-emitente = b-nota-fiscal.cod-emitente and
                docum-est.nat-operacao = b-nota-fiscal.nat-operacao: 
                end.
            if not avail docum-est then next.
            for first ems2mult.estabelec fields (cgc)
                no-lock where estabelec.cod-estabel = docum-est.cod-estabel: 
                end.

            for each devol-cli of docum-est:

                delete devol-cli.
            end.
            l-ok = no.
            if b-nota-fiscal.cod-estabel <> "973" OR b-nota-fiscal.cod-estabel <> "977" then do:
                for each cst_fat_devol WHERE
                         cst_fat_devol.cod_estabel  = docum-est.cod-estabel  AND
                         cst_fat_devol.serie_docto  = docum-est.serie-docto  AND
                         cst_fat_devol.nro_docto    = docum-est.nro-docto    AND
                         cst_fat_devol.cod_emitente = docum-est.cod-emitente AND 
                         cst_fat_devol.nat_operacao = docum-est.nat-operacao:
                    for each int_ds_devolucao_cupom where
                        int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev and
                        int_ds_devolucao_cupom.cnpj_filial_dev = ems2mult.estabelec.cgc :
                       
                         /* reabrir somente se situacao de pedido for 2 - processado. 3 - marcado para não reabrir no cancelamento */
                        assign int_ds_devolucao_cupom.situacao = if int_ds_devolucao_cupom.situacao <> 3 and int_ds_devolucao_cupom.situacao <> 8
                                                                 then 1 else int_ds_devolucao_cupom.situacao.
                        l-ok = yes.
                    end.
                    if l-ok then delete cst_fat_devol.
                end.
                for each item-doc-est no-lock of docum-est:

                    if item-doc-est.nr-pedcli <> "" then do:
                        for each cst_fat_devol where 
                            cst_fat_devol.cod_estabel = docum-est.cod-estabel   and
                            cst_fat_devol.serie_docto = item-doc-est.serie-docto and
                            cst_fat_devol.nro_docto   = item-doc-est.nr-pedcli:
                            
        
                            if not can-find(first b-docum-est no-lock where
                                            b-docum-est.cod-estabel = cst_fat_devol.cod_estabel and
                                            b-docum-est.serie-docto = cst_fat_devol.serie_docto and
                                            b-docum-est.nro-docto   = cst_fat_devol.nro_docto   and
                                            b-docum-est.nro-docto  <> docum-est.nro-docto) then do:
                                            
                                for each int_ds_devolucao_cupom where
                                    int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev and
                                    int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc:

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
                            cst_fat_devol.nro_comp    = item-doc-est.nro-comp:

        
                            if not can-find(first b-docum-est no-lock where
                                            b-docum-est.cod-estabel = cst_fat_devol.cod_estabel and
                                            b-docum-est.serie-docto = cst_fat_devol.serie_docto and
                                            b-docum-est.nro-docto   = cst_fat_devol.nro_docto   and
                                            b-docum-est.nro-docto  <> docum-est.nro-docto) then do:
        
                                for each int_ds_devolucao_cupom where
                                    int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev and
                                    int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc:

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
            end. /* cod-estabel <> "977" */
        end. /* tipo-nota = 8 */

        /* Inicio SM 135 Estorno Custo Cont bil, ICMS Transf Estadual */
        if b-nota-fiscal.esp-docto = 23 /* NFT */ then
        FOR EACH   it-nota-fisc fields (nat-operacao) OF b-nota-fiscal no-lock where
             ( (it-nota-fisc.nat-operacao BEGINS "1152" or it-nota-fisc.nat-operacao BEGINS "5152")
              /* In¡cio SM 10102019 - incluir SAIDAS das transferˆncias interestaduais do 973 tamb‚m */
              or 
              (b-nota-fiscal.cod-estabel = "973" OR b-nota-fiscal.cod-estabel = "977")
              AND (it-nota-fisc.nat-operacao BEGINS "6156" 
                OR it-nota-fisc.nat-operacao BEGINS "6152" 
                OR it-nota-fisc.nat-operacao BEGINS "6409"
                OR it-nota-fisc.nat-operacao BEGINS "5409")
              /* Fim SM 10102019 */ 
            ):

            FOR EACH  movto-estoq NO-LOCK
                WHERE movto-estoq.serie         = b-nota-fiscal.serie 
                  AND movto-estoq.nro-docto     = b-nota-fiscal.nr-nota-fis   
                  AND movto-estoq.cod-emitente  = b-nota-fiscal.cod-emitente
                  AND movto-estoq.nat-operacao  = it-nota-fisc.nat-operacao
                  AND movto-estoq.esp-docto    >= 22 /* NFS */
                  AND movto-estoq.esp-docto    <= 23 /* NFT */
                  AND movto-estoq.tipo-trans   >= 1 
                  AND movto-estoq.tipo-trans   <= 2
                  AND movto-estoq.cod-prog-orig = "trnfssm135"
                  AND movto-estoq.cod-estabel   = b-nota-fiscal.cod-estabel:
        
                FOR each b-movto-estoq EXCLUSIVE-LOCK
                    WHERE ROWID(b-movto-estoq) = ROWID(movto-estoq):
                    DELETE b-movto-estoq.
                END.
            END.
        END.
        /* Fim SM 135 Estorno Custo Cont bil, ICMS Transf Estadual */
    END.
    /* fim cancelamento de nota */


    /* Inicio SM 135 Estorno Custo Cont bil, ICMS Transf Estadual */

        /* desatualizando nota no estoque */
        IF  b-nota-fiscal.idi-sit-nf-eletro      = 3 AND /* Uso Autorizado */
            b-nota-fiscal.dt-confirm             = ? AND
            b-old-nota-fiscal.dt-confirm        <> ? and
            b-nota-fiscal.esp-docto              = 23 /* NFT */
        THEN DO:
        
            FOR EACH   it-nota-fisc fields (nat-operacao) OF b-nota-fiscal no-lock where
                ( (it-nota-fisc.nat-operacao BEGINS "1152" or it-nota-fisc.nat-operacao BEGINS "5152")
                  /* In¡cio SM 10102019 - incluir SAIDAS das transferˆncias interestaduais do 973 tamb‚m */
                  or 
                  (b-nota-fiscal.cod-estabel = "973" OR b-nota-fiscal.cod-estabel = "977")
                  
                  AND (it-nota-fisc.nat-operacao BEGINS "6156" 
                    OR it-nota-fisc.nat-operacao BEGINS "6152" 
                    OR it-nota-fisc.nat-operacao BEGINS "6409"
                    OR it-nota-fisc.nat-operacao BEGINS "5409")
                  /* Fim SM 10102019 */ 
                ):

                FOR EACH  movto-estoq NO-LOCK
                    WHERE movto-estoq.serie         = b-nota-fiscal.serie 
                      AND movto-estoq.nro-docto     = b-nota-fiscal.nr-nota-fis   
                      AND movto-estoq.cod-emitente  = b-nota-fiscal.cod-emitente
                      AND movto-estoq.nat-operacao  = it-nota-fisc.nat-operacao
                      AND movto-estoq.esp-docto    >= 22 /* NFS */
                      AND movto-estoq.esp-docto    <= 23 /* NFT */
                      AND movto-estoq.tipo-trans   >= 1 
                      AND movto-estoq.tipo-trans   <= 2 
                      AND movto-estoq.cod-prog-orig = "trnfssm135"
                      AND movto-estoq.cod-estabel   = b-nota-fiscal.cod-estabel:
            
                    FOR each b-movto-estoq EXCLUSIVE-LOCK
                        WHERE ROWID(b-movto-estoq) = ROWID(movto-estoq):
                        DELETE b-movto-estoq.
                    END.
                END.
            END.
        END.
        
        /* atualizando nota no estoque */
        IF  b-nota-fiscal.idi-sit-nf-eletro      = 3 AND /* Uso Autorizado */
            b-nota-fiscal.dt-confirm            <> ? AND
            b-old-nota-fiscal.dt-confirm         = ? and
            b-nota-fiscal.esp-docto              = 23 /* NFT */
        THEN DO:
            ASSIGN l-erro = NO.
            DO TRANS ON ERROR UNDO, LEAVE:

                EMPTY TEMP-TABLE tt-bonificados.

                FOR EACH it-nota-fisc NO-LOCK
                    WHERE it-nota-fisc.cod-estabel = b-nota-fiscal.cod-estabel
                    AND   it-nota-fisc.serie       = b-nota-fiscal.serie      
                    AND   it-nota-fisc.nr-nota-fis = b-nota-fiscal.nr-nota-fis,
                    FIRST esp-item-nfs-st NO-LOCK
                    WHERE esp-item-nfs-st.cod-estab-nfs = it-nota-fisc.cod-estabel
                    AND   esp-item-nfs-st.cod-ser-nfs   = it-nota-fisc.serie      
                    AND   esp-item-nfs-st.cod-docto-nfs = it-nota-fisc.nr-nota-fis
                    AND   esp-item-nfs-st.num-seq-nfs   = it-nota-fisc.nr-seq-fat
                    AND   esp-item-nfs-st.cod-item      = it-nota-fisc.it-codigo,
                    FIRST ems2mult.emitente NO-LOCK
                    WHERE emitente.cod-emitente = INT(esp-item-nfs-st.cod-emitente-entr),
                    LAST int_ds_it_docto_xml NO-LOCK
                    WHERE int_ds_it_docto_xml.nnf       = esp-item-nfs-st.cod-nota-entr
                    AND   int_ds_it_docto_xml.serie     = esp-item-nfs-st.cod-ser-entr
                    AND   int_ds_it_docto_xml.cnpj      = emitente.cgc
                    AND   int_ds_it_docto_xml.sequencia = esp-item-nfs-st.num-seq-item-entr
                    AND   int_ds_it_docto_xml.it_codigo = esp-item-nfs-st.cod-item:


                    FIND FIRST b-emitente NO-LOCK
                        WHERE b-emitente.cod-emitente = b-nota-fiscal.cod-emitente NO-ERROR.

                    /* KML - Projeto Itens importados  */

                    FOR FIRST ITEM OF it-nota-fisc NO-LOCK: END.

                    IF int_ds_it_docto_xml.picms = 4 AND 
                       b-emitente.estado = "PR" THEN DO:

                        ASSIGN de-vl-importados = ((int_ds_it_docto_xml.vbc_icms / int_ds_it_docto_xml.qcom * 12 / 100) - 
                                              (int_ds_it_docto_xml.vbc_icms / int_ds_it_docto_xml.qcom * int_ds_it_docto_xml.picms / 100)) * it-nota-fisc.qt-faturada[1].
    /*                     MESSAGE "grade importados" SKIP               */
    /*                             de-vl-importados                      */
    /*                         VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */

                        FIND FIRST item-doc-est NO-LOCK
                            WHERE item-doc-est.nro-docto    = int_ds_it_docto_xml.nnf       
                              AND item-doc-est.serie-docto  = int_ds_it_docto_xml.serie     
                              AND item-doc-est.cod-emitente = emitente.cod-emitente               
                              AND item-doc-est.sequencia    = int_ds_it_docto_xml.sequencia 
                              AND item-doc-est.it-codigo    = int_ds_it_docto_xml.it_codigo NO-ERROR.

                        IF AVAIL item-doc-est THEN DO:

                            create tt-movto.
                            assign tt-movto.cod-versao-integ  = 1                              
                                   tt-movto.tipo-trans        = 2 /* Entrada */                
                                   tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel      
                                   tt-movto.serie             = b-nota-fiscal.serie            
                                   tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis      
                                   tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente     
                                   tt-movto.nat-operacao      = it-nota-fisc.nat-operacao      
                                   tt-movto.it-codigo         = it-nota-fisc.it-codigo         
                                   tt-movto.valor-mat-m[1]    = de-vl-importados
                                   tt-movto.conta-contabil    = "11205016"
                                   tt-movto.ct-codigo         = "11205016"
                                   tt-movto.un                = item.un
                                   tt-movto.sc-codigo         = ""
                                   tt-movto.esp-docto         = 21 /* NFT */
                                   tt-movto.conta-db          = if item.tipo-contr = 1 then item.ct-codigo else ""
                                   tt-movto.ct-db             = if item.tipo-contr = 1 then item.ct-codigo else ""
                                   tt-movto.sc-db             = if item.tipo-contr = 1 then item.sc-codigo else ""
                                   tt-movto.cod-prog-orig     = "trnfesm135"
                                   tt-movto.cod-depos         = IF b-nota-fiscal.cod-estabel = "973" THEN "973" ELSE IF b-nota-fiscal.cod-estabel = "977" THEN "977" ELSE "LOJ"
                                   tt-movto.dt-trans          = b-nota-fiscal.dt-emis-nota
                                   .

                               RUN cep/ceapi001.p (INPUT-OUTPUT TABLE tt-movto,
                               INPUT-OUTPUT TABLE tt-erro,
                               INPUT NO).
        
                               IF CAN-FIND (FIRST tt-erro)
                               THEN DO:
           /*                                                                           */
           /*                         FOR EACH tt-erro:                                 */
           /*                             MESSAGE "4 deu erro" SKIP                     */
           /*                                     tt-erro.cd-erro SKIP                  */
           /*                                     tt-erro.mensagem                      */
           /*                                 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
           /*                         END.                                              */
                                   ASSIGN l-erro = YES.
                                   UNDO, LEAVE.
                               END.


                        END.

                    END.

                    empty temp-table tt-erro.
                    empty temp-table tt-movto.
                    /* KML - FIM Projeto Itens importados  */

                     /* KML - Projeto Bonifica‡Æo  */

    /*                 MESSAGE "it-nota-fisc.it-codigo  - " it-nota-fisc.it-codigo  SKIP               */
    /*                         "int_ds_it_docto_xml.nat_operacao = "  int_ds_it_docto_xml.nat_operacao */
    /*                     VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                                   */
    /*                                                                                                 */

                    FIND FIRST int_ds_natur_oper NO-LOCK
                        WHERE int_ds_natur_oper.log_bonificacao = YES
                          AND INT_ds_natur_oper.nat_operacao    = int_ds_it_docto_xml.nat_operacao  NO-ERROR.

                    IF AVAIL int_ds_natur_oper THEN DO:


                        FIND FIRST item-doc-est NO-LOCK
                            WHERE item-doc-est.nro-docto    = int_ds_it_docto_xml.nnf       
                              AND item-doc-est.serie-docto  = int_ds_it_docto_xml.serie     
                              AND item-doc-est.cod-emitente = emitente.cod-emitente               
                              AND item-doc-est.sequencia    = int_ds_it_docto_xml.sequencia 
                              AND item-doc-est.it-codigo    = int_ds_it_docto_xml.it_codigo NO-ERROR.

                        IF AVAIL item-doc-est THEN DO:

                            /*ASSIGN de-vl-bonificacao = ((item-doc-est.preco-total[1] + item-doc-est.despesas[1] - item-doc-est.desconto[1]  - item-doc-est.valor-icm[1]
                                                         - item-doc-est.valor-pis - item-doc-est.val-cofins) / item-doc-est.quantidade * it-nota-fisc.qt-faturada[1] )  - it-nota-fisc.vl-icms-it.*/

                            // KML - 21/03/2023 - alterado redu‡Æo e icms pr¢prio que estava buscando da nota de entrada porem o correto era da nota de saida.

                            ASSIGN de-vl-bonificacao = ROUND(((item-doc-est.preco-total[1] + item-doc-est.despesas[1] - item-doc-est.desconto[1] )
                                                         / item-doc-est.quantidade * it-nota-fisc.qt-faturada[1] ),2) - it-nota-fisc.vl-icms-it.

    /*                         MESSAGE "3 - it-nota-fisc.it-codigo  - " it-nota-fisc.it-codigo  SKIP                */
    /*                                 "int_ds_it_docto_xml.nat_operacao = "  int_ds_it_docto_xml.nat_operacao SKIP */
    /*                                 "item-doc-est.preco-total[1] - " item-doc-est.preco-total[1] SKIP            */
    /*                                 "item-doc-est.despesas[1] - " item-doc-est.despesas[1] SKIP                  */
    /*                                 "item-doc-est.desconto[1] - " item-doc-est.desconto[1] SKIP                  */
    /*                                 "item-doc-est.valor-icm[1] - " item-doc-est.valor-icm[1] SKIP                */
    /*                                 "it-nota-fisc.vl-icms-it - " it-nota-fisc.vl-icms-it SKIP                    */
    /*                                 "de-vl-bonificacao - " de-vl-bonificacao                                     */
    /*                              VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                                       */
    
                            FIND FIRST movto-estoq NO-LOCK 
                                WHERE movto-estoq.cod-estabel       = b-nota-fiscal.cod-estabel
                                  AND movto-estoq.serie-docto       = b-nota-fiscal.serie
                                  AND movto-estoq.cod-emitente      = b-nota-fiscal.cod-emitente 
                                  AND movto-estoq.nro-docto         = b-nota-fiscal.nr-nota-fis
                                  AND movto-estoq.it-codigo         = it-nota-fisc.it-codigo 
                                  AND movto-estoq.nat-operacao      = it-nota-fisc.nat-operacao 
                                  AND movto-estoq.ct-codigo         = "11205017" 
                                  AND movto-estoq.valor-mat-m[1]    = de-vl-bonificacao NO-ERROR.  
                                  
                            IF NOT AVAIL movto-estoq THEN
                            DO:                                  
                                create tt-movto.
                                assign tt-movto.cod-versao-integ  = 1                              
                                       tt-movto.tipo-trans        = 1 /* Entrada */                
                                       tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel      
                                       tt-movto.serie             = b-nota-fiscal.serie            
                                       tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis      
                                       tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente     
                                       tt-movto.nat-operacao      = it-nota-fisc.nat-operacao      
                                       tt-movto.it-codigo         = it-nota-fisc.it-codigo         
                                       tt-movto.valor-mat-m[1]    = de-vl-bonificacao
                                       tt-movto.conta-contabil    = "11205017"
                                       tt-movto.ct-codigo         = "11205017"
                                       tt-movto.un                = item.un
                                       tt-movto.sc-codigo         = ""
                                       tt-movto.esp-docto         = 23 /* NFT */
                                       tt-movto.conta-db          = if item.tipo-contr = 1 then item.ct-codigo else ""
                                       tt-movto.ct-db             = if item.tipo-contr = 1 then item.ct-codigo else ""
                                       tt-movto.sc-db             = if item.tipo-contr = 1 then item.sc-codigo else ""
                                       tt-movto.cod-prog-orig     = "trnfesm135"
                                       tt-movto.cod-depos         = IF b-nota-fiscal.cod-estabel = "973" THEN "973" ELSE IF b-nota-fiscal.cod-estabel = "977" THEN "977" ELSE "LOJ" //IF b-nota-fiscal.cod-estabel = "973" THEN "973" ELSE "977"
                                       tt-movto.dt-trans          = b-nota-fiscal.dt-emis-nota
                                       .

                                FIND FIRST tt-bonificados 
                                    WHERE tt-bonificados.it-codigo = it-nota-fisc.it-codigo    
                                      AND tt-bonificados.sequencia = it-nota-fisc.nr-seq-fat NO-ERROR.

                                IF NOT AVAIL tt-bonificados  THEN
                                    CREATE tt-bonificados.
                                    ASSIGN tt-bonificados.it-codigo = it-nota-fisc.it-codigo 
                                           tt-bonificados.sequencia = it-nota-fisc.nr-seq-fat. 

                                RUN cep/ceapi001.p (INPUT-OUTPUT TABLE tt-movto,
                                INPUT-OUTPUT TABLE tt-erro,
                                INPUT NO).

                                IF CAN-FIND (FIRST tt-erro)
                                THEN DO:

                                    FOR EACH tt-erro:
                                        MESSAGE "3 deu erro" SKIP
                                                tt-erro.cd-erro SKIP
                                                tt-erro.mensagem
                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                    END.
                                    ASSIGN l-erro = YES.
                                    UNDO, LEAVE.
                                END.
                            END.
                        END.


                    END.

               

                     /* KML - Fim projeto bonifica‡Æo */

                    IF int_ds_it_docto_xml.cst_icms = 60 THEN DO:

                        empty temp-table tt-erro.
                        empty temp-table tt-movto.

                        /*FOR FIRST ped-curva NO-LOCK
                            WHERE ped-curva.vl-aberto = 987654321
                            AND   ped-curva.codigo    = 123: */

                            FIND first ITEM no-lock
                                WHERE item.it-codigo = it-nota-fisc.it-codigo no-error.
                    
                            // Inicio - Altera‡Æo Regime Especial CST60 - 30/08
                            IF it-nota-fisc.vl-icms-it > 0 THEN DO:
                            
                               FIND FIRST movto-estoq NO-LOCK 
                                    WHERE movto-estoq.cod-estabel     = b-nota-fiscal.cod-estabel
                                      AND movto-estoq.serie-docto     = b-nota-fiscal.serie
                                      AND movto-estoq.cod-emitente    = b-nota-fiscal.cod-emitente
                                      AND movto-estoq.nro-docto       = b-nota-fiscal.nr-nota-fis
                                      AND movto-estoq.it-codigo       = it-nota-fisc.it-codigo
                                      AND movto-estoq.nat-operacao    = it-nota-fisc.nat-operacao
                                      AND movto-estoq.ct-codigo       = "11205016" 
                                      AND movto-estoq.valor-mat-m[1]  = it-nota-fisc.vl-icms-it NO-ERROR.                            

                                IF NOT AVAIL movto-estoq THEN DO:      
                                
                                    create tt-movto.
                                    assign tt-movto.cod-versao-integ  = 1
                                           tt-movto.tipo-trans        = 2 /* Saida */
                                           tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel
                                           tt-movto.serie             = b-nota-fiscal.serie
                                           tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis
                                           tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente
                                           tt-movto.nat-operacao      = it-nota-fisc.nat-operacao
                                           tt-movto.it-codigo         = it-nota-fisc.it-codigo
                                           tt-movto.valor-mat-m[1]    = it-nota-fisc.vl-icms-it
                                           tt-movto.ct-codigo         = "11205016". 
                                END.          
                            END.

                            // Fim - Altera‡Æo Regime Especial CST60 - 30/08

                            create tt-movto.
                            assign tt-movto.cod-versao-integ  = 1
                                   tt-movto.tipo-trans        = 1 /* Entrada */
                                   tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel
                                   tt-movto.serie             = b-nota-fiscal.serie
                                   tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis
                                   tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente
                                   tt-movto.nat-operacao      = it-nota-fisc.nat-operacao
                                   tt-movto.it-codigo         = it-nota-fisc.it-codigo
                                   tt-movto.valor-mat-m[1]    = 0
                                   tt-movto.ct-codigo         = "11205016".

                            IF int_ds_it_docto_xml.vicmsstret <> ? AND int_ds_it_docto_xml.vicmsstret > 0 THEN ASSIGN tt-movto.valor-mat-m[1] = tt-movto.valor-mat-m[1] + int_ds_it_docto_xml.vicmsstret.
                            IF int_ds_it_docto_xml.vICMSSubs <> ?  AND int_ds_it_docto_xml.vICMSSubs > 0  THEN ASSIGN tt-movto.valor-mat-m[1] = tt-movto.valor-mat-m[1] + int_ds_it_docto_xml.vICMSSubs.
        
                            ASSIGN tt-movto.valor-mat-m[1]  = (tt-movto.valor-mat-m[1] / int_ds_it_docto_xml.qCom) * it-nota-fisc.qt-faturada[1].
                            
                            IF tt-movto.valor-mat-m[1] = ? OR tt-movto.valor-mat-m[1] < 0 THEN DELETE tt-movto.

                            IF CAN-FIND(FIRST tt-movto) THEN DO:
                                for each tt-movto:
                                    assign  tt-movto.quantidade        = 0
                                            tt-movto.valor-nota        = 0
                                            tt-movto.valor-icm         = 0
                                            tt-movto.valor-ipi         = 0 
                                            tt-movto.valor-mob-p[1]    = 0       
                                            tt-movto.valor-ggf-p[1]    = 0    
                                            tt-movto.conta-contabil    = ""  
                                            tt-movto.sc-codigo         = "" 
                                            tt-movto.esp-docto         = 23 /* NFT */
                                            tt-movto.cod-prog-orig     = "trnfssm135"
                                            tt-movto.dt-trans          = b-nota-fiscal.dt-emis-nota
                                            tt-movto.un                = ITEM.un.
                                   
                                   /*ALTERA€ÇO DEVIDO SOLICITA€ÇO CHAMADO 0226-010367 */
                                   if b-nota-fiscal.cod-estabel = "973" then 
                                        
                                        assign tt-movto.cod-depos = "973".
                                        
                                    ELSE IF  b-nota-fiscal.cod-estabel = "977"  THEN
                                    
                                        assign tt-movto.cod-depos = "977".

                                    else 
                                        assign tt-movto.cod-depos = "LOJ".
                                end.
                               
                               /* Fim SM 10102019 */ 

                                RUN cep/ceapi001.p (INPUT-OUTPUT TABLE tt-movto,
                                                    INPUT-OUTPUT TABLE tt-erro,
                                                    INPUT NO).
            
                                IF CAN-FIND (FIRST tt-erro)
                                THEN DO:
                                    ASSIGN l-erro = YES.
                                    UNDO, LEAVE.
                                END.
                            END.
                        //END.
                    END.
                END.
        
                FOR FIRST estabelec fields (ct-icms-ft log-livre-1) NO-LOCK
                    WHERE estabelec.cod-estabel = b-nota-fiscal.cod-estabel: END.
        
                FOR EACH it-nota-fisc fields (cd-trib-icm 
                                              nat-operacao 
                                              it-codigo 
                                              nr-seq-fat 
                                              vl-icms-it 
                                              vl-icmsub-it 
                                              qt-faturada[1]
                                              vl-merc-liq) OF b-nota-fiscal NO-LOCK
                    WHERE  ( (it-nota-fisc.nat-operacao BEGINS "1152" or it-nota-fisc.nat-operacao BEGINS "5152")
                          /* In¡cio SM 10102019 - incluir SAIDAS das transferˆncias interestaduais do 973 tamb‚m */
                          or 
                          (b-nota-fiscal.cod-estabel = "973" OR b-nota-fiscal.cod-estabel = "977") 
                           AND (it-nota-fisc.nat-operacao BEGINS "6156" 
                            OR  it-nota-fisc.nat-operacao BEGINS "6152" 
                            OR  it-nota-fisc.nat-operacao BEGINS "6409"
                            OR  it-nota-fisc.nat-operacao BEGINS "5409")
                          /* Fim SM 10102019 */ 
                        ):
                    
                    for first item fields (it-codigo un char-2) OF it-nota-fisc no-lock: end.
                    empty temp-table tt-erro.
                    empty temp-table tt-movto.

                    /* In¡cio SM 10102019 - incluir SAIDAS das transferˆncias interestaduais do 973 tamb‚m */
                    /* Estorno ICMS Estadual */
                    if it-nota-fisc.vl-icms-it  > 0 and
                      (it-nota-fisc.cd-trib-icm = 1   /* Tributado */ or it-nota-fisc.cd-trib-icm = 4)  /* Reduzido  */ and
                      (it-nota-fisc.nat-operacao BEGINS "1152" or it-nota-fisc.nat-operacao BEGINS "5152")
                    then do:
                        create tt-movto.
                        assign tt-movto.cod-versao-integ  = 1
                               tt-movto.tipo-trans        = 2 /* Sa¡da */
                               tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel
                               tt-movto.serie             = b-nota-fiscal.serie
                               tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis
                               tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente
                               tt-movto.nat-operacao      = it-nota-fisc.nat-operacao
                               tt-movto.it-codigo         = it-nota-fisc.it-codigo
                               tt-movto.valor-mat-m[1]    = it-nota-fisc.vl-icms-it
                               tt-movto.ct-codigo         = estabelec.ct-icms-ft.
                    end.
                    
                    /* Estornos Opera‡Æo Interestadual */
                    
                    if (b-nota-fiscal.cod-estabel = "973" OR b-nota-fiscal.cod-estabel = "977")
                    AND 
                       (it-nota-fisc.nat-operacao      = "5409a5" OR
                        it-nota-fisc.nat-operacao      = "5409s5" OR
                        it-nota-fisc.nat-operacao BEGINS "6156"   OR
                        it-nota-fisc.nat-operacao BEGINS "6152"   OR 
                        it-nota-fisc.nat-operacao BEGINS "6409") then do:

                        /* buscar ST/ICMS da entrada */
                        de-st-entrada = 0.
                        de-icm-entrada = 0.
                        for last movto-estoq fields (nro-docto
                                                     serie-docto
                                                     cod-emitente
                                                     sequen-nf
                                                     it-codigo
                                                     valor-icm
                                                     quantidade) 
                            no-lock where 
                            movto-estoq.dt-trans    < b-nota-fiscal.dt-emis-nota and 
                            movto-estoq.esp-docto   = 21 and 
                            movto-estoq.cod-estabel = b-nota-fiscal.cod-estabel and 
                            movto-estoq.it-codigo   = it-nota-fisc.it-codigo and
                            movto-estoq.ct-codigo   = "91103005" and
                            movto-estoq.quantidade  > 0,
                            first natur-oper fields (transf) no-lock of movto-estoq where natur-oper.transf = no:

                            /*de-icm-entrada = (movto-estoq.valor-icm / movto-estoq.quantidade) * it-nota-fisc.qt-faturada[1].*/
                            for each item-doc-est fields (vl-subs[1] quantidade valor-icm[1]) no-lock where 
                                item-doc-est.nro-docto      = movto-estoq.nro-docto and
                                item-doc-est.serie-docto    = movto-estoq.serie-docto and
                                item-doc-est.cod-emitente   = movto-estoq.cod-emitente and
                                item-doc-est.sequencia      = movto-estoq.sequen-nf and
                                item-doc-est.it-codigo      = movto-estoq.it-codigo:
                                de-st-entrada  = (item-doc-est.vl-subs[1] / item-doc-est.quantidade) * it-nota-fisc.qt-faturada[1].
                                if de-icm-entrada = 0 then
                                    de-icm-entrada = (item-doc-est.valor-icm[1] / item-doc-est.quantidade) * it-nota-fisc.qt-faturada[1].
                            end.
                        end.

                        /***** Retirada pelo projeto Altera‡Æo Custos ICMSST 
                        /* Retirar ICMS ST Utilizando valor da £ltima nota de compra */
                        if de-st-entrada > 0 and it-nota-fisc.vl-icmsub-it > 0 then do:

                            create tt-movto.
                            assign tt-movto.cod-versao-integ  = 1
                                   tt-movto.tipo-trans        = 2 /* Sa¡da */
                                   tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel
                                   tt-movto.serie             = b-nota-fiscal.serie
                                   tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis
                                   tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente
                                   tt-movto.nat-operacao      = it-nota-fisc.nat-operacao
                                   tt-movto.it-codigo         = it-nota-fisc.it-codigo
                                   tt-movto.valor-mat-m[1]    = de-st-entrada 
                                   tt-movto.ct-codigo         = /*estabelec.ct-icmsub-ft.*/ "11204004".
                        end.

                        /* Estorno ICMS interestadual se Compra teve ICMS ST e sa¡da tem ICMS Pr¢prio */
                        if /*de-icm-entrada > 0 and*/ (de-st-entrada > 0 and it-nota-fisc.vl-icms-it > 0) or
                        /* Estorno ICMS interestadual se Compra NAO teve ICMS ST NEM ICMS Proprio e sa¡da tem ICMS Pr¢prio */
                            (de-st-entrada = 0 and de-icm-entrada = 0 and it-nota-fisc.vl-icms-it > 0)  then do:

                            create tt-movto.
                            assign tt-movto.cod-versao-integ  = 1
                                   tt-movto.tipo-trans        = 2 /* Sa¡da */
                                   tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel
                                   tt-movto.serie             = b-nota-fiscal.serie
                                   tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis
                                   tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente
                                   tt-movto.nat-operacao      = it-nota-fisc.nat-operacao
                                   tt-movto.it-codigo         = it-nota-fisc.it-codigo
                                   tt-movto.valor-mat-m[1]    = it-nota-fisc.vl-icms-it
                                   tt-movto.ct-codigo         = estabelec.ct-icms-ft.

                            /* Acerta conta interestadual caso tenha ou nÆo ST na entrada */
                            if (de-st-entrada > 0 and estabelec.log-livre-1 = yes) or
                               (de-st-entrada = 0 and de-icm-entrada = 0 and it-nota-fisc.vl-icms-it > 0) then do:
                                for last estab-ctas-impto no-lock where
                                    estab-ctas-impto.cod-estab       = b-nota-fiscal.cod-estabel  and
                                    estab-ctas-impto.dat-inic-valid <= b-nota-fiscal.dt-emis-nota and
                                    estab-ctas-impto.dat-fim-valid  >= b-nota-fiscal.dt-emis-nota and
                                    estab-ctas-impto.num-impto       = 1 /* ICMS */:
                                    assign tt-movto.ct-codigo = estab-ctas-impto.conta-imposto.
                                end.
                            end.
                            /*
                            else do:
                                assign tt-movto.ct-codigo  = "11205016"
                                       tt-movto.tipo-trans = 1 /* Entrada */.
                            end.
                            */
                        end.
                        ************************************************************************************/

    /*                     IF it-nota-fisc.it-codigo = "30069" THEN DO:          */
    /*                                                                           */
    /*                         FOR EACH tt-bonificados:                          */
    /*                             MESSAGE "dentro da tabela"                    */
    /*                                     tt-bonificados.it-codigo SKIP         */
    /*                                     tt-bonificados.sequencia              */
    /*                                 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
    /*                                                                           */
    /*                         END.                                              */
    /*                         RELEASE tt-bonificados.                           */
    /*                     END.                                                  */

                        FIND FIRST tt-bonificados 
                            WHERE tt-bonificados.it-codigo  = it-nota-fisc.it-codigo
                              AND tt-bonificados.sequencia  = it-nota-fisc.nr-seq-fat NO-ERROR.
    /*                                                                                         */
    /*                     IF it-nota-fisc.it-codigo = "30069" THEN                            */
    /*                         MESSAGE "AVAIL tt-bonificados - " AVAIL tt-bonificados skip     */
    /*                                 "it-nota-fisc.it-codigo - " it-nota-fisc.it-codigo SKIP */
    /*                                 "it-nota-fisc.nr-seq-fat - " it-nota-fisc.nr-seq-fat    */
    /*                             VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                   */

                        IF NOT AVAIL tt-bonificados  THEN DO:
    /*                                                                           */
    /*                         IF it-nota-fisc.it-codigo = "30069" THEN          */
    /*                             MESSAGE "NAO ACHOU BONIFICADO"                */
    /*                                     it-nota-fisc.it-codigo  SKIP          */
    /*                                     it-nota-fisc.nr-seq-fat               */
    /*                                 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
                        
                            /* Retirar PIS */
                            if dec(substr(item.char-2,31,5)) /* PIS */ > 0 then do:
        
                                create tt-movto.
                                assign tt-movto.cod-versao-integ  = 1
                                       tt-movto.tipo-trans        = 1 /* Entrada */
                                       tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel
                                       tt-movto.serie             = b-nota-fiscal.serie
                                       tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis
                                       tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente
                                       tt-movto.nat-operacao      = it-nota-fisc.nat-operacao
                                       tt-movto.it-codigo         = it-nota-fisc.it-codigo
                                       tt-movto.valor-mat-m[1]    = dec(substr(item.char-2,31,5)) * it-nota-fisc.vl-merc-liq / 100
                                       tt-movto.ct-codigo         = /*estabelec.ct-icmsub-ft.*/ "11205016".
                            end.
        
                            /* Retirar COFINS */
                            if dec(substr(item.char-2,36,5)) /* COFINS */ > 0 then do:

                                create tt-movto.
                                assign tt-movto.cod-versao-integ  = 1
                                       tt-movto.tipo-trans        = 1 /* Entrada */
                                       tt-movto.cod-estabel       = b-nota-fiscal.cod-estabel
                                       tt-movto.serie             = b-nota-fiscal.serie
                                       tt-movto.nro-docto         = b-nota-fiscal.nr-nota-fis
                                       tt-movto.cod-emitente      = b-nota-fiscal.cod-emitente
                                       tt-movto.nat-operacao      = it-nota-fisc.nat-operacao
                                       tt-movto.it-codigo         = it-nota-fisc.it-codigo
                                       tt-movto.valor-mat-m[1]    = dec(substr(item.char-2,36,5)) * it-nota-fisc.vl-merc-liq / 100
                                       tt-movto.ct-codigo         = /*estabelec.ct-icmsub-ft.*/ "11205016".
        
                            end.
                        end. /* it-nota-fisc.nat-operacao begins 2115...Estornos Opera‡Æo Interestadual */
                    END.
                    if can-find(first tt-movto) then do:
                        for each tt-movto:
                            assign  tt-movto.quantidade        = 0
                                    tt-movto.valor-nota        = 0
                                    tt-movto.valor-icm         = 0
                                    tt-movto.valor-ipi         = 0 
                                    tt-movto.valor-mob-p[1]    = 0       
                                    tt-movto.valor-ggf-p[1]    = 0    
                                    tt-movto.conta-contabil    = ""  
                                    tt-movto.sc-codigo         = "" 
                                    tt-movto.esp-docto         = 23 /* NFT */
                                    tt-movto.cod-prog-orig     = "trnfssm135"
                                    tt-movto.dt-trans          = b-nota-fiscal.dt-emis-nota
                                    tt-movto.un                = ITEM.un.
                                    
                             /*ALTERA€ÇO DEVIDO SOLICITA€ÇO CHAMADO 0226-010367 */       
                            if b-nota-fiscal.cod-estabel = "973" then 
                                assign tt-movto.cod-depos = "973".
                                
                            ELSE IF b-nota-fiscal.cod-estabel = "977" THEN
                            
                                ASSIGN tt-movto.cod-depos = "977".

                            else 
                                assign tt-movto.cod-depos = "LOJ".
                        end.
                        /* Fim SM 10102019 */ 

                        RUN cep/ceapi001.p (INPUT-OUTPUT TABLE tt-movto,
                                            INPUT-OUTPUT TABLE tt-erro,
                                            INPUT NO).

                        IF CAN-FIND (FIRST tt-erro)
                        THEN DO:
                            ASSIGN l-erro = YES.
                            UNDO, LEAVE.
                        END.
                    end.
                END. /* FOR EACH it-nota-fisc OF b-nota-fiscal NO-LOCK, */
            END. /* DO TRANS ON ERROR UNDO, LEAVE: */
            EMPTY TEMP-TABLE tt-erro.
            EMPTY TEMP-TABLE tt-movto.
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
        FOR FIRST int_ds_pedido  NO-LOCK 
            WHERE int_ds_pedido.ped_codigo_n = int64(b-nota-fiscal.nr-pedcli):
            

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

    /* incluir nota no controle de calculo de preco base */
    def var i-hora as integer no-undo.
    if b-nota-fiscal.dt-confirma <> b-old-nota-fiscal.dt-confirma and
      (b-nota-fiscal.esp-docto = 23 /* NFT */ or b-nota-fiscal.esp-docto = 20 /* NFD */) and 
       b-nota-fiscal.cod-estabel = c-estabel //"977 OU 973" RETIRADO ESTABELECIMENTO FIXO
    then do transaction:

        assign i-hora = time.
        for first cst_nota_fiscal_custo no-lock where 
            cst_nota_fiscal_custo.serie        = b-nota-fiscal.serie       and
            cst_nota_fiscal_custo.nr_nota_fis  = b-nota-fiscal.nr-nota-fis and
            cst_nota_fiscal_custo.cod_estabel  = b-nota-fiscal.cod-estabel and
            cst_nota_fiscal_custo.dt_geracao   = today                     and
            cst_nota_fiscal_custo.tipo_movto  >= 1                         and
            cst_nota_fiscal_custo.i_hr_geracao = i-hora:                   end.    
        if not avail cst_nota_fiscal_custo then do:

            create  cst_nota_fiscal_custo.
            assign  cst_nota_fiscal_custo.serie        = b-nota-fiscal.serie       
                    cst_nota_fiscal_custo.nr_nota_fis  = b-nota-fiscal.nr-nota-fis 
                    cst_nota_fiscal_custo.cod_estabel  = b-nota-fiscal.cod-estabel 
                    cst_nota_fiscal_custo.dt_geracao   = today                     
                    cst_nota_fiscal_custo.tipo_movto   = if b-nota-fiscal.dt-confirma <> ? then 1 else 2
                    cst_nota_fiscal_custo.i_hr_geracao = i-hora
                    cst_nota_fiscal_custo.hr_geracao   = string(time,"HH:MM:SS").


        end.
        
        release cst_nota_fiscal_custo.
    end.
    
    /* FiM incluir nota no controle de calculo de preco base */
    
END.
RETURN "OK".
