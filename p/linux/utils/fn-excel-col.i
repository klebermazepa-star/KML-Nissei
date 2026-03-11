/* converte inteiro para coluna do excel (1='A', 27='AA', ...) 
  ATENCAO: funciona ateh o limite de 702 (ZZ)
*/

function fn-excel-col returns char (input i-col as int).

    return if i-col <= 26 then
               chr(i-col + 64)
           else
           if i-col mod 26 = 0 then
               chr(int(trunc(i-col / 26, 0)) + 63) + 'Z'
           else
               chr(int(trunc(i-col / 26, 0)) + 64) + chr((i-col mod 26) + 64).

end function.
