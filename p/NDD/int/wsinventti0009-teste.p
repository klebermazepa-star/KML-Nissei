/********************************************************************************************************        
*Programa.: wsinventti0009.p                                                                            * 
*Descricao: Baixa os XMLs de entrada  na Inventti                                                      *
*Autor....: Raimundo C. Soares                                                                          * 
*Data.....: 12/2022                                                                                     * 
*********************************************************************************************************/
DEF INPUT  PARAMETER p-cod-estabel LIKE estabelec.cod-estabel NO-UNDO.

//FOR EACH es-nota-rec-invent: ASSIGN es-nota-rec-inventi.sit-integracao   = 0. END.

//DEF VAR p-cod-estabel AS CHAR NO-UNDO.

DEF TEMP-TABLE tt-evento-xml-retornado  NO-UNDO
    FIELD seq          AS INT
    FIELD nome-arquivo AS CHAR 
    FIELD arquivo      AS CHAR. 

//p-cod-estabel = '017'.

{xmlinc\xmlndd.i}

/*{int\wsinventti0000.i}*/

DEF VAR v-retonro-integracao AS MEMPTR NO-UNDO.
DEF VAR hRoot AS HANDLE NO-UNDO.
DEF VAR l-ok AS LOGICAL NO-UNDO.
DEF VAR c-arqu-aux AS CHAR NO-UNDO.
//def var memptrXML as memptr no-undo.
DEF TEMP-TABLE tt-erro-retorno NO-UNDO
    FIELD Codigo    AS CHAR 
    FIELD Descricao AS CHAR.

DEF  VAR c-xml AS LONGCHAR NO-UNDO.
DEF  VAR l-xml AS LONGCHAR NO-UNDO.
DEFINE VARIABLE m-aux         AS MEMPTR      NO-UNDO.

DEF var c-url          AS CHAR     NO-UNDO.

DEFINE VARIABLE hDoc   AS HANDLE  NO-UNDO.
def var v-Codigo       as char    no-undo. 
def var v-Descricao    as char    no-undo. 
DEF VAR l-retorno      AS LOGICAL NO-UNDO.

FIX-CODEPAGE(c-xml) = "utf-8".
FIND FIRST estabelec
     WHERE estabelec.cod-estabel = p-cod-estabel
     NO-LOCK NO-ERROR.

FOR EACH es-nota-rec-inventi
    WHERE es-nota-rec-inventi.CNPJDestinatario = estabelec.cgc
    AND  es-nota-rec-inventi.sit-integracao   = 0
    EXCLUSIVE-LOCK :

    DISP es-nota-rec-inventi.ChaveNFe FORMAT "X(60)" WITH SCROLLABLE. PAUSE 0.
    RUN int\wsinventti0003.p  (input estabelec.cod-estabel,
                               input '',      
                               input '',
                               INPUT trim(es-nota-rec-inventi.ChaveNFe) ,
                               INPUT 0,
                               INPUT 6, 
                               OUTPUT c-xml).
    IF c-xml <> "" THEN do:

       FIND FIRST esp_integracao 
           WHERE  esp_integracao.id_integracao = 1
           NO-ERROR.
       
       FIND FIRST esp_servico_integracao
            WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
            AND   esp_servico_integracao.descricao = "RecuperarXMLRec"
            NO-LOCK NO-ERROR.
       
       ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) .

       RUN int\wsinventti0001.p  (INPUT  c-url, 
                                  INPUT  c-xml,
                                  OUTPUT v-retonro-integracao).

       IF v-retonro-integracao <> ? THEN do:

          
          RUN pi-valida-xml.
          FIND FIRST tt-erro-retorno NO-ERROR.
          IF NOT AVAIL tt-erro-retorno THEN do:
             //ASSIGN c-arqu-aux = 'c:\temp' + es-nota-rec-inventi.ChaveNFe + ".xml".   //SESSION:TEMP-DIRECTORY + es-nota-rec-inventi.ChaveNFe + ".xml".
             //COPY-LOB FROM v-retonro-integracao TO FILE c-arqu-aux.
             ASSIGN  es-nota-rec-inventi.sit-integracao = 1.
             copy-lob FROM v-retonro-integracao to es-nota-rec-inventi.xml-nfe.

             RUN INT/wsinventti0009a.p( INPUT es-nota-rec-inventi.ChaveNFe,
                                        INPUT v-retonro-integracao, 
                                        OUTPUT  l-ok ).

             IF l-ok = YES  THEN
                ASSIGN es-nota-rec-inventi.sit-integracao = 2.
          END. //NOT AVAIL tt-erro-retorno
       END. //v-retonro-integracao
    END. /*IF c-xml <> ""*/
END.
RELEASE es-nota-rec-inventi.
RELEASE NDD_ENTRYINTEGRATION .

PROCEDURE pi-valida-xml:

   EMPTY TEMP-TABLE tt-erro-retorno.
   /*ASSIGN c-xml = v-retonro-integracao.
   RUN pi-retiraTag(INPUT-OUTPUT c-xml).

   CREATE X-DOCUMENT hDoc.
   CREATE X-NODEREF  hRoot.

   hDoc:LOAD("longchar",c-xml,FALSE) NO-ERROR.*/
   hDoc:LOAD("memptr",v-retonro-integracao,FALSE) NO-ERROR.
       IF ERROR-STATUS:ERROR THEN 
           RETURN "ERROR-01".
   
   hDoc:GET-DOCUMENT-ELEMENT(hRoot). 

   RUN piImportaXML (INPUT hRoot,
                     OUTPUT TABLE tt-erro-retorno).

   FOR EACH tt-erro-retorno 
       WHERE tt-erro-retorno.codigo = '':
       DELETE tt-erro-retorno.
   END.
END PROCEDURE.


PROCEDURE piImportaXML:

   DEFINE INPUT PARAMETER hRoot     AS HANDLE      NO-UNDO.
   DEFINE OUTPUT PARAMETER TABLE FOR tt-erro-retorno.
   
   CREATE tt-erro-retorno.
   RUN pi-node(INPUT hRoot,INPUT 'erro', INPUT 'Codigo'    ,INPUT 0, OUTPUT v-Codigo   , OUTPUT l-retorno). IF l-retorno = YES THEN ASSIGN tt-erro-retorno.Codigo        = v-Codigo    .
   RUN pi-node(INPUT hRoot,INPUT 'erro', INPUT 'Descricao' ,INPUT 0, OUTPUT v-Descricao, OUTPUT l-retorno). IF l-retorno = YES THEN ASSIGN tt-erro-retorno.Descricao     = v-Descricao .
         
END PROCEDURE.


PROCEDURE pi-retiraTag :

  DEFINE INPUT-OUTPUT PARAMETER pc-xml AS LONGCHAR.
  
  DEFINE VARIABLE c-xml-aux AS LONGCHAR       NO-UNDO.
  DEFINE VARIABLE c-tag AS LONGCHAR         NO-UNDO.
  DEFINE VARIABLE i-ini AS INTEGER INITIAL 0  NO-UNDO.
  DEFINE VARIABLE i-fim AS INTEGER INITIAL 0  NO-UNDO.

  DO WHILE INDEX(pc-xml,'<?xml') > 0:
      ASSIGN c-xml-aux = SUBSTRING(pc-xml, INDEX(pc-xml, '<?xml'))
             i-ini     = INDEX(c-xml-aux,'<?xml')
             i-fim     = INDEX(c-xml-aux,'>')
             c-tag     = SUBSTRING(c-xml-aux,i-ini, i-fim - i-ini + 1).

      ASSIGN pc-xml = REPLACE(pc-xml, c-tag, '').
  END.
              
END PROCEDURE.


PROCEDURE pi-node :

   DEFINE INPUT  PARAMETER hNode    AS HANDLE.
   DEFINE INPUT  PARAMETER cPai     AS CHARACTER.
   DEFINE INPUT  PARAMETER cFilho   AS CHARACTER.
   DEFINE INPUT  PARAMETER iTipo    AS INTEGER. /* 0 = node, 1 = attribute */
   DEFINE OUTPUT PARAMETER cRetorno AS CHARACTER.
   DEFINE OUTPUT PARAMETER lRetorno AS LOGICAL INITIAL NO.

   DEFINE VARIABLE hCampo   AS HANDLE             NO-UNDO.
   DEFINE VARIABLE hValor   AS HANDLE             NO-UNDO.
   DEFINE VARIABLE i-loop   AS INTEGER            NO-UNDO.

   CREATE X-NODEREF hCampo.
   CREATE X-NODEREF hValor.

   DO i-loop = 1 TO hNode:NUM-CHILDREN:
      hNode:GET-CHILD(hCampo,i-loop).

      IF iTipo = 0 THEN DO:
        // IF hNode:NAME = 'ConteudoInformado'  OR hCampo:NAME = 'ConteudoInformado>' THEN
        //  MESSAGE 'hNode:NAME ' hNode:NAME SKIP 
        //          'hCampo:NAME ' hCampo:NAME
        //      VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        //  
         IF hNode:NAME = cPai THEN DO:
            
            IF hCampo:NAME = cFilho THEN DO:
               hCampo:GET-CHILD(hValor,1).
                ASSIGN cRetorno = hValor:NODE-VALUE
                       lRetorno = YES.
                //IF hCampo:NAME = 'ChaveNFe'  THEN
                //    MESSAGE hValor:NODE-VALUE
                //        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                //
            END.
         END.
      END.
      IF iTipo = 1 THEN DO:
         IF hNode:NAME = cPai THEN DO:
            ASSIGN cRetorno = hNode:GET-ATTRIBUTE('id').
                   lRetorno = YES.
         END.
      END.

      IF lRetorno = YES THEN DO:
          DELETE OBJECT hCampo.
          DELETE OBJECT hValor.

          RETURN "OK":U.
      END.

       RUN pi-node(INPUT hCampo:HANDLE,
                   INPUT cPai,
                   INPUT cFilho,
                   INPUT iTipo,
                   OUTPUT cRetorno,
                   OUTPUT lRetorno).
   END.

   DELETE OBJECT hCampo.
   DELETE OBJECT hValor.

   RETURN "OK":U.

END PROCEDURE.

PROCEDURE pi-integra:

    define input parameter pXML as longchar no-undo.
    define input parameter pGrava as logical no-undo.
    define output parameter pok as logical initial no no-undo.

    def var cSerie  as char no-undo.
    def var cNF     as char no-undo.
    def var cEmit   as char no-undo.
    def var cDest   as char no-undo.
    def var iCont   as integer no-undo.
    def var cAux    as char no-undo.
    
    /* identifica»’o da nota */
    if  not pGrava or (
        length(pXML) > 0 and
        pXML matches "*serie*" and
        pXML matches "*nNF*" and
        pXML matches "*dhEmi*" and
        pXML matches "*CNPJ*") then do
        on error undo, return error:

        
        /* tratar s²rie */
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
           assign cEmit = string(findTag(pXML,'CNPJ',1)) no-error. 
        
            /* destinatario */
           assign cDest = string(findTag(pXML,'CNPJ',index(pXML,'CNPJ') + 25)) no-error.
        end.

        /* armazenar XML para abertura no INT500 */
        if pGrava then do: 
           iUltNSU = 0.

           find first NDD_ENTRYINTEGRATION           
                where NDD_ENTRYINTEGRATION.KIND           = 0             
                and   NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) 
                and   NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    
                and   NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  
                and   NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest) 
                EXCLUSIVE-LOCK no-error.

           IF AVAIL NDD_ENTRYINTEGRATION THEN DO:
               
               //ASSIGN NDD_ENTRYINTEGRATION.NSU                = iUltNSU.
               copy-lob pXML to NDD_ENTRYINTEGRATION.DOCUMENTDATA.
           END.
            
           ELSE do:
              ASSIGN iCont = 1.
                
              for last NDD_ENTRYINTEGRATION no-lock use-index id:
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
                      NDD_ENTRYINTEGRATION.DOCUMENTNUMBER     = int64(cNF)
                      NDD_ENTRYINTEGRATION.NSU                = iUltNSU.
              copy-lob pXML to NDD_ENTRYINTEGRATION.DOCUMENTDATA.
                
           END.
           release NDD_ENTRYINTEGRATION.
           pok = yes.
        END. //if pGrava then
        
        else do:
           
           find first tt-NDD_ENTRYINTEGRATION                   
                where tt-NDD_ENTRYINTEGRATION.KIND           = 0             
                and   tt-NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) 
                and   tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    
                and   tt-NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  
                and   tt-NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest) 
                NO-LOCK no-error.

           if not avail tt-NDD_ENTRYINTEGRATION then do:

               iCont = 1.
               for last tt-NDD_ENTRYINTEGRATION no-lock use-index id:
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

               assign  tt-NDD_ENTRYINTEGRATION.int500 = "N€O"
                       tt-NDD_ENTRYINTEGRATION.processado = "N€O".

               for first NDD_ENTRYINTEGRATION no-lock where 
                   NDD_ENTRYINTEGRATION.KIND           = 0             and
                   NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) and
                   NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    and
                   NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  and
                   NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest):
                   assign  tt-NDD_ENTRYINTEGRATION.int500 = "Sim"
                           tt-NDD_ENTRYINTEGRATION.processado = if NDD_ENTRYINTEGRATION.status_ = 1 then "Sim" else "N€O".
               end.
           END. //if not avail tt-NDD_ENTRYINTEGRATION
	       release tt-NDD_ENTRYINTEGRATION.
           pok = yes.
          /*  /*if l-log then*/ put stream str-log unformatted 
                "Emitente: " cEmit " Serie: " cSerie " Nota: " cNF " Emissao: " cData " Destino: " CDest " Id NDD: " 
                tt-NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID skip. */
               
               
        END. //pGrava = NO
        
    END.
    else do:
       
        //MESSAGE 300 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
         /***
        /*if l-log then*/ put stream str-log unformatted "Problemas na abertura dos XML: " cFile skip. */
        pok = no.
        RUN intprg/int999.p (INPUT "NFENDD", 
                             INPUT string(cFile),
                             INPUT "Arquivo XML n’o pode ser aberto",
                             INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                             INPUT c-seg-usuario,
                             INPUT "INT500RP.P").
        
    end.
   

END PROCEDURE.
