/**
* FUNCAO/INCLUDE:
*   utils/isValidCpf.i
*
* FINALIDADE:
*   Implementacao funcao homonima para validar se um CPF eh valido
*   ou nao, retornando respectivamente true ou false.
*/

{utils/fn-only-digits.i}                                                   
                                                   
function isValidCpf return logical (input cpf as character):
    define variable contador as integer   no-undo. 
    define variable soma1    as integer   no-undo. 
    define variable mul1     as integer   no-undo extent 9 initial [10, 9, 8, 7, 6, 5, 4, 3, 2].
    define variable resto1   as integer   no-undo. 
    define variable soma2    as integer   no-undo. 
    define variable mul2     as integer   no-undo extent 10 initial [11, 10, 9, 8, 7, 6, 5, 4, 3, 2]. 
    define variable resto2   as integer   no-undo.

    assign cpf = fn-only-digits(cpf).

    do contador = 1 to 9: 
        assign soma1 = soma1 + (integer(substring(cpf, contador, 1)) * mul1[contador]). 
    end. 

    assign resto1 = soma1 mod 11. 
    if resto1 > 1 then 
        assign resto1 = 11 - resto1. 
    else 
        assign resto1 = 0. 

    if resto1 <> integer(substring(cpf, 10, 1)) then 
        return false. 

    do contador = 1 to 10: 
        assign soma2 = soma2 + (integer(substring(cpf, contador, 1)) * mul2[contador]). 
    end. 

    assign resto2 = soma2 mod 11. 

    if resto2 > 1 then
        assign resto2 = 11 - resto2.
    else 
        assign resto2 = 0.

    if resto2 <> integer(substring(cpf, 11, 1)) then 
        return false.

    return true. 

end function.

