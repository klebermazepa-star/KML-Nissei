/********************************************************************************
** Programa: EPC-axsep037 - EPC Envio Nota Fiscal NDD
**
** Versao : 12 - 01/04/2016 - Alessandro V Baccin
**
********************************************************************************/
{cdp/cdcfgdis.i}
{include/i-epc200.i} 
{utp/ut-glob.i}
{method/dbotterr.i}

define input        param p-ind-event  as char no-undo.
define input-output param table for tt-epc.
define variable cProtocolo as char no-undo.
define variable cXML as longchar no-undo.
define variable i-id as integer no-undo.
define new global shared variable r-rowid-axsep037 as rowid no-undo.
define new global shared variable h-epc-axsep037 as handle no-undo.

define variable httMed as handle.
define variable httNfe as handle.
define variable httDet as handle.
define variable httRastro as handle.

define variable bhttMed as handle.
define variable bhttNfe as handle.
define variable bhttDet as handle.
define variable bhttRastro as handle.

define variable qhttMed as handle.
define variable qhttNfe as handle.
define variable qhttDet as handle.
define variable qhttRastro as handle.

define variable hField  as handle.

define variable c-cod-estabel like nota-fiscal.cod-estabel.
define variable c-serie       like nota-fiscal.serie.
define variable c-nr-nota-fis like nota-fiscal.nr-nota-fis.
define variable c-it-codigo   like it-nota-fisc.it-codigo.
define variable i-nr-seq-fat  like it-nota-fisc.nr-seq-fat.
define variable de-quantidade like it-nota-fisc.qt-faturada[1].

define variable l-ok           as logical no-undo.

define temp-table tt-lote no-undo like int_ds_pedido_retorno 
    field tipo as char
    index chave 
        ppr_produto_n 
        rpp_quantidade_n
        rpp_lote_s
        tipo.

define buffer btt-epc for tt-epc.
    define buffer bint_ndd_envio for int_ndd_envio.

define temp-table tt_log_erro no-undo 
     field ttv_des_msg_ajuda as character initial ?
     field ttv_des_msg_erro  as character initial ?
     field ttv_num_cod_erro  as integer   initial ? .

DEF VAR c-job-ndd AS CHAR NO-UNDO.
DEF VAR i-job-ndd AS INT  NO-UNDO. 

if DBNAME MATCHES "*producao*" then
   ASSIGN i-job-ndd = 1.
if DBNAME MATCHES "*homologacao*" then
   ASSIGN i-job-ndd = 2.
if DBNAME MATCHES "*teste*" then
   ASSIGN i-job-ndd = 3.

/*
put unformatted p-ind-event skip.
*/

if p-ind-event = "AtualizaDadosNFe" then do:

    for first btt-epc where 
        btt-epc.cod-event     = "AtualizaDadosNFe":U and   
        btt-epc.cod-parameter = "ttMed":U:
        assign httMed = handle(btt-epc.val-parameter).
        bhttMed = httMed:DEFAULT-BUFFER-HANDLE.
    end.
    for first btt-epc where 
        btt-epc.cod-event     = "AtualizaDadosNFe":U and   
        btt-epc.cod-parameter = "ttRastro":U:
        assign httRastro = handle(btt-epc.val-parameter).
        bhttRastro = httRastro:DEFAULT-BUFFER-HANDLE.

    end.
    for first btt-epc where 
        btt-epc.cod-event     = "AtualizaDadosNFe":U and   
        btt-epc.cod-parameter = "ttDet":U:
        assign httDet = handle(btt-epc.val-parameter).
        bhttDet = httDet:DEFAULT-BUFFER-HANDLE.
    end.

    for first btt-epc where 
        btt-epc.cod-event     = "AtualizaDadosNFe":U and   
        btt-epc.cod-parameter = "ttNfe":U:

        assign httNfe = handle(btt-epc.val-parameter).
        bhttNfe = httNfe:DEFAULT-BUFFER-HANDLE.

        create query qhttNfe.
        qhttNfe:set-buffers(bhttNfe).
        qhttNfe:query-prepare("PRESELECT EACH " + "ttNfe" + " INDEXED-REPOSITION").
        qhttNfe:query-open().

        if qhttNfe:num-results > 0 then repeat:
            qhttNfe:get-next().
            if qhttNfe:query-off-end then leave.
        
            assign hField = bhttNfe:buffer-field('CodEstabelNF')
                   c-cod-estabel = hField:buffer-value.
            assign hField = bhttNfe:buffer-field('SerieNF')
                   c-serie = hField:buffer-value.
            assign hField = bhttNfe:buffer-field('NrNotaFisNF')
                   c-nr-nota-fis = hField:buffer-value.

            /*put c-cod-estabel " " c-serie " " c-nr-nota-fis " " skip.*/

            for first nota-fiscal no-lock where
                nota-fiscal.cod-estabel = c-cod-estabel and
                nota-fiscal.serie       = c-serie and
                nota-fiscal.nr-nota-fis = c-nr-nota-fis
                query-tuning(no-lookahead):
                for first estabelec no-lock of nota-fiscal: end.

                /*
                put unformatted c-cod-estabel " " c-serie " " c-nr-nota-fis " ok" skip.
                */

                for each tt-lote query-tuning(no-lookahead). delete tt-lote. end.
                for each int_ds_pedido_retorno no-lock where
                    int_ds_pedido_retorno.ped_codigo_n = int(nota-fiscal.nr-pedcli) and
                    int_ds_pedido_retorno.rpp_lote <> ? and int_ds_pedido_retorno.rpp_lote <> ""
                    query-tuning(no-lookahead):
                    create tt-lote.
                    buffer-copy int_ds_pedido_retorno to tt-lote.

                    if estabelec.cgc = nota-fiscal.cgc then do: /* Balan‡o */
                       assign de-quantidade = int_ds_pedido_retorno.rpp_quantidade_n - int_ds_pedido_retorno.rpp_qtd_inventario_n.
                       if de-quantidade < 0 then do:
                            assign  tt-lote.rpp_quantidade = de-quantidade * -1
                                    tt-lote.tipo = "S".
                       end.
                       else do:
                            assign  tt-lote.rpp_quantidade = de-quantidade
                                    tt-lote.tipo = "E".
                       end.
                    end.
                    /*display tt-lote with width 550 stream-io.*/
                end.

                create query qhttDet.
                qhttDet:set-buffers(bhttDet).
                qhttDet:query-prepare("PRESELECT EACH " + "ttDet" + " INDEXED-REPOSITION").
                qhttDet:query-open().

                /*
                put unformatted  " Notas: " qhttNfe:num-results skip .
                put unformatted  " Det: " qhttDet:num-results skip .
                */

                if qhttDet:num-results > 0 then repeat:
                    qhttDet:get-next().
                    if qhttDet:query-off-end then leave.

                    assign hField = bhttDet:buffer-field('ItCodigoNF')
                           c-it-codigo = trim(hField:buffer-value).
                    assign hField = bhttDet:buffer-field('NrSeqFatNF')
                           i-nr-seq-fat = hField:buffer-value.

                    for first item no-lock where 
                        item.it-codigo = c-it-codigo /*and
                        item.ind-imp-desc = 9*/
                        query-tuning(no-lookahead):

                        find it-carac-tec no-lock where 
                            it-carac-tec.it-codigo = c-it-codigo and
                            it-carac-tec.cd-folha = "CADITEM" and
                            it-carac-tec.cd-comp = "430" no-error.
                        if  not avail it-carac-tec or
                            length(trim(it-carac-tec.observacao)) < 2 then next.

                        /*
                        put unformatted item.it-codigo " " item.ind-imp-desc skip .
                        */

                        for first it-nota-fisc no-lock of nota-fiscal where
                            it-nota-fisc.nr-seq-fat = i-nr-seq-fat and
                            it-nota-fisc.it-codigo  = c-it-codigo
                            query-tuning(no-lookahead):

                            /*
                            put unformatted item.it-codigo " " item.ind-imp-desc " ok" skip .
                            */

                            l-ok = no.
                            if estabelec.cgc = nota-fiscal.cgc then do: /* Balan‡o */
                                for first tt-lote where 
                                    tt-lote.ppr_produto_n   = int(c-it-codigo)            and
                                    tt-lote.rpp_quantidade  = it-nota-fisc.qt-faturada[1] and
                                    tt-lote.rpp_lote       <> ?                           and
                                    tt-lote.rpp_lote       <> ""                          and
                                    tt-lote.tipo            = "S"                         AND
                                    tt-lote.rpp_lote       <> "0"                         AND
                                    tt-lote.rpp_validade_d <> ?                           AND
                                    tt-lote.rpp_validade_d >= TODAY query-tuning(no-lookahead):
                                    run pi-cria-tt-med-rastro.
                                end.
                            end. /* do */
                            /* demais notas */
                            else do:
                                for first tt-lote where 
                                    tt-lote.ppr_produto_n  = int(c-it-codigo)                    and 
                                    tt-lote.rpp_quantidade = it-nota-fisc.qt-faturada[1]         and 
                                    /* uma nota por caixa - caixa informada na nota */
                                    tt-lote.rpp_caixa      = it-nota-fisc.nr-seq-ped /* caixa */ and
                                    tt-lote.rpp_lote       <> ?                                  and
                                    tt-lote.rpp_lote       <> ""                                 AND
                                    tt-lote.rpp_lote       <> "0"                                AND
                                    tt-lote.rpp_validade_d <> ?                                  AND
                                    tt-lote.rpp_validade_d >= TODAY query-tuning(no-lookahead):
                                    run pi-cria-tt-med-rastro.
                                end.
                                /* notas fiscais sem caixa */
                                if not l-ok then do:
                                    for first tt-lote where 
                                        tt-lote.ppr_produto_n   = int(c-it-codigo)                    and  
                                        tt-lote.rpp_quantidade  = it-nota-fisc.qt-faturada[1]         and  
                                        tt-lote.rpp_lote       <> ?                                   and
                                        tt-lote.rpp_lote       <> ""                                  AND
                                        tt-lote.rpp_lote       <> "0"                                 AND
                                        tt-lote.rpp_validade_d <> ?                                   AND
                                        tt-lote.rpp_validade_d >= TODAY query-tuning(no-lookahead):
                                        run pi-cria-tt-med-rastro.
                                        l-ok = yes.
                                    end.
                                end. /* not l-ok */

                            end. /*else do*/
                        end. /* it-nota-fisc */
                    end. /* item */
                end.

                qhttDet:query-close().

            end. /* nota-fiscal */

        end. /* num-results */
        qhttNfe:query-close().
    
        if valid-handle(qhttNfe) then delete object qhttNfe.
        if valid-handle(bhttNfe) then delete object httNfe.
        if valid-handle(httNfe)  then delete object httNfe.

        if valid-handle(qhttDet) then delete object qhttDet.
        if valid-handle(bhttDet) then delete object httDet.
        if valid-handle(httDet)  then delete object httDet.

        if valid-handle(qhttMed) then delete object qhttMed.
        if valid-handle(bhttMed) then delete object httMed.
        if valid-handle(httMed)  then delete object httMed.

        if valid-handle(qhttRastro) then delete object qhttRastro.
        if valid-handle(bhttRastro) then delete object httRastro.
        if valid-handle(httRastro)  then delete object httRastro.

        if valid-handle(hField) then  DELETE OBJECT hField.
    end.
end.

if valid-handle(h-epc-axsep037) then do:
    return "OK".
end.

for first tt-epc where 
    tt-epc.cod-event     = "before-cria-imposto":U and   
    tt-epc.cod-parameter = "rowid-itnotafisc":U:
    cXML = "".
    r-rowid-axsep037 = to-rowid(tt-epc.val-parameter).
    
    for first it-nota-fisc no-lock where rowid(it-nota-fisc) = r-rowid-axsep037 query-tuning(no-lookahead):
        
        for first nota-fiscal no-lock of it-nota-fisc query-tuning(no-lookahead):
            for first ser-estab no-lock where
                ser-estab.cod-estabel = nota-fiscal.cod-estabel AND
                ser-estab.serie = nota-fiscal.serie
                query-tuning(no-lookahead):
                if ser-estab.forma-emis = 2 /* Manual */ then RETURN "NOK".
            end.
            if not can-find (first int_ndd_envio WHERE
                                   int_ndd_envio.cod_estabel = nota-fiscal.cod-estabel AND
                                   int_ndd_envio.serie       = nota-fiscal.serie AND
                                   int_ndd_envio.nr_nota_fis = nota-fiscal.nr-nota-fis AND
                                   int_ndd_envio.dt_envio    = today and 
                                   int_ndd_envio.hr_envio   >= TIME - 60) then do:
                if  NOT VALID-HANDLE(h-epc-axsep037) then
                    RUN adapters/xml/ep2/axsep037.p PERSISTENT SET h-epc-axsep037.
    
                RUN PITransUpsert IN h-epc-axsep037 (INPUT  "upd":U,
                                                 INPUT  "InvoiceNFe":U,
                                                 INPUT  ROWID(nota-fiscal),
                                                 OUTPUT TABLE tt_log_erro).
                RUN pi-retornaXMLNFe IN h-epc-axsep037 (OUTPUT cXML).
            end.
            if cXML <> "" then do:
                create int_ndd_envio.
                ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
                IF i-job-ndd = 1 THEN DO:
                   IF nota-fiscal.cod-estabel <> "973" THEN
                      ASSIGN c-job-ndd = "PD_" + nota-fiscal.cod-estabel.
                   ELSE 
                      ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
                END.
                IF i-job-ndd = 2 THEN DO:
                   IF nota-fiscal.cod-estabel <> "973" THEN
                      ASSIGN c-job-ndd = "HM_" + nota-fiscal.cod-estabel.
                   ELSE 
                      ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
                END.
                IF i-job-ndd = 3 THEN DO:
                   IF nota-fiscal.cod-estabel <> "973" THEN
                      ASSIGN c-job-ndd = "TS_" + nota-fiscal.cod-estabel.
                   ELSE 
                      ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
                END.

                assign /*int_ndd_envio.ID           = i-id*/
                       int_ndd_envio.STATUSNUMBER = 0 /* A processar */
                       int_ndd_envio.JOB          = c-job-ndd 
                       int_ndd_envio.DOCUMENTUSER = c-seg-usuario
                       int_ndd_envio.KIND         = 1 /* XML */
                       int_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel 
                       int_ndd_envio.serie        = nota-fiscal.serie 
                       int_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis 
                       int_ndd_envio.dt_envio     = today
                       int_ndd_envio.hr_envio     = time.
                copy-lob cXML to int_ndd_envio.DOCUMENTDATA.
                RELEASE int_ndd_envio.
             
                create btt-epc.
                assign btt-epc.cod-event     = "AtualizaDadosNFe":U
                       btt-epc.cod-parameter = "XMLEspec":U.
                       
            end.
        end.
        if not avail nota-fiscal then do:
            create btt-epc.
            assign btt-epc.cod-event     = "AtualizaDadosNFe":U
                   btt-epc.cod-parameter = "GeraTT_LOG_ERRO":U.
            &if "{&bf_dis_versao_ems}":U >= "2.07":U &then
            for first cadast_msg no-lock where 
                cadast_msg.cdn_msg = 3084:
                assign btt-epc.val-parameter = cadast_msg.des_text_msg.
            end.
            &else
            for first cad-msgs no-lock where 
                cad-msgs.cd-msg = 3084:
                assign btt-epc.val-parameter = cad-msgs.texto-msg.
            end.
            &endif
        end.

    end.
    if not avail it-nota-fisc then do:
        create btt-epc.
        assign btt-epc.cod-event     = "AtualizaDadosNFe":U
               btt-epc.cod-parameter = "GeraTT_LOG_ERRO":U.
        &if "{&bf_dis_versao_ems}":U >= "2.07":U &then
        for first cadast_msg no-lock where 
            cadast_msg.cdn_msg = 3084:
            assign btt-epc.val-parameter = cadast_msg.des_text_msg.
        end.
        &else
        for first cad-msgs no-lock where 
            cad-msgs.cd-msg = 3084:
            assign btt-epc.val-parameter = cad-msgs.texto-msg.
        end.
        &endif
    end.
    
end.
if valid-handle (h-epc-axsep037) then delete procedure h-epc-axsep037.

return "OK".

procedure pi-cria-tt-med-rastro:

    /*
    DEFINE TEMP-TABLE ttRastro NO-UNDO /*Detalhamento de produto sujeito a rastreabilidade*/
         FIELD nLote          AS CHARACTER INITIAL ?                                   /*Nœmero do Lote do produto*/
         FIELD qLote          AS DECIMAL   INITIAL ?  FORMAT ">>>>>>>9.999" DECIMALS 3 /*Quantidade de produto no Lote*/
         FIELD dFab           AS DATE      INITIAL ?                                   /*Data de fabrica»’o/ Produ»’o*/
         FIELD dVal           AS DATE      INITIAL ?                                   /*Data de validade*/
         FIELD cAgreg         AS CHARACTER INITIAL ?                                   /*C½digo de Agrega»’o*/
         /*Chave EMS*/
         FIELD CodEstabelNF   AS CHARACTER INITIAL ?
         FIELD SerieNF        AS CHARACTER INITIAL ?
         FIELD NrNotaFisNF    AS CHARACTER INITIAL ?
         FIELD ItCodigoNF     AS CHARACTER INITIAL ?
         FIELD NrSeqFatNF     AS INTEGER   INITIAL ?
         INDEX ch-ttRastro CodEstabelNF SerieNF NrNotaFisNF NrSeqFatNF ItCodigoNF.
    */
    
    /*
    DEFINE TEMP-TABLE ttMed NO-UNDO
         FIELD cProdANVISA    AS CHARACTER INITIAL ?                                         /*C½digo de Produto da ANVISA. Utilizar o nœmero do registro do produto da C³mara de Regula»’o do Mercado de Medicamento × CMED*/
         FIELD vPMC           AS DECIMAL   INITIAL ?  FORMAT ">>>>>>>>>>>>9.99" DECIMALS 2   /*Pre»o Mÿximo ao Consumidor*/     
         /*Chave EMS*/
         FIELD CodEstabelNF   AS CHARACTER INITIAL ?
         FIELD SerieNF        AS CHARACTER INITIAL ?
         FIELD NrNotaFisNF    AS CHARACTER INITIAL ?
         FIELD ItCodigoNF     AS CHARACTER INITIAL ?
         FIELD NrSeqFatNF     AS INTEGER   INITIAL ?
         INDEX ch-ttMed CodEstabelNF SerieNF NrNotaFisNF NrSeqFatNF ItCodigoNF.
    */

    bhTTRastro:BUFFER-CREATE().
    assign hField = bhTTRastro:buffer-field('CodEstabelNF')
           hField:buffer-value = c-cod-estabel.
    assign hField = bhTTRastro:buffer-field('SerieNF')
           hField:buffer-value = c-serie.
    assign hField = bhTTRastro:buffer-field('NrNotaFisNF')
           hField:buffer-value = c-nr-nota-fis.
    assign hField = bhTTRastro:buffer-field('ItCodigoNF')
           hField:buffer-value = c-it-codigo.
    assign hField = bhTTRastro:buffer-field('NrSeqFatNF')
           hField:buffer-value = i-nr-seq-fat.
    assign hField = bhTTRastro:buffer-field('dFab')
           hField:buffer-value = if   (tt-lote.rpp_validade_d - 365) <= today 
                                 then (tt-lote.rpp_validade_d - 365) else today - 60.
    assign hField = bhTTRastro:buffer-field('dVal')
           hField:buffer-value = tt-lote.rpp_validade_d.
    assign hField = bhTTRastro:buffer-field('nLote')
           hField:buffer-value = tt-lote.rpp_lote.
    assign hField = bhTTRastro:buffer-field('qLote')
           hField:buffer-value = tt-lote.rpp_quantidade_n.

    bhTTMed:BUFFER-CREATE().
    assign hField = bhTTMed:buffer-field('CodEstabelNF')
           hField:buffer-value = c-cod-estabel.
    assign hField = bhTTMed:buffer-field('SerieNF')
           hField:buffer-value = c-serie.
    assign hField = bhTTMed:buffer-field('NrNotaFisNF')
           hField:buffer-value = c-nr-nota-fis.
    assign hField = bhTTMed:buffer-field('ItCodigoNF')
           hField:buffer-value = c-it-codigo.
    assign hField = bhTTMed:buffer-field('NrSeqFatNF')
           hField:buffer-value = i-nr-seq-fat.
    assign hField = bhTTMed:buffer-field('cProdANVISA')
           hField:buffer-value = if it-carac-tec.tipo-result = 4 
                                 then trim(it-carac-tec.observacao)
                                 else trim(string(it-carac-tec.vl-result)).

    for first unid-feder no-lock where
        unid-feder.estado = nota-fiscal.estado:

        for last preco-item no-lock where
            preco-item.nr-tabpre = unid-feder.nr-tb-pauta and
            preco-item.it-codigo = c-it-codigo and
            preco-item.situacao  = 1:

            assign hField = bhTTMed:buffer-field('vPMC')
                   hField:buffer-value = preco-item.preco-fob.
        end.

    end.

    delete tt-lote.
    l-ok = yes.
end.
