
/* VARIABEL PARA ARMAZENAR OS VALORES OBTIDOS NA INICIALIZACAO DO loalGenXml */
def var hGenXML as handle no-undo.
def var hXML as handle no-undo.
def var cFile as char no-undo.
def var cHeader as longchar no-undo.
def var cReturnValue as longchar no-undo.
def var cXML as longchar no-undo.
def var cMensagem as char no-undo.
def var iId as integer no-undo.
def var hWebService as handle no-undo.
def var hWSInserirDocumentoSoap as handle no-undo.
def var l-connected as logical no-undo.

PROCEDURE InserirDocumento:
  DEFINE INPUT PARAMETER header1 AS LONGCHAR NO-UNDO.
  DEFINE INPUT PARAMETER document AS LONGCHAR NO-UNDO.
  DEFINE OUTPUT PARAMETER eDocumentResult AS LONGCHAR NO-UNDO.
END PROCEDURE.


DEFINE TEMP-TABLE ttStack NO-UNDO
     FIELD ttID AS INTEGER
     FIELD ttPos AS INTEGER
     INDEX tt_id IS PRIMARY UNIQUE
           ttID  ASCENDING.


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


FUNCTION getStack RETURN INTEGER.
     IF AVAIL(ttStack) THEN
          RETURN ttStack.ttPos.
     ELSE
          RETURN 0.
END FUNCTION.

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
    /*RUN setEncoding IN hGenXml ("UTF-8").*/
    
    RUN reset IN hGenXML.
    
    RUN addNode IN hGenXml (getStack(), "eformsInserir", "", OUTPUT iId).
    addStack(iId).
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns:xsd", "http://www.w3.org/2001/XMLSchema").
        RUN setAttribute IN hGenXml (INPUT iId, "xmlns", "http://www.nddigital.com.br/connector").
        RUN addNode IN hGenXml (getStack(), "versao", "1.00", OUTPUT iId).
        RUN addNode IN hGenXml (getStack(), "tipodocumento", "1", OUTPUT iId). /* 1=XML */
        RUN addNode IN hGenXml (getStack(), "tiposervico", cTipoServico, OUTPUT iId). /* 1=Inserir Emiss∆o */
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
    /*
    cFile = "D:\sistemas\clientes\Nissei\NDD\eformsInserirHeader.xml".
    hXML:SAVE("FILE",cFile). 
    */

    hXML:SAVE("longchar",cHeader). 

    delete object hXML.

end.

procedure pi-conectaWebServer:
    define output parameter l-connected as logical no-undo.
    create server hWebService.
    hWebService:connect("-WSDL '\\192.168.200.74\oework\alessandro.baccin\NDD\wsdl\WSInserirDocumento.wsdl' -Service WSInserirDocumento").
    /* -sslprotocols TLSv1 -sslciphers  -sslprotocols TLSv1.1
    
    -Port WSInserirDocumentoSoap 
    -TargetNamespace http://nddigital.com.br/eForms/webservices
    -ServiceNamespace http://nddigital.com.br/eForms/webservices 
        AES128-SHA
        RC4-SHA
        DES-CBC3-SHA
        DES-CBC-SHA
        EXP-DES-CBC-SHA
        EXP-RC4-MD5 */

    /* -sslprotocols TLSv1.2 -sslciphers 
    AES128-SHA256
    DHE-RSA-AES128-SHA256
    AES128-GCM-SHA256
    DHE-RSA-AES128-GCM-SHA256
    ADH-AES128-SHA256
    ADH-AES128-GCM-SHA256
    ADH-AES256-SHA256
    AES256-SHA256
    DHE-RSA-AES256-SHA256
    */

    l-connected = hWebService:connected().
end.

procedure pi-limpaObjetos:
    /* Limpar Objetos */
    hWebService:disconnect() no-error.
    if valid-handle(hGenXML) then delete object hGenXML no-error.
    if valid-handle(hWebService) then delete object hWebService no-error.
    if valid-handle(hWSInserirDocumentoSoap) then delete object hWSInserirDocumentoSoap no-error.
end procedure.
