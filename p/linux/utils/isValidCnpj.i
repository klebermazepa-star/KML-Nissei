/**
* FUNCAO/INCLUDE:
*   utils/isValidCnpj.i
*
* FINALIDADE:
*   Implementacao funcao homonima para validar se um CNPJ eh valido
*   ou nao, retornando respectivamente true ou false.
*/

{utils/fn-only-digits.i}

function isValidCnpj returns logical (input cnpj as character) :
    
    define variable contador as integer   no-undo. 
    define variable soma1    as integer   no-undo. 
    define variable nul1     as integer   extent 12 initial [5,4,3,2,9,8,7,6,5,4,3,2] no-undo.
    define variable resto1   as integer   no-undo. 
    define variable soma2    as integer   no-undo. 
    define variable mul2     as integer   extent 13 initial [6,5,4,3,2,9,8,7,6,5,4,3,2] no-undo. 
    define variable resto2   as integer   no-undo. 
  
    assign cnpj = fn-only-digits(cnpj).

    do contador = 1 to 12: 
        soma1 = soma1 + (integer(substring(cnpj, contador, 1)) *  nul1[contador] ). 
    end. 
  
    resto1 = soma1 modulo 11. 
    if resto1 > 1 then 
        resto1 = 11 - resto1. 
    else 
        resto1 = 0. 
  
    if resto1 <> integer(substring(cnpj, 13, 1)) then 
        return false. 
  
    do contador = 1 to 13: 
        soma2 = soma2 + (integer(substring(cnpj, contador, 1)) * mul2[contador] ). 
    end. 
  
    resto2 = soma2 mod 11. 
    if resto2 > 1 then 
        resto2 = 11 - resto2. 
    else 
        resto2 = 0. 
  
    if resto2 <> integer(substring(cnpj, 14, 1)) then 
        return false. 
  
    return true. 
END FUNCTION.
