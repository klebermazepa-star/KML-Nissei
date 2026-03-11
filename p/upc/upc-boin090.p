
{utp/ut-glob.i}
{include/i-epc200.i boin090} 

DEF INPUT PARAM  p-ind-event AS  CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc.

DEF VAR c-cod-emitente AS CHAR NO-UNDO.
DEF VAR c-nat-operacao AS CHAR NO-UNDO.
DEF VAR c-nro-docto    AS CHAR NO-UNDO.
DEF VAR c-serie-docto  AS CHAR NO-UNDO.


DEFINE VARIABLE r-docum-est AS ROWID       NO-UNDO.
DEF BUFFER bf-docum-est FOR docum-est.


/*def var c-msg as char no-undo.
assign c-msg = "".
for each tt-epc:
    if c-msg <> "" then
        assign c-msg = c-msg + chr(10).
    assign c-msg = c-msg + tt-epc.cod-parameter + '=' + tt-epc.val-parameter.
end.
MESSAGE 'p-ind-event: ' p-ind-event skip
    '1: ' PROGRAM-NAME(1) SKIP
    '2: ' PROGRAM-NAME(2) SKIP
    '3: ' PROGRAM-NAME(3) SKIP
    '4: ' PROGRAM-NAME(4) SKIP
    '5: ' PROGRAM-NAME(5) SKIP
    '6: ' PROGRAM-NAME(6) SKIP skip
    c-msg
    VIEW-AS ALERT-BOX.*/


FIND  tt-epc
WHERE tt-epc.cod-event     = 'beforeDeleteRecord' 
AND   tt-epc.cod-parameter = 'Table-Rowid' NO-ERROR.

DEFINE BUFFER bf-es-contrato-docum FOR es-contrato-docum.
IF AVAIL tt-epc THEN DO:

   ASSIGN r-docum-est =  TO-ROWID(tt-epc.val-parameter).

   FIND FIRST bf-docum-est EXCLUSIVE-LOCK
        WHERE ROWID(bf-docum-est) = r-docum-est NO-ERROR.

   IF AVAIL bf-docum-est THEN DO:

       FIND FIRST es-contrato-docum NO-LOCK
            WHERE es-contrato-docum.serie-docto  = bf-docum-est.serie-docto 
            AND   es-contrato-docum.nro-docto    = bf-docum-est.nro-docto   
            AND   es-contrato-docum.cod-emitente = bf-docum-est.cod-emitente
            AND   es-contrato-docum.nat-operacao = bf-docum-est.nat-operacao
                  NO-ERROR.

       IF AVAIL es-contrato-docum THEN DO:

           FIND FIRST bf-es-contrato-docum EXCLUSIVE-LOCK
               WHERE ROWID(bf-es-contrato-docum) = ROWID(es-contrato-docum) NO-ERROR.

           IF AVAIL bf-es-contrato-docum THEN
                ASSIGN bf-es-contrato-docum.dt-integracao = ?.

           RELEASE bf-es-contrato-docum.

       END.
          

   END.



END.




RETURN "OK".
