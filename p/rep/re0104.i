/*****************************************************************************
**       Programa: re0104.i 
**
**       Data....: 01/07/2003 
**
**       Autor...: DATASUL S.A. - Rubia Daniele Pires de Oliveira 
**
**       Objetivo: Verificar se o cliente possui a funcao Unid-Neg-Devol-Cli
*******************************************************************************/

    define variable l-unid-neg-devol-cli as logical no-undo.

    if  can-find (funcao where funcao.cd-funcao = "spp-unid-neg-devol-cl"
                         and   funcao.ativo) then
        assign l-unid-neg-devol-cli = yes.


    &if "{&bf_mat_versao_ems}":U >= "2.062":U &then
    
        if can-find (first funcao where
                           funcao.cd-funcao = "ems2-unidade-negocio":U and
                           funcao.ativo) THEN DO:
                
            FIND FIRST param-mat NO-LOCK NO-ERROR.

            IF  AVAIL param-mat
            AND param-mat.ind-unid-neg THEN
                ASSIGN l-unid-neg-devol-cli = yes.
        END.
    &endif
