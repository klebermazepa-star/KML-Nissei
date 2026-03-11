/*************************************************************************
** 
**  Programa: CCAPI207.I
** 
**  Objetivo: Defini‡Æo das temp-tables usadas na API "cotacao-item"
**
*************************************************************************/
{cdp/cdcfgmat.i}
def temp-table tt-cotacao-item-aux NO-UNDO like cotacao-item
    INDEX ch-codigo IS PRIMARY numero-ordem
                               cod-emitente
                               it-codigo
                               seq-cotac.

def temp-table tt-cotacao-item no-undo like cotacao-item
    field cod-maq-origem    as integer format "999"       initial 0
    field num-processo      as integer format ">>>>>>>>9" initial 0
    field num-sequencia     as integer format ">>>>>9"    initial 0
    field ind-tipo-movto    as integer format "99"        initial 1
    INDEX ch-codigo IS PRIMARY cod-maq-origem
                               num-processo
                               num-sequencia.

&if defined(bf_mat_despesa_fase_II) &then
    def temp-table tt-desp-cotacao-item-aux NO-UNDO like desp-cotacao-item
        INDEX ch-codigo IS PRIMARY numero-ordem
                                   cod-emitente
                                   it-codigo
                                   seq-cotac
                                   num-seq-desp
                                   cod-despesa.
                                   
    def temp-table tt-desp-cotacao-item no-undo like desp-cotacao-item
        field cod-maq-origem    as   integer format "999"       initial 0
        field num-processo      as   integer format ">>>>>>>>9" initial 0
        field num-sequencia     as   integer format ">>>>>9"    initial 0
        field ind-tipo-movto    as   integer format "99"        initial 1
        INDEX ch-codigo IS PRIMARY  cod-maq-origem
                                    num-processo
                                    num-sequencia.
&endif
