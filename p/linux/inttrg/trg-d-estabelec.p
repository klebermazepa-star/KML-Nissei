/****************************************************************************************************
**   Programa: trg-d-estabelec.p - Trigger de delete para a tabela estabelec
**             Elimina a tabela espec¡fica int_ds_leadtime_fornec (lead time fornec. por estabelec.)
**   Data....: Mar‡o/2016
*****************************************************************************************************/

def new global shared var c-seg-usuario as char no-undo.
 
DEF PARAM BUFFER b-estabelec FOR estabelec.

FOR EACH int_ds_leadtime_fornec USE-INDEX estab_emit WHERE
         int_ds_leadtime_fornec.cod_estabel = b-estabelec.cod-estabel:
    DELETE int_ds_leadtime_fornec.
END.

RETURN "OK".
