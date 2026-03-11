/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i FTAPI017 2.00.01.068 } /*** 010168 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i ftapi017 MFT}
&ENDIF

/********************************************************************************
** Copyright DATASUL S.A. (2001)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

/************************************************************************
**
** FTAPI017.P - Integra‡Æo Notas Faturamento x Contas a Receber 
**
*************************************************************************/
{utp/ut-glob.i}
{ftp/ftapi001.i}
{cdp/cdcfgdis.i} /* pre-processador */
{ftp/ftapi017.i} /* Defini‡äes necess rias a integra‡Æo com o EMS 5 */
{cdp/cd1234.i}   /* Defini‡Æo das fun‡äes para arredondamento de acordo com a moeda */
{ftp/ft0708.i9 NEW SHARED}

{ftp/ftapi001.i1}

{include/i_dbinst.i} /* EMS 5*/
{include/i_dbtype.i} 

{include/i-epc200.i "ftapi017"} /*---- Defini‡äes para uso de EPC ----*/

{cdp/cdcfgdis.i}
{cdp/cdcfgcex.i}
{cdp/cdapi013.i60}

&IF "{&bf_Dis_Versao_ems}" >= "2.07" &THEN

/*********************************************************************
***
***    crp/crapi001b.i - Definicao Temp-table para gera‡Æo Dados do 
***    Faturamento no Contas a Receber                         
***
**********************************************************************/

def temp-table tt-doc-i-cr no-undo
    field ep-codigo            LIKE ems2log.empresa.ep-codigo
    field referencia           as   char format "x(10)"
    field cod-estabel          as   char format "x(5)"
    field total-movto          as   dec  format ">>,>>>,>>>,>>9.99" decimals 2
    field dt-movto             as   date format "99/99/9999"
    field ct-credito           as   char format "x(20)"
    field sc-credito           as   char format "x(20)"
    field serie                as   char format "x(5)"
    field conta-credito        as   char format "x(20)"
    field cod-portador-cb      as   int  format ">>>>9"
    field mo-codigo            as   int  format ">9" 
    field char-1               as   char format "x(100)"
    field char-2               as   char format "x(100)"
    field dec-1                as   dec  format "->>>>>>>>>>>9.99999" decimals 8
    field dec-2                as   dec  format "->>>>>>>>>>>9.99999" decimals 8
    field int-1                as   int  format "->>>>>>>>>9"
    field int-2                as   int  format "->>>>>>>>>9"
    field log-1                as   log  format "Sim/Nï¿½o"
    field log-2                as   log  format "Sim/Nï¿½o"
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
    field ep-codigo        LIKE ems2log.empresa.ep-codigo
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
    field conta-credito    as         char format "x(20)"
    field serie            as         char format "x(5)"
    field contabilizou     as         log  format "Sim/Nao"
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
    field ep-codigo        LIKE ems2log.empresa.ep-codigo
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
    field conta-credito    as         char format "x(20)"
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
    field ep-codigo          LIKE ems2log.empresa.ep-codigo
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
    field ep-codigo            LIKE ems2log.empresa.ep-codigo
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
    field ct-transf            as   char format "x(20)"
    field sc-transf            as   char format "x(20)"
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
    field ep-codigo            LIKE ems2log.empresa.ep-codigo
    field cod-estabel          as         char format "x(3)"
    field cod-esp              as         char format "!!"
    field nr-docto             as         char format "x(16)"
    field parcela              as         char format "x(2)"
    field ep-cod-pre           LIKE ems2log.empresa.ep-codigo
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
    field ep-codigo            LIKE ems2log.empresa.ep-codigo
    field cod-estabel          as         char format "x(3)"
    field serie                as         char format "x(5)"
    field cod-esp              as         char format "!!"
    field nr-docto             as         char format "x(16)"
    field parcela              as         char format "x(2)"
    field cod-emitente         as         int  format ">>>>>>>>9"
    field vl-imposto           as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field ct-imposto           as         char format "x(20)"
    field sc-imposto           as         char format "x(20)"
    field conta-imposto        as         char format "x(20)"
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
    field conta-percepcao      as         char format "x(20)"
    field vl-percepcao         as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field ct-retencao          as         char format "x(20)"
    field sc-retencao          as         char format "x(20)"
    field conta-retencao       as         char format "x(20)"
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
    field conta-iva-liberado   as         char format "x(20)"
    field conta-saldo-credito  as         char format "x(20)"
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
    field ep-codigo            LIKE ems2log.empresa.ep-codigo
    field cod-estabel          as         char format "x(3)"
    field serie                as         char format "x(5)"
    field cod-esp              as         char format "!!"
    field nr-docto             as         char format "x(16)"
    field parcela              as         char format "x(2)"
    field cod-emitente         as         int  format ">>>>>>>>9"
    field vl-imposto           as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field ct-imposto           as         char format "x(20)"
    field sc-imposto           as         char format "x(20)"
    field conta-imposto        as         char format "x(20)"
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
    field conta-percepcao      as         char format "x(20)"
    field vl-percepcao         as   dec  format ">>>,>>>,>>>,>>9.99" decimals 2
    field ct-retencao          as         char format "x(20)"
    field sc-retencao          as         char format "x(20)"
    field conta-retencao       as         char format "x(20)"
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
    field conta-iva-liberado   as         char format "x(20)"
    field conta-saldo-credito  as         char format "x(20)"
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
    field ep-codigo            LIKE ems2log.empresa.ep-codigo
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
&ELSE
    {crp/crapi001c.i} /* Temp-Tables API Implanta‡Æo de Documentos CR.*/
&ENDIF

/**** Inserido na cdp/cdapi013.i60 ***************
DEFINE VARIABLE h-ggapi106 AS HANDLE      NO-UNDO.
**************************************************/
DEFINE VARIABLE pl-modulo  AS LOGICAL     NO-UNDO.
DEFINE VARIABLE pl-funcao  AS LOGICAL     NO-UNDO.

def input  param table for tt-doc-i-cr.
def input  param table for tt-lin-i-cr.
def input  param table for tt-ext-lin-i-cr.
def input  param table for tt-rep-i-cr.
def input  param table for tt-lin-ant.
def input  param table for tt-lin-prev.
def input  param table for tt-impto-tit-pend-cr.
def input  param table for tt-impto-tit-pend-cr-1.
def input  param table for tt-lin-ven.
def input  param table for tt-ext-impto-tit-pend-cr.
def input-output param table for tt-retorno-nota-fiscal.


def temp-table tt_xml_input_output no-undo
    field ttv_cod_label                    as character format "x(8)" label "Label" column-label "Label"
    field ttv_des_conteudo                 as character format "x(40)" label "Texto" column-label "Texto"
    field ttv_des_conteudo_aux             as character format "x(40)"
    field ttv_num_seq_1                    as integer format ">>>,>>9".

def temp-table tt_log_erros no-undo
    field ttv_num_seq                      as integer format ">>>,>>9" label "Sequˆncia" column-label "Seq"
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_erro                     as character format "x(50)" label "Inconsistˆncia" column-label "Inconsistˆncia"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda".
DEF STREAM s-log.
DEF VAR    c-dir-log AS CHAR no-undo init "C:~\windows~\temp":U.

/*** Procura o usuario do sistema para atualizar o diretorio de sa¡da. ***/
find usuar_mestre where usuar_mestre.cod_usuario = c-seg-usuario no-lock no-error.
if  avail usuar_mestre then 
    assign c-dir-log = if length(usuar_mestre.nom_subdir_spool) <> 0
                       then caps(replace(usuar_mestre.nom_dir_spool, " ", "~/") + "~/" + replace(usuar_mestre.nom_subdir_spool, " ", "~/"))
                       else caps(replace(usuar_mestre.nom_dir_spool, " ", "~/")).
else 
    assign c-dir-log = "C:~\windows~\temp":U.

/* Engenharia ComissÆo Agentes Externos */
DEF VAR l-spp-comagext AS LOG INIT NO NO-UNDO.

&IF '{&BF_CEX_VERSAO_EMS}' >= '2.062' &THEN
    ASSIGN l-spp-comagext = YES.
&ELSE
   IF CAN-FIND(funcao WHERE funcao.ativo
                      AND   funcao.cd-funcao = 'spp-comagext':U)  /* ativar com o programa cd7070 */
      THEN ASSIGN l-spp-comagext = YES.
&ENDIF

find funcao WHERE funcao.ativo 
            AND   funcao.cd-funcao = "spp-fn-log-ems5":U NO-LOCK NO-ERROR. /* ativar com o programa cd7070 */    
IF AVAIL funcao THEN DO:
    if funcao.char-1 <> "":U
    then assign c-dir-log = funcao.char-1.

    RUN pi-gera-log-ems2.

END.

DEF NEW GLOBAL SHARED VAR lContaFtPorCliente AS LOG NO-UNDO INIT ?.

IF  lContaFtPorCliente = ? THEN
    ASSIGN lContaFtPorCliente = 
              CAN-FIND(funcao 
                        WHERE funcao.cd-funcao = "spp-ContaFtCli":U
                        AND   funcao.ativo NO-LOCK).

def buffer b-sumar-ft for sumar-ft.
def buffer b-fatura   for fat-duplic.
def buffer b-nota-fiscal for nota-fiscal.
DEF BUFFER b-tt-lin-i-cr FOR tt-lin-i-cr.

def temp-table tt-auxiliar no-undo
    field cod-estabel  like nota-fiscal.cod-estabel
    field serie        like nota-fiscal.serie 
    field nr-nota-fis  like nota-fiscal.nr-nota-fis
    field cod-gr-cli   like emitente.cod-gr-cli
    field familia      like item.fm-codigo
    field nat-oper     like it-nota-fisc.nat-oper
    field it-codigo    like it-nota-fisc.it-codigo
    field cod-esp      like fat-duplic.cod-esp
    field cod-depos    like it-nota-fisc.cod-depos
    field tipo         as integer format 9.

def temp-table tt-ped-curva NO-UNDO
    field codigo      AS CHARACTER FORMAT "x(20)"
    field desc-conta  AS CHARACTER FORMAT "x(32)"
    FIELD ccusto      AS CHARACTER FORMAT "x(20)"
    FIELD desc-centro AS CHARACTER FORMAT "x(32)"
    field it-codigo   as char format 'x(16)' label "item"
    field serie       like it-nota-fisc.serie
    field nr-nota-fis like it-nota-fisc.nr-nota-fis
    field cont        as int
    field dec-1       as dec format '>>>>>>>>>>>9.99999999'
    field vl-credito  as dec format '>>>>>>>>>>>9.99999999' label 'Cr‚dito'
    field vl-debito   as dec format '>>>>>>>>>>>9.99999999' label 'D‚bito'
    &IF "{&bf_dis_versao_ems}" >= "2.062" &THEN
    FIELD cod-unid-negoc LIKE sumar-ft.cod-unid-negoc
    &ENDIF.


def temp-table tt-conta-pend no-undo
    field nr-seq      as int format 999
    field ct-codigo AS CHAR format 'x(20)'
    field sc-codigo AS CHAR format 'x(20)'
    field valor     like sumar-ft.vl-contab
    index ch-codigo is primary
        nr-seq.

def temp-table tt-conta-pend-parcela no-undo
    field nr-seq         as int format 999
    field ct-codigo      AS CHAR format 'x(20)'
    field sc-codigo      AS CHAR format 'x(20)'
    field parcela        like fat-duplic.parcela
    field valor          like sumar-ft.vl-contab
    field cod-unid-negoc as character format "x(3)".

def temp-table tt_log_erros_comis_repres no-undo
    field ttv_num_seq                      as integer format ">>>,>>9" label "Sequencia" column-label "Seq"
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "Numero" column-label "Numero"
    field ttv_des_erro                     as character format "x(50)" label "Inconsistencia" column-label "Inconsistencia"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda".

DEF TEMP-TABLE tt-abat-prev-rem NO-UNDO
    FIELD cod-estabel    LIKE remito.cod-estabel
    FIELD serie          LIKE remito.serie
    FIELD nr-remito      LIKE remito.nr-remito
    FIELD cod-cond-pagto LIKE ped-venda.cod-cond-pag
    FIELD vl-prev        LIKE ped-item.vl-preuni.

def    temp-table tt_integr_acr_aprop_ctbl_pend_au no-undo 
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9" 
    field tta_cod_plano_cta_ctbl           as character format "x(20)" label "Plano Contas" column-label "Plano Contas" 
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contabil" column-label "Conta Contabil" 
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern" 
    field tta_cod_sub_cta_ctbl_ext         as character format "x(20)" label "Sub Conta Externa" column-label "Sub Conta Externa" 
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Negocio" column-label "Un Neg" 
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Negocio Externa" column-label "Unid Negocio Externa" 
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo" 
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo" 
    field tta_cod_ccusto_ext               as character format "x(8)" label "Centro Custo Externo" column-label "CCusto Externo" 
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ" 
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo" 
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl" 
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federacao" column-label "UF" 
    field tta_log_impto_val_agreg          as logical format "Sim/Nao" initial no label "Impto Val Agreg" column-label "Imp Vl Agr" 
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto" 
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto" 
    field tta_cod_pais                     as character format "x(3)" label "Pais" column-label "Pais" 
    field tta_cod_pais_ext                 as character format "x(20)" label "Pais Externo" column-label "Pais Externo" 
    index tt_id                            is primary unique 
          ttv_rec_item_lote_impl_tit_acr   ascending 
          tta_cod_plano_cta_ctbl           ascending 
          tta_cod_cta_ctbl                 ascending 
          tta_cod_cta_ctbl_ext             ascending 
          tta_cod_sub_cta_ctbl_ext         ascending 
          tta_cod_unid_negoc               ascending 
          tta_cod_unid_negoc_ext           ascending 
          tta_cod_plano_ccusto             ascending 
          tta_cod_ccusto                   ascending 
          tta_cod_ccusto_ext               ascending 
          tta_cod_tip_fluxo_financ         ascending 
          tta_cod_fluxo_financ_ext         ascending 
          tta_log_impto_val_agreg          ascending. 

DEF TEMP-TABLE tt_integr_acr_aprop_relacto_au NO-UNDO LIKE tt_integr_acr_aprop_relacto.

def temp-table tt_integr_acr_lote_impl_aux no-undo 
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa" 
    field ttv_cod_empresa_ext              as character format "x(3)" label "Codigo Empresa Ext" column-label "Cod Emp Ext" 
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab" 
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext" 
    field tta_cod_refer                    as character format "x(10)" label "Referencia" column-label "Referencia" 
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda" 
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa" 
    field tta_cod_espec_docto              as character format "x(3)" label "Especie Documento" column-label "Especie" 
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transacao" column-label "Dat Transac" 
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo Especie" column-label "Tipo Especie" 
    field tta_ind_orig_tit_acr             as character format "X(8)" initial "ACREMS50":U label "Origem Tit Cta Rec" column-label "Origem Tit Cta Rec" 
    field tta_val_tot_lote_impl_tit_acr    as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Movimento" column-label "Total Movimento" 
    field tta_val_tot_lote_infor_tit_acr   as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Informado" column-label "Total Informado" 
    field tta_ind_tip_cobr_acr             as character format "X(10)" initial "Normal" label "Tipo Cobranca" column-label "Tipo Cobranca" 
    field ttv_log_lote_impl_ok             as logical format "Sim/Nao" initial no 
    field tta_log_liquidac_autom           as logical format "Sim/Nao" initial no label "Liquidac Automatica" column-label "Liquidac Automatica" 
    index tt_id                            is primary unique 
          tta_cod_estab                    ascending 
          tta_cod_estab_ext                ascending 
          tta_cod_refer                    ascending.

DEFINE TEMP-TABLE tt-unid-aux NO-UNDO
    FIELD cod_unid_negoc AS CHARACTER
    FIELD valor          AS DECIMAL
    INDEX ch-unid IS PRIMARY UNIQUE
        cod_unid_negoc.

def NEW SHARED workfile w-sumar-rej
    field registro as rowid.

def new global shared var v_cod_dwb_user as character format "x(21)" label "Usuario" 
    column-label "Usuario" no-undo. 
def new global shared var v_cod_matriz_trad_org_ext as character format "x(8)" label "Matriz UO" 
    column-label "Matriz UO" no-undo. 
def new global shared var v_hdl_api_integr_acr as handle format ">>>>>>9":U no-undo.

def new shared var l-retorno-epc as logical             no-undo.

def var de-vl-fasb   like sumar-ft.vl-contab            no-undo.
def var l-contabil-dup as logical                       no-undo.
def var l-indicador    as logical                       no-undo. 
def var h-cd9500       as handle                        no-undo.
def var i-empresa    like param-global.empresa-prin     no-undo.
def var i-fatura     like nota-fiscal.nr-nota-fis       no-undo.
def var de-fator       as decimal                       no-undo.
def var de-tot-valor like it-nota-fisc.vl-merc-liq      no-undo.
def var de-tot-desp  like it-nota-fisc.vl-despes-it     no-undo.
def var de-tot-fre   like it-nota-fisc.vl-frete-it      no-undo.
def var r-conta-ft     as rowid                         no-undo. 
def var de-valor     like sumar-ft.vl-contab            no-undo.
def var de-frete-it  like it-nota-fisc.vl-frete-it      no-undo.
def var de-desp-it   like it-nota-fisc.vl-despes-it     no-undo.
def var de-vl-contab   as decimal format "->>,>>>,>>>,>>9.9999" no-undo.
def var i-valor-selec  as decimal no-undo.
def var c-desc-conta   AS CHAR format 'x(32)' no-undo.    
def var c-desc-ccusto  AS CHAR format 'x(32)' no-undo.    
def var r-sumar-ft      as rowid                                    no-undo.
def var de-vl-alfa      as decimal format "->>,>>>,>>>,>>9.9999"    no-undo.
def var de-vl-cmi       like de-vl-alfa                             no-undo.
def var de-vl-alfa1     like de-vl-alfa                             no-undo.
def var de-vl-cmi-acum  like sumar-ft.vl-contab                     no-undo.
def var de-vl-anbid     like sumar-ft.vl-contab                     no-undo.
def var da-ult-datemi   like sumar-ft.dt-movto                      no-undo.
def var c-parametro    as char format "x(20)" no-undo.
def var c-cc-parametro as char format "x(20)" no-undo.
def var v_log_utiliza_rateio_un as logical no-undo.    
def var h-acomp           as handle   no-undo.
def var i-msg             as int      no-undo.
DEF VAR i-time            AS INT      NO-UNDO.
def var c-acomp-ant       as char     no-undo.
def var c-acomp-prev      as char     no-undo.
def var c-acomp-rep       as char     no-undo.
def var c-acomp-imp       as char     no-undo.
def var c-acomp           as char     no-undo.
DEF VAR p-ct-conta        AS INT      NO-UNDO.
DEF VAR p-sc-conta        AS INT      NO-UNDO.
DEF VAR c-tipo-comis      as CHAR format "x(14)" NO-UNDO.
def var de-tot-conta-pend like sumar-ft.vl-contab no-undo.
DEF VAR de-tot-imposto-conta-pend LIKE sumar-ft.vl-contab NO-UNDO.
DEF VAR i-num-tot-parcelas AS INT FORMAT 999 NO-UNDO.
def var de-perc           as dec format ">>9.99"              no-undo.
def var i-tip-cob-desp    like emitente.tip-cob-desp no-undo.
DEF VAR l-atualiz         AS LOG INIT NO.
DEF VAR i-par             AS INT FORMAT '99' NO-UNDO.
def var c-campos-tabela-par as CHAR no-undo.
def var de-vl-acum      like fat-duplic.vl-parcela          no-undo.
def var v_cod_cta_ctbl_ext     as character     format "x(20)"     no-undo. 
DEF VAR de-acum-prev LIKE tt_integr_acr_abat_prev.tta_val_abtdo_prev_tit_abat NO-UNDO.
DEF VAR c-nr-docto LIKE tt-lin-i-cr.nr-docto NO-UNDO.
DEF VAR c-tta_ind_tip_comis_ext like tt_integr_acr_repres_comis_2.tta_ind_tip_comis_ext no-undo.
DEF VAR de-valor-contabil LIKE sumar-ft.vl-contab NO-UNDO.
def var l-contab-lote  as logical NO-UNDO INITIAL NO.

/*Inicio Unifica‡Æo de Conceitos CONTA CONTABIL 2011*/
DEF VAR h_api_cta          AS HANDLE NO-UNDO.
DEF VAR v_des_cta          AS CHAR   NO-UNDO.
DEF VAR v_num_tip_cta      AS INT    NO-UNDO.
DEF VAR v_num_sit_cta      AS INT    NO-UNDO.

DEFINE VARIABLE h_api_cta_ctbl     AS HANDLE      NO-UNDO.
DEFINE VARIABLE h_api_ccusto       AS HANDLE      NO-UNDO.
DEFINE VARIABLE v_cod_cta_ctbl     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_des_cta_ctbl     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_ind_finalid_cta  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_des_ccusto       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_num_tip_cta_ctbl AS INTEGER     NO-UNDO.
DEFINE VARIABLE v_num_sit_cta_ctbl AS INTEGER     NO-UNDO.


DEFINE VARIABLE c-conta-param AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-ccusto-param AS CHARACTER   NO-UNDO.

def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro  as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_msg_ajuda as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro  as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia".

/*Fim Unifica‡Æo de Conceitos CONTA CONTABIL 2011*/


DEFINE VARIABLE de-cotacao            AS DECIMAL INIT 0 NO-UNDO.
DEFINE VARIABLE de-vl-aux             AS DECIMAL INIT 0 NO-UNDO.
DEFINE VARIABLE de-tot-acum           AS DECIMAL INIT 0 NO-UNDO.
DEFINE VARIABLE de-tot-parcela-forte  AS DECIMAL INIT 0 NO-UNDO.
DEFINE VARIABLE de-tot-parcela-padrao AS DECIMAL INIT 0 NO-UNDO.
DEFINE VARIABLE de-tot-acum-lin-i-cr  AS DECIMAL INIT 0 NO-UNDO.
DEFINE VARIABLE de-tot-vl-tot-nota    AS DECIMAL INIT 0 NO-UNDO.
DEFINE VARIABLE de-soma               AS DECIMAL         NO-UNDO.
DEFINE VARIABLE de-maior              AS DECIMAL         NO-UNDO.
DEFINE VARIABLE r-maior               AS RECID           NO-UNDO.
DEFINE VARIABLE l-integra             AS LOGICAL INIT NO NO-UNDO.
DEFINE VARIABLE h-arg0037             AS HANDLE          NO-UNDO.

/* Temp-table de erros do ARG0037 */
DEFINE TEMP-TABLE tt-erro-arg0037 NO-UNDO
    FIELD cod-erro  AS INTEGER
    FIELD des-erro  AS CHARACTER
    FIELD cod-refer AS CHARACTER.

def var de-tot-nf-mo-est       like it-nota-fisc.vl-merc-liq-me no-undo.
def var de-vl-fatura-me        like fat-duplic.vl-parcela       no-undo.
DEF VAR de-tot-vl-tot-merc     LIKE fat-duplic.vl-parcela       NO-UNDO.
DEF VAR de-vl-base-calc-ret-me LIKE fat-duplic.vl-parcela       NO-UNDO.
DEF VAR DE-VL-APROP-ME         AS DECIMAL FORMAT ">>>>,>>9.9999999999" DECIMALS 10 NO-UNDO.

DEF VAR vl-tot-lote-aprop  AS DEC NO-UNDO.
DEF VAR vl-tot-lote-acum   AS DEC NO-UNDO.
DEF VAR vl-tot-imp-relacto AS DEC NO-UNDO.
DEF VAR de-vl-tot-agregados AS DEC NO-UNDO.
DEF VAR de-vl-tot-agregados-prop AS DEC NO-UNDO.
DEF VAR de-vl-aprop         AS DEC NO-UNDO.

{dibo/bodi317.i7} /* l-america-latina */ 

/* IVA Taxado - Imposto Paraguai para Agrotec */
IF can-find(funcao where funcao.cd-funcao = "spp-retira-iva-ems5"
                     and funcao.ativo) THEN ASSIGN l-america-latina = NO.
&IF "{&bf_dis_versao_ems}" >= "2.062" &THEN
{cdp/cd9590.i} /* Variaveis de utiliza‡Æo de unidade neg¢cio */

{ftp/ft0717.i3} /* pi-rateio-despesas-unidade-negocio */
&ENDIF

find first param-global no-lock no-error.
assign i-empresa = param-global.empresa-prin.    

find first para-fat no-lock no-error.
find first param-cr no-lock no-error.

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Implanta‡Æo_de_Documentos *}

run pi-inicializar in h-acomp (input  Return-value ).
run pi-desabilita-cancela in h-acomp.

{utp/ut-liter.i Atualizando_Item_Lote_Implanta‡Æo * R}
assign c-acomp = trim(return-value).
{utp/ut-liter.i Atualizando_Representante: * R}
assign c-acomp-rep = trim(return-value).
{utp/ut-liter.i Atualizando_Antecipa‡Æo: * R}
assign c-acomp-ant = trim(return-value).
{utp/ut-liter.i Atualizando_PrevisÆo: * R}
assign c-acomp-prev = trim(return-value).
{utp/ut-liter.i Atualizando_Imposto: * R}
assign c-acomp-imp = trim(return-value).

if not valid-handle(h-cd9500) then
    run cdp/cd9500.p persistent set h-cd9500.

RUN prgint/ufn/ufn908za.py (input "1":u,
                            INPUT "15":U,
                            OUTPUT v_cod_matriz_trad_org_ext).

ASSIGN l-integra = NO.

DEFINE VARIABLE c-acomp-doc AS CHARACTER  NO-UNDO.
{utp/ut-liter.i Atualizando_Lote * R}
ASSIGN c-acomp-doc = trim(RETURN-VALUE).

bloco_principal:
for each tt-doc-i-cr: 

    EMPTY TEMP-TABLE tt-conta-pend-parcela.
    &if defined (bf_dis_consiste_conta) &then
        find estabelec where
             estabelec.cod-estabel = tt-doc-i-cr.cod-estabel no-lock no-error.
        run cdp/cd9970.p (input rowid(estabelec),
                          output i-empresa).
    &ENDIF

    if  time - i-time > 0 then do:
        assign i-time = time.
        run pi-acompanhar in h-acomp (c-acomp-doc). 
    END.

    create tt_integr_acr_lote_impl. 
    assign tt_integr_acr_lote_impl.ttv_cod_empresa_ext            = string(tt-doc-i-cr.ep-codigo)
           tt_integr_acr_lote_impl.tta_cod_estab                  = ""
           tt_integr_acr_lote_impl.tta_cod_estab_ext              = tt-doc-i-cr.cod-estabel 
           tt_integr_acr_lote_impl.tta_cod_refer                  = tt-doc-i-cr.referencia 
           tt_integr_acr_lote_impl.tta_dat_transacao              = tt-doc-i-cr.dt-movto
           tt_integr_acr_lote_impl.tta_val_tot_lote_impl_tit_acr  = tt-doc-i-cr.total-movto 
           tt_integr_acr_lote_impl.tta_val_tot_lote_infor_tit_acr = tt-doc-i-cr.total-movto
           tt_integr_acr_lote_impl.tta_ind_orig_tit_acr           = "2" /* FATEMS20 */. 

    FIND FIRST tt-lin-i-cr where tt-lin-i-cr.referencia = tt-doc-i-cr.referencia NO-ERROR.

    for first nota-fiscal fields(char-2 cod-emitente nat-operacao cod-estabel serie nr-nota-fis nr-pedcli
                                 nome-ab-cli ind-tip-nota nro-nota-orig serie-orig ind-sit-nota
                                 nr-fatura vl-tot-nota vl-tot-ipi nr-proc-exp cod-canal-venda
                                 dt-emis-nota emite-duplic vl-taxa-exp vl-frete vl-seguro vl-embalagem vl-mercad
                                 mo-codigo ind-sit-nota num-process-negoc num-cx-financ cod-safra)
        where nota-fiscal.cod-estabel = tt-lin-i-cr.cod-estabel
          and nota-fiscal.serie       = tt-lin-i-cr.serie
          and nota-fiscal.nr-nota-fis = tt-lin-i-cr.nr-docto-vincul no-lock:
    end.
    find emitente of nota-fiscal no-lock no-error.        
    FIND natur-oper WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao NO-LOCK NO-ERROR.

    /***************
    SELECT COUNT(*) INTO i-num-tot-parcelas
        FROM fat-duplic
        WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          AND fat-duplic.serie       = nota-fiscal.serie
          AND fat-duplic.nr-fatura   = nota-fiscal.nr-nota-fis.
    ***************/

    FOR EACH fat-duplic FIELDS(cod-estabel)
        WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel
        AND   fat-duplic.serie       = nota-fiscal.serie
        AND   fat-duplic.nr-fatura   = nota-fiscal.nr-nota-fis NO-LOCK:
        ASSIGN i-num-tot-parcelas = i-num-tot-parcelas + 1.
    END.

    if i-pais-impto-usuario <> 1 and para-fat.ind-transitoria then 
        RUN pi-busca-conta-receita.        

    assign de-tot-acum-lin-i-cr = 0.

    for each tt-lin-i-cr where tt-lin-i-cr.referencia = tt-doc-i-cr.referencia:

        ASSIGN tt_integr_acr_lote_impl.tta_cod_espec_docto = tt-lin-i-cr.cod-esp.


        if nota-fiscal.nr-pedcli <> "":U then do:
            find ped-venda 
                where ped-venda.nome-abrev = nota-fiscal.nome-ab-cli
                  and ped-venda.nr-pedcli  = nota-fiscal.nr-pedcli no-lock no-error.
            if avail ped-venda then
                assign i-tip-cob-desp = ped-venda.tip-cob-desp.
            else 
                assign i-tip-cob-desp = emitente.tip-cob-desp.
        end.
        else assign i-tip-cob-desp = emitente.tip-cob-desp.

        /* aqui o tratamento da especie como antecipacao - foi colocado no ftapi001 e ft0603b */

        if  time - i-time > 0 then do:
            assign i-time = time.
            run pi-acompanhar in h-acomp (input c-acomp + " " + tt-lin-i-cr.nr-docto + "/" + tt-lin-i-cr.parcela).    
        END.

        create tt_integr_acr_item_lote_impl_8.
        assign tt_integr_acr_item_lote_impl_8.ttv_rec_lote_impl_tit_acr      = recid(tt_integr_acr_lote_impl)
               tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr = recid(tt_integr_acr_item_lote_impl_8)
               tt_integr_acr_item_lote_impl_8.tta_cdn_cliente                = tt-lin-i-cr.cod-emitente
               tt_integr_acr_item_lote_impl_8.tta_num_seq_refer              = tt-lin-i-cr.sequencia
               tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto            = tt-lin-i-cr.cod-esp
               tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto              = tt-lin-i-cr.serie
               tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr                = tt-lin-i-cr.nr-docto
               tt_integr_acr_item_lote_impl_8.tta_cod_parcela                = tt-lin-i-cr.parcela
               tt_integr_acr_item_lote_impl_8.tta_cod_indic_econ             = string(tt-lin-i-cr.mo-codigo)
               tt_integr_acr_item_lote_impl_8.tta_cod_finalid_econ_ext       = string(tt-lin-i-cr.mo-codigo)
               tt_integr_acr_item_lote_impl_8.tta_ind_sit_tit_acr            = string(tt-lin-i-cr.situacao)
               tt_integr_acr_item_lote_impl_8.tta_cdn_repres                 = tt-lin-i-cr.cod-rep
               tt_integr_acr_item_lote_impl_8.tta_dat_vencto_tit_acr         = tt-lin-i-cr.dt-vencimen
               tt_integr_acr_item_lote_impl_8.tta_dat_prev_liquidac          = tt-lin-i-cr.dt-vencimen
               tt_integr_acr_item_lote_impl_8.tta_dat_desconto               = tt-lin-i-cr.dt-desconto
               tt_integr_acr_item_lote_impl_8.tta_dat_emis_docto             = tt-lin-i-cr.dt-emissao
               tt_integr_acr_item_lote_impl_8.tta_val_perc_juros_dia_atraso  = ?
               tt_integr_acr_item_lote_impl_8.tta_des_text_histor            = "Integra‡Æo Faturamento EMS 2 com Contas a Receber EMS 5.0" 
               tt_integr_acr_item_lote_impl_8.tta_cod_cond_pagto             = string(tt-lin-i-cr.cod-cond-pag)
               tt_integr_acr_item_lote_impl_8.tta_cod_refer                  = tt-lin-i-cr.referencia
               tt_integr_acr_item_lote_impl_8.tta_val_cotac_indic_econ       = 1
               tt_integr_acr_item_lote_impl_8.tta_ind_sit_bcia_tit_acr       = "1"
               tt_integr_acr_item_lote_impl_8.tta_ind_ender_cobr             = "1"
               tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr_bco            = tt-lin-i-cr.num-titulo-banco
               tt_integr_acr_item_lote_impl_8.ttv_val_cr_pis                 = tt-lin-i-cr.vl-pis
               tt_integr_acr_item_lote_impl_8.ttv_val_cr_cofins              = tt-lin-i-cr.vl-cofins
               tt_integr_acr_item_lote_impl_8.ttv_val_cr_csll                = tt-lin-i-cr.vl-csll
               tt_integr_acr_item_lote_impl_8.tta_val_base_calc_impto        = IF  NOT l-america-latina /* os valores estao gravados pelo liquido + despesas */
                                                                               THEN tt-lin-i-cr.vl-base-calc-ret
                                                                               ELSE 0
               tt_integr_acr_item_lote_impl_8.tta_log_retenc_impto_impl      = tt-lin-i-cr.l-ret-impto
               tt_integr_acr_item_lote_impl_8.ttv_cod_nota_fisc_faturam      = nota-fiscal.nr-nota-fis
               de-vl-base-calc-ret-me                                        = tt-lin-i-cr.vl-base-calc-ret
               tt_integr_acr_item_lote_impl_8.tta_val_abat_tit_acr           = tt-lin-i-cr.vl-abatimento
               tt_integr_acr_item_lote_impl_8.tta_dat_abat_tit_acr           = if tt-lin-i-cr.vl-abatimento > 0 then tt-lin-i-cr.dt-vencimen else ?.
        
       /*Projeto 90 - GestÆo Caixas HIS x EMS*/
        if nota-fiscal.num-cx-financ > 0 and nota-fiscal.num-process-negoc > 0 and
		   not can-find(first tt_integr_acr_lote_impl_cx no-lock
					    where tt_integr_acr_lote_impl_cx.ttv_rec_lote_impl_tit_acr = RECID(tt_integr_acr_lote_impl)) then do:
			CREATE tt_integr_acr_lote_impl_cx.
			ASSIGN tt_integr_acr_lote_impl_cx.ttv_rec_lote_impl_tit_acr = RECID(tt_integr_acr_lote_impl)
				   tt_integr_acr_lote_impl_cx.tta_num_cx_financ         = nota-fiscal.num-cx-financ
				   tt_integr_acr_lote_impl_cx.tta_num_process_negoc     = nota-fiscal.num-process-negoc.
		end.
        /*Fim Projeto 90*/
       
        if param-global.log-modul-gg    = yes 
       and trim(nota-fiscal.cod-safra) <> "00000000" then do:

        create tt_params_generic_api.
        assign tt_params_generic_api.ttv_rec_id     = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
               tt_params_generic_api.ttv_cod_tabela = "tt_integr_acr_item_lote_impl"
               tt_params_generic_api.ttv_cod_campo  = "Safra"
               tt_params_generic_api.ttv_cod_valor  = &IF '{&BF_DIS_VERSAO_EMS}' >= '2.062' &THEN
                                                         &IF '{&BF_DIS_VERSAO_EMS}' >= '2.08' &THEN
                                                             nota-fiscal.cod-safra.
                                                         &ELSE
                                                             SUBSTRING(nota-fiscal.char-2,176,8).
                                                         &ENDIF
                                                      &ENDIF
        END.
                                                     
         if  c-nom-prog-dpc-mg97  <> ""
            or  c-nom-prog-appc-mg97 <> "" 
            or  c-nom-prog-upc-mg97  <> ""  then do:
                for each tt-epc where tt-epc.cod-event = "Busca_Ender_Cobranca":U:
                    delete tt-epc.
                end.

                create tt-epc.
                assign tt-epc.cod-event     = "Busca_Ender_Cobranca":U
                       tt-epc.cod-parameter = "nota-fiscal-rowid":U
                       tt-epc.val-parameter = string(rowid(nota-fiscal)).                                                                      
                
                
                {include/i-epc201.i "Busca_Ender_Cobranca"}                           
                
                FIND FIRST tt-epc NO-LOCK WHERE
                           tt-epc.cod-event     = "Busca_Ender_Cobranca":U AND
                           tt-epc.cod-parameter = "nota-fiscal-contato":U  NO-ERROR.
                IF AVAIL tt-epc THEN DO:

                  ASSIGN tt_integr_acr_item_lote_impl_8.tta_nom_abrev_contat = tt-epc.val-parameter.
                  IF tt-epc.val-parameter <> "" THEN
                      ASSIGN tt_integr_acr_item_lote_impl_8.tta_ind_ender_cobr = "3":U.
                END.

        END.

        /**** inicio - Ivomar - Vicunha ******/
        if  string(tt-lin-i-cr.mo-codigo) <> "0":U then do:
            assign de-tot-vl-tot-nota = 0
                   de-tot-nf-mo-est   = 0
                   de-tot-vl-tot-merc = 0.
            if can-find(funcao   /* Fechamento de Duplicatas por Pedido */
                  where funcao.cd-funcao = "spp-FechaDuplic"
                    and funcao.ativo       = yes) then do:
                for each b-nota-fiscal 
                   where b-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel
                     and b-nota-fiscal.serie       = nota-fiscal.serie
                     and b-nota-fiscal.nr-fatura   = nota-fiscal.nr-fatura no-lock:
                    assign de-tot-vl-tot-nota = de-tot-vl-tot-nota + b-nota-fiscal.vl-tot-nota
                           de-tot-vl-tot-merc = de-tot-vl-tot-merc + b-nota-fiscal.vl-mercad 
                                                                   + b-nota-fiscal.vl-frete
                                                                   + b-nota-fiscal.vl-seguro
                                                                   + b-nota-fiscal.vl-embalagem.
                          
                    for each it-nota-fisc 
                        where it-nota-fisc.cod-estabel = b-nota-fiscal.cod-estabel and
                              it-nota-fisc.serie       = b-nota-fiscal.serie       and
                              it-nota-fisc.nr-nota-fis = b-nota-fiscal.nr-nota-fis no-lock:
                        assign de-tot-nf-mo-est = de-tot-nf-mo-est + 
                                                  IF   it-nota-fisc.vl-mercliq-e[1] <> 0  
                                                  THEN it-nota-fisc.vl-mercliq-e[1] + it-nota-fisc.vl-despesit-e[1]
                                                  ELSE it-nota-fisc.vl-merc-liq-me  + it-nota-fisc.vl-despes-it-me.

                    end.
                end.
            end.
            else
            do:
                assign de-tot-vl-tot-nota = nota-fiscal.vl-tot-nota
                       de-tot-vl-tot-merc = de-tot-vl-tot-merc + nota-fiscal.vl-mercad     
                                                               + nota-fiscal.vl-frete      
                                                               + nota-fiscal.vl-seguro     
                                                               + nota-fiscal.vl-embalagem. 
                      
                for each it-nota-fisc 
                    where it-nota-fisc.cod-estabel = nota-fiscal.cod-estabel and
                          it-nota-fisc.serie       = nota-fiscal.serie       and
                          it-nota-fisc.nr-nota-fis = nota-fiscal.nr-nota-fis no-lock:      
                    assign de-tot-nf-mo-est = de-tot-nf-mo-est + 
                                              IF   it-nota-fisc.vl-mercliq-e[1] <> 0  
                                              THEN it-nota-fisc.vl-mercliq-e[1] + it-nota-fisc.vl-despesit-e[1]
                                              ELSE it-nota-fisc.vl-merc-liq-me  + it-nota-fisc.vl-despes-it-me.
                end.
            end.

            IF c-nom-prog-dpc-mg97  <> ""
            OR c-nom-prog-appc-mg97 <> "" 
            OR c-nom-prog-upc-mg97  <> "" THEN DO:
            
                FOR EACH tt-epc
                   WHERE tt-epc.cod-event = "ValorTotalMoedaEstrangeira" :
                    DELETE tt-epc.
                END.
                {include/i-epc200.i2 &CodEvent       = '"ValorTotalMoedaEstrangeira"'
                                     &CodParameter   = '"nota-fiscal-rowid"'
                                     &ValueParameter = STRING(ROWID(nota-fiscal)) }

                {include/i-epc200.i2 &CodEvent       = '"ValorTotalMoedaEstrangeira"'
                                     &CodParameter   = '"MoedaEstrangeira"'
                                     &ValueParameter = STRING(de-tot-nf-mo-est) }
        
                {include/i-epc201.i "ValorTotalMoedaEstrangeira"}
                /*--- Verifica ocorrˆncia de retornos ---*/
                FIND FIRST tt-epc
                     WHERE tt-epc.cod-event     = "ValorTotalMoedaEstrangeira":U
                       AND tt-epc.cod-parameter = "RETORNO" NO-ERROR.

                

                IF AVAIL tt-epc THEN
                    ASSIGN de-tot-nf-mo-est = DEC(tt-epc.val-parameter).
            END.

            find first fat-duplic
                where fat-duplic.cod-estabel   = nota-fiscal.cod-estabel
                and   fat-duplic.serie         = nota-fiscal.serie
                and   fat-duplic.nr-fatura     = nota-fiscal.nr-fatura
                and   fat-duplic.flag-atualiz  = no
                and   fat-duplic.parcela       = tt-lin-i-cr.parcela EXCLUSIVE-LOCK NO-ERROR.

            assign de-vl-fatura-me            = de-tot-nf-mo-est * fat-duplic.vl-parcela / de-tot-vl-tot-nota
                   de-vl-aprop-me             = de-tot-nf-mo-est * fat-duplic.val-base-contrib-social / de-tot-vl-tot-merc
                   tt-lin-i-cr.vl-bruto-me    = de-vl-fatura-me
                   fat-duplic.vl-parcela-me   = de-vl-fatura-me
                   tt-lin-i-cr.vl-desconto-me = de-tot-nf-mo-est * fat-duplic.vl-desconto / de-tot-vl-tot-nota 
                   fat-duplic.vl-desconto-me  = tt-lin-i-cr.vl-desconto-me
                   tt-lin-i-cr.vl-liquido-me  = de-tot-nf-mo-est * fat-duplic.vl-comis / de-tot-vl-tot-nota
                   fat-duplic.vl-comis-me     = tt-lin-i-cr.vl-liquido-me.

                assign tt_integr_acr_item_lote_impl_8.tta_val_cotac_indic_econ = IF  l-america-latina
                                                                                 THEN 1 / ( fat-duplic.val-base-contrib-social / de-vl-aprop-me)
                                                                                 ELSE 1 / ( fat-duplic.vl-parcela / tt-lin-i-cr.vl-bruto-me)
                       de-vl-base-calc-ret-me                                  = fat-duplic.val-base-contrib-social / tt_integr_acr_item_lote_impl_8.tta_val_cotac_indic_econ.

        END.

        IF  nota-fiscal.ind-tip-nota = 10 
        AND nota-fiscal.nro-nota-orig = "" THEN
            ASSIGN tt_integr_acr_item_lote_impl_8.tta_cod_portad_ext             = ""
                   tt_integr_acr_item_lote_impl_8.tta_cod_modalid_ext            = "".
        ELSE 
            ASSIGN tt_integr_acr_item_lote_impl_8.tta_cod_portad_ext             = string(tt-lin-i-cr.cod-portador)
                   tt_integr_acr_item_lote_impl_8.tta_cod_modalid_ext            = string(tt-lin-i-cr.modalidade).

       /* ----------------------------------------------------------------------------------------
           Altera‡äes segundo engenharia :
           ~\~\itaguacu~\pastahst~\EMS20~\Logistics Solutions~\Releases~\EMS - 2.05 - Projeto 8969~\
           Engenharias de OS~\Eng_Plano_Alfa_Integracoes_Cambio_Vendor.doc

           Prop¢sito: Corre‡Æo da funcionalidade VENDOR integrada ao aplicativo financeiro.
           Notas: Altera‡äes repassadas ‚ rel 2.04b do EMS.
           ---------------------------------------------------------------------------------------- */       

        IF CAN-FIND (FIRST funcao WHERE
                           funcao.cd-funcao = "adm-vdr-ems-5.00"  AND
                           funcao.ativo) THEN DO:
           FIND tt-lin-ven WHERE 
                tt-lin-ven.ep-codigo   = tt-lin-i-cr.ep-codigo   AND
                tt-lin-ven.cod-estabel = tt-lin-i-cr.cod-estabel AND
                tt-lin-ven.cod-esp     = tt-lin-i-cr.cod-esp     AND
                tt-lin-ven.serie       = tt-lin-i-cr.serie       AND
                tt-lin-ven.nr-docto    = tt-lin-i-cr.nr-docto    AND
                tt-lin-ven.parcela     = tt-lin-i-cr.parcela
                NO-LOCK NO-ERROR.
           IF AVAIL tt-lin-ven THEN DO:
              ASSIGN tt_integr_acr_item_lote_impl_8.ttv_cod_cond_pagto_vendor       = string(tt-lin-ven.cod-cond-cli)
                     tt_integr_acr_item_lote_impl_8.ttv_val_cotac_tax_vendor_clien  = tt-lin-ven.taxa-cli
                     tt_integr_acr_item_lote_impl_8.ttv_dat_base_fechto_vendor      = tt-lin-ven.data-base
                     tt_integr_acr_item_lote_impl_8.ttv_qti_dias_carenc_fechto      = tt-lin-ven.dias-base
                     tt_integr_acr_item_lote_impl_8.ttv_log_assume_tax_bco          = IF tt-lin-ven.taxa-cli = ? THEN YES 
                                                                                      ELSE NO
                     tt_integr_acr_item_lote_impl_8.ttv_log_vendor = YES.
           END.
        END.

      
        /* Integra‡Æo CƒMBIO */
        /*IF param-global.modulo-mec THEN*/
        ASSIGN tt_integr_acr_item_lote_impl_8.tta_cod_proces_export = tt-lin-i-cr.nr-proc-exp.
        
        CASE nota-fiscal.ind-tip-nota:
            WHEN 10 THEN DO:
                IF nota-fiscal.nro-nota-orig <> "":U THEN
                    ASSIGN tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "10". /* Nota de Cr‚dito */
                ELSE
                    ASSIGN tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "3". /* Antecipa‡Æo */
            END.
            WHEN 9 THEN DO:
                IF nota-fiscal.nro-nota-orig <> "":U THEN   
                    ASSIGN tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "11". /* Nota de D‚bito */
                ELSE
                    ASSIGN tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "2". /* Normal */            
            END.
            OTHERWISE
                ASSIGN tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "2". /* Normal */
        END CASE.

        if  string(tt-lin-i-cr.mo-codigo) <> "0" 
        then do: 
            assign tt_integr_acr_item_lote_impl_8.tta_val_tit_acr     = tt-lin-i-cr.vl-bruto-me 
                   tt_integr_acr_item_lote_impl_8.tta_val_desconto    = tt-lin-i-cr.vl-desconto-me 
                   tt_integr_acr_item_lote_impl_8.tta_val_perc_desc   = (tt-lin-i-cr.vl-desconto-me * 100) / tt-lin-i-cr.vl-bruto-me 
                   tt_integr_acr_item_lote_impl_8.tta_val_liq_tit_acr = tt-lin-i-cr.vl-liquido-me
                   . 
        end.
        else do: 
            assign tt_integr_acr_item_lote_impl_8.tta_val_tit_acr     = tt-lin-i-cr.vl-bruto 
                   tt_integr_acr_item_lote_impl_8.tta_val_desconto    = tt-lin-i-cr.vl-desconto 
                   tt_integr_acr_item_lote_impl_8.tta_val_perc_desc   = (tt-lin-i-cr.vl-desconto * 100) / tt-lin-i-cr.vl-bruto 
                   tt_integr_acr_item_lote_impl_8.tta_val_liq_tit_acr = tt-lin-i-cr.vl-liquido
                   .
        end. 

        /* Pre‡o Flutuante */ 
        IF l-modul-graos THEN DO:
            FOR FIRST ped-venda USE-INDEX ch-pedido NO-LOCK 
            WHERE ped-venda.nome-abrev = nota-fiscal.nome-ab-cli
              AND ped-venda.nr-pedcli  = nota-fiscal.nr-pedcli 
              AND ped-venda.tp-preco   = 4:
               FIND FIRST fat-duplic
                    WHERE fat-duplic.cod-estabel   = nota-fiscal.cod-estabel
                      AND fat-duplic.serie         = nota-fiscal.serie
                      AND fat-duplic.nr-fatura     = nota-fiscal.nr-fatura
                      AND fat-duplic.flag-atualiz  = NO
                      AND fat-duplic.parcela       = tt-lin-i-cr.parcela NO-LOCK NO-ERROR.
               IF AVAIL fat-duplic THEN DO:
                   FOR LAST idx-preco-flut NO-LOCK
                      WHERE idx-preco-flut.cod-estab          = fat-duplic.cod-estabel
                        AND idx-preco-flut.cod-familia-mater  = fat-duplic.cod-familia-mater 
                        AND idx-preco-flut.dat-val-inic      <= fat-duplic.dt-venciment:

                       CREATE tt_params_generic_api.
                       ASSIGN tt_params_generic_api.ttv_rec_id     = RECID(tt_integr_acr_item_lote_impl_8)
                              tt_params_generic_api.ttv_cod_tabela = "tt_integr_acr_item_lote_impl":U
                              tt_params_generic_api.ttv_cod_campo  = "% Antecip Desconto":U
                              tt_params_generic_api.ttv_cod_valor  = STRING(idx-preco-flut.val-perc-desc / 30).

                       ASSIGN tt_integr_acr_item_lote_impl_8.tta_val_perc_desc             = fat-duplic.val-tax-ptlidad  
                              tt_integr_acr_item_lote_impl_8.tta_dat_desconto              = tt_integr_acr_item_lote_impl_8.tta_dat_vencto_tit_acr
                              tt_integr_acr_item_lote_impl_8.tta_val_perc_juros_dia_atraso = (idx-preco-flut.val-taxa / 30). 
                   END.
               END.
            END.
        END.
        /* Fim Pre‡o Flutuante */ 

        
        if (tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "10" /*Nota de Cr‚dito*/
        or  tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "11" /*Nota de D‚bito*/) 
        and nota-fiscal.nro-nota-orig <> "" then do:

            /* Contabiliza‡Æo Despesa Nota Cr‚dito ->> Internacional */
            if  i-pais-impto-usuario <> 1 then do:

                IF (estabelec.integr-ncr-crp <> 3 /*Antecipa*/ 
                    AND tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "10" /*Nota de Cr‚dito*/ ) 
                    OR tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "11" /*Nota de D‚bito*/  THEN DO:

                    if  NOT para-fat.ind-transitoria then DO:
                        EMPTY TEMP-TABLE tt-conta-pend-parcela.
                        run pi-busca-conta-transitoria.
                    END.
    
                    /*** Localiza a nota de origem, para criar a tt de relacionamento ***/
                    FIND b-nota-fiscal
                        WHERE b-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel
                          AND b-nota-fiscal.serie       = nota-fiscal.serie-orig
                          AND b-nota-fiscal.nr-nota-fis = nota-fiscal.nro-nota-orig NO-LOCK NO-ERROR.
        
                    FIND FIRST b-fatura 
                        WHERE b-fatura.cod-estabel = b-nota-fiscal.cod-estabel
                          AND b-fatura.serie       = b-nota-fiscal.serie
                          AND b-fatura.nr-fatura   = b-nota-fiscal.nr-fatura
                          AND b-fatura.parcela     = tt-lin-i-cr.parcela  NO-LOCK NO-ERROR.
    
                    ASSIGN vl-tot-lote-acum = 0.
                    
                    FOR EACH fat-duplic
                        WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel
                          AND fat-duplic.serie       = nota-fiscal.serie
                          AND fat-duplic.nr-fatura   = nota-fiscal.nr-fatura
                          AND fat-duplic.parcela     = tt-lin-i-cr.parcela  NO-LOCK:
                       
                    
                        CREATE tt_integr_acr_relacto_pend.
                        ASSIGN tt_integr_acr_relacto_pend.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
                               tt_integr_acr_relacto_pend.ttv_cod_estab_tit_acr_pai_ext  = nota-fiscal.cod-estabel
                               tt_integr_acr_relacto_pend.tta_cod_espec_docto            = b-fatura.cod-esp /*fat-duplic.cod-esp*/
                               tt_integr_acr_relacto_pend.tta_cod_ser_docto              = nota-fiscal.serie-orig /*fat-duplic.serie*/
                               tt_integr_acr_relacto_pend.tta_cod_tit_acr                = nota-fiscal.nro-nota-orig /*fat-duplic.nr-fatura*/
                               tt_integr_acr_relacto_pend.tta_cod_parcela                = tt-lin-i-cr.parcela /*fat-duplic.parcela*/
                               tt_integr_acr_relacto_pend.tta_val_relacto_tit_acr        = IF  l-america-latina THEN tt-lin-i-cr.vl-base-calc-ret ELSE fat-duplic.vl-parcela
                               tt_integr_acr_relacto_pend.tta_log_gera_alter_val         = YES
                               tt_integr_acr_relacto_pend.tta_ind_motiv_acerto_val       = if nota-fiscal.ind-tip-nota = 10 then "4":U ELSE "3":U.
                         
                        IF  l-america-latina THEN DO:
                            RUN pi-calcula-impostos-relacto(INPUT tt-lin-i-cr.ep-codigo,
                                                            INPUT nota-fiscal.cod-estabel,
                                                            INPUT tt-lin-i-cr.cod-esp,
                                                            INPUT tt-lin-i-cr.nr-docto,
                                                            INPUT tt-lin-i-cr.parcela,
                                                            OUTPUT de-vl-tot-agregados).
    
                            /* quando for nota fiscal de cr‚dito soma os agregados no relacto_pend */
                            ASSIGN tt_integr_acr_relacto_pend.tta_val_relacto_tit_acr = tt_integr_acr_relacto_pend.tta_val_relacto_tit_acr + de-vl-tot-agregados.
                        END.
    
                        FOR EACH tt-conta-pend-parcela
                            WHERE tt-conta-pend-parcela.parcela = tt-lin-i-cr.parcela EXCLUSIVE-LOCK:
    
                            /*** FO 1.519.583 ***/
                            FIND FIRST tt_integr_acr_aprop_relacto
                                 WHERE tt_integr_acr_aprop_relacto.tta_cod_cta_ctbl_ext     = tt-conta-pend-parcela.ct-codigo        
                                   AND tt_integr_acr_aprop_relacto.tta_cod_sub_cta_ctbl_ext = tt-conta-pend-parcela.sc-codigo
                                   AND tt_integr_acr_aprop_relacto.ttv_rec_relacto_pend_tit_acr = recid(tt_integr_acr_relacto_pend) NO-ERROR.
     
                            IF NOT AVAIL tt_integr_acr_aprop_relacto THEN DO:
                            
                            create tt_integr_acr_aprop_relacto.
                            assign tt_integr_acr_aprop_relacto.ttv_rec_relacto_pend_tit_acr = recid(tt_integr_acr_relacto_pend)
                                   tt_integr_acr_aprop_relacto.tta_cod_cta_ctbl_ext         = tt-conta-pend-parcela.ct-codigo        
                                   tt_integr_acr_aprop_relacto.tta_cod_sub_cta_ctbl_ext     = tt-conta-pend-parcela.sc-codigo
                                   tt_integr_acr_aprop_relacto.tta_cod_unid_negoc_ext       = "":U
                                   tt_integr_acr_aprop_relacto.tta_cod_fluxo_financ_ext     = "":U 
                                   tt_integr_acr_aprop_relacto.tta_cod_plano_cta_ctbl       = "":U
                                   tt_integr_acr_aprop_relacto.tta_cod_cta_ctbl             = "":U
                                   tt_integr_acr_aprop_relacto.tta_cod_unid_negoc           = "":U
                                   tt_integr_acr_aprop_relacto.tta_cod_tip_fluxo_financ     = "":U  
                                   tt_integr_acr_aprop_relacto.tta_ind_tip_aprop_ctbl       = "":U.
    
                            END. 
    
                            ASSIGN tt_integr_acr_aprop_relacto.tta_val_aprop_ctbl = tt_integr_acr_aprop_relacto.tta_val_aprop_ctbl + tt-conta-pend-parcela.valor.
                             
                            ASSIGN vl-tot-lote-acum  = vl-tot-lote-acum  + tt-conta-pend-parcela.valor. 
    
                            /* para nota de credito e AM manda o fluxo */
                            IF  l-america-latina
                            AND tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "10":U /* credito */ THEN
                                ASSIGN tt_integr_acr_aprop_relacto.tta_cod_fluxo_financ_ext = string(tt-lin-i-cr.tp-codigo).
                          
                            IF NOT(tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "11":U) /* debito */ THEN DO:
                            /* Verifica se deve ser feito rateio por unidade de neg¢cio */
    
                                assign v_log_utiliza_rateio_un = no.
                                &if defined(bf_dis_unid_neg) &then 
                                    assign v_log_utiliza_rateio_un = yes.
                                &endif.
        
                                if  v_log_utiliza_rateio_un = yes
                                and can-find(first para-dis where para-dis.log-unid-neg = yes) then do:
        
                                    run pi_rateio_unid_neg.
                                    if  return-value = "NOK":U THEN
                                        UNDO bloco_principal, LEAVE bloco_principal.
                                end.
                                ELSE
                                    delete tt-conta-pend-parcela.
                            END.
                        END.
    
                    END. /* for each fat-duplic */

                    /* ap¢s calcular as apropriacoes (com valor liquido) atualiza o valor do relacto_pend com o valor l¡quido*/
                    IF  l-america-latina THEN
                        ASSIGN tt_integr_acr_item_lote_impl_8.tta_val_tit_acr     = vl-tot-lote-acum 
                               tt_integr_acr_item_lote_impl_8.tta_val_liq_tit_acr = vl-tot-lote-acum.
                END.
                ELSE
                    RUN pi-cria-aprop-contab.

            end. /* i-pais-impto-usuario <> 1 */
        end.
        else do:   /* Notas de D‚bito e Cr‚dito nÆo devem criar aprop_ctbl no EMS 5 */
            RUN pi-cria-aprop-contab.
            if return-value = "NOK" then DO:

                FOR EACH tt_integr_acr_item_lote_impl_8 
                    WHERE tt_integr_acr_item_lote_impl_8.ttv_rec_lote_impl_tit_acr = 
                          recid(tt_integr_acr_lote_impl):

                    FOR EACH tt_integr_acr_aprop_ctbl_pend 
                        WHERE tt_integr_acr_aprop_ctbl_pend.ttv_rec_item_lote_impl_tit_acr = 
                              tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr:
                        DELETE tt_integr_acr_aprop_ctbl_pend.
                    END.

                    FOR EACH tt_integr_acr_relacto_pend
                        WHERE tt_integr_acr_relacto_pend.ttv_rec_item_lote_impl_tit_acr = 
                              tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr:
                        DELETE tt_integr_acr_relacto_pend.
                    END.

                    FOR EACH tt_integr_acr_ped_vda_pend
                        WHERE tt_integr_acr_ped_vda_pend.ttv_rec_item_lote_impl_tit_acr = 
                              tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr:
                        DELETE tt_integr_acr_ped_vda_pend.
                    END.

                    FOR EACH tt_integr_acr_repres_pend
                        WHERE tt_integr_acr_repres_pend.ttv_rec_item_lote_impl_tit_acr = 
                              tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr:
                        DELETE tt_integr_acr_repres_pend.
                    END.

                    FOR EACH tt_integr_acr_repres_comis_2
                        WHERE tt_integr_acr_repres_comis_2.ttv_rec_item_lote_impl_tit_acr = 
                              tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr:
                        DELETE tt_integr_acr_repres_comis_2.
                    END.

                    DELETE tt_integr_acr_item_lote_impl_8.
                END.

                DELETE tt_integr_acr_lote_impl.

                next bloco_principal.
            END.
        end.

        if  tt-lin-i-cr.nr-pedcli <> "":U
        then do: 

             find ped-venda use-index ch-pedido
                 where ped-venda.nome-abrev = nota-fiscal.nome-ab-cli
                   and ped-venda.nr-pedcli  = nota-fiscal.nr-pedcli no-lock no-error.

             create tt_integr_acr_ped_vda_pend. 
             assign tt_integr_acr_ped_vda_pend.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr                    
                    tt_integr_acr_ped_vda_pend.tta_cod_ped_vda                = tt-lin-i-cr.nr-pedcli 
                    tt_integr_acr_ped_vda_pend.tta_cod_ped_vda_repres         = tt-lin-i-cr.pedido-rep 
                    /*tt_integr_acr_ped_vda_pend.tta_cod_ped_vda                = string(ped-venda.nr-pedido)*/
                    tt_integr_acr_ped_vda_pend.tta_val_perc_particip_ped_vda  = 100. 
        end.
        if  c-nom-prog-dpc-mg97  <> ""
            or  c-nom-prog-appc-mg97 <> "" 
            or  c-nom-prog-upc-mg97  <> ""  then do:
            
            for each tt-epc 
                where tt-epc.cod-event = "Tipo_Comissao_Externa":
                delete tt-epc.
            end.

            create tt-epc.
            assign tt-epc.cod-event     = "Tipo_Comissao_Externa"
                    tt-epc.cod-parameter = "ped-venda rowid"
                    tt-epc.val-parameter = string(rowid(ped-venda)).
            

            create tt-epc.
            assign tt-epc.cod-event     = "Tipo_Comissao_Externa"
                   tt-epc.cod-parameter = "Tip_Comis_Ext_Repre"
                   tt-epc.val-parameter = "":U.

            {include/i-epc201.i "Tipo_Comissao_Externa"}
            /* Sem tratamento de retorno */

            find tt-epc 
                where tt-epc.cod-event = "Tipo_Comissao_Externa" 
                  and tt-epc.cod-parameter = "Tip_Comis_Ext_Repre" no-error.
            ASSIGN c-tta_ind_tip_comis_ext = tt-epc.val-parameter.
        END.
        ELSE ASSIGN c-tta_ind_tip_comis_ext = "".

        IF NOT CAN-FIND(FIRST tt-rep-i-cr
            where  tt-rep-i-cr.ep-codigo   = tt-lin-i-cr.ep-codigo 
              and  tt-rep-i-cr.cod-estabel = tt-lin-i-cr.cod-estabel 
              and  tt-rep-i-cr.cod-esp     = tt-lin-i-cr.cod-esp 
              and  tt-rep-i-cr.nr-docto    = tt-lin-i-cr.nr-docto 
              and  tt-rep-i-cr.parcela     = tt-lin-i-cr.parcela) 
        THEN
            ASSIGN l-integra = YES.

        for each tt-rep-i-cr no-lock 
            where  tt-rep-i-cr.ep-codigo   = tt-lin-i-cr.ep-codigo 
              and  tt-rep-i-cr.cod-estabel = tt-lin-i-cr.cod-estabel 
              and  tt-rep-i-cr.cod-esp     = tt-lin-i-cr.cod-esp 
              and  tt-rep-i-cr.nr-docto    = tt-lin-i-cr.nr-docto 
              and  tt-rep-i-cr.parcela     = tt-lin-i-cr.parcela
              AND  tt-rep-i-cr.serie       = tt-lin-i-cr.serie: 

            if  time - i-time > 0 then do:
                assign i-time = time.
                run pi-acompanhar in h-acomp (input c-acomp-rep + " " + string(tt-rep-i-cr.cod-rep)).
            END.

            create tt_integr_acr_repres_pend. 
            assign tt_integr_acr_repres_pend.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
                   tt_integr_acr_repres_pend.tta_cdn_repres                 = tt-rep-i-cr.cod-rep 
                   tt_integr_acr_repres_pend.tta_val_perc_comis_repres      = tt-rep-i-cr.comissao 
                   tt_integr_acr_repres_pend.tta_val_perc_comis_repres_emis = tt-rep-i-cr.comis-emis 
                   tt_integr_acr_repres_pend.tta_log_comis_repres_proporc   = ?
                   tt_integr_acr_repres_pend.tta_val_perc_comis_abat        = ?  /* % Comis Abatimento */
                   tt_integr_acr_repres_pend.tta_val_perc_comis_desc        = ?  /* % Comis Desconto */
                   tt_integr_acr_repres_pend.tta_val_perc_comis_juros       = ?  /* % Comis Juros */
                   tt_integr_acr_repres_pend.tta_val_perc_comis_multa       = ?  /* % Comis Multa */
                   tt_integr_acr_repres_pend.tta_val_perc_comis_acerto_val  = ?. /* % Comis AVA */

            create tt_integr_acr_repres_comis_2.
            assign tt_integr_acr_repres_comis_2.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
                   tt_integr_acr_repres_comis_2.tta_cdn_repres                 = tt-rep-i-cr.cod-rep.

            /* Engenharia ComissÆo Agentes Externos */
            IF  l-spp-comagext THEN
                ASSIGN tt_integr_acr_repres_comis_2.ttv_ind_liber_pagto_comis = substr(tt-rep-i-cr.char-1,2,1)
                       tt_integr_acr_repres_comis_2.tta_ind_tip_comis_ext     = if c-tta_ind_tip_comis_ext = "" then substr(tt-rep-i-cr.char-1,1,1) else c-tta_ind_tip_comis_ext.
            ELSE
                ASSIGN tt_integr_acr_repres_comis_2.tta_ind_tip_comis_ext     = c-tta_ind_tip_comis_ext.

                
            RUN prgint/ufn/ufn909za.py (input "1",
                                        INPUT v_cod_matriz_trad_org_ext,
                                        INPUT i-empresa,
                                        INPUT tt_integr_acr_item_lote_impl_8.tta_dat_emis_docto,
                                        OUTPUT c-tipo-comis,
                                        OUTPUT TABLE tt_log_erros_comis_repres).
            

            IF RETURN-VALUE <> "NOK":U THEN
                ASSIGN l-integra = YES.

            for each tt_log_erros_comis_repres:
                
                create tt-retorno-nota-fiscal.
                assign tt-retorno-nota-fiscal.tipo       = 2
                       tt-retorno-nota-fiscal.situacao   = NO
                       tt-retorno-nota-fiscal.cod-erro   = string(tt_log_erros_comis_repres.ttv_num_cod_erro)
                       tt-retorno-nota-fiscal.desc-erro  = tt_log_erros_comis_repres.ttv_des_erro
                       tt-retorno-nota-fiscal.referencia = string(tt-doc-i-cr.referencia)
                       tt-retorno-nota-fiscal.cod-chave  = tt-doc-i-cr.referencia + ",,":U + 
                                                           string(i-empresa) + ",":U + nota-fiscal.cod-estabel + ",":U +
                                                           "":U + ",":U + nota-fiscal.serie + ",":U +
                                                           if nota-fiscal.nr-fatura = "":U then nota-fiscal.nr-nota-fis 
                                                           else nota-fiscal.nr-fatura + ",":U.

            end.

            if c-tipo-comis = "1":U then
                {utp/ut-liter.i Valor_Liquido * R} /*assign c-tipo-comis = "Net Amount" /*"Valor Liquido"*/ . */
            else if c-tipo-comis = "2" then
                {utp/ut-liter.i Valor_Bruto}       /*assign c-tipo-comis = "Gross Amt" /*"Valor Bruto"*/ .*/
            
            assign c-tipo-comis = trim(return-value).

            assign tt_integr_acr_repres_pend.tta_ind_tip_comis = c-tipo-comis. /* 1 = valor_liquido, 2 = valor_bruto */ 

            /* Engenharia ComissÆo Agentes Externos */
            if l-spp-comagext then do:
                if tt_integr_acr_repres_comis_2.tta_ind_tip_comis_ext  <> "2" then     /* PadrÆo */
                   assign tt_integr_acr_repres_comis_2.ttv_ind_liber_pagto_comis = "1".

                if tt_integr_acr_repres_comis_2.ttv_ind_liber_pagto_comis  = "2" then  /* Final do Processo Exporta‡Æo */
                    assign tt_integr_acr_repres_pend.tta_val_perc_comis_repres_emis = 100.

                if tt_integr_acr_repres_comis_2.ttv_ind_liber_pagto_comis  = "3" then  /* Ap¢s Liquid Ult Tit  */
                    assign tt_integr_acr_repres_pend.tta_val_perc_comis_repres_emis = 0.
            end.

        end. 

        IF  l-america-latina THEN DO:
            /********************************************************/
            /** DATASUL LATINA - CHAMADA EPC Integra-impto-faturam **/
            /** INICIO                                             **/
            /********************************************************/
            FIND FIRST tt-impto-tit-pend-cr-1 
                WHERE  tt-impto-tit-pend-cr-1.ep-codigo   = tt-lin-i-cr.ep-codigo 
                  AND  tt-impto-tit-pend-cr-1.cod-estabel = tt-lin-i-cr.cod-estabel 
                  AND  tt-impto-tit-pend-cr-1.cod-esp     = tt-lin-i-cr.cod-esp 
                  AND  tt-impto-tit-pend-cr-1.nr-docto    = tt-lin-i-cr.nr-docto 
                  AND  tt-impto-tit-pend-cr-1.parcela     = tt-lin-i-cr.parcela NO-LOCK NO-ERROR.

            IF  i-pais-impto-usuario = 2 /* Argentina */ THEN DO:
                IF  NOT VALID-HANDLE(h-arg0037) THEN
                    RUN local/arg/arg0037.p PERSISTENT SET h-arg0037.
            
                RUN integra-impto-faturam IN h-arg0037 (INPUT TEMP-TABLE tt-impto-tit-pend-cr-1:HANDLE).
                DELETE PROCEDURE h-arg0037.
            END.

            for each tt-epc
                where tt-epc.cod-event = "Integra-impto-faturam":U:
                delete tt-epc.
            end.
        
            create tt-epc.
            assign tt-epc.cod-event     = "Integra-impto-faturam":U
                   tt-epc.cod-parameter = "handle-tt-impto-tit-pend-cr-1":U.
            
            &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
                ASSIGN tt-epc.val-parameter = string(temp-table tt-impto-tit-pend-cr-1:handle).
            &ENDIF
            
            {include/i-epc201.i "Integra-impto-faturam"}

            for each tt-epc
                where tt-epc.cod-event = "Integra-impto-faturam":U:
                delete tt-epc.
            end.
                
            /********************************************************/
            /** DATASUL LATINA - CHAMADA EPC Integra-impto-faturam **/
            /** FIN                                                **/
            /********************************************************/
            FOR EACH tt-impto-tit-pend-cr-1 NO-LOCK
                WHERE  tt-impto-tit-pend-cr-1.ep-codigo   = tt-lin-i-cr.ep-codigo 
                  AND  tt-impto-tit-pend-cr-1.cod-estabel = tt-lin-i-cr.cod-estabel 
                  AND  tt-impto-tit-pend-cr-1.cod-esp     = tt-lin-i-cr.cod-esp 
                  AND  tt-impto-tit-pend-cr-1.nr-docto    = tt-lin-i-cr.nr-docto 
                  AND  tt-impto-tit-pend-cr-1.parcela     = tt-lin-i-cr.parcela:
        
                IF  TIME - i-time > 0 THEN DO:
                    ASSIGN i-time = TIME.
                    RUN pi-acompanhar IN h-acomp (INPUT c-acomp-imp + " ":U + STRING(tt-impto-tit-pend-cr-1.cod-imposto)).
                END.
    
                CREATE tt_integr_acr_impto_impl_pend. 
                ASSIGN tt_integr_acr_impto_impl_pend.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
                       tt_integr_acr_impto_impl_pend.tta_cod_unid_federac           = ""
                       tt_integr_acr_impto_impl_pend.tta_cod_imposto                = STRING(tt-impto-tit-pend-cr-1.cod-imposto)
                       tt_integr_acr_impto_impl_pend.tta_cod_classif_impto          = STRING(tt-impto-tit-pend-cr-1.cod-classificacao)
                       tt_integr_acr_impto_impl_pend.tta_num_seq                    = tt-impto-tit-pend-cr-1.num-seq-impto
                       tt_integr_acr_impto_impl_pend.tta_val_rendto_tribut          = tt-impto-tit-pend-cr-1.vl-base-me
                       tt_integr_acr_impto_impl_pend.tta_val_aliq_impto             = tt-impto-tit-pend-cr-1.perc-imposto
                       tt_integr_acr_impto_impl_pend.tta_val_imposto                = tt-impto-tit-pend-cr-1.vl-imposto-me
                       tt_integr_acr_impto_impl_pend.tta_ind_clas_impto             = STRING(tt-impto-tit-pend-cr-1.ind-tipo-imposto)
                       tt_integr_acr_impto_impl_pend.tta_cod_indic_econ             = STRING(tt-impto-tit-pend-cr-1.mo-codigo)
                       tt_integr_acr_impto_impl_pend.tta_val_cotac_indic_econ       = 1
                       tt_integr_acr_impto_impl_pend.tta_dat_cotac_indic_econ       = TODAY
                       tt_integr_acr_impto_impl_pend.tta_val_impto_indic_econ_impto = tt-impto-tit-pend-cr-1.vl-imposto-me.

                FOR EACH tt_xml_input_output:
                    DELETE tt_xml_input_output.
                END.
                FOR EACH tt_log_erros.
                    DELETE tt_log_erros.
                END.

                CREATE tt_xml_input_output.
                ASSIGN tt_xml_input_output.ttv_cod_label = "Fun‡Æo":U
                       tt_xml_input_output.ttv_des_conteudo = "Faturamento 2.00":U
                       tt_xml_input_output.ttv_num_seq_1 = 1.
                CREATE tt_xml_input_output.
                ASSIGN tt_xml_input_output.ttv_cod_label = "Produto":U
                       tt_xml_input_output.ttv_des_conteudo = "EMS 5"
                       tt_xml_input_output.ttv_num_seq_1 = 1.
                CREATE tt_xml_input_output.
                ASSIGN tt_xml_input_output.ttv_cod_label = "Empresa":U
                       tt_xml_input_output.ttv_des_conteudo = STRING(i-empresa)
                       tt_xml_input_output.ttv_num_seq_1 = 1.
                CREATE tt_xml_input_output.
                ASSIGN tt_xml_input_output.ttv_cod_label = "Estabel":U
                       tt_xml_input_output.ttv_des_conteudo = tt-doc-i-cr.cod-estabel
                       tt_xml_input_output.ttv_num_seq_1 = 1.
                CREATE tt_xml_input_output.
                ASSIGN tt_xml_input_output.ttv_cod_label = "Contas":U
                       tt_xml_input_output.ttv_des_conteudo = tt-impto-tit-pend-cr-1.ct-imposto + ';' + 
                                                              tt-impto-tit-pend-cr-1.sc-imposto + ';' +
                                                              ""                                + ';' +
                                                              tt-doc-i-cr.cod-estabel           + ';' +
                                                              "".
                       tt_xml_input_output.ttv_num_seq_1 = 1.

                
                
                CREATE tt_xml_input_output.
                ASSIGN tt_xml_input_output.ttv_cod_label = "Pa¡s":U
                       tt_xml_input_output.ttv_des_conteudo = emitente.pais.
                       tt_xml_input_output.ttv_num_seq_1 = 1.


                       
                RUN prgint/utb/utb786za.py (INPUT-OUTPUT TABLE tt_xml_input_output,
                                            OUTPUT       TABLE tt_log_erros).
                       

                IF RETURN-VALUE <> "NOK":U THEN
                    ASSIGN l-integra = YES.
                
                IF  CAN-FIND(first tt_log_erros) THEN DO:

                    FOR EACH tt_log_erros NO-LOCK:
                        
                        CREATE tt-retorno-nota-fiscal.
                        ASSIGN tt-retorno-nota-fiscal.tipo       = 2
                               tt-retorno-nota-fiscal.situacao   = NO
                               tt-retorno-nota-fiscal.cod-erro   = STRING(tt_log_erros.ttv_num_cod_erro)
                               tt-retorno-nota-fiscal.desc-erro  = tt_log_erros.ttv_des_erro
                               tt-retorno-nota-fiscal.referencia = STRING(tt-doc-i-cr.referencia)
                               tt-retorno-nota-fiscal.cod-chave  = tt-doc-i-cr.referencia + ",,":U + 
                                                                   STRING(i-empresa) + ",":U + nota-fiscal.cod-estabel + ",":U +
                                                                   "":U + ",":U + nota-fiscal.serie + ",":U +
                                                                   IF nota-fiscal.nr-fatura = "":U THEN nota-fiscal.nr-nota-fis 
                                                                   ELSE nota-fiscal.nr-fatura + ",":U.
    
                    END.
                END.
                ELSE DO:
                    
                    FIND FIRST tt_xml_input_output NO-LOCK WHERE
                               tt_xml_input_output.ttv_cod_label = "Contas" NO-ERROR.
                    IF  AVAIL tt_xml_input_output THEN
                        ASSIGN tt_integr_acr_impto_impl_pend.tta_cod_plano_cta_ctbl = ENTRY(1,tt_xml_input_output.ttv_des_conteudo_aux, ";")
                               tt_integr_acr_impto_impl_pend.tta_cod_cta_ctbl       = ENTRY(2,tt_xml_input_output.ttv_des_conteudo_aux, ";").

                    FIND FIRST tt_xml_input_output NO-LOCK WHERE
                               tt_xml_input_output.ttv_cod_label = "Pa¡s":U NO-ERROR.
                    IF  AVAIL tt_xml_input_output THEN DO:
                    
                         ASSIGN tt_integr_acr_impto_impl_pend.tta_cod_pais = ENTRY(1,tt_xml_input_output.ttv_des_conteudo_aux, ";").
                       
                    END.
                END.
            END.
        END. /* if america latina */

        
        /********************************************************/
        /** DATASUL LATINA - CHAMADA EPC Cambia-impto-faturam  **/
        /** INICIO                                             **/
        /********************************************************/
        FIND FIRST tt_integr_acr_impto_impl_pend NO-LOCK NO-ERROR.

        IF  i-pais-impto-usuario = 2 /* Argentina */ THEN DO:
            IF  NOT VALID-HANDLE(h-arg0037) THEN
                RUN local/arg/arg0037.p PERSISTENT SET h-arg0037.
        
            RUN cambia-impto-faturam IN h-arg0037 (INPUT TEMP-TABLE tt_integr_acr_impto_impl_pend:HANDLE).
            DELETE PROCEDURE h-arg0037.
        END.

        for each tt-epc
            where tt-epc.cod-event = "Cambia-impto-faturam":U:
            delete tt-epc.
        end.

        create tt-epc.
        assign tt-epc.cod-event     = "Cambia-impto-faturam":U
               tt-epc.cod-parameter = "handle-tt_integr_acr_impto_impl_pend":U.
        &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
            ASSIGN tt-epc.val-parameter = string(temp-table tt_integr_acr_impto_impl_pend:handle).
        &ENDIF
        
        {include/i-epc201.i "Cambia-impto-faturam"}
            
        for each tt-epc
            where tt-epc.cod-event = "Cambia-impto-faturam":U:
            delete tt-epc.
        end.
              
        /********************************************************/
        /** DATASUL LATINA - CHAMADA EPC Cambia-impto-faturam  **/
        /** FIN                                                **/
        /********************************************************/
        if  c-nom-prog-dpc-mg97  <> ""
            or  c-nom-prog-appc-mg97 <> "" 
            or  c-nom-prog-upc-mg97  <> ""  then 
        
            for each  tt-impto-tit-pend-cr-1
                where tt-impto-tit-pend-cr-1.ep-codigo   = tt-lin-i-cr.ep-codigo
                and   tt-impto-tit-pend-cr-1.cod-estabel = tt-lin-i-cr.cod-estabel
                and   tt-impto-tit-pend-cr-1.cod-esp     = tt-lin-i-cr.cod-esp
                and   tt-impto-tit-pend-cr-1.serie       = tt-lin-i-cr.serie
                and   tt-impto-tit-pend-cr-1.nr-docto    = tt-lin-i-cr.nr-docto
                and   tt-impto-tit-pend-cr-1.parcela     = tt-lin-i-cr.parcela
                no-lock:

                if  time - i-time > 0 then do:
                    assign i-time = time.
                    run pi-acompanhar in h-acomp (input c-acomp-imp + " ":U + string(tt-impto-tit-pend-cr-1.cod-imposto)).            
                END.

                for each tt-epc where tt-epc.cod-event = "Update-impto-tit-pend-cr":U:
                    delete tt-epc.
                end.

                create tt-epc.
                assign tt-epc.cod-event     = "Update-impto-tit-pend-cr":U
                       tt-epc.cod-parameter = "rowid(lin-i-cr)":U
                       tt-epc.val-parameter = string(rowid(lin-i-cr)).                                                                      

                create tt-epc.
                assign tt-epc.cod-event     = "Update-impto-tit-pend-cr":U 
                       tt-epc.cod-parameter = "rowid(impto-tit-pend-cr)":U
                       tt-epc.val-parameter = string(rowid(impto-tit-pend-cr)).

                create tt-epc.
                assign tt-epc.cod-event     = "Update-impto-tit-pend-cr":U
                       tt-epc.cod-parameter = "field cod-estabel":U
                       tt-epc.val-parameter = tt-impto-tit-pend-cr-1.cod-estabel.

                create tt-epc.
                assign tt-epc.cod-event     = "Update-impto-tit-pend-cr":U
                       tt-epc.cod-parameter = "field cd-jurisdicao":U
                       tt-epc.val-parameter = tt-impto-tit-pend-cr-1.cd-jurisdicao.

                create tt-epc.
                assign tt-epc.cod-event     = "Update-impto-tit-pend-cr":U
                       tt-epc.cod-parameter = "field vl-imposto":U
                       tt-epc.val-parameter = string(tt-impto-tit-pend-cr-1.vl-imposto).

                create tt-epc.
                assign tt-epc.cod-event     = "Update-impto-tit-pend-cr":U 
                       tt-epc.cod-parameter = "field cod-certif-isencao":U
                       tt-epc.val-parameter = tt-impto-tit-pend-cr-1.cod-certif-isencao.
              
             
                
                create tt-epc.
                assign tt-epc.cod-event     = "Update-impto-tit-pend-cr":U
                       tt-epc.cod-parameter = "field num_seq_refer":U 
                       tt-epc.val-parameter = string(tt_integr_acr_item_lote_impl_8.tta_num_seq_refer).
                
                {include/i-epc201.i "Update-impto-tit-pend-cr"}

                /*[ Tratamento de retorno erros da DPC Sales Tax - USA ]*/
                FIND FIRST tt-epc WHERE
                           tt-epc.cod-event     = 'Update-impto-tit-pend-cr' AND
                           tt-epc.cod-parameter = 'Erro_DPC' NO-ERROR.
                IF AVAIL tt-epc THEN DO:
                    CREATE tt_log_erros_atualiz.
                    ASSIGN tt_log_erros_atualiz.ttv_num_mensagem  = INT(ENTRY(1,tt-epc.val-parameter,CHR(24)))
                           tt_log_erros_atualiz.ttv_des_msg_erro  = ENTRY(2,tt-epc.val-parameter,CHR(24))
                           tt_log_erros_atualiz.ttv_des_msg_ajuda = ENTRY(3,tt-epc.val-parameter,CHR(24))
                           tt_log_erros_atualiz.tta_cod_refer     = ENTRY(4,tt-epc.val-parameter,CHR(24))
                           tt_log_erros_atualiz.tta_cod_estab     = ENTRY(5,tt-epc.val-parameter,CHR(24)).

                    /**[ Gera os erros retornados pela DPC para serem impressos no LOG de Integra‡Æo ]**/
                    RUN pi-geracao-erros.
                
                    /**[ Elimina item lote implanta‡Æo que est  com o Sales Tax com problemas ]**/
                    DELETE tt_integr_acr_item_lote_impl_8.
                END.
            end.
    END.

    
    IF i-pais-impto-usuario <> 1 
    AND CAN-FIND(FIRST it-nota-fisc OF nota-fiscal WHERE it-nota-fisc.nr-remito <> "":U) THEN
        RUN pi-gera-abatimento-remito.

    if  c-nom-prog-dpc-mg97  <> ""
        or  c-nom-prog-appc-mg97 <> "" 
        or  c-nom-prog-upc-mg97  <> ""  then do:
        
        FOR EACH tt-epc WHERE tt-epc.cod-event = "Atualiza‡Æo Impostos":U:
            DELETE tt-epc.
        END.


        {include/i-epc200.i2 &codevent = '"Atualiza‡Æo Impostos":U'
                             &codparameter = '"rowid tt_integr_acr_item_lote_impl_7"'
                             &valueparameter = "string(rowid(item))"}
        {include/i-epc201.i "Atualiza‡Æo Impostos"}
    END.

end. /* For each tt-doc-i-cr */

/* Acerta diferen‡as do Rateio */

FOR EACH tt_integr_acr_item_lote_impl_8:


    ASSIGN de-soma  = 0
           de-maior = 0
           r-maior  = ?.

    FOR EACH tt_integr_acr_aprop_ctbl_pend WHERE 
         tt_integr_acr_aprop_ctbl_pend.ttv_rec_item_lote_impl_tit_acr = 
         tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr:

         ASSIGN de-soma = de-soma + tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl.

         IF tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl > de-maior 
         THEN
             ASSIGN de-maior = tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl
                    r-maior  = RECID(tt_integr_acr_aprop_ctbl_pend).
    END.

    
    IF  de-soma <> tt_integr_acr_item_lote_impl_8.tta_val_tit_acr 
    AND ABSOLUTE(de-soma - tt_integr_acr_item_lote_impl_8.tta_val_tit_acr) < 0.05 THEN DO:
        FIND tt_integr_acr_aprop_ctbl_pend WHERE RECID(tt_integr_acr_aprop_ctbl_pend) = r-maior NO-ERROR.
        ASSIGN tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl = 
                        tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl +
                        tt_integr_acr_item_lote_impl_8.tta_val_tit_acr   - de-soma.
    END.

END.

/***************************************************************/
/**************** EXECU€ÇO DA ACR900 ***************************/

IF NOT CAN-FIND(FIRST tt_integr_acr_item_lote_impl_8) THEN DO:
    if valid-handle(h-cd9500) then
        delete widget h-cd9500.

    run pi-finalizar in h-acomp.

    return "OK":U.
END.

IF l-integra THEN DO:
    {utp/ut-liter.i Inicio_Integra‡Æo_EMS5 *}
    run pi-acompanhar in h-acomp (input  Return-value  + "":U + "":U + "":U + "":U).    

    IF CAN-FIND(funcao WHERE funcao.ativo 
                       AND   funcao.cd-funcao = "spp-fn-log-ems5":U)  /* ativar com o programa cd7070 */
    THEN RUN pi-gera-log-ems5.

   /********************************************************/
   /** DATASUL LATINA - CHAMADA EPC Integra-serie         **/
   /** INICIO                                             **/
   /********************************************************/

    IF  l-america-latina THEN DO:
        for each tt-epc
            where tt-epc.cod-event = "Integra-serie":U:
            delete tt-epc.
        end.

        FIND FIRST tt_integr_acr_abat_antecip     NO-LOCK NO-ERROR.
        FIND FIRST tt_integr_acr_abat_prev        NO-LOCK NO-ERROR.
        FIND FIRST tt_integr_acr_item_lote_impl   NO-LOCK NO-ERROR.
        FIND FIRST tt_integr_acr_item_lote_impl_1 NO-LOCK NO-ERROR.
        FIND FIRST tt_integr_acr_relacto_pend     NO-LOCK NO-ERROR.
        FIND FIRST tt_integr_acr_item_lote_impl_8 NO-LOCK NO-ERROR.

        IF  i-pais-impto-usuario = 2 /* Argentina */ THEN DO:
            IF  NOT VALID-HANDLE(h-arg0037) THEN
                RUN local/arg/arg0037.p PERSISTENT SET h-arg0037.

            FOR EACH tt_integr_acr_abat_antecip EXCLUSIVE-LOCK:
                FIND FIRST tt_integr_acr_item_lote_impl_8 NO-LOCK
                    WHERE  tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_abat_antecip.ttv_rec_item_lote_impl_tit_acr NO-ERROR.
                RUN pi-trata-serie-2 IN h-arg0037 (INPUT tt_integr_acr_abat_antecip.tta_cod_espec_docto,
                                                   INPUT-OUTPUT tt_integr_acr_abat_antecip.tta_cod_ser_docto,
                                                   INPUT IF AVAIL tt_integr_acr_item_lote_impl_8 THEN tt_integr_acr_item_lote_impl_8.tta_cdn_client ELSE 0,
                                                   INPUT IF AVAIL tt_integr_acr_item_lote_impl_8 THEN tt_integr_acr_item_lote_impl_8.tta_cod_refer ELSE "",
                                                   INPUT tt_integr_acr_abat_antecip.tta_cod_estab_ext).
            END.

            FOR EACH tt_integr_acr_abat_prev EXCLUSIVE-LOCK:
                FIND FIRST tt_integr_acr_item_lote_impl_8 NO-LOCK
                    WHERE  tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_abat_prev.ttv_rec_item_lote_impl_tit_acr NO-ERROR.
                RUN pi-trata-serie-2 IN h-arg0037 (INPUT tt_integr_acr_abat_prev.tta_cod_espec_docto,
                                                   INPUT-OUTPUT tt_integr_acr_abat_prev.tta_cod_ser_docto,
                                                   INPUT IF AVAIL tt_integr_acr_item_lote_impl_8 THEN tt_integr_acr_item_lote_impl_8.tta_cdn_client ELSE 0,
                                                   INPUT IF AVAIL tt_integr_acr_item_lote_impl_8 THEN tt_integr_acr_item_lote_impl_8.tta_cod_refer ELSE "",
                                                   INPUT tt_integr_acr_abat_prev.tta_cod_estab_ext).
            END.

            FOR EACH tt_integr_acr_item_lote_impl EXCLUSIVE-LOCK:
                FIND FIRST tt_integr_acr_lote_impl NO-LOCK
                    WHERE  RECID(tt_integr_acr_lote_impl) = tt_integr_acr_item_lote_impl.ttv_rec_lote_impl_tit_acr NO-ERROR.

                RUN pi-trata-serie-2 IN h-arg0037 (INPUT tt_integr_acr_item_lote_impl.tta_cod_espec_docto,
                                                   INPUT-OUTPUT tt_integr_acr_item_lote_impl.tta_cod_ser_docto,
                                                   INPUT tt_integr_acr_item_lote_impl.tta_cdn_cliente,
                                                   INPUT tt_integr_acr_item_lote_impl.tta_cod_refer,
                                                   INPUT IF AVAIL tt_integr_acr_lote_impl THEN tt_integr_acr_lote_impl.tta_cod_estab_ext ELSE "").
            END.

            FOR EACH tt_integr_acr_item_lote_impl_1 EXCLUSIVE-LOCK:
                FIND FIRST tt_integr_acr_lote_impl NO-LOCK
                    WHERE RECID(tt_integr_acr_lote_impl) = tt_integr_acr_item_lote_impl_1.ttv_rec_lote_impl_tit_acr NO-ERROR.

                RUN pi-trata-serie-2 IN h-arg0037 (INPUT tt_integr_acr_item_lote_impl_1.tta_cod_espec_docto,
                                                   INPUT-OUTPUT tt_integr_acr_item_lote_impl_1.tta_cod_ser_docto,
                                                   INPUT tt_integr_acr_item_lote_impl_1.tta_cdn_cliente,
                                                   INPUT tt_integr_acr_item_lote_impl_1.tta_cod_refer,
                                                   INPUT IF AVAIL tt_integr_acr_lote_impl THEN tt_integr_acr_lote_impl.tta_cod_estab_ext ELSE "").
            END.

            FOR EACH tt_integr_acr_relacto_pend EXCLUSIVE-LOCK:
                FIND FIRST tt_integr_acr_item_lote_impl_8 NO-LOCK
                    WHERE  tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_relacto_pend.ttv_rec_item_lote_impl_tit_acr NO-ERROR.
                
                RUN pi-trata-serie-2 IN h-arg0037 (INPUT tt_integr_acr_relacto_pend.tta_cod_espec_docto,
                                                   INPUT-OUTPUT tt_integr_acr_relacto_pend.tta_cod_ser_docto,
                                                   INPUT IF AVAIL tt_integr_acr_item_lote_impl_8 THEN tt_integr_acr_item_lote_impl_8.tta_cdn_client ELSE 0,
                                                   INPUT IF AVAIL tt_integr_acr_item_lote_impl_8 THEN tt_integr_acr_item_lote_impl_8.tta_cod_refer ELSE "",
                                                   INPUT tt_integr_acr_relacto_pend.ttv_cod_estab_tit_acr_pai_ext).
            END.

            FOR EACH tt_integr_acr_item_lote_impl_8 EXCLUSIVE-LOCK:

                FIND FIRST tt-lin-i-cr 
                     WHERE tt-lin-i-cr.cod-emitente = tt_integr_acr_item_lote_impl_8.tta_cdn_cliente
                       AND tt-lin-i-cr.sequencia    = tt_integr_acr_item_lote_impl_8.tta_num_seq_refer
                       AND tt-lin-i-cr.cod-esp      = tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto
                       AND tt-lin-i-cr.serie        = tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto
                       AND tt-lin-i-cr.nr-docto     = tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr NO-LOCK NO-ERROR.

                RUN pi-trata-serie-2 IN h-arg0037 (INPUT tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto,
                                                   INPUT-OUTPUT tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto,
                                                   INPUT tt_integr_acr_item_lote_impl_8.tta_cdn_cliente,
                                                   INPUT tt_integr_acr_item_lote_impl_8.tta_cod_refer,
                                                   INPUT IF AVAIL tt-lin-i-cr THEN tt-lin-i-cr.cod-estabel ELSE "").
            END.

            IF  RETURN-VALUE <> "OK" THEN DO:
                RUN retorna-tt-erro IN h-arg0037 (OUTPUT TABLE tt-erro-arg0037).

                FOR EACH tt-erro-arg0037 NO-LOCK:
                    CREATE tt_log_erros_atualiz.
                    ASSIGN tt_log_erros_atualiz.ttv_num_mensagem  = tt-erro-arg0037.cod-erro
                           tt_log_erros_atualiz.ttv_des_msg_erro  = tt-erro-arg0037.des-erro
                           tt_log_erros_atualiz.ttv_des_msg_ajuda = tt-erro-arg0037.des-erro
                           tt_log_erros_atualiz.tta_cod_refer     = tt-erro-arg0037.cod-refer
                           tt_log_erros_atualiz.tta_cod_estab     = "".
                END.

                RUN pi-geracao-erros.

                DELETE PROCEDURE h-arg0037.

                IF  VALID-HANDLE(h-cd9500) THEN
                    DELETE WIDGET h-cd9500.

                RUN pi-finalizar IN h-acomp.

                RETURN "NOK":U.
            END.

            DELETE PROCEDURE h-arg0037.
        END.

        create tt-epc.
        assign tt-epc.cod-event     = "Integra-serie":U
               tt-epc.cod-parameter = "handle_tt_integr_acr_abat_antecip":U.
        &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
            ASSIGN tt-epc.val-parameter = string(temp-table tt_integr_acr_abat_antecip:handle).
        &ENDIF

        create tt-epc.
        assign tt-epc.cod-event     = "Integra-serie":U
               tt-epc.cod-parameter = "handle_tt_integr_acr_abat_prev":U.
        &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
            ASSIGN tt-epc.val-parameter = string(temp-table tt_integr_acr_abat_prev:handle).
        &ENDIF
        
        create tt-epc.
        assign tt-epc.cod-event     = "Integra-serie":U
               tt-epc.cod-parameter = "handle_tt_integr_acr_item_lote_impl":U.
        &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
            ASSIGN tt-epc.val-parameter = string(temp-table tt_integr_acr_item_lote_impl:handle).
        &ENDIF

        create tt-epc.
        assign tt-epc.cod-event     = "Integra-serie":U
               tt-epc.cod-parameter = "handle_tt_integr_acr_item_lote_impl_1":U.
        &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
            ASSIGN tt-epc.val-parameter = string(temp-table tt_integr_acr_item_lote_impl_1:handle).
        &ENDIF
        
        create tt-epc.
        assign tt-epc.cod-event     = "Integra-serie":U
               tt-epc.cod-parameter = "handle_tt_integr_acr_relacto_pend":U.
        &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
            ASSIGN tt-epc.val-parameter = string(temp-table tt_integr_acr_relacto_pend:handle).
        &ENDIF
        
        IF AVAILABLE tt_integr_acr_item_lote_impl_8 THEN
        DO:
            create tt-epc.
            assign tt-epc.cod-event     = "Integra-serie":U
                   tt-epc.cod-parameter = "handle_tt_integr_acr_item_lote_impl_8":U.
            &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
                ASSIGN tt-epc.val-parameter = string(temp-table tt_integr_acr_item_lote_impl_8:handle).
            &ENDIF
        END.
        
        {include/i-epc201.i "Integra-serie"}

        for each tt-epc
            where tt-epc.cod-event = "Integra-serie":U:
            delete tt-epc.
        end.

    END.

    /********************************************************/
    /** DATASUL LATINA - CHAMADA EPC Integra-serie         **/
    /** FIN                                                **/
    /********************************************************/
    
    /********************************************************/
    /** CHAMADA API PARA TROCAR A MOEDA DO TÖTULO          **/
    /** MàDULO DE GRÇOS                                    **/
    /********************************************************/
    IF CONNECTED("EMSGRA") THEN DO:
        IF NOT VALID-HANDLE(h-ggapi106) THEN
           RUN ggp/ggapi106.p PERSISTENT SET h-ggapi106.

        IF VALID-HANDLE(h-ggapi106) THEN DO:

            RUN piVerificaModulFuncao IN h-ggapi106 (OUTPUT pl-modulo,
                                                     OUTPUT pl-funcao).

            IF pl-modulo THEN DO:
                RUN ggp/ggapi113.p (INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl_8,
                                    INPUT-OUTPUT TABLE tt_integr_acr_lote_impl,
                                    INPUT-OUTPUT TABLE tt_params_generic_api,
                                    INPUT-OUTPUT TABLE tt_integr_acr_repres_comis_2).
            END.

            DELETE PROCEDURE h-ggapi106.
            ASSIGN h-ggapi106 = ?.
        END.
    END.
    /********************************************************/
    /** CHAMADA API PARA TROCAR A MOEDA DO TÖTULO          **/
    /** MàDULO DE GRÇOS                                    **/
    /********************************************************/

    /*Projeto 90 - Gestao Caixas HIS x EMS*/
    RUN prgfin/acr/acr532za.py PERSISTENT SET v_hdl_api_integr_acr.
    RUN pi_main_code_cx_financ_integr_fat IN v_hdl_api_integr_acr(INPUT 11,
                                                                  INPUT v_cod_matriz_trad_org_ext,
                                                                  INPUT YES,
                                                                  INPUT NO,
                                                                  INPUT TABLE tt_integr_acr_repres_comis_2,
                                                                  INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl_8,
                                                                  INPUT TABLE tt_integr_acr_aprop_relacto_2,
                                                                  INPUT-OUTPUT TABLE tt_params_generic_api,
                                                                  INPUT TABLE tt_integr_acr_relacto_pend_aux,
                                                                  INPUT TABLE tt_integr_acr_lote_impl_cx).

    /*RUN prgfin/acr/acr900zi.py persistent set v_hdl_api_integr_acr.
    RUN pi_main_code_integr_acr_new_10 IN v_hdl_api_integr_acr (INPUT 11,
                                                                INPUT v_cod_matriz_trad_org_ext,
                                                                INPUT YES,
                                                                INPUT NO,
                                                                INPUT TABLE tt_integr_acr_repres_comis_2,
                                                                INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl_8,
                                                                INPUT TABLE tt_integr_acr_aprop_relacto_2,
                                                                INPUT-OUTPUT TABLE tt_params_generic_api).*/
    DELETE PROCEDURE v_hdl_api_integr_acr.
    

    if  c-nom-prog-dpc-mg97  <> ""
        or  c-nom-prog-appc-mg97 <> "" 
        or  c-nom-prog-upc-mg97  <> ""  then do:
        
        for each tt-epc 
            where tt-epc.cod-event = "Atualiz-ACR-EMS-5":
            delete tt-epc.
        end.
        {include/i-epc201.i "Atualiz-ACR-EMS-5"}
        /* Sem tratamento de retorno */
    END.

    {utp/ut-liter.i Continuando_Integra‡Æo_EMS5 *}
    run pi-acompanhar in h-acomp (input  RETURN-VALUE ).    


END.


RUN prgfin/acr/acr900zi.py persistent set v_hdl_api_integr_acr.

/*** Valida‡Æo de previsÆo de remito sem saldo no ACR ***/
for each tt-doc-i-cr:

    FIND FIRST tt_log_erros_atualiz 
        WHERE tt_log_erros_atualiz.ttv_num_mensagem = 860 
          AND tt_log_erros_atualiz.tta_cod_refer = tt-doc-i-cr.referencia EXCLUSIVE-LOCK NO-ERROR.


    IF AVAIL tt_log_erros_atualiz then do:

        find tt_integr_acr_item_lote_impl_8
            where tt_integr_acr_item_lote_impl_8.tta_cod_refer = tt-doc-i-cr.referencia NO-ERROR.

        if can-find(FIRST tt_integr_acr_abat_prev
                    where tt_integr_acr_abat_prev.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr) THEN DO:

            FOR EACH tt_integr_acr_abat_prev 
                WHERE tt_integr_acr_abat_prev.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr:
                DELETE tt_integr_acr_abat_prev.
            END.


            
            create tt-retorno-nota-fiscal.
            assign tt-retorno-nota-fiscal.tipo       = 2
                   tt-retorno-nota-fiscal.situacao   = YES
                   tt-retorno-nota-fiscal.cod-erro   = string(tt_log_erros_atualiz.ttv_num_mensagem)
                   tt-retorno-nota-fiscal.desc-erro  = tt_log_erros_atualiz.ttv_des_msg_erro 
                                                       + chr(13) + " Ajuda:" /*l_ajuda:*/ 
                                                       + tt_log_erros_atualiz.ttv_des_msg_ajuda
                   tt-retorno-nota-fiscal.referencia = string(tt_log_erros_atualiz.tta_cod_refer)
                   /*tt-retorno-nota-fiscal.cod-chave  = tt-retorno-nota-fiscal.referencia + ",,":U + 
                                                       string(i-empresa) + ",":U + nota-fiscal.cod-estabel + 
                                                       ",":U + "":U + ",":U + nota-fiscal.serie + ",":U +
                                                       if nota-fiscal.nr-fatura = "":U then nota-fiscal.nr-nota-fis 
                                                       else nota-fiscal.nr-fatura + ",":U.*/
                   tt-retorno-nota-fiscal.cod-chave  = tt-retorno-nota-fiscal.referencia + ",,":U + 
                                                       string(i-empresa) + ",":U + tt-doc-i-cr.cod-estabel + 
                                                       ",":U + "" + ",":U + tt-doc-i-cr.serie + ",":U.
            FOR EACH tt_log_erros_atualiz 
                WHERE tt_log_erros_atualiz.ttv_num_mensagem = 860 
                  AND tt_log_erros_atualiz.tta_cod_refer = tt-doc-i-cr.referencia EXCLUSIVE-LOCK:
                DELETE tt_log_erros_atualiz.
            END.

            FOR EACH tt-lin-i-cr
                where tt-lin-i-cr.referencia = tt-doc-i-cr.referencia:

                &if defined(bf_dis_unid_neg) &then 
                    if can-find(first para-dis where para-dis.log-unid-neg = yes) then do:
                        for first nota-fiscal 
                            fields(cod-emitente nat-operacao cod-estabel serie nr-nota-fis nr-pedcli
                                   nome-ab-cli ind-tip-nota nro-nota-orig serie-orig ind-sit-nota
                                   nr-fatura vl-tot-nota vl-tot-ipi nr-proc-exp cod-canal-venda
                                   dt-emis-nota emite-duplic ind-sit-nota)
                            where nota-fiscal.cod-estabel = tt-lin-i-cr.cod-estabel
                              and nota-fiscal.serie       = tt-lin-i-cr.serie
                              and nota-fiscal.nr-nota-fis = tt-lin-i-cr.nr-docto-vincul no-lock:
                        end.
                        find emitente of nota-fiscal no-lock no-error.        
                    end.
                &endif

                RUN pi-cria-aprop-contab.
            END.

            IF CAN-FIND(funcao WHERE funcao.ativo 
                               AND   funcao.cd-funcao = "spp-fn-log-ems5":U)  /* ativar com o programa cd7070 */
            THEN RUN pi-gera-log-ems5.

            RUN pi_main_code_integr_acr_new_10 IN v_hdl_api_integr_acr (INPUT 11,
                                                                        INPUT v_cod_matriz_trad_org_ext,
                                                                        input yes,
                                                                        input no,
                                                                        INPUT TABLE tt_integr_acr_repres_comis_2,
                                                                        INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl_8,
                                                                        INPUT TABLE tt_integr_acr_aprop_relacto_2,
                                                                        INPUT-OUTPUT TABLE tt_params_generic_api).
            
        END.
    end.
END. /*** Valida‡Æo de previsÆo de remito sem saldo no ACR ***/


IF  i-pais-impto-usuario = 2 /* Argentina */ THEN DO:
    IF  NOT VALID-HANDLE(h-arg0037) THEN
        RUN local/arg/arg0037.p PERSISTENT SET h-arg0037.

    RUN apos-integracao IN h-arg0037 (INPUT TEMP-TABLE tt-doc-i-cr:HANDLE,
                                      INPUT TEMP-TABLE tt-lin-i-cr:HANDLE,
                                      INPUT TEMP-TABLE tt_integr_acr_lote_impl:HANDLE,
                                      INPUT TEMP-TABLE tt_integr_acr_item_lote_impl:HANDLE).
    DELETE PROCEDURE h-arg0037.
END.

/********************************************************/
/** DATASUL LATINA - CHAMADA EPC Apos-integracao       **/
/** INICIO                                             **/
/********************************************************/

for each tt-epc where tt-epc.cod-event = "apos-integracao":
    delete tt-epc.
end.

FIND FIRST tt-doc-i-cr NO-LOCK NO-ERROR.
IF AVAILABLE tt-doc-i-cr THEN
DO:
    create tt-epc.
    assign tt-epc.cod-event     = "apos-integracao":U
           tt-epc.cod-parameter = "handle_tt-doc-i-cr":U.
    &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
        ASSIGN tt-epc.val-parameter = string(temp-table tt-doc-i-cr:handle).
    &ENDIF
END.
FIND FIRST tt-lin-i-cr NO-LOCK NO-ERROR.
IF AVAILABLE tt-lin-i-cr THEN
DO:
    create tt-epc.
    assign tt-epc.cod-event     = "apos-integracao":U
           tt-epc.cod-parameter = "handle_tt-lin-i-cr":U.
    &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
        ASSIGN tt-epc.val-parameter = string(temp-table tt-lin-i-cr:handle).
    &ENDIF
END.

FIND FIRST tt_integr_acr_lote_impl NO-LOCK NO-ERROR.
IF AVAILABLE tt_integr_acr_lote_impl THEN
DO:
    create tt-epc.
    assign tt-epc.cod-event     = "apos-integracao":U
           tt-epc.cod-parameter = "handle_tt_integr_acr_lote_impl":U.
    &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
        ASSIGN tt-epc.val-parameter = string(temp-table tt_integr_acr_lote_impl:handle).
    &ENDIF
END.

FIND FIRST tt_integr_acr_item_lote_impl NO-LOCK NO-ERROR.
IF AVAILABLE tt_integr_acr_item_lote_impl THEN
DO:
    create tt-epc.
    assign tt-epc.cod-event     = "apos-integracao":U
           tt-epc.cod-parameter = "handle_tt_integr_acr_item_lote_impl":U.
    &IF INTEGER(ENTRY(1,PROVERSION,'.')) >= 9 &THEN
        ASSIGN tt-epc.val-parameter = string(temp-table tt_integr_acr_item_lote_impl:handle).
    &ENDIF
END.

{include/i-epc201.i "apos-integracao"}                

/********************************************************/
/** DATASUL LATINA - CHAMADA EPC Apos-integracao       **/
/** FIN                                                **/
/********************************************************/
DELETE PROCEDURE v_hdl_api_integr_acr.


RUN pi-geracao-erros.

if valid-handle(h-cd9500) then
    delete widget h-cd9500.


run pi-finalizar in h-acomp.

return "OK":U.

PROCEDURE pi-busca-conta-receita:

    find first fat-duplic
    where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
      and fat-duplic.serie       = nota-fiscal.serie
      and fat-duplic.nr-fatura   = nota-fiscal.nr-fatura no-lock no-error.

    assign l-indicador = yes.        

    for each sumar-ft
        where sumar-ft.cod-estabel = nota-fiscal.cod-estabel
        and sumar-ft.serie       = nota-fiscal.serie
        and sumar-ft.nr-nota-fis = nota-fiscal.nr-nota-fis EXCLUSIVE-LOCK:
        DELETE sumar-ft.
    END.
               
    {ftp/ft0717.i}

    RUN pi-retorno-ft0717.
END.

PROCEDURE pi-ft0717i1 :
    {ftp/ft0717.i1}    
END PROCEDURE.

PROCEDURE pi-retorno-ft0717:

    DEF VAR de-perc-agreg LIKE de-perc NO-UNDO.

    FIND FIRST sumar-ft
        WHERE sumar-ft.nr-nota-fis = nota-fiscal.nr-nota-fis NO-LOCK NO-ERROR.

    IF l-erro THEN DO:
        FIND FIRST tt-auxiliar NO-LOCK NO-ERROR.
        IF AVAIL tt-auxiliar THEN DO:
            CASE tt-auxiliar.tipo:
                WHEN 1 THEN DO:
                    
                    create tt-retorno-nota-fiscal.
                    {utp/ut-liter.i Contas_para_Faturamento_nÆo_cadastradas * R}
                    assign tt-retorno-nota-fiscal.tipo       = 1
                           tt-retorno-nota-fiscal.cod-erro   = "0000"
                           tt-retorno-nota-fiscal.desc-erro  = return-value
                           tt-retorno-nota-fiscal.situacao   = NO
                           tt-retorno-nota-fiscal.referencia = tt-doc-i-cr.referencia
                           tt-retorno-nota-fiscal.cod-chave  = "":U + ",," +
                                                               string(i-empresa) + "," +
                                                               nota-fiscal.cod-estabel + ",," +
                                                               nota-fiscal.serie + "," +
                                                               if nota-fiscal.nr-fatura = "":U then
                                                                  nota-fiscal.nr-nota-fis 
                                                               else 
                                                                  nota-fiscal.nr-fatura + ",".
                END.
                WHEN 2 THEN DO:
                    
                    create tt-retorno-nota-fiscal.
                    {utp/ut-liter.i Contas_de_Saldo_Gr_Cliente_nÆo_cadastradas * R}
                    assign tt-retorno-nota-fiscal.tipo       = 1
                           tt-retorno-nota-fiscal.cod-erro   = "0000"
                           tt-retorno-nota-fiscal.desc-erro  = return-value
                           tt-retorno-nota-fiscal.situacao   = NO
                           tt-retorno-nota-fiscal.referencia = tt-doc-i-cr.referencia
                           tt-retorno-nota-fiscal.cod-chave  = "":U + ",," +
                                                               string(i-empresa) + "," +
                                                               nota-fiscal.cod-estabel + ",," +
                                                               nota-fiscal.serie + "," +
                                                               if nota-fiscal.nr-fatura = "":U then
                                                                  nota-fiscal.nr-nota-fis 
                                                               else 
                                                                  nota-fiscal.nr-fatura + ",".
                END.
                WHEN 3 THEN DO:
                    
                    create tt-retorno-nota-fiscal.
                    {utp/ut-liter.i Esp‚cie_de_T¡tulo_nÆo_contabiliza * R}
                    assign tt-retorno-nota-fiscal.tipo       = 1
                           tt-retorno-nota-fiscal.cod-erro   = "0000"
                           tt-retorno-nota-fiscal.desc-erro  = return-value
                           tt-retorno-nota-fiscal.situacao   = NO
                           tt-retorno-nota-fiscal.referencia = tt-doc-i-cr.referencia
                           tt-retorno-nota-fiscal.cod-chave  = "":U + ",," +
                                                               string(i-empresa) + "," +
                                                               nota-fiscal.cod-estabel + ",," +
                                                               nota-fiscal.serie + "," +
                                                               if nota-fiscal.nr-fatura = "":U then
                                                                  nota-fiscal.nr-nota-fis 
                                                               else 
                                                                  nota-fiscal.nr-fatura + ",".
                END.

            END CASE.
            FOR EACH tt-auxiliar EXCLUSIVE-LOCK:
                DELETE tt-auxiliar VALIDATE(TRUE,"":U).
            END.
        END.
        RETURN "NOK":U.
    END.
    ELSE DO:

        /********* colocado buffer pq passou a chamar dentro de um for each tt-lin-i-cr ****/

        assign i-cont = 1.

        for each b-tt-lin-i-cr where b-tt-lin-i-cr.referencia = tt-doc-i-cr.referencia:

            assign de-perc = IF  l-america-latina
                             THEN (b-tt-lin-i-cr.vl-base-calc-ret * 100) / (nota-fiscal.vl-mercad + 
                                                                            nota-fiscal.vl-frete  + 
                                                                            nota-fiscal.vl-seguro + 
                                                                            nota-fiscal.vl-embalagem)
                             ELSE (b-tt-lin-i-cr.vl-bruto * 100)/ nota-fiscal.vl-tot-nota
                   de-tot-conta-pend = 0
                   de-tot-imposto-conta-pend = 0.
      
            /* quando for nota de cr‚dito sem nota vinculada, o valor deve ser nota + impostos agregados */
            IF   l-america-latina
            AND  nota-fiscal.ind-tip-nota = 10 
            AND  nota-fiscal.nro-nota-orig = "":U THEN 
                 RUN pi-calcula-impostos-relacto(INPUT b-tt-lin-i-cr.ep-codigo,
                                                 INPUT b-tt-lin-i-cr.cod-estabel,
                                                 INPUT b-tt-lin-i-cr.cod-esp,
                                                 INPUT b-tt-lin-i-cr.nr-docto,
                                                 INPUT b-tt-lin-i-cr.parcela,
                                                 OUTPUT de-vl-tot-agregados).
                  
            for each sumar-ft NO-LOCK
                where sumar-ft.cod-estabel = nota-fiscal.cod-estabel
                and sumar-ft.serie       = nota-fiscal.serie
                and sumar-ft.nr-nota-fis = nota-fiscal.nr-nota-fis  
                AND (    (     nota-fiscal.ind-tip-nota <> 10 
                           AND sumar-ft.vl-contab > 0 )  /* Para notas fiscais normais o lancamento na conta de saldo de clientes e negativo */
                      OR (     nota-fiscal.ind-tip-nota = 10 
                           AND sumar-ft.vl-contab < 0) ) /* Para notas de credito o lancamento nas contas de receita, impostos, e despesas ‚ negativo */
                BREAK BY sumar-ft.vl-contab DESCENDING:

                IF  de-vl-tot-agregados > 0 THEN
                    ASSIGN de-perc-agreg = round((ABS(sumar-ft.vl-contab) * (de-perc / 100)),2) / b-tt-lin-i-cr.vl-base-calc-ret.


                FIND FIRST tt-conta-pend-parcela
                     WHERE tt-conta-pend-parcela.nr-seq         = i-cont
                       AND tt-conta-pend-parcela.ct-codigo      = substring(sumar-ft.ct-conta,1,LENGTH(param-global.ct-format))                                 
                       AND tt-conta-pend-parcela.sc-codigo      = substring(sumar-ft.ct-conta,length(param-global.ct-format) + 1,LENGTH(param-global.sc-format))
                       AND tt-conta-pend-parcela.parcela        = b-tt-lin-i-cr.parcela                                                                         
                       AND tt-conta-pend-parcela.cod-unid-negoc = sumar-ft.cod-unid-negoc 
                       EXCLUSIVE-LOCK NO-ERROR.
                IF NOT AVAIL tt-conta-pend-parcela THEN DO:
                    create tt-conta-pend-parcela.
                    assign tt-conta-pend-parcela.nr-seq         = i-cont
                           tt-conta-pend-parcela.ct-codigo      = substring(sumar-ft.ct-conta,1,LENGTH(param-global.ct-format))
                           tt-conta-pend-parcela.sc-codigo      = substring(sumar-ft.ct-conta,length(param-global.ct-format) + 1,LENGTH(param-global.sc-format))
                           tt-conta-pend-parcela.parcela        = b-tt-lin-i-cr.parcela
                           tt-conta-pend-parcela.cod-unid-negoc = sumar-ft.cod-unid-negoc .
                END.


                IF NOT LAST(sumar-ft.vl-contab) THEN DO:
                    ASSIGN de-valor-contabil           = IF nota-fiscal.ind-tip-nota = 10 
                                                         THEN sumar-ft.vl-contab * -1
                                                         ELSE sumar-ft.vl-contab
                           tt-conta-pend-parcela.valor = tt-conta-pend-parcela.valor + round((de-valor-contabil * (de-perc / 100)),2)
                           de-vl-tot-agregados-prop    = round(de-vl-tot-agregados * de-perc-agreg ,2)
                           de-tot-conta-pend           = de-tot-conta-pend + tt-conta-pend-parcela.valor + de-vl-tot-agregados-prop
                           tt-conta-pend-parcela.valor = tt-conta-pend-parcela.valor + de-vl-tot-agregados-prop  .
                END.
                ELSE 
                    ASSIGN tt-conta-pend-parcela.valor    = tt-conta-pend-parcela.valor +
                                                            IF   l-america-latina 
                                                            THEN ( b-tt-lin-i-cr.vl-base-calc-ret +  de-vl-tot-agregados) - de-tot-conta-pend
                                                            ELSE b-tt-lin-i-cr.vl-bruto         - de-tot-conta-pend.

	        end.
            assign i-cont = i-cont + 1.
	    end.
    END.
END.

Procedure pi-cria-sumar-ft:

    def input param c-conta       as char no-undo.
    def input param c-ccusto      as char no-undo.
    def input param de-valor      as dec  no-undo.
    def input param i-cod-imposto as int  no-undo.

    DEF VAR c-cod-unid-negoc AS CHAR NO-UNDO.

    ASSIGN c-cod-unid-negoc = IF  AVAIL it-nota-fisc THEN it-nota-fisc.cod-unid-negoc ELSE "".

    {ftp/ft0717.i2 c-conta de-valor i-cod-imposto c-ccusto c-cod-unid-negoc}

end procedure.

procedure pi-busca-conta-transitoria:

    create tt-conta-pend-parcela.
    assign tt-conta-pend-parcela.nr-seq    = 1
           tt-conta-pend-parcela.parcela   = tt-lin-i-cr.parcela
           tt-conta-pend-parcela.ct-codigo = string(tt-lin-i-cr.ct-conta) 
           tt-conta-pend-parcela.sc-codigo = string(tt-lin-i-cr.sc-conta)
           tt-conta-pend-parcela.valor     = IF string(tt-lin-i-cr.mo-codigo) <> "0":U 
                                             THEN tt-lin-i-cr.vl-bruto-me
                                             ELSE tt-lin-i-cr.vl-bruto.

    IF   l-america-latina THEN DO:
          /* quando for nota de cr‚dito sem nota vinculada, o valor deve ser nota + impostos agregados */
          IF  nota-fiscal.ind-tip-nota = 10 
          AND nota-fiscal.nro-nota-orig = "":U THEN DO:

              RUN pi-calcula-impostos-relacto(INPUT tt-lin-i-cr.ep-codigo,
                                              INPUT tt-lin-i-cr.cod-estabel,
                                              INPUT tt-lin-i-cr.cod-esp,
                                              INPUT tt-lin-i-cr.nr-docto,
                                              INPUT tt-lin-i-cr.parcela,
                                              OUTPUT de-vl-tot-agregados).
               
              ASSIGN tt-conta-pend-parcela.valor = tt-lin-i-cr.vl-base-calc-ret + de-vl-tot-agregados.
          END.
          ELSE           
              ASSIGN tt-conta-pend-parcela.valor = tt-lin-i-cr.vl-base-calc-ret. /* valor da mercadoria sem impostos */
     END.
end.

procedure pi-geracao-erros:

    FOR EACH tt_log_erros_atualiz
        WHERE tt_log_erros_atualiz.ttv_num_mensagem = 11953:
        find first tt-lin-i-cr where tt-lin-i-cr.referencia = tt_log_erros_atualiz.tta_cod_refer no-lock no-error.
        for first nota-fiscal fields (cod-estabel serie nr-nota-fis nr-fatura ind-sit-nota)
            where nota-fiscal.cod-estabel = tt-lin-i-cr.cod-estabel
              and nota-fiscal.serie       = tt-lin-i-cr.serie
              and nota-fiscal.nr-nota-fis = tt-lin-i-cr.nr-docto-vincul no-lock:
            
            create tt-retorno-nota-fiscal.
            assign tt-retorno-nota-fiscal.tipo       = 2
                   tt-retorno-nota-fiscal.situacao   = YES
                   tt-retorno-nota-fiscal.cod-erro   = string(tt_log_erros_atualiz.ttv_num_mensagem)
                   tt-retorno-nota-fiscal.desc-erro  = tt_log_erros_atualiz.ttv_des_msg_erro 
                                                       + chr(13) + " Ajuda:"  
                                                       + tt_log_erros_atualiz.ttv_des_msg_ajuda
                   tt-retorno-nota-fiscal.referencia = string(tt_log_erros_atualiz.tta_cod_refer)
                   tt-retorno-nota-fiscal.cod-chave  = tt-retorno-nota-fiscal.referencia + ",,":U + 
                                                       string(i-empresa) + ",":U + nota-fiscal.cod-estabel + ",":U +
                                                       "" + ",":U + nota-fiscal.serie + ",":U +
                                                       if nota-fiscal.nr-fatura = "" then nota-fiscal.nr-nota-fis 
                                                       else nota-fiscal.nr-fatura + ",":U.
        end.
        DELETE tt_log_erros_atualiz.
    END.
    for each tt_log_erros_atualiz:
        find first tt-lin-i-cr where tt-lin-i-cr.referencia = tt_log_erros_atualiz.tta_cod_refer no-lock no-error.
        for first nota-fiscal fields (cod-estabel serie nr-nota-fis nr-fatura ind-sit-nota)
            where nota-fiscal.cod-estabel = tt-lin-i-cr.cod-estabel
              and nota-fiscal.serie       = tt-lin-i-cr.serie
              and nota-fiscal.nr-nota-fis = tt-lin-i-cr.nr-docto-vincul no-lock:
        end.
        
        create tt-retorno-nota-fiscal.
        assign tt-retorno-nota-fiscal.tipo       = 2
               tt-retorno-nota-fiscal.situacao   = NO
               tt-retorno-nota-fiscal.cod-erro   = string(tt_log_erros_atualiz.ttv_num_mensagem)
               tt-retorno-nota-fiscal.desc-erro  = tt_log_erros_atualiz.ttv_des_msg_erro 
                                                   + chr(13) + " Ajuda:" /*l_ajuda:*/ 
                                                   + tt_log_erros_atualiz.ttv_des_msg_ajuda
               tt-retorno-nota-fiscal.referencia = string(tt_log_erros_atualiz.tta_cod_refer)
               tt-retorno-nota-fiscal.cod-chave  = tt-retorno-nota-fiscal.referencia + ",,":U + 
                                                   string(i-empresa) + ",":U + nota-fiscal.cod-estabel + ",":U +
                                                   "":U + ",":U + nota-fiscal.serie + ",":U +
                                                   if nota-fiscal.nr-fatura = "":U then nota-fiscal.nr-nota-fis 
                                                   else nota-fiscal.nr-fatura + ",":U.


    end. 

    for each tt-doc-i-cr:
        if not can-find(tt-retorno-nota-fiscal 
                        where tt-retorno-nota-fiscal.referencia = tt-doc-i-cr.referencia
                          AND tt-retorno-nota-fiscal.situacao = NO)
        and not can-find(tt-retorno-nota-fiscal 
                         where tt-retorno-nota-fiscal.referencia = tt-doc-i-cr.referencia
                           AND tt-retorno-nota-fiscal.situacao = yes) then do:
            
            create tt-retorno-nota-fiscal.
            assign tt-retorno-nota-fiscal.situacao = yes
                   tt-retorno-nota-fiscal.referencia = tt-doc-i-cr.referencia
                   tt-retorno-nota-fiscal.tipo       = 1
                   tt-retorno-nota-fiscal.cod-erro   = "EMS5_OK":U.
        end.
    end.

end.

procedure pi_rateio_unid_neg:

    def var c-numero-docto as char                      no-undo.
    DEF VAR de-vl-bruto    LIKE tt-lin-i-cr.vl-bruto-me NO-UNDO.
    
    DEFINE VARIABLE l-exec-tp-receita AS LOGICAL NO-UNDO.
    DEFINE VARIABLE c-cotac-ind-econ  AS CHAR    NO-UNDO.

   
   /* Se no campo tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr estiver gravado
       o numero do processo de exporta‡Æo c-numero-docto recebe o numero da fatura
       seNÆo recebe o pr¢prio */
    assign c-numero-docto = if  (   nota-fiscal.ind-tip-nota = 1
                                 or nota-fiscal.ind-tip-nota = 4
                                 or nota-fiscal.ind-tip-nota = 3)
                            and (   emitente.natureza          = 3
                                 or emitente.natureza          = 4)
                            and nota-fiscal.nr-proc-exp > "0"
                            and para-fat.ind-docum-fatura  = 2
                            then nota-fiscal.nr-fatura
                            else tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr.

    for each tt-unid-aux:
        delete tt-unid-aux.
    end.

    for first rateio-it-duplic fields ( )
         WHERE rateio-it-duplic.cod-estabel = tt_integr_acr_lote_impl.tta_cod_estab_ext
           AND rateio-it-duplic.serie       = tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto
           AND rateio-it-duplic.nr-fatura   = c-numero-docto
           AND rateio-it-duplic.parcela     = tt_integr_acr_item_lote_impl_8.tta_cod_parcela
           NO-LOCK:
    end.

    IF  NOT AVAILABLE(rateio-it-duplic) then do:
        run utp/ut-msgs.p (input "msg",
                   input 27143,
                   input "":U).
        
        create tt-retorno-nota-fiscal.
        assign tt-retorno-nota-fiscal.tipo       = 2
               tt-retorno-nota-fiscal.situacao   = NO
               tt-retorno-nota-fiscal.cod-erro   = "27143":U
               tt-retorno-nota-fiscal.desc-erro  = return-value
               tt-retorno-nota-fiscal.referencia = string(tt-doc-i-cr.referencia)
               tt-retorno-nota-fiscal.cod-chave  = tt-doc-i-cr.referencia + ",,":U + 
                                                   string(i-empresa) + ",":U + nota-fiscal.cod-estabel + ",":U +
                                                   "":U + ",":U + nota-fiscal.serie + ",":U +
                                                   if nota-fiscal.nr-fatura = "":U then nota-fiscal.nr-nota-fis 
                                                   else nota-fiscal.nr-fatura + ",":U.
        RETURN "NOK".                                                   
    end.
    for each rateio-it-duplic fields (cod-estabel serie nr-seq-fat it-codigo valor nr-nota-fis) NO-LOCK
        WHERE rateio-it-duplic.cod-estabel = tt_integr_acr_lote_impl.tta_cod_estab_ext
          AND rateio-it-duplic.serie       = tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto
          AND rateio-it-duplic.nr-fatura   = tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr
          AND rateio-it-duplic.parcela     = tt_integr_acr_item_lote_impl_8.tta_cod_parcela:

        if can-find(funcao   /* Fechamento de Duplicatas por Pedido */
                    where funcao.cd-funcao = "spp-FechaDuplic"
                      and funcao.ativo       = yes) then do:

                FOR EACH b-nota-fiscal FIELDS (b-nota-fiscal.vl-tot-nota b-nota-fiscal.nr-nota-fis b-nota-fiscal.ind-sit-nota)
                   WHERE b-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel
                     and b-nota-fiscal.serie       = nota-fiscal.serie
                     and b-nota-fiscal.nr-fatura   = nota-fiscal.nr-fatura NO-LOCK:

                    IF CAN-FIND(it-nota-fisc 
                       WHERE it-nota-fisc.cod-estabel    = nota-fiscal.cod-estabel
                         AND it-nota-fisc.serie          = nota-fiscal.serie
                         AND it-nota-fisc.nr-nota-fis    = rateio-it-duplic.nr-nota-fis
                         AND it-nota-fisc.it-codigo      = rateio-it-duplic.it-codigo
                         AND it-nota-fisc.nr-seq-fat     = rateio-it-duplic.nr-seq-fat  
                         AND it-nota-fisc.cod-unid-negoc = "") then do:

                        run utp/ut-msgs.p (input "msg",
                                   input 25590,
                                   input "":U).
                        
                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo       = 2
                               tt-retorno-nota-fiscal.situacao   = NO
                               tt-retorno-nota-fiscal.cod-erro   = "25590":U
                               tt-retorno-nota-fiscal.desc-erro  = return-value
                               tt-retorno-nota-fiscal.referencia = string(tt-doc-i-cr.referencia)
                               tt-retorno-nota-fiscal.cod-chave  = tt-doc-i-cr.referencia + ",,":U + 
                                                                   string(i-empresa) + ",":U + nota-fiscal.cod-estabel + ",":U +
                                                                   "":U + ",":U + nota-fiscal.serie + ",":U +
                                                                   if nota-fiscal.nr-fatura = "":U then b-nota-fiscal.nr-nota-fis 
                                                                   else nota-fiscal.nr-fatura + ",":U.
                        return "NOK".
                    end.                          
                END.
        end.
        ELSE IF CAN-FIND( FIRST it-nota-fisc 
                          WHERE it-nota-fisc.cod-estabel    = nota-fiscal.cod-estabel
                            AND it-nota-fisc.serie          = nota-fiscal.serie
                            AND it-nota-fisc.nr-nota-fis    = rateio-it-duplic.nr-nota-fis
                            AND it-nota-fisc.it-codigo      = rateio-it-duplic.it-codigo
                            AND it-nota-fisc.nr-seq-fat     = rateio-it-duplic.nr-seq-fat  
                            AND it-nota-fisc.cod-unid-negoc = "" ) THEN DO:           
            run utp/ut-msgs.p (input "msg",
                       input 25590,
                       input "":U).
            
            create tt-retorno-nota-fiscal.
            assign tt-retorno-nota-fiscal.tipo       = 2
                   tt-retorno-nota-fiscal.situacao   = NO
                   tt-retorno-nota-fiscal.cod-erro   = "25590":U
                   tt-retorno-nota-fiscal.desc-erro  = return-value
                   tt-retorno-nota-fiscal.referencia = string(tt-doc-i-cr.referencia)
                   tt-retorno-nota-fiscal.cod-chave  = tt-doc-i-cr.referencia + ",,":U + 
                                                       string(i-empresa) + ",":U + nota-fiscal.cod-estabel + ",":U +
                                                       "":U + ",":U + nota-fiscal.serie + ",":U +
                                                       if nota-fiscal.nr-fatura = "":U then nota-fiscal.nr-nota-fis 
                                                       else nota-fiscal.nr-fatura + ",":U.
            return "NOK".
        end. 

    END.
    assign de-cotacao            = 0
           de-vl-aux             = 0
           de-tot-acum           = 0
           de-tot-parcela-forte  = 0
           de-tot-parcela-padrao = 0.

    IF  tt-lin-i-cr.mo-codigo <> 0 THEN
        ASSIGN de-vl-bruto = tt-lin-i-cr.vl-bruto-me
               de-vl-aprop = de-vl-base-calc-ret-me.
    ELSE
        ASSIGN de-vl-bruto = tt-lin-i-cr.vl-bruto
               de-vl-aprop = tt-lin-i-cr.vl-base-calc-ret.

    if can-find(funcao   /* Fechamento de Duplicatas por Pedido */
                where funcao.cd-funcao = "spp-FechaDuplic"
                  and funcao.ativo       = yes) THEN DO:

        /*FOR EACH b-nota-fiscal FIELDS (b-nota-fiscal.vl-tot-nota b-nota-fiscal.nr-nota-fis b-nota-fiscal.ind-sit-nota)
           WHERE b-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel
             and b-nota-fiscal.serie       = nota-fiscal.serie
             and b-nota-fiscal.nr-fatura   = nota-fiscal.nr-fatura NO-LOCK:*/

            FOR EACH rateio-it-duplic fields (cod-estabel serie nr-seq-fat it-codigo valor nr-nota-fis) NO-LOCK
                WHERE rateio-it-duplic.cod-estabel = tt_integr_acr_lote_impl.tta_cod_estab_ext
                  AND rateio-it-duplic.serie       = tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto
                  AND rateio-it-duplic.nr-fatura   = c-numero-docto
                  AND rateio-it-duplic.parcela     = tt_integr_acr_item_lote_impl_8.tta_cod_parcela,
                FIRST it-nota-fisc FIELDS(cod-unid-negoc)
                WHERE it-nota-fisc.cod-estabel = rateio-it-duplic.cod-estabel
                AND   it-nota-fisc.serie       = rateio-it-duplic.serie
                AND   it-nota-fisc.nr-nota-fis = rateio-it-duplic.nr-nota-fis
                AND   it-nota-fisc.nr-seq-fat  = rateio-it-duplic.nr-seq-fat
                AND   it-nota-fisc.it-codigo   = rateio-it-duplic.it-codigo NO-LOCK
                break by rateio-it-duplic.nr-seq-fat:

                IF  tt-conta-pend-parcela.cod-unid-negoc = "" THEN
                    FIND tt-unid-aux WHERE
                         tt-unid-aux.cod_unid_negoc = it-nota-fisc.cod-unid-negoc NO-ERROR.
                ELSE
                    FIND tt-unid-aux WHERE
                         tt-unid-aux.cod_unid_negoc = tt-conta-pend-parcela.cod-unid-negoc NO-ERROR.

                IF  NOT AVAILABLE(tt-unid-aux) THEN DO:
                    CREATE tt-unid-aux.
                    ASSIGN tt-unid-aux.cod_unid_negoc = IF  tt-conta-pend-parcela.cod-unid-negoc = "" 
                                                            THEN it-nota-fisc.cod-unid-negoc
                                                            ELSE tt-conta-pend-parcela.cod-unid-negoc.
                END.

                assign de-cotacao            = 1 / tt_integr_acr_item_lote_impl_8.tta_val_cotac_indic_econ
                       de-vl-aux             = IF NOT l-america-latina  /* america latina calcula pelo liquido */
                                               THEN rateio-it-duplic.valor-rateio * tt-conta-pend-parcela.valor / de-vl-bruto
                                               ELSE rateio-it-duplic.dec-1 * tt-conta-pend-parcela.valor / tt-lin-i-cr.vl-base-calc-ret.

                assign tt-unid-aux.valor     = tt-unid-aux.valor      + (de-vl-aux / de-cotacao)
                       de-tot-parcela-forte  = de-tot-parcela-forte   + (de-vl-aux / de-cotacao)
                       de-tot-parcela-padrao = de-tot-parcela-padrao  + de-vl-aux.

                if  last(rateio-it-duplic.nr-seq-fat) then
                    assign tt-unid-aux.valor = tt-unid-aux.valor + (de-tot-parcela-padrao / de-cotacao) - de-tot-parcela-forte.
            END.
       /* END.*/

    END.
    ELSE DO:
        FOR EACH rateio-it-duplic  NO-LOCK
            WHERE rateio-it-duplic.cod-estabel = tt_integr_acr_lote_impl.tta_cod_estab_ext
              AND rateio-it-duplic.serie       = tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto
              AND rateio-it-duplic.nr-fatura   = c-numero-docto
              AND rateio-it-duplic.parcela     = tt_integr_acr_item_lote_impl_8.tta_cod_parcel,
              FIRST it-nota-fisc 
              WHERE it-nota-fisc.cod-estabel = rateio-it-duplic.cod-estabel
              AND   it-nota-fisc.serie       = rateio-it-duplic.serie
              AND   it-nota-fisc.nr-nota-fis = rateio-it-duplic.nr-nota-fis
              AND   it-nota-fisc.nr-seq-fat  = rateio-it-duplic.nr-seq-fat
              AND   it-nota-fisc.it-codigo   = rateio-it-duplic.it-codigo  NO-LOCK
              BREAK BY rateio-it-duplic.nr-seq-fat:
    
              IF  tt-conta-pend-parcela.cod-unid-negoc = "" THEN
                  FIND tt-unid-aux WHERE
                       tt-unid-aux.cod_unid_negoc = it-nota-fisc.cod-unid-negoc NO-ERROR.
              ELSE
                  FIND tt-unid-aux WHERE
                       tt-unid-aux.cod_unid_negoc = tt-conta-pend-parcela.cod-unid-negoc NO-ERROR.

            IF  NOT AVAILABLE(tt-unid-aux) THEN DO:
                CREATE tt-unid-aux.
                ASSIGN tt-unid-aux.cod_unid_negoc = IF  tt-conta-pend-parcela.cod-unid-negoc = "" 
                                                        THEN it-nota-fisc.cod-unid-negoc
                                                        ELSE tt-conta-pend-parcela.cod-unid-negoc.
            END.
    
            IF  l-america-latina THEN
                ASSIGN de-cotacao            = IF  int(nota-fiscal.mo-codigo) <> 0  /* os valores pra base de apropricao j  estao convertidos */
                                               THEN 1
                                               ELSE 1 / tt_integr_acr_item_lote_impl_8.tta_val_cotac_indic_econ
                       de-vl-aux             = rateio-it-duplic.dec-1 * tt-conta-pend-parcela.valor / tt-lin-i-cr.vl-base-calc-ret.
            ELSE 
                assign de-cotacao            = 1 / tt_integr_acr_item_lote_impl_8.tta_val_cotac_indic_econ
                       de-vl-aux             = rateio-it-duplic.valor-rateio * tt-conta-pend-parcela.valor / de-vl-bruto.
                    
                   /* Valor rateado do rateio-it-duplic por unidade de neg¢cio para o item e parcela e lan‡amento contabil por parcela*/  
    
            assign tt-unid-aux.valor     = tt-unid-aux.valor      + (de-vl-aux / de-cotacao)
                   de-tot-acum           = de-tot-acum            + (de-vl-aux / de-cotacao)
                   de-tot-parcela-forte  = de-tot-parcela-forte   + (de-vl-aux / de-cotacao)
                   de-tot-parcela-padrao = de-tot-parcela-padrao  + de-vl-aux.
    
            if  last-of(rateio-it-duplic.nr-seq-fat)
            AND NOT para-fat.ind-pro-fat then
                assign de-vl-aux         = IF NOT l-america-latina  /* america latina calcula pelo liquido */
                                           THEN rateio-it-duplic.valor-rateio * tt-conta-pend-parcela.valor / de-vl-bruto
                                           ELSE rateio-it-duplic.dec-1 * tt-conta-pend-parcela.valor / tt-lin-i-cr.vl-base-calc-ret
                       tt-unid-aux.valor = tt-unid-aux.valor + (de-vl-aux / de-cotacao) - de-tot-acum
                       de-tot-acum       = 0.        
    
            if  last(rateio-it-duplic.nr-seq-fat) then
                assign tt-unid-aux.valor = tt-unid-aux.valor + (de-tot-parcela-padrao / de-cotacao) - de-tot-parcela-forte.
        END.
    END.

    /* ALTERA€ÇO PARA NOTAS DE CREDITO/DEBITO */
    if (tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "10" /*Nota de Cr‚dito*/
    or  tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto = "11" /*Nota de D‚bito*/) 
    and nota-fiscal.nro-nota-orig <> "" then do:

        /* Logica para integra‡Æo das notas de cr‚dito e d‚bito. */
        
        CREATE tt_integr_acr_aprop_relacto_au.
        BUFFER-COPY tt_integr_acr_aprop_relacto
                     EXCEPT tta_cod_unid_negoc
                            tta_val_aprop_ctbl
                     TO tt_integr_acr_aprop_relacto_au.
        DELETE tt_integr_acr_aprop_relacto.
    
        ASSIGN c-cotac-ind-econ = STRING(tt_integr_acr_item_lote_impl_8.tta_val_cotac_indic_econ).
    
        ASSIGN l-exec-tp-receita = NO.
    
        if  c-nom-prog-dpc-mg97  <> ""
            or  c-nom-prog-appc-mg97 <> "" 
            or  c-nom-prog-upc-mg97  <> ""  then do:
        
            FOR EACH tt-epc WHERE tt-epc.cod-event = "Processa_tipo_receita":
                DELETE tt-epc.
            END.
    
            
            CREATE tt-epc.
            ASSIGN tt-epc.cod-event     = "Processa_tipo_receita"
                   tt-epc.cod-parameter = "tipo_receita" 
                   tt-epc.val-parameter = STRING(tt_integr_acr_lote_impl.tta_cod_estab_ext,"x(3)") +
                                          STRING(tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto,"x(3)") +
                                          STRING(c-numero-docto,"x(16)") +
                                          STRING(tt_integr_acr_item_lote_impl_8.tta_cod_parcela,"x(2)") +
                                          STRING(nota-fiscal.nr-nota-fis,"x(16)") +
                                          STRING(c-cotac-ind-econ,"x(10)")  +                          
                                          STRING(TEMP-TABLE tt_integr_acr_aprop_ctbl_pend_au:HANDLE) +
                                          STRING(TEMP-TABLE tt_integr_acr_aprop_ctbl_pend:HANDLE).
    
            
            CREATE tt-epc.
            ASSIGN tt-epc.cod-event     = "Processa_tipo_receita"
                   tt-epc.cod-parameter = "entry_tipo_receita" 
                   tt-epc.val-parameter = STRING(tt_integr_acr_lote_impl.tta_cod_estab_ext,"x(3)") + "," +
                                          STRING(tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto,"x(3)") + "," +
                                          STRING(c-numero-docto,"x(16)") + "," +
                                          STRING(tt_integr_acr_item_lote_impl_8.tta_cod_parcela,"x(2)") + "," +
                                          STRING(nota-fiscal.nr-nota-fis,"x(16)") + "," +
                                          STRING(c-cotac-ind-econ,"x(10)")  + "," +
                                          STRING(TEMP-TABLE tt_integr_acr_aprop_ctbl_pend_au:HANDLE) + "," +
                                          STRING(TEMP-TABLE tt_integr_acr_aprop_ctbl_pend:HANDLE).
    
            {include/i-epc201.i "Processa_tipo_receita"}
            FIND FIRST tt-epc WHERE tt-epc.cod-event     = "Processa_tipo_receita"
                                AND tt-epc.cod-parameter = "ExecutouUpc" NO-LOCK NO-ERROR.
            IF AVAIL tt-epc THEN l-exec-tp-receita = IF tt-epc.val-parameter = "YES" THEN YES ELSE NO.
        
        END.
        IF NOT l-exec-tp-receita THEN DO:
            FOR EACH tt-unid-aux:
                CREATE tt_integr_acr_aprop_relacto.
                BUFFER-COPY tt_integr_acr_aprop_relacto_au
                EXCEPT tta_cod_unid_negoc tta_val_aprop_ctbl
                    TO tt_integr_acr_aprop_relacto.
        
                ASSIGN tt_integr_acr_aprop_relacto.tta_cod_unid_negoc = tt-unid-aux.cod_unid_negoc
                       tt_integr_acr_aprop_relacto.tta_val_aprop_ctbl = tt-unid-aux.valor.
        
                IF tt_integr_acr_aprop_relacto.tta_val_aprop_ctbl = 0 THEN DELETE tt_integr_acr_aprop_relacto.    
            END.
        END.
    END.
    ELSE DO:

        /* Logica para integra‡Æo das demais notas */

        EMPTY TEMP-TABLE tt_integr_acr_aprop_ctbl_pend_au.
        CREATE tt_integr_acr_aprop_ctbl_pend_au.
        BUFFER-COPY tt_integr_acr_aprop_ctbl_pend
                    TO tt_integr_acr_aprop_ctbl_pend_au.

        DELETE tt_integr_acr_aprop_ctbl_pend.
    
        ASSIGN c-cotac-ind-econ = STRING(tt_integr_acr_item_lote_impl_8.tta_val_cotac_indic_econ).
    
        ASSIGN l-exec-tp-receita = NO.
            
        if  c-nom-prog-dpc-mg97  <> ""
            or  c-nom-prog-appc-mg97 <> "" 
            or  c-nom-prog-upc-mg97  <> ""  then do:
        
            FOR EACH tt-epc WHERE tt-epc.cod-event = "Processa_tipo_receita":
                DELETE tt-epc.
            END.
    
            
            CREATE tt-epc.
            ASSIGN tt-epc.cod-event     = "Processa_tipo_receita"
                   tt-epc.cod-parameter = "tipo_receita" 
                   tt-epc.val-parameter = STRING(tt_integr_acr_lote_impl.tta_cod_estab_ext,"x(3)") +
                                          STRING(tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto,"x(3)") +
                                          STRING(c-numero-docto,"x(16)") +
                                          STRING(tt_integr_acr_item_lote_impl_8.tta_cod_parcela,"x(2)") +
                                          STRING(nota-fiscal.nr-nota-fis,"x(16)") +
                                          STRING(c-cotac-ind-econ,"x(10)")  +                          
                                          STRING(TEMP-TABLE tt_integr_acr_aprop_ctbl_pend_au:HANDLE) +
                                          STRING(TEMP-TABLE tt_integr_acr_aprop_ctbl_pend:HANDLE).
    
            CREATE tt-epc.
            ASSIGN tt-epc.cod-event     = "Processa_tipo_receita"
                   tt-epc.cod-parameter = "entry_tipo_receita" 
                   tt-epc.val-parameter = STRING(tt_integr_acr_lote_impl.tta_cod_estab_ext,"x(3)") + "," +
                                          STRING(tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto,"x(3)") + "," +
                                          STRING(c-numero-docto,"x(16)") + "," +
                                          STRING(tt_integr_acr_item_lote_impl_8.tta_cod_parcela,"x(2)") + "," +
                                          STRING(nota-fiscal.nr-nota-fis,"x(16)") + "," +
                                          STRING(c-cotac-ind-econ,"x(10)")  + "," +
                                          STRING(TEMP-TABLE tt_integr_acr_aprop_ctbl_pend_au:HANDLE) + "," +
                                          STRING(TEMP-TABLE tt_integr_acr_aprop_ctbl_pend:HANDLE).
    
            {include/i-epc201.i "Processa_tipo_receita"}
            FIND FIRST tt-epc WHERE tt-epc.cod-event     = "Processa_tipo_receita"
                                AND tt-epc.cod-parameter = "ExecutouUpc" NO-LOCK NO-ERROR.
            IF AVAIL tt-epc THEN l-exec-tp-receita = IF tt-epc.val-parameter = "YES" THEN YES ELSE NO.
        
        END.
        IF NOT l-exec-tp-receita THEN DO:
            FOR EACH tt-unid-aux:
                CREATE tt_integr_acr_aprop_ctbl_pend.
                BUFFER-COPY tt_integr_acr_aprop_ctbl_pend_au
                    TO tt_integr_acr_aprop_ctbl_pend.
        
                ASSIGN tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc = tt-unid-aux.cod_unid_negoc
                       tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl = tt-unid-aux.valor.
        
                IF tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl = 0 THEN DELETE tt_integr_acr_aprop_ctbl_pend.    
            END.
        END.
    END.
    delete tt-conta-pend-parcela.
end.

PROCEDURE pi-cria-aprop-contab:

    if i-pais-impto-usuario = 1 
    or (i-pais-impto-usuario <> 1 and para-fat.ind-transitoria = no) then
      run pi-busca-conta-transitoria.

    ASSIGN vl-tot-lote-aprop = 0.

    for each tt-conta-pend-parcela 
        where tt-conta-pend-parcela.parcela = tt-lin-i-cr.parcela: 

        ASSIGN vl-tot-lote-aprop = vl-tot-lote-aprop + tt-conta-pend-parcela.valor.

        IF  tt-conta-pend-parcela.valor > 0 THEN DO:
            CREATE tt_integr_acr_aprop_ctbl_pend. 
            ASSIGN  tt_integr_acr_aprop_ctbl_pend.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_fluxo_financ_ext       = STRING(tt-lin-i-cr.tp-codigo)
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto_ext             = "" 
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc_ext         = ""
                    tt_integr_acr_aprop_ctbl_pend.tta_log_impto_val_agreg        = NO
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_cta_ctbl         = ""
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_ccusto           = ""
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto                 = ""
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc             = tt-conta-pend-parcela.cod-unid-negoc
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_tip_fluxo_financ       = ""
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl               = ""
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl_ext           = tt-conta-pend-parcela.ct-codigo
                    tt_integr_acr_aprop_ctbl_pend.tta_cod_sub_cta_ctbl_ext       = tt-conta-pend-parcela.sc-codigo
                    tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl             = tt-conta-pend-parcela.valor.
         END.

        assign v_log_utiliza_rateio_un = no.
        &if defined(bf_dis_unid_neg) &then 
            assign v_log_utiliza_rateio_un = yes.
        &endif.

        IF v_log_utiliza_rateio_un = YES 
        and can-find(first para-dis where para-dis.log-unid-neg = yes) THEN DO:
            run pi_rateio_unid_neg.
            IF RETURN-VALUE = "NOK":U THEN
                RETURN "NOK":U.
        END.
        ELSE
            delete tt-conta-pend-parcela.
    end.

    /* ap¢s calcular as apropriacoes (com valor liquido) atualiza o valor do lote com o valor l¡quido*/
    IF  l-america-latina THEN DO:
        IF  nota-fiscal.ind-tip-nota = 10 
        AND nota-fiscal.nro-nota-orig = "":U THEN 
            ASSIGN tt_integr_acr_item_lote_impl_8.tta_val_tit_acr     = tt-lin-i-cr.vl-base-calc-ret 
                   tt_integr_acr_item_lote_impl_8.tta_val_liq_tit_acr = tt-lin-i-cr.vl-base-calc-ret.
            
        ELSE 
            ASSIGN tt_integr_acr_item_lote_impl_8.tta_val_tit_acr     = vl-tot-lote-aprop 
                   tt_integr_acr_item_lote_impl_8.tta_val_liq_tit_acr = vl-tot-lote-aprop.
    end.
END.

PROCEDURE pi-gera-abatimento-remito:

    for each it-nota-fisc fields(it-nota-fisc.nr-seq-ped nr-nota-fis nr-seq-fat 
                                qt-faturada[1] nr-pedcli ind-sit-nota) of nota-fiscal 
        WHERE it-nota-fisc.nr-remito <> ? no-lock,
        each it-remito fields(it-remito.cod-estabel it-remito.serie it-remito.nr-remito qt-pedida)
          where it-remito.cod-estabel = it-nota-fisc.cod-estabel
            and it-remito.serie       = it-nota-fisc.ser-remito
            and it-remito.nr-remito   = it-nota-fisc.nr-remito
            and it-remito.nr-seq-item = it-nota-fisc.nr-seq-it-rmt
            and it-remito.it-codigo   = it-nota-fisc.it-codigo no-lock:

        find remito of it-remito no-lock no-error.
        if remito.dt-prev = ? then next.

        FIND ped-item
            WHERE ped-item.nome-abrev   = nota-fiscal.nome-ab-cli
              AND ped-item.nr-pedcli    = it-nota-fisc.nr-pedcli
              AND ped-item.nr-sequencia = it-nota-fisc.nr-seq-ped NO-LOCK NO-ERROR. 

        FIND tt-abat-prev-rem EXCLUSIVE-LOCK
            WHERE tt-abat-prev-rem.cod-estabel = remito.cod-estabel
              AND tt-abat-prev-rem.serie       = remito.serie
              AND tt-abat-prev-rem.nr-remito   = remito.nr-remito NO-ERROR.

        IF NOT AVAIL tt-abat-prev-rem THEN DO:

            CREATE tt-abat-prev-rem.
            ASSIGN tt-abat-prev-rem.cod-estabel    = remito.cod-estabel
                   tt-abat-prev-rem.serie          = remito.serie
                   tt-abat-prev-rem.nr-remito      = remito.nr-remito
                   tt-abat-prev-rem.cod-cond-pagto = ped-venda.cod-cond-pag.
        END.
        ASSIGN tt-abat-prev-rem.vl-prev = tt-abat-prev-rem.vl-prev + it-nota-fisc.qt-faturada[1] * ped-item.vl-preuni.
    END.
    find first fat-duplic
    where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
    and   fat-duplic.serie     = nota-fiscal.serie
    and   fat-duplic.nr-fatura = nota-fiscal.nr-fatura no-lock no-error.

    ASSIGN c-nr-docto = if  (   nota-fiscal.ind-tip-nota = 1
                             or nota-fiscal.ind-tip-nota = 4
                             or nota-fiscal.ind-tip-nota = 3)
                        and emitente.natureza          = 3
                        and nota-fiscal.nr-proc-exp > "0"
                        and para-fat.ind-docum-fatura  = 2
                        then nota-fiscal.nr-proc-exp
                        else fat-duplic.nr-fatura.

    FOR EACH tt-abat-prev-rem:

        find first ser-estab where
                   ser-estab.serie       = tt-abat-prev-rem.serie and
                   ser-estab.cod-estabel = tt-abat-prev-rem.cod-estabel no-lock no-error.

        ASSIGN de-acum-prev = 0
               i-par        = 0.
        IF tt-abat-prev-rem.cod-cond-pag <> 0 THEN DO:

            find cond-pagto where cond-pagto.cod-cond-pag = tt-abat-prev-rem.cod-cond-pag no-lock no-error.                                 
            DO i-par = 1 TO cond-pagto.num-parcelas:

                FIND tt_integr_acr_item_lote_impl_8
                    WHERE tt_integr_acr_item_lote_impl_8.ttv_rec_lote_impl_tit_acr      = recid(tt_integr_acr_lote_impl)
                      AND tt_integr_acr_item_lote_impl_8.tta_cdn_cliente                = nota-fiscal.cod-emitente
                      AND tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto            = fat-duplic.cod-esp
                      AND tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto              = fat-duplic.serie
                      AND tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr                = c-nr-docto
                      AND tt_integr_acr_item_lote_impl_8.tta_cod_parcela                = STRING(i-par,"99":U)
                     NO-LOCK NO-ERROR.

                IF i-par <> cond-pagto.num-parcelas THEN DO:

                    CREATE tt_integr_acr_abat_prev.
                    assign tt_integr_acr_abat_prev.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
                           tt_integr_acr_abat_prev.tta_cod_estab_ext              = tt-abat-prev-rem.cod-estabel
                           tt_integr_acr_abat_prev.tta_cod_estab                  = ""
                           tt_integr_acr_abat_prev.tta_cod_espec_docto            = ser-estab.cod-esp
                           tt_integr_acr_abat_prev.tta_cod_ser_docto              = tt-abat-prev-rem.serie
                           tt_integr_acr_abat_prev.tta_cod_tit_acr                = tt-abat-prev-rem.nr-remito
                           tt_integr_acr_abat_prev.tta_cod_parcela                = STRING(i-par,"99":U)
                           tt_integr_acr_abat_prev.tta_log_zero_sdo_prev          = no.
                    ASSIGN tt_integr_acr_abat_prev.tta_val_abtdo_prev_tit_abat    = (tt-abat-prev-rem.vl-prev * (cond-pagto.per-pg-dup[i-par] / 100))
                           de-acum-prev                                           = de-acum-prev + tt_integr_acr_abat_prev.tta_val_abtdo_prev_tit_abat.

                END.
                ELSE DO:

                    CREATE tt_integr_acr_abat_prev.
                    assign tt_integr_acr_abat_prev.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
                           tt_integr_acr_abat_prev.tta_cod_estab_ext              = tt-abat-prev-rem.cod-estabel
                           tt_integr_acr_abat_prev.tta_cod_estab                  = ""
                           tt_integr_acr_abat_prev.tta_cod_espec_docto            = ser-estab.cod-esp
                           tt_integr_acr_abat_prev.tta_cod_ser_docto              = tt-abat-prev-rem.serie
                           tt_integr_acr_abat_prev.tta_cod_tit_acr                = tt-abat-prev-rem.nr-remito
                           tt_integr_acr_abat_prev.tta_cod_parcela                = STRING(i-par,"99":U)
                           tt_integr_acr_abat_prev.tta_log_zero_sdo_prev          = no.
                    ASSIGN tt_integr_acr_abat_prev.tta_val_abtdo_prev_tit_abat    = tt-abat-prev-rem.vl-prev - de-acum-prev.             
                END.
            END.
        END.    
        ELSE DO:

            FOR EACH cond-ped NO-LOCK 
                WHERE cond-ped.nr-pedido = ped-venda.nr-pedido 
                BREAK BY cond-ped.nr-sequencia:

                ASSIGN i-par = i-par + 1.

                FIND tt_integr_acr_item_lote_impl_8
                    WHERE tt_integr_acr_item_lote_impl_8.ttv_rec_lote_impl_tit_acr      = recid(tt_integr_acr_lote_impl)
                      AND tt_integr_acr_item_lote_impl_8.tta_cdn_cliente                = nota-fiscal.cod-emitente
                      AND tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto            = fat-duplic.cod-esp
                      AND tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto              = fat-duplic.serie
                      AND tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr                = c-nr-docto
                      AND tt_integr_acr_item_lote_impl_8.tta_cod_parcela                = STRING(i-par,"99":U)
                     NO-LOCK NO-ERROR.

                IF NOT LAST-OF(cond-ped.nr-sequencia) THEN DO:

                    CREATE tt_integr_acr_abat_prev.
                    assign tt_integr_acr_abat_prev.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
                           tt_integr_acr_abat_prev.tta_cod_estab_ext              = tt-abat-prev-rem.cod-estabel
                           tt_integr_acr_abat_prev.tta_cod_estab                  = ""
                           tt_integr_acr_abat_prev.tta_cod_espec_docto            = ser-estab.cod-esp
                           tt_integr_acr_abat_prev.tta_cod_ser_docto              = tt-abat-prev-rem.serie
                           tt_integr_acr_abat_prev.tta_cod_tit_acr                = tt-abat-prev-rem.nr-remito
                           tt_integr_acr_abat_prev.tta_cod_parcela                = STRING(i-par,"99":U)
                           tt_integr_acr_abat_prev.tta_log_zero_sdo_prev          = no.
                    ASSIGN tt_integr_acr_abat_prev.tta_val_abtdo_prev_tit_abat    = (tt-abat-prev-rem.vl-prev * (cond-ped.perc-pagto / 100))
                           de-acum-prev                                           = de-acum-prev + tt_integr_acr_abat_prev.tta_val_abtdo_prev_tit_abat.
                END.
                ELSE DO:

                    CREATE tt_integr_acr_abat_prev.
                    assign tt_integr_acr_abat_prev.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
                           tt_integr_acr_abat_prev.tta_cod_estab_ext              = tt-abat-prev-rem.cod-estabel
                           tt_integr_acr_abat_prev.tta_cod_estab                  = ""
                           tt_integr_acr_abat_prev.tta_cod_espec_docto            = ser-estab.cod-esp
                           tt_integr_acr_abat_prev.tta_cod_ser_docto              = tt-abat-prev-rem.serie
                           tt_integr_acr_abat_prev.tta_cod_tit_acr                = tt-abat-prev-rem.nr-remito
                           tt_integr_acr_abat_prev.tta_cod_parcela                = STRING(i-par,"99":U)
                           tt_integr_acr_abat_prev.tta_log_zero_sdo_prev          = no.
                    ASSIGN tt_integr_acr_abat_prev.tta_val_abtdo_prev_tit_abat    = tt-abat-prev-rem.vl-prev - de-acum-prev.             
                END.

            END.
        END.
    END.
END.

PROCEDURE pi-gera-log-ems2:

    RUN pi-gera-temp-table(INPUT           "tt-doc-i-cr":U,
                           INPUT TEMP-TABLE tt-doc-i-cr:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt-lin-i-cr":U, 
                           INPUT TEMP-TABLE tt-lin-i-cr:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt-ext-lin-i-cr":U, 
                           INPUT TEMP-TABLE tt-ext-lin-i-cr:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt-rep-i-cr":U, 
                           INPUT TEMP-TABLE tt-rep-i-cr:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt-lin-ant":U, 
                           INPUT TEMP-TABLE tt-lin-ant:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt-lin-prev":U, 
                           INPUT TEMP-TABLE tt-lin-prev:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt-impto-tit-pend-cr":U, 
                           INPUT TEMP-TABLE tt-impto-tit-pend-cr:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt-lin-ven":U, 
                           INPUT TEMP-TABLE tt-lin-ven:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt-ext-impto-tit-pend-cr":U, 
                           INPUT TEMP-TABLE tt-ext-impto-tit-pend-cr:HANDLE).

END PROCEDURE.


PROCEDURE pi-gera-log-ems5:

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_abat_antecip":U,
                           INPUT TEMP-TABLE tt_integr_acr_abat_antecip:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_abat_prev":U, 
                           INPUT TEMP-TABLE tt_integr_acr_abat_prev:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_aprop_ctbl_pend":U, 
                           INPUT TEMP-TABLE tt_integr_acr_aprop_ctbl_pend:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_aprop_desp_rec":U, 
                           INPUT TEMP-TABLE tt_integr_acr_aprop_desp_rec:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_aprop_liq_antec":U, 
                           INPUT TEMP-TABLE tt_integr_acr_aprop_liq_antec:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_aprop_relacto":U, 
                           INPUT TEMP-TABLE tt_integr_acr_aprop_relacto:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_aprop_relacto_2", 
                           INPUT TEMP-TABLE tt_integr_acr_aprop_relacto_2:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_cheq":U, 
                           INPUT TEMP-TABLE tt_integr_acr_cheq:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_impto_impl_pend":U, 
                           INPUT TEMP-TABLE tt_integr_acr_impto_impl_pend:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_item_lote_impl":U, 
                           INPUT TEMP-TABLE tt_integr_acr_item_lote_impl:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_item_lote_impl_1":U, 
                           INPUT TEMP-TABLE tt_integr_acr_item_lote_impl_1:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_lote_impl":U, 
                           INPUT TEMP-TABLE tt_integr_acr_lote_impl:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_ped_vda_pend":U, 
                           INPUT TEMP-TABLE tt_integr_acr_ped_vda_pend:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_relacto_pend":U, 
                           INPUT TEMP-TABLE tt_integr_acr_relacto_pend:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_relacto_pend_cheq":U, 
                           INPUT TEMP-TABLE tt_integr_acr_relacto_pend_cheq:HANDLE).
    
    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_repres_comis_2", 
                           INPUT TEMP-TABLE tt_integr_acr_repres_comis_2:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_repres_pend":U, 
                           INPUT TEMP-TABLE tt_integr_acr_repres_pend:HANDLE).

    RUN pi-gera-temp-table(INPUT           "tt_integr_acr_item_lote_impl_8":U, 
                           INPUT TEMP-TABLE tt_integr_acr_item_lote_impl_8:HANDLE).


END PROCEDURE.

PROCEDURE pi-gera-temp-table:

    DEF INPUT PARAMETER c-nome AS CHAR NO-UNDO.
    def input param p-handle-tt as handle no-undo.

    DEFINE VARIABLE h-buffer AS HANDLE.
    DEFINE VARIABLE h-bfield AS HANDLE.
    DEFINE VARIABLE h-query AS HANDLE.
    DEFINE VARIABLE i-seq AS INTEGER    NO-UNDO.
    DEFINE VARIABLE i-cpo AS INTEGER    NO-UNDO.

    ASSIGN h-buffer = p-handle-tt:DEFAULT-BUFFER-HANDLE.

    CREATE QUERY h-query.
    h-query:SET-BUFFERS(h-buffer).
    h-query:QUERY-PREPARE("for each ":U + c-nome + " no-lock":U).

    h-query:QUERY-OPEN.
    h-query:GET-FIRST().

    IF h-query:NUM-RESULTS = 0 THEN RETURN.

    OUTPUT STREAM s-log TO value(c-dir-log + "~\log-ftapi017-":U + c-nome + ".csv":U).
    
    DO i-seq = 1 TO h-query:NUM-BUFFERS:
        ASSIGN h-buffer = h-query:GET-BUFFER-HANDLE(i-seq).

        PUT STREAM s-log
            "RECID"
            ";".

        DO i-cpo = 1 TO h-buffer:NUM-FIELDS:
            ASSIGN h-bfield = h-buffer:BUFFER-FIELD(i-cpo).
            PUT STREAM s-log
                trim(string(h-bfield:NAME,"x(30)")) FORMAT "X(30)"
                ";".
        END.

        PUT STREAM s-log SKIP.

        PUT STREAM s-log
            h-buffer:RECID
            ";".

        DO i-cpo = 1 TO h-buffer:NUM-FIELDS:
            ASSIGN h-bfield = h-buffer:BUFFER-FIELD(i-cpo).
            CASE h-bfield:DATA-TYPE:

                WHEN "INTEGER" 
             OR WHEN "CHARACTER"
             OR WHEN "DECIMAL"
             OR WHEN "DATE"
             OR WHEN "LOGICAL"
             OR WHEN "DEC" THEN DO:
                    PUT STREAM s-log
                        h-bfield:BUFFER-VALUE
                        ";".
             END.
             OTHERWISE DO:
                PUT STREAM s-log
                    h-bfield:STRING-VALUE FORMAT "X(60)"
                    ";".
             END.
            END CASE.
        END.
    END.

    h-query:GET-NEXT().
    DO WHILE NOT h-query:QUERY-OFF-END:
        DO i-seq = 1 TO h-query:NUM-BUFFERS:
            ASSIGN h-buffer = h-query:GET-BUFFER-HANDLE(i-seq).

            PUT STREAM s-log SKIP.

            PUT STREAM s-log
                h-buffer:RECID
                ";".

            DO i-cpo = 1 TO h-buffer:NUM-FIELDS:
                ASSIGN h-bfield = h-buffer:BUFFER-FIELD(i-cpo).
                CASE h-bfield:DATA-TYPE:

                    WHEN "INTEGER" 
                 OR WHEN "CHARACTER"
                 OR WHEN "DECIMAL"
                 OR WHEN "DATE"
                 OR WHEN "LOGICAL"
                 OR WHEN "DEC" THEN DO:
                        PUT STREAM s-log
                            h-bfield:BUFFER-VALUE
                            ";".
                 END.
                 OTHERWISE DO:
                    PUT STREAM s-log
                        h-bfield:STRING-VALUE FORMAT "X(60)"
                        ";".
                 END.
                END CASE.
            END.
        END.
        h-query:GET-NEXT().
    END.    

    OUTPUT STREAM s-log CLOSE.

END PROCEDURE.


PROCEDURE pi-epc: 

    /*--------- INICIO UPC ---------*/ 
    if  c-nom-prog-dpc-mg97  <> ""
        or  c-nom-prog-appc-mg97 <> "" 
        or  c-nom-prog-upc-mg97  <> ""  then do:
            for each tt-epc:
            delete tt-epc.
        end.
        create tt-epc.
        assign tt-epc.cod-event     = "AfterAssignSumarFt"
               tt-epc.cod-parameter = "sumar-ft rowid"
               tt-epc.val-parameter = string(rowid(sumar-ft)).

        {include/i-epc201.i "AfterAssignSumarFt"}
        /*--------- FINAL UPC ---------*/
    END. 

END PROCEDURE.

PROCEDURE pi-calcula-impostos-relacto:

    DEF INPUT PARAMETER p-ep-codigo     LIKE tt-lin-i-cr.ep-codigo NO-UNDO.
    DEF INPUT PARAMETER p-c-cod-estabel LIKE tt-lin-i-cr.cod-estabel NO-UNDO.
    DEF INPUT PARAMETER p-cod-esp       LIKE tt-lin-i-cr.cod-esp     NO-UNDO.
    DEF INPUT PARAMETER p-nr-docto      LIKE tt-lin-i-cr.nr-docto    NO-UNDO.
    DEF INPUT PARAMETER p-nr-parcela    LIKE tt-lin-i-cr.parcela     NO-UNDO.
    DEF OUTPUT PARAMETER p-vl-agregados LIKE it-nota-imp.vl-imposto  NO-UNDO.

    ASSIGN p-vl-agregados = 0.

    FOR EACH  tt-impto-tit-pend-cr-1 NO-LOCK
        WHERE tt-impto-tit-pend-cr-1.ep-codigo   = p-ep-codigo
          AND tt-impto-tit-pend-cr-1.cod-estabel = p-c-cod-estabel
          AND tt-impto-tit-pend-cr-1.cod-esp     = p-cod-esp
          AND tt-impto-tit-pend-cr-1.nr-docto    = p-nr-docto
          AND tt-impto-tit-pend-cr-1.parcela     = p-nr-parcela,
          FIRST tipo-tax 
          WHERE tipo-tax.cod-tax = tt-impto-tit-pend-cr-1.cod-imposto
          AND   tipo-tax.tipo = 2  NO-LOCK: 

          ASSIGN p-vl-agregados = p-vl-agregados + tt-impto-tit-pend-cr-1.vl-imposto-me.
                                                   
    END.

END PROCEDURE.


