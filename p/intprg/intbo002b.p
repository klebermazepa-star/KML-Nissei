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

/* {utp/ut-glob.i} */ 
def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.
            
/*:T--- Diretrizes de definiá∆o ---*/
&GLOBAL-DEFINE DBOName intbo002b
&GLOBAL-DEFINE DBOVersion 
&GLOBAL-DEFINE DBOCustomFunctions 
&GLOBAL-DEFINE TableName int-ds-it-docto-xml
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

/*:T--- Include com definiá∆o da temptable RowObject ---*/
/*:T--- Este include deve ser copiado para o diret¢rio do DBO e, ainda, seu nome
      deve ser alterado a fim de ser idàntico ao nome do DBO mas com 
      extens∆o .i ---*/
      
{intprg/intbo002b.i RowObject}


/*:T--- Include com definiá∆o da query para tabela {&TableName} ---*/
/*:T--- Em caso de necessidade de alteraá∆o da definiá∆o da query, pode ser retirada
      a chamada ao include a seguir e em seu lugar deve ser feita a definiá∆o 
      manual da query ---*/
{method/dboqry.i}


/*:T--- Definiá∆o de buffer que ser† utilizado pelo mÇtodo goToKey ---*/
DEFINE BUFFER bf{&TableName} FOR {&TableName}.

DEFINE VARIABLE i-sequencia    AS INT   NO-UNDO.
DEFINE VARIABLE i-cod-emitente AS INT   NO-UNDO.
DEFINE VARIABLE c-serie        AS CHAR  NO-UNDO.
DEFINE VARIABLE c-nro-docto    AS CHAR  NO-UNDO.
DEFINE VARIABLE i-tipo-nota    AS INT   NO-UNDO.

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
         HEIGHT             = 8
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
       
        WHEN "it-codigo":U THEN ASSIGN pFieldValue = RowObject.it-codigo.
        WHEN "uCom":U      THEN ASSIGN pFieldValue = RowObject.uCom.
        WHEN "lote"        THEN ASSIGN pFieldValue = RowObject.lote.
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
        WHEN "dFab":U THEN ASSIGN pFieldValue = RowObject.dFab.
        WHEN "dval":U THEN ASSIGN pFieldValue = RowObject.dVal.
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

    IF c-seg-usuario = "super" THEN
       MESSAGE RowObject.vDesc "RowObject.vDesc tela"
           VIEW-AS ALERT-BOX INFO BUTTONS OK.

    CASE pFieldName:
        WHEN "qOrdem":U      THEN ASSIGN pFieldValue = RowObject.qOrdem.
        WHEN "qCom":U        THEN ASSIGN pFieldValue = RowObject.qCom.
        WHEN "qcom-forn"     THEN ASSIGN pfieldvalue = RowObject.qCom-forn.
        WHEN "vDesc":U       THEN ASSIGN pFieldValue = RowObject.vDesc.
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
        WHEN "sequencia":U THEN ASSIGN pFieldValue = RowObject.sequencia.
        WHEN "num-pedido":U THEN ASSIGN pFieldValue = RowObject.num-pedido.
        WHEN "numero-ordem":U THEN ASSIGN pFieldValue = RowObject.numero-ordem.
        
        OTHERWISE RETURN "NOK":U.
    END CASE.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getKey DBOProgram 
PROCEDURE getKey :
/*------------------------------------------------------------------------------
  Purpose:     Retorna valores dos campos do °ndice processo
  Parameters:  
               retorna valor do campo processo
               retorna valor do campo seq
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pcod-emitente LIKE int-ds-docto-xml.cod-emitente NO-UNDO.
    DEFINE OUTPUT PARAMETER pserie        LIKE int-ds-docto-xml.serie        NO-UNDO.
    DEFINE OUTPUT PARAMETER pnro-docto    LIKE int-ds-docto-xml.nnf          NO-UNDO.
    DEFINE OUTPUT PARAMETER ptipo-nota    AS INT                             NO-UNDO.
    DEFINE OUTPUT PARAMETER psequencia LIKE int-ds-it-docto-xml.sequencia    NO-UNDO.
                         

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
       RETURN "NOK":U.

    ASSIGN pcod-emitente  = RowObject.cod-emitente
           pserie         = RowObject.serie
           pnro-docto     = RowObject.nNF
           ptipo-nota     = RowObject.tipo-nota
           psequencia     = RowObject.sequencia.


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

    /* CASE pFieldName:
        WHEN "log-1":U THEN ASSIGN pFieldValue = RowObject.log-1.
        OTHERWISE RETURN "NOK":U.
    END CASE.
    */

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
  Purpose:     Reposiciona registro com base no °ndice processo
  Parameters:  
               recebe valor do campo processo
               recebe valor do campo seq
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE input PARAMETER pcod-emitente LIKE int-ds-docto-xml.cod-emitente NO-UNDO.
    DEFINE input PARAMETER pserie        LIKE int-ds-docto-xml.serie        NO-UNDO.
    DEFINE input PARAMETER pnro-docto    LIKE int-ds-docto-xml.nnf          NO-UNDO.
    DEFINE input PARAMETER ptipo-nota    AS INT                             NO-UNDO.
    DEFINE input PARAMETER psequencia LIKE int-ds-it-docto-xml.sequencia    NO-UNDO.
    
    FIND FIRST bfint-ds-it-docto-xml WHERE 
               bfint-ds-it-docto-xml.cod-emitente = psequencia AND
               bfint-ds-it-docto-xml.serie        = pserie     AND
               bfint-ds-it-docto-xml.nNF          = pnro-docto AND
               bfint-ds-it-docto-xml.tipo-nota    = ptipo-nota AND
               bfint-ds-it-docto-xml.sequencia    = psequencia NO-LOCK NO-ERROR.

    /*--- Verifica se registro foi encontrado, em caso de erro ser† retornada flag "NOK":U ---*/
    IF NOT AVAILABLE bfint-ds-it-docto-xml THEN 
        RETURN "NOK":U.

    /*--- Reposiciona query atravÇs de rowid e verifica a ocorrància de erros, caso
          existam erros ser† retornada flag "NOK":U ---*/
    RUN repositionRecord IN THIS-PROCEDURE (INPUT ROWID(bfint-ds-it-docto-xml)).
    IF RETURN-VALUE = "NOK":U THEN
        RETURN "NOK":U.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE linktoNota DBOProgram 
PROCEDURE linktoNota :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pHandle AS HANDLE NO-UNDO.

    RUN getKey IN pHandle (OUTPUT i-cod-emitente ,
                           OUTPUT c-serie ,
                           OUTPUT c-nro-docto,
                           OUTPUT i-tipo-nota).
   
    RUN setConstraintNota IN THIS-PROCEDURE (INPUT i-cod-emitente ,
                                             INPUT c-serie ,
                                             INPUT c-nro-docto,
                                             INPUT i-tipo-nota).

    RETURN "Ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenQueryItem DBOProgram 
PROCEDURE OpenQueryItem :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    OPEN QUERY {&QueryName} FOR EACH {&TableName} NO-LOCK
         WHERE {&TableName}.cod-emitente = i-cod-emitente 
         AND   {&TableName}.serie        = c-serie        
         AND   INT({&TableName}.nNF)     =  int(c-nro-docto)    
         AND   {&TableName}.tipo-nota    =  i-tipo-nota.   
                           

    RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenQueryMain DBOProgram 
PROCEDURE OpenQueryMain :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    OPEN QUERY {&QueryName} FOR EACH {&TableName} NO-LOCK.

    RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setConstraintNota DBOProgram 
PROCEDURE setConstraintNota :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-cod-emitente AS INT   NO-UNDO.
DEFINE INPUT PARAMETER p-serie        AS CHAR  NO-UNDO.
DEFINE INPUT PARAMETER p-nro-docto    AS CHAR  NO-UNDO.
DEFINE INPUT PARAMETER p-tipo-nota    AS INT   NO-UNDO.

ASSIGN i-cod-emitente      = p-cod-emitente
       c-serie             = p-serie       
       c-nro-docto         = p-nro-docto   
       i-tipo-nota         = p-tipo-nota.  

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
    
    DEF VAR d-tot-qtd LIKE RowObject.qCom NO-UNDO.
    def var l-valida  as logical.

    /*:T--- Utilize o parÉmetro pType para identificar quais as validaá‰es a serem
          executadas ---*/
    /*:T--- Os valores poss°veis para o parÉmetro s∆o: Create, Delete e Update ---*/
    /*:T--- Devem ser tratados erros PROGRESS e erros do Produto, atravÇs do 
          include: method/svc/errors/inserr.i ---*/
    /*:T--- Inclua aqui as validaá‰es ---*/
    
              
    IF pType = "create" THEN DO:
        FIND FIRST int-ds-it-docto-xml NO-LOCK WHERE 
                   int-ds-it-docto-xml.cod-emitente = RowObject.cod-emitente AND 
                   int-ds-it-docto-xml.serie        = RowObject.serie        AND
                   int-ds-it-docto-xml.nNF          = RowObject.nNF          AND
                   int-ds-it-docto-xml.tipo-nota    = RowObject.tipo-nota    AND 
                   int-ds-it-docto-xml.sequencia    = RowObject.sequencia NO-ERROR.
        IF AVAIL int-ds-it-docto-xml THEN DO:
               {method/svc/errors/inserr.i
                        &ErrorNumber="17006"
                        &ErrorType="EMS"
                        &ErrorSubType="ERROR" 
                        &ErrorParameters="'Item Nota j† cadastrado com a sequencia informada '"}
        END.

        FIND FIRST ITEM
             WHERE ITEM.it-codigo = RowObject.it-codigo NO-LOCK NO-ERROR.
        IF NOT AVAIL ITEM THEN DO:
           {method/svc/errors/inserr.i
                              &ErrorNumber="17006"
                              &ErrorType="EMS"
                              &ErrorSubType="ERROR" 
                              &ErrorParameters="'Item n∆o cadastrado'"}
        END.

        
        FIND FIRST int-ds-docto-xml exclusive-LOCK WHERE 
                   int-ds-docto-xml.cod-emitente = RowObject.cod-emitente AND 
                   int-ds-docto-xml.serie        = RowObject.serie        AND
                   int-ds-docto-xml.nNF          = RowObject.nNF          AND
                   int-ds-docto-xml.tipo-nota    = RowObject.tipo-nota    NO-ERROR.
        IF AVAIL int-ds-docto-xml THEN DO:
            ASSIGN int-ds-docto-xml.tipo-doc = 0.
        END.

        RELEASE int-ds-docto-xml.
    END.

    IF pType <> "delete" THEN DO:
        
       IF RowObject.qCom-forn = 0 THEN DO:
           {method/svc/errors/inserr.i
                             &ErrorNumber="17006"
                             &ErrorType="EMS"
                             &ErrorSubType="ERROR" 
                             &ErrorParameters="'Quantidade n∆o pode ser Zero.'"}
       END.
       
       assign l-valida = yes.
       
       find first param-re no-lock where
                  param-re.usuario = c-seg-usuario no-error.
       if avail param-re then 
          assign l-valida = not param-re.sem-pedido.           
                  
       if l-valida = yes 
       then do:
            
          FIND FIRST pedido-compr NO-LOCK WHERE
                     pedido-compr.num-pedido = RowObject.num-pedido NO-ERROR.
          IF NOT AVAIL pedido-compr THEN DO:
   
             {method/svc/errors/inserr.i
                                 &ErrorNumber="17006"
                                 &ErrorType="EMS"
                                 &ErrorSubType="ERROR" 
                                 &ErrorParameters="'Pedido de compra n∆o cadastrado'"}
   
          END.
   
          /* FIND FIRST ordem-compra NO-LOCK WHERE
                     ordem-compra.numero-ordem = RowObject.numero-ordem NO-ERROR.
          IF NOT AVAIL ordem-compra THEN DO:
   
             {method/svc/errors/inserr.i
                                 &ErrorNumber="17006"
                                 &ErrorType="EMS"
                                 &ErrorSubType="ERROR" 
                                 &ErrorParameters="'Ordem de compra n∆o cadastrada'"}
   
          END. */
          
       end.
       
       IF RowObject.nat-operacao <> "" 
       THEN DO:  
                                                    
              FIND FIRST natur-oper NO-LOCK WHERE
                         natur-oper.nat-operacao = RowObject.nat-operacao NO-ERROR.
              IF NOT AVAIL natur-oper THEN DO:
    
                {method/svc/errors/inserr.i
                                   &ErrorNumber="17006"
                                   &ErrorType="EMS"
                                   &ErrorSubType="ERROR" 
                                   &ErrorParameters="'Natureza de operacao n∆o cadastrada'"}
    
              END. 
              ELSE 
                  ASSIGN  rowObject.cfop = int(natur-oper.cod-cfop).  /* Verificar com Clausen */

       END.

       IF RowObject.situacao > 2 THEN DO:

            {method/svc/errors/inserr.i
                              &ErrorNumber="17006"
                              &ErrorType="EMS"
                              &ErrorSubType="ERROR" 
                              &ErrorParameters="'Situaá∆o n∆o pode ser alterada.'"}


       END. 

    END.
    
    /*:T--- Verifica ocorrància de erros ---*/
    IF CAN-FIND(FIRST RowErrors WHERE RowErrors.ErrorSubType = "ERROR":U) THEN
        RETURN "NOK":U.
   
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

