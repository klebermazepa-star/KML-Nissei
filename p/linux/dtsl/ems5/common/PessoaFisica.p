&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   PessoaFisica
*
* FINALIDADE:
*   ..
*
* NOTAS:
*   Classe gerada automaticamente pelo class generator
*   da Datasul Paranaense.
*/

{system/Error.i}
{system/InstanceManagerDef.i}

{utils/isValidCpf.i}

define variable messageEms5 as handle      no-undo.

define temp-table ttPessoa_fisic no-undo
    like pessoa_fisic
    field r-rowid as rowid.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 23.58
         WIDTH              = 44.57.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-beforeInsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInsert Procedure 
PROCEDURE beforeInsert :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    do {&throws}:
        run beforeUpsert.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-beforeUpdate) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeUpdate Procedure 
PROCEDURE beforeUpdate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        run beforeUpsert.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-beforeUpsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeUpsert Procedure 
PROCEDURE beforeUpsert :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-canFindByIdFederal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE canFindByIdFederal Procedure 
PROCEDURE canFindByIdFederal :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter cod_pais_         as character no-undo.
    define input  parameter cod_id_feder_     as character no-undo.
    define output parameter found_            as logical     no-undo.

    do {&throws}:
        assign found_ = can-find(first pessoa_fisic use-index pssfsca_id_feder_fisic
                                 where pessoa_fisic.cod_pais     = cod_pais_
                                   and pessoa_fisic.cod_id_feder = cod_id_feder_).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clear) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear Procedure 
PROCEDURE clear PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        empty temp-table ttPessoa_fisic.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-delete) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete Procedure 
PROCEDURE delete :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    do {&throws}:
        run validate('delete').
        run lock.

        delete pessoa_fisic.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-find) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find Procedure 
PROCEDURE find :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input parameter num_pessoa_fisic_ as integer no-undo.

    do {&throws}:
        find first pessoa_fisic
            where pessoa_fisic.num_pessoa_fisic = num_pessoa_fisic_
            no-lock no-error.

        if not available pessoa_fisic then do:
            run createError in messageEms5(524,
                'Pessoa f°sica n∆o encontrada'
                + '~~':u 
                + substitute('Pessoa &1 n∆o encontrada', num_pessoa_fisic_)).

            return error.
        end.

        run load.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-findByIdFederal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE findByIdFederal Procedure 
PROCEDURE findByIdFederal :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter cod_pais_         as character no-undo.
    define input  parameter cod_id_feder_     as character no-undo.

    do {&throws}:
        find first pessoa_fisic use-index pssfsca_id_feder_fisic
            where pessoa_fisic.cod_pais     = cod_pais_
              and pessoa_fisic.cod_id_feder = cod_id_feder_
            no-lock no-error.

        if not available pessoa_fisic then do:
            run createError in messageEms5(524,
                'Pessoa f°sica n∆o encontrada'
                + '~~':u 
                + substitute('Pessoa f°sica n∆o encontrada para o pa°s "&1" e ID Federal "&2"',
                             cod_pais_, cod_id_feder_)).

            return error.
        end.

        run load.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getAnotacaoTabela) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getAnotacaoTabela Procedure 
PROCEDURE getAnotacaoTabela :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter des_anot_tab_ as character no-undo.

    do {&throws}:
        assign des_anot_tab_ = ttPessoa_fisic.des_anot_tab.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getBairro) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getBairro Procedure 
PROCEDURE getBairro :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_bairro_ as character no-undo.

    do {&throws}:
        assign nom_bairro_ = ttPessoa_fisic.nom_bairro.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCaixaPostal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCaixaPostal Procedure 
PROCEDURE getCaixaPostal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_cx_post_ as character no-undo.

    do {&throws}:
        assign cod_cx_post_ = ttPessoa_fisic.cod_cx_post.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCep) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCep Procedure 
PROCEDURE getCep :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_cep_ as character no-undo.

    do {&throws}:
        assign cod_cep_ = ttPessoa_fisic.cod_cep.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCidade) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCidade Procedure 
PROCEDURE getCidade :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_cidade_ as character no-undo.

    do {&throws}:
        assign nom_cidade_ = ttPessoa_fisic.nom_cidade.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getComplemento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getComplemento Procedure 
PROCEDURE getComplemento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_ender_compl_ as character no-undo.

    do {&throws}:
        assign nom_ender_compl_ = ttPessoa_fisic.nom_ender_compl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCondado) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCondado Procedure 
PROCEDURE getCondado :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_condado_ as character no-undo.

    do {&throws}:
        assign nom_condado_ = ttPessoa_fisic.nom_condado.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCpf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCpf Procedure 
PROCEDURE getCpf :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_id_feder_ as character no-undo.

    do {&throws}:
        assign cod_id_feder_ = ttPessoa_fisic.cod_id_feder.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDataNascimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDataNascimento Procedure 
PROCEDURE getDataNascimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter dat_nasc_pessoa_fisic_ as date no-undo.

    do {&throws}:
        assign dat_nasc_pessoa_fisic_ = ttPessoa_fisic.dat_nasc_pessoa_fisic.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDataUltimaAtualizacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDataUltimaAtualizacao Procedure 
PROCEDURE getDataUltimaAtualizacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter dat_ult_atualiz_ as date no-undo.

    do {&throws}:
        assign dat_ult_atualiz_ = ttPessoa_fisic.dat_ult_atualiz.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEMail) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEMail Procedure 
PROCEDURE getEMail :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_e_mail_ as character no-undo.

    do {&throws}:
        assign cod_e_mail_ = ttPessoa_fisic.cod_e_mail.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEndereco) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEndereco Procedure 
PROCEDURE getEndereco :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_endereco_ as character no-undo.

    do {&throws}:
        assign nom_endereco_ = ttPessoa_fisic.nom_endereco.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEnderecoTexto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEnderecoTexto Procedure 
PROCEDURE getEnderecoTexto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_ender_text_ as character no-undo.

    do {&throws}:
        assign nom_ender_text_ = ttPessoa_fisic.nom_ender_text.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEstadoCivil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEstadoCivil Procedure 
PROCEDURE getEstadoCivil :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter ind_estado_civil_pessoa_ as character no-undo.

    do {&throws}:
        assign ind_estado_civil_pessoa_ = ttPessoa_fisic.ind_estado_civil_pessoa.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFax) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFax Procedure 
PROCEDURE getFax :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_fax_ as character no-undo.

    do {&throws}:
        assign cod_fax_ = ttPessoa_fisic.cod_fax.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFaxRamal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFaxRamal Procedure 
PROCEDURE getFaxRamal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_ramal_fax_ as character no-undo.

    do {&throws}:
        assign cod_ramal_fax_ = ttPessoa_fisic.cod_ramal_fax.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getHomePage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getHomePage Procedure 
PROCEDURE getHomePage :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_home_page_ as character no-undo.

    do {&throws}:
        assign nom_home_page_ = ttPessoa_fisic.nom_home_page.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getHoraUltimaAtualizacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getHoraUltimaAtualizacao Procedure 
PROCEDURE getHoraUltimaAtualizacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter hra_ult_atualiz_ as character no-undo.

    do {&throws}:
        assign hra_ult_atualiz_ = ttPessoa_fisic.hra_ult_atualiz.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getImagem) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getImagem Procedure 
PROCEDURE getImagem :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_imagem_ as character no-undo.

    do {&throws}:
        assign cod_imagem_ = ttPessoa_fisic.cod_imagem.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getModem) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getModem Procedure 
PROCEDURE getModem :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_modem_ as character no-undo.

    do {&throws}:
        assign cod_modem_ = ttPessoa_fisic.cod_modem.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getModemRamal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getModemRamal Procedure 
PROCEDURE getModemRamal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_ramal_modem_ as character no-undo.

    do {&throws}:
        assign cod_ramal_modem_ = ttPessoa_fisic.cod_ramal_modem.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNacionalidade) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNacionalidade Procedure 
PROCEDURE getNacionalidade :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_nacion_pessoa_fisic_ as character no-undo.

    do {&throws}:
        assign nom_nacion_pessoa_fisic_ = ttPessoa_fisic.nom_nacion_pessoa_fisic.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNome) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNome Procedure 
PROCEDURE getNome :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_pessoa_ as character no-undo.

    do {&throws}:
        assign nom_pessoa_ = ttPessoa_fisic.nom_pessoa.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNomeMae) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNomeMae Procedure 
PROCEDURE getNomeMae :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_mae_pessoa_ as character no-undo.

    do {&throws}:
        assign nom_mae_pessoa_ = ttPessoa_fisic.nom_mae_pessoa.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPais) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPais Procedure 
PROCEDURE getPais :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_pais_ as character no-undo.

    do {&throws}:
        assign cod_pais_ = ttPessoa_fisic.cod_pais.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPaisNascimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPaisNascimento Procedure 
PROCEDURE getPaisNascimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_pais_nasc_ as character no-undo.

    do {&throws}:
        assign cod_pais_nasc_ = ttPessoa_fisic.cod_pais_nasc.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPessoaFisica) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPessoaFisica Procedure 
PROCEDURE getPessoaFisica :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter num_pessoa_fisic_ as integer no-undo.

    do {&throws}:
        assign num_pessoa_fisic_ = ttPessoa_fisic.num_pessoa_fisic.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getProfissao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getProfissao Procedure 
PROCEDURE getProfissao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_profis_pessoa_fisic_ as character no-undo.

    do {&throws}:
        assign nom_profis_pessoa_fisic_ = ttPessoa_fisic.nom_profis_pessoa_fisic.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRamal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRamal Procedure 
PROCEDURE getRamal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_ramal_ as character no-undo.

    do {&throws}:
        assign cod_ramal_ = ttPessoa_fisic.cod_ramal.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRg) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRg Procedure 
PROCEDURE getRg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_id_estad_fisic_ as character no-undo.

    do {&throws}:
        assign cod_id_estad_fisic_ = ttPessoa_fisic.cod_id_estad_fisic.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRgOrgaoEmissor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRgOrgaoEmissor Procedure 
PROCEDURE getRgOrgaoEmissor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_orgao_emis_id_estad_ as character no-undo.

    do {&throws}:
        assign cod_orgao_emis_id_estad_ = ttPessoa_fisic.cod_orgao_emis_id_estad.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRgUnidadeFederacaoEmissor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRgUnidadeFederacaoEmissor Procedure 
PROCEDURE getRgUnidadeFederacaoEmissor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_unid_federac_emis_estad_ as character no-undo.

    do {&throws}:
        assign cod_unid_federac_emis_estad_ = ttPessoa_fisic.cod_unid_federac_emis_estad.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTelefone) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTelefone Procedure 
PROCEDURE getTelefone :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_telefone_ as character no-undo.

    do {&throws}:
        assign cod_telefone_ = ttPessoa_fisic.cod_telefone.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTelex) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTelex Procedure 
PROCEDURE getTelex :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_telex_ as character no-undo.

    do {&throws}:
        assign cod_telex_ = ttPessoa_fisic.cod_telex.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTipoPessoaFisica) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTipoPessoaFisica Procedure 
PROCEDURE getTipoPessoaFisica :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter ind_tip_pessoa_fisic_ as character no-undo.

    do {&throws}:
        assign ind_tip_pessoa_fisic_ = ttPessoa_fisic.ind_tip_pessoa_fisic.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getUnidadeFederacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getUnidadeFederacao Procedure 
PROCEDURE getUnidadeFederacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_unid_federac_ as character no-undo.

    do {&throws}:
        assign cod_unid_federac_ = ttPessoa_fisic.cod_unid_federac.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getUnidadeFederacaoNascimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getUnidadeFederacaoNascimento Procedure 
PROCEDURE getUnidadeFederacaoNascimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_unid_federac_nasc_ as character no-undo.

    do {&throws}:
        assign cod_unid_federac_nasc_ = ttPessoa_fisic.cod_unid_federac_nasc.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getUsuarioUltimaAtualizacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getUsuarioUltimaAtualizacao Procedure 
PROCEDURE getUsuarioUltimaAtualizacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_usuar_ult_atualiz_ as character no-undo.

    do {&throws}:
        assign cod_usuar_ult_atualiz_ = ttPessoa_fisic.cod_usuar_ult_atualiz.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-insert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE insert Procedure 
PROCEDURE insert :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    do {&throws}:

        run beforeInsert in child().

        run validate('insert':u).

        create pessoa_fisic.
        buffer-copy ttPessoa_fisic except r-rowid
            to pessoa_fisic.

        assign ttPessoa_fisic.r-rowid = rowid(pessoa_fisic).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isEms2Atualizado) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isEms2Atualizado Procedure 
PROCEDURE isEms2Atualizado :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter log_ems_20_atlzdo_ as logical no-undo.

    do {&throws}:
        assign log_ems_20_atlzdo_ = ttPessoa_fisic.log_ems_20_atlzdo.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isEnvioBancoHistorico) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isEnvioBancoHistorico Procedure 
PROCEDURE isEnvioBancoHistorico :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter log_envio_bco_histor_ as logical no-undo.

    do {&throws}:
        assign log_envio_bco_histor_ = ttPessoa_fisic.log_envio_bco_histor.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-load) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load Procedure 
PROCEDURE load PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    do {&throws}:
        run clear.

        buffer-copy pessoa_fisic to ttPessoa_fisic
            assign ttPessoa_fisic.r-rowid = rowid(pessoa_fisic).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-lock) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lock Procedure 
PROCEDURE lock PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    do {&throws}:
        find first pessoa_fisic
            where rowid(pessoa_fisic) = ttPessoa_fisic.r-rowid
            exclusive-lock no-error no-wait.

        if not avail pessoa_fisic then do:
            if locked pessoa_fisic then
                run createError(17006, 'Registro travado por outro usu†rio (pessoa_fisic)').
            else do:
                {utp/ut-table.i emsuni pessoa_fisic 1}
                run createError(2, return-value).
            end.

            return error.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-new) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE new Procedure 
PROCEDURE new :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    do {&throws}:
        run clear.

        create ttPessoa_fisic.
        find first ttPessoa_fisic.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setAnotacaoTabela) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setAnotacaoTabela Procedure 
PROCEDURE setAnotacaoTabela :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter des_anot_tab_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.des_anot_tab = des_anot_tab_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setBairro) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setBairro Procedure 
PROCEDURE setBairro :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_bairro_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_bairro = nom_bairro_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCaixaPostal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCaixaPostal Procedure 
PROCEDURE setCaixaPostal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_cx_post_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_cx_post = cod_cx_post_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCep) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCep Procedure 
PROCEDURE setCep :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_cep_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_cep = cod_cep_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCidade) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCidade Procedure 
PROCEDURE setCidade :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_cidade_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_cidade = nom_cidade_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setComplemento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setComplemento Procedure 
PROCEDURE setComplemento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_ender_compl_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_ender_compl = nom_ender_compl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCondado) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCondado Procedure 
PROCEDURE setCondado :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_condado_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_condado = nom_condado_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCpf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCpf Procedure 
PROCEDURE setCpf :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_id_feder_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_id_feder = cod_id_feder_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDataNascimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDataNascimento Procedure 
PROCEDURE setDataNascimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter dat_nasc_pessoa_fisic_ as date no-undo.

    do {&throws}:
        assign ttPessoa_fisic.dat_nasc_pessoa_fisic = dat_nasc_pessoa_fisic_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDataUltimaAtualizacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDataUltimaAtualizacao Procedure 
PROCEDURE setDataUltimaAtualizacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter dat_ult_atualiz_ as date no-undo.

    do {&throws}:
        assign ttPessoa_fisic.dat_ult_atualiz = dat_ult_atualiz_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEMail) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEMail Procedure 
PROCEDURE setEMail :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_e_mail_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_e_mail = cod_e_mail_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEms2Atualizado) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEms2Atualizado Procedure 
PROCEDURE setEms2Atualizado :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter log_ems_20_atlzdo_ as logical no-undo.

    do {&throws}:
        assign ttPessoa_fisic.log_ems_20_atlzdo = log_ems_20_atlzdo_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEndereco) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEndereco Procedure 
PROCEDURE setEndereco :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_endereco_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_endereco = nom_endereco_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEnderecoTexto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEnderecoTexto Procedure 
PROCEDURE setEnderecoTexto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_ender_text_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_ender_text = nom_ender_text_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEnvioBancoHistorico) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEnvioBancoHistorico Procedure 
PROCEDURE setEnvioBancoHistorico :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter log_envio_bco_histor_ as logical no-undo.

    do {&throws}:
        assign ttPessoa_fisic.log_envio_bco_histor = log_envio_bco_histor_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEstadoCivil) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEstadoCivil Procedure 
PROCEDURE setEstadoCivil :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter ind_estado_civil_pessoa_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.ind_estado_civil_pessoa = ind_estado_civil_pessoa_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFax) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFax Procedure 
PROCEDURE setFax :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_fax_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_fax = cod_fax_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFaxRamal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFaxRamal Procedure 
PROCEDURE setFaxRamal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_ramal_fax_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_ramal_fax = cod_ramal_fax_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setHomePage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setHomePage Procedure 
PROCEDURE setHomePage :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_home_page_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_home_page = nom_home_page_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setHoraUltimaAtualizacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setHoraUltimaAtualizacao Procedure 
PROCEDURE setHoraUltimaAtualizacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter hra_ult_atualiz_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.hra_ult_atualiz = hra_ult_atualiz_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setImagem) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setImagem Procedure 
PROCEDURE setImagem :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_imagem_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_imagem = cod_imagem_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setModem) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setModem Procedure 
PROCEDURE setModem :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_modem_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_modem = cod_modem_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setModemRamal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setModemRamal Procedure 
PROCEDURE setModemRamal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_ramal_modem_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_ramal_modem = cod_ramal_modem_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setNacionalidade) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setNacionalidade Procedure 
PROCEDURE setNacionalidade :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_nacion_pessoa_fisic_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_nacion_pessoa_fisic = nom_nacion_pessoa_fisic_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setNome) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setNome Procedure 
PROCEDURE setNome :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_pessoa_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_pessoa = nom_pessoa_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setNomeMae) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setNomeMae Procedure 
PROCEDURE setNomeMae :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_mae_pessoa_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_mae_pessoa = nom_mae_pessoa_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPais) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPais Procedure 
PROCEDURE setPais :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_pais_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_pais = cod_pais_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPaisNascimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPaisNascimento Procedure 
PROCEDURE setPaisNascimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_pais_nasc_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_pais_nasc = cod_pais_nasc_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPessoaFisica) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPessoaFisica Procedure 
PROCEDURE setPessoaFisica :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter num_pessoa_fisic_ as integer no-undo.

    do {&throws}:
        assign ttPessoa_fisic.num_pessoa_fisic = num_pessoa_fisic_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setProfissao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setProfissao Procedure 
PROCEDURE setProfissao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_profis_pessoa_fisic_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.nom_profis_pessoa_fisic = nom_profis_pessoa_fisic_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setRamal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setRamal Procedure 
PROCEDURE setRamal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_ramal_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_ramal = cod_ramal_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setRg) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setRg Procedure 
PROCEDURE setRg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_id_estad_fisic_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_id_estad_fisic = cod_id_estad_fisic_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setRgOrgaoEmissor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setRgOrgaoEmissor Procedure 
PROCEDURE setRgOrgaoEmissor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_orgao_emis_id_estad_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_orgao_emis_id_estad = cod_orgao_emis_id_estad_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setRgUnidadeFederacaoEmissor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setRgUnidadeFederacaoEmissor Procedure 
PROCEDURE setRgUnidadeFederacaoEmissor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_unid_federac_emis_estad_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_unid_federac_emis_estad = cod_unid_federac_emis_estad_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTelefone) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTelefone Procedure 
PROCEDURE setTelefone :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_telefone_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_telefone = cod_telefone_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTelex) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTelex Procedure 
PROCEDURE setTelex :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_telex_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_telex = cod_telex_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTipoPessoaFisica) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTipoPessoaFisica Procedure 
PROCEDURE setTipoPessoaFisica :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter ind_tip_pessoa_fisic_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.ind_tip_pessoa_fisic = ind_tip_pessoa_fisic_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUnidadeFederacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUnidadeFederacao Procedure 
PROCEDURE setUnidadeFederacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_unid_federac_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_unid_federac = cod_unid_federac_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUnidadeFederacaoNascimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUnidadeFederacaoNascimento Procedure 
PROCEDURE setUnidadeFederacaoNascimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_unid_federac_nasc_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_unid_federac_nasc = cod_unid_federac_nasc_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUsuarioUltimaAtualizacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUsuarioUltimaAtualizacao Procedure 
PROCEDURE setUsuarioUltimaAtualizacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_usuar_ult_atualiz_ as character no-undo.

    do {&throws}:
        assign ttPessoa_fisic.cod_usuar_ult_atualiz = cod_usuar_ult_atualiz_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-startup) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup Procedure 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    {system/InstanceManager.i}

    run createInstance in ghInstanceManager(this-procedure,
        'dtsl/ems5/common/Message.p':u, output messageEms5).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-unlock) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE unlock Procedure 
PROCEDURE unlock PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    do {&throws}:
        find current pessoa_fisic
            no-lock no-error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-update) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update Procedure 
PROCEDURE update :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        run beforeUpdate.
        run validate('update').
        run lock.

        buffer-copy ttPessoa_fisic except r-rowid
            to pessoa_fisic.

        run unlock.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validate) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate Procedure 
PROCEDURE validate PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter validationType as character no-undo.

    define variable hasErrors as logical     no-undo.

    do {&throws}:

        /* fazer validacoes genericas aqui */
        case validationType:
            when 'insert' then
                run validateInsert.

            when 'update' then
                run validateUpdate.

            when 'delete' then
                run validateDelete.

            otherwise do:
                run createError(17006, substitute('validate.validationType inv†lido (&1)',
                    validationType)).
                return error.
            end.
        end case.

        run hasError(output hasErrors).
        if hasErrors then
            return error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validateCpf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateCpf Procedure 
PROCEDURE validateCpf PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    find first ems5.pais 
        where  pais.cod_pais = ttPessoa_fisic.cod_pais
        no-lock no-error.

    if not avail(pais) then do:
        run createError in messageEms5(524,
                  'Pa°s n∆o encontrado'
                  + '~~':u
                  + substitute('Pa°s &1 n∆o pode ser encontrado.', ttPessoa_fisic.cod_pais)).

        return error.
    end.
    
    /*Se necess†rio valida os digitos verificadores do CPF*/
    if pais.ind_digito_id_feder_fisic <> 'N∆o Valida' and
       not isValidCpf(ttPessoa_fisic.cod_id_feder) then do:


        run createError in messageEms5(524,
                  'CPF inv†lido'
                  + '~~':u
                  + substitute('CPF &1 inv†lido', ttPessoa_fisic.cod_id_feder)).

        return error.

    end.
    
    
    /*Se necess†rio valida a duplicidade do CPF*/
    if pais.ind_id_feder_fisic_unico = 'N∆o Valida' then
        return.
    
    if can-find( first pessoa_fisic
            where pessoa_fisic.cod_pais = ttPessoa_fisic.cod_pais
              and pessoa_fisic.cod_id_feder = ttPessoa_fisic.cod_id_feder
              and pessoa_fisic.num_pessoa_fisic <> ttPessoa_fisic.num_pessoa_fisic ) then do:
    
        run createError in messageEms5(524,
            'CPF j† cadastrado'
            + '~~':u 
            + substitute('O CPF "&1" j† existe', ttPessoa_fisic.cod_id_feder )).
    
        return error.
    end.
    


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validateDelete) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateDelete Procedure 
PROCEDURE validateDelete PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        if can-find(first acum_pagto_pessoa 
            where acum_pagto_pessoa.num_pessoa = ttPessoa_fisic.num_pessoa_fisic) then 
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Acumulados Pagamentos Pessoa!')). 

        /*if can-find(first emspmg.bolsista 
            where emspmg.bolsista.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then 
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Bolsista!')).*/

        if can-find(first emsuni.cliente 
            where emsuni.cliente.num_pessoa = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Cliente!')).

        if can-find(first emsuni.contato 
            where emsuni.contato.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Contato Pessoa!')).

        if can-find(first dirf_apb 
            where dirf_apb.num_pessoa = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Dado para Emiss∆o DIRF!')). 

        if can-find(first fiador 
            where fiador.num_pessoa = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Fiador!')).

        /*if can-find(first emspmg.ficha_invent_trein 
            where emspmg.ficha_invent_trein.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Ficha Invent†rio Treinamento!')).*/

        if can-find(first emsuni.fornecedor 
            where emsuni.fornecedor.num_pessoa = ttPessoa_fisic.num_pessoa_fisic) then 
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Fornecedor!')).

        /*if can-find(first emsuhr.funcionario 
            where emsuhr.funcionario.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then 
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Funcion†rio!')).*/

        if can-find(first func_financ 
            where func_financ.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then 
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Funcion†rio!')).

        if can-find(first emsuni.idiom_pessoa_fisic 
            where emsuni.idiom_pessoa_fisic.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then 
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Idioma Pessoa F°sica!')).

        /*if can-find(first emspmg.instrut_trein 
            where emspmg.instrut_trein.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Instrutor Treinamento!')).*/

        /*if can-find(first emspmg.lista_inscr 
            where emspmg.lista_inscr.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then 
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Lista Inscriá∆o!')).*/

        /*if can-find(first emspmg.pessoa_ext_trein 
            where emspmg.pessoa_ext_trein.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Pessoa Externa Treinamento!')).*/

        if can-find(first emsuni.representante 
            where emsuni.representante.num_pessoa = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Representante!')).

        /*if can-find(first emspmg.treindo_curso_espor 
            where emspmg.treindo_curso_espor.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Treinando Curso Espor†dico!')).*/

        /*if can-find(first emspmg.treindo_turma_trein 
            where emspmg.treindo_turma_trein.num_pessoa_fisic = ttPessoa_fisic.num_pessoa_fisic) then
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Treinando Turma!')).*/

        if can-find(first usuar_mestre 
            where usuar_mestre.num_pessoa = ttPessoa_fisic.num_pessoa_fisic) then 
            run createError(17006, substitute('Pessoa F°sica possui relacionamentos com Usu†rio!')).

    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validateInsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateInsert Procedure 
PROCEDURE validateInsert PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        /* Faca aqui as validacoes para inclusao, mas nao de return-error,
           pois essa instrucao eh dada pelo metodo validate. Veja um exemplo:

        if can-find(first familia where familia.fm-codigo = ttFamilia.fm-codigo) then
            run createError(17006, substitute('Fam°lia de Materiais &1 j† cadastrada',
                ttFamilia.fm-codigo)).
        */
        run validateUpsert.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validateUpdate) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateUpdate Procedure 
PROCEDURE validateUpdate PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        /* Faca aqui as validacoes para atualizacao, mas nao de return-error,
           pois essa instrucao eh dada pelo metodo validate. Veja um exemplo:

        find first familia
            where familia.fm-codigo = ttFamilia.fm-codigo
            no-lock no-error.

        if not available familia then
            run createError(17006, substitute('Fam°la de Materiais n∆o encontrada para atualizaá∆o', ttFamilia.fm-codigo)).
        */
        run validateUpsert.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validateUpsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateUpsert Procedure 
PROCEDURE validateUpsert PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:

        if ttPessoa_fisic.cod_pais <> '' and
           not can-find(first ems5.pais no-lock where 
                              pais.cod_pais = ttPessoa_fisic.cod_pais) then
          run createError in messageEms5(524,
              'Pa°s n∆o encontrado'
              + '~~':u
              + substitute('Pa°s &1 n∆o encontrado', ttPessoa_fisic.cod_pais)).

        if ttPessoa_fisic.cod_unid_federac <> '' and
           not can-find(first unid_feder no-lock where 
                              unid_feder.cod_pais         = ttPessoa_fisic.cod_pais and
                              unid_feder.cod_unid_federac = ttPessoa_fisic.cod_unid_federac) then
          run createError in messageEms5(524,
               'Unidade da federaá∆o n∆o encontrada'
               + '~~':u
               + substitute('Unidade da federaá∆o &1 n∆o encontrada', ttPessoa_fisic.cod_unid_federac)).  

        /* Cadastro de Pessoa Fisica n∆o valida cidade 
        if ttPessoa_fisic.nom_cidade <> '' and
           not can-find(first cidade no-lock where 
                              cidade.nom_cidade = ttPessoa_fisic.nom_cidade) then
          run createError(17006, substitute('Cidade &1 n∆o encontrado', ttPessoa_fisic.nom_cidade)).
        */
        
        run validateCPF.

    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

