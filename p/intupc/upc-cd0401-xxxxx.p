/*************************************************************************
**    Programa.:  UPC-CD0401.P
**    Objetivo.:  UPC para cadastro de informa‡äes adicionais do Fornecedor
**                Integra‡Æo Datasul -> Sysfarma
*************************************************************************/

/*********************** Defini‡Æo de Parƒmetros *************************/
define input parameter p-ind-event               as character      no-undo.
define input parameter p-ind-object              as character      no-undo.
define input parameter p-wgh-object              as handle         no-undo.
define input parameter p-wgh-frame               as widget-handle  no-undo.
define input parameter p-cod-table               as character      no-undo.
define input parameter p-row-table               as rowid          no-undo.

DEF NEW GLOBAL SHARED VAR wh-int-ds-cd0401            AS WIDGET-HANDLE                            NO-UNDO.
DEF NEW GLOBAL SHARED VAR l-protocolodevolucao-cd0401 LIKE int-ds-ext-emitente.protocolodevolucao NO-UNDO.  
DEF NEW GLOBAL SHARED VAR l-emitedanfe-cd0401         LIKE int-ds-ext-emitente.emitedanfe         NO-UNDO.
DEF NEW GLOBAL SHARED VAR l-biometriamotorista-cd0401 LIKE int-ds-ext-emitente.biometriamotorista NO-UNDO.   
DEF NEW GLOBAL SHARED VAR l-microempresa-cd0401       LIKE int-ds-ext-emitente.microempresa       NO-UNDO.
DEF NEW GLOBAL SHARED VAR l-industria-cd0401          LIKE int-ds-ext-emitente.industria          NO-UNDO.  
DEF NEW GLOBAL SHARED VAR l-emitenotadevolucao-cd0401 LIKE int-ds-ext-emitente.emitenotadevolucao NO-UNDO.
DEF NEW GLOBAL SHARED VAR l-excecaoindustria-cd0401   LIKE int-ds-ext-emitente.excecaoindustria   NO-UNDO. 
DEF NEW GLOBAL SHARED VAR i-tipo-trib-cd0401          LIKE int-ds-ext-emitente.tipo-trib          NO-UNDO. 
DEF NEW GLOBAL SHARED VAR da-databloqueio-cd0401      LIKE int-ds-ext-emitente.databloqueio       NO-UNDO.    
DEF NEW GLOBAL SHARED VAR c-eancnpj-cd0401            LIKE int-ds-ext-emitente.eancnpj            NO-UNDO.   
DEF NEW GLOBAL SHARED VAR i-prazo-entrega-cd0401      LIKE int-ds-ext-emitente.prazo-entrega      NO-UNDO.   
DEF NEW GLOBAL SHARED VAR l-inf-compl                 AS LOGICAL                                  NO-UNDO. 
DEF NEW GLOBAL SHARED VAR wh-emite-nfe-cd0401         AS WIDGET-HANDLE.
DEF NEW GLOBAL SHARED VAR wh-gera-nota-cd0401         AS WIDGET-HANDLE.

DEF VAR wgh-grupo  AS WIDGET-HANDLE NO-UNDO.
DEF VAR l-compl-ok AS LOGICAL       NO-UNDO.
DEF VAR c-telex    AS CHAR          NO-UNDO.


/* MESSAGE p-ind-event              "p-ind-event  " skip   */
/*          p-ind-object             "p-ind-object " skip  */
/*          p-wgh-object:FILE-NAME   "p-wgh-object " skip  */
/*          p-wgh-frame:NAME         "p-wgh-frame  " skip  */
/*          p-cod-table              "p-cod-table  " skip  */
/*         string(p-row-table)      "p-row-table  " skip   */
/*         p-wgh-object:FILE-NAME    "objeto"               */
/*  VIEW-AS ALERT-BOX INFO BUTTONS OK.                     */


/**** Criar BotÆo Informa‡äes complemetares *****/
                  
if  p-ind-event   = "INITIALIZE"   and 
    p-ind-object  = "CONTAINER"    then do:
    
    create button wh-int-ds-cd0401
    assign frame     = p-wgh-frame 
           row       = 1.35 
           column    = 69
           height    = 1.24
           width     = 4.0
           tooltip   = "Complemento Sysfarma"  
           help      = "Complemento Sysfarma"
           label     = "Complemento Sysfarma"
           sensitive = true
           visible   = true.
    
    wh-int-ds-cd0401:load-image("image/im-pedido.bmp").
    wh-int-ds-cd0401:MOVE-TO-TOP().
    ON 'choose' of wh-int-ds-cd0401 PERSISTENT
        run intprg/nicd0401.w.
END.

IF  p-ind-event            = "VALIDATE" 
AND p-ind-object           = "VIEWER"
AND p-wgh-object:FILE-NAME = "cdp/cd0401-v02.w"
AND p-wgh-frame:NAME       = "f-main" 
AND p-cod-table            = "emitente" THEN DO:
    
    ASSIGN l-compl-ok = NO.

    FIND FIRST emitente WHERE
               ROWID(emitente) = p-row-table NO-LOCK NO-ERROR.
    IF AVAIL emitente THEN DO:
       FIND FIRST int-ds-ext-emitente WHERE
                  int-ds-ext-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.
       IF AVAIL int-ds-ext-emitente THEN DO:
          IF l-inf-compl = YES THEN DO:
             ASSIGN int-ds-ext-emitente.protocolodevolucao = l-protocolodevolucao-cd0401
                    int-ds-ext-emitente.emitedanfe         = l-emitedanfe-cd0401        
                    int-ds-ext-emitente.biometriamotorista = l-biometriamotorista-cd0401
                    int-ds-ext-emitente.microempresa       = l-microempresa-cd0401      
                    int-ds-ext-emitente.industria          = l-industria-cd0401         
                    int-ds-ext-emitente.emitenotadevolucao = l-emitenotadevolucao-cd0401
                    int-ds-ext-emitente.excecaoindustria   = l-excecaoindustria-cd0401  
                    int-ds-ext-emitente.tipo-trib          = i-tipo-trib-cd0401         
                    int-ds-ext-emitente.databloqueio       = da-databloqueio-cd0401     
                    int-ds-ext-emitente.eancnpj            = c-eancnpj-cd0401           
                    int-ds-ext-emitente.prazo-entrega      = i-prazo-entrega-cd0401.              
          END.
          ASSIGN l-compl-ok = YES.
       END.
    END.

    IF  l-compl-ok  = NO 
    AND l-inf-compl = NO THEN DO:
        RUN utp/ut-msgs.p (INPUT "show",
                           INPUT 17006,
                           INPUT "Informa‡äes Complementares Sysfarma nÆo preenchidas.").
        RETURN "NOK".
    END.

    IF  l-compl-ok  = NO 
    AND l-inf-compl = YES THEN DO:
        FIND FIRST emitente WHERE
                   ROWID(emitente) = p-row-table NO-ERROR.
        IF AVAIL emitente THEN DO:
           CREATE int-ds-ext-emitente.
           ASSIGN int-ds-ext-emitente.cod-emitente       = emitente.cod-emitente
                  int-ds-ext-emitente.protocolodevolucao = l-protocolodevolucao-cd0401
                  int-ds-ext-emitente.emitedanfe         = l-emitedanfe-cd0401        
                  int-ds-ext-emitente.biometriamotorista = l-biometriamotorista-cd0401
                  int-ds-ext-emitente.microempresa       = l-microempresa-cd0401      
                  int-ds-ext-emitente.industria          = l-industria-cd0401         
                  int-ds-ext-emitente.emitenotadevolucao = l-emitenotadevolucao-cd0401
                  int-ds-ext-emitente.excecaoindustria   = l-excecaoindustria-cd0401  
                  int-ds-ext-emitente.tipo-trib          = i-tipo-trib-cd0401         
                  int-ds-ext-emitente.databloqueio       = da-databloqueio-cd0401     
                  int-ds-ext-emitente.eancnpj            = c-eancnpj-cd0401           
                  int-ds-ext-emitente.prazo-entrega      = i-prazo-entrega-cd0401     
                  c-telex                                = emitente.telex
                  emitente.telex                         = "."
                  emitente.telex                         = c-telex.       
        END.
    END.

    ASSIGN l-protocolodevolucao-cd0401 = NO
           l-emitedanfe-cd0401         = NO
           l-biometriamotorista-cd0401 = NO
           l-microempresa-cd0401       = NO
           l-industria-cd0401          = NO
           l-emitenotadevolucao-cd0401 = NO
           l-excecaoindustria-cd0401   = NO
           i-tipo-trib-cd0401          = 1
           da-databloqueio-cd0401      = ?
           c-eancnpj-cd0401            = ""
           i-prazo-entrega-cd0401      = 0
           l-inf-compl                 = NO
           l-compl-ok                  = NO.
END.

IF  (p-ind-event            = "CANCEL"
AND p-ind-object            = "VIEWER"
AND p-wgh-object:FILE-NAME  = "cdp/cd0401-v02.w"
AND p-wgh-frame:NAME        = "f-main" 
AND p-cod-table             = "emitente") 
    OR 
    (p-ind-event             = "DESTROY"
AND p-ind-object            = "CONTAINER"
AND p-wgh-object:FILE-NAME  = "cdp/cd0401.w"
AND p-wgh-frame:NAME        = "f-cad") THEN DO:
    ASSIGN l-protocolodevolucao-cd0401 = NO
           l-emitedanfe-cd0401         = NO
           l-biometriamotorista-cd0401 = NO
           l-microempresa-cd0401       = NO
           l-industria-cd0401          = NO
           l-emitenotadevolucao-cd0401 = NO
           l-excecaoindustria-cd0401   = NO
           i-tipo-trib-cd0401          = 1
           da-databloqueio-cd0401      = ?
           c-eancnpj-cd0401            = ""
           i-prazo-entrega-cd0401      = 0
           l-inf-compl                 = NO.
END.
    
/**** Criar campo Gera nota xml via pedido de compra ****/


/* Guarda handle C«digo Emitente */

IF  p-ind-event  = "INITIALIZE" AND 
    p-ind-object = "VIEWER"     AND 
    p-wgh-object:FILE-NAME  = "cdp/cd0401-v02.w" 
THEN DO:

    /* DO:
        ASSIGN wgh-grupo = p-wgh-frame:FIRST-CHILD.
        ASSIGN wgh-grupo = wgh-grupo:FIRST-CHILD.

        DO  WHILE wgh-grupo <> ? :
            IF  wgh-grupo:TYPE <> "field-group" THEN DO:

                IF  wgh-grupo:NAME = "cod-emitente" THEN 
                    ASSIGN wgh-cod-emitente-cd0401 = wgh-grupo.
                
                ASSIGN wgh-grupo = wgh-grupo:NEXT-SIBLING.
            END.
            ELSE
                ASSIGN wgh-grupo = wgh-grupo:FIRST-CHILD.
        END.
    END. */

END.

IF  p-ind-event  = "INITIALIZE" AND 
    p-ind-object = "VIEWER"     AND 
    p-wgh-object:FILE-NAME  = "cdp/cd0401-v05.w" 
THEN DO:

    DO:
        ASSIGN wgh-grupo = p-wgh-frame:FIRST-CHILD.
        ASSIGN wgh-grupo = wgh-grupo:FIRST-CHILD.

        DO  WHILE wgh-grupo <> ? :
            IF  wgh-grupo:TYPE <> "field-group" THEN DO:

                IF  wgh-grupo:NAME = "l-emite-nfe" THEN 
                    ASSIGN wh-emite-nfe-cd0401 = wgh-grupo.
                
                
                ASSIGN wgh-grupo = wgh-grupo:NEXT-SIBLING.
            END.
            ELSE
                ASSIGN wgh-grupo = wgh-grupo:FIRST-CHILD.
        END.
    END. 

    if valid-handle(wh-emite-nfe-cd0401)  
    then do:

        ASSIGN wh-emite-nfe-cd0401:ROW = wh-emite-nfe-cd0401:ROW - 0.3.

        create toggle-box wh-gera-nota-cd0401
        ASSIGN FRAME             = p-wgh-frame
               WIDTH             = wh-emite-nfe-cd0401:WIDTH
               HEIGHT            = wh-emite-nfe-cd0401:HEIGHT
               ROW               = wh-emite-nfe-cd0401:ROW + 0.7
               COL               = wh-emite-nfe-cd0401:COL
               NAME              = 'wh-emite-nfe-cd0401':U
               VISIBLE           = yes
               SENSITIVE         = no
               CHECKED           = no
               LABEL             = "Gera Nota Entrada via Pedido Compra":U.
    end.

END.

IF  p-ind-event  = "ENABLE"       AND 
    p-ind-object = "VIEWER"       AND
    p-wgh-object:FILE-NAME  = "cdp/cd0401-v05.w" THEN DO:

    if valid-handle(wh-gera-nota-cd0401) then
        ASSIGN wh-gera-nota-cd0401:sensitive = yes.

END.

IF  p-ind-event  = "DISABLE"      AND 
    p-ind-object = "VIEWER"       AND
    p-wgh-object:FILE-NAME  = "cdp/cd0401-v05.w" THEN DO:

    if valid-handle(wh-gera-nota-cd0401) then
        ASSIGN wh-gera-nota-cd0401:sensitive = no.

END.

IF  p-ind-event  = "ADD"          AND 
    p-ind-object = "VIEWER"       AND
    p-wgh-object:FILE-NAME  = "cdp/cd0401-v05.w" THEN DO:

    if valid-handle(wh-gera-nota-cd0401) then
        ASSIGN wh-gera-nota-cd0401:checked   = no.

END.

IF  p-ind-event  = "DISPLAY" AND 
    p-ind-object = "VIEWER"  AND
    p-wgh-object:FILE-NAME  = "cdp/cd0401-v05.w" 
THEN DO:
           
    IF valid-handle(wh-gera-nota-cd0401) 
    THEN DO:

        FIND FIRST emitente WHERE
                ROWID(emitente) = p-row-table NO-LOCK NO-ERROR.
        IF AVAIL emitente THEN DO:

            FIND FIRST int-ds-ext-emitente NO-LOCK
                 WHERE int-ds-ext-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.
            IF  AVAIL int-ds-ext-emitente THEN
                ASSIGN wh-gera-nota-cd0401:screen-value = string(int-ds-ext-emitente.gera-nota).
            ELSE
                ASSIGN wh-gera-nota-cd0401:screen-value = 'no':U.
        END.
    END.

END.

IF ((p-ind-event  = "ASSIGN"  AND
     p-ind-object = "VIEWER"  AND
     p-wgh-object:FILE-NAME  = "cdp/cd0401-v05.w" )) 
THEN DO:

     FIND FIRST emitente WHERE
           ROWID(emitente) = p-row-table NO-LOCK NO-ERROR.
     IF AVAIL emitente THEN DO:
     
        FOR FIRST int-ds-ext-emitente EXCLUSIVE-LOCK WHERE 
                  int-ds-ext-emitente.cod-emitente = emitente.cod-emitente :
        END.

        IF NOT AVAIL int-ds-ext-emitente 
        THEN DO:
            CREATE int-ds-ext-emitente.
            ASSIGN int-ds-ext-emitente.cod-emitente = emitente.cod-emitente.
        END.

        ASSIGN int-ds-ext-emitente.gera-nota = logical(wh-gera-nota-cd0401:screen-value).
        
     END.
END.




    
