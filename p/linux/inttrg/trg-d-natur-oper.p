/************************************************************************************
**   Programa: trg-d-natur-oper.p - Trigger de delete para a tabela natur-oper
**             Eliminar a tabela int-ds-natur-oper
**   Data....: Dezembro/2015
************************************************************************************/

DEF PARAM BUFFER b-natur-oper FOR natur-oper.

FOR EACH int_ds_natur_oper WHERE
         int_ds_natur_oper.nat_operacao = b-natur-oper.nat-operacao:
    DELETE int_ds_natur_oper.
END.

RETURN "OK".
