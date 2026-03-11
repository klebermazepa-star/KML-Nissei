/******************************************************************************
* Programa .....: escd001rp.p                                                 *
* Data .........: 10 de agosto de 2022                                        *
* Empresa ......: Jeferson Consulting                                         *
* Cliente ......: Farm†cias Nissei                                            *
* Programador ..: Jeferson Souza                                              *
* Objetivo .....: Envio de dados TaxRules                                     *
* Revis‰es .....: 001 - 10/08/2022 - JS - Criaá∆o                             *  
******************************************************************************/

// C:\totvs\progress\oe11\gui\netlib\OpenEdge.Net.pl

using OpenEdge.Net.HTTP.*.
using OpenEdge.Net.URI.
using progress.Json.ObjectModel.ObjectModelParser.
using progress.Json.*.
using progress.Json.ObjectModel.*.

{include/i-prgvrs.i escd001rp 12.01.34.000}  
{utp/ut-glob.i}
{cdp/cd0666.i}

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
        {include/i-license-manager.i ESCD001 MCD}
&ENDIF

// Tempor†rias
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field modelo-rtf       as char format "x(35)"
    field l-habilitaRtf    as LOG
    field ge-codigo-ini    like item.ge-codigo
    field ge-codigo-fim    like item.ge-codigo
    field fm-cod-com-ini   like item.fm-cod-com
    field fm-cod-com-fim   like item.fm-cod-com
    field fm-codigo-ini    like item.fm-codigo
    field fm-codigo-fim    like item.fm-codigo
    field it-codigo-ini    like item.it-codigo
    field it-codigo-fim    like item.it-codigo
    field cod-estabel      like estabelec.cod-estabel
    field cod-emitente     like emitente.cod-emitente
    field url-servico      as char
    field lg-apenas-diverg as log
    field lg-atualiza      as log.

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.

define temp-table tt-raw-digita
    field raw-digita as raw.

define temp-table tt-itens no-undo
    field it-codigo             like item.it-codigo
    field desc-item             like item.desc-item
    field codigo-orig           like item.codigo-orig
    field dec-1                 like item.dec-1
    field cod-ean               like item-mat.cod-ean
    field class-fiscal          like item.class-fiscal
    field class-fiscal-new      like item.class-fiscal
    field cest                  as int
    field cest-new              as int
    field r-sit-tribut-relacto  as rowid
    field aliquota-ipi          like item.aliquota-ipi
    field aliquota-ipi-new      like item.aliquota-ipi
    field aliquota-pis          as dec
    field aliquota-pis-new      as dec
    field aliquota-cofins       as dec
    field aliquota-cofins-new   as dec
    field seq-item-atu          as int
    index ch-item it-codigo
    index ch-seq-item seq-item-atu.

define temp-table tt-item-uf
    field it-codigo             like item.it-codigo
    field estado-orig           like estabelec.estado
    field estado-dest           like estabelec.estado
    field aliquota-icm          like icms-it-uf.aliquota-icm
    field aliquota-icm-int      like icms-it-uf.aliquota-icm
    field aliquota-icm-new      like icms-it-uf.aliquota-icm
    field cod-clas-fisc-fcp     like ct-clas-fisc.cod-clas-fisc
    field aliquota-fcp          as dec
    field aliquota-fcp-new      as dec
    index ch-indice it-codigo  
                    estado-orig
                    estado-dest.

// Buffers
def buffer b-cidade         for ems2dis.cidade.
def buffer b-tt-erro        for tt-erro.

// Vari†veis
define variable jSonDoc     as Progress.Json.ObjectModel.jSonObject     no-undo.
define variable jSonArray   as Progress.Json.ObjectModel.JsonArray      no-undo.
define variable jSonObject  as Progress.Json.ObjectModel.jSonObject     no-undo.
define variable i-seq-item  as int                                      no-undo.
define variable h-acomp     as handle                                   no-undo.
define variable chExcel     as office.iface.excel.ExcelWrapper          no-undo.
define variable chWorkBook  as office.iface.excel.Workbook              no-undo.
define variable chWorkSheet as office.iface.excel.WorkSheet             no-undo.
define variable chRange     as office.iface.excel.Range                 no-undo.

// Definiá∆o de forms 
form tt-erro.i-sequen       column-label "Seq"
     tt-erro.cd-erro        column-label "Cod"
     tt-erro.mensagem       column-label "Erro "       format "x(60)"
     with frame f-erro no-box stream-io width 150 down.

// Parametros
define input parameter raw-param as raw no-undo.
define input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

{office/office.i Excel chExcel}
{include/i-rpvar.i}

find first param-global 
           no-lock no-error.

find first mguni.empresa 
     where empresa.ep-codigo = param-global.empresa-prin 
           no-lock no-error.

assign c-programa     = "ESCD001"
       c-versao	      = "12.01.34"
       c-revisao	  = ".000"
       c-empresa      = empresa.nome   
       c-sistema	  = "MCD"
       c-titulo-relat = "Calculos TaxRules".

{include/i-rpout.i}
{include/i-rpcab.i}

view frame f-cabec.
view frame f-rodape.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Carregando Itens...").

for each item use-index grupo where
         item.ge-codigo   >= tt-param.ge-codigo-ini
     and item.ge-codigo   <= tt-param.ge-codigo-fim
     and item.it-codigo   >= tt-param.it-codigo-ini
     and item.it-codigo   <= tt-param.it-codigo-fim
     and item.cod-obsoleto = 1 // Ativo
         no-lock:
    
    if item.fm-cod-com < tt-param.fm-cod-com-ini or
       item.fm-cod-com > tt-param.fm-cod-com-fim
    then next.

    if item.fm-codigo < tt-param.fm-codigo-ini or
       item.fm-codigo > tt-param.fm-codigo-fim
    then next.

    run pi-acompanhar IN h-acomp ("Item: " + item.it-codigo).

    create tt-itens.
    buffer-copy item to tt-itens.
    assign tt-itens.aliquota-pis    = dec(substring(item.char-2,31,5))
           tt-itens.aliquota-cofins = dec(substring(item.char-2,36,5)).

    find first item-mat
         where item-mat.it-codigo = item.it-codigo
               no-lock no-error.

    if avail item-mat 
    then assign tt-itens.cod-ean = item-mat.cod-ean.

end.

// Busca Parametrizaá‰es para FCP
run pi-seta-titulo IN h-acomp ("Buscando al°quota de FCP").

if not can-find (first tt-itens) 
then do:
    put unformat
        skip
        caps("Nenhum item elencado para c†lculo") at 10.
end.
else do:
    find first estabelec
         where estabelec.cod-estabel = tt-param.cod-estabel
               no-lock no-error.
    
    find first ems2dis.cidade
         where cidade.pais   = estabelec.pais  
           and cidade.estado = estabelec.estado
           and cidade.cidade = estabelec.cidade
               no-lock no-error.
    
    find first emitente
         where emitente.cod-emitente = tt-param.cod-emitente // 8484
               no-lock no-error.
    
    run pi-seta-titulo IN h-acomp ("Gerando JSON por UF").
    
    for each unid-feder where
             unid-feder.pais = estabelec.pais
             no-lock,
       first b-cidade where
             b-cidade.pais   = unid-feder.pais
         and b-cidade.estado = unid-feder.estado
         and b-cidade.cdn-munpio-ibge <> 0
             no-lock
             by unid-feder.estado
             by b-cidade.cidade:

        run pi-acompanhar IN h-acomp ("UF: " + unid-feder.estado).
    
        // Cria um arquivo por estado
        run pi-create-json.
    
    end.

    // Geraá∆o Arquivo Excel
    run pi-gera-excel.

    if tt-param.lg-atualiza 
    then do:
        for each tt-itens
                 no-lock:
            
            if tt-itens.class-fiscal <> tt-itens.class-fiscal-new
            then do:
                run pi-posiciona-item (input tt-itens.it-codigo).
    
                if avail item 
                then assign item.class-fiscal = tt-itens.class-fiscal-new.
    
            end.
    
            if tt-itens.cest <> tt-itens.cest-new
            then do:
                find first sit-tribut use-index sttrbt-id where
                           sit-tribut.cdn-tribut      = 11 // Cest
                       and sit-tribut.cdn-sit-tribut  = tt-itens.cest-new
                       and sit-tribut.dat-valid-inic < today
                           no-lock no-error.
    
                if avail sit-tribut 
                then do:
                    find first sit-tribut-relacto
                         where rowid(sit-tribut-relacto) = r-sit-tribut-relacto
                               exclusive-lock no-error.
    
                    if avail sit-tribut-relacto 
                    then assign sit-tribut-relacto.cdn-sit-tribut = tt-itens.cest-new.
                end.
                else do:
                    find last b-tt-erro no-error.
    
                    create tt-erro.
                    assign tt-erro.i-sequen = if avail b-tt-erro then b-tt-erro.i-sequen + 1 else 0
                           tt-erro.cd-erro  = 17567
                           tt-erro.mensagem = "N∆o foi identifada a CEST " + string(tt-itens.cest-new) + " no cadastro CD0354. Favor verificar".
                end.
            end.
    
            /* Neste momento n∆o ser† tratatado IPI
            if tt-itens.aliquota-ipi <> tt-itens.aliquota-ipi-new
            then do:
                run pi-posiciona-item (input tt-itens.it-codigo).
    
                if avail item 
                then assign item.aliquota-ipi = tt-itens.aliquota-ipi-new.
            end.
            */
    
            /* NÉo ser† atualizado PIS e COFINS nesse momento
            if tt-itens.aliquota-pis <> tt-itens.aliquota-pis-new
            then do:
                run pi-posiciona-item (input tt-itens.it-codigo).
    
                if avail item 
                then overlay(item.char-2,31,5) = string(tt-itens.aliquota-pis-new,"99.99").
    
            end.
    
            if tt-itens.aliquota-cofins <> tt-itens.aliquota-cofins-new
            then do:
                run pi-posiciona-item (input tt-itens.it-codigo).
    
                if avail item 
                then overlay(item.char-2,36,5)  = string(tt-itens.aliquota-cofins-new,"99.99").
            end.
            */

            release item.
    
            for each tt-item-uf where
                     tt-item-uf.it-codigo     = tt-itens.it-codigo
                 and tt-item-uf.aliquota-icm <> tt-item-uf.aliquota-icm-new
                     no-lock:
    
                if tt-itens.codigo-orig = 0 // Nacional
                then do:
                    find first icms-it-uf
                         where icms-it-uf.it-codigo = tt-itens.it-codigo
                           and icms-it-uf.estado    = tt-item-uf.estado-dest
                               exclusive-lock no-error.
    
                    if not avail icms-it-uf 
                    then do:
                        create icms-it-uf.
                        assign icms-it-uf.it-codigo = tt-itens.it-codigo    
                               icms-it-uf.estado    = tt-item-uf.estado-dest.
                    end.
    
                    assign icms-it-uf.aliquota-icm = tt-item-uf.aliquota-icm-new.
                end.
                else do: // Importado
                    if tt-item-uf.estado-orig <> tt-item-uf.estado-dest 
                    then do:
                        find first relacto-item-uf-aliq
                             where relacto-item-uf-aliq.cod-impto   = "ICMS"
                               and relacto-item-uf-aliq.cod-item    = tt-item-uf.it-codigo
                               and relacto-item-uf-aliq.cod-uf-orig = tt-item-uf.estado-orig
                               and relacto-item-uf-aliq.cod-uf-dest = tt-item-uf.estado-dest
                                   exclusive-lock no-error.
                
                        if not avail relacto-item-uf-aliq 
                        then do:
                            create relacto-item-uf-aliq.
                            assign relacto-item-uf-aliq.cod-impto   = "ICMS"                
                                   relacto-item-uf-aliq.cod-item    = tt-item-uf.it-codigo  
                                   relacto-item-uf-aliq.cod-uf-orig = tt-item-uf.estado-orig
                                   relacto-item-uf-aliq.cod-uf-dest = tt-item-uf.estado-dest.
                        end.
    
                        assign relacto-item-uf-aliq.val-aliq = tt-item-uf.aliquota-icm-new.
                    end.
                end.

                // FCP
                if tt-item-uf.aliquota-fcp <> tt-item-uf.aliquota-fcp-new 
                then do:
                    // Se for diferente de zero, descadastra a relaá∆o existente
                    if tt-item-uf.aliquota-fcp <> 0 
                    then do:
                        find first ct-clas-item
                             where ct-clas-item.cod-clas-fisc = tt-item-uf.cod-clas-fisc-fcp
                               and ct-clas-item.cod-item      = tt-item-uf.it-codigo
                                   exclusive-lock no-error.
                
                        if avail ct-clas-item 
                        then delete ct-clas-item.
                    end.
                
                    if tt-item-uf.aliquota-fcp-new <> 0
                    then do:
                        // Busca a classificaá∆o com a aliquota retornada
                        for each es-ct-clas-fisc use-index idx-fcp where
                                 es-ct-clas-fisc.lg-fcp
                             and es-ct-clas-fisc.estado       = tt-item-uf.estado-dest
                             and es-ct-clas-fisc.aliquota-fcp = tt-item-uf.aliquota-fcp-new
                                 no-lock:
                            
                            find first ct-clas-item
                                 where ct-clas-item.cod-clas-fisc = es-ct-clas-fisc.cod-clas-fisc
                                   and ct-clas-item.cod-item      = tt-item-uf.it-codigo
                                       exclusive-lock no-error.
                
                            if not avail ct-clas-item 
                            then do:
                                create ct-clas-item.              
                                assign ct-clas-item.cod-clas-fisc         = es-ct-clas-fisc.cod-clas-fisc
                                       ct-clas-item.cod-item              = tt-itens.it-codigo
                                       ct-clas-item.dat-ult-atualiz       = today
                                       ct-clas-item.hra-ult-atualiz       = replace(string(time,"HH:MM:SS"),":","")
                                       ct-clas-item.cod-usuar-ult-atualiz = c-seg-usuario.
                            end.
                        end.
                
                    end.
                end.
            end.
        end.
    end.

    if can-find (first tt-erro)
    then do:
        put unformat 
            skip
            caps("Erros encontrados na execuá∆o") at 10
            skip(1).
    
        for each tt-erro
                 by tt-erro.i-sequen:
    
            disp tt-erro.i-sequen
                 tt-erro.cd-erro
                 tt-erro.mensagem
                 with frame f-erro.
            down with frame f-erro.
        end.
    end.
    else put unformat
             skip
             caps("Execuá∆o executada com sucesso") at 10.
end.

run pi-finalizar in h-acomp.

{include/i-rpclo.i}

return 'OK'.

/****************** PROCEDURES *******************/

procedure pi-create-json:

    jSonDoc = new Progress.Json.ObjectModel.jSonObject().

    // CalcParam
    jSonObject = new Progress.Json.ObjectModel.jSonObject().
    jSonObject:Add("mdArred", "A").
    jSonDoc:Add("calcParam",jSonObject).
    
    jSonDoc:Add("cdTipo","S"). // OK
    jSonDoc:Add("desconsideraDesoneracao",false).
    
    // Destinat†rio
    jSonObject = new Progress.Json.ObjectModel.jSonObject().
    jSonArray = new Progress.Json.ObjectModel.JsonArray().
    jSonArray:Add(0,"4644301"). // OK
    jSonObject:Add("cdAtividadeEconomica" , jSonArray). // OK
    jSonObject:Add("cdMunicipio" , b-cidade.cdn-munpio-ibge). // NOK
    jSonObject:Add("cdPais" , "105"). // OK

    if emitente.identific = 1 // Fisica
    then jSonObject:Add("cpf" , emitente.cgc). // OK - Fisica
    else jSonObject:Add("cnpj" , emitente.cgc). // OK - Juridica

    jSonObject:Add("contribuinteCOFINS" , "N"). // OK
    jSonObject:Add("contribuinteICMS" , "N"). // OK
    jSonObject:Add("contribuinteII" , "N").
    jSonObject:Add("contribuinteIPI" , "N"). // OK
    jSonObject:Add("contribuinteISS" , "N").
    jSonObject:Add("contribuintePIS" , "N"). // OK
    jSonObject:Add("contribuinteST" , "N").
    jSonObject:Add("pessoaJuridica" , "N"). // OK
    jSonObject:Add("simplesNac" , "N").
    jSonObject:Add("uf" , b-cidade.estado). // OK
    jSonDoc:Add("destinatario",jSonObject).
    
    jSonDoc:Add("docFiscalTeste" , false).
    jSonDoc:Add("dtEmissao" , today). // OK
    
    // Emitente
    jSonObject = new Progress.Json.ObjectModel.jSonObject().
    jSonArray = new Progress.Json.ObjectModel.JsonArray().
    jSonArray:Add(0,"4644301"). // OK
    jSonObject:Add("cdAtividadeEconomica" , jSonArray). // OK
    jSonObject:Add("cdMunicipio" , ems2dis.cidade.cdn-munpio-ibge). // OK
    jSonObject:Add("cdPais" , "105"). // OK
    jSonObject:Add("cnpj" , estabelec.cgc). // OK
    jSonObject:Add("contribuinteCOFINS" , "S"). // OK
    jSonObject:Add("contribuinteICMS" , "S"). // OK
    jSonObject:Add("contribuinteII" , "N").
    jSonObject:Add("contribuinteIPI" , "S"). // OK
    jSonObject:Add("contribuinteISS" , "N"). 
    jSonObject:Add("contribuintePIS" , "S"). // OK
    jSonObject:Add("contribuinteST" , "N").
    jSonObject:Add("pessoaJuridica" , "S"). // OK
    jSonObject:Add("simplesNac" , "N"). // OK
    jSonObject:Add("uf" , estabelec.estado). // OK
    jSonDoc:Add("emitente" , jSonObject).
    
    jSonDoc:Add("indConsumidorFinal" , "S"). // OK
    
    // Itens
    run pi-add-itens (output jSonArray).
    jSonDoc:Add("itensDocFiscal" , jSonArray).
    
    jSonDoc:Add("naturezaOperacao" , "002"). // OK
    jSonDoc:Add("numero" , 0). // OK
    jSonDoc:Add("serie" , "SU"). // OK
    jSonDoc:Add("tipoOperacao" , if estabelec.estado = unid-feder.estado then "E" else "I"). // OK
    jSonDoc:Add("tipoPagto" , 2).
    jSonDoc:Add("tpCalculo" , "TAX"). // OK
    jSonDoc:Add("tpDocFiscal" , "FT"). // OK
    jSonDoc:Add("versaoNFe" , "4.00"). // OK
    
    jSonDoc:WriteFile(session:temp-directory + "JSON_" + caps(unid-feder.estado) +  ".json", yes).

    run pi-processa-tax-rules (input jSonDoc).
    
end.

procedure pi-add-itens:

    // Parametros
    define output parameter p-jSonArray   as Progress.Json.ObjectModel.JsonArray      no-undo.

    // Vari†veis
    define variable jSonObject      as Progress.Json.ObjectModel.jSonObject     no-undo.
    define variable jSonObjectItem  as Progress.Json.ObjectModel.jSonObject     no-undo.
    define variable i-cont-item     as int                                      no-undo.
    define variable i-cont          as int                                      no-undo.
    
    p-jSonArray = new Progress.Json.ObjectModel.JsonArray().

    for each tt-itens
             no-lock:

        // Relaá∆o Item x UF
        find first tt-item-uf
             where tt-item-uf.it-codigo   = tt-itens.it-codigo
               and tt-item-uf.estado-orig = estabelec.estado //emitente
               and tt-item-uf.estado-dest = unid-feder.estado
                   no-error.

        if not avail tt-item-uf 
        then do:
            create tt-item-uf.
            assign tt-item-uf.it-codigo   = tt-itens.it-codigo
                   tt-item-uf.estado-orig = estabelec.estado  //emitente
                   tt-item-uf.estado-dest = unid-feder.estado.
        end.

        // Busca FCP
        for first es-ct-clas-fisc use-index idx-fcp where
                  es-ct-clas-fisc.lg-fcp
              and es-ct-clas-fisc.estado = unid-feder.estado
                  no-lock,
            first ct-clas-item where
                  ct-clas-item.cod-clas-fisc = es-ct-clas-fisc.cod-clas-fisc
              and ct-clas-item.cod-item      = tt-itens.it-codigo
                  no-lock:

            assign tt-item-uf.cod-clas-fisc-fcp = es-ct-clas-fisc.cod-clas-fisc
                   tt-item-uf.aliquota-fcp      = es-ct-clas-fisc.aliquota-fcp.
        end.


        if tt-itens.codigo-orig = 0 // Nacional
        then do:
            find first icms-it-uf
                 where icms-it-uf.it-codigo = tt-itens.it-codigo
                   and icms-it-uf.estado    = unid-feder.estado
                       no-lock no-error.

            if avail icms-it-uf 
            then assign tt-item-uf.aliquota-icm = icms-it-uf.aliquota-icm.
            else do:
                if tt-item-uf.estado-orig <> tt-item-uf.estado-dest 
                then do:
                    assign tt-item-uf.aliquota-icm = unid-feder.per-icms-int.

                    // Verifica lista de exeá∆o
                    do i-cont = 1 to 25:

                        if unid-feder.est-exc[i-cont] = tt-item-uf.estado-dest 
                        then do:
                            assign tt-item-uf.aliquota-icm-int = unid-feder.perc-exc[i-cont].
                            leave.
                        end.
                    end.

                    // Se n∆o encontrou na lista de exceá∆o, busca do ICMS Interestadual.
                    if tt-item-uf.aliquota-icm-int = 0 
                    then assign tt-item-uf.aliquota-icm-int = unid-feder.per-icms-ext.

                end.
                else assign tt-item-uf.aliquota-icm = unid-feder.per-icms-int.
            end.
        end.
        else do: // Importado
            if tt-item-uf.estado-orig = tt-item-uf.estado-dest 
            then do:
                find first icms-it-uf
                     where icms-it-uf.it-codigo = tt-itens.it-codigo
                       and icms-it-uf.estado    = unid-feder.estado
                           no-lock no-error.

                if avail icms-it-uf 
                then assign tt-item-uf.aliquota-icm = icms-it-uf.aliquota-icm.
                else assign tt-item-uf.aliquota-icm = unid-feder.per-icms-int.
            end.
            else do:
                find first relacto-item-uf-aliq
                     where relacto-item-uf-aliq.cod-impto   = "ICMS"
                       and relacto-item-uf-aliq.cod-item    = tt-item-uf.it-codigo
                       and relacto-item-uf-aliq.cod-uf-orig = tt-item-uf.estado-orig
                       and relacto-item-uf-aliq.cod-uf-dest = tt-item-uf.estado-dest
                           no-lock no-error.

                if avail relacto-item-uf-aliq 
                then assign tt-item-uf.aliquota-icm = relacto-item-uf-aliq.val-aliq.
                else assign tt-item-uf.aliquota-icm = unid-feder.per-icms-int.
            end.
        end.

        // Busca CEST
        for first sit-tribut-relacto use-index sttrbtrl-item where
                  sit-tribut-relacto.cod-item        = tt-itens.it-codigo
              and sit-tribut-relacto.dat-valid-inic < today
              and sit-tribut-relacto.cdn-tribut      = 11 // Cest
              and sit-tribut-relacto.idi-tip-docto   = 2  // Saida
                  no-lock:

            assign tt-itens.cest                 = sit-tribut-relacto.cdn-sit-tribut
                   tt-itens.r-sit-tribut-relacto = rowid(sit-tribut-relacto).
        end.

        jSonObject = new Progress.Json.ObjectModel.jSonObject().

        jSonObject:Add("cdClassificacao" , "M"). // OK
        jSonObject:Add("cdItemDocFiscal" , i-seq-item). // OK
        jSonObject:Add("qtItemDocFiscal" , 1). // OK
        jSonObject:Add("qtTributariaUnidade" , "UN"). // OK
        jSonObject:Add("unidade" , "UN"). // OK
        jSonObject:Add("vlTotal" , 100.00). // OK
        jSonObject:Add("vlTotalCI" , 100.00). // OK
        jSonObject:Add("deduzCFOP" , "S").
        jSonObject:Add("deduzCSTCOFINS" , "S").
        jSonObject:Add("deduzCSTICMS" , "S").
        jSonObject:Add("deduzCSTIPI" , "N").
        jSonObject:Add("deduzCSTPIS" , "S").
        jSonObject:Add("deduzCEST" , "N").
        jSonObject:Add("indFarmaciaPopular" , "N").
        jSonObject:Add("praticaRepasse" , "N").
        
        jSonObjectItem = new Progress.Json.ObjectModel.jSonObject().
        
        jSonObjectItem:Add("codigo" , tt-itens.it-codigo). // OK
        jSonObjectItem:Add("descricao" , tt-itens.desc-item). // OK
        jSonObjectItem:Add("aplicacao" , "U"). // OK
        jSonObjectItem:Add("cdOrigem" , if tt-itens.codigo-orig = 1 then 2 else tt-itens.codigo-orig). // OK - Tratativa para enviar c¢digo 2 quando for 1...(Solicitaá∆o do cliente)
        jSonObjectItem:Add("exNCM" , ""). // OK
        jSonObjectItem:Add("exTIPI" , string(tt-itens.dec-1)). // OK
        jSonObjectItem:Add("fabricacao" , "1"). // OK
        jSonObjectItem:Add("EAN" , tt-itens.cod-ean). // OK
        jSonObjectItem:Add("NCM" , tt-itens.class-fiscal). // OK
        jSonObjectItem:Add("CEST" , tt-itens.cest). // OK
        jSonObject:Add("prodItem" ,  jSonObjectItem).
        
        jSonObject:Add("qtTributaria" , 1). // OK
        //jSonObject:Add("unidade" , "UN"). // OK
        //jSonObject:Add("vlDesconto" , 39.93).
        //jSonObject:Add("vlTotal" , 100.00). // OK
        //jSonObject:Add("vlTotalCI" , 100.00). //
        //jSonObject:Add("vlPrecoFabrica" , 57.87).
        //jSonObject:Add("vlPMC" , 80.0).
        //jSonObject:Add("cdAplicacao" , "C").
        
        p-jSonArray:add(i-cont-item,jSonObject).

        assign tt-itens.seq-item-atu = i-cont-item
               i-cont-item           = i-cont-item + 1.
    end.

end.

procedure pi-processa-tax-rules:

    // Parametros
    define input parameter jSonDoc     as Progress.Json.ObjectModel.jSonObject     no-undo.

    // Variaveis
    define variable oClient             as IHttpClient                              no-undo.
    define variable oURI                as URI                                      no-undo.
    define variable oRequest            as IHttpRequest                             no-undo. 
    define variable oResponse           as IHttpResponse                            no-undo.
    define variable oJsonObject         as Progress.Json.ObjectModel.jSonObject     no-undo.
    define variable JsonString          as longchar                                 no-undo.
    define variable oResponseBody       as OpenEdge.Core.String                     no-undo.

    //Build a request
    assign oURI = URI:Parse(tt-param.url-servico).

    oRequest = RequestBuilder:POST(oURI,jSonDoc):AddHeader("Content-Type", "application/json"):Request.
    
    //Execute a request
    oClient = ClientBuilder:Build():Client.
    oResponse = oClient:Execute(oRequest).

    //Process the response
    if oResponse:StatusCode <> 200 
    then put unformat
             "Erro de reposta para o c†lculo dos itens para o estado de destino " + unid-feder.estado + ":" + string(oResponse:StatusCode)
             skip(1).
    else do:
        assign oJsonObject = CAST(oResponse:Entity, Progress.Json.ObjectModel.jSonObject).

        oJsonObject:Write(JsonString, true).
        oJsonObject:WriteFile(session:temp-directory + "JSON_RET_" + caps(unid-feder.estado) +  ".json", yes).
        //put unformat string(JsonString).

        run ProcessObject (input "ROOT", INPUT oJsonObject).
    end.
end.


procedure ProcessObject:

    // Parametros
    define input parameter pParentName      as char                                         no-undo.
    define input parameter oJsonObject      as Progress.Json.ObjectModel.jSonObject         no-undo.

    // Vari†veis
    define variable myArray         as character extent                         no-undo.
    define variable i-cont          as integer                                  no-undo.  
    define variable cText           as longchar                                 no-undo.  
    define variable cParent         as character                                no-undo.
    define variable oJsonObject2    as Progress.Json.ObjectModel.jSonObject     no-undo.
    define variable c-tributo       as char                                     no-undo.
    define variable oParser         as ObjectModelParser                        no-undo.
    define variable oJsonArray      as JsonArray                                no-undo.
    define variable cString         as character                                no-undo.

    assign oParser = new ObjectModelParser()
           myArray = oJsonObject:GetNames() no-error.

    do i-cont = 1 to extent(myArray):

        assign cText   = oJsonObject:getJsonText(myArray[i-cont]) no-error.
        assign cString = string(cText) no-error.
        assign cParent = myArray[i-cont] no-error. 

        if pParentName = 'itensDocFiscal' 
        then do:
            if cParent = 'cdItemDocFiscal' 
            then do:
                // Posiciona no item
                find first tt-itens use-index ch-seq-item
                     where tt-itens.seq-item-atu = int(cString)
                           no-error.
            end.

            if cParent = 'vlAliquotaEfetivaFCPICM' 
            then do:
                find first tt-item-uf
                     where tt-item-uf.it-codigo   = tt-itens.it-codigo
                       and tt-item-uf.estado-orig = estabelec.estado //emitente
                       and tt-item-uf.estado-dest = unid-feder.estado
                           no-error.

                if avail tt-item-uf 
                and tt-item-uf.aliquota-fcp-new = 0
                then assign tt-item-uf.aliquota-fcp-new = dec(replace(cString,".",",")).
            end.
        end.

        if pParentName = 'prodItem' 
        then do:
            if cParent = 'ncm' 
            then do:
                if avail tt-itens 
                and tt-itens.class-fiscal-new = ''
                then assign tt-itens.class-fiscal-new = cString.
            end.

            if cParent = 'cest' 
            then do:
                if avail tt-itens 
                and tt-itens.cest-new = 0
                then assign tt-itens.cest-new = int(cString).
            end.
        end.

        if pParentName = 'enquadramentos' 
        then do:
            if cParent = 'dsSigla' 
            then assign c-tributo = string(cText).

            if cParent = 'vlAliquota' 
            and avail tt-itens
            then do:
                /*
                if c-tributo = 'IPI' 
                then assign tt-itens.aliquota-ipi-new = dec(cString) / 100. // Divide por cem, pois o . nao considera para decimal*/

                if c-tributo = 'PIS' 
                then assign tt-itens.aliquota-pis-new = dec(replace(cString,".",",")). // Divide por cem, pois o . nao considera para decimal

                if c-tributo = 'COFINS' 
                then assign tt-itens.aliquota-cofins-new = dec(replace(cString,".",",")). // Divide por cem, pois o . nao considera para decimal

                if c-tributo = 'ICMS' 
                then do:
                    find first tt-item-uf
                         where tt-item-uf.it-codigo   = tt-itens.it-codigo
                           and tt-item-uf.estado-orig = estabelec.estado
                           and tt-item-uf.estado-dest = unid-feder.estado
                               no-error.

                    if avail tt-item-uf 
                    then assign tt-item-uf.aliquota-icm-new = dec(replace(cString,".",",")).
                end.
            end.
        end.

        /*
        if //cParent = 'cest' 
           cParent = 'dsSigla'
        then
            MESSAGE  pParentName skip
                     string(cText)
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */

        if oJsonObject:GetType(myArray[i-cont]) = JsonDataType:object 
        then do:
            assign oJsonObject2 = CAST(oParser:Parse( oJsonObject:getJsonText(myArray[i-cont]) ), JsonObject) no-error.
            run ProcessObject (input cParent, input oJsonObject2). /* Process the JSON Object */ 
        end.
        
        if oJsonObject:GetType(myArray[i-cont]) = JsonDataType:ARRAY
        then do:
            assign oJsonArray = CAST(oParser:Parse( oJsonObject:getJsonText(myArray[i-cont]) ), JsonArray) no-error.
        
            run ProcessArray (input cParent, input oJsonArray). /* Process the JSON Array */     
        end.
    end.
end.

procedure ProcessArray:

    // Parametros
    define input parameter pParentName      as char              no-undo.
    define input parameter oJsonArray       as JsonArray         no-undo.

    define variable i-cont      as integer                no-undo.  
    define variable cText       as longchar               no-undo.  
    define variable oJsonObject as JsonObject             no-undo.
    define variable oParser     as ObjectModelParser      no-undo.

    assign oParser = new ObjectModelParser().

    /* Process each object in the JSON array */
    do i-cont = 1 to oJsonArray:length:

        assign cText = oJsonArray:getJsonText(i-cont).

        assign oJsonObject = cast(oParser:Parse(cText), JsonObject) no-error.
                                                       
        run ProcessObject (input pParentName, input oJsonObject). /* Process the JSON Object */
    end.  
end.

procedure pi-posiciona-item:

    // Parametros
    def input parameter p-it-codigo         like item.it-codigo         no-undo.

    find first item
         where item.it-codigo = p-it-codigo
               exclusive-lock no-error.
    
end.

procedure pi-gera-excel:

    // Vari†veis
    def var c-arquivo          as char                                no-undo.
    def var i-lin              as int init 2                          no-undo.

    run pi-seta-titulo in h-acomp ("Gerando Relat¢rio").

    assign c-arquivo = session:temp-directory
                     + "ESCD001.xls".

    os-delete value(c-arquivo) no-error.

    assign chExcel:visible = no.
    chExcel:application:DisplayAlerts = no.

    // Cabeáalho
    chExcel:SheetsInNewWorkbook = 1. // Nr Planilhas Totais  
    chWorkBook = chExcel:Workbooks:add(). 
    chWorkSheet = chWorkBook:Sheets:add().
    chWorkSheet:name = "ESCD001".

    // Colunas
    chWorkSheet:range("A1"):value = "Estado Orig.".
    chWorkSheet:range("A1"):columnWidth = 16.
    chWorkSheet:range("A:A"):NumberFormat = "@".

    chWorkSheet:range("B1"):value = "Estado Dest.".
    chWorkSheet:range("B1"):columnWidth = 16.
    chWorkSheet:range("B:B"):NumberFormat = "@".

    chWorkSheet:range("C1"):value = "Item".
    chWorkSheet:range("C1"):columnWidth = 16.
    chWorkSheet:range("C:C"):NumberFormat = "@".
    
    chWorkSheet:range("D1"):value = "Descriá∆o".
    chWorkSheet:range("D1"):columnWidth = 50.
    chWorkSheet:range("D:D"):NumberFormat = "@".
    
    chWorkSheet:range("E1"):value = "Classificaá∆o Fiscal".
    chWorkSheet:range("E1"):columnWidth = 17.
    chWorkSheet:range("E:E"):NumberFormat = "@".

    chWorkSheet:range("F1"):value = "Classificaá∆o Fiscal (Calc)".
    chWorkSheet:range("F1"):columnWidth = 23.
    chWorkSheet:range("F:F"):NumberFormat = "@".

    chWorkSheet:range("G1"):value = "CEST".
    chWorkSheet:range("G1"):columnWidth = 10.
    chWorkSheet:range("G:G"):NumberFormat = "@".

    chWorkSheet:range("H1"):value = "CEST (Calc)".
    chWorkSheet:range("H1"):columnWidth = 10.
    chWorkSheet:range("H:H"):NumberFormat = "@".

    /*
    chWorkSheet:range("I1"):value = "Al°quota IPI".
    chWorkSheet:range("I1"):columnWidth = 11.
    chWorkSheet:range("I:I"):NumberFormat = "##0,00".

    chWorkSheet:range("J1"):value = "Al°quota IPI (Calc)".
    chWorkSheet:range("J1"):columnWidth = 16.
    chWorkSheet:range("J:J"):NumberFormat = "##0,00".*/

    chWorkSheet:range("I1"):value = "Al°quota PIS".
    chWorkSheet:range("I1"):columnWidth = 11.
    chWorkSheet:range("I:I"):NumberFormat = "##0,00".

    chWorkSheet:range("J1"):value = "Al°quota PIS (Calc)".
    chWorkSheet:range("J1"):columnWidth = 17.
    chWorkSheet:range("J:J"):NumberFormat = "##0,00".

    chWorkSheet:range("K1"):value = "Al°quota COFINS".
    chWorkSheet:range("K1"):columnWidth = 15.
    chWorkSheet:range("K:K"):NumberFormat = "##0,00".

    chWorkSheet:range("L1"):value = "Al°quota COFINS (Calc)".
    chWorkSheet:range("L1"):columnWidth = 21.
    chWorkSheet:range("L:L"):NumberFormat = "##0,00".

    chWorkSheet:range("M1"):value = "Al°quota ICMS".
    chWorkSheet:range("M1"):columnWidth = 13.
    chWorkSheet:range("M:M"):NumberFormat = "##0,00".

    chWorkSheet:range("N1"):value = "Al°quota ICMS INTERES.".
    chWorkSheet:range("N1"):columnWidth = 21.
    chWorkSheet:range("N:N"):NumberFormat = "##0,00".

    chWorkSheet:range("O1"):value = "Al°quota ICMS (Calc)".
    chWorkSheet:range("O1"):columnWidth = 19.
    chWorkSheet:range("O:O"):NumberFormat = "##0,00".

    chWorkSheet:range("P1"):value = "Al°quota FCP".
    chWorkSheet:range("P1"):columnWidth = 19.
    chWorkSheet:range("P:P"):NumberFormat = "##0,00".

    chWorkSheet:range("Q1"):value = "Al°quota FCP (Calc)".
    chWorkSheet:range("Q1"):columnWidth = 19.
    chWorkSheet:range("Q:Q"):NumberFormat = "##0,00".

    chWorkSheet:range("A1:Q1"):font:bold = yes.

    for each tt-itens
             no-lock,
        each tt-item-uf where
             tt-item-uf.it-codigo = tt-itens.it-codigo
             no-lock
             by tt-item-uf.it-codigo
             by tt-item-uf.estado-dest:

        if  tt-param.lg-apenas-diverg
        and tt-itens.class-fiscal    = tt-itens.class-fiscal-new
        and tt-itens.cest            = tt-itens.cest-new
        and tt-itens.aliquota-ipi    = tt-itens.aliquota-ipi-new
        and tt-itens.aliquota-pis    = tt-itens.aliquota-pis-new
        and tt-itens.aliquota-cofins = tt-itens.aliquota-cofins-new
        and tt-item-uf.aliquota-icm  = tt-item-uf.aliquota-icm-new
        then next.

        run pi-acompanhar IN h-acomp ("Item: " + tt-itens.it-codigo).

        chWorkSheet:range("A" + string(i-lin)):value = tt-item-uf.estado-orig.
        chWorkSheet:range("B" + string(i-lin)):value = tt-item-uf.estado-dest.
        chWorkSheet:range("C" + string(i-lin)):value = tt-itens.it-codigo.
        chWorkSheet:range("D" + string(i-lin)):value = tt-itens.desc-item.
        chWorkSheet:range("E" + string(i-lin)):value = tt-itens.class-fiscal.
        chWorkSheet:range("F" + string(i-lin)):value = tt-itens.class-fiscal-new.
        chWorkSheet:range("G" + string(i-lin)):value = string(tt-itens.cest).
        chWorkSheet:range("H" + string(i-lin)):value = string(tt-itens.cest-new).
        //chWorkSheet:range("I" + string(i-lin)):value = string(tt-itens.aliquota-ipi).
        //chWorkSheet:range("J" + string(i-lin)):value = string(tt-itens.aliquota-ipi-new).
        chWorkSheet:range("I" + string(i-lin)):value = string(tt-itens.aliquota-pis).
        chWorkSheet:range("J" + string(i-lin)):value = string(tt-itens.aliquota-pis-new).
        chWorkSheet:range("K" + string(i-lin)):value = string(tt-itens.aliquota-cofins).
        chWorkSheet:range("L" + string(i-lin)):value = string(tt-itens.aliquota-cofins-new).
        chWorkSheet:range("M" + string(i-lin)):value = string(tt-item-uf.aliquota-icm).
        chWorkSheet:range("N" + string(i-lin)):value = string(tt-item-uf.aliquota-icm-int).
        chWorkSheet:range("O" + string(i-lin)):value = string(tt-item-uf.aliquota-icm-new).
        chWorkSheet:range("P" + string(i-lin)):value = string(tt-item-uf.aliquota-fcp).
        chWorkSheet:range("Q" + string(i-lin)):value = string(tt-item-uf.aliquota-fcp-new).

        assign i-lin = i-lin + 1.
        
    end.

    // Salva
    chWorkBook:SaveAs(c-arquivo,1,"","",no,no,no).  

    if tt-param.destino = 3 
    then do:
        assign chExcel:visible = yes.
    end.
    else do:
        chWorkBook:close().                   
        chExcel:quit().
    end.
end.



