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
        "Nome|ID Federal|ID Estadual Fisica|Orgao Emissor|"
        "UF Emis| Data Nasc|  Pais Nasc| UF Nasc| Mae|Endereco|Complemento|Bairro|Cidade|Condado|Pais| UF|CEP|"
        "Caixa Postal|Telefone|FAX|Ramal Fax|TELEX|Modem|Ramal Modem|E-Mail|E-Mail Cobranca|Pessoa Fisic Cobr|"
        "Endereco Cobranca|Complemento Cobr|Bairro Cobr|Cidade Cobr|Condado Cobr |UF Cobr| Pais Cobr|"
        "CEP Cobranca|Cx Postal Cobr| Anotacao Tabela|Tipo Pessoa Fisica|Estad Civ Pes|Nacionalidade| Profissao|"
        "Home Page|Endereco Compl.|End Cobranca Compl|Microrregiao Vendas| Replic P HCM |Replic P CRM |Replic P GPS |"
        "FAX 2|Ramal Fax 2| Telefone 2 |Ramal 2|"
        skip.
end.
else return.

for each pessoa_fisic no-lock:
    if  not can-find (first fornecedor no-lock where
                      fornecedor.num_pessoa = pessoa_fisic.num_pessoa_fisic)
    and not can-find (first cliente no-lock where
                      cliente.num_pessoa = pessoa_fisic.num_pessoa_fisic)
    and not can-find (first representante no-lock where 
                      representante.num_pessoa = pessoa_fisic.num_pessoa_fisic) 
    and not can-find (first funcionario no-lock where 
                      funcionario.num_pessoa_fisic = pessoa_fisic.num_pessoa_fisic)
    then do:

        put unformatted
            pessoa_fisic.nom_pessoa                             "|"  
            pessoa_fisic.cod_id_feder format "999.999.999-99"   "|"  
            pessoa_fisic.cod_id_estad_fisic                     "|"  
            pessoa_fisic.cod_orgao_emis_id_estad                "|"  
            pessoa_fisic.cod_unid_federac_emis_estad            "|"  
            pessoa_fisic.dat_nasc_pessoa_fisic                  "|"  
            pessoa_fisic.cod_pais_nasc                          "|"  
            pessoa_fisic.cod_unid_federac_nasc                  "|"  
            pessoa_fisic.nom_mae_pessoa                         "|"  
            pessoa_fisic.nom_endereco                           "|"  
            pessoa_fisic.nom_ender_compl                        "|"  
            pessoa_fisic.nom_bairro                             "|"  
            pessoa_fisic.nom_cidade                             "|"  
            pessoa_fisic.nom_condado                            "|"  
            pessoa_fisic.cod_pais                               "|"  
            pessoa_fisic.cod_unid_federac                       "|"  
            pessoa_fisic.cod_cep                                "|"  
            pessoa_fisic.cod_cx_post                            "|"  
            pessoa_fisic.cod_telefone                           "|"  
            pessoa_fisic.cod_fax                                "|"  
            pessoa_fisic.cod_ramal_fax                          "|"  
            pessoa_fisic.cod_telex                              "|"  
            pessoa_fisic.cod_modem                              "|"  
            pessoa_fisic.cod_ramal_modem                        "|"  
            pessoa_fisic.cod_e_mail                             "|"  
            pessoa_fisic.cod_e_mail_cobr                        "|"  
            pessoa_fisic.num_pessoa_fisic_cobr                  "|"  
            pessoa_fisic.nom_ender_cobr                         "|"  
            pessoa_fisic.nom_ender_compl_cobr                   "|"  
            pessoa_fisic.nom_bairro_cobr                        "|"  
            pessoa_fisic.nom_cidad_cobr                         "|"  
            pessoa_fisic.nom_condad_cobr                        "|"  
            pessoa_fisic.cod_unid_federac_cobr                  "|"  
            pessoa_fisic.cod_pais_cobr                          "|"  
            pessoa_fisic.cod_cep_cobr                           "|"  
            pessoa_fisic.cod_cx_post_cobr                       "|"  
            pessoa_fisic.des_anot_tab                           "|"  
            pessoa_fisic.ind_tip_pessoa_fisic                   "|"  
            pessoa_fisic.ind_estado_civil_pessoa                "|"  
            pessoa_fisic.nom_nacion_pessoa_fisic                "|"  
            pessoa_fisic.nom_profis_pessoa_fisic                "|"  
            pessoa_fisic.nom_home_page                          "|"  
            PrintChar(pessoa_fisic.nom_ender_text)              "|"  
            PrintChar(pessoa_fisic.nom_ender_cobr_text)         "|"  
            pessoa_fisic.cod_sub_regiao_vendas                  "|"  
            pessoa_fisic.log_replic_pessoa_hcm                  "|"  
            pessoa_fisic.log_replic_pessoa_crm                  "|"  
            pessoa_fisic.log_replic_pessoa_gps                  "|"  
            pessoa_fisic.cod_fax_2                              "|"
            pessoa_fisic.cod_ramal_fax_2                        "|"
            pessoa_fisic.cod_telef_2                            "|"
            pessoa_fisic.cod_ramal_2                            "|".
        put skip.
    end.        
end.
output close.

message "Pessoa FISICA Sem Relacoes exportados para: " + v-arquivo view-as alert-box.



