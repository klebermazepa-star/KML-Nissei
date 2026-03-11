{\\192.168.200.53\datasul\_custom_teste\export.i}
def var v-arquivo as char no-undo.
define buffer bportador for emsbas.portador.
define buffer bcart_bcia for cart_bcia.
define buffer binstruc_bcia for instruc_bcia.
define buffer cliente for emsbas.cliente.
define buffer portador for emsbas.portador.

SYSTEM-DIALOG GET-FILE v-arquivo  FILTERS "*.txt" "*.txt"  ask-overwrite  SAVE-AS TITLE "Arquivo de Sa¡da (.txt)".

if v-arquivo <> "" then do:
    if num-entries (v-arquivo,'.') < 2 then 
        v-arquivo = v-arquivo + ".txt".
    output to value(v-arquivo).
    put unformatted
        "Empresa|Cliente |Nome|Pessoa|Nome Abreviado|Pais|ID Federal|Grp Clien |Descricao|Tipo Clien|"
        "Data Implantacao|Replic E HCM|Replic E GPS|Replic E CRM|Replic E FIN| Replic E ERP|"
        "Portador| Nome Port|Port Preferenc|Nome Port Preferen|Representante| Nome Repres|Carteira| "
        "Desc Carteira|Carteira Preferencia| Desc CArt Preferen|Classif Msg Cobr|Instrucaoo 1| Descr Instrucao Bcia 1|"
        "Instrucaoo 2| Descr Instrucao Bcia 2|Banco|Agencia|Dig Ag| Tipo Cliente| Descr Tipo Cliente|"
        "Tipo Fluxo Financ|Sit Cliente|Dias Atraso|Valor Minimo Av Deb|Verba Pub| Percentual Verba|"
        "Envio Banco Historic| Emitir Boleto |Gerar AD| Retem Imposto| Debito Auto| Calcula Multa| Env SERASA|"
        "Qtd Tit Abert|"
        "Nome|ID Federal|ID Estadual|ID Municipal|Id Previdencia|Fins Lucrativos|Matriz| Endereco|Complemento|Bairro|"
        "Cidade|Condado|Pais|UF|CEP|Caixa Postal|Telefone|FAX|Ramal Fax|TELEX|Modem|Ramal Modem|E-Mail|E-Mail Cobranca|"
        "Pessoa Jur Cobr|Endereco Cobranca|Complemento|Bairro Cobranca|Cidade Cobranca|Condado Cobranca|"
        "UF Cobr|Pais Cobranca| CEP Cobranca|Caixa Postal Cobranc| Pessoa Jurid Pagto|Endereco Pagto|"
        "Complemento|Bairro Pagto|Cidade Pagto|Condado Pagto |UF Pagto| Pais Pagto| CEP Pagto|Cx Postal Pagto|"
        "Anotacao Tabela|Tipo Pessoa| Tipo Capital| Home Page|Endereco Compl.|End Cobranca Compl|End Pagto Compl.|"
        "Envio Banco Historic| Nat Pessoa|Nome Fantasia |Microrregiao Vendas| Replic P HCM| Replic P CRM|"
        "Replic P GPS| FAX 2|Ramal Fax 2| Telefone 2| Ramal 2|"
        skip.
end.
else return.

for each cliente no-lock where cliente.cod_empresa = "1" and
    cliente.cdn_Cliente >= 3040030:
    for first clien_financ no-lock of cliente: end.
    for first pessoa_jurid no-lock where 
        pessoa_jurid.num_pessoa_jurid = cliente.num_pessoa: end.
    if not avail pessoa_jurid then next.
    for first grp_clien no-lock where 
        grp_clien.cod_grp_clien = cliente.cod_grp_clien: end.
    

        put unformatted
            Cliente.cod_empresa                      "|"
            Cliente.cdn_Cliente                      "|"
            Cliente.nom_pessoa                       "|"
            Cliente.num_pessoa                       "|"
            Cliente.nom_abrev                        "|"
            Cliente.cod_pais                         "|"
            Cliente.cod_id_feder format "99.999.999/9999-99"  "|" 
            Cliente.cod_grp_clien                    "|" 
            grp_clien.des_grp_clien                         "|" 
            Cliente.cod_tip_clien                    "|" 
            Cliente.dat_impl_clien                   "|" 
            Cliente.log_replic_emit_hcm              "|" 
            Cliente.log_replic_emit_gps              "|" 
            Cliente.log_replic_emit_crm              "|" 
            Cliente.log_replic_emit_financ           "|" 
            Cliente.log_replic_emit_erp              "|" 
            .
    if avail clien_financ then do:
        for first portador no-lock where 
            portador.cod_portador = clien_financ.cod_portador: end.
        for first bportador no-lock where 
            bportador.cod_portador = clien_financ.cod_portad_prefer: end.

        for first tip_clien no-lock where 
            tip_clien.cod_empresa = clien_financ.cod_empresa and
            tip_clien.cod_tip_clien = clien_financ.cod_tip_clien: end.

        for first representante no-lock where 
            representante.cod_empresa = clien_financ.cod_empresa and
            representante.cdn_repres = clien_financ.cdn_repres: end.

        for first cart_bcia no-lock where 
            cart_bcia.cod_cart_bcia = clien_financ.cod_cart_bcia: end.

        for first bcart_bcia no-lock where 
            bcart_bcia.cod_cart_bcia = clien_financ.cod_cart_bcia_prefer: end.

        for first instruc_bcia no-lock where 
            instruc_bcia.cod_instruc_bcia = clien_financ.cod_instruc_bcia_1_acr: end.

        for first binstruc_bcia no-lock where 
            binstruc_bcia.cod_instruc_bcia = clien_financ.cod_instruc_bcia_2_acr: end.

        put unformatted
            clien_financ.cod_portador                       "|"
           (if avail portador 
            then portador.nom_abrev                       
            else "N/D")                                     "|"
            clien_financ.cod_portad_prefer                  "|"
           (if avail bportador 
            then bportador.nom_abrev                       
            else "N/D")                                     "|"
            clien_financ.cdn_repres                         "|"
           (if avail representante 
            then representante.nom_abrev     
            else "N/D")                                     "|"
            clien_financ.cod_cart_bcia                      "|"
           (if avail cart_bcia 
            then cart_bcia.des_cart_bcia
            else "N/D")                                     "|"
            clien_financ.cod_cart_bcia_prefer               "|"
           (if avail bcart_bcia 
            then bcart_bcia.des_cart_bcia
            else "N/D")                                     "|"
            clien_financ.cod_classif_msg_cobr               "|"
            clien_financ.cod_instruc_bcia_1_acr             "|"
           (if avail instruc_bcia 
            then instruc_bcia.des_instruc_bcia
            else "N/D")                                     "|"
            clien_financ.cod_instruc_bcia_2_acr             "|"
           (if avail binstruc_bcia 
            then binstruc_bcia.des_instruc_bcia
            else "N/D")                                     "|"
            clien_financ.cod_banco                          "|"
            clien_financ.cod_agenc_bcia                     "|"
            clien_financ.cod_digito_agenc_bcia              "|"
            clien_financ.cod_tip_clien                      "|"
           (if avail tip_clien 
            then tip_clien.des_tip_clien 
            else "N/D")                                     "|"
            clien_financ.cod_tip_fluxo_financ               "|"
            clien_financ.ind_sit_clien_perda_dedut          "|"
            clien_financ.num_dias_atraso_avdeb              "|"
            clien_financ.val_min_avdeb                      "|" 
            clien_financ.log_utiliz_verba                   "|"
            clien_financ.val_perc_verba                     "|"
            clien_financ.log_envio_bco_histor               "|" 
            clien_financ.log_habilit_emis_boleto            "|" 
            clien_financ.log_habilit_gera_avdeb             "|" 
            clien_financ.log_retenc_impto                   "|" 
            clien_financ.log_habilit_db_autom               "|" 
            clien_financ.log_calc_multa                     "|" 
            clien_financ.log_envdo_serasa                   "|" 
            clien_financ.num_tit_acr_aber                   "|" 
            .                                                
    end.                                                        
    else do:                                                    
        put unformatted fill("|",34).
    end.
    put unformatted
            pessoa_jurid.nom_pessoa                             "|" 
            pessoa_jurid.cod_id_feder format "99.999.999/9999-99"  "|" 
            pessoa_jurid.cod_id_estad_jurid                     "|" 
            pessoa_jurid.cod_id_munic_jurid                     "|" 
            pessoa_jurid.cod_id_previd_social                   "|" 
            pessoa_jurid.log_fins_lucrat                        "|" 
            pessoa_jurid.num_pessoa_jurid_matriz                "|" 
            pessoa_jurid.nom_endereco             "|" 
            pessoa_jurid.nom_ender_compl          "|" 
            pessoa_jurid.nom_bairro                             "|" 
            pessoa_jurid.nom_cidade                             "|" 
            pessoa_jurid.nom_condado                            "|" 
            pessoa_jurid.cod_pais                               "|" 
            pessoa_jurid.cod_unid_federac                       "|" 
            pessoa_jurid.cod_cep                                "|" 
            pessoa_jurid.cod_cx_post                            "|" 
            pessoa_jurid.cod_telefone                           "|" 
            pessoa_jurid.cod_fax                                "|" 
            pessoa_jurid.cod_ramal_fax                          "|" 
            pessoa_jurid.cod_telex                              "|" 
            pessoa_jurid.cod_modem                              "|" 
            pessoa_jurid.cod_ramal_modem                        "|" 
            pessoa_jurid.cod_e_mail                             "|" 
            pessoa_jurid.cod_e_mail_cobr                        "|" 
            pessoa_jurid.num_pessoa_jurid_cobr                  "|" 
            pessoa_jurid.nom_ender_cobr           "|" 
            pessoa_jurid.nom_ender_compl_cobr     "|" 
            pessoa_jurid.nom_bairro_cobr                        "|" 
            pessoa_jurid.nom_cidad_cobr                         "|" 
            pessoa_jurid.nom_condad_cobr                        "|" 
            pessoa_jurid.cod_unid_federac_cobr                  "|" 
            pessoa_jurid.cod_pais_cobr                          "|" 
            pessoa_jurid.cod_cep_cobr                           "|" 
            pessoa_jurid.cod_cx_post_cobr                       "|" 
            pessoa_jurid.num_pessoa_jurid_pagto                 "|" 
            pessoa_jurid.nom_ender_pagto          "|" 
            pessoa_jurid.nom_ender_compl_pagto    "|" 
            pessoa_jurid.nom_bairro_pagto                       "|" 
            pessoa_jurid.nom_cidad_pagto                        "|" 
            pessoa_jurid.nom_condad_pagto                       "|" 
            pessoa_jurid.cod_unid_federac_pagto                 "|" 
            pessoa_jurid.cod_pais_pagto                         "|" 
            pessoa_jurid.cod_cep_pagto                          "|" 
            pessoa_jurid.cod_cx_post_pagto                      "|" 
            pessoa_jurid.des_anot_tab                           "|" 
            pessoa_jurid.ind_tip_pessoa_jurid                   "|" 
            pessoa_jurid.ind_tip_capit_pessoa_jurid             "|" 
            pessoa_jurid.nom_home_page                          "|" 
            PrintChar(pessoa_jurid.nom_ender_text)              "|" 
            PrintChar(pessoa_jurid.nom_ender_cobr_text)         "|" 
            PrintChar(pessoa_jurid.nom_ender_pagto_text)        "|" 
            pessoa_jurid.log_envio_bco_histor                   "|" 
            pessoa_jurid.ind_natur_pessoa_jurid                 "|" 
            pessoa_jurid.nom_fantasia                           "|" 
            pessoa_jurid.cod_sub_regiao_vendas                  "|" 
            pessoa_jurid.log_replic_pessoa_hcm                  "|" 
            pessoa_jurid.log_replic_pessoa_crm                  "|" 
            pessoa_jurid.log_replic_pessoa_gps                  "|" 
            pessoa_jurid.cod_fax_2                              "|" 
            pessoa_jurid.cod_ramal_fax_2                        "|" 
            pessoa_jurid.cod_telef_2                            "|" 
            pessoa_jurid.cod_ramal_2                            "|"
            .
    put skip.
end.
output close.

message "Clientes Pessoa JURIDICA exportados para: " + v-arquivo view-as alert-box.
