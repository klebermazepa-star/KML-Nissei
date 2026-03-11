/*************************************************************************
** 
**  Programa: REAPI190.I
** 
**  Objetivo: Defini‡Æo das temp-tables usadas na API reapi190.p
**                                               e em re0190rp.p
**
*************************************************************************/
{cdp/cdcfgdis.i} /* Pre-processadores Distribuicao */
{cdp/cdcfgmat.i} /* Pre-processadores Materiais    */

/* Definicoes de temp-tables de uso geral */

def temp-table tt-versao-integr no-undo
    field registro              as int
    field cod-versao-integracao as int format "999".

{cdp/cd0666.i} /* defini‡Æo da temp-table de erros */   

def temp-table tt-raw-digita
    field raw-digita  as raw.
def new shared temp-table tt-item-doc-est no-undo
    field registro              as   int
    field it-codigo             like item-doc-est.it-codigo 
    field cod-refer             like item-doc-est.cod-refer 
    field numero-ordem          like item-doc-est.numero-ordem 
    field parcela               like item-doc-est.parcela
    field encerra-pa            like item-doc-est.encerra-pa 
    field nr-ord-prod           like item-doc-est.nr-ord-prod 
    field cod-roteiro           like item-doc-est.cod-roteiro 
    field op-codigo             like item-doc-est.op-codigo 
    field item-pai              like item-doc-est.item-pai 
    field ct-codigo             like item-doc-est.ct-codigo 
    field sc-codigo             like item-doc-est.sc-codigo 
    field baixa-ce              like item-doc-est.baixa-ce 
    field etiquetas             like item-doc-est.etiquetas 
    field qt-do-forn            like item-doc-est.qt-do-forn 
    field quantidade            like item-doc-est.quantidade
    field preco-total           like item-doc-est.preco-total extent 0
    field desconto              like item-doc-est.desconto extent 0
    field vl-frete-cons         like item-doc-est.pr-total-cmi
    field despesas              like item-doc-est.despesas extent 0
    field peso-liquido          like item-doc-est.peso-liquido 
    field cod-depos             like rat-lote.cod-depos             /* rat lote */
    field cod-localiz           like rat-lote.cod-localiz
    field lote                  like rat-lote.lote
    field dt-vali-lote          like rat-lote.dt-vali-lote

    field class-fiscal          like item-doc-est.class-fiscal 
    field aliquota-ipi          like item-doc-est.aliquota-ipi 
    field cd-trib-ipi           like item-doc-est.cd-trib-ipi 
    field base-ipi              like item-doc-est.base-ipi extent 0
    field valor-ipi             like item-doc-est.valor-ipi extent 0
    field aliquota-iss          like item-doc-est.aliquota-iss 
    field cd-trib-iss           like item-doc-est.cd-trib-iss 
    field base-iss              like item-doc-est.base-iss extent 0
    field valor-iss             like item-doc-est.valor-iss extent 0

    field base-pis              like item-doc-est.base-pis extent 0
    field valor-pis             like item-doc-est.valor-pis extent 0
    field cd-trib-pis           as integer format "9"
    field aliquota-pis          as decimal format ">>9.99"

    field base-cofins           like item-doc-est.base-cofins extent 0
    field valor-cofins          as decimal format ">>>,>>>,>>>,>>9.99" extent 0
    field cd-trib-cofins        as integer format "9"      
    field aliquota-cofins       as decimal format ">>9.99" 

    field aliquota-icm          like item-doc-est.aliquota-icm 
    field cd-trib-icm           like item-doc-est.cd-trib-icm 
    field base-icm              like item-doc-est.base-icm extent 0
    field valor-icm             like item-doc-est.valor-icm extent 0
    field base-subs             like item-doc-est.base-subs extent 0
    field valor-subs            like item-doc-est.vl-subs extent 0
    field icm-complem           like item-doc-est.icm-complem extent 0
    field ind-icm-ret           like item-doc-est.baixa-ce
    field narrativa             like item-doc-est.narrativa
    field serie-comp            like item-doc-est.serie-comp
    field nro-comp              like item-doc-est.nro-comp
    field nat-comp              like item-doc-est.nat-comp
    field seq-comp              like item-doc-est.seq-comp            
    field data-comp             like item-doc-est.data-comp           
    field icm-outras            like item-doc-est.icm-outras extent 0 
    field ipi-outras            like item-doc-est.ipi-outras extent 0 
    field iss-outras            like item-doc-est.iss-outras extent 0 
    field icm-ntrib             like item-doc-est.icm-ntrib extent 0  
    field ipi-ntrib             like item-doc-est.ipi-ntrib extent 0  
    field iss-ntrib             like item-doc-est.iss-ntrib extent 0  

    field val-perc-red-ipi      as   dec  format ">>9.9999"
    field val-perc-red-icm      as   dec  format ">>9.9999"

    field nr-proc-imp           as character format "x(12)"         /* Campo Integracao Modulo Importacao */
    field serie-docto           like item-doc-est.serie-docto       /* resgatado pelo item-doc-est */
    field nro-docto             like item-doc-est.nro-docto         /* resgatado pelo item-doc-est */
    field cod-emitente          like item-doc-est.cod-emitente      /* resgatado pelo item-doc-est */
    field nat-operacao          like item-doc-est.nat-operacao      /* resgatado pelo item-doc-est */
    field sequencia             like item-doc-est.sequencia         /* atribuido pelo i-seq */
    field nr-ato-concessorio    as character format "x(20)"         /*este campo esta sendo utilizado para a funcionalidade DRAWBACK*/
    field per-ppm               LIKE rat-lote.per-ppm               /*utilizado para alimentar o campo per-ppm da tabela rat-lote */
    field cod-unid-negoc        like item-doc-est.cod-unid-negoc
    field un                    like item-doc-est.un
    
    &if '{&bf_lote_avancado_liberado}' = 'yes' &then /*Campos Projeto FDA*/
        field cod-lote-fabrican             like item-doc-est.cod-lote-fabrican
        field dat-fabricc-lote              like item-doc-est.dat-fabricc-lote
        field dat-valid-lote-fabrican       like item-doc-est.dat-valid-lote-fabrican
        field nom-fabrican                  like item-doc-est.nom-fabrican
    &ENDIF
    index documento is primary unique
          serie-docto
    	  nro-docto
    	  cod-emitente
    	  nat-operacao
          sequencia.


def temp-table tt-docum-est no-undo
    field registro              as   int
    field serie-docto           like docum-est.serie-docto 
    field nro-docto             like docum-est.nro-docto 
    field cod-emitente          like docum-est.cod-emitente 
    field nat-operacao          like docum-est.nat-operacao 
    field cod-observa           like docum-est.cod-observa 
    field cod-estabel           like docum-est.cod-estabel 
    field estab-fisc            like docum-est.estab-fisc
    field ct-transit            like docum-est.ct-transit 
    field sc-transit            like docum-est.sc-transit
    field dt-emissao            like docum-est.dt-emissao 
    field dt-trans              like docum-est.dt-trans 
    field usuario               like docum-est.usuario 
    field uf                    like docum-est.uf 
    field via-transp            like docum-est.via-transp
    field mod-frete             like docum-est.mod-frete 
    field nff                   like docum-est.nff 
    field tot-peso              like docum-est.tot-peso 
    field tot-desconto          like docum-est.tot-desconto 
    field valor-frete           like docum-est.valor-frete 
    field valor-seguro          like docum-est.valor-seguro 
    field valor-embal           like docum-est.valor-embal 
    field valor-outras          like docum-est.valor-outras 
    field valor-mercad          like docum-est.valor-mercad 
    field dt-venc-ipi           like docum-est.dt-venc-ipi 
    field dt-venc-icm           like docum-est.dt-venc-icm 
    field tot-valor             like docum-est.tot-valor
    field efetua-calculo        as   int  format "9"
    field observacao            like docum-est.observacao
    field cotacao-dia           like docum-est.cotacao-dia     /* Campo Integracao Modulo Importacao */
    field embarque              as character format "x(12)"    /* Campo Integracao Modulo Importacao */

    field sequencia             as   int  format "999999"
    field esp-docto             like docum-est.esp-docto   
    field rec-fisico            like docum-est.rec-fisico   /* atribui‡Æo direta = no       */
    field origem                like docum-est.origem       /* atribui‡Æo direta = "I"      */
    field pais-origem           like docum-est.pais-origem  /* atribui‡Æo direta = "RE1001" */
    field gera-unid-neg         as   int format "9"  /* 0-NÆo; 1-Gera */
    FIELD nome-transp           AS CHAR FORMAT "x(12)"
    FIELD cod-placa-1           AS CHAR FORMAT "x(07)"
    FIELD cod-placa-2           AS CHAR FORMAT "x(07)"
    FIELD cod-placa-3           AS CHAR FORMAT "x(07)"
    FIELD cod-uf-placa-1        AS CHAR FORMAT "x(02)"
    FIELD cod-uf-placa-2        AS CHAR FORMAT "x(02)"
    FIELD cod-uf-placa-3        AS CHAR FORMAT "x(02)"
    field char-1                like docum-est.char-1
    &if "{&bf_mat_versao_ems}" >= "2.07" &then
     FIELD cod-chave-aces-nf-eletro LIKE docum-est.cod-chave-aces-nf-eletro
     FIELD cdn-sit-nfe              LIKE docum-est.cdn-sit-nfe
    &endif
    FIELD cod-modalid-frete LIKE modalid-frete.cod-modalid-frete
    index documento is primary
          serie-docto
          nro-docto
          cod-emitente
          nat-operacao

    index seq is unique
          sequencia.

/* Defini‡Æo da temp-table TT-DOCUM-EST-AUX */
{rep/reapi190a.i1 "-aux"}

def temp-table tt-dupli-apagar no-undo
    field registro              as   int
    field parcela               like dupli-apagar.parcela
    field nr-duplic             like dupli-apagar.nr-duplic 
    field cod-esp               like dupli-apagar.cod-esp
    field tp-despesa            like dupli-apagar.tp-despesa 
    field dt-vencim             like dupli-apagar.dt-vencim 
    field vl-a-pagar            like dupli-apagar.vl-a-pagar
    field vl-desconto           like dupli-apagar.vl-desconto 
    field dt-venc-desc          like dupli-apagar.dt-venc-desc 
    field cod-ret-irf           like dupli-apagar.cod-ret-irf
    field mo-codigo             like ordem-compra.mo-codigo    /* Campo Integracao Modulo Importacao */
    field vl-a-pagar-mo         like dupli-apagar.vl-a-pagar   /* Campo Integracao Modulo Importacao */

    field serie-docto           like dupli-apagar.serie-docto       /* resgatado pelo item-doc-est */
    field nro-docto             like dupli-apagar.nro-docto         /* resgatado pelo item-doc-est */
    field cod-emitente          like dupli-apagar.cod-emitente      /* resgatado pelo item-doc-est */
    field nat-operacao          like dupli-apagar.nat-operacao      /* resgatado pelo item-doc-est */

    index documento is primary
          serie-docto
          nro-docto
          cod-emitente
          nat-operacao
          parcela.

def temp-table tt-dupli-imp no-undo
    field registro              as   int
    field cod-imp               as   int format ">>>9"
    field cod-esp               like dupli-imp.cod-esp    
    field dt-venc-imp           like dupli-imp.dt-venc-imp     
    field rend-trib             like dupli-imp.rend-trib     
    field aliquota              like dupli-imp.aliquota 
    field vl-imposto            like dupli-imp.vl-imposto 
    field tp-codigo             like dupli-imp.tp-codigo
    field cod-retencao          like dupli-imp.cod-retencao

    field serie-docto           like dupli-imp.serie-docto       /* resgatado pelo item-doc-est */
    field nro-docto             like dupli-imp.nro-docto         /* resgatado pelo item-doc-est */
    field cod-emitente          like dupli-imp.cod-emitente      /* resgatado pelo item-doc-est */
    field nat-operacao          like dupli-imp.nat-operacao      /* resgatado pelo item-doc-est */
    field parcela               like dupli-imp.parcela

    index dupli-imp is primary
          serie-docto
          nro-docto
          cod-emitente
          nat-operacao
          parcela
          cod-esp.

def temp-table tt-unid-neg-nota no-undo
    field registro              as   int
    field cod-emitente          like unid-neg-nota.cod-emitente
    field serie-docto           like unid-neg-nota.serie-docto
    field nro-docto             like unid-neg-nota.nro-docto
    field nat-operacao          like unid-neg-nota.nat-operacao
    field sequencia             like unid-neg-nota.sequencia
    field cod_unid_negoc        like unid-neg-nota.cod_unid_negoc
    field perc-unid-neg         like unid-neg-nota.perc-unid-neg
    index documento is primary
          serie-docto
          nro-docto
          cod-emitente
          nat-operacao
          sequencia
          cod_unid_negoc.

/* fim da include */


