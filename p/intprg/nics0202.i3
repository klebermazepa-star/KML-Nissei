/*****************************************************************************
**    NICS0202.I3 - Rotina de Impressao dos Custos dos Itens por Item
*****************************************************************************/

for each item where
    item.it-codigo >= c-item-ini and item.it-codigo <= c-item-fim and
    item.ge-codigo >= i-grupo-ini and item.ge-codigo <= i-grupo-fim and
    item.fm-codigo >= c-familia-ini and item.fm-codigo <= c-familia-fim and
    item.desc-item >= c-descr-ini and item.desc-item <= c-descr-fim and
    item.inform-compl >= c-inf-ini and item.inform-compl <= c-inf-fim and
    item.data-implant >= d-data-ini and item.data-implant <= d-data-fim no-lock
    &IF DEFINED (bf_man_custeio_item) &THEN
        , first item-uni-estab where
                item-uni-estab.it-codigo   = item.it-codigo and
                item-uni-estab.cod-estabel = tt-param.cod-estabel no-lock
    &ENDIF    
    on stop undo, leave:
    view frame f-cabec-255.
    view frame f-rodape-255.   
    
    if c-opcao-obs = "2" and item.cod-obsoleto > 1 then
        next.
    if c-opcao-obs = "3" and item.cod-obsoleto = 1 then
        next.
    {intprg/nics0202.i5}

end.

/* Fim do Include */
