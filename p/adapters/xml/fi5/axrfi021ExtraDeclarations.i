def var h-api as handle no-undo.
DEF VAR v_hdl_utb765zl AS HANDLE NO-UNDO.
def new global shared var v_log_eai_habilit
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.

DEF VAR v_log_eai_habilit_bkp AS LOGICAL NO-UNDO.

DEF VAR i-ep-codigo-empresa AS INTEGER NO-UNDO.
DEF VAR c-arquivo-saida AS CHAR NO-UNDO.

def new global shared var v_cod_empres_usuar
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.

def new global shared var v_num_control_ult_msg
    as integer
    format ">>>>,>>9":U
    no-undo.

/**/
