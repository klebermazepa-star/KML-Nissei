/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         csbi001rph
&SCOPED-DEFINE program_definition   "CSBI001 - FAT"
&SCOPED-DEFINE program_version      1.00.00.003

{include/i-prgvrs.i {&program_name} {&program_version} }

{cstp/csbi001tt.i}

/*Parameters Definitions*/
DEFINE INPUT PARAMETER raw-param AS RAW NO-UNDO .
DEFINE INPUT PARAMETER TABLE FOR tt-raw-digita .

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp AS HANDLE NO-UNDO.
DEF VAR i-acomp AS INT NO-UNDO .
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

IF tt-param.num_dias <> 0 THEN DO:
    ASSIGN tt-param.dt_trans_fim = TODAY .
    ASSIGN tt-param.dt_trans_ini = TODAY - tt-param.num_dias .
END.

RUN pi-acompanhar IN h-acomp(INPUT "FAT - Eliminando...") .
DELETE FROM cst_ctbl_bi
    WHERE cst_ctbl_bi.cod_modul = "FAT"
    AND   cst_ctbl_bi.dt_trans >= tt-param.dt_trans_ini
    AND   cst_ctbl_bi.dt_trans <= tt-param.dt_trans_fim
    AND   cst_ctbl_bi.cod_estab >= tt-param.cod_estab_ini
    AND   cst_ctbl_bi.cod_estab <= tt-param.cod_estab_fim
    AND   cst_ctbl_bi.cod_cta_ctbl >= tt-param.cod_cta_ctbl_ini
    AND   cst_ctbl_bi.cod_cta_ctbl <= tt-param.cod_cta_ctbl_fim
    .

ASSIGN i-acomp = 0 .
FOR EACH estabelec NO-LOCK 
    WHERE estabelec.cod-estabel >= tt-param.cod_estab_ini
    AND   estabelec.cod-estabel <= tt-param.cod_estab_fim ,
    EACH sumar-ft NO-LOCK USE-INDEX ch-movto
    WHERE sumar-ft.cod-estabel = estabelec.cod-estabel 
    AND   sumar-ft.dt-movto >= tt-param.dt_trans_ini
    AND   sumar-ft.dt-movto <= tt-param.dt_trans_fim
    AND   sumar-ft.ct-conta >= tt-param.cod_cta_ctbl_ini
    AND   sumar-ft.ct-conta <= tt-param.cod_cta_ctbl_fim , 
    FIRST nota-fiscal FIELDS(cod-estabel serie nr-nota-fis cod-emitente) 
    NO-LOCK
    WHERE nota-fiscal.cod-estabel = sumar-ft.cod-estabel
    AND   nota-fiscal.serie = sumar-ft.serie
    AND   nota-fiscal.nr-nota-fis = sumar-ft.nr-nota-fis
    :
    ASSIGN i-acomp = i-acomp + 1 .
    IF i-acomp MOD 100 = 0 THEN DO:
        RUN pi-acompanhar IN h-acomp(INPUT "FAT: " + STRING(i-acomp) + " - " + 
                                     sumar-ft.cod-estabel + " - " +
                                     STRING(sumar-ft.dt-movto , "99/99/9999") ) 
            .
    END.
    /**/ 
    CREATE cst_ctbl_bi . ASSIGN
        cst_ctbl_bi.dt_trans        = sumar-ft.dt-movto
        cst_ctbl_bi.cod_estab       = sumar-ft.cod-estabel
        cst_ctbl_bi.cod_cta_ctbl    = sumar-ft.ct-conta
        cst_ctbl_bi.cod_ccusto      = sumar-ft.sc-conta
        cst_ctbl_bi.ind_natur       = IF sumar-ft.vl-contab < 0 THEN "DB" ELSE "CR"
        cst_ctbl_bi.val_lancto      = ABS(sumar-ft.vl-contab)
        cst_ctbl_bi.cod_modul       = "FAT"
        cst_ctbl_bi.des_historico   = sumar-ft.serie + "/" + sumar-ft.nr-nota-fis
        cst_ctbl_bi.cdn_emitente    = nota-fiscal.cod-emitente
        cst_ctbl_bi.nro_docto       = nota-fiscal.nr-nota-fis
        .
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .


