/***********************************************************************
**  Programa..: 
**  Autor.....: 
**  Data......: 
**  Descricao.: 
**  Vers o....: 
**                  Desenvolvimento Programa
************************************************************************/
def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

/* {utp/ut-glob.i} */

DEFINE VARIABLE c-objeto   AS CHARACTER     NO-UNDO.

DEF NEW GLOBAL SHARED VAR wh-tab-ind-fin-pd1001  AS WIDGET-HANDLE NO-UNDO.

DEF NEW GLOBAL SHARED VAR tx-crm-pd1001   AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-crm-pd1001   AS WIDGET-HANDLE NO-UNDO.

def new global shared var gr-ped-venda as rowid no-undo.

assign c-objeto = entry(num-entries(p-wgh-object:file-name,"~/"), 
                        p-wgh-object:file-name,"~/").

/*
    MESSAGE "p-ind-event : " p-ind-event   SKIP
            "p-ind-object: " p-ind-object  SKIP
            "p-wgh-object: " p-wgh-object  SKIP
            "objeto      : " c-objeto      SKIP
            "p-cod-table : " p-cod-table   SKIP
            "p-wgh-frame : " p-wgh-frame   SKIP
            "p-row-table : " STRING(p-row-table)
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
*/

IF p-ind-event    = "DISPLAY"      AND
   p-ind-object   = "viewer"       AND 
   c-objeto       = "v31di159.w"   AND
   p-cod-table    = "ped-venda"    AND
   p-row-table   <> ?              THEN DO:

   ASSIGN gr-ped-venda = p-row-table.
END.
    

IF p-ind-object = "viewer" AND c-objeto = "v34di159.w " THEN DO:

    CASE p-ind-event:
        WHEN "BEFORE-INITIALIZE" THEN DO:            
            RUN tela-upc (INPUT p-wgh-frame,
                          INPUT p-ind-Event,
                          INPUT "fill-in",      /*** Type ***/
                          INPUT "tab-ind-fin",   /*** Name ***/
                          INPUT NO,            /*** Apresenta Mensagem dos Objetos ***/
                          INPUT 1,             /*** Quando existir mais de um objeto com o mesmo nome ***/
                          OUTPUT wh-tab-ind-fin-pd1001).

            IF VALID-HANDLE(wh-tab-ind-fin-pd1001) THEN DO:
                CREATE TEXT tx-crm-pd1001
                ASSIGN
                    FRAME        = p-wgh-frame
                    FORMAT       = "x(12)"
                    WIDTH        = 15
                    SCREEN-VALUE = "CRM:"
                    ROW          = wh-tab-ind-fin-pd1001:ROW + 0.18
                    COL          = wh-tab-ind-fin-pd1001:COL + 36
                    VISIBLE      = YES
                    .
        
                CREATE FILL-IN wh-crm-pd1001
                ASSIGN
                    FRAME             = p-wgh-frame
                    DATA-TYPE         = "character"
                    FORMAT            = "x(20)" 
                    WIDTH             = 20
                    HEIGHT            = 0.88
                    ROW               = wh-tab-ind-fin-pd1001:ROW
                    COL               = wh-tab-ind-fin-pd1001:COL + 40
                    VISIBLE           = YES
                    SENSITIVE         = NO
                    .
            END.
        END.
        WHEN "DISPLAY" THEN DO:
            IF VALID-HANDLE(wh-crm-pd1001) THEN DO:

                ASSIGN wh-crm-pd1001:SCREEN-VALUE  = "".

                FOR FIRST ped-venda NO-LOCK WHERE ROWID(ped-venda) = p-row-table,
                    FIRST ext-ped-venda NO-LOCK
                    WHERE ext-ped-venda.nome-abrev = ped-venda.nome-abrev
                      AND ext-ped-venda.nr-pedcli  = ped-venda.nr-pedcli:

                    ASSIGN wh-crm-pd1001:SCREEN-VALUE  = ext-ped-venda.crm.
                END.
            END.
        END.
    END CASE.
END.

PROCEDURE tela-upc:
    DEFINE INPUT  PARAMETER  pWghFrame    AS WIDGET-HANDLE NO-UNDO.
    DEFINE INPUT  PARAMETER  pIndEvent    AS CHARACTER     NO-UNDO.
    DEFINE INPUT  PARAMETER  pObjType     AS CHARACTER     NO-UNDO.
    DEFINE INPUT  PARAMETER  pObjName     AS CHARACTER     NO-UNDO.
    DEFINE INPUT  PARAMETER  pApresMsg    AS LOGICAL       NO-UNDO.
    DEFINE INPUT  PARAMETER  pAux         AS INTEGER       NO-UNDO.
    DEFINE OUTPUT PARAMETER  phObj        AS HANDLE        NO-UNDO.

    DEFINE VARIABLE wgh-obj AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE i-aux   AS INTEGER       NO-UNDO.

    ASSIGN wgh-obj = pWghFrame:FIRST-CHILD
           i-aux   = 0.

    DO WHILE VALID-HANDLE(wgh-obj):                                

        IF pApresMsg = YES THEN                                    
            MESSAGE "Nome do Objeto" wgh-obj:NAME SKIP             
                    "Type do Objeto" wgh-obj:TYPE SKIP             
                    "P-Ind-Event"    pIndEvent VIEW-AS ALERT-BOX.  

        IF wgh-obj:TYPE = pObjType AND
           wgh-obj:NAME = pObjName THEN DO:
            ASSIGN phObj = wgh-obj:HANDLE
                   i-aux = i-aux + 1.

            IF i-aux = pAux THEN
                LEAVE.
        END.
        IF wgh-obj:TYPE = "field-group" THEN
            ASSIGN wgh-obj = wgh-obj:FIRST-CHILD.
        ELSE
            ASSIGN wgh-obj = wgh-obj:NEXT-SIBLING.
    END.
END PROCEDURE.
