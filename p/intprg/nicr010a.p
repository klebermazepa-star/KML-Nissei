/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i CD9922 2.00.00.017 } /*** 010017 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i cd9922 CDP}
&ENDIF



{include/i_dbvers.i}

def temp-table tt_fat no-undo
    field ttv_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field ttv_cdn_cliente                  as Integer format ">>>,>>>,>>9" label "Cliente" column-label "Cliente"
    field ttv_cod_espec_docto              as character format "x(3)" label "Esp?cie Documento" column-label "Esp?cie"
    field ttv_cod_ser_docto                as character format "x(3)" label "S?rie Docto" column-label "S?rie"
    field ttv_cod_tit_acr                  as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field ttv_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_ind_origin_tit_acr           as character format "X(08)" label "Origem Tit Cta Rec" column-label "Origem Tit Cta Rec"
    field ttv_nom_natur                    as character format "x(30)" label "Natur. de Opera?’o" column-label "Natur. de Opera?’o"
    field ttv_val_orig                     as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    field ttv_dat_emis_docto               as date format "99/99/9999" label "Data Emiss’o" column-label "Dt Emiss’o"
    field ttv_log_cancelado                as logical format "Sim/N’o" initial no label "Cancelado" column-label "Cancelado"
    field ttv_cod_proces_export            as character format "x(10)" label "Processo Exp" column-label "Processo Exp"
    .

def temp-table tt_acr no-undo
    field ttv_dat_trans                    as date format "99/99/9999" initial ?
    field ttv_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field ttv_cdn_cliente                  as Integer format ">>>,>>>,>>9" label "Cliente" column-label "Cliente"
    field ttv_cod_espec_docto              as character format "x(3)" label "Esp?cie Documento" column-label "Esp?cie"
    field ttv_cod_ser_docto                as character format "x(3)" label "S?rie Docto" column-label "S?rie"
    field ttv_cod_tit_acr                  as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field ttv_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_val_origin_tit_acr           as decimal format "->>>,>>>,>>9.99" decimals 2 label "Valor Original" column-label "Valor Original"
    field ttv_val_fgl                      as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    field ttv_log_estordo                  as logical format "Sim/N’o" initial no label "Estornado" column-label "Estornado"
    index tt_codigo                       
          ttv_cod_estab                    ascending
          ttv_cdn_cliente                  ascending
          ttv_cod_espec_docto              ascending
          ttv_cod_ser_docto                ascending
          ttv_cod_tit_acr                  ascending
          ttv_cod_parcela                  ascending
    index tt_ordem                        
          ttv_dat_trans                    ascending
          ttv_cod_tit_acr                  ascending
    index tt_tudo                         
          ttv_dat_trans                    ascending
          ttv_cod_estab                    ascending
          ttv_cdn_cliente                  ascending
          ttv_cod_espec_docto              ascending
          ttv_cod_ser_docto                ascending
          ttv_cod_tit_acr                  ascending
          ttv_cod_parcela                  ascending
    .

def temp-table tt_concil_acr_fat no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp?cie Documento" column-label "Esp?cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S?rie Documento" column-label "S?rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_val_acr                      as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Valor ACR" column-label "Valor ACR"
    field ttv_val_faturam                  as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Valor FAT" column-label "Valor FAT"
    field ttv_val_dif_acr_faturam          as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Valor Diferen?a" column-label "Valor Diferen?a"
    field ttv_log_erro                     as logical format "Sim/N’o" initial yes
    field ttv_des_erro                     as character format "x(50)" label "Inconsist?ncia" column-label "Inconsist?ncia"
    field ttv_num_nota_concil_faturam_dif  as integer format ">>>,>>>,>>9" label "Total FAT"
    field ttv_num_tit_acr_concil           as integer format ">>>,>>>,>>9" label "Total ACR"
    field ttv_num_tit_acr_concil_dif       as integer format ">>>,>>>,>>9" label "Total ACR"
    .

def new global shared var gr-nota-fiscal as rowid no-undo.
def var c-des-msg                        as char  no-undo.
DEF VAR v_num_cont_aux                   AS INT  NO-UNDO.

/*****************************************************************************
** Procedure Interna.....: pi_monta_temp_table_concil_fat
** Descricao.............: pi_monta_temp_table_concil_fat
** Criado por............: fut1090
** Criado em.............: 23/08/2004 14:13:30
** Alterado por..........: fut1090
** Alterado em...........: 23/08/2004 16:32:08
*****************************************************************************/
PROCEDURE pi_monta_temp_table_concil_fat:

    DEF INPUT PARAM p-dat-ini AS DATE.
    DEF INPUT PARAM p-dat-fim AS DATE.
    DEF INPUT PARAM p-estab-ini as char.
    DEF INPUT PARAM p-estab-fim as char.
    DEF input-output PARAM p-num-tot-nota as int.
    DEF input-output PARAM TABLE FOR tt_fat.

    for each nota-fiscal 
       where nota-fiscal.dt-emis-nota  >= p-dat-ini
         and nota-fiscal.dt-emis-nota  <= p-dat-fim
         and nota-fiscal.cod-estabel   >= p-estab-ini
         and nota-fiscal.cod-estabel   <= p-estab-fim
/*          and nota-fiscal.dt-atual-cr   <> ? */
         and nota-fiscal.dt-cancela     = ?
        no-lock:

        if nota-fiscal.emite-duplic = no then
            next.

        for each fat-duplic 
            where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
              and fat-duplic.serie       = nota-fiscal.serie
              and fat-duplic.nr-fatura   = nota-fiscal.nr-nota-fis no-lock:

             create tt_fat.
             assign tt_fat.ttv_cod_estab          = nota-fiscal.cod-estabel  
                    tt_fat.ttv_cod_espec_docto    = fat-duplic.cod-esp      
                    tt_fat.ttv_cod_ser_docto      = fat-duplic.serie  
                    tt_fat.ttv_cod_tit_acr        = fat-duplic.nr-fatura
                    tt_fat.ttv_cod_parcela        = fat-duplic.parcela      
                    tt_fat.ttv_ind_origin_tit_acr = "FAT" /*l_fat*/ 
                    tt_fat.ttv_nom_natur          = nota-fiscal.nat-oper
                    &if "{&mgadm_version}" >= "2.02" &then
                        tt_fat.ttv_val_orig           = fat-duplic.vl-parcela
                    &endif
                    tt_fat.ttv_dat_emis_docto     = nota-fiscal.dt-emis-nota
                    tt_fat.ttv_log_cancelado      = if nota-fiscal.ind-sit-nota = 4 then yes else no
                    p-num-tot-nota                = p-num-tot-nota + 1
                    tt_fat.ttv_cod_proces_export  = nota-fiscal.nr-proc-exp.
        end.
    end.
END PROCEDURE. /* pi_monta_temp_table_concil_fat */
/*****************************************************************************
** Procedure Interna.....: pi_monta_temp_table_concil_fat_lista
** Descricao.............: pi_monta_temp_table_concil_fat_lista
** Criado por............: fut42929
** Criado em.............: 01/02/2013 14:13:30
** Alterado por..........: fut42929
** Alterado em...........: 01/02/2013 16:32:08
*****************************************************************************/
PROCEDURE pi_monta_temp_table_concil_fat_lista:

    DEF INPUT PARAM p-dat-ini AS DATE.
    DEF INPUT PARAM p-dat-fim AS DATE.
    DEF INPUT PARAM p-lista-estab as char.
    DEF input-output PARAM p-num-tot-nota as int.
    DEF input-output PARAM TABLE FOR tt_fat.

    des_estab_block:
    do v_num_cont_aux = 1 to num-entries(p-lista-estab):

        for each nota-fiscal 
           where nota-fiscal.dt-emis-nota  >= p-dat-ini
             and nota-fiscal.dt-emis-nota  <= p-dat-fim
             and nota-fiscal.cod-estabel   = entry(v_num_cont_aux, p-lista-estab)
/*              and nota-fiscal.dt-atual-cr   <> ? */
             and nota-fiscal.dt-cancela     = ?
            no-lock:
    
            if nota-fiscal.emite-duplic = no then
                next.
            
            for each fat-duplic 
                where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
                  and fat-duplic.serie       = nota-fiscal.serie
                  and fat-duplic.nr-fatura   = nota-fiscal.nr-nota-fis no-lock:
    
                 create tt_fat.
                 assign tt_fat.ttv_cod_estab          = nota-fiscal.cod-estabel  
                        tt_fat.ttv_cod_espec_docto    = fat-duplic.cod-esp      
                        tt_fat.ttv_cod_ser_docto      = fat-duplic.serie  
                        tt_fat.ttv_cod_tit_acr        = fat-duplic.nr-fatura
                        tt_fat.ttv_cod_parcela        = fat-duplic.parcela      
                        tt_fat.ttv_ind_origin_tit_acr = "FAT" /*l_fat*/ 
                        tt_fat.ttv_nom_natur          = nota-fiscal.nat-oper
                        &if "{&mgadm_version}" >= "2.02" &then
                            tt_fat.ttv_val_orig           = fat-duplic.vl-parcela
                        &endif
                        tt_fat.ttv_dat_emis_docto     = nota-fiscal.dt-emis-nota
                        tt_fat.ttv_log_cancelado      = if nota-fiscal.ind-sit-nota = 4 then yes else no
                        p-num-tot-nota                = p-num-tot-nota + 1
                        tt_fat.ttv_cod_proces_export  = nota-fiscal.nr-proc-exp.
            end.
        end.
    END.
END PROCEDURE. /* pi_monta_temp_table_concil_fat_lista */
/*****************************************************************************
** Procedure Interna.....: pi_monta_temp_table_concilia_fat
** Descricao.............: pi_monta_temp_table_concilia_fat
** Criado por............: fut1090
** Criado em.............: 23/08/2004 14:13:30
** Alterado por..........: fut1090
** Alterado em...........: 23/08/2004 16:32:08
*****************************************************************************/
PROCEDURE pi_monta_temp_table_concilia_fat:

    DEF INPUT PARAM p-dat-ini AS DATE.
    DEF INPUT PARAM p-dat-fim AS DATE.
    DEF INPUT PARAM p-cod-estab-ini as char.
    DEF INPUT PARAM p-cod-estab-fim as char.
    DEF input PARAM TABLE FOR tt_acr.
    DEF input PARAM TABLE FOR tt_fat.
    DEF INPUT PARAM p_hdl_prog_ems5 AS HANDLE.
    DEF input-output PARAM TABLE FOR tt_concil_acr_fat.
    DEF input-output PARAM p_val_tit_acr_concil AS DECIMAL.
    DEF input-output PARAM p_val_tot_nota_concil_faturam AS DECIMAL.

    DEF VAR v-cod-estab-ext                     AS CHARACTER NO-UNDO.
    DEF VAR v_cod_estab_aux                     AS CHARACTER NO-UNDO.
    DEF VAR v_log_nota                          AS LOGICAL   NO-UNDO.
    DEF VAR v_log_fatur                         AS LOGICAL   NO-UNDO.

    
    tt_acr_block:
    for each tt_acr:
        if not can-find (first tt_concil_acr_fat 
            where tt_concil_acr_fat.tta_cod_estab = tt_acr.ttv_cod_estab
            and   tt_concil_acr_fat.tta_cod_espec_docto = tt_acr.ttv_cod_espec_docto
            and   tt_concil_acr_fat.tta_cod_ser_docto = tt_acr.ttv_cod_ser_docto
            and   tt_concil_acr_fat.tta_cod_tit_acr = tt_acr.ttv_cod_tit_acr
            and   tt_concil_acr_fat.tta_cod_parcela = tt_acr.ttv_cod_parcela ) then do:

            run pi_traduz_estabelecimento in p_hdl_prog_ems5 (input  1,
                                                              input  tt_acr.ttv_cod_estab,
                                                              output v-cod-estab-ext).

            run utp/ut-msgs.p(input 'msg', 
                              input 46078,
                              input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                                 " ")).
            assign c-des-msg = return-value.

            if v-cod-estab-ext = "" then do:
                create tt_concil_acr_fat.
                assign tt_concil_acr_fat.tta_cod_estab = tt_acr.ttv_cod_estab
                       tt_concil_acr_fat.tta_cod_espec_docto = tt_acr.ttv_cod_espec_docto
                       tt_concil_acr_fat.tta_cod_ser_docto   = tt_acr.ttv_cod_ser_docto
                       tt_concil_acr_fat.tta_cod_tit_acr     = tt_acr.ttv_cod_tit_acr
                       tt_concil_acr_fat.tta_cod_parcela     = tt_acr.ttv_cod_parcela
                       tt_concil_acr_fat.ttv_log_erro = yes
                       tt_concil_acr_fat.ttv_des_erro = c-des-msg.
                next.
            end.
            create tt_concil_acr_fat.
            assign tt_concil_acr_fat.tta_cod_estab = tt_acr.ttv_cod_estab
                   tt_concil_acr_fat.tta_cod_espec_docto = tt_acr.ttv_cod_espec_docto
                   tt_concil_acr_fat.tta_cod_ser_docto   = tt_acr.ttv_cod_ser_docto
                   tt_concil_acr_fat.tta_cod_tit_acr     = tt_acr.ttv_cod_tit_acr
                   tt_concil_acr_fat.tta_cod_parcela     = tt_acr.ttv_cod_parcela
                   tt_concil_acr_fat.ttv_val_acr = 0
                   tt_concil_acr_fat.ttv_val_faturam = 0
                   tt_concil_acr_fat.ttv_val_dif_acr_faturam = 0
                   tt_concil_acr_fat.ttv_log_erro = no.

            find first tt_fat
                 where tt_fat.ttv_cod_estab   =  v-cod-estab-ext
                 and   tt_fat.ttv_cod_esp     =  tt_acr.ttv_cod_esp
                 and   tt_fat.ttv_cod_ser     =  tt_acr.ttv_cod_ser
                 and   tt_fat.ttv_cod_tit_acr =  tt_acr.ttv_cod_tit_acr
                 and   tt_fat.ttv_cod_parcela =  tt_acr.ttv_cod_parcela no-error.
            if  not avail tt_fat then do:
                assign v_log_nota = no
                       v_log_fatur = no.
                for each fat-duplic no-lock
                   where fat-duplic.cod-estabel  = v-cod-estab-ext
                   and   fat-duplic.serie        = tt_acr.ttv_cod_ser_docto
                   and   fat-duplic.nr-fatura    = tt_acr.ttv_cod_tit_acr
                   and   fat-duplic.ind-fat-nota = 1
                   and   fat-duplic.cod-esp      = tt_acr.ttv_cod_espec_docto
                   and   fat-duplic.parcela      = tt_acr.ttv_cod_parcela:
                   find nota-fiscal no-lock
                       where nota-fiscal.cod-estabel = fat-duplic.cod-estabel
                       and   nota-fiscal.serie       = fat-duplic.serie
                       and   nota-fiscal.nr-nota-fis = fat-duplic.nr-fatura no-error.
                   if avail nota-fiscal then do:
                        if nota-fiscal.dt-emis-nota  < p-dat-ini
                        or nota-fiscal.dt-emis-nota  > p-dat-fim then do:

                            run utp/ut-msgs.p(input 'help', 
                                              input 52768,
                                              input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                              string(nota-fiscal.dt-emis-nota))).
                            assign c-des-msg = return-value.

                            assign tt_concil_acr_fat.ttv_log_erro = yes
                                   tt_concil_acr_fat.ttv_des_erro = c-des-msg
                                   tt_concil_acr_fat.ttv_val_faturam = fat-duplic.vl-parcela
                                   tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                                   tt_concil_acr_fat.ttv_val_dif_acr_faturam = fat-duplic.vl-parcela - tt_acr.ttv_val_origin_tit_acr
                                   p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                                   p_val_tot_nota_concil_faturam = p_val_tot_nota_concil_faturam + fat-duplic.vl-parcela.
                        end.
                        run pi_traduz_estabelecimento in p_hdl_prog_ems5 (input  2,
                                                                          input  nota-fiscal.cod-estabel,
                                                                          output v_cod_estab_aux).
                        if v_cod_estab_aux < p-cod-estab-ini
                        or v_cod_estab_aux > p-cod-estab-fim then do:

                            run utp/ut-msgs.p(input 'help', 
                                              input 52769,
                                              input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                              string(nota-fiscal.cod-estabel))).
                            assign c-des-msg = return-value.

                            assign tt_concil_acr_fat.ttv_log_erro = yes
                                   tt_concil_acr_fat.ttv_des_erro = c-des-msg
                                   tt_concil_acr_fat.ttv_val_faturam = fat-duplic.vl-parcela
                                   tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                                   tt_concil_acr_fat.ttv_val_dif_acr_faturam = fat-duplic.vl-parcela - tt_acr.ttv_val_origin_tit_acr
                                   p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                                   p_val_tot_nota_concil_faturam = p_val_tot_nota_concil_faturam + fat-duplic.vl-parcela.
                        end.
                        if nota-fiscal.dt-cancela <> ? then do:
                            if not tt_acr.ttv_log_estordo then do:

                                run utp/ut-msgs.p(input 'help', 
                                                  input 52770,
                                                  input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                                  " ")).
                                assign c-des-msg = return-value.

                                assign tt_concil_acr_fat.ttv_log_erro = yes
                                       tt_concil_acr_fat.ttv_des_erro = c-des-msg
                                       tt_concil_acr_fat.ttv_val_faturam = 0
                                       tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                                       tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_acr.ttv_val_origin_tit_acr
                                       p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr.
                            end.
                            else do:
                                delete tt_concil_acr_fat.
                                next tt_acr_block.
                            end.
                        end.
                        assign v_log_nota = yes.
                   end.
                   assign v_log_fatur = yes.
                end.
                if not v_log_nota THEN DO:
                    
                    run utp/ut-msgs.p(input 'help', 
                                      input 52771,
                                      input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                      " ")).
                    assign c-des-msg = return-value.

                    assign tt_concil_acr_fat.ttv_log_erro = yes
                           tt_concil_acr_fat.ttv_des_erro = c-des-msg
                           tt_concil_acr_fat.ttv_val_faturam = 0
                           tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                           tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_acr.ttv_val_origin_tit_acr
                           p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr.
                END.
                ELSE DO:

                    run utp/ut-msgs.p(input 'help', 
                                      input 52772,
                                      input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                      " ")).
                    assign c-des-msg = return-value.

                    if not v_log_fatur then
                        assign tt_concil_acr_fat.ttv_log_erro = yes
                               tt_concil_acr_fat.ttv_des_erro = c-des-msg
                               tt_concil_acr_fat.ttv_val_faturam = 0
                               tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                               tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_acr.ttv_val_origin_tit_acr
                               p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr.
                END.
            end.
            else do:

                run utp/ut-msgs.p(input 'help', 
                                  input 52773,
                                  input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                  STRING(tt_acr.ttv_val_origin_tit_acr, '-zzzz,zzz,zz9.99'),
                                  STRING(tt_fat.ttv_val_orig, '-zzzz,zzz,zz9.99'))).
                assign c-des-msg = return-value.

                if  tt_fat.ttv_val_orig <> tt_acr.ttv_val_orig then do:
                    assign tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_orig
                           tt_concil_acr_fat.ttv_val_faturam = tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_fat.ttv_val_orig - tt_acr.ttv_val_orig
                           tt_concil_acr_fat.ttv_log_erro = yes
                           tt_concil_acr_fat.ttv_des_erro = c-des-msg
                           p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                           p_val_tot_nota_concil_faturam = p_val_tot_nota_concil_faturam + tt_fat.ttv_val_orig.
                end.
                else do:
                    assign tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                           tt_concil_acr_fat.ttv_val_faturam  = tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_log_erro = no
                           tt_concil_acr_fat.ttv_des_erro = 'Integra?’o OK'
                           p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                           p_val_tot_nota_concil_faturam = p_val_tot_nota_concil_faturam + tt_fat.ttv_val_orig.
                end.
            end.
        end.
    end.
END PROCEDURE. /* pi_monta_temp_table_concil_acr_fat */
/*****************************************************************************
** Procedure Interna.....: pi_monta_temp_table_concilia_fat_lista
** Descricao.............: pi_monta_temp_table_concilia_fat_lista
** Criado por............: fut1090
** Criado em.............: 23/08/2004 14:13:30
** Alterado por..........: fut1090
** Alterado em...........: 23/08/2004 16:32:08
*****************************************************************************/
PROCEDURE pi_monta_temp_table_concilia_fat_lista:

    DEF INPUT PARAM p-dat-ini AS DATE.
    DEF INPUT PARAM p-dat-fim AS DATE.
    DEF INPUT PARAM p-lista-estab as char.
    DEF input PARAM TABLE FOR tt_acr.
    DEF input PARAM TABLE FOR tt_fat.
    DEF INPUT PARAM p_hdl_prog_ems5 AS HANDLE.
    DEF input-output PARAM TABLE FOR tt_concil_acr_fat.
    DEF input-output PARAM p_val_tit_acr_concil AS DECIMAL.
    DEF input-output PARAM p_val_tot_nota_concil_faturam AS DECIMAL.

    DEF VAR v-cod-estab-ext                     AS CHARACTER NO-UNDO.
    DEF VAR v_cod_estab_aux                     AS CHARACTER NO-UNDO.
    DEF VAR v_log_nota                          AS LOGICAL   NO-UNDO.
    DEF VAR v_log_fatur                         AS LOGICAL   NO-UNDO.

    
    tt_acr_block:
    for each tt_acr:
        if not can-find (first tt_concil_acr_fat 
            where tt_concil_acr_fat.tta_cod_estab = tt_acr.ttv_cod_estab
            and   tt_concil_acr_fat.tta_cod_espec_docto = tt_acr.ttv_cod_espec_docto
            and   tt_concil_acr_fat.tta_cod_ser_docto = tt_acr.ttv_cod_ser_docto
            and   tt_concil_acr_fat.tta_cod_tit_acr = tt_acr.ttv_cod_tit_acr
            and   tt_concil_acr_fat.tta_cod_parcela = tt_acr.ttv_cod_parcela ) then do:

            run pi_traduz_estabelecimento in p_hdl_prog_ems5 (input  1,
                                                              input  tt_acr.ttv_cod_estab,
                                                              output v-cod-estab-ext).

            run utp/ut-msgs.p(input 'msg', 
                              input 46078,
                              input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                                 " ")).
            assign c-des-msg = return-value.

            if v-cod-estab-ext = "" then do:
                create tt_concil_acr_fat.
                assign tt_concil_acr_fat.tta_cod_estab = tt_acr.ttv_cod_estab
                       tt_concil_acr_fat.tta_cod_espec_docto = tt_acr.ttv_cod_espec_docto
                       tt_concil_acr_fat.tta_cod_ser_docto   = tt_acr.ttv_cod_ser_docto
                       tt_concil_acr_fat.tta_cod_tit_acr     = tt_acr.ttv_cod_tit_acr
                       tt_concil_acr_fat.tta_cod_parcela     = tt_acr.ttv_cod_parcela
                       tt_concil_acr_fat.ttv_log_erro = yes
                       tt_concil_acr_fat.ttv_des_erro = c-des-msg.
                next.
            end.
            create tt_concil_acr_fat.
            assign tt_concil_acr_fat.tta_cod_estab = tt_acr.ttv_cod_estab
                   tt_concil_acr_fat.tta_cod_espec_docto = tt_acr.ttv_cod_espec_docto
                   tt_concil_acr_fat.tta_cod_ser_docto   = tt_acr.ttv_cod_ser_docto
                   tt_concil_acr_fat.tta_cod_tit_acr     = tt_acr.ttv_cod_tit_acr
                   tt_concil_acr_fat.tta_cod_parcela     = tt_acr.ttv_cod_parcela
                   tt_concil_acr_fat.ttv_val_acr = 0
                   tt_concil_acr_fat.ttv_val_faturam = 0
                   tt_concil_acr_fat.ttv_val_dif_acr_faturam = 0
                   tt_concil_acr_fat.ttv_log_erro = no.

            find first tt_fat
                 where tt_fat.ttv_cod_estab   =  v-cod-estab-ext
                 and   tt_fat.ttv_cod_esp     =  tt_acr.ttv_cod_esp
                 and   tt_fat.ttv_cod_ser     =  tt_acr.ttv_cod_ser
                 and   tt_fat.ttv_cod_tit_acr =  tt_acr.ttv_cod_tit_acr
                 and   tt_fat.ttv_cod_parcela =  tt_acr.ttv_cod_parcela no-error.
            if  not avail tt_fat then do:
                assign v_log_nota = no
                       v_log_fatur = no.
                for each fat-duplic no-lock
                   where fat-duplic.cod-estabel  = v-cod-estab-ext
                   and   fat-duplic.serie        = tt_acr.ttv_cod_ser_docto
                   and   fat-duplic.nr-fatura    = tt_acr.ttv_cod_tit_acr
                   and   fat-duplic.ind-fat-nota = 1
                   and   fat-duplic.cod-esp      = tt_acr.ttv_cod_espec_docto
                   and   fat-duplic.parcela      = tt_acr.ttv_cod_parcela:
                   find nota-fiscal no-lock
                       where nota-fiscal.cod-estabel = fat-duplic.cod-estabel
                       and   nota-fiscal.serie       = fat-duplic.serie
                       and   nota-fiscal.nr-nota-fis = fat-duplic.nr-fatura no-error.
                   if avail nota-fiscal then do:
                        if nota-fiscal.dt-emis-nota  < p-dat-ini
                        or nota-fiscal.dt-emis-nota  > p-dat-fim then do:

                            run utp/ut-msgs.p(input 'help', 
                                              input 52768,
                                              input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                              string(nota-fiscal.dt-emis-nota))).
                            assign c-des-msg = return-value.

                            assign tt_concil_acr_fat.ttv_log_erro = yes
                                   tt_concil_acr_fat.ttv_des_erro = c-des-msg
                                   tt_concil_acr_fat.ttv_val_faturam = fat-duplic.vl-parcela
                                   tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                                   tt_concil_acr_fat.ttv_val_dif_acr_faturam = fat-duplic.vl-parcela - tt_acr.ttv_val_origin_tit_acr
                                   p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                                   p_val_tot_nota_concil_faturam = p_val_tot_nota_concil_faturam + fat-duplic.vl-parcela.
                        end.
                        
                        if lookup(nota-fiscal.cod-estabel, p-lista-estab) = 0 THEN DO:

                            run utp/ut-msgs.p(input 'help', 
                                              input 52769,
                                              input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                              string(nota-fiscal.cod-estabel))).
                            assign c-des-msg = return-value.

                            assign tt_concil_acr_fat.ttv_log_erro = yes
                                   tt_concil_acr_fat.ttv_des_erro = c-des-msg
                                   tt_concil_acr_fat.ttv_val_faturam = fat-duplic.vl-parcela
                                   tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                                   tt_concil_acr_fat.ttv_val_dif_acr_faturam = fat-duplic.vl-parcela - tt_acr.ttv_val_origin_tit_acr
                                   p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                                   p_val_tot_nota_concil_faturam = p_val_tot_nota_concil_faturam + fat-duplic.vl-parcela.
                        end.
                        if nota-fiscal.dt-cancela <> ? then do:
                            if not tt_acr.ttv_log_estordo then do:

                                run utp/ut-msgs.p(input 'help', 
                                                  input 52770,
                                                  input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                                  " ")).
                                assign c-des-msg = return-value.

                                assign tt_concil_acr_fat.ttv_log_erro = yes
                                       tt_concil_acr_fat.ttv_des_erro = c-des-msg
                                       tt_concil_acr_fat.ttv_val_faturam = 0
                                       tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                                       tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_acr.ttv_val_origin_tit_acr
                                       p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr.
                            end.
                            else do:
                                delete tt_concil_acr_fat.
                                next tt_acr_block.
                            end.
                        end.
                        assign v_log_nota = yes.
                   end.
                   assign v_log_fatur = yes.
                end.
                if not v_log_nota THEN DO:
                    
                    run utp/ut-msgs.p(input 'help', 
                                      input 52771,
                                      input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                      " ")).
                    assign c-des-msg = return-value.

                    assign tt_concil_acr_fat.ttv_log_erro = yes
                           tt_concil_acr_fat.ttv_des_erro = c-des-msg
                           tt_concil_acr_fat.ttv_val_faturam = 0
                           tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                           tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_acr.ttv_val_origin_tit_acr
                           p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr.
                END.
                ELSE DO:

                    run utp/ut-msgs.p(input 'help', 
                                      input 52772,
                                      input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                      " ")).
                    assign c-des-msg = return-value.

                    if not v_log_fatur then
                        assign tt_concil_acr_fat.ttv_log_erro = yes
                               tt_concil_acr_fat.ttv_des_erro = c-des-msg
                               tt_concil_acr_fat.ttv_val_faturam = 0
                               tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                               tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_acr.ttv_val_origin_tit_acr
                               p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr.
                END.
            end.
            else do:

                run utp/ut-msgs.p(input 'help', 
                                  input 52773,
                                  input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                  STRING(tt_acr.ttv_val_origin_tit_acr, '-zzzz,zzz,zz9.99'),
                                  STRING(tt_fat.ttv_val_orig, '-zzzz,zzz,zz9.99'))).
                assign c-des-msg = return-value.

                if  tt_fat.ttv_val_orig <> tt_acr.ttv_val_orig then do:
                    assign tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_orig
                           tt_concil_acr_fat.ttv_val_faturam = tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_fat.ttv_val_orig - tt_acr.ttv_val_orig
                           tt_concil_acr_fat.ttv_log_erro = yes
                           tt_concil_acr_fat.ttv_des_erro = c-des-msg
                           p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                           p_val_tot_nota_concil_faturam = p_val_tot_nota_concil_faturam + tt_fat.ttv_val_orig.
                end.
                else do:
                    assign tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                           tt_concil_acr_fat.ttv_val_faturam  = tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_log_erro = no
                           tt_concil_acr_fat.ttv_des_erro = 'Integra?’o OK'
                           p_val_tit_acr_concil = p_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                           p_val_tot_nota_concil_faturam = p_val_tot_nota_concil_faturam + tt_fat.ttv_val_orig.
                end.
            end.
        end.
    end.
END PROCEDURE. /* pi_monta_temp_table_concil_acr_fat_lista */
/*****************************************************************************
** Procedure Interna.....: pi_detalhe_nota_fiscal
** Descricao.............: pi_detalhe_nota_fiscal
** Criado por............: fut1090
** Criado em.............: 23/08/2004 14:13:30
** Alterado por..........: fut1090
** Alterado em...........: 23/08/2004 16:32:08
*****************************************************************************/
PROCEDURE pi_detalhe_nota_fiscal:

    DEF INPUT PARAM p_cod_estab AS char.
    DEF INPUT PARAM p_cod_espec as char.
    DEF INPUT PARAM p_cod_ser as char.
    DEF INPUT PARAM p_nr_fatura as char.
    DEF INPUT PARAM p_parcela as char.
    DEF INPUT PARAM p_hdl_prog_ems5 AS HANDLE.

    def var v-cod-estab-ext as char.
    
    run pi_traduz_estabelecimento in p_hdl_prog_ems5 (input  1,
                                                      input  p_cod_estab,
                                                      output v-cod-estab-ext).
    
    if v-cod-estab-ext <> "" then do:
        find first fat-duplic no-lock
            where fat-duplic.cod-estabel = v-cod-estab-ext
              and fat-duplic.serie       = p_cod_ser
              and fat-duplic.nr-fatura   = p_nr_fatura
              and fat-duplic.parcela     = p_parcela no-error.
        if avail fat-duplic then do:
            find first nota-fiscal no-lock
                where nota-fiscal.cod-estabel = fat-duplic.cod-estabel
                and   nota-fiscal.serie = fat-duplic.serie
                and   nota-fiscal.nr-nota-fis = fat-duplic.nr-fatura no-error.
            if avail nota-fiscal then do:
                assign gr-nota-fiscal = rowid(nota-fiscal).
                run ftp/ft0904B.r.
            end.
        end.
    end.

END PROCEDURE. /* pi_detalhe_nota_fiscal */
/*****************************************************************************
** Procedure Interna.....: pi_valida_conta_transitoria
** Descricao.............: pi_valida_conta_transitoria
** Criado por............: fut42929
** Criado em.............: 28/02/2013 14:13:30
** Alterado por..........: fut42929
** Alterado em...........: 28/02/2013 16:32:08
*****************************************************************************/
PROCEDURE pi_valida_conta_transitoria:

    DEF INPUT  PARAM p_cod_estab AS char.
    DEF INPUT  PARAM p_cod_conta as char.
    DEF OUTPUT PARAM p_log_conta_transitoria AS LOG.
    
    ASSIGN p_log_conta_transitoria = NO.
    
    des_estab_block:
    DO v_num_cont_aux = 1 TO NUM-ENTRIES(p_cod_estab):

        FIND FIRST estabelec
             WHERE estabelec.cod-estabel = entry(v_num_cont_aux, p_cod_estab)
               AND estabelec.ct-recven   = p_cod_conta NO-LOCK NO-ERROR.
        IF AVAIL estabelec THEN DO:
            ASSIGN p_log_conta_transitoria = YES.
            RETURN.
        END.
        
        FIND FIRST conta-ft
             WHERE conta-ft.cod-estabel = entry(v_num_cont_aux, p_cod_estab)
               AND conta-ft.ct-recven   = p_cod_conta NO-LOCK NO-ERROR.
        IF AVAIL conta-ft THEN DO:
            ASSIGN p_log_conta_transitoria = YES.
            RETURN.
        END.
            
        FIND FIRST estab-mat
             WHERE estab-mat.cod-estabel          = entry(v_num_cont_aux, p_cod_estab)
               AND estab-mat.cod-cta-devol-c-unif = p_cod_conta NO-LOCK NO-ERROR.
        IF AVAIL estab-mat THEN DO:
            ASSIGN p_log_conta_transitoria = YES.
            RETURN.
        END.
    END.

END PROCEDURE. /* pi_valida_conta_transitoria */
