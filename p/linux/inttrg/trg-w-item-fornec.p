 /****************************************************************************************************
**   Programa: trg-w-item-fornec.p - Trigger de write para a tabela item-fornec
**             Atualiza a tabela de integraá∆o de Item x Fornecedor entre Datasul e Sysfarma
**   Data....: Dezembro/2015
*****************************************************************************************************/

def new global shared var c-seg-usuario as char no-undo.
 
DEF PARAM BUFFER b-item-fornec     FOR item-fornec.
DEF PARAM BUFFER b-old-item-fornec FOR item-fornec.

DEF VAR i-pro_codigo_n LIKE int_ds_item_fornec.pro_codigo_n NO-UNDO.
DEF VAR i-alternativo  LIKE int_ds_item_fornec.alternativo  NO-UNDO.

FIND FIRST emitente WHERE
           emitente.cod-emitente = b-item-fornec.cod-emitente NO-LOCK NO-ERROR.
IF AVAIL emitente THEN DO:
   IF emitente.identific > 1 THEN DO: /* Fornecedor e Ambos */
      
      ASSIGN i-pro_codigo_n = INT(b-item-fornec.it-codigo) NO-ERROR.
      ASSIGN i-alternativo  = INT(b-item-fornec.item-do-forn) NO-ERROR.

      CREATE int_ds_item_fornec.
      ASSIGN int_ds_item_fornec.tipo_movto   = IF b-item-fornec.cod-emitente <>
                                                  b-old-item-fornec.cod-emitente THEN
                                                  1 /* Inclus∆o */
                                               ELSE
                                                  2 /* Alteraá∆o */
             int_ds_item_fornec.dt_geracao   = TODAY
             int_ds_item_fornec.hr_geracao   = STRING(TIME,"hh:mm:ss") 
             int_ds_item_fornec.cod_usuario  = c-seg-usuario
             int_ds_item_fornec.situacao     = 1 /* Pendente */
             int_ds_item_fornec.codigo       = b-item-fornec.cod-emitente
             int_ds_item_fornec.pro_codigo_n = i-pro_codigo_n 
             int_ds_item_fornec.alternativo  = i-alternativo 
             int_ds_item_fornec.equivalencia = b-item-fornec.lote-mul-for
             int_ds_item_fornec.cnpj_cpf     = substr(emitente.cgc,1,18)
             int_ds_item_fornec.item_do_forn = b-item-fornec.item-do-forn
             int_ds_item_fornec.envio_status = 2.

      /*FOR FIRST int-ds-ean-item WHERE 
                int-ds-ean-item.it-codigo = b-item-fornec.it-codigo AND 
                int-ds-ean-item.principal = YES NO-LOCK:
      END.
      IF AVAIL int-ds-ean-item THEN
         ASSIGN int_ds_item_fornec.codigobarras = int-ds-ean-item.codigo-ean.*/

   END.
END.

RETURN "OK".
