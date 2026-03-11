/******************************************************************************
*      Programa .....: esacr001rp.p                                              *
*      Data .........: 06/2022                                                   *
*      Sistema ......:                                                           *
*      Empresa ......: Sensus                                                    * 
*      Cliente ......: Nissei                                                    *
*      Programador ..: Jeferson Venicios de Souza                                *
*      Objetivo .....: Conferˆncia Cupons (FT0904) com t¡tulos no ACR            *
**********************************************************************************
*      VERSAO      DATA        RESPONSAVEL    MOTIVO                             *
*      12.1.34     06/2022     Venicios       Desenvolvimento                    * 
******************************************************************************/
{include/i-prgvrs.i esacr001rp.p 12.1.34.000} 
{utp/ut-glob.i}

/****** Defini‡Æo Tabelas Tempor rias ***********/

DEFINE TEMP-TABLE tt-param NO-UNDO
    FIELD destino               AS INTEGER
    FIELD execucao              AS INTEGER
    FIELD arquivo               AS CHAR FORMAT "x(35)"
    FIELD usuario               AS CHAR FORMAT "x(12)" 
    FIELD c-data-ini            AS DATE FORMAT "99/99/9999"
    FIELD c-data-fim            AS DATE FORMAT "99/99/9999"
    FIELD c-cod-estabel-ini     AS CHAR FORMAT "x(5)"
    FIELD c-cod-estabel-fim     AS CHAR FORMAT "x(5)"
    FIELD tg-resumo             AS LOGICAL
    FIELD tg-detalhar-nf        AS LOGICAL
    FIELD tg-detalhar-tit       AS LOGICAL.

DEF TEMP-TABLE tt-dados
    FIELD cod-grupo             AS CHAR
    FIELD peso                  AS DECIMAL FORMAT ">>>,>>>,>>9.9999".

DEF TEMP-TABLE tt-notas
    FIELD cod-estabel           LIKE nota-fiscal.cod-estabel
    FIELD serie                 LIKE nota-fiscal.serie
    FIELD nr-nota-fis           LIKE nota-fiscal.nr-nota-fis
    FIELD cod-emitente          LIKE nota-fiscal.cod-emitente
    FIELD vl-tot-nota           LIKE nota-fiscal.vl-tot-nota
    FIELD vl-retorno            LIKE nota-fiscal.vl-tot-nota
    FIELD vl-cupom              LIKE nota-fiscal.vl-tot-nota
    FIELD vl-acr                LIKE nota-fiscal.vl-tot-nota
    FIELD vl-dif-nf-cup         AS DECIMAL FORMAT "->>>,>>9.99"
    FIELD dt-emis-nota          LIKE nota-fiscal.dt-emis-nota
    INDEX idx-primary
    cod-estabel
    serie
    nr-nota-fis
    INDEX idx-dif
    cod-estabel
    vl-dif-nf-cup.

DEF TEMP-TABLE tt-titulos
    FIELD cod_estab             LIKE tit_acr.cod_estab
    FIELD cod_espec_docto       LIKE tit_acr.cod_espec_docto
    FIELD cod_ser_docto         LIKE tit_acr.cod_ser_docto
    FIELD cod_tit_acr           LIKE tit_acr.cod_tit_acr
    FIELD cod_parcela           LIKE tit_acr.cod_parcela
    FIELD cdn_cliente           LIKE tit_acr.cdn_cliente
    FIELD dat_emis_docto        LIKE tit_acr.dat_emis_docto
    FIELD val_origin_tit_acr    LIKE tit_acr.val_origin_tit_acr
    FIELD val_desc_tit_acr      LIKE tit_acr.val_desc_tit_acr
    FIELD val_abat_tit_acr      LIKE tit_acr.val_abat_tit_acr
    FIELD vl-cupom              LIKE tit_acr.val_origin_tit_acr
    FIELD vl-ftp                LIKE tit_acr.val_origin_tit_acr
    FIELD vl-dif-tit-cup        AS DECIMAL FORMAT "->>>,>>9.99"
    INDEX idx-primary
    cod_estab
    cod_espec_docto
    cod_ser_docto
    cod_tit_acr
    cod_parcela
    INDEX idx-cupom
    cod_estab
    cod_ser_docto
    cod_tit_acr
    //cdn_cliente
    dat_emis_docto.

DEF TEMP-TABLE tt-cupons
    FIELD cod_estab             LIKE tit_acr.cod_estab
    FIELD cod_espec_docto       LIKE tit_acr.cod_espec_docto  
    FIELD cod_ser_docto         LIKE tit_acr.cod_ser_docto    
    FIELD cod_tit_acr           LIKE tit_acr.cod_tit_acr
    FIELD cod_parcela           LIKE tit_acr.cod_parcela
    FIELD val_origin_tit_acr    LIKE tit_acr.val_origin_tit_acr
    FIELD num_id_tit_acr        LIKE tit_acr.num_id_tit_acr
    FIELD num_cupom             LIKE tit_acr_cartao.num_cupom
    FIELD serie_cupom           LIKE tit_acr_cartao.serie_cupom
    FIELD cod_admdra            LIKE tit_acr_cartao.cod_admdra
    FIELD dat_vda_cartao_cr     LIKE tit_acr_cartao.dat_vda_cartao_cr
    FIELD val_comprov_vda       LIKE tit_acr_cartao.val_comprov_vda
    FIELD cup_sem_nota          AS LOGICAL
    INDEX idx-cup-sem-nota
    cup_sem_nota.

DEF TEMP-TABLE tt-comparativo
    FIELD cod-estabel           LIKE nota-fiscal.cod-estabel 
    FIELD data                  AS DATE FORMAT "99/99/9999"
    FIELD vl-fat                AS DECIMAL FORMAT ">>>,>>>,>>9.99"
    FIELD vl-acr                AS DECIMAL FORMAT ">>>,>>>,>>9.99"
    FIELD vl-dif                AS DECIMAL FORMAT "->>>,>>>,>>9.99"
    INDEX idx-primary  AS PRIMARY UNIQUE
    cod-estabel
    data.

DEF TEMP-TABLE tt-raw-digita
    FIELD raw-digita AS RAW.    

/*********************************************************************************/

/****** Defini‡Æo Vari veis ***********/
DEF VAR h-acomp         AS HANDLE           NO-UNDO.

DEF VAR i-data          AS DATE FORMAT "99/99/9999" NO-UNDO.
DEF VAR cont            AS INTEGER                  NO-UNDO.
DEF VAR aux-soma        AS DECIMAL                  NO-UNDO.
DEF VAR c-dir-spool     AS CHAR                     NO-UNDO.
DEF VAR c-arquivo       AS CHAR FORMAT "x(100)"     NO-UNDO.

DEF VAR c-ini           AS INTEGER                  NO-UNDO.
DEF VAR c-fim           AS INTEGER                  NO-UNDO.
DEF VAR l-ini           AS INTEGER                  NO-UNDO.
DEF VAR l-fim           AS INTEGER                  NO-UNDO.
DEF VAR linha-ini       AS INTEGER                  NO-UNDO.
DEF VAR linha-fim       AS INTEGER                  NO-UNDO.
DEF VAR coluna-ini      AS INTEGER                  NO-UNDO.
DEF VAR coluna-fim      AS INTEGER                  NO-UNDO.
DEF VAR cont_linha      AS INTEGER                  NO-UNDO.
DEF VAR i-coluna        AS INTEGER                  NO-UNDO.
DEF VAR c-coluna        AS CHAR EXTENT 256          NO-UNDO
    INITIAL ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK","AL","AM","AN","AO","AP","AQ","AR","AS","AT","AU","AV","AW",
    "AX","AY","AZ","BA","BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BO","BP","BQ","BR","BS","BT",
    "BU","BV","BW","BX","BY","BZ","CA","CB","CC","CD","CE","CF","CG","CH","CI","CJ","CK","CL","CM","CN","CO","CP","CQ",
    "CR","CS","CT","CU","CV","CW","CX","CY","CZ","DA","DB","DC","DD","DE","DF","DG","DH","DI","DJ","DK","DL","DM","DN",
    "DO","DP","DQ","DR","DS","DT","DU","DV","DW","DX","DY","DZ","EA","EB","EC","ED","EE","EF","EG","EH","EI","EJ","EK",
    "EL","EM","EN","EO","EP","EQ","ER","ES","ET","EU","EV","EW","EX","EY","EZ","FA","FB","FC","FD","FE","FF","FG","FH",
    "FI","FJ","FK","FL","FM","FN","FO","FP","FQ","FR","FS","FT","FU","FV","FW","FX","FY","FZ","GA","GB","GC","GD","GE",
    "GF","GG","GH","GI","GJ","GK","GL","GM","GN","GO","GP","GQ","GR","GS","GT","GU","GV","GW","GX","GY","GZ","HA","HB",
    "HC","HD","HE","HF","HG","HH","HI","HJ","HK","HL","HM","HN","HO","HP","HQ","HR","HS","HT","HU","HV","HW","HX","HY",
    "HZ","IA","IB","IC","ID","IE","IF","IG","IH","II","IJ","IK","IL","IM","IN","IO","IP","IQ","IR","IS","IT","IU","IV"].

/*********************************************************************************/

/********** Vari veis Excel ***********/
DEFINE VARIABLE c-modelo    AS CHAR       NO-UNDO.
DEFINE VARIABLE hExcel      AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hWorkbook   AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hWorksheet  AS COM-HANDLE NO-UNDO.

/*********************************************************************************/

/****** Parƒmetros do Sistema *********/
DEF INPUT PARAMETER raw-param AS RAW NO-UNDO.
DEF INPUT PARAMETER TABLE FOR tt-raw-digita.

DEF STREAM st-arq-param.

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.
                               
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.

/********************************************************************************/


/********************** In¡cio Programa *****************************************/
RUN pi-inicializar IN h-acomp (INPUT "Gerando relatorio").

EMPTY TEMP-TABLE tt-dados.
EMPTY TEMP-TABLE tt-notas.
EMPTY TEMP-TABLE tt-titulos.
EMPTY TEMP-TABLE tt-cupons.
EMPTY TEMP-TABLE tt-comparativo.

/*=====================================================================================================================================*/
//buscar notas de saida no ft0904 (cupons)
ASSIGN cont = 0.
FOR EACH estabelec WHERE
    estabelec.cod-estabel  >=   tt-param.c-cod-estabel-ini  AND
    estabelec.cod-estabel  <=   tt-param.c-cod-estabel-fim  NO-LOCK.

    DO i-data = tt-param.c-data-ini TO tt-param.c-data-fim:
        FOR EACH nota-fiscal USE-INDEX ch-sit-nota WHERE
            nota-fiscal.dt-emis-nota                =   i-data                  AND
            nota-fiscal.ind-sit-nota               <>   4                       AND
            nota-fiscal.cod-estabel                 =   estabelec.cod-estabel   AND
            nota-fiscal.serie                      >=   ""                      AND
            nota-fiscal.dt-cancel                   =   ?                       AND
            nota-fiscal.emite-duplic                =   YES                     AND
            nota-fiscal.esp-docto                  <>   20                      AND
            SUBSTRING(nota-fiscal.nat-operacao,1,1) >   "4"                     NO-LOCK
            BREAK BY nota-fiscal.nr-nota-fis.
        
            RUN pi-acompanhar IN h-acomp (INPUT "1-Pesq. notas " + STRING(i-data) + " Estab " + estabelec.cod-estabel + " - " + STRING(cont)).
        
            ASSIGN cont = cont + 1.
        
            CREATE tt-notas.
            ASSIGN
                tt-notas.cod-estabel    =   nota-fiscal.cod-estabel
                tt-notas.serie          =   nota-fiscal.serie
                tt-notas.nr-nota-fis    =   nota-fiscal.nr-nota-fis
                tt-notas.cod-emitente   =   nota-fiscal.cod-emitente
                tt-notas.vl-tot-nota      =   nota-fiscal.vl-tot-nota
                tt-notas.vl-retorno     =   0
                tt-notas.vl-cupom       =   0
                tt-notas.vl-acr         =   0
                tt-notas.vl-dif-nf-cup  =   nota-fiscal.vl-tot-nota
                tt-notas.dt-emis-nota   =   nota-fiscal.dt-emis-nota.
    
            FIND FIRST tt-comparativo WHERE
                tt-comparativo.cod-estabel  =   nota-fiscal.cod-estabel     AND
                tt-comparativo.data         =   nota-fiscal.dt-emis-nota    NO-LOCK NO-ERROR.
            IF NOT AVAIL tt-comparativo THEN DO:
                CREATE tt-comparativo.
                ASSIGN
                    tt-comparativo.cod-estabel  =   nota-fiscal.cod-estabel
                    tt-comparativo.data         =   nota-fiscal.dt-emis-nota
                    tt-comparativo.vl-fat       =   0
                    tt-comparativo.vl-acr       =   0
                    tt-comparativo.vl-dif       =   0.
            END.
            ASSIGN tt-comparativo.vl-fat = tt-comparativo.vl-fat + nota-fiscal.vl-tot-nota.
        END.
    END.

    DO i-data = tt-param.c-data-ini TO tt-param.c-data-fim:
        FOR EACH docum-est WHERE
                docum-est.dt-trans      =   i-data                  AND
                docum-est.cod-estabel   =   estabelec.cod-estabel   NO-LOCK,
            EACH item-doc-est OF docum-est NO-LOCK.
            
            FIND FIRST tt-notas WHERE
                tt-notas.cod-estabel    =   docum-est.cod-estabel   AND
                tt-notas.serie          =   item-doc-est.serie-comp AND
                tt-notas.nr-nota-fis    =   item-doc-est.nro-comp   NO-LOCK NO-ERROR.
            IF AVAIL tt-notas THEN DO:
                ASSIGN 
                    tt-notas.vl-retorno     =   tt-notas.vl-retorno + item-doc-est.preco-total[1].
                    //tt-notas.vl-dif-nf-cup  =   tt-notas.vl-dif-nf-cup - item-doc-est.preco-total[1].
    
                /*FIND FIRST tt-comparativo WHERE
                    tt-comparativo.cod-estabel = tt-notas.cod-estabel NO-LOCK NO-ERROR.
                IF AVAIL tt-comparativo THEN DO:
                    ASSIGN tt-comparativo.vl-fat = tt-comparativo.vl-fat - item-doc-est.preco-total[1].
                END.*/
            END.
        END.
    END.
END.

/*=====================================================================================================================================*/
//pesquisar titulos acr implantados no periodo
FOR EACH estabelec WHERE
        estabelec.cod-estabel  >=   tt-param.c-cod-estabel-ini  AND
        estabelec.cod-estabel  <=   tt-param.c-cod-estabel-fim  NO-LOCK,
    EACH trad_org_ext WHERE
        trad_org_ext.cod_unid_organ_ext      =   estabelec.cod-estabel  NO-LOCK.

    RUN pi-acompanhar IN h-acomp (INPUT "2-Pesq. t¡tulos - Estab " + estabelec.cod-estabel).

    FOR EACH tit_acr WHERE
        tit_acr.cod_estab           =   trad_org_ext.cod_unid_organ     AND
        tit_acr.dat_emis_docto     >=   tt-param.c-data-ini             AND
        tit_acr.dat_emis_docto     <=   tt-param.c-data-fim             AND
        tit_acr.log_tit_acr_estordo =   NO                              NO-LOCK.

        RUN pi-acompanhar IN h-acomp (INPUT "2-Pesq. t¡tulos - Estab " + estabelec.cod-estabel + " - " + tit_acr.cod_tit_acr).

        CREATE tt-titulos.
        ASSIGN
            tt-titulos.cod_estab            =   tit_acr.cod_estab
            tt-titulos.cod_espec_docto      =   tit_acr.cod_espec_docto
            tt-titulos.cod_ser_docto        =   tit_acr.cod_ser_docto
            tt-titulos.cod_tit_acr          =   tit_acr.cod_tit_acr
            tt-titulos.cod_parcela          =   tit_acr.cod_parcela
            tt-titulos.cdn_cliente          =   tit_acr.cdn_cliente
            tt-titulos.dat_emis_docto       =   tit_acr.dat_emis_docto
            tt-titulos.val_origin_tit_acr   =   tit_acr.val_origin_tit_acr
            tt-titulos.val_desc_tit_acr     =   tit_acr.val_desc_tit_acr
            tt-titulos.val_abat_tit_acr     =   tit_acr.val_abat_tit_acr
            tt-titulos.vl-cupom             =   0
            tt-titulos.vl-ftp               =   0
            tt-titulos.vl-dif-tit-cup       =   tit_acr.val_origin_tit_acr. //- tit_acr.val_desc_tit_acr - tit_acr.val_abat_tit_acr.

        FIND FIRST tt-comparativo WHERE
            tt-comparativo.cod-estabel  =   tit_acr.cod_estab       AND
            tt-comparativo.data         =   tit_acr.dat_emis_docto  NO-LOCK NO-ERROR.
        IF NOT AVAIL tt-comparativo THEN DO:
            CREATE tt-comparativo.
            ASSIGN
                tt-comparativo.cod-estabel  =   tit_acr.cod_estab
                tt-comparativo.data         =   tit_acr.dat_emis_docto
                tt-comparativo.vl-fat       =   0
                tt-comparativo.vl-acr       =   0
                tt-comparativo.vl-dif       =   0.
        END.
        ASSIGN tt-comparativo.vl-acr = tt-comparativo.vl-acr + tit_acr.val_origin_tit_acr. //- tit_acr.val_desc_tit_acr - tit_acr.val_abat_tit_acr.

        // busca cupons associados ao titulo na tabela especifica
        FOR EACH tit_acr_cartao WHERE
            tit_acr_cartao.cod_estab        =   tit_acr.cod_estab       AND
            tit_acr_cartao.num_id_tit_acr   =   tit_acr.num_id_tit_acr  AND
            tit_acr_cartao.num_seq         >=   0                       NO-LOCK.

            CREATE tt-cupons.
            ASSIGN
                tt-cupons.cod_estab             =   tit_acr.cod_estab
                tt-cupons.cod_espec_docto       =   tit_acr.cod_espec_docto
                tt-cupons.cod_ser_docto         =   tit_acr.cod_ser_docto
                tt-cupons.cod_tit_acr           =   tit_acr.cod_tit_acr
                tt-cupons.cod_parcela           =   tit_acr.cod_parcela
                tt-cupons.val_origin_tit_acr    =   tit_acr.val_origin_tit_acr
                tt-cupons.num_id_tit_acr        =   tit_acr.num_id_tit_acr
                tt-cupons.num_cupom             =   tit_acr_cartao.num_cupom
                tt-cupons.serie_cupom           =   tit_acr_cartao.serie_cupom
                tt-cupons.dat_vda_cartao_cr     =   tit_acr_cartao.dat_vda_cartao_cr
                tt-cupons.cod_admdra            =   tit_acr_cartao.cod_admdra
                tt-cupons.val_comprov_vda       =   tit_acr_cartao.val_comprov_vda
                tt-cupons.cup_sem_nota          =   NO
                tt-titulos.vl-cupom             =   tt-titulos.vl-cupom + tt-cupons.val_comprov_vda
                tt-titulos.vl-dif-tit-cup       =   tt-titulos.vl-dif-tit-cup - tt-cupons.val_comprov_vda.

            FIND FIRST tt-notas WHERE
                tt-notas.cod-estabel    =   tt-cupons.cod_estab     AND
                tt-notas.serie          =   tt-cupons.serie_cupom   AND
                tt-notas.nr-nota-fis    =   tt-cupons.num_cupom     NO-LOCK NO-ERROR.
            IF AVAIL tt-notas THEN DO:
                ASSIGN 
                    tt-notas.vl-cupom       =   tt-notas.vl-cupom + tt-cupons.val_comprov_vda
                    tt-notas.vl-dif-nf-cup  =   tt-notas.vl-dif-nf-cup - tt-cupons.val_comprov_vda.
            END.
            ELSE DO:
                ASSIGN tt-cupons.cup_sem_nota = YES.
            END.
        END.
    END.
END.

/*=====================================================================================================================================*/
FOR EACH tt-comparativo NO-LOCK.
    ASSIGN tt-comparativo.vl-dif = tt-comparativo.vl-fat - tt-comparativo.vl-acr.
END.

/*=====================================================================================================================================*/
//analisa notas que nao fecharam o valor da nota com valor de cupons, e pesquisa se tem titulos direto com a chave dessas notas.

FOR EACH tt-comparativo WHERE
        tt-comparativo.vl-dif <> 0 NO-LOCK,
    EACH tt-notas WHERE 
        tt-notas.cod-estabel    =   tt-comparativo.cod-estabel  AND
        tt-notas.dt-emis-nota   =   tt-comparativo.data         AND
        tt-notas.vl-dif-nf-cup <>   0                           NO-LOCK.

    RUN pi-acompanhar IN h-acomp (INPUT "3-Pesq. t¡tulos de notas " + tt-notas.cod-estabel + " - " + tt-notas.nr-nota-fis).

    FOR EACH tt-titulos WHERE
        tt-titulos.cod_estab        =   tt-notas.cod-estabel    AND   
        tt-titulos.cod_ser_docto    =   tt-notas.serie          AND
        tt-titulos.cod_tit_acr      =   tt-notas.nr-nota-fis    AND
        tt-titulos.dat_emis_docto   =   tt-notas.dt-emis-nota   NO-LOCK.

        ASSIGN
            tt-notas.vl-acr             =   tt-notas.vl-acr + tt-titulos.val_origin_tit_acr
            tt-notas.vl-dif-nf-cup      =   tt-notas.vl-dif-nf-cup - tt-titulos.val_origin_tit_acr
            tt-titulos.vl-ftp           =   tt-titulos.val_origin_tit_acr
            tt-titulos.vl-dif-tit-cup   =   tt-titulos.vl-dif-tit-cup - tt-titulos.val_origin_tit_acr.
    END.
END.

/*=====================================================================================================================================*/
IF (TEMP-TABLE tt-notas:HAS-RECORDS) THEN DO:

    RUN pi-inicia-excel.

    // === planilha 1 ====================================================================================
    hExcel:worksheets:ITEM(1):SELECT.
    hWorkSheet = hExcel:Sheets:ITEM(1).
    
    ASSIGN 
        cont_linha  =   3
        coluna-ini  =   1
        linha-ini   =   4
        coluna-fim  =   4.

    FOR EACH tt-comparativo NO-LOCK
        BREAK   BY tt-comparativo.cod-estabel
                BY tt-comparativo.data.

        RUN pi-acompanhar IN h-acomp (INPUT "101-Imprimindo comparativo - " + tt-comparativo.cod-estabel).

        ASSIGN tt-comparativo.vl-dif = tt-comparativo.vl-fat - tt-comparativo.vl-acr.

        RUN pi-tt-comparativo.
    END.
    ASSIGN linha-fim = cont_linha.
    RUN pi-total-comparativo.
    //RUN pi-bordas.
    RUN pi-posiciona-inicio.

    // === gerar o detalhamento===============================================================================
    IF (NOT tt-param.tg-resumo) THEN DO:
        // === planilha 2 ====================================================================================
        hExcel:worksheets:ITEM(2):SELECT.
        hWorkSheet = hExcel:Sheets:ITEM(2).
        
        ASSIGN 
            cont_linha  =   1
            coluna-ini  =   1
            linha-ini   =   1
            coluna-fim  =   5
            cont        =   0.
    
        FOR EACH tt-comparativo WHERE
                tt-comparativo.vl-dif <> 0 NO-LOCK,
            EACH tt-notas WHERE 
                tt-notas.cod-estabel = tt-comparativo.cod-estabel NO-LOCK,
            EACH emitente WHERE
                emitente.cod-emitente = tt-notas.cod-emitente NO-LOCK
            BREAK   BY tt-notas.cod-estabel
                    BY tt-notas.nr-nota-fis.
    
            RUN pi-acompanhar IN h-acomp (INPUT "102-Imprimindo notas - estab " + tt-notas.cod-estabel + " - " + STRING(cont)).
    
            IF NOT (tt-param.tg-detalhar-nf) THEN DO:
                IF (tt-notas.vl-dif-nf-cup = 0) THEN NEXT.
            END.
    
            ASSIGN cont = cont + 1.
    
            RUN pi-tt-notas.
        END.
        ASSIGN linha-fim = cont_linha.
        //RUN pi-bordas.
        RUN pi-posiciona-inicio.
    
        // === planilha 3 ====================================================================================
        hExcel:worksheets:ITEM(3):SELECT.
        hWorkSheet = hExcel:Sheets:ITEM(3).
    
        ASSIGN 
            cont_linha  =   1
            coluna-ini  =   1
            linha-ini   =   1
            coluna-fim  =   14
            cont        =   0.
    
        ASSIGN l-ini = cont_linha + 1.
        FOR EACH tt-comparativo WHERE
                tt-comparativo.vl-dif <> 0 NO-LOCK,
            EACH tt-titulos WHERE
                tt-titulos.cod_estab = tt-comparativo.cod-estabel NO-LOCK,
            EACH emitente WHERE
                emitente.cod-emitente = tt-titulos.cdn_cliente NO-LOCK
            BREAK   BY tt-titulos.cod_estab
                    BY tt-titulos.cod_tit_acr.
    
            RUN pi-acompanhar IN h-acomp (INPUT "103-Imprimindo t¡tulos - estab " + tt-titulos.cod_estab + " - " + STRING(cont)).
    
            IF NOT (tt-param.tg-detalhar-tit) THEN DO:
                IF (tt-titulos.vl-dif-tit-cup = 0) THEN NEXT.
            END.
    
            ASSIGN cont = cont + 1.
    
            RUN pi-tt-titulos.
        END.
        ASSIGN linha-fim = cont_linha.
        //RUN pi-bordas.
        RUN pi-posiciona-inicio.
    
        // === planilha 4 ====================================================================================
        hExcel:worksheets:ITEM(4):SELECT.
        hWorkSheet = hExcel:Sheets:ITEM(4).
    
        ASSIGN 
            cont_linha  =   1
            coluna-ini  =   1
            linha-ini   =   1
            coluna-fim  =   14.
    
        ASSIGN l-ini = cont_linha + 1.
        FOR EACH tt-cupons WHERE
                tt-cupons.cup_sem_nota = YES NO-LOCK
            BREAK BY tt-cupons.cod_estab.
    
            RUN pi-acompanhar IN h-acomp (INPUT "104-Imprimindo cupons sem nota...").
    
            RUN pi-tt-cupons.
        END.
        ASSIGN linha-fim = cont_linha.
        //RUN pi-bordas.
        RUN pi-posiciona-inicio.
    
        // === planilha 1 ====================================================================================
        hExcel:worksheets:ITEM(1):SELECT.
        hWorkSheet = hExcel:Sheets:ITEM(1).
    END.
    // === fim gerar o detalhamento===========================================================================

    RUN pi-finaliza-excel.

END.
ELSE DO:
    MESSAGE "NÆo h  informa‡äes para a sele‡Æo informada." VIEW-AS ALERT-BOX ERROR TITLE "Erro".
END.

/*-------------------------------------------------------------------------------------------------------------------------------------------------*/

RUN pi-finalizar IN h-acomp.  

/*=====================================================================================================================================*/
PROCEDURE pi-posiciona-inicio:
    /*DEF VAR aux AS INTEGER.
    aux = 0.
    DO WHILE aux < 56:
        hWorkSheet:RANGE(STRING(c-coluna[1]) + STRING(cont_linha)):Interior:ColorIndex = aux.
        hWorkSheet:RANGE(STRING(c-coluna[1]) + STRING(cont_linha)):VALUE = aux.
        aux = aux + 1.
        cont_linha = cont_linha + 1.
    END.*/
    hExcel:RANGE('A1'):Select.
END PROCEDURE.

/*=====================================================================================================================================*/
PROCEDURE pi-inicia-excel:
    RUN pi-acompanhar IN h-acomp (INPUT "100-Criando arquivo Excel...").
    CREATE "Excel.Application" hExcel.
    IF (INTEGER(hExcel:VERSION) = 110) THEN /*office 2003*/
        ASSIGN c-modelo = SEARCH("layout\esacr001.xls").
    ELSE
        ASSIGN c-modelo = SEARCH("layout\esacr001.xlsx").
    hExcel:Workbooks:ADD(c-modelo).

END PROCEDURE.

/*=====================================================================================================================================*/
PROCEDURE pi-finaliza-excel:

    RUN pi-acompanhar IN h-acomp (INPUT "200-Finalizando arquivo Excel...").

    CASE tt-param.destino:
        WHEN 2 THEN DO:
            ASSIGN c-arquivo = tt-param.arquivo.
            ASSIGN c-arquivo = REPLACE(c-arquivo,"/","\").
            
            IF (tt-param.execucao = 1) THEN DO: //ON-LINE
                IF (INTEGER(hExcel:VERSION) <= 110) THEN DO: //office 2003
                    ASSIGN c-arquivo = ENTRY(1,c-arquivo,".") + ".xls".
                    IF SEARCH(c-arquivo) <> ? THEN DO:  //pesquisa se o arquivo ja existe no destino com o mesmo nome
                        ASSIGN c-arquivo = ENTRY(1,c-arquivo,".") + "-" + STRING(ETIME) + ".xls".   //opcao por renomear o anterior
                        //OS-DELETE SILENT VALUE(c-arquivo).                                        //opcao por deletar o anterior
                    END.
                    hExcel:Workbooks:ITEM(1):SaveAs(c-arquivo,1,,,NO,NO,NO) NO-ERROR.
                END.
                ELSE DO:    //office mais novo
                    ASSIGN c-arquivo = ENTRY(1,c-arquivo,".") + ".xlsx".
                    IF SEARCH(c-arquivo) <> ? THEN DO:
                        ASSIGN c-arquivo = ENTRY(1,c-arquivo,".") + "-" + STRING(ETIME) + ".xlsx".
                        //OS-DELETE SILENT VALUE(c-arquivo).
                    END.
                    hExcel:Workbooks:ITEM(1):SaveAs(c-arquivo,51,,,NO,NO,NO) NO-ERROR.
                END.
                hExcel:QUIT().
            END.
            ELSE DO:    //BATCH
                RUN piBuscaDirSpool (OUTPUT c-dir-spool).

                IF (INTEGER(hExcel:VERSION) <= 110) THEN DO: //office 2003
                    ASSIGN 
                        c-arquivo   =   ENTRY(1,c-arquivo,".") + ".xls"
                        c-arquivo   =   c-dir-spool + "\" + c-arquivo
                        c-arquivo   =   REPLACE(c-arquivo,"/","\").

                    IF SEARCH(c-arquivo) <> ? THEN DO:
                        ASSIGN c-arquivo = ENTRY(1,c-arquivo,".") + "-" + STRING(ETIME) + ".xls".
                        //OS-DELETE SILENT VALUE(c-arquivo).
                    END.
                    hExcel:Workbooks:ITEM(1):SaveAs(c-arquivo,1,,,NO,NO,NO) NO-ERROR.
                END.
                ELSE DO:    //office mais novo
                    ASSIGN 
                        c-arquivo   =   ENTRY(1,c-arquivo,".") + ".xlsx"
                        c-arquivo   =   c-dir-spool + "\" + c-arquivo
                        c-arquivo   =   REPLACE(c-arquivo,"/","\").

                    IF SEARCH(c-arquivo) <> ? THEN DO:
                        ASSIGN c-arquivo = ENTRY(1,c-arquivo,".") + "-" + STRING(ETIME) + ".xlsx".
                        //OS-DELETE SILENT VALUE(c-arquivo).
                    END.
                    hExcel:Workbooks:ITEM(1):SaveAs(c-arquivo,51,,,NO,NO,NO) NO-ERROR.
                END.
                hExcel:QUIT().
            END.        
        END.
        WHEN 3 THEN
            hExcel:VISIBLE = TRUE.
    END CASE.

    IF valid-handle(hWorksheet) THEN
        RELEASE OBJECT hWorksheet.
    IF valid-handle(hWorkbook) THEN
        RELEASE OBJECT hWorkbook.
    IF valid-handle(hExcel) THEN
        RELEASE OBJECT hExcel.
END PROCEDURE.

/*=====================================================================================================================================*/
PROCEDURE pi-tt-notas:
    ASSIGN cont_linha = cont_linha + 1.
    ASSIGN i-coluna = 0.

    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-notas.dt-emis-nota.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-notas.cod-estabel.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-notas.serie.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-notas.nr-nota-fis.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-notas.vl-tot-nota.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-notas.vl-retorno.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-notas.vl-cupom.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-notas.vl-acr.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-notas.vl-dif-nf-cup.
    
END PROCEDURE.

/*=====================================================================================================================================*/
PROCEDURE pi-tt-titulos:
    ASSIGN cont_linha = cont_linha + 1.
    ASSIGN i-coluna = 0.

    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.dat_emis_docto.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.cod_estab.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.cod_espec_docto.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.cod_ser_docto.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.cod_tit_acr.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.cod_parcela.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.cdn_cliente.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = emitente.nome-emit.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.val_origin_tit_acr.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.val_desc_tit_acr.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.val_abat_tit_acr.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.vl-cupom.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.vl-ftp.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-titulos.vl-dif-tit-cup.
    
END PROCEDURE.

/*=====================================================================================================================================*/
PROCEDURE pi-tt-cupons:
    ASSIGN cont_linha = cont_linha + 1.
    ASSIGN i-coluna = 0.

    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.dat_vda_cartao_cr.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.cod_estab.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.cod_espec_docto.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.cod_ser_docto.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.cod_tit_acr.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.cod_parcela.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.val_origin_tit_acr.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.serie_cupom.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.num_cupom.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-cupons.val_comprov_vda.

END PROCEDURE.

/*=====================================================================================================================================*/
PROCEDURE pi-tt-comparativo:

    ASSIGN cont_linha = cont_linha + 1.
    ASSIGN i-coluna = 0.

    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-comparativo.cod-estabel.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-comparativo.data.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-comparativo.vl-fat.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-comparativo.vl-acr * -1.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-comparativo.vl-dif.


END PROCEDURE.

/*=====================================================================================================================================*/
PROCEDURE pi-total-comparativo:
    ASSIGN cont_linha = 1.
    ASSIGN i-coluna = 0.

    ASSIGN i-coluna = i-coluna + 1.     //hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = tt-param.c-data.
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = "=SUBTOTAL(9," + STRING(c-coluna[i-coluna]) + STRING(linha-ini) + ":" + STRING(c-coluna[i-coluna]) + STRING(linha-fim) + ")".
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = "=SUBTOTAL(9," + STRING(c-coluna[i-coluna]) + STRING(linha-ini) + ":" + STRING(c-coluna[i-coluna]) + STRING(linha-fim) + ")".
    ASSIGN i-coluna = i-coluna + 1.     hExcel:RANGE(STRING(c-coluna[i-coluna]) + STRING(cont_linha)):VALUE = "=SUBTOTAL(9," + STRING(c-coluna[i-coluna]) + STRING(linha-ini) + ":" + STRING(c-coluna[i-coluna]) + STRING(linha-fim) + ")".

END PROCEDURE.

/*=====================================================================================================================================*/
PROCEDURE pi-bordas:
    hExcel:RANGE(STRING(c-coluna[coluna-ini]) + STRING(linha-ini) + ":" + STRING(c-coluna[coluna-fim]) + STRING(linha-fim)):Borders(3):LineStyle = 1.    /*linha superior*/
    hExcel:RANGE(STRING(c-coluna[coluna-ini]) + STRING(linha-ini) + ":" + STRING(c-coluna[coluna-fim]) + STRING(linha-fim)):Borders(2):LineStyle = 1.    /*coluna direita*/
    hExcel:RANGE(STRING(c-coluna[coluna-ini]) + STRING(linha-ini) + ":" + STRING(c-coluna[coluna-fim]) + STRING(linha-fim)):Borders(4):LineStyle = 1.    /*linha inferior*/
    hExcel:RANGE(STRING(c-coluna[coluna-ini]) + STRING(linha-ini) + ":" + STRING(c-coluna[coluna-fim]) + STRING(linha-fim)):Borders(1):LineStyle = 1.    /*coluna esquerda*/
END PROCEDURE.

/*=====================================================================================================================================*/
PROCEDURE piBuscaDirSpool:
    DEFINE OUTPUT PARAMETER pc-dir-spool AS CHARACTER NO-UNDO.

    FOR FIRST ped_exec NO-LOCK
        WHERE ped_exec.num_ped_exec = i-num-ped-exec-rpw:
        FOR FIRST servid_exec NO-LOCK
            WHERE servid_exec.cod_servid_exec = ped_exec.cod_servid_exec:
           ASSIGN pc-dir-spool = servid_exec.nom_dir_spool.
       END.
    END.

    IF pc-dir-spool = "" THEN
       ASSIGN pc-dir-spool = SESSION:TEMP-DIRECTORY.

    IF SUBSTRING(pc-dir-spool,LENGTH(pc-dir-spool),1) = "/" OR SUBSTRING(pc-dir-spool,LENGTH(pc-dir-spool),1) = "\" THEN
        ASSIGN OVERLAY(pc-dir-spool,LENGTH(pc-dir-spool),1) = "".
   
    FOR FIRST usuar_mestre NO-LOCK
        WHERE usuar_mestre.cod_usuario = ped_exec.cod_usuario:
        IF usuar_mestre.nom_subdir_spool_rpw <> "" THEN
            ASSIGN pc-dir-spool = pc-dir-spool + '/' + usuar_mestre.nom_subdir_spool_rpw.
    END.

    IF SUBSTRING(pc-dir-spool,LENGTH(pc-dir-spool),1) = "/" OR SUBSTRING(pc-dir-spool,LENGTH(pc-dir-spool),1) = "\" THEN
        ASSIGN OVERLAY(pc-dir-spool,LENGTH(pc-dir-spool),1) = "".

    ASSIGN pc-dir-spool = TRIM(pc-dir-spool).

    RETURN "OK":U.
END PROCEDURE.

/*=====================================================================================================================================*/
