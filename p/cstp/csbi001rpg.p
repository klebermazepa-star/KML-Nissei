/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         csbi001rpg
&SCOPED-DEFINE program_definition   "CSBI001 - CEP"
&SCOPED-DEFINE program_version      1.00.00.001

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

RUN pi-acompanhar IN h-acomp(INPUT "Eliminando...") .
DELETE FROM cst_ctbl_bi
    WHERE cst_ctbl_bi.cod_modul = "CEP"
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
    EACH movto-estoq FIELDS(cod-estabel dt-trans ct-codigo sc-codigo ct-saldo sc-saldo it-codigo
                            tipo-trans serie-docto nro-docto cod-emitente nat-operacao sequen-nf
                            descricao-db valor-mat-m valor-ggf-m valor-mob-m)
    NO-LOCK USE-INDEX estab-dep
    WHERE movto-estoq.cod-estabel = estabelec.cod-estabel 
    AND   movto-estoq.dt-trans >= tt-param.dt_trans_ini
    AND   movto-estoq.dt-trans <= tt-param.dt_trans_fim
    :
    ASSIGN i-acomp = i-acomp + 1 .
    IF i-acomp MOD 100 = 0 THEN DO:
        RUN pi-acompanhar IN h-acomp(INPUT "CEP: " + STRING(i-acomp) + " - " + 
                                     movto-estoq.cod-estabel + " - " +
                                     STRING(movto-estoq.dt-trans , "99/99/9999") ) 
            .
    END.
    IF movto-estoq.ct-codigo <> "" AND 
       movto-estoq.ct-codigo >= tt-param.cod_cta_ctbl_ini AND
       movto-estoq.ct-codigo <= tt-param.cod_cta_ctbl_fim
    THEN DO:
        CREATE cst_ctbl_bi . ASSIGN
            cst_ctbl_bi.dt_trans        = movto-estoq.dt-trans
            cst_ctbl_bi.cod_estab       = movto-estoq.cod-estabel
            cst_ctbl_bi.cod_cta_ctbl    = movto-estoq.ct-codigo
            cst_ctbl_bi.cod_ccusto      = movto-estoq.sc-codigo
            cst_ctbl_bi.ind_natur       = IF movto-estoq.tipo-trans = 1 THEN "CR" ELSE "DB"
            cst_ctbl_bi.val_lancto      = movto-estoq.valor-mat-m[1] + movto-estoq.valor-ggf-m[1] + movto-estoq.valor-mob-m[1]
            cst_ctbl_bi.cod_modul       = "CEP"
            cst_ctbl_bi.des_historico   = movto-estoq.nro-docto + "," + SUBSTRING(movto-estoq.descricao-db , 1 , 80)
            cst_ctbl_bi.cdn_emitente    = movto-estoq.cod-emitente
            cst_ctbl_bi.cod_item        = movto-estoq.it-codigo
            .
        /**/
        IF movto-estoq.serie-docto <> "" AND 
           movto-estoq.nro-docto <> "" AND 
           movto-estoq.cod-emitente <> 0 AND 
           movto-estoq.nat-operacao <> "" 
        THEN DO:
            RUN pi-verifica-contrato .
        END.
    END.
    IF movto-estoq.ct-saldo <> "" AND 
       movto-estoq.ct-saldo >= tt-param.cod_cta_ctbl_ini AND
       movto-estoq.ct-saldo <= tt-param.cod_cta_ctbl_fim
    THEN DO:
        CREATE cst_ctbl_bi . ASSIGN
            cst_ctbl_bi.dt_trans        = movto-estoq.dt-trans
            cst_ctbl_bi.cod_estab       = movto-estoq.cod-estabel
            cst_ctbl_bi.cod_cta_ctbl    = movto-estoq.ct-saldo
            cst_ctbl_bi.cod_ccusto      = movto-estoq.sc-saldo
            cst_ctbl_bi.ind_natur       = IF movto-estoq.tipo-trans = 1 THEN "CR" ELSE "DB"
            cst_ctbl_bi.val_lancto      = movto-estoq.valor-mat-m[1] + movto-estoq.valor-ggf-m[1] + movto-estoq.valor-mob-m[1]
            cst_ctbl_bi.cod_modul       = "CEP"
            cst_ctbl_bi.des_historico   = movto-estoq.nro-docto + "," + SUBSTRING(movto-estoq.descricao-db , 1 , 80)
            cst_ctbl_bi.cdn_emitente    = movto-estoq.cod-emitente
            cst_ctbl_bi.cod_item        = movto-estoq.it-codigo
            cst_ctbl_bi.nro_docto       = movto-estoq.nro-docto
            .
        /**/
        IF movto-estoq.serie-docto <> "" AND 
           movto-estoq.nro-docto <> "" AND 
           movto-estoq.cod-emitente <> 0 AND 
           movto-estoq.nat-operacao <> "" 
        THEN DO:
            RUN pi-verifica-contrato .
        END.
    END.
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .

/* ***************************  PROCEDURES  ************************** */
PROCEDURE pi-verifica-contrato:
    FOR FIRST rat-ordem NO-LOCK
        WHERE rat-ordem.serie-docto = movto-estoq.serie-docto
        AND   rat-ordem.nro-docto = movto-estoq.nro-docto
        AND   rat-ordem.cod-emitente = movto-estoq.cod-emitente
        AND   rat-ordem.nat-operacao = movto-estoq.nat-operacao
        AND   rat-ordem.sequencia = movto-estoq.sequen-nf 
        AND   rat-ordem.nr-contrato <> 0 , 
        FIRST contrato-for NO-LOCK
        WHERE contrato-for.nr-contrato = rat-ordem.nr-contrato
        :
        ASSIGN cst_ctbl_bi.des_historico = movto-estoq.nro-docto + "," + SUBSTR(contrato-for.narrat-contrat,1,80) .
    END.
    /**/
    RETURN "OK":U .
END PROCEDURE .
