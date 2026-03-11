
/*******************************************************************************
**
**   Programa: CD9730.i
**
**   Data....: Julho de 1997
**
**   Autor...: DATASUL S.A.
**
**   Objetivo: Definicao da temp-table t-invest
**
**   Versao  : 1.00.000 - Sandra Stadelhofer
**
*****************************************************************************/

def {1} shared temp-table t-invest
    field ep-codigo      like ordem-compra.ep-codigo
    field numero-ordem   like ordem-compra.numero-ordem
    field num-ord-magnus like ordem-compra.num-ord-inv 
    field cod-estabel    like ordem-compra.cod-estabel
    field parcela        like prazo-compra.parcela
    field cod-emitente   like ordem-compra.cod-emitente
    field data-cotacao   like cotacao-item.data-cotacao
    field ord-par        as char format "x(01)"
    field tipo           as char format "x(01)".
/*    index emp-ord-par is primary  
 *           ep-codigo    ascending
 *           numero-ordem ascending
 *           parcela      ascending
 *           ord-par      ascending
 *           tipo         descending.*/
                            

