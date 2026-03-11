/*-------------------------------------------------
            AXSEP006ExtraDeclarations.i
-------------------------------------------------*/

&IF INTEGER(ENTRY(1,PROVERSION,".")) >= 10 &THEN

DEFINE TEMP-TABLE ttNFETSS NO-UNDO
    FIELD ID   AS CHAR
    FIELD MAIL AS CHAR
    FIELD XML  AS CLOB.

DEFINE TEMP-TABLE ttNFETSSRet NO-UNDO
    FIELD k    AS ROWID
    FIELD STR  AS CHAR LABEL "STRING".

DEFINE TEMP-TABLE ttNFES4 NO-UNDO
    FIELD k        AS ROWID
    FIELD ID       AS CHAR
    FIELD MENSAGEM AS CHAR.

&ENDIF

DEFINE TEMP-TABLE ttStack NO-UNDO
     FIELD ttID  AS INTEGER
     FIELD ttPos AS INTEGER
     INDEX tt_id IS PRIMARY UNIQUE
           ttID  ASCENDING.


FUNCTION addStack RETURN INTEGER (INPUT val AS INTEGER).
     DEFINE VAR id AS INTEGER INITIAL 1 NO-UNDO.
     FIND LAST ttStack NO-ERROR.
     IF AVAIL(ttStack) THEN
          id = ttStack.ttID + 1.

     CREATE ttStack.
     ASSIGN ttStack.ttID = id.
     ASSIGN ttStack.ttPos = val.
END FUNCTION.


FUNCTION delStack RETURN INTEGER.
     FIND LAST ttStack NO-ERROR.
     IF AVAIL(ttStack) THEN
          DELETE ttStack.

     FIND LAST ttStack NO-ERROR.
END FUNCTION.


FUNCTION getStack RETURN INTEGER.
     IF AVAIL(ttStack) THEN
          RETURN ttStack.ttPos.
     ELSE
          RETURN 0.
END FUNCTION.

DEFINE TEMP-TABLE tt_log_erro NO-UNDO
     FIELD ttv_des_msg_ajuda AS CHARACTER INITIAL ?
     FIELD ttv_des_msg_erro  AS CHARACTER INITIAL ?
     FIELD ttv_num_cod_erro  AS INTEGER   INITIAL ? .

/*Definiá∆o da temp-table utilizado pela include axrep012upsert.i (TSSSChemaRet)*/
DEFINE TEMP-TABLE tt_nfe_erro  NO-UNDO
    FIELD cStat      AS CHAR    /* C¢digo do Status da resposta */
    FIELD chNFe      AS CHAR   /* Chave de acesso da Nota Fiscal Eletrìnica */
    FIELD dhRecbto   AS CHAR   /* Data/Hora da homologacao do cancelamento */
    FIELD nProt      AS CHAR.  /* N£mero do protocolo de aprovacao */

/* TEMP-TABLE PARA CALCULO DO PESO DOS VOLUMES */
DEF TEMP-TABLE tt-nota-embal NO-UNDO 
    FIELD rw-nota-embal     AS ROWID
    FIELD peso-liq-tot      AS DEC FORMAT ">>>>>>>.99999"
    FIELD peso-bru-tot      AS DEC FORMAT ">>>>>>>.99999"
    FIELD calculado         AS LOGICAL.
/* FIM - TEMP-TABLE PARA CALCULO DO PESO DOS VOLUMES */

DEFINE VAR hMessageHandler AS HANDLE                  NO-UNDO.
DEFINE VAR iId             AS INTEGER   INITIAL ?     NO-UNDO.
DEFINE VAR idLote          AS CHARACTER INITIAL ?     NO-UNDO.
DEFINE VAR iContItem       AS INT       INITIAL ?     NO-UNDO.
DEFINE VAR iContNota       AS INT       INITIAL ?     NO-UNDO.
DEFINE VAR cReturnValue    AS CHARACTER INITIAL ?     NO-UNDO.
DEFINE VAR cValue          AS CHARACTER INITIAL ?     NO-UNDO.
DEFINE VAR lLayoutXML      AS LOGICAL   INITIAL ?     NO-UNDO.
DEFINE VAR lLayoutTXT      AS LOGICAL   INITIAL ?     NO-UNDO.
DEFINE VAR cTpTrans        AS CHARACTER               NO-UNDO.

/* VARIABEL PARA ARMAZENAR OS VALORES OBTIDOS NA INICIALIZACAO DO loalGenXml */
DEFINE VAR hGenXml         AS HANDLE                  NO-UNDO.


/* VARIAVEL PARA EFETUAR CHAMADA DO AXSEP017.P NO AXSEP006UPSERT.I */
DEFINE VARIABLE h-axsep017 AS HANDLE      NO-UNDO.

/*---------------------------------------------------------
             TRATAMENTO PARA ACENTUAÄ«O
---------------------------------------------------------*/

{include/i-freeac.i}

DEFINE VARIABLE c-string-sem-acento AS CHARACTER   NO-UNDO.

/*-------------------------------------------------------*/




DEFINE VARIABLE c-serie              AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c-cod-cfop           AS CHARACTER  NO-UNDO.
DEFINE VARIABLE h-cdapi704           AS HANDLE     NO-UNDO.
DEFINE VARIABLE c-endereco           AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c-rua                AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c-nro                AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c-comp               AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c-fone               AS CHARACTER  NO-UNDO.
DEFINE VARIABLE i-cont               AS INTEGER    NO-UNDO.
DEFINE VARIABLE c-cod-ean            AS CHARACTER  NO-UNDO.
DEFINE VARIABLE l-sub                AS LOGICAL    NO-UNDO.
DEFINE VARIABLE i-niv-trib-icms      AS INTEGER    NO-UNDO.
DEFINE VARIABLE c-niv-trib-icms      AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c-mod-base-icms      AS CHARACTER  NO-UNDO.
DEFINE VARIABLE d-aliquota-icms      AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-vl-imp-icms        AS DECIMAL    NO-UNDO.
DEFINE VARIABLE c-mod-base-icms-st   AS CHARACTER  NO-UNDO.
DEFINE VARIABLE d-perc-redimp        AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-vl-bicms-it        AS DECIMAL    NO-UNDO.
DEFINE VARIABLE c-sit-trib-ipi       AS CHARACTER  NO-UNDO.
DEFINE VARIABLE c-sit-trib-pis       AS CHARACTER  NO-UNDO.
DEFINE VARIABLE d-aliq-pis           AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-base-pis           AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-valor-pis          AS DECIMAL    NO-UNDO.
DEFINE VARIABLE c-sit-trib-cofins    AS CHARACTER  NO-UNDO.
DEFINE VARIABLE d-aliq-cofins        AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-base-cofins        AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-valor-cofins       AS DECIMAL    NO-UNDO.
DEFINE VARIABLE c-desc-prod          AS CHARACTER  NO-UNDO.
DEFINE VARIABLE d-base-ii            AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-base-icms    AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-icms         AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-base-iss     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-iss          AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-serv         AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-ipi          AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-base-icms-st AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-icms-st      AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-ii           AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-pis          AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-cofins       AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-outras-desp  AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-ret-pis      AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-ret-cofins   AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-ret-csll     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-ret-irf      AS DECIMAL    NO-UNDO.
DEFINE VARIABLE d-total-base-ret-irf AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de-perc-pis-subst    AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de-base-pis-subs     AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de-perc-cofins-subst AS DECIMAL    NO-UNDO.
DEFINE VARIABLE de-base-cofins-subs  AS DECIMAL    NO-UNDO.
DEFINE VARIABLE cLocalArqTXT         AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cArquivoNFeTXT       AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cArquivoEmitTXT      AS CHARACTER  NO-UNDO.
DEFINE VARIABLE dpesoB-sgt           as decimal    no-undo.
DEFINE VARIABLE dpesoL-sgt           as decimal    no-undo.
DEFINE VARIABLE iqVol-sgt            as integer    no-undo.
DEFINE VARIABLE cesp-sgt             as character  no-undo.
DEFINE VARIABLE de-vl-zfm-tot        AS DECIMAL    NO-UNDO.
DEFINE VARIABLE l-nota-compl-imp     AS LOGICAL    NO-UNDO.
DEFINE VARIABLE l-impressao-danfe    AS LOGICAL    NO-UNDO.

/* variaveis utilizadas para a funcao SPP-PRECO-BRUTO-NFE */
DEFINE VARIABLE de-vProdTotal            AS DECIMAL NO-UNDO.
DEFINE VARIABLE l-funcao-preco-bruto-nfe AS LOGICAL NO-UNDO.
/* fim - variaveis utilizadas para a funcao SPP-PRECO-BRUTO-NFE */

/*ZFM   VARIABLES - BEGIN*/
def var de-vl-unit               as decimal                             no-undo.
def var de-vl-unit-trib          as decimal                             no-undo.
def var de-conv                  as decimal format ">>>>9.99"           NO-UNDO.
def var de-conv-total            as decimal format ">>>>9.99"           NO-UNDO.
DEF VAR r-cidade-zf              AS ROWID                               NO-UNDO.
def var de-vl-total              as decimal                             no-undo.
def var de-qt-fatur              as decimal format ">>>>,>>9.9999"      no-undo.
def var l-frete-bipi             as log                                 no-undo. 
def var de-vl-bipi-it            like it-nota-fisc.vl-bipi-it           no-undo. 
def var de-vl-ipi-it             like it-nota-fisc.vl-ipi-it            no-undo.

DEF VAR l-fn-ZFM AS LOGICAL INITIAL NO NO-UNDO. /*funcao spp-DescZFM-NFe-ManSP*/
/*ZFM    VARIABLES - END*/    

/*ICMS Outras*/
DEFINE VARIABLE d-vl-imp-icmsou      AS DECIMAL    NO-UNDO.
DEFINE VARIABLE l-icms-outras-it     AS LOGICAL    NO-UNDO. /*CD0606 - Considera ICMS Outras na NF-e*/
/*ICMS Outras*/
def var l-funcao-SGT as logical no-undo.
assign l-funcao-SGT = can-find(first funcao
                               where funcao.cd-funcao = 'spp-sgt':U
                               and   funcao.ativo).

/* TSS SINCRONO ATIVO */
DEFINE VARIABLE l-integ-tss-sincrono AS LOGICAL     NO-UNDO INITIAL NO.
/* TSS SINCRONO ATIVO */

/* VARIAVEL CONTROLE PARA OBTER O XML DA NFE E N«O EFETUAR O ENVIO - TSS SINCRONO */
&IF INTEGER(ENTRY(1,PROVERSION,".")) >= 10 &THEN
    DEFINE VARIABLE lcXMLNFe AS LONGCHAR NO-UNDO.
&ENDIF
DEFINE VARIABLE lObtemXMLNFe AS LOGICAL  NO-UNDO.
/* VARIAVEL CONTROLE PARA OBTER O XML DA NFE E N«O EFETUAR O ENVIO - TSS SINCRONO */

DEFINE VARIABLE i-natureza AS INTEGER     NO-UNDO.

DEFINE BUFFER bf-unid-feder-est  FOR unid-feder. /* Leitura Unid-Feder do Estabelecimento  */
DEFINE BUFFER bf-cidade-est      FOR ems5.cidade.     /* Leitura Cidade     do Estabelecimento  */
DEFINE BUFFER bf-emitente-est    FOR emitente.   /* Leitura Emitente   do Estabelecimento  */
DEFINE BUFFER bf-unid-feder-emit FOR unid-feder. /* Leitura Unid-Feder do Emitente         */
DEFINE BUFFER bf-cidade-emit     FOR ems5.cidade.     /* Leitura Cidade     do Emitente         */
DEFINE BUFFER bf-cidade-entrega  FOR ems5.cidade.     /* Leitura Cidade     do Local de Entrega */
DEFINE BUFFER bf-cidade-nf       FOR ems5.cidade.     /* Leitura Cidade     da Nota Fiscal      */
DEFINE BUFFER bf-natur-oper-nf   FOR natur-oper. /* Leitura Natur-Oper da Nota Fiscal      */
DEFINE BUFFER bf-natur-oper-it   FOR natur-oper. /* Leitura Natur-Oper do Item Nota Fiscal */
DEFINE BUFFER bf-pais            FOR ems5.pais.       /* Leitura Pa°s do Emitente */


FUNCTION fn-ajusta-tamanho-campo RETURNS CHAR (INPUT cCampo         AS CHAR,
                                               INPUT iTamanhoCampo  AS INT).

    /* Restringe tamanhos de campos, conforme layout definido pela Sefaz */

    DEFINE VARIABLE cCampoAjustado AS CHARACTER  NO-UNDO.

    IF  LENGTH(TRIM(cCampo)) > iTamanhoCampo THEN
        ASSIGN cCampoAjustado = SUBSTRING(TRIM(cCampo),1,iTamanhoCampo).
    ELSE
        ASSIGN cCampoAjustado = TRIM(cCampo).

    RETURN TRIM(cCampoAjustado).

END FUNCTION.

FUNCTION fn-ajusta-espacos-branco RETURNS CHAR (INPUT cCampo AS CHAR).

    /*--- Em uma string, retirar os espacos em branco a mais entre as palavras [mais de 2 espacos] ---*/
    DEFINE VARIABLE cRetiraEspacos AS CHARACTER  NO-UNDO.

    ASSIGN cRetiraEspacos = cCampo.
    DO  WHILE INDEX(cRetiraEspacos, "  ") > 0.
        ASSIGN cRetiraEspacos = REPLACE(cRetiraEspacos, "  ", " ").
    END.
    
    RETURN TRIM(cRetiraEspacos).

END FUNCTION.

FUNCTION fn-trata-caracteres RETURNS CHAR (INPUT p-string AS CHAR ).
    DEFINE VARIABLE c-trata-caracteres     AS CHAR CASE-SENSITIVE NO-UNDO.
    DEFINE VARIABLE c-trata-caracteres-aux AS CHAR CASE-SENSITIVE NO-UNDO.
    DEFINE VARIABLE i-posicao              AS INTEGER     NO-UNDO.
    DEFINE VARIABLE i-codigo-asc           AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-caracter             AS CHAR CASE-SENSITIVE NO-UNDO.
    
    ASSIGN c-trata-caracteres = p-string
           c-trata-caracteres = replace(c-trata-caracteres, '˚', '1')
           c-trata-caracteres = replace(c-trata-caracteres, '˝', '2')
           c-trata-caracteres = replace(c-trata-caracteres, '¸', '3')
           c-trata-caracteres = replace(c-trata-caracteres, ' ', '')
           c-trata-caracteres = replace(c-trata-caracteres, "'~'", '')
           c-trata-caracteres = replace(c-trata-caracteres, '^', '')  
           c-trata-caracteres = replace(c-trata-caracteres, 'í', '')
           c-trata-caracteres = replace(c-trata-caracteres, '˘', '')  
           c-trata-caracteres = replace(c-trata-caracteres, '·', 'b')
           c-trata-caracteres = replace(c-trata-caracteres, '∏', 'c')   
           c-trata-caracteres = replace(c-trata-caracteres, 'Ω', 'c')
           c-trata-caracteres = replace(c-trata-caracteres, 'Ù', 'c')
           c-trata-caracteres = replace(c-trata-caracteres, 'ú', 'e')
           c-trata-caracteres = replace(c-trata-caracteres, '≥', 'f')
           c-trata-caracteres = replace(c-trata-caracteres, '¯', 'o')
	       c-trata-caracteres = replace(c-trata-caracteres, 'ù', 'o')
           c-trata-caracteres = replace(c-trata-caracteres, 'Ê', 'm')
           c-trata-caracteres = replace(c-trata-caracteres, '©', 'r')
           c-trata-caracteres = replace(c-trata-caracteres, 'ı', 's')
           c-trata-caracteres = replace(c-trata-caracteres, '¶', 'a')
           c-trata-caracteres = replace(c-trata-caracteres, 'ß', 'o')
           c-trata-caracteres = REPLACE(c-trata-caracteres,CHR(10), "")
           c-trata-caracteres = REPLACE(c-trata-caracteres,CHR(13), "")
           c-trata-caracteres = REPLACE(c-trata-caracteres,CHR(9), "").
           
    /*IF  l-integ-tss-sincrono THEN DO:*/
    
        DO  i-posicao = 1 TO LENGTH(c-trata-caracteres):
            ASSIGN  c-caracter   = SUBSTR(c-trata-caracteres,i-posicao,1)
                    i-codigo-asc = ASC(c-caracter).
            
            IF  i-codigo-asc >= 32  AND
                i-codigo-asc <= 126 THEN DO:
            
                CASE i-codigo-asc:
                
                    /*WHEN 34 /* " */ THEN ASSIGN c-caracter = "&quot;":U.
                    WHEN 38 /* & */ THEN ASSIGN c-caracter = "&amp;":U.
                    WHEN 39 /* ' */ THEN ASSIGN c-caracter = "&#39;":U.
                    WHEN 60 /* < */ THEN ASSIGN c-caracter = "&lt;":U.
                    WHEN 62 /* > */ THEN ASSIGN c-caracter = "&gt;":U.*/
		    WHEN 63 THEN ASSIGN c-caracter = "".
                
                END CASE.

                ASSIGN c-trata-caracteres-aux = c-trata-caracteres-aux + c-caracter.

            END.

            ELSE ASSIGN c-trata-caracteres-aux = c-trata-caracteres-aux + "".

        END.
        
        ASSIGN c-trata-caracteres = c-trata-caracteres-aux.

    /*END.*/
        
    RETURN trim(c-trata-caracteres).
END FUNCTION.

FUNCTION fn-tira-acento RETURNS char (INPUT p-string AS char ).
    define var c-free-accent as char case-sensitive no-undo.
    
    assign c-free-accent = p-string
           c-free-accent =  replace(c-free-accent, '∑', 'A')
           c-free-accent =  replace(c-free-accent, 'µ', 'A')
           c-free-accent =  replace(c-free-accent, '∂', 'A')
           c-free-accent =  replace(c-free-accent, '«', 'A')
           c-free-accent =  replace(c-free-accent, 'é', 'A')
           c-free-accent =  replace(c-free-accent, '‘', 'E')
           c-free-accent =  replace(c-free-accent, 'ê', 'E')
           c-free-accent =  replace(c-free-accent, '“', 'E')
           c-free-accent =  replace(c-free-accent, '”', 'E')
           c-free-accent =  replace(c-free-accent, 'ﬁ', 'I')
           c-free-accent =  replace(c-free-accent, '÷', 'I')
           c-free-accent =  replace(c-free-accent, '◊', 'I')
           c-free-accent =  replace(c-free-accent, 'ÿ', 'I')
           c-free-accent =  replace(c-free-accent, '„', 'O')
           c-free-accent =  replace(c-free-accent, '‡', 'O')
           c-free-accent =  replace(c-free-accent, '‚', 'O')
           c-free-accent =  replace(c-free-accent, 'Â', 'O')
           c-free-accent =  replace(c-free-accent, 'ô', 'O')
           c-free-accent =  replace(c-free-accent, 'Î', 'U')
           c-free-accent =  replace(c-free-accent, 'È', 'U')
           c-free-accent =  replace(c-free-accent, 'Í', 'U')
           c-free-accent =  replace(c-free-accent, 'ö', 'U')
           c-free-accent =  replace(c-free-accent, 'Ì', 'Y')
           c-free-accent =  replace(c-free-accent, 'ü', 'Y')
           c-free-accent =  replace(c-free-accent, 'Ä', 'C')
           c-free-accent =  replace(c-free-accent, '•', 'N')
           c-free-accent =  replace(c-free-accent, 'Ö', 'a')
           c-free-accent =  replace(c-free-accent, '†', 'a')
           c-free-accent =  replace(c-free-accent, 'É', 'a')
           c-free-accent =  replace(c-free-accent, '∆', 'a')
           c-free-accent =  replace(c-free-accent, 'Ñ', 'a')
           c-free-accent =  replace(c-free-accent, 'ä', 'e')
           c-free-accent =  replace(c-free-accent, 'Ç', 'e')
           c-free-accent =  replace(c-free-accent, 'à', 'e')
           c-free-accent =  replace(c-free-accent, 'â', 'e')
           c-free-accent =  replace(c-free-accent, 'ç', 'i')
           c-free-accent =  replace(c-free-accent, '°', 'i')
           c-free-accent =  replace(c-free-accent, 'å', 'i')
           c-free-accent =  replace(c-free-accent, 'ã', 'i')
           c-free-accent =  replace(c-free-accent, 'ï', 'o')
           c-free-accent =  replace(c-free-accent, '¢', 'o')
           c-free-accent =  replace(c-free-accent, 'ì', 'o')
           c-free-accent =  replace(c-free-accent, '‰', 'o')
           c-free-accent =  replace(c-free-accent, 'î', 'o')
           c-free-accent =  replace(c-free-accent, 'ó', 'u')
           c-free-accent =  replace(c-free-accent, '£', 'u')
           c-free-accent =  replace(c-free-accent, 'ñ', 'u')
           c-free-accent =  replace(c-free-accent, 'Å', 'u')
           c-free-accent =  replace(c-free-accent, 'Ï', 'y')
           c-free-accent =  replace(c-free-accent, 'ò', 'y')
           c-free-accent =  replace(c-free-accent, 'á', 'c')
           c-free-accent =  replace(c-free-accent, '§', 'n').
     
    return c-free-accent.
end function.


