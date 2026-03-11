/*****************************************************************************
*  Programa: UPC/trg-w-res-emb.p - TRIGGER de WRITE de Embalagens de Resumo
*  
*  Autor: Alessandro V Baccin
*
*  Data: 28/01/2016
*
*  
******************************************************************************/
def param BUFFER p-res-emb     FOR mgdis.res-emb.
def param BUFFER p-OLD-res-emb FOR mgdis.res-emb.

def var c-embalagem as char no-undo.
def var i-volumes as integer no-undo.
def var c-lotes as char no-undo.

if avail p-res-emb and avail p-OLD-res-emb then do:

    if p-res-emb.nr-embarque <> 0 and p-OLD-res-emb.nr-embarque = 0 then do:
        for each res-cli no-lock of res-emb:
            assign  c-embalagem = ""
                    i-volumes = 0.
            for each it-pre-fat no-lock of res-cli:
                for each cst_ped_item no-lock WHERE 
                         cst_ped_item.nome_abrev   = it-pre-fat.nome-abrev AND 
                         cst_ped_item.nr_sequencia = it-pre-fat.nr-sequencia AND
                         cst_ped_item.nr_pedcli    = it-pre-fat.nr-pedcli AND
                         cst_ped_item.it_codigo    = it-pre-fat.it-codigo AND
                         cst_ped_item.cod_ref      = it-pre-fat.cod-ref:
                    if cst_ped_item.numero_caixa <> "" then do:
                        assign i-volumes = i-volumes + 1.
                        if c-embalagem = "" then 
                            assign c-embalagem = "Cx: " + 
                                                 string(cst_ped_item.numero_caixa).
                        else 
                            assign c-embalagem = c-embalagem + " " + 
                                                 string(cst_ped_item.numero_caixa).
                    end.    
                    if cst_ped_item.numero_lote <> "" then do:
                        if c-lotes = "" then 
                            assign c-lotes = "Lote: " + 
                                             cst_ped_item.numero_lote.
                        else 
                            assign c-lotes = c-lotes + " " + 
                                             cst_ped_item.numero_lote.
                    end.
                end.
            end.
        end.
    end.
    if c-embalagem <> "" then 
        assign  res-emb.qt-volumes = i-volumes
                res-emb.desc-vol = res-emb.desc-vol + c-embalagem.
    if c-lotes <> "" then 
        assign res-emb.desc-vol = res-emb.desc-vol + c-lotes.
end.
