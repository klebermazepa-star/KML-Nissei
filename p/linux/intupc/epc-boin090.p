/*****************************************************************************
**  Programa : epc-boin090.p
******************************************************************************/                             

{include/i-epc200.i1}
{method/dbotterr.i} /** Definicao temp-table rowErrors **/

DEF INPUT        PARAM p-ind-event  AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE        FOR tt-epc. 

/*** Definicao de Variaveis ***/
DEFINE VARIABLE h-boin090       as HANDLE  NO-UNDO.

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

{inbo/boin090.i tt-docum-est}

/*MESSAGE p-ind-event " p-ind-event" SKIP
        PROGRAM-NAME(1)" PROGRAM-NAME(1) " skip
        PROGRAM-NAME(2)" PROGRAM-NAME(2) " skip
        PROGRAM-NAME(3)" PROGRAM-NAME(3) " skip
        PROGRAM-NAME(4)" PROGRAM-NAME(4) " skip
        PROGRAM-NAME(5)" PROGRAM-NAME(5) " skip
        PROGRAM-NAME(6)" PROGRAM-NAME(6) " skip
        PROGRAM-NAME(7)" PROGRAM-NAME(7) " skip
        PROGRAM-NAME(8)" PROGRAM-NAME(8) " skip
        VIEW-AS ALERT-BOX.*/

IF (p-ind-event = "ValidateRecord" AND PROGRAM-NAME(5) = "saveRecord rep/re1001a.w") 
OR (p-ind-event = "ValidateRecord" AND PROGRAM-NAME(5) = "saveRecord rep/re1001a1.w") THEN DO:    

    FIND FIRST tt-epc NO-LOCK WHERE 
               tt-epc.cod-event     = p-ind-event AND
               tt-epc.cod-parameter = "OBJECT-HANDLE" NO-ERROR.
    
    IF AVAIL tt-epc THEN DO:

        ASSIGN h-boin090 = WIDGET-HANDLE(tt-epc.val-parameter).
    
        RUN getRecord IN h-boin090 (OUTPUT TABLE tt-docum-est).
    
        FIND FIRST tt-docum-est NO-LOCK NO-ERROR.
    END.    

    IF AVAIL tt-docum-est THEN DO:

       FIND FIRST int_ds_ext_param_re WHERE
                  int_ds_ext_param_re.usuario = c-seg-usuario NO-LOCK NO-ERROR.
       IF AVAIL int_ds_ext_param_re THEN DO:
          IF tt-docum-est.dt-trans < int_ds_ext_param_re.dt_entrada_nf THEN DO:
             RUN _insertErrorManual IN h-boin090(INPUT 0,
                                                 INPUT "EMS",
                                                 INPUT "error",
                                                 INPUT "Data de transa‡Æo " + string(tt-docum-est.dt-trans,"99/99/9999") + " inferior a data permitida para a entrada do documento " + string(int_ds_ext_param_re.dt_entrada_nf,"99/99/9999"),
                                                 INPUT "Verifique os Parƒmetros do Recebimento (RE0101) para o Usu rio " + c-seg-usuario,
                                                 INPUT "").
          END.
       END.
    END.
END.

RETURN "OK".
