/********************************************************************************
***
*** crp/crapi009.i - Defini‡Æo de temp-tables
***
********************************************************************************/

def temp-table tt-nota-db-cr no-undo
    field ep-codigo       like titulo.ep-codigo
    field cod-estabel     like titulo.cod-estabel
    field cod-esp         like titulo.cod-esp
    field serie           like titulo.serie
    field nr-docto        like titulo.nr-docto
    field parcela         like titulo.parcela
    field nr-docto-gerado like titulo.nr-docto
    field parcela-gerada  like titulo.parcela
    field obs-gerada      like titulo.observacao
    field cod-emitente    like titulo.cod-emitente
    field nome-abrev      like titulo.nome-abrev
    field referencia      like titulo.referencia
    field referencia-cb   like mov-tit.nr-docto-banco
    field dt-emissao      like titulo.dt-emissao
    field dt-trans        as date format "99/99/9999"
    field cod-rep         like titulo.cod-rep
    field cod-port        like titulo.cod-port
    field modalidade      like titulo.modalidade
    field mo-codigo       like titulo.mo-codigo
    field cotacao-dia     like titulo.cotacao-dia
    field vl-original     like titulo.vl-original
    field vl-original-me  like titulo.vl-original-me
    field diversos        like titulo.diversos
    field diversos-me     like titulo.diversos-me
    field frete           like titulo.frete
    field frete-me        like titulo.frete-me
    field conta-credito   like titulo.conta-credito
    field observacao      like titulo.observacao
    field tem-docto-orig  as logical
    field ep-codigo-orig  like titulo.ep-codigo
    field cod-est-orig    like titulo.cod-estabel
    field cod-esp-orig    like titulo.cod-esp
    field serie-orig      like titulo.serie
    field nr-docto-orig   like titulo.nr-docto
    field parcela-orig    like titulo.parcela
    field obs-orig        like titulo.observacao
    field sequencia       as int
    field cod-programa    as char format "x(10)"
    field tp-codigo       like titulo.tp-codigo
    field l-devolucao     as logical
    field l-estorna-comis as logical
    field l-msg-serie     as logical init yes
    field ind-tp-alter    as integer init 1
    field ind-contabiliza as integer init 0
    field int-1           as integer init 0
    field int-2           as integer init 0
    field dec-1           as decimal init 0
    field dec-2           as decimal init 0
    field char-1          as char    init ""
    field char-2          as char    init ""
    field log-1           as logical init no
    field log-2           as logical init no
    INDEX ch-codigo      IS PRIMARY ep-codigo
                                    cod-estabel
                                    cod-esp
                                    serie
                                    nr-docto
                                    parcela.

def new shared temp-table tt-nota-db-cr-shared no-undo
    like tt-nota-db-cr.

def temp-table tt-impto-nota-db-cr no-undo
    field ep-codigo             like impto-tit-cr.ep-codigo
    field cod-estabel           like impto-tit-cr.cod-estabel
    field cod-esp               like impto-tit-cr.cod-esp
    field serie                 like impto-tit-cr.serie
    field nr-docto              like impto-tit-cr.nr-docto
    field parcela               like impto-tit-cr.parcela
    field cod-imposto           like impto-tit-cr.cod-imposto
    field tipo                  like impto-tit-cr.tipo
    field conta-imposto         like impto-tit-cr.conta-imposto
    field ct-imposto            like impto-tit-cr.ct-imposto
    field sc-imposto            like impto-tit-cr.sc-imposto
    field conta-percepcao       like impto-tit-cr.conta-percepcao
    field ct-percepcao          like impto-tit-cr.ct-percepcao
    field sc-percepcao          like impto-tit-cr.sc-percepcao
    field conta-retencao        like impto-tit-cr.conta-retencao
    field ct-retencao           like impto-tit-cr.ct-retencao
    field sc-retencao           like impto-tit-cr.sc-retencao
    field conta-iva-liberado    like impto-tit-cr.conta-iva-liberado
    field conta-saldo-credito   like impto-tit-cr.conta-saldo-credito
    field cotacao-dia           like impto-tit-cr.cotacao-dia
    field mo-codigo             like impto-tit-cr.mo-codigo
    field perc-imposto          like impto-tit-cr.perc-imposto
    field perc-percepcao        like impto-tit-cr.perc-percepcao
    field perc-retencao         like impto-tit-cr.perc-retencao
    field perc-iva-liberado     like impto-tit-cr.perc-iva-liberado
    field vl-base               like impto-tit-cr.vl-base
    field vl-base-me            like impto-tit-cr.vl-base-me
    field vl-imposto            like impto-tit-cr.vl-imposto
    field vl-imposto-me         like impto-tit-cr.vl-imposto-me
    field vl-percepcao          like impto-tit-cr.vl-percepcao
    field vl-percepcao-me       like impto-tit-cr.vl-percepcao-me
    field vl-retencao           like impto-tit-cr.vl-retencao
    field vl-retencao-me        like impto-tit-cr.vl-retencao-me
    field vl-saldo-imposto      like impto-tit-cr.vl-saldo-imposto
    field vl-saldo-imposto-me   like impto-tit-cr.vl-saldo-imposto-me
    field vl-iva-liberado       like impto-tit-cr.vl-iva-liberado
    field vl-iva-liberado-me    like impto-tit-cr.vl-iva-liberado-me
    field num-seq-impto         like impto-tit-cr.num-seq-impto    
    field descricao             like tipo-tax.descricao
    field obs                   like impto-tit-cr.obs
    field int-1                 as   integer init 0
    field int-2                 as   integer init 0
    field dec-1                 as   decimal init 0 /*campo utilizado para grava o vl-liquido*/
    field dec-2                 as   decimal init 0 /*campo utilizado para grava o vl-liquido-me*/
    field char-1                as   char    init ""
    field char-2                as   char    init ""
    field log-1                 as   logical init no
    field log-2                 as   logical init no
    INDEX ch-codigo             IS PRIMARY cod-estabel
                                           cod-esp
                                           serie
                                           nr-docto
                                           parcela.

def temp-table tt-retorno-nota no-undo
    field cod-erro   as character format "x(8)"
    field desc-erro  as character format "x(60)"
    field situacao   as logical
    field cod-chave  as character
    INDEX ch-codigo  IS PRIMARY cod-erro
                                cod-chave.

/* crp/crapi009.i */
