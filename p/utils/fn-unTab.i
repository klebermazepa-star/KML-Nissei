/***
*
* FINALIDADE:
*   retirar TABs de linhas (chr(09)), substituindo por espaco.
*
* NOTAS:
*/

function fn-unTab returns char (input c-text as char).

    return replace(c-text, chr(09), ' ').
    
end function.

