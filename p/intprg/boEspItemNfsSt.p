&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DBOProgram 
/*:T--------------------------------------------------------------------------
    File       : dbo.p
    Purpose    : O DBO (Datasul Business Objects) Ç um programa PROGRESS 
                 que contÇm a l¢gica de neg¢cio e acesso a dados para uma 
                 tabela do banco de dados.

    Parameters : 

    Notes      : 
  ------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.               */
/*------------------------------------------------------------------------*/

/* ***************************  Definitions  **************************** */

/*:T--- Diretrizes de definiá∆o ---*/
&GLOBAL-DEFINE DBOName BOESP-ITEM-NFS-ST
&GLOBAL-DEFINE DBOVersion 
&GLOBAL-DEFINE DBOCustomFunctions 
&GLOBAL-DEFINE TableName esp-item-nfs-st
&GLOBAL-DEFINE TableLabel 
&GLOBAL-DEFINE QueryName qr{&TableName} 

/* DBO-XML-BEGIN */
/*:T Pre-processadores para ativar XML no DBO */
/*:T Retirar o comentario para ativar 
&GLOBAL-DEFINE XMLProducer YES    /*:T DBO atua como producer de mensagens para o Message Broker */
&GLOBAL-DEFINE XMLTopic           /*:T Topico da Mensagem enviada ao Message Broker, geralmente o nome da tabela */
&GLOBAL-DEFINE XMLTableName       /*:T Nome da tabela que deve ser usado como TAG no XML */ 
&GLOBAL-DEFINE XMLTableNameMult   /*:T Nome da tabela no plural. Usado para multiplos registros */ 
&GLOBAL-DEFINE XMLPublicFields    /*:T Lista dos campos (c1,c2) que podem ser enviados via XML. Ficam fora da listas os campos de especializacao da tabela */ 
&GLOBAL-DEFINE XMLKeyFields       /*:T Lista dos campos chave da tabela (c1,c2) */
&GLOBAL-DEFINE XMLExcludeFields   /*:T Lista de campos a serem excluidos do XML quando PublicFields = "" */

&GLOBAL-DEFINE XMLReceiver YES    /*:T DBO atua como receiver de mensagens enviado pelo Message Broker (mÇtodo Receive Message) */
&GLOBAL-DEFINE QueryDefault       /*:T Nome da Query que d† acessos a todos os registros, exceto os exclu°dos pela constraint de seguranáa. Usada para receber uma mensagem XML. */
&GLOBAL-DEFINE KeyField1 cust-num /*:T Informar os campos da chave quando o Progress n∆o conseguir resolver find {&TableName} OF RowObject. */
*/
/* DBO-XML-END */

DEFINE VARIABLE c-cod-estab-entr        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-ser-entr          AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-nota-entr         AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-natur-operac-entr AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-emitente-entr     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-item              AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-num-seq-item-entr     AS INTEGER     NO-UNDO.

/*:T--- Include com definiá∆o da temptable RowObject ---*/
/*:T--- Este include deve ser copiado para o diret¢rio do DBO e, ainda, seu nome
      deve ser alterado a fim de ser idàntico ao nome do DBO mas com 
      extens∆o .i ---*/
//{xxxxxxxx/boxxxxxx.i RowObject}
DEF TEMP-TABLE RowObject LIKE esp-item-nfs-st
    FIELD r-rowid AS ROWID.


/*:T--- Include com definiá∆o da query para tabela {&TableName} ---*/
/*:T--- Em caso de necessidade de alteraá∆o da definiá∆o da query, pode ser retirada
      a chamada ao include a seguir e em seu lugar deve ser feita a definiá∆o 
      manual da query ---*/
{method/dboqry.i}


/*:T--- Definiá∆o de buffer que ser† utilizado pelo mÇtodo goToKey ---*/
DEFINE BUFFER bf{&TableName} FOR {&TableName}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DBOProgram
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DBOProgram
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW DBOProgram ASSIGN
         HEIGHT             = 2
         WIDTH              = 40.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "DBO 2.0 Wizard" DBOProgram _INLINE
/* Actions: wizard/dbowizard.w ? ? ? ? */
/* DBO 2.0 Wizard (DELETE)*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB DBOProgram 
/* ************************* Included-Libraries *********************** */

{method/dbo.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DBOProgram 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calculaSaldoFim DBOProgram 
PROCEDURE calculaSaldoFim :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT-OUTPUT PARAMETER p-sdo-fim         AS DECIMAL     NO-UNDO.
    DEFINE INPUT        PARAMETER h-boEspItemEntrSt AS HANDLE      NO-UNDO.

    RUN linkToByEntrada(INPUT h-boEspItemEntrSt).

    FOR EACH {&TableName}
        WHERE {&TableName}.cod-estab-entr         = c-cod-estab-entr
        AND   {&TableName}.cod-ser-entr           = c-cod-ser-entr
        AND   {&TableName}.cod-nota-entr          = c-cod-nota-entr
        AND   {&TableName}.cod-natur-operac-entr  = c-cod-natur-operac-entr
        AND   {&TableName}.cod-emitente-entr      = c-cod-emitente-entr
        AND   {&TableName}.cod-item               = c-cod-item
        AND   {&TableName}.num-seq-item-entr      = i-num-seq-item-entr:

        ASSIGN p-sdo-fim = p-sdo-fim - {&TableName}.qtd-saida.
    END.

    RETURN "OK".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCharField DBOProgram 
PROCEDURE getCharField :
/*------------------------------------------------------------------------------
  Purpose:     Retorna valor de campos do tipo caracter
  Parameters:  
               recebe nome do campo
               retorna valor do campo
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pFieldName AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pFieldValue AS CHARACTER NO-UNDO.

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
        RETURN "NOK":U.

    CASE pFieldName:
        WHEN "cod-docto-nfs":U THEN ASSIGN pFieldValue = RowObject.cod-docto-nfs.
        WHEN "cod-emitente-entr":U THEN ASSIGN pFieldValue = RowObject.cod-emitente-entr.
        WHEN "cod-estab-entr":U THEN ASSIGN pFieldValue = RowObject.cod-estab-entr.
        WHEN "cod-estab-nfs":U THEN ASSIGN pFieldValue = RowObject.cod-estab-nfs.
        WHEN "cod-item":U THEN ASSIGN pFieldValue = RowObject.cod-item.
        WHEN "cod-natur-operac-entr":U THEN ASSIGN pFieldValue = RowObject.cod-natur-operac-entr.
        WHEN "cod-nota-entr":U THEN ASSIGN pFieldValue = RowObject.cod-nota-entr.
        WHEN "cod-ser-entr":U THEN ASSIGN pFieldValue = RowObject.cod-ser-entr.
        WHEN "cod-ser-nfs":U THEN ASSIGN pFieldValue = RowObject.cod-ser-nfs.
        OTHERWISE RETURN "NOK":U.
    END CASE.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDateField DBOProgram 
PROCEDURE getDateField :
/*------------------------------------------------------------------------------
  Purpose:     Retorna valor de campos do tipo data
  Parameters:  
               recebe nome do campo
               retorna valor do campo
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pFieldName AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pFieldValue AS DATE NO-UNDO.

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
        RETURN "NOK":U.

    CASE pFieldName:
        OTHERWISE RETURN "NOK":U.
    END CASE.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDecField DBOProgram 
PROCEDURE getDecField :
/*------------------------------------------------------------------------------
  Purpose:     Retorna valor de campos do tipo decimal
  Parameters:  
               recebe nome do campo
               retorna valor do campo
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pFieldName AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pFieldValue AS DECIMAL NO-UNDO.

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
        RETURN "NOK":U.

    CASE pFieldName:
        WHEN "qtd-saida":U THEN ASSIGN pFieldValue = RowObject.qtd-saida.
        WHEN "val-base-calc-impto":U THEN ASSIGN pFieldValue = RowObject.val-base-calc-impto.
        WHEN "val-impto":U THEN ASSIGN pFieldValue = RowObject.val-impto.
        OTHERWISE RETURN "NOK":U.
    END CASE.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getIntField DBOProgram 
PROCEDURE getIntField :
/*------------------------------------------------------------------------------
  Purpose:     Retorna valor de campos do tipo inteiro
  Parameters:  
               recebe nome do campo
               retorna valor do campo
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pFieldName AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pFieldValue AS INTEGER NO-UNDO.

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
        RETURN "NOK":U.

    CASE pFieldName:
        WHEN "num-seq-item-entr":U THEN ASSIGN pFieldValue = RowObject.num-seq-item-entr.
        WHEN "num-seq-nfs":U THEN ASSIGN pFieldValue = RowObject.num-seq-nfs.
        OTHERWISE RETURN "NOK":U.
    END CASE.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getKey DBOProgram 
PROCEDURE getKey :
/*------------------------------------------------------------------------------
  Purpose:     Retorna valores dos campos do °ndice idx
  Parameters:  
               retorna valor do campo cod-estab-entr
               retorna valor do campo cod-ser-entr
               retorna valor do campo cod-nota-entr
               retorna valor do campo cod-natur-operac-entr
               retorna valor do campo cod-emitente-entr
               retorna valor do campo num-seq-item-entr
               retorna valor do campo cod-item
               retorna valor do campo cod-estab-nfs
               retorna valor do campo cod-ser-nfs
               retorna valor do campo cod-docto-nfs
               retorna valor do campo num-seq-nfs
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pcod-estab-entr LIKE esp-item-nfs-st.cod-estab-entr NO-UNDO.
    DEFINE OUTPUT PARAMETER pcod-ser-entr LIKE esp-item-nfs-st.cod-ser-entr NO-UNDO.
    DEFINE OUTPUT PARAMETER pcod-nota-entr LIKE esp-item-nfs-st.cod-nota-entr NO-UNDO.
    DEFINE OUTPUT PARAMETER pcod-natur-operac-entr LIKE esp-item-nfs-st.cod-natur-operac-entr NO-UNDO.
    DEFINE OUTPUT PARAMETER pcod-emitente-entr LIKE esp-item-nfs-st.cod-emitente-entr NO-UNDO.
    DEFINE OUTPUT PARAMETER pnum-seq-item-entr LIKE esp-item-nfs-st.num-seq-item-entr NO-UNDO.
    DEFINE OUTPUT PARAMETER pcod-item LIKE esp-item-nfs-st.cod-item NO-UNDO.
    DEFINE OUTPUT PARAMETER pcod-estab-nfs LIKE esp-item-nfs-st.cod-estab-nfs NO-UNDO.
    DEFINE OUTPUT PARAMETER pcod-ser-nfs LIKE esp-item-nfs-st.cod-ser-nfs NO-UNDO.
    DEFINE OUTPUT PARAMETER pcod-docto-nfs LIKE esp-item-nfs-st.cod-docto-nfs NO-UNDO.
    DEFINE OUTPUT PARAMETER pnum-seq-nfs LIKE esp-item-nfs-st.num-seq-nfs NO-UNDO.

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
       RETURN "NOK":U.

    ASSIGN pcod-estab-entr = RowObject.cod-estab-entr
           pcod-ser-entr = RowObject.cod-ser-entr
           pcod-nota-entr = RowObject.cod-nota-entr
           pcod-natur-operac-entr = RowObject.cod-natur-operac-entr
           pcod-emitente-entr = RowObject.cod-emitente-entr
           pnum-seq-item-entr = RowObject.num-seq-item-entr
           pcod-item = RowObject.cod-item
           pcod-estab-nfs = RowObject.cod-estab-nfs
           pcod-ser-nfs = RowObject.cod-ser-nfs
           pcod-docto-nfs = RowObject.cod-docto-nfs
           pnum-seq-nfs = RowObject.num-seq-nfs.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getLogField DBOProgram 
PROCEDURE getLogField :
/*------------------------------------------------------------------------------
  Purpose:     Retorna valor de campos do tipo l¢gico
  Parameters:  
               recebe nome do campo
               retorna valor do campo
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pFieldName AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pFieldValue AS LOGICAL NO-UNDO.

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
        RETURN "NOK":U.

    CASE pFieldName:
        OTHERWISE RETURN "NOK":U.
    END CASE.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRawField DBOProgram 
PROCEDURE getRawField :
/*------------------------------------------------------------------------------
  Purpose:     Retorna valor de campos do tipo raw
  Parameters:  
               recebe nome do campo
               retorna valor do campo
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pFieldName AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pFieldValue AS RAW NO-UNDO.

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
        RETURN "NOK":U.

    CASE pFieldName:
        OTHERWISE RETURN "NOK":U.
    END CASE.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRecidField DBOProgram 
PROCEDURE getRecidField :
/*------------------------------------------------------------------------------
  Purpose:     Retorna valor de campos do tipo recid
  Parameters:  
               recebe nome do campo
               retorna valor do campo
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pFieldName AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pFieldValue AS RECID NO-UNDO.

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
        RETURN "NOK":U.

    CASE pFieldName:
        OTHERWISE RETURN "NOK":U.
    END CASE.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE goToKey DBOProgram 
PROCEDURE goToKey :
/*------------------------------------------------------------------------------
  Purpose:     Reposiciona registro com base no °ndice idx
  Parameters:  
               recebe valor do campo cod-estab-entr
               recebe valor do campo cod-ser-entr
               recebe valor do campo cod-nota-entr
               recebe valor do campo cod-natur-operac-entr
               recebe valor do campo cod-emitente-entr
               recebe valor do campo num-seq-item-entr
               recebe valor do campo cod-item
               recebe valor do campo cod-estab-nfs
               recebe valor do campo cod-ser-nfs
               recebe valor do campo cod-docto-nfs
               recebe valor do campo num-seq-nfs
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pcod-estab-entr LIKE esp-item-nfs-st.cod-estab-entr NO-UNDO.
    DEFINE INPUT PARAMETER pcod-ser-entr LIKE esp-item-nfs-st.cod-ser-entr NO-UNDO.
    DEFINE INPUT PARAMETER pcod-nota-entr LIKE esp-item-nfs-st.cod-nota-entr NO-UNDO.
    DEFINE INPUT PARAMETER pcod-natur-operac-entr LIKE esp-item-nfs-st.cod-natur-operac-entr NO-UNDO.
    DEFINE INPUT PARAMETER pcod-emitente-entr LIKE esp-item-nfs-st.cod-emitente-entr NO-UNDO.
    DEFINE INPUT PARAMETER pnum-seq-item-entr LIKE esp-item-nfs-st.num-seq-item-entr NO-UNDO.
    DEFINE INPUT PARAMETER pcod-item LIKE esp-item-nfs-st.cod-item NO-UNDO.
    DEFINE INPUT PARAMETER pcod-estab-nfs LIKE esp-item-nfs-st.cod-estab-nfs NO-UNDO.
    DEFINE INPUT PARAMETER pcod-ser-nfs LIKE esp-item-nfs-st.cod-ser-nfs NO-UNDO.
    DEFINE INPUT PARAMETER pcod-docto-nfs LIKE esp-item-nfs-st.cod-docto-nfs NO-UNDO.
    DEFINE INPUT PARAMETER pnum-seq-nfs LIKE esp-item-nfs-st.num-seq-nfs NO-UNDO.

    FIND FIRST bfesp-item-nfs-st WHERE 
        bfesp-item-nfs-st.cod-estab-entr = pcod-estab-entr AND 
        bfesp-item-nfs-st.cod-ser-entr = pcod-ser-entr AND 
        bfesp-item-nfs-st.cod-nota-entr = pcod-nota-entr AND 
        bfesp-item-nfs-st.cod-natur-operac-entr = pcod-natur-operac-entr AND 
        bfesp-item-nfs-st.cod-emitente-entr = pcod-emitente-entr AND 
        bfesp-item-nfs-st.num-seq-item-entr = pnum-seq-item-entr AND 
        bfesp-item-nfs-st.cod-item = pcod-item AND 
        bfesp-item-nfs-st.cod-estab-nfs = pcod-estab-nfs AND 
        bfesp-item-nfs-st.cod-ser-nfs = pcod-ser-nfs AND 
        bfesp-item-nfs-st.cod-docto-nfs = pcod-docto-nfs AND 
        bfesp-item-nfs-st.num-seq-nfs = pnum-seq-nfs NO-LOCK NO-ERROR.

    /*--- Verifica se registro foi encontrado, em caso de erro ser† retornada flag "NOK":U ---*/
    IF NOT AVAILABLE bfesp-item-nfs-st THEN 
        RETURN "NOK":U.

    /*--- Reposiciona query atravÇs de rowid e verifica a ocorrància de erros, caso
          existam erros ser† retornada flag "NOK":U ---*/
    RUN repositionRecord IN THIS-PROCEDURE (INPUT ROWID(bfesp-item-nfs-st)).
    IF RETURN-VALUE = "NOK":U THEN
        RETURN "NOK":U.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE linkToByEntrada DBOProgram 
PROCEDURE linkToByEntrada :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER h-boEspItemEntrSt AS HANDLE NO-UNDO.

    RUN getKey IN h-boEspItemEntrSt (OUTPUT c-cod-estab-entr,
                                     OUTPUT c-cod-ser-entr,
                                     OUTPUT c-cod-nota-entr,
                                     OUTPUT c-cod-natur-operac-entr,
                                     OUTPUT c-cod-emitente-entr,
                                     OUTPUT i-num-seq-item-entr,
                                     OUTPUT c-cod-item).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQueryByEntrada DBOProgram 
PROCEDURE openQueryByEntrada :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    OPEN QUERY {&QueryName} FOR EACH {&TableName}
                                WHERE {&TableName}.cod-estab-entr         = c-cod-estab-entr
                                AND   {&TableName}.cod-ser-entr           = c-cod-ser-entr
                                AND   {&TableName}.cod-nota-entr          = c-cod-nota-entr
                                AND   {&TableName}.cod-natur-operac-entr  = c-cod-natur-operac-entr
                                AND   {&TableName}.cod-emitente-entr      = c-cod-emitente-entr
                                AND   {&TableName}.cod-item               = c-cod-item
                                AND   {&TableName}.num-seq-item-entr      = i-num-seq-item-entr
                                NO-LOCK INDEXED-REPOSITION.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateRecord DBOProgram 
PROCEDURE validateRecord :
/*:T------------------------------------------------------------------------------
  Purpose:     Validaá‰es pertinentes ao DBO
  Parameters:  recebe o tipo de validaá∆o (Create, Delete, Update)
  Notes:       
------------------------------------------------------------------------------*/
    
    DEFINE INPUT PARAMETER pType AS CHARACTER NO-UNDO.
    
    /*:T--- Utilize o parÉmetro pType para identificar quais as validaá‰es a serem
          executadas ---*/
    /*:T--- Os valores poss°veis para o parÉmetro s∆o: Create, Delete e Update ---*/
    /*:T--- Devem ser tratados erros PROGRESS e erros do Produto, atravÇs do 
          include: method/svc/errors/inserr.i ---*/
    /*:T--- Inclua aqui as validaá‰es ---*/
    
    /*:T--- Verifica ocorrància de erros ---*/
    IF CAN-FIND(FIRST RowErrors WHERE RowErrors.ErrorSubType = "ERROR":U) THEN
        RETURN "NOK":U.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

