/*******************************************************************************
** Programa: 
** Autor...: 
** Data....: 
** OBS.....: 
*******************************************************************************/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
USING OpenEdge.Core.*. 
USING OpenEdge.Net.HTTP.*. 
USING OpenEdge.Net.HTTP.Lib.ClientLibraryBuilder. 

{utp/ut-api.i}

{utp/ut-api-action.i pi-create-invoice POST /criaBordero/~* }
{utp/ut-api-action.i pi-search-invoices POST /carregaTitBordero/~* }
{utp/ut-api-action.i pi-relact-invoices POST /vinculaTitBordero/~* }
{utp/ut-api-action.i pi-confirm POST /confirmaBordero/~* }
{utp/ut-api-action.i pi-delete POST /eliminaBordero/~* }
{utp/ut-api-action.i pi-get POST /consultaBordero/~* }
{utp/ut-api-action.i pi-get-open-bord POST /buscaBorderoAberto/~* }
{utp/ut-api-action.i pi-get-item POST /consultaItemBordero/~* }
{utp/ut-api-action.i pi-send POST /envioBanco/~* }
{utp/ut-api-action.i pi-transfer POST /transfereBordero/~* }
{utp/ut-api-action.i pi-transmit POST /transmitirBanco/~* }
{utp/ut-api-notfound.i}


DEFINE VARIABLE oJsonArrayAux AS JsonArray         NO-UNDO.
DEFINE VARIABLE oJsonAux      AS JsonObject        NO-UNDO.
DEFINE VARIABLE objParse      AS ObjectModelParser NO-UNDO.
    
DEFINE VARIABLE apiHandler AS HANDLE      NO-UNDO.

{esp/roboteasy/robotapifn.i}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
// ATENÄ«O
// ATUALIZAR A VERS«O NO INCLUDE robotapi004.i
// - roboteasy\robotapi004.p
// - roboteasy\api\v1\restapiborderoap.p
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------

{esp/roboteasy/robotapi004.i "restapiborderoap"}

DEFINE DATASET dsBordero
    FOR tt_bordero.
DEF DATASET dsRetorno 
    FOR tt-retorno.
DEF DATASET dsTitulosBord 
    FOR tt_titulos_bord.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-create-invoice:
    
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-cria-bordero IN apiHandler (INPUT  TABLE tt_bordero, INPUT-OUTPUT TABLE tt-retorno).
    RUN pi-json-saida (INPUT ?, INPUT ?, OUTPUT jsonOutput).
    RETURN "OK":U.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-confirm:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-confirma-bordero IN apiHandler (INPUT TABLE tt_bordero, OUTPUT TABLE tt-retorno).
    RUN pi-json-saida (INPUT ?, INPUT ?, OUTPUT jsonOutput).
    RETURN "OK":U.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-get-open-bord:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-busca-bordero-aberto IN apiHandler (INPUT-OUTPUT TABLE tt_param, OUTPUT TABLE tt_bordero, INPUT-OUTPUT TABLE tt-retorno).
    RUN pi-json-saida (INPUT TEMP-TABLE tt_param:HANDLE, INPUT TEMP-TABLE tt_bordero:HANDLE, OUTPUT jsonOutput).
    RETURN "OK":U.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-get:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-consulta-bordero IN apiHandler (INPUT-OUTPUT TABLE tt_bordero, OUTPUT TABLE tt-retorno).
    RUN pi-json-saida (INPUT TEMP-TABLE tt_bordero:HANDLE, INPUT ?, OUTPUT jsonOutput).
    RETURN "OK":U.
    
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-transfer:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-transfere-bordero IN apiHandler (INPUT TABLE tt_bordero, INPUT-OUTPUT TABLE tt-retorno).
    RUN pi-json-saida (INPUT ?, INPUT ?, OUTPUT jsonOutput).
    RETURN "OK":U.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-get-item:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-consulta-item-bordero IN apiHandler (INPUT TABLE tt_bordero, OUTPUT TABLE tt_titulos_bord, INPUT-OUTPUT TABLE tt-retorno).
    RUN pi-json-saida (INPUT TEMP-TABLE tt_titulos_bord:HANDLE, INPUT ?, OUTPUT jsonOutput).
    RETURN "OK":U.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-delete:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-elimina-bordero IN apiHandler (INPUT TABLE tt_bordero, INPUT-OUTPUT TABLE tt-retorno).
    RUN pi-json-saida (INPUT ?, INPUT ?, OUTPUT jsonOutput).
    RETURN "OK":U.
    
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-send:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-envio-banco IN apiHandler (INPUT TABLE tt_bordero, INPUT-OUTPUT TABLE tt-retorno).

/*     FOR FIRST tt-retorno                                                                */
/*         WHERE tt-retorno.cod-status = 200: // executado com sucesso                     */
/*     END.                                                                                */
/*     IF  NOT AVAIL tt-retorno THEN DO:                                                   */
/*         FOR FIRST tt-retorno                                                            */
/*             WHERE tt-retorno.cod-status = 201: // executado com erro                    */
/*         END.                                                                            */
/*         IF  NOT AVAIL tt-retorno THEN DO:                                               */
/*             FOR FIRST tt-retorno                                                        */
/*                 WHERE tt-retorno.cod-status > 0: // tem alguma mensagem de erro         */
/*             END.                                                                        */
/*             IF  NOT AVAIL tt-retorno THEN DO:                                           */
/*                 CREATE tt-retorno.                                                      */
/*                 ASSIGN tt-retorno.versao-api = c-versao-api                             */
/*                        tt-retorno.cod-status = 201                                      */
/*                        tt-retorno.desc-retorno = "Ocorreu um erro no envio do borderì". */
/*             END. // >0                                                                  */
/*         END. // 201                                                                     */
/*     END. // 200                                                                         */

    RUN pi-json-saida (INPUT ?, INPUT ?, OUTPUT jsonOutput).
    RETURN "OK":U.

END PROCEDURE.

PROCEDURE pi-transmit:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser    AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload         AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oJsonPayLoad      AS JsonObject           NO-UNDO.
    DEFINE VARIABLE oJsonArrayAux     AS JsonArray            NO-UNDO.
    DEFINE VARIABLE jsonObjectOutput  AS JsonObject           NO-UNDO.

    DEFINE VARIABLE apiHandler AS HANDLE      NO-UNDO.
    DEFINE VARIABLE iRet       AS INTEGER     NO-UNDO.
    DEFINE VARIABLE lPassou AS LOGICAL     NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().
   
    oJsonPayLoad = fnTextToJsonObject(lcPayload).
 
    RUN pi-json-entrada (INPUT oJsonPayLoad).
   
    IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN esp/roboteasy/robotapi004.p PERSISTENT SET apiHandler.
    END.

    RUN pi-transmitir-banco IN apiHandler (INPUT  TABLE tt_bordero,
                                           OUTPUT TABLE tt-retorno).

    DELETE PROCEDURE apiHandler NO-ERROR.

    jsonOutput = NEW JSONObject().

    oJsonArrayAux = NEW JsonArray().
    oJsonArrayAux:READ(TEMP-TABLE tt-retorno :HANDLE).
    
         
    ASSIGN iRet = 500.
    jsonObjectOutput = NEW JsonObject().

    IF  TEMP-TABLE tt-retorno:HAS-RECORDS THEN DO:
        ASSIGN iRet = 200.
        jsonObjectOutput:READ(DATASET dsRetorno:HANDLE).
        ASSIGN lPassou = YES.
    END.
    
    IF  lPassou = NO THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api   = c-versao-api 
               tt-retorno.cod-status   = 9999
               tt-retorno.desc-retorno = "Erro na execuá∆o da API".
        jsonObjectOutput:READ(TEMP-TABLE tt-retorno:HANDLE).
    END.
    
    jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).

    RETURN "OK":U.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-search-invoices:
    
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-busca-tit IN apiHandler (INPUT-OUTPUT  TABLE tt_param, OUTPUT TABLE tt_titulos_bord, INPUT-OUTPUT TABLE tt-retorno).
    RUN pi-json-saida (INPUT TEMP-TABLE tt_param:handle, INPUT TEMP-TABLE tt_titulos_bord:handle, OUTPUT jsonOutput).
    RETURN "OK":U.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-relact-invoices:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    RUN pi-json-entrada (INPUT jsonInput).
    RUN pi-vincula-bord IN apiHandler (INPUT-OUTPUT TABLE tt_param, INPUT TABLE tt_titulos_bord, INPUT-OUTPUT TABLE tt-retorno).
    RUN pi-json-saida (INPUT ?, INPUT TEMP-TABLE tt_param:handle, OUTPUT jsonOutput).
    RETURN "OK":U.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-json-entrada:
    
    DEFINE INPUT PARAMETER p-oJsonInput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser    AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload         AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oJsonPayLoad      AS JsonObject           NO-UNDO.

    //DEFINE VARIABLE oJsonAux       AS JsonObject NO-UNDO.
    //DEFINE VARIABLE oJsonArrayAux  AS JsonArray  NO-UNDO.
    DEFINE VARIABLE i-length       AS INTEGER    NO-UNDO.
    DEFINE VARIABLE i-aux          AS INTEGER    NO-UNDO.

    //----------------------------------------------------------------------------------------------------
    
    IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN esp/roboteasy/robotapi004.p PERSISTENT SET apiHandler.
    END.

    //----------------------------------------------------------------------------------------------------

    oRequestParser = NEW JsonAPIRequestParser(p-oJsonInput).
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().
    oJsonPayLoad = fnTextToJsonObject(lcPayload).

    //----------------------------------------------------------------------------------------------------

    IF oJsonPayLoad:Has("bordero") THEN DO:

        oJsonArrayAux = oJsonPayLoad:GetJsonArray("bordero").
        ASSIGN i-length = oJsonArrayAux:LENGTH.

        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).
            CREATE tt_bordero.                    
            ASSIGN tt_bordero.cod_estab                 = IF oJsonAux:Has("codEstab")         THEN oJsonAux:GetCharacter("codEstab")      ELSE "" NO-ERROR. 
            ASSIGN tt_bordero.cod_empresa               = IF oJsonAux:Has("codEmpresa")       THEN oJsonAux:GetCharacter("codEmpresa")    ELSE "" NO-ERROR.
            ASSIGN tt_bordero.cod_portador              = IF oJsonAux:Has("codPortador")      THEN oJsonAux:GetCharacter("codPortador")   ELSE "" NO-ERROR.
            ASSIGN tt_bordero.num_bord_ap               = IF oJsonAux:Has("numBordAp")        THEN oJsonAux:GetInteger("numBordAp")       ELSE ?  NO-ERROR.
            ASSIGN tt_bordero.dat_transacao             = IF oJsonAux:Has("datTransacao")     THEN oJsonAux:GetDate("datTransacao")       ELSE ?  NO-ERROR.
            ASSIGN tt_bordero.ind_tip_bord_ap           = IF oJsonAux:Has("indTipBordAp")     THEN oJsonAux:GetCharacter("indTipBordAp")  ELSE "" NO-ERROR.
            ASSIGN tt_bordero.val_tot_lote_pagto_efetd  = IF oJsonAux:Has("valTotLotePagto")  THEN oJsonAux:GetDecimal("valTotLotePagto") ELSE ?  NO-ERROR.                  
            ASSIGN tt_bordero.cod_indic_econ            = IF oJsonAux:Has("codIndicEcon")     THEN oJsonAux:GetCharacter("codIndicEcon")  ELSE "" NO-ERROR.
            ASSIGN tt_bordero.cod_msg_inic              = IF oJsonAux:Has("codMsgInic"  )     THEN oJsonAux:GetCharacter("codMsgInic"  )  ELSE ?  NO-ERROR.
            ASSIGN tt_bordero.cod_msg_fim               = IF oJsonAux:Has("codMsgFim"   )     THEN oJsonAux:GetCharacter("codMsgFim"   )  ELSE ?  NO-ERROR.
            ASSIGN tt_bordero.log_bxa_estab_tit_ap      = IF oJsonAux:Has("logBxaEstab")      THEN oJsonAux:GetLogical("logBxaEstab")     ELSE NO NO-ERROR.
            ASSIGN tt_bordero.log_vincul_autom          = IF oJsonAux:Has("logVinculAutom")   THEN oJsonAux:GetLogical("logVinculAutom")  ELSE NO NO-ERROR.
            ASSIGN tt_bordero.log_bord_gps              = IF oJsonAux:Has("logBordGps")       THEN oJsonAux:GetLogical("logBordGps")      ELSE NO NO-ERROR.
            ASSIGN tt_bordero.log_bord_darf             = IF oJsonAux:Has("logBordDarf")      THEN oJsonAux:GetLogical("logBordDarf")     ELSE NO NO-ERROR.
            ASSIGN tt_bordero.log_bord_ap_escrit        = IF oJsonAux:Has("logBordEscrit")    THEN oJsonAux:GetLogical("logBordEscrit")   ELSE NO NO-ERROR.
            ASSIGN tt_bordero.ind_tip_bord_ap           = IF oJsonAux:Has("indTipBordAp")     THEN oJsonAux:GetCharacter("indTipBordAp")  ELSE "" NO-ERROR.
        END.
    END.

    //----------------------------------------------------------------------------------------------------
    
    IF oJsonPayLoad:Has("param") THEN DO:

        oJsonArrayAux = oJsonPayLoad:GetJsonArray("param").
        ASSIGN i-length = oJsonArrayAux:LENGTH.

        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).
            CREATE tt_param.  
            ASSIGN tt_param.cod_estab                     = IF oJsonAux:has("codEstab") 			 THEN oJsonAux:GetCharacter("codEstab")                 ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_empresa                   = IF oJsonAux:has("codEmpresa") 	        THEN oJsonAux:GetCharacter("codEmpresa")               ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_portador                  = IF oJsonAux:has("codPortador")              THEN oJsonAux:GetCharacter("codPortador")              ELSE ? NO-ERROR.
            ASSIGN tt_param.num_bord_ap                   = IF oJsonAux:has("numBordAp")                THEN oJsonAux:GetInteger("numBordAp")                  ELSE ? NO-ERROR.
            ASSIGN tt_param.ind_tip_docto_prepar_pagto    = IF oJsonAux:has("indTipDoctoPreparPagto")   THEN oJsonAux:GetCharacter("indTipDoctoPreparPagto")   ELSE ? NO-ERROR.
            ASSIGN tt_param.ind_liber_pagto_dat           = IF oJsonAux:has("indLiberPagtoDat") 	 THEN oJsonAux:GetCharacter("indLiberPagtoDat")         ELSE ? NO-ERROR.
            ASSIGN tt_param.dat_inicio                    = IF oJsonAux:has("datInicio") 			 THEN oJsonAux:GetDate("datInicio")                     ELSE ? NO-ERROR.
            ASSIGN tt_param.dat_fim                       = IF oJsonAux:has("datFim") 			 THEN oJsonAux:GetDate("datFim")                        ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_estab_ini                 = IF oJsonAux:has("codEstabIni") 		 THEN oJsonAux:GetCharacter("codEstabIni")              ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_estab_fim                 = IF oJsonAux:has("codEstabFim") 		 THEN oJsonAux:GetCharacter("codEstabFim")              ELSE ? NO-ERROR.
            ASSIGN tt_param.cdn_fornecedor_ini            = IF oJsonAux:has("cdnFornecedorIni") 	 THEN oJsonAux:GetInteger("cdnFornecedorIni")           ELSE ? NO-ERROR.
            ASSIGN tt_param.cdn_fornecedor_fim            = IF oJsonAux:has("cdnFornecedorFim") 	 THEN oJsonAux:GetInteger("cdnFornecedorFim")           ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_espec_docto_ini           = IF oJsonAux:has("codEspecDoctoIni") 	 THEN oJsonAux:GetCharacter("codEspecDoctoIni")         ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_espec_docto_fim           = IF oJsonAux:has("codEspecDoctoFim") 	 THEN oJsonAux:GetCharacter("codEspecDoctoFim")         ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_forma_pagto_ini           = IF oJsonAux:has("codFormaPagtoIni")         THEN oJsonAux:GetCharacter("codFormaPagtoIni")         ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_forma_pagto_fim           = IF oJsonAux:has("codFormaPagtoFim") 	 THEN oJsonAux:GetCharacter("codFormaPagtoFim")         ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_indic_econ_ini            = IF oJsonAux:has("codIndicEconIni") 		 THEN oJsonAux:GetCharacter("codIndicEconIni")          ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_indic_econ_fim            = IF oJsonAux:has("codIndicEconFim") 		 THEN oJsonAux:GetCharacter("codIndicEconFim")          ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_portador_ini              = IF oJsonAux:has("codPortadorIni") 		 THEN oJsonAux:GetCharacter("codPortadorIni")           ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_portador_fim              = IF oJsonAux:has("codPortadorFim") 		 THEN oJsonAux:GetCharacter("codPortadorFim")           ELSE ? NO-ERROR.
            ASSIGN tt_param.ind_pagto_liber               = IF oJsonAux:has("indPagtoLiber") 		 THEN oJsonAux:GetCharacter("indPagtoLiber")            ELSE ? NO-ERROR.
            ASSIGN tt_param.val_cotac_indic_econ          = IF oJsonAux:has("valCotacIndicEcon") 	 THEN oJsonAux:GetDecimal("valCotacIndicEcon")          ELSE ? NO-ERROR.
            ASSIGN tt_param.dat_cotac_indic_econ          = IF oJsonAux:has("datCotacIndicEcon") 	 THEN oJsonAux:GetDate("datCotacIndicEcon")             ELSE ? NO-ERROR.
            ASSIGN tt_param.ind_favorec_cheq              = IF oJsonAux:has("indFavorecCheq") 		 THEN oJsonAux:GetCharacter("indFavorecCheq")           ELSE ? NO-ERROR.
            ASSIGN tt_param.log_gerac_autom               = IF oJsonAux:has("logGeracAutom") 		 THEN oJsonAux:GetLogical("logGeracAutom")              ELSE ? NO-ERROR.
            ASSIGN tt_param.log_consid_fatur_cta          = IF oJsonAux:has("logConsidFaturCta") 	 THEN oJsonAux:GetLogical("logConsidFaturCta")          ELSE ? NO-ERROR.
            ASSIGN tt_param.cod_histor_padr               = IF oJsonAux:has("codHistorPadr") 	        THEN oJsonAux:GetCharacter("codHistorPadr")            ELSE ? NO-ERROR. 
            ASSIGN tt_param.log_atualiza_dat_pagto        = IF oJsonAux:has("logAtualizaDatPagto") 	 THEN oJsonAux:GetLogical("logAtualizaDatPagto")        ELSE ? NO-ERROR. 
            ASSIGN tt_param.ind_forma_pagto               = IF oJsonAux:has("indFormaPagto") 	        THEN oJsonAux:GetCharacter("indFormaPagto")            ELSE ? NO-ERROR. 
            ASSIGN tt_param.cod_forma_pagto               = IF oJsonAux:has("codFormaPagto") 	        THEN oJsonAux:GetCharacter("codFormaPagto")            ELSE ? NO-ERROR.
            ASSIGN tt_param.log_assume_chave_pix_pref     = IF oJsonAux:has("logAssumeChavePixPref") 	 THEN oJsonAux:GetLogical("logAssumeChavePixPref")      ELSE ? NO-ERROR.
            ASSIGN tt_param.log_pix_sem_chave             = IF oJsonAux:has("logPixSemChave") 	        THEN oJsonAux:GetLogical("logPixSemChave")             ELSE ? NO-ERROR.
            ASSIGN tt_param.zerar-total-informado         = IF oJsonAux:has("zerarTotalInformado")      THEN oJsonAux:GetLogical("zerarTotalInformado")        ELSE ? NO-ERROR.
            ASSIGN tt_param.zerar-total-vinculado         = IF oJsonAux:has("zerarTotalVinculado")      THEN oJsonAux:GetLogical("zerarTotalVinculado")        ELSE ? NO-ERROR.
            ASSIGN tt_param.alterar-status-impresso       = IF oJsonAux:has("alterarStatusImpresso")    THEN oJsonAux:GetLogical("alterarStatusImpresso")      ELSE ? NO-ERROR.
            
        END.
    END.

    //----------------------------------------------------------------------------------------------------
    
    IF oJsonPayLoad:Has("titulosBordero") THEN DO:

        oJsonArrayAux = oJsonPayLoad:GetJsonArray("titulosBordero").
        ASSIGN i-length = oJsonArrayAux:LENGTH.

        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).
            CREATE tt_titulos_bord.
            ASSIGN tt_titulos_bord.ind_sit_prepar_liber        = IF oJsonAux:has("indSitPreparLiber")      THEN oJsonAux:GetCharacter("indSitPreparLiber")          ELSE ? NO-ERROR.  
            ASSIGN tt_titulos_bord.cod_estab                   = IF oJsonAux:has("codEstab" )              THEN oJsonAux:GetCharacter("codEstab")                   ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cdn_fornecedor              = IF oJsonAux:has("cdnFornecedor")          THEN oJsonAux:GetInteger("cdnFornecedor")                ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.nom_abrev                   = IF oJsonAux:has("nomAbrev")               THEN oJsonAux:GetCharacter("nomAbrev")                   ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_espec_docto             = IF oJsonAux:has("codEspecDocto")          THEN oJsonAux:GetCharacter("codEspecDocto")              ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_ser_docto               = IF oJsonAux:has("codSerDocto")            THEN oJsonAux:GetCharacter("codSerDocto")                ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_tit_ap                  = IF oJsonAux:has("codTitAp")               THEN oJsonAux:GetCharacter("codTitAp")                   ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_parcela                 = IF oJsonAux:has("codParcela")             THEN oJsonAux:GetCharacter("codParcela")                 ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.dat_prev_pagto              = IF oJsonAux:has("datPrevPagto")           THEN oJsonAux:GetDate("datPrevPagto")                    ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.val_sdo_tit_ap              = IF oJsonAux:has("valSdoTitAp")            THEN oJsonAux:GetDecimal("valSdoTitAp")                  ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.dat_vencto_tit_ap           = IF oJsonAux:has("datVectoTitAp")          THEN oJsonAux:GetDate("datVectoTitAp")                   ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_indic_econ              = IF oJsonAux:has("codIndicEcon")           THEN oJsonAux:GetCharacter("codIndicEcon")               ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_refer_antecip_pef       = IF oJsonAux:has("codReferAntecipPef")     THEN oJsonAux:GetCharacter("codReferAntecipPef")         ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.val_pagto_moe               = IF oJsonAux:has("valPagtoMoe")            THEN oJsonAux:GetDecimal("valPagtoMoe")                  ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.dat_emis_docto              = IF oJsonAux:has("datEmisDocto")           THEN oJsonAux:GetDate("datEmisDocto")                    ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.dat_desconto                = IF oJsonAux:has("datDesconto")            THEN oJsonAux:GetDate("datDesconto")                     ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_forma_pagto             = IF oJsonAux:has("codFormaPagto")          THEN oJsonAux:GetCharacter("codFormaPagto")              ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_refer                   = IF oJsonAux:has("codRefer")               THEN oJsonAux:GetCharacter("codRefer")                   ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_banco                   = IF oJsonAux:has("codBanco")               THEN oJsonAux:GetCharacter("codBanco")                   ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_agenc_bcia_digito       = IF oJsonAux:has("codAgencBciaDigito")     THEN oJsonAux:GetCharacter("codAgencBciaDigito")         ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.cod_cta_corren_bco_digito   = IF oJsonAux:has("codCtaCorrenBcoDigito")  THEN oJsonAux:GetCharacter("codCtaCorrenBcoDigito")      ELSE ? NO-ERROR.
            ASSIGN tt_titulos_bord.num_seq_pagto_tit_ap        = IF oJsonAux:has("numSeqPagtoTitAp")       THEN oJsonAux:GetInteger("numSeqPagtoTitAp")             ELSE ? NO-ERROR.  
            ASSIGN tt_titulos_bord.val_cotac_indic_econ        = IF oJsonAux:has("valCotacIndicEcon")      THEN oJsonAux:GetDecimal("valCotacIndicEcon")            ELSE ? NO-ERROR. 
            ASSIGN tt_titulos_bord.log_possui_antecip_forn     = IF oJsonAux:has("logPossuiAntecipForn")   THEN oJsonAux:GetLogical("logPossuiAntecipForn")         ELSE ? NO-ERROR.
        END.
    END.

    //----------------------------------------------------------------------------------------------------

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-json-saida:

    DEF INPUT  PARAM p-htt-1      AS HANDLE     NO-UNDO.
    DEF INPUT  PARAM p-htt-2      AS HANDLE     NO-UNDO.
    DEF OUTPUT PARAM p-jsonOutput AS JsonObject NO-UNDO.
    
    //DEFINE VARIABLE oJsonArrayAux     AS JsonArray            NO-UNDO.
    //DEFINE VARIABLE jsonRetornoOutput AS JsonObject           NO-UNDO.
    //DEFINE VARIABLE jsonTitulosOutput AS JsonObject           NO-UNDO.
    DEFINE VARIABLE jsonObjectOutput  AS JsonObject           NO-UNDO.

    DEFINE VARIABLE iRet       AS INTEGER     NO-UNDO.
    DEFINE VARIABLE lPassou AS LOGICAL     NO-UNDO.

    //----------------------------------------------------------------------------------------------------

    FOR FIRST tt-retorno
        WHERE tt-retorno.cod-status = 200: // executado com sucesso
    END.

    IF  NOT AVAIL tt-retorno THEN DO:
        // n∆o executou com sucesso

        // verificar se tem alguma mensagem de erro diferente de -1, 200, 201
        FOR FIRST b-tt-retorno
            WHERE b-tt-retorno.cod-status > 0
            AND   b-tt-retorno.cod-status <> 200
            AND   b-tt-retorno.cod-status <> 201
            AND   b-tt-retorno.desc-retorno <> ""
            AND   b-tt-retorno.desc-retorno <> ?:
        END.

        FOR FIRST tt-retorno
            WHERE tt-retorno.cod-status = 201: // executado com erro e com mensagem
        END.

        IF  AVAIL tt-retorno THEN DO:
            // executou com erro

            // tem cod 201 mas n∆o tem mensagem de erro
            IF  (tt-retorno.desc-retorno = "" OR  tt-retorno.desc-retorno = ?)
            AND AVAIL b-tt-retorno THEN
                ASSIGN tt-retorno.desc-retorno = b-tt-retorno.desc-retorno.

        END.
        ELSE DO:
            CREATE tt-retorno.
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status = 201
                   tt-retorno.desc-retorno = IF   AVAIL b-tt-retorno
                                             THEN b-tt-retorno.desc-retorno
                                             ELSE "Ocorreu um erro na execuá∆o da rotina".
        END. 
    END. 

    //----------------------------------------------------------------------------------------------------

    ASSIGN iRet = 500.
    jsonObjectOutput = NEW JsonObject().
     
    IF  p-htt-1 <> ?
    AND p-htt-1:HAS-RECORDS THEN DO:               
        oJsonArrayAux = NEW JsonArray().
        oJsonArrayAux:READ(p-htt-1).
        jsonObjectOutput:ADD(p-htt-1:SERIALIZE-NAME, oJsonArrayAux).
        ASSIGN iRet = 200.                                         
        ASSIGN lPassou = YES.                                      
    END. 

    IF  p-htt-2 <> ?
    AND p-htt-2:HAS-RECORDS THEN DO:               
        oJsonArrayAux = NEW JsonArray().
        oJsonArrayAux:READ(p-htt-2).
        jsonObjectOutput:ADD(p-htt-2:SERIALIZE-NAME, oJsonArrayAux).
        ASSIGN iRet = 200.                                         
        ASSIGN lPassou = YES.                                      
    END.
                                                                    
    //----------------------------------------------------------------------------------------------------

    IF  lPassou = NO THEN DO:                                    
        IF TEMP-TABLE tt-retorno:HAS-RECORDS  THEN DO:
            ASSIGN iRet = 200.                                         
            ASSIGN lPassou = YES.                                      
        END.  
        IF lPassou = NO THEN DO:
            CREATE tt-retorno.                                         
            ASSIGN tt-retorno.versao-api   = c-versao-api 
                   tt-retorno.cod-status   = 999                      
                   tt-retorno.desc-retorno = "Erro na execuá∆o da API".
        END.
    END.

    oJsonArrayAux = NEW JsonArray().
    oJsonArrayAux:READ(TEMP-TABLE tt-retorno:HANDLE).
    jsonObjectOutput:ADD(TEMP-TABLE tt-retorno:SERIALIZE-NAME, oJsonArrayAux).

    p-jsonOutput = NEW JSONObject().
    p-jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).

    DELETE PROCEDURE apiHandler NO-ERROR.
    RETURN "OK".

END PROCEDURE.

//----------------------------------------------------------------------------------------------------
