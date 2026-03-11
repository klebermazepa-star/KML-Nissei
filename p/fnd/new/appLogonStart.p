/*
*/

PROCEDURE SetCurrentDirectoryA EXTERNAL "KERNEL32.DLL":
       DEFINE INPUT  PARAMETER chrCurDir AS CHARACTER.
       DEFINE RETURN PARAMETER intResult AS LONG.
END PROCEDURE.

DEF VAR i-retorno   AS INT NO-UNDO .

RUN SetCurrentDirectoryA 
    (INPUT SESSION:TEMP-DIR ,
     OUTPUT i-retorno) 
    .

/* BTB */
DEFINE NEW GLOBAL SHARED VARIABLE hLicManager           AS HANDLE    NO-UNDO.

DEFINE VARIABLE hMen702dc   AS HANDLE NO-UNDO .
DEFINE VARIABLE running     AS LOGICAL NO-UNDO INITIAL FALSE .
DEFINE VARIABLE cRet        AS CHARACTER NO-UNDO .

ON alt-backspace, CTRL-ALT-H ANYWHERE DO:
    DEFINE VARIABLE v-dbname    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-table     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-name      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-data-type AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-format    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-Prog      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-Prog-tmp  AS CHARACTER NO-UNDO.
    
    IF  VALID-HANDLE(FOCUS) THEN 
    DO:
        ASSIGN 
            v-dbname = FOCUS:DBNAME no-error.
        IF  ERROR-STATUS:ERROR THEN 
            ASSIGN v-dbname = "".
        ASSIGN 
            v-table = FOCUS:TABLE no-error.
        IF  ERROR-STATUS:ERROR THEN 
            ASSIGN v-table = "".
        ASSIGN 
            v-name = FOCUS:NAME no-error.
        IF  ERROR-STATUS:ERROR THEN 
            ASSIGN v-name = "".
        ASSIGN 
            v-data-type = FOCUS:DATA-TYPE no-error.
        IF  ERROR-STATUS:ERROR THEN 
            ASSIGN v-data-type = "".
        ASSIGN 
            v-format = FOCUS:FORMAT no-error.
        IF  ERROR-STATUS:ERROR THEN 
            ASSIGN v-format = "".                  
        ASSIGN 
            v-prog = FOCUS:INSTANTIATING-PROCEDURE:NAME no-error.
        IF  ERROR-STATUS:ERROR THEN 
            ASSIGN v-prog = "".
        ASSIGN v-prog-tmp = REPLACE(v-prog, ".py", ".r")
               v-prog-tmp = REPLACE(v-prog-tmp, ".p", ".r")
               v-prog-tmp = REPLACE(v-prog-tmp, ".w", ".r").
        FILE-INFO:FILENAME = v-prog-tmp.
        IF  FILE-INFO:PATHNAME = ? THEN DO:
            FILE-INFO:FILENAME = v-prog.
        END.
        MESSAGE "DBName:"      v-dbname           SKIP
                "Table:"       v-table            SKIP
                "Name:"        v-name             SKIP
                "Type:"        v-data-type        SKIP
                "Format:"      v-format           SKIP
                "Transaction:" TRANSACTION        SKIP 
                "Program:"     v-prog             SKIP 
                "Path:"        FILE-INFO:PATHNAME
                VIEW-AS ALERT-BOX INFORMATION.
    END.
END.

ON CTRL-ALT-S ANYWHERE DO:
    RUN men/men903zd.p .
END.

ON CTRL-ALT-F10 ANYWHERE DO:
    RUN btb/btb100aa.w.
END.

ON CTRL-ALT-L ANYWHERE DO:
    IF VALID-HANDLE(hLicManager) THEN 
    DO:
        RUN setDllLogConsumo IN hLicManager (OUTPUT running).
        RUN licManagerLoc ("consumeLicense#DI", OUTPUT cRet). 
        IF running THEN                    
            MESSAGE "License log is on"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                
        ELSE
            MESSAGE "License log is off"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    END.
END.

ON CTRL-ALT-E ANYWHERE DO:
    READKEY .
    IF SEARCH("btb/btb944za.p") <> ? OR SEARCH("btb/btb944za.r") <> ? THEN
        RUN btb/btb944za.p(INPUT SELF).
    ELSE
        RUN utp/ut-msgs.p (INPUT "show", INPUT 4748, INPUT SUBSTITUTE ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", "btb/btb944za.p")) .
END.

/**/
RUN FND/new/appLogonWin.w .
/*
QUIT .
*/