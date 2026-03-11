/****************************************************************************************************
**   Programa: trg-d-emitente.p - Trigger de delete para a tabela emitente
**             Atualiza a tabela de integraá∆o de Fornecedores entre Datasul e Sysfarma
**   Data....: Novembro/2015
*****************************************************************************************************/

def new global shared var c-seg-usuario as char no-undo.
 
DEF PARAM BUFFER b-emitente FOR emitente.

IF b-emitente.identific > 1 THEN DO: /* Fornecedor e Ambos */
   CREATE int_ds_fornecedor.
   ASSIGN int_ds_fornecedor.envio_status  = 0
          int_ds_fornecedor.tipo_movto    = 3 /* Exclus∆o */
          int_ds_fornecedor.dt_geracao    = TODAY
          int_ds_fornecedor.hr_geracao    = STRING(TIME,"hh:mm:ss") 
          int_ds_fornecedor.cod_usuario   = c-seg-usuario
          int_ds_fornecedor.situacao      = 1 /* Pendente */
          int_ds_fornecedor.codigo        = b-emitente.cod-emitente
          int_ds_fornecedor.nome          = substr(b-emitente.nome-emit,1,50)
          int_ds_fornecedor.cnpj          = substr(b-emitente.cgc,1,18)
          int_ds_fornecedor.nome_abrev    = b-emitente.nome-abrev
          int_ds_fornecedor.id_sequencial = NEXT-VALUE(seq-int-ds-fornecedor). /* Preparaá∆o para integraá∆o com Procfit */

   FOR EACH int_ds_leadtime_fornec USE-INDEX emit_estab WHERE
            int_ds_leadtime_fornec.cod_emitente = b-emitente.cod-emitente:
       DELETE int_ds_leadtime_fornec.
   END.

   FOR EACH int_ds_ext_emitente WHERE 
            int_ds_ext_emitente.cod_emitente = b-emitente.cod-emitente:
       DELETE int_ds_ext_emitente.
   END.

   ASSIGN int_ds_fornecedor.envio_status = 1.

   RELEASE int_ds_fornecedor.

END.

RETURN "OK".


