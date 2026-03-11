/********************************************************************************
**  Programa: upc-oc0201a.p
**  Funcao..: Incluir Campos Saving
**  Autor...: Maylon Damasceno Lima
**  Data....: 20/06/2013
********************************************************************************/
DEFINE INPUT PARAMETER Evento      AS CHAR          NO-UNDO.
DEFINE INPUT PARAMETER Objeto      AS CHAR          NO-UNDO.
DEFINE INPUT PARAMETER hPrograma   AS HANDLE        NO-UNDO.
DEFINE INPUT PARAMETER hFrame      AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER Tabela      AS CHAR          NO-UNDO.
DEFINE INPUT PARAMETER RegRowID    AS ROWID         NO-UNDO.

/*MESSAGE "Evento: "   + Evento                SKIP
        /*"Objeto: "   + Objeto                SKIP
        "hPrograma: "  + STRING(VALID-HANDLE(hPrograma),"V lido/Inv lido") SKIP
        "Frame: "    + hFrame:NAME           SKIP*/
        "Tabela: "   + Tabela                SKIP
        "RegRowID: " + STRING(RegRowID)
        VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

DEF VAR bt-ok        AS HANDLE  NO-UNDO.     
DEF VAR bt-ok_fake   AS HANDLE  NO-UNDO.
DEF VAR minhaAPI     AS HANDLE  NO-UNDO.
DEF VAR EstaOK       AS LOGICAL NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR v_cod_usuar_corren AS CHARACTER NO-UNDO.

IF Evento = "INITIALIZE" THEN DO:
   RUN BuscaWidget(CURRENT-WINDOW).
   
   IF NOT VALID-HANDLE(bt-ok_fake) THEN DO: 
       CREATE BUTTON  bt-ok_fake
       ASSIGN FRAME         = bt-ok:FRAME
              WIDTH         = bt-ok:WIDTH
              HEIGHT        = bt-ok:HEIGHT
              Y             = bt-ok:Y
              X             = bt-ok:X
              NAME          = "bt-ok_fake"
              LABEL         = bt-ok:LABEL + "*"
              TOOLTIP       = bt-ok:TOOLTIP + "*"
              NO-FOCUS      = bt-ok:NO-FOCUS
              FLAT-BUTTON   = bt-ok:FLAT-BUTTON
              VISIBLE       = TRUE
              SENSITIVE     = TRUE
       TRIGGERS:
          //Evento chama esta pr½pria UPC com novo evento de clique no bot’o
          ON 'CHOOSE':U PERSISTENT RUN intupc/upc-cn0302b.p(INPUT "CHOOSE",
                                                            INPUT "bt-ok_fake",   
                                                            INPUT hPrograma,
                                                            INPUT hFrame,   
                                                            INPUT Tabela,   
                                                            INPUT RegRowID).
    
       END TRIGGERS.
       HIDE bt-ok.
   END.
END.

IF Evento = "CHOOSE" AND Objeto = "bt-ok_fake" THEN DO:
   RUN BuscaWidget(CURRENT-WINDOW).
   TMaior:
   DO TRANS:
      DO ON STOP UNDO TMaior, LEAVE:
         DO ON QUIT UNDO TMaior, LEAVE:
            APPLY "CHOOSE" TO bt-ok.
            IF bt-ok_fake:PRIVATE-DATA = "UNDO" THEN DO:
               UNDO TMaior, LEAVE.
            END.
         END.
      END.
   END.
END.

IF Evento = "CHOOSE-BTOK" THEN DO:
   RUN BuscaWidget(CURRENT-WINDOW).

   bt-ok_fake:PRIVATE-DATA = STRING(RegRowID).
END.

IF Evento = "DESTROY" THEN DO:
   RUN BuscaWidget(CURRENT-WINDOW).
   
   //MESSAGE bt-ok_fake:PRIVATE-DATA VIEW-AS ALERT-BOX.

   FIND FIRST medicao-contrat WHERE ROWID(medicao-contrat) = TO-ROWID(bt-ok_fake:PRIVATE-DATA) NO-LOCK NO-ERROR.

   IF AVAIL medicao-contrat THEN DO:
      
      FIND FIRST ordem-compra WHERE ordem-compra.numero-ordem = medicao-contrat.numero-ordem NO-LOCK NO-ERROR.
      
      FIND FIRST pedido-compr OF ordem-compra NO-LOCK NO-ERROR.
      
      IF NOT AVAIL pedido-compr THEN DO:
         RUN utp/ut-msgs.p(INPUT "show",
                                 INPUT 17242,
                                 INPUT "Pedido de compra nÆo encontrado~~Ordem de compra " + STRING(medicao-contrat.numero-ordem) + " nÆo encontrou pedido de compra correspondente").  
         bt-ok_fake:PRIVATE-DATA = "UNDO".
         RETURN.                     
      END.
      
      //MESSAGE 111 SKIP v_cod_usuar_corren SKIP pedido-compr.num-pedido VIEW-AS ALERT-BOX.
      
      IF SEARCH("lapepc\mla_upc_procedures.r") = ? THEN DO:
         MESSAGE "NÆo encontrado o programa 'lapepc\mla_upc_procedures.r'"
                 VIEW-AS ALERT-BOX.
         bt-ok_fake:PRIVATE-DATA = "UNDO".
         RETURN.
      END.
   
      RUN lapepc/mla_upc_procedures.p PERSISTENT SET minhaAPI.
      
      FIND FIRST es-medicao-contrat OF medicao-contrat NO-ERROR.
      
      /*
      
Table: es-medicao-contrat

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
nr-contrato                 inte       i   >>>>>>>>9
num-seq-item                inte       i   >>,>>9
numero-ordem                inte       i   zzzzz9,99
num-seq-event               inte       i   >,>>9
num-seq-medicao             inte       i   >,>>9
dt-validade                 date           99/99/9999

      
      */
      
      RUN gerarDocumEstMedicao IN minhaAPI(INPUT v_cod_usuar_corren,
                                           INPUT medicao-contrat.numero-ordem ,
                                           INPUT string(medicao-contrat.numero-ordem) + STRING(medicao-contrat.num-seq-medicao),
                                           INPUT medicao-contrat.qtd-prevista,
                                           INPUT medicao-contrat.val-medicao,
                                           INPUT IF AVAIL es-medicao-contrat THEN es-medicao-contrat.dt-validade ELSE TODAY + 7 ,
                                           OUTPUT EstaOK).
                                    
      IF NOT EstaOK THEN DO:
         bt-ok_fake:PRIVATE-DATA = "UNDO".
         RETURN.
      END.
   
   END.
END.

//################################################################################################
PROCEDURE BuscaWidget.
   DEF INPUT PARAMETER objEntrada AS HANDLE.
   DEF VAR objFilho AS HANDLE.

   objFilho = objEntrada:FIRST-CHILD NO-ERROR.

   DO WHILE VALID-HANDLE(objFilho).
      IF objFilho:TYPE = "WINDOW" OR objFilho:TYPE = "FRAME" OR objFilho:TYPE = "FIELD-GROUP" THEN DO:
         IF objFilho:TYPE = "FRAME" THEN DO:
            /*IF objFilho:NAME = "fPage1" THEN DO:
               hFrame1 = objFilho.
            END.*/
         END.
         RUN BuscaWidget(objFilho).
      END.
      ELSE DO:
         IF objFilho:TYPE = "BUTTON" THEN DO:
            IF objFilho:NAME = "bt-ok" THEN DO:
               bt-ok = objFilho.
            END.
            IF objFilho:NAME = "bt-ok_fake" THEN DO:
               bt-ok_fake = objFilho.
            END.
         END.
      END.
      objFilho = objFilho:NEXT-SIBLING NO-ERROR.
   END.

END PROCEDURE.
//################################################################################################
