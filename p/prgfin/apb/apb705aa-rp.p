
{include/i_dbinst.i}
{include/i_dbtype.i}
{include/i_fcldef.i}
//{include/i_trddef.i}

DEF VAR v_log_answer AS LOGICAL NO-UNDO.
DEF VAR v_log_method AS LOGICAL NO-UNDO.
DEF VAR v_nom_title_aux AS CHAR NO-UNDO.
DEF VAR v_ind_tip_filho_fatur AS CHAR NO-UNDO.

def var v_wgh_servid_rpc
    as widget-handle
    format ">>>>>>9":U
    label "Handle RPC"
    column-label "Handle RPC"
    no-undo.
    
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

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.

DEFINE temp-table tt-raw-digita
    field raw-digita as raw.

DEF INPUT PARAM raw-param as raw no-undo.
DEF INPUT PARAM table for tt-raw-digita.

CREATE tt-param.
RAW-TRANSFER raw-param to tt-param.     


DEF new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.

def new global shared var v_cod_ccusto_corren
    as character
    format "x(20)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.

def new global shared var v_cod_dwb_user
    as character
    format "x(21)":U
    label "Usu rio"
    column-label "Usu rio"
    no-undo.
def new global shared var v_cod_empres_usuar
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
def new global shared var v_cod_estab_usuar
    as character
    format "x(5)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def new global shared var v_cod_funcao_negoc_empres
    as character
    format "x(50)":U
    no-undo.
def new global shared var v_cod_grp_usuar_lst
    as character
    format "x(3)":U
    label "Grupo Usu rios"
    column-label "Grupo"
    no-undo.
def new global shared var v_cod_idiom_usuar
    as character
    format "x(8)":U
    label "Idioma"
    column-label "Idioma"
    no-undo.
def new global shared var v_cod_modul_dtsul_corren
    as character
    format "x(3)":U
    label "M¢dulo Corrente"
    column-label "M¢dulo Corrente"
    no-undo.
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pa¡s Empresa Usu rio"
    column-label "Pa¡s"
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.

DEF new global shared var v_cod_unid_negoc_usuar
    as character
    format "x(3)":U
    view-as combo-box
    &if "{&FNC_MULTI_IDIOMA}" = "YES" &then
    list-item-pairs "",""
    &else
    list-items ""
    &endif
    inner-lines 5
    bgcolor 15 font 2
    label "Unidade Neg¢cio"
    column-label "Unid Neg¢cio"
    no-undo.
def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu rio Corrente"
    column-label "Usu rio Corrente"
    no-undo.
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.

def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def new global shared var v_rec_estabelecimento
    as recid
    format ">>>>>>9":U
    no-undo.
def new global shared var v_rec_fornecedor
    as recid
    format ">>>>>>9":U
    no-undo.
def new global shared var v_rec_item_lote_impl_ap
    as recid
    format ">>>>>>9":U
    no-undo.
def new global shared var v_rec_lote_impl_tit_ap
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.

def new global shared var v_rec_usuar_financ_estab_apb
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.

def buffer b_tit_ap
    for tit_ap.
    
def buffer b_movto_tit_ap for movto_tit_ap.    

def new shared temp-table tt_lote_impl_erros_fatura        
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(5)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_ap                   as character format "x(16)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_cod_erro_atualiz             as character format "x(8)"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia"
    field ttv_des_help_erro                as character format "x(200)"
    .

def temp-table tt_exec_rpc no-undo
    field ttv_cod_aplicat_dtsul_corren     as character format "x(3)"
    field ttv_cod_ccusto_corren            as character format "x(20)" label "Centro Custo" column-label "Centro Custo"
    field ttv_cod_dwb_user                 as character format "x(21)" label "Usu rio" column-label "Usu rio"
    field ttv_cod_empres_usuar             as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_estab_usuar              as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field ttv_cod_funcao_negoc_empres      as character format "x(50)"
    field ttv_cod_grp_usuar_lst            as character format "x(3)" label "Grupo Usu rios" column-label "Grupo"
    field ttv_cod_idiom_usuar              as character format "x(8)" label "Idioma" column-label "Idioma"
    field ttv_cod_modul_dtsul_corren       as character format "x(3)" label "M¢dulo Corrente" column-label "M¢dulo Corrente"
    field ttv_cod_modul_dtsul_empres       as character format "x(100)"
    field ttv_cod_pais_empres_usuar        as character format "x(3)" label "Pa¡s Empresa Usu rio" column-label "Pa¡s"
    field ttv_cod_plano_ccusto_corren      as character format "x(8)" label "Plano CCusto" column-label "Plano CCusto"
    field ttv_cod_unid_negoc_usuar         as character format "x(3)" label "Unidade Neg¢cio" column-label "Unid Neg¢cio"
    field ttv_cod_usuar_corren             as character format "x(12)" label "Usu rio Corrente" column-label "Usu rio Corrente"
    field ttv_cod_usuar_corren_criptog     as character format "x(16)"
    field ttv_num_ped_exec_corren          as integer format ">>>>9"
    field ttv_cod_livre                    as character format "x(2000)"
    .
    
FUNCTION SetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          input p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER,
                                          input p_cod_valor       AS CHARACTER):

/* ************* Parametros da FUN?€O *******************************
** Fun?’o para tratamento dos Entries dos c½digos livres
** 
**  p_num_posicao     - Nœmero do Entry / Posi?’o que serÿ atualizado
**  p_cod_campo       - Campo / Variÿvel que serÿ atualizada
**  p_cod_separador   - Separador que serÿ utilizado
**  p_cod_valor       - Valor que serÿ atualizado no Entry passado 
*******************************************************************/

    def var v_num_cont        as integer initial 0 no-undo.
    def var v_num_entries_ini as integer initial 0 no-undo.

    /* ** No progress a menor Entry ? 1 ***/
    if p_num_posicao <= 0 then 
       assign p_num_posicao = 1.       

    /* ** Caso o Campo contenha um valor invÿlido, este valor serÿ convertido para Branco
         para possibilitar os cÿlculo ***/
    if p_cod_campo = ? then do:
       assign p_cod_campo = "" /* l_*/ .
    end.

    assign v_num_entries_ini = num-entries(p_cod_campo,p_cod_separador) + 1 .    
    if p_cod_campo = "" /* l_*/  then do:
       assign v_num_entries_ini = 2.
    end.

    do v_num_cont =  v_num_entries_ini to p_num_posicao :
       assign p_cod_campo = p_cod_campo + p_cod_separador.
    end.

    assign entry(p_num_posicao,p_cod_campo,p_cod_separador) = p_cod_valor.

    RETURN p_cod_campo.

END FUNCTION.


/* End_Include: i_declara_SetEntryField */


/* Begin_Include: i_declara_GetEntryField */
FUNCTION GetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          INPUT p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER):

/* ************* Parametros da FUN?€O *******************************
** Fun?’o para tratamento dos Entries dos c½digos livres
** 
**  p_num_posicao     - Nœmero do Entry que serÿ atualizado
**  p_cod_campo       - Campo / Variÿvel que serÿ atualizada
**  p_cod_separador   - Separador que serÿ utilizado
*******************************************************************/

    if  p_num_posicao <= 0  then do:
        assign p_num_posicao  = 1.
    end.
    if num-entries(p_cod_campo,p_cod_separador) >= p_num_posicao  then do:
       return entry(p_num_posicao,p_cod_campo,p_cod_separador).
    end.
    return "" /*l_*/ .

END FUNCTION.

/* End_Include: i_declara_GetEntryField */


assign v_ind_tip_filho_fatur = "Notas" /*l_notas*/ .

/* Begin_Include: i_exec_define_rpc */
FUNCTION rpc_exec         RETURNS logical   (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_server       RETURNS handle    (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_program      RETURNS character (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_tip_exec     RETURNS logical   (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_exec_set     RETURNS logical   (input p_cod_program as character, 
                                             input p_log_value as logical)     in v_wgh_servid_rpc.    

assign v_rec_lote_impl_tit_ap = tt-param.registro.

run pi_controlar_atualizacao_fatura.

PROCEDURE pi_controlar_atualizacao_fatura:

    FIND FIRST lote_impl_tit_ap WHERE RECID(lote_impl_tit_ap) = v_rec_lote_impl_tit_ap NO-LOCK NO-ERROR.

    /************************* Variable Definition Begin ************************/

    def var v_cod_estab
        as character
        format "x(5)":U
        label "Estabelecimento"
        column-label "Estabelecimento"
        no-undo.
    def var v_cod_refer
        as character
        format "x(10)":U
        label "Referˆncia"
        column-label "Referˆncia"
        no-undo.
    def var v_log_erro
        as logical
        format "Sim/NÆo"
        initial yes
        no-undo.


    /************************** Variable Definition End *************************/

    TMaior:
    DO TRANS:
       for each tt_exec_rpc:
           delete tt_exec_rpc.
       end.

       create  tt_exec_rpc.
       assign  tt_exec_rpc.ttv_cod_aplicat_dtsul_corren  = v_cod_aplicat_dtsul_corren 
               tt_exec_rpc.ttv_cod_ccusto_corren         = v_cod_ccusto_corren
               tt_exec_rpc.ttv_cod_dwb_user              = v_cod_dwb_user
               tt_exec_rpc.ttv_cod_empres_usuar          = v_cod_empres_usuar
               tt_exec_rpc.ttv_cod_estab_usuar           = v_cod_estab_usuar 
               tt_exec_rpc.ttv_cod_funcao_negoc_empres   = v_cod_funcao_negoc_empres
               tt_exec_rpc.ttv_cod_grp_usuar_lst         = v_cod_grp_usuar_lst
               tt_exec_rpc.ttv_cod_idiom_usuar           = v_cod_idiom_usuar
               tt_exec_rpc.ttv_cod_modul_dtsul_corren    = v_cod_modul_dtsul_corren
               tt_exec_rpc.ttv_cod_modul_dtsul_empres    = ""
               tt_exec_rpc.ttv_cod_pais_empres_usuar     = v_cod_pais_empres_usuar
               tt_exec_rpc.ttv_cod_plano_ccusto_corren   = v_cod_plano_ccusto_corren
               tt_exec_rpc.ttv_cod_unid_negoc_usuar      = v_cod_unid_negoc_usuar
               tt_exec_rpc.ttv_cod_usuar_corren          = v_cod_usuar_corren
               tt_exec_rpc.ttv_cod_usuar_corren_criptog  = v_cod_usuar_corren_criptog
               tt_exec_rpc.ttv_num_ped_exec_corren       = v_num_ped_exec_corren .

       for each tt_lote_impl_erros_fatura:
           delete tt_lote_impl_erros_fatura.
       end.               

       FOR each  relacto_pend_tit_ap no-lock
           where relacto_pend_tit_ap.cod_estab = lote_impl_tit_ap.cod_estab
           and   relacto_pend_tit_ap.cod_refer = lote_impl_tit_ap.cod_refer:     

         assign v_log_erro = no.

           run pi_validar_movtos_dat_transacao_subs (Input relacto_pend_tit_ap.cod_estab,
                                                     Input relacto_pend_tit_ap.num_id_tit_ap_pai,
                                                     Input lote_impl_tit_ap.dat_transacao,
                                                     output v_log_erro) /* pi_validar_movtos_dat_transacao_subs*/.
                                                                                                        
           if  v_log_erro = yes then do:                                          

               find b_tit_ap no-lock
                      WHERE b_tit_ap.cod_estab     = relacto_pend_tit_ap.cod_estab
                      AND   b_tit_ap.num_id_tit_ap = relacto_pend_tit_ap.num_id_tit_ap_pai NO-ERROR.

               if  avail b_tit_ap then do:
                   PUT UNFORMAT "Data Transa‡Æo da Substitui‡Æo menor que a data do £ltimo movimento.".
                   UNDO TMaior,LEAVE.
               end /* if */.    
           end.
       END.           

      if avail lote_impl_tit_ap then do:
      
         find first relacto_pend_tit_ap no-lock
            where relacto_pend_tit_ap.cod_estab = lote_impl_tit_ap.cod_estab
              and relacto_pend_tit_ap.cod_refer = lote_impl_tit_ap.cod_refer no-error.
              
         if avail relacto_pend_tit_ap then do:
            find first tit_ap no-lock
            where tit_ap.cod_estab     = relacto_pend_tit_ap.cod_estab_tit_ap_pai
              and tit_ap.num_id_tit_ap = relacto_pend_tit_ap.num_id_tit_ap_pai no-error.
            if avail tit_ap then do:
               find first ext_tit_ap no-lock
                  where ext_tit_ap.cod_estab     = relacto_pend_tit_ap.cod_estab_tit_ap_pai 
                 and ext_tit_ap.num_id_tit_ap = relacto_pend_tit_ap.num_id_tit_ap_pai no-error.
               if avail ext_tit_ap then do:
                  for each item_lote_impl_ap
                    where item_lote_impl_ap.cod_estab = lote_impl_tit_ap.cod_estab
                     and item_lote_impl_ap.cod_refer = lote_impl_tit_ap.cod_refer exclusive-lock:

                  &if defined(BF_FIN_REINF_12120) &then
                     assign item_lote_impl_ap.num_tip_serv_mdo = ext_tit_ap.num_tip_serv_mdo
                    item_lote_impl_ap.cod_obra         = ext_tit_ap.cod_obra
                    item_lote_impl_ap.log_mdo_emptda   = ext_tit_ap.log_mdo_emptda
                    item_lote_impl_ap.num_tip_obra     = ext_tit_ap.num_tip_obra.
                  &else
                        assign item_lote_impl_ap.cod_livre_1 = setEntryField(5,item_lote_impl_ap.cod_livre_1, chr(10), string(ext_tit_ap.num_livre_1))
                             item_lote_impl_ap.cod_livre_1 = setEntryField(6,item_lote_impl_ap.cod_livre_1, chr(10), GetEntryField(1, ext_tit_ap.cod_livre_1, chr(10)))
                             item_lote_impl_ap.log_livre_1 = ext_tit_ap.log_livre_1
                             item_lote_impl_ap.num_livre_1 = ext_tit_ap.num_livre_2.
                  &endif
                  end.
               end. 
            end.
         end.

          assign v_cod_estab = lote_impl_tit_ap.cod_estab.
          assign v_cod_refer = lote_impl_tit_ap.cod_refer.

          assign v_log_method = session:set-wait-state('general').           


          /* Begin_Include: i_exec_program_rpc2 */
          &if '{&emsbas_version}' > '1.00' &then

             /* Begin_Include: i_exec_initialize_rpc */
             if  not valid-handle(v_wgh_servid_rpc)
             or v_wgh_servid_rpc:type <> 'procedure':U
             or v_wgh_servid_rpc:file-name <> 'prgtec/btb/btb008za.py':U
             then do:
                 run prgtec/btb/btb008za.py persistent set v_wgh_servid_rpc (input 1).
             end /* if */.

             run pi_connect in v_wgh_servid_rpc ("api_controlar_atualizacao_fatura":U, '', yes).
             /* End_Include: i_exec_initialize_rpc */

             if  rpc_exec("api_controlar_atualizacao_fatura":U)
             then do:

                 /* Begin_Include: i_exec_dispatch_rpc */
                 rpc_exec_set("api_controlar_atualizacao_fatura":U,yes).
                 rpc_block:
                 repeat while rpc_exec("api_controlar_atualizacao_fatura":U) on stop undo rpc_block, retry rpc_block:
                     if  rpc_program("api_controlar_atualizacao_fatura":U) = ?
                     then do: 
                        leave rpc_block.        
                     end /* if */.
                     if  retry
                     then do:
                         run pi_status_error in v_wgh_servid_rpc.
                         next rpc_block.
                     end /* if */.
                     if  rpc_tip_exec("api_controlar_atualizacao_fatura":U)
                     then do:
                         run pi_check_server in v_wgh_servid_rpc ("api_controlar_atualizacao_fatura":U).
                         if  return-value = 'yes'
                         then do:
                             if  rpc_program("api_controlar_atualizacao_fatura":U) <> ?
                             then do:
                                 if  '1,input table tt_exec_rpc,input-output v_rec_lote_impl_tit_ap,input-output table tt_lote_impl_erros_fatura' = '""'
                                 then do:
                                     &if '""' = '""' &then
                                         run value(rpc_program("api_controlar_atualizacao_fatura":U)) on rpc_server("api_controlar_atualizacao_fatura":U) transaction distinct no-error.
                                     &else
                                         run value(rpc_program("api_controlar_atualizacao_fatura":U)) persistent set "" on rpc_server("api_controlar_atualizacao_fatura":U) transaction distinct no-error.
                                     &endif
                                 end /* if */.
                                 else do:
                                     &if '""' = '""' &then
                                         run value(rpc_program("api_controlar_atualizacao_fatura":U)) on rpc_server("api_controlar_atualizacao_fatura":U) transaction distinct (1,input table tt_exec_rpc,input-output v_rec_lote_impl_tit_ap,input-output table tt_lote_impl_erros_fatura) no-error.
                                     &else
                                         run value(rpc_program("api_controlar_atualizacao_fatura":U)) persistent set "" on rpc_server("api_controlar_atualizacao_fatura":U) transaction distinct (1,input table tt_exec_rpc,input-output v_rec_lote_impl_tit_ap,input-output table tt_lote_impl_erros_fatura) no-error.
                                     &endif
                                 end /* else */.
                             end /* if */.    
                         end /* if */.
                         else do:
                             next rpc_block.
                         end /* else */.
                     end /* if */.
                     else do:
                         if  rpc_program("api_controlar_atualizacao_fatura":U) <> ?
                         then do: 
                             if  '1,input table tt_exec_rpc,input-output v_rec_lote_impl_tit_ap,input-output table tt_lote_impl_erros_fatura' = '""'
                             then do:
                                 &if '""' = '""' &then 
                                     run value(rpc_program("api_controlar_atualizacao_fatura":U)) no-error.
                                 &else
                                     run value(rpc_program("api_controlar_atualizacao_fatura":U)) persistent set "" no-error.
                                 &endif
                             end /* if */.
                             else do:
                                 &if '""' = '""' &then 
                                     run value(rpc_program("api_controlar_atualizacao_fatura":U)) (1,input table tt_exec_rpc,input-output v_rec_lote_impl_tit_ap,input-output table tt_lote_impl_erros_fatura) no-error.
                                 &else
                                     run value(rpc_program("api_controlar_atualizacao_fatura":U)) persistent set "" (1,input table tt_exec_rpc,input-output v_rec_lote_impl_tit_ap,input-output table tt_lote_impl_erros_fatura) no-error.
                                 &endif
                             end /* else */.
                         end /* if */.        
                     end /* else */.

                     run pi_status_error in v_wgh_servid_rpc.
                 end /* repeat rpc_block */.
                 /* End_Include: i_exec_dispatch_rpc */

             end /* if */.

             /* Begin_Include: i_exec_destroy_rpc */
             run pi_destroy_rpc in v_wgh_servid_rpc ("api_controlar_atualizacao_fatura":U).

             &if '""' <> '""' &then
                 if  valid-handle("") then
                     delete procedure "".
             &endif

             if  valid-handle(v_wgh_servid_rpc) then
                 delete procedure v_wgh_servid_rpc.

             /* End_Include: i_exec_destroy_rpc */

          &endif.



          /* End_Include: i_exec_destroy_rpc */


          /* ** Atualiza‡†o dos Saldos das Contas Correntes SPOOL ***/
          run pi_sdo_cta_corren_spool_modulos.

          assign v_log_method = session:set-wait-state('').

          find first tt_lote_impl_erros_fatura no-lock no-error.
          if  avail tt_lote_impl_erros_fatura
          then do:
              run pi_mostra_erros_lote_impl_fatura /*pi_mostra_erros_lote_impl_fatura*/.
          end /* if */.
          else do:
              if  search("prgfin/apb/apb800zb.r") = ? and search("prgfin/apb/apb800zb.p") = ? then do:
                      return "Programa execut vel n†o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/apb/apb800zb.p".
              end.
              else
                  run prgfin/apb/apb800zb.p (Input v_cod_estab,
                                         Input v_cod_refer) /*prg_fnc_atualiza_epc*/.
          end.
       end.
    END.

END PROCEDURE.


PROCEDURE pi_validar_movtos_dat_transacao_subs:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_num_id_tit_ap
        as integer
        format "9999999999"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_log_erro
        as logical
        format "Sim/NÆo"
        no-undo.


    /************************* Parameter Definition End *************************/

    find  b_tit_ap no-lock
    where b_tit_ap.cod_estab     = p_cod_estab
      and b_tit_ap.num_id_tit_ap = p_num_id_tit_ap no-error.

    if  avail b_tit_ap 
          and b_tit_ap.val_sdo_tit_ap > 0 then do:
        find first b_movto_tit_ap no-lock
             where b_movto_tit_ap.cod_estab            = p_cod_estab
               and b_movto_tit_ap.num_id_tit_ap        = b_tit_ap.num_id_tit_ap
               and b_movto_tit_ap.dat_transacao        > p_dat_transacao
               and (b_movto_tit_ap.log_ctbz_aprop_ctbl 
                OR  b_movto_tit_ap.log_aprop_ctbl_ctbzda)
               and b_movto_tit_ap.log_movto_estordo    = no
               and not b_movto_tit_ap.ind_trans_ap begins "Estorno" /*l_estorno*/    no-error.
        if avail b_movto_tit_ap then
            assign p_log_erro = yes.
    end.   
END PROCEDURE. /* pi_validar_movtos_dat_transacao_subs */



PROCEDURE pi_sdo_cta_corren_spool_modulos:

    /* --- API para Atualiza‡Æo dos Saldos das Contas Correntes SPOOL ---*/
    DO ON ERROR UNDO, RETURN ERROR:
        run prgfin/cmg/cmg709za.py (Input 1) /*prg_api_sdo_cta_corren_spool*/.
    
        if  return-value = '2782' then do:
            PUT UNFORMAT "VersÆo de integra‡Æo incorreta".
            RETURN.
        end.
    
        run pi_sdo_fluxo_cx_spool_modulos /*pi_sdo_fluxo_cx_spool_modulos*/.
    END.
END PROCEDURE. /* pi_sdo_cta_corren_spool_modulos */


PROCEDURE pi_sdo_fluxo_cx_spool_modulos:

    /* --- API para Atualiza‡Æo dos Saldos do Fluxo de Caixa SPOOL ---*/

    DO ON ERROR UNDO, RETURN ERROR:
    /* Manter esta altera‡Æo - Lista de Impacto gerada conforme altera‡Æo nos programas 
       ref. FO 1139356 */

    &if '{&emsfin_version}' >= "5.02" &then
        run prgfin/cfl/cfl704za.py (Input 1) /*prg_api_sdo_fluxo_cx_spool*/.
    &else
        run prgfin/cfl/cfl704zb.py (Input 1) /*prg_api_tab_livre_emsfin_spool_fluxo_cx*/.
    &endif

    if  return-value = '2782' then do:
        PUT UNFORMAT "VersÆo de integra‡Æo incorreta".
        RETURN.
    end.

    END.
END PROCEDURE.


PROCEDURE pi_mostra_erros_lote_impl_fatura:

     PUT UNFORMAT "---------------Erros Implanta‡Æo Fatura---------------------" SKIP.
     PUT UNFORMAT "Estab.: "  + lote_impl_tit_ap.cod_estab SKIP.
     PUT UNFORMAT "Referˆncia: " + lote_impl_tit_ap.cod_refer SKIP(1).

    erros_block:
    for
        each tt_lote_impl_erros_fatura no-lock.
        /* tt_block: */
        case tt_lote_impl_erros_fatura.ttv_cod_erro_atualiz:
            when "1" then block_1:
             do:
                PUT UNFORMAT "Esp‚cie de Documento da Fatura Inexistente !" SKIP.
            end /* do block_1 */.
            when "2" then block_2:
             do:
                PUT UNFORMAT "Fornecedor da Fatura Inexistente !" SKIP.
            end /* do block_2 */.
            when "3" then block_3:
             do:
                PUT UNFORMAT "Conta Saldo p/ Grp Fornec da Fatura inexistente ou invÿlida !" SKIP.
            end /* do block_3 */.
            when "4" then block_4:
             do:
                PUT UNFORMAT "Valor da Fatura difere do valor total da(s) Duplicata(s) !" SKIP.
            end /* do block_4 */.
            when "5" then block_5:
             do:
                PUT UNFORMAT "Quantidade Parc. implantadas difere do informado na Fatura !" SKIP.
            end /* do block_5 */.
            when "6" then block_6:
             do:
                PUT UNFORMAT "Estab.: "  +  tt_lote_impl_erros_fatura.tta_cod_estab SKIP.
                PUT UNFORMAT "Fornec.: "  +  STRING(tt_lote_impl_erros_fatura.tta_cdn_fornecedor) SKIP.
                PUT UNFORMAT "Espec. Docto.: "  +  tt_lote_impl_erros_fatura.tta_cod_espec_docto SKIP.
                PUT UNFORMAT "S‚rie.: "  +  tt_lote_impl_erros_fatura.tta_cod_ser_docto SKIP.
                PUT UNFORMAT "Cod. Tit.: "  +  tt_lote_impl_erros_fatura.tta_cod_tit_ap SKIP.
                PUT UNFORMAT "Nr Parc.: "  +  tt_lote_impl_erros_fatura.tta_cod_parcela SKIP.
                PUT UNFORMAT "Titulo da Nota Fiscal informada na Fatura inexistente !" SKIP.
            end /* do block_6 */.
            when "7" then block_7:
             do:
                PUT UNFORMAT "Estab.: "  +  tt_lote_impl_erros_fatura.tta_cod_estab SKIP.
                PUT UNFORMAT "Fornec.: "  +  STRING(tt_lote_impl_erros_fatura.tta_cdn_fornecedor) SKIP.
                PUT UNFORMAT "Espec. Docto.: "  +  tt_lote_impl_erros_fatura.tta_cod_espec_docto SKIP.
                PUT UNFORMAT "S‚rie.: "  +  tt_lote_impl_erros_fatura.tta_cod_ser_docto SKIP.
                PUT UNFORMAT "Cod. Tit.: "  +  tt_lote_impl_erros_fatura.tta_cod_tit_ap SKIP.
                PUT UNFORMAT "Nr Parc.: "  +  tt_lote_impl_erros_fatura.tta_cod_parcela SKIP.
                PUT UNFORMAT "Titulo da Nota Fiscal informada na Fatura inexistente !" SKIP.
            end /* do block_7 */.
            when "8" then block_8:
             do:
                PUT UNFORMAT "Estab.: "  +  tt_lote_impl_erros_fatura.tta_cod_estab SKIP.
                PUT UNFORMAT "Fornec.: "  +  STRING(tt_lote_impl_erros_fatura.tta_cdn_fornecedor) SKIP.
                PUT UNFORMAT "Espec. Docto.: "  +  tt_lote_impl_erros_fatura.tta_cod_espec_docto SKIP.
                PUT UNFORMAT "S‚rie.: "  +  tt_lote_impl_erros_fatura.tta_cod_ser_docto SKIP.
                PUT UNFORMAT "Cod. Tit.: "  +  tt_lote_impl_erros_fatura.tta_cod_tit_ap SKIP.
                PUT UNFORMAT "Nr Parc.: "  +  tt_lote_impl_erros_fatura.tta_cod_parcela SKIP.
                PUT UNFORMAT "Unid. Negoc. do Estab da Nota diferem das do Estab da Fatura !" SKIP.
            end /* do block_8 */.
            when "9" then block_9:
             do:
                PUT UNFORMAT "Estab.: "  +  tt_lote_impl_erros_fatura.tta_cod_estab SKIP.
                PUT UNFORMAT "Fornec.: "  +  STRING(tt_lote_impl_erros_fatura.tta_cdn_fornecedor) SKIP.
                PUT UNFORMAT "Espec. Docto.: "  +  tt_lote_impl_erros_fatura.tta_cod_espec_docto SKIP.
                PUT UNFORMAT "S‚rie.: "  +  tt_lote_impl_erros_fatura.tta_cod_ser_docto SKIP.
                PUT UNFORMAT "Cod. Tit.: "  +  tt_lote_impl_erros_fatura.tta_cod_tit_ap SKIP.
                PUT UNFORMAT "Nr Parc.: "  +  tt_lote_impl_erros_fatura.tta_cod_parcela SKIP.
                PUT UNFORMAT "Cta Saldo p/ Grp Fornec do Titulo inexistente ou inv lida !" SKIP.
            end /* do block_9 */.
            when "10" then block_10:
             do:
                PUT UNFORMAT "Estab.: "  +  tt_lote_impl_erros_fatura.tta_cod_estab SKIP.
                PUT UNFORMAT "Fornec.: "  +  STRING(tt_lote_impl_erros_fatura.tta_cdn_fornecedor) SKIP.
                PUT UNFORMAT "Espec. Docto.: "  +  tt_lote_impl_erros_fatura.tta_cod_espec_docto SKIP.
                PUT UNFORMAT "S‚rie.: "  +  tt_lote_impl_erros_fatura.tta_cod_ser_docto SKIP.
                PUT UNFORMAT "Cod. Tit.: "  +  tt_lote_impl_erros_fatura.tta_cod_tit_ap SKIP.
                PUT UNFORMAT "Nr Parc.: "  +  tt_lote_impl_erros_fatura.tta_cod_parcela SKIP.
                PUT UNFORMAT "Cta Trans Subst p/ Grp Fornec do Titulo inexist. ou inv lida !" SKIP.
            end /* do block_10 */.
            when "11" then block_11:
             do:
                PUT UNFORMAT "Estab.: "  +  tt_lote_impl_erros_fatura.tta_cod_estab SKIP.
                PUT UNFORMAT "Fornec.: "  +  STRING(tt_lote_impl_erros_fatura.tta_cdn_fornecedor) SKIP.
                PUT UNFORMAT "Espec. Docto.: "  +  tt_lote_impl_erros_fatura.tta_cod_espec_docto SKIP.
                PUT UNFORMAT "S‚rie.: "  +  tt_lote_impl_erros_fatura.tta_cod_ser_docto SKIP.
                PUT UNFORMAT "Cod. Tit.: "  +  tt_lote_impl_erros_fatura.tta_cod_tit_ap SKIP.
                PUT UNFORMAT "Nr Parc.: "  +  tt_lote_impl_erros_fatura.tta_cod_parcela SKIP.
                PUT UNFORMAT "Cta Trans Transf p/ Grp Fornec do Titulo inexist ou inv lida !" SKIP.
            end /* do block_11 */.
            when "12" then block_12:
             do:
                PUT UNFORMAT "Somatorio dos valores das notas difere do total da Fatura !" SKIP.
            end /* do block_12 */.

            when "13" then block_13:
             do:
                PUT UNFORMAT "Valor do t¡tulo menor que o valor indicado na fatura !" SKIP.
            end /* do block_13 */.
            when "14" then block_14:
             do:
                PUT UNFORMAT "T¡tulos possuem datas diferentes p/ œltima corre‡Æo de valor." SKIP.
            end /* do block_14 */.
            when "4144" then block_14:
             do:
                PUT UNFORMAT tt_lote_impl_erros_fatura.ttv_des_msg_erro SKIP.
            end /* do block_14 */.
            when "4145" then block_14:
             do:
                PUT UNFORMAT tt_lote_impl_erros_fatura.ttv_des_msg_erro SKIP.
            end /* do block_14 */.
            when "4146" then block_14:
             do:
                PUT UNFORMAT tt_lote_impl_erros_fatura.ttv_des_msg_erro SKIP.
            end /* do block_14 */.

            when "506" then block_506:
             do:
                PUT UNFORMAT "Estab.: "  +  tt_lote_impl_erros_fatura.tta_cod_estab SKIP.
                PUT UNFORMAT "Fornec.: "  +  STRING(tt_lote_impl_erros_fatura.tta_cdn_fornecedor) SKIP.
                PUT UNFORMAT "Espec. Docto.: "  +  tt_lote_impl_erros_fatura.tta_cod_espec_docto SKIP.
                PUT UNFORMAT "S‚rie.: "  +  tt_lote_impl_erros_fatura.tta_cod_ser_docto SKIP.
                PUT UNFORMAT "Cod. Tit.: "  +  tt_lote_impl_erros_fatura.tta_cod_tit_ap SKIP.
                PUT UNFORMAT "Nr Parc.: "  +  tt_lote_impl_erros_fatura.tta_cod_parcela SKIP.
                PUT UNFORMAT "Portador Inexistente !" SKIP.
            end.
            when "775" then block_6:
             do:
                PUT UNFORMAT "Estab.: "  +  tt_lote_impl_erros_fatura.tta_cod_estab SKIP.
                PUT UNFORMAT "Fornec.: "  +  STRING(tt_lote_impl_erros_fatura.tta_cdn_fornecedor) SKIP.
                PUT UNFORMAT "Espec. Docto.: "  +  tt_lote_impl_erros_fatura.tta_cod_espec_docto SKIP.
                PUT UNFORMAT "S‚rie.: "  +  tt_lote_impl_erros_fatura.tta_cod_ser_docto SKIP.
                PUT UNFORMAT "Cod. Tit.: "  +  tt_lote_impl_erros_fatura.tta_cod_tit_ap SKIP.
                PUT UNFORMAT "Nr Parc.: "  +  tt_lote_impl_erros_fatura.tta_cod_parcela SKIP.
                PUT UNFORMAT "Portador nÆo vinculado ao estabelecimento !" SKIP.
            end.
            when "776" then block_776:
             do:
                PUT UNFORMAT "Estab.: "  +  tt_lote_impl_erros_fatura.tta_cod_estab SKIP.
                PUT UNFORMAT "Fornec.: "  +  STRING(tt_lote_impl_erros_fatura.tta_cdn_fornecedor) SKIP.
                PUT UNFORMAT "Espec. Docto.: "  +  tt_lote_impl_erros_fatura.tta_cod_espec_docto SKIP.
                PUT UNFORMAT "S‚rie.: "  +  tt_lote_impl_erros_fatura.tta_cod_ser_docto SKIP.
                PUT UNFORMAT "Cod. Tit.: "  +  tt_lote_impl_erros_fatura.tta_cod_tit_ap SKIP.
                PUT UNFORMAT "Nr Parc.: "  +  tt_lote_impl_erros_fatura.tta_cod_parcela SKIP.
                PUT UNFORMAT "Finalidade ou Indicador Econ“mico Incorreto para Portador !" SKIP.
            end.
            when "11954" then block_11954:
             do:
                PUT UNFORMAT "Data transa‡Æo estÿ em um per¡odo nÆo habilitado." SKIP.
            end.
            otherwise do:
                PUT UNFORMAT tt_lote_impl_erros_fatura.ttv_cod_erro_atualiz + " - " +
                             tt_lote_impl_erros_fatura.ttv_des_msg_erro SKIP.
            end.
        end /* case tt_block */.
    end /* for erros_block */.

END PROCEDURE. /* pi_mostra_erros_lote_impl_fatura */
