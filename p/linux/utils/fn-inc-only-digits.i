/* 
  Incrementa os numeros contidos em c-source: c9x9mm, 1 = c10x0m
 
 funcoes que devem ser incluidas onde esta eh chamada 

{utils/fn-only-digits.i}
{utils/fn-fill-left.i}

*/

function fn-inc-only-digits returns char (c-source as char, i-inc as integer).

    def var i-n as integer no-undo.
    def var i-c as integer no-undo.

    def var c-result as char no-undo.
    def var c-aux    as char no-undo.
    def var n-aux    as decimal no-undo.
    define variable cFormat as character no-undo.

    assign
        c-aux    = fn-only-digits(c-source)
        c-result = ''.

    if c-aux <> '' then do:

        assign
            n-aux = dec(c-aux) + i-inc
            cFormat = fill('>', length(c-aux)) + '9'.

        if length(string(n-aux)) < length(c-aux) then /* zeros a esquerda, completa o numero incrementado */
            assign c-aux = fn-fill-left(trim(string(n-aux, cFormat)), length(c-aux), '0').
        else
        if length(trim(string(n-aux), cFormat)) > length(c-aux) then /* aumentou os digitos (de 99 para 100, ex), aumenta o c-source */
            assign
                substring(c-source, index(c-source, substring(c-aux, 1, 1)), 1) = 
                    fill('0', length(trim(string(n-aux), cFormat)) - length(c-aux)) +
                    substring(c-source, index(c-source, substring(c-aux, 1, 1)), 1)
                c-aux = trim(string(n-aux, cFormat)).
        else
            assign c-aux = trim(string(n-aux, cFormat)).

        assign i-n        = 1.

        /* para cada caracter original, se for letra, usa do original,
           se for numero usa do incrementado */
        do i-c = 1 to length(c-source):

            if substring(c-source, i-c, 1) >= '0' and
               substring(c-source, i-c, 1) <= '9'     then do:

                assign
                    c-result = c-result + substring(c-aux, i-n, 1)
                    i-n = i-n + 1.
            end.
            else do:
                assign
                    c-result = c-result + substring(c-source, i-c, 1).
            end.
        end.
    end.
    else
        assign c-result = c-source.

    return c-result.

end function.

