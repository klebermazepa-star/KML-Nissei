/******************************************************************************************
**  Programa..: upc-re1001.p
**  Versao....:  
**  Objetivo..: Listar notas integradas pelo XML e criar notas no recebimento fiscal
******************************************************************************************/
DEF INPUT PARAM p-ind-event      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE            NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE     NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID             NO-UNDO.

 
/* MESSAGE p-ind-event              "p-ind-event  " skip   */
/*          p-ind-object             "p-ind-object " skip  */
/*          p-wgh-object:FILE-NAME   "p-wgh-object " skip  */
/*          p-wgh-frame:NAME         "p-wgh-frame  " skip  */
/*          p-cod-table              "p-cod-table  " skip  */
/*         string(p-row-table)      "p-row-table  " skip   */
/*  VIEW-AS ALERT-BOX INFO BUTTONS OK.                     */
   

DEFINE NEW GLOBAL SHARED VAR wh-frame                 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-object-frame          AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-emitente-re1001   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-serie-re1001          AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nro-docto-re1001      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nat-oper-re1001       AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btconf-orig-re1001    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-bt-int-xml-re1001     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-bt-impostos-re1001    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-object-re1001         AS WIDGET-HANDLE NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-query-re1001          AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR r-row-table-imposto-re1001 AS ROWID NO-UNDO.
                                           
define new global shared var adm-broker-hdl as handle no-undo.

define var c-objects      as character no-undo.
define var h-object       as handle    no-undo.
define var i-objects      as integer   no-undo.
define var l-habilita     as logical   no-undo.

DEF BUFFER b-docum-est FOR docum-est.

/* {utp/ut-glob.i} */ def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

IF p-ind-event  = "before-initialize" AND  
   p-ind-object = "container" 
THEN DO:          

    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD. 
 
    DO WHILE VALID-HANDLE(wh-frame):
       
        IF wh-frame:NAME = "btConf" THEN
           ASSIGN wh-btconf-orig-re1001 = wh-frame.
        
        IF wh-frame:NAME = "cod-emitente" THEN
          ASSIGN wh-cod-emitente-re1001 = wh-frame.

        IF wh-frame:NAME = "serie-docto" THEN
          ASSIGN wh-serie-re1001 = wh-frame.

        IF wh-frame:NAME = "nro-docto" THEN
         ASSIGN wh-nro-docto-re1001 = wh-frame.

        IF wh-frame:NAME = "nat-operacao" THEN
         ASSIGN wh-nat-oper-re1001 = wh-frame.
             
        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.
    
END.
 
IF p-ind-event  = "after-initialize" AND  
   p-ind-object = "container" 
THEN DO:  

  IF VALID-HANDLE (wh-btconf-orig-re1001) THEN DO:
      
     find first docum-est no-lock no-error.
     if avail docum-est then 
        assign l-habilita = wh-btconf-orig-re1001:SENSITIVE.
     else 
        assign l-habilita = yes.   
               
     CREATE BUTTON wh-bt-int-xml-re1001                                       
     ASSIGN FRAME     = wh-btconf-orig-re1001:FRAME                        
            LABEL     = wh-btconf-orig-re1001:LABEL                            
            FONT      = 4
            WIDTH     = 4.5 
            HEIGHT    = 1.20
            ROW       = 1.10                              
            COL       = wh-btconf-orig-re1001:COL - 14.8
            FGCOLOR   = ?
            BGCOLOR   = ?
            CONVERT-3D-COLORS = YES
            TOOLTIP   = "Integra‡Æo XML"
            VISIBLE   = wh-btconf-orig-re1001:VISIBLE                                        
            SENSITIVE = YES
            TRIGGERS:                                              
                ON CHOOSE PERSISTENT RUN intupc/upc-re1001-a.p.
            END TRIGGERS.
              
            wh-bt-int-xml-re1001:LOAD-IMAGE-UP("image/toolbar/im-carga").
            wh-bt-int-xml-re1001:LOAD-IMAGE-INSENSITIVE("image/toolbar/im-carga").
            wh-bt-int-xml-re1001:MOVE-TO-TOP().
  END.   
  ASSIGN wh-object-re1001 = p-wgh-object. 
           
END. 

IF  p-ind-event            = "BEFORE-INITIALIZE"
AND p-ind-object           = "CONTAINER"
AND p-wgh-object:FILE-NAME = "rep/re1001.w"
AND p-wgh-frame:NAME       = "fPage0" THEN DO:
    
    CREATE BUTTON wh-bt-impostos-re1001                                       
    ASSIGN FRAME     = wh-cod-emitente-re1001:FRAME                        
           LABEL     = "bt-imposto"                            
           FONT      = 4
           WIDTH     = 7.5 
           HEIGHT    = 2.5
           ROW       = 3.8                           
           COL       = 77
           FGCOLOR   = ?
           BGCOLOR   = ?
           CONVERT-3D-COLORS = YES
           TOOLTIP   = "Carrega Impostos"
           VISIBLE   = YES                                        
           SENSITIVE = YES
           TRIGGERS:                                              
               ON CHOOSE PERSISTENT RUN intupc/upc-re1001-b.p.
           END TRIGGERS.

           wh-bt-impostos-re1001:LOAD-IMAGE-UP("image/toolbar/im-down3").
           wh-bt-impostos-re1001:LOAD-IMAGE-INSENSITIVE("image/toolbar/im-down3").
           wh-bt-impostos-re1001:MOVE-TO-TOP().

END.

IF  p-ind-event            = "AFTER-DISPLAY"
AND p-ind-object           = "CONTAINER"
AND p-wgh-object:FILE-NAME = "rep/re1001.w"
AND p-wgh-frame:NAME       = "fPage0" THEN DO:

    IF  p-cod-table = "docum-est" 
    AND p-row-table = ? THEN     
        ASSIGN wh-bt-impostos-re1001:SENSITIVE = NO.
    
    IF  p-cod-table = "docum-est" 
    AND p-row-table <> ? THEN DO:
        ASSIGN r-row-table-imposto-re1001 = p-row-table.
        FIND FIRST b-docum-est WHERE 
                   ROWID(b-docum-est) = p-row-table NO-LOCK NO-ERROR. 
        IF AVAIL b-docum-est THEN DO:
           FOR FIRST int_ds_docto_xml WHERE
                     int_ds_docto_xml.serie        = b-docum-est.serie-docto    AND
                     int(int_ds_docto_xml.nNF)     = int(b-docum-est.nro-docto) AND
                     int_ds_docto_xml.cod_emitente = b-docum-est.cod-emitente   AND 
                     int_ds_docto_xml.tipo_nota    = b-docum-est.tipo-nota      NO-LOCK:
           END.
           IF AVAIL int_ds_docto_xml THEN 
              ASSIGN wh-bt-impostos-re1001:SENSITIVE = YES.
           ELSE
              ASSIGN wh-bt-impostos-re1001:SENSITIVE = NO.
        END.
        ELSE
           ASSIGN wh-bt-impostos-re1001:SENSITIVE = NO.
    END.
END.

RETURN "OK".
