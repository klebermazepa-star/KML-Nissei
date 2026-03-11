define input parameter item as character no-undo. 
define parameter buffer item-caixa for item-caixa.

find first item-caixa 
    where item-caixa.it-codigo = item
    no-lock no-error.
