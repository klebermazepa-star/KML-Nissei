/****************************************************************************
** OF0770.I3 - Determina para uma vari vel se ser  utilizada a descri‡Æo   **
**             da natureza ou do CFOP, dependendo da data de in¡cio do     **
**             Ajuste Sinief 07                                            **
** OBS: A include CD0620.I1 ‚ pr‚-requisito para utiliza‡Æo desta.         **
**  {1} - Indica se dever  pegar a natureza ou o CFOP do documento fiscal  **
**        ou da natureza de operacao. Seguem os valores poss¡veis:         **
**        "doc-fiscal"..: Para pegar a informa‡Æo do documento; ou         **
**        "nat-operacao": Para pegar a informa‡Æo da natureza de opera‡Æo. **
**  {2} - Data do documento ou da nota fiscal que dever  ser comparada a   **
**        data de in¡cio do Ajste Sinief. Desta forma, a l¢gica abaixo ir  **
**        identificar se pega o CFOP novo ou a pr¢pria natureza de         **
**        opera‡Æo                                                         **
****************************************************************************/
assign c-desc-cfop-nat = "":U.
if  "{1}" = "doc-fiscal" then
    if {2} >= da-dt-cfop then do:
        assign c-desc-cfop-nat = "NÆo possui CFOP":U.
        &IF DEFINED(bf_dis_formato_CFOP) &THEN
            for first cfop-natur 
                where cfop-natur.cod-cfop = doc-fiscal.cod-cfop no-lock:
                assign c-desc-cfop-nat    = cfop-natur.des-cfop. 
            end.
        &ELSE 
            for first ped-curva use-index ch-vlitem
                where ped-curva.it-codigo = doc-fiscal.cod-cfop  
                and   ped-curva.vl-aberto = 620 no-lock:
                assign c-desc-cfop-nat    = ped-curva.nome.
            end.
        &ENDIF
    end.
    else 
        assign c-desc-cfop-nat = natur-oper.denominacao.
else 
    if {2} >= da-dt-cfop then do:
        assign c-desc-cfop-nat = "NÆo possui CFOP":U.
        &IF DEFINED(bf_dis_formato_CFOP) &THEN
            for first cfop-natur 
                where cfop-natur.cod-cfop = natur-oper.cod-cfop no-lock:
                assign c-desc-cfop-nat    = cfop-natur.des-cfop. 
            end.
        &ELSE
            for first ped-curva use-index ch-vlitem
                where ped-curva.it-codigo = trim(substr(natur-oper.char-1,45,10))  
                and   ped-curva.vl-aberto = 620 no-lock:
                assign c-desc-cfop-nat    = ped-curva.nome.
            end.
        &ENDIF
    end.
    else 
        assign c-desc-cfop-nat = natur-oper.denominacao.

/* OF0770.I3 */
