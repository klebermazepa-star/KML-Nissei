/** Includes Office **/
{office/office-defs.i}
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i FT0518F1 2.00.00.023 } /*** 010023 ***/

/*
&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i FT0518F1 MFT}
&ENDIF
*/

{ftp/ft0518f.i5}
{include/tt-edit.i}
{include/pi-edit.i}

{include/i-epc200.i "FT0518F1":U}

{ftp/ft0518rp.i1} /* Definiá∆o temp-table ttCaracteres como SHARED */

{adapters/xml/ep2/axsep017extradeclarations.i} /* definiá∆o FUNCTION fn-tira-acento */

DEF TEMP-TABLE ttLinha NO-UNDO
    FIELD sequenciaLinha  AS INT 
    FIELD codigoColuna    AS CHAR
    FIELD conteudoCampo   AS CHAR
    INDEX idx1 IS PRIMARY UNIQUE sequenciaLinha codigoColuna
    INDEX idx2 codigoColuna
    INDEX idx3 sequenciaLinha DESC.

DEF INPUT  PARAM TABLE FOR ttDanfe.
DEF INPUT  PARAM TABLE FOR ttDanfeItem.
DEF INPUT  PARAM pcArq         AS CHAR NO-UNDO.
DEF INPUT  PARAM cModeloDanfe  AS CHAR NO-UNDO.
DEF INPUT  PARAM pSemWord      AS LOG  NO-UNDO.

DEF VAR cLinha      AS CHAR       NO-UNDO.
DEF VAR cSeqAux     AS CHAR       NO-UNDO.
DEF VAR iSeqTotal   AS INT        NO-UNDO.
DEF VAR iPagTotal   AS INT        NO-UNDO.
DEF VAR iPagAtual   AS INT        NO-UNDO.
DEF VAR iSeqTtLinha AS INT        NO-UNDO.
DEF VAR cArqAux     AS CHAR       NO-UNDO.
DEF VAR ch-app-word AS office.iface.word.WordWrapper NO-UNDO.
DEF VAR lFirst      AS LOG        NO-UNDO.
def var c-tracejado1 as character format 'x(180)' no-undo.
def var c-tracejado2 as character format 'x(249)' no-undo.
def var lEmiteTracejado as logical no-undo.

DEF VAR l-danfe         AS LOG  NO-UNDO.
DEF VAR c-danfeaux      AS CHAR NO-UNDO.
DEF VAR c-chave-nota    AS CHAR NO-UNDO.
DEF VAR c-cod-estabel   AS CHAR NO-UNDO.
DEF VAR c-serie-aux     AS CHAR NO-UNDO.
DEF VAR c-serie-1       AS CHAR NO-UNDO.
DEF VAR c-nr-nota-fis   AS CHAR NO-UNDO.
DEF VAR c-nr-nota-fis-1 AS CHAR NO-UNDO.
DEF VAR c-arquivo-pdf   AS CHAR NO-UNDO.

DEFINE VARIABLE cCodProduto     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cDescProduto    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cNCM            AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cCST            AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cCFOP           AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cUn             AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cQuantidade     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cValorUni       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cValorTotal     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cBaseCalcIcms   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cValorIcms      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cValorIpi       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cAliquotaIcms   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cAliquotaIpi    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cBaseCalcIcmsST AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cValorIcmsST    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cInfCompl       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cInfComplAux    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cSeparador      AS CHARACTER   NO-UNDO.

DEFINE VARIABLE cUnTrib         AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cQuantidadeTrib AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cValorUniTrib   AS CHARACTER   NO-UNDO.

DEFINE VARIABLE cDirDanfe       AS CHARACTER   NO-UNDO.

DEFINE VARIABLE iNumLinhasProdPrimeiraPagina AS INTEGER     NO-UNDO.
DEFINE VARIABLE iNumLinhasProdOutrasPaginas  AS INTEGER     NO-UNDO.

DEFINE VARIABLE lPrimeiraPagina             AS LOGICAL     NO-UNDO.
DEFINE VARIABLE lPaginaInfCompl             AS LOGICAL     NO-UNDO.
DEFINE VARIABLE iLinhaPaginaAtual           AS INTEGER     NO-UNDO.
DEFINE VARIABLE lUltimaLinhaPagina          AS LOGICAL     NO-UNDO.
DEFINE VARIABLE iNumLinhasOcupadasProduto   AS INTEGER     NO-UNDO.

DEFINE VARIABLE iMaxEntries AS INTEGER     NO-UNDO.

DEFINE VARIABLE iCont AS INTEGER     NO-UNDO.

ASSIGN l-danfe = CAN-FIND(FIRST funcao NO-LOCK
                          WHERE funcao.cd-funcao = "spp-danfe":U
                          AND   funcao.ativo).

DEF STREAM sInput.
DEF STREAM sOutput.

FIND FIRST para-ped NO-LOCK NO-ERROR.

DEF NEW GLOBAL SHARED VAR gcDiretorioDanfe         AS CHAR NO-UNDO.
DEF NEW GLOBAL SHARED VAR gcDiretorioDanfeIt       AS CHAR NO-UNDO.
DEF NEW GLOBAL SHARED VAR gcDiretorioDanfeInfCompl AS CHAR NO-UNDO.


/** FAZER A BUSCA DO DIRET‡RIO INFORMADO NO FT0114 **/
FIND FIRST ser-estab
	 WHERE ser-estab.cod-estabel = ENTRY(1,pcArq,"-")
	   AND ser-estab.serie       = ENTRY(2,pcArq,"-")  NO-LOCK NO-ERROR.

IF AVAIL ser-estab THEN DO:
    ASSIGN cDirDanfe = TRIM(SUBSTRING(ser-estab.char-1,92,200)).

    IF cDirDanfe <> "":U THEN DO:
        /* Retira o £ltimo caracter quando este for uma barra caso contr†rio n∆o funcionar† a busca do layout */
        IF SUBSTRING(cDirDanfe,LENGTH(cDirDanfe),1) = "/" OR 
           SUBSTRING(cDirDanfe,LENGTH(cDirDanfe),1) = "~\" THEN
            ASSIGN cDirDanfe = SUBSTRING(cDirDanfe,1,LENGTH(cDirDanfe) - 1).
    END.
END.


IF  cModeloDANFE = '3' THEN /* Retrato */
    ASSIGN iNumLinhasProdPrimeiraPagina = 23
           iNumLinhasProdOutrasPaginas  = IF pSemWord THEN 71  /* Impress∆o SEM word */
                                                      ELSE 70. /* Impress∆o COM word */
ELSE
    ASSIGN iNumLinhasProdPrimeiraPagina = 7
           iNumLinhasProdOutrasPaginas  = IF pSemWord THEN 48  /* Impress∆o SEM word */
                                                      ELSE 47. /* Impress∆o COM word */

ASSIGN lPrimeiraPagina             = YES
       iLinhaPaginaAtual           = 0
       lUltimaLinhaPagina          = NO.

ASSIGN iSeqTtLinha = 0.
FOR EACH ttDanfeItem:

    RUN piTrataQuebraCampo (INPUT "CodProduto":U, 
                            INPUT ttDanfeItem.cprod,
                            OUTPUT cCodProduto,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "DescProduto":U, 
                            INPUT ttDanfeItem.descitem,
                            OUTPUT cDescProduto,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "NCM":U, 
                            INPUT ttDanfeItem.ncm,
                            OUTPUT cNCM,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "CST":U, 
                            INPUT ttDanfeItem.s,
                            OUTPUT cCST,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "CFOP":U, 
                            INPUT ttDanfeItem.cfop,
                            OUTPUT cCFOP,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "Un":U, 
                            INPUT ttDanfeItem.u,
                            OUTPUT cUn,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "Quantidade":U, 
                            INPUT ttDanfeItem.quantitem,
                            OUTPUT cQuantidade,
                            OUTPUT cSeparador).
    
    RUN piTrataQuebraCampo (INPUT "ValorUni":U, 
                            INPUT ttDanfeItem.vlunit,
                            OUTPUT cValorUni,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "ValorTotal":U, 
                            INPUT ttDanfeItem.vltotitem,
                            OUTPUT cValorTotal,
                            OUTPUT cSeparador).
    
    RUN piTrataQuebraCampo (INPUT "BaseCalcIcms":U, 
                            INPUT ttDanfeItem.vlbcicmit,
                            OUTPUT cBaseCalcIcms,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "ValorIcms":U, 
                            INPUT ttDanfeItem.vlicmit,
                            OUTPUT cValorIcms,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "ValorIpi":U, 
                            INPUT ttDanfeItem.vlipiit,
                            OUTPUT cValorIpi,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "AliquotaIcms":U, 
                            INPUT ttDanfeItem.icm,
                            OUTPUT cAliquotaIcms,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "AliquotaIpi":U, 
                            INPUT ttDanfeItem.ipi,
                            OUTPUT cAliquotaIpi,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "BaseCalcIcmsST":U, 
                            INPUT ttDanfeItem.vlbcicmit-st,
                            OUTPUT cBaseCalcIcmsST,
                            OUTPUT cSeparador).

    RUN piTrataQuebraCampo (INPUT "ValorIcmsST":U, 
                            INPUT ttDanfeItem.vlicmit-st,
                            OUTPUT cValorIcmsST,
                            OUTPUT cSeparador).

    IF  DEC(ttDanfeItem.vlunit-trib) <> 0                       /*AND
        DEC(ttDanfeItem.vlunit-trib) <> DEC(ttDanfeItem.vlunit) AVB */ THEN DO:

        RUN piTrataQuebraCampo (INPUT "Un":U, 
                                INPUT ttDanfeItem.u-trib,
                                OUTPUT cUnTrib,
                                OUTPUT cSeparador).

        RUN piTrataQuebraCampo (INPUT "Quantidade":U, 
                                INPUT ttDanfeItem.quantitem-trib,
                                OUTPUT cQuantidadeTrib,
                                OUTPUT cSeparador).

        RUN piTrataQuebraCampo (INPUT "ValorUni":U, 
                                INPUT ttDanfeItem.vlunit-trib,
                                OUTPUT cValorUniTrib,
                                OUTPUT cSeparador).
        
        ASSIGN iMaxEntries = MAX(NUM-ENTRIES(cUn        , cSeparador),
                                 NUM-ENTRIES(cQuantidade, cSeparador),
                                 NUM-ENTRIES(cValorUni  , cSeparador)).

        DO  iCont = 1 TO iMaxEntries:
            
            IF  NUM-ENTRIES(cUn, cSeparador) <= iCont THEN
                ASSIGN cUn = TRIM(cUn) + cSeparador.

            IF  NUM-ENTRIES(cQuantidade, cSeparador) <= iCont THEN
                ASSIGN cQuantidade = TRIM(cQuantidade) + cSeparador.

            IF  NUM-ENTRIES(cValorUni, cSeparador) <= iCont THEN
                ASSIGN cValorUni = TRIM(cValorUni) + cSeparador.

        END.

        ASSIGN cUn         = TRIM(cUn)         + TRIM(cUnTrib)
               cQuantidade = TRIM(cQuantidade) + TRIM(cQuantidadeTrib)
               cValorUni   = TRIM(cValorUni)   + TRIM(cValorUniTrib).

    END.

    ASSIGN iNumLinhasOcupadasProduto = MAX(NUM-ENTRIES(cCodProduto    , cSeparador),
                                           NUM-ENTRIES(cDescProduto   , cSeparador),
                                           NUM-ENTRIES(cNCM           , cSeparador),
                                           NUM-ENTRIES(cCST           , cSeparador),
                                           NUM-ENTRIES(cCFOP          , cSeparador),
                                           NUM-ENTRIES(cUn            , cSeparador),
                                           NUM-ENTRIES(cQuantidade    , cSeparador),
                                           NUM-ENTRIES(cValorUni      , cSeparador),
                                           NUM-ENTRIES(cValorTotal    , cSeparador),
                                           NUM-ENTRIES(cBaseCalcIcms  , cSeparador),
                                           NUM-ENTRIES(cValorIcms     , cSeparador),
                                           NUM-ENTRIES(cValorIpi      , cSeparador),
                                           NUM-ENTRIES(cAliquotaIcms  , cSeparador),
                                           NUM-ENTRIES(cAliquotaIpi   , cSeparador),
                                           NUM-ENTRIES(cBaseCalcIcmsST, cSeparador),
                                           NUM-ENTRIES(cValorIcmsST   , cSeparador)).
    
    DO  iCont = 1 TO iNumLinhasOcupadasProduto:
        
        ASSIGN iLinhaPaginaAtual = iLinhaPaginaAtual + 1
               iSeqTtLinha       = iSeqTtLinha + 1.

        RUN piControlePaginaAtual. 
        
        IF  iCont = 1              AND 
            lEmiteTracejado        AND 
            iLinhaPaginaAtual > 1  AND
            NOT lUltimaLinhaPagina THEN DO:

            RUN piCriaLinhaTracejada (INPUT iSeqTtLinha).

            ASSIGN iLinhaPaginaAtual = iLinhaPaginaAtual + 1
                   iSeqTtLinha       = iSeqTtLinha + 1
                   lEmiteTracejado   = NO.
                   
            RUN piControlePaginaAtual. 
        END.

        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "CodProduto":U,
                           INPUT (IF  NUM-ENTRIES(cCodProduto, cSeparador) >= iCont 
                                  THEN ENTRY (iCont, cCodProduto, cSeparador)
                                  ELSE "") ).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "DescProduto":U,
                           INPUT (IF  NUM-ENTRIES(cDescProduto, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cDescProduto, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "NCM":U,
                           INPUT (IF  NUM-ENTRIES(cNCM, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cNCM, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "CST":U,
                           INPUT (IF  NUM-ENTRIES(cCST, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cCST, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "CFOP":U,
                           INPUT (IF  NUM-ENTRIES(cCFOP, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cCFOP, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "Un":U,
                           INPUT (IF  NUM-ENTRIES(cUn, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cUn, cSeparador)
                                         ELSE "")). 
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "Quantidade":U,
                           INPUT (IF  NUM-ENTRIES(cQuantidade, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cQuantidade, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "ValorUni":U,
                           INPUT (IF  NUM-ENTRIES(cValorUni, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cValorUni, cSeparador)
                                         ELSE "")). 
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "ValorTotal":U,
                           INPUT (IF  NUM-ENTRIES(cValorTotal, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cValorTotal, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "BaseCalcIcms":U,
                           INPUT (IF  NUM-ENTRIES(cBaseCalcIcms, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cBaseCalcIcms, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "ValorIcms":U,
                           INPUT (IF  NUM-ENTRIES(cValorIcms, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cValorIcms, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "ValorIpi":U,
                           INPUT (IF  NUM-ENTRIES(cValorIpi, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cValorIpi, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "AliquotaIcms":U,
                           INPUT (IF  NUM-ENTRIES(cAliquotaIcms, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cAliquotaIcms, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "AliquotaIpi":U,
                           INPUT (IF  NUM-ENTRIES(cAliquotaIpi, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cAliquotaIpi, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "BaseCalcIcmsST":U,
                           INPUT (IF  NUM-ENTRIES(cBaseCalcIcmsST, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cBaseCalcIcmsST, cSeparador)
                                         ELSE "")).
        RUN piCriaTtLinha (INPUT iSeqTtLinha,
                           INPUT "ValorIcmsST":U,
                           INPUT (IF  NUM-ENTRIES(cValorIcmsST, cSeparador) >= iCont 
                                         THEN ENTRY (iCont, cValorIcmsST, cSeparador)
                                         ELSE "")). 
       
    END. /* REPEAT: */

END. /* FOR EACH ttDanfeItem: */

ASSIGN iSeqTotal = iSeqTtLinha.

ASSIGN iPagTotal = iSeqTotal - iNumLinhasProdPrimeiraPagina
       iPagTotal = IF iPagTotal <= 0 
                   THEN 1 
                   ELSE (2 + (IF iPagTotal MOD iNumLinhasProdOutrasPaginas = 0 
                              THEN -1 + 1 * INT(TRUNC(iPagTotal / iNumLinhasProdOutrasPaginas, 0)) 
                              ELSE INT(TRUNC(iPagTotal / iNumLinhasProdOutrasPaginas, 0)))).

FOR FIRST ttDanfe:

    /*=====================================================================================================================================================
      VOLUMES E EMBALAGENS
    =====================================================================================================================================================*/
    def var de-tot-peso-bru as decimal no-undo.
    def var de-tot-peso-liq as decimal no-undo.
    def var c-aux as char no-undo.

    assign c-aux = ttDanfe.cnpjempresa.
    assign c-aux = replace (c-aux,".","").
    assign c-aux = replace (c-aux,"/","").
    assign c-aux = replace (c-aux,"-","").            

    for each estabelec no-lock where estabelec.cgc = c-aux:
        for first nota-fiscal no-lock where
            nota-fiscal.cod-estabel = estabelec.cod-estabel and
            nota-fiscal.serie       = ttDanfe.ser           and
            nota-fiscal.nr-nota-fis = ttDanfe.nrnota:       
            c-aux = estabelec.cod-estabel.
            assign ttDanfe.especievolume = "".
            if ttDanfe.informacoescomplementares matches "*Embalagens:*"
            then assign ttDanfe.especievolume = "Vide Observaá‰es".
            i-cont = 0.
            for each it-nota-fisc no-lock of nota-fiscal:
                for each item-embal no-lock of it-nota-fisc:
                    assign i-cont = i-cont + 1.
                end.
            end.
            for each nota-embal no-lock where of nota-fiscal:
                assign i-cont = i-cont + nota-embal.qt-volumes.
                if ttDanfe.especievolume <> "Vide Observaá‰es" then do:
                    if nota-embal.desc-vol <> "" then do:
                        if ttDanfe.especievolume = "" then
                            assign ttDanfe.especievolume = nota-embal.desc-vol.
                        else 
                            assign ttDanfe.especievolume = ttDanfe.especievolume + "/" + nota-embal.desc-vol.
                    end.
                    else 
                        for first embalag no-lock where 
                            embalag.sigla-emb = nota-embal.sigla-emb:
                        if ttDanfe.especievolume = "" then
                            assign ttDanfe.especievolume = embalag.descricao.
                        else                     
                            assign ttDanfe.especievolume = ttDanfe.especievolume + "/" + embalag.descricao.
                        end.                
                end.
            end.
            ASSIGN ttDanfe.qtvolume              = if i-cont <> 0 then string(i-cont) else ""
                   ttDanfe.marcavolume           = nota-fiscal.marca-volume
                   ttDanfe.numeracaovolume       = nota-fiscal.nr-volumes
                   ttDanfe.pesobrutototal        = TRIM(STRING(
                       if nota-fiscal.peso-bru-tot <> 0 
                       then nota-fiscal.peso-bru-tot
                       else de-tot-peso-bru,"->>>,>>>,>>>,>>9.999"))
                   ttDanfe.pesoliquidototal      = TRIM(STRING(
                       if nota-fiscal.peso-liq-tot <> 0 
                       then nota-fiscal.peso-liq-tot
                       else de-tot-peso-liq,"->>>,>>>,>>>,>>9.999")).
        end.
    end.
    /* Verificaá∆o do tamanho das informaá‰es complementares, para que quando nao couber em uma p†gina, imprimir o restante na £ltima p†gina */
    RUN piQuebraColuna (INPUT ttDanfe.informacoescomplementares, 
                        INPUT IF  cModeloDanfe  = '3' THEN 1045 ELSE 1099.8,
                        OUTPUT cInfCompl,
                        OUTPUT cSeparador).

    ASSIGN lPaginaInfCompl = NO.
    IF  NUM-ENTRIES(cInfCompl, cSeparador) > 1 THEN
        ASSIGN lPaginaInfCompl = YES
               iPagTotal       = iPagTotal + 1.

    IF pSemWord THEN DO:
        IF ttDanfe.chavedeacessoadicionalnfe <> "" THEN DO:
            IF cModeloDanfe = '3' THEN DO: /* Retrato */
                ASSIGN gcDiretorioDanfe = SEARCH(cDirDanfe + "/danfev2modwvr-cont":U + string(iPagTotal) + ".rtf":U). /* Retrato */

                IF gcDiretorioDanfe = ? OR gcDiretorioDanfe = "" THEN
                    ASSIGN gcDiretorioDanfe = SEARCH("layout/danfev2modwvr-cont":U + string(iPagTotal) + ".rtf":U).  /* Retrato */
            END.
            ELSE DO:
                ASSIGN gcDiretorioDanfe = SEARCH(cDirDanfe + "/danfev2modwvp-cont":U + string(iPagTotal) + ".rtf":U). /* Paisagem */
                
                IF gcDiretorioDanfe = ? OR gcDiretorioDanfe = "" THEN
                    ASSIGN gcDiretorioDanfe = SEARCH("layout/danfev2modwvp-cont":U + string(iPagTotal) + ".rtf":U). /* Paisagem */    
            END.
        END.
        ELSE DO:
            IF cModeloDanfe = '3' THEN DO:  /* Retrato */
                ASSIGN gcDiretorioDanfe = SEARCH(cDirDanfe + "/danfev2modwvr":U + string(iPagTotal) + ".rtf":U). /* Retrato */

                IF gcDiretorioDanfe = ? OR gcDiretorioDanfe = "" THEN
                    ASSIGN gcDiretorioDanfe = SEARCH("layout/danfev2modwvr":U + string(iPagTotal) + ".rtf":U). /* Retrato */
            END.
            ELSE DO: 
                ASSIGN gcDiretorioDanfe = SEARCH(cDirDanfe + "/danfev2modwvp":U + string(iPagTotal) + ".rtf":U). /* Paisagem */

                IF gcDiretorioDanfe = ? OR gcDiretorioDanfe = "" THEN
                    ASSIGN gcDiretorioDanfe = SEARCH("layout/danfev2modwvp":U + string(iPagTotal) + ".rtf":U). /* Paisagem */
            END.
        END.
        ASSIGN gcDiretorioDanfeIt = gcDiretorioDanfe.
    END. 
    ELSE DO:
        /*--- medida utilizada para somente apresentar o c¢digo de barras dos dados da DANFE quando contingància ---------*/
        IF  ttDanfe.chavedeacessoadicionalnfe <> "" THEN DO:
            ASSIGN gcDiretorioDanfe = IF cModeloDanfe = '3' THEN SEARCH(cDirDanfe + "/danfev2mod1-cont.rtf":U) /* Retrato */
                                                            ELSE SEARCH(cDirDanfe + "/danfev2mod2-cont.rtf":U). /* Paisagem */
           
            IF gcDiretorioDanfe = ? OR gcDiretorioDanfe = "" THEN
                ASSIGN gcDiretorioDanfe   = IF cModeloDanfe = '3' THEN SEARCH("layout/danfev2mod1-cont.rtf":U)  /* Retrato */
                                                                  ELSE SEARCH("layout/danfev2mod2-cont.rtf":U). /* Paisagem */


            ASSIGN gcDiretorioDanfeIt = IF cModeloDanfe = '3' THEN SEARCH(cDirDanfe + "/danfev2mod1it-cont.rtf":U) /* Retrato */
                                                              ELSE SEARCH(cDirDanfe + "/danfev2mod2it-cont.rtf":U). /* Paisagem */

            IF gcDiretorioDanfeIt = ? OR gcDiretorioDanfeIt = "" THEN
                ASSIGN gcDiretorioDanfeIt = IF cModeloDanfe = '3' THEN SEARCH("layout/danfev2mod1it-cont.rtf":U) /* Retrato */
                                                                  ELSE SEARCH("layout/danfev2mod2it-cont.rtf":U). /* Paisagem */
       END.
       ELSE DO:
           ASSIGN gcDiretorioDanfe = IF cModeloDanfe = '3' THEN SEARCH(cDirDanfe + "/danfev2mod1.rtf":U) /* Retrato */
                                                           ELSE SEARCH(cDirDanfe + "/danfev2mod2.rtf":U). /* Paisagem */                                                           

           IF gcDiretorioDanfe = ? OR gcDiretorioDanfe = "" THEN
               ASSIGN gcDiretorioDanfe   = IF cModeloDanfe = '3' THEN SEARCH("layout/danfev2mod1.rtf":U) /* Retrato */
                                                                 ELSE SEARCH("layout/danfev2mod2.rtf":U). /* Paisagem */

           ASSIGN gcDiretorioDanfeIt = IF cModeloDanfe = '3' THEN SEARCH(cDirDanfe + "/danfev2mod1it.rtf":U) /* Retrato */
                                                             ELSE SEARCH(cDirDanfe + "/danfev2mod2it.rtf":U). /* Paisagem */

           IF gcDiretorioDanfeIt = ? OR gcDiretorioDanfeIt = "" THEN
               ASSIGN gcDiretorioDanfeIt = IF cModeloDanfe = '3' THEN SEARCH("layout/danfev2mod1it.rtf":U) /* Retrato */
                                                                 ELSE SEARCH("layout/danfev2mod2it.rtf":U). /* Paisagem */
       END.

       ASSIGN gcDiretorioDanfeInfCompl  = IF cModeloDanfe = '3' THEN SEARCH(cDirDanfe + "/danfev2mod1ic.rtf":U) /* Retrato */
                                                                ELSE SEARCH(cDirDanfe + "/danfev2mod1ic.rtf":U). /* Paisagem */

       IF gcDiretorioDanfeInfCompl = ? OR gcDiretorioDanfeInfCompl = "" THEN
           ASSIGN gcDiretorioDanfeInfCompl = IF cModeloDanfe = '3' THEN SEARCH("layout/danfev2mod1ic.rtf":U) /* Retrato */
                                                                   ELSE SEARCH("layout/danfev2mod2ic.rtf":U). /* Paisagem */
    END.

    IF  gcDiretorioDanfe   = ?  OR  gcDiretorioDanfe   = "" THEN NEXT.
    IF  gcDiretorioDanfeIt = ?  OR  gcDiretorioDanfeIt = "" THEN NEXT.

    /*----------------------------------------------------------------------------------------------------------------*/
    
    INPUT  STREAM sInput  FROM VALUE(gcDiretorioDanfe).
    OUTPUT STREAM sOutput TO VALUE(SESSION:TEMP-DIRECTORY + "/" + pcArq) NO-CONVERT.

    REPEAT:                         
        IMPORT STREAM sInput UNFORMAT cLinha.
        IF  INDEX(cLinha,"#":U) > 0 THEN DO:
            ASSIGN cLinha = REPLACE(cLinha, "#BCCODE1281":U,                {ftp/ft0518f.i7 ttDanfe.BCCODE128-chave              }). /*Chave de Acesso NF-e*/
            ASSIGN cLinha = REPLACE(cLinha, "#BCCODE1282":U,                {ftp/ft0518f.i7 ttDanfe.BCCODE128-chaveadicional     }). /*Chave de Acesso Adicional - Para impress∆o em Contingància*/
            ASSIGN cLinha = REPLACE(cLinha, "#razaosocialempresa":U,        {ftp/ft0518f.i7 ttDanfe.razaosocialempresa           }).
            ASSIGN cLinha = REPLACE(cLinha, "#sn":U,                        {ftp/ft0518f.i7 ttDanfe.sn                           }).
            ASSIGN cLinha = REPLACE(cLinha, "#enderecoemp":U,               {ftp/ft0518f.i7 ttDanfe.enderecoemp                  }).
            ASSIGN cLinha = REPLACE(cLinha, "#bairroemp":U,                 {ftp/ft0518f.i7 ttDanfe.bairroemp                    }).
            ASSIGN cLinha = REPLACE(cLinha, "#cidadeemp":U,                 {ftp/ft0518f.i7 ttDanfe.cidadeemp                    }).
            ASSIGN cLinha = REPLACE(cLinha, "#ufemp":U,                     {ftp/ft0518f.i7 ttDanfe.ufemp                        }).
            ASSIGN cLinha = REPLACE(cLinha, "#cepemp":U,                    {ftp/ft0518f.i7 ttDanfe.cepemp                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#foneemp":U,                   {ftp/ft0518f.i7 ttDanfe.foneemp                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#siteemp":U,                   {ftp/ft0518f.i7 ttDanfe.siteemp                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#nrnota":U,                    {ftp/ft0518f.i7 ttDanfe.nrnota                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#ser":U,                       {ftp/ft0518f.i7 ttDanfe.ser                          }).
            ASSIGN cLinha = REPLACE(cLinha, "#n1":U,                        {ftp/ft0518f.i7 '1'                                  }).
            ASSIGN cLinha = REPLACE(cLinha, "#nnn":U,                       {ftp/ft0518f.i7 TRIM(STRING(iPagTotal))              }).
            ASSIGN cLinha = REPLACE(cLinha, "#naturezaoperacao":U,          {ftp/ft0518f.i7 caps(ttDanfe.naturezaoperacao)       }).
            ASSIGN cLinha = REPLACE(cLinha, "#inscrestadempresa":U,         {ftp/ft0518f.i7 ttDanfe.inscrestadempresa            }).
            ASSIGN cLinha = REPLACE(cLinha, "#inscrestadsubstituto":U,      {ftp/ft0518f.i7 ttDanfe.inscrestadsubstituto         }).
            ASSIGN cLinha = REPLACE(cLinha, "#cnpjempresa":U,               {ftp/ft0518f.i7 ttDanfe.cnpjempresa                  }).
            ASSIGN cLinha = REPLACE(cLinha, "#cnpjdestinatario":U,          {ftp/ft0518f.i7 ttDanfe.cnpjdestinatario             }).
            ASSIGN cLinha = REPLACE(cLinha, "#chavedeacessonfe":U,          {ftp/ft0518f.i7 ttDanfe.chavedeacessonfe             }).
            ASSIGN cLinha = REPLACE(cLinha, "#dadosdanfe":U,                {ftp/ft0518f.i7 ttDanfe.chavedeacessoadicionalnfe    }).
            ASSIGN cLinha = REPLACE(cLinha, "#protocoloautorizacao":U,      {ftp/ft0518f.i7 ttDanfe.protocoloautorizacao         }).
            ASSIGN cLinha = REPLACE(cLinha, "#razaosocialdestinatario":U,   {ftp/ft0518f.i7 caps(ttDanfe.razaosocialdestinatario)}).
            ASSIGN cLinha = REPLACE(cLinha, "#dataemissao":U,               {ftp/ft0518f.i7 ttDanfe.dataemissao                  }).
            ASSIGN cLinha = REPLACE(cLinha, "#dataentrega":U,               {ftp/ft0518f.i7 ttDanfe.dataentrega                  }).
            ASSIGN cLinha = REPLACE(cLinha, "#horasaida":U,                 {ftp/ft0518f.i7 ttDanfe.horasaida                    }).
            ASSIGN cLinha = REPLACE(cLinha, "#enderecodestinatario":U,      {ftp/ft0518f.i7 caps(ttDanfe.enderecodestinatario)   }).
            ASSIGN cLinha = REPLACE(cLinha, "#cidadedestinatario":U,        {ftp/ft0518f.i7 caps(ttDanfe.cidadedestinatario)     }).
            ASSIGN cLinha = REPLACE(cLinha, "#bairrodestinatario":U,        {ftp/ft0518f.i7 caps(ttDanfe.bairrodestinatario)     }).
            ASSIGN cLinha = REPLACE(cLinha, "#cepdestinatario":U,           {ftp/ft0518f.i7 ttDanfe.cepdestinatario              }).
            ASSIGN cLinha = REPLACE(cLinha, "#fonedestinatario":U,          {ftp/ft0518f.i7 ttDanfe.fonedestinatario             }).
            ASSIGN cLinha = REPLACE(cLinha, "#ufdest":U,                    {ftp/ft0518f.i7 caps(ttDanfe.ufdest)                 }).
            ASSIGN cLinha = REPLACE(cLinha, "#inscrestaddestinatario":U,    {ftp/ft0518f.i7 ttDanfe.inscrestaddestinatario       }).
            ASSIGN cLinha = REPLACE(cLinha, "#fatura1":U,                   {ftp/ft0518f.i7 ttDanfe.fatura1                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#vencfat1":U,                  {ftp/ft0518f.i7 ttDanfe.vencfat1                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlfat1":U,                    {ftp/ft0518f.i7 ttDanfe.vlfat1                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#fatura2":U,                   {ftp/ft0518f.i7 ttDanfe.fatura2                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#vencfat2":U,                  {ftp/ft0518f.i7 ttDanfe.vencfat2                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlfat2":U,                    {ftp/ft0518f.i7 ttDanfe.vlfat2                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#fatura3":U,                   {ftp/ft0518f.i7 ttDanfe.fatura3                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#vencfat3":U,                  {ftp/ft0518f.i7 ttDanfe.vencfat3                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlfat3":U,                    {ftp/ft0518f.i7 ttDanfe.vlfat3                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#fatura4":U,                   {ftp/ft0518f.i7 ttDanfe.fatura4                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#vencfat4":U,                  {ftp/ft0518f.i7 ttDanfe.vencfat4                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlfat4":U,                    {ftp/ft0518f.i7 ttDanfe.vlfat4                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#fatura5":U,                   {ftp/ft0518f.i7 ttDanfe.fatura5                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#vencfat5":U,                  {ftp/ft0518f.i7 ttDanfe.vencfat5                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlfat5":U,                    {ftp/ft0518f.i7 ttDanfe.vlfat5                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#fatura6":U,                   {ftp/ft0518f.i7 ttDanfe.fatura6                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#vencfat6":U,                  {ftp/ft0518f.i7 ttDanfe.vencfat6                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlfat6":U,                    {ftp/ft0518f.i7 ttDanfe.vlfat6                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#fatura7":U,                   {ftp/ft0518f.i7 ttDanfe.fatura7                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#vencfat7":U,                  {ftp/ft0518f.i7 ttDanfe.vencfat7                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlfat7":U,                    {ftp/ft0518f.i7 ttDanfe.vlfat7                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#fatura8":U,                   {ftp/ft0518f.i7 ttDanfe.fatura8                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#vencfat8":U,                  {ftp/ft0518f.i7 ttDanfe.vencfat8                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlfat8":U,                    {ftp/ft0518f.i7 ttDanfe.vlfat8                       }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlbcicmsnota":U,              {ftp/ft0518f.i7 ttDanfe.vlbcicmsnota                 }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlicmsnota":U,                {ftp/ft0518f.i7 ttDanfe.vlicmsnota                   }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlbcicmsstnota":U,            {ftp/ft0518f.i7 ttDanfe.vlbcicmsstnota               }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlicmsstnota":U,              {ftp/ft0518f.i7 ttDanfe.vlicmsstnota                 }).
            ASSIGN cLinha = REPLACE(cLinha, "#vltotprod":U,                 {ftp/ft0518f.i7 ttDanfe.vltotprod                    }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlfretenota":U,               {ftp/ft0518f.i7 ttDanfe.vlfretenota                  }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlseguronota":U,              {ftp/ft0518f.i7 ttDanfe.vlseguronota                 }).
            ASSIGN cLinha = REPLACE(cLinha, "#vldescontonota":U,            {ftp/ft0518f.i7 ttDanfe.vldescontonota               }).
            ASSIGN cLinha = REPLACE(cLinha, "#vldespesasnota":U,            {ftp/ft0518f.i7 ttDanfe.vldespesasnota               }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlipinota":U,                 {ftp/ft0518f.i7 ttDanfe.vlipinota                    }).
            ASSIGN cLinha = REPLACE(cLinha, "#vltotnota":U,                 {ftp/ft0518f.i7 ttDanfe.vltotnota                    }).
            ASSIGN cLinha = REPLACE(cLinha, "#nometransp":U,                {ftp/ft0518f.i7 caps(ttDanfe.nometransp)             }).
            ASSIGN cLinha = REPLACE(cLinha, "#idfr":U,                      {ftp/ft0518f.i7 ttDanfe.idfr                         }).
            ASSIGN cLinha = REPLACE(cLinha, "#codantt1":U,                  {ftp/ft0518f.i7 ttDanfe.codantt1                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#codantt2":U,                  {ftp/ft0518f.i7 ttDanfe.codantt2                     }).
            ASSIGN cLinha = REPLACE(cLinha, "#placa1":U,                    {ftp/ft0518f.i7 caps(ttDanfe.placa1)                 }).
            ASSIGN cLinha = REPLACE(cLinha, "#placa2":U,                    {ftp/ft0518f.i7 caps(ttDanfe.placa2)                 }).
            ASSIGN cLinha = REPLACE(cLinha, "#ufpl1":U,                     {ftp/ft0518f.i7 caps(ttDanfe.ufpl1)                  }).
            ASSIGN cLinha = REPLACE(cLinha, "#ufpl2":U,                     {ftp/ft0518f.i7 caps(ttDanfe.ufpl2)                  }).
            ASSIGN cLinha = REPLACE(cLinha, "#cnpjtransp":U,                {ftp/ft0518f.i7 ttDanfe.cnpjtransp                   }).
            ASSIGN cLinha = REPLACE(cLinha, "#enderecotransp":U,            {ftp/ft0518f.i7 caps(ttDanfe.enderecotransp)         }).
            ASSIGN cLinha = REPLACE(cLinha, "#cidadetransp":U,              {ftp/ft0518f.i7 caps(ttDanfe.cidadetransp)           }).
            ASSIGN cLinha = REPLACE(cLinha, "#uftran":U,                    {ftp/ft0518f.i7 caps(ttDanfe.uftran)                 }).
            ASSIGN cLinha = REPLACE(cLinha, "#inscrestadtransp":U,          {ftp/ft0518f.i7 ttDanfe.inscrestadtransp             }).
            ASSIGN cLinha = REPLACE(cLinha, "#qtvolume":U,                  {ftp/ft0518f.i7 ttDanfe.qtvolume                     }).
            
            /*ASSIGN cLinha = REPLACE(cLinha, "#especievolume":U,             {ftp/ft0518f.i7 caps(ttDanfe.especievolume)          }).*/
            /* AVB - cuztomizacao das embalagens p/ GEO */
 
            assign c-aux = ttDanfe.cnpjempresa.
            assign c-aux = replace (c-aux,".","").
            assign c-aux = replace (c-aux,"/","").
            assign c-aux = replace (c-aux,"-","").            
                
            if not ttDanfe.informacoescomplementares matches "*Embalagens:*" or c-aux <> "95391462000193" /* GEO */
            then 
                ASSIGN cLinha = REPLACE(cLinha, "#especievolume",             caps(ttDanfe.especievolume)   ).
            else 
                ASSIGN cLinha = REPLACE(cLinha, "#especievolume",             "Vide Observaá‰es"            ).

            ASSIGN cLinha = REPLACE(cLinha, "#marcavolume":U,               {ftp/ft0518f.i7 caps(ttDanfe.marcavolume)            }).
            ASSIGN cLinha = REPLACE(cLinha, "#numeracaovolume":U,           {ftp/ft0518f.i7 ttDanfe.numeracaovolume              }).
            ASSIGN cLinha = REPLACE(cLinha, "#pesobrutototal":U,            {ftp/ft0518f.i7 ttDanfe.pesobrutototal               }).
            ASSIGN cLinha = REPLACE(cLinha, "#pesoliquidototal":U,          {ftp/ft0518f.i7 ttDanfe.pesoliquidototal             }).
            ASSIGN cLinha = REPLACE(cLinha, "#inscrmunicipaliss":U,         {ftp/ft0518f.i7 ttDanfe.inscrmunicipaliss            }).
            ASSIGN cLinha = REPLACE(cLinha, "#vltotalsevicos":U,            {ftp/ft0518f.i7 ttDanfe.vltotalsevicos               }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlbciss":U,                   {ftp/ft0518f.i7 ttDanfe.vlbciss                      }).
            ASSIGN cLinha = REPLACE(cLinha, "#vlisstotal":U,                {ftp/ft0518f.i7 ttDanfe.vlisstotal                   }).
            ASSIGN cLinha = REPLACE(cLinha, "#informacoescomplementares":U, {ftp/ft0518f.i7 ENTRY(1,cInfCompl,cSeparador)        }).
            ASSIGN cLinha = REPLACE(cLinha, "#contingencia":U,              {ftp/ft0518f.i7 ''                                   }).
            ASSIGN cLinha = REPLACE(cLinha, "#homologacao1":U,              {ftp/ft0518f.i7 ttDanfe.homologacao1                 }).
            ASSIGN cLinha = REPLACE(cLinha, "#homologacao2":U,              {ftp/ft0518f.i7 ttDanfe.homologacao2                 }).
            ASSIGN cLinha = REPLACE(cLinha, "#conteudovariavel1":U,         {ftp/ft0518f.i7 ttDanfe.conteudovariavel1            }).
            ASSIGN cLinha = REPLACE(cLinha, "#conteudovariavel2":U,         {ftp/ft0518f.i7 ttDanfe.conteudovariavel2            }).
            
        END.

        IF  INDEX(cLinha,"$":U) > 0 THEN DO:
            RUN piImprimeQuadroProdutos.
        END.

        PUT STREAM sOutput UNFORMATTED cLinha SKIP.
    END.
    PUT STREAM sOutput "}}":U.

    INPUT  STREAM sInput  CLOSE.
    OUTPUT STREAM sOutput CLOSE.
END.

/*IF  NOT pSemWord THEN DO:*/
    FOR FIRST ttDanfe:
        ASSIGN c-danfeaux = string(RANDOM(1,9999999)).
        DO  iPagAtual = 2 TO iPagTotal:
            IF  lPaginaInfCompl
            AND iPagAtual = iPagTotal THEN
                INPUT  STREAM sInput  FROM VALUE(gcDiretorioDanfeinfcompl).
            ELSE
                INPUT  STREAM sInput  FROM VALUE(gcDiretorioDanfeit).
            IF  NOT l-danfe THEN
                OUTPUT STREAM sOutput TO VALUE(SESSION:TEMP-DIRECTORY + "/" + "danfeaux":U + TRIM(STRING(iPagAtual)) + ".doc":U) NO-CONVERT.
            ELSE 
                OUTPUT STREAM sOutput TO VALUE(SESSION:TEMP-DIRECTORY + "/" + "danfeaux":U + c-danfeaux + TRIM(STRING(iPagAtual)) + ".doc":U) NO-CONVERT.
            
            REPEAT:                             
                IMPORT STREAM sInput UNFORMAT cLinha.
                IF  INDEX(cLinha,"#":U) > 0 THEN DO:
                    ASSIGN cLinha = REPLACE(cLinha, "#BCCODE1281":U,           {ftp/ft0518f.i7 ttDanfe.BCCODE128-chave           }).
                    ASSIGN cLinha = REPLACE(cLinha, "#BCCODE1282":U,           {ftp/ft0518f.i7 ttDanfe.BCCODE128-chaveadicional  }).
                    ASSIGN cLinha = REPLACE(cLinha, "#razaosocialempresa":U,   {ftp/ft0518f.i7 ttDanfe.razaosocialempresa        }).
                    ASSIGN cLinha = REPLACE(cLinha, "#sn":U,                   {ftp/ft0518f.i7 ttDanfe.sn                        }).
                    ASSIGN cLinha = REPLACE(cLinha, "#enderecoemp":U,          {ftp/ft0518f.i7 ttDanfe.enderecoemp               }).
                    ASSIGN cLinha = REPLACE(cLinha, "#bairroemp":U,            {ftp/ft0518f.i7 ttDanfe.bairroemp                 }).
                    ASSIGN cLinha = REPLACE(cLinha, "#cidadeemp":U,            {ftp/ft0518f.i7 ttDanfe.cidadeemp                 }).
                    ASSIGN cLinha = REPLACE(cLinha, "#ufemp":U,                {ftp/ft0518f.i7 ttDanfe.ufemp                     }).
                    ASSIGN cLinha = REPLACE(cLinha, "#cepemp":U,               {ftp/ft0518f.i7 ttDanfe.cepemp                    }).
                    ASSIGN cLinha = REPLACE(cLinha, "#foneemp":U,              {ftp/ft0518f.i7 ttDanfe.foneemp                   }).
                    ASSIGN cLinha = REPLACE(cLinha, "#siteemp":U,              {ftp/ft0518f.i7 ttDanfe.siteemp                   }).
                    ASSIGN cLinha = REPLACE(cLinha, "#nrnota":U,               {ftp/ft0518f.i7 ttDanfe.nrnota                    }).
                    ASSIGN cLinha = REPLACE(cLinha, "#ser":U,                  {ftp/ft0518f.i7 ttDanfe.ser                       }).
                    ASSIGN cLinha = REPLACE(cLinha, "#n1":U,                   {ftp/ft0518f.i7 TRIM(STRING(iPagAtual))           }).
                    ASSIGN cLinha = REPLACE(cLinha, "#nnn":U,                  {ftp/ft0518f.i7 TRIM(STRING(iPagTotal))           }).
                    ASSIGN cLinha = REPLACE(cLinha, "#naturezaoperacao":U,     {ftp/ft0518f.i7 caps(ttDanfe.naturezaoperacao)    }).
                    ASSIGN cLinha = REPLACE(cLinha, "#inscrestadempresa":U,    {ftp/ft0518f.i7 ttDanfe.inscrestadempresa         }).
                    ASSIGN cLinha = REPLACE(cLinha, "#inscrestadsubstituto":U, {ftp/ft0518f.i7 ttDanfe.inscrestadsubstituto      }).
                    ASSIGN cLinha = REPLACE(cLinha, "#cnpjempresa":U,          {ftp/ft0518f.i7 ttDanfe.cnpjempresa               }).
                    ASSIGN cLinha = REPLACE(cLinha, "#chavedeacessonfe":U,     {ftp/ft0518f.i7 ttDanfe.chavedeacessonfe          }).
                    ASSIGN cLinha = REPLACE(cLinha, "#dadosdanfe":U,           {ftp/ft0518f.i7 ttDanfe.chavedeacessoadicionalnfe }).
                    ASSIGN cLinha = REPLACE(cLinha, "#protocoloautorizacao":U, {ftp/ft0518f.i7 ttDanfe.protocoloautorizacao      }).
                    ASSIGN cLinha = REPLACE(cLinha, "#conteudovariavel1":U,    {ftp/ft0518f.i7 ttDanfe.conteudovariavel1         }).
                    ASSIGN cLinha = REPLACE(cLinha, "#conteudovariavel2":U,    {ftp/ft0518f.i7 ttDanfe.conteudovariavel2         }).
                END.
                    
                IF  INDEX(cLinha,"$":U) > 0 THEN DO:
                    RUN piImprimeQuadroProdutos.
                END.

                IF  lPaginaInfCompl
                AND iPagAtual = iPagTotal THEN DO:
                    ASSIGN cInfComplAux = "".
                    DO iCont = 2 TO NUM-ENTRIES(cInfCompl,cSeparador):
                        ASSIGN cInfComplAux = cInfComplAux + ENTRY(iCont,cInfCompl,cSeparador).
                    END.
                    ASSIGN cLinha =  REPLACE(cLinha, "#informacoescomplementares2":U, {ftp/ft0518f.i7 cInfComplAux    }).
                END.
                    

                PUT STREAM sOutput UNFORMATTED cLinha SKIP.
            END.

            PUT STREAM sOutput "}}":U.

            INPUT  STREAM sInput  CLOSE.
            OUTPUT STREAM sOutput CLOSE.
        END.
    END.
    
    IF  iPagTotal >= 2 THEN DO:
        {office/office.i Word ch-app-word}                         /* Cria uma aplicaá∆o WORD */
        ch-app-word:WindowState = 2.                                     /* O estado dois para o Word Ç minimizado */
        ch-app-word:VISIBLE = NO.                                        /* Apenas para n∆o mostrar que o word est† sendo utilizado em tela */
        ch-app-word:Documents:ADD(SESSION:TEMP-DIRECTORY + "/" + pcArq). /* Inclui arquivo */
        DO  iPagAtual = 2 TO iPagTotal:
            ch-app-word:SELECTION:EndKey(6).                             /* Posiciona cursor no final do arquivo */
            ch-app-word:SELECTION:InsertBreak(7).                        /* Qubra pagina antes de inserir arquivo */
            IF  NOT l-danfe THEN DO:
                ch-app-word:SELECTION:Insertfile(SESSION:TEMP-DIRECTORY + "/" + "danfeaux":U + TRIM(STRING(iPagAtual)) + ".doc":U). /* Insere arquivo no documento aberto */
                OS-DELETE VALUE(SESSION:TEMP-DIRECTORY + "/" + "danfeaux":U + TRIM(STRING(iPagAtual)) + ".doc":U) NO-ERROR. /* Elimina o arquivo auxiliar */
            END.
            ELSE DO:
                ch-app-word:SELECTION:Insertfile(SESSION:TEMP-DIRECTORY + "/" + "danfeaux":U + c-danfeaux + TRIM(STRING(iPagAtual)) + ".doc":U). /* Insere arquivo no documento aberto */
                OS-DELETE VALUE(SESSION:TEMP-DIRECTORY + "/" + "danfeaux":U + c-danfeaux + TRIM(STRING(iPagAtual)) + ".doc":U) NO-ERROR. /* Elimina o arquivo auxiliar */
            END.
        END.
        ch-app-word:ActiveDocument:SaveAs(SESSION:TEMP-DIRECTORY + "/" + pcArq). /* Salva o arquivo aberto no WORD com o nome final do arquivo */
        ch-app-word:ActiveDocument:CLOSE().                                /* Fecha o arquivo do WORD */
        ch-app-word:QUIT().                                              /* Fechar o WORD */
        DELETE OBJECT ch-app-word.                                      /* Elimina o endereáo utilizado para o WORD na m†quina */
    END.

    /* Portal de Clientes - Vipal */
    /*IF &IF '{&bf_dis_versao_ems}' >= '2.09':U &THEN 
           para-ped.log-intgr-portal /* Integra com Pedidos de Penda */
       &ELSE 
           SUBSTRING(para-ped.char-2,7,1) = "S" /* Integra com Pedidos de Penda */
       &ENDIF THEN DO:*/
       
       FIND FIRST portal-param
            WHERE portal-param.cod-param = "portal-pasta-arquivos-danfe-nfe" NO-LOCK NO-ERROR.
      
       IF AVAIL portal-param AND portal-param.cod-val-param <> "" THEN DO:
          
         ASSIGN c-chave-nota    = pcArq    
                c-cod-estabel   = ENTRY(1,c-chave-nota,"-") 
                c-serie-aux     = ENTRY(2,c-chave-nota,"-") 
                c-nr-nota-fis   = ENTRY(3,c-chave-nota,"-")
                c-serie-1       = c-serie-aux
                c-nr-nota-fis-1 = c-nr-nota-fis. 

         IF c-serie-aux = "" THEN
            ASSIGN c-serie-aux = "000".
         ELSE DO:   
            IF LENGTH(c-serie-aux) < 3 THEN
               ASSIGN c-serie-aux = IF LENGTH(c-serie-aux) = 1 THEN "00" + c-serie-aux
                                                               ELSE "0"  + c-serie-aux.
         END.

         /*IF LENGTH(c-nr-nota-fis) <= 9 THEN 
            ASSIGN c-nr-nota-fis = STRING(INT(c-nr-nota-fis),"999999999").*/
                      
         ASSIGN c-chave-nota    = c-cod-estabel + c-serie-aux + c-nr-nota-fis + ".pdf"
                c-arquivo-pdf   = portal-param.cod-val-param + "/" + c-chave-nota.
				
		 FIND FIRST nota-fiscal 
			  WHERE nota-fiscal.cod-estabel = c-cod-estabel
				AND nota-fiscal.serie       = c-serie-1
				AND nota-fiscal.nr-nota-fis = c-nr-nota-fis-1 NO-LOCK NO-ERROR.
		
         /*IF AVAIl nota-fiscal 
		      AND nota-fiscal.nr-pedcli <> "" THEN*/

			
		    /*IF CAN-FIND(FIRST ped-venda 
			            WHERE ped-venda.nome-abrev = nota-fiscal.nome-ab-cli
						  AND ped-venda.nr-pedcli  = nota-fiscal.nr-pedcli
						  AND ped-venda.data-2 <> ?) THEN DO:*/
				
				 {office/office.i Word ch-app-word} /* Cria uma aplicaá∆o WORD */                                                            
				 ch-app-word:WindowState = 2.             /* O estado dois para o Word Ç minimizado */                                             
				 ch-app-word:VISIBLE = NO.                /* Apenas para n∆o mostrar que o word est† sendo utilizado em tela */                                                                                                                                                                    
				 ch-app-word:Documents:ADD(SESSION:TEMP-DIRECTORY + "/" + pcArq). /* Inclui arquivo */ 

				 ch-app-word:ActiveDocument:ExportAsFixedFormat(c-arquivo-pdf, 
															   17, /* wdExportFormatPDF - Exportar documento no formato PDF */
															   FALSE, 
															   0, /* wdExportOptimizeForPrint - Exportar para impress∆o, que Ç de qualidade superior e resulta em um tamanho de arquivo maior */ 
															   0, /* wdExportAllDocument - Exporta o documento inteiro */
															   1, 
															   999, 
															   0, /* wdExportDocumentContent - Exporta o documento sem marcaá∆o */
															   TRUE, 
															   TRUE, 
															   0, /* wdExportCreateNoBookmarks - N∆o criar indicadores no documento exportado */
															   TRUE,  
															   TRUE, 
															   FALSE).  

				 ch-app-word:ActiveDocument:CLOSE(). /* Fecha o arquivo do WORD */ 
				 ch-app-word:QUIT().               /* Fechar o WORD */
				 DELETE OBJECT ch-app-word.       /* Elimina o endereáo utilizado para o WORD na m†quina */  		 
		  /*END.*/

       END. /* IF AVAIL portal-param AND portal-param.cod-val-param <> "" THEN DO: */    
    /*END.*/  /* IF &IF '{&bf_dis_versao_ems}' >= '2.09':U &THEN  */

/*END.*/

PROCEDURE piTrataQuebraCampo:
    DEFINE  INPUT PARAMETER cNomeCampo      AS CHARACTER NO-UNDO.
    DEFINE  INPUT PARAMETER cConteudoCampo  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cConteudoQuebra AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cCaracterQuebra AS CHARACTER NO-UNDO.

    FOR FIRST ttColunasDANFE 
        WHERE ttColunasDANFE.descricao = cNomeCampo:
    END.

    IF  AVAIL ttColunasDANFE THEN DO:
        RUN piQuebraColuna (INPUT cConteudoCampo, 
                            INPUT (IF cModeloDanfe = '3'  /* Retrato */
                                   THEN ttColunasDANFE.tamanhoRetrato
                                   ELSE ttColunasDANFE.tamanhoPaisagem),
                            OUTPUT cConteudoQuebra,
                            OUTPUT cCaracterQuebra).
/*         IF cNomeCampo = "CodProduto" THEN           */
/*             ASSIGN cConteudoQuebra = cConteudoCampo */
/*                    cCaracterQuebra = "".            */

    END.
    ELSE
        ASSIGN cConteudoQuebra = cConteudoCampo.

END PROCEDURE.


PROCEDURE piQuebraColuna:
    DEFINE INPUT  PARAMETER cConteudo       AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER dTamanhoColuna  AS DECIMAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER cConteudoQuebra AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cCaracterQuebra AS CHARACTER NO-UNDO.

    DEFINE VARIABLE i                    AS INTEGER     NO-UNDO.
    DEFINE VARIABLE cCaracterAtual       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE dTamanhoChar         AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE dTamanhoAtual        AS DECIMAL     NO-UNDO.
    
    ASSIGN cCaracterQuebra = CHR(1).

    IF  dTamanhoColuna > 0 THEN DO:

        ASSIGN cConteudo = TRIM(cConteudo).
    
        DO  i = 1 TO LENGTH(cConteudo):
    
            ASSIGN cCaracterAtual = SUBSTR(cConteudo, i, 1).
    
            FIND FIRST ttCaracteres
                 WHERE ttCaracteres.codigoAsc = ASC(cCaracterAtual) NO-ERROR.
    
            IF  NOT AVAIL ttCaracteres THEN
                FIND FIRST ttCaracteres
                 WHERE ttCaracteres.codigoAsc = ASC(fn-tira-acento(cCaracterAtual)) NO-ERROR.

            IF  NOT AVAIL ttCaracteres        OR
                ttCaracteres.tamanhoChar <= 0 THEN
                ASSIGN dTamanhoChar = 1.
            ELSE
                ASSIGN dTamanhoChar = ttCaracteres.tamanhoChar.
    
            ASSIGN dTamanhoAtual = dTamanhoAtual + dTamanhoChar.
    
            IF  dTamanhoAtual > dTamanhoColuna THEN DO:
                ASSIGN cConteudoQuebra = cConteudoQuebra + cCaracterQuebra
                       dTamanhoAtual   = dTamanhoChar.
            END.
    
            ASSIGN cConteudoQuebra = cConteudoQuebra + cCaracterAtual.

            /*IF  INDEX(cConteudo,"MTPPROIMP0000036") > 0 THEN
                MESSAGE cConteudoQuebra SKIP
                        cCaracterAtual SKIP
                        dTamanhoAtual SKIP
                        cConteudo SKIP
                        dTamanhoColuna
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.*/
    
        END.

    END.

END PROCEDURE.

PROCEDURE piImprimeQuadroProdutos:
    
    FOR EACH ttColunasDANFE
          BY ttColunasDANFE.codigo:

        RUN piReplaceColunaProduto (INPUT ttColunasDANFE.codigo).
       
    END.

END PROCEDURE.

PROCEDURE piReplaceColunaProduto:
    DEFINE INPUT PARAMETER cCodigoColuna AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE cSeqLinha     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE iSeqLinha     AS INTEGER     NO-UNDO.
    
    IF  INDEX(cLinha, cCodigoColuna) > 0 THEN
        ASSIGN cSeqLinha = SUBSTR(cLinha, (INDEX(cLinha, cCodigoColuna) + LENGTH(cCodigoColuna)), (IF pSemWord THEN 3 ELSE 2) ).

/*
    if cCodigoColuna = "$f" then do:
        message cSeqLinha 
            view-as alert-box.
                        ASSIGN iSeqLinha = INT(cSeqLinha).
        FOR each ttLinha
        /*
            WHERE 
            ttLinha.sequenciaLinha = iSeqLinha and
            ttLinha.codigoColuna   = cCodigoColuna: */ :
            if ttLinha.conteudoCampo = "kg" then 
                message ttlinha.sequencialinha 
                        ttlinha.codigocoluna
                        ttLinha.conteudoCampo 
                view-as alert-box.
                    
        END.
            
    end.
*/
    IF  cSeqLinha <> "" THEN DO:

        IF  iPagAtual >= 2 THEN
            ASSIGN iSeqLinha = ( INT(cSeqLinha) + ((iPagAtual - 2) * iNumLinhasProdOutrasPaginas)  + iNumLinhasProdPrimeiraPagina ).
        ELSE
            ASSIGN iSeqLinha = INT(cSeqLinha).

        FOR FIRST ttLinha
            WHERE ttLinha.sequenciaLinha = iSeqLinha
              AND ttLinha.codigoColuna   = cCodigoColuna: END.
        
        ASSIGN cLinha = REPLACE(cLinha, (cCodigoColuna + TRIM(cSeqLinha)), (IF AVAIL ttLinha THEN ttLinha.conteudoCampo ELSE "") ).
        
    END.

END PROCEDURE.

PROCEDURE piRetornaCodigoColuna:
    DEFINE INPUT PARAMETER cDescricao AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER cCodigo    AS CHARACTER NO-UNDO.

    FOR FIRST ttColunasDANFE
        WHERE ttColunasDANFE.descricao = cDescricao:
        ASSIGN cCodigo = ttColunasDANFE.codigo.
    END.

END PROCEDURE.
              
PROCEDURE piCriaTtLinha:
    DEFINE INPUT PARAMETER iSequenciaLinha  AS INT  NO-UNDO.
    DEFINE INPUT PARAMETER cDescricaoColuna AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER cConteudoCampo   AS CHAR NO-UNDO.

    DEFINE VARIABLE cCodigoColuna AS CHARACTER   NO-UNDO.
    
    RUN piRetornaCodigoColuna (INPUT  cDescricaoColuna,
                               OUTPUT cCodigoColuna).
    
    IF  cCodigoColuna <> "" THEN DO:
        CREATE ttLinha.
        ASSIGN ttLinha.sequenciaLinha = iSequenciaLinha
               ttLinha.codigoColuna   = cCodigoColuna
               ttLinha.conteudoCampo  = TRIM(cConteudoCampo).
    END.

END PROCEDURE.

PROCEDURE piCriaLinhaTracejada:
    DEFINE INPUT PARAMETER iSequenciaLinha AS INTEGER NO-UNDO.
    
    DEFINE VARIABLE cCaracterLinha AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE dTamanhoChar   AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE cConteudoCampo AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE dTamanhoAtual  AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE dTamanhoColuna AS DECIMAL     NO-UNDO.

    ASSIGN cCaracterLinha = "-":U.

    FIND FIRST ttCaracteres
         WHERE ttCaracteres.codigoAsc = ASC(cCaracterLinha) NO-ERROR.

    IF  NOT AVAIL ttCaracteres      OR
        ttCaracteres.tamanhoChar <= 0 THEN
        ASSIGN dTamanhoChar = 1.
    ELSE
        ASSIGN dTamanhoChar = ttCaracteres.tamanhoChar.
    
    FOR EACH ttColunasDANFE
          BY ttColunasDANFE.codigo:
        
        ASSIGN cConteudoCampo = ""
               dTamanhoAtual  = 0
               dTamanhoColuna = IF  cModeloDANFE = '3' /* Retrato */
                                THEN ttColunasDANFE.tamanhoRetrato
                                ELSE ttColunasDANFE.tamanhoPaisagem.

        REPEAT:
            ASSIGN dTamanhoAtual  = dTamanhoAtual + dTamanhoChar
                   cConteudoCampo = cConteudoCampo + cCaracterLinha.

            IF  dTamanhoAtual > dTamanhoColuna THEN
                LEAVE.
        END.

        RUN piCriaTtLinha (INPUT iSequenciaLinha,
                           INPUT ttColunasDANFE.descricao,
                           INPUT cConteudoCampo).
       
    END.

END PROCEDURE.

PROCEDURE piControlePaginaAtual:
    DEFINE VARIABLE iLinhasRestantesPaginaAtual AS INTEGER     NO-UNDO.

    IF  NOT lEmiteTracejado AND
        iCont > 1           THEN
        ASSIGN lEmiteTracejado = YES.

    IF  lPrimeiraPagina THEN DO:

        IF  iLinhaPaginaAtual = iNumLinhasProdPrimeiraPagina THEN
            ASSIGN lUltimaLinhaPagina = YES.
        ELSE IF  iLinhaPaginaAtual > iNumLinhasProdPrimeiraPagina THEN
            ASSIGN iLinhaPaginaAtual  = 1
                   lPrimeiraPagina    = NO
                   lUltimaLinhaPagina = NO.

    END.
    ELSE DO:
         
        IF  iLinhaPaginaAtual = iNumLinhasProdOutrasPaginas THEN
            ASSIGN lUltimaLinhaPagina = YES.
        ELSE IF  iLinhaPaginaAtual > iNumLinhasProdOutrasPaginas THEN
            ASSIGN iLinhaPaginaAtual  = 1
                   lUltimaLinhaPagina = NO.

    END.

    IF  iCont = 1 THEN DO:

        IF lPrimeiraPagina THEN
            ASSIGN iLinhasRestantesPaginaAtual = iNumLinhasProdPrimeiraPagina - iLinhaPaginaAtual + 1.
        ELSE
            ASSIGN iLinhasRestantesPaginaAtual = iNumLinhasProdOutrasPaginas  - iLinhaPaginaAtual + 1.
        
        IF  iNumLinhasOcupadasProduto >  (iLinhasRestantesPaginaAtual - (IF lEmiteTracejado THEN 1 ELSE 0)) THEN DO:
        
            ASSIGN iLinhaPaginaAtual  = 1
                   lPrimeiraPagina    = NO
                   lUltimaLinhaPagina = NO.

            ASSIGN iSeqTtLinha = iSeqTtLinha + iLinhasRestantesPaginaAtual.

        END.
    END.    

END PROCEDURE.
