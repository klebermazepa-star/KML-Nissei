/**
*
* PROGRAMA:
* utils/printGradeBytesrp.p
*
* FINALIDADE:
* Imprime uma grade de bytes. A intencao eh imprimir num formulario
* de NF para determinar as posicoes
*
* $Id$
*
*/

/* include de controle de versao */
{include/i-prgvrs.i printGradeBytesrp 2.04.00.001}

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field modelo           as char format "x(35)"
    field iLinhas          as integer
    field iColunas         as integer
    field iRegua           as integer.

def temp-table tt-raw-digita
   field raw-digita      as raw.

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.


{utils/fn-fill-left.i}

/* Include padrao para variaveis de relatorio */
{include/i-rpvar.i}

/* include padrao para output de relatorio */
{include/i-rpout.i}

def var cRegua as char no-undo.
def var i as int no-undo.

/*
'1...5...10....5...20....5...30....5...40....5...50....5...60....5...70....5...80....5...90....5..100....5..110....5..120....5..130....5..140....5..150....5..160'
*/

assign
    cRegua = '1...5...10'
    i = 20.

do while i <= tt-param.iColunas:
    assign
        cRegua = cRegua + '....5' + fn-fill-left(string(i), 5, '.')
        i = i + 10.
end.

put unformatted
   cRegua.

do i = 2 to tt-param.iLinhas:
    if i mod tt-param.iRegua = 0 or i = tt-param.iLinhas then
        put unformatted
            cRegua at 01.
    else
        put string(i) at 01.
end.

/* fechamento do output do relatorio */
{include/i-rpclo.i}

return.
