/***************************************************************************
** 
**  Programa: FTAPI208.I
** 
**  Objetivo: Defini‡Æo das temp-tables usadas na API ftapi208.p/ftapi308.p
**
***************************************************************************/

/* ============================ Devol-cli ============================= */
def temp-table tt-devol-cli-aux like devol-cli
    use-index ch-nfs.

def temp-table tt-devol-cli like devol-cli
    field cod-maq-origem   as  integer format "999"       initial 0
    field num-processo     as  integer format ">>>>>>>>9" initial 0
    field num-sequencia    as  integer format ">>>>>9"    initial 0
    field ind-tipo-movto   as  integer format "99"        initial 1
    index ch-nota is primary cod-maq-origem
                             num-processo
                             num-sequencia.
                             
