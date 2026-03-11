/* Temporary Table Definitions */
DEF TEMP-TABLE tt-param NO-UNDO
    FIELD empresa           LIKE mguni.empresa.ep-codigo
    FIELD destino           AS INTEGER
    FIELD arquivo           AS CHAR
    FIELD usuario           AS CHAR
    FIELD data-exec         AS DATE
    FIELD hora-exec         AS INTEGER
    FIELD classifica        AS INTEGER
    FIELD desc-classifica   AS CHAR
    /*Selecao*/
    FIELD num_dias          AS INT
	FIELD dt_trans_ini      LIKE cst_ctbl_bi.dt_trans
	FIELD dt_trans_fim      LIKE cst_ctbl_bi.dt_trans
	FIELD cod_estab_ini     LIKE cst_ctbl_bi.cod_estab
	FIELD cod_estab_fim     LIKE cst_ctbl_bi.cod_estab
	FIELD cod_cta_ctbl_ini  LIKE cst_ctbl_bi.cod_cta_ctbl
	FIELD cod_cta_ctbl_fim  LIKE cst_ctbl_bi.cod_cta_ctbl
    FIELD modul_fgl         AS LOGICAL
    FIELD modul_acr         AS LOGICAL
    FIELD modul_apb         AS LOGICAL
    FIELD modul_cmg         AS LOGICAL
    FIELD modul_pat         AS LOGICAL
    FIELD modul_apl         AS LOGICAL
    FIELD modul_cep         AS LOGICAL
    FIELD modul_fat         AS LOGICAL
    /*Parametros*/
    /*Impressao*/
    .

DEF TEMP-TABLE tt-digita NO-UNDO
    FIELD cod_livre_1       AS CHAR
    .

/* Transfer Definitions */
DEF TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita         AS RAW
    .
