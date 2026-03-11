&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   PessoaJuridica
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

{utils/isValidCnpj.i}

define variable messageEms5 as handle      no-undo.

define temp-table ttPessoa_jurid no-undo
    like pessoa_jurid
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
         HEIGHT             = 21.58
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
        if ttPessoa_jurid.num_pessoa_jurid_matriz = 0 then
            assign ttPessoa_jurid.num_pessoa_jurid_matriz = ttPessoa_jurid.num_pessoa_jurid.

        if trim(ttPessoa_jurid.ind_tip_pessoa_jurid) = '' then
            assign ttPessoa_jurid.ind_tip_pessoa_jurid = 'Privada'.
        
        if trim(ttPessoa_jurid.ind_tip_capit_pessoa_jurid) = '' then
            ttPessoa_jurid.ind_tip_capit_pessoa_jurid = 'Nacional'.
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
    define input  parameter cod_pais_     as character   no-undo.
    define input  parameter cod_id_feder_ as character   no-undo.
    define output parameter found_        as logical     no-undo.

    do {&throws}:
        assign found_ = can-find(first pessoa_jurid use-index pssjrda_id_feder_jurid
                                 where pessoa_jurid.cod_pais     = cod_pais_
                                   and pessoa_jurid.cod_id_feder = cod_id_feder_).
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
        empty temp-table ttPessoa_jurid.
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

        delete pessoa_jurid.
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
    define input parameter num_pessoa_jurid_ as integer no-undo.

    do {&throws}:
        find first pessoa_jurid
            where pessoa_jurid.num_pessoa_jurid = num_pessoa_jurid_
            no-lock no-error.

        if not available pessoa_jurid then do:
            run createError in messageEms5(524,
                'Pessoa jur°dica n∆o encontrada'
                + '~~':u 
                + substitute('Pessoa &1 n∆o encontrada', num_pessoa_jurid_)).

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
    define input  parameter cod_pais_         as character   no-undo.
    define input  parameter cod_id_feder_     as character   no-undo.

    do {&throws}:
        find first pessoa_jurid use-index pssjrda_id_feder_jurid
            where pessoa_jurid.cod_pais     = cod_pais_
              and pessoa_jurid.cod_id_feder = cod_id_feder_
            no-lock no-error.

        if not available pessoa_jurid then do:
            run createError in messageEms5(524,
                'Pessoa jur°dica n∆o encontrada'
                + '~~':u 
                + substitute('Pessoa jur°dica n∆o encontrada para o pa°s "&1" e ID Federal "&2"',
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
        assign des_anot_tab_ = ttPessoa_jurid.des_anot_tab.
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
        assign nom_bairro_ = ttPessoa_jurid.nom_bairro.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getBairroCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getBairroCobranca Procedure 
PROCEDURE getBairroCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_bairro_cobr_ as character no-undo.

    do {&throws}:
        assign nom_bairro_cobr_ = ttPessoa_jurid.nom_bairro_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getBairroPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getBairroPagamento Procedure 
PROCEDURE getBairroPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_bairro_pagto_ as character no-undo.

    do {&throws}:
        assign nom_bairro_pagto_ = ttPessoa_jurid.nom_bairro_pagto.
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
        assign cod_cx_post_ = ttPessoa_jurid.cod_cx_post.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCaixaPostalCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCaixaPostalCobranca Procedure 
PROCEDURE getCaixaPostalCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_cx_post_cobr_ as character no-undo.

    do {&throws}:
        assign cod_cx_post_cobr_ = ttPessoa_jurid.cod_cx_post_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCaixaPostalPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCaixaPostalPagamento Procedure 
PROCEDURE getCaixaPostalPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_cx_post_pagto_ as character no-undo.

    do {&throws}:
        assign cod_cx_post_pagto_ = ttPessoa_jurid.cod_cx_post_pagto.
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
        assign cod_cep_ = ttPessoa_jurid.cod_cep.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCepCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCepCobranca Procedure 
PROCEDURE getCepCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_cep_cobr_ as character no-undo.

    do {&throws}:
        assign cod_cep_cobr_ = ttPessoa_jurid.cod_cep_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCepPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCepPagamento Procedure 
PROCEDURE getCepPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_cep_pagto_ as character no-undo.

    do {&throws}:
        assign cod_cep_pagto_ = ttPessoa_jurid.cod_cep_pagto.
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
        assign nom_cidade_ = ttPessoa_jurid.nom_cidade.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCidadeCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCidadeCobranca Procedure 
PROCEDURE getCidadeCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_cidad_cobr_ as character no-undo.

    do {&throws}:
        assign nom_cidad_cobr_ = ttPessoa_jurid.nom_cidad_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCidadePagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCidadePagamento Procedure 
PROCEDURE getCidadePagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_cidad_pagto_ as character no-undo.

    do {&throws}:
        assign nom_cidad_pagto_ = ttPessoa_jurid.nom_cidad_pagto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCnpj) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCnpj Procedure 
PROCEDURE getCnpj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_id_feder_ as character no-undo.

    do {&throws}:
        assign cod_id_feder_ = ttPessoa_jurid.cod_id_feder.
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
        assign nom_ender_compl_ = ttPessoa_jurid.nom_ender_compl.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getComplementoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getComplementoCobranca Procedure 
PROCEDURE getComplementoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_ender_compl_cobr_ as character no-undo.

    do {&throws}:
        assign nom_ender_compl_cobr_ = ttPessoa_jurid.nom_ender_compl_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getComplementoPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getComplementoPagamento Procedure 
PROCEDURE getComplementoPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_ender_compl_pagto_ as character no-undo.

    do {&throws}:
        assign nom_ender_compl_pagto_ = ttPessoa_jurid.nom_ender_compl_pagto.
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
        assign nom_condado_ = ttPessoa_jurid.nom_condado.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCondadoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCondadoCobranca Procedure 
PROCEDURE getCondadoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_condad_cobr_ as character no-undo.

    do {&throws}:
        assign nom_condad_cobr_ = ttPessoa_jurid.nom_condad_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCondadoPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCondadoPagamento Procedure 
PROCEDURE getCondadoPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_condad_pagto_ as character no-undo.

    do {&throws}:
        assign nom_condad_pagto_ = ttPessoa_jurid.nom_condad_pagto.
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
        assign dat_ult_atualiz_ = ttPessoa_jurid.dat_ult_atualiz.
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
        assign cod_e_mail_ = ttPessoa_jurid.cod_e_mail.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEMailCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEMailCobranca Procedure 
PROCEDURE getEMailCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_e_mail_cobr_ as character no-undo.

    do {&throws}:
        assign cod_e_mail_cobr_ = ttPessoa_jurid.cod_e_mail_cobr.
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
        assign nom_endereco_ = ttPessoa_jurid.nom_endereco.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEnderecoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEnderecoCobranca Procedure 
PROCEDURE getEnderecoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_ender_cobr_ as character no-undo.

    do {&throws}:
        assign nom_ender_cobr_ = ttPessoa_jurid.nom_ender_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEnderecoCobrancaTexto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEnderecoCobrancaTexto Procedure 
PROCEDURE getEnderecoCobrancaTexto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_ender_cobr_text_ as character no-undo.

    do {&throws}:
        assign nom_ender_cobr_text_ = ttPessoa_jurid.nom_ender_cobr_text.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEnderecoPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEnderecoPagamento Procedure 
PROCEDURE getEnderecoPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_ender_pagto_ as character no-undo.

    do {&throws}:
        assign nom_ender_pagto_ = ttPessoa_jurid.nom_ender_pagto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEnderecoPagamentoTexto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEnderecoPagamentoTexto Procedure 
PROCEDURE getEnderecoPagamentoTexto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter nom_ender_pagto_text_ as character no-undo.

    do {&throws}:
        assign nom_ender_pagto_text_ = ttPessoa_jurid.nom_ender_pagto_text.
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
        assign nom_ender_text_ = ttPessoa_jurid.nom_ender_text.
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
        assign cod_fax_ = ttPessoa_jurid.cod_fax.
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
        assign cod_ramal_fax_ = ttPessoa_jurid.cod_ramal_fax.
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
        assign nom_home_page_ = ttPessoa_jurid.nom_home_page.
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
        assign hra_ult_atualiz_ = ttPessoa_jurid.hra_ult_atualiz.
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
        assign cod_imagem_ = ttPessoa_jurid.cod_imagem.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getInscricaoEstadual) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getInscricaoEstadual Procedure 
PROCEDURE getInscricaoEstadual :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_id_estad_jurid_ as character no-undo.

    do {&throws}:
        assign cod_id_estad_jurid_ = ttPessoa_jurid.cod_id_estad_jurid.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getInscricaoMunicipal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getInscricaoMunicipal Procedure 
PROCEDURE getInscricaoMunicipal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_id_munic_jurid_ as character no-undo.

    do {&throws}:
        assign cod_id_munic_jurid_ = ttPessoa_jurid.cod_id_munic_jurid.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMatriz) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMatriz Procedure 
PROCEDURE getMatriz :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter num_pessoa_jurid_matriz_ as integer no-undo.

    do {&throws}:
        assign num_pessoa_jurid_matriz_ = ttPessoa_jurid.num_pessoa_jurid_matriz.
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
        assign cod_modem_ = ttPessoa_jurid.cod_modem.
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
        assign cod_ramal_modem_ = ttPessoa_jurid.cod_ramal_modem.
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
        assign nom_pessoa_ = ttPessoa_jurid.nom_pessoa.
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
        assign cod_pais_ = ttPessoa_jurid.cod_pais.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPaisCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPaisCobranca Procedure 
PROCEDURE getPaisCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_pais_cobr_ as character no-undo.

    do {&throws}:
        assign cod_pais_cobr_ = ttPessoa_jurid.cod_pais_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPaisPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPaisPagamento Procedure 
PROCEDURE getPaisPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_pais_pagto_ as character no-undo.

    do {&throws}:
        assign cod_pais_pagto_ = ttPessoa_jurid.cod_pais_pagto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPessoaJuridica) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPessoaJuridica Procedure 
PROCEDURE getPessoaJuridica :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter num_pessoa_jurid_ as integer no-undo.

    do {&throws}:
        assign num_pessoa_jurid_ = ttPessoa_jurid.num_pessoa_jurid.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPessoaJuridicaCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPessoaJuridicaCobranca Procedure 
PROCEDURE getPessoaJuridicaCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter num_pessoa_jurid_cobr_ as integer no-undo.

    do {&throws}:
        assign num_pessoa_jurid_cobr_ = ttPessoa_jurid.num_pessoa_jurid_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPessoaJuridicaPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPessoaJuridicaPagamento Procedure 
PROCEDURE getPessoaJuridicaPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter num_pessoa_jurid_pagto_ as integer no-undo.

    do {&throws}:
        assign num_pessoa_jurid_pagto_ = ttPessoa_jurid.num_pessoa_jurid_pagto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPrevidencia) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPrevidencia Procedure 
PROCEDURE getPrevidencia :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_id_previd_social_ as character no-undo.

    do {&throws}:
        assign cod_id_previd_social_ = ttPessoa_jurid.cod_id_previd_social.
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
        assign cod_telefone_ = ttPessoa_jurid.cod_telefone.
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
        assign cod_telex_ = ttPessoa_jurid.cod_telex.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTipoCapital) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTipoCapital Procedure 
PROCEDURE getTipoCapital :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter ind_tip_capit_pessoa_jurid_ as character no-undo.

    do {&throws}:
        assign ind_tip_capit_pessoa_jurid_ = ttPessoa_jurid.ind_tip_capit_pessoa_jurid.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTipoPessoa) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTipoPessoa Procedure 
PROCEDURE getTipoPessoa :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter ind_tip_pessoa_jurid_ as character no-undo.

    do {&throws}:
        assign ind_tip_pessoa_jurid_ = ttPessoa_jurid.ind_tip_pessoa_jurid.
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
        assign cod_unid_federac_ = ttPessoa_jurid.cod_unid_federac.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getUnidadeFederacaoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getUnidadeFederacaoCobranca Procedure 
PROCEDURE getUnidadeFederacaoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_unid_federac_cobr_ as character no-undo.

    do {&throws}:
        assign cod_unid_federac_cobr_ = ttPessoa_jurid.cod_unid_federac_cobr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getUnidadeFederacaoPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getUnidadeFederacaoPagamento Procedure 
PROCEDURE getUnidadeFederacaoPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_unid_federac_pagto_ as character no-undo.

    do {&throws}:
        assign cod_unid_federac_pagto_ = ttPessoa_jurid.cod_unid_federac_pagto.
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
        assign cod_usuar_ult_atualiz_ = ttPessoa_jurid.cod_usuar_ult_atualiz.
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

        create pessoa_jurid.
        buffer-copy ttPessoa_jurid except r-rowid
            to pessoa_jurid.

        assign ttPessoa_jurid.r-rowid = rowid(pessoa_jurid).
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
        assign log_ems_20_atlzdo_ = ttPessoa_jurid.log_ems_20_atlzdo.
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
        assign log_envio_bco_histor_ = ttPessoa_jurid.log_envio_bco_histor.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isFinsLucrativos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isFinsLucrativos Procedure 
PROCEDURE isFinsLucrativos :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter log_fins_lucrat_ as logical no-undo.

    do {&throws}:
        assign log_fins_lucrat_ = ttPessoa_jurid.log_fins_lucrat.
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

        buffer-copy pessoa_jurid to ttPessoa_jurid
            assign ttPessoa_jurid.r-rowid = rowid(pessoa_jurid).

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
        find first pessoa_jurid
            where rowid(pessoa_jurid) = ttPessoa_jurid.r-rowid
            exclusive-lock no-error no-wait.

        if not avail pessoa_jurid then do:
            if locked pessoa_jurid then
                run createError(17006, 'Registro travado por outro usu†rio (pessoa_jurid)').
            else do:
                {utp/ut-table.i emsuni pessoa_jurid 1}
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
        
        create ttPessoa_jurid.
        find first ttPessoa_jurid.
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
        assign ttPessoa_jurid.des_anot_tab = des_anot_tab_.
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
        assign ttPessoa_jurid.nom_bairro = nom_bairro_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setBairroCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setBairroCobranca Procedure 
PROCEDURE setBairroCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_bairro_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_bairro_cobr = nom_bairro_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setBairroPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setBairroPagamento Procedure 
PROCEDURE setBairroPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_bairro_pagto_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_bairro_pagto = nom_bairro_pagto_.
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
        assign ttPessoa_jurid.cod_cx_post = cod_cx_post_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCaixaPostalCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCaixaPostalCobranca Procedure 
PROCEDURE setCaixaPostalCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_cx_post_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_cx_post_cobr = cod_cx_post_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCaixaPostalPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCaixaPostalPagamento Procedure 
PROCEDURE setCaixaPostalPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_cx_post_pagto_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_cx_post_pagto = cod_cx_post_pagto_.
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
        assign ttPessoa_jurid.cod_cep = cod_cep_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCepCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCepCobranca Procedure 
PROCEDURE setCepCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_cep_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_cep_cobr = cod_cep_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCepPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCepPagamento Procedure 
PROCEDURE setCepPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_cep_pagto_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_cep_pagto = cod_cep_pagto_.
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
        assign ttPessoa_jurid.nom_cidade = nom_cidade_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCidadeCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCidadeCobranca Procedure 
PROCEDURE setCidadeCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_cidad_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_cidad_cobr = nom_cidad_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCidadePagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCidadePagamento Procedure 
PROCEDURE setCidadePagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_cidad_pagto_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_cidad_pagto = nom_cidad_pagto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCnpj) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCnpj Procedure 
PROCEDURE setCnpj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_id_feder_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_id_feder = cod_id_feder_.
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
        assign ttPessoa_jurid.nom_ender_compl = nom_ender_compl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setComplementoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setComplementoCobranca Procedure 
PROCEDURE setComplementoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_ender_compl_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_ender_compl_cobr = nom_ender_compl_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setComplementoPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setComplementoPagamento Procedure 
PROCEDURE setComplementoPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_ender_compl_pagto_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_ender_compl_pagto = nom_ender_compl_pagto_.
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
        assign ttPessoa_jurid.nom_condado = nom_condado_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCondadoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCondadoCobranca Procedure 
PROCEDURE setCondadoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_condad_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_condad_cobr = nom_condad_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCondadoPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCondadoPagamento Procedure 
PROCEDURE setCondadoPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_condad_pagto_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_condad_pagto = nom_condad_pagto_.
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
        assign ttPessoa_jurid.dat_ult_atualiz = dat_ult_atualiz_.
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
        assign ttPessoa_jurid.cod_e_mail = cod_e_mail_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEMailCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEMailCobranca Procedure 
PROCEDURE setEMailCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_e_mail_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_e_mail_cobr = cod_e_mail_cobr_.
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
        assign ttPessoa_jurid.log_ems_20_atlzdo = log_ems_20_atlzdo_.
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
        assign ttPessoa_jurid.nom_endereco = nom_endereco_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEnderecoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEnderecoCobranca Procedure 
PROCEDURE setEnderecoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_ender_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_ender_cobr = nom_ender_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEnderecoCobrancaTexto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEnderecoCobrancaTexto Procedure 
PROCEDURE setEnderecoCobrancaTexto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_ender_cobr_text_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_ender_cobr_text = nom_ender_cobr_text_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEnderecoPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEnderecoPagamento Procedure 
PROCEDURE setEnderecoPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_ender_pagto_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_ender_pagto = nom_ender_pagto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEnderecoPagamentoTexto) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEnderecoPagamentoTexto Procedure 
PROCEDURE setEnderecoPagamentoTexto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter nom_ender_pagto_text_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.nom_ender_pagto_text = nom_ender_pagto_text_.
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
        assign ttPessoa_jurid.nom_ender_text = nom_ender_text_.
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
        assign ttPessoa_jurid.log_envio_bco_histor = log_envio_bco_histor_.
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
        assign ttPessoa_jurid.cod_fax = cod_fax_.
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
        assign ttPessoa_jurid.cod_ramal_fax = cod_ramal_fax_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFinsLucrativos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFinsLucrativos Procedure 
PROCEDURE setFinsLucrativos :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter log_fins_lucrat_ as logical no-undo.

    do {&throws}:
        assign ttPessoa_jurid.log_fins_lucrat = log_fins_lucrat_.
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
        assign ttPessoa_jurid.nom_home_page = nom_home_page_.
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
        assign ttPessoa_jurid.hra_ult_atualiz = hra_ult_atualiz_.
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
        assign ttPessoa_jurid.cod_imagem = cod_imagem_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setInscricaoEstadual) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setInscricaoEstadual Procedure 
PROCEDURE setInscricaoEstadual :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_id_estad_jurid_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_id_estad_jurid = cod_id_estad_jurid_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setInscricaoMunicipal) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setInscricaoMunicipal Procedure 
PROCEDURE setInscricaoMunicipal :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_id_munic_jurid_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_id_munic_jurid = cod_id_munic_jurid_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setMatriz) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setMatriz Procedure 
PROCEDURE setMatriz :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter num_pessoa_jurid_matriz_ as integer no-undo.

    do {&throws}:
        assign ttPessoa_jurid.num_pessoa_jurid_matriz = num_pessoa_jurid_matriz_.
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
        assign ttPessoa_jurid.cod_modem = cod_modem_.
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
        assign ttPessoa_jurid.cod_ramal_modem = cod_ramal_modem_.
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
        assign ttPessoa_jurid.nom_pessoa = nom_pessoa_.
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
        assign ttPessoa_jurid.cod_pais = cod_pais_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPaisCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPaisCobranca Procedure 
PROCEDURE setPaisCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_pais_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_pais_cobr = cod_pais_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPaisPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPaisPagamento Procedure 
PROCEDURE setPaisPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_pais_pagto_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_pais_pagto = cod_pais_pagto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPessoaJuridica) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPessoaJuridica Procedure 
PROCEDURE setPessoaJuridica :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter num_pessoa_jurid_ as integer no-undo.

    do {&throws}:
        assign ttPessoa_jurid.num_pessoa_jurid = num_pessoa_jurid_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPessoaJuridicaCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPessoaJuridicaCobranca Procedure 
PROCEDURE setPessoaJuridicaCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter num_pessoa_jurid_cobr_ as integer no-undo.

    do {&throws}:
        assign ttPessoa_jurid.num_pessoa_jurid_cobr = num_pessoa_jurid_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPessoaJuridicaPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPessoaJuridicaPagamento Procedure 
PROCEDURE setPessoaJuridicaPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter num_pessoa_jurid_pagto_ as integer no-undo.

    do {&throws}:
        assign ttPessoa_jurid.num_pessoa_jurid_pagto = num_pessoa_jurid_pagto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPrevidencia) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPrevidencia Procedure 
PROCEDURE setPrevidencia :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_id_previd_social_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_id_previd_social = cod_id_previd_social_.
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
        assign ttPessoa_jurid.cod_telefone = cod_telefone_.
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
        assign ttPessoa_jurid.cod_telex = cod_telex_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTipoCapital) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTipoCapital Procedure 
PROCEDURE setTipoCapital :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter ind_tip_capit_pessoa_jurid_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.ind_tip_capit_pessoa_jurid = ind_tip_capit_pessoa_jurid_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTipoPessoa) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTipoPessoa Procedure 
PROCEDURE setTipoPessoa :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter ind_tip_pessoa_jurid_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.ind_tip_pessoa_jurid = ind_tip_pessoa_jurid_.
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
        assign ttPessoa_jurid.cod_unid_federac = cod_unid_federac_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUnidadeFederacaoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUnidadeFederacaoCobranca Procedure 
PROCEDURE setUnidadeFederacaoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_unid_federac_cobr_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_unid_federac_cobr = cod_unid_federac_cobr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUnidadeFederacaoPagamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUnidadeFederacaoPagamento Procedure 
PROCEDURE setUnidadeFederacaoPagamento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_unid_federac_pagto_ as character no-undo.

    do {&throws}:
        assign ttPessoa_jurid.cod_unid_federac_pagto = cod_unid_federac_pagto_.
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
        assign ttPessoa_jurid.cod_usuar_ult_atualiz = cod_usuar_ult_atualiz_.
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
        find current pessoa_jurid
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
        buffer-copy ttPessoa_jurid except r-rowid
            to pessoa_jurid.
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

&IF DEFINED(EXCLUDE-validateCnpj) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateCnpj Procedure 
PROCEDURE validateCnpj PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    find first ems5.pais 
        where pais.cod_pais = ttPessoa_jurid.cod_pais 
        no-lock no-error.
    
    if not avail pais then
        run createError in messageEms5(524, 
            'Pais inv†lido'
            + '~~':u
            + substitute('Pa°s "&1" inv†lido', ttPessoa_jurid.cod_pais)).
        return error.


    if pais.ind_validac_id_feder <> 'N∆o Valida' and 
       not isValidCnpj(ttPessoa_jurid.cod_id_feder) then do:

        run createError in messageEms5(524, 
            'CNPJ inv†lido'
            + '~~':u
            + substitute('CNPJ "&1" inv†lido', ttPessoa_jurid.cod_id_feder)).
        return error.
    end.

    if pais.ind_id_feder_jurid_unico = 'N∆o Valida' then
        return.
   
    if can-find(first pessoa_jurid 
            where pessoa_jurid.cod_pais = ttPessoa_jurid.cod_pais
              and pessoa_jurid.cod_id_feder = ttPessoa_jurid.cod_id_feder
              and pessoa_jurid.num_pessoa_jurid <> ttPessoa_jurid.num_pessoa_jurid) then do:

        run createError in messageEms5(524,
            'CNPJ j† cadastrado'
            + '~~':u 
            + substitute('O CNPJ "&1" j† existe', ttPessoa_jurid.cod_id_feder)).
        
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
        /* Faca aqui as validacoes para exclusao, mas nao de return-error,
           pois essa instrucao eh dada pelo metodo validate. Veja um exemplo:

        find first familia
            where familia.fm-codigo = ttFamilia.fm-codigo
            no-lock no-error.

        if not avail then
            run createError(17006, substitute('Fam°la de Materiais n∆o encontrada para exclus∆o', ttFamilia.fm-codigo)).
        */

        if can-find(first acum_pagto_pessoa 
            where acum_pagto_pessoa.num_pessoa = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Acumulados Pagamentos Pessoa!')).

        if can-find(first admdra_cartao_cr 
            where admdra_cartao_cr.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Administradora Cart∆o CrÇdito!')).

        if can-find(first emsuni.agenc_bcia 
            where emsuni.agenc_bcia.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Agància Banc†ria!')).

        if can-find(first arrendador 
            where arrendador.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Arrendador!')).

        if can-find(first arrendatario 
            where arrendatario.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Arrendat†rio!')).

        if can-find(first bem_pat 
            where bem_pat.num_pessoa_jurid_gartia = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Bem!')).

        if can-find(first emsuni.cliente 
            where emsuni.cliente.num_pessoa = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Cliente!')).

        /*if can-find(first stfscc.clien_supor 
            where stfscc.clien_supor.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Cliente Suporte!')).*/

        if can-find(first coment_usuar_hotel 
            where coment_usuar_hotel.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Coment†rio Hotel!')).

        if can-find(first conces_telef 
            where conces_telef.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Concession†ria Cobranáa!')).

        if can-find(first concorrente 
            where concorrente.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Concorrente!')).

        if can-find(first emsuni.contato 
            where emsuni.contato.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Contato Pessoa!')).

        if can-find(first emsuni.contat_clas 
            where emsuni.contat_clas.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Classes do Contato!')).

        if can-find(first emsuni.cta_corren 
            where emsuni.cta_corren.num_pessoa_jurid_dest_mutuo = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Conta Corrente!')).

        if can-find(first emsuni.cta_corren 
            where emsuni.cta_corren.num_pessoa_jurid_emit_mutuo = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Conta Corrente!')).

        if can-find(first emsuni.cta_corren 
            where emsuni.cta_corren.num_pessoa_jurid_favorec = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Conta Corrente!')).

        if can-find(first dirf_apb 
            where dirf_apb.num_pessoa = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Dado para Emiss∆o DIRF!')).

        if can-find(first emsuni.ender_entreg 
            where emsuni.ender_entreg.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Endereáo Entrega!')).

        if can-find(first emsuni.estabelecimento 
            where emsuni.estabelecimento.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Estabelecimento!')).

        if can-find(first fiador 
            where fiador.num_pessoa = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Fiador!')).

        if can-find(first emsuni.fornecedor 
            where emsuni.fornecedor.num_pessoa = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Fornecedor!')).

        if can-find(first horar_passag 
            where horar_passag.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Hor†rio Passagem!')).

        if can-find(first hotel_eec 
            where hotel_eec.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Hotel!')).

        if can-find(first emsuni.idiom_contat 
            where emsuni.idiom_contat.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Idioma Contato!')).

        /*if can-find(first emspmg.instit_trein 
            where emspmg.instit_trein.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Instituiá∆o Treinamento!')).*/

        /*if can-find(first emslgt.local_estoq 
            where emslgt.local_estoq.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Local Estoque!')).*/

        if can-find(first emsuni.marca 
            where emsuni.marca.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Marca!')).

        if can-find(first movto_bem_pat 
            where movto_bem_pat.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Movimento Bem Patrimonial!')).

        /*if can-find(first stfscc.movto_fo 
            where stfscc.movto_fo.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Movimento Chamado!')).*/

        if can-find(first parcei_spc 
            where parcei_spc.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Parceiro!')).

        if can-find(first passag_eec 
            where passag_eec.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Passagem!')).

        /*if can-find(first emspmg.pessoa_ext_trein 
            where emspmg.pessoa_ext_trein.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Pessoa Externa Treinamento!')).*/

        /*if can-find(first emspmg.pessoa_ext_trein 
            where emspmg.pessoa_ext_trein.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Pessoa Externa Treinamento!')).*/

        if can-find(first emsuni.pessoa_jurid_ativid 
            where emsuni.pessoa_jurid_ativid.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Pessoa Jur°dica Atividade!')).

        if can-find(first emsuni.pessoa_jurid_ramo_negoc 
            where emsuni.pessoa_jurid_ramo_negoc.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Pessoa Jur°dica Ramo Neg¢cio!')).

        if can-find(first ems5.portador 
            where portador.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Portador!')).

        if can-find(first emsuni.porte_pessoa_jurid 
            where emsuni.porte_pessoa_jurid.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Porte Pessoa Jur°dica!')).

        if can-find(first emsuni.representante 
            where emsuni.representante.num_pessoa = ttPessoa_jurid.num_pessoa_jurid) then
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Representante!')).

        if can-find(first seguradora 
            where seguradora.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Seguradora!')).

        /*if can-find(first emsuhr.sindicato 
            where emsuhr.sindicato.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then 
            run createError(17006, substitute('Pessoa Jur°dica possui relacionamentos com Sindicato!')).*/
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
        if can-find(first pessoa_jurid
                    where pessoa_jurid.num_pessoa_jurid = ttPessoa_jurid.num_pessoa_jurid) then do:
            run createError in messageEms5(524, 
                'Pessoa Jur°dica j† existe'
                + '~~':u
                + substitute('Pessoa &1 j† existe.' , ttPessoa_jurid.num_pessoa_jurid)).
            return error.
        end.

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
        
        
        if ttPessoa_jurid.cod_pais <> '' 
            and not can-find(first ems5.pais no-lock where 
                                pais.cod_pais = ttPessoa_jurid.cod_pais) then
            run createError in messageEms5(524,
                'Pa°s n∆o encontrado'
                + '~~':u  
                + substitute('Pa°s "&1" n∆o encontrado', ttPessoa_jurid.cod_pais)).

        if ttPessoa_jurid.cod_unid_federac <> '' and
           not can-find(first unid_feder no-lock where 
                              unid_feder.cod_pais = ttPessoa_jurid.cod_pais and
                              unid_feder.cod_unid_federac = ttPessoa_jurid.cod_unid_federac) then
            run createError in messageEms5(524,
                'Unidade da federaá∆o n∆o encontrada'
                + '~~':u
                + substitute('Unidade da federaá∆o &1 n∆o encontrada', ttPessoa_jurid.cod_unid_federac)).

        if lookup(ttPessoa_jurid.ind_tip_capit_pessoa_jurid, 
                  'Nacional,Multinacional,Municipal,Estadual,Federal') = 0 then
            run createError in messageEms5(524,
                'Tipo de capital inv†lido'
                + '~~':u
                + substitute('Tipo de capital "&1" n∆o Ç v†lido', ttPessoa_jurid.ind_tip_capit_pessoa_jurid)).

        if lookup(ttPessoa_jurid.ind_tip_pessoa_jurid, 'Privada,P£blica,Mista') = 0 then
            run createError in messageEms5(524,
                'Tipo de pessoa jur°dica inv†lido'
                + '~~':u
                + substitute('Tipo de pessoa jur°dica "&1" n∆o Ç v†lido', ttPessoa_jurid.ind_tip_pessoa_jurid)).
        /*** Cadastro de Pessoa Jur°dica n∆o valida cidade
        if ttPessoa_jurid.nom_cidade <> '' and
           not can-find(first cidade no-lock where 
                              cidade.nom_cidade = ttPessoa_jurid.nom_cidade) then
          run createError(17006, substitute('Cidade &1 n∆o encontrado', ttPessoa_jurid.nom_cidade)).
        ***/

        run validateCnpj.


    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

