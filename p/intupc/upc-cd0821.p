/******************************************************************************
**
**     Programa: upc-CD0821.p
**
**     Objetivo: 
**
**     Autor...: Guilherme Nichele KML
**
**     Vers∆o..: 1.00.00.001 - 05/10/2025
**
******************************************************************************/
DEFINE INPUT PARAMETER p-ind-event   AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-ind-object  AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-wgh-object  AS HANDLE        NO-UNDO.
DEFINE INPUT PARAMETER p-wgh-frame   AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-cod-table   AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-row-table   AS ROWID         NO-UNDO.


def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo NO-UNDO.
define new global shared var h-inf-moeda   as handle no-undo.
define new global shared var h-estab-principal   as handle no-undo.
define new global shared var h-estab-principal_2   as handle no-undo.
define new global shared var h-text-estab-principal   as handle no-undo.

define new global shared VAR c-usuario-cd0821   as CHAR no-undo.



/* Teste simples de chamada */
.MESSAGE "EVENTO: " p-ind-event SKIP
        "OBJETO: " p-ind-object SKIP
        "FRAME: "  STRING(p-wgh-frame) SKIP
        "TABELA: " p-cod-table SKIP
        "ROWID: "  STRING(p-row-table)
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
    


IF p-ind-event = "INITIALIZE"  THEN DO:

    RUN utils/findWidget.p (INPUT  'inf-moeda',                                                               
                            INPUT  'toggle-box',       
                            INPUT  p-wgh-frame,
                            output h-inf-moeda).
                            

end.


IF p-ind-event = "BEFORE-DISPLAY" THEN
DO:

    IF VALID-HANDLE(h-inf-moeda) THEN DO:
    
        
    
        .MESSAGE "achou"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
     /*   create text h-text-estab-principal
        assign name = "h-text-estab-principal"
             FRAME     = h-inf-moeda:FRAME
             ROW       = h-inf-moeda:ROW
             COL       = h-inf-moeda:COL + 21  
             VISIBLE   = YES
             FORMAT         = "X(20)"
             screen-value = "Estab Principal:".
             //+ 22
        
        CREATE FILL-IN h-estab-principal
         ASSIGN NAME      = "h-estab-principal"
                FRAME     = h-text-estab-principal:FRAME
                ROW       = h-text-estab-principal:ROW
                COL       = h-text-estab-principal:COL + 12
                width     = 9.5
                height    = .88
                VISIBLE   = YES
                SENSITIVE = no
                HEIGHT-CHARS   = 0.70
                WIDTH-CHARS    = 8
                //LABEL     = "Estab Principal" */
                . 
                
         CREATE BUTTON h-estab-principal_2
         ASSIGN NAME         = "h-estab-principal_2"
                FRAME        = h-inf-moeda:FRAME
                ROW          = h-inf-moeda:ROW 
                COL          = h-inf-moeda:COL + 34
                width        = 12
                VISIBLE      = YES
                SENSITIVE    = YES
                LABEL     = "Estab Principal"
                TRIGGERS:
                ON CHOOSE PERSISTENT RUN intupc/upc-cd0821-button.w. 
            END TRIGGERS
                .
        
        
    
    END.
    
END.
/* IF  p-ind-event = "ENABLE"                          */
/* THEN DO:                                            */
/*                                                     */
/*                                                     */
/*    IF valid-handle(h-estab-principal) THEN          */
/*       ASSIGN    h-estab-principal_2:SENSITIVE = yes */
/*                 h-estab-principal:SENSITIVE = yes   */
/*            .                                        */
/*                                                     */
/* end.                                                */
/* IF  p-ind-event = "DISABLE"                         */
/*                                                     */
/* THEN DO:                                            */
/*                                                     */
/*     IF valid-handle(h-estab-principal) THEN         */
/*         ASSIGN h-estab-principal:SENSITIVE = no     */
/*                .                                    */
/*                                                     */
/* end.                                                */
IF  p-ind-event = "DISPLAY" THEN DO:

    find first user-coml
            where   rowid(user-coml) = p-row-table no-error.
    IF AVAIL user-coml THEN
    DO:
        ASSIGN c-usuario-cd0821  = user-coml.usuario.
        
    END.
        
    


    
        

/*                                                                                            */
/*         IF AVAIL user-coml THEN                                                            */
/*         DO:                                                                                */
/*                                                                                            */
/*            .MESSAGE "achou user-coml " user-coml.usuario                                   */
/*                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                                   */
/*                                                                                            */
/*            FIND FIRST esp-estab-principal NO-LOCK                                          */
/*                 WHERE esp-estab-principal.cod-user = user-coml.usuario NO-ERROR.           */
/*                                                                                            */
/*            IF AVAIL esp-estab-principal THEN                                               */
/*            DO:                                                                             */
/*                                                                                            */
/*               ASSIGN h-estab-principal:SCREEN-VALUE = esp-estab-principal.estab-principal. */
/*                                                                                            */
/*            END.                                                                            */
/*            ELSE DO:                                                                        */
/*                                                                                            */
/*               ASSIGN h-estab-principal:SCREEN-VALUE =  "".                                 */
/*                                                                                            */
/*            END.                                                                            */
/*                                                                                            */
/*         END.                                                                               */
/*                                                                                            */
/*     END.                                                                                   */

END.

/* IF  p-ind-event = "ASSIGN"                                                                  */
/* // and p-ind-object = "VIEWER"                                                              */
/*  //AND c-objeto = "V01AD107.W"                                                              */
/*  THEN DO:                                                                                   */
/*                                                                                             */
/*      IF valid-handle(h-estab-principal) then do:                                            */
/*                                                                                             */
/*         find first user-coml                                                                */
/*             where   rowid(user-coml) = p-row-table no-error.                                */
/*                                                                                             */
/*                                                                                             */
/*          if avail user-coml then do:                                                        */
/*                                                                                             */
/*              FIND FIRST esp-estab-principal                                                 */
/*                 WHERE esp-estab-principal.cod-user = user-coml.usuario NO-ERROR.            */
/*                                                                                             */
/*                if not avail esp-estab-principal then do:                                    */
/*                                                                                             */
/*                   create esp-estab-principal.                                               */
/*                   assign esp-estab-principal.cod-user = user-coml.usuario.                  */
/*                                                                                             */
/*                end.                                                                         */
/*                                                                                             */
/*                                                                                             */
/*                ASSIGN esp-estab-principal.estab-principal = h-estab-principal:SCREEN-VALUE. */
/*                                                                                             */
/*                                                                                             */
/*          end.                                                                               */
/*                                                                                             */
/*      end.                                                                                   */
/*                                                                                             */
/*                                                                                             */
/* end.                                                                                        */


RETURN "OK".

    

   
