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
DEF NEW GLOBAL SHARED VAR l-protocolodevolucao-cd0401 LIKE int_ds_ext_emitente.protocolodevolucao NO-UNDO.  
DEF NEW GLOBAL SHARED VAR l-emitedanfe-cd0401         LIKE int_ds_ext_emitente.emitedanfe         NO-UNDO.
DEF NEW GLOBAL SHARED VAR l-biometriamotorista-cd0401 LIKE int_ds_ext_emitente.biometriamotorista NO-UNDO.   
DEF NEW GLOBAL SHARED VAR l-microempresa-cd0401       LIKE int_ds_ext_emitente.microempresa       NO-UNDO.
DEF NEW GLOBAL SHARED VAR l-industria-cd0401          LIKE int_ds_ext_emitente.industria          NO-UNDO.  
DEF NEW GLOBAL SHARED VAR l-emitenotadevolucao-cd0401 LIKE int_ds_ext_emitente.emitenotadevolucao NO-UNDO.
DEF NEW GLOBAL SHARED VAR l-excecaoindustria-cd0401   LIKE int_ds_ext_emitente.excecaoindustria   NO-UNDO. 
DEF NEW GLOBAL SHARED VAR i-tipo-trib-cd0401          LIKE int_ds_ext_emitente.tipo_trib          NO-UNDO. 
DEF NEW GLOBAL SHARED VAR da-databloqueio-cd0401      LIKE int_ds_ext_emitente.databloqueio       NO-UNDO.    
DEF NEW GLOBAL SHARED VAR c-eancnpj-cd0401            LIKE int_ds_ext_emitente.eancnpj            NO-UNDO.   
DEF NEW GLOBAL SHARED VAR i-prazo-entrega-cd0401      LIKE int_ds_ext_emitente.prazo_entrega      NO-UNDO.   
DEF NEW GLOBAL SHARED VAR gr-emitente                 AS ROWID                                    NO-UNDO.

DEF NEW GLOBAL SHARED VAR wh-emite-nfe-cd0401         AS WIDGET-HANDLE.
DEF NEW GLOBAL SHARED VAR wh-gera-nota-cd0401         AS WIDGET-HANDLE.

DEF NEW GLOBAL SHARED VAR l-inf-compl                 AS LOGICAL NO-UNDO.   

DEF VAR wgh-grupo  AS WIDGET-HANDLE NO-UNDO.
DEF VAR c-char     AS CHAR NO-UNDO.
DEF VAR l-compl-ok AS LOGICAL NO-UNDO.
DEF VAR c-telex    AS CHAR NO-UNDO.

assign c-char = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

/* MESSAGE p-ind-event              "p-ind-event  " skip   */
/*          p-ind-object             "p-ind-object " skip  */
/*          p-wgh-object:FILE-NAME   "p-wgh-object " skip  */
/*          p-wgh-frame:NAME         "p-wgh-frame  " skip  */
/*          p-cod-table              "p-cod-table  " skip  */
/*         string(p-row-table)      "p-row-table  " skip   */
/*         c-char                   "objeto"               */
/*         VIEW-AS ALERT-BOX INFO BUTTONS OK.              */

IF  p-ind-event            = "after-end-update"
AND p-ind-object           = "viewer"
AND p-wgh-object:FILE-NAME = "cdp/cd0401-v02.w" THEN DO:
    run intprg/nicd0401.w.
END.
    
/**** Criar campo Gera nota de entrada sem XML ****/

/* Guarda handle C«digo Emitente */


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
               LABEL             = "Gera Nota Entrada Sem XML":U.
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

            FIND FIRST int_ds_ext_emitente NO-LOCK
                 WHERE int_ds_ext_emitente.cod_emitente = emitente.cod-emitente NO-ERROR.
            IF  AVAIL int_ds_ext_emitente THEN
                ASSIGN wh-gera-nota-cd0401:screen-value = string(int_ds_ext_emitente.gera_nota).
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
     
        FOR FIRST int_ds_ext_emitente EXCLUSIVE-LOCK WHERE 
                  int_ds_ext_emitente.cod_emitente = emitente.cod-emitente :
        END.

        IF NOT AVAIL int_ds_ext_emitente 
        THEN DO:
            CREATE int_ds_ext_emitente.
            ASSIGN int_ds_ext_emitente.cod_emitente = emitente.cod-emitente.
        END.

        ASSIGN int_ds_ext_emitente.gera_nota = logical(wh-gera-nota-cd0401:screen-value).
        
     END.
END.




    



    
