/************************************************************************
**
** ftapi001.i - Definiá∆o vari†veis integraá∆o FT x CR (ftapi001.p) 
**
*************************************************************************/ 

{utp/ut0666.i}
{cdp/cd7300.i1}

/*********************** Temp TableÔs ***********************/

def temp-table tt-nota-fiscal no-undo
    field atualizar     as log  init yes
    field referencia    as char format "x(10)"
    field r-nota-fiscal as rowid
    field emite-duplic  like nota-fiscal.emite-duplic
    field cod-estabel   like nota-fiscal.cod-estabel
    field serie         like nota-fiscal.serie
    field nr-fatura     like nota-fiscal.nr-fatura.

def new global shared temp-table tt-seven
    field ep-codigo      like lin-i-cr.ep-codigo
    field cod-estabel    like lin-i-cr.cod-estabel 
    field referencia     like lin-i-cr.referencia  
    field sequencia      like lin-i-cr.sequencia  
    field seq-import     like lin-i-cr.seq-import
    field perc-multa     like lin-i-cr.perc-multa.   
    
def temp-table tt-cheque-pend like cheque-pend.    
def temp-table tt-his-tit-pend like his-tit-pend.
def temp-table tt-relacto-pend-titulo-cheq like relacto-pend-titulo-cheq.

def temp-table tt-retorno-nota-fiscal no-undo
    field tipo       as integer   /* 1- Nota Fiscal 2- T°tulo 3- Nota de DÇbito/CrÇdito */
    field cod-erro   as character format "x(10)"
    field referencia as character format "x(10)"
    field desc-erro  as character format "x(60)"
                        view-as editor max-chars 2000 
                        scrollbar-vertical size 50 by 4
    field situacao   as logical
    field cod-chave  as character
    INDEX ch-codigo  IS PRIMARY tipo
                                cod-erro
                                cod-chave.

def temp-table tt-total-refer no-undo
    field referencia     as char format "x(10)"
    field nr-doctos      as int
    field vendas-a-vista as dec format '->>>,>>>,>>9.99'
    field vendas-a-prazo as dec format '->>>,>>>,>>9.99'
    field vl-total       as dec format '->>>,>>>,>>9.99'
    INDEX ch-codigo      IS PRIMARY referencia.

def temp-table tt-imposto
    field cod-imposto  as integer
    field vl-base      as decimal
    field vl-imposto   as decimal.
    
def temp-table tt-previsao-remito no-undo
    field cod-estabel as char
    field serie       as char
    field nr-remito   as char
    field vl-faturado as decimal
    index ch-remito is primary unique cod-estabel
                                      serie
                                      nr-remito.
    
def temp-table tt-fat-duplic-lido no-undo
    like fat-duplic.

/******************** Buffers *************************/

def buffer b-nota-fiscal-orig for nota-fiscal.
def buffer b-fat-duplic-orig  for fat-duplic.
def buffer b-titulo-orig      for titulo.
def buffer b-nota             for nota-fiscal.
def buffer b-fat-dupl         for fat-duplic.
def buffer b-fat-duplic       for fat-duplic.
def buffer b-repres           for repres.
def buffer b-emitente         for emitente.
def buffer b-natur-op         for natur-oper.
def buffer b-ped-venda        for ped-venda.

/************ Integraá∆o 2.00 X 5.00 *****************/

def new global shared var c-seg-usuario      as char format "x(12)" no-undo.
def new global shared var v_cod_usuar_corren as char format "x(12)" no-undo. 

def new global shared var l-seven as log init no no-undo.     

def new shared var i-emitente-cod-gr-cli like emitente.cod-gr-cli.
def new shared var i-cod-rep             like repres.cod-rep. 
def new shared var i-cod-princ           like repres.cod-rep. 

def new shared var de-abatim     as decimal.
def new shared var i-port-cod    like mgadm.portador.cod-portador.
def new shared var c-port-abrev  like mgadm.portador.nome-abrev.   
def new shared var c-cod-esp     like esp-doc.cod-esp init "".

def new shared var de-tot-aux    like it-nota-fisc.vl-tot-item.
def new shared var de-tot-it     like it-nota-fisc.vl-tot-item.
def new shared var de-comis      as decimal format ">>9.99999999".
def new shared var de-comis-emis as decimal format ">>9.99999999".
def new shared var de-comis-ind  as decimal format ">>9.99999999".
def new shared var l-principal   as logical.

def var de-comis-tot    as decimal format ">>9.99999999".
def var de-vl-comisnota like nota-fiscal.vl-comis-nota.
def var i-num-est       as integer.
def var i-tamanho       as integer.
def var c-parcela-orig  as char  format "x(02)"  no-undo. 
def var c-especie-pre   as char                  no-undo.
def var c-nr-pedido     like ped-venda.nr-pedido no-undo.

/********************* Work Files **********************/

def workfile doc-work
    field reg-doc as rowid.

def workfile w-fat-repre
    field nome-ab-rep like fat-repre.nome-ab-rep
    field posicao     as integer.

/************************* FT0506 *********************/

/* estas variaveis permitiram que este programa seja executado pelo ft0506
   conforme para-fat.ind-atu-cr */


def var c-nome-abrev      like emitente.nome-abrev no-undo.
def var i-ind             as integer.
def var r-fat-dupl        as rowid.
def var r-nota            as rowid.
 
def var c-nome-cliente    like emitente.nome-abrev no-undo.
def var c-serie           like serie.serie no-undo.
 
def var l-titulo          as logical.
def var i-nr-seq          like lin-i-cr.sequencia.
def var de-vl-total       like doc-i-cr.total-movto.
def var de-vl-vista       like doc-i-cr.total-movto.
def var de-vl-prazo       like doc-i-cr.total-movto.
def var de-titulo         like fat-duplic.vl-parcela.
def var de-maior-tit      like fat-duplic.vl-parcela.
def var de-fator1         as decimal.
def var de-fator2         as decimal.
def var c-fr-val          as character.
def var c-conta           as character format "x(20)".
def var c-ccusto          as character format "x(20)".
def var c-emp             as character format "x(52)". 
def var c-estab           as character format "x(16)".
def var c-num-docto       as character format "x(20)".
def var c-especie         as character format "x(8)".
def var c-pend            as character format "x(44)".
def var i-tot-doc         as integer format ">,>>9".
def var i-not-doc         as integer.
def var l-confirma        as logical format "Sim/Nao".
def var l-tem-repres      as logical init no no-undo.
def var de-conta          as decimal.

def var l-erro            as logical no-undo.
def var l-atual           as logical no-undo.

/****** Calcular a comissao pelo cadastro de comissoes ******/

def var l-achou     as logical               init no no-undo.
def var l-comissao  as logical               init no no-undo.
def var i-co-tab    as integer  format "99"  init 0  no-undo.
def var i-tab       as integer  format "99"  init 0  no-undo.



def var c-ref       as char     format "x(13)"                no-undo.
def var c-reg-tab   like comissao.nome-ab-reg         init ?  extent 64.
def var c-fam-tab   like comissao.fm-codigo           init ?  extent 64.
def var c-fmcom-tab like comissao.fm-cod-com          init ?  extent 64.
def var i-rep-tab   like comissao.cod-rep             init ?  extent 64.
def var i-cpg-tab   like comissao.cod-cond-pag        init ?  extent 64.
def var i-grp-tab   like comissao.cod-gr-cli          init ?  extent 64.

/******** Variaveis para chamar CR0501A.P **********/

def new shared frame f-referencia with stream-io.
def new shared frame f-linha with stream-io.
def new shared frame f-total with stream-io.
def var d-vl-total      like doc-i-cr.total-movto.
def var i-sequencia     like lin-i-cr.sequencia   init 0.
def new shared var r-registro  as rowid no-undo.
def new shared var c-sistema-x as character format "x(2)" init "FT".

/******* Vari†veis para geraá∆o dos impostos pendentes *******/

def var i-cod-tax           like tipo-tax.cod-tax.
def var de-vl-imposto       like it-nota-imp.vl-imposto.
def var i-parcela           like cond-pagto.num-parcela.
def var i-num-parcela       like cond-pagto.num-parcela.
def var de-vl-tot-imposto   like it-nota-imp.vl-imposto.
def var de-vl-parcela       like it-nota-imp.vl-imposto.
def var de-vl-base          like it-nota-imp.vl-base-imp.
def var gr-imposto          as rowid.
def var de-acum-base        as decimal.
def var de-acum-imposto     as decimal.
def var de-tot-base         as decimal.
def var de-tot-imposto      as decimal.

def var i-cont      as int no-undo.
def var i-cod       as int no-undo.
def var i-cont-parc as int no-undo.

def var c-ft       as char format "x(02)" no-undo.

def new shared var l-implanta as logical.

def var c-tabela as character.  
def var c-mensagem as char format "x(35)".
def var c-mensagem1 as char format "x(20)".

/**** Vari†veis para gerar a previs∆o no CR - Internacional ***/

def var de-total-item as decimal no-undo.

def var i-num-parcelas     as integer no-undo.
def var de-vl-tot-parcelas as decimal no-undo.
def var de-vl-parcela-pre  like lin-prev.vl-previsao.

/**************** Vendor ******************/

def var l-vendor as logical no-undo.

/* ftapi001.i */
