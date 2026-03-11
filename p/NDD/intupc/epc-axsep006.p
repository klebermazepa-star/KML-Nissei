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
    define buffer bint_ndd_envio for int_ndd_envio.

define temp-table tt_log_erro no-undo 
     field ttv_des_msg_ajuda as character initial ?
     field ttv_des_msg_erro  as character initial ?
     field ttv_num_cod_erro  as integer   initial ? .

DEF VAR c-job-ndd AS CHAR NO-UNDO.
DEF VAR i-job-ndd AS INT  NO-UNDO. 

/*OUTPUT TO \\192.168.200.53\datasul\wrk\axsep006.LOG APPEND.
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
OUTPUT CLOSE. */

if valid-handle(h--epc-axsep006) then return "OK".
for first tt-epc where 
    tt-epc.cod-event     = "before-cria-imposto":U and   
    tt-epc.cod-parameter = "rowid-itnotafisc":U:
    cXML = "".
    r-rowid = to-rowid(tt-epc.val-parameter).
    for first it-nota-fisc no-lock where rowid(it-nota-fisc) = r-rowid:
        
        for first nota-fiscal no-lock of it-nota-fisc:

            if not can-find (first int_ndd_envio WHERE 
                                   int_ndd_envio.cod_estabel = nota-fiscal.cod-estabel AND 
                                   int_ndd_envio.serie       = nota-fiscal.serie AND
                                   int_ndd_envio.nr_nota_fis = nota-fiscal.nr-nota-fis AND
                                   int_ndd_envio.dt_envio    = today and 
                                   int_ndd_envio.hr_envio   >= TIME - 60) then do:
                IF  NOT VALID-HANDLE(h--epc-axsep006) THEN
                    RUN adapters/xml/ep2/axsep006.p PERSISTENT SET h--epc-axsep006.
    
                RUN PITransUpsert IN h--epc-axsep006 (INPUT  "upd":U,
                                                 INPUT  "InvoiceNFe":U,
                                                 INPUT  ROWID(nota-fiscal),
                                                 OUTPUT TABLE tt_log_erro).
                RUN pi-retornaXMLNFe IN h--epc-axsep006 (OUTPUT cXML).
            end.
            if cXML <> "" then do:

               FIND FIRST estabelec 
                    WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel 
                    NO-LOCK NO-ERROR.

               FIND FIRST es-param-integracao-estab
                    WHERE es-param-integracao-estab.cod-estabel =  nota-fiscal.cod-estabel 
                    AND   es-param-integracao-estab.empresa-integracao = 2
                    NO-LOCK NO-ERROR.

               IF AVAIL es-param-integracao-estab THEN DO:
                  RUN int\wsinventti0006.p  (INPUT  ROWID(nota-fiscal)).
               END.

               ELSE do:
                 create int_ndd_envio.
                
                 ASSIGN i-job-ndd = 1. /* Produá∆o */
                 
                 IF AVAIL estabelec THEN DO:
                    IF estabelec.idi-tip-emis-nf-eletro = 2 THEN
                       ASSIGN i-job-ndd = 2. /* Homologaá∆o */
                    IF estabelec.idi-tip-emis-nf-eletro = 3 THEN
                       ASSIGN i-job-ndd = 1. /* Produá∆o */
                 END.
                 
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

               END. //NDD fim

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
            create int_ndd_envio.
            assign /*Qint_ndd_envio.ID           = via trigger */
                   int_ndd_envio.STATUSNUMBER = 0 /* A processar */
                   int_ndd_envio.JOB          = nota-fiscal.cod-estabel 
                                                + nota-fiscal.serie 
                                                + nota-fiscal.nr-nota-fis 
                                                + "-" 
                                                + string(time,"HH:MM:SS")
                   int_ndd_envio.DOCUMENTUSER = c-seg-usuario
                   int_ndd_envio.KIND         = 1 /* XML */.
            copy-lob cXML to int_ndd_envio.DOCUMENTDATA.

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

