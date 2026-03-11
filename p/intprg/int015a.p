define input  parameter c-tp-pedido      as char no-undo.
define input  parameter c-uf-destino     as char no-undo.
define input  parameter c-uf-origem      as char no-undo.
define input  parameter c-cod-estabel    as char no-undo.
define input  parameter i-cod-emitente   as integer no-undo.
define input  parameter c-class-fiscal   as char no-undo.
define input  parameter i-cst-icms       as integer no-undo.
define output parameter c-nat-operacao   as char no-undo.
define output parameter i-cod-cond-pag   as integer.
define output parameter i-cod-portador   as integer.
define output parameter i-modalidade     as integer.
define output parameter c-serie          as char.
define output parameter r-rowid          as rowid.
DEFINE OUTPUT PARAMETER c-nat-oper-ent   AS CHAR NO-UNDO.

c-nat-operacao = "".
RUN pi-busca-natureza(input c-tp-pedido    ,
                      input c-uf-destino,
                      input c-uf-origem,
                      input c-cod-estabel   ,
                      input i-cod-emitente  ,
                      input c-class-fiscal  ,
                      input if c-tp-pedido = "15" or
                               c-tp-pedido = "32" then i-cst-icms
                            else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,   
                          input ?               ,
                          input c-uf-origem,
                          input c-cod-estabel   ,
                          input i-cod-emitente  ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input ?               ,
                          input c-cod-estabel   ,
                          input i-cod-emitente  ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input c-uf-origem,
                          input ?               ,
                          input i-cod-emitente  ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).


if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input c-uf-origem,
                          input c-cod-estabel   ,
                          input ?               ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).


if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input c-uf-origem,
                          input c-cod-estabel   ,
                          input i-cod-emitente,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).


if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?               ,
                          input ?               ,
                          input c-cod-estabel   ,
                          input i-cod-emitente  ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?,
                          input c-uf-origem,
                          input ?               ,
                          input i-cod-emitente  ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input ?               ,
                          input ?               ,
                          input i-cod-emitente  ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?,
                          input c-uf-origem,
                          input c-cod-estabel   ,
                          input ?               ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input ?               ,
                          input c-cod-estabel   ,
                          input ?               ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input c-uf-origem,
                          input ?               ,
                          input ?               ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?,
                          input c-uf-origem,
                          input c-cod-estabel               ,
                          input i-cod-emitente ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input ?,
                          input c-cod-estabel               ,
                          input i-cod-emitente ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input c-uf-origem,
                          input ?               ,
                          input i-cod-emitente ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input c-uf-origem,
                          input c-cod-estabel               ,
                          input ? ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input i-cod-emitente  ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?               ,
                          input ?               ,
                          input c-cod-estabel   ,
                          input ?               ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?               ,
                          input c-uf-origem,
                          input ?               ,
                          input ?               ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?              ,
                          input ?              ,
                          input c-cod-estabel  ,
                          input i-cod-emitente ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?              ,
                          input c-uf-origem       ,
                          input ?              ,
                          input i-cod-emitente ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino       ,
                          input ?              ,
                          input ?              ,
                          input i-cod-emitente ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino       ,
                          input ?              ,
                          input c-cod-estabel  ,
                          input ? ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino       ,
                          input c-uf-origem       ,
                          input ?  ,
                          input ? ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input c-class-fiscal ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).
if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input i-cod-emitente               ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).


if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?               ,
                          input ?               ,
                          input c-cod-estabel   ,
                          input ?               ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).

if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input ?               ,
                          input c-uf-origem       ,
                          input ?               ,
                          input ?               ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).


if c-nat-operacao = "" then
    RUN pi-busca-natureza(input c-tp-pedido    ,
                          input c-uf-destino        ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input ? ,
                          input if c-tp-pedido = "15" or
                                   c-tp-pedido = "32" then i-cst-icms
                                else 0).


procedure pi-busca-natureza:
    define input  parameter c-tp-pedido     as char no-undo.
    define input  parameter c-uf-destino    as char no-undo.
    define input  parameter c-uf-origem     as char no-undo.
    define input  parameter c-cod-estabel   as char no-undo.
    define input  parameter i-cod-emitente  as inte no-undo.
    define input  parameter c-class-fiscal  as char no-undo.
    define input  parameter i-cst-icms      as integer no-undo.

    for first int_ds_tp_natur_oper no-lock where 
        int_ds_tp_natur_oper.tp_pedido     = c-tp-pedido    and
        int_ds_tp_natur_oper.uf_destino    = c-uf-destino   and
        int_ds_tp_natur_oper.uf_origem     = c-uf-origem    and
        int_ds_tp_natur_oper.cod_emitente  = i-cod-emitente and
        int_ds_tp_natur_oper.cod_estabel   = c-cod-estabel  and
        int_ds_tp_natur_oper.class_fiscal  = c-class-fiscal /*and
        int_ds_tp_natur_oper.cst-icms      = i-cst-icms*/ :
        assign r-rowid = rowid(int_ds_tp_natur_oper).
        assign c-nat-operacao = int_ds_tp_natur_oper.nat_operacao
               i-cod-cond-pag = int_ds_tp_natur_oper.cod_cond_pag
               i-cod-portador = int_ds_tp_natur_oper.cod_portador
               i-modalidade   = int_ds_tp_natur_oper.modalidade
               c-serie        = int_ds_tp_natur_oper.serie
               c-nat-oper-ent = int_ds_tp_natur_oper.nat_oper_entrada.

    end.

end.
