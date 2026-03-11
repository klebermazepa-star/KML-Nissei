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


def var r-eq0506b      as rowid     no-undo.

/* Teste simples de chamada */
.MESSAGE "EVENTO: " p-ind-event SKIP
        "OBJETO: " p-ind-object SKIP
        "FRAME: "  STRING(p-wgh-frame) SKIP
        "TABELA: " p-cod-table SKIP
        "ROWID: "  STRING(p-row-table)
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
        
.MESSAGE p-ind-event
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
DEF VAR h-eq0506b    AS HANDLE  NO-UNDO .
    

IF v_cdn_empres_usuar = "10" THEN DO:

    
    IF p-ind-event = "CREATE-TT-PED-ENT" THEN
    DO:
        ASSIGN r-eq0506b =  p-row-table.
        
        IF r-eq0506b <> ? THEN
        DO:
        
            FIND FIRST ems2mult.emitente NO-LOCK
                WHERE ROWID(emitente) = r-eq0506b NO-ERROR.
        
            FIND FIRST cst_cliente_bloqueio NO-LOCK
                WHERE cst_cliente_bloqueio.cod-emitente = string(emitente.cod-emitente) no-error.
                
            IF AVAIL cst_cliente_bloqueio AND
               cst_cliente_bloqueio.bloqueio = YES AND 
               cst_cliente_bloqueio.dt_fim > TODAY - 1
               THEN DO:
               
                MESSAGE "Cliente " + emitente.nome-abrev + "tem bloqueio de vendas (ESCM0201)"
                    VIEW-AS ALERT-BOX ERROR BUTTONS OK.
                                         
                RETURN "NOK"    .            
                
            END.  
            
            IF AVAIL cst_cliente_bloqueio AND
               cst_cliente_bloqueio.bloqueio = YES AND 
               cst_cliente_bloqueio.dt_fim = ?
               THEN DO:
               
                MESSAGE "Cliente " + emitente.nome-abrev + "Esta sem data de fim (ESCM0201)"
                    VIEW-AS ALERT-BOX ERROR BUTTONS OK.
                                         
                RETURN "NOK"    .            
                
            END.
        END.
    END.
END.
   
