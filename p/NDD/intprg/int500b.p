/********************************************************************************
** Programa: int500a - ConexÆo E leitura WebServer NDD - Entradas
**
** Versao : 12 - 15/09/2018 - Alessandro V Baccin
**
********************************************************************************/
{cdp/cdcfgdis.i}
{include/i-epc200.i} 
{utp/ut-glob.i}
{method/dbotterr.i}
/*{utils/BASE64.i}*/
/*{intprg/int500.i}*/
DEFINE INPUT PARAMETER p-cont AS INTEGER NO-UNDO.
/* Variaveis e procedures para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}

/* Carrega API auxiliar processamento de XML */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXML" &GXReturnValue="cReturnValue"}

if l-log then output stream str-log to value(cCaminhoTMP + "int500a-" + string(p-cont) + ".LOG").
/* retornar depois de corrigido pelo ndd
/* reprocessa arquivos que ficaram pendentes por algum motivo */
do:
    if opsys = "Unix" then 
        os-command silent "ls -s" value(cCaminhoTMP + "eformsConsultarColdDFeRetorno*.xml") > value(cCaminhoTMP + c-seg-usuario + ".inp") no-error.
    else
        os-command silent "dir /b" value(cCaminhoTMP + "eformsConsultarColdDFeRetorno*.xml") > value(cCaminhoTMP + c-seg-usuario + ".inp") no-error.
    if search(cCaminhoTMP + c-seg-usuario + ".inp") <> ? then do:
        input from value(cCaminhoTMP + c-seg-usuario + ".inp").
        repeat:
            import cFile.
            assign cFile = cCaminhoTMP + cFile.
            copy-lob FILE cFile TO cReturnValue.
            run pi-processa-retorno-Cold (input yes).
        end.
    end.
end.
*/

/* processa estabelecimentos */
for each estabelec no-lock
    /*WHERE estabelec.cgc = '79430682014000' */
    break by estabelec.cgc:

    if last-of (estabelec.cgc) then do:

        /* Gera Header do envio para NDD */
        run pi-GeraHeaderConsultarColdDFe (estabelec.cgc, output cHeader).
        if l-log then do:
            cFile = cCaminhoTMP + "eformsConsultarColdDFeHeader-" + estabelec.cod-estabel + ".xml".
            copy-lob cHeader to FILE cFile.
        end.

        /* envio p/ WebService */
        run pi-conectaWebServer (input 'WSConsultarColdDFe.wsdl', 
                                 input 'WSConsultarColdDFe',      
                                 input "973", /* utilizar webserver do CD para entradas */
                                 output l-connected).
        if l-connected then do:
            run WSConsultarColdDFeSoap set hWSPortaSoap on hWebService.

            run ConsultarDFeInterno in hWSPortaSoap(input  cHeader, 
                                                    output cReturnValue).

            /* guardando arquivo para posterior processamento em caso de queda ou erro no processamento */
            cFile = cCaminhoTMP + "eformsConsultarColdDFeRetorno" + "-" + 
                estabelec.cod-estabel + "-" + 
                c-seg-usuario + "-" + string(today,"99-99-9999") + 
                replace(string(time,"HH:MM:SS"),':','-') + ".xml".
            copy-lob cReturnValue TO FILE cFile.

            run pi-processa-retorno-Cold (input yes).

        end.
    end.
end.

if l-log then output stream str-log close.
if valid-handle(hGenXML) then delete object hGenXML no-error.
return "OK".

