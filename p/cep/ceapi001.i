/**************************************************************************
**
**   ceapi001.i - Include de definicoes da temp-table e variaveis 
**
**                da API ceapi001.p
**
**************************************************************************/

{cdp/cdcfgmat.i}

def temp-table tt-movto NO-UNDO
    field cod-versao-integracao as integer format "999"
    field cod-prog-orig         like movto-estoq.cod-prog-orig
    field l-mov-erro            as logical initial no
    field r-mov-inv             as rowid    
    field r-mov-orig            as rowid  /* registro original para  
                                             valorizar o estorno,
                                             devolu‡Æo,retorno */
    field sequen-nf             like movto-estoq.sequen-nf
    field cod-depos             like movto-estoq.cod-depos
    field cod-emitente          like movto-estoq.cod-emitente
    field cod-estabel           like movto-estoq.cod-estabel
    field cod-refer             like movto-estoq.cod-refer
    field ct-codigo             like movto-estoq.ct-codigo
    field descricao-db          like movto-estoq.descricao-db
    field dt-nf-saida           like movto-estoq.dt-nf-saida
    field dt-trans              like movto-estoq.dt-trans
    field esp-docto             like movto-estoq.esp-docto
    field it-codigo             like movto-estoq.it-codigo
    field cod-localiz           like movto-estoq.cod-localiz
    field lote                  like movto-estoq.lote
    field nat-operacao          like movto-estoq.nat-operacao
    field nro-docto             like movto-estoq.nro-docto
    field num-sequen            like movto-estoq.num-sequen
    field numero-ordem          like movto-estoq.numero-ordem
    field nr-ord-produ          like movto-estoq.nr-ord-produ
    field peso-liquido          like movto-estoq.peso-liquido
    field quantidade            like movto-estoq.quantidade
    field referencia            like movto-estoq.referencia
    field sc-codigo             like movto-estoq.sc-codigo
    field serie-docto           like movto-estoq.serie-docto
    field tipo-preco            like movto-estoq.tipo-preco
    field tipo-trans            like movto-estoq.tipo-trans
    field tipo-valor            like movto-estoq.tipo-valor
    field un                    like movto-estoq.un         
    field valor-mat-m           like movto-estoq.valor-mat-m
    field valor-mat-o           like movto-estoq.valor-mat-o
    field valor-mat-p           like movto-estoq.valor-mat-p
    field valor-mob-m           like movto-estoq.valor-mob-m
    field valor-mob-o           like movto-estoq.valor-mob-o
    field valor-mob-p           like movto-estoq.valor-mob-p
    field valor-ggf-m           like movto-estoq.valor-ggf-m
    field valor-ggf-o           like movto-estoq.valor-ggf-o
    field valor-ggf-p           like movto-estoq.valor-ggf-p
    field valor-nota            like movto-estoq.valor-nota
    field vl-nota-fasb          like movto-estoq.vl-nota-fasb
    field nr-ord-refer          like movto-estoq.nr-ord-refer
    field nr-req-sum            like movto-estoq.nr-req-sum
    field cod-roteiro           like movto-estoq.cod-roteiro
    field nr-reporte            like movto-estoq.nr-reporte
    field item-pai              like movto-estoq.item-pai
    field op-codigo             like movto-estoq.op-codigo
    field cod-usu-ult-alter     like movto-estoq.cod-usu-ult-alter
    field conta-contabil        like movto-estoq.conta-contabil
    field conta-db              like movto-estoq.conta-contabil
    field ct-db                 like movto-estoq.ct-codigo
    field sc-db                 like movto-estoq.sc-codigo
    field dt-vali-lote          like saldo-estoq.dt-vali-lote
    field op-seq                like movto-estoq.op-seq
    field usuario               like movto-estoq.usuario
    field nr-trans              like movto-estoq.nr-trans 
    field cod-estabel-des       like movto-estoq.cod-estabel-des
    field origem-valor          like movto-estoq.origem-valor
    field num-ord-des           like movto-estoq.num-ord-des
    field num-seq-des           like movto-estoq.num-seq-des
    field num-ord-inv           like movto-estoq.num-ord-inv
    field valor-ipi             like movto-estoq.valor-ipi
    field valor-iss             like movto-estoq.valor-iss
    field valor-icm             like movto-estoq.valor-icm
    field vl-icm-fasb           like movto-estoq.vl-icm-fasb
    field vl-iss-fasb           like movto-estoq.vl-iss-fasb
    field vl-ipi-fasb           like movto-estoq.vl-ipi-fasb 
    field per-ppm               like movto-estoq.per-ppm
    field atualiza-ul-ent       as logical
    field i-sequen              as integer
    field gera-saldo            as logical init no
    field qt-alocada            as DECIMAL FORMAT "->>>>,>>>,>>9.9999"
  &if '{&bf_lote_avancado_liberado}' = 'yes' &then
    field i-sequen-pai             as integer
    field log-ficha                as log
  &endif
  .

/* Fim Include ceapi001.i */
