/********************************************************************************************************        
*Programa.: wsinventti0008.p                                                                            * 
*Descricao: Buscas os XMLs de entrada  na Inventti                                                      *
*Autor....: Raimundo C. Soares                                                                          * 
*Data.....: 12/2022                                                                                     * 
*********************************************************************************************************/
//CURRENT-LANGUAGE = CURRENT-LANGUAGE.
DEF INPUT  PARAMETER p-cod-estabel LIKE estabelec.cod-estabel NO-UNDO.
DEF VAR  p-retonro-integracao   AS LONGCHAR NO-UNDO.
{int\wsinventti0000.i}


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

    def var hc as handle.
    def var loop  as int.

DEFINE VARIABLE h1Root         AS HANDLE      NO-UNDO.
DEF  VAR c-xml AS LONGCHAR NO-UNDO.
DEF var c-url                AS CHAR     NO-UNDO.

DEFINE VARIABLE m-aux         AS MEMPTR      NO-UNDO.
DEFINE VARIABLE i-pos-fim     AS INTEGER     NO-UNDO.
DEFINE VARIABLE i-pos-ini     AS INTEGER     NO-UNDO.
DEF VAR c-arq-nao-localizado  AS CHAR NO-UNDO.
DEF VAR v-arq-nao-localizado  AS CHAR NO-UNDO.
DEF VAR l-item                AS LOGICAL NO-UNDO.
DEF VAR l-retorno             AS LOGICAL NO-UNDO.
DEF VAR c-ChaveDaNota         AS CHAR NO-UNDO.
def var v-situacao            AS CHAR NO-UNDO.
def var v-Codigo              AS CHAR NO-UNDO.
def var v-descricao           AS CHAR NO-UNDO.
def var v-cStat               AS CHAR NO-UNDO.
DEF VAR nprod                 AS INT NO-UNDO.
DEF VAR i-pagina              AS INT NO-UNDO.
def var v-ChaveNFe             as char  no-undo.
def var v-Serie                as char  no-undo.
def var v-NumeroNotaFiscal     as char  no-undo.
def var v-CNPJEmissor          as char  no-undo.
def var v-xNome                as char  no-undo. 
def var v-IE                   as char  no-undo. 
def var v-dEmi                 as char  no-undo. 
def var v-tpNF                 as char  no-undo. 
def var v-vNF                  as char  no-undo. 
def var v-digVal               as char  no-undo. 
def var v-dhRecbto             as char  no-undo. 
def var v-SituacaoNFe          as char  no-undo. 
def var v-SituacaoConfirmacao  as char  no-undo. 
def var v-SituacaoXMLNFe       as char  no-undo. 
def var v-CNPJDestinatario     as char  no-undo. 
def var vTabela                as char  no-undo.
def var Importar               AS LOGICAL  no-undo.
def var rid                    AS ROWID  no-undo.
def var tabelas                as char  no-undo.
DEFINE VARIABLE hDoc           AS HANDLE      NO-UNDO.
DEFINE VARIABLE lc-xml         AS LONGCHAR    NO-UNDO.
DEF VAR hCascade01             AS HANDLE NO-UNDO.
DEF VAR i-cont                 AS INT NO-UNDO.
DEF VAR no-1                   AS INT  no-undo.
def var bh                     as handle  no-undo.
def var fh                     as handle  no-undo.
DEF VAR QuantidadeNotasDestinadas AS CHAR NO-UNDO.
DEF VAR i-QuantidadeNotasDestinadas AS INT NO-UNDO.
DEF VAR data-ref  AS DATE NO-UNDO.
DEF VAR c-teste AS CHAR NO-UNDO.
DEF VAR dt-aux     AS DATE NO-UNDO.
DEF VAR l-novo-dia AS LOGICAL NO-UNDO.
DEF VAR v-cont AS INT NO-UNDO.
//c-teste = "C:\temp\dados\teste-retorno-nfe-entrada.xml".
ASSIGN i-QuantidadeNotasDestinadas = 100.
i-pagina = 0.
DO : //WHILE i-QuantidadeNotasDestinadas >= 100:  vamos executa uma pagina por vez
 
   FIND FIRST estabelec
        WHERE estabelec.cod-estabel = p-cod-estabel
        NO-LOCK NO-ERROR.
       
   FIND FIRST es-param-int-nfe-entrada OF estabelec EXCLUSIVE-LOCK NO-ERROR.

   IF NOT AVAIL es-param-int-nfe-entrada THEN DO:
      CREATE es-param-int-nfe-entrada. 
      ASSIGN es-param-int-nfe-entrada.cod-estabel   = p-cod-estabel
             es-param-int-nfe-entrada.data-emissao  = TODAY - 1
             es-param-int-nfe-entrada.pagina        = 1
             es-param-int-nfe-entrada.qtd-registros = 0.
   END.


   IF es-param-int-nfe-entrada.data-emissao  < TODAY THEN
      ASSIGN es-param-int-nfe-entrada.data-emissao = TODAY
             i-pagina =  1.

   ELSE i-pagina = IF es-param-int-nfe-entrada.qtd-registros < 100 THEN es-param-int-nfe-entrada.pagina ELSE (es-param-int-nfe-entrada.pagina + 1).

   
   FIND FIRST es-param-int-nfe-entrada OF estabelec NO-LOCK NO-ERROR.
   ASSIGN dt-aux   = es-param-int-nfe-entrada.data-emissao.

   // MESSAGE 'i-pagina ' i-pagina SKIP 
         //         'dt-aux   ' dt-aux 
         //     VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
         //

   RUN int\wsinventti0003.p  (input estabelec.cod-estabel,
                             input '',      
                             input '',
                             INPUT '',
                             INPUT string(i-pagina),
                             INPUT 5, 
                             OUTPUT c-xml).

   //MESSAGE STRING(c-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

   FIND FIRST esp_integracao 
        WHERE  esp_integracao.id_integracao = 1
        NO-ERROR.
   
   FIND FIRST esp_servico_integracao
        WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao          
        AND   esp_servico_integracao.descricao = "Obter DF-e"
        NO-LOCK NO-ERROR.
   
   ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) .

   //MESSAGE STRING(c-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
   RUN int\wsinventti0001a.p  (INPUT  c-url, 
                              INPUT  c-xml,
                              OUTPUT v-retonro-integracao).
   
   ASSIGN p-retonro-integracao = v-retonro-integracao.
          lc-xml               = v-retonro-integracao.

   IF v-retonro-integracao <>  "" THEN do:

      ASSIGN  lc-xml = v-retonro-integracao.
      RUN pi-retiraTag(INPUT-OUTPUT lc-xml).

     
      CREATE X-DOCUMENT hDoc.
      CREATE X-NODEREF  hRoot.
      
      hDoc:LOAD("longchar",lc-xml,FALSE) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN 
          RETURN "ERROR-01".
      
      hDoc:GET-DOCUMENT-ELEMENT(hRoot). 

      EMPTY TEMP-TABLE NotaDestinada.
      ASSIGN tabelas = "NotaDestinada".

      RUN pi-node(INPUT hRoot,INPUT 'RecepcionarNotasDestinadasResposta',  INPUT 'QuantidadeNotasDestinadas'            ,INPUT 0,OUTPUT QuantidadeNotasDestinadas            ,OUTPUT l-retorno).  //IF l-retorno = YES THEN ASSIGN tt-nf-entrada.ChaveNFe             = v-ChaveNFe           .
      run obtemnode (input hRoot).

      ASSIGN i-QuantidadeNotasDestinadas = INT(QuantidadeNotasDestinadas) 
             i-cont                      = 0   NO-ERROR.

      ASSIGN data-ref = TODAY.
      FOR EACH NotaDestinada BREAK BY NotaDestinada.dEmi:

          
          i-cont = i-cont + 1.

          IF NotaDestinada.CNPJEmissor  BEGINS '79430682'  THEN NEXT.
          data-ref = DATE( int(substring(NotaDestinada.dEmi,6,2)),
                           int(substring(NotaDestinada.dEmi,9,2)),
                           int(substring(NotaDestinada.dEmi,1,4))).

         dt-aux = data-ref.
       //  DISP  p-cod-estabel
       //        data-ref
       //        NotaDestinada.Serie            
       //        NotaDestinada.NumeroNotaFiscal 
       //        NotaDestinada.CNPJEmissor      
       //        //NotaDestinada.dEmi  FORMAT "x(30)" 
       //        WITH SCROLLABLE.   PAUSE 0.  
              
         FIND FIRST es-nota-rec-inventi
              WHERE es-nota-rec-inventi.ChaveNFe         = NotaDestinada.ChaveNFe        
              AND   es-nota-rec-inventi.Serie            = NotaDestinada.Serie             
	          and   es-nota-rec-inventi.NumeroNotaFiscal = NotaDestinada.NumeroNotaFiscal  
	          and   es-nota-rec-inventi.CNPJEmissor      = NotaDestinada.CNPJEmissor     
              and   es-nota-rec-inventi.CNPJDestinatario = NotaDestinada.CNPJDestinatario
              EXCLUSIVE-LOCK NO-ERROR.
         
         IF NOT AVAIL es-nota-rec-inventi THEN DO:
         
            CREATE es-nota-rec-inventi.
            ASSIGN es-nota-rec-inventi.ChaveNFe               = NotaDestinada.ChaveNFe         
                   es-nota-rec-inventi.Serie                  = NotaDestinada.Serie            
                   es-nota-rec-inventi.NumeroNotaFiscal       = NotaDestinada.NumeroNotaFiscal 
                   es-nota-rec-inventi.CNPJEmissor            = NotaDestinada.CNPJEmissor      
                   es-nota-rec-inventi.CNPJDestinatario       = NotaDestinada.CNPJDestinatario 
                   es-nota-rec-inventi.xNome                  = NotaDestinada.xNome               
                   es-nota-rec-inventi.IE                     = NotaDestinada.IE                  
                   es-nota-rec-inventi.dEmi                   = NotaDestinada.dEmi                
                   es-nota-rec-inventi.tpNF                   = NotaDestinada.tpNF                
                   es-nota-rec-inventi.vNF                    = NotaDestinada.vNF                 
                   es-nota-rec-inventi.digVal                 = NotaDestinada.digVal              
                   es-nota-rec-inventi.dhRecbto               = NotaDestinada.dhRecbto            
                   es-nota-rec-inventi.SituacaoNFe            = NotaDestinada.SituacaoNFe         
                   es-nota-rec-inventi.SituacaoConfirmacao    = NotaDestinada.SituacaoConfirmacao 
                   es-nota-rec-inventi.SituacaoXMLNFe         = NotaDestinada.SituacaoXMLNFe.  
                   es-nota-rec-inventi.sit-integracao         = IF substring(NotaDestinada.ChaveNFe,7,8) =  '79430682' THEN 3 ELSE 0.
         END.
      END.
     
      IF i-QuantidadeNotasDestinadas <> i-cont THEN
         ASSIGN i-QuantidadeNotasDestinadas = i-cont.
     
   END.
END. // DO WHILE i-QuantidadeNotasDestinadas


 FIND FIRST es-param-int-nfe-entrada 
      WHERE es-param-int-nfe-entrada.cod-estabel = p-cod-estabel
      EXCLUSIVE-LOCK NO-ERROR.

 ASSIGN es-param-int-nfe-entrada.data-emissao  = TODAY
        es-param-int-nfe-entrada.pagina        = i-pagina
        es-param-int-nfe-entrada.qtd-registros = i-QuantidadeNotasDestinadas.

RELEASE es-param-int-nfe-entrada.
RELEASE es-nota-rec-inventi.

PROCEDURE piLoadXML :

    DEFINE INPUT  PARAMETER pc-nome-arquivo AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER hRoot           AS HANDLE    NO-UNDO.

    /* Lˆ arquivos dispon¥veis */
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

    /* Carrega o XML a partir da vari vel longchar lc-xml,
       depois de retirada as tags '<?xml'                  */
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF  hRoot.

    hDoc:LOAD("longchar",lc-xml,FALSE) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN 
        RETURN "ERROR-01".

    hDoc:GET-DOCUMENT-ELEMENT(hRoot). 

    RETURN "OK".

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
                                             

