/******************************************************************************
**
**     Programa: upc-eq0506a.w
**
**     Objetivo: 
**
**     Autor...: Guilherme Nichele KML
**
**     Vers∆o..: 1.00.00.001 - 03/10/2025
**
******************************************************************************/
DEFINE INPUT PARAMETER p-ind-event   AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-ind-object  AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-wgh-object  AS HANDLE        NO-UNDO.
DEFINE INPUT PARAMETER p-wgh-frame   AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-cod-table   AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-row-table   AS ROWID         NO-UNDO.


def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo NO-UNDO.
def new global shared var c-seg-usuario   as char no-undo.

DEF NEW GLOBAL SHARED VAR wgh-cod-estabel      AS WIDGET-HANDLE NO-UNDO.

def var r-eq0506a      as rowid     no-undo.

/* Teste simples de chamada */
.MESSAGE "EVENTO: " p-ind-event SKIP
        "OBJETO: " p-ind-object SKIP
        "FRAME: "  STRING(p-wgh-frame) SKIP
        "TABELA: " p-cod-table SKIP
        "ROWID: "  STRING(p-row-table)
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
        
.MESSAGE p-ind-event
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
DEF VAR h-eq0506a    AS HANDLE  NO-UNDO .
    


    IF p-ind-event  = 'INITIALIZE' AND p-ind-object = 'CONTAINER':U THEN DO:
        RUN utils/FindWidget.p (INPUT 'cod-estabel',
                                INPUT 'fill-in', 
                                INPUT  p-wgh-frame, 
                                OUTPUT wgh-cod-estabel).
                                
       
    
    END.

    
    IF p-ind-event = "Validate-estab" THEN
    DO: 
    
        
        IF v_cdn_empres_usuar = "10" THEN DO:
        
            FIND FIRST esp-estab-principal NO-LOCK
                WHERE  esp-estab-principal.cod-user = c-seg-usuario NO-ERROR.
                
                
            IF AVAIL esp-estab-principal THEN
            DO:
            
            
                IF esp-estab-principal.estab-principal[1] = "" THEN DO:
                
                       
                        
                    IF wgh-cod-estabel:SCREEN-VALUE = "10001" THEN
                    DO:
                         MESSAGE "N∆o tem permiss∆o para o estabelecimento " + wgh-cod-estabel:SCREEN-VALUE
                             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
     
                         RETURN "NOK":U. 
                                                        
                        
                    END.

                END.
                
                IF esp-estab-principal.estab-principal[2] = "" THEN DO:
                
                       
                        
                    IF wgh-cod-estabel:SCREEN-VALUE = "10002" THEN
                    DO:
                         MESSAGE "N∆o tem permiss∆o para o estabelecimento " + wgh-cod-estabel:SCREEN-VALUE
                             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
     
                         RETURN "NOK":U. 
                                                        
                        
                    END.

                END.
                
                IF esp-estab-principal.estab-principal[3] = "" THEN DO:
                
                       
                        
                    IF wgh-cod-estabel:SCREEN-VALUE = "10003" THEN
                    DO:
                         MESSAGE "N∆o tem permiss∆o para o estabelecimento " + wgh-cod-estabel:SCREEN-VALUE
                             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
     
                         RETURN "NOK":U. 
                                                        
                        
                    END.

                END.
                
                IF esp-estab-principal.estab-principal[4] = "" THEN DO:
                
                       
                        
                    IF wgh-cod-estabel:SCREEN-VALUE = "10004" THEN
                    DO:
                         MESSAGE "N∆o tem permiss∆o para o estabelecimento " + wgh-cod-estabel:SCREEN-VALUE
                             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
     
                         RETURN "NOK":U. 
                                                        
                        
                    END.

                END.
                
                IF esp-estab-principal.estab-principal[5] = "" THEN DO:
                
                       
                        
                    IF wgh-cod-estabel:SCREEN-VALUE = "10005" THEN
                    DO:
                         MESSAGE "N∆o tem permiss∆o para o estabelecimento " + wgh-cod-estabel:SCREEN-VALUE
                             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
     
                         RETURN "NOK":U. 
                                                        
                        
                    END.

                END.
                
                IF esp-estab-principal.estab-principal[6] = "" THEN DO:
                
                       
                        
                    IF wgh-cod-estabel:SCREEN-VALUE = "10006" THEN
                    DO:
                         MESSAGE "N∆o tem permiss∆o para o estabelecimento " + wgh-cod-estabel:SCREEN-VALUE
                             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
     
                         RETURN "NOK":U. 
                                                        
                        
                    END.

                END.
                
                IF esp-estab-principal.estab-principal[7] = "" THEN DO:
                
                       
                        
                    IF wgh-cod-estabel:SCREEN-VALUE = "10007" THEN
                    DO:
                         MESSAGE "N∆o tem permiss∆o para o estabelecimento " + wgh-cod-estabel:SCREEN-VALUE
                             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
     
                         RETURN "NOK":U. 
                                                        
                        
                    END.

                END.
                
                IF esp-estab-principal.estab-principal[8] = "" THEN DO:
                
                       
                        
                    IF wgh-cod-estabel:SCREEN-VALUE = "10008" THEN
                    DO:
                         MESSAGE "N∆o tem permiss∆o para o estabelecimento " + wgh-cod-estabel:SCREEN-VALUE
                             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
     
                         RETURN "NOK":U. 
                                                        
                        
                    END.

                END.

            END.
            ELSE DO:
            
                ASSIGN wgh-cod-estabel:SENSITIVE    = YES.
            
            END.
            
    /*         IF AVAIL esp-estab-principal AND esp-estab-principal.estab-principal <> "" THEN */
    /*         DO:                                                                             */
    /*                                                                                         */
    /*                                                                                         */
    /*                                                                                         */
    /*             ASSIGN  wgh-cod-estabel:SCREEN-VALUE =  esp-estab-principal.estab-principal */
    /*                     wgh-cod-estabel:SENSITIVE    = NO.                                  */
    /*                                                                                         */
    /*                                                                                         */
    /*                                                                                         */
    /*         END.                                                                            */
    /*         ELSE DO:                                                                        */
    /*                                                                                         */
    /*             ASSIGN wgh-cod-estabel:SENSITIVE    = YES.                                  */
    /*                                                                                         */
    /*         END.                                                                            */
    END.
END.

/*
---------------------------
Information
---------------------------
EVENTO:  after-leave-cod-estabel 
OBJETO:  VIEWER 
FRAME:  16900 
TABELA:   
ROWID:  ?
---------------------------
OK   
---------------------------



---------------------------
Information
---------------------------
EVENTO:  AFTER-ENABLE 
OBJETO:  VIEWER 
FRAME:  15562 
TABELA:  embarque 
ROWID:  0x0000000000126201
---------------------------
OK   
---------------------------
*/
   
