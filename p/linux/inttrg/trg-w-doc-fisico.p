/****************************************************************************************************
**   Programa: trg-w-doc-fisico.p - Trigger de write para a tabela doc-fisico
**             Executa o programa int100.p - Gera Nota de Devolu‡Æo para itens com divergˆncia na
**             conferˆncia feita pelo WMS - PRS
**   Data....: Fevereiro/2016
*****************************************************************************************************/

DEF PARAM BUFFER b-doc-fisico     FOR doc-fisico.
DEF PARAM BUFFER b-old-doc-fisico FOR doc-fisico.

FIND FIRST int_ds_docto_wms WHERE
           int_ds_docto_wms.doc_numero_n = INT(b-doc-fisico.nro-docto) AND
           int_ds_docto_wms.doc_serie_s  = b-doc-fisico.serie-docto    AND
           int_ds_docto_wms.doc_origem_n = b-doc-fisico.cod-emitente NO-ERROR.
IF AVAIL int_ds_docto_wms THEN 
   ASSIGN int_ds_docto_wms.situacao = 3. /* Liberado - Nota atualizada no Estoque */

/*RUN intprg/int100.p (INPUT b-doc-fisico.serie-docto,
                     INPUT b-doc-fisico.nro-docto,
                     INPUT b-doc-fisico.cod-emitente).*/

RETURN "OK".
