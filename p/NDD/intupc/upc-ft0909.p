def input param p-ind-event  as char          no-undo.
def input param p-ind-object as char          no-undo.
def input param p-wgh-object as handle        no-undo.
def input param p-wgh-frame  as widget-handle no-undo.
def input param p-cod-table  as char          no-undo.
def input param p-row-table  as rowid         no-undo.

DEFINE NEW GLOBAL SHARED VARIABLE gc-NFe-nfs-a-cancelar   AS CHAR NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE gc-NFe-nfs-a-inutilizar AS CHAR NO-UNDO.

DEFINE NEW GLOBAL SHARED VARIABLE ft0909-cancelar   AS LOGICAL NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE ft0909-inutilizar AS LOGICAL NO-UNDO.

def new global shared var h-ft0909-btInutilizar     as widget-handle no-undo. 
def new global shared var h-ft0909-btCancelar       as widget-handle no-undo. 
def new global shared var h-ft0909-btAtualiza       as widget-handle no-undo.
def new global shared var h-ft0909-btEnviar         as widget-handle no-undo.
def new global shared var h-ft0909-bt-atualiza      AS handle        no-undo.
DEF NEW GLOBAL SHARED VAR h-ver-xml                 AS handle        no-undo.
DEF NEW GLOBAL SHARED VAR h-browse                  AS handle        no-undo.
DEF NEW GLOBAL SHARED VAR h-buffer                  AS HANDLE        no-undo.
DEF NEW GLOBAL SHARED VAR h-query                   AS handle        no-undo.
DEFINE VARIABLE situacao AS CHARACTER INITIAL "Documento Nao Gerado,Em Processamento no Aplicativo de Transmiss∆o(em processo no EAI),Uso Autorizado,Uso Denegado,Documento Rejeitado,Documento Cancelado,Documento Inutilizado,Em processamento no aplicativo de transmissao,Em processamento na SEFAZ,Em processamento no SCAN,NF-e Gerada,NF-e em Processamento de Cancelamento,Nf-e em processo de inutilizacao,Nf-e pendente de retorno,DPEC recebido pelo SCE"  NO-UNDO.

DEFINE VARIABLE i       AS INTEGER      NO-UNDO.

def var c-objeto       as character     no-undo.
def var h_frame        as widget-handle no-undo.
def var h_campo        as widget-handle no-undo.

DEF VAR h-acomp    AS HANDLE  NO-UNDO.

assign c-objeto = entry(num-entries(p-wgh-object:private-data,"~/"),
                        p-wgh-object:private-data, "~/").

/*MESSAGE "Evento..........:" string(p-ind-event)    skip 
        "Objeto..........:" string(p-ind-object)   skip 
        "Handle do Objeto:" string(p-wgh-object)   skip 
        "Handle da Frame.:" string(p-wgh-frame)    skip 
        "Tabela..........:" p-cod-table            skip 
        "Rowid...........:" string(p-row-table)    skip 
        "p-wgh-object....:" p-wgh-object:file-name SKIP
        "c-objeto........:" c-objeto  SKIP
        "p-wgh-frame.....:" p-wgh-frame:NAME
    VIEW-AS ALERT-BOX.*/

/*****************************************************************************************************************/
IF p-ind-event = "AFTER-INITIALIZE" THEN DO :    
    
    RUN utils/findWidget.p (INPUT  'brNfe',
                            INPUT  'browse',
                            INPUT  p-wgh-frame,
                            OUTPUT h-browse).
    
    h-query  = h-browse:QUERY.
    h-buffer = h-query:GET-BUFFER-HANDLE(1).  

    CREATE BUTTON h-ver-xml
    ASSIGN FRAME     = p-wgh-frame
           WIDTH     = 10
           LABEL     = "Ver XML"
           HEIGHT    = 1
           ROW       = 6.7
           COL       = 122
           SENSITIVE = YES
           VISIBLE   = YES.
    ON 'CHOOSE' OF h-ver-xml PERSISTENT RUN intupc\upc-ft0909a.p.
    
    /*CREATE BUTTON h-ft0909-bt-atualiza
    ASSIGN FRAME     = p-wgh-frame
           WIDTH     = 10
           LABEL     = "Atualiza NF"
           HEIGHT    = 1
           ROW       = 6.7
           COL       = 110
           SENSITIVE = YES
           VISIBLE   = YES.

    ON 'CHOOSE' OF h-ft0909-bt-atualiza PERSISTENT RUN intupc/upc-ft0909.p (INPUT "CHOOSE", 
                                                                            INPUT "h-ft0909-bt-atualiza", 
                                                                            INPUT p-wgh-object, 
                                                                            INPUT p-wgh-frame:FRAME, 
                                                                            INPUT ?, 
                                                                            INPUT ?).*/

    IF NOT VALID-HANDLE (h-ft0909-btAtualiza) THEN do:
        RUN utils/findWidget.p (INPUT  'btAtualiza',
                                INPUT  'button',
                                INPUT  p-wgh-frame,
                                OUTPUT h-ft0909-btAtualiza).
    END.

    CREATE BUTTON h-ft0909-bt-atualiza
    ASSIGN FRAME     = p-wgh-frame
           WIDTH     = h-ft0909-btAtualiza:WIDTH
           LABEL     = "Atualiza NF"
           HEIGHT    = h-ft0909-btAtualiza:HEIGHT
           ROW       = h-ft0909-btAtualiza:ROW
           COL       = h-ft0909-btAtualiza:COL
           SENSITIVE = YES
           VISIBLE   = YES.

    ON 'CHOOSE' OF h-ft0909-bt-atualiza PERSISTENT RUN intupc/upc-ft0909.p (INPUT "CHOOSE", 
                                                                            INPUT "h-ft0909-bt-atualiza", 
                                                                            INPUT p-wgh-object, 
                                                                            INPUT p-wgh-frame:FRAME, 
                                                                            INPUT ?, 
                                                                            INPUT ?).

    h-ft0909-bt-atualiza:MOVE-TO-TOP().

    h-ft0909-bt-atualiza:LOAD-IMAGE-UP('image\im-relo.bmp').
    h-ft0909-bt-atualiza:LOAD-IMAGE-INSENSITIVE('image\ii-relo.bmp').

    h-ft0909-btAtualiza:HIDDEN = YES.
           
END.

/********************************************************************************************************/
if p-ind-event = "after-initialize" and
    p-ind-object = "container"  then do:

    if not valid-handle (h-ft0909-btAtualiza) THEN do:
        RUN utils/findWidget.p (INPUT  'btAtualiza',
                                INPUT  'button',
                                INPUT  p-wgh-frame,
                                OUTPUT h-ft0909-btAtualiza).
    end.
 
    if not valid-handle (h-ft0909-btEnviar) THEN do:
        RUN utils/findWidget.p (INPUT  'btEnviar',
                                INPUT  'button',
                                INPUT  p-wgh-frame,
                                OUTPUT h-ft0909-btEnviar).
    end.

    if not valid-handle (h-ft0909-btInutilizar) THEN do:
        RUN utils/findWidget.p (INPUT  'btInutilizar',
                                INPUT  'button',
                                INPUT  p-wgh-frame,
                                OUTPUT h-ft0909-btInutilizar).
    end.

    if not valid-handle (h-ft0909-btCancelar) THEN do:
        RUN utils/findWidget.p (INPUT  'btCancelar',
                                INPUT  'button',
                                INPUT  p-wgh-frame,
                                OUTPUT h-ft0909-btCancelar).
    end.

    IF valid-handle (h-ft0909-btInutilizar) THEN
       ON "mouse-move-down" OF h-ft0909-btInutilizar PERSISTENT RUN intupc/upc-ft0909.p (INPUT "mouse-move-down", 
                                                                                         INPUT "btInutilizar", 
                                                                                         INPUT p-wgh-object, 
                                                                                         INPUT p-wgh-frame:FRAME, 
                                                                                         INPUT ?, 
                                                                                         INPUT ?).
    IF valid-handle (h-ft0909-btCancelar) THEN
       
        ON "mouse-move-down" OF h-ft0909-btCancelar PERSISTENT RUN intupc/upc-ft0909.p (INPUT "mouse-move-down", 
                                                                                        INPUT "btCancelar", 
                                                                                        INPUT p-wgh-object, 
                                                                                        INPUT p-wgh-frame:FRAME, 
                                                                                        INPUT ?, 
                                                                                        INPUT ?).

        ON "mouse-move-down" OF h-ft0909-btEnviar PERSISTENT RUN intupc/upc-ft0909.p (INPUT "mouse-move-down", 
                                                                                      INPUT "btEnviar", 
                                                                                      INPUT p-wgh-object, 
                                                                                      INPUT p-wgh-frame:FRAME, 
                                                                                      INPUT ?, 
                                                                                      INPUT ?).
    
END.

/********************************************************************************************************/
IF p-ind-event  = "mouse-move-down"  AND p-ind-object = "btInutilizar" THEN DO:

   ASSIGN ft0909-cancelar   = NO 
          ft0909-inutilizar = yes .

   APPLY "CHOOSE":u TO h-ft0909-btInutilizar.

   //ASSIGN ft0909-cancelar   = NO 
   //       ft0909-inutilizar = NO .
END.

/********************************************************************************************************/
IF p-ind-event  = "mouse-move-down"  AND p-ind-object = "btCancelar" THEN DO:

   ASSIGN ft0909-cancelar   = YES
          ft0909-inutilizar = NO.

   APPLY "CHOOSE":u TO h-ft0909-btCancelar.

END.

/********************************************************************************************************/ 
IF p-ind-event  = "mouse-move-down"  AND p-ind-object = "btEnviar" THEN DO:

   FIND FIRST nota-fiscal NO-LOCK
        WHERE nota-fiscal.cod-estabel = trim(h-buffer:buffer-field(1):buffer-value)
          AND nota-fiscal.serie       = trim(h-buffer:buffer-field(2):buffer-value)
          AND nota-fiscal.nr-nota-fis = trim(h-buffer:buffer-field(3):buffer-value) NO-ERROR.
   IF AVAIL nota-fiscal THEN DO:

      FIND FIRST es-param-integracao-estab
           WHERE es-param-integracao-estab.cod-estabel =  nota-fiscal.cod-estabel 
           AND   es-param-integracao-estab.empresa-integracao = 2
           NO-LOCK NO-ERROR.

      IF AVAIL es-param-integracao-estab THEN DO:

         RUN int\wsinventti0002.p  (INPUT  ROWID(nota-fiscal)).
         
         RUN int\wsinventti0004.p  (input nota-fiscal.cod-estabel,
                                    input nota-fiscal.serie,      
                                    input nota-fiscal.nr-nota-fis).
      END.

   END.

   APPLY "CHOOSE":u TO h-ft0909-btEnviar.
   
END.

/********************************************************************************************************/
IF p-ind-event  = "CHOOSE"  AND p-ind-object = "h-ft0909-bt-atualiza" THEN DO:
    
    IF VALID-HANDLE(h-ft0909-btAtualiza) THEN APPLY "CHOOSE" TO h-ft0909-btAtualiza.

      run utp/ut-acomp.p persistent set h-acomp.
      run pi-inicializar in h-acomp (input "Integraá∆o Inventti").

    IF VALID-HANDLE(h-browse) THEN DO:

        h-query  = h-browse:QUERY.

        IF VALID-HANDLE(h-query) THEN DO:

            h-buffer = h-query:GET-BUFFER-HANDLE(1).

            IF VALID-HANDLE(h-buffer) THEN DO:
                
                h-query:GET-FIRST().

                DO WHILE h-buffer:AVAIL:

                    /*MESSAGE "BT-Atualiza-Fake" SKIP
                        "trim(h-buffer:buffer-field(1):buffer-value): " trim(h-buffer:buffer-field(1):buffer-value) SKIP
                        "trim(h-buffer:buffer-field(2):buffer-value): " trim(h-buffer:buffer-field(2):buffer-value) SKIP
                        "trim(h-buffer:buffer-field(3):buffer-value): " trim(h-buffer:buffer-field(3):buffer-value) SKIP
                        "trim(h-buffer:buffer-field(10):buffer-value): " trim(h-buffer:buffer-field(10):buffer-value) SKIP
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/

                    FIND FIRST nota-fiscal NO-LOCK
                         WHERE nota-fiscal.cod-estabel = trim(h-buffer:buffer-field(1):buffer-value)
                           AND nota-fiscal.serie       = trim(h-buffer:buffer-field(2):buffer-value)
                           AND nota-fiscal.nr-nota-fis = trim(h-buffer:buffer-field(3):buffer-value)NO-ERROR.
                    IF AVAIL nota-fiscal THEN DO:
                        
                        FIND FIRST es-param-integracao-estab NO-LOCK
                             WHERE es-param-integracao-estab.cod-estabel = nota-fiscal.cod-estabel 
                               AND es-param-integracao-estab.empresa-integracao = 2 NO-ERROR.
                        IF AVAIL es-param-integracao-estab THEN do:

                            /*MESSAGE "Situacao da NFe: " entry(nota-fiscal.idi-sit-nf-eletro, situacao)
                                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/

                            IF nota-fiscal.idi-sit-nf-eletro < 3 THEN DO:

                                RUN pi-acompanhar IN h-acomp(INPUT "NFE: " + nota-fiscal.cod-estabel + '_' + nota-fiscal.serie + '_' + nota-fiscal.nr-nota-fis).  


                                .MESSAGE "antes do 002" skip
                                        nota-fiscal.nr-nota-fis
                                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                            
                                RUN int\wsinventti0002.p  (INPUT ROWID(nota-fiscal)).

                                .MESSAGE "antes do 004"
                                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                         
                                RUN int\wsinventti0004.p (input nota-fiscal.cod-estabel,
                                                          input nota-fiscal.serie,      
                                                          input nota-fiscal.nr-nota-fis).

                            END.
                        END.
                    END.

                    h-query:GET-NEXT().
                END.
            END.
        END.
            
        //reabre o browser atualizado
        IF VALID-HANDLE(h-ft0909-btAtualiza) THEN APPLY "CHOOSE" TO h-ft0909-btAtualiza.

        /*FIND FIRST nota-fiscal
             WHERE nota-fiscal.cod-estabel = trim(h-buffer:buffer-field(1):buffer-value)
               AND nota-fiscal.serie       = trim(h-buffer:buffer-field(2):buffer-value)
               AND nota-fiscal.nr-nota-fis = trim(h-buffer:buffer-field(3):buffer-value) NO-LOCK NO-ERROR.
        IF AVAIL nota-fiscal THEN DO:
    
         /* FIND FIRST es-param-integracao-estab
               WHERE es-param-integracao-estab.cod-estabel =  nota-fiscal.cod-estabel 
               AND   es-param-integracao-estab.empresa-integracao = 2
               NO-LOCK NO-ERROR.
    
          IF AVAIL es-param-integracao-estab THEN do:
    
             RUN int\wsinventti0004.p  (input nota-fiscal.cod-estabel,
                                        input nota-fiscal.serie,      
                                        input nota-fiscal.nr-nota-fis).
          END.*/
        END.*/

    END.

    IF VALID-HANDLE(h-acomp) THEN 
        run pi-finalizar in h-acomp.
END.
/*****************************************************************************************************************/
/*
   1=Documento Nao Gerado
   2=Em Processamento no Aplicativo de Transmiss o(em processo no EAI)
   3=Uso Autorizado
   4=Uso Denegado
   5=Documento Rejeitado
   6=Documento Cancelado
   7=Documento Inutilizado
   8=Em processamento no aplicativo de transmissao
   9=Em processamento na SEFAZ
  10=Em processamento no SCAN 
  11=NF-e Gerada
  12=NF-e em Processamento de Cancelamento
  13=Nf-e em processo de inutilizacao
  14=Nf-e pendente de retorno
  15=DPEC recebido pelo SCE
*/
