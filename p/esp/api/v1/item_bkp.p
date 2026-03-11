USING Progress.Json.ObjectModel.*.

{utp/ut-api.i}
{utp/ut-api-action.i pi-get-grupo-estoq     GET   /grEstoq/~* }
{utp/ut-api-action.i pi-get-grupo-estoq     GET   /cest/~* }
{utp/ut-api-action.i pi-get-fam-comerc      GET   /famComerc/~* }
{utp/ut-api-action.i pi-get-fam-material    GET   /famMat/~* }
{utp/ut-api-action.i pi-get-caracteristicas GET   /caracteristicas/~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF TEMP-TABLE item_cest NO-UNDO
    FIELD it-codigo LIKE item.it-codigo
    FIELD cest      AS CHAR
    INDEX id IS PRIMARY it-codigo.

DEF TEMP-TABLE grupo_estoque NO-UNDO
    FIELD ge-codigo LIKE grup-estoque.ge-codigo
    FIELD descricao LIKE grup-estoque.descricao
    INDEX id IS PRIMARY ge-codigo.

DEF TEMP-TABLE familia_material NO-UNDO
    FIELD fm-codigo LIKE familia.fm-codigo
    FIELD descricao LIKE familia.descricao
    FIELD un        LIKE familia.un       
    INDEX id IS PRIMARY fm-codigo.

DEF TEMP-TABLE familia_comercial NO-UNDO
    FIELD fm-cod-com LIKE fam-comerc.fm-cod-com
    FIELD descricao  LIKE fam-comerc.descricao 
    FIELD un         LIKE fam-comerc.un        
    INDEX id IS PRIMARY fm-cod-com.

DEF TEMP-TABLE caracteristicas NO-UNDO
    FIELD cd-folha       LIKE comp-folh.cd-folha      
    FIELD cd-comp        LIKE comp-folh.cd-comp       
    FIELD descricao      LIKE comp-folh.descricao     
    FIELD tipo-result    LIKE comp-folh.tipo-result   
    FIELD vl-minimo      LIKE comp-folh.vl-minimo     
    FIELD vl-maximo      LIKE comp-folh.vl-maximo     
    FIELD nr-tabela      LIKE comp-folh.nr-tabela     
    FIELD nr-max-esc     LIKE comp-folh.nr-max-esc    
    FIELD inf-compl      LIKE comp-folh.inf-compl     
    FIELD un-medida      LIKE comp-folh.un-medida     
    FIELD seq-de-impres  LIKE comp-folh.seq-de-impres 
    FIELD abreviatura    LIKE comp-folh.abreviatura   
    FIELD ajuda          LIKE comp-folh.ajuda         
    FIELD dt-maxima      LIKE comp-folh.dt-maxima     
    FIELD dt-minima      LIKE comp-folh.dt-minima     
    FIELD formato        LIKE comp-folh.formato       
    FIELD nr-casa-dec    LIKE comp-folh.nr-casa-dec   
    FIELD forma-verif    LIKE comp-folh.forma-verif   
    FIELD nr-min-igual   LIKE comp-folh.nr-min-igual  
    FIELD cod-exame      LIKE comp-folh.cod-exame     
    FIELD cod-comp       LIKE comp-folh.cod-comp      
    FIELD gera-narrativa LIKE comp-folh.gera-narrativa
    FIELD gera-texto     LIKE comp-folh.gera-texto    
    INDEX id IS PRIMARY cd-folha cd-comp.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-get-cest:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    CREATE item_cest.
    ASSIGN item_cest.it-codigo  = "teste"
           item_cest.cest       = "teste2" .


    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE item_cest:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-grupo-estoq:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    FOR EACH grup-estoque NO-LOCK:

        CREATE grupo_estoque.
        ASSIGN grupo_estoque.ge-codigo = grup-estoque.ge-codigo
               grupo_estoque.descricao = grup-estoque.descricao.
    END.

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE grupo_estoque:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-fam-comerc:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    FOR EACH fam-comerc NO-LOCK:

        CREATE familia_comercial.
        ASSIGN familia_comercial.fm-cod-com = fam-comerc.fm-cod-com
               familia_comercial.descricao  = fam-comerc.descricao 
               familia_comercial.un         = fam-comerc.un        .
    END.

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE familia_comercial:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-fam-material:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    FOR EACH familia NO-LOCK:

        CREATE familia_material.
        ASSIGN familia_material.fm-codigo = familia.fm-codigo
               familia_material.descricao = familia.descricao
               familia_material.un        = familia.un       .
    END.

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE familia_material:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-caracteristicas:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    FOR EACH comp-folh NO-LOCK:
        CREATE caracteristicas.
        BUFFER-COPY comp-folh TO caracteristicas.
    END.

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE caracteristicas:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.
