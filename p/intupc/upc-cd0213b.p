/*********************************************************************************
**  Programa.: upc-cd0213b.p - UPC no programa Manutená∆o Folha de Especificaá∆o
**  
**  Descriá∆o: Inclus∆o do campo Obriga Resultado Carac. TÇcnica Item
*********************************************************************************/

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

DEF VAR c-char                     AS CHAR          NO-UNDO.
DEF VAR wh-objeto                  AS WIDGET-HANDLE NO-UNDO.
DEF VAR wgh-child                  AS WIDGET-HANDLE NO-UNDO.

DEF NEW GLOBAL SHARED VAR wh-carac-tec-item-cd0213b AS WIDGET-HANDLE NO-UNDO.

DEF VAR wgh-grupo AS WIDGET-HANDLE NO-UNDO.
DEF VAR wgh-frame AS WIDGET-HANDLE NO-UNDO.

/******************************************************************************************************/
assign c-char = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

/* MESSAGE p-ind-event              "p-ind-event  " skip   */
/*          p-ind-object             "p-ind-object " skip  */
/*          p-wgh-object:FILE-NAME   "p-wgh-object " skip  */
/*          p-wgh-frame:NAME         "p-wgh-frame  " skip  */
/*          p-cod-table              "p-cod-table  " skip  */
/*         string(p-row-table)      "p-row-table  " skip   */
/*         c-char                                          */
/*  VIEW-AS ALERT-BOX INFO BUTTONS OK.                     */

IF  p-ind-event            = "before-initialize"
and p-ind-object           = "container"
AND p-wgh-object:FILE-NAME = "cdp/cd0213b.w" THEN DO:

    ASSIGN wgh-grupo = p-wgh-frame:FIRST-CHILD.
    IF  VALID-HANDLE(wgh-grupo) THEN DO:
        ASSIGN wgh-child = wgh-grupo:FIRST-CHILD. 
    
        encontra-frame:
        DO  WHILE VALID-HANDLE(wgh-child):
            CASE wgh-child:TYPE:
                 WHEN "frame" THEN DO:   
                    IF  wgh-child:NAME = "f-main" THEN DO:

                        ASSIGN wgh-frame = wgh-child:HANDLE.
                        LEAVE encontra-frame.

                    END.
                END.
            END.
            ASSIGN wgh-child = wgh-child:NEXT-SIBLING NO-ERROR.
        END.
    END.
                          
    CREATE TOGGLE-BOX wh-carac-tec-item-cd0213b
    ASSIGN FRAME              = wgh-frame
           ROW                = 5.85
           COL                = 43
           VISIBLE            = YES
           SENSITIVE          = YES
           LABEL              = "Resultado Obrigat¢rio".

END.

IF  p-ind-event  = "display"   
AND p-ind-object = "viewer"
AND c-char       = "v02in051.w" THEN DO:

    FIND FIRST comp-folh NO-LOCK WHERE ROWID(comp-folh) = p-row-table NO-ERROR.
    IF AVAIL comp-folh THEN DO:
       FIND first int_ds_ext_comp_folh NO-LOCK 
            WHERE int_ds_ext_comp_folh.cd_folha = comp-folh.cd-folha AND
                  int_ds_ext_comp_folh.cd_comp  = comp-folh.cd-comp NO-ERROR.
       IF AVAIL int_ds_ext_comp_folh THEN
          ASSIGN wh-carac-tec-item-cd0213b:CHECKED = int_ds_ext_comp_folh.obriga_carac_tec.
       ELSE
          ASSIGN wh-carac-tec-item-cd0213b:CHECKED = NO.
    END.
END.

IF  p-ind-event  = "assign"   
AND p-ind-object = "viewer"
AND c-char       = "v02in051.w" THEN DO:

    FIND FIRST comp-folh NO-LOCK WHERE ROWID(comp-folh) = p-row-table NO-ERROR.
    IF AVAIL comp-folh THEN DO:
       FIND first int_ds_ext_comp_folh EXCLUSIVE-LOCK 
            WHERE int_ds_ext_comp_folh.cd_folha = comp-folh.cd-folha AND
                  int_ds_ext_comp_folh.cd_comp  = comp-folh.cd-comp NO-ERROR.
       IF NOT AVAIL int_ds_ext_comp_folh THEN DO:
          CREATE int_ds_ext_comp_folh.
          ASSIGN int_ds_ext_comp_folh.cd_folha = comp-folh.cd-folha
                 int_ds_ext_comp_folh.cd_comp  = comp-folh.cd-comp.
       END. 
       ASSIGN int_ds_ext_comp_folh.obriga_carac_tec = wh-carac-tec-item-cd0213b:CHECKED. 
    END.
END.





