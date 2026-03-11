/********************************************************************************************************        
*Programa.: wsinventti0003.p                                                                            * 
*Descricao: Gera‡Æo de XML para CARTA CORRECAO NFe e/ou  na Inventti *
            e/ou solicitar os XMLs das notas de entrada 
*Autor....: Raimundo C. Soares                                                                          * 
*Data.....: 12/2022                                                                                     * 
*********************************************************************************************************/

DEF INPUT PARAMETER  p-cod-estabel    like  nota-fiscal.cod-estabel no-undo. 
DEF INPUT PARAMETER  p-serie          like  nota-fiscal.serie       no-undo. 
DEF INPUT PARAMETER  p-nr-nota-fisc   like  nota-fiscal.nr-nota-fis no-undo. 
DEF INPUT PARAMETER  p-justificatica  AS CHAR                       NO-UNDO.
DEF INPUT PARAMETER  p-enveto         AS CHAR                       NO-UNDO.
DEF INPUT PARAMETER  p-tipo           AS INT                        NO-UNDO.
DEF OUTPUT PARAMETER p-xml           AS  LONGCHAR                  NO-UNDO.   
DEF VAR tpamb   AS CHAR NO-UNDO FORMAT "X".
DEF VAR c-xml  AS CHAR NO-UNDO.
DEF VAR c-hora AS CHAR NO-UNDO.
DEFINE VARIABLE hApiXml AS HANDLE  NO-UNDO.
DEFINE VARIABLE cId        AS CHARACTER NO-UNDO.

DEFINE VARIABLE cVal       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDiretorio AS CHARACTER NO-UNDO.

DEFINE VARIABLE cId011     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cId01      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cId02      AS CHARACTER NO-UNDO.
def var c-data-ini as char no-undo. 
def var c-data-fim as char no-undo. 
DEF VAR dt-aux     AS DATE NO-UNDO.
DEF VAR dt-aux1     AS DATE NO-UNDO.
DEF VAR i-pagina    AS INT.
DEF VAR i-time     AS INT NO-UNDO.

RUN xmlutp/ut-genxml.p PERSISTENT SET hApiXml.
RUN setEncoding   IN hApiXml (INPUT "utf-8").

IF p-tipo < 5 THEN do:

   FOR FIRST nota-fiscal 
       WHERE nota-fiscal.cod-estabel = p-cod-estabel        //  "017"
       AND   nota-fiscal.serie       = p-serie              //  '1'
       AND   nota-fiscal.nr-nota-fis = p-nr-nota-fisc       //   '0004138'
       NO-LOCK:
   
       FIND FIRST estabelec
            WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel
            NO-LOCK NO-ERROR.

       ASSIGN tpamb = IF estabelec.idi-tip-emis-nf-eletro = 3 THEN '1' ELSE "2".
   
       FIND FIRST natur-oper
            WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao 
            NO-LOCK NO-ERROR.
   
       ASSIGN c-xml  = SESSION:TEMP-DIRECTORY + "Nfe_" + nota-fiscal.cod-estabel + "-" + nota-fiscal.serie + "-" + nota-fiscal.nr-nota-fis + ".xml"
              c-hora = STRING(TIME, "HH:MM:SS").
              CVal   =  STRING(YEAR(TODAY),'9999') + "-" + STRING(MONTH(TODAY),'99') + "-" + STRING(DAY(TODAY),'99') + "T" + trim(c-hora) + "-03:00".
   
       IF p-tipo = 1 OR p-tipo = 2 THEN do:
          
          RUN addNode IN hApiXml (INPUT "0",  INPUT "infEvento", INPUT "",                                   OUTPUT cId).
          RUN addNode IN hApiXml (INPUT cId,  INPUT "CNPJ",      INPUT estabelec.cgc,                      OUTPUT cId01).
          RUN addNode IN hApiXml (INPUT cId,  INPUT "chNFe",     INPUT nota-fiscal.cod-chave-aces-nf-eletro, OUTPUT cId01).
          RUN addNode IN hApiXml (INPUT cId,  INPUT "tpEvento",  INPUT p-enveto,                             OUTPUT cId01).
          
          
          IF p-tipo = 1 THEN /*cancelamento*/
             RUN addNode IN hApiXml (INPUT cId,  INPUT "xJust",     INPUT p-justificatica, OUTPUT cId01).
          
          ELSE  /*carta de corre‡Æo*/
             RUN addNode IN hApiXml (INPUT cId,  INPUT "xCorrecao",     INPUT p-justificatica, OUTPUT cId01).
          
          RUN addNode IN hApiXml (INPUT cId,  INPUT "dhEvento",  INPUT CVal,            OUTPUT cId01).
       END.
       
       IF p-tipo = 4 THEN DO: //consulta
          p-xml =  "<?xml version='1.0' encoding='utf-8'?>" + CHR (10) +
                   "<RecepcionarConsultaNota>" + CHR (10) +
                   "    <CNPJ>" + estabelec.cgc + "</CNPJ>" + CHR (10) +
                   "    <Serie>"+ nota-fiscal.serie + "</Serie>" + CHR (10) +
                   "    <NumeroNota>" + TRIM(nota-fiscal.nr-nota-fis) + "</NumeroNota>" + CHR (10) +
                   "    <ModeloDocumento>" + string(natur-oper.cod-model-nf-eletro) + "</ModeloDocumento>" + CHR (10) +
                   "</RecepcionarConsultaNota>" + CHR (10) .


          //RUN addNode IN hApiXml (INPUT "0",  INPUT "RecepcionarConsultaNota", INPUT '',                                     OUTPUT cId).
          //RUN addNode IN hApiXml (INPUT cId,  INPUT "CNPJ",                    INPUT estabelec.cgc,                          OUTPUT cId01).  
          //RUN addNode IN hApiXml (INPUT cId,  INPUT "Serie",                   INPUT nota-fiscal.serie,                      OUTPUT cId01).  
          //RUN addNode IN hApiXml (INPUT cId,  INPUT "NumeroNota",              INPUT nota-fiscal.nr-nota-fis,                OUTPUT cId01).  //<serie>SERIE</serie>
          //RUN addNode IN hApiXml (INPUT cId,  INPUT "ModeloDocumento",         INPUT string(natur-oper.cod-model-nf-eletro), OUTPUT cId01).  
       END.
   
       IF p-tipo <> 4 THEN DO:
       RUN generateXmlToFile IN hApiXml (INPUT c-xml).
       IF c-xml <> '' THEN COPY-LOB FROM FILE c-xml   TO p-xml.
       END.

       IF p-tipo = 3 THEN DO:

           p-xml =  '<?xml version="1.0" encoding="utf-8" ?>'                           + CHR (10) +
                    '<infInut Id="' + trim(nota-fiscal.cod-chave-aces-nf-eletro) + '">' + CHR (10) +
                    '<tpAmb> + tpamb + </tpAmb>'                                                  + CHR (10) +
                    '<xServ>INUTILIZAR</xServ>'                                         + CHR (10) +
                    '<cUF>'   + trim(nota-fiscal.estado)               + '</cUF>'       + CHR (10) +
                    '<ano>'   + STRING(YEAR(TODAY),'9999')             + '</ano>'       + CHR (10) +
                    '<CNPJ>'  + trim(estabelec.cgc)                    + '</CNPJ>'      + CHR (10) +
                    '<mod>'   + string(natur-oper.cod-model-nf-eletro) + '</mod>'       + CHR (10) +
                    '<serie>' + nota-fiscal.serie                      + '</serie>'     + CHR (10) +
                    '<nNFIni>'+ nota-fiscal.nr-nota-fis                + '</nNFIni>'    + CHR (10) +
                    '<nNFFin>'+ nota-fiscal.nr-nota-fis                + '</nNFFin>'    + CHR (10) +
                    '<xJust>' + p-justificatica                        + '</xJust>'     + CHR (10) +
                    '</infInut>'.
       END.
   END. /*FOR FIRST nota-fiscal*/
END.

ELSE DO:

   FIND FIRST estabelec
        WHERE estabelec.cod-estabel = p-cod-estabel
        NO-LOCK NO-ERROR.

   IF AVAIL estabelec THEN DO:
      IF p-tipo = 5 THEN do:
         ASSIGN c-xml  = 'C:\temp\estab_' + p-cod-estabel + ".xml"
                c-hora = STRING(TIME, "HH:MM:SS").
                CVal   =  STRING(YEAR(TODAY),'9999') + "-" + STRING(MONTH(TODAY),'99') + "-" + STRING(DAY(TODAY),'99') + "T" + trim(c-hora) + "-03:00".
      
         FIND FIRST es-param-int-nfe-entrada OF estabelec NO-LOCK NO-ERROR.
         
         ASSIGN i-time  = TIME
                dt-aux = es-param-int-nfe-entrada.data-emissao
                c-data-ini = STRING(YEAR(dt-aux),'9999')  + "-" + STRING(MONTH(dt-aux),'99')  + "-" + STRING(DAY(dt-aux),'99')  + "T00:00:00"     //'2023-01-01T16:21:56' 
                c-data-fim = STRING(YEAR(TODAY),'9999') +  "-" + STRING(MONTH(TODAY),'99') + "-" + STRING(DAY(TODAY),'99') + "T23:59:59".         //'2023-01-03T16:21:57' 
                i-pagina   = int(p-enveto) .
                ///es-controle-notas-recebimento.hr-execucao = i-time
                ///es-controle-notas-recebimento.data-excutada = dt-aux1.
      
                //MESSAGE c-data-ini VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

         RUN addNode IN hApiXml (INPUT "0",  INPUT "RecepcionarNotasDestinadas", INPUT '',            OUTPUT cId).
         RUN addNode IN hApiXml (INPUT cId,  INPUT "CNPJDestinatario",           INPUT estabelec.cgc, OUTPUT cId01).  
         RUN addNode IN hApiXml (INPUT cId,  INPUT "DataEmissaoInicial",         INPUT c-data-ini ,   OUTPUT cId01). //opcinais 
         RUN addNode IN hApiXml (INPUT cId,  INPUT "DataEmissaoFinal",           INPUT c-data-fim ,   OUTPUT cId01). //opcinais 
         RUN addNode IN hApiXml (INPUT cId,  INPUT "Pagina",                     INPUT i-pagina,      OUTPUT cId01).
      
         //<!-- Campos/ Filtros opcionais -->
         //<ValorNFInicial>0.00</ValorNFInicial>
         //<ValorNFFinal>0.00</ValorNFFinal>
         //<SituacaoConfirmacaoDestinatario>0</SituacaoConfirmacaoDestinatario>     
      
         RUN generateXmlToFile IN hApiXml (INPUT c-xml).
         IF c-xml<> '' THEN COPY-LOB FROM FILE c-xml   TO p-xml.
      END. //IF p-tipo = 6 THEN
      IF p-tipo = 6 THEN do:

        p-xml =  '<?xml version="1.0" encoding="utf-8" ?>'   + CHR (10) +
                 '<RecuperarXMLNota>'                        + CHR (10) +
                 "<NFe Chave='" +  trim(p-justificatica) + "'/>" + CHR (10) +
                 '</RecuperarXMLNota>'.
      END.
      
   END. //IF AVAIL estabelec THEN
END.

IF VALID-HANDLE (hApiXml) THEN DO:
   DELETE object hApiXml.
END.
   
