/*********************************************************************************
*      Programa .....: esof001rp.p                                               *
*      Data .........: 11/08/2021                                                *
*      Sistema ......: Obrigaá‰es Fiscais                                        *
*      Empresa ......:                                                           * 
*      Cliente ......: Farm†cias Nissei                                          *
*      Programador ..: LGJ Desenv                                                *
*      Objetivo .....: Ajuste de valores de ICMS no Livro Fiscal atravÇs de      *
*                      importaá∆o de valores em planilha Excel.                  *
**********************************************************************************
*      VERSAO      DATA        RESPONSAVEL    MOTIVO                             *
*      12.1.32     11/08/2021  Leandro        Desenvolvimento                    * 
*********************************************************************************/


{include/i-prgvrs.i esof001rp}   

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i esof001rp MOF}
&ENDIF

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita AS RAW.

DEFINE TEMP-TABLE tt-param
    FIELD destino               AS INTEGER
    FIELD arq-destino           AS CHAR
    FIELD arq-entrada           AS CHAR
    FIELD arq-itens             AS CHAR
    FIELD todos                 AS INTEGER
    FIELD usuario               AS CHAR
    FIELD data-exec             AS DATE
    FIELD hora-exec             AS INTEGER.

DEFINE TEMP-TABLE tt-dados NO-UNDO
    //campos importados
    FIELD chave                 AS CHAR FORMAT "x(44)"
    FIELD nr-doc-fis            LIKE doc-fiscal.nr-doc-fis
    FIELD serie                 LIKE doc-fiscal.serie
    FIELD dt-emis-doc           LIKE doc-fiscal.dt-emis-doc
    FIELD cnpj-emit             LIKE estabelec.cgc
    FIELD cnpj-dest             LIKE emitente.cgc
    FIELD nr-seq-doc            LIKE it-doc-fisc.nr-seq-doc
    FIELD cod-cfop              LIKE natur-oper.cod-cfop
    FIELD quantidade            LIKE it-doc-fisc.quantidade
    FIELD vl-unitario           AS DECIMAL
    FIELD vl-produto            AS DECIMAL  FORMAT ">>>,>>>,>>9.99"
    FIELD vl-desconto           AS DECIMAL  FORMAT ">>>,>>>,>>9.99"
    FIELD vl-vbcstret           AS DECIMAL  FORMAT ">>>,>>>,>>9.99"
    FIELD it-codigo             LIKE it-doc-fisc.it-codigo

    //campos pesquisados
    FIELD nat-operacao          LIKE doc-fiscal.nat-operacao
    FIELD cod-estabel           LIKE doc-fiscal.cod-estabel
    FIELD cod-emitente          LIKE doc-fiscal.cod-emitente

    //campos calculados
    FIELD vl-bicms-it           LIKE it-doc-fisc.vl-bicms-it
    FIELD vl-icmsou-it          LIKE it-doc-fisc.vl-icmsou-it
    FIELD aliquota-icm          LIKE it-doc-fisc.aliquota-icm   //pegar da planilha de itens
    FIELD vl-icms-destacado     AS DECIMAL      //it-doc-fisc.val-livre-1

    FIELD erro                  AS LOGICAL
    FIELD linha-import          AS INTEGER
    .

DEFINE TEMP-TABLE tt-itens
    FIELD it-codigo         LIKE ITEM.it-codigo
    FIELD dt-val-ini        AS DATE FORMAT "99/99/9999"
    FIELD dt-val-fim        AS DATE FORMAT "99/99/9999"
    FIELD aliquota          LIKE it-doc-fisc.aliquota-icm
    FIELD erro              AS LOGICAL
    FIELD linha-import      AS INTEGER
    INDEX idx AS PRIMARY
    it-codigo.

DEFINE TEMP-TABLE tt-erros-import
    FIELD linha-import          AS INTEGER
    FIELD cod-erro              AS INTEGER
    FIELD desc-erro             AS CHAR FORMAT "x(120)".

DEFINE INPUT PARAMETER raw-param AS RAW NO-UNDO.
DEFINE INPUT PARAMETER TABLE FOR tt-raw-digita.

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

{METHOD/dbotterr.i} 

/* include padr∆o para vari†veis para o log  */
{include/i-rpvar.i}

{include/i-rpout.i &STREAM="stream str-rp" &TOFILE=tt-param.arq-destino}

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i &STREAM="str-rp"}

/*=================================================================================================================*/
/* bloco principal do programa */
FIND FIRST param-global NO-LOCK.

ASSIGN 
    c-programa      =   "esof001":U
    c-versao        =   "12.1.32":U
    c-revisao       =   "000":U
    c-empresa       =   param-global.grupo
    c-titulo-relat  =   "Ajuste de valores Livro Fiscal"
    c-sistema       =   "Obrigaá‰es Fiscais".

VIEW STREAM str-rp FRAME f-cabec.
VIEW STREAM str-rp FRAME f-rodape.

FORM
    tt-dados.cod-estabel        FORMAT "x(5)"       COLUMN-LABEL "Estab"
    tt-dados.serie              FORMAT "x(3)"       COLUMN-LABEL "SÇrie"
    tt-dados.nr-doc-fis         FORMAT "x(7)"       COLUMN-LABEL "Documento"
    tt-dados.cod-emitente       FORMAT ">>>>>>9"    COLUMN-LABEL "Emitente"
    tt-dados.dt-emis-doc        FORMAT "99/99/9999" COLUMN-LABEL "Dt. Emiss∆o"
    tt-dados.nr-seq-doc         FORMAT ">>9"        COLUMN-LABEL "Seq"
    tt-dados.it-codigo          FORMAT "x(7)"       COLUMN-LABEL "Item"
    tt-dados.vl-produto         FORMAT ">>>,>>9.99" COLUMN-LABEL "Vl Merc Orig"
    tt-dados.vl-vbcstret        FORMAT ">>>,>>9.99" COLUMN-LABEL "Vl BCSTret"
    tt-dados.vl-bicms-it        FORMAT ">>>,>>9.99" COLUMN-LABEL "Vl BC. Icms"
    tt-dados.vl-icmsou-it       FORMAT ">>>,>>9.99" COLUMN-LABEL "Vl ICMS Out"
    tt-dados.vl-icms-destacado  FORMAT ">>>,>>9.99" COLUMN-LABEL "Vl ICMS Dest"
    tt-dados.aliquota-icm                           COLUMN-LABEL "Al°q."
    WITH FRAME f-1 WIDTH 132 STREAM-IO DOWN.

FORM
    tt-erros-import.linha-impor     FORMAT ">>>>>9"     COLUMN-LABEL "Linha"
    tt-erros-import.cod-erro        FORMAT ">>9"        COLUMN-LABEL "C¢d"
    tt-erros-import.desc-erro       FORMAT "x(115)"     COLUMN-LABEL "Descriá∆o"
    WITH FRAME f-erro WIDTH 132 STREAM-IO DOWN.

/*=================================================================================================================*/
/* Definicao de vari†veis */
DEF VAR v-erro          AS LOGICAL                  NO-UNDO.
DEF VAR aux-1           AS CHAR                     NO-UNDO.
DEF VAR aux-2           AS CHAR                     NO-UNDO.
DEF VAR h-acomp         AS HANDLE                   NO-UNDO.
DEF VAR l-achou         AS LOGICAL                  NO-UNDO.
DEF VAR cont-mov        AS INTEGER                  NO-UNDO.
DEF VAR cont-itens      AS INTEGER                  NO-UNDO.
DEF VAR cont_linha      AS INTEGER                  NO-UNDO     init 2.
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


/********** Vari†veis Excel ***********/
//DEFINE VARIABLE c-arquivo       AS CHAR       NO-UNDO.
DEFINE VARIABLE hExcel-1        AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hWorkbook-1     AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hWorksheet-1    AS COM-HANDLE NO-UNDO.

DEFINE VARIABLE hExcel-2        AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hWorkbook-2     AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE hWorksheet-2    AS COM-HANDLE NO-UNDO.
/**************************************/


/*=================================================================================================================*/
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Inicializando...").

FIND FIRST tt-param NO-LOCK NO-ERROR.

EMPTY TEMP-TABLE tt-dados NO-ERROR.
EMPTY TEMP-TABLE tt-itens NO-ERROR.
EMPTY TEMP-TABLE tt-erros-import NO-ERROR.

ASSIGN 
    cont-itens  =   0
    cont-mov    =   0
    v-erro      =   NO.

IF (tt-param.arq-itens <> "") THEN DO:
    RUN pi-importacao-itens.
    
    IF (tt-param.arq-entrada <> "") THEN DO:
        RUN pi-importacao-movimentos.
    END.
    ELSE DO:
        CREATE tt-erros-import.
        ASSIGN
            tt-erros-import.linha-import    =   0
            tt-erros-import.cod-erro        =   998
            tt-erros-import.desc-erro       =   "Arquivo de movimentos n∆o informado.".
    END.
END.
ELSE DO:
    CREATE tt-erros-import.
    ASSIGN
        tt-erros-import.linha-import    =   0
        tt-erros-import.cod-erro        =   999
        tt-erros-import.desc-erro       =   "Arquivo de itens n∆o informado.".
END.

/*=================================================================================================================*/
IF (TEMP-TABLE tt-itens:HAS-RECORDS) THEN DO:
    /*FOR EACH tt-itens NO-LOCK:
        MESSAGE 
            tt-itens.it-codigo SKIP
            tt-itens.dt-val-ini SKIP
            tt-itens.dt-val-fim SKIP
            tt-itens.aliquota
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    END.*/
    IF (TEMP-TABLE tt-dados:HAS-RECORDS) THEN DO:
        FOR EACH tt-dados WHERE 
            tt-dados.erro = NO NO-LOCK BREAK BY tt-dados.linha-import.
            /*MESSAGE
                tt-dados.chave                 skip
                tt-dados.nr-doc-fis            skip
                tt-dados.serie                 skip
                tt-dados.dt-emis-doc           skip
                tt-dados.cnpj-emit             skip
                tt-dados.cnpj-dest             skip
                tt-dados.nr-seq-doc            skip
                tt-dados.cod-cfop              skip
                tt-dados.quantidade            skip
                tt-dados.vl-unitario           skip
                tt-dados.vl-produto            skip
                tt-dados.vl-desconto           skip
                tt-dados.vl-vbcstret           skip
                tt-dados.it-codigo             skip
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/
    
            ASSIGN cont-mov = cont-mov + 1.
    
            RUN pi-acompanhar IN h-acomp (INPUT "Pesquisando documentos: " + STRING(cont-mov)).
    
            ASSIGN l-achou = NO.
            FOR EACH doc-fiscal WHERE
                    doc-fiscal.cod-estabel              =   tt-dados.cod-estabel        AND
                    doc-fiscal.serie                    =   tt-dados.serie              AND
                    doc-fiscal.nr-doc-fis               =   tt-dados.nr-doc-fis         AND
                    doc-fiscal.cod-emitente             =   tt-dados.cod-emitente       AND
                    doc-fiscal.nat-operacao            <>   ""                          AND
                    SUBSTRING(doc-fiscal.char-2,155,44) =   tt-dados.chave              NO-LOCK,
                EACH natur-oper WHERE
                    natur-oper.nat-operacao = doc-fiscal.nat-operacao NO-LOCK,
                EACH it-doc-fisc OF doc-fiscal WHERE
                    it-doc-fisc.it-codigo = tt-dados.it-codigo NO-LOCK.
    
                ASSIGN l-achou = YES.
                ASSIGN 
                    tt-dados.nat-operacao   =   it-doc-fisc.nat-operacao
                    tt-dados.nr-seq-doc     =   it-doc-fisc.nr-seq-doc.

                IF (tt-dados.vl-vbcstret <> 0) THEN DO:
                    ASSIGN
                        tt-dados.vl-bicms-it        =   tt-dados.vl-vbcstret
                        tt-dados.vl-icmsou-it       =   IF (tt-dados.aliquota > 0) THEN
                                                            tt-dados.vl-bicms-it * tt-dados.aliquota / 100
                                                        ELSE
                                                            0
                        tt-dados.vl-icms-destacado  =   tt-dados.vl-icmsou-it.
                END.
                ELSE DO:
                    IF (natur-oper.cod-cfop =   "1403"  OR
                        natur-oper.cod-cfop =   "1409") THEN DO:
                        ASSIGN
                            /*tt-dados.vl-bicms-it        =   IF (TRIM(SUBSTRING(it-doc-fisc.char-2,138,14)) = "") THEN 0 
                                                            ELSE DECIMAL(SUBSTRING(it-doc-fisc.char-2,138,14))*/
                            tt-dados.vl-bicms-it        =   tt-dados.vl-produto - tt-dados.vl-desconto
                            tt-dados.vl-icmsou-it       =   IF (tt-dados.aliquota > 0 AND tt-dados.vl-bicms-it > 0) THEN
                                                                tt-dados.vl-bicms-it * tt-dados.aliquota / 100
                                                            ELSE
                                                                0
                            tt-dados.vl-icms-destacado  =   tt-dados.vl-icmsou-it.
                    END.
                    ELSE DO:    //se a NF cair nessa parte, nao eh pra alterar nada.
                        ASSIGN tt-dados.erro = YES.     //atribui erro apenas pra nao entrar no codigo de alteracao do item
                    END.
                END.
            END.
    
            IF NOT (l-achou) THEN DO:
                ASSIGN tt-dados.erro = YES.
                CREATE tt-erros-import.
                ASSIGN
                    tt-erros-import.linha-import    =   tt-dados.linha-import
                    tt-erros-import.cod-erro        =   3
                    tt-erros-import.desc-erro       =   "N∆o encontrado documento/item." 
                                                        + " Estab " + TRIM(tt-dados.cod-estabel) 
                                                        + " Serie " + TRIM(tt-dados.serie) 
                                                        + " Doc " + TRIM(tt-dados.nr-doc-fis) 
                                                        + " Emitente " + STRING(tt-dados.cod-emitente) 
                                                        + " Seq. " + STRING(tt-dados.nr-seq-doc)
                                                        + " Item " + TRIM(tt-dados.it-codigo) + ".".
            END.
        END.
    END.
    ELSE DO:
        CREATE tt-erros-import.
        ASSIGN
            tt-erros-import.linha-import    =   0
            tt-erros-import.cod-erro        =   996
            tt-erros-import.desc-erro       =   "N∆o foram encontrados movimentos no arquivo de movimentos informado.".
    END.
END.
ELSE DO:
    CREATE tt-erros-import.
    ASSIGN
        tt-erros-import.linha-import    =   0
        tt-erros-import.cod-erro        =   997
        tt-erros-import.desc-erro       =   "N∆o foram encontrados itens no arquivo de itens informado.".
END.

/*=================================================================================================================*/
//alterar os documentos cfe a planilha importada
ASSIGN cont-mov = 0.
FOR EACH tt-dados WHERE 
    tt-dados.erro = NO NO-LOCK BREAK BY tt-dados.linha-import.

    ASSIGN cont-mov = cont-mov + 1.
    RUN pi-acompanhar IN h-acomp (INPUT "Alterando documentos: " + STRING(cont-mov)).

    FIND FIRST it-doc-fisc WHERE
        it-doc-fisc.cod-estabel     =   tt-dados.cod-estabel        AND
        it-doc-fisc.serie           =   tt-dados.serie              AND
        it-doc-fisc.nr-doc-fis      =   tt-dados.nr-doc-fis         AND
        it-doc-fisc.cod-emitente    =   tt-dados.cod-emitente       AND
        it-doc-fisc.nat-operacao    =   tt-dados.nat-operacao       AND
        it-doc-fisc.nr-seq-doc      =   tt-dados.nr-seq-doc         EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL it-doc-fisc THEN DO:
        ASSIGN
            it-doc-fisc.aliquota-icm    =   tt-dados.aliquota
            it-doc-fisc.vl-bicms-it     =   tt-dados.vl-bicms-it
            it-doc-fisc.vl-icmsou-it    =   tt-dados.vl-icmsou-it
            it-doc-fisc.val-livre-1     =   tt-dados.vl-icms-destacado.

        DISP STREAM str-rp
            tt-dados.cod-estabel
            tt-dados.serie
            tt-dados.nr-doc-fis
            tt-dados.cod-emitente
            tt-dados.dt-emis-doc
            tt-dados.nr-seq-doc
            tt-dados.it-codigo                              
            tt-dados.vl-produto
            tt-dados.vl-vbcstret
            tt-dados.vl-bicms-it
            tt-dados.vl-icmsou-it
            tt-dados.vl-icms-destacado
            tt-dados.aliquota-icm
            WITH FRAME f-1 WIDTH 132 DOWN STREAM-IO.
        DOWN WITH FRAME f-1.
        RELEASE it-doc-fisc.
    END.
    ELSE DO:
        ASSIGN tt-dados.erro = YES.
        CREATE tt-erros-import.
        ASSIGN
            tt-erros-import.linha-import    =   tt-dados.linha-import
            tt-erros-import.cod-erro        =   5
            tt-erros-import.desc-erro       =   "N∆o encontrado it-nota-fisc. Estab " + TRIM(tt-dados.cod-estabel) + " Serie " + TRIM(tt-dados.serie) 
                                                + " Doc " + TRIM(tt-dados.nr-doc-fis) + " Item " + TRIM(tt-dados.it-codigo) + ".".
    END.

END.

/*=================================================================================================================*/

IF (TEMP-TABLE tt-erros-import:HAS-RECORDS) THEN DO:
    PUT STREAM str-rp SKIP (3).
    PUT STREAM str-rp
        "============================================================================================================================"  SKIP
        "                                                         ERROS                                                              "  SKIP
        "============================================================================================================================"  SKIP.
    
    FOR EACH tt-erros-import NO-LOCK BREAK BY tt-erros-import.linha-import.
        DISP STREAM str-rp
            tt-erros-import.linha-import
            tt-erros-import.cod-erro
            tt-erros-import.desc-erro
            WITH FRAME f-erro WIDTH 132 DOWN STREAM-IO.
        DOWN WITH FRAME f-erro.
    END.
END.

{include/i-rpclo.i &STREAM="stream str-rp"}

RUN pi-finalizar IN h-acomp.
RETURN 'OK':U.

/*=================================================================================================================*/
PROCEDURE pi-inicia-excel-1:

    RUN pi-acompanhar IN h-acomp (INPUT "Criando arquivo Excel itens...").
    CREATE "Excel.Application" hExcel-1.
    hExcel-1:Workbooks:OPEN(tt-param.arq-itens).
    hExcel-1:worksheets:ITEM(1):SELECT.
    hWorksheet-1 = hExcel-1:Sheets:ITEM(1).
    hExcel-1:DisplayAlerts = FALSE.
    ASSIGN cont_linha = 2.

END PROCEDURE.

/*=================================================================================================================*/
PROCEDURE pi-inicia-excel-2:

    RUN pi-acompanhar IN h-acomp (INPUT "Criando arquivo Excel movimentos...").
    CREATE "Excel.Application" hExcel-2.
    hExcel-2:Workbooks:OPEN(tt-param.arq-entrada).
    hExcel-2:worksheets:ITEM(1):SELECT.
    hWorksheet-2 = hExcel-2:Sheets:ITEM(1).
    hExcel-2:DisplayAlerts = FALSE.
    ASSIGN cont_linha = 2.

END PROCEDURE.

/*=================================================================================================================*/
PROCEDURE pi-finaliza-excel-1:

    hExcel-1:QUIT().
    IF VALID-HANDLE(hWorksheet-1) THEN
        RELEASE OBJECT hWorksheet-1.
    IF VALID-HANDLE(hWorkbook-1) THEN
        RELEASE OBJECT hWorkbook-1.
    IF VALID-HANDLE(hExcel-1) THEN
        RELEASE OBJECT hExcel-1.

END PROCEDURE.

/*=================================================================================================================*/
PROCEDURE pi-finaliza-excel-2:

    hExcel-2:QUIT().
    IF VALID-HANDLE(hWorksheet-2) THEN
        RELEASE OBJECT hWorksheet-2.
    IF VALID-HANDLE(hWorkbook-2) THEN
        RELEASE OBJECT hWorkbook-2.
    IF VALID-HANDLE(hExcel-2) THEN
        RELEASE OBJECT hExcel-2.

END PROCEDURE.

/*=================================================================================================================*/
PROCEDURE pi-importacao-itens:

    DEF VAR c-linha         AS INTEGER.
    DEF VAR c-item          AS CHAR.
    DEF VAR b-1             AS CHAR.
    DEF VAR c-dt-ini        AS CHAR.
    DEF VAR c-dt-fim        AS CHAR.
    DEF VAR c-aliquota      AS CHAR.

    ASSIGN c-linha = 0.

    INPUT FROM VALUE (SEARCH(tt-param.arq-itens)).
    REPEAT:
        IMPORT DELIMITER ";"
            c-item
            b-1
            c-dt-ini
            c-dt-fim
            c-aliquota.

        ASSIGN c-linha = c-linha + 1.

        RUN pi-acompanhar IN h-acomp (INPUT "Importando itens: " + STRING(c-linha)).

        IF (c-item <> "Item" AND c-item <> "") THEN DO:
            CREATE tt-itens.
            ASSIGN
                tt-itens.erro           =   NO
                tt-itens.linha-import   =   c-linha
                tt-itens.it-codigo      =   c-item
                tt-itens.dt-val-ini     =   DATE(c-dt-ini)
                tt-itens.dt-val-fim     =   DATE(c-dt-fim)
                tt-itens.aliquota       =   DECIMAL(c-aliquota).
        END.
    END.
    INPUT CLOSE.
    
END PROCEDURE.
/*=================================================================================================================*/
PROCEDURE pi-importacao-movimentos:
    
    DEF VAR d-linha         AS INTEGER.
    DEF VAR d-chave         AS CHAR FORMAT "x(44)".
    DEF VAR d-documento     LIKE doc-fiscal.nr-doc-fis.
    DEF VAR d-serie         LIKE doc-fiscal.serie.
    DEF VAR d-data          AS CHAR. //LIKE doc-fiscal.dt-emis-doc.
    DEF VAR d-dest          LIKE emitente.cgc.
    DEF VAR d-emit          LIKE estabelec.cgc.
    DEF VAR d-seq           AS CHAR. //LIKE it-doc-fisc.nr-seq-doc.
    DEF VAR d-cprod         AS CHAR.
    DEF VAR d-cean          AS CHAR.
    DEF VAR d-ceantrib      AS CHAR.
    DEF VAR d-xprod         AS CHAR.
    DEF VAR d-cfop          LIKE natur-oper.cod-cfop.
    DEF VAR d-ncm           AS CHAR.
    DEF VAR d-un            AS CHAR.
    DEF VAR d-qtde          AS CHAR. //LIKE it-doc-fisc.quantidade.
    DEF VAR d-vl-unit       AS CHAR. //DECIMAL FORMAT ">>>,>>>,>>9.99".
    DEF VAR d-vl-prod       AS CHAR. //AS DECIMAL FORMAT ">>>,>>>,>>9.99".
    DEF VAR d-vl-desc       AS CHAR. //AS DECIMAL FORMAT ">>>,>>>,>>9.99".
    DEF VAR d-cst           AS CHAR.
    DEF VAR d-predbc        AS CHAR.
    DEF VAR d-vbc           AS CHAR.
    DEF VAR d-picms         AS CHAR.
    DEF VAR d-vicms         AS CHAR.
    DEF VAR d-predbcst      AS CHAR.
    DEF VAR d-bcst          AS CHAR.
    DEF VAR d-picmsst       AS CHAR.
    DEF VAR d-vicmsst       AS CHAR.
    DEF VAR d-vl-bcstret    AS CHAR. //AS DECIMAL FORMAT ">>>,>>>,>>9.99".
    DEF VAR d-item          LIKE it-doc-fisc.it-codigo.

    ASSIGN d-linha = 0.

    INPUT FROM VALUE (SEARCH(tt-param.arq-entrada)).
    REPEAT:
        ASSIGN d-linha = d-linha + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Importando documentos: " + STRING(d-linha)).

        IMPORT DELIMITER ";"
            d-chave      
            d-documento  
            d-serie      
            d-data       
            d-dest       
            d-emit       
            d-seq        
            d-cprod      
            d-cean       
            d-ceantrib   
            d-xprod      
            d-cfop       
            d-ncm        
            d-un         
            d-qtde       
            d-vl-unit    
            d-vl-prod    
            d-vl-desc    
            d-cst        
            d-predbc     
            d-vbc        
            d-picms      
            d-vicms      
            d-predbcst   
            d-bcst       
            d-picmsst    
            d-vicmsst    
            d-vl-bcstret 
            d-item.

        IF (d-chave                <>   ""          AND
            SUBSTRING(d-chave,1,5) <>   "CHAVE")    THEN DO:
            CREATE tt-dados.
            ASSIGN
                tt-dados.erro           =   NO
                tt-dados.linha-import   =   d-linha
                tt-dados.aliquota-icm   =   0
                tt-dados.chave          =   d-chave
                tt-dados.nr-doc-fis     =   d-documento
                tt-dados.serie          =   d-serie
                tt-dados.dt-emis-doc    =   DATE(d-data)
                tt-dados.cnpj-emit      =   d-emit
                tt-dados.cnpj-dest      =   d-dest
                tt-dados.nr-seq-doc     =   INTEGER(d-seq) * 10
                tt-dados.cod-cfop       =   d-cfop
                tt-dados.quantidade     =   DECIMAL(d-qtde)
                tt-dados.vl-unitario    =   DECIMAL(d-vl-unit)
                tt-dados.vl-produto     =   DECIMAL(d-vl-prod)
                tt-dados.vl-desconto    =   DECIMAL(d-vl-desc)
                tt-dados.vl-vbcstret    =   DECIMAL(d-vl-bcstret)
                tt-dados.it-codigo      =   d-item.
    
            IF (LENGTH(tt-dados.nr-doc-fis) < 7) THEN DO:
                ASSIGN tt-dados.nr-doc-fis = FILL("0",7 - LENGTH(d-documento)) + d-documento.
            END.
    
            FIND FIRST estabelec WHERE
                estabelec.cgc = tt-dados.cnpj-emit NO-LOCK NO-ERROR.
            IF AVAIL estabelec THEN DO:
                ASSIGN tt-dados.cod-estabel = estabelec.cod-estabel.
            END.
            ELSE DO:
                ASSIGN tt-dados.erro = YES.
                CREATE tt-erros-import.
                ASSIGN
                    tt-erros-import.linha-import    =   tt-dados.linha-import
                    tt-erros-import.cod-erro        =   1
                    tt-erros-import.desc-erro       =   "N∆o encontrado estabelecimento com o cnpj " + tt-dados.cnpj-emit.
            END.
    
            FIND FIRST emitente WHERE
                emitente.cgc = tt-dados.cnpj-dest NO-LOCK NO-ERROR.
            IF AVAIL emitente THEN DO:
                ASSIGN tt-dados.cod-emitente = emitente.cod-emitente.
            END.
            ELSE DO:
                ASSIGN tt-dados.erro = YES.
                CREATE tt-erros-import.
                ASSIGN
                    tt-erros-import.linha-import    =   tt-dados.linha-import
                    tt-erros-import.cod-erro        =   2
                    tt-erros-import.desc-erro       =   "N∆o encontrado cliente/fornecedor com o cnpj " + tt-dados.cnpj-dest.
            END.
    
            FIND FIRST tt-itens WHERE
                tt-itens.it-codigo      =   tt-dados.it-codigo      AND
                tt-itens.dt-val-ini    <=   tt-dados.dt-emis-doc    AND
                tt-itens.dt-val-fim    >=   tt-dados.dt-emis-doc    NO-LOCK NO-ERROR.
            IF AVAIL tt-itens THEN DO:
                ASSIGN tt-dados.aliquota = tt-itens.aliquota.
            END.
            ELSE DO:
                ASSIGN tt-dados.erro = YES.
                CREATE tt-erros-import.
                ASSIGN
                    tt-erros-import.linha-import    =   tt-dados.linha-import
                    tt-erros-import.cod-erro        =   4
                    tt-erros-import.desc-erro       =   "N∆o encontrado item com validade na tabela de itens. " 
                                                        + "Item " + TRIM(tt-dados.it-codigo) 
                                                        + " Data " + STRING(tt-dados.dt-emis-doc,"99/99/9999").
            END.
        END.
    END.
    INPUT CLOSE.

END PROCEDURE.

/*=================================================================================================================*/
PROCEDURE pi-tira-zeros:    //por causa da formatacao do excel, estava importando um monte de ,0000 depois de alguns campos.

    DEF INPUT PARAMETER v-1     AS CHAR.
    DEF OUTPUT PARAMETER v-2    AS CHAR.
    DEF VAR ix                  AS INTEGER.
    DEF VAR troca               AS LOGICAL.
    
    ASSIGN troca = NO.
    DO ix = 1 TO LENGTH(v-1).
        IF NOT (troca) THEN DO:
            IF (SUBSTRING(v-1,ix,1) = ",") THEN DO:
                ASSIGN troca = YES.
            END.
        END.
    
        IF (troca) THEN DO:
            ASSIGN SUBSTRING(v-1,ix,1) = " ".
        END.
    END.
    ASSIGN v-2 = TRIM(v-1).
    IF (v-2 = ?) THEN DO:
        ASSIGN v-2 = "".
    END.

END PROCEDURE.

/*=================================================================================================================*/
