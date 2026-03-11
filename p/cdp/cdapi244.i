/************************************************************************
**
** Include : CPAPI244.I
**
** Objetivo: Defini‡Æo das temp-tables usadas na API cdapi244.p
**
************************************************************************/


def temp-table tt-item-aux no-undo like item 
    INDEX ch-codigo IS PRIMARY it-codigo.
    
def {1} temp-table tt-item no-undo like item 
    field cod-maq-origem   as   integer format "9999"
    field num-processo     as   integer format ">>>>>>>>9" initial 0
    field num-sequencia    as   integer format ">>>>>9"    initial 0
    field ind-tipo-movto   as   integer format "99"        initial 1
    field cod-erro         as   integer format "99999" 
    field des-erro         as   char    format "x(60)"
    INDEX ch-codigo IS PRIMARY  cod-maq-origem
                                num-processo
                                num-sequencia.
