/* 
   retorna i-col, i-row, i-col, irow no formato excel: 1,1, 2,2 = 'A1:B2'
   
   ATENCAO: necessario incluir {utils/fn-excel-col.i} e {utils/fn-excel-cell.i}
            onde esta eh usada 
*/

function fn-excel-range returns char (i-ci as integer, i-ri as integer,
                                      i-cf as integer, i-rf as integer).
    return fn-excel-cell(i-ci, i-ri) + ':' + fn-excel-cell(i-cf, i-rf).
end function.

