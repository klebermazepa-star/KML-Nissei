/************************************************************************************
**   Programa: trg-d-param-re.p - Trigger de delete para a tabela param-re
**             Eliminar a tabela int-ds-ext-param-re
**   Data....: Janeiro/2016
************************************************************************************/

DEF PARAM BUFFER b-param-re FOR param-re.

FOR EACH int_ds_ext_param_re WHERE
         int_ds_ext_param_re.usuario = b-param-re.usuario:
    DELETE int_ds_ext_param_re.
END.

RETURN "OK".
