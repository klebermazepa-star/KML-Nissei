/***
*
* FINALIDADE:
*   retirar quebras de linhas (chr(10) e chr(13)), substituindo por
*   espacos. Pode ser usada emconjunto com a fn-one-space.
*
* NOTAS:
*
* VERSOES:
*   31/08/2005, Leansro Dalle Laste,
*   - criacao
*
*/

function fn-unWrap returns char (input c-text as char).

    return replace(replace(c-text, chr(10), ' '), chr(13), ' ').
    
end function.

