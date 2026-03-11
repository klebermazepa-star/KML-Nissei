define input param p-wgh-frame  as widget-handle no-undo.

define variable cod_portador  as widget-handle no-undo.
define variable fcod_portador as widget-handle no-undo.

define variable cod_estab_bord as widget-handle no-undo.
define variable num_bord_ap    as widget-handle no-undo.
define variable codigoBordero  as integer   no-undo.


run utils/findWidget.p('cod_portador', 'fill-in', p-wgh-frame, output cod_portador).
run utils/findWidget.p('fcod_portador', 'fill-in', p-wgh-frame, output fcod_portador).


if valid-handle(fcod_portador) and valid-handle(cod_portador) then do:
    cod_portador:screen-value = fcod_portador:screen-value.
    apply 'leave':u to cod_portador.

    run utils/findWidget.p('cod_estab_bord', 'fill-in', p-wgh-frame, output cod_estab_bord).
    run utils/findWidget.p('num_bord_ap', 'fill-in', p-wgh-frame, output num_bord_ap).
    
    /*Captura o menor n£mero dispon¡vel para boreros pelo estabelecimento e portador*/
    assign codigoBordero = 0.

    for each bord_ap
        where bord_ap.cod_estab_bord = trim(cod_estab_bord:screen-value)
          and bord_ap.cod_portador   = trim(cod_portador:screen-value)
        no-lock
        by bord_ap.num_bord_ap  
        :

        if (codigoBordero + 1) = bord_ap.num_bord_ap then do:
            assign codigoBordero = codigoBordero + 1.
            next.
        end.
        
        if not can-find( first compl_movto_pagto
            where compl_movto_pagto.cod_estab_pagto = bord_ap.cod_estab_bord
              and compl_movto_pagto.cod_portador    = bord_ap.cod_portador
              and compl_movto_pagto.num_bord_ap     = codigoBordero + 1) then
            
            leave.
        else
        	assign codigoBordero = bord_ap.num_bord_ap.
    end.

    assign codigoBordero = codigoBordero + 1
           num_bord_ap:screen-value = string(codigoBordero).

end.

num_bord_ap:screen-value = string(codigoBordero).



