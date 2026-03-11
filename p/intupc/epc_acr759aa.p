/***************************************************************************** 
** Nome Externo..........: prgfin/epc/epc_acr759aa.p
** Descricao.............: Programa Espec¡fico 
** Engenharia............: Desenvolvimento customizado conforme FO 1798.849
** Criado por............: Paulo Roberto Barth
** Criado em.............: 22/07/2008
*****************************************************************************/ 
def Input param p_ind_event        as character     no-undo.
def Input param p_ind_objeto       as character     no-undo.
def Input param p_wgh_objeto       as handle        no-undo.
def Input param p_wgh_frame        as widget-handle no-undo.
def Input param p_cod_table        as character     no-undo.
def Input param p_row_table_dw     as recid         no-undo.

DEF NEW GLOBAL SHARED VAR h-campo         AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-button       AS WIDGET-HANDLE NO-UNDO.
DEF                   VAR wh-button-false AS WIDGET-HANDLE NO-UNDO.
DEF                   VAR h-objeto        AS WIDGET-HANDLE NO-UNDO.
def var v_cod_estab   AS CHAR FORMAT "x(05)" no-undo.
def var v_cod_espec   AS CHAR FORMAT "x(03)" no-undo.
def var v_cod_ser     AS CHAR FORMAT "x(02)" no-undo.
def var v_cod_tit_acr AS CHAR FORMAT "x(10)" no-undo.
def var v_cod_parcela AS CHAR FORMAT "x(02)" no-undo.

def NEW GLOBAL SHARED VAR h_epc759aa as handle no-undo.
  
IF p_ind_event = "DISPLAY" THEN DO:

    assign wh-button       = ?
           wh-button-false = ?.

    DO:
        ASSIGN h-objeto = p_wgh_frame:FIRST-CHILD.
        do  while valid-handle(h-objeto):
            IF  h-objeto:TYPE <> "field-group" THEN DO:
                
                IF  h-objeto:NAME = "bt_print" then do:
                    assign wh-button = h-objeto.
                end.
                
                assign h-objeto = h-objeto:NEXT-SIBLING.
            end.
            ELSE DO:
                Assign h-objeto = h-objeto:first-child.
            END.
        end.
    END.

    IF VALID-HANDLE(wh-button)           AND 
       NOT VALID-HANDLE(wh-button-false) THEN DO:

        UNSUBSCRIBE PROCEDURE h_epc759aa TO ALL.

        run intupc/epc_acr759aa.p persistent set h_epc759aa (Input "",
                                                             Input p_ind_objeto,
                                                             Input p_wgh_objeto,
                                                             Input p_wgh_frame,
                                                             Input p_cod_table,
                                                             Input p_row_table_dw).
        
        CREATE BUTTON wh-button-false
        ASSIGN FRAME     = p_wgh_frame
               NAME      = "bt_print_false"
               WIDTH     = 10
               HEIGHT    = 1
               LABEL     = wh-button:LABEL
               ROW       = wh-button:ROW
               COL       = wh-button:COL
               FONT      = ?
               VISIBLE   = YES
               SENSITIVE = YES
               TRIGGERS:
                   ON CHOOSE PERSISTENT RUN pi_exec IN h_epc759aa.
               END TRIGGERS.

        SUBSCRIBE PROCEDURE h_epc759aa to "getParamEpc" ANYWHERE.

        ASSIGN wh-button:VISIBLE   = NO
               wh-button:SENSITIVE = NO.

    END.
END.

PROCEDURE pi_exec:

    MESSAGE 321
        VIEW-AS ALERT-BOX INFO BUTTONS OK.

    APPLY "CHOOSE" TO wh-button.

    MESSAGE 123 SKIP
            "RETURN - " RETURN-VALUE
        VIEW-AS ALERT-BOX INFO BUTTONS OK.

END.
