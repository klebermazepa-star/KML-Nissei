/*****************************************************************************
**
** Programa EPC para API de Estorno
**
** OBS: prgfin/acr/acr715zb
**
******************************************************************************/

define temp-table tt-epc no-undo
    field cod-event     as char format "x(12)"
    field cod-parameter as char format "x(32)"
    field val-parameter as char format "x(54)"
    index  id is primary cod-parameter cod-event ascending.
    
def input param p_ind_event as char no-undo.
def input-output param table for tt-epc.

def buffer bf_movto_tit_acr for movto_tit_acr.
def buffer bf_tit_acr       for tit_acr.

def var v_cod_estab      as char    format "x(03)"      no-undo.
def var v_num_id_tit_acr as integer format "9999999999" no-undo.
def var v_cont           as integer                     no-undo.

if p_ind_event = "Tratamento-Estorno" then do:

    if can-find(tt-epc where tt-epc.cod-event = "Tratamento-Estorno"
            and tt-epc.cod-parameter          = "erros") then
        return "nok".
        
    find first tt-epc where tt-epc.cod-event     = "Tratamento-Estorno"
                        and tt-epc.cod-parameter = "Movimento" no-error.
    if avail tt-epc and entry(2,tt-epc.val-parameter,chr(10)) = "Estorno" then do:

        do v_cont = 1 to 30:
            
            if index(program-name(v_cont), "prgfin/spp/spp001ac.p") > 0 then do:
                return.
            end.
    
            if program-name(v_cont) = ? then
                leave.
        end.

        find first bf_movto_tit_acr no-lock
            where rowid(bf_movto_tit_acr) = to-rowid(entry(1,tt-epc.val-parameter,chr(10))) no-error.
        if avail bf_movto_tit_acr then do:

            if bf_movto_tit_acr.ind_trans_acr = "Liquidaá∆o" or 
               bf_movto_tit_acr.ind_trans_acr = "Liquidaá∆o Transf Estab" or 
               bf_movto_tit_acr.ind_trans_acr = "Liquidaá∆o Subst" or
               bf_movto_tit_acr.ind_trans_acr = "Liquidaá∆o Renegociac" or
               bf_movto_tit_acr.ind_trans_acr = "Liquidaá∆o Enctro Ctas" or
               bf_movto_tit_acr.ind_trans_acr = "Liquidaá∆o Perda Dedut°vel" or
               bf_movto_tit_acr.ind_trans_acr = "Acerto Valor a Maior" or 
               bf_movto_tit_acr.ind_trans_acr = "Acerto Valor a Menor" then do:
                
                if can-find(first tit_acr_cartao no-lock 
                            where tit_acr_cartao.cod_estab       = bf_movto_tit_acr.cod_estab
                              and tit_acr_cartao.num_id_tit_acr  = bf_movto_tit_acr.num_id_tit_acr
                              and tit_acr_cartao.ind_sit_tit_acr    <> "Aberto") then do:
                    
                    assign tt-epc.cod-parameter = "Retorno-Movimento"
                           tt-epc.val-parameter = "T°tulo com Movimento de Cart∆o Diferente de Aberto~~O movimento que esta sendo estornado tem vinculado a ele t°tulos cart∆o, por isso para estorna-lo Ç necess†rio utilizar o programa de desconciliaá∆o.".
                    return "nok".
                end.                
            end.
            else if (bf_movto_tit_acr.ind_trans_acr = "Implantaá∆o" or
                     bf_movto_tit_acr.ind_trans_acr = "Implantaá∆o a CrÇdito") then do:
                 
                if can-find(first tit_acr_cartao no-lock 
                            where tit_acr_cartao.cod_estab       = bf_movto_tit_acr.cod_estab
                              and tit_acr_cartao.num_id_tit_acr  = bf_movto_tit_acr.num_id_tit_acr
                              and tit_acr_cartao.ind_sit_tit_acr    <> "Aberto") then do:
                    
                    assign tt-epc.cod-parameter = "Retorno-Movimento"
                           tt-epc.val-parameter = "T°tulo com Movimento de Cart∆o Diferente de Aberto~~O movimento que esta sendo estornado tem vinculado a ele t°tulos cart∆o, por isso para estorna-lo Ç necess†rio utilizar o programa de desconciliaá∆o.".
                    return "nok".
                end.                
        
                for each tit_acr_cartao exclusive-lock
                    where tit_acr_cartao.cod_estab      = bf_movto_tit_acr.cod_estab
                      and tit_acr_cartao.num_id_tit_acr = bf_movto_tit_acr.num_id_tit_acr:
                    
                    delete tit_acr_cartao.
                end.                
            end.
        end.
    end.
    return "ok".
end.        
if p_ind_event = "Valida - Cancelamento T°tulo" then do:

    find first tt-epc where tt-epc.cod-event     = "Valida - Cancelamento T°tulo"
                        and tt-epc.cod-parameter = "Id Movto" no-error.

    if not avail tt-epc then
        return.

    find bf_movto_tit_acr no-lock where
         bf_movto_tit_acr.cod_estab            = entry(1, tt-epc.val-parameter, chr(10)) and
         bf_movto_tit_acr.num_id_movto_tit_acr = integer(entry(2, tt-epc.val-parameter, chr(10))) no-error.

    if avail bf_movto_tit_acr then do:     
        if can-find(first tit_acr_cartao no-lock 
                    where tit_acr_cartao.cod_estab       = bf_movto_tit_acr.cod_estab
                      and tit_acr_cartao.num_id_tit_acr  = bf_movto_tit_acr.num_id_tit_acr
                      and tit_acr_cartao.ind_sit_tit_acr    <> "Aberto") then do:
            
            assign tt-epc.cod-parameter = "Erro"
                   tt-epc.val-parameter = "524;T°tulo com Movimento de Cart∆o Diferente de Aberto;" +
                                               "O t°tulo que esta sendo estornado tem vinculado a ele t°tulos cart∆o," +
                                               "por isso para estorna-lo Ç necess†rio utilizar o programa de desconciliaá∆o.".
            return "nok".
        end.                

        for each tit_acr_cartao exclusive-lock
            where tit_acr_cartao.cod_estab      = bf_movto_tit_acr.cod_estab
              and tit_acr_cartao.num_id_tit_acr = bf_movto_tit_acr.num_id_tit_acr:
            
            delete tit_acr_cartao.
        end.                
    end.
    
    return "OK".

end.


/*****************************************************************************
**  Procedure Interna: pi_messages
**  Descricao........: Mostra Mensagem com Ajuda
*****************************************************************************/
PROCEDURE pi_messages:

    def input param c_action    as char    no-undo.
    def input param i_msg       as integer no-undo.
    def input param c_param     as char    no-undo.

    def var c_prg_msg           as char    no-undo.

    assign c_prg_msg = "messages/":U
                     + string(trunc(i_msg / 1000,0),"99":U)
                     + "/msg":U
                     + string(i_msg, "99999":U).

    if search(c_prg_msg + ".r":U) = ? and search(c_prg_msg + ".p":U) = ? then do:
        message "Mensagem nr. " i_msg "!!!":U skip
                "Programa Mensagem" c_prg_msg "n∆o encontrado."
                view-as alert-box error.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input c_action, input c_param).
    return return-value.
END PROCEDURE.  /* pi_messages */


