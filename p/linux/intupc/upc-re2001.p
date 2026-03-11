/******************************************************************************************
**  Programa: upc-re2001.p
**  
**  Data....: Bot∆o integraá∆o XML / Bot∆o conferància WMS
******************************************************************************************/

DEF INPUT PARAM p-ind-event      AS   CHAR            NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR            NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE          NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE   NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR            NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID           NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-frame                 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-object-re2001         AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-emitente-re2001   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-serie-re2001          AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nro-docto-re2001      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btconf-orig-re2001    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-bt-int-xml-re2001     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-bt-conf-wms-re2001    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-tb-conf-wms-re2001    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-query-re2001          AS WIDGET-HANDLE NO-UNDO.
                                           
DEF NEW GLOBAL SHARED VAR c-cod-table-wms-re2001 AS CHAR     NO-UNDO.
DEF NEW GLOBAL SHARED VAR r-row-table-wms-re2001 AS ROWID    NO-UNDO.

define new global shared var adm-broker-hdl as handle no-undo.

define var c-objects      as character no-undo.
define var h-object       as handle    no-undo.
define var i-objects      as integer   no-undo.
Define var c-char         as char      no-undo.

assign c-char = entry(num-entries(p-wgh-object:file-name,"~/"), p-wgh-object:file-name,"~/") no-error.

/*MESSAGE p-ind-event              "p-ind-event  " skip 
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
 VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

IF (p-ind-event  = "before-initialize" AND  
    p-ind-object = "container")  OR 
   (p-ind-event  = "initialize" AND  
    p-ind-object = "viewer") THEN DO:          
    
    ASSIGN wh-frame = p-wgh-frame:FIRST-CHILD
           wh-frame = wh-frame:FIRST-CHILD. 
 
    DO WHILE VALID-HANDLE(wh-frame):
       
        IF wh-frame:NAME = "bt-atualizar" THEN 
           ASSIGN wh-btconf-orig-re2001 = wh-frame.
        
        IF wh-frame:NAME = "cod-emitente" THEN 
           ASSIGN wh-cod-emitente-re2001 = wh-frame.

        IF wh-frame:NAME = "serie-docto" THEN
           ASSIGN wh-serie-re2001 = wh-frame.

        IF wh-frame:NAME = "nro-docto" THEN
           ASSIGN wh-nro-docto-re2001 = wh-frame.
        
        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.

END.
 
IF p-ind-event  = "initialize" AND  
   p-ind-object = "container" THEN DO:  

  /* novo receboimento n∆o utilizar† mais recebimento f°sico
  IF VALID-HANDLE (wh-btconf-orig-re2001) THEN DO:  
     CREATE BUTTON wh-bt-int-xml-re2001                                       
     ASSIGN FRAME     = wh-btconf-orig-re2001:FRAME                        
            LABEL     = wh-btconf-orig-re2001:LABEL                            
            FONT      = 4
            WIDTH     = 4.5 
            HEIGHT    = 1.20
            ROW       = 1.10                              
            COL       = wh-btconf-orig-re2001:COL - 9
            FGCOLOR   = ?
            BGCOLOR   = ?
            CONVERT-3D-COLORS = YES
            TOOLTIP   = "Integraá∆o XML"
            VISIBLE   = YES                                        
            SENSITIVE = YES
            TRIGGERS:                                              
                ON CHOOSE PERSISTENT RUN intupc/upc-re2001-a.p.
            END TRIGGERS.
              
            wh-bt-int-xml-re2001:LOAD-IMAGE-UP("image/toolbar/im-carga").
            wh-bt-int-xml-re2001:LOAD-IMAGE-INSENSITIVE("image/toolbar/im-carga").
            wh-bt-int-xml-re2001:MOVE-TO-TOP().

     CREATE BUTTON wh-bt-conf-wms-re2001                                       
     ASSIGN FRAME     = wh-btconf-orig-re2001:FRAME                        
            LABEL     = wh-btconf-orig-re2001:LABEL                            
            FONT      = 4
            WIDTH     = 4.5 
            HEIGHT    = 1.20
            ROW       = 1.10                              
            COL       = wh-btconf-orig-re2001:COL - 14.5
            FGCOLOR   = ?
            BGCOLOR   = ?
            CONVERT-3D-COLORS = YES
            TOOLTIP   = "Conferància WMS"
            VISIBLE   = wh-btconf-orig-re2001:VISIBLE                                        
            SENSITIVE = wh-btconf-orig-re2001:SENSITIVE
            TRIGGERS:
               ON CHOOSE PERSISTENT RUN intupc/upc-re2001-b.p.
            END TRIGGERS.

            wh-bt-conf-wms-re2001:LOAD-IMAGE-UP("image/toolbar/im-edl").
            wh-bt-conf-wms-re2001:LOAD-IMAGE-INSENSITIVE("image/toolbar/im-edl").
            wh-bt-conf-wms-re2001:MOVE-TO-TOP().
  END.   
  */
   
  ASSIGN wh-object-re2001 = p-wgh-object. 

  RUN get-link-handle IN adm-broker-hdl (INPUT p-wgh-object, 
                                         INPUT "CONTAINER-TARGET":U, 
                                         OUTPUT c-objects).
        
  do i-objects = 1 to num-entries(c-objects):
     assign h-object = widget-handle(entry(i-objects, c-objects)).
      
     if index(h-object:private-data, "qry") <> 0 then do:

        ASSIGN wh-query-re2001 = h-object.
         
     end.     
  end.                         
END. 

IF p-ind-event  = "DISPLAY" AND  
   p-ind-object = "VIEWER"  AND
   c-char       = "v09in163.w" THEN DO:

   CREATE TOGGLE-BOX wh-tb-conf-wms-re2001
   ASSIGN FRAME      = p-wgh-frame
          ROW        = 1.3
          COL        = 68
          VISIBLE    = YES
          SENSITIVE  = NO
          LABEL      = "Em Conferància WMS".

   IF  p-cod-table = "doc-fisico" 
   AND p-row-table <> ? THEN DO:

       ASSIGN c-cod-table-wms-re2001 = p-cod-table
              r-row-table-wms-re2001 = p-row-table.

       FIND FIRST doc-fisico WHERE 
                  ROWID(doc-fisico) = r-row-table-wms-re2001 NO-LOCK NO-ERROR. 
       IF AVAIL doc-fisico THEN DO:
          FIND FIRST int_ds_docto_wms WHERE
                     int_ds_docto_wms.doc_numero_n = INT(doc-fisico.nro-docto) AND
                     int_ds_docto_wms.doc_serie_s  = doc-fisico.serie-docto    AND
                     int_ds_docto_wms.doc_origem_n = doc-fisico.cod-emitente NO-ERROR.
          IF AVAIL int_ds_docto_wms THEN DO:
             IF int_ds_docto_wms.situacao = 1 
             OR int_ds_docto_wms.situacao = 3
             OR int_ds_docto_wms.situacao >= 10 /* novo recebimento cd */THEN 
                ASSIGN wh-tb-conf-wms-re2001:CHECKED = YES.
             ELSE
                ASSIGN wh-tb-conf-wms-re2001:CHECKED = NO.
          END.
       END.
   END.
END.

IF  p-ind-event  = "INITIALIZE" 
AND p-ind-object = "CONTAINER" 
AND c-char       = "re2001.w" THEN DO:

    FIND FIRST doc-fisico WHERE 
               ROWID(doc-fisico) = r-row-table-wms-re2001 NO-LOCK NO-ERROR. 
    IF AVAIL doc-fisico THEN DO:
       FIND FIRST int_ds_docto_wms WHERE
                  int_ds_docto_wms.doc_numero_n = INT(doc-fisico.nro-docto) AND
                  int_ds_docto_wms.doc_serie_s  = doc-fisico.serie-docto    AND
                  int_ds_docto_wms.doc_origem_n = doc-fisico.cod-emitente NO-ERROR.
       IF AVAIL int_ds_docto_wms THEN DO:
          IF int_ds_docto_wms.situacao = 1 
          OR int_ds_docto_wms.situacao = 3
          OR int_ds_docto_wms.situacao >= 10 /* novo recebimento CD */  THEN
             ASSIGN wh-btconf-orig-re2001:SENSITIVE = NO.
          ELSE
             ASSIGN wh-btconf-orig-re2001:SENSITIVE = YES.
       END.
       FIND FIRST param-re WHERE 
                  param-re.usuario = doc-fisico.usuario NO-LOCK NO-ERROR.
       IF AVAIL param-re THEN DO:      
          FIND FIRST int_ds_ext_param_re WHERE 
                     int_ds_ext_param_re.usuario = param-re.usuario NO-LOCK NO-ERROR.
          IF AVAIL int_ds_ext_param_re THEN DO:
             IF int_ds_ext_param_re.lib_conf_wms = YES THEN 
                ASSIGN wh-btconf-orig-re2001:SENSITIVE = YES.
          END.
       END.
    END.
END.

IF  p-ind-event  = "AFTER-OPEN-QUERY"
AND p-ind-object = "BROWSER"
AND c-char       = "b06in163.w" THEN DO:

    FIND FIRST doc-fisico WHERE
               ROWID(doc-fisico) = r-row-table-wms-re2001 NO-LOCK NO-ERROR.
    IF AVAIL doc-fisico THEN DO:
       FIND FIRST int_ds_docto_wms WHERE
                  int_ds_docto_wms.doc_numero_n = INT(doc-fisico.nro-docto) AND
                  int_ds_docto_wms.doc_serie_s  = doc-fisico.serie-docto    AND
                  int_ds_docto_wms.doc_origem_n = doc-fisico.cod-emitente NO-ERROR.
       IF AVAIL int_ds_docto_wms THEN DO:
          IF int_ds_docto_wms.situacao = 1
          OR int_ds_docto_wms.situacao = 3 
          OR int_ds_docto_wms.situacao >= 10 /* novo recebimento CD */  THEN
             ASSIGN wh-btconf-orig-re2001:SENSITIVE = NO.
          ELSE
             ASSIGN wh-btconf-orig-re2001:SENSITIVE = YES.
       END.
       FIND FIRST param-re WHERE 
                  param-re.usuario = doc-fisico.usuario NO-LOCK NO-ERROR.
       IF AVAIL param-re THEN DO:      
          FIND FIRST int_ds_ext_param_re WHERE 
                     int_ds_ext_param_re.usuario = param-re.usuario NO-LOCK NO-ERROR.
          IF AVAIL int_ds_ext_param_re THEN DO:
             IF int_ds_ext_param_re.lib_conf_wms = YES THEN 
                ASSIGN wh-btconf-orig-re2001:SENSITIVE = YES.
          END.
       END.
    END.
END.

IF  p-ind-event  = "DISPLAY"
AND p-ind-object = "VIEWER"
AND c-char       = "v09in163.w" THEN DO:

    FIND FIRST doc-fisico WHERE
               ROWID(doc-fisico) = r-row-table-wms-re2001 NO-LOCK NO-ERROR.
    IF AVAIL doc-fisico THEN DO:
       FIND FIRST int_ds_docto_wms WHERE
                  int_ds_docto_wms.doc_numero_n = INT(doc-fisico.nro-docto) AND
                  int_ds_docto_wms.doc_serie_s  = doc-fisico.serie-docto    AND
                  int_ds_docto_wms.doc_origem_n = doc-fisico.cod-emitente NO-ERROR.
       IF AVAIL int_ds_docto_wms THEN DO:
          IF int_ds_docto_wms.situacao = 1
          OR int_ds_docto_wms.situacao = 3 
          OR int_ds_docto_wms.situacao >= 10 /* novo recebimento CD */  THEN DO:
             ASSIGN wh-btconf-orig-re2001:SENSITIVE = NO.
          END.
          ELSE
             ASSIGN wh-btconf-orig-re2001:SENSITIVE = YES.
       END.
       FIND FIRST param-re WHERE 
                  param-re.usuario = doc-fisico.usuario NO-LOCK NO-ERROR.
       IF AVAIL param-re THEN DO:      
          FIND FIRST int_ds_ext_param_re WHERE 
                     int_ds_ext_param_re.usuario = param-re.usuario NO-LOCK NO-ERROR.
          IF AVAIL int_ds_ext_param_re THEN DO:
             IF int_ds_ext_param_re.lib_conf_wms = YES THEN 
                ASSIGN wh-btconf-orig-re2001:SENSITIVE = YES.
          END.
       END.
    END.
END.

RETURN "OK".
