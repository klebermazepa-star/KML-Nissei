{utp/ut-glob.i}

/* VARIABEL PARA ARMAZENAR OS VALORES OBTIDOS NA INICIALIZACAO DO loalGenXml */
def var hGenXML as handle no-undo.
def var hXML as handle no-undo.
def var cFile as char no-undo.
def var cFileXML as char no-undo.
def var cHeader as longchar no-undo.
def var cReturnValue as longchar no-undo.
def var cXML as longchar no-undo.
def var memptrXML as memptr no-undo.
def var cMensagem as char no-undo.
def var cCodigoErro as char no-undo.
def var cProtocolo as char no-undo.
def var cChaveAcesso as char no-undo.
def var cData as char no-undo.
def var iId as integer no-undo.
def var hWebService as handle no-undo.
def var hWSPortaSoap as handle no-undo.
def var cCaminhoNDD as char /*initial '\\192.168.200.250\totvs12\_custom_prod\NDD\'*/ no-undo.
def var cCaminhoTMP as char /*initial '\\192.168.200.250\totvs12\_custom_prod\NDD\'*/ no-undo.
def var cColdID as char initial /*'399' saidas */ '400' /* entradas*/ no-undo.
def var cUserNDD as char initial 'Nissei' no-undo.
def var cPwdNDD as char initial 'Nissei2015' no-undo.
def var cChildren as longchar no-undo.
def var l-log as logical no-undo initial yes.
def var l-connected as logical no-undo.
def var l-aux as logical no-undo.
def var i-aux as integer no-undo.

define temp-table tt-NDD_ENTRYINTEGRATION no-undo like NDD_ENTRYINTEGRATION
    field retOk as char label "Leitura OK"
    field int500 as char label "INT500" format "X(3)"
    field processado as char label "Proc" format "X(3)".

define stream str-log.

def var c-job-ndd as char no-undo.
def var i-job-ndd as int no-undo.

for first int_ndd_param no-lock:
    if opsys = "Unix" then do:
        cCaminhoNDD = int_ndd_param.caminho_unix. 
        if trim(substring(cCaminhoNDD,length(cCaminhoNDD),1)) <> "/" then
            cCaminhoNDD = cCaminhoNDD + "/".
    end.
    else do:
        cCaminhoNDD = int_ndd_param.caminho.
        if trim(substring(cCaminhoNDD,length(cCaminhoNDD),1)) <> "~\" then
            cCaminhoNDD = cCaminhoNDD + "~\".
    end.
    cColdID     = int_ndd_param.conexaodi.
    cUserNDD    = int_ndd_param.usuario.
    cPwdNDD     = int_ndd_param.senha.
    l-log       = int_ndd_param.gerarlog.
end.
if opsys = "Unix" then do:
    cCaminhoTMP = session:temp-directory.
    if trim(substring(cCaminhoTMP,length(cCaminhoTMP),1)) <> "/" then
        cCaminhoTMP = cCaminhoTMP + "/".
end.
else do:
    cCaminhoTMP = session:temp-directory.
    if trim(substring(cCaminhoTMP,length(cCaminhoTMP),1)) <> "~\" then
        cCaminhoTMP = cCaminhoTMP + "~\".
end.

assign i-job-ndd = 0.
if dbname matches "*producao*" then
   assign i-job-ndd = 1.
else if dbname matches "*homologacao*" then
   assign i-job-ndd = 2.
else if dbname matches "*teste*" then
   assign i-job-ndd = 3.
else do:
    /* assume ambiente do estabelecimento 973 */
    for first estabelec fields (&if "{&BF_DIS_VERSAO_EMS}" >= "2.07" &then
                                   estabelec.idi-tip-emis-nf-eletro
                                &else
                                   estabelec.char-1
                                &endif)
        no-lock where estabelec.cod-estabel = "973":
        assign i-job-ndd = 
            (if &if "{&BF_DIS_VERSAO_EMS}" >= "2.07" &then
                   estabelec.idi-tip-emis-nf-eletro    = 3
                &else
                   int(substr(estabelec.char-1,168,1)) = 3  
                &endif
             then 1  /* Produá∆o    */
             else 2) /* Homologaá∆o */ .
    end.
end.

DEFINE TEMP-TABLE ttStack NO-UNDO
     FIELD ttID AS INTEGER
     FIELD ttPos AS INTEGER
     INDEX tt_id IS PRIMARY UNIQUE
           ttID  ASCENDING.

define buffer bint_ndd_envio for int_ndd_envio.
define buffer bint_ndd_retorno for int_ndd_retorno.
define buffer bnota-fiscal for nota-fiscal.

FUNCTION addStack RETURN INTEGER (INPUT val AS INTEGER).
     DEFINE VAR id AS INTEGER INITIAL 1 NO-UNDO.
     FIND LAST ttStack NO-ERROR.
     IF AVAIL(ttStack) THEN
          id = ttStack.ttID + 1.

     CREATE ttStack.
     ASSIGN ttStack.ttID = id.
     ASSIGN ttStack.ttPos = val.
END FUNCTION.


FUNCTION delStack RETURN INTEGER.
     FIND LAST ttStack NO-ERROR.
     IF AVAIL(ttStack) THEN
          DELETE ttStack.

     FIND LAST ttStack NO-ERROR.
END FUNCTION.



function findTag returns longchar
    (pSource as longchar, pTag as char, pStart as int64):

    def var cTagIni as char no-undo.
    def var cTagFim as char no-undo.

    if length(trim(pSource)) > 0 and length(trim(pTag)) > 0 and pStart >= 1 then do:
        assign  cTagIni = '<'  + trim(pTag) + '>'
                cTagFim = '</' + trim(pTag) + '>'.

        return trim(substring(pSource,
                              index(pSource,cTagIni,pStart) + length(cTagIni), 
                              index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) 
                              ) 
                    ).
    end.
    return "".
end.

FUNCTION getStack RETURN INTEGER.
     IF AVAIL(ttStack) THEN
          RETURN ttStack.ttPos.
     ELSE
          RETURN 0.
END FUNCTION.


function OnlyNumbers returns char
    (p-char as char):

    def var i-ind as integer no-undo.
    def var c-aux as char no-undo.
    do i-ind = 1 to length (p-char):
        if lookup (substring(p-char,i-ind,1),"1,2,3,4,5,6,7,8,9,0") > 0 then
            assign c-aux = c-aux + substring(p-char,i-ind,1).
    end.
    if c-aux <> ? then return c-aux. else return "".
end.

function PrintChar returns longchar
    (input pc-string as longchar):

    /* necess†rio para que a funá∆o seja case-sensitive */
    define variable c-string as longchar case-sensitive no-undo.
    define variable i-ind as integer no-undo.

    assign c-string = pc-string.

    assign c-string = replace(c-string,"†","a").
    assign c-string = replace(c-string,"Ö","a").
    assign c-string = replace(c-string,"∆","a").
    assign c-string = replace(c-string,"É","a").
    assign c-string = replace(c-string,"Ñ","a").

    assign c-string = replace(c-string,"Ç","e").
    assign c-string = replace(c-string,"ä","e").
    assign c-string = replace(c-string,"à","e").
    assign c-string = replace(c-string,"â","e").

    assign c-string = replace(c-string,"°","i").
    assign c-string = replace(c-string,"ç","i").
    assign c-string = replace(c-string,"å","i").
    assign c-string = replace(c-string,"ã","i").

    assign c-string = replace(c-string,"¢","o").
    assign c-string = replace(c-string,"ï","o").
    assign c-string = replace(c-string,"ì","o").
    assign c-string = replace(c-string,"î","o").
    assign c-string = replace(c-string,"‰","o").

    assign c-string = replace(c-string,"£","u").
    assign c-string = replace(c-string,"ó","u").
    assign c-string = replace(c-string,"ñ","u").
    assign c-string = replace(c-string,"Å","u").

    assign c-string = replace(c-string,"á","c").
    assign c-string = replace(c-string,"§","n").

    assign c-string = replace(c-string,"Ï","y").
    assign c-string = replace(c-string,"ò","y").

    assign c-string = replace(c-string,"µ","A").
    assign c-string = replace(c-string,"∑","A").
    assign c-string = replace(c-string,"«","A").
    assign c-string = replace(c-string,"∂","A").
    assign c-string = replace(c-string,"é","A").

    assign c-string = replace(c-string,"ê","E").
    assign c-string = replace(c-string,"‘","E").
    assign c-string = replace(c-string,"“","E").
    assign c-string = replace(c-string,"”","E").

    assign c-string = replace(c-string,"÷","I").
    assign c-string = replace(c-string,"ﬁ","I").
    assign c-string = replace(c-string,"◊","I").
    assign c-string = replace(c-string,"ÿ","I").

    assign c-string = replace(c-string,"‡","O").
    assign c-string = replace(c-string,"„","O").
    assign c-string = replace(c-string,"‚","O").
    assign c-string = replace(c-string,"ô","O").
    assign c-string = replace(c-string,"Â","O").

    assign c-string = replace(c-string,"È","U").
    assign c-string = replace(c-string,"Î","U").
    assign c-string = replace(c-string,"Í","U").
    assign c-string = replace(c-string,"ö","U").

    assign c-string = replace(c-string,"Ä","C").
    assign c-string = replace(c-string,"•","N").
                                        
    assign c-string = replace(c-string,"Ì","Y").

    assign c-string = replace(c-string,CHR(13),"").
    assign c-string = replace(c-string,CHR(10),"").

    assign c-string = replace(c-string,"˚","").
    assign c-string = replace(c-string,"≠","").
    assign c-string = replace(c-string,"˝","2").
    assign c-string = replace(c-string,"¸","3").
    assign c-string = replace(c-string,"œ","o").
    assign c-string = replace(c-string,"∞","E").
    assign c-string = replace(c-string,"¨","1/4").
    assign c-string = replace(c-string,"´","1/2").
    assign c-string = replace(c-string,"Û","3/4").
    assign c-string = replace(c-string,"æ","Y").
    assign c-string = replace(c-string,"û","x").
    assign c-string = replace(c-string,"Á","p").
    assign c-string = replace(c-string,"©","r").
    assign c-string = replace(c-string,"Ü","a").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"–","y").
    assign c-string = replace(c-string,"õ","o").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ë","ae").
    assign c-string = replace(c-string,"Ê","u").
    assign c-string = replace(c-string,"®","").
    assign c-string = replace(c-string,"∫","").
    assign c-string = replace(c-string,"ı","").
    assign c-string = replace(c-string,"è","A").
    assign c-string = replace(c-string,"©","").
    assign c-string = replace(c-string,"Ë","p").
    assign c-string = replace(c-string,"Æ","-").
    assign c-string = replace(c-string,"Ø","-").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ù","0").
    assign c-string = replace(c-string,"—","D").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"í","").
    assign c-string = replace(c-string,"∏","").
    assign c-string = replace(c-string,"ú","").
    assign c-string = replace(c-string,"ı","").

    assign c-string = replace(c-string,"ˆ","").
    assign c-string = replace(c-string,"›","").
    assign c-string = replace(c-string,"¯","o").
    assign c-string = replace(c-string,"Ω","c").

    do i-ind = 1 to 31:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 127 to 144:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 147 to 159:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 162 to 182:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 184 to 191:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 215 to 216:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 248 to 248:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.

    assign c-string = trim(c-string).

    if c-string = ? then return "". else return c-string.

end function.

PROCEDURE InserirDocumento:
  DEFINE INPUT PARAMETER header1 AS LONGCHAR NO-UNDO.
  DEFINE INPUT PARAMETER document AS LONGCHAR NO-UNDO.
  DEFINE OUTPUT PARAMETER eDocumentResult AS LONGCHAR NO-UNDO.
END PROCEDURE.

PROCEDURE ConsultarStatus:
  DEFINE INPUT PARAMETER xml AS LONGCHAR NO-UNDO.
  DEFINE OUTPUT PARAMETER ConsultarStatusResult AS LONGCHAR NO-UNDO.
END PROCEDURE.

PROCEDURE ConsultarProtocolo:
  DEFINE INPUT PARAMETER xml AS LONGCHAR NO-UNDO.
  DEFINE OUTPUT PARAMETER ConsultarProtocoloResult AS LONGCHAR NO-UNDO.
END PROCEDURE.

PROCEDURE ConsultarDFeInterno:
  DEFINE INPUT PARAMETER xml AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER ConsultarDFeInternoResult AS CHARACTER NO-UNDO.
END PROCEDURE.

PROCEDURE ConsultarDocumento:
  DEFINE INPUT PARAMETER xml AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER ConsultarDocumentoResult AS CHARACTER NO-UNDO.
END PROCEDURE.

procedure pi-geraHeaderInserirDocumentoNDD:
    define input parameter cTipoServico as char no-undo.
    /*
    1 = Emiss∆o - Inserá∆o de documento;
    2 = Emiss∆o - Inserá∆o de Cancelamento;
    3 = Emiss∆o - Inserá∆o de Inutilizaá∆o;
    4 = Emiss∆o - Inserá∆o de Cancelamento /Inutilizaá∆o;
    5 = Emiss∆o - Inserá∆o de Impress∆o comandada;
    6 = Emiss∆o - Inserá∆o de Eventos;
    9 = Recepá∆o - Inserá∆o de documento / Eventos.
    */

    define output parameter cHeader as longchar no-undo.
    
    /* SETA VALOR DE ENCODING */
    RUN setEncoding IN hGenXml ("" /*"UTF-8"*/).
    
    RUN reset IN hGenXML.
    
    RUN addNode IN hGenXml (getStack(), "eformsInserir", "", OUTPUT iId).
    addStack(iId).
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsd", "http://www.w3.org/2001/XMLSchema").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns", "http://www.nddigital.com.br/connector").
        RUN addNode IN hGenXml (getStack(), "versao", "1.00", OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "tipodocumento", "1", OUTPUT iId). /* 1=XML */
        RUN addNode IN hGenXml (getStack(), "tiposervico", cTipoServico, OUTPUT iId). 
        RUN addNode IN hGenXml (getStack(), "identificador", c-job-ndd, OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "validarschema", "2", OUTPUT iId).
        /*
        RUN addNode IN hGenXml (getStack(), "cnpj", trim(substring(&if "{&bf_dis_versao_ems}" < "2.07" &then       
                                                                       trim(substring(nota-fiscal.char-2,3,44))    
                                                                   &elseif "{&bf_dis_versao_ems}" >= "2.07" &then  
                                                                       nota-fiscal.cod-chave-aces-nf-eletro        
                                                                   &endif
                                                                   ,7,14)), OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "numero", trim(substring(&if "{&bf_dis_versao_ems}" < "2.07" &then        
                                                                         trim(substring(nota-fiscal.char-2,3,44))     
                                                                     &elseif "{&bf_dis_versao_ems}" >= "2.07" &then   
                                                                         nota-fiscal.cod-chave-aces-nf-eletro         
                                                                     &endif                                           
                                                                     ,26,9)), OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "serie", trim(substring(&if "{&bf_dis_versao_ems}" < "2.07" &then        
                                                                         trim(substring(nota-fiscal.char-2,3,44))     
                                                                     &elseif "{&bf_dis_versao_ems}" >= "2.07" &then   
                                                                         nota-fiscal.cod-chave-aces-nf-eletro         
                                                                     &endif                                           
                                                                     ,23,3)), OUTPUT iId).
                                                                     */
    delStack().
    
    empty temp-table ttStack.
    
    /* OBTEM O XML NUMA HANDLE */
    RUN generateXML IN hGenXml (OUTPUT hXML).
    hXML:SAVE("longchar",cHeader). 

    delete object hXML.

end.

procedure pi-geraHeaderConsultarProtocoloNDD:
    define input parameter cProtocolo as char no-undo.
    define output parameter cHeader as longchar no-undo.
    
    /* SETA VALOR DE ENCODING */
    RUN setEncoding IN hGenXml ("" /*"UTF-8"*/).    

    RUN reset IN hGenXML.
    
    RUN addNode IN hGenXml (getStack(), "eformsConsultarProtocolo", "", OUTPUT iId).
    addStack(iId).
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsd", "http://www.w3.org/2001/XMLSchema").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns", "http://www.nddigital.com.br/connector").
        RUN addNode IN hGenXml (getStack(), "versao", "1.00", OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "listaconsulta", "", OUTPUT iId).
        addStack(iId).
            RUN addNode IN hGenXml (getStack(), "consulta", "", OUTPUT iId).
            addStack(iId).
                RUN addNode IN hGenXml (getStack(), "protocolo", cProtocolo, OUTPUT iId).
    delStack().
    
    empty temp-table ttStack.
    
    /* OBTEM O XML NUMA HANDLE */
    RUN generateXML IN hGenXml (OUTPUT hXML).
    hXML:SAVE("longchar",cHeader). 

    delete object hXML.
end.

procedure pi-geraHeaderConsultarStatusNDD:
    define input parameter cChave as char no-undo.
    define output parameter cHeader as longchar no-undo.
    
    /* SETA VALOR DE ENCODING */
    RUN setEncoding IN hGenXml ("" /*"UTF-8"*/).

    RUN reset IN hGenXML.
    
    RUN addNode IN hGenXml (getStack(), "eformsConsultarStatus", "", OUTPUT iId).
    addStack(iId).
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsd", "http://www.w3.org/2001/XMLSchema").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns", "http://www.nddigital.com.br/connector").
        RUN addNode IN hGenXml (getStack(), "versao", "1.00", OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "listaconsulta", "", OUTPUT iId).
        addStack(iId).
            RUN addNode IN hGenXml (getStack(), "consulta", "", OUTPUT iId).
            addStack(iId).
                RUN addNode IN hGenXml (getStack(), "chaveprotocolo", "", OUTPUT iId).
                addStack(iId).
                    RUN addNode IN hGenXml (getStack(), "chaveacesso", cChave, OUTPUT iId).
    delStack().
    
    empty temp-table ttStack.
    
    /* OBTEM O XML NUMA HANDLE */
    RUN generateXML IN hGenXml (OUTPUT hXML).
    hXML:SAVE("longchar",cHeader). 

    delete object hXML.
end.

procedure pi-GeraHeaderConsultarColdDFe:
    define input parameter cCNPJ as char no-undo.
    define output parameter cHeader as longchar no-undo.

    def var cDataAux as char no-undo.
    if today - 30 >= 11/14/2018 then 
        assign  cDataAux = string(today - 30,"99/99/9999").
    else
        assign  cDataAux = string(11/14/2018,"99/99/9999").

    /*assign  cDataAux = substring(cDataAux,4,2) + "/" + substring(cDataAux,1,2) + "/" + substring(cDataAux,7,4).*/

    /* SETA VALOR DE ENCODING */
    RUN setEncoding IN hGenXml ("" /*"UTF-8"*/).

    RUN reset IN hGenXML.

    RUN addNode IN hGenXml (getStack(), "eformsConsultaColdDFe", "", OUTPUT iId).
    addStack(iId).
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsd", "http://www.w3.org/2001/XMLSchema").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns", "http://www.nddigital.com.br/connector").
        RUN addNode IN hGenXml (getStack(), "coldID", cColdID, OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "cnpj", cCNPJ, OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "dataInicial", cDataAux, OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "modelo", "1", OUTPUT iId).
    delStack().

    empty temp-table ttStack.

    /* OBTEM O XML NUMA HANDLE */
    RUN generateXML IN hGenXml (OUTPUT hXML).
    hXML:SAVE("longchar",cHeader). 

    delete object hXML.
end.

procedure pi-GeraHeaderConsultarColdSincrono:
    define input parameter cChaveNFe as char no-undo.
    define output parameter cHeader as longchar no-undo.

    /* SETA VALOR DE ENCODING */
    RUN setEncoding IN hGenXml ("" /*"UTF-8"*/).

    RUN reset IN hGenXML.

    RUN addNode IN hGenXml (getStack(), "eformsConsultarColdChaveAcesso", "", OUTPUT iId).
    addStack(iId).
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsd", "http://www.w3.org/2001/XMLSchema").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns", "http://www.nddigital.com.br/connector").
        RUN addNode IN hGenXml (getStack(), "versao", "4.00", OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "autenticacao", "", OUTPUT iId).
        addStack(iId).
            RUN addNode IN hGenXml (getStack(), "usuario", cUserNDD, OUTPUT iId).
            RUN addNode IN hGenXml (getStack(), "senha", cPwdNDD, OUTPUT iId).
            RUN addNode IN hGenXml (getStack(), "conexaoid", cColdID, OUTPUT iId).
        delStack().
        RUN addNode IN hGenXml (getStack(), "listaconexoescold", "", OUTPUT iId).
        addStack(iId).
            RUN addNode IN hGenXml (getStack(), "autenticacaocold", "", OUTPUT iId).
            addStack(iId).
                RUN addNode IN hGenXml (getStack(), "usuario", cUserNDD, OUTPUT iId).
                RUN addNode IN hGenXml (getStack(), "senha", cPwdNDD, OUTPUT iId).
                RUN addNode IN hGenXml (getStack(), "conexaoid", cColdID, OUTPUT iId).
            delStack().
        delStack().
        RUN addNode IN hGenXml (getStack(), "tiposervico", 2 /* XML do Documento */, OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "chaveacesso", cChaveNFe, OUTPUT iId).
    delStack().
    empty temp-table ttStack.

    /* OBTEM O XML NUMA HANDLE */
    RUN generateXML IN hGenXml (OUTPUT hXML).
    hXML:SAVE("longchar",cHeader). 

    delete object hXML.
end.

procedure pi-conectaWebServer:
    define input parameter pWSDL as char no-undo.
    define input parameter pServico as char no-undo.
    define input parameter pEstabel as char no-undo.
    define output parameter l-connected as logical no-undo.

    if l-connected then run pi-desConectaWebServer.

    create server hWebService.
    hWebService:connect("-WSDL " + cCaminhoNDD + (if pEstabel = "973" then "wsdl/CD/" else "wsdl/LOJA/") 
                        + pWSDL + " -Service " + pServico + " -nohostverify"
                         ).
    /*
    " -sslSOAPProtocols TLSv1.2,TLSv1" + 
    " -sslSOAPCiphers AES128-SHA,AES128-SHA256"    
    
    " -sslprotocols TLSv1 -sslciphers AES128-SHA "*/
    
    /* -sslprotocols TLSv1 -sslciphers  -sslprotocols TLSv1.1
    -Port WSInserirDocumentoSoap RC4-MD5
    -TargetNamespace http://nddigital.com.br/eForms/webservices
    -ServiceNamespace http://nddigital.com.br/eForms/webservices 
    " -sslprotocols TLSv1 -sslciphers AES128-SHA" +     
    */

    l-connected = hWebService:connected().
end.

procedure pi-limpaObjetos:
    /*if valid-handle(hGenXML) then delete object hGenXML no-error.*/
    run pi-desConectaWebServer.
end procedure.

procedure pi-desConectaWebServer:
    /* Limpar Objetos */
    hWebService:disconnect() no-error.
    l-connected = no.
    if valid-handle(hWebService) then delete object hWebService no-error.
    if valid-handle(hWSPortaSoap) then delete object hWSPortaSoap no-error.
end procedure.

procedure pi-cria-ret-nf-eletro:
    define input parameter pcod-estabel as char no-undo.
    define input parameter pserie       as char no-undo.
    define input parameter pnr-nota-fis as char no-undo.
    define input parameter pnProt       as char no-undo.

    for last ret-nf-eletro exclusive-lock where 
        ret-nf-eletro.cod-estabel = pcod-estabel and 
        ret-nf-eletro.cod-serie   = pserie       and 
        ret-nf-eletro.nr-nota-fis = pnr-nota-fis and 
        ret-nf-eletro.cod-msg     = cCodigoErro  and 
        ret-nf-eletro.dat-ret     = today        /*and
        ret-nf-eletro.cod-livre-2 = cMensagem*/
        query-tuning(no-lookahead): end.
    if not avail ret-nf-eletro then do:
        create  ret-nf-eletro.
        assign  ret-nf-eletro.cod-estabel = pcod-estabel
                ret-nf-eletro.cod-serie   = pserie
                ret-nf-eletro.nr-nota-fis = pnr-nota-fis
                ret-nf-eletro.dat-ret     = today
                ret-nf-eletro.cod-msg     = cCodigoErro.
    end.
    assign  ret-nf-eletro.hra-ret     = replace(string(time, "HH:MM:SS"),":","")
            ret-nf-eletro.cod-livre-2 = "Web NDD-" + cMensagem
            ret-nf-eletro.log-ativo   = yes.
    &if "{&bf_dis_versao_ems}" >= "2.07" &then 
        ret-nf-eletro.cod-protoc  = pnProt.
    &else
        ret-nf-eletro.cod-livre-1 = pnProt.
    &endif

    release ret-nf-eletro.
end.

procedure pi-consultarProtocolo:

    run pi-desConectaWebServer.
    run pi-geraHeaderConsultarProtocoloNDD (string(int_ndd_envio.protocolo), output cHeader).

    if l-log then do:
        cFile = cCaminhoTMP + c-seg-usuario + "_" + "formsConsultarProtocoloHeader" + "_" + string(today,"99-99-9999") + replace(string(time,"HH:MM:SS"),':','_') + ".xml".
        copy-lob cHeader to FILE cFile.
    end.

    /* envio p/ WebService */
    run pi-conectaWebServer (input 'WSConsultarProtocolo.wsdl',
                             input 'WSConsultarProtocolo',
                             input int_ndd_envio.cod_estabel,
                             output l-connected).

    if l-connected then do:
        run WSConsultarProtocoloSoap set hWSPortaSoap on hWebService.
        run ConsultarProtocolo  in hWSPortaSoap(input  cHeader, 
                                                output cReturnValue).


        if l-log then do:
            cFile = cCaminhoTMP + c-seg-usuario + "_" + "eformsConsultarProtocoloRetorno" + "_" + string(today,"99-99-9999") + replace(string(time,"HH:MM:SS"),':','_') + ".xml".
            copy-lob cReturnValue to FILE cFile.
        end.

        cMensagem = "".
        cCodigoErro = "".
        /* Trata Retorno do WebService */
        run reset in hGenXML.
        run loadXMLFromLongChar in hGenXML (cReturnValue).
        run loadValue in hGenXML ("codigo", 9, output cCodigoErro).
        cCodigoErro = OnlyNumbers(cCodigoErro).
        run loadValue in hGenXML ("mensagem", 9, output cMensagem).
        cMensagem = PrintChar(cMensagem).
        run loadValue in hGenXML ("chaveacesso", 12, output cChaveAcesso).
        cChaveAcesso = PrintChar(cChaveAcesso).

        /* protocolo inserido com sucesso */
        if cCodigoErro = "010" then do: 
            assign int_ndd_envio.STATUSNUMBER = 1.

            /* Traca de Chave por envio EPEC */
            if  cChaveAcesso <> "" and length(cChaveAcesso) = 44 and
                cChaveAcesso <> (&if "{&bf_dis_versao_ems}" < "2.07" &then       
                                    trim(substring(nota-fiscal.char-2,3,44))    
                                &elseif "{&bf_dis_versao_ems}" >= "2.07" &then  
                                    trim(nota-fiscal.cod-chave-aces-nf-eletro)
                                &endif) then do:
                for each bnota-fiscal exclusive-lock where 
                    rowid(bnota-fiscal) = rowid(nota-fiscal):
                    assign  &if "{&bf_dis_versao_ems}" < "2.07" &then       
                                    overlay(bnota-fiscal.char-2,3,44)
                            &elseif "{&bf_dis_versao_ems}" >= "2.07" &then  
                                    bnota-fiscal.cod-chave-aces-nf-eletro &endif = cChaveAcesso.
                    if nota-fiscal.ind-tip-nota = 8 then do:
                        for each docum-est where 
                            docum-est.serie-docto  = nota-fiscal.serie and
                            docum-est.nro-docto    = nota-fiscal.nr-nota-fis and
                            docum-est.cod-emitente = nota-fiscal.cod-emitente and
                            docum-est.nat-operacao = nota-fiscal.nat-operacao
                            query-tuning(no-lookahead): 
                            assign  &if '{&bf_dis_versao_ems}' >= '2.07':U &then 
                                        docum-est.cod-chave-aces-nf-eletro 
                                    &else overlay(docum-est.char-1,93,60) &endif = cChaveAcesso.
                        end.
                    end.
                end.
            end.
        end.
        /* protocolo inserido com erro */
        else do:
            run loadValue in hGenXML ("codigo", 14, output cReturnValue) .
            if string(cReturnValue) <> ? then 
                cCodigoErro = OnlyNumbers(string(cReturnValue)).
            run loadValue in hGenXML ("mensagem", 14, output cReturnValue) .
            if string(cReturnValue) <> ? then
                cMensagem = PrintChar(string(cReturnValue)).
        end.
        if cCodigoErro <> ? and cMensagem <> ? then do:
            run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                       nota-fiscal.serie,
                                       nota-fiscal.nr-nota-fis,
                                       "000000000000000").
        end.
    end. /* conected */
    else do:
        cCodigoErro = '9999'. cMensagem = "WebService NDD n∆o conectado".
        run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                   nota-fiscal.serie,
                                   nota-fiscal.nr-nota-fis,
                                   "000000000000000").
    end.

end procedure.


procedure pi-consultarStatus:

    run pi-desConectaWebServer.
    run pi-geraHeaderConsultarStatusNDD (string( /* chNFe */
                                        &if "{&bf_dis_versao_ems}" < "2.07" &then       
                                           trim(substring(nota-fiscal.char-2,3,44))    
                                        &elseif "{&bf_dis_versao_ems}" >= "2.07" &then  
                                           trim(nota-fiscal.cod-chave-aces-nf-eletro)
                                        &endif), 
                                        output cHeader).

    if l-log then do:
        cFile = cCaminhoTMP + c-seg-usuario + "_" + "eformsConsultarStatusHeader" + "_" + string(today,"99-99-9999") + replace(string(time,"HH:MM:SS"),':','_') + ".xml".
        copy-lob cHeader to FILE cFile.
    end.

    /* envio p/ WebService */
    run pi-conectaWebServer (input 'WSConsultarStatus.wsdl',
                             input 'WSConsultarStatus',
                             input nota-fiscal.cod-estabel,
                             output l-connected).

    if l-connected then do:
        run WSConsultarStatusSoap set hWSPortaSoap on hWebService.
        run ConsultarStatus  in hWSPortaSoap(input  cHeader, 
                                             output cReturnValue).


        if l-log then do:
            cFile = cCaminhoTMP + c-seg-usuario + "_" + "eformsConsultarStatusRetorno" + "_" + string(today,"99-99-9999") + replace(string(time,"HH:MM:SS"),':','_') + ".xml".
            copy-lob cReturnValue to FILE cFile.
        end.

        cMensagem = "".
        cCodigoErro = "".
        cProtocolo = "".
        cData = "".
        /* Trata Retorno do WebService */
        run reset in hGenXML.
        run loadXMLFromLongChar in hGenXML (cReturnValue).
        do iId = 1 to 9:
            if cCodigoErro = "" or cCodigoErro = ? then do:
                run loadValue in hGenXML ("codigo", iId, output cCodigoErro).
                cCodigoErro = OnlyNumbers(cCodigoErro).
            end.
            if cMensagem = "" or cMensagem = ? then do:
                run loadValue in hGenXML ("mensagem", iId, output cMensagem).
                cMensagem = PrintChar(cMensagem).
            end.
        end.

        /* Status consultado com sucesso */
        if cCodigoErro = "000" /*and cProtocolo <> ? and cProtocolo <> ""*/ then do: 

            cCodigoErro = "".
            cMensagem = "".
            do iId = 10 to 20:
                if cCodigoErro = "" or cCodigoErro = ? then do:
                    run loadValue in hGenXML ("codigo", iId, output cCodigoErro).
                    cCodigoErro = OnlyNumbers(cCodigoErro).
                end.
                if cMensagem = "" or cMensagem = ? then do:
                    run loadValue in hGenXML ("mensagem", iId, output cMensagem).
                    cMensagem = PrintChar(cMensagem).
                end.
                if cProtocolo = "" or cProtocolo = ? then do:
                    run loadValue in hGenXML ("protocolosefaz", iId, output cProtocolo) .
                    cProtocolo = OnlyNumbers(cProtocolo).
                end.
                if cData = "" or cData = ? then do:
                    run loadValue in hGenXML ("datahora", iId, output cData) .
                    cData = PrintChar(cData).
                end.
            end.

            /* criar int_ndd_retorno com as strings diferenciadas pelo kind de envio */
            for first int_ndd_retorno exclusive where 
                int_ndd_retorno.cod_estabel = int_ndd_envio.cod_estabel and
                int_ndd_retorno.serie       = int_ndd_envio.serie       and
                int_ndd_retorno.nr_nota_fis = int_ndd_envio.nr_nota_fis and
                int_ndd_retorno.protocolo   = int_ndd_envio.protocolo:  end.
            if not avail int_ndd_retorno then do:
                iId = next-value(seq-int-ndd-retorno).
                create  int_ndd_retorno.
                assign  int_ndd_retorno.id          = iId
                        int_ndd_retorno.statusnumb  = 0
                        int_ndd_retorno.cod_estabel = int_ndd_envio.cod_estabel 
                        int_ndd_retorno.serie       = int_ndd_envio.serie 
                        int_ndd_retorno.nr_nota_fis = int_ndd_envio.nr_nota_fis 
                        int_ndd_retorno.protocolo   = int_ndd_envio.protocolo.
            end.
            assign  int_ndd_retorno.documentuser = int_ndd_envio.documentuser
                    int_ndd_retorno.job          = int_ndd_envio.job.

            find estabelec no-lock of nota-fiscal no-error.

            case int_ndd_envio.kind:
                when 1 then do:
                    assign int_ndd_retorno.KIND = 0 /* emiss∆o */.
                    assign cReturnValue =  
                                        /* infProt */
                                        trim(int_ndd_envio.protocolo) 
                                        + ";" +
                                        /* tpAmb */
                                       (if &if "{&BF_DIS_VERSAO_EMS}" >= "2.07" &then
                                              estabelec.idi-tip-emis-nf-eletro    = 3
                                           &else
                                              int(substr(estabelec.char-1,168,1)) = 3  
                                           &endif
                                        then "1"  /* Produá∆o    */
                                        else "2") /* Homologaá∆o */ 
                                        + ";" +
                                        /* verAplic */
                                        &if"{&bf_dis_versao_ems}" >= "2.071" &then
                                           trim(estabelec.des-vers-layout)
                                        &else
                                           trim(substr(estabelec.char-1,173,10))
                                        &endif 
                                        + ";" +

                                        /* chNFe */
                                        &if "{&bf_dis_versao_ems}" < "2.07" &then       
                                           trim(substring(nota-fiscal.char-2,3,44))    
                                        &elseif "{&bf_dis_versao_ems}" >= "2.07" &then  
                                           trim(nota-fiscal.cod-chave-aces-nf-eletro)
                                        &endif 
                                        + ";" +

                                        /* dhRecbto */
                                        cData + ";" +
                                        /* nProt */
                                        cProtocolo + ";" +
                                        /* digVal */
                                        ";" +
                                        /* cStat */
                                        cCodigoErro + ";" +
                                        /* xMotivo */
                                        cMensagem + ";" +
                                        /* tpEmis */
                                        (&if "{&bf_dis_versao_ems}" < "2.07" &then 
                                            if int(substr(nota-fiscal.char-2,65,2)) > 0 then
                                                trim(string(int(substr(nota-fiscal.char-2,65,2))))
                                            else ""
                                        &elseif "{&bf_dis_versao_ems}" >= "2.07" &then
                                            if int(nota-fiscal.idi-forma-emis-nf-eletro) > 0 then
                                                trim(string(int(nota-fiscal.idi-forma-emis-nf-eletro)))
                                            else ""
                                        &endif)
                                        + ";" +
                                        /* chNFe2 */ 
                                        ";".
                end.
                when 2 then do:
                    assign int_ndd_retorno.KIND = 1 /* cancelamento */.
                    assign cReturnValue = 
                                        /* Id */
                                        trim(string(iId)) + ";" +
                                        /* cStat */
                                        cCodigoErro + ";" +
                                        /* xMotivo */
                                        cMensagem + ";" +
                                        /* chNFe */
                                        &if "{&bf_dis_versao_ems}" < "2.07" &then       
                                           trim(substring(nota-fiscal.char-2,3,44))    
                                        &elseif "{&bf_dis_versao_ems}" >= "2.07" &then  
                                           trim(nota-fiscal.cod-chave-aces-nf-eletro)
                                        &endif + ";" +
                                        /* dhRecbto */
                                        cData + ";" +
                                        /* nProt */
                                        cProtocolo + ";" +
                                        /* chNFe2 */
                                        ";".
                end.
                when 3 then do:
                    find natur-oper no-lock where natur-oper.nat-operacao = nota-fiscal.nat-operacao.
                    assign int_ndd_retorno.KIND = 2 /* inutilizaá∆o */.
                    assign cReturnValue = 
                                        /* Id */
                                        trim(string(iId)) + ";" +                        
                                        /* tpAmb */
                                       (if &if "{&BF_DIS_VERSAO_EMS}" >= "2.07" &then
                                              estabelec.idi-tip-emis-nf-eletro    = 3
                                           &else
                                              int(substr(estabelec.char-1,168,1)) = 3  
                                           &endif
                                        then "1"  /* Produá∆o    */
                                        else "2") /* Homologaá∆o */ + ";" +
                                        /* verAplic */
                                        &if"{&bf_dis_versao_ems}" >= "2.071" &then
                                           trim(estabelec.des-vers-layout)
                                        &else
                                           trim(substr(estabelec.char-1,173,10))
                                        &endif + ";" +
                                        /* cStat */
                                        cCodigoErro + ";" +
                                        /* xMotivo */
                                        cMensagem + ";" +
                                        /* cUF       */
                                        estabelec.estado + ";" +
                                        /* ano       */
                                        trim(substring(string(nota-fiscal.dt-emis-nota, "99/99/9999"), 7,2)) + ";" +
                                        /* CNPJ      */
                                        estabelec.cgc + ";" +
                                        /* modelo    */
                                        &if '{&bf_dis_versao_ems}' >= '2.07' &then 
                                            natur-oper.cod-model-nf-eletro 
                                        &ELSE
                                            substring(natur-oper.char-2,120,2) 
                                        &endif + ";" +                               
                                        /* serie     */
                                        nota-fiscal.serie + ";" +
                                        /* nNFIni    */
                                        nota-fiscal.nr-nota-fis + ";" +
                                        /* nNFFin    */
                                        nota-fiscal.nr-nota-fis + ";" +
                                        /* dhRecbto  */
                                        cData + ";" +
                                        /* nProt     */
                                        cProtocolo
                                        + ";".
                end.
                when 6 then do:
                    assign int_ndd_retorno.KIND = 7 /* Evento Carta Correá∆o */.
                    assign cReturnValue = 
                                        /*infEvento */ 
                                        "Carta Correcao" + ";" +
                                        /* tpAmb */
                                       (if &if "{&BF_DIS_VERSAO_EMS}" >= "2.07" &then
                                              estabelec.idi-tip-emis-nf-eletro    = 3
                                           &else
                                              int(substr(estabelec.char-1,168,1)) = 3  
                                           &endif
                                        then "1"  /* Produá∆o    */
                                        else "2") /* Homologaá∆o */ + ";" +
                                        /* verAplic */
                                        &if"{&bf_dis_versao_ems}" >= "2.071" &then
                                           trim(estabelec.des-vers-layout)
                                        &else
                                           trim(substr(estabelec.char-1,173,10))
                                        &endif + ";" +
                                        /*cOrgao    */
                                        "" + ";" +
                                        /*cStat     */
                                        cCodigoErro + ";" +
                                        /* xMotivo */
                                        cMensagem + ";" +
                                        /* chNFe */
                                        &if "{&bf_dis_versao_ems}" < "2.07" &then       
                                           trim(substring(nota-fiscal.char-2,3,44))    
                                        &elseif "{&bf_dis_versao_ems}" >= "2.07" &then  
                                           trim(nota-fiscal.cod-chave-aces-nf-eletro)
                                        &endif + ";" +
                                        /*tpEvento  */
                                        "7" + ";" +
                                        /*xEvento   */
                                        "Carta de Correcao" + ";" +
                                        /*nseqEvento*/
                                        "1" + ";" +
                                        /*CNPJDest  */
                                        "" + ";" +
                                        /*emailDest */
                                        "" + ";" +
                                        /*dhRegEvento*/
                                        cData + ";" +
                                        /*nProt     */ 
                                        cProtocolo 
                                        + ";".
                end.
            end case.
            copy-lob cReturnValue to int_ndd_retorno.DOCUMENTDATA.
            assign int_ndd_envio.STATUSNUMBER = 2. /* marcando para n∆o processar no int022a */
        end.
        /* Status consultado com erro */
        else do:
            /*
            do iId = 10 to 20:
                if cCodigoErro = "" or cCodigoErro = ? then do:
                    run loadValue in hGenXML ("codigo", iId, output cCodigoErro).
                    cCodigoErro = OnlyNumbers(cCodigoErro).
                end.
                if cMensagem = "" or cMensagem = ? then do:
                    run loadValue in hGenXML ("mensagem", iId, output cMensagem).
                    cMensagem = PrintChar(cMensagem).
                end.
            end.
            */
            if cCodigoErro <> ? and cMensagem <> ? then do:
                run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                           nota-fiscal.serie,
                                           nota-fiscal.nr-nota-fis,
                                           "000000000000000").
            end.
        end.
    end. /* conected */
    else do:
        cCodigoErro = '9999'. cMensagem = "WebService NDD n∆o conectado".
        run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                   nota-fiscal.serie,
                                   nota-fiscal.nr-nota-fis,
                                   "000000000000000").
    end.

end procedure.


procedure pi-processa-retorno-Cold:

    define input parameter pGrava as logical no-undo.

    cCodigoErro = OnlyNumbers(string(findTag(cReturnValue,'codigo',1))).
    cMensagem   = PrintChar(string(findTag(cReturnValue,'mensagem',1))).
    if l-log then put stream str-log unformatted index(cReturnValue,'<codigo>') " " cCodigoErro " " cMensagem skip.

    if cCodigoErro <> "000" then do:
        l-aux = no.
    end.
    else do:
        l-aux = yes.
        i-aux = index(cReturnValue,'<document>',1).
        /*if l-log then put stream str-log unformatted i-aux " ".*/
        do while i-aux > 0 
            on stop undo, leave 
            on error undo, leave
            on endkey undo, leave:
            iId = iId + 1.
            /*if l-log then put stream str-log unformatted I-AUX skip.*/
            cChildren = findTag(cReturnValue,'document',i-aux).

            if cChildren <> "" then do:
                /* conversao base64 da Progress */
                memptrXML = base64-decode(cChildren).
                copy-lob memptrXML to cChildren.
                /* conversao base 64 francesa
                /*cChildren = PrintChar(cChildren).*/
                cChildren = PrintChar(base64_decode(cChildren)).*/
                /*
                if l-log and pGrava then do:
                    cFileXML =  cCaminhoTMP + "NF" + "_" + c-seg-usuario + "_" +
                                string(today,"99-99-9999") + replace(string(time,"HH:MM:SS"),':','_') + "_" + string(iId) + '.xml'.
                    copy-lob cChildren to file cFileXML.
                end.
                */
                run pi-abre-xml-string(input cChildren, input pGrava).
            end.

            i-aux = index(cReturnValue,'</document>',i-aux).
            i-aux = index(cReturnValue,'<document>',i-aux).
            if i-aux = 0 or i-aux = ? then leave.
        end.

        /*
        run getChildrenList in hGenXML (5,output cChildren).
        if cChildren <> "" and num-entries(cChildren,',') > 0 then
        do iId = int(entry(1,cChildren,',')) to int(entry(num-entries(cChildren,','),cChildren,',')):
            run getValue in hGenXML (iId, output cReturnValue).
            cReturnValue = base64_decode(cReturnValue).
            cFileXML =  cCaminhoTMP + "NF" + "_" + estabelec.cod-estabel + "_" + c-seg-usuario + "_" +
                        string(today,"99-99-9999") + replace(string(time,"HH:MM:SS"),':','_') + "_" + string(iId) + '.xml'.
            copy-lob cReturnValue to file cFileXML.
            run pi-abre-xml(input cFileXML).
        end.
        */
    end. /* cCodigoErro = "000" */
    
    /* limpar arquivo se leitura teve sucesso */
    if l-aux and pGrava then os-delete value(cFile) no-error.
    
end.

procedure pi-ConsultarColdSincrono:
    define input parameter cChaveNFe as char no-undo.

    /* Gera Header do envio para NDD */
    run pi-GeraHeaderConsultarColdSincrono (cChaveNFe, output cHeader).
    if l-log then do:
        cFile = cCaminhoTMP + "eformsConsultarColdSincronoHeader_" + cChaveNFe + ".xml".
        copy-lob cHeader to FILE cFile.
    end.

    /* envio p/ WebService */
    run pi-conectaWebServer (input 'WSConsultarColdSincrono.wsdl', 
                             input 'WSConsultarColdSincrono',      
                             input "973", /* utilizar webserver do CD para entradas */
                             output l-connected).
    if l-connected then do:
        run WSConsultarColdSincronoSoap set hWSPortaSoap on hWebService.

        run ConsultarDocumento in hWSPortaSoap(input  cHeader, 
                                               output cReturnValue).

        /* guardando arquivo para posterior processamento em caso de queda ou erro no processamento */
        cFile = cCaminhoTMP + "eformsConsultarColdSincronoRetorno" + "_" + 
            cChaveNFe + "_" + 
            string(today,"99-99-9999") + 
            replace(string(time,"HH:MM:SS"),':','_') + ".xml".
        copy-lob cReturnValue TO FILE cFile.

        run pi-processa-retorno-Cold (input no).

    end.
end.

procedure pi-abre-xml-string: 

    define input parameter pXML as longchar no-undo.
    define input parameter pGrava as logical no-undo.

    def var cSerie  as char no-undo.
    def var cNF     as char no-undo.
    def var cEmit   as char no-undo.
    def var cDest   as char no-undo.
    def var iCont   as integer no-undo.
    def var cAux    as char no-undo.

    /* identificaá∆o da nota */
    if  not pGrava or (
        length(pXML) > 0 and
        pXML matches "*serie*" and
        pXML matches "*nNF*" and
        pXML matches "*dhEmi*" and
        pXML matches "*CNPJ*") then do
        on error undo, return error:
    
            
        /* tratar sÇrie */
        if  pXML matches "*serie*" then do:           
            assign cSerie = OnlyNumbers(string(int(findTag(pXML,'serie',1)))) no-error.
            if length(cSerie) > 3 then assign cSerie = substring(cSerie,1,3) no-error.
        end.

        if  pXML matches "*nNF*" then 
            assign cNF   = OnlyNumbers(string(int64(findTag(pXML,'nNF',1)),">>>9999999")) no-error.
        if pXML matches "*dhEmi*" then do:
            assign cData = substring(findTag(pXML,'dhEmi',1),1,10) 
                   cData = entry(3,cData,"-") + "/" + entry(2,cData,"-")  + "/" + entry(1,cData,"-") no-error.
        end.

        if pXML matches "*CNPJ*" then do: 
            /* emitente do documento */
            assign cEmit = string(findTag(pXML,'CNPJ',1)) no-error. 
        
            /* destinatario */
            assign cDest = string(findTag(pXML,'CNPJ',index(pXML,'CNPJ') + 25)) no-error.
        end.

        /* armazenar XML para abertura no INT500 */
        if pGrava then do: 
            for first NDD_ENTRYINTEGRATION EXCLUSIVE where 
                NDD_ENTRYINTEGRATION.KIND           = 0             and
                NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) and
                NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    and
                NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  and
                NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest)
                query-tuning(no-lookahead): end.
            if not avail NDD_ENTRYINTEGRATION then do:
                iCont = 1.
                for last NDD_ENTRYINTEGRATION exclusive-lock use-index id:
                    assign iCont = NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID + 1.
                end.
                create  NDD_ENTRYINTEGRATION.
                assign  NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID = iCont
                        NDD_ENTRYINTEGRATION.STATUS_            = 0
                        NDD_ENTRYINTEGRATION.KIND               = 0
                        NDD_ENTRYINTEGRATION.EMISSIONDATE       = datetime(cData)
                        NDD_ENTRYINTEGRATION.CNPJEMIT           = int64(cEmit)
                        NDD_ENTRYINTEGRATION.CNPJDEST           = int64(cDest)
                        NDD_ENTRYINTEGRATION.SERIE              = int64(cSerie)
                        NDD_ENTRYINTEGRATION.DOCUMENTNUMBER     = int64(cNF).
                copy-lob pXML to NDD_ENTRYINTEGRATION.DOCUMENTDATA.
            end.
            if l-log then put stream str-log unformatted 
                "Emitente: " cEmit " Serie: " cSerie " Nota: " cNF " Emissao: " cData " Destino: " CDest " Id NDD: " 
                NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID skip.
        end.
        else do:
            for first tt-NDD_ENTRYINTEGRATION EXCLUSIVE where 
                tt-NDD_ENTRYINTEGRATION.KIND           = 0             and
                tt-NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) and
                tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    and
                tt-NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  and
                tt-NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest)
                query-tuning(no-lookahead): end.
            if not avail tt-NDD_ENTRYINTEGRATION then do:
                iCont = 1.
                for last tt-NDD_ENTRYINTEGRATION exclusive-lock use-index id:
                    assign iCont = tt-NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID + 1.
                end.
                create  tt-NDD_ENTRYINTEGRATION.
                assign  tt-NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID = iCont
                        tt-NDD_ENTRYINTEGRATION.STATUS_            = 0
                        tt-NDD_ENTRYINTEGRATION.KIND               = 0
                        tt-NDD_ENTRYINTEGRATION.EMISSIONDATE       = datetime(cData)
                        tt-NDD_ENTRYINTEGRATION.CNPJEMIT           = int64(cEmit)
                        tt-NDD_ENTRYINTEGRATION.CNPJDEST           = int64(cDest)
                        tt-NDD_ENTRYINTEGRATION.SERIE              = int64(cSerie)
                        tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER     = int64(cNF).
                        tt-NDD_ENTRYINTEGRATION.retOK              = if cEmit <> "" and cEmit <> ? and
                                                                        cNF <> "" and cNF <> ? and
                                                                        CDest <> "" and CDest <> ? and
                                                                        cData <> "" and cData <> ? and
                                                                        cSerie <> ? 
                                                                     then "Leitura executada com sucesso"
                                                                     else "ERRO de leitura!!!".
                copy-lob pXML to tt-NDD_ENTRYINTEGRATION.DOCUMENTDATA.

                assign  tt-NDD_ENTRYINTEGRATION.int500 = "N«O"
                        tt-NDD_ENTRYINTEGRATION.processado = "N«O".
                for first NDD_ENTRYINTEGRATION EXCLUSIVE where 
                    NDD_ENTRYINTEGRATION.KIND           = 0             and
                    NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) and
                    NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    and
                    NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  and
                    NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest)
                    query-tuning(no-lookahead):
                    assign  tt-NDD_ENTRYINTEGRATION.int500 = "Sim"
                            tt-NDD_ENTRYINTEGRATION.processado = if NDD_ENTRYINTEGRATION.status_ = 1 then "Sim" else "N«O" .
                end.

            end.
            if l-log then put stream str-log unformatted 
                "Emitente: " cEmit " Serie: " cSerie " Nota: " cNF " Emissao: " cData " Destino: " CDest " Id NDD: " 
                tt-NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID skip.
        end.
    end.
    else do:
        if l-log then put stream str-log unformatted "Problemas na abertura dos XML: " cFile skip.
        l-aux = no.
        RUN intprg/int999.p (INPUT "NFENDD", 
                             INPUT string(cFile),
                             INPUT "Arquivo XML n∆o pode ser aberto",
                             INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                             INPUT c-seg-usuario,
                             INPUT "INT500RP.P").
    end.
end. 

