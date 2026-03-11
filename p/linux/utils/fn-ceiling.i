/**
*
* INCLUDE:
*   utils/fn-ceiling.i
*
* FINALIDADE:
*   Implementa a funcao fn-ceiling, cuja finalidade eh sempre
*   arredondar para cima, conforme o numero de casas decimais
*   especificadas.
*
*   Exemplos:
*     0,1 => 1,0
*     1,1 => 2,0
*     1,6 => 2,0
*
* VERSOES:
*   04/11/2005, Leandro Johann, Datasul Paranaense,
*     Criacao.
*
*/
function fn-ceiling return decimal
    ( input deValue     as decimal,
      input deDecPlaces as integer ):
    define variable deValueAux as decimal    no-undo.

    assign deValueAux = truncate(deValue, deDecPlaces).

    if deValue - deValueAux <> 0 then
        return deValueAux + (1 / exp(10, deDecPlaces)).

    return deValue.
end function.
