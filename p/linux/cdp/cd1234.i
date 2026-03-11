/******************************************************************************
**
**  Include.: cd1234.i 
**  Objetivo: Tratamento para n£mero de casas decimais 
**  24.09.99
******************************************************************************/

def new global shared temp-table tt-moedas
    field cod-moeda            as integer
    field qtd-decimais         as integer
    field ind-tratamento-infor as integer
    field ind-tratamento-calc  as integer.

def var l-rejeita-dec as logical.

function FN_AJUST_DEC returns decimal (p-valor as decimal, p-moeda as integer).

    &if '{&mguni_version}' < "2.03" &then
        if not can-find(funcao no-lock where funcao.cd-funcao = "spp_ajusta_dec") then
            return (p-valor).
    &endif

    find tt-moedas 
        where tt-moedas.cod-moeda = p-moeda no-error.
    if not avail tt-moedas then do:
        find mguni.moeda no-lock where mguni.moeda.mo-codigo = p-moeda no-error.
        create tt-moedas.
        &if '{&mguni_version}' < "2.02" &then
            assign tt-moedas.cod-moeda            = mguni.moeda.mo-codigo
                   tt-moedas.qtd-decimais         = mguni.moeda.int-1
                   tt-moedas.ind-tratamento-infor = mguni.moeda.int-2
                   tt-moedas.ind-tratamento-calc  = mguni.moeda.dec-1.
        &else
            assign tt-moedas.cod-moeda            = mguni.moeda.mo-codigo
                   tt-moedas.qtd-decimais         = mguni.moeda.qtd-dec
                   tt-moedas.ind-tratamento-infor = mguni.moeda.ind-val-infor
                   tt-moedas.ind-tratamento-calc  = mguni.moeda.ind-val-calc.
        &endif
    end.

    if tt-moedas.qtd-decimais = 2 then
        return (p-valor).   

    if tt-moedas.ind-tratamento-calc = 1 then
        return (round(p-valor, tt-moedas.qtd-decimais)).
    else
        return (truncate(p-valor, tt-moedas.qtd-decimais)).

end function.

function FN_VLD_AJUST_DEC returns decimal (p-valor as decimal, p-moeda as integer).

    &if '{&mguni_version}' < "2.03" &then
        if not can-find(funcao no-lock where funcao.cd-funcao = "spp_ajusta_dec") then
            return (p-valor).
    &endif

    find tt-moedas
        where tt-moedas.cod-moeda = p-moeda no-error.
    if not avail tt-moedas then do:
        find mguni.moeda no-lock where mguni.moeda.mo-codigo = p-moeda no-error.
        create tt-moedas.
        &if '{&mguni_version}' < "2.02" &then
            assign tt-moedas.cod-moeda            = mguni.moeda.mo-codigo
                   tt-moedas.qtd-decimais         = mguni.moeda.int-1
                   tt-moedas.ind-tratamento-infor = mguni.moeda.int-2
                   tt-moedas.ind-tratamento-calc  = mguni.moeda.dec-1.
        &else
            assign tt-moedas.cod-moeda            = mguni.moeda.mo-codigo
                   tt-moedas.qtd-decimais         = mguni.moeda.qtd-dec
                   tt-moedas.ind-tratamento-infor = mguni.moeda.ind-val-infor
                   tt-moedas.ind-tratamento-calc  = mguni.moeda.ind-val-calc.
        &endif
    end.

    if tt-moedas.qtd-decimais = 2 then
        return (p-valor).

    case tt-moedas.ind-tratamento-infor:
        when 1 then 
            return (round(p-valor, tt-moedas.qtd-decimais)).
        when 2 then 
            return (truncate(p-valor, tt-moedas.qtd-decimais)).
        when 3 then do:
            if (truncate(p-valor, tt-moedas.qtd-decimais) <> p-valor) then
                assign l-rejeita-dec = yes.
            return (p-valor).
        end.
    end.

end function.
