/*************************************************************************
** 
**  Programa: REAPI214.I
** 
**  Objetivo: Defini‡Æo das temp-tables usadas na API REAPI214.p
**
*************************************************************************/                                

def temp-table tt-docto-dev-aux 
    field c-mp-cod-esp        like fat-duplic.cod-esp
    field c-mp-cod-estabel    like estabelec.cod-estabel
    field c-mp-it-codigo      like item-doc-est.it-codigo
    field c-mp-nat-operacao   like docum-est.nat-operacao
    field c-mp-serie          like item-doc-est.serie-comp
    field c-mp-serie-comp     like item-doc-est.serie-comp
    field da-mp-dt-trans      like docum-est.dt-trans
    field de-mp-vl-devol      as   decimal
    field i-mp-cod-emitente   like emitente.cod-emitente
    field i-mp-empresa-prin   like param-global.empresa-prin
    field i-mp-nr-parc        like fat-duplic.nr-fatura
    field i-mp-nro-comp       like item-doc-est.nro-comp
    field i-mp-nro-docto      like item-doc-est.nro-docto
    field i-mp-parcela        like fat-duplic.parcela
    field i-mp-sequencia      like item-doc-est.sequencia
    field l-mp-estorn-comis   like docum-est.estorn-comis
   INDEX documento IS PRIMARY c-mp-serie
                              i-mp-nro-docto
                              c-mp-cod-estabel
                              c-mp-nat-operacao
                              i-mp-sequencia.                               


def temp-table tt-docto-dev
    field c-mp-cod-esp        like fat-duplic.cod-esp
    field c-mp-cod-estabel    like estabelec.cod-estabel
    field c-mp-it-codigo      like item-doc-est.it-codigo
    field c-mp-nat-operacao   like docum-est.nat-operacao
    field c-mp-serie          like item-doc-est.serie-comp
    field c-mp-serie-comp     like item-doc-est.serie-comp
    field da-mp-dt-trans      like docum-est.dt-trans
    field de-mp-vl-devol      as   decimal
    field i-mp-cod-emitente   like emitente.cod-emitente
    field i-mp-empresa-prin   like param-global.empresa-prin
    field i-mp-nr-parc        like fat-duplic.nr-fatura
    field i-mp-nro-comp       like item-doc-est.nro-comp
    field i-mp-nro-docto      like item-doc-est.nro-docto
    field i-mp-parcela        like fat-duplic.parcela
    field i-mp-sequencia      like item-doc-est.sequencia
    field l-mp-estorn-comis   like docum-est.estorn-comis
    field cod-maq-origem   like maquina.cd-maquina
    field num-processo     as   integer format ">>>>>>>>9" initial 0
    field num-sequencia    as   integer format ">>>>>9"    initial 0
    field ind-tipo-movto   as   integer format "99"        initial 1
    INDEX documento IS PRIMARY  cod-maq-origem
                                num-processo
                                num-sequencia.

