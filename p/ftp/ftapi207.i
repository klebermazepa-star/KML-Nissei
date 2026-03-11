/*************************************************************************
** 
**  Programa: FTAPI207.I
** 
**  Objetivo: Defini‡Æo das temp-tables usadas no FTAPI207.P
**
*************************************************************************/

def temp-table tt-parametros-aux 
    field destino          as integer
    field arquivo          as char
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field da-emis-ini      as date
    field da-emis-fim      as date
    field c-estabel-ini    as char
    field c-serie-ini      as char
    field c-serie-fim      as char
    field c-nota-fis-ini   as char
    field c-nota-fis-fim   as char
    field cdd-embarq-ini   as dec format ">>>>>>>>>>>>>>>9"
    field cdd-embarq-fim   as dec format ">>>>>>>>>>>>>>>9"
    field i-cod-portador   as integer
    field rs-gera-titulo   as integer
    field l-tipo-sel       as logical
    field desc-titulo      as char format "x(35)".

def temp-table tt-parametros
    field destino          as integer
    field arquivo          as char
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field da-emis-ini      as date
    field da-emis-fim      as date
    field c-estabel-ini    as char
    field c-serie-ini      as char
    field c-serie-fim      as char
    field c-nota-fis-ini   as char
    field c-nota-fis-fim   as char
    field cdd-embarq-ini   as dec  format ">>>>>>>>>>>>>>>9"
    field cdd-embarq-fim   as dec  format ">>>>>>>>>>>>>>>9"
    field i-cod-portador   as integer
    field rs-gera-titulo   as integer
    field l-tipo-sel       as logical
    field desc-titulo      as char format "x(35)"
    field cod-maq-origem   as  integer format "999"       initial 0
    field num-processo     as  integer format ">>>>>>>>9" initial 0
    field num-sequencia    as  integer format ">>>>>9"    initial 0
    field ind-tipo-movto   as  integer format "99"        initial 1.
    
