/******************************************************************************
**
** CD4401.I3 - Definicao da tabela temporaria tt-saldo-estoq.
**
******************************************************************************/

def temp-table tt-saldo-estoq no-undo
    field seq-tt-saldo-estoq as   int
    field seq-tt-it-docto    as   int
    field it-codigo          like saldo-estoq.it-codigo
    field cod-depos          like saldo-estoq.cod-depos
    field cod-localiz        like saldo-estoq.cod-localiz
    field lote               like saldo-estoq.lote
    field dt-vali-lote       like saldo-estoq.dt-vali-lote
    field quantidade         like saldo-estoq.qtidade-atu
    field qtd-contada        like saldo-estoq.qtidade-atu
    field c-char             as char
    index seq is unique
          seq-tt-saldo-estoq.

/*  CD4401.I3  */
