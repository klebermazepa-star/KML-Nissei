/**
* PROGRAMA:
*   utils/ttBoErro.i
*
* FINALIDADE:
*   declarar a temp-table tt-bo-erro
*/
define temp-table tt-bo-erro no-undo
    field i-sequen     as integer
    field cd-erro      as integer
    field mensagem     as character
    field parametros   as char format "x(255)" init ""
    field errorType    as char format "x(20)"
    field errorHelp    as char format "x(20)"
    field errorSubType as character.
