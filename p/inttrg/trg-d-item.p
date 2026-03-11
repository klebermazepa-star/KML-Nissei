/****************************************************************************************************
**   Programa: trg-d-item.p - Trigger de delete para a tabela item
**             Atualiza a tabela de integraá∆o de Itens entre Datasul e Sysfarma
**   Data....: Novembro/2015
*****************************************************************************************************/

def new global shared var c-seg-usuario as char no-undo.
 
DEF PARAM BUFFER b-item FOR ITEM.

CREATE int_ds_item.
ASSIGN int_ds_item.envio_status = 0
       int_ds_item.tipo_movto   = 3 /* Exclus∆o */
       int_ds_item.dt_geracao   = TODAY
       int_ds_item.hr_geracao   = STRING(TIME,"hh:mm:ss") 
       int_ds_item.cod_usuario  = c-seg-usuario
       int_ds_item.situacao     = 1 /* Pendente */
       int_ds_item.pro_codigo_n = int(b-item.it-codigo)
       int_ds_item.id_sequencial = NEXT-VALUE(seq-int-ds-item). /* Preparaá∆o para integraá∆o com Procfit */

FOR EACH int_ds_ext_item WHERE
         int_ds_ext_item.it_codigo = b-item.it-codigo:
    DELETE int_ds_ext_item.
END.

FOR EACH int_ds_ean_item WHERE
         int_ds_ean_item.it_codigo = b-item.it-codigo:
    DELETE int_ds_ean_item.
END.

FOR EACH int_ds_item_compl WHERE
         int_ds_item_compl.cba_produto_n = int(b-item.it-codigo):
    DELETE int_ds_item_compl.
END.

ASSIGN int_ds_item.envio_status = 1.

RELEASE int_ds_item.

RETURN "OK".
