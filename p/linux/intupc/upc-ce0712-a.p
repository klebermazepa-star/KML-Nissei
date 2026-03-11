/***************************************************************************************
**  Autor....: ResultPro
**  Cliente..: Nissei
**  Programa.: upc-ce0712-a.p
**  
**  Objetivo: Criar filtro por estabelecimento 
***************************************************************************************/

DEFINE NEW GLOBAL SHARED VAR wh-tela-ce0712        AS WIDGET-HANDLE            no-undo.
DEFINE NEW GLOBAL SHARED VAR c-cod-estabel-ce0712  LIKE inventario.cod-estabel NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-estabel-ce0712  AS WIDGET-HANDLE no-undo.

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

    DEFINE VARIABLE d-dt-saldo    LIKE inventario.dt-saldo    NO-UNDO.
    
    DEFINE FRAME fGoToRecord
        d-dt-saldo        AT ROW 1.40 COL 21.72 COLON-ALIGNED VIEW-AS FILL-IN SIZE 10 by 0.88
        c-cod-estabel-ce0712     AT ROW 2.40 COL 21.72 COLON-ALIGNED VIEW-AS FILL-IN SIZE 4  by 0.88
        btGoToOK          AT ROW 3.63 COL 2.14
        btGoToCancel      AT ROW 3.63 COL 13
        rtGoToButton      AT ROW 3.38 COL 1
        SPACE(0.28)
        WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE
             THREE-D SCROLLABLE TITLE "V  Para Data Saldo Inventariar" FONT 1
             DEFAULT-BUTTON btGoToOK CANCEL-BUTTON btGoToCancel.

    RUN utp/ut-trfrrp.p (INPUT FRAME fGoToRecord:HANDLE).

    {utp/ut-liter.i V _Para_Saldo_Inventariar *}
    ASSIGN FRAME fGoToRecord:TITLE =  RETURN-VALUE.

    ON "CHOOSE":U OF btGoToOK IN FRAME fGoToRecord DO:
        ASSIGN d-dt-saldo c-cod-estabel-ce0712.

        FIND FIRST inventario NO-LOCK WHERE
                   inventario.dt-saldo    = d-dt-saldo AND 
                   inventario.cod-estabel = c-cod-estabel-ce0712 NO-ERROR.
        IF NOT AVAIL inventario THEN DO:
            {utp/ut-liter.i Data_Saldo_Inventariar *}
            RUN utp/ut-msgs.p (INPUT "SHOW":U, INPUT 2, INPUT return-value).

            RETURN NO-APPLY.
        END.
        ELSE DO:
            RUN repositionRecord IN wh-tela-ce0712 (INPUT rowid(inventario)).     
            
            run setFaixas in wh-tela-ce0712 (input "",
                                             input "ZZZZZZZZZZZZZZZZ",
                                             input 0,
                                             input 99,
                                             input "",
                                             input "ZZZZZZZZ",
                                             input "",
                                             input "ZZZZZZZZ",
                                             input "",
                                             input "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
                                             input "",
                                             input "ZZZZZZZZZZZZZZZZZZZZ",
                                             input "",
                                             input "ZZZ",
                                             input c-cod-estabel-ce0712,
                                             input c-cod-estabel-ce0712,
                                             input 0,
                                             input 9999999).

            run piAtualizaBrowse IN wh-tela-ce0712.

            ASSIGN wh-cod-estabel-ce0712:SCREEN-VALUE = c-cod-estabel-ce0712.
        END.

        APPLY "GO":U TO FRAME fGoToRecord.
    END.

    ENABLE d-dt-saldo c-cod-estabel-ce0712 btGoToOK btGoToCancel
        WITH FRAME fGoToRecord.

    WAIT-FOR "GO":U OF FRAME fGoToRecord.                        
