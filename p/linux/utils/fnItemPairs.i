/* transforma uma lista de itens em lista par de itens:
   One,Two,Three => One,1,Two,2,Three,3
*/

function fnItemPairs returns character (cItems as character):
    
    define variable cList as character no-undo.
    define variable iList as integer   no-undo.
    
    do iList = 1 to num-entries(cItems):
        assign
            cList = cList + (if iList > 1 then ',' else '') +
                    entry(iList, cItems) + ',' + string(iList).
    end.

    return cList.
end.

