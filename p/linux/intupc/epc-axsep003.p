/********************************************************************************
** Programa: EPC-AXSEP006 - EPC Envio Nota Fiscal NDD
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
define buffer bint_ndd_envio for int_ndd_envio.

OUTPUT TO t:\axsep003.LOG APPEND.
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
    btt-epc.val-parameter = "INUTILIZACAO":U:
    
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
        /*
        /*tratamento XML NDD */
        if cXML <> "" then do:
            create int_ndd_envio.
            /*
            for last bint_ndd_envio use-index id exclusive-lock:
                assign i-id = bint_ndd_envio.id + 1.
            end.*/
            assign /*int_ndd_envio.ID           = i-id*/
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
                   tt-epc.cod-parameter = "XMLEspec":U
                   tt-epc.val-parameter = "CancelaNota#" + cProtocolo.
        end.
        */
        PUT "OK" SKIP.
    end.
    if not avail nota-fiscal then do:

        PUT "NOT AVAIL" SKIP.
        
        create tt-epc.
        assign tt-epc.cod-event     = "TrataNFeEspec":U
               tt-epc.cod-parameter = "GeraTT_LOG_ERRO":U.
        for first cadast_msg no-lock where 
            cadast_msg.cdn_msg = 3084:
            /*assign tt-epc.val-parameter = "3084#" + cadast_msg.texto-msg + "#" + cadast_msg.help-msg.*/
            assign tt-epc.val-parameter = cadast_msg.des_text_msg.
        end.
    end.
end. /* btt-epc */

OUTPUT CLOSE.
return "OK":U.

