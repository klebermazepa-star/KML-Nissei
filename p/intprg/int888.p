/********************************************************************************
**
**  Programa: int888.p - Controle e tratativa dos Logs de erros das Integra‡äes
**
********************************************************************************/

DEF INPUT PARAM p-origem   AS CHAR NO-UNDO.
DEF INPUT PARAM p-programa AS CHAR NO-UNDO.

FOR EACH int_ds_log WHERE
         int_ds_log.origem       = p-origem AND
         int_ds_log.cod_programa = p-programa AND
         int_ds_log.situacao     = 1 QUERY-TUNING(NO-LOOKAHEAD):
    DELETE int_ds_log.
END.

FOR EACH int_ds_log_aux WHERE
         int_ds_log_aux.origem       = p-origem   AND
         int_ds_log_aux.cod_programa = p-programa AND 
         int_ds_log_aux.situacao     = 1 QUERY-TUNING(NO-LOOKAHEAD):
    CREATE int_ds_log.
    BUFFER-COPY int_ds_log_aux TO int_ds_log.
END.

FOR EACH int_ds_log_aux WHERE
         int_ds_log_aux.origem       = p-origem AND
         int_ds_log_aux.cod_programa = p-programa QUERY-TUNING(NO-LOOKAHEAD):
    DELETE int_ds_log_aux.
END.


