/******************************************************************************************
**  Programa: epc-re0402rp.p
******************************************************************************************/
              
{include/i-epc200.i re0402rp}

DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc. 
    
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

DEF BUFFER b-docum-est FOR docum-est.

IF p-ind-event = "NAO-DESATUALIZA" THEN DO:
    FIND FIRST tt-epc WHERE 
               tt-epc.cod-event     = p-ind-event AND
               tt-epc.cod-parameter = "ROWID-DOCUM-EST" NO-ERROR.
    IF AVAIL tt-epc THEN DO:
       FIND FIRST b-docum-est WHERE
                  ROWID(b-docum-est) = TO-ROWID(tt-epc.val-parameter) NO-LOCK NO-ERROR.
       IF AVAIL b-docum-est THEN DO:
          FIND FIRST int_ds_ext_param_re WHERE
                     int_ds_ext_param_re.usuario = c-seg-usuario NO-LOCK NO-ERROR.
          IF AVAIL int_ds_ext_param_re THEN DO:
             IF b-docum-est.dt-trans < int_ds_ext_param_re.dt_entrada_nf THEN DO:
                RETURN "NOK".
             END.
             ELSE DO:
                RETURN "OK".
             END.
          END.
       END.
    END.
END. 

RETURN "OK".
     

