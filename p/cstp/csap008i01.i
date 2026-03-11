/*
*/

DEF {1} TEMP-TABLE tt-docto{2} NO-UNDO
    FIELD r-rowid           AS ROWID
    FIELD serie-docto       LIKE docum-est.serie-docto
    FIELD nro-docto         LIKE docum-est.nro-docto
    FIELD cod-emitente      LIKE docum-est.cod-emitente COLUMN-LABEL "Fornecedor"
    FIELD nat-operacao      LIKE docum-est.nat-operacao
    FIELD cod-estabel       LIKE docum-est.cod-estabel
    FIELD dt-emissao        LIKE docum-est.dt-emissao
    FIELD dt-trans          LIKE docum-est.dt-trans
    FIELD nome-emit         LIKE emitente.nome-emit COLUMN-LABEL "Fornecedor"
    FIELD simples-nac       AS LOGICAL COLUMN-LABEL "Simples Nac"
    FIELD cod-esp           LIKE dupli-apagar.cod-esp
    FIELD parcela           LIKE dupli-apagar.parcela            
    FIELD dt-vencim         LIKE dupli-apagar.dt-vencim
    FIELD vl-docto          LIKE dupli-apagar.vl-a-pagar 
    FIELD vl-a-pagar        LIKE dupli-apagar.vl-a-pagar       
    FIELD cod-imposto       AS INT FORMAT ">>>>>9" COLUMN-LABEL "Cod Imposto"
    FIELD cod-retencao      LIKE dupli-imp.cod-retencao
    FIELD rend-trib         LIKE dupli-imp.rend-trib
    FIELD aliquota          LIKE dupli-imp.aliquota
    FIELD vl-imposto        LIKE dupli-imp.vl-imposto
    FIELD l_ger             AS LOGICAL COLUMN-LABEL "Gerado"
    FIELD cod_usuario_ger   LIKE cst_dupli_apagar.cod_usuario_ger
    FIELD dt_ger            LIKE cst_dupli_apagar.dt_ger
    FIELD hr_ger            LIKE cst_dupli_apagar.hr_ger
    INDEX idx1  AS PRIMARY
    cod-estabel cod-emitente dt-emissao serie-docto nro-docto
    .

DEF {1} TEMP-TABLE tt-param{2} NO-UNDO
    FIELD empresa           LIKE mguni.empresa.ep-codigo
    FIELD destino           AS INTEGER
    FIELD arquivo           AS CHAR
    FIELD usuario           AS CHAR
    FIELD data-exec         AS DATE
    FIELD hora-exec         AS INTEGER
    FIELD classifica        AS INTEGER
    FIELD desc-classifica   AS CHAR
    /*Selecao*/
	FIELD mes-transacao     AS INT
    FIELD ano-transacao     AS INT
    FIELD cod-prefeitura    AS INT
    FIELD dir-arquivos      AS CHAR
    FIELD l-teste           AS LOGICAL
    /*Parametros*/
    /*Impressao*/
    .
