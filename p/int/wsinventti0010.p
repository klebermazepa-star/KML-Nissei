/********************************************************************************************************        
*Programa.: wsinventti0008.p                                                                            * 
*Descricao: integraá∆o INVENTTI MDFe                                                                    *
*Autor....:                                                                                             * 
*Data.....: 05/2023                                                                                     * 
*********************************************************************************************************/
//CURRENT-LANGUAGE = CURRENT-LANGUAGE.
{method/dbotterr.i}
{utp/ut-glob.i}

DEF BUFFER bf-mdfe-docto FOR mdfe-docto.

DEFINE INPUT  PARAMETER p-processo    AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER p-rowid-mdfe  AS ROWID       NO-UNDO.

DEF VAR  p-retonro-integracao   AS LONGCHAR NO-UNDO.
{int\wsinventti0000.i}

DEF VAR c-xml                AS LONGCHAR NO-UNDO.
DEF var c-url                AS CHAR     NO-UNDO.

DEFINE VARIABLE m-aux         AS MEMPTR      NO-UNDO.
DEFINE VARIABLE i-pos-fim     AS INTEGER     NO-UNDO.
DEFINE VARIABLE i-pos-ini     AS INTEGER     NO-UNDO.
DEF VAR c-arq-nao-localizado  AS CHAR NO-UNDO.
DEF VAR v-arq-nao-localizado  AS CHAR NO-UNDO.
DEF VAR l-retorno             AS LOGICAL NO-UNDO.
DEF VAR nprod                 AS INT NO-UNDO.
DEF VAR i-pagina              AS INT NO-UNDO.
def var vTabela                as char  no-undo.
def var Importar               AS LOGICAL  no-undo.
def var rid                    AS ROWID  no-undo.
def var tabelas                as char  no-undo.
DEFINE VARIABLE hDoc           AS HANDLE      NO-UNDO.
DEFINE VARIABLE lc-xml         AS LONGCHAR    NO-UNDO.
def var bh                     as handle  no-undo.
def var fh                     as handle  no-undo.
DEF VAR dt-aux     AS DATE NO-UNDO.
DEFINE VARIABLE cSucesso     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cErro        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cStatus      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cDescricao   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cStat        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cxMotivo     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cProtocolo   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cChaveDoMDFe AS CHARACTER   NO-UNDO.

IF p-processo = "RecepcionarMDFe" THEN
    RUN pi-RecepcionarMDFe.

IF p-processo = "ConsultaMDFe" THEN
    RUN pi-ConsultaMDFe.

PROCEDURE pi-ConsultaMDFe:

    DEFINE VARIABLE c-cnpj   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-serie  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-numero AS CHARACTER   NO-UNDO.

    FOR FIRST mdfe-docto NO-LOCK WHERE ROWID(mdfe-docto) = p-rowid-mdfe,
        FIRST estabelec NO-LOCK WHERE estabelec.cod-estabel = mdfe-docto.cod-estab:
        
        ASSIGN c-cnpj   = estabelec.cgc
               c-serie  = mdfe-docto.cod-ser-mdfe
               c-numero = TRIM(STRING(int64(mdfe-docto.cod-num-mdfe))).

        ASSIGN c-xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ConsultarMDFe xmlns="http://localhost/MDFePack.IntegracaoWebServices"><consultaMDFe>'
                     + '<![CDATA[<ConsultaMDFe><CNPJ>' + c-cnpj + '</CNPJ><Serie>' + c-serie + '</Serie><Numero>' + c-numero + '</Numero></ConsultaMDFe>]]>'
                     //+ '<![CDATA[<ConsultaMDFe><CNPJ>75006999000185</CNPJ><Serie>0</Serie><Numero>5</Numero></ConsultaMDFe>]]>'
                     + '</consultaMDFe></ConsultarMDFe></soap:Body></soap:Envelope>'.

        FIND FIRST esp_integracao 
             WHERE  esp_integracao.id_integracao = 2
             NO-ERROR.
        
        FIND FIRST esp_servico_integracao
             WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao          
             AND   esp_servico_integracao.descricao = "ConsultarMDFe"
             NO-LOCK NO-ERROR.
        
        IF NOT AVAIL esp_servico_integracao THEN DO:
            RUN  utp/ut-msgs.p(INPUT "show",
                               INPUT 17006,
                               INPUT "Erro na integraá∆o com a Inventi!~~Configuraá‰es conex∆o InventtiMDFe n∆o cadastradas no programa ESINT0001!").
            RETURN "NOK".
        END.

        ASSIGN c-url = trim(esp_servico_integracao.servico).

        //ASSIGN c-url = "http://localhost/MDFePack.IntegracaoWebServices/ConsultarMDFe".
        
        RUN int\wsinventti0010b.p  (INPUT  c-url, 
                                    INPUT  c-xml,
                                    OUTPUT v-retonro-integracao).
        
        ASSIGN p-retonro-integracao = v-retonro-integracao.
               lc-xml               = v-retonro-integracao.
        
        IF v-retonro-integracao <>  "" THEN DO:
            
            ASSIGN  lc-xml = v-retonro-integracao.

            RUN pi-busca-result(INPUT "ConsultarMDFeResult",
                                INPUT-OUTPUT lc-xml).
            
            CREATE X-DOCUMENT hDoc.
            CREATE X-NODEREF  hRoot.
            
            hDoc:LOAD("longchar",lc-xml,FALSE) NO-ERROR.
            IF ERROR-STATUS:ERROR THEN 
                RETURN "ERROR-01".
            
            hDoc:GET-DOCUMENT-ELEMENT(hRoot). 
    
            RUN pi-node(INPUT hRoot,
                        INPUT 'MDFe',  
                        INPUT 'Status',
                        INPUT 0,
                        OUTPUT cStatus,
                        OUTPUT l-retorno).
            
            RUN pi-node(INPUT hRoot,
                        INPUT 'MDFe',  
                        INPUT 'Descricao',
                        INPUT 0,
                        OUTPUT cDescricao,
                        OUTPUT l-retorno).

            RUN pi-node(INPUT hRoot,
                        INPUT 'Sefaz',  
                        INPUT 'cStat',
                        INPUT 0,
                        OUTPUT cStat,
                        OUTPUT l-retorno).

            RUN pi-node(INPUT hRoot,
                        INPUT 'Sefaz',
                        INPUT 'xMotivo',
                        INPUT 0,
                        OUTPUT cxMotivo,
                        OUTPUT l-retorno).

            RUN pi-node(INPUT hRoot,
                        INPUT 'Sefaz',
                        INPUT 'Protocolo',
                        INPUT 0,
                        OUTPUT cProtocolo,
                        OUTPUT l-retorno).

            RUN pi-node(INPUT hRoot,
                        INPUT 'Erro',  
                        INPUT 'Descricao',
                        INPUT 0,
                        OUTPUT cErro,
                        OUTPUT l-retorno).

            IF cErro = "" THEN DO:

                IF  (mdfe-docto.idi-sit-mdfe = 8
                AND (cStat = "100":U OR  /*100 Uso Autorizado*/              
                     cStat = "150":U))   /*150 Uso Autorizado fora de prazo*/
                THEN NEXT.
    
                /* Verificar se retornou Uso Autorizado, Canc Homologado ou Inut Homologado, se retornou nro de protocolo */
                IF ((cStat = "100":U OR /*100 Uso Autorizado*/              
                     cStat = "150":U)   /*150 Uso Autorizado fora de prazo*/
                OR (cStat = "101":U OR  /*101 Cancelamento de NF-e homologado*/                                                
                    cStat = "151":U OR  /*151 Cancelamento de NF-e homologado fora de prazo*/                                  
                    cStat = "155":U)    /*155 Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
                OR  cStat = "102":U)
                AND (cProtocolo = ""
                OR   cProtocolo = ?) THEN NEXT.
                    
                RUN pi-atualiza-Docto-TSS.
            END.
            ELSE DO:
                FIND FIRST mdfe-ret 
                     WHERE mdfe-ret.cod-estab    = mdfe-docto.cod-estab    
                       AND mdfe-ret.cod-ser-mdfe = mdfe-docto.cod-ser-mdfe 
                       AND mdfe-ret.cod-num-mdfe = mdfe-docto.cod-num-mdfe 
                       AND mdfe-ret.cod-msg      = cStat 
                       AND mdfe-ret.dat-ret      = TODAY                         
                       AND mdfe-ret.hra-ret      = REPLACE(STRING(TIME, "HH:MM:SS"),":","") NO-LOCK NO-ERROR.
                IF NOT AVAIL mdfe-ret THEN DO:
                    CREATE mdfe-ret.
                    ASSIGN mdfe-ret.cod-estab    = mdfe-docto.cod-estab   
                           mdfe-ret.cod-ser-mdfe = mdfe-docto.cod-ser-mdfe
                           mdfe-ret.cod-num-mdfe = mdfe-docto.cod-num-mdfe
                           mdfe-ret.cod-msg      = cStat
                           mdfe-ret.dat-ret      = TODAY
                           mdfe-ret.hra-ret      = REPLACE(STRING(TIME, "HH:MM:SS"),":","")
                           mdfe-ret.cod-livre-2  = cErro
                           mdfe-ret.cod-livre-1  = cProtocolo
                           mdfe-ret.cod-livre-3  = c-seg-usuario.
                END.
            END.
        END.
    END.


END PROCEDURE.

PROCEDURE pi-RecepcionarMDFe:

    FIND FIRST esp_integracao 
         WHERE  esp_integracao.id_integracao = 2
         NO-ERROR.
    
    FIND FIRST esp_servico_integracao
         WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao          
         AND   esp_servico_integracao.descricao = "RecepcionarMDFe"
         NO-LOCK NO-ERROR.

    IF NOT AVAIL esp_servico_integracao THEN DO:
        RUN  utp/ut-msgs.p(INPUT "show",
                           INPUT 17006,
                           INPUT "Erro na integraá∆o com a Inventi!~~Configuraá‰es conex∆o InventtiMDFe n∆o cadastradas no programa ESINT0001!").
        RETURN "NOK".
    END.
        
    RUN INT\wsinventti0010a.p (INPUT p-rowid-mdfe,
                               OUTPUT c-xml).

    ASSIGN c-url = trim(esp_servico_integracao.servico).

    //ASSIGN c-url = "http://localhost/MDFePack.IntegracaoWebServices/RecepcionarMDFe".
    
    RUN int\wsinventti0010b.p  (INPUT  c-url, 
                                INPUT  c-xml,
                                OUTPUT v-retonro-integracao).
    
    ASSIGN p-retonro-integracao = v-retonro-integracao.
           lc-xml               = v-retonro-integracao.
    
    IF v-retonro-integracao <>  "" THEN do:
    
         ASSIGN  lc-xml = v-retonro-integracao.
         
         RUN pi-busca-result(INPUT "RecepcionarMDFeResult",
                             INPUT-OUTPUT lc-xml).
         
         
         CREATE X-DOCUMENT hDoc.
         CREATE X-NODEREF  hRoot.
         
         hDoc:LOAD("longchar",lc-xml,FALSE) NO-ERROR.
         IF ERROR-STATUS:ERROR THEN 
             RETURN "ERROR-01".
         
         hDoc:GET-DOCUMENT-ELEMENT(hRoot). 

         RUN pi-node(INPUT hRoot,
                     INPUT 'RespostaIntegracaoWebService',  
                     INPUT 'Sucesso',
                     INPUT 0,
                     OUTPUT cSucesso,
                     OUTPUT l-retorno).
         
         IF cSucesso = "TRUE" THEN DO:
             RUN pi-node(INPUT hRoot,
                         INPUT 'MDFe',  
                         INPUT 'ChaveDoMDFe',
                         INPUT 0,
                         OUTPUT cChaveDoMDFe,
                         OUTPUT l-retorno).

             FOR FIRST bf-mdfe-docto EXCLUSIVE-LOCK
                 WHERE ROWID(bf-mdfe-docto) = p-rowid-mdfe:

                 ASSIGN bf-mdfe-docto.idi-sit-mdfe   = 6
                        bf-mdfe-docto.cod-chave-mdfe = cChaveDoMDFe.
             END.
         END.
         ELSE DO:
             RUN pi-node(INPUT hRoot,
                         INPUT 'Erro',  
                         INPUT 'Descricao',
                         INPUT 0,
                         OUTPUT cErro,
                         OUTPUT l-retorno).

             RUN  utp/ut-msgs.p(INPUT "show",
                                INPUT 17006,
                                INPUT "Erro na integraá∆o com a Inventi!~~" + cErro).
         END.
    END.

END PROCEDURE.

PROCEDURE piLoadXML :

    DEFINE INPUT  PARAMETER pc-nome-arquivo AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER hRoot           AS HANDLE    NO-UNDO.

    /* Là arquivos dispon•veis */
    IF SEARCH(pc-nome-arquivo) = ? THEN do:
        RETURN "NOK".
    END.

    /* Importa o XML para ponteiro de mem¢ria m-aux  */
    FILE-INFO:FILE-NAME = pc-nome-arquivo.
    SET-SIZE(m-aux) = FILE-INFO:FILE-SIZE.
    INPUT FROM VALUE(pc-nome-arquivo) BINARY NO-CONVERT.
    IMPORT UNFORMATTED m-aux.
    
    /* Copia o ponteiro m-aux para variavel longchar lc-xml, 
       para que possam ser retiradas as tags iniciadas em '<?xml' */
    COPY-LOB m-aux TO lc-xml.
    RUN pi-retiraTag(INPUT-OUTPUT lc-xml).

    /* Carrega o XML a partir da vari†vel longchar lc-xml,
       depois de retirada as tags '<?xml'                  */
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF  hRoot.

    hDoc:LOAD("longchar",lc-xml,FALSE) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN 
        RETURN "ERROR-01".

    hDoc:GET-DOCUMENT-ELEMENT(hRoot). 

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi-busca-result :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT        PARAMETER p-tag  AS CHARACTER   NO-UNDO.
    DEFINE INPUT-OUTPUT PARAMETER pc-xml AS LONGCHAR.
    
    DEFINE VARIABLE c-xml-aux AS LONGCHAR       NO-UNDO.
    DEFINE VARIABLE c-tag AS LONGCHAR           NO-UNDO.
    DEFINE VARIABLE i-ini AS INTEGER INITIAL 0  NO-UNDO.
    DEFINE VARIABLE i-fim AS INTEGER INITIAL 0  NO-UNDO.

    // ConsultarMDFeResult
    // RecepcionarMDFeResult

    IF INDEX(pc-xml,'<' + p-tag + '>') > 0 THEN DO:
        ASSIGN c-xml-aux = SUBSTRING(pc-xml, INDEX(pc-xml, '<' + p-tag + '>'))
               i-ini     = INDEX(c-xml-aux,'<' + p-tag + '>') + LENGTH(p-tag) + 2
               i-fim     = INDEX(c-xml-aux,'</' + p-tag + '>') - LENGTH(p-tag) - 3
               c-tag     = SUBSTRING(c-xml-aux,i-ini, i-fim - i-ini).

        ASSIGN pc-xml = c-tag. //REPLACE(pc-xml, c-tag, '').
    END.

    ASSIGN pc-xml = REPLACE(pc-xml,"&lt;", "<")
           pc-xml = REPLACE(pc-xml,"&gt;", ">").

    RUN pi-retiraTag(INPUT-OUTPUT pc-xml).
              
END PROCEDURE.

PROCEDURE pi-retiraTag :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT-OUTPUT PARAMETER pc-xml AS LONGCHAR.
    
    DEFINE VARIABLE c-xml-aux AS LONGCHAR       NO-UNDO.
    DEFINE VARIABLE c-tag AS LONGCHAR           NO-UNDO.
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
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

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
           
          IF hNode:NAME = cPai THEN DO:
             
             IF hCampo:NAME = cFilho THEN DO:
                hCampo:GET-CHILD(hValor,1).
                 ASSIGN cRetorno = hValor:NODE-VALUE
                        lRetorno = YES.
                 //IF hCampo:NAME = 'ChaveNFe'  THEN MESSAGE hValor:NODE-VALUE VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

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

PROCEDURE obtemnode:
  DEFINE VARIABLE hCampo   AS HANDLE             NO-UNDO.
    DEFINE VARIABLE hValor   AS HANDLE             NO-UNDO.
    DEFINE VARIABLE i-loop   AS INTEGER            NO-UNDO.

  def input parameter vh as handle.
  def var hc as handle.
  def var loop  as int.

  create x-noderef hc.
  

  do loop = 1 to vh:num-children.

     vh:get-child(hc,loop).


     if loop = 1 and lookup(vh:name,tabelas) > 0 then do:

        create buffer bh for table vh:name.
        bh:buffer-create.

        if bh:name = "prod" then 
           nProd = nProd + 1.

        if lookup(vh:name,"prod,icms,ipi,pis,cofins,ICMSUFDest") > 0 then 
            bh:buffer-field("nItem"):buffer-value = nProd.

        ASSIGN vTabela  = vh:name
               Importar = yes
               rid      = bh:rowid.
     END.

     if importar and hc:subtype = "text" then do:

        if bh:find-by-rowid(rid) then do:
           fh = bh:buffer-field(vh:name) no-error.
           if valid-handle(fh) then 
               fh:buffer-value = hc:node-value.
        END.
     END.
     run obtemnode (input hc:handle).
  END.

  if valid-handle(vh) and lookup(vh:name,tabelas) > 0 then 
     ASSIGN importar = no.
END PROCEDURE.
                                             
PROCEDURE pi-atualiza-Docto-TSS :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE c-serie                AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-cgc                  AS CHARACTER   NO-UNDO.
    
    EMPTY TEMP-TABLE RowErrors               NO-ERROR.
    
    DEFINE VARIABLE r-mdfe-docto AS ROWID       NO-UNDO.

    ASSIGN r-mdfe-docto = ROWID(mdfe-docto).

    FIND FIRST mdfe-ret 
         WHERE mdfe-ret.cod-estab    = mdfe-docto.cod-estab    
           AND mdfe-ret.cod-ser-mdfe = mdfe-docto.cod-ser-mdfe 
           AND mdfe-ret.cod-num-mdfe = mdfe-docto.cod-num-mdfe 
           AND mdfe-ret.cod-msg      = cStat 
           AND mdfe-ret.dat-ret      = TODAY                         
           AND mdfe-ret.hra-ret      = REPLACE(STRING(TIME, "HH:MM:SS"),":","") NO-LOCK NO-ERROR.
    IF NOT AVAIL mdfe-ret THEN DO:
        CREATE mdfe-ret.
        ASSIGN mdfe-ret.cod-estab    = mdfe-docto.cod-estab   
               mdfe-ret.cod-ser-mdfe = mdfe-docto.cod-ser-mdfe
               mdfe-ret.cod-num-mdfe = mdfe-docto.cod-num-mdfe
               mdfe-ret.cod-msg      = cStat
               mdfe-ret.dat-ret      = TODAY
               mdfe-ret.hra-ret      = REPLACE(STRING(TIME, "HH:MM:SS"),":","")
               mdfe-ret.cod-livre-2  = cxMotivo
               mdfe-ret.cod-livre-1  = cProtocolo
               mdfe-ret.cod-livre-3  = c-seg-usuario.
    END.

    FOR FIRST bf-mdfe-docto EXCLUSIVE-LOCK
        WHERE ROWID(bf-mdfe-docto) = p-rowid-mdfe:
    
        IF  bf-mdfe-docto.idi-sit-mdfe = 4 OR
            bf-mdfe-docto.idi-sit-mdfe = 5 THEN
            RETURN "OK":U.
    
        IF cStat = "1" THEN 
           ASSIGN bf-mdfe-docto.idi-sit-mdfe = 8.
    
        IF mdfe-ret.cod-msg = "100":U  THEN DO:  /*100 Uso Autorizado */
           ASSIGN bf-mdfe-docto.idi-sit-mdfe = 2
                  bf-mdfe-docto.cod-protoc-autoriz = cProtocolo
                  bf-mdfe-docto.dat-autoriz = TODAY
                  bf-mdfe-docto.hra-autoriz = REPLACE(STRING(TIME, "HH:MM:SS"), ":", "").
        END.
    
        IF  bf-mdfe-docto.idi-sit-mdfe = 8 
        AND (mdfe-ret.cod-msg = "101" OR
             mdfe-ret.cod-msg = "135") THEN DO:
            ASSIGN bf-mdfe-docto.idi-sit-mdfe = 4
                   bf-mdfe-docto.dat-cancel = TODAY
                   bf-mdfe-docto.hra-cancel = REPLACE(STRING(TIME, "HH:MM:SS"), ":", "").
        END.
    
        IF  bf-mdfe-docto.idi-sit-mdfe = 9 
        AND (mdfe-ret.cod-msg = "132" OR mdfe-ret.cod-msg = "135") THEN DO:
            ASSIGN bf-mdfe-docto.idi-sit-mdfe = 5
                   bf-mdfe-docto.dat-cancel = TODAY
                   bf-mdfe-docto.hra-cancel = REPLACE(STRING(TIME, "HH:MM:SS"), ":", "").
            
        END.
    
        /*Rejeiªío Contingºncia*/
        IF  mdfe-ret.cod-msg = "108"  /*Serviªo Paralisado Momentaneamente (curto prazo)         */
        OR  mdfe-ret.cod-msg = "109"  /*Serviªo Paralisado sem Previsío                          */
        THEN 
            ASSIGN bf-mdfe-docto.idi-sit-mdfe = 3.
        
        IF ((mdfe-ret.cod-msg >= "200":U   AND
             mdfe-ret.cod-msg <= "299":U)  OR
            (mdfe-ret.cod-msg >= "400":U   AND
             mdfe-ret.cod-msg <= "999":U)) THEN
           ASSIGN bf-mdfe-docto.idi-sit-mdfe = IF bf-mdfe-docto.idi-sit-mdfe = 8 OR bf-mdfe-docto.idi-sit-mdfe = 9 THEN 2 ELSE 3.
    
        IF  (bf-mdfe-docto.idi-sit-mdfe = 2 OR bf-mdfe-docto.idi-sit-mdfe = 3) AND
            bf-mdfe-docto.dat-cancel <> ? THEN DO:
            ASSIGN bf-mdfe-docto.idi-sit-mdfe = 8. /* Em processo de cancelamento */
        END.
    END.

    RELEASE bf-mdfe-docto NO-ERROR.
END PROCEDURE.
