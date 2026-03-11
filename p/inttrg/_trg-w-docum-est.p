 /****************************************************************************************************
**   Programa: trg-w-docum-est.p - Trigger de write para a tabela docum-est
**   Objetivo: Ao atualizar nota de entrada , atualizar tabela int-ds-doc para calculo do CMV      
**   Data....: Maio/2016
*****************************************************************************************************/
DEF PARAM BUFFER b-docum-est     FOR docum-est.
DEF PARAM BUFFER b-old-docum-est FOR docum-est.
   
DEF TEMP-TABLE tt-balanco NO-UNDO
FIELD ped-tipopedido-n LIKE int-ds-pedido.ped-tipopedido-n.

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

RETURN "OK".

PUT "INICIO TRIGGER TRG-W-DOCUM-EST... " SKIP.
/* alterar chave do documento quando gera nota no faturamento e demais campos de controle para evitar faturamento duplicado */
if b-old-docum-est.nro-docto <> "" AND 
   b-old-docum-est.nro-docto <> b-docum-est.nro-docto then do:
    for each cst-fat-devol of b-old-docum-est
        query-tuning(no-lookahead):
        assign cst-fat-devol.nro-docto   = b-docum-est.nro-docto
               cst-fat-devol.serie-docto = b-docum-est.serie-docto.
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
    FOR FIRST int-ds-natur-oper NO-LOCK
        WHERE int-ds-natur-oper.nat-operacao = b-docum-est.nat-operacao:
    
        IF  int-ds-natur-oper.log-bonificacao              = YES AND
            int-ds-natur-oper.cod-cta-transit-bonificacao <> ""  AND
            int-ds-natur-oper.cod-cta-transit-bonificacao <> b-docum-est.ct-transit
        THEN
            ASSIGN b-docum-est.ct-transit = int-ds-natur-oper.cod-cta-transit-bonificacao.
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

            IF  b-docum-est.cod-estabel <> "973"
            THEN
                RUN pi-int-ds-nota-entrada.
            ELSE DO:
                RUN pi-int-ds-docto-xml.
                RUN pi-int-ds-docto-wms(10).
            END.

            IF  c-nr-pedcli <> ""
            THEN DO:
                FOR FIRST nota-fiscal EXCLUSIVE-LOCK
                    WHERE nota-fiscal.cod-estabel = b-docum-est.cod-estabel
                      AND nota-fiscal.serie       = estabelec.serie
                      AND nota-fiscal.nr-nota-fis = b-docum-est.nro-docto
                      AND nota-fiscal.nr-pedcli   = "":

                    FOR EACH it-nota-fisc OF nota-fiscal EXCLUSIVE-LOCK:
                        ASSIGN it-nota-fisc.nr-pedcli = c-nr-pedcli.
                    END.
                    ASSIGN nota-fiscal.nr-pedcli = c-nr-pedcli.
                END.
                RELEASE nota-fiscal.
                RELEASE it-nota-fisc.
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
                    FOR FIRST cst-item-uni-estab NO-LOCK
                        WHERE cst-item-uni-estab.it-codigo   = item-doc-est.it-codigo
                          AND cst-item-uni-estab.cod-estabel = b-docum-est.cod-estabel:

                        ASSIGN da-valor-ult-ent = cst-item-uni-estab.dat-ult-entr
                               de-valor-ult-ent = cst-item-uni-estab.val-ult-entr.
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
                            FIND FIRST cst-item-uni-estab EXCLUSIVE-LOCK
                                WHERE  cst-item-uni-estab.it-codigo   = item-doc-est.it-codigo
                                  AND  cst-item-uni-estab.cod-estabel = b-docum-est.cod-estabel NO-ERROR.
    
                            IF  NOT AVAIL cst-item-uni-estab
                            THEN DO:
                                CREATE cst-item-uni-estab.
                                ASSIGN cst-item-uni-estab.it-codigo   = item-doc-est.it-codigo
                                       cst-item-uni-estab.cod-estabel = b-docum-est.cod-estabel. 
                            END.
    
                            ASSIGN cst-item-uni-estab.dat-penult-entr = item-uni-estab.data-ult-ent
                                   cst-item-uni-estab.val-penult-entr = item-uni-estab.preco-ul-ent
                                   cst-item-uni-estab.dat-ult-entr    = da-valor-ult-ent
                                   cst-item-uni-estab.val-ult-entr    = de-valor-ult-ent.
                        END.

                        ASSIGN item-uni-estab.data-ult-ent = da-valor-ult-ent
                               item-uni-estab.preco-ul-ent = de-valor-ult-ent.
                    END.
                END.
                RELEASE cst-item-uni-estab.
                RELEASE item-uni-estab.
                RELEASE item-mat-estab.
                RELEASE ITEM.
            END.
        END.
    END. /* FOR FIRST estabelec NO-LOCK */
    /* 04/07/2017 - Fim Atualizaá∆o data e Valor Èltima Entrada Item */


    /* 07/07/2017 - Inicio Atualizaá∆o Conta Transit¢ria Bonificaá∆o - Geraá∆o DIV */
    FOR FIRST int-ds-natur-oper NO-LOCK
        WHERE int-ds-natur-oper.nat-operacao = b-docum-est.nat-operacao:

        IF  int-ds-natur-oper.log-bonificacao              = YES AND
            int-ds-natur-oper.cod-cta-transit-bonificacao <> ""
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
                           tt-movto.conta-contabil    = int-ds-natur-oper.cod-cta-transit-bonificacao   
                           tt-movto.ct-codigo         = int-ds-natur-oper.cod-cta-transit-bonificacao            
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
            FIND emitente NO-LOCK
                WHERE emitente.cod-emitente = b-docum-est.cod-emitente NO-ERROR.

            FIND estabelec NO-LOCK
                WHERE estabelec.cod-estabel = b-docum-est.cod-estabel NO-ERROR.

            /*IF  b-docum-est.cod-estabel <> "973" - int-ds-docto-xml Ç utilizado para o 973 - AVB 06/06/2017 */
            IF  b-docum-est.cod-estabel = "973"
            THEN DO:
                FIND int-ds-docto-xml EXCLUSIVE-LOCK
                    WHERE int-ds-docto-xml.serie        = estabelec.serie
                      AND int-ds-docto-xml.nNF          = b-docum-est.nro-docto
                      AND int-ds-docto-xml.cod-emitente = b-docum-est.cod-emitente
                      AND int-ds-docto-xml.tipo-nota    = 1 NO-ERROR. /* compra */
            
                IF  AVAIL int-ds-docto-xml
                THEN DO:
                    FOR EACH  int-ds-it-docto-xml EXCLUSIVE-LOCK
                        WHERE int-ds-it-docto-xml.cod-emitente = int-ds-docto-xml.cod-emitente
                          AND int-ds-it-docto-xml.serie        = int-ds-docto-xml.serie       
                          AND int-ds-it-docto-xml.nNF          = int-ds-docto-xml.nNF         
                          AND int-ds-it-docto-xml.tipo-nota    = int-ds-docto-xml.tipo-nota:

                        ASSIGN int-ds-it-docto-xml.situacao = 2. /* Processada */
                    END.
                    ASSIGN int-ds-docto-xml.situacao = 2. /* Processada */
                END.
                RELEASE int-ds-docto-xml.
                RELEASE int-ds-it-docto-xml.
                /* cancelar movtos no PRS - AVB - 06/06/2017 */
                RUN pi-int-ds-docto-wms(65).
            END.
            ELSE DO:
                FIND int-ds-nota-entrada EXCLUSIVE-LOCK
                    WHERE int-ds-nota-entrada.nen-cnpj-origem-s = emitente.cgc
                      AND int-ds-nota-entrada.nen-serie-s       = estabelec.serie
                      AND int-ds-nota-entrada.nen-notafiscal-n  = INT(b-docum-est.nro-docto) NO-ERROR. 
            
                IF  AVAIL int-ds-nota-entrada
                THEN
                    ASSIGN int-ds-nota-entrada.situacao = 2. /* Processada */

                RELEASE int-ds-nota-entrada.
                
                /* nota de loja n∆o deve ter int-ds-docto-wms - AVB - 06/06/2017
                FIND FIRST int-ds-docto-wms EXCLUSIVE-LOCK
                    WHERE  int-ds-docto-wms.doc_numero_n = INT(b-docum-est.nro-docto)
                      AND  int-ds-docto-wms.doc_serie_s  = b-docum-est.serie
                      AND  int-ds-docto-wms.doc_origem_n = b-docum-est.cod-emitente NO-ERROR.
            
                IF  AVAIL int-ds-docto-wms
                THEN
                    ASSIGN int-ds-docto-wms.situacao = 50.
    
                RELEASE int-ds-docto-wms.
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
                        FOR FIRST cst-item-uni-estab EXCLUSIVE-LOCK
                            WHERE cst-item-uni-estab.it-codigo   = item-doc-est.it-codigo
                              AND cst-item-uni-estab.cod-estabel = b-docum-est.cod-estabel:

                            IF  emitente.cgc BEGINS "79430682" /* Qdo for Nissei n∆o atualiza */
                            THEN
                                ASSIGN da-valor-ult-ent = cst-item-uni-estab.dat-ult-entr 
                                       de-valor-ult-ent = cst-item-uni-estab.val-ult-entr.
                            ELSE
                                ASSIGN da-valor-ult-ent                = cst-item-uni-estab.dat-penult-entr 
                                       de-valor-ult-ent                = cst-item-uni-estab.val-penult-entr
                                       cst-item-uni-estab.dat-ult-entr = cst-item-uni-estab.dat-penult-entr
                                       cst-item-uni-estab.val-ult-entr = cst-item-uni-estab.val-penult-entr.

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
                RELEASE cst-item-uni-estab.
                RELEASE item-uni-estab.
                RELEASE item-mat-estab.
                RELEASE ITEM.
            END.
        END.
    END. /* FOR FIRST emitente NO-LOCK */
    /* 04/07/2017 - Fim Atualizaá∆o data e Valor Èltima Entrada Item */


    /* 07/07/2017 - Inicio Atualizaá∆o Conta Transit¢ria Bonificaá∆o - Geraá∆o DIV */
    FOR FIRST int-ds-natur-oper NO-LOCK
        WHERE int-ds-natur-oper.nat-operacao = b-docum-est.nat-operacao:
    
        IF  int-ds-natur-oper.log-bonificacao              = YES AND
            int-ds-natur-oper.cod-cta-transit-bonificacao <> ""  AND
            int-ds-natur-oper.cod-cta-transit-bonificacao  = b-docum-est.ct-transit
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

   FIND FIRST int-ds-docto-xml NO-LOCK WHERE
              int(int-ds-docto-xml.nnf)     = int(b-docum-est.nro-docto) AND 
              int-ds-docto-xml.cod-emitente = b-docum-est.cod-emitente   AND 
              int-ds-docto-xml.serie        = b-docum-est.serie          AND 
              int-ds-docto-xml.tipo-nota    = b-docum-est.tipo-nota NO-ERROR.
   IF AVAIL int-ds-docto-xml 
   THEN DO:

      FIND FIRST doc-fisico NO-LOCK WHERE
                 int(doc-fisico.nro-docto) = int(b-docum-est.nro-docto) AND
                 doc-fisico.serie-docto   = b-docum-est.serie        AND
                 doc-fisico.cod-emitente  = b-docum-est.cod-emitente AND
                 doc-fisico.tipo-nota     = b-docum-est.tipo-nota NO-ERROR.
      IF AVAIL doc-fisico 
      THEN DO:

         FOR EACH int-ds-doc EXCLUSIVE-LOCK WHERE
                  int-ds-doc.cod-estabel    = int-ds-docto-xml.cod-estab    AND         
                  int-ds-doc.serie          = int-ds-docto-xml.serie        AND 
                  int(int-ds-doc.nro-docto) = int(int-ds-docto-xml.nnf)     AND 
                  int-ds-doc.cod-emitente  = int-ds-docto-xml.cod-emitente AND
                  int-ds-doc.tipo-nota     = int-ds-docto-xml.tipo-nota    AND 
                  int-ds-doc.nat-operacao  = p-natureza
             query-tuning(no-lookahead):
             
             IF p-natureza = "" THEN
                ASSIGN int-ds-doc.nat-operacao = b-docum-est.nat-operacao.
             ELSE 
                ASSIGN int-ds-doc.nat-operacao = "".

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
           FOR FIRST int-ds-doc EXCLUSIVE-LOCK WHERE
                     int-ds-doc.cod-estabel   = int-ds-docto-xml.cod-estab    AND         
                     int-ds-doc.serie         = int-ds-docto-xml.serie        AND 
                     int(int-ds-doc.nro-docto)  = int(int-ds-docto-xml.nnf)    AND 
                     int-ds-doc.cod-emitente  = int-ds-docto-xml.cod-emitente AND
                     int-ds-doc.tipo-nota     = int-ds-docto-xml.tipo-nota    AND 
                     int-ds-doc.nat-operacao  = p-natureza
               query-tuning(no-lookahead):
           END. 
      END. 
   END.
END.



PROCEDURE pi-int-ds-docto-xml:

    FIND int-ds-docto-xml NO-LOCK
        WHERE int-ds-docto-xml.serie        = estabelec.serie
          AND int-ds-docto-xml.nNF          = b-docum-est.nro-docto
          AND int-ds-docto-xml.cod-emitente = b-docum-est.cod-emitente
          AND int-ds-docto-xml.tipo-nota    = 1 NO-ERROR. /* compra */

    IF  AVAIL int-ds-docto-xml
    THEN
        RETURN.

    CREATE int-ds-docto-xml.
    ASSIGN int-ds-docto-xml.serie         = estabelec.serie
           int-ds-docto-xml.nNF           = b-docum-est.nro-docto
           int-ds-docto-xml.cod-emitente  = b-docum-est.cod-emitente
           int-ds-docto-xml.tipo-nota     = 1 /* Compra */
           int-ds-docto-xml.situacao      = 1 /* pendente */
           int-ds-docto-xml.tipo-estab    = 2 /* 1- principal/cd, 2 frente loja */
           int-ds-docto-xml.tipo-docto    = b-docum-est.tipo-docto
           int-ds-docto-xml.cod-estab     = b-docum-est.cod-estabel
           int-ds-docto-xml.estab-de-or   = b-docum-est.cod-estabel
           int-ds-docto-xml.CNPJ          = emitente.cgc
           int-ds-docto-xml.xNome         = emitente.nome-emit
           int-ds-docto-xml.CNPJ-dest     = estabelec.cgc
           int-ds-docto-xml.dEmi          = b-docum-est.dt-emissao
           int-ds-docto-xml.dt-trans      = b-docum-est.dt-trans
           int-ds-docto-xml.dt-atualiza   = b-docum-est.dt-atualiza
           int-ds-docto-xml.valor-frete   = b-docum-est.valor-frete
           int-ds-docto-xml.valor-seguro  = b-docum-est.valor-seguro
           int-ds-docto-xml.valor-outras  = b-docum-est.valor-outras
           int-ds-docto-xml.valor-mercad  = b-docum-est.valor-mercad
           int-ds-docto-xml.vNF           = b-docum-est.tot-valor
           int-ds-docto-xml.tot-desconto  = b-docum-est.tot-desconto
           int-ds-docto-xml.despesa-nota  = b-docum-est.despesa-nota
           int-ds-docto-xml.valor-ipi     = b-docum-est.ipi-deb-cre
           int-ds-docto-xml.valor-icms    = b-docum-est.icm-deb-cre
           int-ds-docto-xml.valor-st      = b-docum-est.vl-subs
           int-ds-docto-xml.valor-cofins  = b-docum-est.vl-cofins-subs
           int-ds-docto-xml.valor-pis     = b-docum-est.vl-pis-subs
           int-ds-docto-xml.vbc           = b-docum-est.base-icm
           int-ds-docto-xml.chnfe         = b-docum-est.cod-chave-aces-nf-eletro
           int-ds-docto-xml.modFrete      = b-docum-est.mod-frete
           int-ds-docto-xml.cfop          = INT(natur-oper.cod-cfop)
           int-ds-docto-xml.nat-operacao  = b-docum-est.nat-operacao
           int-ds-docto-xml.ep-codigo     = INT(i-ep-codigo-usuario)
           int-ds-docto-xml.observacao    = b-docum-est.observacao
           int-ds-docto-xml.cod-usuario   = b-docum-est.usuario
           int-ds-docto-xml.chnfe         = SUBSTRING(b-docum-est.char-1,93,60)
           int-ds-docto-xml.num-pedido    = IF  c-nr-pedcli = "" THEN 0 ELSE INT(c-nr-pedcli)
           int-ds-docto-xml.id_sequencial = /*NEXT-VALUE(seq-int-ds-docto-xml). /* Preparaá∆o para integraá∆o com Procfit */*/ ?
           .

/*         int-ds-docto-xml.base-guia-st - NAO PREENCHER   */
/*         int-ds-docto-xml.chnft - NAO PREENCHER          */
/*         int-ds-docto-xml.dt-guia-st - NAO PREENCHER     */
/*         int-ds-docto-xml.perc-red-icms - NAO PREENCHER  */
/*         int-ds-docto-xml.sit-re - NAO PREENCHER         */
/*         int-ds-docto-xml.valor-guia-st - NAO PREENCHER  */
/*         int-ds-docto-xml.valor-icms-des - NAO PREENCHER */
/*         int-ds-docto-xml.valor-ii - NAO PREENCHER       */
/*         int-ds-docto-xml.vbc-cst - NAO PREENCHER        */
/*         int-ds-docto-xml.volume - NAO PREENCHER         */
/*         int-ds-docto-xml.num-pedido  - Campo numero do item da nota fiscal     */
        

    FOR EACH item-doc-est OF b-docum-est NO-LOCK,
        FIRST ITEM OF item-doc-est:
        CREATE int-ds-it-docto-xml.
        ASSIGN int-ds-it-docto-xml.cod-emitente = int-ds-docto-xml.cod-emitente
               int-ds-it-docto-xml.serie        = int-ds-docto-xml.serie
               int-ds-it-docto-xml.nNF          = int-ds-docto-xml.nNF 
               int-ds-it-docto-xml.tipo-nota    = int-ds-docto-xml.tipo-nota
               int-ds-it-docto-xml.sequencia    = item-doc-est.sequencia
               int-ds-it-docto-xml.situacao     = 1  /* pendente */
               int-ds-it-docto-xml.CNPJ         = int-ds-docto-xml.CNPJ
               int-ds-it-docto-xml.predBc       = item-doc-est.val-perc-red-icm
               int-ds-it-docto-xml.vicmsdeson   = item-doc-est.icm-outras[1]
               int-ds-it-docto-xml.nat-operacao = item-doc-est.nat-of
               int-ds-it-docto-xml.cfop         = int-ds-docto-xml.cfop
               int-ds-it-docto-xml.it-codigo    = item-doc-est.it-codigo
               int-ds-it-docto-xml.qCom         = item-doc-est.quantidade
               int-ds-it-docto-xml.Lote         = item-doc-est.lote
               int-ds-it-docto-xml.dVal         = item-doc-est.dt-vali-lote
               int-ds-it-docto-xml.vProd        = item-doc-est.preco-total[1]
               int-ds-it-docto-xml.vDesc        = item-doc-est.desconto[1]
               int-ds-it-docto-xml.vOutro       = item-doc-est.despesas[1]
               int-ds-it-docto-xml.picms        = item-doc-est.aliquota-icm
               int-ds-it-docto-xml.vbc-icms     = item-doc-est.base-icm[1]
               int-ds-it-docto-xml.vicms        = item-doc-est.valor-icm[1]
               int-ds-it-docto-xml.pipi         = item-doc-est.aliquota-ipi
               int-ds-it-docto-xml.vbc-ipi      = item-doc-est.base-ipi[1]
               int-ds-it-docto-xml.vipi         = item-doc-est.valor-ipi[1]
               int-ds-it-docto-xml.vbcst        = item-doc-est.base-subs[1]
               int-ds-it-docto-xml.vbc-pis      = item-doc-est.base-pis
               int-ds-it-docto-xml.ppis         = item-doc-est.val-aliq-pis
               int-ds-it-docto-xml.vpis         = item-doc-est.valor-pis
               int-ds-it-docto-xml.vbc-cofins   = item-doc-est.base-cofins
               int-ds-it-docto-xml.pcofins      = item-doc-est.val-aliq-cofins
               int-ds-it-docto-xml.vcofins      = item-doc-est.val-cofins
               int-ds-it-docto-xml.numero-ordem = item-doc-est.numero-ordem
               int-ds-it-docto-xml.ncm          = int(item-doc-est.class-fiscal) /* validar tipo dado */
               int-ds-it-docto-xml.num-pedido   = item-doc-est.num-pedido
               int-ds-it-docto-xml.numero-ordem = item-doc-est.numero-ordem
               int-ds-it-docto-xml.narrativa    = item-doc-est.narrativa
               int-ds-it-docto-xml.vUnCom       = item-doc-est.vl-unit
               int-ds-it-docto-xml.uCom         = item-doc-est.un
               int-ds-it-docto-xml.xProd        = SUBSTRING(item.desc-item,1,60).


          IF  ITEM.tipo-contr < 3 
          THEN
              ASSIGN int-ds-it-docto-xml.tipo-contr = 1.

          IF  ITEM.tipo-contr = 4 
          THEN
              ASSIGN int-ds-it-docto-xml.tipo-contr = 4.

          /* Notas Pepsico , apenas atualizam no re1001 */
          FIND FIRST int-ds-ext-emitente NO-LOCK WHERE
                     int-ds-ext-emitente.cod-emitente = int-ds-it-docto-xml.cod-emitente NO-ERROR.
          IF AVAIL int-ds-ext-emitente AND  
                   int-ds-ext-emitente.gera-nota 
          THEN 
              ASSIGN int-ds-it-docto-xml.tipo-contr = 4.


           FIND FIRST item-fornec NO-LOCK 
               WHERE  item-fornec.cod-emitente = int-ds-it-docto-xml.cod-emitente 
                 AND  ITEM-fornec.it-codigo    = int-ds-it-docto-xml.it-codigo        
                 AND  ITEM-fornec.ativo = YES NO-ERROR. 
           IF AVAIL ITEM-fornec 
           THEN DO:
               ASSIGN int-ds-it-docto-xml.uCom-forn    = item-fornec.unid-med-for
                      int-ds-it-docto-xml.item-do-forn = TRIM(item-fornec.item-do-forn).
           END.

        CASE item-doc-est.cd-trib-icm:
            WHEN(1) THEN ASSIGN int-ds-it-docto-xml.cst-icms = 10.
            WHEN(2) THEN ASSIGN int-ds-it-docto-xml.cst-icms = 30.
            WHEN(3) THEN ASSIGN int-ds-it-docto-xml.cst-icms = 50.
            WHEN(4) THEN ASSIGN int-ds-it-docto-xml.cst-icms = 20.
            OTHERWISE    ASSIGN int-ds-it-docto-xml.cst-icms = 50.
        END CASE.


        CASE item-doc-est.cd-trib-ipi:
            WHEN(2) THEN ASSIGN int-ds-it-docto-xml.cst-ipi = 2.
            WHEN(3) THEN ASSIGN int-ds-it-docto-xml.cst-ipi = 1.
            OTHERWISE    ASSIGN int-ds-it-docto-xml.cst-ipi = 49.
        END CASE.

/*         int-ds-it-docto-xml.arquivo - NAO PREENCHER    */
/*         int-ds-it-docto-xml.cenq - NAO PREENCHER       */
/*         int-ds-it-docto-xml.dFab - NAO PREENCHER       */
/*         int-ds-it-docto-xml.modbc - NAO PREENCHER      */
/*         int-ds-it-docto-xml.modbcst - NAO PREENCHER    */
/*         int-ds-it-docto-xml.orig-icms - NAO PREENCHER  */
/*         int-ds-it-docto-xml.picmsst  - NAO PREENCHER   */
/*         int-ds-it-docto-xml.pmvast - NAO PREENCHER     */
/*         int-ds-it-docto-xml.predBc - NAO PREENCHER     */
/*         int-ds-it-docto-xml.qOrdem - NAO PREENCHER     */
/*         int-ds-it-docto-xml.vbcstret - NAO PREENCHER   */
/*         int-ds-it-docto-xml.vicmsstret - NAO PREENCHER */
/*         int-ds-it-docto-xml.vPMC - NAO PREENCHER       */
/*         int-ds-it-docto-xml.vtottrib - NAO PREENCHER   */
/*         int-ds-it-docto-xml.vicmsst - NAO PREENCHER    */
/*         int-ds-it-docto-xml.cst-pis - NAO PREENCHER    */
/*         int-ds-it-docto-xml.cst-cofins - NAO PREENCHER */

    END.

    RELEASE int-ds-docto-xml.
    RELEASE int-ds-it-docto-xml.

END PROCEDURE.    


    
PROCEDURE pi-int-ds-nota-entrada:

    FIND int-ds-nota-entrada NO-LOCK
        WHERE int-ds-nota-entrada.nen-cnpj-origem-s = emitente.cgc
          AND int-ds-nota-entrada.nen-serie-s       = estabelec.serie
          AND int-ds-nota-entrada.nen-notafiscal-n  = INT(b-docum-est.nro-docto) NO-ERROR. 

    IF  AVAIL int-ds-nota-entrada
    THEN
        RETURN.

    CREATE int-ds-nota-entrada.
    ASSIGN int-ds-nota-entrada.nen-cnpj-origem-s        = emitente.cgc            
           int-ds-nota-entrada.nen-serie-s              = estabelec.serie         
           int-ds-nota-entrada.nen-notafiscal-n         = INT(b-docum-est.nro-docto)
           int-ds-nota-entrada.dt-geracao               = b-docum-est.dt-trans
           int-ds-nota-entrada.hr-geracao               = b-docum-est.hr-atualiza
           int-ds-nota-entrada.nen-baseicms-n           = b-docum-est.base-icm
           int-ds-nota-entrada.nen-baseipi-n            = b-docum-est.base-ipi
           int-ds-nota-entrada.nen-cfop-n               = INT(natur-oper.cod-cfop)
           int-ds-nota-entrada.nen-chaveacesso-s        = b-docum-est.cod-chave-aces-nf-eletro
           int-ds-nota-entrada.nen-cnpj-destino-s       = estabelec.cgc
           int-ds-nota-entrada.nen-dataemissao-d        = b-docum-est.dt-emis
           int-ds-nota-entrada.nen-datamovimentacao-d   = b-docum-est.dt-trans
           int-ds-nota-entrada.nen-desconto-n           = b-docum-est.tot-desconto
           int-ds-nota-entrada.nen-despesas-n           = b-docum-est.despesa-nota
           int-ds-nota-entrada.nen-frete-n              = b-docum-est.valor-frete
           int-ds-nota-entrada.nen-horamovimentacao-s   = b-docum-est.hr-atualiza
           int-ds-nota-entrada.nen-modalidade-frete-n   = b-docum-est.mod-frete
           int-ds-nota-entrada.nen-observacao-s         = b-docum-est.observacao
           int-ds-nota-entrada.nen-seguro-n             = b-docum-est.valor-seguro
           int-ds-nota-entrada.nen-valoricms-n          = b-docum-est.icm-deb-cre
           int-ds-nota-entrada.nen-valoripi-n           = b-docum-est.ipi-deb-cre
           int-ds-nota-entrada.nen-valortotalprodutos-n = b-docum-est.tot-valor
           int-ds-nota-entrada.situacao                 = 1 /* pendente */
           int-ds-nota-entrada.tipo-movto               = 1 /* inclus∆o */
           int-ds-nota-entrada.tipo-nota                = 1 /* compra */
           int-ds-nota-entrada.ped-codigo-n             = IF  c-nr-pedcli = "" THEN 0 ELSE INT(c-nr-pedcli)
           int-ds-nota-entrada.id_sequencial            = /*NEXT-VALUE(seq-int-ds-nota-entrada). /* Preparaá∆o para integraá∆o com Procfit */*/ ?
           .

/*     int-ds-nota-entrada.nen-basediferido-n - NAO PREENCHER */
/*     int-ds-nota-entrada.nen-baseisenta-n  - NAO PREENCHER  */
/*     int-ds-nota-entrada.nen-basest-n  - NAO PREENCHER      */
/*     int-ds-nota-entrada.nen-conferida-n - NAO PREENCHER    */
/*     int-ds-nota-entrada.nen-icmsst-n - NAO PREENCHER       */
/*     int-ds-nota-entrada.nen-quantidade-n - Campo quantidade do item da nota fiscal   */

    FOR EACH item-doc-est OF b-docum-est NO-LOCK,
        FIRST ITEM OF item-doc-est:

        FIND FIRST item-fornec NO-LOCK 
            WHERE  item-fornec.cod-emitente = b-docum-est.cod-emitente 
              AND  ITEM-fornec.it-codigo    = item-doc-est.it-codigo        
              AND  ITEM-fornec.ativo = YES NO-ERROR. 

        CREATE int-ds-nota-entrada-produto.
        ASSIGN int-ds-nota-entrada-produto.nen-cnpj-origem-s      = emitente.cgc             
               int-ds-nota-entrada-produto.nen-notafiscal-n       = INT(b-docum-est.nro-docto)          
               int-ds-nota-entrada-produto.nen-serie-s            = estabelec.serie  
               int-ds-nota-entrada-produto.alternativo-fornecedor = IF AVAIL item-fornec THEN TRIM(item-fornec.item-do-forn) ELSE ""
               int-ds-nota-entrada-produto.nep-sequencia-n        = item-doc-est.sequencia
               int-ds-nota-entrada-produto.nep-produto-n          = INT(item-doc-est.it-codigo)
               int-ds-nota-entrada-produto.nep-lote-s             = item-doc-est.lote
               int-ds-nota-entrada-produto.nen-cfop-n             = INT(natur-oper.cod-cfop)
               int-ds-nota-entrada-produto.nep-basecofins-n       = item-doc-est.base-cofins
               int-ds-nota-entrada-produto.nep-baseicms-n         = item-doc-est.base-icm[1]
               int-ds-nota-entrada-produto.nep-baseipi-n          = item-doc-est.base-ipi[1]
               int-ds-nota-entrada-produto.nep-basepis-n          = item-doc-est.base-pis
               int-ds-nota-entrada-produto.nep-basest-n           = item-doc-est.base-subs[1]
               int-ds-nota-entrada-produto.nep-cstb-icm-n         = item-doc-est.cd-trib-icm
               int-ds-nota-entrada-produto.nep-cstb-ipi-n         = item-doc-est.cd-trib-ipi
               int-ds-nota-entrada-produto.nep-datavalidade-d     = item-doc-est.dt-vali-lote
               int-ds-nota-entrada-produto.nep-percentualicms-n   = item-doc-est.aliquota-icm
               int-ds-nota-entrada-produto.nep-percentualipi-n    = item-doc-est.aliquota-ipi
               int-ds-nota-entrada-produto.nep-quantidade-n       = item-doc-est.quantidade
               int-ds-nota-entrada-produto.nep-valor-outras-n     = item-doc-est.despesas[1]
               int-ds-nota-entrada-produto.nep-valorbruto-n       = item-doc-est.preco-total[1]
               int-ds-nota-entrada-produto.nep-valordesconto-n    = item-doc-est.desconto[1]
               int-ds-nota-entrada-produto.nep-valoricms-n        = item-doc-est.valor-icm[1]
               int-ds-nota-entrada-produto.nep-valoripi-n         = item-doc-est.valor-ipi[1]
               int-ds-nota-entrada-produto.ped-codigo-n           = item-doc-est.num-pedido
               int-ds-nota-entrada-produto.nep-valorpis-n         = item-doc-est.valor-pis
               int-ds-nota-entrada-produto.nep-valorcofins-n      = item-doc-est.val-cofins
               int-ds-nota-entrada-produto.nep-valorliquido-n     = item-doc-est.preco-unit[1]
               int-ds-nota-entrada-produto.nep-percentualcofins-n = item-doc-est.val-aliq-cofins
               int-ds-nota-entrada-produto.nep-percentualpis-n    = item-doc-est.val-aliq-pis
               int-ds-nota-entrada-produto.nep-redutorbaseicms-n  = item-doc-est.val-perc-red-icm
               int-ds-nota-entrada-produto.npx-descricaoproduto-s = SUBSTRING(item.desc-item,1,60)
               int-ds-nota-entrada.nen-quantidade-n               = int-ds-nota-entrada.nen-quantidade-n + item-doc-est.quantidade.
        
        
/* int-ds-nota-entrada-produto.nep-basediferido-n - NAO PREENCHER   */
/* int-ds-nota-entrada-produto.nep-baseisenta-n - NAO PREENCHER     */
/* int-ds-nota-entrada-produto.nep-csta-n - NAO PREENCHER           */
/* int-ds-nota-entrada-produto.nep-icmsst-n - NAO PREENCHER         */
/* int-ds-nota-entrada-produto.nep-valor-icms-des-n - NAO PREENCHER */
/* int-ds-nota-entrada-produto.nep-valordespesa-n - NAO PREENCHER   */
/* int-ds-nota-entrada-produto.npx-ean-n - NAO PREENCHER            */

    END.

    RELEASE int-ds-nota-entrada.
    RELEASE int-ds-nota-entrada-produto.

END PROCEDURE.
    

PROCEDURE pi-int-ds-docto-wms:
    define input param p-situacao as integer.

    FIND FIRST int-ds-docto-wms NO-LOCK
        WHERE  int-ds-docto-wms.doc_numero_n = INT(b-docum-est.nro-docto)
          AND  int-ds-docto-wms.doc_serie_s  = estabelec.serie
          AND  int-ds-docto-wms.doc_origem_n = b-docum-est.cod-emitente NO-ERROR.

    IF  AVAIL int-ds-docto-wms
    THEN
        RETURN.

    CREATE int-ds-docto-wms.
    ASSIGN int-ds-docto-wms.doc_numero_n       = INT(b-docum-est.nro-docto)
           int-ds-docto-wms.doc_serie_s        = estabelec.serie         
           int-ds-docto-wms.doc_origem_n       = b-docum-est.cod-emitente
           int-ds-docto-wms.cnpj_cpf           = emitente.cgc
           int-ds-docto-wms.datamovimentacao_d = b-docum-est.dt-atualiza
           int-ds-docto-wms.horamovimentacao_s = b-docum-est.hr-atualiza
           int-ds-docto-wms.situacao           = p-situacao
           int-ds-docto-wms.tipo-nota          = b-docum-est.tipo-nota
           int-ds-docto-wms.ENVIO_STATUS    = 1
           int-ds-docto-wms.ENVIO_DATA_HORA = datetime(today)
           int-ds-docto-wms.id_sequencial   = ? 
           /*int-ds-docto-wms.id_sequencial      = NEXT-VALUE(seq-int-ds-docto-wms). /* Preparaá∆o para integraá∆o com Procfit */*/.

    IF  emitente.natureza = 1
    THEN
        ASSIGN int-ds-docto-wms.tipo_fornecedor = "F".
    ELSE
        ASSIGN int-ds-docto-wms.tipo_fornecedor = "J".

    RELEASE int-ds-docto-wms.

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

PUT "FIM TRIGGER TRG-W-DOCUM-EST... " SKIP.
RETURN "OK".
