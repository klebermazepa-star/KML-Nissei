/****************************************************************************************************
**   Programa: trg-d-comp-folh.p - Trigger de delete para a tabela comp-folh
**             Elimina a tabela espec¡fica int_ds_ext_comp_folh
*****************************************************************************************************/

DEF PARAM BUFFER b-comp-folh FOR comp-folh.

FOR EACH int_ds_ext_comp_folh WHERE
         int_ds_ext_comp_folh.cd_folha = b-comp-folh.cd-folha AND
         int_ds_ext_comp_folh.cd_comp  = b-comp-folh.cd-comp:
    DELETE int_ds_ext_comp_folh.
END.

RETURN "OK".
