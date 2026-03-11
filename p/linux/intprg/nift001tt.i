define temp-table tt-param   no-undo
    field destino             as integer
    field arquivo             as char    format "x(35)"
    field usuario             as char    format "x(12)"
    field data-exec           as date
    field hora-exec           as integer
    FIELD cod-estab-ini     LIKE estabelec.cod-estabel
    FIELD cod-estab-fim     LIKE estabelec.cod-estabel
    field num-nota-ini      like nota-fiscal.nr-nota-fis
    field num-nota-fim      like nota-fiscal.nr-nota-fis
    FIELD c-serie-ini       LIKE nota-fiscal.serie
    FIELD c-serie-fim       LIKE nota-fiscal.serie
    field dat-emis-ini        as date    format "99/99/9999"
    field dat-emis-fim        as date    format "99/99/9999"
    FIELD cod-transp-ini    LIKE transporte.cod-transp
    FIELD cod-transp-fim    LIKE transporte.cod-transp
    FIELD c-nome-transp-ini LIKE transporte.nome-abrev
    FIELD c-nome-transp-fim LIKE transporte.nome-abrev
    FIELD c-pasta-destino     AS CHAR.

define temp-table tt-digita no-undo
    field num-nota     like nota-fiscal.nr-nota-fis. 
