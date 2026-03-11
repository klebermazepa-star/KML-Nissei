/*****************************************************************************
*  Programa: UPC/CD0403.p - Atualiza‡Æo de Estabelecimentos
*  
*  Autor: AVB Consultoria e Planejamento
*
*  Data: 06/2016
*
*  
******************************************************************************/

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
define new global shared var h-cod-estabel       as handle no-undo.

def var c-objeto as char no-undo.
assign c-objeto   = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

/*
message "EVENTO" p-ind-event skip
        "OBJETO" p-ind-object skip
        "NOME OBJ" c-objeto skip
        "FRAME" p-wgh-frame skip
        "TABELA" p-cod-table skip
        "ROWID" string(p-row-table) view-as alert-box.

  */

/* Main Block ***************************************************************/
/* Main Block ***************************************************************/
/* Tratamento de Armazenamento de Campos **************************************/
if (p-ind-event  = "INITIALIZE" AND 
    p-ind-object = "CONTAINER")
then do:

    RUN utils/findWidget.p (INPUT  'cod-estabel',   
                            INPUT  'fill-in',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then assign h-cod-estabel = h-campo.

    /* cria campos da tela */     
    if     valid-handle (h-campo) and 
       not valid-handle (h-dt-fim-operacao) then
    do:
        create text h-lbl-dt-fim-oper
            assign
                name      = 'lbl-dt-fim-oper':u
                frame     = h-campo:frame
                row       = h-campo:row + 0.1
                format    = 'x(18)'
                col       = h-campo:col + 24
                width     = 12.5
                screen-value = 'Dt Fim Opera‡Æo:'
                font      = h-campo:font
                fgcolor   = h-campo:fgcolor
                visible   = yes.
    
        create fill-in h-dt-fim-operacao
            assign
                name      = 'dt-fim-operacao':u
                frame     = h-campo:frame
                width     = 10
                height    = .88
                column    = h-lbl-dt-fim-oper:col + h-lbl-dt-fim-oper:width
                row       = h-campo:row
                font      = h-campo:font
                fgcolor   = h-campo:fgcolor
                format    = "99/99/9999"
                side-label-handle = h-lbl-dt-fim-oper
                help      = 'Data de fim de opera‡Æo do estab. com o c¢digo atual':u
                tooltip   = 'Indica a data final de opera‡Æo no estabelecimento com este c¢digo. Para fins de mudan‡a de endere‡o.':u
                visible   = true
                sensitive = no.

        h-dt-fim-operacao:tab-stop = yes.
    end.

    if valid-handle (h-dt-fim-operacao) then
    do:
        for first cst-estabelec where 
            cst-estabelec.cod-estabel = h-cod-estabel:screen-value. end.
        if avail cst-estabelec then
        do:
            assign h-dt-fim-operacao:screen-value = string(cst-estabelec.dt-fim-operacao,"99/99/9999").
        end.
        else do:
            create cst-estabelec.
            assign cst-estabelec.cod-estabel = h-cod-estabel:screen-value
                   cst-estabelec.dt-fim-operacao = 12/31/2016.
            assign h-dt-fim-operacao:screen-value = "31/12/2099".
        end.
    end.

end.

 /* Cria o fill-in na tela  **************************************/
 if p-ind-event = "DISPLAY" and 
    p-ind-object = "VIEWER" and
    c-objeto = "V01AD107.W"
 then do:

     if valid-handle (h-dt-fim-operacao) then
     do:
         for first cst-estabelec where 
             cst-estabelec.cod-estabel = h-cod-estabel:screen-value. end.
         if avail cst-estabelec then
         do:
             assign h-dt-fim-operacao:screen-value = string(cst-estabelec.dt-fim-operacao,"99/99/9999").
         end.
         else assign h-dt-fim-operacao:screen-value = "12/31/2099".
     end.
 end.

  /* Tratamento de Grava‡Æo de Campos **************************************/
 IF p-ind-event = "AFTER-END-UPDATE" and
    p-ind-object = "VIEWER" and
    c-objeto = "V01AD107.W"
 THEN DO:
     for first cst-estabelec where 
         cst-estabelec.cod-estabel = h-cod-estabel:screen-value. end.
     if NOT AVAIL cst-estabelec THEN do:
         CREATE cst-estabelec.
         ASSIGN cst-estabelec.cod-estabel = h-cod-estabel:screen-value.
         /*
         for first estabelec no-lock where 
             estabelec.cod-estabel = cst-estabelec.cod-estabel:
             assign cst-estabelec.cnpj = estabelec.cgc.
         end.
         */
     end.
     assign cst-estabelec.dt-fim-operacao = date(h-dt-fim-operacao:screen-value).
     if cst-estabelec.dt-fim-operacao = ? then cst-estabelec.dt-fim-operacao = 12/31/2016.
     assign h-dt-fim-operacao:sensitive = no.
     FOR EACH param-nf-estab EXCLUSIVE-LOCK /*WHERE
         param-nf-estab.cod-estabel = h-cod-estabel:screen-value*/:
         DELETE param-nf-estab.
     END.
 END.

 /* Tratamento de Elimina‡Æo de Registros **************************************/
 IF p-ind-event = "BEFORE-DELETE" and 
    p-ind-object = "CONTAINER"
 THEN DO:
     for first cst-estabelec where 
         cst-estabelec.cod-estabel = h-cod-estabel:screen-value. end.
     IF AVAIL cst-estabelec THEN delete cst-estabelec.
 END.

 /* Tratamento de Altera‡Æo de Registros **************************************/
 IF p-ind-event = "ENABLE" and 
     p-ind-object = "VIEWER" and
     c-objeto = "V01AD107.W"
 THEN DO:
     if valid-handle (h-dt-fim-operacao) then
     do:
         assign h-dt-fim-operacao:sensitive = yes.
     end.
 END.

 /* Tratamento de Cancelamento de Registros **************************************/
 IF p-ind-event = "CANCEL" and 
    p-ind-object = "VIEWER" and
    c-objeto = "V01AD107.W"
 THEN DO:
     if valid-handle (h-dt-fim-operacao) then
     do:
         assign h-dt-fim-operacao:sensitive = no.
     end.
 END.

RETURN "OK".
