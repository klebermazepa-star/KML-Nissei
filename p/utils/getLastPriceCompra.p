/* utils/getLastPriceCompra */

define input parameter estab as character no-undo. 
define input parameter item  as character no-undo.
define input parameter data  as date      no-undo.
define output parameter valor as decimal   no-undo.

define query q-movto-estoq
    for movto-estoq
    fields (cod-emitente quantidade nat-operacao serie-docto
            nro-docto    it-codigo  sequen-nf    dt-trans).

open query q-movto-estoq
    for each movto-estoq
        where movto-estoq.it-codigo   = item
          and movto-estoq.cod-estabel = estab
          and movto-estoq.dt-trans   <= data
          and movto-estoq.esp-docto   = {ininc/i03in218.i 6 'NFE'}
        no-lock
        by movto-estoq.dt-trans desc.

get first q-movto-estoq no-lock.

if avail movto-estoq then do:
    for first item-doc-est
        where item-doc-est.serie-docto  = movto-estoq.serie-docto
          and item-doc-est.nro-docto    = movto-estoq.nro-docto
          and item-doc-est.cod-emitente = movto-estoq.cod-emitente
          and item-doc-est.nat-operacao = movto-estoq.nat-operacao
          and item-doc-est.it-codigo    = movto-estoq.it-codigo
          and item-doc-est.sequencia    = movto-estoq.sequen-nf
        no-lock:

        assign
            valor = (item-doc-est.preco-total[1] - item-doc-est.desconto[1])
                  / item-doc-est.quantidade.
    end.
end.

return.
