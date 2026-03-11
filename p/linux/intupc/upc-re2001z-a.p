/****************************************************************************
** Programa: upc-re2001z-a.p
** Objetivo: Trazer natureza de opera‡Æo conforme int_ds_docto_xml
*****************************************************************************/
DEF INPUT PARAMETER p-opcao AS CHAR.

def new global shared var wh-fi-cod-emitente    as widget-handle    no-undo.
def new global shared var wh-fi-nat-operacao    as widget-handle    no-undo.
def new global shared var wh-fi-nro-docto       as widget-handle    no-undo.
def new global shared var wh-fi-serie-docto     as widget-handle    no-undo.
def new global shared var wh-fi-tipo-nota       as widget-handle    no-undo.
DEF NEW GLOBAL SHARED VAR wh-row-ant            AS ROWID            NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-log-natureza       AS LOGICAL          NO-UNDO.


DEF VAR i-tipo-nota AS INTEGER NO-UNDO.
     
/* trim(string({ininc/i01in089.i 06 wh-fi-tipo-nota:screen-value})). */


     
IF p-opcao = "entry" 
THEN DO:
   
  CASE wh-fi-tipo-nota:screen-value:
            WHEN "Compra"               THEN ASSIGN i-tipo-nota = 1.
            WHEN "Devolu»’o"            THEN ASSIGN i-tipo-nota = 2.
            WHEN "Transfer¼ncia"        THEN ASSIGN i-tipo-nota = 3.
            WHEN "Remessa Entr. Futura" THEN ASSIGN i-tipo-nota = 4.
  END CASE. 

  FIND first int_ds_docto_xml NO-LOCK where 
             int_ds_docto_xml.nnf          = wh-fi-nro-docto:screen-value   and  
             int_ds_docto_xml.serie        = wh-fi-serie-docto:screen-value and  
             int_ds_docto_xml.cod_emitente = int(wh-fi-cod-emitente:screen-value) AND
             int_ds_docto_xml.tipo_nota    =   i-tipo-nota NO-ERROR.
  IF AVAIL int_ds_docto_xml  THEN DO:

      IF wh-row-ant <> rowid(int_ds_docto_xml) THEN
         ASSIGN wh-log-natureza = NO.
           
      IF wh-log-natureza = NO 
      THEN DO:
      
          ASSIGN wh-log-natureza = YES
                 wh-row-ant      = ROWID(int_ds_docto_xml).
    
          ASSIGN wh-fi-nat-operacao:SCREEN-VALUE = int_ds_docto_xml.nat_operacao.
    
          APPLY "LEAVE" TO wh-fi-nat-operacao.
          
      END.

  END.
  ELSE DO:

      ASSIGN wh-row-ant = ?
             wh-fi-nat-operacao:SCREEN-VALUE = "".
    
      APPLY "LEAVE" TO wh-fi-nat-operacao. 

  END.                                     

END.

