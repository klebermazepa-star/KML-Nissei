/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ni0302F 2.00.00.035 } /*** 010035 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i ni0302f MFP}
&ENDIF

/******************************************************************************
 **
 ** ni0302f.p - display do resumo por aliquotas
 **
 ******************************************************************************/
 
def input param l-entrada as int no-undo.

def shared var h-acomp as handle                                 no-undo.

def var de-vl-bcalc   as decimal format ">>>>>>,>>>,>>>,>>9.99"  no-undo.
def var de-vl-impcred as decimal format ">>>>>>,>>>,>>>,>>9.99"  no-undo.

def var l-tem-funcao         as log     no-undo.

assign l-tem-funcao = can-find(funcao where funcao.cd-funcao = "considera-termo" and funcao.ativo).

{intprg/ni0302.i3}
{intprg/ni0302.i4 "shared"}

{include/tt-edit.i}  /** defini‡Æo da tabela p/ impressÆo do campo editor */

assign i-pag-aux     = 0
       de-vl-bcalc   = 0
       de-vl-impcred = 0
       c-tit         = "REGISTRO DE"
       c-titimposto  = "ICMS"
       c-uf          = " ".

if  l-entrada = 1 then 
    assign c-tipo = "RESUMO POR ALIQUOTA DE ICMS - ENTRADA"
           c-tit1 = "OPERACOES COM CREDITOS DO IMPOSTO"
           c-tit2 = "OPERACOES SEM CREDITOS DO IMPOSTO"
           c-tit3 = "CREDITADO".
else 
    assign c-tipo = "RESUMO POR ALIQUOTA DE ICMS - SAIDA"
           c-tit1 = "OPERACOES COM DEBITOS DO IMPOSTO"
           c-tit2 = "OPERACOES SEM DEBITOS DO IMPOSTO"
           c-tit3 = "DEBITADO".

run pi-imprime-termo ( line-counter, 1 ).

if  l-separadores then
    disp c-tipo 
         c-tit1
         c-tit2
         c-tit3 with frame f-sdiag.
else do:
    hide frame f-cab-3.
    view frame f-cabec.
    if  l-entrada = 1 
    then disp c-tipo with frame f-cab-2.
    else disp c-tipo with frame f-cab-3.
end.

find first res-aliq 
    where res-aliq.tp-natur = l-entrada no-lock no-error.

if  not avail res-aliq then do:

    assign i-pag-aux = i-num-pag.
 
    run pi-imprime-termo ( line-counter, 1 ).
 
    {intprg/ni0302.i6}
  
    put c-sep at 1
        c-sep at 24
        c-sep at 45
        c-sep at 67
        c-sep at 89
        c-sep at 111
        c-sep at 132 skip.

    assign i-pag-aux = i-num-pag.

    run pi-imprime-termo ( line-counter, 4 ).

    {intprg/ni0302.i6}

    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-total AS CHARACTER FORMAT "X(7)" NO-UNDO.
    {utp/ut-liter.i "TOTAL" *}
    ASSIGN c-lbl-liter-total = TRIM(RETURN-VALUE).
    put c-sep at 1
        c-lbl-liter-total at 6
        c-sep at 24
        c-sep at 45
        0 format ">>>>,>>>,>>>,>>9.99" at 48
        c-sep
        0 format ">>>>,>>>,>>>,>>9.99" at 70
        c-sep
        c-sep at 111
        c-sep at 132 skip
        c-sep at 1
        c-sep at 24
        c-sep at 45
        c-sep at 67
        c-sep at 89
        c-sep at 111
        c-sep at 132 skip
        c-sep at 1
        c-sep at 24
        c-sep at 45
        c-sep at 67
        c-sep at 89
        c-sep at 111
        c-sep at 132 skip
        c-sep at 1
        c-sep at 24
        c-sep at 45
        c-sep at 67
        c-sep at 89
        c-sep at 111
        c-sep at 132 skip.
end.

for each res-aliq no-lock
    where res-aliq.tp-natur = l-entrada
    break by res-aliq.vl-aliq descend:

    assign de-vl-bcalc   = de-vl-bcalc   + res-aliq.vl-bcalc
           de-vl-impcred = de-vl-impcred + res-aliq.vl-impcred.

    accumulate res-aliq.vl-bcalc (total)
               res-aliq.vl-impcred (total).

    if  last-of(res-aliq.vl-aliq) then do:
        
        assign i-pag-aux = i-num-pag.
        
        run pi-imprime-termo ( line-counter, 1 ).
        
        {intprg/ni0302.i6}
        
        put c-sep at 1
            c-sep at 24
            res-aliq.vl-aliq format ">>9.99" at 39
            c-sep at 45
            de-vl-bcalc format ">>>>,>>>,>>>,>>9.99" at 48
            c-sep
            de-vl-impcred format ">>>>,>>>,>>>,>>9.99" at 70
            c-sep
            c-sep at 111
            c-sep at 132 skip.
        
        assign de-vl-bcalc   = 0
               de-vl-impcred = 0.
    end.

    if  last(res-aliq.vl-aliq) then do:
    
        assign i-pag-aux = i-num-pag.
    
        run pi-imprime-termo ( line-counter, 4 ).
    
        {intprg/ni0302.i6}
    
        /* Inicio -- Projeto Internacional */
        DEFINE VARIABLE c-lbl-liter-total-2 AS CHARACTER FORMAT "X(7)" NO-UNDO.
        {utp/ut-liter.i "TOTAL" *}
        ASSIGN c-lbl-liter-total-2 = TRIM(RETURN-VALUE).
        put c-sep at 1
            c-sep at 24
            c-sep at 45
            c-sep at 67
            c-sep at 89
            c-sep at 111
            c-sep at 132 skip
            c-sep at 1
            c-lbl-liter-total-2 at 6
            c-sep at 24
            c-sep at 45
            accum total res-aliq.vl-bcalc format ">>>>,>>>,>>>,>>9.99" at 48
            c-sep
            accum total res-aliq.vl-impcred format ">>>>,>>>,>>>,>>9.99" at 70
            c-sep
            c-sep at 111
            c-sep at 132 skip
            c-sep at 1
            c-sep at 24
            c-sep at 45
            c-sep at 67
            c-sep at 89
            c-sep at 111
            c-sep at 132 skip
            c-sep at 1
            c-sep at 24
            c-sep at 45
            c-sep at 67
            c-sep at 89
            c-sep at 111
            c-sep at 132 skip.
    end.

end.

if  l-entrada = 2 then 
do  i-aux = line-counter to page-size: 
    put c-sep at 1
        c-sep at 24
        c-sep at 45
        c-sep at 67
        c-sep at 89
        c-sep at 111
        c-sep at 132 skip.
end.

{include/pi-edit.i} /* procedure pi-print-editor */

{intprg/ni0302.i8} /* procedure pi-imprime-termo */

