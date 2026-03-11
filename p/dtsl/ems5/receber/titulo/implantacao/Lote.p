&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   Lote
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

&scoped-define Cheque               _integr_acr_cheq
&scoped-define Relacionamento       _integr_acr_aprop_relacto_2
&scoped-define Lote                 _integr_acr_lote_impl
&scoped-define Item                 _integr_acr_item_lote_impl_8
&scoped-define ApropriacaoContabil  _integr_acr_aprop_ctbl_pend
&scoped-define Antecipacao          _integr_acr_abat_antecip
&scoped-define Receita              _integr_acr_aprop_desp_rec
&scoped-define Imposto              _integr_acr_impto_impl_pend
&scoped-define Representante        _integr_acr_repres_pend
&scoped-define Comissao             _integr_acr_repres_comis_2
&scoped-define Erro                 _log_erros_atualiz

{dtsl/ems5/receber/titulo/implantacao/Implantacao.i}

define variable apiImplantacao as handle    no-undo.
define variable itens as handle no-undo.
define variable cheques as handle    no-undo.
define variable relacionamentos as handle    no-undo.

define variable matrizTraducaoExterna as character no-undo.
define variable atualizaReferencia as logical   no-undo.
define variable assumeDataEmissao as logical   no-undo.

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
         HEIGHT             = 28.04
         WIDTH              = 46.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-addCheque) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addCheque Procedure 
PROCEDURE addCheque :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cheque as handle no-undo.
    
    do {&throws}:
        run verifyInstanceCheques.

        run add in cheques(cheque).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-addItem) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addItem Procedure 
PROCEDURE addItem :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter item as handle no-undo.
    
    do {&throws}:
        run verifyInstanceItens.

        run add in itens(item).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-addRelacionamento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addRelacionamento Procedure 
PROCEDURE addRelacionamento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter relacionamento as handle no-undo.
    
    do {&throws}:
        run verifyInstanceRelacionamentos.

        run add in relacionamentos(relacionamento).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-afterNew) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterNew Procedure 
PROCEDURE afterNew :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    
    define variable referencia as character no-undo.
    
    do {&throws}:
        run setDataTransacao(today).
        run setMatrizTraducaoExterna('').
        run setAtualizaReferencia(true).
        run setTipoCobranca('Normal').
        run setTipoEspecieDocumento('Normal').
        run setOrigemTitulo('ACR').
        run setLoteImplantacaoOk(true).

        run utils/geraReferenciaEMS5.p(output referencia).
        run setReferencia(referencia).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-beforeInsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInsert Procedure 
PROCEDURE beforeInsert :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do {&throws}:
        /*<Execute os set's das colunas de valores default. Se nao precisar, exclua esse metodo>*/
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-calculateItemSequencia) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calculateItemSequencia Procedure 
PROCEDURE calculateItemSequencia :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter sequencia as integer no-undo.

    do {&throws}:
        assign 
            sequencia = 10.

        find last tt{&Item}
            where tt{&Item}.ttv_rec_lote_impl_tit_acr = recid(tt{&Lote})
            no-lock no-error.

        if avail tt{&item} then
            assign 
                sequencia = tt{&Item}.tta_num_seq_refer + 10.
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
        empty temp-table tt{&Cheque} no-error.
        empty temp-table tt{&Relacionamento} no-error.
        empty temp-table tt{&Lote} no-error.
        empty temp-table tt{&Item} no-error.
        empty temp-table tt{&ApropriacaoContabil} no-error.
        empty temp-table tt{&Antecipacao} no-error.
        empty temp-table tt{&Receita} no-error.
        empty temp-table tt{&Imposto} no-error.
        empty temp-table tt{&Representante} no-error.
        empty temp-table tt{&Comissao} no-error.
        empty temp-table tt{&Erro} no-error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearCheques) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearCheques Procedure 
PROCEDURE clearCheques :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run clear in cheques.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearItens) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearItens Procedure 
PROCEDURE clearItens :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run clear in itens.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearRelacionamentos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearRelacionamentos Procedure 
PROCEDURE clearRelacionamentos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run clear in relacionamentos.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-dispose) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dispose Procedure 
PROCEDURE dispose :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if valid-handle(apiImplantacao) then
            delete widget apiImplantacao.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCodigoCliente) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCodigoCliente Procedure 
PROCEDURE getCodigoCliente :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter idFederal as character  no-undo.
    define output parameter cliente as integer    no-undo.

    define variable estabelecimento as handle    no-undo.
    define variable pessoaFisica as handle    no-undo.
    define variable pessoaJuridica as handle    no-undo.

    define variable codigoEstabel as character no-undo.
    define variable pais as character no-undo.
    define variable found as logical   no-undo.

    do {&throws}:
        run getEstabelecimento(output codigoEstabel).

        run createInstance in ghInstanceManager(this-procedure,            
            'dtsl/ems5/common/Estabelecimento.p':u, output estabelecimento).

        run find in estabelecimento(codigoEstabel).
        run getPais in estabelecimento(output pais).

        run createInstance in ghInstanceManager(this-procedure,            
            'dtsl/ems5/common/PessoaFisica.p':u, output pessoaFisica).

        run canFindByIdFederal in pessoaFisica(pais, idFederal, output found).
        if found then do:
            run findByIdFederal in pessoaFisica(pais, idFederal).
            run getEmitente in pessoaFisica(output cliente).
            return.
        end.

        run createInstance in ghInstanceManager(this-procedure,            
            'dtsl/ems5/common/PessoaJuridica.p':u, output pessoaJuridica).     

        run canFindByIdFederal in pessoaJuridica(pais, idFederal, output found).
        if found then do:
            run findByIdFederal in pessoaJuridica(pais, idFederal).
            run getEmitente in pessoaJuridica(output cliente).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDataTransacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDataTransacao Procedure 
PROCEDURE getDataTransacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_dat_transacao_ as date no-undo.

    do {&throws}:
        assign
            tta_dat_transacao_ = tt{&Lote}.tta_dat_transacao.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEmpresa) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEmpresa Procedure 
PROCEDURE getEmpresa :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_empresa_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_empresa_ = tt{&Lote}.tta_cod_empresa.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEmpresaExterna) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEmpresaExterna Procedure 
PROCEDURE getEmpresaExterna :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter ttv_cod_empresa_ext_ as character no-undo.

    do {&throws}:
        assign
            ttv_cod_empresa_ext_ = tt{&Lote}.ttv_cod_empresa_ext.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEspecieDocumento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEspecieDocumento Procedure 
PROCEDURE getEspecieDocumento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_espec_docto_ = tt{&Lote}.tta_cod_espec_docto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEstabelecimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEstabelecimento Procedure 
PROCEDURE getEstabelecimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_estab_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_estab_ = tt{&Lote}.tta_cod_estab.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEstabelecimentoExterno) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEstabelecimentoExterno Procedure 
PROCEDURE getEstabelecimentoExterno :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_estab_ext_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_estab_ext_ = tt{&Lote}.tta_cod_estab_ext.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFinalidadeEconomicaExterna) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFinalidadeEconomicaExterna Procedure 
PROCEDURE getFinalidadeEconomicaExterna :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_finalid_econ_ext_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_finalid_econ_ext_ = tt{&Lote}.tta_cod_finalid_econ_ext.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getIndicadorEconomico) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getIndicadorEconomico Procedure 
PROCEDURE getIndicadorEconomico :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_indic_econ_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_indic_econ_ = tt{&Lote}.tta_cod_indic_econ.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getOrigemTitulo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getOrigemTitulo Procedure 
PROCEDURE getOrigemTitulo :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_ind_orig_tit_acr_ as character no-undo.

    do {&throws}:
        assign
            tta_ind_orig_tit_acr_ = tt{&Lote}.tta_ind_orig_tit_acr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getReferencia) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getReferencia Procedure 
PROCEDURE getReferencia :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_cod_refer_ as character no-undo.

    do {&throws}:
        assign
            tta_cod_refer_ = tt{&Lote}.tta_cod_refer.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTipoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTipoCobranca Procedure 
PROCEDURE getTipoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_ind_tip_cobr_acr_ as character no-undo.

    do {&throws}:
        assign
            tta_ind_tip_cobr_acr_ = tt{&Lote}.tta_ind_tip_cobr_acr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTipoEspecieDocumento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTipoEspecieDocumento Procedure 
PROCEDURE getTipoEspecieDocumento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_ind_tip_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            tta_ind_tip_espec_docto_ = tt{&Lote}.tta_ind_tip_espec_docto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getValorImplantacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getValorImplantacao Procedure 
PROCEDURE getValorImplantacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_val_tot_lote_impl_tit_acr_ as decimal no-undo.

    do {&throws}:
        assign
            tta_val_tot_lote_impl_tit_acr_ = tt{&Lote}.tta_val_tot_lote_impl_tit_acr.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getValorInformado) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getValorInformado Procedure 
PROCEDURE getValorInformado :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_val_tot_lote_infor_tit_acr_ as decimal no-undo.

    do {&throws}:
        assign
            tta_val_tot_lote_infor_tit_acr_ = tt{&Lote}.tta_val_tot_lote_infor_tit_acr.
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

        run populateRelacionamentos.
        run populateCheques.
        run populateLote.

        run validate('insert':u).

        run verifyInstanceApi.
        run pi_main_code_integr_acr_new_9 in apiImplantacao(
            11,
            matrizTraducaoExterna,
            atualizaReferencia,
            assumeDataEmissao,
            input table tt{&Comissao},
            input-output table tt{&Item},
            input table tt{&Relacionamento}).

        run verifyErrors.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isLiquidacaoAutomatica) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isLiquidacaoAutomatica Procedure 
PROCEDURE isLiquidacaoAutomatica :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter tta_log_liquidac_autom_ as logical no-undo.

    do {&throws}:
        assign
            tta_log_liquidac_autom_ = tt{&Lote}.tta_log_liquidac_autom.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isLoteImplantacaoOk) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isLoteImplantacaoOk Procedure 
PROCEDURE isLoteImplantacaoOk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter ttv_log_lote_impl_ok_ as logical no-undo.

    do {&throws}:
        assign
            ttv_log_lote_impl_ok_ = tt{&Lote}.ttv_log_lote_impl_ok.
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

        create tt{&Lote}.

        run afterNew in child().
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateAntecipacoes) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateAntecipacoes Procedure 
PROCEDURE populateAntecipacoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter item as handle     no-undo.

    define variable antecipacoes as handle    no-undo.

    do {&throws}:
        run getAntecipacoes in item(output antecipacoes).

        if not valid-handle(antecipacoes) then
            return.

        {system/forEach.i antecipacao antecipacoes}
            create tt{&Antecipacao}.
            assign 
                tt{&Antecipacao}.ttv_rec_item_lote_impl_tit_acr = tt{&Item}.ttv_rec_item_lote_impl_tit_acr
                tt{&Antecipacao}.ttv_rec_abat_antecip_acr = recid(tt{&Antecipacao}).
    
            run getEspecieDocumento           in antecipacao(output tt{&Antecipacao}.tta_cod_espec_docto).
            run getEstabelecimento            in antecipacao(output tt{&Antecipacao}.tta_cod_estab).
            run getEstabelecimentoExterno     in antecipacao(output tt{&Antecipacao}.tta_cod_estab_ext).
            run getParcela                    in antecipacao(output tt{&Antecipacao}.tta_cod_parcela).
            run getSerieDocumento             in antecipacao(output tt{&Antecipacao}.tta_cod_ser_docto).
            run getTitulo                     in antecipacao(output tt{&Antecipacao}.tta_cod_tit_acr).
            run getValorAbatimentoAntecipacao in antecipacao(output tt{&Antecipacao}.tta_val_abtdo_antecip_tit_abat).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateApropriacoesContabeis) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateApropriacoesContabeis Procedure 
PROCEDURE populateApropriacoesContabeis :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter item as handle     no-undo.

    define variable apropriacoesContabeis as handle    no-undo.

    do {&throws}:
        run getApropriacoesContabeis in item(output apropriacoesContabeis).

        if not valid-handle(apropriacoesContabeis) then
            return.

        {system/forEach.i apropriacaoContabil apropriacoesContabeis}
            create tt{&ApropriacaoContabil}.
            assign 
                tt{&ApropriacaoContabil}.ttv_rec_item_lote_impl_tit_acr = tt{&Item}.ttv_rec_item_lote_impl_tit_acr.

            run getCentroCusto              in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_ccusto).
            run getCentroCustoExterno       in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_ccusto_ext).
            run getCentroCustoExterno-1     in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_sub_cta_ctbl_ext).
            run getContaContabil            in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_cta_ctbl).
            run getContaContabilExterna     in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_cta_ctbl_ext).
            run getFluxoFinanceiroExterno   in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_fluxo_financ_ext).
            run getImposto                  in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_imposto).
            run getImpostoClassificacao     in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_classif_impto).
            run getPais                     in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_pais).
            run getPaisExterno              in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_pais_ext).
            run getPlanoCentroCusto         in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_plano_ccusto).
            run getPlanoContas              in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_plano_cta_ctbl).
            run getTipoFluxoFinanceiro      in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_tip_fluxo_financ).
            run getUnidadeFederacao         in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_unid_federac).
            run getUnidadeNegocio           in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_unid_negoc).
            run getUnidadeNegocioExterna    in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_cod_unid_negoc_ext).
            run getValorApropriacaoContabil in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_val_aprop_ctbl).
            run isImpostoValorAgregado      in apropriacaoContabil(output tt{&ApropriacaoContabil}.tta_log_impto_val_agreg).
        end.
    end.
            
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateCheques) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateCheques Procedure 
PROCEDURE populateCheques PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if not valid-handle(cheques) then
            return.

        {system/forEach.i cheque cheques}
            create tt{&Cheque}.
            run getAgenciaBancaria              in cheque(output tt{&Cheque}.tta_cod_agenc_bcia).
            run getBanco                        in cheque(output tt{&Cheque}.tta_cod_banco).
            run getContaCorrente                in cheque(output tt{&Cheque}.tta_cod_cta_corren).
            run getDataDeposito                 in cheque(output tt{&Cheque}.tta_dat_depos_cheq_acr).
            run getDataDepositoPrevisao         in cheque(output tt{&Cheque}.tta_dat_prev_depos_cheq_acr).
            run getDataDesconto                 in cheque(output tt{&Cheque}.tta_dat_desc_cheq_acr).
            run getDataDescontoPrevisao         in cheque(output tt{&Cheque}.tta_dat_prev_desc_cheq_acr).
            run getDataEmissao                  in cheque(output tt{&Cheque}.tta_dat_emis_cheq).
            run getEmitenteCidade               in cheque(output tt{&Cheque}.tta_nom_cidad_emit).
            run getEmitenteNome                 in cheque(output tt{&Cheque}.tta_nom_emit).
            run getEstabelecimento              in cheque(output tt{&Cheque}.tta_cod_estab).
            run getEstabelecimentoExterno       in cheque(output tt{&Cheque}.tta_cod_estab_ext).
            run getFinalidadeEconomicaExterna   in cheque(output tt{&Cheque}.tta_cod_finalid_econ_ext).
            run getIdFederacao                  in cheque(output tt{&Cheque}.tta_cod_id_feder).
            run getIndicadorEconomico           in cheque(output tt{&Cheque}.tta_cod_indic_econ).
            run getMotivoDevolucao              in cheque(output tt{&Cheque}.tta_cod_motiv_devol_cheq).
            run getNumeroCheque                 in cheque(output tt{&Cheque}.tta_num_cheque).
            run getNumeroPessoa                 in cheque(output tt{&Cheque}.tta_num_pessoa).
            run getPais                         in cheque(output tt{&Cheque}.tta_cod_pais).
            run getUsuarioChequeTerceiro        in cheque(output tt{&Cheque}.tta_cod_usuar_cheq_acr_terc).
            run getValorCheque                  in cheque(output tt{&Cheque}.tta_val_cheque).
            run isDevolvido                     in cheque(output tt{&Cheque}.tta_log_cheq_acr_devolv).
            run isRenegociado                   in cheque(output tt{&Cheque}.tta_log_cheq_acr_renegoc).
            run isTerceiro                      in cheque(output tt{&Cheque}.tta_log_cheq_terc).
            run isPendente                      in cheque(output tt{&Cheque}.tta_log_pend_cheq_acr).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateComissoes) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateComissoes Procedure 
PROCEDURE populateComissoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter item as handle     no-undo.

    define variable comissoes as handle    no-undo.

    do {&throws}:
        run getComissoes in item(output comissoes).

        if not valid-handle(comissoes) then
            return.

        {system/forEach.i comissao comissoes}
            create tt{&Comissao}.
            assign 
                tt{&Comissao}.ttv_rec_item_lote_impl_tit_acr = tt{&Item}.ttv_rec_item_lote_impl_tit_acr.

            run getRepresentante      in comissao(output tt{&Comissao}.tta_cdn_repres).
            run getLiberacaoPagamento in comissao(output tt{&Comissao}.ttv_ind_liber_pagto_comis).
            run getSituacaoExterna    in comissao(output tt{&Comissao}.ttv_ind_sit_comis_ext).
            run getTipoExterno        in comissao(output tt{&Comissao}.tta_ind_tip_comis_ext).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateImpostos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateImpostos Procedure 
PROCEDURE populateImpostos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter item as handle     no-undo.

    define variable impostos as handle    no-undo.

    do {&throws}:
        run getImpostos in item(output impostos).

        if not valid-handle(impostos) then
            return.

        {system/forEach.i imposto impostos}
            create tt{&Imposto}.
            assign 
                tt{&Imposto}.ttv_rec_item_lote_impl_tit_acr = tt{&Item}.ttv_rec_item_lote_impl_tit_acr.

            run getCentroCustoExterno             in imposto(output tt{&Imposto}.tta_cod_sub_cta_ctbl_ext).
            run getContaContabil                  in imposto(output tt{&Imposto}.tta_cod_cta_ctbl).
            run getContaContabilExterna           in imposto(output tt{&Imposto}.tta_cod_cta_ctbl_ext).
            run getFinalidadeEconomicaExterna     in imposto(output tt{&Imposto}.tta_cod_finalid_econ_ext).
            run getImposto                        in imposto(output tt{&Imposto}.tta_cod_imposto).
            run getImpostoAliquota                in imposto(output tt{&Imposto}.tta_val_aliq_impto).
            run getImpostoClasse                  in imposto(output tt{&Imposto}.tta_ind_clas_impto).
            run getImpostoClassificacao           in imposto(output tt{&Imposto}.tta_cod_classif_impto).
            run getImpostoValor                   in imposto(output tt{&Imposto}.tta_val_imposto).
            run getIndicadorEconomico             in imposto(output tt{&Imposto}.tta_cod_indic_econ).
            run getIndicadorEconomicoCotacaoData  in imposto(output tt{&Imposto}.tta_dat_cotac_indic_econ).
            run getIndicadorEconomicoCotacaoValor in imposto(output tt{&Imposto}.tta_val_cotac_indic_econ).
            run getIndicadorEconomicoImpostoValor in imposto(output tt{&Imposto}.tta_val_impto_indic_econ_impto).
            run getPais                       in imposto(output tt{&Imposto}.tta_cod_pais).
            run getPaisExterno                in imposto(output tt{&Imposto}.tta_cod_pais_ext).
            run getPlanoContas                in imposto(output tt{&Imposto}.tta_cod_plano_cta_ctbl).
            run getRendimentoTributavel       in imposto(output tt{&Imposto}.tta_val_rendto_tribut).
            run getSequencia                  in imposto(output tt{&Imposto}.tta_num_seq).
            run getUnidadeFederacao           in imposto(output tt{&Imposto}.tta_cod_unid_federac).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateItens) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateItens Procedure 
PROCEDURE populateItens PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter valorTotal as decimal    no-undo.

    define variable idFederal as character no-undo.
    define variable cliente as integer   no-undo.

    do {&throws}:
        if not valid-handle(itens) then
            return.

        {system/forEach.i item itens}
            create tt{&Item}.
            assign 
                tt{&Item}.ttv_rec_lote_impl_tit_acr = recid(tt{&Lote})
                tt{&Item}.ttv_rec_item_lote_impl_tit_acr = recid(tt{&Item})
                tt{&Item}.tta_cod_refer = tt{&Lote}.tta_cod_refer.

            run calculateItemSequencia(output tt{&item}.tta_num_seq_refer).

            run getCliente in item(output cliente).
            if cliente = 0 then do:
                run getIdFederal in item(output idFederal).
                if trim(idFederal) <> '' then
                    run getCodigoCliente(idFederal, output tt{&Item}.tta_cdn_cliente).
            end.

            run populateAntecipacoes(item).
            run populateApropriacoesContabeis(item).
            run populateComissoes(item).
            run populateImpostos(item).
            run populateReceitas(item).
            run populateRepresentantes(item).

            run getAgencia                          in item(output tt{&Item}.tta_cod_agenc_bcia).
            run getAgenciaCobranca                  in item(output tt{&Item}.tta_cod_agenc_cobr_bcia).
            run getAgenciaFp                        in item(output tt{&Item}.ttv_cdn_agenc_fp).
            run getBanco                            in item(output tt{&Item}.tta_cod_banco).
            run getCarteiraBancaria                 in item(output tt{&Item}.tta_cod_cart_bcia).                                    
            run getCodigoAdministradora             in item(output tt{&Item}.tta_cod_admdra_cartao_cr).
            run getCodigoAutorizacao                in item(output tt{&Item}.ttv_cod_autoriz_bco_emissor).
            run getCodigoAutorizacaoCartaoCredito   in item(output tt{&Item}.tta_cod_autoriz_cartao_cr).
            run getCodigoCartaoCredito              in item(output tt{&Item}.tta_cod_cartcred).
            run getComprovanteVenda                 in item(output tt{&Item}.ttv_cod_comprov_vda_aux).
            run getConcessionariaDdd                in item(output tt{&Item}.tta_num_ddd_localid_conces).
            run getConcessionariaMilhar             in item(output tt{&Item}.tta_num_milhar_localid_conces).
            run getConcessionariaPrefixo            in item(output tt{&Item}.tta_num_prefix_localid_conces).
            run getConcessionariaTelefone           in item(output tt{&Item}.tta_cod_conces_telef).
            run getCondicaoCobranca                 in item(output tt{&Item}.tta_cod_cond_cobr).
            run getCondicaoPagamento                in item(output tt{&Item}.tta_cod_cond_pagto).
            run getContaCorrente                    in item(output tt{&Item}.tta_cod_cta_corren_bco).
            run getContaCorrenteDigito              in item(output tt{&Item}.tta_cod_digito_cta_corren).
            run getContatoNomeAbreviado             in item(output tt{&Item}.tta_nom_abrev_contat).
            run getDataAbatimento                   in item(output tt{&Item}.tta_dat_abat_tit_acr).
            run getDataCompraCartao                 in item(output tt{&Item}.tta_dat_compra_cartao_cr).
            run getDataDesconto                     in item(output tt{&Item}.tta_dat_desconto).
            run getDataEmissao                      in item(output tt{&Item}.tta_dat_emis_docto).
            run getDataLiquidacaoPrevisao           in item(output tt{&Item}.tta_dat_prev_liquidac).
            run getDataVencimento                   in item(output tt{&Item}.tta_dat_vencto_tit_acr).
            run getDiasCarenciaJuros                in item(output tt{&Item}.tta_qtd_dias_carenc_juros_acr).
            run getDiasCarenciaMulta                in item(output tt{&Item}.tta_qtd_dias_carenc_multa_acr).
            run getEnderecoCobranca                 in item(output tt{&Item}.tta_ind_ender_cobr).
            run getEspecieDocumento                 in item(output tt{&Item}.tta_cod_espec_docto).
            run getEstabelecimentoPortador          in item(output tt{&Item}.ttv_cod_estab_portad).
            run getFinalidadeEconomicaExterna       in item(output tt{&Item}.tta_cod_finalid_econ_ext).
            run getHistoricoPadrao                  in item(output tt{&Item}.tta_cod_histor_padr).
            run getHistoricoDescricao               in item(output tt{&Item}.tta_des_text_histor).
            run getIdMovimento                      in item(output tt{&Item}.tta_num_id_movto_tit_acr).
            run getIdMovimentoContaCorrente         in item(output tt{&Item}.tta_num_id_movto_cta_corren).
            run getIdTitulo                         in item(output tt{&Item}.tta_num_id_tit_acr).
            run getIndicacaoEconomica               in item(output tt{&Item}.tta_cod_indic_econ).
            run getIndicacaoEconomicaDesembolso     in item(output tt{&Item}.tta_cod_indic_econ_desemb).
            run getInstrucaoBancaria1               in item(output tt{&Item}.tta_cod_instruc_bcia_1_movto).
            run getInstrucaoBancaria2               in item(output tt{&Item}.tta_cod_instruc_bcia_2_movto).
            run getLoteVendaOriginal                in item(output tt{&Item}.ttv_cod_lote_origin).
            run getMesAnoValidadeCartao             in item(output tt{&Item}.tta_cod_mes_ano_valid_cartao).
            run getModalidadeExterna                in item(output tt{&Item}.tta_cod_modalid_ext).
            run getMotivoMovimento                  in item(output tt{&Item}.tta_cod_motiv_movto_tit_acr).
            run getNotaFiscalFaturamento            in item(output tt{&Item}.ttv_cod_nota_fisc_faturam).
            run getNumeroParcelas                   in item(output tt{&Item}.ttv_num_parc_cartcred).
            run getObservacaoCobranca               in item(output tt{&Item}.tta_des_obs_cobr).
            run getParcela                          in item(output tt{&Item}.tta_cod_parcela). 
            run getPercentualAbatimento             in item(output tt{&Item}.tta_val_perc_abat_acr).
            run getPercentualJurosDiaAtraso         in item(output tt{&Item}.tta_val_perc_juros_dia_atraso).
            run getPortador                         in item(output tt{&Item}.tta_cod_portador).
            run getPortadorExterno                  in item(output tt{&Item}.tta_cod_portad_ext).
            run getProcessoExportacao               in item(output tt{&Item}.tta_cod_proces_export).
            run getRepresentante                    in item(output tt{&Item}.tta_cdn_repres).
            run getSerieDocumento                   in item(output tt{&Item}.tta_cod_ser_docto).
            run getSituacao                         in item(output tt{&Item}.tta_ind_sit_tit_acr).
            run getSituacaoBancaria                 in item(output tt{&Item}.tta_ind_sit_bcia_tit_acr).
            run getTipoCalculoJuros                 in item(output tt{&Item}.tta_ind_tip_calc_juros).
            run getTipoEspecieDocumento             in item(output tt{&Item}.tta_ind_tip_espec_docto).
            run getTitulo                           in item(output tt{&Item}.tta_cod_tit_acr).
            run getTituloBanco                      in item(output tt{&Item}.tta_cod_tit_acr_bco).
            run getValorAbatimento                  in item(output tt{&Item}.tta_val_abat_tit_acr).
            run getValorBaseCalculoComissao         in item(output tt{&Item}.tta_val_base_calc_comis).
            run getValorBaseCalculoImposto          in item(output tt{&Item}.tta_val_base_calc_impto).
            run getValorCotacao                     in item(output tt{&Item}.tta_val_cotac_indic_econ).
            run getValorCreditoCofins               in item(output tt{&Item}.ttv_val_cr_cofins).
            run getValorCreditoCsll                 in item(output tt{&Item}.ttv_val_cr_csll).
            run getValorCreditoPis                  in item(output tt{&Item}.ttv_val_cr_pis).
            run getValorDesconto                    in item(output tt{&Item}.tta_val_desconto).
            run getValorDescontoPercentual          in item(output tt{&Item}.tta_val_perc_desc).
            run getValorLiquido                     in item(output tt{&Item}.tta_val_liq_tit_acr).
            run getValorMultaAtrasoPercentual       in item(output tt{&Item}.tta_val_perc_multa_atraso).
            run getValorTitulo                      in item(output tt{&Item}.tta_val_tit_acr).
            run getVendorCondicaoPagamento          in item(output tt{&Item}.ttv_cod_cond_pagto_vendor).
            run getVendorDataBase                   in item(output tt{&Item}.ttv_dat_base_fechto_vendor).
            run getVendorDiasCarencia               in item(output tt{&Item}.ttv_qti_dias_carenc_fechto).
            run getVendorEstabelecimento            in item(output tt{&Item}.ttv_cod_estab_vendor).
            run getVendorPlanilha                   in item(output tt{&Item}.ttv_num_planilha_vendor).
            run getVendorTaxaCliente                in item(output tt{&Item}.ttv_val_cotac_tax_vendor_clie).
            run isAssumeTaxaBanco                   in item(output tt{&Item}.ttv_log_assume_tax_bco).
            run isCreditoComGarantia                in item(output tt{&Item}.tta_log_tip_cr_perda_dedut_tit).
            run isDebitoAutomatico                  in item(output tt{&Item}.tta_log_db_autom).
            run isDestinacaoCobranca                in item(output tt{&Item}.tta_log_destinac_cobr).
            run isLiquidacaoAutomatica              in item(output tt{&Item}.tta_log_liquidac_autom).
            run isRetencaoImpostoImplantacao        in item(output tt{&Item}.tta_log_retenc_impto_impl).
            run isVendor                            in item(output tt{&Item}.ttv_log_vendor).

            assign
                valorTotal = valorTotal + tt{&Item}.tta_val_tit_acr.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateLote) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateLote Procedure 
PROCEDURE populateLote PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable valorTotal as decimal   no-undo.

    do {&throws}:
        create tt{&Lote}.
        run getDataTransacao              (output tt{&Lote}.tta_dat_transacao).
        run getEmpresa                    (output tt{&Lote}.tta_cod_empresa).
        run getEmpresaExterna             (output tt{&Lote}.ttv_cod_empresa_ext).
        run getEspecieDocumento           (output tt{&Lote}.tta_cod_espec_docto).
        run getEstabelecimento            (output tt{&Lote}.tta_cod_estab).
        run getEstabelecimentoExterno     (output tt{&Lote}.tta_cod_estab_ext).
        run getFinalidadeEconomicaExterna (output tt{&Lote}.tta_cod_finalid_econ_ext).
        run getIndicadorEconomico         (output tt{&Lote}.tta_cod_indic_econ).
        run getOrigemTitulo               (output tt{&Lote}.tta_ind_orig_tit_acr).
        run getReferencia                 (output tt{&Lote}.tta_cod_refer).
        run getTipoCobranca               (output tt{&Lote}.tta_ind_tip_cobr_acr).
        run getTipoEspecieDocumento       (output tt{&Lote}.tta_ind_tip_espec_docto).
        run getValorImplantacao           (output tt{&Lote}.tta_val_tot_lote_impl_tit_acr).
        run getValorInformado             (output tt{&Lote}.tta_val_tot_lote_infor_tit_acr).
        run isLiquidacaoAutomatica        (output tt{&Lote}.tta_log_liquidac_autom).
        run isLoteImplantacaoOk           (output tt{&Lote}.ttv_log_lote_impl_ok).

        run populateItens(output valorTotal).

        if tt{&Lote}.tta_val_tot_lote_impl_tit_acr = 0 then
            assign
                tt{&Lote}.tta_val_tot_lote_impl_tit_acr = valorTotal.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateReceitas) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateReceitas Procedure 
PROCEDURE populateReceitas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter item as handle     no-undo.

    define variable receitas as handle    no-undo.

    do {&throws}:
        run getReceitas in item(output receitas).

        if not valid-handle(receitas) then
            return.

        {system/forEach.i receita receitas}
            create tt{&Receita}.
            assign 
                tt{&Receita}.ttv_rec_item_lote_impl_tit_acr = tt{&Item}.ttv_rec_item_lote_impl_tit_acr.

            run getCentroCustoExterno     in receita(output tt{&Receita}.tta_cod_sub_cta_ctbl_ext).
            run getContaContabil          in receita(output tt{&Receita}.tta_cod_cta_ctbl).
            run getContaContabilExterna   in receita(output tt{&Receita}.tta_cod_cta_ctbl_ext).
            run getFluxoFinanceiroExterno in receita(output tt{&Receita}.tta_cod_fluxo_financ_ext).
            run getPlanoContas            in receita(output tt{&Receita}.tta_cod_plano_cta_ctbl).
            run getTipoAbatimento         in receita(output tt{&Receita}.tta_cod_tip_abat).
            run getTipoApropriacao        in receita(output tt{&Receita}.tta_ind_tip_aprop_recta_despes).
            run getTipoFluxoFinanceiro    in receita(output tt{&Receita}.tta_cod_tip_fluxo_financ).
            run getUnidadeNegocio         in receita(output tt{&Receita}.tta_cod_unid_negoc).
            run getUnidadeNegocioExterna  in receita(output tt{&Receita}.tta_cod_unid_negoc_ext).
            run getValorPercentualRateio  in receita(output tt{&Receita}.tta_val_perc_rat_ctbz).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateRelacionamentos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateRelacionamentos Procedure 
PROCEDURE populateRelacionamentos PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if not valid-handle(relacionamentos) then
            return.

        {system/forEach.i relacionamento relacionamentos}
            create tt{&Relacionamento}.
            assign 
                tt{&Relacionamento}.ttv_rec_relacto_pend_tit_acr = recid(tt{&Relacionamento}).

            run getCentroCusto      in relacionamento(output tt{&Relacionamento}.tta_cod_ccusto).
            run getPlanoCentroCusto in relacionamento(output tt{&Relacionamento}.tta_cod_plano_ccusto).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateRepresentantes) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateRepresentantes Procedure 
PROCEDURE populateRepresentantes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter item as handle     no-undo.

    define variable representantes as handle    no-undo.
            
    do {&throws}:
        run getRepresentantes in item(output representantes).

        if not valid-handle(representantes) then
            return.

        {system/forEach.i representante representantes}
            create tt{&Representante}.
            assign tt{&Representante}.ttv_rec_item_lote_impl_tit_acr = tt{&Item}.ttv_rec_item_lote_impl_tit_acr.

            run getRepresentante                      in representante(output tt{&Representante}.tta_cdn_repres).
            run getTipoComissao                       in representante(output tt{&Representante}.tta_ind_tip_comis).
            run getValorPercentualComissao            in representante(output tt{&Representante}.tta_val_perc_comis_repres).
            run getValorPercentualComissaoAbatimento  in representante(output tt{&Representante}.tta_val_perc_comis_abat).
            run getValorPercentualComissaoAcertoValor in representante(output tt{&Representante}.tta_val_perc_comis_acerto_val).
            run getValorPercentualComissaoDesconto    in representante(output tt{&Representante}.tta_val_perc_comis_desc).
            run getValorPercentualComissaoJuros       in representante(output tt{&Representante}.tta_val_perc_comis_juros).
            run getValorPercentualComissaoMulta       in representante(output tt{&Representante}.tta_val_perc_comis_multa).
            run getValorPercentualComissaoEmissao     in representante(output tt{&Representante}.tta_val_perc_comis_repres_emis).
            run isComissaoProporcional                in representante(output tt{&Representante}.tta_log_comis_repres_proporc).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setAssumeDataEmissao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setAssumeDataEmissao Procedure 
PROCEDURE setAssumeDataEmissao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter assumeDataEmissao_ as logical    no-undo.

    do {&throws}:
        assign
            assumeDataEmissao = assumeDataEmissao_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setAtualizaReferencia) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setAtualizaReferencia Procedure 
PROCEDURE setAtualizaReferencia :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter atualizaReferencia_ as logical    no-undo.

    do {&throws}:
        assign
            atualizaReferencia = atualizaReferencia_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDataTransacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDataTransacao Procedure 
PROCEDURE setDataTransacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_dat_transacao_ as date no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_dat_transacao = tta_dat_transacao_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEmpresa) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEmpresa Procedure 
PROCEDURE setEmpresa :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_empresa_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_cod_empresa = tta_cod_empresa_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEmpresaExterna) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEmpresaExterna Procedure 
PROCEDURE setEmpresaExterna :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter ttv_cod_empresa_ext_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.ttv_cod_empresa_ext = ttv_cod_empresa_ext_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEspecieDocumento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEspecieDocumento Procedure 
PROCEDURE setEspecieDocumento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_cod_espec_docto = tta_cod_espec_docto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEstabelecimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEstabelecimento Procedure 
PROCEDURE setEstabelecimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_estab_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_cod_estab = tta_cod_estab_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEstabelecimentoExterno) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEstabelecimentoExterno Procedure 
PROCEDURE setEstabelecimentoExterno :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_estab_ext_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_cod_estab_ext = tta_cod_estab_ext_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFinalidadeEconomicaExterna) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFinalidadeEconomicaExterna Procedure 
PROCEDURE setFinalidadeEconomicaExterna :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_finalid_econ_ext_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_cod_finalid_econ_ext = tta_cod_finalid_econ_ext_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setIndicadorEconomico) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setIndicadorEconomico Procedure 
PROCEDURE setIndicadorEconomico :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_indic_econ_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_cod_indic_econ = tta_cod_indic_econ_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLiquidacaoAutomatica) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLiquidacaoAutomatica Procedure 
PROCEDURE setLiquidacaoAutomatica :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_log_liquidac_autom_ as logical no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_log_liquidac_autom = tta_log_liquidac_autom_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLoteImplantacaoOk) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLoteImplantacaoOk Procedure 
PROCEDURE setLoteImplantacaoOk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter ttv_log_lote_impl_ok_ as logical no-undo.

    do {&throws}:
        assign
            tt{&Lote}.ttv_log_lote_impl_ok = ttv_log_lote_impl_ok_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setMatrizTraducaoExterna) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setMatrizTraducaoExterna Procedure 
PROCEDURE setMatrizTraducaoExterna :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter matrizTraducaoExterna_ as character  no-undo.
    
    do {&throws}:
        assign
            matrizTraducaoExterna = matrizTraducaoExterna_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setOrigemTitulo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setOrigemTitulo Procedure 
PROCEDURE setOrigemTitulo :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_ind_orig_tit_acr_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_ind_orig_tit_acr = tta_ind_orig_tit_acr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setReferencia) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setReferencia Procedure 
PROCEDURE setReferencia :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_cod_refer_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_cod_refer = tta_cod_refer_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTipoCobranca) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTipoCobranca Procedure 
PROCEDURE setTipoCobranca :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_ind_tip_cobr_acr_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_ind_tip_cobr_acr = tta_ind_tip_cobr_acr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTipoEspecieDocumento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTipoEspecieDocumento Procedure 
PROCEDURE setTipoEspecieDocumento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_ind_tip_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_ind_tip_espec_docto = tta_ind_tip_espec_docto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setValorImplantacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setValorImplantacao Procedure 
PROCEDURE setValorImplantacao :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_val_tot_lote_impl_tit_acr_ as decimal no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_val_tot_lote_impl_tit_acr = tta_val_tot_lote_impl_tit_acr_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setValorInformado) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setValorInformado Procedure 
PROCEDURE setValorInformado :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter tta_val_tot_lote_infor_tit_acr_ as decimal no-undo.

    do {&throws}:
        assign
            tt{&Lote}.tta_val_tot_lote_infor_tit_acr = tta_val_tot_lote_infor_tit_acr_.
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
                run createError(17006, substitute('validate.validationType inv lido (&1)',
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

&IF DEFINED(EXCLUDE-validateInsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateInsert Procedure 
PROCEDURE validateInsert PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    define variable estabelecimento as character no-undo.
    define variable referencia as character no-undo.

    do {&throws}:
        run getEstabelecimento(output estabelecimento).
        run getReferencia(output referencia).

        find first lote_impl_tit_acr
            where lote_impl_tit_acr.cod_estab = estabelecimento
              and lote_impl_tit_acr.cod_refer = referencia
            no-lock no-error.

        if avail lote_impl_tit_acr then do:
            run insertError(524, 'Lote ja existe',
                substitute('Estab "&1", ref "&2"', estabelecimento, referencia)).

            return error.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyErrors Procedure 
PROCEDURE verifyErrors PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable hasError as logical   no-undo.
    
    do {&throws}:
        for each tt{&Erro}
            no-lock:
            run insertError(tt{&Erro}.ttv_num_mensagem,
                'Erro na integra‡Æo', tt{&Erro}.ttv_des_msg_ajuda).
        end.

        run hasError(output hasError).
        if hasError then
            return error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyInstanceApi) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyInstanceApi Procedure 
PROCEDURE verifyInstanceApi PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if not valid-handle(apiImplantacao) then
            run createInstance in ghInstanceManager(this-procedure,
                'prgfin/acr/acr900zi.py', output apiImplantacao).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyInstanceCheques) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyInstanceCheques Procedure 
PROCEDURE verifyInstanceCheques PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if not valid-handle(cheques) then
            run createInstance in ghInstancemanager(this-procedure,
                'system/TempTableCollection.p', output cheques).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyInstanceItens) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyInstanceItens Procedure 
PROCEDURE verifyInstanceItens PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if not valid-handle(itens) then
            run createInstance in ghInstancemanager(this-procedure,
                'system/TempTableCollection.p', output itens).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyInstanceRelacionamentos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyInstanceRelacionamentos Procedure 
PROCEDURE verifyInstanceRelacionamentos PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if not valid-handle(relacionamentos) then
            run createInstance in ghInstancemanager(this-procedure,
                'system/TempTableCollection.p', output relacionamentos).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

