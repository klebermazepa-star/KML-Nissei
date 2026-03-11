/****************************************************************************************************
**   Programa: trg-d-item-fornec.p - Trigger de delete para a tabela item-fornec
**             Atualiza a tabela de integraá∆o de Item x Fornecedor entre Datasul e Sysfarma
**   Data....: Dezembro/2015
*****************************************************************************************************/

def new global shared var c-seg-usuario as char no-undo.
 
DEF PARAM BUFFER b-item-fornec FOR item-fornec.

FIND FIRST emitente WHERE
           emitente.cod-emitente = b-item-fornec.cod-emitente NO-LOCK NO-ERROR.
IF AVAIL emitente THEN DO:
   IF emitente.identific > 1 THEN DO: /* Fornecedor e Ambos */   
      CREATE int_ds_item_fornec.
      ASSIGN int_ds_item_fornec.tipo_movto   = 3 /* Exclus∆o */
             int_ds_item_fornec.dt_geracao   = TODAY
             int_ds_item_fornec.hr_geracao   = STRING(TIME,"hh:mm:ss") 
             int_ds_item_fornec.cod_usuario  = c-seg-usuario
             int_ds_item_fornec.situacao     = 1 /* Pendente */
             int_ds_item_fornec.codigo       = b-item-fornec.cod-emitente
             int_ds_item_fornec.pro_codigo_n = INT(b-item-fornec.it-codigo) 
             int_ds_item_fornec.alternativo  = INT(b-item-fornec.item-do-forn)
             int_ds_item_fornec.item_do_forn = b-item-fornec.item-do-forn
             int_ds_item_fornec.envio_status = 2.
   END.
END.

RETURN "OK".

