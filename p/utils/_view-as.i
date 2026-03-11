def var i-cont as int no-undo.
def var c-nome as char no-undo.

define temp-table tt-lista
    field numero as int
    field descr  as char format "x(50)".

do i-cont = 1 to {{1} 05}:
    assign c-nome = {{1} 04 i-cont}.
    create tt-lista.
    assign tt-lista.numero = i-cont
           tt-lista.descr  = c-nome.
end.

for each tt-lista:
    disp tt-lista.numero tt-lista.descr format 'x(60)' skip.
end.
