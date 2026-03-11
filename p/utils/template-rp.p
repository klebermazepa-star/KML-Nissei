/**
*
* PROGRAMA:
* ckp/ck0092rp.p
*
* FINALIDADE:
* Relatorio de saldos em estoque por autex
*
* $Id$
*
*/

/* include de controle de versao */
{include/i-prgvrs.i ck0092rp 2.04.00.001}

/* definicao das temp-tables para recebimento de parametros */
{ckinc/ck0092.i}

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

/* def var l-digitou as logical no-undo. */
def var h-acomp as handle no-undo.

create tt-param.
raw-transfer raw-param to tt-param.

/* for each tt-raw-digita:                                 */
/*     create tt-digita.                                   */
/*     raw-transfer tt-raw-digita.raw-digita to tt-digita. */
/*     assign l-digitou = true.                            */
/* end.                                                    */

/* temp-tables de processamento */
def temp-table tt-saldos
    field .


/* Include padrao para variaveis de relatorio */
{include/i-rpvar.i}

/* form header                                                */
/*     with width 132 no-labels no-box page-top frame f-cab2. */

find first param-global no-lock no-error.

assign c-programa     = "ck0092rp"
       c-versao       = "2.04"
       c-revisao      = "001"
       c-empresa      = param-global.grupo
       c-titulo-relat = "Saldos em estoque"
       c-sistema      = "Estoque".

/* include padrao para output de relatorio */
{include/i-rpout.i}

/* include com a definicao da frame de cabecalho e rodape */
{include/i-rpcab.i}

view frame f-cabec.
view frame f-rodape.
/* view frame f-cab2. */

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input 'Preparando...').

/* preparacao dos dados */
for each

    run pi-acompanhar in h-acomp (input '').

    create tt-saldo.
end.


run pi-seta-titulo in h-acomp (input 'Imprimindo...').

/* impressao do relatorio */
for each 

    run pi-acompanhar in h-acomp (input string(esp-nota-fiscal.data-saida-trans)).


    disp 

        with stream-io down width 132 no-box frame f-rel.
    down with frame f-rel.


    end.

end.


run pi-finalizar in h-acomp.

/* fechamento do output do relatorio */
{include/i-rpclo.i}

return.
