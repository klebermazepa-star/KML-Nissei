/*******************************************************************************
**  Programa.: upc-cd0204.p	- UPC cadastro de Itens
**  
**  Descri‡Æo: InclusÆo dos campos NCMIPI, Pre‡o Base e Pre‡o Ult. Entrada
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

DEF NEW GLOBAL SHARED VAR wh-it-codigo-cd0204          AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-ncmipi-cd0204             AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-label-ncmipi-cd0204       AS WIDGET-HANDLE NO-UNDO.
def new global shared var wh-bt-compl-it-cd0204        as widget-handle no-undo.
def new global shared var wh-bt-exporta-cd0204         as widget-handle no-undo.
def new global shared var wh-cd-folh-item-cd0204       as widget-handle no-undo.
DEF NEW GLOBAL SHARED VAR wh-it-carac-tec-cd0204       AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-handle-container-cd0204  AS WIDGET-HANDLE NO-UNDO.

DEF NEW GLOBAL SHARED VAR wh-preco-base-cd0204         AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-preco-ul-ent-cd0204       AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-label-preco-base-cd0204   AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-label-preco-ul-ent-cd0204 AS WIDGET-HANDLE NO-UNDO.

def new global shared var wh-frame                 as widget-handle no-undo.

def new global shared var r-rowid-upc-cd0204       as rowid no-undo.

DEF BUFFER b-item-uni-estab FOR item-uni-estab.

DEF TEMP-TABLE tt-estabel NO-UNDO
    FIELD cod-estabel AS CHAR
    INDEX codigo cod-estabel.

DEF NEW GLOBAL SHARED TEMP-TABLE tt-preco-cd0204
    FIELD it-codigo-cd0204    AS CHAR
    FIELD preco-base-cd0204   AS DEC
    FIELD preco-ul-ent-cd0204 AS DEC.

DEF VAR i-vetor-item-mat AS INT NO-UNDO.

/******************************************************************************************************/
assign c-char = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/")
       r-rowid-upc-cd0204 = p-row-table.

/*MESSAGE p-ind-event              "p-ind-event  " skip
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         c-char                   "c-char " SKIP  
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
       
       IF wh-frame:NAME = "bt-exporta" THEN 
          ASSIGN wh-bt-exporta-cd0204 = wh-frame.

       IF wh-frame:NAME = "cd-folh-item" THEN 
          ASSIGN wh-cd-folh-item-cd0204 = wh-frame.

       IF wh-frame:NAME = "it-codigo" THEN 
          ASSIGN wh-it-carac-tec-cd0204 = wh-frame.
               
       ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.
END.

IF p-ind-event  = "initialize" AND  
   p-ind-object = "container" THEN DO:  
    
   ASSIGN wgh-handle-container-cd0204 = p-wgh-object.

   IF VALID-HANDLE (wh-bt-exporta-cd0204) THEN DO:  
      CREATE BUTTON wh-bt-compl-it-cd0204                                       
      ASSIGN FRAME     = wh-bt-exporta-cd0204:FRAME                        
             LABEL     = wh-bt-exporta-cd0204:LABEL                            
             FONT      = 4
             WIDTH     = 4.5 
             HEIGHT    = 1.20
             ROW       = 1.10                              
             COL       = wh-bt-exporta-cd0204:COL + 4.2
             FGCOLOR   = ?
             BGCOLOR   = ?
             CONVERT-3D-COLORS = YES
             TOOLTIP   = "C¢digos EAN"
             VISIBLE   = wh-bt-exporta-cd0204:VISIBLE                                        
             SENSITIVE = wh-bt-exporta-cd0204:SENSITIVE
             TRIGGERS:                                              
                 ON CHOOSE PERSISTENT RUN intprg/nicd0204.w.
             END TRIGGERS.
              
      wh-bt-compl-it-cd0204:LOAD-IMAGE-UP("image/toolbar/mip-barras").
      wh-bt-compl-it-cd0204:LOAD-IMAGE-INSENSITIVE("image/toolbar/mip-barras").
      wh-bt-compl-it-cd0204:MOVE-TO-TOP().
   end.
end.

if p-ind-event = "INITIALIZE" and c-char = "v34in172.w" then do:
    assign wh-objeto = p-wgh-frame:first-child 
           wh-objeto = wh-objeto:first-child.
    
    do while valid-handle(wh-objeto):        
       IF wh-objeto:NAME = "it-codigo" THEN
          ASSIGN wh-it-codigo-cd0204 = wh-objeto.        
       IF wh-objeto:TYPE = "field-group" THEN
          assign wh-objeto = wh-objeto:FIRST-CHILD.
       ELSE
          ASSIGN wh-objeto = wh-objeto:next-sibling.    
    END.
END.


IF  p-ind-event = "before-initialize"   
AND c-char      = "v36in172.w" THEN DO:  

   CREATE TEXT wh-label-ncmipi-cd0204
   ASSIGN ROW            = 7.3
          COLUMN         = 57
          FRAME          = p-wgh-frame
          SENSITIVE      = NO
          VISIBLE        = YES
          HEIGHT-CHARS   = 0.88
          WIDTH-CHARS    = 8
          FORMAT         = "X(8)"
          SCREEN-VALUE   = "NCMIPI:".

    CREATE FILL-IN wh-ncmipi-cd0204
    ASSIGN ROW          = 7.3
           COLUMN       = 65.7
           DATA-TYPE    = "INTEGER"
           FRAME        = p-wgh-frame
           SENSITIVE    = NO
           VISIBLE      = YES
           HEIGHT       = 0.88
           WIDTH        = 10
           NAME         = "ncmipi"
           FORMAT       = ">>>>>>>>9"
           SCREEN-VALUE = "0"
           HELP         = "Informe o NCMIPI do Item".

    CREATE TEXT wh-label-preco-base-cd0204
    ASSIGN ROW            = 4.2
           COLUMN         = 57
           FRAME          = p-wgh-frame
           SENSITIVE      = NO
           VISIBLE        = YES
           HEIGHT-CHARS   = 0.88
           WIDTH-CHARS    = 12
           FORMAT         = "X(11)"
           SCREEN-VALUE   = "Pre‡o Base:".

     CREATE FILL-IN wh-preco-base-cd0204
     ASSIGN ROW          = 4.2
            COLUMN       = 65.7
            DATA-TYPE    = "DECIMAL"
            FRAME        = p-wgh-frame
            SENSITIVE    = NO
            VISIBLE      = YES
            HEIGHT       = 0.88
            WIDTH        = 17
            NAME         = "preco-base"
            FORMAT       = ">>>,>>>,>>9.9999"
            SCREEN-VALUE = "0"
            HELP         = "Informe o Pre‡o Base do Item".

     CREATE TEXT wh-label-preco-ul-ent-cd0204
     ASSIGN ROW            = 5.2
            COLUMN         = 55
            FRAME          = p-wgh-frame
            SENSITIVE      = NO
            VISIBLE        = YES
            HEIGHT-CHARS   = 0.88
            WIDTH-CHARS    = 12
            FORMAT         = "X(17)"
            SCREEN-VALUE   = "Pre‡o Ult. Ent.:".

      CREATE FILL-IN wh-preco-ul-ent-cd0204
      ASSIGN ROW          = 5.2
             COLUMN       = 65.7
             DATA-TYPE    = "DECIMAL"
             FRAME        = p-wgh-frame
             SENSITIVE    = NO
             VISIBLE      = YES
             HEIGHT       = 0.88
             WIDTH        = 17
             NAME         = "preco-ul-ent"
             FORMAT       = ">>>,>>>,>>9.9999"
             SCREEN-VALUE = "0"
             HELP         = "Informe o Pre‡o Ultima Entrada do Item".

END.

IF  p-ind-event = "Enable"      
AND c-char      = "v36in172.w" THEN DO:
    
    IF VALID-HANDLE(wh-ncmipi-cd0204) THEN
       ASSIGN wh-ncmipi-cd0204:SENSITIVE       = TRUE
              wh-preco-base-cd0204:SENSITIVE   = TRUE
              wh-preco-ul-ent-cd0204:SENSITIVE = TRUE.

END.

IF  p-ind-event = "Disable"     
AND c-char      = "v36in172.w" THEN DO:
   
    IF  VALID-HANDLE(wh-ncmipi-cd0204) THEN
        ASSIGN wh-ncmipi-cd0204:SENSITIVE       = FALSE
               wh-preco-base-cd0204:SENSITIVE   = FALSE
               wh-preco-ul-ent-cd0204:SENSITIVE = FALSE.
END.

IF  p-ind-event = "Display"   
AND c-char      = "v36in172.w" THEN DO:

    IF VALID-HANDLE(wh-ncmipi-cd0204) THEN DO:
       ASSIGN wh-ncmipi-cd0204:SENSITIVE       = FALSE
              wh-ncmipi-cd0204:SCREEN-VALUE    = "0"
              wh-preco-base-cd0204:SENSITIVE   = FALSE
              wh-preco-ul-ent-cd0204:SENSITIVE = FALSE.

       FIND FIRST ITEM NO-LOCK
            WHERE ROWID(ITEM) = p-row-table  NO-ERROR.
       IF AVAIL ITEM THEN DO:
          FIND first int_ds_ext_item NO-LOCK 
               WHERE int_ds_ext_item.it_codigo = ITEM.it-codigo NO-ERROR.
          IF AVAIL int_ds_ext_item THEN
             ASSIGN wh-ncmipi-cd0204:SCREEN-VALUE = string(int_ds_ext_item.ncmipi).

          FIND FIRST item-uni-estab USE-INDEX codigo WHERE
                     item-uni-estab.it-codigo   = ITEM.it-codigo AND
                     item-uni-estab.cod-estabel = "973" NO-LOCK NO-ERROR.
          IF AVAIL item-uni-estab THEN DO:
             ASSIGN wh-preco-base-cd0204:SCREEN-VALUE   = STRING(item-uni-estab.preco-base)
                    wh-preco-ul-ent-cd0204:SCREEN-VALUE = STRING(item-uni-estab.preco-ul-ent).
          END.
          ELSE DO: 
             ASSIGN wh-preco-base-cd0204:SCREEN-VALUE   = "0,0000"
                    wh-preco-ul-ent-cd0204:SCREEN-VALUE = "0,0000".
          END.
       END.  
    END.

    RUN select-page IN wgh-handle-container-cd0204 (INPUT 3).
    RUN select-page IN wgh-handle-container-cd0204 (INPUT 1).

END.

if  p-ind-event = "ASSIGN"      
AND c-char      = "v36in172.w" then do:

    IF  VALID-HANDLE(wh-ncmipi-cd0204) THEN DO:

        ASSIGN wh-ncmipi-cd0204:SENSITIVE       = FALSE
               wh-preco-base-cd0204:SENSITIVE   = FALSE
               wh-preco-ul-ent-cd0204:SENSITIVE = FALSE.

        FIND FIRST ITEM NO-LOCK
             WHERE ROWID(ITEM) = p-row-table  NO-ERROR.
        IF AVAIL ITEM THEN DO:
           FIND first int_ds_ext_item WHERE 
                      int_ds_ext_item.it_codigo = ITEM.it-codigo exclusive-LOCK NO-ERROR.
           IF NOT AVAIL int_ds_ext_item THEN DO:
              CREATE int_ds_ext_item.
              ASSIGN int_ds_ext_item.it_codigo = ITEM.it-codigo.
           END. 
           ASSIGN int_ds_ext_item.ncmipi = int(wh-ncmipi-cd0204:SCREEN-VALUE).
        END.
    END.
END.

IF  p-ind-event = "ADD" 
AND c-char = "v36in172.w" THEN DO:
    
    ASSIGN wh-label-ncmipi-cd0204:VISIBLE = YES
           wh-label-ncmipi-cd0204:SCREEN-VALUE = "NCMIPI:"
           wh-ncmipi-cd0204:SCREEN-VALUE = "0".

    ASSIGN wh-label-preco-base-cd0204:VISIBLE = YES
           wh-label-preco-base-cd0204:SCREEN-VALUE = "Pre‡o Base:"
           wh-preco-base-cd0204:SCREEN-VALUE = "0".

    ASSIGN wh-label-preco-ul-ent-cd0204:VISIBLE = YES
           wh-label-preco-ul-ent-cd0204:SCREEN-VALUE = "Pre‡o Ult. Ent.:"
           wh-preco-ul-ent-cd0204:SCREEN-VALUE = "0".

    RUN select-page IN wgh-handle-container-cd0204 (INPUT 3).
    RUN select-page IN wgh-handle-container-cd0204 (INPUT 1).

END.

IF  (p-ind-event = "enable" OR p-ind-event = "after-enable") 
AND valid-handle(wh-it-codigo-cd0204) 
AND wh-it-codigo-cd0204:SENSITIVE = TRUE 
AND c-char = "v36in172.w" THEN DO:

    IF VALID-HANDLE(wh-ncmipi-cd0204) THEN
       ASSIGN wh-ncmipi-cd0204:SENSITIVE       = TRUE
              wh-preco-base-cd0204:SENSITIVE   = TRUE
              wh-preco-ul-ent-cd0204:SENSITIVE = TRUE.

    ASSIGN wh-ncmipi-cd0204:SCREEN-VALUE = "0".
END. 

if  p-ind-event = "INITIALIZE" 
and c-char = "v35in172.w" then do:

    assign wh-objeto = p-wgh-frame:first-child 
           wh-objeto = wh-objeto:first-child.

    do while valid-handle(wh-objeto):
        
        IF wh-objeto:TYPE = "field-group" THEN
            assign wh-objeto = wh-objeto:FIRST-CHILD.
        ELSE
            ASSIGN wh-objeto = wh-objeto:next-sibling.
    END.
END.

IF  p-ind-event  = "assign" 
AND p-ind-object = "viewer"
AND c-char       = "v36in172.w" THEN DO:

    IF wh-preco-base-cd0204:SCREEN-VALUE = "0,0000" THEN DO:
       RUN select-page IN wgh-handle-container-cd0204 (INPUT 3).
       RUN select-page IN wgh-handle-container-cd0204 (INPUT 2).
       MESSAGE "Pre‡o Base deve ser diferente de zero."
               VIEW-AS ALERT-BOX ERROR BUTTONS OK.    
       ASSIGN wh-preco-base-cd0204:SENSITIVE   = TRUE
              wh-preco-ul-ent-cd0204:SENSITIVE = TRUE.
       RETURN "NOK".
    END.

    IF wh-preco-ul-ent-cd0204:SCREEN-VALUE = "0,0000" THEN DO:       
       RUN select-page IN wgh-handle-container-cd0204 (INPUT 3).
       RUN select-page IN wgh-handle-container-cd0204 (INPUT 2).
       MESSAGE "Pre‡o Ultima Entrada deve ser diferente de zero."
               VIEW-AS ALERT-BOX ERROR BUTTONS OK.
       ASSIGN wh-preco-base-cd0204:SENSITIVE   = TRUE
              wh-preco-ul-ent-cd0204:SENSITIVE = TRUE.
       RETURN "NOK".
    END.

    FIND FIRST ITEM NO-LOCK WHERE ROWID(ITEM) = p-row-table NO-ERROR.
    IF AVAIL ITEM THEN DO:
       FIND FIRST b-item-uni-estab WHERE
                  b-item-uni-estab.it-codigo = ITEM.it-codigo NO-LOCK NO-ERROR.
       IF AVAIL b-item-uni-estab THEN DO:
          FOR EACH item-uni-estab USE-INDEX codigo WHERE
                   item-uni-estab.it-codigo = ITEM.it-codigo:
              ASSIGN item-uni-estab.preco-base   = DEC(wh-preco-base-cd0204:SCREEN-VALUE)
                     item-uni-estab.preco-ul-ent = DEC(wh-preco-ul-ent-cd0204:SCREEN-VALUE)
                     item-uni-estab.data-base    = TODAY
                     item-uni-estab.data-ult-ent = TODAY.

              FIND FIRST tt-preco-cd0204 WHERE
                         tt-preco-cd0204.it-codigo = ITEM.it-codigo NO-ERROR.
              IF NOT AVAIL tt-preco-cd0204 THEN DO: 
                 CREATE tt-preco-cd0204.
                 ASSIGN tt-preco-cd0204.it-codigo-cd0204 = ITEM.it-codigo. 
              END.
              ASSIGN tt-preco-cd0204.preco-base-cd0204   = DEC(wh-preco-base-cd0204:SCREEN-VALUE)    
                     tt-preco-cd0204.preco-ul-ent-cd0204 = DEC(wh-preco-ul-ent-cd0204:SCREEN-VALUE). 
          END.
       END.
       ELSE DO:
           EMPTY TEMP-TABLE tt-estabel.
           FOR EACH fam-uni-estab WHERE
                    fam-uni-estab.fm-codigo = item.fm-codigo NO-LOCK:
               FOR EACH estabelec WHERE 
                        estabelec.cod-estabel = fam-uni-estab.cod-estabel NO-LOCK:
                   IF estabelec.log-1 = NO THEN DO:
                      CREATE tt-estabel.
                      BUFFER-COPY estabelec TO tt-estabel.
                   END.
               END.
           END.
                
           FOR EACH tt-estabel:   
               FIND FIRST fam-uni-estab WHERE
                          fam-uni-estab.fm-codigo   = ITEM.fm-codigo AND
                          fam-uni-estab.cod-estabel = tt-estabel.cod-estabel NO-LOCK NO-ERROR.                      
               FIND FIRST estabelec WHERE 
                          estabelec.cod-estabel = fam-uni-estab.cod-estabel NO-LOCK NO-ERROR. 
               FIND FIRST lin-prod WHERE 
                          lin-prod.cod-estabel = estabelec.cod-estabel NO-LOCK NO-ERROR.
               IF NOT CAN-FIND (item-uni-estab WHERE
                                item-uni-estab.it-codigo   = item.it-codigo AND
                                item-uni-estab.cod-estabel = tt-estabel.cod-estabel) THEN DO:
                  CREATE item-uni-estab.
                  BUFFER-COPY item EXCEPT char-1 char-2 cod-estabel TO item-uni-estab.
                  ASSIGN item-uni-estab.cod-estabel          = estabelec.cod-estabel
                         item-uni-estab.deposito-pad         = fam-uni-estab.deposito-pad
                         item-uni-estab.cd-planejado         = IF AVAIL lin-prod
                                                               THEN lin-prod.cd-planejado
                                                               ELSE item.cd-planejado
                         item-uni-estab.cod-localiz          = fam-uni-estab.cod-localiz
                         SUBSTR(item-uni-estab.char-1,10,1)  = IF INTEGER(SUBSTRING(item.char-1,10,1)) <> 0
                                                               THEN SUBSTRING(item.char-1,10,1)
                                                               ELSE "1"
                         SUBSTR(item-uni-estab.char-1,129,3) = SUBSTRING(item.char-1,129,3)
                         item-uni-estab.horiz-fixo           = ITEM.horiz-fixo                                                                          
                         SUBSTR(item-uni-estab.char-1,132,1) = SUBSTRING(item.char-1,132,1)
                         item-uni-estab.qt-min-res-fabr      = DECIMAL(SUBSTRING(item.char-1,20,12))
                         item-uni-estab.var-tempo-res-fabr   = INTEGER(SUBSTRING(item.char-1,15,4))
                         item-uni-estab.var-qtd-res-fabr     = DECIMAL(SUBSTRING(item.char-1,35,12))
                         item-uni-estab.nr-linha             = fam-uni-estab.nr-linha
                         item-uni-estab.int-1                = IF item-uni-estab.cod-estabel = item.cod-estabel
                                                               THEN 0
                                                               ELSE 1
                         item-uni-estab.preco-base           = DEC(wh-preco-base-cd0204:SCREEN-VALUE)  
                         item-uni-estab.preco-ul-ent         = DEC(wh-preco-ul-ent-cd0204:SCREEN-VALUE)
                         item-uni-estab.data-base            = TODAY                              
                         item-uni-estab.data-ult-ent         = TODAY.                             

                  FIND FIRST tt-preco-cd0204 WHERE
                             tt-preco-cd0204.it-codigo = ITEM.it-codigo NO-ERROR.
                  IF NOT AVAIL tt-preco-cd0204 THEN DO: 
                     CREATE tt-preco-cd0204.
                     ASSIGN tt-preco-cd0204.it-codigo-cd0204 = ITEM.it-codigo. 
                  END.
                  ASSIGN tt-preco-cd0204.preco-base-cd0204   = DEC(wh-preco-base-cd0204:SCREEN-VALUE)    
                         tt-preco-cd0204.preco-ul-ent-cd0204 = DEC(wh-preco-ul-ent-cd0204:SCREEN-VALUE). 

                  FIND FIRST item-man WHERE
                             item-man.it-codigo = item.it-codigo NO-LOCK NO-ERROR.                   
                  IF AVAIL item-man THEN
                     ASSIGN item-uni-estab.ind-lista-mrp = item-man.ind-lista-mrp                          
                            item-uni-estab.ind-lista-csp = item-man.ind-lista-csp.

                  if avail item-uni-estab then do:
                     find FIRST item-mat where 
                                item-mat.it-codigo = item-uni-estab.it-codigo no-lock no-error.
                     if avail item-mat then do:
                        IF item-mat.prioridade-aprov > 0 AND 
                           item-mat.prioridade-aprov < 5 THEN
                           ASSIGN item-uni-estab.prioridade-aprov = item-mat.prioridade-aprov.
                        ELSE DO:
                           IF item-mat.prioridade-aprov >= 0  AND         
                              item-mat.prioridade-aprov <= 300 THEN        
                              ASSIGN item-uni-estab.prioridade-aprov = 4.         
                           ELSE IF item-mat.prioridade-aprov >  300 AND    
                                   item-mat.prioridade-aprov <= 600 THEN   
                                   ASSIGN item-uni-estab.prioridade-aprov = 3.        
                                ELSE IF item-mat.prioridade-aprov > 600 AND    
                                        item-mat.prioridade-aprov < 999 THEN   
                                         ASSIGN item-uni-estab.prioridade-aprov = 2.         
                                     ELSE                                              
                                         ASSIGN item-uni-estab.prioridade-aprov = 1.  
                        END.
                        assign item-uni-estab.variacao-perm    = item-mat.variacao-perm
                               item-uni-estab.deposito-cq      = item-mat.deposito-cq
                               item-uni-estab.cod-estab-gestor = item-mat.cod-estab-gestor
                               item-uni-estab.altera-conta     = item-mat.altera-conta
                               item-uni-estab.cd-freq          = item-mat.cd-freq
                               item-uni-estab.cod-fat-ponder   = item-mat.cod-fat-ponder                                 
                               item-uni-estab.cod-grp-compra   = item-mat.cod-grp-compra                                 
                               item-uni-estab.crit-cc          = item-mat.crit-cc                               
                               item-uni-estab.crit-ce          = item-mat.crit-ce
                               item-uni-estab.data-ult-ressup  = item-mat.data-ult-ressup
                               item-uni-estab.ind-cons-prv     = item-mat.ind-cons-prv
                               item-uni-estab.lote-per-max     = item-mat.lote-per-max
                               item-uni-estab.ponto-encomenda  = item-mat.ponto-encomenda                 
                               item-uni-estab.tp-ressup        = item-mat.tp-ressup
                               item-uni-estab.var-qtd-re       = item-mat.var-qtd-re                      
                               item-uni-estab.var-val-re-maior = item-mat.var-val-re-maior
                               item-uni-estab.var-val-re-menor = item-mat.var-val-re-menor
                               item-uni-estab.dep-rej-cq       = item-mat.dep-rej-cq      
                               item-uni-estab.lim-var-qtd      = item-mat.lim-var-qtd     
                               item-uni-estab.lim-var-valor    = item-mat.lim-var-valor.
            
                        do i-vetor-item-mat = 1 to 12:
                           assign item-uni-estab.fator-ponder[i-vetor-item-mat] = item-mat.fator-ponder[i-vetor-item-mat].
                        end. 
                     END.
                  end.
               END.
           END.
       END.
    END.
END.

IF  p-ind-event  = "after-cancel" 
AND p-ind-object = "viewer"
AND c-char       = "v36in172.w" THEN DO:
    FOR EACH tt-preco-cd0204:
        FOR EACH item-uni-estab USE-INDEX codigo WHERE
                 item-uni-estab.it-codigo = tt-preco-cd0204.it-codigo-cd0204:
            ASSIGN item-uni-estab.preco-base   = tt-preco-cd0204.preco-base-cd0204
                   item-uni-estab.preco-ul-ent = tt-preco-cd0204.preco-ul-ent-cd0204
                   item-uni-estab.data-base    = TODAY
                   item-uni-estab.data-ult-ent = TODAY.
        END.
    END.
END.

IF  p-ind-event  = "change-page" 
AND p-ind-object = "container" THEN DO: 
    FOR EACH tt-preco-cd0204:
        FOR EACH item-uni-estab USE-INDEX codigo WHERE
                 item-uni-estab.it-codigo = tt-preco-cd0204.it-codigo-cd0204:
            ASSIGN item-uni-estab.preco-base   = tt-preco-cd0204.preco-base-cd0204
                   item-uni-estab.preco-ul-ent = tt-preco-cd0204.preco-ul-ent-cd0204
                   item-uni-estab.data-base    = TODAY
                   item-uni-estab.data-ult-ent = TODAY.
        END.
    END.
END.

IF  p-ind-event  = "destroy" 
AND p-ind-object = "container"
AND c-char       = "cd0204.w" THEN DO:
    EMPTY TEMP-TABLE tt-preco-cd0204.
END.

RETURN "OK".

 
