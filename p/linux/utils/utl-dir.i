/***
*
* FINALIDADE:
*   Retorna o caminho passado como parametro contendo apenas "\".
*
* NOTAS:
*   O caminho retornado sempre conter  uma "\" no final da string.
*
* VERSOES:
*   05/09/2002, ljohann, criacao
*
*/
function fnTrataDir returns character 
    ( input c-dir as char, input l-barra-fim as logical ):

    /* deixa o caminho apenas com "\" */
    if index(c-dir, "/") > 0 then
        assign c-dir = replace(c-dir, "/", "\").

    /* se for para colocar uma barra no final (quando l-barra-fim = true),
       certifica-se que o caminho termina com uma "\" */
    if l-barra-fim and substring(c-dir, length(c-dir), 1) <> "\" then
        c-dir = c-dir + "\".

    return c-dir.
end function.
