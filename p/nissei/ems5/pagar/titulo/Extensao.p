&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   TituloExtensao
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

&scoped-define tableName cst_tit_ap
&scoped-define databaseName ems2custom

define temp-table tt{&tableName} no-undo
    like {&tableName}
    field r-rowid as rowid.

define variable messageEms5 as handle    no-undo.

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
         HEIGHT             = 30.13
         WIDTH              = 40.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-afterNew) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterNew Procedure 
PROCEDURE afterNew :
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

&IF DEFINED(EXCLUDE-beforeInsert) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInsert Procedure 
PROCEDURE beforeInsert :
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

&IF DEFINED(EXCLUDE-canFind) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE canFind Procedure 
PROCEDURE canFind :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    define input parameter cod_estab_ as character no-undo.
    define input parameter cdn_fornecedor_ as integer no-undo.
    define input parameter cod_espec_docto_ as character no-undo.
    define input parameter cod_ser_docto_ as character no-undo.
    define input parameter cod_tit_ap_ as character no-undo.
    define input parameter cod_parcela_ as character no-undo.
    define output parameter found_ as logical    no-undo.

    do {&throws}:
        assign
            found_ = can-find({&tableName}
                              where {&tableName}.cod_estab = cod_estab_
                                and {&tableName}.cdn_fornecedor = cdn_fornecedor_
                                and {&tableName}.cod_espec_docto = cod_espec_docto_
                                and {&tableName}.cod_ser_docto = cod_ser_docto_
                                and {&tableName}.cod_tit_ap = cod_tit_ap_
                                and {&tableName}.cod_parcela = cod_parcela_).
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
        empty temp-table tt{&tableName}.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearTable) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearTable Procedure 
PROCEDURE clearTable :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        for each cst_tit_ap
            exclusive-lock:
            delete cst_tit_ap.
        end.
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

        delete {&tableName}.
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
    define input parameter cod_estab_ as character no-undo.
    define input parameter cdn_fornecedor_ as integer no-undo.
    define input parameter cod_espec_docto_ as character no-undo.
    define input parameter cod_ser_docto_ as character no-undo.
    define input parameter cod_tit_ap_ as character no-undo.
    define input parameter cod_parcela_ as character no-undo.

    do {&throws}:
        find first {&tableName}
             where {&tableName}.cod_estab = cod_estab_
               and {&tableName}.cdn_fornecedor = cdn_fornecedor_
               and {&tableName}.cod_espec_docto = cod_espec_docto_
               and {&tableName}.cod_ser_docto = cod_ser_docto_
               and {&tableName}.cod_tit_ap = cod_tit_ap_
               and {&tableName}.cod_parcela = cod_parcela_
             no-lock no-error.

        if not avail {&tableName} then do:
            run createError in messageEms5(524, 'Titulo extens∆o n∆o encontrado'
                    + '~~':u 
                    + substitute('Estab "&1", fornec &2, espÇcie "&3", sÇrie "&4", '
                    + 't°tulo "&5", parcela "6"', cod_estab_, cdn_fornecedor_,
                    cod_espec_docto_, cod_ser_docto_, cod_tit_ap_, cod_parcela_)).
            return error.
        end.

        run findByRowId(rowid({&tableName})).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-findByRowId) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE findByRowId Procedure 
PROCEDURE findByRowId :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input parameter rTable_ as rowid      no-undo.

    do {&throws}:
        find {&tableName}
             where rowid({&tableName}) = rTable_
             no-lock no-error.

        if not avail {&tableName} then do:
            {utp/ut-table.i {&databaseName} {&tableName} 1}
            run createError(17006,
                            substitute('Registro inexistente em &1~~' +
                                       'N∆o encontrado registro na tabela &1 com id &2',
                                       return-value,
                                       string(rtable_))).
            run createError in messageEms5(524, 'Registro inexistente em t°tulo extens∆o a pagar'
                    + '~~':u 
                    + substitute('Registro id &1', rTable_)).
            return error.
        end.

        run load.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getCodigoDeBarras) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getCodigoDeBarras Procedure 
PROCEDURE getCodigoDeBarras :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cb4_tit_ap_bco_cobdor_ as character no-undo.

    do {&throws}:
        assign
            cb4_tit_ap_bco_cobdor_ = tt{&tableName}.cb4_tit_ap_bco_cobdor.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDataLiquidacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDataLiquidacao Procedure 
PROCEDURE getDataLiquidacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter dat_liquidac_tit_ap_ as date       no-undo.

    do {&throws}:
        assign
            dat_liquidac_tit_ap_ = tt{&tableName}.dat_liquidac_tit_ap.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDataVencimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDataVencimento Procedure 
PROCEDURE getDataVencimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter dat_vencto_tit_ap_ as date no-undo.

    do {&throws}:
        assign
            dat_vencto_tit_ap_ = tt{&tableName}.dat_vencto_tit_ap.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEspecie) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getEspecie Procedure 
PROCEDURE getEspecie :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            cod_espec_docto_ = tt{&tableName}.cod_espec_docto.
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
    define output parameter cod_estab_ as character no-undo.

    do {&throws}:
        assign
            cod_estab_ = tt{&tableName}.cod_estab.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFornecedor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFornecedor Procedure 
PROCEDURE getFornecedor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cdn_fornecedor_ as integer no-undo.

    do {&throws}:
        assign
            cdn_fornecedor_ = tt{&tableName}.cdn_fornecedor.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getParcela) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getParcela Procedure 
PROCEDURE getParcela :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_parcela_ as character no-undo.

    do {&throws}:
        assign
            cod_parcela_ = tt{&tableName}.cod_parcela.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRowId) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRowId Procedure 
PROCEDURE getRowId :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter rTable_ as rowid      no-undo.

    do {&throws}:
        assign
            rTable_ = tt{&tableName}.r-rowid
            no-error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getSerie) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getSerie Procedure 
PROCEDURE getSerie :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_ser_docto_ as character no-undo.

    do {&throws}:
        assign
            cod_ser_docto_ = tt{&tableName}.cod_ser_docto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTipoEspecie) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTipoEspecie Procedure 
PROCEDURE getTipoEspecie :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter ind_tip_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            ind_tip_espec_docto_ = tt{&tableName}.ind_tip_espec_docto.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTitulo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTitulo Procedure 
PROCEDURE getTitulo :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter cod_tit_ap_ as character no-undo.

    do {&throws}:
        assign
            cod_tit_ap_ = tt{&tableName}.cod_tit_ap.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getValorSaldo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getValorSaldo Procedure 
PROCEDURE getValorSaldo :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define output parameter val_sdo_tit_ap_ as decimal no-undo.

    do {&throws}:
        assign
            val_sdo_tit_ap_ = tt{&tableName}.val_sdo_tit_ap.
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

        create {&tableName}.
        buffer-copy tt{&tableName} except r-rowid
            to {&tableName}.

        run unlock.

        assign
            tt{&tableName}.r-rowid = rowid({&tableName}).
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

        buffer-copy {&tableName} to tt{&tableName}
            assign tt{&tableName}.r-rowid = rowid({&tableName}).
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

        find first {&tableName}
            where rowid({&tableName}) = tt{&tableName}.r-rowid
            exclusive-lock no-error no-wait.

        if not avail {&tableName} then do:
            if locked {&tableName} then
                run createError in messageEms5(524, 'Registro travado por outro usu†rio ({&tableName})').
            else do:
                run createError in messageEms5(524, 'Titulo extens∆o n∆o encontrado').
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

        create tt{&tableName}.

        run afterNew in child().
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCodigoDeBarras) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCodigoDeBarras Procedure 
PROCEDURE setCodigoDeBarras :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cb4_tit_ap_bco_cobdor_ as character no-undo.

    do {&throws}:
        assign
            tt{&tableName}.cb4_tit_ap_bco_cobdor = cb4_tit_ap_bco_cobdor_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDataLiquidacao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDataLiquidacao Procedure 
PROCEDURE setDataLiquidacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter dat_liquidac_tit_ap_ as date       no-undo.

    do {&throws}:
        assign
            tt{&tableName}.dat_liquidac_tit_ap = dat_liquidac_tit_ap_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDataVencimento) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDataVencimento Procedure 
PROCEDURE setDataVencimento :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter dat_vencto_tit_ap_ as date no-undo.

    do {&throws}:
        assign
            tt{&tableName}.dat_vencto_tit_ap = dat_vencto_tit_ap_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setEspecie) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEspecie Procedure 
PROCEDURE setEspecie :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            tt{&tableName}.cod_espec_docto = cod_espec_docto_.
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
    define input  parameter cod_estab_ as character no-undo.

    do {&throws}:
        assign
            tt{&tableName}.cod_estab = cod_estab_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFornecedor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFornecedor Procedure 
PROCEDURE setFornecedor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cdn_fornecedor_ as integer no-undo.

    do {&throws}:
        assign
            tt{&tableName}.cdn_fornecedor = cdn_fornecedor_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setParcela) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setParcela Procedure 
PROCEDURE setParcela :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_parcela_ as character no-undo.

    do {&throws}:
        assign
            tt{&tableName}.cod_parcela = cod_parcela_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setSerie) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setSerie Procedure 
PROCEDURE setSerie :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_ser_docto_ as character no-undo.

    do {&throws}:
        assign
            tt{&tableName}.cod_ser_docto = cod_ser_docto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTipoEspecie) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTipoEspecie Procedure 
PROCEDURE setTipoEspecie :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter ind_tip_espec_docto_ as character no-undo.

    do {&throws}:
        assign
            tt{&tableName}.ind_tip_espec_docto = ind_tip_espec_docto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTitulo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTitulo Procedure 
PROCEDURE setTitulo :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter cod_tit_ap_ as character no-undo.

    do {&throws}:
        assign
            tt{&tableName}.cod_tit_ap = cod_tit_ap_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setValorSaldo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setValorSaldo Procedure 
PROCEDURE setValorSaldo :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input  parameter val_sdo_tit_ap_ as decimal no-undo.

    do {&throws}:
        assign
            tt{&tableName}.val_sdo_tit_ap = val_sdo_tit_ap_.
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

    do {&throws}:
        run createInstance in ghInstanceManager(this-procedure,
            'dtsl/ems5/common/Message.p':u, output messageEms5).
    end.

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
        find current {&tableName}
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
        run validate('update').
        run lock.

        buffer-copy tt{&tableName} except r-rowid
            to {&tableName}.

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
    define variable found as logical   no-undo.

    do {&throws}:
        /* Faca aqui as validacoes para inclusao, mas nao de return-error,
           pois essa instrucao eh dada pelo metodo validate. Veja um exemplo:

        if can-find(first familia where familia.fm-codigo = ttFamilia.fm-codigo) then
            run createError(17006, substitute('Fam°lia de Materiais &1 j† cadastrada',
                ttFamilia.fm-codigo)).
        */

        run canFind(tt{&tableName}.cod_estab,
                    tt{&tableName}.cdn_fornecedor,
                    tt{&tableName}.cod_espec_docto,
                    tt{&tableName}.cod_ser_docto,
                    tt{&tableName}.cod_tit_ap,
                    tt{&tableName}.cod_parcela,
                    output found).

        if found then do:
            run createError in messageEms5(524, 'Titulo extens∆o ja existe'
                    + '~~':u 
                    + substitute('Estab "&1", fornec &2, espÇcie "&3", sÇrie "&4", '
                    + 't°tulo "&5", parcela "6"', cod_estab, cdn_fornecedor,
                    cod_espec_docto, cod_ser_docto, cod_tit_ap, cod_parcela)).
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
        /* Faca aqui as validacoes para inclusao e atualizacao, mas nao de return-error,
           pois essa instrucao eh dada pelo metodo validate. Veja um exemplo:

        if can-find(first familia where familia.fm-codigo = ttFamilia.fm-codigo) then
            run createError(17006, substitute('Fam°lia de Materiais &1 j† cadastrada',
                ttFamilia.fm-codigo)).
        */
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

