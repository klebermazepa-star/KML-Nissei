/*******************************************************************************
**  Programa.: upc-cn0302.p	- UPC programa Manutená∆o de Contratos
**  
**  Descriá∆o: upc no bot∆o Liberar para criar registro no esre1001
*********************************************************************************/

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        AS rowid         no-undo.
DEFINE VARIABLE da-data-venc       AS DATE        NO-UNDO.



def new global shared var wh-nar-item-cn0302        as widget-handle no-undo.
def new global shared var wh-bt-liberar-cn0302      as widget-handle no-undo.
def new global shared var wh-bt-liberar-cn0302-new  as widget-handle no-undo.
def new global shared var wh-gbr-table-cn0302       as widget-handle no-undo.
def new global shared var wh-dt-valid-cn0302        as widget-handle no-undo.
def new global shared var wh-num-seq-item-cn0302    as widget-handle no-undo. 
def new global shared var wh-num-seq-event-cn0302   as widget-handle no-undo. 
def new global shared var wh-num-seq-medicao-cn0302 as widget-handle no-undo. 

DEFINE VARIABLE i-cont AS INTEGER       NO-UNDO.
DEFINE VARIABLE hAux   AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE c-mes-contrato AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-ano-contrato AS CHARACTER   NO-UNDO.

def new global shared var r-seq-medicao      AS ROWID       NO-UNDO.
def new global shared var r-seq-ordem-compra AS ROWID       NO-UNDO.


DEFINE BUFFER bf-es-contrato-docum FOR es-contrato-docum.
DEFINE BUFFER bf-es-contrato-docum-dup FOR es-contrato-docum-dup.

{utp/ut-glob.i}


/*MESSAGE p-ind-event              "p-ind-event  " skip
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
 VIEW-AS ALERT-BOX INFO BUTTONS OK.*/


IF p-ind-event  = "AFTER-VALUE-CHANGED" AND  
   p-ind-object = "BROWSER"          THEN DO:  

    IF p-row-table <> ? THEN DO:
        ASSIGN r-seq-medicao = p-row-table.
    END.

END.

IF p-ind-event  = "BEFORE-DISPLAY" AND  
   p-ind-object = "VIEWER"          THEN DO:  

    RUN utils/findWidget.p (INPUT  'bt-liberar',   
                            INPUT  'BUTTON',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-bt-liberar-cn0302).
    if valid-handle (wh-bt-liberar-cn0302) then DO:
    
        CREATE BUTTON wh-bt-liberar-cn0302-new
        ASSIGN FRAME     = wh-bt-liberar-cn0302:FRAME
              WIDTH     = wh-bt-liberar-cn0302:WIDTH
              HEIGHT    = wh-bt-liberar-cn0302:HEIGHT
              LABEL     = wh-bt-liberar-cn0302:LABEL
              ROW       = wh-bt-liberar-cn0302:ROW
              COL       = wh-bt-liberar-cn0302:COL
              VISIBLE   = wh-bt-liberar-cn0302:VISIBLE
              SENSITIVE = wh-bt-liberar-cn0302:SENSITIVE
              Name      = "wh-bt-liberar-cn0302"
              TRIGGERS:
                  ON CHOOSE PERSISTENT RUN intupc/upc-cn0302.r  (INPUT "choose",
                                                                 INPUT "Botao_Gera_Falso",
                                                                 INPUT wh-bt-liberar-cn0302-new,
                                                                 INPUT p-wgh-frame,
                                                                 INPUT p-cod-table,
                                                                 INPUT p-row-table).
              END TRIGGERS.
    END.

    IF p-row-table <> ? THEN
        ASSIGN r-seq-ordem-compra = p-row-table.

END.

IF p-ind-event  = "BEFORE-INITIALIZE" AND  
   p-ind-object = "BROWSER"         THEN DO:  

    RUN utils/findWidget.p (INPUT  'gbr-table',   
                            INPUT  'BROWSE',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-gbr-table-cn0302).

    IF VALID-HANDLE(wh-gbr-table-cn0302) THEN DO:
        DO i-cont = 1 TO wh-gbr-table-cn0302:NUM-COLUMN:
           ASSIGN hAux = wh-gbr-table-cn0302:GET-BROWSE-COLUMN(i-cont).
           /* Buscar do handle dos demais campos do browse - implementar com os campos disponiveis no CC0311 */
           IF TRIM(hAux:NAME) = "num-seq-item" THEN
               ASSIGN wh-num-seq-item-cn0302 = hAux:BUFFER-FIELD().
           IF TRIM(hAux:NAME) = "num-seq-event" THEN
               ASSIGN wh-num-seq-event-cn0302 = hAux:BUFFER-FIELD().
           IF TRIM(hAux:NAME) = "num-seq-medicao" THEN
               ASSIGN wh-num-seq-medicao-cn0302 = hAux:BUFFER-FIELD().
        END.

        wh-dt-valid-cn0302 = wh-gbr-table-cn0302:ADD-CALC-COLUMN("DATE", "99/99/9999" , "" , "Dt. Valid", 4).
        wh-dt-valid-cn0302:COLUMN-READ-ONLY = YES.
        wh-dt-valid-cn0302:WIDTH            = 8.
        wh-dt-valid-cn0302:READ-ONLY        = YES.

        ON ROW-DISPLAY OF wh-gbr-table-cn0302 PERSISTENT RUN intupc/upc-cn0302-browse.p.
    END.

END.

DEFINE VARIABLE i-parcelas AS INTEGER     NO-UNDO.
DEFINE VARIABLE l-result   AS LOGICAL     NO-UNDO.

DEFINE VARIABLE dt-periodo-aux AS DATE        NO-UNDO.
DEFINE VARIABLE i-dias-venc    AS INT         NO-UNDO.
DEFINE VARIABLE dt-aux         AS DATE        NO-UNDO.
DEFINE VARIABLE i-seq-aux      AS INTEGER     NO-UNDO.
DEFINE VARIABLE i-parcela      AS INTEGER     NO-UNDO.


IF p-ind-event  = "choose" AND
   p-ind-object = "Botao_Gera_Falso" 
    THEN DO:

    /*MESSAGE "Deseja gerar dados de contrato de aluguel"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE "" UPDATE l-result AS LOGICAL.*/

    RUN pi-pergunta(OUTPUT i-parcelas,
                    OUTPUT l-result).

    IF l-result THEN DO: /* YES */ 

        FIND FIRST medicao-contrat NO-LOCK
            WHERE ROWID(medicao-contrat) = r-seq-medicao NO-ERROR.


        IF AVAIL medicao-contrat THEN DO:

            FIND FIRST ordem-compra NO-LOCK
                WHERE ordem-compra.numero-ordem = medicao-contrat.numero-ordem
                  AND ordem-compra.nr-contrato  = medicao-contrat.nr-contrato NO-ERROR.

            FIND FIRST ITEM NO-LOCK
                WHERE ITEM.it-codigo = ordem-compra.it-codigo NO-ERROR.

            FIND LAST bf-es-contrato-docum USE-INDEX idx-1 NO-LOCK NO-ERROR.

            FOR FIRST es-contrato-for NO-LOCK
                WHERE es-contrato-for.nr-contrato = medicao-contrat.nr-contrato: END.

            IF ordem-compra.it-codigo <> "cont.007"     AND 
               ordem-compra.it-codigo <> "cont.0070"    AND 
               ordem-compra.it-codigo <> "cont.001"     AND 
               ordem-compra.it-codigo <> "cont.002"     AND 
               ordem-compra.it-codigo <> "cont.003"     AND 
               ordem-compra.it-codigo <> "cont.004"     AND 
               ordem-compra.it-codigo <> "cont.005" THEN LEAVE.
               
               
            FIND FIRST  es-contrato-docum NO-LOCK
                WHERE es-contrato-docum.nr-contrato     = medicao-contrat.nr-contrato 
                  AND es-contrato-docum.dt-periodo      = dt-periodo-aux NO-ERROR.
                
                
            IF NOT AVAIL es-contrato-docum THEN DO:                
            
            
                CREATE es-contrato-docum.
                ASSIGN es-contrato-docum.sequencia      = IF AVAIL bf-es-contrato-docum THEN bf-es-contrato-docum.sequencia + 1 ELSE 1  
                       es-contrato-docum.num-pedido     = ordem-compra.num-pedido  
                       es-contrato-docum.nr-contrato    = medicao-contrat.nr-contrato  
                       es-contrato-docum.cod-emitente   = ordem-compra.cod-emitente  
                       es-contrato-docum.serie-docto    = "001"   
                       es-contrato-docum.nat-operacao   = "1949x3"   
                       es-contrato-docum.cod-estabel    = ordem-compra.cod-estabel   
                       es-contrato-docum.nro-docto      = ordem-compra.cod-estabel + STRING(MONTH(TODAY),"99") + SUBstring(STRING(YEAR(TODAY)),3,2) 
                       es-contrato-docum.it-codigo      = ordem-compra.it-codigo   
                       es-contrato-docum.numero-ordem   = medicao-contrat.numero-ordem   
                       es-contrato-docum.qt-do-forn     = 1  
                       es-contrato-docum.un             = ITEM.un    
                       es-contrato-docum.quantidade     = 1   
                       es-contrato-docum.preco-unit     = medicao-contrat.val-medicao    
                       es-contrato-docum.preco-total    = medicao-contrat.val-medicao
                       es-contrato-docum.dt-periodo     = DATE( "01/" + string(MONTH(medicao-contrat.dat-prev-medicao), "99") + "/" + string(YEAR(medicao-contrat.dat-prev-medicao), "9999")) 
                       es-contrato-docum.dt-inclusao    = TODAY.


                ASSIGN da-data-venc = ?.

                FOR FIRST es-medicao-contrat NO-LOCK
                    WHERE es-medicao-contrat.nr-contrato     = ordem-compra.nr-contrato
                    AND   es-medicao-contrat.num-seq-item    = medicao-contrat.num-seq-item
                    AND   es-medicao-contrat.numero-ordem    = ordem-compra.numero-ordem
                    AND   es-medicao-contrat.num-seq-event   = medicao-contrat.num-seq-event
                    AND   es-medicao-contrat.num-seq-medicao = medicao-contrat.num-seq-medicao:
                    ASSIGN da-data-venc = es-medicao-contrat.dt-valid.
                END.


                FIND LAST bf-es-contrato-docum-dup USE-INDEX idx-1
                    WHERE bf-es-contrato-docum-dup.sequencia      = es-contrato-docum.sequencia    
                     NO-LOCK NO-ERROR.

                IF AVAIL bf-es-contrato-docum-dup THEN
                    ASSIGN i-parcela = bf-es-contrato-docum-dup.seq-dup + 1.
                ELSE 
                    ASSIGN i-parcela = 1.

                CREATE es-contrato-docum-dup.
                ASSIGN es-contrato-docum-dup.sequencia      = es-contrato-docum.sequencia    
                       es-contrato-docum-dup.seq-dup        = i-parcela
                       es-contrato-docum-dup.parcela        = STRING(i-parcela)
                       es-contrato-docum-dup.nr-duplic      = es-contrato-docum.nro-docto
                       es-contrato-docum-dup.cod-esp        = IF AVAIL es-contrato-for THEN es-contrato-for.cod-esp ELSE "NC"
                       es-contrato-docum-dup.tp-despesa     = IF AVAIL es-contrato-for THEN es-contrato-for.tp-desp ELSE 399
                       es-contrato-docum-dup.dt-emissao     = medicao-contrat.dat-prev-medicao
                       es-contrato-docum-dup.dt-trans       = medicao-contrat.dat-prev-medicao 
                       es-contrato-docum-dup.dt-vencim      = da-data-venc
                       es-contrato-docum-dup.vl-a-pagar     = medicao-contrat.val-medicao
                       es-contrato-docum-dup.desconto       = 0
                       es-contrato-docum-dup.vl-desconto    = 0
                       es-contrato-docum-dup.dt-venc-desc   = ?.

                ASSIGN dt-periodo-aux = es-contrato-docum.dt-periodo
                       i-seq-aux      = es-contrato-docum.sequencia.

                RELEASE es-contrato-docum.
                RELEASE es-contrato-docum-dup.

            END.
            
            IF i-parcelas > 0 THEN DO i-cont = 1 TO i-parcelas:
               
                IF MONTH(dt-periodo-aux) = 12 THEN

                    ASSIGN dt-periodo-aux = DATE(1, 1, YEAR(dt-periodo-aux) + 1).
                ELSE
                    ASSIGN dt-periodo-aux = DATE(MONTH(dt-periodo-aux) + 1, 1, YEAR(dt-periodo-aux)).

                ASSIGN i-seq-aux = i-seq-aux + 1.

                
                FIND FIRST  es-contrato-docum NO-LOCK
                    WHERE es-contrato-docum.nr-contrato = medicao-contrat.nr-contrato 
                      AND es-contrato-docum.dt-periodo     = dt-periodo-aux NO-ERROR.
                
                
                IF NOT AVAIL es-contrato-docum THEN DO:  

                    CREATE es-contrato-docum.
                    ASSIGN es-contrato-docum.sequencia      = i-seq-aux
                           es-contrato-docum.num-pedido     = ordem-compra.num-pedido  
                           es-contrato-docum.nr-contrato    = medicao-contrat.nr-contrato  
                           es-contrato-docum.cod-emitente   = ordem-compra.cod-emitente  
                           es-contrato-docum.serie-docto    = "001"   
                           es-contrato-docum.nat-operacao   = "1949x3"   
                           es-contrato-docum.cod-estabel    = ordem-compra.cod-estabel   
                           es-contrato-docum.nro-docto      = ordem-compra.cod-estabel + STRING(MONTH(dt-periodo-aux),"99") + SUBstring(STRING(YEAR(dt-periodo-aux)),3,2) 
                           es-contrato-docum.it-codigo      = ordem-compra.it-codigo   
                           es-contrato-docum.numero-ordem   = medicao-contrat.numero-ordem   
                           es-contrato-docum.qt-do-forn     = 1  
                           es-contrato-docum.un             = ITEM.un    
                           es-contrato-docum.quantidade     = 1   
                           es-contrato-docum.preco-unit     = medicao-contrat.val-medicao    
                           es-contrato-docum.preco-total    = medicao-contrat.val-medicao
                           es-contrato-docum.dt-periodo     = dt-periodo-aux
                           es-contrato-docum.dt-inclusao    = dt-periodo-aux.


        
                    /*  criar duplicata  */ 


    /*                 IF MONTH(dt-periodo-aux) = 12 THEN                                                                          */
    /*                     ASSIGN dt-aux = DATE(MONTH(dt-periodo-aux),DAY(medicao-contrat.dat-prev-medicao),YEAR(dt-periodo-aux)). */
    /*                 ELSE                                                                                                        */
                           
                    ASSIGN dt-aux = DATE(MONTH(dt-periodo-aux),DAY(medicao-contrat.dat-prev-medicao),YEAR(dt-periodo-aux)).
         

                    IF MONTH(da-data-venc) = 12 THEN
                         ASSIGN da-data-venc = DATE(1,DAY(da-data-venc),YEAR(da-data-venc) + 1).  
                    ELSE
                         ASSIGN da-data-venc = DATE(MONTH(da-data-venc) + 1,DAY(da-data-venc),YEAR(da-data-venc)).                 

                    RUN pi-verifica-dia(INPUT  dt-aux,
                                        INPUT  ordem-compra.cod-estabel,
                                        OUTPUT dt-aux).

                    RUN pi-verifica-dia(INPUT  da-data-venc,
                                        INPUT  ordem-compra.cod-estabel,
                                        OUTPUT da-data-venc).
        
                    /* KML - 07/08/2023 - Corrigido sequencia da duplicata  */

                    FIND LAST bf-es-contrato-docum-dup USE-INDEX idx-1
                        WHERE bf-es-contrato-docum-dup.sequencia      = es-contrato-docum.sequencia    
                         NO-LOCK NO-ERROR.

                    IF AVAIL bf-es-contrato-docum-dup THEN
                        ASSIGN i-parcela = bf-es-contrato-docum-dup.seq-dup + 1.
                    ELSE 
                        ASSIGN i-parcela = 1.

                    CREATE es-contrato-docum-dup.
                    ASSIGN es-contrato-docum-dup.sequencia      = es-contrato-docum.sequencia
                           es-contrato-docum-dup.seq-dup        = i-parcela
                           es-contrato-docum-dup.parcela        = STRING(i-parcela)
                           es-contrato-docum-dup.nr-duplic      = es-contrato-docum.nro-docto
                           es-contrato-docum-dup.cod-esp        = IF AVAIL es-contrato-for THEN es-contrato-for.cod-esp ELSE "NC"
                           es-contrato-docum-dup.tp-despesa     = IF AVAIL es-contrato-for THEN es-contrato-for.tp-desp ELSE 399 
                           es-contrato-docum-dup.dt-emissao     = dt-aux 
                           es-contrato-docum-dup.dt-trans       = dt-aux 
                           es-contrato-docum-dup.dt-vencim      = da-data-venc
                           es-contrato-docum-dup.vl-a-pagar     = medicao-contrat.val-medicao
                           es-contrato-docum-dup.desconto       = 0
                           es-contrato-docum-dup.vl-desconto    = 0
                           es-contrato-docum-dup.dt-venc-desc   = ?.

                    RELEASE es-contrato-docum.
                    RELEASE es-contrato-docum-dup.
                    
                END.

            END.

        END.
    END.

    // Roda bot∆o padr∆o ap¢s especifico
    APPLY "choose" TO wh-bt-liberar-cn0302 .
END.

RETURN "OK".
  
procedure pi-verifica-dia:
 
    def input  param p-data          as date no-undo.
    def input  param p-cod-estabel   as char no-undo.
    def output param p-data-nova     as date no-undo.
 
    find first calen-coml
         where calen-coml.ep-codigo   = "1"
         AND   calen-coml.cod-estabel = p-cod-estabel
         and   calen-coml.data        = p-data
         no-lock no-error.
    if  avail calen-coml then do:
 
        if  calen-coml.tipo-dia = 1 then
            assign p-data-nova = p-data.
        else do:
            assign p-data = p-data + 1.
 
            run pi-verifica-dia (input p-data,
                                 input p-cod-estabel,
                                 output p-data-nova).
        end.
    end.
    else
        assign p-data-nova = p-data.
 
end procedure.

PROCEDURE pi-pergunta:
/*------------------------------------------------------------------------------
  Purpose:     Exibe dialog de Vò Para
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER p-parcelas AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER l-ok       AS LOGICAL     NO-UNDO.

    ASSIGN l-ok = NO.

    DEFINE RECTANGLE rtFrame
         EDGE-PIXELS 2 GRAPHIC-EDGE  
         SIZE 58 BY 1.62
         BGCOLOR 8.

    DEFINE BUTTON btGoToCancel AUTO-END-KEY 
         LABEL "&Cancelar" 
         SIZE 10 BY 1
         BGCOLOR 8.

    DEFINE BUTTON btGoToOK AUTO-GO 
         LABEL "&OK" 
         SIZE 10 BY 1
         BGCOLOR 8.

    DEFINE RECTANGLE rtGoToButton
         EDGE-PIXELS 2 GRAPHIC-EDGE  
         SIZE 58 BY 1.42
         BGCOLOR 7.

    DEFINE VARIABLE rGoTo AS ROWID NO-UNDO.

    DEFINE VARIABLE i-parcelas AS INTEGER NO-UNDO.

    DEFINE FRAME fGoToRecord
        rtFrame        AT ROW 1.00 COL 1
        i-parcelas     FORMAT ">>9" LABEL "Meses subsequentes" AT ROW 1.40 COL 24.00 COLON-ALIGNED
        btGoToOK       AT ROW 3.03 COL 2.14
        btGoToCancel   AT ROW 3.03 COL 13
        rtGoToButton   AT ROW 2.78 COL 1
        SPACE(0.28)
        WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE 
             THREE-D SCROLLABLE TITLE "Deseja gerar dados de contrato de aluguel?" FONT 1
             DEFAULT-BUTTON btGoToOK CANCEL-BUTTON btGoToCancel.

    RUN utp/ut-trfrrp.p (input Frame fGoToRecord:Handle).
    //{utp/ut-liter.i "Vò_Para_Natureza_Operaªío"}
    //ASSIGN FRAME fGoToRecord:TITLE = RETURN-VALUE.

    ASSIGN i-parcelas = 0.
    assign i-parcelas:width in frame fGoToRecord = 4.

    DISP i-parcelas
        WITH FRAME fGoToRecord. 
    
    ON  "CHOOSE":U OF btGoToOK IN FRAME fGoToRecord DO:
        ASSIGN i-parcelas.

        ASSIGN l-ok       = YES
               p-parcelas = i-parcelas.

        APPLY "GO":U TO FRAME fGoToRecord.
    END.

    ENABLE i-parcelas btGoToOK btGoToCancel 
           WITH FRAME fGoToRecord. 

    WAIT-FOR "GO":U OF FRAME fGoToRecord.

END PROCEDURE.
