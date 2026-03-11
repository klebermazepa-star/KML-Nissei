/****************************************************************************
**
**     Programa: upc-ft2100a.p
**
**     Objetivo: Atualizar o movimento de estoque com o valor do item na nota
**
**     Autor...: Geovane Hil rio Linzmeyer
**
**     Data....: 04 de Janeiro de 2024
**
**     Versao..: 1.00.00.001 - Geovane Hilario Linzmeyer
**
****************************************************************************/

{utp/ut-glob.i}.
{include/i-epc200.i1}.

def input param p-ind-event as char no-undo.
def input-output param table for tt-epc.

def var r-it-nota-fisc   as rowid     no-undo.
def var h-tt-movto       as handle    no-undo.
def var h-buffer         as handle    no-undo.
def var h-query          as handle    no-undo.
def var h-item           as handle    no-undo.
def var h-seq            as handle    no-undo.
def var h-valor          as handle    no-undo.
def var h-estab          as handle    no-undo.
def var h-serie          as handle    no-undo.
def var h-docto          as handle    no-undo.
def var i-conta          as integer   no-undo.
def var l-valoriza-medio as logical   no-undo.

def stream str-log.

if p-ind-event = "TIPO-VALORIZA" then do:

   find first tt-epc where
              tt-epc.cod-event     = "TIPO-VALORIZA" and
              tt-epc.cod-parameter = "rw-it-nota-fisc" no-error.
   if avail tt-epc then do:
      assign r-it-nota-fisc = to-rowid(tt-epc.val-parameter).

      for first it-nota-fisc no-lock where
          rowid(it-nota-fisc) = r-it-nota-fisc:

         find first int_ds_natur_oper no-lock where
                    int_ds_natur_oper.nat_operacao = it-nota-fisc.nat-operacao no-error.

         /* flag especifico */
         if avail int_ds_natur_oper and
            int_ds_natur_oper.trata_valoriza then do:

            IF int_ds_natur_oper.id_valoriza = 2 THEN DO:
           
                assign l-valoriza-medio = NO.

                create tt-epc.
                assign tt-epc.cod-event     = "TIPO-VALORIZA"
                       tt-epc.cod-parameter = "VALORIZA-MEDIO"
                       tt-epc.val-parameter = string(l-valoriza-medio).
            END.
         end.
      end.
   end.
end.

if p-ind-event = "atualizadadosttmovto" then do:
   find first tt-epc where
              tt-epc.cod-event     = "atualizadadosttmovto" and
              tt-epc.cod-parameter = "tt-movto" no-error.
   if avail tt-epc then do:
      assign h-tt-movto = handle(tt-epc.val-parameter).
   end.
   if valid-handle(h-tt-movto) then do:
      assign h-buffer = h-tt-movto:default-buffer-handle.

      create query h-query.
      h-query:set-buffers(h-buffer).
      h-query:query-prepare("for each tt-movto").
      h-query:query-open.

      repeat:
         assign h-item  = h-buffer:buffer-field("it-codigo")
                h-seq   = h-buffer:buffer-field("sequen-nf")
                h-valor = h-buffer:buffer-field("valor-mat-m")
                h-estab = h-buffer:buffer-field("cod-estabel")
                h-serie = h-buffer:buffer-field("serie-docto")
                h-docto = h-buffer:buffer-field("nro-docto").
         for first it-nota-fisc no-lock where
                   it-nota-fisc.cod-estabel = h-estab:buffer-value and
                   it-nota-fisc.serie       = h-serie:buffer-value and
                   it-nota-fisc.nr-nota-fis = h-docto:buffer-value and
                   it-nota-fisc.it-codigo   = h-item:buffer-value  and
                   it-nota-fisc.nr-seq-fat  = h-seq:buffer-value:

            find first int_ds_natur_oper no-lock 
                WHERE int_ds_natur_oper.nat_operacao = it-nota-fisc.nat-operacao no-error.

             /* flag especifico */
             if avail int_ds_natur_oper and
                int_ds_natur_oper.trata_valoriza then do:

                 IF int_ds_natur_oper.id_valoriza = 2 THEN DO:

                     assign h-valor:buffer-value(1) = it-nota-fisc.vl-tot-item.

                 END.
                    

             END.
         end.
         h-query:get-next().
         if h-query:query-off-end then 
            leave.
      end.
   end.
end.

return 'ok'.

/* Fim do Programa */

