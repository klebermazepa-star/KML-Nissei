/* NÆo foi feita a replica‡Æo da l¢gica, pois, tanto no layout 1.10 como no      */
/* layout novo 2.00, a l¢gica da include abaixo ‚ a mesma. Caso seja necess rio  */ 
/* alterar a l¢gica da mesma apenas para o layout 2.00 da NF-e, solicitamos que  */
/* o c¢digo da include seja copiado para esse fonte, e a altera‡Æo seja feita    */
/* somente nele.                                                                 */
 
{adapters/xml/ep2/axsep006extradeclarations.i}

/* NOVAS DEFINICOES PARA O LAYOUT 2.00 DA NF-E */

DEFINE VARIABLE l-IPITributado        AS LOGICAL        NO-UNDO.
DEFINE VARIABLE cHoraContingencia     AS CHARACTER      NO-UNDO.
DEFINE VARIABLE cCodEstabel           AS CHARACTER      NO-UNDO.
DEFINE VARIABLE de-vlzfm              AS DECIMAL        NO-UNDO.
DEFINE VARIABLE de-icmzfm             AS DECIMAL        NO-UNDO.
DEFINE VARIABLE de-descto-icms        AS DECIMAL        NO-UNDO.
DEFINE VARIABLE de-vl-servico         AS DECIMAL        NO-UNDO.
DEFINE VARIABLE d-total-pis-serv      AS DECIMAL        NO-UNDO.
DEFINE VARIABLE d-total-cofins-serv   AS DECIMAL        NO-UNDO.
DEFINE VARIABLE d-total-pis-st        AS DECIMAL        NO-UNDO.
DEFINE VARIABLE d-total-cofins-st     AS DECIMAL        NO-UNDO.
DEFINE VARIABLE l-sem-iss             AS LOG            NO-UNDO.
DEFINE VARIABLE l-pis-cofins-st-total AS LOG            NO-UNDO.
DEFINE VARIABLE l-retira-out-desp-obs AS LOG            NO-UNDO.
DEFINE VARIABLE d-total-icms-STA      AS DECIMAL        NO-UNDO.
DEFINE VARIABLE d-total-IPI-espec     AS DECIMAL        NO-UNDO.
DEFINE VARIABLE d-total-icms-ST-espec AS DECIMAL        NO-UNDO.
DEFINE VARIABLE d-total-ipi-out-tot   AS DECIMAL        NO-UNDO.
DEFINE VARIABLE d-total-desp-n-destaq AS DECIMAL        NO-UNDO.
DEFINE VARIABLE l-ipi-outras-total    AS LOG            NO-UNDO.
DEFINE VARIABLE l-funcao-DESCONTO-NFE AS LOGICAL        NO-UNDO.
DEFINE VARIABLE l-nota-dif-preco-RE   AS LOGICAL        NO-UNDO.
DEFINE VARIABLE i-codigo-orig         AS INTEGER        NO-UNDO.
DEFINE VARIABLE i-codigo-orig-estab   AS INTEGER INIT ? NO-UNDO.
DEFINE VARIABLE c-cod-csosn           AS CHARACTER      NO-UNDO.

DEFINE BUFFER bf-it-nota-fisc-rat  FOR it-nota-fisc. /* Leitura it-nota-fisc para Rateios do Seguro e Outras Despesas  */
DEFINE BUFFER b-nota-fiscal        FOR nota-fiscal.

DEFINE TEMP-TABLE tt-rateio-seguro NO-UNDO
    FIELD nr-seq-fat LIKE it-nota-fisc.nr-seq-fat
    FIELD it-codigo  LIKE it-nota-fisc.it-codigo
    FIELD percentual AS DEC
    FIELD valor      AS DEC.

DEFINE TEMP-TABLE tt-rateio-vOutro NO-UNDO
    FIELD nr-seq-fat LIKE it-nota-fisc.nr-seq-fat
    FIELD it-codigo  LIKE it-nota-fisc.it-codigo
    FIELD percentual AS DEC
    FIELD valor      AS DEC.


/*--- cEAN/cEANTrib ---*/
DEFINE VARIABLE c-cod-ean-trib         AS CHARACTER   NO-UNDO.

DEFINE TEMP-TABLE tt-combinacao NO-UNDO
         FIELD seq           AS INT
         FIELD cod-item      AS CHAR
         FIELD cod-un-medid  AS CHAR
         FIELD cod-pais-orig AS CHAR
         FIELD cdn-emitente  AS INT.
/*--- cEAN/cEANTrib ---*/
