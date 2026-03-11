/**************************************************************************************
**
**  Programa - NI-IMP-NOTAS-ERRO-PEDIDO-RP.P - Importaá∆o Notas com erro Pedido Compra
**
**************************************************************************************/ 

{include/i-prgvrs.i NI-IMP-NOTAS-ERRO-PEDIDO-RP 2.00.00.000 } 

define temp-table tt-param
    field destino          as integer
    field arq-destino      as char
    field arq-entrada1     as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer.

def temp-table tt-raw-digita                      
    field raw-digita      as raw.                 

DEF TEMP-TABLE tt-nota
    FIELD cnpj-emit  AS DEC  FORMAT ">>>>>>>>>>>>>>>>>>9" COLUMN-LABEL "CNPJ Emit"
    FIELD cnpj-dest  AS DEC  FORMAT ">>>>>>>>>>>>>>>>>>9" COLUMN-LABEL "CNPJ Dest"
    FIELD nr-nota    AS INT  FORMAT ">>>>>>>9"            COLUMN-LABEL "Nr Nota"
    FIELD serie      AS INT  FORMAT ">>9"                 COLUMN-LABEL "SÇrie"
    FIELD dt-emissao AS DATE FORMAT "99/99/9999"          COLUMN-LABEL "Dt Emiss∆o"
    FIELD nr-pedido  AS INT  FORMAT ">>>>>>>9"            COLUMN-LABEL "Nr Pedido"
    FIELD nr-ped-xml AS INT  FORMAT ">>>>>>>9"            COLUMN-LABEL "Nr Pedido XML".

DEF TEMP-TABLE tt-erro
    FIELD chave     AS CHAR FORMAT "x(50)"
    FIELD desc-erro AS CHAR FORMAT "x(80)".

{intprg/int500.i}

DEF VAR i-cont       AS INT FORMAT ">>>,>>9"   NO-UNDO.
DEF VAR h-acomp      AS HANDLE                 NO-UNDO.
DEF VAR c-doc        AS     LONGCHAR NO-UNDO.
DEF VAR c-xml       AS CHAR     NO-UNDO.

DEF VAR pXMLResult  AS LONGCHAR NO-UNDO. 
DEF VAR i-num-pedido  AS INT  FORMAT ">>>>>>>9".

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importaá∆o Notas Erro Pedido").

EMPTY TEMP-TABLE tt-nota.
EMPTY TEMP-TABLE tt-erro.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-nota.
   IMPORT DELIMITER ";" tt-nota NO-ERROR.  

   assign i-cont = i-cont + 1.

   run pi-acompanhar in h-acomp (input "Criando tt-nota: " + string(tt-nota.nr-nota) + " - " + string(i-cont)).

END. 
    
INPUT CLOSE.
  
function PrintChar returns longchar
    (input pc-string as longchar):

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

    return c-string.

end function.

ASSIGN i-cont = 0.

for each tt-nota WHERE tt-nota.nr-nota <> 0:
    assign i-cont = i-cont + 1.

    run pi-acompanhar in h-acomp (input "Nota: " + string(tt-nota.nr-nota) + " - " + string(i-cont)).

    FOR FIRST ndd_entryintegration WHERE
              ndd_entryintegration.documentnumber     = tt-nota.nr-nota   AND
              ndd_entryintegration.serie              = tt-nota.serie     AND
              ndd_entryintegration.cnpjemit           = tt-nota.cnpj-emit AND  
              ndd_entryintegration.cnpjdest           = tt-nota.cnpj-dest NO-LOCK:                       
    END.

    IF AVAIL ndd_entryintegration THEN DO:
       COPY-LOB FROM NDD_ENTRYINTEGRATION.documentdata TO pXMLResult.

       ASSIGN c-doc = PrintChar(pXMLResult)
              c-xml = SESSION:TEMP-DIRECTORY + "xml_temp" + string(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID) +  ".xml".
                           
       IF SEARCH(c-xml) <> ? THEN
          os-delete value(c-xml) no-wait no-console.  
                           
       RUN SaveXML(INPUT c-doc, 
                   INPUT c-xml).

       run pi-abre-xml(INPUT STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID),
                       INPUT c-xml).

       IF SEARCH(c-xml) <> ? THEN
          os-delete value(c-xml) no-wait no-console.

    END.
end.

PROCEDURE SaveXML:
    DEFINE INPUT PARAMETER pXML  AS LONGCHAR NO-UNDO.
    DEFINE INPUT PARAMETER pFile AS CHAR NO-UNDO.

    DEF VAR hDoc AS HANDLE NO-UNDO.

    CREATE X-DOCUMENT hDoc.
    hDoc:LOAD("LONGCHAR", pXML, FALSE).
    hDoc:SAVE("FILE", pFile).
    DELETE OBJECT hDoc.
END PROCEDURE.

PROCEDURE pi-abre-xml:

    DEF INPUT PARAMETER p-arquivo AS CHAR.
    DEF INPUT PARAMETER p-xml     AS CHAR.

    EMPTY TEMP-TABLE ttIde.
    EMPTY temp-table ttInfNFe. 
    EMPTY temp-table ttIde.
    EMPTY temp-table ttNFref .
    EMPTY temp-table ttRefNF .
    EMPTY temp-table ttEmit .
    EMPTY temp-table ttEnderEmit .
    EMPTY temp-table ttDest .
    EMPTY temp-table ttEnderDest .
    EMPTY temp-table ttDet .
    EMPTY temp-table ttProd .
    EMPTY temp-table ttDI .
    EMPTY temp-table ttAdi .
    EMPTY temp-table ttVeicProd .
    EMPTY temp-table ttImposto .
    EMPTY temp-table ttIcms .
    EMPTY temp-table ttICMS00. 
    EMPTY temp-table ttICMS10 .
    EMPTY temp-table ttICMS20 .
    EMPTY temp-table ttICMS30 .
    EMPTY temp-table ttICMS40.
    EMPTY temp-table ttICMS51 .
    EMPTY temp-table ttICMS60.
    EMPTY temp-table ttICMS70 .
    EMPTY temp-table ttICMS90.
    EMPTY temp-table ttICMSSN101.
    EMPTY temp-table ttICMSSN102. 
    EMPTY temp-table ttICMSSN201.
    EMPTY temp-table ttICMSSN202.
    EMPTY temp-table ttICMSSN500.
    EMPTY temp-table ttICMSSN900.
    EMPTY temp-table ttIPI.
    EMPTY temp-table ttIPITrib.
    EMPTY temp-table ttIPINT.
    EMPTY temp-table ttII.
    EMPTY temp-table ttPIS.
    EMPTY temp-table ttPISAliq.
    EMPTY temp-table ttPISNT.
    EMPTY temp-table ttPISOutr.
    EMPTY temp-table ttCOFINS.
    EMPTY temp-table ttCOFINSAliq.
    EMPTY temp-table ttCOFINSNT.
    EMPTY temp-table ttCOFINSOutr.
    EMPTY temp-table ttISSQN.
    EMPTY temp-table ttTotal.
    EMPTY temp-table ttICMSTot.
    EMPTY temp-table ttISSQNtot.
    EMPTY temp-table ttRetTrib.
    EMPTY temp-table ttTransp.
    EMPTY temp-table ttTransporta.
    EMPTY temp-table ttVeicTransp.
    EMPTY temp-table ttReboque.
    EMPTY temp-table ttVol.
    EMPTY temp-table ttCobr. 
    EMPTY temp-table ttFat.
    EMPTY temp-table ttDup.
    EMPTY TEMP-TABLE ttInfAdic.
    EMPTY  temp-table ttExporta.
    EMPTY TEMP-TABLE ttmed.
    EMPTY TEMP-TABLE ttinfprot.
    EMPTY TEMP-TABLE ttcompra.

     /*------------------------------------------------------------------------------
     Notes: Ler XML e carregar Dataset
    ------------------------------------------------------------------------------*/
    DEF var cSourceType as char no-undo.
    def var cReadMode as char no-undo.
    def var lOverrideDefaultMapping as log no-undo.
    def var cFile as char no-undo.
    def var cEncoding as char no-undo.
    def var cSchemaLocation as char no-undo.
    def var cFieldTypeMapping as char no-undo.
    def var cVerifySchemaMode as char no-undo.
    def var retOK as log no-undo.
    
    /* inicio processamento XML */
    dataset dsNfe:empty-dataset no-error.
    dataset dsChave:empty-dataset no-error.
    
    assign cSourceType = "FILE"
    cFile = p-xml /* arquivo da nfe - Realiza a leitura do procNFe */
    cReadMode = "empty"
    cSchemaLocation = ?
    lOverrideDefaultMapping = ?
    cFieldTypeMapping = ?
    cVerifySchemaMode = "IGNORE"
    no-error.
    
    assign retOK = dataset dsNfe:read-xml(cSourceType,
    cFile,
    cReadMode,
    cSchemaLocation,
    lOverrideDefaultMapping,
    cFieldTypeMapping,
    cVerifySchemaMode) no-error.
    
    assign retOK = dataset dsChave:read-xml(cSourceType,
    cFile,
    cReadMode,
    cSchemaLocation,
    lOverrideDefaultMapping,
    cFieldTypeMapping,
    cVerifySchemaMode) no-error.
    /* inicio processamento XML */

    ASSIGN i-num-pedido = 0.

    /* inicio tratamento tmp-tables geradas pelo XML */
    for first ttIde ON ERROR UNDO, RETURN ERROR:

        for first ttCompra:
          ASSIGN i-num-pedido = int(ttCompra.xped) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN
              ASSIGN i-num-pedido = 0.      
        end.
        if avail ttCompra then do:
            if trim(ttCompra.xped) = "PBM" then
               ASSIGN i-num-pedido = ?.
        end.
        
        /* itens da nota */
        FOR EACH ttprod 
            BY ttprod.nitem:
                    
           IF i-num-pedido = 0 THEN DO:
               ASSIGN i-num-pedido = int(ttprod.xped) NO-ERROR.
               IF ERROR-STATUS:ERROR THEN
                  ASSIGN i-num-pedido = 0.
           END.
           if trim(ttprod.xped) = "PBM" then
               ASSIGN i-num-pedido = ?.
        END.

        ASSIGN tt-nota.nr-ped-xml = i-num-pedido.

    END. /* ttIde */
    
END PROCEDURE.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importaá∆o Notas Erro Pedido Compra"
       c-programa     = "NI-IMP-NOTAS-ERRO-PEDIDO-RP".

{include/i-rpcab.i}

view frame f-cabec.

FOR EACH tt-nota WHERE
         tt-nota.nr-nota <> 0:
 disp tt-nota
      with width 132 no-box stream-io down frame f-erros.
END.


/*for each tt-erro:

    disp tt-erro.chave column-label "Chave"
         tt-erro.desc-erro column-label "Descriá∆o"
         with width 132 no-box stream-io down frame f-erros.

end.*/         

view frame f-rodape.    

{include/i-rpclo.i}





