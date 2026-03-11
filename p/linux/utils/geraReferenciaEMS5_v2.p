/**
*
* INCLUDE:
*   utils/geraReferenciaEMS5_v2.p
*
* FINALIDADE:
*   Gera referencia para o EMS 5 .
*
*/

def Input param p_ind_tip_atualiz
    as character
    format "X(08)"
    no-undo.
def Input param p_dat_refer
    as date
    format "99/99/9999"
    no-undo.
def output param p_cod_refer
    as character
    format "x(10)"
    no-undo.

def var v_des_dat                        as character       no-undo. /*local*/
def var v_num_aux                        as integer         no-undo. /*local*/
def var v_num_aux_2                      as integer         no-undo. /*local*/
def var v_num_cont                       as integer         no-undo. /*local*/

assign v_des_dat   = string(p_dat_refer,"99999999")
       p_cod_refer = substring(v_des_dat,7,2)
                   + substring(v_des_dat,3,2)
                   + substring(v_des_dat,1,2)
                   + substring(p_ind_tip_atualiz,1,1)
       v_num_aux_2 = integer(this-procedure:handle) .

do  v_num_cont = 1 to 3:
    assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
           p_cod_refer = p_cod_refer + chr(v_num_aux).
end.
