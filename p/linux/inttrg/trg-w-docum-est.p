 /****************************************************************************************************
**   Programa: trg-w-docum-est.p - Trigger de write para a tabela docum-est
**   Objetivo: Ao atualizar nota de entrada , atualizar tabela int_ds_doc para calculo do CMV      
**   Data....: Maio/2016
*****************************************************************************************************/
DEF PARAM BUFFER b-docum-est     FOR docum-est.
DEF PARAM BUFFER b-old-docum-est FOR docum-est.
   
DEF TEMP-TABLE tt-balanco NO-UNDO
FIELD ped-tipopedido-n LIKE int_ds_pedido.ped_tipopedido_n.

DEF VAR i-ndd         LIKE ndd_entryIntegration.entryintegrationId.
DEF VAR c-nr-pedcli   LIKE nota-fiscal.nr-pedcli NO-UNDO.

DEFINE VARIABLE l-erro           AS LOGICAL     NO-UNDO.
DEFINE VARIABLE de-valor-ult-ent AS DECIMAL     NO-UNDO.
DEFINE VARIABLE da-valor-ult-ent AS DATE        NO-UNDO.
DEFINE VARIABLE c-conta-icm      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE h-boin879        AS HANDLE      NO-UNDO.

DEF BUFFER b-movto-estoq FOR movto-estoq.

{utp/ut-glob.i}
{cep/ceapi001.i}    /* Definicao de temp-table do movto-estoq */
{cdp/cd0666.i}      /* Definicao da temp-table de erros */

/* alterar chave do documento quando gera nota no faturamento e demais campos de controle para evitar faturamento duplicado */
if b-old-docum-est.nro-docto <> "" AND 
   b-old-docum-est.nro-docto <> b-docum-est.nro-docto then do:
    for each cst_fat_devol WHERE
             cst_fat_devol.cod_estabel  = b-old-docum-est.cod-estabel  AND
             cst_fat_devol.serie_docto  = b-old-docum-est.serie-docto  AND
             cst_fat_devol.nro_docto    = b-old-docum-est.nro-docto    AND
             cst_fat_devol.cod_emitente = b-old-docum-est.cod-emitente AND 
             cst_fat_devol.nat_operacao = b-old-docum-est.nat-operacao query-tuning(no-lookahead):
        assign cst_fat_devol.nro_docto   = b-docum-est.nro-docto
               cst_fat_devol.serie_docto = b-docum-est.serie-docto.
    end.
    for each nota-fiscal exclusive-lock where 
        nota-fiscal.cod-estabel = b-docum-est.nro-docto     and
        nota-fiscal.serie       = b-docum-est.serie-docto   and
        nota-fiscal.nr-nota-fis = b-docum-est.nro-docto:
        if nota-fiscal.nr-pedcli = "" then do:
            for each it-nota-fisc fields (nr-pedcli)
                no-lock of nota-fiscal where it-nota-fisc.nr-pedcli <> "":
                assign nota-fiscal.nr-pedcli = it-nota-fisc.nr-pedcli.
                leave.
            end.
            if nota-fiscal.nr-pedcli = "" then do:
                for each item-doc-est fields (nr-pedcli) no-lock of b-docum-est where item-doc-est.nr-pedcli <> "":
                    assign nota-fiscal.nr-pedcli = item-doc-est.nr-pedcli.
                    leave.
                end.
                for each it-nota-fisc of nota-fiscal exclusive-lock:
                    assign it-nota-fisc.nr-pedcli = nota-fiscal.nr-pedcli.
                end.
            end.
        end.
        assign  nota-fiscal.serie-orig      = b-old-docum-est.serie-docto
                nota-fiscal.nro-nota-orig   = b-old-docum-est.nro-docto.
    end.
end.

/* 07/07/2017 - Inicio Atualizaá∆o Conta Transit¢ria Bonificaá∆o */
IF  b-docum-est.ce-atual = NO
THEN DO:
    FOR FIRST int_ds_natur_oper NO-LOCK
        WHERE int_ds_natur_oper.nat_operacao = b-docum-est.nat-operacao:
    
        IF  int_ds_natur_oper.log_bonificacao              = YES AND
            int_ds_natur_oper.cod_cta_transit_bonificacao <> ""  AND
            int_ds_natur_oper.cod_cta_transit_bonificacao <> b-docum-est.ct-transit
        THEN
            ASSIGN b-docum-est.ct-transit = int_ds_natur_oper.cod_cta_transit_bonificacao.
    END.
END.
/* 07/07/2017 - Inicio Atualizaá∆o Conta Transit¢ria Bonificaá∆o */

IF b-old-docum-est.ce-atual = NO AND 
   b-docum-est.ce-atual     = YES    
THEN DO:
    /* 19/04/2017 - Inicio Gerar integraá∆o notas estorno */
    FOR FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = b-docum-est.nat-operacao:

        IF  SUBSTRING(natur-oper.char-1,159,1) = "S" /* Nfe de Estorno */
        THEN DO:
            FIND emitente NO-LOCK
                WHERE emitente.cod-emitente = b-docum-est.cod-emitente NO-ERROR.

            FIND estabelec NO-LOCK
                WHERE estabelec.cod-estabel = b-docum-est.cod-estabel NO-ERROR.

            IF  NUM-ENTRIES(b-docum-est.observacao,"[") > 1
            THEN
                ASSIGN c-nr-pedcli = TRIM(ENTRY(2,b-docum-est.observacao,"[")).

            FOR FIRST nota-fiscal EXCLUSIVE-LOCK
                WHERE nota-fiscal.cod-estabel = b-docum-est.cod-estabel
                  AND nota-fiscal.serie       = estabelec.serie
                  AND nota-fiscal.nr-nota-fis = b-docum-est.nro-docto:
    
                IF  b-docum-est.cod-estabel <> "973"
                THEN
                    RUN pi-int_ds_nota_entrada.
                ELSE DO:
                    RUN pi-int_ds_docto_xml.
                    RUN pi-int_ds_docto_wms(10).
                END.
                if c-nr-pedcli <> "" and nota-fiscal.nr-pedcli = "" then do:
                    FOR EACH it-nota-fisc OF nota-fiscal EXCLUSIVE-LOCK:
                        ASSIGN it-nota-fisc.nr-pedcli = c-nr-pedcli.
                        RELEASE it-nota-fisc.
                    END.
                    ASSIGN nota-fiscal.nr-pedcli = c-nr-pedcli.
                END.
                RELEASE nota-fiscal.
            end.
            IF  c-nr-pedcli <> ""
            THEN DO:
                ASSIGN b-docum-est.observacao = REPLACE(b-docum-est.observacao,"[",":").
            END.
        END.
    END.
    /* 19/04/2017 - Fim Gerar integraá∆o notas estorno */




   /* RUN pi-atualiza-doc ( INPUT 1,   /* Atualiza */
                         INPUT "").   
      */

   /**** Atualiza registro para atualizar a nota pelo int500 
   
   IF INDEX(b-docum-est.obs,"Pedido Balan") > 0 
   THEN DO:
        FOR LAST ndd_entryIntegration BY ndd_entryIntegration.entryintegrationId:
    
           ASSIGN i-ndd = ndd_entryIntegration.entryintegrationId + 1.
             
        END.
    
        FOR FIRST nota-fiscal NO-LOCK WHERE
                  nota-fiscal.cod-estabel      = b-docum-est.cod-estabel AND 
                  nota-fiscal.serie            = b-docum-est.serie    AND
              int(nota-fiscal.nr-nota-fis) = int(b-docum-est.nro-docto),
               FIRST natur-oper WHERE
                     natur-oper.nat-operacao = nota-fiscal.nat-operacao AND 
                     natur-oper.tipo         = 1  : /* Entrada */ 
                   
                   FOR FIRST int-ndd-envio WHERE
                             int-ndd-envio.cod-estabel = b-docum-est.cod-estabel    AND 
                             int(int-ndd-envio.nr-nota-fis) = int(b-docum-est.nro-docto) AND 
                             int-ndd-envio.serie       = b-docum-est.serie , 
                        FIRST estabelec NO-LOCK WHERE
                              estabelec.cod-estabel = int-ndd-envio.cod-estabel: 
                        
                        CREATE ndd_entryIntegration.
                        ASSIGN ndd_entryIntegration.entryintegrationId = i-ndd
                               ndd_entryIntegration.Kind               = 0 
                               ndd_entryIntegration.STATUS_            = 0
                               NDD_ENTRYINTEGRATION.CNPJDEST           = dec(estabelec.cgc)
                               NDD_ENTRYINTEGRATION.CNPJEMIT           = dec(estabelec.cgc)
                               NDD_ENTRYINTEGRATION.DOCUMENTDATA       = int-ndd-envio.documentdata
                               NDD_ENTRYINTEGRATION.DOCUMENTNUMBER     = int(int-ndd-envio.nr-nota-fis)
                               NDD_ENTRYINTEGRATION.EMISSIONDATE       = int-ndd-envio.dt-envio
                               NDD_ENTRYINTEGRATION.SERIE              = int(int-ndd-envio.serie).  
        
                       RELEASE NDD_ENTRYINTEGRATION.
                                
                   END.  
        
        END. 
   END.
   */


/*    /* 27/06/2017 - Hoepers - Inicio alerta nota com chave em branco   */ */
/*    /* Este bloco ser† removido assim que descobrirmos onde est†  erro */ */
/*                                                                          */
/*     IF  b-docum-est.cod-chave-aces-nf-eletro = ""                        */
/*     THEN DO:                                                             */
/*         FOR FIRST emitente NO-LOCK                                       */
/*             WHERE emitente.cod-emitente = b-docum-est.cod-emitente:      */
/*                                                                          */
/*             IF  emitente.cgc BEGINS "31565104" AND /* PEPSICO */         */
/*                 INT(b-docum-est.serie-docto) <> 1                        */
/*             THEN.                                                        */
/*             ELSE DO:                                                     */
/*                 IF  NOT b-docum-est.nat-operacao BEGINS "1933" AND       */
/*                     NOT b-docum-est.nat-operacao BEGINS "2933" AND       */
/*                     NOT b-docum-est.nat-operacao BEGINS "1352" AND       */
/*                     NOT b-docum-est.nat-operacao BEGINS "1252" AND       */
/*                     NOT b-docum-est.nat-operacao BEGINS "2352" AND       */
/*                     NOT b-docum-est.nat-operacao BEGINS "2252"           */
/*                 THEN DO:                                                 */
/*                     RUN pi-gera-log.                                     */
/*                 END.                                                     */
/*             END.                                                         */
/*         END.                                                             */
/*     END.                                                                 */
/*     /* 27/06/2017 - Hoepers - Fim alerta nota com chave em branco */     */


    /* 04/07/2017 - Inicio Atualizaá∆o data e Valor Èltima Entrada Item */
    FOR FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = b-docum-est.cod-emitente:

        FOR EACH  item-doc-est OF b-docum-est NO-LOCK
            WHERE item-doc-est.quantidade > 0,
            FIRST natur-oper  OF item-doc-est NO-LOCK:

            IF  natur-oper.tipo          = 1  AND /* Entrada */
                natur-oper.transf        = NO AND
                b-docum-est.cod-observa <> 3      /* Devoluá∆o */
            THEN DO:
                ASSIGN da-valor-ult-ent = ?
                       de-valor-ult-ent = 0.

                IF  emitente.cgc BEGINS "79430682" /* Qdo for Nissei n∆o atualiza */
                THEN DO:
                    FOR FIRST cst_item_uni_estab NO-LOCK
                        WHERE cst_item_uni_estab.it_codigo   = item-doc-est.it-codigo
                          AND cst_item_uni_estab.cod_estabel = b-docum-est.cod-estabel:

                        ASSIGN da-valor-ult-ent = cst_item_uni_estab.dat_ult_entr
                               de-valor-ult-ent = cst_item_uni_estab.val_ult_entr.
                    END.
                END.
                ELSE
                    ASSIGN da-valor-ult-ent = b-docum-est.dt-trans
                           de-valor-ult-ent = item-doc-est.preco-unit[1] - (item-doc-est.desconto[1] / item-doc-est.quantidade).

                FOR FIRST ITEM OF item-doc-est EXCLUSIVE-LOCK:

                    IF  da-valor-ult-ent = ? OR
                        de-valor-ult-ent = 0
                    THEN
                        ASSIGN da-valor-ult-ent = item.data-ult-ent
                               de-valor-ult-ent = item.preco-ul-ent.

                    IF  item.data-ult-ent  = ? OR 
                        item.data-ult-ent <= b-docum-est.dt-trans 
                    THEN
                        ASSIGN item.data-ult-ent = da-valor-ult-ent
                               item.preco-ul-ent = de-valor-ult-ent.
                END.

                FOR FIRST item-mat-estab EXCLUSIVE-LOCK 
                    WHERE item-mat-estab.it-codigo   = item-doc-est.it-codigo 
                      AND item-mat-estab.cod-estabel = b-docum-est.cod-estabel:

                      IF  item-mat-estab.data-ult-ent  = ? OR 
                          item-mat-estab.data-ult-ent <= b-docum-est.dt-trans
                      THEN
                          ASSIGN item-mat-estab.data-ult-ent = da-valor-ult-ent
                                 item-mat-estab.preco-ul-ent = de-valor-ult-ent.
                END.

                FOR FIRST item-uni-estab EXCLUSIVE-LOCK
                    WHERE item-uni-estab.it-codigo   = item-doc-est.it-codigo
                      AND item-uni-estab.cod-estabel = b-docum-est.cod-estabel:

                    IF  item-uni-estab.data-ult-ent  = ? OR 
                        item-uni-estab.data-ult-ent <= b-docum-est.dt-trans
                    THEN DO:
                        IF  NOT emitente.cgc BEGINS "79430682" /* Qdo for Nissei n∆o atualiza */
                        THEN DO:
                            FIND FIRST cst_item_uni_estab EXCLUSIVE-LOCK
                                WHERE  cst_item_uni_estab.it_codigo   = item-doc-est.it-codigo
                                  AND  cst_item_uni_estab.cod_estabel = b-docum-est.cod-estabel NO-ERROR.
    
                            IF  NOT AVAIL cst_item_uni_estab
                            THEN DO:
                                CREATE cst_item_uni_estab.
                                ASSIGN cst_item_uni_estab.it_codigo   = item-doc-est.it-codigo
                                       cst_item_uni_estab.cod_estabel = b-docum-est.cod-estabel. 
                            END.
    
                            ASSIGN cst_item_uni_estab.dat_penult_entr = item-uni-estab.data-ult-ent
                                   cst_item_uni_estab.val_penult_entr = item-uni-estab.preco-ul-ent
                                   cst_item_uni_estab.dat_ult_entr    = da-valor-ult-ent
                                   cst_item_uni_estab.val_ult_entr    = de-valor-ult-ent.
                        END.

                        ASSIGN item-uni-estab.data-ult-ent = da-valor-ult-ent
                               item-uni-estab.preco-ul-ent = de-valor-ult-ent.
                    END.
                END.
                RELEASE cst_item_uni_estab.
                RELEASE item-uni-estab.
                RELEASE item-mat-estab.
                RELEASE ITEM.
            END.
        END.
    END. /* FOR FIRST estabelec NO-LOCK */
    /* 04/07/2017 - Fim Atualizaá∆o data e Valor Èltima Entrada Item */


    /* 07/07/2017 - Inicio Atualizaá∆o Conta Transit¢ria Bonificaá∆o - Geraá∆o DIV */
    FOR FIRST int_ds_natur_oper NO-LOCK
        WHERE int_ds_natur_oper.nat_operacao = b-docum-est.nat-operacao:

        IF  int_ds_natur_oper.log_bonificacao              = YES AND
            int_ds_natur_oper.cod_cta_transit_bonificacao <> ""
        THEN DO:

            ASSIGN l-erro = NO.
            DO TRANS ON ERROR UNDO, LEAVE: 
                FOR EACH item-doc-est OF b-docum-est NO-LOCK,
                    FIRST ITEM OF item-doc-est NO-LOCK:

                    EMPTY TEMP-TABLE tt-erro.
                    EMPTY TEMP-TABLE tt-movto.

                    CREATE tt-movto.
                    ASSIGN tt-movto.cod-versao-integ  = 1
                           tt-movto.cod-estabel       = b-docum-est.cod-estabel
                           tt-movto.serie             = b-docum-est.serie-docto
                           tt-movto.nro-docto         = b-docum-est.nro-docto
                           tt-movto.cod-emitente      = b-docum-est.cod-emitente
                           tt-movto.nat-operacao      = b-docum-est.nat-operacao
                           tt-movto.it-codigo         = item-doc-est.it-codigo
                           tt-movto.quantidade        = 0
                           tt-movto.valor-nota        = item-doc-est.preco-total[1] + item-doc-est.despesas[1] + item-doc-est.valor-ipi[1] - item-doc-est.desconto[1]
                           tt-movto.valor-mat-m[1]    = item-doc-est.preco-total[1] + item-doc-est.despesas[1] - item-doc-est.desconto[1]  - item-doc-est.valor-icm[1] - item-doc-est.valor-pis - item-doc-est.val-cofins
                           tt-movto.valor-icm         = IF item-doc-est.cd-trib-icm <> 2 AND item-doc-est.cd-trib-icm <> 3 THEN item-doc-est.valor-icm[1] ELSE 0
                           tt-movto.valor-ipi         = IF item-doc-est.cd-trib-ipi <> 2 AND item-doc-est.cd-trib-ipi <> 3 THEN item-doc-est.valor-ipi[1] ELSE 0
                           tt-movto.valor-mob-p[1]    = item-doc-est.valor-pis       
                           tt-movto.valor-ggf-p[1]    = item-doc-est.val-cofins    
                           tt-movto.conta-contabil    = int_ds_natur_oper.cod_cta_transit_bonificacao   
                           tt-movto.ct-codigo         = int_ds_natur_oper.cod_cta_transit_bonificacao            
                           tt-movto.sc-codigo         = "" 
                           tt-movto.esp-docto         = 22 /* NFS   */
                           tt-movto.tipo-trans        = 2  /* Sa°da */
                           tt-movto.cod-prog-orig     = "trnfebonif"
                           tt-movto.dt-trans          = TODAY                       
                           tt-movto.un                = item.un.

                    IF  item-doc-est.cd-trib-icm = 2 OR
                        item-doc-est.cd-trib-icm = 3
                    THEN
                        ASSIGN tt-movto.valor-mat-m[1] = tt-movto.valor-mat-m[1] + item-doc-est.valor-icm[1].


                    IF  item-doc-est.cd-trib-ipi = 2 OR
                        item-doc-est.cd-trib-ipi = 3
                    THEN
                        ASSIGN tt-movto.valor-mat-m[1] = tt-movto.valor-mat-m[1] + item-doc-est.valor-ipi[1].

                    IF  b-docum-est.cod-estabel = "973" 
                    THEN 
                        ASSIGN tt-movto.cod-depos = b-docum-est.cod-estabel.
                    ELSE     
                        ASSIGN tt-movto.cod-depos = "LOJ". 

                    RUN cep/ceapi001.p (INPUT-OUTPUT TABLE tt-movto,
                                        INPUT-OUTPUT TABLE tt-erro,
                                        INPUT NO).

                    IF CAN-FIND (FIRST tt-erro) 
                    THEN DO:
                        ASSIGN l-erro = YES.
                        EMPTY TEMP-TABLE tt-erro.
                        EMPTY TEMP-TABLE tt-movto.
                        UNDO, LEAVE.
                    END.
                    ELSE DO:
                        /* Atualizar valor do PIS/COFINS na DIV, temp-table n∆o trata este campo */
                        FOR FIRST movto-estoq EXCLUSIVE-LOCK
                            WHERE movto-estoq.serie         = b-docum-est.serie-docto 
                              AND movto-estoq.nro-docto     = b-docum-est.nro-docto   
                              AND movto-estoq.cod-emitente  = b-docum-est.cod-emitente
                              AND movto-estoq.nat-operacao  = b-docum-est.nat-operacao
                              AND movto-estoq.esp-docto     = 22 /* NFS   */
                              AND movto-estoq.tipo-trans    = 2  /* Sa°da */
                              AND movto-estoq.it-codigo     = item-doc-est.it-codigo
                              AND movto-estoq.cod-prog-orig = "trnfebonif":

                            ASSIGN movto-estoq.valor-pis  = item-doc-est.valor-pis
                                   movto-estoq.val-cofins = item-doc-est.val-cofins.
                        END.
                        RELEASE movto-estoq.
                    END.
                    EMPTY TEMP-TABLE tt-erro.
                    EMPTY TEMP-TABLE tt-movto.
                END.
            END.
            IF  l-erro = YES
            THEN DO:
                EMPTY TEMP-TABLE tt-erro.
                EMPTY TEMP-TABLE tt-movto.
                RETURN "NOK".
            END.
        END.
    END.
    /* 07/07/2017 - Fim Atualizaá∆o Conta Transit¢ria Bonificaá∆o - Geraá∆o DIV */

    /* Inicio SM 135 Estorno Custo Cont†bil, ICMS Transf Estadual */
    FOR FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel = b-docum-est.cod-estabel:

        ASSIGN c-conta-icm = estabelec.ct-icm.

        IF estabelec.log-livre-1 = YES THEN DO: 

            FIND FIRST estab-ctas-impto NO-LOCK
                WHERE estab-ctas-impto.cod-estab = estabelec.cod-estabel
                  AND estab-ctas-impto.num-impto = 01
                  AND estab-ctas-impto.dat-inic-valid <= TODAY
                  AND estab-ctas-impto.dat-fim-valid >= TODAY NO-ERROR.

            IF AVAIL estab-ctas-impto THEN DO:
                c-conta-icm = estab-ctas-impto.conta-imposto.
            END.
        END.
                  

      /*     /*inicializaá∆o do handle neste ponto para evitar 
             erro caso n∆o tenha sido efetuado a aplicaá∆o do delta 
             com a tabela estab-ctas-impto */
            IF NOT VALID-HANDLE(h-boin879) 
            THEN
                RUN inbo/boin879.p persistent set h-boin879.

            RUN openQueryStatic IN h-boin879 (INPUT "Main").   
                                                           
            RUN goToKeyCustom IN h-boin879 ( INPUT estabelec.cod-estabel,
                                             INPUT 01,
                                             INPUT TODAY ).
                                                                                      
            IF RETURN-VALUE = "OK"
            THEN
                RUN getCharField IN h-boin879 ( INPUT "conta-imposto",
                                                OUTPUT c-conta-icm ).
        END. 

        IF  VALID-HANDLE(h-boin879) 
        THEN DO:
            DELETE PROCEDURE h-boin879.
            ASSIGN h-boin879 = ?.
        END.
        
        */


    END.

    ASSIGN l-erro = NO.
    /*DO TRANS ON ERROR UNDO, LEAVE: */

        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-movto.

        FOR EACH   item-doc-est OF b-docum-est NO-LOCK
            WHERE  item-doc-est.valor-icm[1] > 0
              AND (item-doc-est.cd-trib-icm  = 1   /* Tributado */
               OR  item-doc-est.cd-trib-icm  = 4), /* Reduzido  */
            FIRST ITEM OF item-doc-est NO-LOCK:



            FOR FIRST  natur-oper NO-LOCK
                WHERE  natur-oper.nat-operacao = item-doc-est.nat-of
                  AND  natur-oper.transf       = YES
                  AND (natur-oper.nat-operacao BEGINS "1152"
                   OR  natur-oper.nat-operacao BEGINS "5152"):

                CREATE tt-movto.
                ASSIGN tt-movto.cod-versao-integ  = 1
                       tt-movto.cod-estabel       = b-docum-est.cod-estabel
                       tt-movto.serie             = b-docum-est.serie-docto
                       tt-movto.nro-docto         = b-docum-est.nro-docto
                       tt-movto.cod-emitente      = b-docum-est.cod-emitente
                       tt-movto.nat-operacao      = item-doc-est.nat-of
                       tt-movto.it-codigo         = item-doc-est.it-codigo
                       tt-movto.quantidade        = 0
                       tt-movto.valor-nota        = 0
                       tt-movto.valor-mat-m[1]    = item-doc-est.valor-icm[1]
                       tt-movto.valor-icm         = 0
                       tt-movto.valor-ipi         = 0 
                       tt-movto.valor-mob-p[1]    = 0       
                       tt-movto.valor-ggf-p[1]    = 0    
                       tt-movto.conta-contabil    = c-conta-icm
                       tt-movto.ct-codigo         = c-conta-icm 
                       tt-movto.sc-codigo         = ""
                       tt-movto.esp-docto         = 21 /* NFE   */
                       tt-movto.conta-db          = IF ITEM.tipo-contr = 1 THEN ITEM.ct-codigo ELSE ""
                       tt-movto.ct-db             = IF ITEM.tipo-contr = 1 THEN ITEM.ct-codigo ELSE ""
                       tt-movto.sc-db             = IF ITEM.tipo-contr = 1 THEN ITEM.sc-codigo ELSE ""
                       tt-movto.tipo-trans        = 1  /* Entrada */
                       tt-movto.cod-prog-orig     = "trnfesm135"
                       tt-movto.dt-trans          = TODAY                       
                       tt-movto.un                = ITEM.un.

                IF  b-docum-est.cod-estabel = "973" 
                THEN 
                    ASSIGN tt-movto.cod-depos = b-docum-est.cod-estabel.
                ELSE     
                    ASSIGN tt-movto.cod-depos = "LOJ". 

            END. /* FOR FIRST natur-oper NO-LOCK */


        END. /* FOR EACH item-doc-est OF b-docum-est NO-LOCK, */

        IF CAN-FIND (FIRST tt-movto) THEN DO:
            RUN cep/ceapi001.p (INPUT-OUTPUT TABLE tt-movto,
                                INPUT-OUTPUT TABLE tt-erro,
                                INPUT NO).

            IF CAN-FIND (FIRST tt-erro)
            THEN DO:


                ASSIGN l-erro = YES.
                EMPTY TEMP-TABLE tt-erro.
                EMPTY TEMP-TABLE tt-movto.
                UNDO, LEAVE.
            END.
        END.

    /*END. /* DO TRANS ON ERROR UNDO, LEAVE: */ */
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-movto.
    /* Fim SM 135 Estorno Custo Cont†bil, ICMS Transf Estadual */

END.

IF b-old-docum-est.ce-atual = YES AND 
   b-docum-est.ce-atual     = NO    
THEN DO:
    /* 19/04/2017 - Inicio Cancelar integraá∆o notas estorno */
    FOR FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = b-docum-est.nat-operacao:

        IF  SUBSTRING(natur-oper.char-1,159,1) = "S" /* Nfe de Estorno */
        THEN DO:
            find emitente no-lock 
                where emitente.cod-emitente = b-docum-est.cod-emitente no-error.

            find estabelec no-lock 
                where estabelec.cod-estabel = b-docum-est.cod-estabel no-error.

            /*IF  b-docum-est.cod-estabel <> "973" - int_ds_docto_xml Ç utilizado para o 973 - AVB 06/06/2017 */
            IF  b-docum-est.cod-estabel = "973"
            THEN DO:
                FIND int_ds_docto_xml EXCLUSIVE-LOCK
                    WHERE int_ds_docto_xml.serie        = estabelec.serie
                      AND int_ds_docto_xml.nNF          = b-docum-est.nro-docto
                      AND int_ds_docto_xml.cod_emitente = b-docum-est.cod-emitente
                      AND int_ds_docto_xml.tipo_nota    = 5 NO-ERROR. /* Estorno */
            
                IF  AVAIL int_ds_docto_xml
                THEN DO:
                    FOR EACH  int_ds_it_docto_xml EXCLUSIVE-LOCK
                        WHERE int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente
                          AND int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie       
                          AND int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF         
                          AND int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota:

                        ASSIGN int_ds_it_docto_xml.situacao = 2. /* Processada */
                    END.
                    ASSIGN int_ds_docto_xml.situacao = 2. /* Processada */
                END.
                RELEASE int_ds_docto_xml.
                RELEASE int_ds_it_docto_xml.
                /* cancelar movtos no PRS - AVB - 06/06/2017 */
                RUN pi-int_ds_docto_wms(65).
            END.
            ELSE DO:
                FIND int_ds_nota_entrada EXCLUSIVE-LOCK
                    WHERE int_ds_nota_entrada.nen_cnpj_origem_s = emitente.cgc
                      AND int_ds_nota_entrada.nen_serie_s       = estabelec.serie
                      AND int_ds_nota_entrada.nen_notafiscal_n  = INT(b-docum-est.nro-docto) NO-ERROR. 
            
                IF  AVAIL int_ds_nota_entrada
                THEN
                    ASSIGN int_ds_nota_entrada.situacao = 2. /* Processada */

                RELEASE int_ds_nota_entrada.
                
                /* nota de loja n∆o deve ter int_ds_docto_wms - AVB - 06/06/2017
                FIND FIRST int_ds_docto_wms EXCLUSIVE-LOCK
                    WHERE  int_ds_docto_wms.doc_numero_n = INT(b-docum-est.nro-docto)
                      AND  int_ds_docto_wms.doc_serie_s  = b-docum-est.serie
                      AND  int_ds_docto_wms.doc_origem_n = b-docum-est.cod-emitente NO-ERROR.
            
                IF  AVAIL int_ds_docto_wms
                THEN
                    ASSIGN int_ds_docto_wms.situacao = 50.
    
                RELEASE int_ds_docto_wms.
                */
            END.
        END.
    END.
    /* 19/04/2017 - Fim Cancelar integraá∆o notas estorno */


    /* 04/07/2017 - Inicio Atualizaá∆o data e Valor Èltima Entrada Item */
    FOR FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = b-docum-est.cod-emitente:

        FOR EACH  item-doc-est OF b-docum-est NO-LOCK
            WHERE item-doc-est.quantidade > 0,
            FIRST natur-oper  OF item-doc-est NO-LOCK:

            IF  natur-oper.tipo          = 1  AND /* Entrada */
                natur-oper.transf        = NO AND
                b-docum-est.cod-observa <> 3      /* Devoluá∆o */
            THEN DO:
                FOR FIRST item-uni-estab EXCLUSIVE-LOCK
                    WHERE item-uni-estab.it-codigo   = item-doc-est.it-codigo
                      AND item-uni-estab.cod-estabel = b-docum-est.cod-estabel:

                    IF  item-uni-estab.data-ult-ent = b-docum-est.dt-trans
                    THEN DO:
                        FOR FIRST cst_item_uni_estab EXCLUSIVE-LOCK
                            WHERE cst_item_uni_estab.it_codigo   = item-doc-est.it-codigo
                              AND cst_item_uni_estab.cod_estabel = b-docum-est.cod-estabel:

                            IF  emitente.cgc BEGINS "79430682" /* Qdo for Nissei n∆o atualiza */
                            THEN
                                ASSIGN da-valor-ult-ent = cst_item_uni_estab.dat_ult_entr 
                                       de-valor-ult-ent = cst_item_uni_estab.val_ult_entr.
                            ELSE
                                ASSIGN da-valor-ult-ent                = cst_item_uni_estab.dat_penult_entr 
                                       de-valor-ult-ent                = cst_item_uni_estab.val_penult_entr
                                       cst_item_uni_estab.dat_ult_entr = cst_item_uni_estab.dat_penult_entr
                                       cst_item_uni_estab.val_ult_entr = cst_item_uni_estab.val_penult_entr.

                            ASSIGN item-uni-estab.data-ult-ent = da-valor-ult-ent
                                   item-uni-estab.preco-ul-ent = de-valor-ult-ent.

                            FOR FIRST item-mat-estab EXCLUSIVE-LOCK 
                                WHERE item-mat-estab.it-codigo   = item-doc-est.it-codigo 
                                  AND item-mat-estab.cod-estabel = b-docum-est.cod-estabel:

                                 ASSIGN item-mat-estab.data-ult-ent = da-valor-ult-ent 
                                        item-mat-estab.preco-ul-ent = de-valor-ult-ent.
                            END.

                            FOR FIRST ITEM EXCLUSIVE-LOCK 
                                WHERE item.it-codigo = item-doc-est.it-codigo:

                                 ASSIGN item.data-ult-ent = da-valor-ult-ent 
                                        item.preco-ul-ent = de-valor-ult-ent.
                            END.
                        END.
                    END.
                END.
                RELEASE cst_item_uni_estab.
                RELEASE item-uni-estab.
                RELEASE item-mat-estab.
                RELEASE ITEM.
            END.
        END.
    END. /* FOR FIRST emitente NO-LOCK */
    /* 04/07/2017 - Fim Atualizaá∆o data e Valor Èltima Entrada Item */


    /* 07/07/2017 - Inicio Atualizaá∆o Conta Transit¢ria Bonificaá∆o - Geraá∆o DIV */
    FOR FIRST int_ds_natur_oper NO-LOCK
        WHERE int_ds_natur_oper.nat_operacao = b-docum-est.nat-operacao:
    
        IF  int_ds_natur_oper.log_bonificacao              = YES AND
            int_ds_natur_oper.cod_cta_transit_bonificacao <> ""  AND
            int_ds_natur_oper.cod_cta_transit_bonificacao  = b-docum-est.ct-transit
        THEN DO:
            FOR EACH  movto-estoq NO-LOCK
                WHERE movto-estoq.serie         = b-docum-est.serie-docto 
                  AND movto-estoq.nro-docto     = b-docum-est.nro-docto   
                  AND movto-estoq.cod-emitente  = b-docum-est.cod-emitente
                  AND movto-estoq.nat-operacao  = b-docum-est.nat-operacao
                  AND movto-estoq.esp-docto     = 22
                  AND movto-estoq.tipo-trans    = 2
                  AND movto-estoq.cod-prog-orig = "trnfebonif":

                FOR FIRST b-movto-estoq EXCLUSIVE-LOCK
                    WHERE ROWID(b-movto-estoq) = ROWID(movto-estoq):
                    DELETE b-movto-estoq.
                END.
            END.
        END.
    END.
    /* 07/07/2017 - Inicio Atualizaá∆o Conta Transit¢ria Bonificaá∆o - Geraá∆o DIV */

    /* Inicio SM 135 Estorno Custo Cont†bil, ICMS Transf Estadual */
    FOR EACH   item-doc-est OF b-docum-est NO-LOCK
        WHERE  item-doc-est.valor-icm[1] > 0
          AND (item-doc-est.cd-trib-icm  = 1   /* Tributado */
           OR  item-doc-est.cd-trib-icm  = 4): /* Reduzido  */
        FOR FIRST  natur-oper NO-LOCK
            WHERE  natur-oper.nat-operacao = item-doc-est.nat-of
              AND  natur-oper.transf       = YES
              AND (natur-oper.nat-operacao BEGINS "1152"
               OR  natur-oper.nat-operacao BEGINS "5152"):
        
            FOR EACH  movto-estoq NO-LOCK
                WHERE movto-estoq.serie         = b-docum-est.serie-docto
                  AND movto-estoq.nro-docto     = b-docum-est.nro-docto   
                  AND movto-estoq.cod-emitente  = b-docum-est.cod-emitente
                  AND movto-estoq.nat-operacao  = item-doc-est.nat-of
                  AND movto-estoq.esp-docto     = 21
                  AND movto-estoq.tipo-trans    = 1
                  AND movto-estoq.cod-prog-orig = "trnfesm135":
        
                FOR FIRST b-movto-estoq EXCLUSIVE-LOCK
                    WHERE ROWID(b-movto-estoq) = ROWID(movto-estoq):
                    DELETE b-movto-estoq.
                END.
            END.
        END.
    END.
    /* Fim SM 135 Estorno Custo Cont†bil, ICMS Transf Estadual */

   
   /* RUN pi-atualiza-doc (INPUT 2,                          /* Desatualiza */
                        INPUT b-docum-est.nat-operacao).
      */

END.

PROCEDURE pi-atualiza-doc:

DEF INPUT PARAMETER p-tipo     AS INTEGER.
DEF INPUT PARAMETER p-natureza AS CHAR.

   FIND FIRST int_ds_docto_xml NO-LOCK WHERE
              int(int_ds_docto_xml.nnf)     = int(b-docum-est.nro-docto) AND 
              int_ds_docto_xml.cod_emitente = b-docum-est.cod-emitente   AND 
              int_ds_docto_xml.serie        = b-docum-est.serie          /*AND 
              int_ds_docto_xml.tipo-nota    = b-docum-est.tipo-nota*/ NO-ERROR.
   IF AVAIL int_ds_docto_xml 
   THEN DO:

      FIND FIRST doc-fisico NO-LOCK WHERE
                 int(doc-fisico.nro-docto) = int(b-docum-est.nro-docto) AND
                 doc-fisico.serie-docto   = b-docum-est.serie        AND
                 doc-fisico.cod-emitente  = b-docum-est.cod-emitente /*AND
                 doc-fisico.tipo-nota     = b-docum-est.tipo-nota*/ NO-ERROR.
      IF AVAIL doc-fisico 
      THEN DO:

         FOR EACH int_ds_doc EXCLUSIVE-LOCK WHERE
                  int_ds_doc.cod_estabel    = int_ds_docto_xml.cod_estab    AND         
                  int_ds_doc.serie          = int_ds_docto_xml.serie        AND 
                  int(int_ds_doc.nro_docto) = int(int_ds_docto_xml.nnf)     AND 
                  int_ds_doc.cod_emitente  = int_ds_docto_xml.cod_emitente  /*AND
                  int_ds_doc.tipo-nota     = int_ds_docto_xml.tipo-nota  */ AND 
                  int_ds_doc.nat_operacao  = p-natureza
             query-tuning(no-lookahead):
             
             IF p-natureza = "" THEN
                ASSIGN int_ds_doc.nat_operacao = b-docum-est.nat-operacao.
             ELSE 
                ASSIGN int_ds_doc.nat_operacao = "".

         END.

      END.
      
      FIND FIRST doc-fiscal NO-LOCK WHERE
                 doc-fiscal.cod-estabel  = b-docum-est.cod-estabel  and 
                 doc-fiscal.serie        = b-docum-est.serie        and 
                 int(doc-fiscal.nr-doc-fis)   = int(b-docum-est.nro-docto)  and
                 doc-fiscal.cod-emitente = b-docum-est.cod-emitente AND 
                 doc-fiscal.nat-operacao = b-docum-est.nat-operacao NO-ERROR.
      IF AVAIL doc-fiscal 
      THEN DO:
           FOR FIRST int_ds_doc EXCLUSIVE-LOCK WHERE
                     int_ds_doc.cod_estabel   = int_ds_docto_xml.cod_estab    AND         
                     int_ds_doc.serie         = int_ds_docto_xml.serie        AND 
                     int(int_ds_doc.nro_docto)  = int(int_ds_docto_xml.nnf)    AND 
                     int_ds_doc.cod_emitente  = int_ds_docto_xml.cod_emitente AND
                     int_ds_doc.tipo_nota     = int_ds_docto_xml.tipo_nota    AND 
                     int_ds_doc.nat_operacao  = p-natureza
               query-tuning(no-lookahead):
           END. 
      END. 
   END.
END.



PROCEDURE pi-int_ds_docto_xml:

    FIND int_ds_docto_xml NO-LOCK
        WHERE int_ds_docto_xml.serie        = estabelec.serie
          AND int_ds_docto_xml.nNF          = b-docum-est.nro-docto
          AND int_ds_docto_xml.cod_emitente = b-docum-est.cod-emitente
          AND int_ds_docto_xml.tipo_nota    = 5 NO-ERROR. /* Estorno */

    IF  AVAIL int_ds_docto_xml
    THEN
        RETURN.

    CREATE int_ds_docto_xml.
    ASSIGN int_ds_docto_xml.serie         = estabelec.serie
           int_ds_docto_xml.nNF           = b-docum-est.nro-docto
           int_ds_docto_xml.cod_emitente  = b-docum-est.cod-emitente
           int_ds_docto_xml.tipo_nota     = 5 /* Estorno */
           int_ds_docto_xml.situacao      = 1 /* pendente */
           int_ds_docto_xml.tipo_estab    = 2 /* 1- principal/cd, 2 frente loja */
           int_ds_docto_xml.tipo_docto    = b-docum-est.tipo-docto
           int_ds_docto_xml.cod_estab     = b-docum-est.cod-estabel
           int_ds_docto_xml.estab_de_or   = b-docum-est.cod-estabel
           int_ds_docto_xml.CNPJ          = emitente.cgc
           int_ds_docto_xml.xNome         = emitente.nome-emit
           int_ds_docto_xml.CNPJ_dest     = estabelec.cgc
           int_ds_docto_xml.dEmi          = b-docum-est.dt-emissao
           int_ds_docto_xml.dt_trans      = b-docum-est.dt-trans
           int_ds_docto_xml.dt_atualiza   = b-docum-est.dt-atualiza
           int_ds_docto_xml.valor_frete   = b-docum-est.valor-frete
           int_ds_docto_xml.valor_seguro  = b-docum-est.valor-seguro
           int_ds_docto_xml.valor_outras  = b-docum-est.valor-outras
           int_ds_docto_xml.valor_mercad  = b-docum-est.valor-mercad
           int_ds_docto_xml.vNF           = b-docum-est.tot-valor
           int_ds_docto_xml.tot_desconto  = b-docum-est.tot-desconto
           int_ds_docto_xml.despesa_nota  = b-docum-est.despesa-nota
           int_ds_docto_xml.valor_ipi     = b-docum-est.ipi-deb-cre
           int_ds_docto_xml.valor_icms    = b-docum-est.icm-deb-cre
           int_ds_docto_xml.valor_st      = b-docum-est.vl-subs
           int_ds_docto_xml.valor_cofins  = b-docum-est.vl-cofins-subs
           int_ds_docto_xml.valor_pis     = b-docum-est.vl-pis-subs
           int_ds_docto_xml.vbc           = b-docum-est.base-icm
           int_ds_docto_xml.chnfe         = /*b-docum-est.cod-chave-aces-nf-eletro*/ nota-fiscal.cod-chave-aces-nf-eletro
           int_ds_docto_xml.modFrete      = b-docum-est.mod-frete
           int_ds_docto_xml.cfop          = INT(natur-oper.cod-cfop)
           int_ds_docto_xml.nat_operacao  = b-docum-est.nat-operacao
           int_ds_docto_xml.ep_codigo     = INT(i-ep-codigo-usuario)
           int_ds_docto_xml.observacao    = b-docum-est.observacao
           int_ds_docto_xml.cod_usuario   = b-docum-est.usuario
           int_ds_docto_xml.num_pedido    = IF  c-nr-pedcli = "" THEN 0 ELSE INT(c-nr-pedcli)
           int_ds_docto_xml.id_sequencial = /*NEXT-VALUE(seq-int_ds_docto_xml). /* Preparaá∆o para integraá∆o com Procfit */*/ ?
           .

/*         int_ds_docto_xml.base-guia-st - NAO PREENCHER   */
/*         int_ds_docto_xml.chnft - NAO PREENCHER          */
/*         int_ds_docto_xml.dt-guia-st - NAO PREENCHER     */
/*         int_ds_docto_xml.perc-red-icms - NAO PREENCHER  */
/*         int_ds_docto_xml.sit-re - NAO PREENCHER         */
/*         int_ds_docto_xml.valor-guia-st - NAO PREENCHER  */
/*         int_ds_docto_xml.valor-icms-des - NAO PREENCHER */
/*         int_ds_docto_xml.valor-ii - NAO PREENCHER       */
/*         int_ds_docto_xml.vbc-cst - NAO PREENCHER        */
/*         int_ds_docto_xml.volume - NAO PREENCHER         */
/*         int_ds_docto_xml.num-pedido  - Campo numero do item da nota fiscal     */
        

    FOR EACH item-doc-est OF b-docum-est NO-LOCK,
        FIRST ITEM OF item-doc-est:
        CREATE int_ds_it_docto_xml.
        ASSIGN int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente
               int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie
               int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF 
               int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota
               int_ds_it_docto_xml.sequencia    = item-doc-est.sequencia
               int_ds_it_docto_xml.situacao     = 1  /* pendente */
               int_ds_it_docto_xml.CNPJ         = int_ds_docto_xml.CNPJ
               int_ds_it_docto_xml.predBc       = item-doc-est.val-perc-red-icm
               int_ds_it_docto_xml.vicmsdeson   = item-doc-est.icm-outras[1]
               int_ds_it_docto_xml.nat_operacao = item-doc-est.nat-of
               int_ds_it_docto_xml.cfop         = int_ds_docto_xml.cfop
               int_ds_it_docto_xml.it_codigo    = item-doc-est.it-codigo
               int_ds_it_docto_xml.qCom         = item-doc-est.quantidade
               int_ds_it_docto_xml.Lote         = item-doc-est.lote
               int_ds_it_docto_xml.dVal         = item-doc-est.dt-vali-lote
               int_ds_it_docto_xml.vProd        = item-doc-est.preco-total[1]
               int_ds_it_docto_xml.vDesc        = item-doc-est.desconto[1]
               int_ds_it_docto_xml.vOutro       = item-doc-est.despesas[1]
               int_ds_it_docto_xml.picms        = item-doc-est.aliquota-icm
               int_ds_it_docto_xml.vbc_icms     = item-doc-est.base-icm[1]
               int_ds_it_docto_xml.vicms        = item-doc-est.valor-icm[1]
               int_ds_it_docto_xml.pipi         = item-doc-est.aliquota-ipi
               int_ds_it_docto_xml.vbc_ipi      = item-doc-est.base-ipi[1]
               int_ds_it_docto_xml.vipi         = item-doc-est.valor-ipi[1]
               int_ds_it_docto_xml.vbcst        = item-doc-est.base-subs[1]
               int_ds_it_docto_xml.vbc_pis      = item-doc-est.base-pis
               int_ds_it_docto_xml.ppis         = item-doc-est.val-aliq-pis
               int_ds_it_docto_xml.vpis         = item-doc-est.valor-pis
               int_ds_it_docto_xml.vbc_cofins   = item-doc-est.base-cofins
               int_ds_it_docto_xml.pcofins      = item-doc-est.val-aliq-cofins
               int_ds_it_docto_xml.vcofins      = item-doc-est.val-cofins
               int_ds_it_docto_xml.numero_ordem = item-doc-est.numero-ordem
               int_ds_it_docto_xml.ncm          = int(item-doc-est.class-fiscal) /* validar tipo dado */
               int_ds_it_docto_xml.num_pedido   = item-doc-est.num-pedido
               int_ds_it_docto_xml.numero_ordem = item-doc-est.numero-ordem
               int_ds_it_docto_xml.narrativa    = item-doc-est.narrativa
               int_ds_it_docto_xml.vUnCom       = item-doc-est.vl-unit
               int_ds_it_docto_xml.uCom         = item-doc-est.un
               int_ds_it_docto_xml.xProd        = SUBSTRING(item.desc-item,1,60).


          IF  ITEM.tipo-contr < 3 
          THEN
              ASSIGN int_ds_it_docto_xml.tipo_contr = 1.

          IF  ITEM.tipo-contr = 4 
          THEN
              ASSIGN int_ds_it_docto_xml.tipo_contr = 4.

          /* Notas Pepsico , apenas atualizam no re1001 */
          FIND FIRST int_ds_ext_emitente NO-LOCK WHERE
                     int_ds_ext_emitente.cod_emitente = int_ds_it_docto_xml.cod_emitente NO-ERROR.
          IF AVAIL int_ds_ext_emitente AND  
                   int_ds_ext_emitente.gera_nota 
          THEN 
              ASSIGN int_ds_it_docto_xml.tipo_contr = 4.


           FIND FIRST item-fornec NO-LOCK 
               WHERE  item-fornec.cod-emitente = int_ds_it_docto_xml.cod_emitente 
                 AND  ITEM-fornec.it-codigo    = int_ds_it_docto_xml.it_codigo        
                 AND  ITEM-fornec.ativo = YES NO-ERROR. 
           IF AVAIL ITEM-fornec 
           THEN DO:
               ASSIGN int_ds_it_docto_xml.uCom_forn    = item-fornec.unid-med-for
                      int_ds_it_docto_xml.item_do_forn = TRIM(item-fornec.item-do-forn).
           END.

        CASE item-doc-est.cd-trib-icm:
            WHEN(1) THEN ASSIGN int_ds_it_docto_xml.cst_icms = 10.
            WHEN(2) THEN ASSIGN int_ds_it_docto_xml.cst_icms = 30.
            WHEN(3) THEN ASSIGN int_ds_it_docto_xml.cst_icms = 50.
            WHEN(4) THEN ASSIGN int_ds_it_docto_xml.cst_icms = 20.
            OTHERWISE    ASSIGN int_ds_it_docto_xml.cst_icms = 50.
        END CASE.


        CASE item-doc-est.cd-trib-ipi:
            WHEN(2) THEN ASSIGN int_ds_it_docto_xml.cst_ipi = 2.
            WHEN(3) THEN ASSIGN int_ds_it_docto_xml.cst_ipi = 1.
            OTHERWISE    ASSIGN int_ds_it_docto_xml.cst_ipi = 49.
        END CASE.

/*         int_ds_it_docto_xml.arquivo - NAO PREENCHER    */
/*         int_ds_it_docto_xml.cenq - NAO PREENCHER       */
/*         int_ds_it_docto_xml.dFab - NAO PREENCHER       */
/*         int_ds_it_docto_xml.modbc - NAO PREENCHER      */
/*         int_ds_it_docto_xml.modbcst - NAO PREENCHER    */
/*         int_ds_it_docto_xml.orig-icms - NAO PREENCHER  */
/*         int_ds_it_docto_xml.picmsst  - NAO PREENCHER   */
/*         int_ds_it_docto_xml.pmvast - NAO PREENCHER     */
/*         int_ds_it_docto_xml.predBc - NAO PREENCHER     */
/*         int_ds_it_docto_xml.qOrdem - NAO PREENCHER     */
/*         int_ds_it_docto_xml.vbcstret - NAO PREENCHER   */
/*         int_ds_it_docto_xml.vicmsstret - NAO PREENCHER */
/*         int_ds_it_docto_xml.vPMC - NAO PREENCHER       */
/*         int_ds_it_docto_xml.vtottrib - NAO PREENCHER   */
/*         int_ds_it_docto_xml.vicmsst - NAO PREENCHER    */
/*         int_ds_it_docto_xml.cst-pis - NAO PREENCHER    */
/*         int_ds_it_docto_xml.cst-cofins - NAO PREENCHER */

    END.

    RELEASE int_ds_docto_xml.
    RELEASE int_ds_it_docto_xml.

END PROCEDURE.    


    
PROCEDURE pi-int_ds_nota_entrada:

    FIND int_ds_nota_entrada NO-LOCK
        WHERE int_ds_nota_entrada.nen_cnpj_origem_s = emitente.cgc
          AND int_ds_nota_entrada.nen_serie_s       = estabelec.serie
          AND int_ds_nota_entrada.nen_notafiscal_n  = INT(b-docum-est.nro-docto) NO-ERROR. 

    if avail int_ds_nota_entrada then return.

    find FIRST cst_estabelec NO-LOCK WHERE 
               cst_estabelec.cod_estabel = estabelec.cod-estabel no-error.

    CREATE int_ds_nota_entrada.
    ASSIGN int_ds_nota_entrada.nen_cnpj_origem_s        = emitente.cgc            
           int_ds_nota_entrada.nen_serie_s              = estabelec.serie         
           int_ds_nota_entrada.nen_notafiscal_n         = INT(b-docum-est.nro-docto)
           int_ds_nota_entrada.dt_geracao               = b-docum-est.dt-trans
           int_ds_nota_entrada.hr_geracao               = b-docum-est.hr-atualiza
           int_ds_nota_entrada.nen_baseicms_n           = b-docum-est.base-icm
           int_ds_nota_entrada.nen_baseipi_n            = b-docum-est.base-ipi
           int_ds_nota_entrada.nen_cfop_n               = INT(natur-oper.cod-cfop)
           int_ds_nota_entrada.nen_chaveacesso_s        = /*b-docum-est.cod-chave-aces-nf-eletro*/ nota-fiscal.cod-chave-aces-nf-eletro
           int_ds_nota_entrada.nen_cnpj_destino_s       = estabelec.cgc
           int_ds_nota_entrada.nen_dataemissao_d        = b-docum-est.dt-emis
           int_ds_nota_entrada.nen_datamovimentacao_d   = b-docum-est.dt-trans
           int_ds_nota_entrada.nen_desconto_n           = b-docum-est.tot-desconto
           int_ds_nota_entrada.nen_despesas_n           = b-docum-est.despesa-nota
           int_ds_nota_entrada.nen_frete_n              = b-docum-est.valor-frete
           int_ds_nota_entrada.nen_horamovimentacao_s   = b-docum-est.hr-atualiza
           int_ds_nota_entrada.nen_modalidade_frete_n   = b-docum-est.mod-frete
           int_ds_nota_entrada.nen_observacao_s         = b-docum-est.observacao
           int_ds_nota_entrada.nen_seguro_n             = b-docum-est.valor-seguro
           int_ds_nota_entrada.nen_valoricms_n          = b-docum-est.icm-deb-cre
           int_ds_nota_entrada.nen_valoripi_n           = b-docum-est.ipi-deb-cre
           int_ds_nota_entrada.nen_valortotalprodutos_n = b-docum-est.tot-valor
           int_ds_nota_entrada.situacao                 = 1 /* pendente */
           int_ds_nota_entrada.tipo_movto               = 1 /* inclus∆o */
           int_ds_nota_entrada.tipo_nota                = if avail cst_estabelec and (
                                                             cst_estabelec.dt_inicio_oper = ? or 
                                                             cst_estabelec.dt_inicio_oper > b-docum-est.dt-trans) then 1 /* Compra - OBLAK */
                                                          else 5 /* Estorno - Procfit */
           int_ds_nota_entrada.ped_codigo_n             = IF  c-nr-pedcli = "" THEN 0 ELSE INT(c-nr-pedcli)
           int_ds_nota_entrada.id_sequencial            = /*NEXT-VALUE(seq-int_ds_nota_entrada). /* Preparaá∆o para integraá∆o com Procfit */*/ ?
           .

/*     int_ds_nota_entrada.nen-basediferido-n - NAO PREENCHER */
/*     int_ds_nota_entrada.nen-baseisenta-n  - NAO PREENCHER  */
/*     int_ds_nota_entrada.nen-basest-n  - NAO PREENCHER      */
/*     int_ds_nota_entrada.nen-conferida-n - NAO PREENCHER    */
/*     int_ds_nota_entrada.nen-icmsst-n - NAO PREENCHER       */
/*     int_ds_nota_entrada.nen-quantidade-n - Campo quantidade do item da nota fiscal   */

    FOR EACH item-doc-est OF b-docum-est NO-LOCK,
        FIRST ITEM OF item-doc-est:

        FIND FIRST item-fornec NO-LOCK 
            WHERE  item-fornec.cod-emitente = b-docum-est.cod-emitente 
              AND  ITEM-fornec.it-codigo    = item-doc-est.it-codigo        
              AND  ITEM-fornec.ativo = YES NO-ERROR. 

        CREATE int_ds_nota_entrada_produt.
        ASSIGN int_ds_nota_entrada_produt.nen_cnpj_origem_s      = emitente.cgc             
               int_ds_nota_entrada_produt.nen_notafiscal_n       = INT(b-docum-est.nro-docto)          
               int_ds_nota_entrada_produt.nen_serie_s            = estabelec.serie  
               int_ds_nota_entrada_produt.alternativo_fornecedor = IF AVAIL item-fornec THEN TRIM(item-fornec.item-do-forn) ELSE ""
               int_ds_nota_entrada_produt.nep_sequencia_n        = item-doc-est.sequencia
               int_ds_nota_entrada_produt.nep_produto_n          = INT(item-doc-est.it-codigo)
               int_ds_nota_entrada_produt.nep_lote_s             = item-doc-est.lote
               int_ds_nota_entrada_produt.nen_cfop_n             = INT(natur-oper.cod-cfop)
               int_ds_nota_entrada_produt.nep_basecofins_n       = item-doc-est.base-cofins
               int_ds_nota_entrada_produt.nep_baseicms_n         = item-doc-est.base-icm[1]
               int_ds_nota_entrada_produt.nep_baseipi_n          = item-doc-est.base-ipi[1]
               int_ds_nota_entrada_produt.nep_basepis_n          = item-doc-est.base-pis
               int_ds_nota_entrada_produt.nep_basest_n           = item-doc-est.base-subs[1]
               int_ds_nota_entrada_produt.nep_cstb_icm_n         = item-doc-est.cd-trib-icm
               int_ds_nota_entrada_produt.nep_cstb_ipi_n         = item-doc-est.cd-trib-ipi
               int_ds_nota_entrada_produt.nep_datavalidade_d     = item-doc-est.dt-vali-lote
               int_ds_nota_entrada_produt.nep_percentualicms_n   = item-doc-est.aliquota-icm
               int_ds_nota_entrada_produt.nep_percentualipi_n    = item-doc-est.aliquota-ipi
               int_ds_nota_entrada_produt.nep_quantidade_n       = item-doc-est.quantidade
               int_ds_nota_entrada_produt.nep_valor_outras_n     = item-doc-est.despesas[1]
               int_ds_nota_entrada_produt.nep_valorbruto_n       = item-doc-est.preco-total[1]
               int_ds_nota_entrada_produt.nep_valordesconto_n    = item-doc-est.desconto[1]
               int_ds_nota_entrada_produt.nep_valoricms_n        = item-doc-est.valor-icm[1]
               int_ds_nota_entrada_produt.nep_valoripi_n         = item-doc-est.valor-ipi[1]
               int_ds_nota_entrada_produt.ped_codigo_n           = item-doc-est.num-pedido
               int_ds_nota_entrada_produt.nep_valorpis_n         = item-doc-est.valor-pis
               int_ds_nota_entrada_produt.nep_valorcofins_n      = item-doc-est.val-cofins
               int_ds_nota_entrada_produt.nep_valorliquido_n     = item-doc-est.preco-unit[1]
               int_ds_nota_entrada_produt.nep_percentualcofins_n = item-doc-est.val-aliq-cofins
               int_ds_nota_entrada_produt.nep_percentualpis_n    = item-doc-est.val-aliq-pis
               int_ds_nota_entrada_produt.nep_redutorbaseicms_n  = item-doc-est.val-perc-red-icm
               int_ds_nota_entrada_produt.npx_descricaoproduto_s = SUBSTRING(item.desc-item,1,60)
               int_ds_nota_entrada.nen_quantidade_n               = int_ds_nota_entrada.nen_quantidade_n + item-doc-est.quantidade.
        
        
/* int_ds_nota_entrada_produt.nep-basediferido-n - NAO PREENCHER   */
/* int_ds_nota_entrada_produt.nep-baseisenta-n - NAO PREENCHER     */
/* int_ds_nota_entrada_produt.nep-csta-n - NAO PREENCHER           */
/* int_ds_nota_entrada_produt.nep-icmsst-n - NAO PREENCHER         */
/* int_ds_nota_entrada_produt.nep-valor-icms-des-n - NAO PREENCHER */
/* int_ds_nota_entrada_produt.nep-valordespesa-n - NAO PREENCHER   */
/* int_ds_nota_entrada_produt.npx-ean-n - NAO PREENCHER            */

    END.

    RELEASE int_ds_nota_entrada.
    RELEASE int_ds_nota_entrada_produt.

END PROCEDURE.
    

PROCEDURE pi-int_ds_docto_wms:
    define input param p-situacao as integer.

    FIND FIRST int_ds_docto_wms NO-LOCK
        WHERE  int_ds_docto_wms.doc_numero_n = INT(b-docum-est.nro-docto)
          AND  int_ds_docto_wms.doc_serie_s  = estabelec.serie
          AND  int_ds_docto_wms.doc_origem_n = b-docum-est.cod-emitente NO-ERROR.

    IF  AVAIL int_ds_docto_wms
    THEN
        RETURN.

    CREATE int_ds_docto_wms.
    ASSIGN int_ds_docto_wms.doc_numero_n       = INT(b-docum-est.nro-docto)
           int_ds_docto_wms.doc_serie_s        = estabelec.serie         
           int_ds_docto_wms.doc_origem_n       = b-docum-est.cod-emitente
           int_ds_docto_wms.cnpj_cpf           = emitente.cgc
           int_ds_docto_wms.datamovimentacao_d = b-docum-est.dt-atualiza
           int_ds_docto_wms.horamovimentacao_s = b-docum-est.hr-atualiza
           int_ds_docto_wms.situacao           = p-situacao
           int_ds_docto_wms.tipo_nota          = /*b-docum-est.tipo-nota*/ 5 /* Estorno */
           int_ds_docto_wms.ENVIO_STATUS    = 1
           int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today)
           int_ds_docto_wms.id_sequencial   = ? 
           /*int_ds_docto_wms.id_sequencial      = NEXT-VALUE(seq-int_ds_docto_wms). /* Preparaá∆o para integraá∆o com Procfit */*/.

    IF  emitente.natureza = 1
    THEN
        ASSIGN int_ds_docto_wms.tipo_fornecedor = "F".
    ELSE
        ASSIGN int_ds_docto_wms.tipo_fornecedor = "J".

    RELEASE int_ds_docto_wms.

END PROCEDURE.


/* PROCEDURE pi-gera-log:                                                                                                    */
/*                                                                                                                           */
/*     DEFINE VARIABLE c-arquivo AS CHARACTER   NO-UNDO.                                                                     */
/*     DEFINE VARIABLE i-cont    AS INTEGER     NO-UNDO.                                                                     */
/*                                                                                                                           */
/*     ASSIGN c-arquivo = "c:\temp\monitor\nota_sem_chave"           + "_" +                                                 */
/*                        REPLACE(STRING(TODAY,"99/99/9999"),"/","") + "_" +                                                 */
/*                        REPLACE(STRING(TIME,"HH:MM:SS"),":","")    + ".txt".                                               */
/*                                                                                                                           */
/*     OUTPUT TO VALUE(c-arquivo) CONVERT TARGET "iso8859-1".                                                                */
/*         PUT UNFORMATTED  "b-docum-est.serie-docto   " + b-docum-est.serie-docto                      + CHR(10) +          */
/*                          "b-docum-est.nro-docto     " + b-docum-est.nro-docto                        + CHR(10) +          */
/*                          "b-docum-est.cod-emitente  " + STRING(b-docum-est.cod-emitente)             + CHR(10) +          */
/*                          "b-docum-est.nat-operacao  " + b-docum-est.nat-operacao                     + CHR(10) +          */
/*                          "b-docum-est.dt-emissao    " + STRING(b-docum-est.dt-emissao,"99/99/9999")  + CHR(10) +          */
/*                          "c-seg-usuario             " + c-seg-usuario                                + CHR(10) +          */
/*                          "SESSION:BATCH-MODE        " + STRING(SESSION:BATCH-MODE)                   + CHR(10) + CHR(10). */
/*                                                                                                                           */
/*         DO i-cont = 1 TO 10:                                                                                              */
/*             IF  PROGRAM-NAME(i-cont) <> ?                                                                                 */
/*             THEN                                                                                                          */
/*                 PUT UNFORMATTED "PROGRAM-NAME(" + STRING(i-cont) + ") " + PROGRAM-NAME(i-cont) + CHR(10).                 */
/*         END.                                                                                                              */
/*     OUTPUT CLOSE.                                                                                                         */
/*                                                                                                                           */
/* END PROCEDURE.                                                                                                            */


RETURN "OK".
