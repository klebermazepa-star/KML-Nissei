        
define input parameter cItComponente as character no-undo. 
define input parameter cItPai as character no-undo. 
            
run isComponenteOf(input cItComponente, input cItPai).

return return-value.

/* end */


procedure isComponenteOf private:
    define input parameter cItComponente as character no-undo. 
    define input parameter cItPai as character no-undo. 

    for each estrutura
        where estrutura.it-codigo = cItPai
        no-lock:

        if estrutura.es-codigo = cItComponente then
            return 'ok':u.

        run isComponenteOf(input cItComponente, input estrutura.es-codigo).

        if return-value = 'ok':u then
            return return-value.
    end.

    return 'nok':u.
end.
