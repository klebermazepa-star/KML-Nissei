/**********************************************************************
**
**   CRAPI017.I - DEFINICAO DE TEMP-TABLE PARA ESTORNO DO TÖTULO
**
***********************************************************************/
/******************************************************************************
 ** ATENCAO.: Qualquer altera»’o que for feita nas temp-tables tt-tot-tit e  **
 **         tt-titulo tamb²m deverÿ ser feita nas temp-tables tt-tot-tit-mp  **
 **         e tt-titulo-mp que est’o definidas logo abaixo.                  **
 ******************************************************************************/


def temp-table tt-tot-tit
    field referencia     like titulo.referencia
    field ep-codigo      like titulo.ep-codigo
    field cod-empresa    as character format "x(3)"
    field cod-estabel    like titulo.cod-estabel
    field cod-estab-ems5 like titulo.cod-estabel
    field cod-esp        like titulo.cod-esp
    field serie          like titulo.serie
    field nr-docto       like titulo.nr-docto
    field cod-emitente   like titulo.cod-emitente
    field tot-saldo      like titulo.vl-saldo
    field tot-baixa      like titulo.vl-saldo
    field mo-codigo      like docum-est.mo-codigo
    field cotacao-dia    like docum-est.cotacao-dia
    field dt-trans       like docum-est.dt-trans
    field nr-docto-cr    like titulo.nr-docto
    field serie-cr       like titulo.serie
    field cod-esp-cr     like titulo.cod-esp 
    field tp-codigo      like natur-oper.tp-rec-desp
    field estorn-comis   like docum-est.estorn-comis
    field sequencia      as   integer
    field ct-devol       AS CHAR FORMAT "x(20)"
    FIELD sc-devol       AS CHAR FORMAT "x(20)"
    field erro           as logical
    index seq            is primary unique
          sequencia
    index titulo
          serie
          nr-docto
          ct-devol
          sc-devol.

def temp-table tt-titulo
    field sequencia     as  integer
    field parcela       like titulo.parcela
    field vl-saldo      like titulo.vl-saldo
    field vl-baixa      like titulo.vl-saldo
    field ind-baixa     as logical
    index titulo        is primary
          sequencia
          ind-baixa .


def temp-table tt-tot-tit-imp
    field sequencia         as integer
    field seq-imp           as integer
    field cod-imposto       like it-nota-imp.cod-taxa
    field tipo              like it-nota-imp.tipo-tax
    FIELD ct-imposto        AS CHAR FORMAT "x(20)"
    FIELD sc-imposto        AS CHAR FORMAT "x(20)"
    FIELD ct-percepcao      AS CHAR FORMAT "x(20)"
    FIELD sc-percepcao      AS CHAR FORMAT "x(20)"
    field perc-imposto      like it-nota-imp.aliquota
    field perc-percepcao    like impto-tit-cr.perc-percepcao
    field vl-base           like impto-tit-cr.vl-base
    field vl-base-me        like impto-tit-cr.vl-base-me
    field vl-imposto        like impto-tit-cr.vl-imposto
    field vl-imposto-me     like impto-tit-cr.vl-imposto-me
    field vl-percepcao      like impto-tit-cr.vl-percepcao  
    field vl-percepcao-me   like impto-tit-cr.vl-percepcao-me
    index titulo        is primary
          sequencia
          seq-imp .
    

/*as temp-tables abaixo possuem a mesma defini»’o das temp-tables acima.
  A œnica diferen»a ² que nas temp-tables abaixo foram inclu­dos campos para
  utiliza»’o no multiplanta*/

def temp-table tt-tot-tit-mp
    field referencia     like titulo.referencia
    field ep-codigo      like titulo.ep-codigo
    field cod-empresa    as character format "x(3)"
    field cod-estabel    like titulo.cod-estabel
    field cod-estab-ems5 like titulo.cod-estabel
    field cod-esp        like titulo.cod-esp
    field serie          like titulo.serie
    field nr-docto       like titulo.nr-docto
    field cod-emitente   like titulo.cod-emitente
    field tot-saldo      like titulo.vl-saldo
    field tot-baixa      like titulo.vl-saldo
    field mo-codigo      like docum-est.mo-codigo
    field cotacao-dia    like docum-est.cotacao-dia
    field dt-trans       like docum-est.dt-trans
    field nr-docto-cr    like titulo.nr-docto
    field serie-cr       like titulo.serie
    field cod-esp-cr     like titulo.cod-esp 
    field tp-codigo      like natur-oper.tp-rec-desp
    field estorn-comis   like docum-est.estorn-comis
    field sequencia      as   integer
    FIELD ct-devol       AS CHAR FORMAT "x(20)"
    FIELD sc-devol       AS CHAR FORMAT "x(20)"
    field erro           as logical
    field cod-maq-origem   like maquina.cd-maquina
    field num-processo     as   integer format ">>>>>>>>9" initial 0
    field num-sequencia    as   integer format ">>>>>9"    initial 0
    field ind-tipo-movto   as   integer format "99"        initial 1    
    INDEX documento IS PRIMARY  cod-maq-origem
                                num-processo
                                num-sequencia.

def temp-table tt-titulo-mp
    field sequencia     as  integer
    field parcela       like titulo.parcela
    field vl-saldo      like titulo.vl-saldo
    field vl-baixa      like titulo.vl-saldo
    field ind-baixa     as logical
    field cod-maq-origem   like maquina.cd-maquina
    field num-processo     as   integer format ">>>>>>>>9" initial 0
    field num-sequencia    as   integer format ">>>>>9"    initial 0
    field ind-tipo-movto   as   integer format "99"        initial 1
    INDEX documento IS PRIMARY  cod-maq-origem
                                num-processo
                                num-sequencia.


def temp-table tt-tot-tit-imp-mp
    field sequencia         as integer
    field seq-imp           as integer
    field cod-imposto       like it-nota-imp.cod-taxa
    field tipo              like it-nota-imp.tipo-tax
    field ct-percepcao      as char format "x(20)"
    field sc-percepcao      as char format "x(20)"
    field ct-imposto        as char format "x(20)"
    field sc-imposto        as char format "x(20)"
    field perc-imposto      like it-nota-imp.aliquota
    field perc-percepcao    like impto-tit-cr.perc-percepcao
    field vl-base           like impto-tit-cr.vl-base
    field vl-base-me        like impto-tit-cr.vl-base-me
    field vl-imposto        like impto-tit-cr.vl-imposto
    field vl-imposto-me     like impto-tit-cr.vl-imposto-me
    field vl-percepcao      like impto-tit-cr.vl-percepcao  
    field vl-percepcao-me   like impto-tit-cr.vl-percepcao-me
    field cod-maq-origem   like maquina.cd-maquina
    field num-processo     as   integer format ">>>>>>>>9" initial 0
    field num-sequencia    as   integer format ">>>>>9"    initial 0
    field ind-tipo-movto   as   integer format "99"        initial 1
    INDEX documento IS PRIMARY  cod-maq-origem
                                num-processo
                                num-sequencia.

DEF TEMP-TABLE tt-impto-retid-fat
    FIELD cod-estabel       LIKE titulo.cod-estabel
    FIELD cod-estab-ems5    LIKE titulo.cod-estabel
    FIELD cod-esp           LIKE titulo.cod-esp
    FIELD serie             LIKE titulo.serie
    FIELD nr-docto          LIKE titulo.nr-docto
    FIELD parcela           LIKE titulo.parcela
    FIELD cod-emitente      LIKE titulo.cod-emitente
    FIELD idi-tip-impto     AS   INTEGER
    FIELD vl-impto          AS   DECIMAL
    INDEX documento IS PRIMARY cod-estab-ems5
                               serie
                               nr-docto
                               cod-emitente
                               parcela
                               cod-esp
                               idi-tip-impto.

&global-define bf_devolucao_contas_receber YES

/* fim do include */
