/****************************************************************************************************
**
** CD9700.i  - Definicao de variaveis para include cd9700.i1
**
*****************************************************************************************************/

DEF VAR l-fatura-fat-antecip  AS LOG NO-UNDO.
DEF VAR l-remessa-fat-antecip AS LOG NO-UNDO.
DEF VAR l-fatura-ent-futura   AS LOG NO-UNDO.
DEF VAR l-remessa-ent-futura  AS LOG NO-UNDO.

DEF VAR h-bodi578             AS HANDLE                    NO-UNDO.
DEF VAR c-nat-operacao-fatura LIKE natur-oper.nat-operacao NO-UNDO.

DEF BUFFER bf-natur-oper-cd9700   FOR natur-oper.
DEF BUFFER bf-item-doc-est-cd9700 FOR item-doc-est.

DEF NEW GLOBAL SHARED TEMP-TABLE tt-rat-ordem-utiliz NO-UNDO
    FIELD nro-docto     LIKE {1}item-doc-est.nro-docto   
    FIELD cod-emitente  LIKE {1}item-doc-est.cod-emitente
    FIELD nat-operacao  LIKE {1}item-doc-est.nat-operacao
    FIELD serie-docto   LIKE {1}item-doc-est.serie-docto 
    FIELD sequencia     LIKE {1}item-doc-est.sequencia   
    FIELD numero-ordem  LIKE {1}item-doc-est.numero-ordem
    FIELD num-pedido    LIKE {1}item-doc-est.num-pedido  
    FIELD parcela       LIKE {1}item-doc-est.parcela 
    INDEX chave nro-docto   
                cod-emitente
                nat-operacao
                serie-docto 
                sequencia   
                numero-ordem
                num-pedido  
                parcela.




