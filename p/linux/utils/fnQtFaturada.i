/* utils/fnQtFaturada.i
 
   retorna qt-faturada de acordo com faturamento
   
 */
function fnQtFaturada returns decimal (buffer it-nota-fisc for it-nota-fisc):

    if it-nota-fisc.ind-fat-qtfam then
        return it-nota-fisc.qt-faturada[2].

    return it-nota-fisc.qt-faturada[1].

end function.

function fnUnFaturada returns character (buffer it-nota-fisc for it-nota-fisc):

    if it-nota-fisc.ind-fat-qtfam then
        return it-nota-fisc.un-fatur[2].

    return it-nota-fisc.un-fatur[1].

end function.
