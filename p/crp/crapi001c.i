
/*********************************************************************
***
***    crp/crapi001b.i - Definicao Temp-table para gera‡Æo Dados do 
***    Faturmento no Contas a Receber                         
***
**********************************************************************/

def temp-table tt-doc-i-cr no-undo
    field ep-codigo            LIKE ems2mult.empresa.ep-codigo
    field referencia           as   char format "x(10)"
    field cod-estabel          as   char format "x(3)"
    field total-movto          as   dec  format ">>,>>>,>>>,>>9.99" decimals 2
    field dt-movto             as   date format "99/99/9999"
    field ct-credito           as   char format "x(20)"
    field sc-credito           as   char format "x(20)"
    field serie                as   char format "x(5)"
    field conta-credito        as   char format "x(17)"
    field cod-portador-cb      as   int  format ">>>>9"
    field mo-codigo            as   int  format ">9" 
    field char-1               as   char format "x(100)"
    field char-2               as   char format "x(100)"
    field dec-1                as   dec  format "->>>>>>>>>>>9.99999" decimals 8
    field dec-2                as   dec  format "->>>>>>>>>>>9.99999" decimals 8
    field int-1                as   int  format "->>>>>>>>>9"
    field int-2                as   int  format "->>>>>>>>>9"
    field log-1                as   log  format "Sim/NÆo"
    field log-2                as   log  format "Sim/NÆo"
    field data-1               as   date format "99/99/9999"
    field data-2               as   date format "99/99/9999"
    field ind-sit-lote-implantacao-cr  as   int  format ">9"
    field refer-integ-cb       as   char format "x(16)"
    field check-sum            as   char format "x(20)"
    field cod-versao-integ as integer init 0 format "999" /* 1 - Elimina lote em caso de erro */
    field ind-elimina-lote as integer init 1 format "99" /*2 - Deixa pendente lote com erro */  
    index codigo                            is primary unique
          ep-codigo               ascending
          cod-estabel             ascending 
          referencia              ascending.


def temp-table tt-lin-i-cr no-undo
    field ep-codigo        LIKE ems2mult.empresa.ep-codigo
    field referencia       as  char format "x(10)"
    field sequencia        as  int  format ">>>,>>9"
    field cod-esp          as  char format "!!"
    field cod-estabel      as  char format "x(3)"
    field nr-docto         as  char format "x(16)"
    field parcela          as  char format "x(2)"
    field cod-emitente     as  int  format ">>>>>>>>9"
    field cod-rep          as  int  format ">>>>9"
    field cod-portador     as  int  format ">>>>9"
    field modalidade       as  int  format "9"
    field dt-emissao       as  date format "99/99/9999"
    field dt-vencimen      as  date format "99/99/9999"
    field vl-bruto         as  dec  format ">>>>>>>,>>9.99" decimals 2
    field vl-liquido       as  dec  format "->>>,>>>,>>>,>>9.99" decimals 2
    field dt-desconto      as  date format "99/99/9999"
    field vl-desconto      as  dec  format ">>>>>>>,>>9.99" decimals 2
    field pedido-rep       as         char format "x(12)"
    field nat-operacao     as         char format "9.99-xxx"
    field nr-pedcli        as         char format "x(12)"
    field situacao         as         int  format "9"
    field emite-bloq       as         log  format "Sim/Nao"
    field ct-conta         as         char format "x(20)"
    field sc-conta         as         char format "x(20)"
    field cod-cond-pag     as         int  format ">>9"
    field cod-vencto       as         int  format "9"
    field vl-fatura        as         dec  format ">>>>>>>,>>9.99" decimals 2
    field seq-import       as         int  format ">>>>>9"
    field tp-codigo        as         int  format ">>9"
    field vl-abatimento    as         dec  format ">>>>>>>,>>9.99" decimals 2
    field u-data-1         as         date format "99/99/9999"
    field valor-cmi        as         dec  format ">>>,>>>,>>9.99" decimals 2
    field valor-pres       as         dec  format ">>>,>>>,>>9.99" decimals 2
    field valor-fasb       as         dec  format ">>>,>>>,>>9.99" decimals 2
    field cod-controle     as         char format "x(15)"
    field origem           as         int  format ">9"
    field mercado          as         int  format ">9"
    field mo-negoc         as         int  format ">9"
    field conta-credito    as         char format "x(17)"
    field serie            as         char format "x(5)"
    field contabilizou     as         log  format "Sim/NÆo"
    field cotacao-dia      as         dec  format ">>>,>9.99999999" decimals 8
    field diversos         as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field dt-pg-prev       as   date format "99/99/9999"
    field frete            as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field l-calc-desc      as   log  format "Sim/NÆo"
    field mo-codigo        as   int  format ">9"
    field observacao       as   char format "x(2000)"
    field tipo-titulo      as   int  format "9"
    field cod-esp-vincul   as   char format "!!"
    field serie-vincul     as   char format "x(5)"
    field nr-docto-vincul  as   char format "x(16)"
    field parcela-vincul   as   char format "x(2)"
    field vl-bruto-me      as   dec  format ">>>>>>>,>>9.99" decimals 2
    field frete-me         as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field diversos-me      as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-liquido-me    as   dec  format "->>>,>>>,>>>,>>9.99" decimals 2
    field vl-desconto-me   as   dec  format ">>>>>>>,>>9.99" decimals 2
    field vl-fatura-me     as   dec  format ">>>>>>>,>>9.99" decimals 2
    field vl-abatimento-me as   dec  format ">>>>>>>,>>9.99" decimals 2
    field char-1           as   char format "x(100)"
    field char-2           as   char format "x(100)"
    field dec-1            as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field dec-2            as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field int-1            as   int  format "->>>>>>>>>9"
    field int-2            as   int  format "->>>>>>>>>9"
    field log-1            as   log  format "Sim/NÆo"
    field log-2            as   log  format "Sim/NÆo"
    field data-1           as   date format "99/99/9999"
    field data-2           as   date format "99/99/9999"
    field perc-multa       as   dec  format ">>>9.99" decimals 2
    field dt-multa         as   date format "99/99/9999"
    field nr-docto-deposito as  char format "x(16)"
    field cod-entrega       as  char format "x(12)"
    field check-sum         as  char format "x(20)"
    field num-titulo-banco  as  char format "x(20)"
    field perc-desc-an      as  deci format ">>9.99999" decimals 5
    field log-port-centr    as  log  format "yes/no"
    field nr-proc-exp       as  char format "x(12)"
    field l-vincula-contr-cambio as  log  format "yes/no"
    field vl-pis            as  dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-cofins         as  dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-csll           as  dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field l-ret-impto      as  log  format "yes/no"
    field vl-base-calc-ret as  dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    index codigo                            is primary unique
          ep-codigo               ascending
          cod-estabel             ascending 
          referencia              ascending
          sequencia               ascending
          seq-import              ascending.

def temp-table tt-ext-lin-i-cr no-undo
    field ep-codigo        LIKE ems2mult.empresa.ep-codigo
    field referencia       as   char format "x(10)"
    field sequencia        as   int  format ">>>,>>9"
    field cod-esp          as   char format "!!"
    field cod-estabel      as   char format "x(3)"
    field nr-docto         as   char format "x(16)"
    field parcela          as   char format "x(2)"
    field cod-emitente     as   int  format ">>>>>>>>9"
    field cod-rep          as   int  format ">>>>9"
    field cod-portador     as   int  format ">>>>9"
    field modalidade       as   int  format "9"
    field dt-emissao       as   date format "99/99/9999"
    field dt-vencimen      as   date format "99/99/9999"
    field vl-bruto         as   dec  format ">>>>>>>,>>9.99" decimals 2
    field vl-liquido       as   dec  format "->>>,>>>,>>>,>>9.99" decimals 2
    field dt-desconto      as   date format "99/99/9999"
    field vl-desconto      as   dec  format ">>>>>>>,>>9.99" decimals 2
    field pedido-rep       as         char format "x(12)"
    field nat-operacao     as         char format "9.99-xxx"
    field nr-pedcli        as         char format "x(12)"
    field situacao         as         int  format "9"
    field emite-bloq       as         log  format "Sim/Nao"
    field ct-conta         as         char format "x(20)"
    field sc-conta         as         char format "x(20)"
    field cod-cond-pag     as         int  format ">>9"
    field cod-vencto       as         int  format "9"
    field vl-fatura        as         dec  format ">>>>>>>,>>9.99" decimals 2
    field seq-import       as         int  format ">>>>>9"
    field tp-codigo        as         int  format ">>9"
    field vl-abatimento    as         dec  format ">>>>>>>,>>9.99" decimals 2
    field u-data-1         as         date format "99/99/9999"
    field valor-cmi        as         dec  format ">>>,>>>,>>9.99" decimals 2
    field valor-pres       as         dec  format ">>>,>>>,>>9.99" decimals 2
    field valor-fasb       as         dec  format ">>>,>>>,>>9.99" decimals 2
    field cod-controle     as         char format "x(15)"
    field origem           as         int  format ">9"
    field mercado          as         int  format ">9"
    field mo-negoc         as         int  format ">9"
    field conta-credito    as         char format "x(17)"
    field serie            as         char format "x(5)"
    field contabilizou     as         log  format "Sim/NÆo"
    field cotacao-dia      as         dec  format ">>>,>9.99999999" decimals 8
    field diversos         as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field dt-pg-prev       as   date format "99/99/9999"
    field frete            as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field l-calc-desc      as   log  format "Sim/NÆo"
    field mo-codigo        as   int  format ">9"
    field observacao       as   char format "x(2000)"
    field tipo-titulo      as   int  format "9"
    field cod-esp-vincul   as   char format "!!"
    field serie-vincul     as   char format "x(5)"
    field nr-docto-vincul  as   char format "x(16)"
    field parcela-vincul   as   char format "x(2)"
    field vl-bruto-me      as   dec  format ">>>>>>>,>>9.99" decimals 2
    field frete-me         as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field diversos-me      as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-liquido-me    as   dec  format "->>>,>>>,>>>,>>9.99" decimals 2
    field vl-desconto-me   as   dec  format ">>>>>>>,>>9.99" decimals 2
    field vl-fatura-me     as   dec  format ">>>>>>>,>>9.99" decimals 2
    field vl-abatimento-me as   dec  format ">>>>>>>,>>9.99" decimals 2
    field char-1           as   char format "x(100)"
    field char-2           as   char format "x(100)"
    field dec-1            as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field dec-2            as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field int-1            as   int  format "->>>>>>>>>9"
    field int-2            as   int  format "->>>>>>>>>9"
    field log-1            as   log  format "Sim/NÆo"
    field log-2            as   log  format "Sim/NÆo"
    field data-1           as   date format "99/99/9999"
    field data-2           as   date format "99/99/9999"
    field perc-multa       as   dec  format ">>>9.99" decimals 2
    field dt-multa         as   date format "99/99/9999"
    field nr-docto-deposito as  char format "x(16)"
    field cod-entrega       as  char format "x(12)"
    field check-sum         as  char format "x(20)"
    field num-titulo-banco  as  char format "x(20)"
    field perc-desc-an      as  deci format ">>9.99999" decimals 5
    field log-port-centr    as  log  format "yes/no"
    field nr-proc-exp       as  char format "x(12)"
    field l-vincula-contr-cambio as  log  format "yes/no"
    field tp-ret-iva         as         int  format ">>>9"
    field tp-ret-gan         as         int  format ">>9"
    field acum-ant-gan       as         dec  format ">>>,>>9.99"      decimals 2
    field vl-base-gan        as         dec  format ">>>,>>9.99"      decimals 2
    field gravado            as         dec  format ">>>,>>>,>>9.99"  decimals 2
    field no-gravado         as         dec  format ">>>,>>>,>>9.99"  decimals 2
    field isento             as         dec  format ">>>,>>>,>>9.99"  decimals 2
    field uf-entrega         as         char format "x(4)".

def temp-table tt-rep-i-cr no-undo
    field ep-codigo          LIKE ems2mult.empresa.ep-codigo
    field cod-estabel        as   char format "x(3)"
    field cod-esp            as   char format "!!"
    field nr-docto           as   char format "x(16)"
    field parcela            as   char format "x(2)"
    field cod-rep            as   int  format ">>>>9"
    field comissao           as   dec  format ">>9.99999999" decimals 8
    field comis-emis         as   dec  format ">>9.99999999" decimals 8
    field serie              as   char format "x(5)"
    field char-1             as   char format "x(100)"
    field char-2             as   char format "x(100)"
    field dec-1              as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field dec-2              as   dec  format "->>>>>>>>>>>9.99999" decimals 2     
    field int-1              as   int  format "->>>>>>>>>9"
    field int-2              as   int  format "->>>>>>>>>9"
    field log-1              as   log  format "Sim/NÆo"
    field log-2              as   log  format "Sim/NÆo"
    field data-1             as   date format "99/99/9999"
    field data-2             as   date format "99/99/9999"
    field check-sum          as   char format "x(20)"
    field cod-classificador  as   char format "x(8)"
    field perc-abatimento    as   dec  format ">>9.99999999" decimals 8
    field perc-juros         as   dec  format ">>9.99999999" decimals 8
    field perc-multa         as   dec  format ">>9.99999999" decimals 8
    field perc-desconto      as   dec  format ">>9.99999999" decimals 8
    field perc-AVA           as   dec  format ">>9.99999999" decimals 8
    field comis-propor       as   log  format "Sim/NÆo"
    field vl-base-calc-comis as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
&IF DEFINED(BF_FIN_RAC) &THEN 
    index codigo                  is primary unique
          ep-codigo               ascending
          cod-estabel             ascending 
          cod-esp                 ascending
          serie                   ascending
          nr-docto                ascending
          parcela                 ascending
          cod-rep                 ascending
          cod-classificador       ascending.
&ELSE
    index codigo                  is primary unique
          ep-codigo               ascending
          cod-estabel             ascending 
          cod-esp                 ascending
          serie                   ascending
          nr-docto                ascending
          parcela                 ascending
          cod-rep                 ascending.
&ENDIF




def temp-table tt-lin-ant no-undo
    field ep-codigo            LIKE ems2mult.empresa.ep-codigo
    field cod-estabel          as   char format "x(3)"
    field cod-esp              as   char format "!!"
    field nr-docto             as   char format "x(16)"
    field parcela              as   char format "x(2)"
    field cod-emitente         as   int  format ">>>>>>>>9"
    field esp-antecip          as   char format "!!"
    field doc-antecip          as   char format "x(16)"
    field parc-antecip         as   char format "x(2)"
    field vl-antecip           as   dec  format ">>,>>>,>>>,>>9.99"  decimals 2
    field vl-ant-fasb          as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field u-data-1             as   date format "99/99/9999"
    field cod-controle         as   char format "x(15)"
    field serie                as   char format "x(5)"
    field serie-antecip        as   char format "x(5)"
    field cod-estabel-transf   as   char format "x(3)"
    field conta-transf         as   char format "x(17)"
    FIELD ct-transf            AS   CHAR FORMAT "x(20)"
    FIELD sc-transf            AS   CHAR FORMAT "x(20)"
    field vl-antecip-me        as   dec  format ">>>>>>>,>>9.99" decimals 2
    field mo-codigo            as   int  format ">9"
    field vl-var-monet         as   dec  format "->>,>>>,>>>,>>9.99" decimals 2
    field cotacao-dia          as   dec  format ">>>,>9.99999999"    decimals 8
    field vl-var-monet-antecip as   dec  format "->>,>>>,>>>,>>9.99" decimals 2
    field origem-antecip       as   int  format "9"
    field char-1               as   char format "x(100)"
    field char-2               as   char format "x(100)"
    field dec-1                as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field dec-2                as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field int-1                as   int  format "->>>>>>>>>9"
    field int-2                as   int  format "->>>>>>>>>9"
    field log-1                as   log  format "Sim/NÆo"
    field log-2                as   log  format "Sim/NÆo"
    field data-1               as   date format "99/99/9999"
    field data-2               as   date format "99/99/9999"
    field check-sum            as   char format "x(20)".

def temp-table tt-lin-prev no-undo
    field ep-codigo            LIKE ems2mult.empresa.ep-codigo
    field cod-estabel          as         char format "x(3)"
    field cod-esp              as         char format "!!"
    field nr-docto             as         char format "x(16)"
    field parcela              as         char format "x(2)"
    field ep-cod-pre           LIKE ems2mult.empresa.ep-codigo
    field cod-est-pre          as         char format "x(3)"
    field cod-esp-pre          as         char format "!!"
    field nr-docto-pre         as         char format "x(16)"
    field parcela-pre          as         char format "x(2)"
    field vl-previsao          as   dec  format ">>,>>>,>>>,>>9.99" decimals 2
    field moeda-pre            as         int  format ">9"
    field cod-controle         as         char format "x(15)"
    field serie                as         char format "x(5)"
    field serie-pre            as         char format "x(5)"
    field vl-previsao-me       as   dec  format ">>,>>>,>>>,>>9.99" decimals 2
    field char-1               as         char format "x(100)"
    field char-2               as         char format "x(100)"
    field dec-1                as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field dec-2                as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field int-1                as         int  format "->>>>>>>>>9"
    field int-2                as         int  format "->>>>>>>>>9"
    field log-1                as         log  format "Sim/NÆo"
    field log-2                as         log  format "Sim/NÆo"
    field data-1               as         date format "99/99/9999"
    field data-2               as         date format "99/99/9999"
    field check-sum            as         char format "x(20)".

def temp-table tt-impto-tit-pend-cr no-undo
    field ep-codigo            LIKE ems2mult.empresa.ep-codigo
    field cod-estabel          as         char format "x(3)"
    field serie                as         char format "x(5)"
    field cod-esp              as         char format "!!"
    field nr-docto             as         char format "x(16)"
    field parcela              as         char format "x(2)"
    field cod-emitente         as         int  format ">>>>>>>>9"
    field vl-imposto           as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field ct-imposto           as         char format "x(20)"
    field sc-imposto           as         char format "x(20)"
    field conta-imposto        as         char format "x(17)"
    field tipo                 as         int  format "99"
    field contabilizou         as         log  format "Sim/NÆo"
    field perc-imposto         as         dec  format ">>>9.99" decimals 2
    field cod-imposto          as         int  format ">>>9"
    field dt-transacao         as         date format "99/99/9999"
    field vl-base              as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field dt-emissao           as         date format "99/99/9999"
    field obs                  as         char format "x(2000)"
    field ind-data-base        as         int  format "9"
    field vl-saldo-imposto     as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field lancamento           as         int  format ">9"
    field ct-percepcao         as         char format "x(20)"
    field sc-percepcao         as         char format "x(20)"
    field conta-percepcao      as         char format "x(17)"
    field vl-percepcao         as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field ct-retencao          as         char format "x(20)"
    field sc-retencao          as         char format "x(20)"
    field conta-retencao       as         char format "x(17)" 
    field perc-retencao        as         dec  format ">>>9.99" decimals 2
    field vl-retencao          as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field perc-percepcao       as         dec  format ">>>9.99" decimals 2
    field vl-imposto-me        as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-base-me           as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-saldo-imposto-me  as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-percepcao-me      as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-retencao-me       as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2    
    field mo-codigo            as         int  format ">9"
    field num-seq-impto        as         int  format ">>>>>>>>>9"
    field cotacao-dia          as   dec  format ">>>,>9.99999999" decimals 8
    field vl-var-monet         as   dec  format "->>,>>>,>>>,>>9.99" decimals 2
    field transacao-impto      as         int  format ">9"
    field origem-impto         as         int  format ">9"    
    field char-1               as         char format "x(100)"
    field char-2               as         char format "x(100)"
    field dec-1                as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field dec-2                as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field int-1                as         int  format "->>>>>>>>>9"
    field int-2                as         int  format "->>>>>>>>>9"
    field log-1                as         log  format "Sim/NÆo"
    field log-2                as         log  format "Sim/NÆo"
    field data-1               as         date format "99/99/9999"
    field data-2               as         date format "99/99/9999"
    field ind-tip-calculo      as         int  format "9"   
    field vl-iva-liberado      as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-iva-liberado-me   as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field perc-iva-liberado    as   dec  format ">>>9.99" decimals 2
    field ct-iva-liberado      as         char format "x(20)"
    field sc-iva-liberado      as         char format "x(20)"
    field conta-iva-liberado   as         char format "x(17)"
    field conta-saldo-credito  as         char format "x(17)"
    field sc-saldo-credito     as         char format "x(20)"
    field ct-saldo-credito     as         char format "x(20)"
    field cod-esp-ret          as         char format "!!"
    field serie-ret            as         char format "x(5)"
    field nr-docto-ret         as         char format "x(16)"
    field parcela-ret          as         char format "x(2)"
    field nat-operacao         as         char format "9.99-xxx"
    field cod-classificacao    as         int  format ">>>9"
    field ind-tipo-imposto     as         int  format ">9"
    field check-sum            as         char format "x(20)".

def temp-table tt-ext-impto-tit-pend-cr no-undo
    field ep-codigo            LIKE ems2mult.empresa.ep-codigo
    field cod-estabel          as         char format "x(3)"
    field serie                as         char format "x(5)"
    field cod-esp              as         char format "!!"
    field nr-docto             as         char format "x(16)"
    field parcela              as         char format "x(2)"
    field cod-emitente         as         int  format ">>>>>>>>9"
    field vl-imposto           as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field ct-imposto           as         char format "x(20)"
    field sc-imposto           as         char format "x(20)"
    field conta-imposto        as         char format "x(17)"
    field tipo                 as         int  format "99"
    field contabilizou         as         log  format "Sim/NÆo"
    field perc-imposto         as         dec  format ">>>9.99" decimals 2
    field cod-imposto          as         int  format ">>>9"
    field dt-transacao         as         date format "99/99/9999"
    field vl-base              as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field dt-emissao           as         date format "99/99/9999"
    field obs                  as         char format "x(2000)"
    field ind-data-base        as         int  format "9"
    field vl-saldo-imposto     as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field lancamento           as         int  format ">9"
    field ct-percepcao         as         char format "x(20)"
    field sc-percepcao         as         char format "x(20)"
    field conta-percepcao      as         char format "x(17)"
    field vl-percepcao         as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field ct-retencao          as         char format "x(20)"
    field sc-retencao          as         char format "x(20)"
    field conta-retencao       as         char format "x(17)" 
    field perc-retencao        as         dec  format ">>>9.99" decimals 2
    field vl-retencao          as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field perc-percepcao       as         dec  format ">>>9.99" decimals 2
    field vl-imposto-me        as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-base-me           as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-saldo-imposto-me  as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-percepcao-me      as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-retencao-me       as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2    
    field mo-codigo            as         int  format ">9"
    field num-seq-impto        as         int  format ">>>>>>>>>9"
    field cotacao-dia          as   dec  format ">>>,>9.99999999" decimals 8
    field vl-var-monet         as   dec  format "->>,>>>,>>>,>>9.99" decimals 2
    field transacao-impto      as         int  format ">9"
    field origem-impto         as         int  format ">9"    
    field char-1               as         char format "x(100)"
    field char-2               as         char format "x(100)"
    field dec-1                as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field dec-2                as   dec  format "->>>>>>>>>>>9.99999" decimals 2
    field int-1                as         int  format "->>>>>>>>>9"
    field int-2                as         int  format "->>>>>>>>>9"
    field log-1                as         log  format "Sim/NÆo"
    field log-2                as         log  format "Sim/NÆo"
    field data-1               as         date format "99/99/9999"
    field data-2               as         date format "99/99/9999"
    field ind-tip-calculo      as         int  format "9"   
    field vl-iva-liberado      as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field vl-iva-liberado-me   as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field perc-iva-liberado    as   dec  format ">>>9.99" decimals 2
    field ct-iva-liberado      as         char format "x(20)"
    field sc-iva-liberado      as         char format "x(20)"
    field conta-iva-liberado   as         char format "x(17)"
    field conta-saldo-credito  as         char format "x(17)"
    field sc-saldo-credito     as         char format "x(20)"
    field ct-saldo-credito     as         char format "x(20)"
    field cod-esp-ret          as         char format "!!"
    field serie-ret            as         char format "x(5)"
    field nr-docto-ret         as         char format "x(16)"
    field parcela-ret          as         char format "x(2)"
    field nat-operacao         as         char format "9.99-xxx"
    field cod-classificacao    as         int  format ">>>9"
    field ind-tipo-imposto     as         int  format ">9"
    field check-sum            as         char format "x(20)"
    field uf                   as         char format "xx".

def temp-table tt-lin-ven no-undo
    field ep-codigo            LIKE ems2mult.empresa.ep-codigo
    field cod-estabel          as         char format "x(3)"
    field cod-esp              as         char format "!!"
    field serie                as         char format "x(5)"
    field nr-docto             as         char format "x(16)"
    field parcela              as         char format "x(2)"
    field taxa-cliente         as         dec  format ">>9.999999" 
    field mo-cliente           as         int  format ">9"
    field cod-cond-cli         as         int  format ">>9"
    field dias-base            as         int  format ">>9"
    field data-base            as         date format "99/99/9999".

def temp-table tt-retorno-lin-i-cr no-undo
    field cod-erro   as character format "x(10)"
    field desc-erro  as character format "x(60)"
                        view-as editor max-chars 2000 
                        scrollbar-vertical size 50 by 4
    field situacao   as logical
    field cod-chave  as character
    INDEX ch-codigo  IS PRIMARY cod-erro
                                cod-chave.

def temp-table tt-erros-cons no-undo
    field cod-erro  as int
    field descricao as char format "x(256)"
    field parametro as char format "x(50)"
    INDEX ch-codigo is primary unique cod-erro
                                      parametro.

/* Fim da Include */



