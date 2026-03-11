{utp/ut-glob.i}

//****************************************************************************************************

//--------------------------------------------------------------------------------
// dados do log ativo
//--------------------------------------------------------------------------------
def var c-LOGFILE-NAME      as char no-undo.
def var c-LOG-ENTRY-TYPES   as char no-undo.
def var i-LOGGING-LEVEL     as inte no-undo.

ASSIGN c-LOGFILE-NAME    = LOG-MANAGER:LOGFILE-NAME
       c-LOG-ENTRY-TYPES = LOG-MANAGER:LOG-ENTRY-TYPES
       i-LOGGING-LEVEL   = LOG-MANAGER:LOGGING-LEVEL.

PROCEDURE ativarLog :

    def input param p-c-nome-pasta   as char no-undo.
    def input param p-c-nome-arquivo as char no-undo.
    
    //--------------------------------------------------------------------------------
    // nome da pasta
    //--------------------------------------------------------------------------------

    IF  p-c-nome-pasta = "" THEN DO:
        FIND FIRST usuar_mestre WHERE usuar_mestre.cod_usuario = c-seg-usuario NO-LOCK NO-ERROR.
            
        ASSIGN p-c-nome-pasta = IF AVAIL usuar_mestre AND usuar_mestre.nom_dir_spool <> "" 
                                THEN (usuar_mestre.nom_dir_spool + "/")
                                ELSE (SESSION:TEMP-DIRECTORY + "/").
    END.
    ELSE
        ASSIGN p-c-nome-pasta = p-c-nome-pasta + "/".

    IF  OPSYS BEGINS "WIN" THEN
        ASSIGN p-c-nome-pasta = replace(p-c-nome-pasta, "/", "\")
               p-c-nome-pasta = replace(p-c-nome-pasta, "\\", "\").
    ELSE
        ASSIGN p-c-nome-pasta = replace(p-c-nome-pasta, "\", "/")
               p-c-nome-pasta = replace(p-c-nome-pasta, "//", "/").
    
    //--------------------------------------------------------------------------------
    // nome do arquivo
    //--------------------------------------------------------------------------------
    IF  p-c-nome-arquivo = "" THEN
        ASSIGN p-c-nome-arquivo = "RPA_LOG_" 
                                  + c-seg-usuario + "_"
                                  + substring(string(year(today),"9999"),3,2) + string(month(today),"99") + string(day(today),"99") + "_" 
                                  + REPLACE(STRING(TIME,"HH:MM:SS"),":", "") 
                                  + ".log":U.
                                  
    ASSIGN p-c-nome-arquivo = p-c-nome-pasta + p-c-nome-arquivo.

    //--------------------------------------------------------------------------------
    
    ASSIGN LOG-MANAGER:LOGFILE-NAME    = p-c-nome-arquivo
           LOG-MANAGER:LOG-ENTRY-TYPES = ?.
    ASSIGN LOG-MANAGER:LOGGING-LEVEL   = 4
           LOG-MANAGER:LOG-ENTRY-TYPES = "4GLMessages,4GLTrace,FileID,4GLTrans".

    RUN gravarDadosSessao.

    //run utp/ut-msgs.p(input "show":U, input 55005, input p-c-nome-arquivo). // arquivo de log est  ativo
    
END PROCEDURE.

//****************************************************************************************************

PROCEDURE gravarDadosSessao :

    DEFINE VARIABLE contador    AS INTEGER     NO-UNDO.
    DEFINE VARIABLE cproversion AS CHARACTER   NO-UNDO.
    
    DEFINE variable cOracleSid  AS CHARACTER   NO-UNDO.
    DEFINE variable cOracleHome AS CHARACTER   NO-UNDO.
    DEFINE variable cNLSLang    AS CHARACTER   NO-UNDO.
    DEFINE variable cCharSet    AS CHARACTER   NO-UNDO.
    
    DEFINE VARIABLE DatasulVersion AS CHARACTER   NO-UNDO.
    
    IF  LOG-MANAGER:LOGFILE-NAME = ? THEN
        RETURN.
    
    RUN getDatasulVersion( INPUT-OUTPUT DatasulVersion ).
    
    RUN GetProgressVersion ( OUTPUT cproversion ).
    
    RUN GetOracleEnv ( OUTPUT cOracleSid ,
                       OUTPUT cOracleHome,
                       OUTPUT cNLSLang   ,
                       OUTPUT cCharSet   ).
    
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE ( SUBSTITUTE("&1", FILL("=", 100)  ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE ( SUBSTITUTE("Program=&1", program-name(1) ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE ( SUBSTITUTE("&1=&2", "DATETIME", NOW ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    LOG-MANAGER:WRITE-MESSAGE ( SUBSTITUTE("&1=&2", "Datasul", DatasulVersion ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("&1&2",  "PROGRESS SECTION BEGIN"  ), "FRMWRK" ).
    
    /* PROCESS-ARCHITECTURE */
    &IF PROVERSION >= "11" &THEN    
        LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("    &1=&2bits",  "Architeture", PROCESS-ARCHITECTURE ), "FRMWRK" ).    
    &ENDIF
    
    &IF PROVERSION >= "11" &THEN
        LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("    &1=&2", "Proversion", PROVERSION(1) ), "FRMWRK" ).
    &ELSE
        LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("    &1=&2", "Proversion", PROVERSION ), "FRMWRK" ).
    &ENDIF
    
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("    &1=&2",  "Progress", PROGRESS ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("    &1=&2",  "Version", cproversion ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("    &1=&2",  "Propath", PROPATH ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("    &1=&2",  "Startup Parameters", SESSION:STARTUP-PARAMETERS ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("&1&2",  "PROGRESS SECTION END."  ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("&1&2",  "DATABASE SECTION BEGIN"  ), "FRMWRK" ).
    
    DO contador = 1 TO NUM-DBS:
        LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("    db=&1,&2,&3,&4,&5,&6,&7,&8",  LDBNAME(contador), DBVERSION(contador), DBTYPE(contador), DBRESTRICTIONS(contador), PDBNAME(contador), SDBNAME(contador), DBPARAM(contador) ), "FRMWRK" ).
    END.
    
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("    &1",  "ALIASES" ), "FRMWRK" ).
    DO contador = 1 TO NUM-ALIASES:  
        LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("        db=&1,&2",  LDBNAME( ALIAS(contador)), ALIAS(contador) ) 
                                    , "FRMWRK" ).
    END.
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("&1&2",  "DATABASE SECTION END."  ), "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE( SUBSTITUTE("&1" ,  FILL("=", 100)  ), 
                               "FRMWRK" ).
    
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    LOG-MANAGER:WRITE-MESSAGE ( " ", "FRMWRK" ).
    
END PROCEDURE.

//****************************************************************************************************

PROCEDURE desativarLog :

    IF  LOG-MANAGER:CLOSE-LOG() THEN DO:
        //run utp/ut-msgs.p( INPUT "show":U, INPUT 55004, INPUT "").
    END.
    
    IF  c-LOGFILE-NAME <> ""
    AND c-LOGFILE-NAME <> ? THEN DO:
        ASSIGN LOG-MANAGER:LOGFILE-NAME    = c-LOGFILE-NAME
               LOG-MANAGER:LOG-ENTRY-TYPES = ?.
        ASSIGN LOG-MANAGER:LOGGING-LEVEL   = i-LOGGING-LEVEL
               LOG-MANAGER:LOG-ENTRY-TYPES = c-LOG-ENTRY-TYPES.
    END.    
    
END PROCEDURE.

//****************************************************************************************************

PROCEDURE GetDatasulVersion :

    DEFINE INPUT-OUTPUT  PARAMETER frmwk_frameVersion AS CHARACTER   NO-UNDO.

    &IF "{&product_version}" >= "12.1.13" &THEN
        /* TODO: Revisar busca da propriedade framework.version */
        frmwk_frameVersion = "".
    &ELSE
    DO ON ERROR UNDO, LEAVE:
        IF  NUM-ENTRIES(SESSION:PARAMETER) >= 12 THEN DO:
            RUN men/men906zb.p(ENTRY(10,SESSION:PARAMETER),ENTRY(9,SESSION:PARAMETER),ENTRY(11,SESSION:PARAMETER),ENTRY(12,SESSION:PARAMETER),"","getProperty","","","framework.version","",FALSE) NO-ERROR.
            
            IF  ERROR-STATUS:ERROR THEN DO:
                frmwk_frameVersion = ERROR-STATUS:GET-MESSAGE(1).
            END.
            ELSE
                frmwk_frameVersion = RETURN-VALUE.
        END.
    END. 
    &ENDIF 
    
END PROCEDURE.

//****************************************************************************************************

PROCEDURE GetOracleEnv :

    DEFINE OUTPUT PARAMETER pOracleSid  AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER pOracleHome AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER pNLSLang    AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER pCharSet    AS CHARACTER   NO-UNDO.
    
    pOracleSid  = OS-GETENV("ORACLE_SID":U) .
    pOracleHome = OS-GETENV("ORACLE_HOME":U) .
    pNLSLang    = OS-GETENV("NLS_LANG":U) .
    pCharSet    = OS-GETENV("NLS_CHARACTER_SET":U).

END PROCEDURE.

//****************************************************************************************************

PROCEDURE GetProgressVersion :

    DEFINE OUTPUT PARAMETER cinp AS CHARACTER   NO-UNDO.
  
    DEFINE VARIABLE dlcValue   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE patchLevel AS CHARACTER NO-UNDO.

    IF OPSYS = "Win32":U THEN /* Get DLC from Registry */
    GET-KEY-VALUE SECTION "Startup":U KEY "DLC":U VALUE dlcValue.
    
    IF (dlcValue = "" OR dlcValue = ?) THEN DO:
        ASSIGN dlcValue = OS-GETENV("DLC":U). /* Get DLC from environment */
        IF (dlcValue = "" OR dlcValue = ?) THEN DO: /* Still nothing? */
            ASSIGN patchLevel = "".
            RETURN.
        END.
    END.
    
    FILE-INFO:FILE-NAME = dlcValue + "/version":U.
    IF FILE-INFO:FULL-PATHNAME NE ? THEN DO: /* Read the version file */
        INPUT FROM VALUE(FILE-INFO:FULL-PATHNAME).
        IMPORT UNFORMATTED cinp. /* Get the first line */
        INPUT CLOSE.
    END.

END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-mostrar-log-anterior:

    def input param p-i-ponto as inte no-undo.

    message "log anterior [ " + string(p-i-ponto) + "]" skip(1)
            "c-LOGFILE-NAME = " c-LOGFILE-NAME skip
            "c-LOG-ENTRY-TYPES = " c-LOG-ENTRY-TYPES skip
            "i-LOGGING-LEVEL  = " i-LOGGING-LEVEL  skip
        view-as alert-box.

END PROCEDURE.
