/********************************************************************************
***
*** crp/crapi009.i3 - Defini‡Æo de temp-tables
***
********************************************************************************/

def temp-table tt-ext-lin-i-cr         no-undo like lin-i-cr
    field tp-ret-iva   as int  format ">>>9"
    field tp-ret-gan   as int  format ">>9"
    field acum-ant-gan as dec  format ">>>,>>9.99"      decimals 2
    field vl-base-gan  as dec  format ">>>,>>9.99"      decimals 2
    field gravado      as dec  format ">>>,>>>,>>9.99"  decimals 2
    field no-gravado   as dec  format ">>>,>>>,>>9.99"  decimals 2
    field isento       as dec  format ">>>,>>>,>>9.99"  decimals 2
    field uf-entrega   as char format "x(4)".
