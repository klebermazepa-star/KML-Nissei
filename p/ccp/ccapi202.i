/*************************************************************************
** 
**  Programa: CCAPI202.I
** 
**  Objetivo: Defini‡Æo das temp-tables usadas na API ccapi202.p
**
*************************************************************************/
def temp-table tt-ordem-compra-aux like ordem-compra
    INDEX ch-codigo IS PRIMARY numero-ordem.

def temp-table tt-prazo-compra-aux like prazo-compra
    INDEX ch-codigo IS PRIMARY numero-ordem
                               parcela.

def temp-table tt-ordem-compra no-undo like ordem-compra
    field l-split           as   logical                    initial no
    field cod-maq-origem-mp as   integer format "999"       initial 0
    field num-processo      as   integer format ">>>>>>>>9" initial 0
    field num-sequencia     as   integer format ">>>>>9"    initial 0
    field ind-tipo-movto    as   integer format "99"        initial 1
    INDEX ch-codigo IS PRIMARY  cod-maq-origem-mp
                                num-processo
                                num-sequencia.

def temp-table tt-prazo-compra no-undo like prazo-compra
    field cod-maq-origem    as   integer format "999"       initial 0
    field num-processo      as   integer format ">>>>>>>>9" initial 0
    field num-sequencia     as   integer format ">>>>>9"    initial 0
    field ind-tipo-movto    as   integer format "99"        initial 1
    INDEX ch-codigo IS PRIMARY  cod-maq-origem
                                num-processo
                                num-sequencia.

&IF '{&bf_mat_versao_ems}' >= '2.04' &THEN
    
    DEF TEMP-TABLE tt-matriz-rat-med-aux NO-UNDO LIKE matriz-rat-med.
    DEF TEMP-TABLE tt-matriz-rat-med     NO-UNDO LIKE matriz-rat-med
        FIELD cod-maq-origem    AS  INTEGER FORMAT "999"       INITIAL 0
        FIELD num-processo      AS  INTEGER FORMAT ">>>>>>>>9" INITIAL 0
        FIELD num-sequencia     AS  INTEGER FORMAT ">>>>>9"    INITIAL 0
        FIELD ind-tipo-movto    AS  INTEGER FORMAT "99"        INITIAL 1
        INDEX ch-codigo IS PRIMARY  cod-maq-origem
                                    num-processo
                                    num-sequencia.
&ENDIF
