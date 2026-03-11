/* Defini‡Æo tt-param */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    FIELD i-execucao       AS INT

    FIELD da-emissao-ini       AS date
    FIELD da-emissao-fim       AS date
    FIELD c-cod-estabel-ini    AS CHAR
    FIELD c-cod-estabel-fim    AS CHAR
    FIELD de-embarque-ini      AS decimal
    FIELD de-embarque-fim      AS decimal
    FIELD c-nr-nota-ini        AS CHAR
    FIELD c-nr-nota-fim        AS CHAR
    FIELD c-serie-ini          AS CHAR
    FIELD c-serie-fim          AS CHAR
	
	field id-convenio          as logical
    field id-servico           as logical 
    field id-full-point        as logical 
	field id-troco             as logical
	field id-cheque            as logical
	
	field rs-gera-titulo       as integer

    FIELD i-pais               AS INT
    field i-cod-portador      as integer
	
    .


