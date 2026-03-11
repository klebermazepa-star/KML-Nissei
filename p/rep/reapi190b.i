/*************************************************************************
** 
**  Programa: REAPI190b.I
** 
**  Objetivo: Defini»’o das temp-tables usadas na API reapi190b.p
**
*************************************************************************/

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

{inbo/boin092.i tt-dupli-apagar-2}		  

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

{inbo/boin567.i tt-dupli-imp-2}

/* fim da include */



