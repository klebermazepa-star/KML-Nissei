/********************************************************************************
** Programa: INT018a - API para definir naturezas de opera‡Æo e dados financeios do cupom fiscal
**
** Versao : 12 - 10/05/2016 - Alessandro V Baccin
**          13 - 08/05/2017 - Hoepers - Aterada toda a api conforme defini‡äes do Sr. Ricardo Clausen
**
********************************************************************************/

DEF INPUT  PARAM c-condipag          AS CHAR  NO-UNDO.
DEF INPUT  PARAM c-class-fiscal      AS CHAR  NO-UNDO.
DEF OUTPUT PARAM p-row-loja-cond-pag AS ROWID NO-UNDO.
DEF OUTPUT PARAM p-row-classif-fisc  AS ROWID NO-UNDO.

ASSIGN p-row-loja-cond-pag = ?
       p-row-classif-fisc  = ?.

FOR FIRST int_ds_loja_cond_pag NO-LOCK
    WHERE int_ds_loja_cond_pag.condipag = c-condipag:
    ASSIGN p-row-loja-cond-pag = ROWID(int_ds_loja_cond_pag).
END.

FOR FIRST int_ds_classif_fisc NO-LOCK
    WHERE int_ds_classif_fisc.class_fiscal = c-class-fiscal:
    ASSIGN p-row-classif-fisc = ROWID(int_ds_classif_fisc).
END.


/*
define input  parameter c-condipag      as char no-undo.
define input  parameter c-estado        as char no-undo.
define input  parameter c-cidade        as char no-undo.
define input  parameter c-cod-estabel   as char no-undo.
define input  parameter c-convenio      as char no-undo.
define input  parameter c-class-fiscal  as char no-undo.
/*
define output  parameter c-natur        like int-ds-loja-natur-oper.nat-operacao no-undo.
define output  parameter i-cod-cond-pag like int-ds-loja-natur-oper.cod-cond-pag no-undo.
define output  parameter i-cod-portador like int-ds-loja-natur-oper.cod-portador no-undo.
define output  parameter i-modalidade   like int-ds-loja-natur-oper.modalidade   no-undo.
define output  parameter c-serie        like int-ds-loja-natur-oper.serie        no-undo.
define output  parameter c-nat-devol    like int-ds-loja-natur-oper.nat-devol    no-undo.
*/

define var c-natur as char.
define output parameter r-rowid         as rowid.


r-rowid = ?.
RUN pi-busca-natureza(input c-condipag    ,
                      input c-estado,
                      input c-cidade,
                      input c-cod-estabel   ,
                      input c-convenio  ,
                      input c-class-fiscal).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,   
                          input ?               ,
                          input c-cidade,
                          input c-cod-estabel   ,
                          input c-convenio  ,
                          input c-class-fiscal).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input ?               ,
                          input c-cod-estabel   ,
                          input c-convenio  ,
                          input c-class-fiscal ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input c-cidade,
                          input ?               ,
                          input c-convenio  ,
                          input c-class-fiscal ).
/*
if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input c-cidade,
                          input c-cod-estabel   ,
                          input ""              ,
                          input c-class-fiscal ).
*/

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input c-cidade,
                          input c-cod-estabel   ,
                          input c-convenio,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?               ,
                          input ?               ,
                          input c-cod-estabel   ,
                          input c-convenio  ,
                          input c-class-fiscal ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?,
                          input c-cidade,
                          input ?               ,
                          input c-convenio  ,
                          input c-class-fiscal ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input ?               ,
                          input ?               ,
                          input c-convenio  ,
                          input c-class-fiscal ).

/*
if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?,
                          input c-cidade,
                          input c-cod-estabel   ,
                          input ""              ,
                          input c-class-fiscal ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input ?               ,
                          input c-cod-estabel   ,
                          input ""              ,
                          input c-class-fiscal ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input c-cidade,
                          input ?               ,
                          input ""              ,
                          input c-class-fiscal ).
*/

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?,
                          input c-cidade,
                          input c-cod-estabel               ,
                          input c-convenio ,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input ?,
                          input c-cod-estabel               ,
                          input c-convenio ,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input c-cidade,
                          input ?               ,
                          input c-convenio ,
                          input ? ).
/*
if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input c-cidade,
                          input c-cod-estabel ,
                          input "" ,
                          input ? ).
*/

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input c-convenio  ,
                          input c-class-fiscal ).

/*
if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?               ,
                          input ?               ,
                          input c-cod-estabel   ,
                          input ""              ,
                          input c-class-fiscal ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?               ,
                          input c-cidade,
                          input ?               ,
                          input ""              ,
                          input c-class-fiscal ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input c-estado,
                          input ?               ,
                          input ?               ,
                          input ""              ,
                          input c-class-fiscal ).

*/

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?              ,
                          input ?              ,
                          input c-cod-estabel  ,
                          input c-convenio ,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?              ,
                          input c-cidade       ,
                          input ?              ,
                          input c-convenio ,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag     ,
                          input c-estado       ,
                          input ?              ,
                          input ?              ,
                          input c-convenio     ,
                          input ? ).
/*
if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag     ,
                          input c-estado       ,
                          input ?              ,
                          input c-cod-estabel  ,
                          input "" ,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag     ,
                          input c-estado       ,
                          input c-cidade       ,
                          input ?  ,
                          input "" ,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag    ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input ""              ,
                          input c-class-fiscal ).
*/

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag      ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input c-convenio      ,
                          input ? ).

/*
if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag      ,
                          input ?               ,
                          input ?               ,
                          input c-cod-estabel   ,
                          input ""              ,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag      ,
                          input ?               ,
                          input c-cidade        ,
                          input ?               ,
                          input ""              ,
                          input ? ).


if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag      ,
                          input c-estado        ,
                          input ?               ,
                          input ?               ,
                          input ""              ,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input c-condipag      ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input ""              ,
                          input ? ).

if r-rowid = ? then
    RUN pi-busca-natureza(input ?               ,
                          input ?               ,
                          input ?               ,
                          input ?               ,
                          input ""              ,
                          input c-class-fiscal).
*/

if r-rowid = ? then
    RUN pi-busca-natureza(input ?           ,
                          input ?           ,
                          input ?           ,
                          input ?           ,
                          input c-convenio  ,
                          input ?).

/*
if r-rowid = ? then
    RUN pi-busca-natureza(input ?               ,
                          input ?               ,
                          input ?               ,
                          input c-cod-estabel   ,
                          input ""              ,
                          input ?).

if r-rowid = ? then
    RUN pi-busca-natureza(input ?               ,
                          input ?               ,
                          input c-cidade,
                          input ?  ,
                          input "" ,
                          input ?).

if r-rowid = ? then
    RUN pi-busca-natureza(input ?                  ,
                          input c-estado                ,
                          input ?,
                          input ?   ,
                          input ""  ,
                          input ?).
*/

procedure pi-busca-natureza:
    define input  parameter c-condipag     as char no-undo.
    define input  parameter c-estado as char no-undo.
    define input  parameter c-cidade as char no-undo.
    define input  parameter c-cod-estabel    as char no-undo.
    define input  parameter c-convenio   as char no-undo.
    define input  parameter c-class-fiscal    as char no-undo.

    for first int-ds-loja-natur-oper no-lock where 
        int-ds-loja-natur-oper.condipag      = c-condipag     and
        int-ds-loja-natur-oper.estado        = c-estado       and
        int-ds-loja-natur-oper.cidade        = c-cidade       and
        int-ds-loja-natur-oper.cod-estabel   = c-cod-estabel  AND 
        int-ds-loja-natur-oper.convenio      = c-convenio     and
        int-ds-loja-natur-oper.class-fiscal  = c-class-fiscal:
        /*
        assign  c-natur        = int-ds-loja-natur-oper.nat-operacao 
                i-cod-cond-pag = int-ds-loja-natur-oper.cod-cond-pag 
                i-cod-portador = int-ds-loja-natur-oper.cod-portador
                i-modalidade   = int-ds-loja-natur-oper.modalidade
                c-serie        = int-ds-loja-natur-oper.serie.
                c-nat-devol    = int-ds-loja-natur-oper.nat-devol.
        */
        assign r-rowid = rowid(int-ds-loja-natur-oper).
    end.
end.

*/
