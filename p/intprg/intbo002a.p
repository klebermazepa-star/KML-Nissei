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
&GLOBAL-DEFINE DBOName intbo002a
&GLOBAL-DEFINE DBOVersion 
&GLOBAL-DEFINE DBOCustomFunctions 
&GLOBAL-DEFINE TableName int-ds-docto-xml
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
{intprg/intbo002a.i RowObject}


/*:T--- Include com definiá∆o da query para tabela {&TableName} ---*/
/*:T--- Em caso de necessidade de alteraá∆o da definiá∆o da query, pode ser retirada
      a chamada ao include a seguir e em seu lugar deve ser feita a definiá∆o 
      manual da query ---*/
{method/dboqry.i}
{utp/ut-glob.i}


/*:T--- Definiá∆o de buffer que ser† utilizado pelo mÇtodo goToKey ---*/
DEFINE BUFFER bf{&TableName} FOR {&TableName}.

DEFINE VARIABLE i-emitente-ini     AS INTEGER  NO-UNDO.
DEFINE VARIABLE i-emitente-fim     AS INTEGER  NO-UNDO.
DEFINE VARIABLE c-nr-nota-ini      AS CHAR     NO-UNDO.
DEFINE VARIABLE c-nr-nota-fim      AS CHAR     NO-UNDO.
DEFINE VARIABLE c-serie-ini        AS char     NO-UNDO.
DEFINE VARIABLE c-serie-fim        AS char     NO-UNDO.
DEFINE VARIABLE dt-data-ini        AS DATE     NO-UNDO.
DEFINE VARIABLE dt-data-fim        AS DATE     NO-UNDO.
DEFINE VARIABLE i-sit-ini          AS INTEGER  NO-UNDO.
DEFINE VARIABLE i-sit-fim          AS INTEGER  NO-UNDO.

DEFINE VARIABLE i-nr-nota-ini      AS INT  NO-UNDO.
DEFINE VARIABLE i-nr-nota-fim      AS INT  NO-UNDO.

  
  

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
         HEIGHT             = 17.33
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
        WHEN "cod-emitente":U THEN ASSIGN pFieldValue = RowObject.cod-emitente.
        WHEN "num-pedido"    THEN  ASSIGN pFieldValue = RowObject.num-pedido.
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
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pcod-emitente LIKE int-ds-docto-xml.cod-emitente NO-UNDO.
    DEFINE OUTPUT PARAMETER pserie        LIKE int-ds-docto-xml.serie        NO-UNDO.
    DEFINE OUTPUT PARAMETER pnro-docto    LIKE int-ds-docto-xml.nnf          NO-UNDO.
    DEFINE OUTPUT PARAMETER ptipo-nota    AS INT                             NO-UNDO.
                         

    /*--- Verifica se temptable RowObject est† dispon°vel, caso n∆o esteja ser†
          retornada flag "NOK":U ---*/
    IF NOT AVAILABLE RowObject THEN 
       RETURN "NOK":U.

    ASSIGN pcod-emitente  = RowObject.cod-emitente
           pserie         = RowObject.serie
           pnro-docto     = RowObject.nNF
           ptipo-nota     = RowObject.tipo-nota.
           

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
  Purpose:     Reposiciona registro com base no °ndice processo
  Parameters:  
               recebe valor do campo processo
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pcod-emitente LIKE int-ds-docto-xml.cod-emitente NO-UNDO.
    DEFINE INPUT PARAMETER pserie        LIKE int-ds-docto-xml.serie        NO-UNDO.
    DEFINE INPUT PARAMETER pnro-docto    LIKE int-ds-docto-xml.nnf          NO-UNDO.
    DEFINE INPUT PARAMETER ptipo-nota    AS INT                             NO-UNDO.
   
    FIND FIRST bfint-ds-docto-xml NO-LOCK WHERE 
               bfint-ds-docto-xml.cod-emitente = pcod-emitente AND
               bfint-ds-docto-xml.serie        = pserie        AND
               int(bfint-ds-docto-xml.nnf)     = int(pnro-docto) AND
               bfint-ds-docto-xml.tipo-nota    = ptipo-nota  NO-ERROR. 
       
    /*--- Verifica se registro foi encontrado, em caso de erro ser† retornada flag "NOK":U ---*/
    IF NOT AVAILABLE bfint-ds-docto-xml THEN 
        RETURN "NOK":U.

    /*--- Reposiciona query atravÇs de rowid e verifica a ocorrància de erros, caso
          existam erros ser† retornada flag "NOK":U ---*/
    RUN repositionRecord IN THIS-PROCEDURE (INPUT ROWID(bfint-ds-docto-xml)).
    IF RETURN-VALUE = "NOK":U THEN
        RETURN "NOK":U.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenQueryEmitente DBOProgram 
PROCEDURE OpenQueryEmitente :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    OPEN QUERY {&QueryName} FOR EACH {&TableName} NO-LOCK WHERE
                                     {&TableName}.cod-emitente >= i-emitente-ini
                                 AND {&TableName}.cod-emitente <= i-emitente-fim
                                 AND {&TableName}.demi         >= dt-data-ini
                                 AND {&TableName}.demi         <= dt-data-fim
                                 AND {&TableName}.situacao     >= i-sit-ini
                                 AND {&TableName}.situacao     <= i-sit-fim  
                                 AND {&TableName}.tipo-estab = 1.


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

    OPEN QUERY {&QueryName} FOR EACH {&TableName} NO-LOCK WHERE
                                     {&TableName}.tipo-estab = 1.
    
    
    RETURN "Ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenQueryNota DBOProgram 
PROCEDURE OpenQueryNota :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    ASSIGN i-nr-nota-ini = int(c-nr-nota-ini) 
           i-nr-nota-fim = int(c-nr-nota-fim).

    OPEN QUERY {&QueryName} FOR EACH {&TableName} NO-LOCK
                               WHERE INT({&TableName}.nnf)  >= i-nr-nota-ini 
                                 AND INT({&TableName}.nnf)  <= i-nr-nota-fim
                                 AND {&TableName}.serie     >= c-serie-ini
                                 AND {&TableName}.serie     <= c-serie-fim
                                 AND {&TableName}.demi      >= dt-data-ini
                                 AND {&TableName}.demi      <= dt-data-fim
                                 AND {&TableName}.situacao  >= i-sit-ini
                                 AND {&TableName}.situacao  <= i-sit-fim
                                 AND {&TableName}.tipo-estab = 1.

    RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setConstraintEmitente DBOProgram 
PROCEDURE setConstraintEmitente :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    DEFINE INPUT  PARAMETER p-emitente-ini AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER p-emitente-fim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER p-dt-emit-ini  AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER p-dt-emit-fim  AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER p-situacao     AS INTEGER     NO-UNDO.
    
    ASSIGN i-emitente-ini = p-emitente-ini
           i-emitente-fim = p-emitente-fim 
           dt-data-ini    = p-dt-emit-ini
           dt-data-fim    = p-dt-emit-fim.
                                
    IF p-situacao = 4 THEN
       ASSIGN i-sit-ini = 1
              i-sit-fim = 3.
    ELSE 
       ASSIGN i-sit-ini = p-situacao
              i-sit-fim = p-situacao.
                          

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

    DEFINE INPUT  PARAMETER p-nr-nota-ini    AS CHAR       NO-UNDO.
    DEFINE INPUT  PARAMETER p-nr-nota-fim    AS CHAR       NO-UNDO.
    DEFINE INPUT  PARAMETER p-serie-ini      AS char       NO-UNDO.
    DEFINE INPUT  PARAMETER p-serie-fim      AS CHAR       NO-UNDO.
    DEFINE INPUT  PARAMETER p-dt-emit-ini    AS DATE       NO-UNDO.
    DEFINE INPUT  PARAMETER p-dt-emit-fim    AS DATE       NO-UNDO.
    DEFINE INPUT  PARAMETER p-situacao       AS INTEGER    NO-UNDO.


    ASSIGN c-nr-nota-ini    = p-nr-nota-ini
           c-nr-nota-fim    = p-nr-nota-fim
           c-serie-ini      = p-serie-ini  
           c-serie-fim      = p-serie-fim  
           dt-data-ini      = p-dt-emit-ini
           dt-data-fim      = p-dt-emit-fim.
                                
    IF p-situacao = 4 THEN
       ASSIGN i-sit-ini = 1
              i-sit-fim = 3.
    ELSE 
       ASSIGN i-sit-ini = p-situacao
              i-sit-fim = p-situacao.

    RETURN "ok".
    
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
    
    DEF VAR c-serie AS CHAR NO-UNDO.
    
    /*:T--- Utilize o parÉmetro pType para identificar quais as validaá‰es a serem
          executadas ---*/
    /*:T--- Os valores poss°veis para o parÉmetro s∆o: Create, Delete e Update ---*/
    /*:T--- Devem ser tratados erros PROGRESS e erros do Produto, atravÇs do 
          include: method/svc/errors/inserr.i ---*/
    /*:T--- Inclua aqui as validaá‰es ---*/
     
    IF pType = "create" THEN DO:

        FIND FIRST int-ds-docto-xml NO-LOCK WHERE 
                   int-ds-docto-xml.cod-emitente = RowObject.cod-emitente AND 
                   int-ds-docto-xml.serie        = RowObject.serie        AND
                   int(int-ds-docto-xml.nNF)     = int(RowObject.nNF)     AND
                   int-ds-docto-xml.tipo-nota    = RowObject.tipo-nota NO-ERROR.
        IF AVAIL int-ds-docto-xml THEN DO:
               {method/svc/errors/inserr.i
                        &ErrorNumber="17006"
                        &ErrorType="EMS"
                        &ErrorSubType="ERROR" 
                        &ErrorParameters="'Nota j† cadastrada'"}
        END.
               
        FIND FIRST serie NO-LOCK WHERE 
                   serie.serie = RowObject.serie NO-ERROR.
        IF NOT AVAIL serie THEN DO:
               {method/svc/errors/inserr.i
                        &ErrorNumber="17006"
                        &ErrorType="EMS"
                        &ErrorSubType="ERROR" 
                        &ErrorParameters="'Serie n∆o cadastrada.'"}
        END.
      
        FIND FIRST emitente NO-LOCK WHERE 
                   emitente.cod-emitente = RowObject.cod-emitente NO-ERROR.
        IF NOT AVAIL emitente THEN DO:
               {method/svc/errors/inserr.i
                        &ErrorNumber="17006"
                        &ErrorType="EMS"
                        &ErrorSubType="ERROR" 
                        &ErrorParameters="'Emitente n∆o cadastrado.'"}
        END.
        ELSE DO:
            ASSIGN RowObject.cnpj = emitente.cgc.
        END.
       
    END.

    IF pType = "delete" 
    THEN DO:

        IF RowObject.situacao = 3 THEN DO:
         
             {method/svc/errors/inserr.i
                        &ErrorNumber="17006"
                        &ErrorType="EMS"
                        &ErrorSubType="ERROR" 
                        &ErrorParameters="'Documento Atualizado , n∆o permite eliminaá∆o.'"}

        END.
        ELSE DO:

            IF rowobject.tipo-docto = 4  /* Notas Pepsico */
            THEN DO:
               
               DO TRANS:
               
                   IF rowobject.chnft <> ? AND 
                      rowobject.chnft <> "" 
                   THEN DO:
                       ASSIGN c-serie = rowobject.chnft. /* serie original */
                   END.
                   ELSE DO:
                       ASSIGN c-serie = rowobject.serie.
                   END.

                   for each int-ds-docto-wms where
                       int-ds-docto-wms.doc_numero_n   = INT(rowobject.nnf) and
                       int-ds-docto-wms.doc_serie_s    = c-serie            and
                       int-ds-docto-wms.cnpj           = rowobject.cnpj:    
                       delete int-ds-docto-wms.
                   end.
                   CREATE int-ds-docto-wms.
                   ASSIGN int-ds-docto-wms.doc_numero_n   = INT(rowobject.nnf)
                          int-ds-docto-wms.doc_serie_s    = c-serie   
                          int-ds-docto-wms.doc_origem_n   = rowobject.cod-emitente
                          int-ds-docto-wms.situacao       = 50 /* Em cancelamento */
                          int-ds-docto-wms.tipo-nota      = 1 /* Em cancelamento */.
    
                   FIND FIRST emitente WHERE
                              emitente.cod-emitente = rowobject.cod-emitente NO-LOCK NO-ERROR.
                   IF AVAIL emitente THEN 
                      ASSIGN int-ds-docto-wms.cnpj_cpf        = emitente.cgc 
                             int-ds-docto-wms.tipo_fornecedor = IF emitente.natureza = 1 THEN "F" ELSE "J".
                   release int-ds-docto-wms.
               END.
               /* evitando que o registro fique pendente de cancelamento dada a falta de retorno do PRS */
               for each int-ds-docto-wms where
                   int-ds-docto-wms.doc_numero_n   = INT(rowobject.nnf)      and
                   int-ds-docto-wms.doc_serie_s    = c-serie                 and
                   int-ds-docto-wms.cnpj           = rowobject.cnpj: 
                   assign int-ds-docto-wms.situacao  = 60. /* Cancelada */
               end.
            END.

            FOR EACH int-ds-it-docto-xml EXCLUSIVE-LOCK WHERE
                     int-ds-it-docto-xml.cod-emitente = RowObject.cod-emitente AND
                     int-ds-it-docto-xml.serie        = RowObject.serie        AND
                     int(int-ds-it-docto-xml.nnf)     = int(RowObject.nnf)     AND
                     int-ds-it-docto-xml.tipo-nota    = RowObject.tipo-nota    AND 
                     int-ds-it-docto-xml.sequencia    > 0 :
                  
                 DELETE int-ds-it-docto-xml.
                  
            END.
            
        END.
    END.

    IF pType <> "delete" THEN DO:
          
        IF RowObject.nat-operacao <> "" 
        THEN DO:
        
            FIND FIRST natur-oper NO-LOCK WHERE 
                       natur-oper.nat-operacao = RowObject.nat-operacao NO-ERROR.
            IF NOT AVAIL natur-oper THEN DO:
                   {method/svc/errors/inserr.i
                            &ErrorNumber="17006"
                            &ErrorType="EMS"
                            &ErrorSubType="ERROR" 
                            &ErrorParameters="'Natureza de Operaá∆o n∆o cadastrado.'"}
            END.


        END.

        IF RowObject.situacao = 3 THEN DO:
         
             {method/svc/errors/inserr.i
                        &ErrorNumber="17006"
                        &ErrorType="EMS"
                        &ErrorSubType="ERROR" 
                        &ErrorParameters="'Documento Atualizado , n∆o permite Alteraá∆o.'"}

        END.

        FIND FIRST estabelec NO-LOCK WHERE
                   estabelec.cod-estabel = RowObject.cod-estab NO-ERROR.
        IF AVAIL estabelec THEN
           ASSIGN RowObject.cnpj-dest = estabelec.cgc.

    END.

    /* ASSIGN RowObject.despesa-nota   = 1
           RowObject.estab-de-or    = "973"
           RowObject.observacao     = "TESTE"
           RowObject.tot-desconto   = 1
           RowObject.valor-frete    = 1
           RowObject.valor-mercad   = 1
           RowObject.valor-outras   = 1
           RowObject.valor-seguro   = 1
           RowObject.vbc            = 1
           RowObject.valor-icms     = 1
           RowObject.valor-icms-des = 1
           RowObject.vbc-cst        = 1
           RowObject.valor-st       = 1
           RowObject.valor-ii       = 1
           RowObject.valor-ipi      = 1
           RowObject.valor-pis      = 1
           RowObject.valor-cofins   = 1.
          
       
    MESSAGE    RowObject.ep-codigo            "   ep-codigo         "              skip   
               length(RowObject.arquivo)      "   arquivo           "              SKIP
               length(RowObject.serie)        "   length(serie)     "              skip
               LENGTH(RowObject.nNF)          "   LENGTH(nNF)       "              skip
               RowObject.dEmi                 "   dEmi              "              skip
               RowObject.dt-trans             "   dt-trans          "              skip
               length(RowObject.CNPJ)         "   length(CNPJ)      "              skip
               RowObject.situacao             "   situacao          "              skip
               LENGTH(RowObject.xNome)        "   LENGTH(xNome)     "              skip
               RowObject.tipo-nota            "   tipo-nota         "              skip
               RowObject.vNF                  "   vNF               "              skip
               RowObject.cod-emitente         "   cod-emitente      "              skip
               LENGTH(RowObject.chnfe)        "   LENGTH(chnfe)     "              skip
               LENGTH(RowObject.CNPJ-dest)    "   LENGTH(CNPJ-dest) "              skip
               LENGTH(RowObject.volume)       "   LENGTH(volume)    "              skip
               RowObject.tipo-docto           "   tipo-docto        "              skip
               LENGTH(RowObject.cod-estab)    "   LENGTH(cod-estab) "              skip
               LENGTH(RowObject.cod-usuario)  "   LENGTH(cod-usuario"              skip
               RowObject.despesa-nota         "   despesa-nota      "              skip
               RowObject.dt-atualiza          "   dt-atualiza       "              skip
               LENGTH(RowObject.estab-de-or)  "   LENGTH(estab-de-or"              skip
               LENGTH(RowObject.observacao)   "   LENGTH(observacao)"              skip
               RowObject.tot-desconto         "   tot-desconto      "              skip
               RowObject.valor-frete          "   valor-frete       "              skip
               RowObject.valor-mercad         "   valor-mercad      "              skip
               RowObject.valor-outras         "   valor-outras      "              skip
               RowObject.valor-seguro         "   valor-seguro      "              skip
               RowObject.sit-re               "   sit-re            "              skip
               RowObject.vbc                  "   vbc               "              skip
               RowObject.valor-icms           "   valor-icms        "              skip
               RowObject.valor-icms-des       "   valor-icms-des    "              skip
               RowObject.vbc-cst              "   vbc-cst           "              skip
               RowObject.valor-st             "   valor-st          "              skip
               RowObject.valor-ii             "   valor-ii          "              skip
               RowObject.valor-ipi            "   valor-ipi         "              skip
               RowObject.valor-pis            "   valor-pis         "              skip
               RowObject.valor-cofins         "   valor-cofins      "              skip
               LENGTH(RowObject.chnft)        "   LENGTH(chnft)     "              skip
               RowObject.tipo-estab           "   tipo-estab        "              skip
               RowObject.modFrete             "   modFrete          "              skip
               LENGTH(RowObject.nat-operacao) "   LENGTH(nat-operaca"              skip
               RowObject.num-pedido           "   num-pedido        "              skip
               RowObject.cfop                 "   cfop              "              skip
              VIEW-AS ALERT-BOX.
       */

    /*:T--- Verifica ocorrància de erros ---*/
    IF CAN-FIND(FIRST RowErrors WHERE RowErrors.ErrorSubType = "ERROR":U) THEN
        RETURN "NOK":U.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

