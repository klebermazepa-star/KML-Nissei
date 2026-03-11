{include/i-freeac.i}

/*{dibo/bodi601.i tt-carta-correc-eletro}*/

def temp-table tt-dados-evento no-undo
  field cod-estab               like nota-fiscal.cod-estabel
  field cod-serie               like nota-fiscal.serie
  field cod-nota-fis            like nota-fiscal.nr-nota-fis
  field desc-evento             as char format "x(100)"
  field num-seq                 like carta-correc-eletro.num-seq
  field cod-versao              like carta-correc-eletro.cod-versao
  field dsl-evento              like carta-correc-eletro.dsl-carta-correc-eletro
  field des-dat-hora-event      like carta-correc-eletro.des-dat-hora-event
  field r-rowid                 as rowid
  index ch-nota is primary
        cod-estab   
        cod-serie   
        cod-nota-fis.

{utp/ut-glob.i}
{cdp/cdcfgdis.i}

{include/i-epc200.i AXSEP018}

DEFINE VAR cReturnValue     AS CHARACTER INITIAL ?     NO-UNDO.
DEFINE VAR hMessageHandler  AS HANDLE                  NO-UNDO.
DEFINE VAR lCreateMsg       AS LOGICAL   INITIAL FALSE NO-UNDO.
DEFINE VAR pSendSuccess     AS LOGICAL   INITIAL YES   NO-UNDO.
DEFINE VAR pTotalErrors     AS INTEGER   INITIAL ?     NO-UNDO.
DEFINE VAR hBusinessContent AS HANDLE                  NO-UNDO.
DEFINE VAR hGenXml          AS HANDLE                  NO-UNDO.
DEFINE VAR lcXMLEvento      AS LONGCHAR                NO-UNDO.
DEFINE VAR lObtemXMLEvento  AS LOGICAL                 NO-UNDO.

DEFINE VAR iCount           AS INTEGER   INITIAL ?     NO-UNDO.
DEFINE VAR iId              AS INTEGER   INITIAL ?     NO-UNDO.
DEFINE VAR pErrorId         AS INTEGER   INITIAL ?     NO-UNDO.
DEFINE VAR pErrorType       AS CHARACTER INITIAL ?     NO-UNDO.
DEFINE VAR inPtr            AS MEMPTR                  NO-UNDO.
DEFINE VAR lcConteudo       AS LONGCHAR                NO-UNDO.


DEFINE TEMP-TABLE tt_log_erro NO-UNDO
     FIELD ttv_num_cod_erro  AS INTEGER   INITIAL ?
     FIELD ttv_des_msg_ajuda AS CHARACTER INITIAL ?
     FIELD ttv_des_msg_erro  AS CHARACTER INITIAL ? .

DEFINE TEMP-TABLE ttEvento NO-UNDO
     FIELD codEstab     AS CHARACTER INITIAL ?
     FIELD codSerie     AS CHARACTER INITIAL ?
     FIELD codNrNota    AS CHARACTER INITIAL ? FORMAT "x(16)"
     FIELD chNFe        AS CHARACTER INITIAL ? FORMAT "x(44)"
     FIELD cOrgao       AS CHARACTER INITIAL ? FORMAT "x(02)"
     FIELD descEvento   AS CHARACTER INITIAL ? FORMAT "x(18)"
     FIELD dhEvento     AS CHARACTER INITIAL ? FORMAT "x(25)"
     FIELD nSeqEvento   AS CHARACTER INITIAL ? 
     FIELD tpAmb        AS CHARACTER INITIAL ? 
     FIELD cnpj         AS CHARACTER INITIAL ? FORMAT "x(14)"
     FIELD cpf          AS CHARACTER INITIAL ? FORMAT "x(11)"
     FIELD tpEvento     AS CHARACTER INITIAL ? 
     FIELD infEventoID  AS CHARACTER INITIAL ? FORMAT "x(54)"
     FIELD verEvento    AS CHARACTER INITIAL ? 
     FIELD xCondUso     AS CHARACTER INITIAL ? FORMAT "x(1000)"
     FIELD xCorrecao    AS CHARACTER INITIAL ? FORMAT "x(1000)"
     FIELD nProt        AS CHARACTER INITIAL ?
     FIELD xJust        AS CHARACTER INITIAL ?
     INDEX ixttEventoID IS PRIMARY UNIQUE infEventoID ASCENDING.

DEFINE TEMP-TABLE ttStack NO-UNDO
     FIELD ttID  AS INTEGER
     FIELD ttPos AS INTEGER
     INDEX tt_id IS PRIMARY UNIQUE
           ttID  ASCENDING.
                 
FUNCTION addStack RETURN INTEGER (INPUT val AS INTEGER).

    DEFINE VAR id AS INTEGER INITIAL 1 NO-UNDO.
    
    FIND LAST ttStack NO-ERROR.
    IF  AVAIL(ttStack) THEN
        id = ttStack.ttID + 1.

    CREATE ttStack.
    ASSIGN ttStack.ttID = id.
    ASSIGN ttStack.ttPos = val.

END FUNCTION.
    
FUNCTION delStack RETURN INTEGER.
     
    FIND LAST ttStack NO-ERROR.
    IF  AVAIL(ttStack) THEN
        DELETE ttStack.

    FIND LAST ttStack NO-ERROR.

END FUNCTION.
    
FUNCTION getStack RETURN INTEGER.
     
    IF  AVAIL(ttStack) THEN
        RETURN ttStack.ttPos.
    ELSE
        RETURN 0.

END FUNCTION.

DEFINE TEMP-TABLE ttEventoTSS NO-UNDO
    FIELD ID   AS CHAR
    FIELD XML  AS CLOB.

DEFINE TEMP-TABLE ttNFES4 NO-UNDO
    FIELD k        AS ROWID
    FIELD ID       AS CHAR
    FIELD MENSAGEM AS CHAR.

FUNCTION fn-ajusta-espacos-branco RETURNS CHAR (INPUT cCampo AS CHAR).

    /*--- Em uma string, retirar os espacos em branco a mais entre as palavras [mais de 2 espacos] ---*/
    DEFINE VARIABLE cRetiraEspacos AS CHARACTER  NO-UNDO.

    ASSIGN cRetiraEspacos = cCampo.
    DO  WHILE INDEX(cRetiraEspacos, "  ") > 0.
        ASSIGN cRetiraEspacos = REPLACE(cRetiraEspacos, "  ", " ").
    END.
    
    RETURN TRIM(cRetiraEspacos).

END FUNCTION.
