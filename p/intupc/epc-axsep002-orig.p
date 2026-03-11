/********************************************************************************
** Programa: EPC-AXSEP002 - EPC Envio Nota Fiscal NDD
**
** Versao : 12 - 01/04/2016 - Alessandro V Baccin
**
********************************************************************************/

/* ------------------- Parametros da DBO -------------------------*/            
{include/i-epc200.i} 
{utp/ut-glob.i}


{method/dbotterr.i}


define input        param p-ind-event  as char          no-undo.
define input-output param table for tt-epc.

define buffer btt-epc for tt-epc.
define variable cProtocolo as char no-undo.
define variable cXML as longchar no-undo.
define variable r-rowid as rowid no-undo.
define variable i-id as integer no-undo.
define buffer bint-ndd-envio for int-ndd-envio.

DEF VAR c-job-ndd AS CHAR NO-UNDO.
DEF VAR i-job-ndd AS INT  NO-UNDO. 

IF DBNAME MATCHES "*producao*" THEN
   ASSIGN i-job-ndd = 1.
IF DBNAME MATCHES "*homologacao*" THEN
   ASSIGN i-job-ndd = 2.
IF DBNAME MATCHES "*teste*" THEN
   ASSIGN i-job-ndd = 3.

OUTPUT TO t:\axsep002.LOG APPEND.
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

for first btt-epc where 
    btt-epc.cod-event     = "TrataNFeEspec":U and   
    btt-epc.cod-parameter = "Origem":U and
    btt-epc.val-parameter = "CANCELAMENTO":U:
    
    cXML = "".
    for first tt-epc where 
        tt-epc.cod-event     = "TrataNFeEspec":U and   
        tt-epc.cod-parameter = "ConteudoNFe":U:
        cXML = tt-epc.val-parameter.    
    end.

    r-rowid = ?.
    for first tt-epc where 
        tt-epc.cod-event     = "TrataNFeEspec":U and   
        tt-epc.cod-parameter = "RowidNFe":U:
        r-rowid = to-rowid(tt-epc.val-parameter).
    end.
    for first nota-fiscal no-lock where 
        rowid(nota-fiscal) = r-rowid: 
        /*tratamento XML NDD */
        if cXML <> "" then do:
            create int-ndd-envio.
            /*
            i-id = 1.
            for last bint-ndd-envio use-index id exclusive-lock:
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
                   int-ndd-envio.KIND         = 1 /* XML */.
            copy-lob cXML to int-ndd-envio.DOCUMENTDATA.

            create tt-epc.
            assign tt-epc.cod-event     = "TrataNFeEspec":U
                   tt-epc.cod-parameter = "XMLEspec":U
                   tt-epc.val-parameter = "CancelaNota#" + cProtocolo.
        end.
    end.
    if not avail nota-fiscal then do:
        create tt-epc.
        assign tt-epc.cod-event     = "TrataNFeEspec":U
               tt-epc.cod-parameter = "GeraTT_LOG_ERRO":U.
        for first cadast_msg no-lock where 
            cadast_msg.cdn_msg = 3084:
            assign tt-epc.val-parameter = "3084#" + cadast_msg.des_text_msg + "#" + cadast_msg.dsl_help_msg.
        end.
    end.
end. /* btt-epc */
OUTPUT CLOSE.
return "OK":U.

