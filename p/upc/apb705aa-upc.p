/********************************************************************************
**  Programa: apb705aa-upc.p
**  Funcao..: Implantaá∆o de fatura por RPW
**  Autor...: Rafael de Araujo Andrade
**  Data....: 31/07/2024
********************************************************************************/
DEFINE INPUT PARAMETER Evento           AS CHAR          NO-UNDO.
DEFINE INPUT PARAMETER Objeto           AS CHAR          NO-UNDO.
DEFINE INPUT PARAMETER hObjeto          AS HANDLE        NO-UNDO.
DEFINE INPUT PARAMETER hFrame           AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER Tabela           AS CHAR          NO-UNDO.
DEFINE INPUT PARAMETER RegRecID         AS RECID         NO-UNDO.

//bas_lote_impl_tit_ap_fatura

/*MESSAGE "Evento: "   + Evento              SKIP
        "Objeto: "   + Objeto                SKIP
        "hObjeto: "  + STRING(VALID-HANDLE(hObjeto),"V†lido/Inv†lido")    SKIP
        "Frame: "    + (IF VALID-HANDLE(hFrame) THEN hFrame:NAME ELSE "") SKIP
        "Tabela: "   + (IF Tabela <> ? THEN Tabela ELSE "")               SKIP
        "RegRecID: " + (IF RegRecID <> ? THEN STRING(RegRecID) ELSE "")
        VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

DEF NEW GLOBAL SHARED VAR v_cod_usuar_corren AS CHAR NO-UNDO.

DEF VAR bt_atz             AS HANDLE NO-UNDO.
DEF VAR btnAtualizar       AS HANDLE NO-UNDO.
DEF VAR raw-param          AS RAW NO-UNDO.
DEF VAR i-num-ped-exec-rpw AS INTEGER NO-UNDO.

DEFINE TEMP-TABLE tt-param NO-UNDO
            FIELD destino           AS INTEGER
            FIELD arquivo           AS CHAR FORMAT "x(35)"
            FIELD usuario           AS CHAR FORMAT "x(12)"
            FIELD data-exec         AS DATE
            FIELD hora-exec         AS INTEGER
            FIELD classifica        AS INTEGER
            FIELD programa          AS CHAR
            FIELD registro          AS RECID
            FIELD tipoExecucao      AS INTEGER.

DEFINE TEMP-TABLE tt-raw-digita
            FIELD raw-digita AS RAW.
            
            
FUNCTION getDataHoraString RETURNS CHARACTER ().
   DEF VAR Saida AS CHAR.
   
   Saida = STRING(YEAR(TODAY),"9999") + "-" + STRING(MONTH(TODAY),"99") + "-" + STRING(DAY(TODAY),"99") + "_" + REPLACE(STRING(TIME,"HH:MM:SS"),":","-").
   
   RETURN Saida.
   
END FUNCTION.

IF Evento = "INITIALIZE" THEN DO:
   RUN BuscaWidget(CURRENT-WINDOW).
   
   IF VALID-HANDLE(btnAtualizar) = FALSE THEN DO:
      CREATE BUTTON btnAtualizar
      ASSIGN NAME       = "btnAtualizar"
             FRAME      = bt_atz:FRAME
             WIDTH      = bt_atz:WIDTH
             HEIGHT     = bt_atz:HEIGHT
             X          = 450 //bt_atz:X
             Y          = bt_atz:Y
             TOOLTIP    = bt_atz:TOOLTIP + "*"
             SENSITIVE  = TRUE
      TRIGGERS:
        ON CHOOSE PERSISTENT RUN upc/apb705aa-upc.p (INPUT "CHOOSE",  
                                                     INPUT "btnAtualizar",  
                                                     INPUT hObjeto, 
                                                     INPUT hFrame,  
                                                     INPUT Tabela,  
                                                     INPUT RegRecID).
      END TRIGGERS. 
      btnAtualizar:LOAD-IMAGE-UP(bt_atz:IMAGE-UP).
      btnAtualizar:LOAD-IMAGE-DOWN(bt_atz:IMAGE-DOWN).
      btnAtualizar:LOAD-IMAGE-INSENSITIVE(bt_atz:IMAGE-INSENSITIVE).

      btnAtualizar:MOVE-TO-TOP().
      bt_atz:WIDTH = 4. //era 1
      bt_atz:HEIGHT = 1. //era 1
   END.

END.

IF Evento = "DISPLAY" THEN DO:
   RUN BuscaWidget(CURRENT-WINDOW).
   
   IF VALID-HANDLE(btnAtualizar) = TRUE THEN DO:
      btnAtualizar:PRIVATE-DATA = STRING(RegRecID).
      //MESSAGE RegRecID VIEW-AS ALERT-BOX.
   END.
END.

IF Evento = "CHOOSE" AND Objeto = "btnAtualizar" THEN DO:
   RUN BuscaWidget(CURRENT-WINDOW).

   EMPTY TEMP-TABLE tt-param.
   
   //MESSAGE SESSION:TEMP-DIR + "\log.txt" VIEW-AS ALERT-BOX.

   CREATE tt-param.
   ASSIGN tt-param.destino           = 2 //1 = Online, 2 = Batch
          tt-param.arquivo           = "apb705aa-rp_l" + getDataHoraString() + ".txt"
          tt-param.usuario           = v_cod_usuar_corren
          tt-param.data-exec         = TODAY
          tt-param.hora-exec         = TIME
          tt-param.programa          = "bas_lote_impl_tit_ap_fatura" //v_cod_dwb_program
          tt-param.registro          = INTEGER(btnAtualizar:PRIVATE-DATA)
          tt-param.tipoExecucao      = 2 //1 = Online, 2 = Batch
          .

   RAW-TRANSFER tt-param TO raw-param.

   FOR EACH tt-param:
       CREATE tt-raw-digita.
       RAW-TRANSFER tt-param TO tt-raw-digita.raw-digita.
   END.

   FIND FIRST tt-param NO-LOCK NO-ERROR.
   /*ASSIGN tt-param.arquivo = ENTRY(NUM-ENTRIES(tt-param.arquivo,"\"),tt-param.arquivo,"\").*/

   RUN btb/btb911zb.p (INPUT "bas_lote_impl_tit_ap_fatura",
                       INPUT "upc/apb705aa-rp.p",
                       INPUT 1,
                       INPUT 97,
                       INPUT tt-param.arquivo,
                       INPUT tt-param.destino,
                       INPUT raw-param,
                       INPUT TABLE tt-raw-digita,
                       OUTPUT i-num-ped-exec-rpw).

   IF i-num-ped-exec-rpw <> 0 THEN RUN utp/ut-msgs.p (input "show", input 4169, input string(i-num-ped-exec-rpw)).
   ELSE DO:
      MESSAGE "Tarefa do RPW n∆o foi gerada"
              VIEW-AS ALERT-BOX ERROR BUTTONS OK TITLE "Erro".
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
            IF objFilho:NAME = "bt_atz" THEN DO:
               bt_atz = objFilho.
            END.
            IF objFilho:NAME = "btnAtualizar" THEN DO:
               btnAtualizar = objFilho.
            END.
         END.
      END.
      objFilho = objFilho:NEXT-SIBLING NO-ERROR.
   END.

END PROCEDURE.
//################################################################################################
