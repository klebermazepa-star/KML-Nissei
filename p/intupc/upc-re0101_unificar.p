/*****************************************************************************
*  Autor....: ResultPro
*  Cliente..: Nissei 
*  Programa : upc-re0101.p
*  Descri‡Æo: UPC no programa re0101 para criar os campos Usu rio Master 
******************************************************************************/

/*-------------- Parƒmetros ----------------------*/
define input parameter p-ind-event   as char.
define input parameter p-ind-object  as char.
define input parameter p-wgh-object  as handle.
DEFINE Input Parameter p-wgh-frame   AS HANDLE.
define input parameter p-cod-table   as char.
define input parameter p-row-table   as rowid.

/*-------------- Variaveis ----------------------*/
DEF VAR h-frame   AS HANDLE        NO-UNDO. 
DEF VAR wh-objeto AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-usu-xml        AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-manut-xml      AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-tipo-arredonda AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-rect           AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-text-rect      AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-re0101-tela           AS WIDGET-HANDLE NO-UNDO.

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
                  HELP      = "Informe se o Usu rio pode alterar doctos importados."
                  FONT      =  wh-re0101-tipo-arredonda:FONT.

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
      FIND FIRST int-ds-param-re
           WHERE int-ds-param-re.cod-usuario = param-re.usuario NO-LOCK NO-ERROR.
      IF AVAILABLE int-ds-param-re THEN DO:
         /* IF int-ds-param-re.usu-xml = YES THEN
            ASSIGN wh-re0101-var-permitida:SENSITIVE = NO. */

      END.
   END.

   IF p-ind-event = "enable" THEN
      ASSIGN wh-re0101-usu-xml:SENSITIVE      = YES
             wh-re0101-manut-xml:SENSITIVE    = YES. 

   IF p-ind-event = "disable" THEN
      ASSIGN wh-re0101-usu-xml:SENSITIVE     = NO
             wh-re0101-manut-xml:SENSITIVE   = NO.

   IF p-ind-event = "add" THEN 
      ASSIGN wh-re0101-usu-xml:CHECKED        = NO
             wh-re0101-usu-xml:SENSITIVE      = YES
             wh-re0101-manut-xml:CHECKED      = NO
             wh-re0101-manut-xml:SENSITIVE    = YES.

   IF p-ind-event = "display" THEN DO:
      FIND FIRST param-re
           WHERE ROWID(param-re) = p-row-table NO-LOCK NO-ERROR.
      IF AVAILABLE param-re THEN DO:
         FIND FIRST int-ds-param-re
              WHERE int-ds-param-re.cod-usuario = param-re.usuario NO-LOCK NO-ERROR.
         IF AVAILABLE int-ds-param-re THEN DO:
            ASSIGN wh-re0101-usu-xml:CHECKED   = int-ds-param-re.usu-xml
                   wh-re0101-manut-xml:CHECKED   = int-ds-param-re.usu-manut.
         END.
         ELSE
            ASSIGN wh-re0101-usu-xml:CHECKED   = NO
                   wh-re0101-manut-xml:CHECKED = NO.
       END.
   END.

   IF p-ind-event = "assign" THEN DO:
      FIND FIRST param-re
           WHERE ROWID(param-re) = p-row-table NO-LOCK NO-ERROR.
      IF AVAILABLE param-re THEN DO:
         FIND FIRST int-ds-param-re
              WHERE int-ds-param-re.cod-usuario = param-re.usuario EXCLUSIVE-LOCK NO-ERROR.
         IF NOT AVAILABLE int-ds-param-re THEN DO:
            CREATE int-ds-param-re.
            ASSIGN int-ds-param-re.cod-usuario = param-re.usuario.
         END.
         ASSIGN int-ds-param-re.usu-xml    = wh-re0101-usu-xml:CHECKED
                int-ds-param-re.usu-manut  = wh-re0101-manut-xml:CHECKED.
      END.
   END.
END.

IF  p-ind-event  = "INITIALIZE"  
AND p-ind-object = "CONTAINER" THEN DO: 

    ASSIGN wh-re0101-tela = p-wgh-object.
     
    RUN select-page IN wh-re0101-tela(INPUT 3).
    RUN select-page IN wh-re0101-tela(INPUT 1).
END.

