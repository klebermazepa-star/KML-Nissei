/*****************************************************************************
*  Programa: UPC/CD0404.p - Atualiza‡Æo de Condicao de Pagamento
*  
*  Autor: AVB Consultoria e Planejamento
*
*  Data: 06/2016
*
*  
******************************************************************************/
{utp/ut-glob.i}
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
define var h-campo        as widget-handle no-undo. 
define var c-aux          as char no-undo.

define new global shared var h-cod-esp       as handle no-undo.
define new global shared var h-lbl-cod-esp   as handle no-undo.
define new global shared var h-num-parcelas  as handle no-undo.
define new global shared var h-cod-cond-pag  as handle no-undo.
define new global shared var h-fPage2        as handle no-undo.
define new global shared var h-lbl-rs-taxa   as handle no-undo.
define new global shared var h-rs-taxa       as handle no-undo.
define new global shared var h-cod-portador  as handle no-undo.
define new global shared var h-nom-portador  as handle no-undo.
define new global shared var h-lbl-cod-port  as handle no-undo.
define new global shared var h-lbl-rs-modo   as handle no-undo.
define new global shared var h-rs-modo       as handle no-undo.


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
/* Tratamento de Armazenamento de Campos **************************************/
if (p-ind-event  = "INITIALIZE" AND 
    p-ind-object = "VIEWER" and
    c-objeto = "v04ad039.w")
then do:
    RUN utils/findWidget.p (INPUT  'f-main',   
                            INPUT  'frame',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then assign h-fPage2 = h-campo.
end.

if (p-ind-event  = "INITIALIZE" AND 
    p-ind-object = "CONTAINER")
then do:

    RUN utils/findWidget.p (INPUT  'cod-cond-pag',   
                            INPUT  'fill-in',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then assign h-cod-cond-pag = h-campo.

    RUN utils/findWidget.p (INPUT  'num-parcelas',   
                            INPUT  'fill-in',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then assign h-num-parcelas = h-campo.



    /* cria campos da tela */     
    if     valid-handle (h-cod-cond-pag) and 
           valid-handle (h-num-parcelas) then
    do:
        create text h-lbl-cod-esp
            assign
                name      = 'lbl-cod-esp':u
                frame     = h-num-parcelas:frame
                row       = h-num-parcelas:row + 0.1
                format    = 'x(8)'
                col       = h-num-parcelas:col - 30
                width     = 7
                screen-value = 'Esp‚cie:'
                font      = h-num-parcelas:font
                fgcolor   = h-num-parcelas:fgcolor
                visible   = yes.
        create combo-box h-cod-esp
            assign
                name      = 'c-cod-esp':u
                frame     = h-num-parcelas:frame
                width     = 6
                /*height    = .88*/
                column    = h-lbl-cod-esp:col + h-lbl-cod-esp:width
                row       = h-num-parcelas:row
                font      = h-num-parcelas:font
                fgcolor   = h-num-parcelas:fgcolor
                format    = "X(2)"
                side-label-handle = h-lbl-cod-esp
                help      = 'C¢digo da esp‚cie de t¡tulos (Somente p/ Cupom Fiscal)':u
                tooltip   = 'C¢digo da esp‚cie de t¡tulos (Somente p/ Cupom Fiscal).':u
                visible   = true
                sensitive = no
                inner-lines = 20
                auto-completion = yes.

        h-cod-esp:add-last(" ").
        h-cod-esp:screen-value = " ".
        for each esp-doc no-lock:
            h-cod-esp:add-last(esp-doc.cod-esp).
        end.
        h-cod-esp:tab-stop = yes.

        
        create text h-lbl-rs-taxa
            assign
                name      = 'lbl-rs-taxa':u
                frame     = h-num-parcelas:frame
                row       = h-num-parcelas:row + 0.2
                format    = 'x(8)'
                col       = h-num-parcelas:col + 15
                width     = 7
                screen-value = 'Tx ADM:'
                font      = h-num-parcelas:font
                fgcolor   = h-num-parcelas:fgcolor
                visible   = yes.

        create radio-set h-rs-taxa
            assign row          = h-num-parcelas:row + 0.1
                   col          = h-num-parcelas:col + 22
                   side-label-handle = h-lbl-rs-taxa
                   width        = 14
                   HEIGHT       = 0.88
                   /*label        = "Situa»’o"*/
                   visible      = yes
                   tab-stop     = yes
                   TOOLTIP      = "Taxa de Administra‡Æo de cartÆo" 
                   help         = "Possui taxa de administra‡Æo do cartÆo?"
                   frame        = h-num-parcelas:frame
                   horizontal   = yes
                   radio-buttons = "Sim,Yes,Nao,No".

        assign h-rs-taxa:sensitive  = yes.


        create text h-lbl-rs-modo
            assign
                name      = 'lbl-rs-modo':u
                frame     = h-num-parcelas:frame
                row       = h-num-parcelas:row + 1.2
                format    = 'x(15)'
                col       = h-num-parcelas:col + 5
                width     = 10
                screen-value = 'Devolu‡Æo:'
                font      = h-num-parcelas:font
                fgcolor   = h-num-parcelas:fgcolor
                visible   = yes.

        create radio-set h-rs-modo
            assign row          = h-num-parcelas:row + 1.1
                   col          = h-num-parcelas:col + 13.1
                   side-label-handle = h-lbl-rs-modo
                   width        = 24
                   HEIGHT       = 0.88
                   /*label        = "Situa»’o"*/
                   visible      = yes
                   tab-stop     = yes
                   TOOLTIP      = "Modo de devolu‡Æo de cupom fiscal" 
                   help         = "Modo de devolu‡Æo de cupom fiscal"
                   frame        = h-num-parcelas:frame
                   horizontal   = yes
                   radio-buttons = "Dinheiro,Dinheiro,CartÆo,Cartao,Nenhum,Nenhum".

        assign h-rs-modo:sensitive  = yes.

        create text h-lbl-cod-port
            assign
                name      = 'lbl-cod-portad':u
                frame     = h-num-parcelas:frame
                row       = h-num-parcelas:row + 1.02
                format    = 'x(9)'
                col       = h-num-parcelas:col - 46
                width     = 7
                screen-value = 'Portador:'
                font      = h-num-parcelas:font
                fgcolor   = h-num-parcelas:fgcolor
                visible   = yes.
        create combo-box h-cod-portador
            assign
                name      = 'c-cod-portador':u
                frame     = h-num-parcelas:frame
                width     = 43
                /*height    = .88*/
                column    = h-lbl-cod-port:col + h-lbl-cod-port:width
                row       = h-num-parcelas:row + 0.95
                font      = h-num-parcelas:font
                fgcolor   = h-num-parcelas:fgcolor
                format    = "X(80)"
                side-label-handle = h-lbl-cod-port
                help      = 'C¢digo do portador de t¡tulos (Somente p/ Cupom Fiscal)':u
                tooltip   = 'C¢digo do portador de t¡tulos (Somente p/ Cupom Fiscal).':u
                visible   = true
                sensitive = no
                inner-lines = 20
                auto-completion = yes.

        /*
        create fill-in h-nom-portador
            assign
                name      = 'c-nom-portador':u
                frame     = h-num-parcelas:frame
                width     = 20
                height    = .88
                column    = h-cod-portador:col + h-cod-portador:width
                row       = h-num-parcelas:row + 0.95
                font      = h-num-parcelas:font
                fgcolor   = h-num-parcelas:fgcolor
                format    = "X(25)"
                visible   = true
                sensitive = no.
        */

        h-cod-portador:add-last(" ").
        h-cod-portador:screen-value = " ".
        for each ems2mult.portador no-lock where
            ems2mult.portador.ep-codigo = i-ep-codigo-usuario:
            h-cod-portador:add-last(string(ems2mult.portador.cod-portador,">>>>9") + " / " + 
                                    trim({adinc/i03ad209.i 04 ems2mult.portador.modalidade}) + " / " +
                                    trim(ems2mult.portador.nome)).
        end.
        h-cod-portador:tab-stop = yes.
    end.

    if valid-handle (h-cod-esp) and
       valid-handle (h-rs-taxa) and 
       valid-handle (h-rs-modo) and 
       valid-handle (h-cod-portador) then do:
        assign h-cod-esp:screen-value = " "
               h-rs-taxa:screen-value = "No"
               h-rs-modo:screen-value = ""
               h-cod-portador:screen-value = " "
               /*h-nom-portador:screen-value = " "*/.
        for first cst_cond_pagto where 
            cst_cond_pagto.cod_cond_pag = int(h-cod-cond-pag:screen-value). 
            assign  h-cod-esp:screen-value = string(cst_cond_pagto.cod_esp)
                    h-rs-taxa:screen-value = string(cst_cond_pagto.ind_taxa).
            if cst_cond_pagto.cod_portador <> 0 then do:
                for FIRST ems2mult.portador fields (nome) where 
                    ems2mult.portador.ep-codigo = i-ep-codigo-usuario and
                    ems2mult.portador.cod-portador = cst_cond_pagto.cod_portador and
                    ems2mult.portador.modalidade = cst_cond_pagto.modalidade:
                    /*assign h-nom-portador:screen-value = ems2mult.portador.nome.*/
                    assign h-cod-portador:screen-value = string(cst_cond_pagto.cod_portador) 
                                               + " / " + {adinc/i03ad209.i 04 cst_cond_pagto.modalidade} 
                                               + " / " + ems2mult.portador.nome.
                end.
            end.
            else
                assign h-cod-portador:screen-value = " ".
        end.
    end.

    if valid-handle (h-fPage2) then h-fPage2:visible = false. 
end.

 /* Mostra o fill-in na tela  **************************************/
 if p-ind-event = "DISPLAY" and 
    p-ind-object = "VIEWER" and
    c-objeto = "V04AD039.W"
 then do:
     if valid-handle (h-cod-esp) then
     do:
         assign h-cod-esp:screen-value = " "
                h-rs-taxa:screen-value = "No"
                h-rs-modo:screen-value = ""
                h-cod-portador:screen-value = " "
                /*h-nom-portador:screen-value = ""*/.
         for first cst_cond_pagto where 
             cst_cond_pagto.cod_cond_pag = int(h-cod-cond-pag:screen-value). 
             assign h-cod-esp:screen-value = cst_cond_pagto.cod_esp
                    h-rs-taxa:screen-value = string(cst_cond_pagto.ind_taxa)
                    h-rs-modo:screen-value = string(cst_cond_pagto.modo_devolucao).
             if cst_cond_pagto.cod_portador <> 0 then do:
                 for FIRST ems2mult.portador fields (nome) where 
                     ems2mult.portador.ep-codigo = i-ep-codigo-usuario and
                     ems2mult.portador.cod-portador = cst_cond_pagto.cod_portador and
                     ems2mult.portador.modalidade = cst_cond_pagto.modalidade:
                     /*assign h-nom-portador:screen-value = ems2mult.portador.nome.*/
                     assign h-cod-portador:screen-value = string(cst_cond_pagto.cod_portador) 
                                                + " / " + {adinc/i03ad209.i 04 cst_cond_pagto.modalidade} 
                                                + " / " + ems2mult.portador.nome.
                 end.
             end.
         end.
     end.
 end.

 /* Tratamento de Grava‡Æo de Campos **************************************/
 IF p-ind-event = "AFTER-END-UPDATE" and
    p-ind-object = "VIEWER" and
    c-objeto = "V04AD039.W"
 THEN DO:

     for first cst_cond_pagto where 
         cst_cond_pagto.cod_cond_pag = int(h-cod-cond-pag:screen-value). end.
     if NOT AVAIL cst_cond_pagto THEN do:
         CREATE cst_cond_pagto.
         ASSIGN cst_cond_pagto.cod_cond_pag = int(h-cod-cond-pag:screen-value).
     end.
     assign cst_cond_pagto.cod_esp  = if can-find (first esp-doc no-lock where
                                                   esp-doc.cod-esp = h-cod-esp:screen-value)
                                      then upper(h-cod-esp:screen-value) else " "
            cst_cond_pagto.ind_taxa = logical(h-rs-taxa:screen-value,"Sim/Nao")
            cst_cond_pagto.modo_devolucao = h-rs-modo:screen-value.
    c-aux = trim(entry(2,h-cod-portador:screen-value,"/")).
    if int(entry(1,h-cod-portador:screen-value,"/")) <> 0 then
        assign cst_cond_pagto.cod_portador = int(entry(1,h-cod-portador:screen-value,"/"))
               cst_cond_pagto.modalidade   = {adinc/i03ad209.i 06 c-aux}.
    else
        assign cst_cond_pagto.cod_portador = 0
               cst_cond_pagto.modalidade   = 0.

     assign h-cod-esp:sensitive = no
            h-rs-taxa:sensitive = no
            h-rs-modo:sensitive = no
            h-cod-portador:sensitive = no.
 END.

 /* Tratamento de Elimina‡Æo de Registros **************************************/
 IF p-ind-event = "BEFORE-DELETE" and 
    p-ind-object = "CONTAINER"
 THEN DO:
     for first cst_cond_pagto where 
         cst_cond_pagto.cod_cond_pag = int(h-cod-cond-pag:screen-value). 
         delete cst_cond_pagto.
     end.
 END.

 /* Tratamento de Altera‡Æo de Registros **************************************/
 IF p-ind-event = "ENABLE" and 
     p-ind-object = "VIEWER" and
     c-objeto = "V04AD039.W"
 THEN DO:
     if valid-handle (h-cod-esp) then
     do:
         assign h-cod-esp:sensitive = yes
                h-rs-taxa:sensitive = yes
                h-rs-modo:sensitive = yes
                h-cod-portador:sensitive = yes.
     end.
 END.

 /* Tratamento de Cancelamento de Registros **************************************/
 IF p-ind-event = "CANCEL" and 
    p-ind-object = "VIEWER" and
    c-objeto = "V04AD039.W"
 THEN DO:
     if valid-handle (h-cod-esp) then
     do:
         assign h-cod-esp:sensitive = no
                h-rs-taxa:sensitive = no
                h-rs-modo:sensitive = no
                h-cod-portador:sensitive = no.
     end.
 END.

RETURN "OK".
