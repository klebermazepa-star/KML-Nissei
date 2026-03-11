

DEF TEMP-TABLE tt-xml NO-UNDO
    FIELD id-pai            AS INT  FORMAT ">>>>>>>>9"
    FIELD id-filho          AS INT  FORMAT ">>>>>>>>9"
    FIELD node-pai          AS CHAR FORMAT "x(20)"
    FIELD node-filho        AS CHAR FORMAT "x(20)"
    FIELD node-filho-seq    AS INT
    FIELD conteudo          AS CHAR FORMAT "x(200)"
    INDEX idx IS PRIMARY UNIQUE
        id-pai
        id-filho
        node-filho-seq.


DEF TEMP-TABLE NotaDestinada NO-UNDO 
    field ChaveNFe            as char 
    field Serie               as char 
    field NumeroNotaFiscal    as char 
    field CNPJEmissor         as char 
    field xNome               as char 
    field IE                  as char 
    field dEmi                as char 
    field tpNF                as char 
    field vNF                 as char 
    field digVal              as char 
    field dhRecbto            as char 
    field SituacaoNFe         as char 
    field SituacaoConfirmacao as char 
    field SituacaoXMLNFe      as char 
    field CNPJDestinatario    as char .

DEFINE VARIABLE i-aux AS INTEGER     NO-UNDO.

DEFINE BUFFER b-NDD_ENTRYINTEGRATION FOR NDD_ENTRYINTEGRATION.

function findTag returns longchar
    (pSource as longchar, pTag as char, pStart as int64):

    LOG-MANAGER:WRITE-MESSAGE("findTag _ " + pTag) NO-ERROR.

    def var cTagIni as char no-undo.
    def var cTagFim as char no-undo.

    if length(trim(pSource)) > 0 and length(trim(pTag)) > 0 and pStart >= 1 then do:
        assign  cTagIni = '<'  + trim(pTag) + '>'
                cTagFim = '</' + trim(pTag) + '>'.

       // LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagIni,pStart))) NO-ERROR.
       // LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart))) NO-ERROR.
       // LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ))) NO-ERROR.
        IF index(pSource,cTagIni,pStart) < 0
        OR index(pSource,cTagFim,pStart) < 0 
        OR index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) < 0 THEN RETURN "".

        return trim(substring(pSource,
                              index(pSource,cTagIni,pStart) + length(cTagIni), 
                              index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) 
                              ) 
                    ).
    end.
    return "".
end.

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
                
PROCEDURE gera_ndd_entryintegration:

    DEFINE INPUT PARAMETER pxml AS LONGCHAR NO-UNDO.
    DEFINE OUTPUT PARAMETER c-result AS CHARACTER NO-UNDO.

    def var cSerie  as char no-undo.
    def var cNF     as char no-undo.
    //DEF VAR cCT     AS CHAR NO-UNDO.
    def var cEmit   as char no-undo.
    def var cDest   as char no-undo.
    def var cData   as char no-undo.
    DEF VAR icont   AS INT NO-UNDO.
    
    DEFINE VARIABLE hDoc AS HANDLE   NO-UNDO.
    
    CREATE X-DOCUMENT hDoc.

    log-manager:write-message("KML - antes criar ndd" ) no-error.

    //COPY-LOB FROM pxml TO FILE "xml2.xml" .
  

    /* tratar sÇrie */
    if  pXML matches "*serie*" then do:     
        assign cSerie = OnlyNumbers(string(int(findTag(pXML,'serie',1)))) no-error.
        if length(cSerie) > 3 then assign cSerie = substring(cSerie,1,3) no-error.
    end.
    
    if  pXML matches "*nNF*" THEN
         assign cNF   = OnlyNumbers(string(int64(findTag(pXML,'nNF',1)),">>>9999999")) NO-ERROR.
        
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

    log-manager:write-message("KMLR - antes FIND ndd" ) no-error.
    log-manager:write-message("KMLR - cEmit - " + cEmit ) no-error.
    log-manager:write-message("KMLR - cDest - " + cDest ) no-error.
    log-manager:write-message("KMLR - cSerie - " + cSerie ) no-error.
    log-manager:write-message("KMLR - cNF - " + cNF ) no-error.
    //log-manager:write-message("KMLR - cCT - " + cCT ) no-error.

    IF cNF = "" THEN DO:
        ASSIGN c-result = "XML com erro".
        RETURN c-result.
    END.

    
    FIND first NDD_ENTRYINTEGRATION NO-LOCK where 
              NDD_ENTRYINTEGRATION.KIND           = 0             and
              NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) and
              NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    and
              NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  and
              NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest) NO-ERROR.

    log-manager:write-message("KMLR - achou ndd ou nao" ) no-error.

    IF AVAIL NDD_ENTRYINTEGRATION THEN DO:
        ASSIGN c-result = "XML j† existe na base".
        RETURN c-result.

    END.
    ELSE DO: 

       log-manager:write-message("KMLR - 1 criou ndd" ) no-error.

       for last b-NDD_ENTRYINTEGRATION NO-LOCK use-index id:
            assign iCont = b-NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID + 1.
        end.

        log-manager:write-message("KMLR - 2 criou ndd" ) no-error.
        log-manager:write-message("KMLR - cEmit - " + cEmit ) no-error.
        log-manager:write-message("KMLR - cDest - " + cDest ) no-error.
        log-manager:write-message("KMLR - cSerie - " + cSerie ) no-error.
        log-manager:write-message("KMLR - cNF - " + cNF ) no-error.

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

        RELEASE NDD_ENTRYINTEGRATION.

    END.

    FIND FIRST NDD_ENTRYINTEGRATION NO-LOCK 
        WHERE NDD_ENTRYINTEGRATION.KIND           = 0             
          AND NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) 
          AND NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    
          AND NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  
          AND NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest) NO-ERROR.

    IF AVAIL NDD_ENTRYINTEGRATION THEN DO: 
    
        ASSIGN c-result = "XML importado com sucesso".
        RETURN c-result.
    END.
    ELSE DO:
        ASSIGN c-result = "XML n∆o importado".
        RETURN c-result.
    END.

END PROCEDURE.




