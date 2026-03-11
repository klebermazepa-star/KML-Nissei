/******************************************************************************
**
**  Include.: cd1234.i3 
**  Objetivo: Funá∆o de convers∆o de moedas em Portugal 
**  13.03.2000
******************************************************************************/  
  
  if p-mo-origem <> 0 then
       find tt-mo-portugal 
            where tt-mo-portugal.cod-moeda = p-mo-origem exclusive-lock no-error.
    else                                
       find tt-mo-portugal
            where tt-mo-portugal.cod-moeda = p-mo-destino exclusive-lock no-error.
            
    if not avail tt-mo-portugal then do:
        if p-mo-origem <> 0 then do:
            find moeda where moeda.mo-codigo = p-mo-origem no-lock no-error.
            if avail moeda then
                create tt-mo-portugal.
                assign tt-mo-portugal.cod-moeda               = moeda.mo-codigo
                       tt-mo-portugal.ind-fator-md            = moeda.ind-fator-md.
            end.           
        else  do:         
            find moeda where moeda.mo-codigo = p-mo-destino no-lock no-error.
            if avail moeda then 
                create tt-mo-portugal.
                assign tt-mo-portugal.cod-moeda              = moeda.mo-codigo
                       tt-mo-portugal.ind-fator-md           = moeda.ind-fator-md.
        end.               
    end.
    if p-mo-destino = 0 then do:
        if tt-mo-portugal.ind-fator-md = no then /* fator divisivo */
                    /* usa-se o inverso quando a moeda destino Ç 0 - local */
            return (p-valor * p-cotacao).
        else
            return (p-valor / p-cotacao).
    end.
    else do:
        if tt-mo-portugal.ind-fator-md = no then /* fator divisivo */
                    /* usa-se o inverso quando a moeda destino Ç 0 -local */
             return (p-valor / p-cotacao).
        else do:
             return (p-valor * p-cotacao).
        end.
end.
