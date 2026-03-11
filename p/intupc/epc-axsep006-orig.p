/********************************************************************************
** Programa: EPC-AXSEP006 - EPC Envio Nota Fiscal NDD
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
define variable r-rowid as rowid no-undo.
define variable i-id as integer no-undo.
define new global shared variable h--epc-axsep006 as handle no-undo.

define buffer btt-epc for tt-epc.
    define buffer bint-ndd-envio for int-ndd-envio.

define temp-table tt_log_erro no-undo 
     field ttv_des_msg_ajuda as character initial ?
     field ttv_des_msg_erro  as character initial ?
     field ttv_num_cod_erro  as integer   initial ? .

DEF VAR c-job-ndd AS CHAR NO-UNDO.
DEF VAR i-job-ndd AS INT  NO-UNDO. 

IF DBNAME MATCHES "*producao*" THEN
   ASSIGN i-job-ndd = 1.
IF DBNAME MATCHES "*homologacao*" THEN
   ASSIGN i-job-ndd = 2.
IF DBNAME MATCHES "*teste*" THEN
   ASSIGN i-job-ndd = 3.

OUTPUT TO \\192.168.200.53\datasul\wrk\axsep006.LOG APPEND.
FOR EACH btt-epc:
    DISPLAY 
        p-ind-event             FORMAT "X(25)"
        btt-epc.cod-event       FORMAT "X(25)"
        btt-epc.cod-parameter   FORMAT "X(25)"
        WITH WIDTH 300 STREAM-IO.
    DISPLAY PROGRAM-NAME(2) FORMAT "X(50)" LABEL "2".
    DISPLAY PROGRAM-NAME(3) FORMAT "X(50)" LABEL "3".
    DISPLAY PROGRAM-NAME(4) FORMAT "X(50)" LABEL "4".
END.
OUTPUT CLOSE.

if valid-handle(h--epc-axsep006) then return "OK".
for first tt-epc where 
    tt-epc.cod-event     = "before-cria-imposto":U and   
    tt-epc.cod-parameter = "rowid-itnotafisc":U:
    cXML = "".
    r-rowid = to-rowid(tt-epc.val-parameter).
    for first it-nota-fisc no-lock where rowid(it-nota-fisc) = r-rowid:
        
        for first nota-fiscal no-lock of it-nota-fisc:

            if not can-find (first int-ndd-envio of nota-fiscal where
                             dt-envio = today and hr-envio >= TIME - 60) then do:
                IF  NOT VALID-HANDLE(h--epc-axsep006) THEN
                    RUN adapters/xml/ep2/axsep006.p PERSISTENT SET h--epc-axsep006.
    
                RUN PITransUpsert IN h--epc-axsep006 (INPUT  "upd":U,
                                                 INPUT  "InvoiceNFe":U,
                                                 INPUT  ROWID(nota-fiscal),
                                                 OUTPUT TABLE tt_log_erro).
                RUN pi-retornaXMLNFe IN h--epc-axsep006 (OUTPUT cXML).
            end.
            if cXML <> "" then do:
                create int-ndd-envio.
                /*
                i-id = 1.
                for last bint-ndd-envio use-index id:
                    assign i-id = bint-ndd-envio.id + 1.
                end.*/

                ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
                /*IF i-job-ndd = 1 THEN DO:
                   IF nota-fiscal.cod-estabel = "247" THEN
                      ASSIGN c-job-ndd = "PD_" + nota-fiscal.cod-estabel.
                   ELSE 
                      ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
                END.
                IF i-job-ndd = 2 THEN
                   ASSIGN c-job-ndd = "HM_" + nota-fiscal.cod-estabel.
                IF i-job-ndd = 3 THEN
                   ASSIGN c-job-ndd = "TS_" + nota-fiscal.cod-estabel.*/

                assign /*int-ndd-envio.ID           = i-id*/
                       int-ndd-envio.STATUSNUMBER = 0 /* A processar */
                       int-ndd-envio.JOB          = c-job-ndd 
                       int-ndd-envio.DOCUMENTUSER = c-seg-usuario
                       int-ndd-envio.KIND         = 1 /* XML */
                       int-ndd-envio.cod-estabel  = nota-fiscal.cod-estabel 
                       int-ndd-envio.serie        = nota-fiscal.serie 
                       int-ndd-envio.nr-nota-fis  = nota-fiscal.nr-nota-fis 
                       int-ndd-envio.dt-envio     = today
                       int-ndd-envio.hr-envio     = time.
                copy-lob cXML to int-ndd-envio.DOCUMENTDATA.

                create btt-epc.
                assign btt-epc.cod-event     = "TrataNFeEspec":U
                       btt-epc.cod-parameter = "XMLEspec":U.
            end.
        end.
        if not avail nota-fiscal then do:
            create btt-epc.
            assign btt-epc.cod-event     = "TrataNFeEspec":U
                   btt-epc.cod-parameter = "GeraTT_LOG_ERRO":U.
            &IF "{&bf_dis_versao_ems}":U >= "2.07":U &THEN
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
        assign btt-epc.cod-event     = "TrataNFeEspec":U
               btt-epc.cod-parameter = "GeraTT_LOG_ERRO":U.
        &IF "{&bf_dis_versao_ems}":U >= "2.07":U &THEN
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
if valid-handle (h--epc-axsep006) then delete procedure h--epc-axsep006.

/* n∆o existe mais este ponto de epc
for first btt-epc where 
    btt-epc.cod-event     = "TrataNFeEspec":U and   
    btt-epc.cod-parameter = "Origem":U and
    btt-epc.val-parameter = "Envio":U:
    cXML = "".
    for first tt-epc where 
        tt-epc.cod-event     = "TrataNFeEspec":U and   
        tt-epc.cod-parameter = "ConteudoNFe":U:
        cXML = tt-epc.val-parameter.    
    end.

    for first tt-epc where 
        tt-epc.cod-event     = "TrataNFeEspec":U and   
        tt-epc.cod-parameter = "RowidNFe":U:
        r-rowid = to-rowid(tt-epc.val-parameter).
    end.

    /*tratamento XML NDD */
    for first nota-fiscal no-lock where 
        rowid(nota-fiscal) = r-rowid: 
        /*tratamento XML NDD */
        if cXML <> "" then do:
            create int-ndd-envio.
            assign /*Qint-ndd-envio.ID           = via trigger */
                   int-ndd-envio.STATUSNUMBER = 0 /* A processar */
                   int-ndd-envio.JOB          = nota-fiscal.cod-estabel 
                                                + nota-fiscal.serie 
                                                + nota-fiscal.nr-nota-fis 
                                                + "-" 
                                                + string(time,"HH:MM:SS")
                   int-ndd-envio.DOCUMENTUSER = c-seg-usuario
                   int-ndd-envio.KIND         = 1 /* XML */.
            copy-lob cXML to int-ndd-envio.DOCUMENTDATA.

            create tt-epc.
            assign tt-epc.cod-event     = "TrataNFeEspec":U
                   tt-epc.cod-parameter = "XMLEspec":U.
        end.
    end.
    if not avail nota-fiscal then do:
        create tt-epc.
        assign tt-epc.cod-event     = "TrataNFeEspec":U
               tt-epc.cod-parameter = "GeraTT_LOG_ERRO":U.
        for first cadast_msg no-lock where 
            cadast_msg.cdn_msg = 3084:
            /*assign tt-epc.val-parameter = "3084#" + cadast_msg.texto-msg + "#" + cadast_msg.help-msg.*/
            assign tt-epc.val-parameter = cadast_msg.des_text_msg.
        end.
    end.

end.
*/

return "OK".

