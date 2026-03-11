
        
define input parameter cItComponente as character no-undo. 
define input parameter cItPai as character no-undo. 
            
run isFantasmaOf(input cItComponente, input cItPai).

return return-value.

/* end */


procedure isFantasmaOf private:
    define input parameter cItComponente as character no-undo. 
    define input parameter cItPai as character no-undo. 

    for each estrutura
        where estrutura.it-codigo = cItPai
        no-lock:

        if estrutura.es-codigo = cItComponente then
            return string(estrutura.fantasma, 'ok/nok':u).

        run isFantasmaOf(input cItComponente, input estrutura.es-codigo).

        if return-value = 'ok':u or return-value = 'nok':u then
            return return-value.
    end.

    return 'error':u.
end.

