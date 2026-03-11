/**********************************************************************
**
**  Programa: upc-re0101.p - UPC para o programa RE0101 
**              
**  Objetivo: Criar o campo Libera Conferˆncia WMS 
**
**********************************************************************/

/*********************** Defini‡Æo de Parƒmetros *************************/
define input parameter p-ind-event               as character      no-undo.
define input parameter p-ind-object              as character      no-undo.
define input parameter p-wgh-object              as handle         no-undo.
define input parameter p-wgh-frame               as widget-handle  no-undo.
define input parameter p-cod-table               as character      no-undo.
define input parameter p-row-table               as rowid          no-undo.

/******************** Defini‡Æo de Vari veis Globais *********************/
DEFINE NEW GLOBAL SHARED VAR wh-lib-conf-wms-re0101 AS WIDGET-HANDLE NO-UNDO.

DEF NEW GLOBAL SHARED VAR wh-re0101-usu-xml             AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-manut-xml           AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-vld-pedido          AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-tipo-arredonda      AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-rect                AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-text-rect           AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-tela                AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-text-dt-entrada-nf  AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-dt-entrada-nf       AS WIDGET-HANDLE NO-UNDO.

/******************** Defini‡Æo de Vari veis Locais **********************/
Define var  c-char                               as char           no-undo.
DEF VAR c-lib-conf-wms                           AS CHAR           NO-UNDO.
DEF VAR h-frame   AS HANDLE        NO-UNDO. 
DEF VAR wh-objeto AS WIDGET-HANDLE NO-UNDO.

/************************** In¡cio do Programa ***************************/

assign c-char = entry(num-entries(p-wgh-object:file-name,"~/"), p-wgh-object:file-name,"~/") no-error.

/*MESSAGE "Evento ...:"   p-ind-event   SKIP
        "Objeto ...:"   p-ind-object  SKIP
        "HObjeto...:"   p-wgh-object  SKIP
        "hFrame ...:"   p-wgh-frame   SKIP
        "Tabela ...:"   p-cod-table   SKIP
        "Rowid  ...:"   string(p-row-table)   SKIP
        "NomeObjeto:"   c-char        VIEW-AS ALERT-BOX.*/
  
if  p-ind-object  = "VIEWER"            and
    p-ind-event   = "BEFORE-INITIALIZE" and
    c-char        = "v02in292.w"        then do:
     
    CREATE TOGGLE-BOX wh-lib-conf-wms-re0101
    ASSIGN FRAME      = p-wgh-frame
           ROW        = 10.8
           COL        = 5.4
           VISIBLE    = YES
           SENSITIVE  = NO
           LABEL      = "Libera Conferˆncia WMS".
end.

if  p-ind-object  = "VIEWER"     and
    p-ind-event   = "DISPLAY"    and
    c-char        = "v02in292.w" then do:
    IF  p-row-table <> ? 
    AND valid-handle(wh-lib-conf-wms-re0101) THEN DO:      
        FIND FIRST param-re WHERE rowid(param-re) = p-row-table NO-LOCK NO-ERROR.
        IF AVAIL param-re THEN DO:
           FIND FIRST int_ds_ext_param_re NO-LOCK
                WHERE int_ds_ext_param_re.usuario = param-re.usuario NO-ERROR.
           IF AVAIL int_ds_ext_param_re THEN 
              ASSIGN wh-lib-conf-wms-re0101:SCREEN-VALUE  = STRING(int_ds_ext_param_re.lib_conf_wms).

           ELSE
              ASSIGN wh-lib-conf-wms-re0101:SCREEN-VALUE  = "no".
        END.
    END.
END.

if  p-ind-object  = "VIEWER"     and
    p-ind-event   = "DISPLAY"    and
    c-char        = "v06in292.w" then do:
    IF  p-row-table <> ? 
    AND valid-handle(wh-re0101-dt-entrada-nf) THEN DO:      
        FIND FIRST param-re WHERE rowid(param-re) = p-row-table NO-LOCK NO-ERROR.
        IF AVAIL param-re THEN DO:
           FIND FIRST int_ds_ext_param_re NO-LOCK
                WHERE int_ds_ext_param_re.usuario = param-re.usuario NO-ERROR.
           IF AVAIL int_ds_ext_param_re THEN 
              ASSIGN wh-re0101-dt-entrada-nf:SCREEN-VALUE = string(int_ds_ext_param_re.dt_entrada_nf,"99/99/9999").

           ELSE
              ASSIGN wh-re0101-dt-entrada-nf:SCREEN-VALUE = "".
        END.
    END.
END.

if p-ind-event  = "add"        and
   p-ind-object = "viewer"     and
   c-char       = "v02in292.w" then do:

   ASSIGN wh-lib-conf-wms-re0101:SCREEN-VALUE  = "no".

end.

if p-ind-event  = "add"        and
   p-ind-object = "viewer"     and
   c-char       = "v06in292.w" then do:

   ASSIGN wh-re0101-dt-entrada-nf:SCREEN-VALUE = "".

end.

if p-ind-event  = "enable"       and
   p-ind-object = "viewer"       and
   c-char       = "v02in292.w"  then do:
   
   IF VALID-HANDLE(wh-lib-conf-wms-re0101) THEN
      ASSIGN wh-lib-conf-wms-re0101:SENSITIVE  = YES.
         
end.

if p-ind-event  = "enable"       and
   p-ind-object = "viewer"       and
   c-char       = "v06in292.w"  then do:
   
   IF VALID-HANDLE(wh-lib-conf-wms-re0101) THEN
      ASSIGN wh-re0101-dt-entrada-nf:SENSITIVE = YES.
         
end.

if p-ind-event  = "disable"     and
   p-ind-object = "viewer"      and
   c-char       = "v02in292.w"  then do:
   
   IF VALID-HANDLE(wh-lib-conf-wms-re0101) THEN
      ASSIGN wh-lib-conf-wms-re0101:SENSITIVE  = NO.

end.

if p-ind-event  = "disable"     and
   p-ind-object = "viewer"      and
   c-char       = "v06in292.w"  then do:
   
   IF VALID-HANDLE(wh-lib-conf-wms-re0101) THEN
      ASSIGN wh-re0101-dt-entrada-nf:SENSITIVE = NO.

end.

if p-ind-event  = "assign"      and 
   p-ind-object = "viewer"      and
   c-char       = "v02in292.w"  then do:
   
   FIND FIRST param-re NO-LOCK WHERE rowid(param-re) = p-row-table NO-ERROR.
   IF AVAIL param-re THEN DO:      
      FIND FIRST int_ds_ext_param_re EXCLUSIVE-LOCK
           WHERE int_ds_ext_param_re.usuario = param-re.usuario NO-ERROR.
      ASSIGN c-lib-conf-wms = wh-lib-conf-wms-re0101:SCREEN-VALUE.
      IF NOT AVAIL int_ds_ext_param_re THEN DO:
         CREATE int_ds_ext_param_re.
         ASSIGN int_ds_ext_param_re.usuario       = param-re.usuario
                int_ds_ext_param_re.lib_conf_wms  = IF c-lib-conf-wms = "yes" THEN YES ELSE NO.
      END.
      ELSE 
         ASSIGN int_ds_ext_param_re.lib_conf_wms  = IF c-lib-conf-wms = "yes" THEN YES ELSE NO.
   END.
end.

if p-ind-event  = "assign"      and 
   p-ind-object = "viewer"      and
   c-char       = "v06in292.w"  then do:
   
   FIND FIRST param-re NO-LOCK WHERE rowid(param-re) = p-row-table NO-ERROR.
   IF AVAIL param-re THEN DO:      
      FIND FIRST int_ds_ext_param_re EXCLUSIVE-LOCK
           WHERE int_ds_ext_param_re.usuario = param-re.usuario NO-ERROR.
      IF NOT AVAIL int_ds_ext_param_re THEN DO:
         CREATE int_ds_ext_param_re.
         ASSIGN int_ds_ext_param_re.usuario       = param-re.usuario
                int_ds_ext_param_re.dt_entrada_nf = date(wh-re0101-dt-entrada-nf:SCREEN-VALUE). 

      END.
      ELSE 
         ASSIGN int_ds_ext_param_re.dt_entrada_nf = date(wh-re0101-dt-entrada-nf:SCREEN-VALUE). 
   END.
end.

IF  p-ind-object = "VIEWER" 
AND p-wgh-object:FILE-NAME = "invwr/v06in292.w" THEN DO:
   
   IF p-ind-event = "before-initialize" OR  
      p-ind-event = "initialize"        OR  
      p-ind-event = "ADD"               THEN DO:
        ASSIGN wh-objeto = p-wgh-frame:FIRST-CHILD.

        DO WHILE VALID-HANDLE(wh-objeto):

           IF wh-objeto:TYPE = "TEXT" AND 
              (wh-objeto:NAME = "c-tp-atual-cr" OR 
               wh-objeto:NAME = "c-orig-aliq-ipi") THEN 
               ASSIGN wh-objeto:HIDDEN = YES.
                       
           IF wh-objeto:NAME = "tipo-arredonda" THEN
              ASSIGN wh-re0101-tipo-arredonda = wh-objeto.
           IF wh-objeto:TYPE = "Field-Group" THEN
               ASSIGN wh-objeto = wh-objeto:FIRST-CHILD.
           ELSE
               ASSIGN wh-objeto = wh-objeto:NEXT-SIBLING.
        END.                                             
  
        IF VALID-HANDLE(wh-re0101-tipo-arredonda) THEN DO:
           CREATE RECTANGLE wh-re0101-rect
           ASSIGN FRAME        = wh-re0101-tipo-arredonda:FRAME
                  WIDTH        = 23
                  FILLED       = NO
                  HEIGHT       = 4.37
                  ROW          = 1.3
                  COL          = 57
                  EDGE-PIXELS  = 2
                  GRAPHIC-EDGE = YES
                  VISIBLE      = YES.
           
           CREATE TEXT wh-re0101-text-rect
           ASSIGN ROW          = 1
                  COLUMN       = 58.5
                  FRAME        = p-wgh-frame
                  HEIGHT       = 0.88
                  FORMAT       = "x(21)"
                  WIDTH        = 16
                  SCREEN-VALUE = "Integra‡Æo Notas XML"
                  FONT         =  wh-re0101-tipo-arredonda:FONT.

           CREATE TOGGLE-BOX wh-re0101-usu-xml
           ASSIGN ROW       = wh-re0101-tipo-arredonda:ROW + 0.5
                  COLUMN    = wh-re0101-tipo-arredonda:COLUMN + 56
                  FRAME     = wh-re0101-tipo-arredonda:FRAME
                  SENSITIVE = NO
                  VISIBLE   = YES
                  CHECKED   = NO
                  LABEL     = "Integra‡Æo XML"
                  HELP      = "Informe se o Usu rio ‚ Master."
                  FONT      =  wh-re0101-tipo-arredonda:FONT.

           CREATE TOGGLE-BOX wh-re0101-manut-xml
           ASSIGN ROW       = wh-re0101-tipo-arredonda:ROW + 1.5
                  COLUMN    = wh-re0101-tipo-arredonda:COLUMN + 56
                  FRAME     = wh-re0101-tipo-arredonda:FRAME
                  SENSITIVE = NO
                  VISIBLE   = YES
                  CHECKED   = NO
                  LABEL     = "Manuten‡Æo Notas XML"
                  HELP      = "Informe se o Usu rio pode alterar doctos importados"
                  FONT      =  wh-re0101-tipo-arredonda:FONT.

           CREATE TOGGLE-BOX wh-re0101-vld-pedido
           ASSIGN ROW       = wh-re0101-tipo-arredonda:ROW + 2.5
                  COLUMN    = wh-re0101-tipo-arredonda:COLUMN + 56
                  FRAME     = wh-re0101-tipo-arredonda:FRAME
                  WIDTH     = 20
                  SENSITIVE = NO
                  VISIBLE   = YES
                  CHECKED   = NO
                  LABEL     = "Valida Pedido de Compra"
                  HELP      = "Informe se o Usu rio necess rio validar pedido de compra"
                  FONT      =  wh-re0101-tipo-arredonda:FONT.

           CREATE FILL-IN wh-re0101-dt-entrada-nf
           ASSIGN FORMAT       = "99/99/9999"
                  ROW          = wh-re0101-tipo-arredonda:ROW + 4.36 
                  COLUMN       = wh-re0101-tipo-arredonda:COLUMN + 57
                  FRAME        = wh-re0101-tipo-arredonda:FRAME 
                  SENSITIVE    = NO
                  VISIBLE      = YES
                  HEIGHT       = 0.88
                  WIDTH        = 10
                  NAME         = "dt-entrada-nf"
                  HELP         = "Data Entrada NF liberada … partir de".

           CREATE text wh-re0101-text-dt-entrada-nf
           ASSIGN FORMAT       = "x(28)"
                  ROW          = wh-re0101-tipo-arredonda:ROW + 4.36
                  COLUMN       = wh-re0101-tipo-arredonda:COLUMN + 37.5
                  FRAME        = wh-re0101-tipo-arredonda:FRAME 
                  HEIGHT       = 0.88
                  WIDTH        = 19
                  NAME         = "text-entrada-nf"
                  SCREEN-VALUE = "Data Entrada NF … partir de:".

           /* IF VALID-HANDLE(wh-re0101-usu-xml) THEN DO:
              ON "value-changed" OF wh-re0101-usu-xml PERSISTENT RUN intupc/upc-re0101a.p.
           END. */
          
        END.
       
        IF p-ind-event = "ADD" THEN DO:
            RUN select-page IN wh-re0101-tela(INPUT 3).
            RUN select-page IN wh-re0101-tela(INPUT 1).
        END.

   END.  

   FIND FIRST param-re
        WHERE ROWID(param-re) = p-row-table NO-LOCK NO-ERROR.
   IF AVAILABLE param-re THEN DO:
      FIND FIRST int_ds_param_re
           WHERE int_ds_param_re.cod_usuario = param-re.usuario NO-LOCK NO-ERROR.
      IF AVAILABLE int_ds_param_re THEN DO:
         /* IF int_ds_param_re.usu-xml = YES THEN
            ASSIGN wh-re0101-var-permitida:SENSITIVE = NO. */

      END.
   END.

   IF p-ind-event = "enable" THEN
      ASSIGN wh-re0101-usu-xml:SENSITIVE       = YES
             wh-re0101-manut-xml:SENSITIVE     = YES
             wh-re0101-vld-pedido:SENSITIVE    = YES.

   IF p-ind-event = "disable" THEN
      ASSIGN wh-re0101-usu-xml:SENSITIVE       = NO
             wh-re0101-manut-xml:SENSITIVE     = NO
             wh-re0101-vld-pedido:SENSITIVE    = NO.

   IF p-ind-event = "add" THEN 
      ASSIGN wh-re0101-usu-xml:CHECKED         = NO
             wh-re0101-usu-xml:SENSITIVE       = YES
             wh-re0101-manut-xml:CHECKED       = NO
             wh-re0101-manut-xml:SENSITIVE     = YES
             wh-re0101-vld-pedido:CHECKED      = NO
             wh-re0101-vld-pedido:SENSITIVE    = YES.

   IF p-ind-event = "display" THEN DO:
      FIND FIRST param-re
           WHERE ROWID(param-re) = p-row-table NO-LOCK NO-ERROR.
      IF AVAILABLE param-re THEN DO:
         FIND FIRST int_ds_param_re
              WHERE int_ds_param_re.cod_usuario = param-re.usuario NO-LOCK NO-ERROR.
         IF AVAILABLE int_ds_param_re THEN DO:
            ASSIGN wh-re0101-usu-xml:CHECKED            = int_ds_param_re.usu_xml
                   wh-re0101-manut-xml:CHECKED          = int_ds_param_re.usu_manut
                   wh-re0101-vld-pedido:CHECKED         = int_ds_param_re.vld_pedido.
         END.
         ELSE
            ASSIGN wh-re0101-usu-xml:CHECKED            = NO
                   wh-re0101-manut-xml:CHECKED          = NO
                   wh-re0101-vld-pedido:CHECKED         = NO.
       END.
   END.

   IF p-ind-event = "assign" THEN DO:
      FIND FIRST param-re
           WHERE ROWID(param-re) = p-row-table NO-LOCK NO-ERROR.
      IF AVAILABLE param-re THEN DO:
         FIND FIRST int_ds_param_re
              WHERE int_ds_param_re.cod_usuario = param-re.usuario EXCLUSIVE-LOCK NO-ERROR.
         IF NOT AVAILABLE int_ds_param_re THEN DO:
            CREATE int_ds_param_re.
            ASSIGN int_ds_param_re.cod_usuario = param-re.usuario.
         END.
         ASSIGN int_ds_param_re.usu_xml       = wh-re0101-usu-xml:CHECKED
                int_ds_param_re.usu_manut     = wh-re0101-manut-xml:CHECKED
                int_ds_param_re.vld_pedido    = wh-re0101-vld-pedido:CHECKED.
      END.
   END.
END.

IF  p-ind-event  = "INITIALIZE"  
AND p-ind-object = "CONTAINER" THEN DO: 

    ASSIGN wh-re0101-tela = p-wgh-object.
     
    RUN select-page IN wh-re0101-tela(INPUT 3).
    RUN select-page IN wh-re0101-tela(INPUT 1).
END.


  
  

