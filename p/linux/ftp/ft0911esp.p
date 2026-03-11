/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i FT0911 2.00.00.030 } /*** 010030 ***/

&if "{&EMSFND_VERSION}" >= "1.00" &then
{include/i-license-manager.i ft0911 MFT}
&endif

{utp/ut-glob.i}
{cdp/cdcfgdis.i}
{cdp/cdcfgmat.i}


/*******************************************************************************
            EFETIVAÄ«O DO CANCELAMENTO OU INUTILIZAÄ«O DA NF-e
*******************************************************************************/


/*--- PAR∂METROS ---*/
DEFINE INPUT  PARAMETER p-r-nota-fiscal  AS ROWID       NO-UNDO.
DEFINE INPUT  PARAMETER p-stat-NFe       AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER p-protocolo-NFe  AS CHARACTER   NO-UNDO.

/*--- DEFINIÄÂES ---*/
DEFINE VARIABLE i-cont    AS INTEGER     NO-UNDO.
DEFINE VARIABLE raw-param AS RAW         NO-UNDO.

DEFINE VARIABLE h-bodi515      AS HANDLE      NO-UNDO.
DEFINE VARIABLE h-boin090      AS HANDLE      NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR i-num-ped-exec-rpw AS INT NO-UNDO.
DEFINE BUFFER bf-docum-est     FOR docum-est.
DEFINE BUFFER bf-nota-fiscal   FOR nota-fiscal.

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita        AS RAW.


&IF "{&bf_mat_versao_ems}":U >= "2.062":U &THEN
        DEFINE TEMP-TABLE tt-param-ft2200 NO-UNDO
            FIELD destino            AS INTEGER
            FIELD arquivo            AS CHAR FORMAT "x(35)"
            FIELD usuario            AS CHAR FORMAT "x(12)"
            FIELD data-exec          AS DATE
            FIELD hora-exec          AS INTEGER
            FIELD cod-estabel        LIKE nota-fiscal.cod-estabel
            FIELD serie              LIKE nota-fiscal.serie
            FIELD nr-nota-fis        LIKE nota-fiscal.nr-nota-fis
            FIELD dt-cancela         LIKE nota-fiscal.dt-cancela
            FIELD desc-cancela       LIKE nota-fiscal.desc-cancela
            FIELD arquivo-estoq      AS CHAR
            FIELD reabre-resumo      AS LOG 
            FIELD cancela-titulos    AS LOG 
            FIELD imprime-ajuda      AS LOG 
            FIELD l-valida-dt-saida  AS LOG.
    
&ELSE
    DEFINE TEMP-TABLE tt-param-ft2200 NO-UNDO
        FIELD destino            AS INTEGER
        FIELD arquivo            AS CHAR FORMAT "x(35)"
        FIELD usuario            AS CHAR FORMAT "x(12)"
        FIELD data-exec          AS DATE
        FIELD hora-exec          AS INTEGER
        FIELD cod-estabel        LIKE nota-fiscal.cod-estabel
        FIELD serie              LIKE nota-fiscal.serie
        FIELD nr-nota-fis        LIKE nota-fiscal.nr-nota-fis
        FIELD dt-cancela         LIKE nota-fiscal.dt-cancela
        FIELD desc-cancela       LIKE nota-fiscal.desc-cancela
        FIELD arquivo-estoq      AS CHAR
        FIELD reabre-resumo      AS LOG 
        FIELD cancela-titulos    AS LOG 
        FIELD imprime-ajuda      AS LOG 
        FIELD l-valida-dt-saida  AS LOG.
    
&ENDIF    


/* FT2200 */


/******** VALIDA XML CANCELAMENTO TSS ********/
&IF INTEGER(ENTRY(1,PROVERSION,".")) >= 10 &THEN

DEFINE TEMP-TABLE ttRetornaNotasTSS NO-UNDO
    FIELD ID   AS CHAR.

DEFINE TEMP-TABLE ttNFES3 NO-UNDO
    FIELD k          AS ROWID
    FIELD ID         AS CHAR.

DEFINE TEMP-TABLE ttNFE NO-UNDO
    FIELD k          AS ROWID
    FIELD PROTOCOLO  AS CHAR
    FIELD XML        AS CLOB
    FIELD XMLPROT    AS CHAR.

DEFINE TEMP-TABLE ttNFECANCELADA NO-UNDO
    FIELD k          AS ROWID
    FIELD PROTOCOLO  AS CHAR
    FIELD XML        AS CLOB
    FIELD XMLPROT    AS CHAR.

&ENDIF
/***** FIM - VALIDA XML CANCELAMENTO TSS *****/

/* RE0402 [definiá∆o RE0402.I3] */

define temp-table tt-param-re0402
    field destino            as INTEGER                                                                
    field arquivo            as char                                                                   
    field usuario            as char format "x(12)"                                                    
    field data-exec          as date                                                                   
    field hora-exec          as integer                                                                
    field da-data-ini        as date format "99/99/9999"                                               
    field da-data-fim        as date format "99/99/9999"                                               
    field c-esp-ini          as char                                                                   
    field c-esp-fim          as char                                                                   
    field c-ser-ini          as char                                                                   
    field c-ser-fim          as char                                                                   
    field c-num-ini          as char                                                                   
    field c-num-fim          as char                                                                   
    field i-emit-ini         as integer                                                                
    field i-emit-fim         as integer                                                                
    field c-nat-ini          as char                                                                   
    field c-nat-fim          as char                                                                   
    field c-estab-ini        as char                                                                   
    field c-estab-fim        as char                                                                   
    field da-atual-ini       as date format "99/99/9999"                                               
    field da-atual-fim       as date format "99/99/9999"                                               
    field c-usuario-ini      as char                                                                   
    field c-usuario-fim      as char                                                                   
    field i-tipo-ini         as integer                                                                
    field i-tipo-fim         as integer                                                                
    field l-of               as logical                                                                
    field l-saldo            as logical                                                                
    field l-desatual         as logical                                                                
    field l-custo-padrao     as logical                                                                
    field l-desatualiza-ap   as logical                                                                
    field l-desatualiza-aca  as logical                                                                
    field i-prc-custo        as integer                                                                
    field c-custo            as char                                                                   
    field c-destino          as char                                                                   
    field l-desatualiza-wms  as logical                                                                
    field l-desatualiza-draw as logical                                                                
    field l-desatualiza-cr   as logical                                                               
    FIELD l-imp-param        AS LOGICAL                                        
    FIELD mot-canc           AS CHAR FORMAT "x(08)".                           
                                                                                        
DEFINE TEMP-TABLE tt-digita-re0402
    FIELD serie-docto  LIKE docum-est.serie-docto
    FIELD nro-docto    LIKE docum-est.nro-docto
    FIELD cod-emitente LIKE docum-est.cod-emitente
    FIELD nat-operacao LIKE docum-est.nat-operacao.

def temp-table tt-erro-docum no-undo
    field i-sequen  as int              
    field cd-erro   as int
    field desc-erro as char format "x(255)". 

/*TDNOTG*/
/*DO  TRANS ON ERROR UNDO, LEAVE:*/

    FOR FIRST bf-nota-fiscal NO-LOCK
        WHERE ROWID(bf-nota-fiscal) = p-r-nota-fiscal:
    END.

    &if "{&bf_dis_versao_ems}" < "2.07" &then
        FIND FIRST sit-nf-eletro NO-LOCK 
             WHERE sit-nf-eletro.cod-estabel   = bf-nota-fiscal.cod-estabel
               AND sit-nf-eletro.cod-serie     = bf-nota-fiscal.serie
               AND sit-nf-eletro.cod-nota-fisc = bf-nota-fiscal.nr-nota-fis NO-ERROR.
        IF  NOT AVAIL sit-nf-eletro THEN
            RETURN "OK":U.
    &endif
    
    IF ((p-stat-NFe = "101":U  OR               /* 101 -> Cancelamento de NF-e homologado*/                                                
         p-stat-NFe = "151":U  OR               /* 151 -> Cancelamento de NF-e homologado fora de prazo*/                                  
         p-stat-NFe = "155":U)                  /* 155 -> Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
    OR   p-stat-NFe = "102":U)                  /* 102 -> Inutilizaá∆o de n£mero homologado */
    AND ( &if "{&bf_dis_versao_ems}" >= "2.07" &then
             (bf-nota-fiscal.idi-sit-nf-eletro   = 12   /* 12  -> NF-e em processo de Cancelamento  */
          OR  bf-nota-fiscal.idi-sit-nf-eletro   = 13)  /* 13  -> NF-e em processo de Inutilizaá∆o  */
          &else
             (sit-nf-eletro.idi-sit-nf-eletro = 12   /* 12  -> NF-e em processo de Cancelamento  */
          OR  sit-nf-eletro.idi-sit-nf-eletro = 13)  /* 13  -> NF-e em processo de Inutilizaá∆o  */
          &endif )
          
    THEN DO:

        IF  NOT AVAIL estabelec THEN
            FOR FIRST estabelec FIELDS(&if "{&bf_dis_versao_ems}" >= "2.07" &then estabelec.idi-tip-emis-nf-eletro &else char-1 &endif) NO-LOCK
                WHERE estabelec.cod-estabel = bf-nota-fiscal.cod-estabel:
            END.

        /***********************************************
        Atualizar status da NF-e para quando Emissao em 
                          HOMOLOGACAO
        ***********************************************/

        IF  &if "{&bf_dis_versao_ems}" >= "2.07" &then
             estabelec.idi-tip-emis-nf-eletro    = 2  /* Processo Emiss∆o NF-e - CD0403 [ 2 - Homologaá∆o] */
            &else
             INT(SUBSTR(estabelec.char-1,168,1)) = 2  /* Processo Emiss∆o NF-e - CD0403 [ 2 - Homologaá∆o] */
            &endif
        THEN DO:

            /* Atualiza Situacao NF-e */

            &if "{&bf_dis_versao_ems}" >= "2.07" &then            
                FIND CURRENT bf-nota-fiscal EXCLUSIVE-LOCK NO-ERROR.
                ASSIGN bf-nota-fiscal.idi-sit-nf-eletro = (IF (p-stat-NFe = "101":U  /*101 Cancelamento de NF-e homologado*/                                                
                                                           OR  p-stat-NFe = "151":U  /*151 Cancelamento de NF-e homologado fora de prazo*/                                  
                                                           OR  p-stat-NFe = "155":U) /*155 Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
                                                           THEN 6 /*6 Documento Cancelado*/
                                                           ELSE IF p-stat-NFe = "102":U
                                                                THEN 7 /*7 Documento Inutilizado*/
                                                                ELSE bf-nota-fiscal.idi-sit-nf-eletro).
                FIND CURRENT bf-nota-fiscal NO-LOCK NO-ERROR.
            &else
                FIND CURRENT sit-nf-eletro EXCLUSIVE-LOCK NO-ERROR.
                ASSIGN sit-nf-eletro.idi-sit-nf-eletro  = (IF (p-stat-NFe = "101":U  /*101 Cancelamento de NF-e homologado*/                                                
                                                           OR  p-stat-NFe = "151":U  /*151 Cancelamento de NF-e homologado fora de prazo*/                                  
                                                           OR  p-stat-NFe = "155":U) /*155 Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
                                                           THEN 6 /*6 Documento Cancelado*/
                                                           ELSE IF p-stat-NFe = "102":U
                                                                THEN 7 /*7 Documento Inutilizado*/
                                                                ELSE sit-nf-eletro.idi-sit-nf-eletro).
                FIND CURRENT sit-nf-eletro NO-LOCK NO-ERROR.
            &endif
            
            RUN piAtualizaSituacoesNF-e.

            
        END.
        /***********************************************
                           PRODUCAO
        ***********************************************/
        ELSE IF &if "{&bf_dis_versao_ems}" >= "2.07" &then
                 estabelec.idi-tip-emis-nf-eletro    = 3  /* Processo Emiss∆o NF-e - CD0403 [ 3 - Produá∆o] */
                &else
                 INT(SUBSTR(estabelec.char-1,168,1)) = 3  /* Processo Emiss∆o NF-e - CD0403 [ 3 - Produá∆o] */
                &endif
             THEN DO:  
        
            IF  bf-nota-fiscal.dt-cancela = ? THEN DO: /* N∆o est† cancelada no sistema */

                /*NF-e FT*/
                IF (bf-nota-fiscal.ind-tip-nota <> 8  /* 8 - Origem no Recebimento */
                
                OR ( bf-nota-fiscal.ind-tip-nota = 8  /* NOTA DE CRêDITO DE ATIVO GERADO VIA FT4003 COM NATUREZA DE ENTRADA E FUNCAO ESPECIAL "NFEFT4003" - CANCELAMENTO VIA FT2200 */
                AND  bf-nota-fiscal.int-2        = 4003
                AND  CAN-FIND (FIRST funcao
                               WHERE funcao.cd-funcao = "spp-NFEFT4003":U
                                 AND funcao.ativo) )
                     
                OR (bf-nota-fiscal.ind-tip-nota = 4   /* NOTA DE CRêDITO DE ATIVO GERADO VIA RI0207 - CANCELAMENTO VIA FT2200 */
                AND bf-nota-fiscal.int-2        = 207)) THEN DO:
                
                    FOR EACH tt-param-ft2200:
                        DELETE tt-param-ft2200.
                    END.
    
                    FIND FIRST para-fat NO-LOCK NO-ERROR.
    
                    IF  NOT AVAIL sit-nf-eletro THEN
                        FOR FIRST sit-nf-eletro NO-LOCK
                            WHERE sit-nf-eletro.cod-estabel  = bf-nota-fiscal.cod-estabel
                              AND sit-nf-eletro.cod-serie    = bf-nota-fiscal.serie
                              AND sit-nf-eletro.cod-nota-fis = bf-nota-fiscal.nr-nota-fis:
                        END.
    
                    CREATE tt-param-ft2200.
                    ASSIGN tt-param-ft2200.usuario             = c-seg-usuario
                           tt-param-ft2200.destino             = 2 /* arquivo */
                           tt-param-ft2200.data-exec           = today
                           tt-param-ft2200.hora-exec           = time
                           tt-param-ft2200.cod-estabel         = bf-nota-fiscal.cod-estabel
                           tt-param-ft2200.serie               = bf-nota-fiscal.serie
                           tt-param-ft2200.nr-nota-fis         = bf-nota-fiscal.nr-nota-fis
                           tt-param-ft2200.dt-cancela          = TODAY
                           tt-param-ft2200.desc-cancela        = "Nota Fiscal cancelada automaticamente pelo sistema":U
                           tt-param-ft2200.arquivo-estoq       = IF i-num-ped-exec-rpw <> 0 THEN "FT2100.LST":U ELSE SESSION:TEMP-DIRECTORY + "FT2100.LST":U
                           tt-param-ft2200.arquivo             = IF i-num-ped-exec-rpw <> 0 THEN "FT2200.LST":U ELSE SESSION:TEMP-DIRECTORY + "FT2200.LST":U
                           tt-param-ft2200.l-valida-dt-saida   = NO /*faz gerar erro no cancelamento da nota que tem Data Sa°da de Mercadoria informada*/
                           tt-param-ft2200.imprime-ajuda       = YES
                           /*Parametros salvos no momento da solicitaá∆o de cancelamento/inutlizaá∆o (gravados no ft2200/ft2201)*/
                           tt-param-ft2200.reabre-resumo       = (IF NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 1
                                                                  THEN (ENTRY(1,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                  ELSE (SUBSTRING(para-fat.char-2, 41, 1) = "Y":U))
                           tt-param-ft2200.cancela-titulos     = (IF NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 2
                                                                  THEN (ENTRY(2,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                  ELSE YES) NO-ERROR.
    
                    RAW-TRANSFER tt-param-ft2200 TO raw-param.
                    RUN ftp/ft2200rp.p(INPUT raw-param, INPUT TABLE tt-raw-digita).
                    
                    RUN piAtualizaSituacoesNF-e.
    
                END.
                /*NF-e gerada no RE*/
                ELSE DO:
    
                    IF (p-stat-NFe = "101":U    /*101 Cancelamento de NF-e homologado*/                                                
                    OR  p-stat-NFe = "151":U    /*151 Cancelamento de NF-e homologado fora de prazo*/                                  
                    OR  p-stat-NFe = "155":U)   /*155 Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
                    THEN DO:
    
                        FOR EACH tt-param-re0402:
                            DELETE tt-param-re0402.
                        END.
                        FOR EACH tt-digita-re0402:
                            DELETE tt-digita-re0402.
                        END.
                        FOR EACH tt-raw-digita:
                            DELETE tt-raw-digita.
                        END.
    
                        IF  NOT AVAIL sit-nf-eletro THEN
                            FOR FIRST sit-nf-eletro NO-LOCK
                                WHERE sit-nf-eletro.cod-estabel  = bf-nota-fiscal.cod-estabel
                                  AND sit-nf-eletro.cod-serie    = bf-nota-fiscal.serie
                                  AND sit-nf-eletro.cod-nota-fis = bf-nota-fiscal.nr-nota-fis:
                            END.
    
                        CREATE tt-param-re0402.
                        ASSIGN tt-param-re0402.usuario            = c-seg-usuario
                               tt-param-re0402.destino            = 2 /* arquivo */
                               tt-param-re0402.data-exec          = TODAY
                               tt-param-re0402.hora-exec          = TIME
                               tt-param-re0402.arquivo            = IF i-num-ped-exec-rpw <> 0 THEN "RE0402.LST":U ELSE SESSION:TEMP-DIRECTORY + "RE0402.LST":U
                               /*Parametros salvos no momento da solicitaá∆o de desatualizaá∆o (gravados no re0402)*/
                               tt-param-re0402.l-of               = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 1
                                                                     AND ENTRY(1,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN (ENTRY(1,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                     ELSE NO)
                               tt-param-re0402.l-saldo            = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 2
                                                                     AND ENTRY(2,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN (ENTRY(2,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                     ELSE YES)
                               tt-param-re0402.l-desatual         = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 3
                                                                     AND ENTRY(3,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN (ENTRY(3,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                     ELSE YES)
                               tt-param-re0402.l-custo-padrao     = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 4
                                                                     AND ENTRY(4,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN (ENTRY(4,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                     ELSE NO)
                               tt-param-re0402.l-desatualiza-ap   = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 5
                                                                     AND ENTRY(5,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN (ENTRY(5,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                     ELSE NO)
                               tt-param-re0402.l-desatualiza-aca  = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 6
                                                                     AND ENTRY(6,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN (ENTRY(6,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                     ELSE NO)
                               tt-param-re0402.l-desatualiza-wms  = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 7
                                                                     AND ENTRY(7,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN (ENTRY(7,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                     ELSE NO)
                               tt-param-re0402.l-desatualiza-draw = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 8
                                                                     AND ENTRY(8,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN (ENTRY(8,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                     ELSE NO)
                               tt-param-re0402.l-desatualiza-cr   = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 9
                                                                     AND ENTRY(9,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN (ENTRY(9,sit-nf-eletro.cod-livre-1,"#") = "S")
                                                                     ELSE NO)
                               tt-param-re0402.i-prc-custo        = (IF  AVAIL sit-nf-eletro
                                                                     AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 10
                                                                     AND ENTRY(10,sit-nf-eletro.cod-livre-1,"#") <> ""
                                                                     THEN INT(ENTRY(10,sit-nf-eletro.cod-livre-1,"#"))
                                                                     ELSE 2).
                        
                        FOR FIRST bf-docum-est NO-LOCK
                            WHERE bf-docum-est.serie-docto  = bf-nota-fiscal.serie
                              AND bf-docum-est.nro-docto    = bf-nota-fiscal.nr-nota-fis
                              AND bf-docum-est.cod-emitente = bf-nota-fiscal.cod-emitente
                              AND bf-docum-est.nat-operacao = bf-nota-fiscal.nat-operacao:
                        END.
    
                        CREATE tt-digita-re0402.
                        ASSIGN tt-digita-re0402.cod-emitente = bf-docum-est.cod-emitente
                               tt-digita-re0402.serie-docto  = bf-docum-est.serie-docto
                               tt-digita-re0402.nro-docto    = bf-docum-est.nro-docto
                               tt-digita-re0402.nat-operacao = bf-docum-est.nat-operacao.
    
                        RAW-TRANSFER tt-param-re0402 TO raw-param.
    
                        FOR EACH tt-digita-re0402:
                            CREATE tt-raw-digita.
                            RAW-TRANSFER tt-digita-re0402 to tt-raw-digita.raw-digita.
                        END.
    
                        RUN rep/re0402rp.p (INPUT raw-param, INPUT TABLE tt-raw-digita).
    
                        RUN piAtualizaSituacoesNF-e.

                        IF  bf-nota-fiscal.dt-cancela = ? AND
                            (p-stat-NFe = "101":U OR    /*101 Cancelamento de NF-e homologado*/                                                
                             p-stat-NFe = "151":U OR    /*151 Cancelamento de NF-e homologado fora de prazo*/                                  
                             p-stat-NFe = "155":U) AND  /*155 Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
                            &if "{&bf_dis_versao_ems}" >= "2.07" &then
                             bf-nota-fiscal.idi-sit-nf-eletro = 3
                            &else
                             sit-nf-eletro.idi-sit-nf-eletro = 3
                            &endif AND
                            &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                estabelec.idi-tip-emis-nf-eletro    = 3  /* Processo Emiss∆o NF-e - CD0403 [ 3 - Produá∆o] */
                            &else
                                INT(SUBSTR(estabelec.char-1,168,1)) = 3  /* Processo Emiss∆o NF-e - CD0403 [ 3 - Produá∆o] */
                            &endif THEN DO:
                                &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                 FIND CURRENT bf-nota-fiscal EXCLUSIVE-LOCK NO-ERROR.
                                 bf-nota-fiscal.idi-sit-nf-eletro = 12.
                                 FIND CURRENT bf-nota-fiscal NO-LOCK NO-ERROR.
                                &else
                                 FIND CURRENT sit-nf-eletro EXCLUSIVE-LOCK NO-ERROR.
                                 sit-nf-eletro.idi-sit-nf-eletro = 12.
                                 FIND CURRENT sit-nf-eletro NO-LOCK NO-ERROR.
                                &endif
                            /*
                            Se o documento tever origem no recebimento e no TSS estiver como Cancelado ou Inutilizado,
                            voltar ao status de processamento porque houve algum problema na desatualizacao do recebimento 
                            3 Uso Autorizado, retornar para 12 Se estiver como Em Processo de Cancelamento
                            5 Documento Rejeitado, retornar para 13 Em Processo de Inutilizaá∆o */
                        END.
                    END. /*fim p-stat-NFe = "101"*/
    
                    /* 102 -> Inutilizaá∆o de n£mero homologado */
                    IF  p-stat-NFe = "102":U THEN DO:
    
                        /*---
                        Nota Fiscal gerada no Recebimento
                        Retornando como Rejeitada, esta nota deve ser Inutilizada.
                        No BOIN090.m27, envia XML de Inutilizaá∆o.
                        Ao retornar como Inutilizaá∆o de N£mero Homologado - 102, fazer o restante da atualizaá∆o, conforme BOIN090.m27.
                        ---*/
                        
                        FIND CURRENT bf-nota-fiscal EXCLUSIVE-LOCK NO-ERROR.
                        ASSIGN bf-nota-fiscal.dt-cancela = TODAY.
                        FIND CURRENT bf-nota-fiscal NO-LOCK NO-ERROR.
                        
                        FOR EACH it-nota-fisc
                           WHERE it-nota-fisc.cod-estabel = bf-nota-fiscal.cod-estabel
                             AND it-nota-fisc.serie       = bf-nota-fiscal.serie
                             AND it-nota-fisc.nr-nota-fis = bf-nota-fiscal.nr-nota-fis EXCLUSIVE-LOCK:
        
                            ASSIGN it-nota-fisc.dt-cancela   = bf-nota-fiscal.dt-cancela
                                   it-nota-fisc.ind-sit-nota = bf-nota-fiscal.ind-sit-nota.
                        END.
                        FIND CURRENT it-nota-fisc NO-LOCK NO-ERROR.

                        FOR FIRST bf-docum-est EXCLUSIVE-LOCK
                            WHERE bf-docum-est.serie-docto  = bf-nota-fiscal.serie
                              AND bf-docum-est.nro-docto    = bf-nota-fiscal.nr-nota-fis
                              AND bf-docum-est.cod-emitente = bf-nota-fiscal.cod-emitente
                              AND bf-docum-est.nat-operacao = bf-nota-fiscal.nat-operacao:
                            ASSIGN bf-docum-est.log-1 = NO.  /* Nao atualizado no Faturamento */
                        END.
                        FIND CURRENT bf-docum-est NO-LOCK NO-ERROR.
                        
                        RUN piAtualizaSituacoesNF-e.
                        
                    END. /*fim p-stat-NFe = "102"*/
    
                END.  /*fim NF gerada no RE*/
                
                /*--- CASO N«O SEJA ATUALIZADO O NRO DO PROTOCOLO, ATUALIZAR ---*/
                FIND CURRENT bf-nota-fiscal NO-LOCK NO-ERROR.
    
                IF  bf-nota-fiscal.dt-cancela <> ? THEN DO:
    
                    FOR EACH ret-nf-eletro EXCLUSIVE-LOCK
                       WHERE ret-nf-eletro.cod-estabel = bf-nota-fiscal.cod-estabel
                         AND ret-nf-eletro.cod-serie   = bf-nota-fiscal.serie
                         AND ret-nf-eletro.nr-nota-fis = bf-nota-fiscal.nr-nota-fis
                          BY ret-nf-eletro.dat-ret DESC
                          BY ret-nf-eletro.hra-ret DESC:
    
                        IF ((ret-nf-eletro.cod-msg = "101":U OR   /*101 Cancelamento de NF-e homologado*/                                                
                             ret-nf-eletro.cod-msg = "151":U OR   /*151 Cancelamento de NF-e homologado fora de prazo*/                                  
                             ret-nf-eletro.cod-msg = "155":U)     /*155 Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
                        OR   ret-nf-eletro.cod-msg = "102":U)
                        AND ( &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                  ret-nf-eletro.cod-protoc  = ""
                              OR  ret-nf-eletro.cod-protoc  = ?
                              &else
                                  ret-nf-eletro.cod-livre-1 = ""
                              OR  ret-nf-eletro.cod-livre-1 = ?                        
                              &endif ) THEN DO:
    
                            &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                ASSIGN ret-nf-eletro.cod-protoc  = TRIM(p-protocolo-NFe).
                            &else
                                ASSIGN ret-nf-eletro.cod-livre-1 = TRIM(p-protocolo-NFe).
                            &endif
                            
                            LEAVE.
                        END.
                    END.
                END.
                /*---*/
            END. /*fim IF  bf-nota-fiscal.dt-cancela = ?*/

            /***********************************************
            ATUALIZAÄÂES DA SIF NF-e E PROTOCOLOCO DE CANCEL
                     (para os casos de Resumo)
            ***********************************************/
            ELSE DO: /*Nota j† est† cancelada no sistema*/

                /*Atualizar o protocolo, caso ainda n∆o exista ou seja diferente do protocolo atual(de autorizacao de uso)
                IF &if "{&bf_dis_versao_ems}" >= "2.07" &then
                     (bf-nota-fiscal.cod-protoc              = "" OR bf-nota-fiscal.cod-protoc              <> p-protocolo-NFe)
                   &else
                     (SUBSTRING(bf-nota-fiscal.char-1,97,15) = "" OR SUBSTRING(bf-nota-fiscal.char-1,97,15) <> p-protocolo-NFe)
                   &endif
                THEN DO:*/
                
                    RUN piAtualizaSituacoesNF-e.
                /*END.*/
            END.

        END. /*fim PRODUÄ«O*/
    END.
/*END.*/ /*fim DO  TRANS*/

RELEASE sit-nf-eletro.
RELEASE bf-nota-fiscal.
RELEASE it-nota-fisc.
RELEASE bf-docum-est.
RELEASE ret-nf-eletro.

RETURN "OK":U.

PROCEDURE piAtualizaSituacoesNF-e :

    DEFINE VARIABLE i-nova-sit-NFe AS INTEGER     NO-UNDO.
    
    FIND CURRENT bf-nota-fiscal EXCLUSIVE-LOCK NO-ERROR.

    /*
    Se n∆o foi possivel cancelar no ft2200 ou re0402, voltar ao status antigo:
    12 Se estiver como Em Processo de Cancelamento, retornar para 3 Uso Autorizado
    13 Se estiver como Em Processo de Inutilizaá∆o, retornar para 5 Documento Rejeitado]
    */
    IF  bf-nota-fiscal.dt-cancela = ? THEN DO:

        &if "{&bf_dis_versao_ems}" >= "2.07" &then
            ASSIGN i-nova-sit-NFe = (IF bf-nota-fiscal.idi-sit-nf-eletro = 12
                                     THEN 3
                                     ELSE IF bf-nota-fiscal.idi-sit-nf-eletro = 13
                                          THEN 5
                                          ELSE bf-nota-fiscal.idi-sit-nf-eletro).
        &else
            ASSIGN i-nova-sit-NFe = (IF sit-nf-eletro.idi-sit-nf-eletro = 12
                                     THEN 3
                                     ELSE IF sit-nf-eletro.idi-sit-nf-eletro = 13
                                          THEN 5
                                          ELSE sit-nf-eletro.idi-sit-nf-eletro).
        &endif
    END.
    /*Cancelou, ent∆o atualizar para 6 Documento Cancelado ou 7 Documento Inutilizado*/
    ELSE DO:

        &if "{&bf_dis_versao_ems}" >= "2.07" &then
            ASSIGN i-nova-sit-NFe = (IF bf-nota-fiscal.idi-sit-nf-eletro = 12
                                     THEN 6
                                     ELSE IF bf-nota-fiscal.idi-sit-nf-eletro = 13
                                          THEN 7
                                          ELSE bf-nota-fiscal.idi-sit-nf-eletro).
        &else
            ASSIGN i-nova-sit-NFe = (IF sit-nf-eletro.idi-sit-nf-eletro = 12
                                     THEN 6
                                     ELSE IF sit-nf-eletro.idi-sit-nf-eletro = 13
                                          THEN 7
                                          ELSE sit-nf-eletro.idi-sit-nf-eletro).
        &endif
    END.
        
    /*FT - Atualiza Situaá∆o*/
    &if "{&bf_dis_versao_ems}" >= "2.07" &then
        ASSIGN bf-nota-fiscal.idi-sit-nf-eletro = i-nova-sit-NFe.
    &else
        FIND CURRENT sit-nf-eletro EXCLUSIVE-LOCK NO-ERROR.

        ASSIGN sit-nf-eletro.idi-sit-nf-eletro = i-nova-sit-NFe.
        
        FIND CURRENT sit-nf-eletro NO-LOCK NO-ERROR.
    &endif
    
    IF  bf-nota-fiscal.ind-tip-nota = 8 THEN DO: /* Recebimento */
        /*RE - Atualiza Situaá∆o*/
        FOR FIRST bf-docum-est EXCLUSIVE-LOCK
            WHERE bf-docum-est.serie-docto  = bf-nota-fiscal.serie
              AND bf-docum-est.nro-docto    = bf-nota-fiscal.nr-nota-fis
              AND bf-docum-est.cod-emitente = bf-nota-fiscal.cod-emitente
              AND bf-docum-est.nat-operacao = bf-nota-fiscal.nat-operacao:
    
            &if "{&bf_dis_versao_ems}" >= "2.071" &then
                ASSIGN bf-docum-est.idi-sit-nf-eletro     = i-nova-sit-NFe.
            &else
                ASSIGN OVERLAY(bf-docum-est.char-1,154,2) = STRING(i-nova-sit-NFe).
            &endif
        END.
        FIND CURRENT bf-docum-est NO-LOCK NO-ERROR.
    END.

    /* Se n∆o foi possivel cancelar no ft2200 ou re0402, ent∆o n∆o continuar*/
    IF  bf-nota-fiscal.dt-cancela = ? THEN 
        RETURN "OK":U.

    &if "{&bf_dis_versao_ems}" >= "2.07" &then
        ASSIGN bf-nota-fiscal.cod-protoc = TRIM(p-protocolo-NFe).
    &else
        ASSIGN OVERLAY(bf-nota-fiscal.char-1,97,15) = TRIM(p-protocolo-NFe).                
    &endif
    
    /* Grava ret-nf-eletro */
    CREATE ret-nf-eletro.
    ASSIGN ret-nf-eletro.cod-estabel      = bf-nota-fiscal.cod-estabel
           ret-nf-eletro.cod-serie        = bf-nota-fiscal.serie
           ret-nf-eletro.nr-nota-fis      = bf-nota-fiscal.nr-nota-fis
           ret-nf-eletro.cod-msg          = p-stat-NFe
           ret-nf-eletro.dat-ret          = TODAY
           ret-nf-eletro.hra-ret          = REPLACE(STRING(TIME, "HH:MM:SS"),":","")
           ret-nf-eletro.idi-orig-solicit = 3 /* Inutilizaá∆o numeraá∆o */
           ret-nf-eletro.log-ativo        = YES
           &if "{&bf_dis_versao_ems}" >= "2.07" &then
           ret-nf-eletro.cod-protoc       = p-protocolo-NFe
           &else
           ret-nf-eletro.cod-livre-1      = p-protocolo-NFe
           &endif .
           
    /* Atualiza nota-fisc-adc (CD4035) */
    IF  NOT VALID-HANDLE(h-bodi515) THEN
        RUN dibo/bodi515.p PERSISTENT SET h-bodi515.

    IF  VALID-HANDLE(h-bodi515) THEN DO:
        RUN cancelaNotaFiscAdc IN h-bodi515 (INPUT bf-nota-fiscal.cod-estabel,
                                             INPUT bf-nota-fiscal.serie,
                                             INPUT bf-nota-fiscal.nr-nota-fis,
                                             INPUT bf-nota-fiscal.cod-emitente,
                                             INPUT bf-nota-fiscal.nat-operacao,
                                             INPUT &IF "{&bf_dis_versao_ems}":U >= "2.07":U &THEN
                                                        bf-nota-fiscal.idi-sit-nf-eletro
                                                   &ELSE
                                                        sit-nf-eletro.idi-sit-nf-eletro
                                                   &ENDIF).
        DELETE PROCEDURE h-bodi515.
    END.

    ASSIGN h-bodi515 = ?.
    /* Fim - Atualiza nota-fisc-adc (CD4035) */
    
    /* Atualiza msg cancelamento nota fiscal */
    FOR FIRST msg-ret-nf-eletro FIELDS(dsl-msg cod-msg)
        WHERE ( &if "{&bf_dis_versao_ems}" >= "2.07" &then
                    bf-nota-fiscal.idi-sit-nf-eletro   = 6
                &else
                    sit-nf-eletro.idi-sit-nf-eletro = 6 
                &endif                                                
                AND (msg-ret-nf-eletro.cod-msg = "101":U OR msg-ret-nf-eletro.cod-msg = "151":U OR msg-ret-nf-eletro.cod-msg = "155":U) ) OR
              ( &if "{&bf_dis_versao_ems}" >= "2.07" &then
                    bf-nota-fiscal.idi-sit-nf-eletro   = 7
                &else
                    sit-nf-eletro.idi-sit-nf-eletro = 7 
                &endif                                    
                AND msg-ret-nf-eletro.cod-msg = "102":U ) NO-LOCK:
    
        ASSIGN bf-nota-fiscal.desc-cancela = TRIM(msg-ret-nf-eletro.dsl-msg) + ".  Data/Hora: ":U + 
                                          STRING(TODAY) + ".  Protocolo: ":U + 
                                          &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                              ret-nf-eletro.cod-protoc  
                                          &else
                                              ret-nf-eletro.cod-livre-1
                                          &endif.                                          
        
        IF  CAN-FIND (FIRST funcao NO-LOCK
                      WHERE funcao.cd-funcao = "SPP-INTEG-TSS"
                        AND funcao.ativo) THEN
            IF  NOT CAN-FIND (FIRST funcao NO-LOCK
                              WHERE funcao.cd-funcao = "SPP-INTEG-TSS-SINCRONO":U
                                AND funcao.ativo) THEN
                /*--- Motivo de Cancelamento/Inutilizaá∆o enviado Ö Sefaz - mensagens padr∆o do TSS ---*/
                ASSIGN bf-nota-fiscal.desc-cancela = bf-nota-fiscal.desc-cancela +
                                                     ".  Justificativa na SEFAZ: ":U + 
                                                     IF (msg-ret-nf-eletro.cod-msg = "101":U
                                                     OR  msg-ret-nf-eletro.cod-msg = "151":U
                                                     OR  msg-ret-nf-eletro.cod-msg = "155":U)
                                                     THEN "Cancelamento de nota fiscal eletronica por emissao indevida":U
                                                     ELSE "Cancelamento de nota fiscal eletronica por emissao indevida, sem transmissao a SEFAZ":U.
            ELSE DO:
                IF (msg-ret-nf-eletro.cod-msg = "101":U
                OR  msg-ret-nf-eletro.cod-msg = "151":U
                OR  msg-ret-nf-eletro.cod-msg = "155":U)
                THEN
                    {utp/ut-liter.i "Nota_fiscal_cancelada_automaticamente_pela_desatualizaá∆o_de_documentos"}
                ELSE
                    {utp/ut-liter.i "Nota_fiscal_eletrìnica_inutilizada_automaticamente_ap¢s_rejeiá∆o"}

                ASSIGN bf-nota-fiscal.desc-cancela = bf-nota-fiscal.desc-cancela +
                                                     ".  Justificativa na SEFAZ: ":U + 
                                                     IF  bf-nota-fiscal.ind-tip-nota <> 8
                                                     THEN IF AVAIL sit-nf-eletro AND NUM-ENTRIES(sit-nf-eletro.cod-livre-1,"#") >= 3 
                                                          THEN ENTRY(3,sit-nf-eletro.cod-livre-1,"#")
                                                          ELSE ""
                                                     ELSE RETURN-VALUE .
            END.
                                
        /*---*/
    END.
    /* Fim - Atualiza msg cancelamento nota fiscal */
    
    FIND CURRENT bf-nota-fiscal NO-LOCK NO-ERROR.

    IF  bf-nota-fiscal.ind-tip-nota = 8  AND /* Nota origem Recebimento */
        &IF "{&bf_dis_versao_ems}" >= "2.07" &THEN
            bf-nota-fiscal.idi-sit-nf-eletro
        &ELSE
            sit-nf-eletro.idi-sit-nf-eletro
        &ENDIF  = 7 THEN DO: /* Documento inutilizado */
        
        /* Cria doc-fiscal de NF-e que foi inutilizada */
        IF  NOT VALID-HANDLE(h-boin090) THEN
            RUN inbo/boin090.p PERSISTENT SET h-boin090.
    
        IF  VALID-HANDLE(h-boin090) THEN DO:
            RUN pi-criaDocumentoFiscal IN h-boin090 (INPUT ROWID(bf-nota-fiscal)).
            DELETE PROCEDURE h-boin090.
        END.
    

        
           

            IF AVAIL bf-docum-est AND bf-docum-est.log-1 = NO THEN DO:

                IF  CONNECTED ("emsgra") THEN DO:
                    RUN ggp/ggapi108.p (input rowid(bf-docum-est)).

                

                END.

            END.

    
        ASSIGN h-boin090 = ?.
        /* Fim - Cria doc-fiscal de NF-e que foi inutilizada */


    END. 

    
    
END PROCEDURE.
