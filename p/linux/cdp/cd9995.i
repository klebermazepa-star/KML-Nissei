/***************************************************************
**
** cd9995.i - EPC para Evento definido pelo usu rio de SmartViewer 
** 
** {1} - Nome do evento
** {2} - Tipo de retorno caso haja erro (no-apply, "ADM-ERROR")
***************************************************************/ 

/* DPC */
if  c-nom-prog-dpc-mg97 <> "" then do:
    run value(c-nom-prog-dpc-mg97) (input "{1}",
                                    input "VIEWER":U,
                                    input THIS-PROCEDURE,
                                    input frame {&FRAME-NAME}:HANDLE,
                                    input "{&FIRST-EXTERNAL-TABLE}":U,
    &IF DEFINED(FIRST-EXTERNAL-TABLE) = 0 &THEN
                                    input ?).
    &ELSE
                                    input (if  avail {&FIRST-EXTERNAL-TABLE} then rowid({&FIRST-EXTERNAL-TABLE}) else ?)).
    &ENDIF
    
    if RETURN-VALUE = "NOK":U then
       return "{2}":U.
end.

/* APPC */
if  c-nom-prog-appc-mg97 <> "" then do:
    run value(c-nom-prog-appc-mg97) (input "{1}",
                                     input "VIEWER":U,
                                     input THIS-PROCEDURE,
                                     input frame {&FRAME-NAME}:HANDLE,
                                     input "{&FIRST-EXTERNAL-TABLE}":U,
    &IF DEFINED(FIRST-EXTERNAL-TABLE) = 0 &THEN
                                     input ?).
    &ELSE
                                     input (if  avail {&FIRST-EXTERNAL-TABLE} then rowid({&FIRST-EXTERNAL-TABLE}) else ?)).
    &ENDIF
    
    if RETURN-VALUE = "NOK":U then
       return "{2}":U.
end.

/* UPC */
if  c-nom-prog-upc-mg97 <> "" then do:
    run value(c-nom-prog-upc-mg97) (input "{1}",
                                    input "VIEWER":U,
                                    input THIS-PROCEDURE,
                                    input frame {&FRAME-NAME}:HANDLE,
                                    input "{&FIRST-EXTERNAL-TABLE}":U,
    &IF DEFINED(FIRST-EXTERNAL-TABLE) = 0 &THEN
                                    input ?).
    &ELSE
                                    input (if  avail {&FIRST-EXTERNAL-TABLE} then rowid({&FIRST-EXTERNAL-TABLE}) else ?)).
    &ENDIF
    
    if RETURN-VALUE = "NOK":U then
       return "{2}":U.
end.

/* cd9995.i */
