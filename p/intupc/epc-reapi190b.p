/******************************************************************************************
**  Programa: epc-reapi190b.p
**   
**  Objetivo: Rec lculo PIS/COFINS 
******************************************************************************************/      
          
{include/i-epc200.i reapi190b}

define input param p-ind-event as char no-undo.
define input param table for tt-epc. 

def var c-rowid as char no-undo.

if p-ind-event  = "fim-reapi190"
then do:    

    for first tt-epc where 
        tt-epc.cod-event     = p-ind-event and   
        tt-epc.cod-parameter = "docum-est rowid": 
        assign c-rowid = tt-epc.val-parameter.
    end.
    for first docum-est where 
        rowid(docum-est) = to-rowid(c-rowid):

        for each item-doc-est of docum-est:
            
            for first natur-oper fields (nat-operacao mercado perc-pis per-fin-soc char-1)
                no-lock where natur-oper.nat-operacao = item-doc-est.nat-operacao: end.
            for first item fields (char-2 it-codigo)
                no-lock where item.it-codigo = item-doc-est.it-codigo: end.

            /* Tributa‡Æo PIS    */ 
            assign item-doc-est.idi-tributac-pis = int(substr(natur-oper.char-1,86,1)).

            /* Aliquota PIS      */ 
            assign item-doc-est.val-aliq-pis = 0.
            if item-doc-est.idi-tributac-pis = 1 then do:
                if natur-oper.mercado = 1 then                         /* Mercado Interno */
                    if substr(item.char-2,52,1) = "1" then             /* Al¡quota do Item */
                        assign item-doc-est.val-aliq-pis = dec(substr(item.char-2,31,5)).
                    else /* aliquota da natureza*/
                        assign item-doc-est.val-aliq-pis = natur-oper.perc-pis[1].
                else  /* Mercado externo */
                    assign item-doc-est.val-aliq-pis = natur-oper.perc-pis[2].

                assign item-doc-est.base-pis  = item-doc-est.preco-total[1] + item-doc-est.despesas[1] - item-doc-est.desconto[1]
                       item-doc-est.valor-pis = item-doc-est.base-pis * item-doc-est.val-aliq-pis / 100.
            end.
            /* sem aliquota deve ficar como isento */
            if item-doc-est.val-aliq-pis = 0 then do:
                assign item-doc-est.idi-tributac-pis = 2
                       item-doc-est.base-pis         = 0
                       item-doc-est.valor-pis        = 0.
            end.
            /* Tributa‡Æo COFINS */
            assign item-doc-est.idi-tributac-cofins = int(substr(natur-oper.char-1,87,1)).

            /* Aliquota COFINS   */ 
            assign item-doc-est.val-aliq-cofins = 0.
            if item-doc-est.val-aliq-cofins = 1 then do:
                if natur-oper.mercado = 1 then                    /* Mercado Interno */               
                    if substr(item.char-2,53,1) = "1" then        /* aliquota do item */
                        assign item-doc-est.val-aliq-cofins = dec(substr(item.char-2,36,5)).
                    else /* aliquota da natureza*/
                        assign item-doc-est.val-aliq-cofins = natur-oper.per-fin-soc[1].
                else /* Mercado externo */ 
                    assign item-doc-est.val-aliq-cofins = natur-oper.per-fin-soc[2].

                
                assign item-doc-est.base-cofins = item-doc-est.preco-total[1] + item-doc-est.despesas[1] - item-doc-est.desconto[1]
                       item-doc-est.val-cofins  = item-doc-est.base-cofins * item-doc-est.val-aliq-cofins / 100.
            end.
            /* sem aliquota deve ficar como isento */
            if item-doc-est.val-aliq-cofins = 0 then do:
                assign item-doc-est.idi-tributac-cofins = 2
                       item-doc-est.base-cofins         = 0
                       item-doc-est.val-cofins          = 0.
            end.
        end.
    end.
end. 

return "OK".
     
