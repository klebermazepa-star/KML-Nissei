/*****************************************************************************
*  Programa: UPC/CD0403.p - Atualiza‡Æo de Estabelecimentos
*  
*  Autor: AVB Consultoria e Planejamento
*
*  Data: 06/2016
*
******************************************************************************/

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

/* Global Variable Definitions **********************************************/
define new global shared var adm-broker-hdl as handle no-undo.

/* Variable Definitions *****************************************************/
define var c-objects      as character no-undo.
define var i-objects      as integer   no-undo.
define var h-object       as handle    no-undo.
DEFINE var h-campo        as widget-handle no-undo. 

define new global shared var h-dt-fim-operacao   as handle no-undo.
define new global shared var h-lbl-dt-fim-oper   as handle no-undo.
define new global shared var h-lbl-sistema       as handle no-undo.
define new global shared var h-sistema           as HANDLE no-undo.
define new global shared var h-lbl-dt-ini-oper   as handle no-undo.
define new global shared var h-lbl-dt-ini-oper   as handle no-undo.
define new global shared var h-dt-ini-oper       as handle no-undo.
define new global shared var h-cod-estabel       as handle no-undo.

define new global shared var h-integr-ap-ncr     as handle no-undo.
define new global shared var h-cod-suframa       as handle no-undo.
define new global shared var h-lbl-fi-adquirente as handle no-undo.
define new global shared var h-adquirente        as HANDLE no-undo.
define new global shared var h-fi-portador-db    as HANDLE no-undo.
define new global shared var h-fi-portador-cr    as HANDLE no-undo.

define new global shared var h-container-obj     as HANDLE no-undo.

def var c-objeto as char no-undo.
assign c-objeto   = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").


/* message "EVENTO" p-ind-event   skip                    */
/*         "OBJETO" p-ind-object  skip                    */
/*         "NOME OBJ" c-objeto    skip                    */
/*         "FRAME" p-wgh-frame    skip                    */
/*         "TABELA" p-cod-table   skip                    */
/*         "ROWID" string(p-row-table) view-as alert-box. */
 

/* Main Block ***************************************************************/
/* Main Block ***************************************************************/
IF p-ind-event  = "initialize" AND 
   p-ind-object = "container"  THEN DO:
    ASSIGN h-container-obj = p-wgh-object.
END.

/* Tratamento de Armazenamento de Campos **************************************/
IF  (p-ind-event  = "INITIALIZE" 
AND p-ind-object = "CONTAINER")
then do:

    
    RUN utils/findWidget.p (INPUT  'cod-estabel',   
                            INPUT  'fill-in',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then 
       assign h-cod-estabel = h-campo.

    /* cria campos da tela */     
    if     valid-handle (h-campo) and 
       not valid-handle (h-dt-fim-operacao) then
    do:
        create text h-lbl-dt-fim-oper
            assign
                name      = 'lbl-dt-fim-oper':u
                frame     = h-campo:frame
                row       = h-campo:row + 0.11
                format    = 'x(18)'
                col       = h-campo:col + 9
                width     = 12.5
                screen-value = 'Fim Opera‡Æo:'
                font      = h-campo:font
                fgcolor   = h-campo:fgcolor
                visible   = yes.
    
        create fill-in h-dt-fim-operacao
            assign
                name      = 'dt-fim-operacao':u
                frame     = h-campo:frame
                width     = 9.5
                height    = .88
                column    = h-lbl-dt-fim-oper:col + h-lbl-dt-fim-oper:width - 2.4
                row       = h-campo:row
                font      = h-campo:font
                fgcolor   = h-campo:fgcolor
                format    = "99/99/9999"
                side-label-handle = h-lbl-dt-fim-oper
                help      = 'Data de fim de opera‡Æo do estab. com o c¢digo atual.':u
                tooltip   = 'Indica a data final de opera‡Æo no estabelecimento com este c¢digo. Para fins de mudan‡a de endere‡o.':u
                visible   = true
                sensitive = no.

        create text h-lbl-sistema
            assign
                name      = 'lbl-sistema':u
                frame     = h-campo:frame
                row       = h-campo:ROW + 0.11 
                format    = 'x(8)'
                col       = h-campo:col + 29.5
                width     = 8
                screen-value = 'Sistema:'
                font      = h-campo:font
                fgcolor   = h-campo:fgcolor
                visible   = yes.
        
        create RADIO-SET h-sistema
            assign
                name       = 'sistema':u
                frame      = h-campo:frame
                width      = 14
                height     = .88
                column     = 59.5
                row        = h-campo:ROW 
                font       = h-campo:font
                fgcolor    = h-campo:fgcolor
                horizontal = TRUE
                side-label-handle = h-lbl-sistema
                radio-buttons = "Oblak,YES,Procfit,NO"
                help       = 'Sistema que a filial est  utilizando (Oblak ou Procfit).':u
                tooltip    = 'Indica em qual sistema encontra-se a opera‡Æo da filial (Oblak ou Procfit).':u
                visible    = true
                SENSITIVE  = NO.
        
        create text h-lbl-dt-ini-oper
            assign
                name      = 'lbl-dt-ini-oper':u
                frame     = h-campo:frame
                row       = h-campo:row + 0.11
                format    = 'x(20)'
                col       = h-campo:col + 50.5
                width     = 20
                screen-value = 'Ini. Oper. Procfit:'
                font      = h-campo:font
                fgcolor   = h-campo:fgcolor
                visible   = yes.

        create fill-in h-dt-ini-oper
            assign
                name      = 'dt-ini-oper':u
                frame     = h-campo:frame
                width     = 9.5
                height    = .88
                column    = 86
                row       = h-campo:row
                font      = h-campo:font
                fgcolor   = h-campo:fgcolor
                format    = "99/99/9999"
                side-label-handle = h-lbl-dt-ini-oper
                help      = 'Data que a filial passou a utilizar o Procfit.':u
                tooltip   = 'Indica a data de in¡cio de opera‡Æo no sistema Procfit.':u
                visible   = true
                sensitive = no.

        ASSIGN h-dt-fim-operacao:TAB-STOP = YES
               h-sistema:TAB-STOP         = YES
               h-dt-ini-oper:TAB-STOP     = YES.
    end.

    if valid-handle (h-dt-fim-operacao) then
    do:
        for first cst_estabelec where 
                  cst_estabelec.cod_estabel = h-cod-estabel:SCREEN-VALUE: 
        end.
        if avail cst_estabelec then
        do:
            assign h-dt-fim-operacao:screen-value = string(cst_estabelec.dt_fim_operacao,"99/99/9999")
                   h-sistema:SCREEN-VALUE         = string(cst_estabelec.sistema)
                   h-dt-ini-oper:SCREEN-VALUE     = string(cst_estabelec.dt_inicio_oper,"99/99/9999").
            IF cst_estabelec.dt_inicio_oper = ? THEN
               ASSIGN h-dt-ini-oper:SCREEN-VALUE = "".
        end.
        else do:
            create cst_estabelec.
            assign cst_estabelec.cod_estabel      = h-cod-estabel:screen-value
                   cst_estabelec.dt_fim_operacao  = 12/31/2016
                   cst_estabelec.sistema          = logical(h-sistema:screen-value,"Oblak/Procfit")
                   cst_estabelec.dt_inicio_oper   = DATE(h-dt-ini-oper:SCREEN-VALUE)
                   h-dt-fim-operacao:screen-value = "31/12/2099"
                   cst_estabelec.dt_alter         = TODAY
                   cst_estabelec.cod_usuario      = c-seg-usuario.
        end.
    end.
end.

 IF  p-ind-event = "INITIALIZE" 
 AND p-ind-object = "VIEWER" 
 AND c-objeto = "V34AD107.W" THEN DO:

     
    RUN utils/findWidget.p (INPUT  'cb-integr-ap-ncr',   
                            INPUT  'COMBO-BOX',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then 
       assign h-integr-ap-ncr = h-campo.

    IF VALID-HANDLE(h-integr-ap-ncr) THEN DO:

        CREATE TEXT h-lbl-fi-adquirente
        ASSIGN name      = 'lbl-fi-adquirente':u
               frame     = h-campo:frame
               row       = h-campo:row + 2.4
               format    = 'x(11)'
               col       = h-campo:col - 8
               width     = 10
               screen-value = 'Adquirente:'
               font      = h-campo:font
               fgcolor   = h-campo:fgcolor
               visible   = yes.

        CREATE COMBO-BOX h-adquirente
        ASSIGN name       = 'Adquirente':u
               frame      = h-campo:frame
               width      = 19
               column     = h-campo:col
               row        = h-campo:row + 2.20
               font       = h-campo:font
               fgcolor    = h-campo:fgcolor
               LIST-ITEM-PAIRS = "125 - Cielo,125,082 - GetNet,082,296 - Safrapay,296,005 - Rede,005"
               help       = 'Adquirente que est  sendo utilizado no Estabelecimento':u
               tooltip    = 'Indica em qual o Adquirente est  sendo utilizado no Estabelecimento':u
               visible    = true
               SENSITIVE  = NO

               TRIGGERS:
                   ON VALUE-CHANGED PERSISTENT RUN intupc/upc-cd0403-a.p.
               END TRIGGERS.

        CREATE TEXT h-fi-portador-db
        ASSIGN name      = 'h-fi-portador-db':u
               frame     = h-adquirente:frame
               row       = h-adquirente:row + 1
               format    = 'x(15)'
               col       = h-adquirente:col + 20
               width     = 13
               screen-value = 'D‚bito :'
               font      = h-adquirente:font
               fgcolor   = h-adquirente:fgcolor
               visible   = yes.

        CREATE TEXT h-fi-portador-cr
        ASSIGN name      = 'h-fi-portador-cr':u
               frame     = h-adquirente:frame
               row       = h-adquirente:ROW + 0.2
               format    = 'x(15)'
               col       = h-adquirente:col + 20
               width     = 13
               screen-value = 'Cr‚dito:'
               font      = h-adquirente:font
               fgcolor   = h-adquirente:fgcolor
               visible   = yes.


        ASSIGN h-lbl-fi-adquirente:TAB-STOP = YES
               h-adquirente:TAB-STOP        = YES
               h-fi-portador-cr:TAB-STOP    = YES
               h-fi-portador-db:TAB-STOP    = YES.

        for first cst_estabelec where 
                  cst_estabelec.cod_estabel = h-cod-estabel:screen-value. 
        end.
        IF AVAIL cst_estabelec THEN DO:

           IF cst_estabelec.cod_adquirente = 0 OR cst_estabelec.cod_adquirente = ? THEN DO:
               ASSIGN h-adquirente:SCREEN-VALUE = "125".
               APPLY "VALUE-CHANGED" TO h-adquirente .
           END.
           ELSE DO:
               ASSIGN h-adquirente:SCREEN-VALUE = STRING(INT(cst_estabelec.cod_adquirente),"999").
               APPLY "VALUE-CHANGED" TO h-adquirente .
           END.
        END.

        run select-page in h-container-obj (input 5).
        run select-page in h-container-obj (input 1). 

    END.
 END.

/* Cria o fill-in na tela  **************************************/
 IF  p-ind-event = "DISPLAY" 
 AND p-ind-object = "VIEWER" 
 AND c-objeto = "V01AD107.W"
 then do:

     if valid-handle (h-dt-fim-operacao) THEN do:
         for first cst_estabelec where 
                   cst_estabelec.cod_estabel = h-cod-estabel:screen-value. 
         end.
         if avail cst_estabelec then
         do:
            assign h-dt-fim-operacao:screen-value = string(cst_estabelec.dt_fim_operacao,"99/99/9999")
                   h-sistema:SCREEN-VALUE         = string(cst_estabelec.sistema)
                   h-dt-ini-oper:SCREEN-VALUE     = string(cst_estabelec.dt_inicio_oper,"99/99/9999").
            IF cst_estabelec.dt_inicio_oper = ? THEN
               ASSIGN h-dt-ini-oper:SCREEN-VALUE = "".
         end.
         else assign h-dt-fim-operacao:screen-value = "12/31/2099"
                     h-sistema:SCREEN-VALUE         = "Oblak" 
                     h-dt-ini-oper:SCREEN-VALUE     = "".        
     end.
 end.


 IF  p-ind-event = "DISPLAY" 
 AND p-ind-object = "VIEWER" 
 AND c-objeto = "V28AD107.W"
 then do:

     IF VALID-HANDLE(h-adquirente) THEN DO:
         for first cst_estabelec where 
                   cst_estabelec.cod_estabel = h-cod-estabel:screen-value. 
         end.
         IF AVAIL cst_estabelec THEN DO:

            IF cst_estabelec.cod_adquirente = 0 OR cst_estabelec.cod_adquirente = ? THEN DO:
                ASSIGN h-adquirente:SCREEN-VALUE = "125".
                APPLY "VALUE-CHANGED" TO h-adquirente .
            END.
            ELSE DO:
                ASSIGN h-adquirente:SCREEN-VALUE = STRING(INT(cst_estabelec.cod_adquirente),"999").
                APPLY "VALUE-CHANGED" TO h-adquirente .
            END.
         END.
     END.
  END.

  /* Tratamento de Grava‡Æo de Campos **************************************/
 IF  p-ind-event = "AFTER-END-UPDATE" 
 AND p-ind-object = "VIEWER" 
 AND c-objeto = "V01AD107.W"
 THEN DO:
     for first cst_estabelec where 
               cst_estabelec.cod_estabel = h-cod-estabel:screen-value. 
     end.
     if NOT AVAIL cst_estabelec THEN do:
         CREATE cst_estabelec.
         ASSIGN cst_estabelec.cod_estabel = h-cod-estabel:screen-value.
     end.
     assign cst_estabelec.dt_fim_operacao = date(h-dt-fim-operacao:screen-value)
            cst_estabelec.sistema         = logical(h-sistema:screen-value,"Oblak/Procfit")
            cst_estabelec.dt_inicio_oper  = date(h-dt-ini-oper:screen-value)
            cst_estabelec.dt_alter        = TODAY
            cst_estabelec.cod_usuario     = c-seg-usuario.

     if cst_estabelec.dt_fim_operacao = ? then 
        cst_estabelec.dt_fim_operacao = 12/31/2016.
     
     assign h-dt-fim-operacao:sensitive = NO
            h-sistema:SENSITIVE         = NO
            h-dt-ini-oper:SENSITIVE     = NO.
     
     FOR EACH param-nf-estab EXCLUSIVE-LOCK /*WHERE
              param-nf-estab.cod-estabel = h-cod-estabel:screen-value:*/ :
         DELETE param-nf-estab.
     END.
 END.

  IF  p-ind-event = "AFTER-END-UPDATE" 
 AND p-ind-object = "VIEWER" 
 AND c-objeto = "V28AD107.W"
 THEN DO:

      IF VALID-HANDLE(h-adquirente) THEN DO:
          for first cst_estabelec where 
                    cst_estabelec.cod_estabel = h-cod-estabel:screen-value. 
          end.
          IF AVAIL cst_estabelec THEN DO:
              ASSIGN cst_estabelec.cod_adquirente = INT(h-adquirente:SCREEN-VALUE).

              IF h-adquirente:SCREEN-VALUE = "125" THEN DO: /* CIELO */
                  ASSIGN cst_estabelec.cod_portador_cr = 90101
                         cst_estabelec.cod_portador_db = 90102.
              END.
              ELSE IF h-adquirente:SCREEN-VALUE = "005" THEN DO: /* SAFRAPAY */
                  ASSIGN cst_estabelec.cod_portador_cr = 90201
                         cst_estabelec.cod_portador_db = 90202.
              END.
              ELSE IF h-adquirente:SCREEN-VALUE = "082" THEN DO: /* GETNETLAC */
                  ASSIGN cst_estabelec.cod_portador_cr = 91601
                         cst_estabelec.cod_portador_db = 91602.
              END.
              ELSE IF h-adquirente:SCREEN-VALUE = "296" THEN DO: /* SAFRAPAY */
                  ASSIGN cst_estabelec.cod_portador_cr = 91501
                         cst_estabelec.cod_portador_db = 91502.
              END.
          END.
      END.

      IF VALID-HANDLE(h-adquirente) THEN DO:
          ASSIGN h-adquirente:SENSITIVE = NO.
      END.

  END.

/*  */


/*  */

 /* Tratamento de Elimina‡Æo de Registros **************************************/
 IF  p-ind-event = "BEFORE-DELETE" 
 AND p-ind-object = "CONTAINER"
 THEN DO:
     for first cst_estabelec where 
         cst_estabelec.cod_estabel = h-cod-estabel:screen-value. end.
     IF AVAIL cst_estabelec THEN 
        delete cst_estabelec.
 END.

 /* Tratamento de Altera‡Æo de Registros **************************************/
 IF  p-ind-event = "ENABLE" 
 and p-ind-object = "VIEWER" 
 AND c-objeto = "V01AD107.W"
 THEN DO:
     if valid-handle (h-dt-fim-operacao) then
     do:
         assign h-dt-fim-operacao:sensitive = YES
                h-sistema:SENSITIVE         = YES
                h-dt-ini-oper:SENSITIVE     = YES.
     end.

     IF VALID-HANDLE(h-adquirente) THEN DO:

         IF h-sistema:SCREEN-VALUE = "YES"  THEN
             ASSIGN h-adquirente:SENSITIVE = YES.
     END.

 END.

 IF  p-ind-event = "ENABLE" 
 and p-ind-object = "VIEWER" 
 AND c-objeto = "V28AD107.W"
 THEN DO:
     IF VALID-HANDLE(h-adquirente) THEN DO:

         IF h-sistema:SCREEN-VALUE = "YES"  THEN
             ASSIGN h-adquirente:SENSITIVE = YES.
     END.
 END.

 /* Tratamento de Cancelamento de Registros **************************************/
 IF  p-ind-event = "CANCEL" 
 and p-ind-object = "VIEWER" 
 and c-objeto = "V01AD107.W"
 THEN DO:

     if valid-handle (h-dt-fim-operacao) THEN DO:
         assign h-dt-fim-operacao:sensitive = NO
                h-sistema:SENSITIVE         = NO 
                h-dt-ini-oper:SENSITIVE     = NO.
     end.

     IF VALID-HANDLE(h-adquirente) THEN DO:
         ASSIGN h-adquirente:SENSITIVE = NO.
     END.

 END.

 IF  p-ind-event = "CANCEL" 
 AND p-ind-object = "VIEWER" 
 AND c-objeto = "V28AD107.W" 
 THEN DO:

     IF VALID-HANDLE(h-adquirente) THEN DO:
         ASSIGN h-adquirente:SENSITIVE = NO.
     END.
 END.

RETURN "OK".
