/******************************************************************************
**
**  Include.: OF0717.I3
**
**  Objetivo: Variaveis para impressao do resumo por UF
**
******************************************************************************/

def {1} shared temp-table res-uf-e1 no-undo
    field uf          as character format "!!"
    field nat-oper    like doc-fiscal.nat-operacao
    field vl-bsubs    like doc-fiscal.vl-bsubs
                      format ">>>>>>,>>>,>>>,>>9.99"
    field vl-icmsub   like doc-fiscal.vl-icmsub
                      format ">>>>>>,>>>,>>>,>>9.99"
    index uf uf.

def {1} shared temp-table res-uf-e2 no-undo
    field uf          as character format "!!"
    field nat-oper    like doc-fiscal.nat-operacao
    field vl-bsubs    like doc-fiscal.vl-bsubs
                      format ">>>>>>,>>>,>>>,>>9.99"
    field vl-icmsub   like doc-fiscal.vl-icmsub
                      format ">>>>>>,>>>,>>>,>>9.99"
    index uf uf.

def {1} shared temp-table res-aliq no-undo
    field nat-oper    as character 
                      format "9.99"
                      label "Nat.Operacao"
    field vl-aliq     as decimal 
                      format ">>>>>>,>>>,>>>,>>9.99"
                      label "Vl. Aliquota"
    field vl-bcalc    as decimal
                      format ">>>>>>,>>>,>>>,>>9.99"
                      label "Base Calculo"
    field vl-impcred  as decimal
                      format ">>>>>>,>>>,>>>,>>9.99"
                      label "Imposto Creditado"
    field tp-natur    like doc-fiscal.tipo-nat
    index natureza nat-oper.

def temp-table res-uf-s1 no-undo
    field uf          as character format "!!"
    field nat-oper    like doc-fiscal.nat-operacao
    field vl-bsubs    like doc-fiscal.vl-bsubs
                      format ">>>>>>,>>>,>>>,>>9.99"
    field vl-icmsub   like doc-fiscal.vl-icmsub
                      format ">>>>>>,>>>,>>>,>>9.99"
    index uf uf.

def temp-table res-uf-s2 no-undo
    field uf          as character format "!!"
    field nat-oper    like doc-fiscal.nat-operacao
    field vl-bsubs    like doc-fiscal.vl-bsubs
                      format ">>>>>>,>>>,>>>,>>9.99"
    field vl-icmsub   like doc-fiscal.vl-icmsub
                      format ">>>>>>,>>>,>>>,>>9.99"
    index uf uf.

/* of0717.i3 */
