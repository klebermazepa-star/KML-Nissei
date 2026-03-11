/******************************************************************************
**
**  Include.: PD9100.I
**
**  Objetivo: Buscar a Cotacao de Uma moeda em determinada data.
**
**
******************************************************************************/

find first cotacao
    where cotacao.mo-codigo   = {1}
    and   cotacao.ano-periodo = string(year({2})) + string(month({2}),"99")
    and   cotacao.cotacao[int(day({2}))] <> 0 no-lock no-error.

if  avail cotacao then
    assign {3} = cotacao.cotacao[int(day({2}))].

/* PD9100.I */
