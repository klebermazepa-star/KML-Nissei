/*****************************************************************************
**
** Programa EPC para tela de estorno
**
** OBS: prgfin/acr/acr715aa
**
******************************************************************************/

/* Defini‡Æo de parƒmetros de entrada - */
def input param p_ind_event        as char          no-undo.
def input param p_ind_object       as char          no-undo.
def input param p_wgh_object       as handle        no-undo.
def input param p_wgh_frame        as widget-handle no-undo.
def input param p_cod_table        as char          no-undo.
def input param p_row_table        as recid         no-undo.

def var h_bt_epc as widget-handle no-undo.
DEF VAR h-objeto AS WIDGET-HANDLE NO-UNDO.

def new global shared var v_row_table as recid no-undo.

if p_ind_event = "Display" then do:

    assign h_bt_epc    = ?
           v_row_table = p_row_table.

    assign h-objeto = p_wgh_frame:FIRST-CHILD.
    do  while valid-handle(h-objeto):
        IF  h-objeto:TYPE <> "field-group" THEN DO:
            
            IF  h-objeto:NAME = "bt_tit_cartao" then do:
                assign h_bt_epc = h-objeto.
                leave.
            end.

            
            assign h-objeto = h-objeto:NEXT-SIBLING.
        end.
        ELSE DO:
            Assign h-objeto = h-objeto:first-child.
        END.
    end.
    
    if not valid-handle(h_bt_epc) then do:
    
      create button h_bt_epc   
         assign frame             = p_wgh_frame
                name              = "bt_tit_cartao"
                width             = 04.00
                height            = 01.13
                row               = 01.08
                col               = 36.14
                tooltip           = "Movimentos CartÆo"
                visible           = yes
                sensitive         = no
                triggers:
                    on 'CHOOSE':U persistent run prgfin\spp\spp715aa.p.               
                end triggers.
     
         h_bt_epc:load-image("image/im-mov.bmp").
  
    end.
    
    find tit_acr no-lock where
         recid(tit_acr) = p_row_table no-error.
    
    assign h_bt_epc:sensitive = no.
    
    if avail tit_acr then do:
    
        if can-find(first tit_acr_cartao where
                          tit_acr.cod_estab      = tit_acr_cartao.cod_estab
                      and tit_acr.num_id_tit_acr = tit_acr_cartao.num_id_tit_acr) then do:
            assign h_bt_epc:sensitive = yes.
        end.
    end.
end.

