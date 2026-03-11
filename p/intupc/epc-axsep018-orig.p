/********************************************************************************
** Programa: EPC-axsep018 - EPC Envio Carta Corre‡Æo NDD
**
** Versao : 01 - 31/10/2016 - Sz Solu‡äes
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
define new global shared variable r-rowid-axsep018 as rowid no-undo.
define new global shared variable h-epc-axsep018 as handle no-undo.

DEFINE VARIABLE c-job-ndd AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-job-ndd AS INTEGER     NO-UNDO.
DEFINE VARIABLE c-origem  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-replace AS CHARACTER   NO-UNDO.

IF DBNAME MATCHES "*producao*" THEN
   ASSIGN i-job-ndd = 1.
IF DBNAME MATCHES "*homologacao*" THEN
   ASSIGN i-job-ndd = 2.
IF DBNAME MATCHES "*teste*" THEN
   ASSIGN i-job-ndd = 3.

define buffer btt-epc for tt-epc.
    define buffer bint-ndd-envio for int-ndd-envio.

DEFINE TEMP-TABLE tt_log_erro NO-UNDO
     FIELD ttv_num_cod_erro  AS INTEGER   INITIAL ?
     FIELD ttv_des_msg_ajuda AS CHARACTER INITIAL ?
     FIELD ttv_des_msg_erro  AS CHARACTER INITIAL ? .

for first tt-epc where 
    tt-epc.cod-event     = "TrataCCeEspec":U and   
    tt-epc.cod-parameter = "ConteudoCCe":U:

    cXML = "".
    cXML = tt-epc.val-parameter.

    ASSIGN cXML = REPLACE(cXML,"UTF-8","utf-16").

    ASSIGN c-replace = '<envEvento xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">'
                     + "<idLote>000000000000001</idLote>".

    ASSIGN cXML = REPLACE(cXML,"<Upsert>",c-replace).

    ASSIGN c-origem  = '<Evento versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
           c-replace = '<evento xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">'
           cXML      = REPLACE(cXML,c-origem,c-replace).

    ASSIGN cXML = REPLACE(cXML,"</Evento>","</evento>")
           cXML = REPLACE(cXML,"</Upsert>","</envEvento>").
end.

for first tt-epc where 
    tt-epc.cod-event     = "TrataCCeEspec":U and   
    tt-epc.cod-parameter = "RowidCCe":U:
   
    r-rowid-axsep018 = to-rowid(tt-epc.val-parameter).
    
    for first carta-correc-eletro EXCLUSIVE-LOCK 
        where rowid(carta-correc-eletro) = r-rowid-axsep018:
        
        for first nota-fiscal no-lock 
            where nota-fiscal.cod-estabel = carta-correc-eletro.cod-estab
              and nota-fiscal.serie       = carta-correc-eletro.cod-serie
              and nota-fiscal.nr-nota-fis = carta-correc-eletro.cod-nota-fis:

            if not can-find (first int-ndd-envio of nota-fiscal 
                             where int-ndd-envio.dt-envio = today and int-ndd-envio.hr-envio >= TIME - 60) and cXML <> "" then do:

                ASSIGN c-job-ndd = nota-fiscal.cod-estabel + "_EVT".
                /*IF i-job-ndd = 1 THEN DO:
                   IF nota-fiscal.cod-estabel = "247" THEN
                      ASSIGN c-job-ndd = "PD_" + nota-fiscal.cod-estabel + "_EVT".
                   ELSE 
                      ASSIGN c-job-ndd = nota-fiscal.cod-estabel + "_EVT".
                END.
                IF i-job-ndd = 2 THEN
                   ASSIGN c-job-ndd = "HM_" + nota-fiscal.cod-estabel + "_EVT".
                IF i-job-ndd = 3 THEN
                   ASSIGN c-job-ndd = "TS_" + nota-fiscal.cod-estabel + "_EVT".*/

                create int-ndd-envio.
                assign int-ndd-envio.STATUSNUMBER = 0 /* A processar */
                       int-ndd-envio.JOB          = c-job-ndd
                       int-ndd-envio.DOCUMENTUSER = c-seg-usuario
                       int-ndd-envio.KIND         = 1 /* XML */
                       int-ndd-envio.cod-estabel  = nota-fiscal.cod-estabel 
                       int-ndd-envio.serie        = nota-fiscal.serie 
                       int-ndd-envio.nr-nota-fis  = nota-fiscal.nr-nota-fis 
                       int-ndd-envio.dt-envio     = today
                       int-ndd-envio.hr-envio     = time.
                
                copy-lob cXML to int-ndd-envio.DOCUMENTDATA.

                ASSIGN carta-correc-eletro.dsl-xml-armaz = cXML.

                release int-ndd-envio.
             
                create btt-epc.
                assign btt-epc.cod-event     = "TrataCCeEspec":U
                       btt-epc.cod-parameter = "XMLEspec":U.
                       
            end.
        end.
    end.
    RELEASE carta-correc-eletro.

end.

return "OK".

