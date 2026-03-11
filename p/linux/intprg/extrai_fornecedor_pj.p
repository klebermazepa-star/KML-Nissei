{\\192.168.200.53\datasul\_custom_teste\export.i}
def var v-arquivo as char no-undo.

define buffer fornecedor for emsbas.fornecedor.
define buffer portador for emsbas.portador.
define buffer forma_pagto for emsbas.forma_pagto.


SYSTEM-DIALOG GET-FILE v-arquivo  FILTERS "*.txt" "*.txt"  ask-overwrite  SAVE-AS TITLE "Arquivo de Sa¡da (.txt)".

if v-arquivo <> "" then do:
    if num-entries (v-arquivo,'.') < 2 then 
        v-arquivo = v-arquivo + ".txt".
    output to value(v-arquivo).
    put unformatted
        "Empresa|Fornecedor |Nome|Pessoa|Nome Abreviado|Pais|ID Federal|Grp Fornec |Descricao|Tipo Fornec|"
        "Classificacao|Data Implantacaoo |Credita PIS| Contr Lim INSS| Credita COFINS| Retem no Pagto |Replic E HCM|"
        "Replic E GPS|Replic E CRM|Replic E FIN| Replic E ERP|"
        "Portador |Nome Abreviado|Banco|Agencia| Dig Ag| F Pagto| Descr Forma Pagto|Tipo Fornec|"
        "Descr Tipo Fornec|Tipo Fluxo Financ| Vencto Sab |Vencto Dom |Vencto Feriado |Juros|Fornecto|Armazena Valor Pagto| "
        "Fornec Export |Pagto Bloqdo| Retem Imposto|Dt Ult Impl|Dt Ult Pagto|Dt Maior Tit| Qtd Antec |"
        "Qtd Tit Abert| Valor Maior Titulo|Maior Vl Aberto|Sdo Antecip Aberto|Sdo Tit Aberto|Vl Ult Implantacao|"
        "Rendto Tributavel| Vencto Igual Dt Flx| Perc Bonificacao| Ind Rendimento| Dias Compensacao| Envio Banco Historic|"
        "Retem no Pagto| Assoc Desp| Cooper|"
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

for each fornecedor no-lock where fornecedor.cod_empresa = "1" :
    for first fornec_financ no-lock of fornecedor: end.
    for first pessoa_jurid no-lock where 
        pessoa_jurid.num_pessoa_jurid = fornecedor.num_pessoa: end.
    if not avail pessoa_jurid then next.
    for first grp_fornec no-lock where 
        grp_fornec.cod_grp_fornec = fornecedor.cod_grp_fornec: end.
    

    put unformatted
        fornecedor.cod_empresa                   "|"
        fornecedor.cdn_fornecedor                "|"
        fornecedor.nom_pessoa                    "|"
        fornecedor.num_pessoa                    "|"
        fornecedor.nom_abrev                     "|"
        fornecedor.cod_pais                      "|"
        fornecedor.cod_id_feder format "99.999.999/9999-99"  "|"
        fornecedor.cod_grp_fornec                "|" 
        grp_fornec.des_grp_fornec                       "|" 
        fornecedor.cod_tip_fornec                "|" 
        fornecedor.cdn_classif_fornec            "|" 
        fornecedor.dat_impl_fornec               "|" 
        fornecedor.log_cr_pis                    "|" 
        fornecedor.log_control_inss              "|" 
        fornecedor.log_cr_cofins                 "|" 
        fornecedor.log_retenc_impto_pagto        "|" 
        fornecedor.log_replic_emit_hcm           "|" 
        fornecedor.log_replic_emit_gps           "|" 
        fornecedor.log_replic_emit_crm           "|" 
        fornecedor.log_replic_emit_financ        "|" 
        fornecedor.log_replic_emit_erp           "|" 
        .
    if avail fornec_financ then do:
        for first portador no-lock where 
            portador.cod_portador = fornec_financ.cod_portador: end.
        for first forma_pagto no-lock where 
            forma_pagto.cod_forma_pagto = fornec_financ.cod_forma_pagto: end.
        for first tip_fornec no-lock where 
            tip_fornec.cod_empresa = fornec_financ.cod_empresa and
            tip_fornec.cod_tip_fornec = fornec_financ.cod_tip_fornec: end.

        put unformatted
            fornec_financ.cod_portador                      "|"
            portador.nom_abrev                       "|"
            fornec_financ.cod_banco                         "|"
            fornec_financ.cod_agenc_bcia                    "|"
            fornec_financ.cod_digito_agenc_bcia             "|"
            fornec_financ.cod_forma_pagto                   "|"
           (if avail forma_pagto then forma_pagto.des_forma_pagto              
            else "N/D")                                     "|"
            fornec_financ.cod_tip_fornec                    "|"
           (if avail tip_fornec then tip_fornec.des_tip_fornec 
            else "N/D")                                     "|"
            fornec_financ.cod_tip_fluxo_financ              "|"
            fornec_financ.ind_tratam_vencto_sab             "|"
            fornec_financ.ind_tratam_vencto_dom             "|"
            fornec_financ.ind_tratam_vencto_fer             "|"
            fornec_financ.ind_pagto_juros_fornec_ap         "|"
            fornec_financ.ind_tip_fornecto                  "|"
            fornec_financ.ind_armaz_val_pagto               "|"
            fornec_financ.log_fornec_serv_export            "|"
            fornec_financ.log_pagto_bloqdo                  "|"
            fornec_financ.log_retenc_impto                  "|"
            fornec_financ.dat_ult_impl_tit_ap               "|"
            fornec_financ.dat_ult_pagto                     "|"
            fornec_financ.dat_impl_maior_tit_ap             "|" 
            fornec_financ.num_antecip_aber                  "|" 
            fornec_financ.num_tit_ap_aber                   "|" 
            fornec_financ.val_tit_ap_maior_val              "|" 
            fornec_financ.val_tit_ap_maior_val_aber         "|" 
            fornec_financ.val_sdo_antecip_aber              "|" 
            fornec_financ.val_sdo_tit_ap_aber               "|" 
            fornec_financ.val_ult_impl_tit_ap               "|" 
            fornec_financ.num_rendto_tribut                 "|" 
            fornec_financ.log_vencto_dia_nao_util           "|" 
            fornec_financ.val_percent_bonif                 "|" 
            fornec_financ.log_indic_rendto                  "|" 
            fornec_financ.num_dias_compcao                  "|" 
            fornec_financ.log_envio_bco_histor              "|" 
            fornec_financ.log_retenc_impto_pagto            "|" 
            fornec_financ.log_assoc_desport                 "|" 
            fornec_financ.log_cooperat                      "|" 
            .
    end.                                                        
    else do:                                                    
        put unformatted fill("|",38).                           
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

message "Fornecedores Pessoa JURIDICA exportados para: " + v-arquivo view-as alert-box.
