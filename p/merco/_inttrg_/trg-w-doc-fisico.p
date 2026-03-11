/****************************************************************************************************
**   Programa: trg-w-doc-fisico.p - Trigger de write para a tabela doc-fisico
**             Executa o programa int100.p - Gera Nota de Devolu‡Æo para itens com divergˆncia na
**             conferˆncia feita pelo WMS - PRS
**   Data....: Fevereiro/2016
*****************************************************************************************************/

DEF PARAM BUFFER b-doc-fisico     FOR doc-fisico.
DEF PARAM BUFFER b-old-doc-fisico FOR doc-fisico.

/* KML Consultoria Guilherme Nichele - 13/06/2024 - Criar tabela de altera‡Æo para leitura do BI */

FIND FIRST b-doc-fisico  NO-ERROR.

IF AVAIL b-doc-fisico THEN
 DO:
 
   /* CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "doc-fisico"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.serie-docto = b-doc-fisico.serie-docto
           esp-alteracao-bi.nro-docto = b-doc-fisico.nro-docto
           esp-alteracao-bi.cod-emitente = b-doc-fisico.cod-emitente
           esp-alteracao-bi.tipo-nota = b-doc-fisico.tipo-nota.
         */                 
         
 END.

FIND FIRST int_ds_docto_wms WHERE
           int_ds_docto_wms.doc_numero_n = b-doc-fisico.nro-docto   AND
           int_ds_docto_wms.doc_serie_s  = b-doc-fisico.serie-docto AND
           int_ds_docto_wms.doc_origem_n = b-doc-fisico.cod-emitente NO-ERROR.
IF AVAIL int_ds_docto_wms THEN 
   ASSIGN int_ds_docto_wms.situacao = 3. /* Liberado - Nota atualizada no Estoque */

/*RUN intprg/int100.p (INPUT b-doc-fisico.serie-docto,
                     INPUT b-doc-fisico.nro-docto,
                     INPUT b-doc-fisico.cod-emitente).*/

RETURN "OK".
