/* 
   retorna i-col, i-row no formato excel: 1,1 = 'A1'
   
   ATENCAO: necessario incluir {utils/fn-excel-col.i} onde esta eh usada
*/

function fn-excel-cell returns char (i-col as integer, i-row as integer).
    return fn-excel-col(i-col) + string(i-row).
end function.
