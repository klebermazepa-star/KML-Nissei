{\\192.168.200.53\datasul\_custom_teste\export.i}
def var v-arquivo as char no-undo.

define buffer fornecedor for emsbas.fornecedor.
define buffer portador for emsbas.portador.
define buffer forma_pagto for emsbas.forma_pagto.
define buffer cliente for emsbas.cliente.


SYSTEM-DIALOG GET-FILE v-arquivo  FILTERS "*.txt" "*.txt"  ask-overwrite  SAVE-AS TITLE "Arquivo de Sa¡da (.txt)".

if v-arquivo <> "" then do:
    if num-entries (v-arquivo,'.') < 2 then 
        v-arquivo = v-arquivo + ".txt".
    output to value(v-arquivo).
    put unformatted
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

for each pessoa_jurid no-lock:
    if  not can-find (first fornecedor no-lock where
                      fornecedor.num_pessoa = pessoa_jurid.num_pessoa_jurid)
    and not can-find (first cliente no-lock where
                      cliente.num_pessoa = pessoa_jurid.num_pessoa_jurid)
    and not can-find (first representante no-lock where 
                      representante.num_pessoa = pessoa_jurid.num_pessoa_jurid) then do:
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
                PrintChar(pessoa_jurid.nom_ender_text)           "|" 
                PrintChar(pessoa_jurid.nom_ender_cobr_text)      "|" 
                PrintChar(pessoa_jurid.nom_ender_pagto_text)     "|" 
                pessoa_jurid.log_envio_bco_histor     "|" 
                pessoa_jurid.ind_natur_pessoa_jurid                 "|" 
                pessoa_jurid.nom_fantasia                           "|" 
                pessoa_jurid.cod_sub_regiao_vendas                  "|" 
                pessoa_jurid.log_replic_pessoa_hcm                  "|" 
                pessoa_jurid.log_replic_pessoa_crm                  "|" 
                pessoa_jurid.log_replic_pessoa_gps                  "|" 
                pessoa_jurid.cod_fax_2                              "|" 
                pessoa_jurid.cod_ramal_fax_2                        "|" 
                pessoa_jurid.cod_telef_2                            "|" 
                pessoa_jurid.cod_ramal_2                            "|".
        put skip.
    end.
end.
output close.

message "Pessoa JURIDICA exportados para: " + v-arquivo view-as alert-box.



