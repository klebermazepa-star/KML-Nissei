/**********************************************************************        
*Programa.: wsinventti0005.p                                          * 
*Descricao: Trata retorno da Inventi                                  * 
*Autor....: Raimundo                                                  * 
*Data.....: 12/2022                                                   * 
**********************************************************************/

.MESSAGE "v6"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

{int\wsinventti0000.i}
{int\wsinventti0005.i}

DEF new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.


{utp/ut-glob.i}

def VAR raw-param as raw no-undo.

def var bo-cancela   as handle no-undo.

DEFINE TEMP-TABLE tt-param-ft2100 NO-UNDO
    FIELD destino           AS intEGER  
    FIELD arquivo           AS CHAR
    FIELD usuario           AS CHAR
    FIELD data-exec         AS date
    FIELD hora-exec         AS intEGER
    FIELD tipo-atual        AS intEGER   /* 1 - Atualiza, 2 - Desatualiza */
    FIELD c-desc-tipo-atual AS CHAR format "x(15)"
    FIELD da-emissao-ini    AS date format "99/99/9999"
    FIELD da-emissao-fim    AS date format "99/99/9999"
    FIELD da-saida          AS date format "99/99/9999"
    FIELD da-vencto-ipi     AS date format "99/99/9999"
    FIELD da-vencto-icms    AS date format "99/99/9999"
    FIELD da-vencto-iss     AS date format "99/99/9999"
    FIELD c-estabel-ini     AS CHAR
    FIELD c-estabel-fim     AS CHAR
    FIELD c-serie-ini       AS CHAR
    FIELD c-serie-fim       AS CHAR
    FIELD c-nr-nota-ini     AS CHAR
    FIELD c-nr-nota-fim     AS CHAR
    FIELD de-embarque-ini   AS DEC
    FIELD de-embarque-fim   AS DEC
    FIELD c-preparador      AS CHAR
    FIELD l-disp-men        AS LOG
    FIELD l-b2b             AS LOG
    FIELD log-1             AS LOG.

def temp-table tt-raw-digita NO-UNDO
        field raw-digita	as raw.

DEF INPUT PARAMETER p-retonro-integracao AS LONGCHAR NO-UNDO.
DEF INPUT PARAMETER p-rowid-nota-fiscal  AS ROWID NO-UNDO.
v-retonro-integracao =  p-retonro-integracao.
DEF VAR protocolo AS CHAR NO-UNDO.
DEF VAR c-status  AS CHAR NO-UNDO . 
DEF VAR v-xmotivo AS CHAR NO-UNDO.
DEF VAR l-atualizou AS LOGICAL NO-UNDO.

//MESSAGE STRING(v-retonro-integracao) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE "0005".
DEF VAR c-xml AS CHAR.
DEF VAR l-xml AS LONGCHAR NO-UNDO.
def var tabelas     as char.
DEF VAR nprod                 AS INT NO-UNDO.

DEF TEMP-TABLE tt1-protocolo NO-UNDO 
    field protocolo as char  
    field c-status  as char  
    field v-xmotivo as char.  

DEFINE VARIABLE h1Root         AS HANDLE      NO-UNDO.
DEF VAR no-1       AS INT.     
def var bh          as handle. 
def var fh          as handle. 
def var hc as handle.
def var h1c as handle.
def var loop  as int.
DEF VAR  i-cont AS INT NO-UNDO.
def var vTabela               as CHAR        no-undo.
def var Importar              AS LOGICAL     no-undo.
def var rid                   AS ROWID       no-undo.
DEFINE VARIABLE m-aux         AS MEMPTR      NO-UNDO.
DEFINE VARIABLE i-pos-fim     AS INTEGER     NO-UNDO.
DEFINE VARIABLE i-pos-ini     AS INTEGER     NO-UNDO.
DEF VAR c-arqaux              AS CHAR        NO-UNDO.
DEFINE VARIABLE hXML1   AS HANDLE NO-UNDO.

DEFINE VARIABLE mem-aux AS MEMPTR      NO-UNDO.
DEFINE VARIABLE lc-aux  AS LONGCHAR    NO-UNDO.
DEFINE VARIABLE tipo-nota AS CHARACTER   NO-UNDO.


DEFINE BUFFER b-nota-fiscal FOR nota-fiscal.

.MESSAGE "int005"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

ASSIGN tabelas = "ide,emit,dest,prod,icms,ipi,pis,cofins,total,transporta,vol,dup,infProt,infAdic,transp,ICMSUFDest,infEventoo,sefaz,nota"  /* Tabelas a serem importadas */
       no-1  = 1
       v-retonro-integracao  = p-retonro-integracao .

 IF v-retonro-integracao <> '' THEN do:
 .MESSAGE "1"
     VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
 
    CREATE X-DOCUMENT hXML1.
    CREATE X-NODEREF hRoot.
              
    hXML1:LOAD('LONGCHAR':U, v-retonro-integracao , FALSE).
    hXML1:GET-DOCUMENT-ELEMENT(hRoot).

    ASSIGN Parentname = 'RecepcionarConsultaNotaResposta'.
    CREATE tt-nota-aux.

    RUN process-children( INPUT hRoot ).

    DELETE OBJECT hXML1.
    DELETE OBJECT hRoot.
    
    FIND FIRST tt-nota-aux NO-ERROR.

    IF AVAIL tt-nota-aux THEN do:

        .MESSAGE "2 - v-idi-sit-nf-eletro - "v-idi-sit-nf-eletro SKIP
                protocolo SKIP
                tt-nota-aux.descricao SKIP
                tt-nota-aux.xMotivo SKIP
                tt-nota-aux.cStat SKIP
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

       CASE int(tt-nota-aux.situacao):
           When 1  then  assign v-idi-sit-nf-eletro = 2  cMensagem = "Recebida".
           When 2  then  assign v-idi-sit-nf-eletro = 2  cMensagem = "Validada".
           When 3  then  assign v-idi-sit-nf-eletro = 2  cMensagem = "Critica validacao".
           When 4  then  assign v-idi-sit-nf-eletro = 9  cMensagem = "Enviada SEFAZ".
           When 6  then  assign v-idi-sit-nf-eletro = 3  cMensagem = "100 - Autorizado o uso sa NFE".
           When 7  then  assign v-idi-sit-nf-eletro = 4  cMensagem = 'Uso denegado'.  
           When 8  then  assign v-idi-sit-nf-eletro = 5  cMensagem = "Documento Rejeitado".
           When 9  then  assign v-idi-sit-nf-eletro = 6  cMensagem = "'Documento Cancelado".
           When 10 then  assign v-idi-sit-nf-eletro = 10 cMensagem = "Pendente Retorno Contingància".
           When 11 then  assign v-idi-sit-nf-eletro = 12 cMensagem = "NF-e em Processo de Cancelamento".
           When 12 then  assign v-idi-sit-nf-eletro = 13 cMensagem = "NF-e em Processo de Inutilizaá∆o".
           When 13 then  assign v-idi-sit-nf-eletro = 7  cMensagem = "Documento Inutilizado".
           When 40 then  assign v-idi-sit-nf-eletro = 10 cMensagem = "Enviada EPEC".
           When 41 then  assign v-idi-sit-nf-eletro = 15 cMensagem = "Registrada EPEC".
           When 90 then  assign v-idi-sit-nf-eletro = 14 cMensagem = "Pendente Retorno SEFAZ".
           When 91 then  assign v-idi-sit-nf-eletro = 1  cMensagem = "N∆o Localizada".
           When 92 then  assign v-idi-sit-nf-eletro = 8  cMensagem = "Pendente consulta SEFAZ".
           When 99 then  assign v-idi-sit-nf-eletro = 4  cMensagem = "Duplicada Emiss∆o".
       END CASE.

      

       FIND FIRST nota-fiscal  
            WHERE rowid(nota-fiscal) = p-rowid-nota-fiscal 
            NO-LOCK NO-ERROR.
            
       .MESSAGE "0:  " nota-fiscal.nr-embarque VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       
       IF AVAIL nota-fiscal THEN do:
       
        .MESSAGE "0.1" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.    
       
       
            // KML - Correá∆o para fazer cancelamento da forma correta
        IF v-idi-sit-nf-eletro = 6 OR (v-idi-sit-nf-eletro = 7)THEN DO:
        
            .MESSAGE "1" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
            FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
                    WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.
    
            IF AVAIL b-nota-fiscal  THEN DO:
            
                ASSIGN b-nota-fiscal.idi-sit-nf-eletro        = 3. //KML - Foráo autorizaá∆o para a API conseguir cancelar a nota fiscal.
            END.
            RELEASE b-nota-fiscal.

          //  run pi-desatualiza-ft2100.

            run dibo/bodi135cancel.p persistent set bo-cancela.

            run cancelaNotaFiscal in bo-cancela (input nota-fiscal.cod-estabel,
                                                 input nota-fiscal.serie,
                                                 input nota-fiscal.nr-nota-fis,
                                                 input TODAY,
                                                 input "Cancelamento autorizado junto a sefaz",
                                                 input YES,
                                                 input NO,
                                                 input YES,
                                                 input SESSION:TEMP-DIRECTORY + "ft2200.tmp",
                                                 INPUT c-seg-usuario).
             
            .MESSAGE "2" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. 
             
            // KML - Correá∆o para poder reabrir o embarque quando fizer o cancelamento 
            IF v_cdn_empres_usuar = "10" THEN DO:  // Apenas usuario conectado aos bancos merco
            
                FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
                    WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.
                
                MESSAGE "nr-embarque: " nota-fiscal.cdd-embarq
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                        
            
                .MESSAGE "3 " SKIP b-nota-fiscal.nr-nota-fis SKIP b-nota-fiscal.nr-embarque VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
                FOR EACH pre-fatur EXCLUSIVE-LOCK
                    WHERE pre-fatur.cdd-embarq = b-nota-fiscal.cdd-embarq 
                    AND pre-fatur.nr-resumo  = 1:
                    
                    .MESSAGE "Entrou pre-fatur" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                    
                    ASSIGN pre-fatur.cod-sit-pre = 1.
                    
                    FOR EACH ped-item 
                        WHERE  ped-item.nr-pedcli    = b-nota-fiscal.nr-pedcli
                        :
                        
                        FOR EACH ped-ent 
                            WHERE  ped-ent.it-codigo    = ped-item.it-codigo
                            :
                            
                            FOR EACH res-item 
                                WHERE  res-item.it-codigo    = ped-ent.it-codigo
                                :
                                
                                .MESSAGE "Entrou qt-alocada = 0" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                
                                ASSIGN  res-item.qt-alocada     = 0
                                        ped-item.qt-log-aloca   = 0
                                        ped-ent.qt-log-aloca    = 0.
                                
                            END.
                        END.
                    END.
                END. 
            END.
            
            

            IF nota-fiscal.dt-atualiza <> ?  THEN DO:
                run pi-desatualiza-ft2100.
            END.

            FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
                WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.

            IF AVAIL b-nota-fiscal THEN DO:
                assign b-nota-fiscal.dt-cancela   = TODAY
                       b-nota-fiscal.ind-sit-nota = 4.
            END.

            RELEASE b-nota-fiscal.

            for each it-nota-fisc EXCLUSIVE-LOCK of nota-fiscal:

                FIND doc-fiscal WHERE
                     doc-fiscal.cod-emitente = nota-fiscal.cod-emitente  AND
                     doc-fiscal.nr-doc-fis   = nota-fiscal.nr-nota-fis   AND
                     doc-fiscal.serie        = nota-fiscal.serie         AND
                     doc-fiscal.nat-operacao = it-nota-fisc.nat-operacao AND
                     doc-fiscal.cod-estabel  = nota-fiscal.cod-estabel
                     EXCLUSIVE-LOCK NO-ERROR.
        
                IF AVAIL doc-fiscal THEN DO:
        
                    ASSIGN doc-fiscal.ind-sit-doc = 2.
                END.
                RELEASE doc-fiscal.

                assign it-nota-fisc.dt-cancela  = nota-fiscal.dt-cancela
                        it-nota-fisc.dt-confirma = nota-fiscal.dt-confirma.
            end.

            RELEASE it-nota-fisc.

            run pi-altera-docum-est.

            RUN ftp/ft0911.p (rowid(nota-fiscal), "101", nota-fiscal.cod-protoc).
            
            IF v_cdn_empres_usuar = "1" THEN // Apenas usuario conectado aos bancos Nissei
                RUN intprg/int301-cancela.r ( INPUT ROWID(nota-fiscal)). // Envio de cancelamento notas para datahub

        END.
     


        FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
                WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.

        IF AVAIL b-nota-fiscal  THEN DO:

            .MESSAGE b-nota-fiscal.cod-chave-aces-nf-eletro SKIP
                    "TT-nota" SKIP
                    tt-nota-aux.ChaveDaNota SKIP 
                    "inventti0005"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                                                 
            ASSIGN b-nota-fiscal.cod-protoc               = IF protocolo <> '' THEN protocolo ELSE nota-fiscal.cod-protoc
                   b-nota-fiscal.idi-sit-nf-eletro        = v-idi-sit-nf-eletro //rejeitada
                   //b-nota-fiscal.cod-chave-aces-nf-eletro = tt-nota-aux.ChaveDaNota.
                .
                
                
           
           //Bloco de envio notas para o HUB/VNDA    
            IF v_cdn_empres_usuar = "1" THEN DO:  // Apenas usuario conectado aos bancos Nissei
            
                IF v-idi-sit-nf-eletro = 3 OR v-idi-sit-nf-eletro = 6 THEN   // Envia somente autorizadas e canceladas
                DO:
                    
                
                    FIND FIRST ems2mult.estabelec NO-LOCK
                        WHERE estabelec.cod-estabel = b-nota-fiscal.cod-estabel NO-ERROR.
                        
                    FIND FIRST natur-oper NO-LOCK
                        WHERE natur-oper.nat-operacao = b-nota-fiscal.nat-operacao NO-ERROR. 
                    
                    IF AVAIL estabelec AND
                       estabelec.ep-codigo =  "1" THEN DO:   // Apenas nota de estabelecimento VNDA
                       
                        IF natur-oper.especie-doc = "NFS" AND natur-oper.transf = NO AND natur-oper.tipo = 2 AND natur-oper.cod-mensagem = 2 THEN
                        DO:
                        
                            ASSIGN tipo-nota = "Saida-Transferencia".
                
                        END.
                       
                        IF natur-oper.especie-doc = "NFT" AND natur-oper.transf = YES AND natur-oper.tipo = 2 THEN
                        DO:
                        
                            ASSIGN tipo-nota = "Saida-Transferencia".
                
                        END.
                                           
                        ELSE IF natur-oper.especie-doc = "NFD" AND natur-oper.transf = NO AND natur-oper.tipo = 2 THEN
                        DO:
                        
                            ASSIGN tipo-nota = "Saida-DevolucaoCompra".
  
                        END.
                        
                         ELSE IF natur-oper.especie-doc = "NFS" AND natur-oper.transf = NO AND natur-oper.tipo = 2 AND natur-oper.cod-mensagem = 7 THEN
                        DO:
                        
                            ASSIGN tipo-nota = "Saida-Transferencia".
  
                        END.
      
                        ELSE IF natur-oper.especie-doc = "NFD" AND natur-oper.transf = NO AND natur-oper.tipo = 1  THEN
                        DO:
                        
                            FIND FIRST it-nota-fisc OF nota-fiscal NO-LOCK NO-ERROR.
                            
                            IF it-nota-fisc.nr-docum <> "" THEN
                            DO:
                            
                                 ASSIGN tipo-nota = "Entrada-DevolucaoVenda".
                                
                            END.
                               
                        END.              
                        
                        IF (b-nota-fiscal.serie <> "402" AND b-nota-fiscal.cod-estabel = "139" OR b-nota-fiscal.nome-ab-cli = "NISSEI 139") THEN
                        DO:
                        
                            RUN intprg/int301rp.r (INPUT "Saida" ,
                                                   INPUT tipo-nota ,
                                                   INPUT ROWID(b-nota-fiscal)). // Envio de notas para datahub (VNDA)
                                                   
                        END.
                        
                        IF b-nota-fiscal.cod-estabel = "139" AND b-nota-fiscal.nome-ab-cli = "DN CD ADM" THEN
                        DO:
                        
                            RUN intprg/int301rp.r (INPUT "Saida" ,
                                                   INPUT tipo-nota ,
                                                   INPUT ROWID(b-nota-fiscal)). // Envio de notas para datahub (VNDA)
                                                   
                        END.
                        
                    END.
                END.
            END.    
                
                     
            // KML - Kleber Mazepa - 20/01/2025 - Envio de nota para o Datahub
            IF v_cdn_empres_usuar = "10" THEN DO:  // Apenas usuario conectado aos bancos merco
            
                IF v-idi-sit-nf-eletro = 3 OR v-idi-sit-nf-eletro = 6 THEN   // Envia somente autorizadas e canceladas
                DO:
                    
                
                    FIND FIRST ems2mult.estabelec NO-LOCK
                        WHERE estabelec.cod-estabel = b-nota-fiscal.cod-estabel NO-ERROR.
                    
                    IF AVAIL estabelec AND
                       estabelec.ep-codigo =  "10" THEN DO:   // Apenas nota de estabelecimento merco
                       
                            RUN custom\eswms004.r (INPUT "Saida" ,
                                                   INPUT "SAIDA - VENDA" ,
                                                   INPUT ROWID(b-nota-fiscal)). // Envio de notas para datahub (MERCO)     
                    END.
                END.
            END.
           
            .MESSAGE  "Depois da assign"
                b-nota-fiscal.cod-chave-aces-nf-eletro SKIP
                "inventti0005"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.


        END.
        RELEASE b-nota-fiscal.

          if nota-fiscal.ind-tip-nota = 8 then
             RUN pi-atualiza-recebimento.
          

          IF int(tt-nota-aux.situacao) = 8 OR int(tt-nota-aux.situacao) = 3 THEN DO:  // Rejeitada ou criticada

              .MESSAGE "rejeitada ou criticada"
                  VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

             FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
                    WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.

             IF AVAIL b-nota-fiscal THEN
                ASSIGN b-nota-fiscal.idi-sit-nf-eletro = 5. // Marcar como rejeitada
             RELEASE b-nota-fiscal.

             FIND FIRST ext-nota-fiscal-danfe
                  WHERE ext-nota-fiscal-danfe.cod-estabel = nota-fiscal.cod-estabel
                  AND   ext-nota-fiscal-danfe.serie       = nota-fiscal.serie      
                  AND   ext-nota-fiscal-danfe.nr-nota-fis = nota-fiscal.nr-nota-fis
                  EXCLUSIVE-LOCK NO-ERROR.
          
             IF NOT AVAIL ext-nota-fiscal-danfe THEN DO:
             
                CREATE ext-nota-fiscal-danfe.
                ASSIGN ext-nota-fiscal-danfe.cod-estabel = nota-fiscal.cod-estabel
                       ext-nota-fiscal-danfe.serie       = nota-fiscal.serie      
                       ext-nota-fiscal-danfe.nr-nota-fis = nota-fiscal.nr-nota-fis.
             END.
          
             COPY-LOB p-retonro-integracao TO mem-aux.
             ASSIGN lc-aux = BASE64-ENCODE(mem-aux).
             COPY-LOB lc-aux TO ext-nota-fiscal-danfe.doc-danfe.
             COPY-LOB lc-aux TO ext-nota-fiscal-danfe.doc-xml.
             RELEASE ext-nota-fiscal.


             FOR EACH int_ndd_envio
                 where /*int_ndd_envio.STATUSNUMBER = 0 
                 and*/   int_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel     
                 and   int_ndd_envio.serie        = nota-fiscal.serie          
                 and   int_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis    
                 EXCLUSIVE-LOCK:

                 IF int_ndd_envio.protocolo = ""  OR  int_ndd_envio.protocolo = ? THEN
                    ASSIGN int_ndd_envio.protocolo = IF protocolo <> '' THEN protocolo ELSE nota-fiscal.cod-protoc.
                 
                 ASSIGN int_ndd_envio.STATUSNUMBER = 1.
                 // run pi-consultarProtocolo. ver essa rotina depois
                 
             END.
             RELEASE int_ndd_envio.

             ASSIGN cMensagem = trim(tt-nota-aux.cstat) + " - " + trim(tt-nota-aux.descricao) + " - " + TRIM(tt-nota-aux.xMotivo)
                    cCodigoErro = trim(tt-nota-aux.cstat).

             CREATE  tt1-protocolo.
             ASSIGN  tt1-protocolo.protocolo = protocolo 
                     tt1-protocolo.c-status  = c-status 
                     tt1-protocolo.v-xmotivo = v-xmotivo.

             RUN pi-cria-ret-nf-eletro(input nota-fiscal.cod-estabel,
                                       input nota-fiscal.serie,       
                                       input nota-fiscal.nr-nota-fis,
                                       INPUT nota-fiscal.cod-protoc).
             l-atualizou = YES.

          END.  //IF int(tt-nota-aux.situacao) = 8

       END. //IF AVAIL nota-fiscal
       RELEASE nota-fiscal.
    END.   //IF AVAIL tt-nota-aux 
      
    
    .MESSAGE "ponto 2"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    CREATE X-DOCUMENT  hXML.
    CREATE X-NODEREF hRoot.

    v-retonro-integracao  = p-retonro-integracao.
    hXML:LOAD('LONGCHAR':U, v-retonro-integracao , FALSE).
    hXML:GET-DOCUMENT-ELEMENT(hRoot).

    EMPTY TEMP-TABLE infprot.
    EMPTY TEMP-TABLE infEvento.

    
    run obtemnode (input hRoot).
    
    DELETE OBJECT hRoot.
    
    FOR EACH  tt-evento-xml-retornado:


        .MESSAGE "entrou for each" SKIP
                int(tt-nota-aux.situacao) 
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
         
        
        IF tt-evento-xml-retornado.arquivo MATCHES "*lei*" THEN NEXT.
        .MESSAGE "KML" SKIP
                'tt-evento-xml-retornado.arquivo' SKIP tt-evento-xml-retornado.arquivo VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        RUN piLoadXML (INPUT tt-evento-xml-retornado.arquivo,
                       OUTPUT hRoot).
    
        run obtemnode (input hRoot).
        DELETE OBJECT hRoot.

        RUN pi-atualiza.
       
    
    END. //FOR EACH  tt-evento-xml-retornado
 END. //v-retonro-integracao <> ""

 //FOR EACH nodes:
 //    DISP  nodes WITH SCROLLABLE.
 //
 //END.

PROCEDURE piLoadXML :

  DEFINE INPUT  PARAMETER pc-nome-arquivo AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER hRoot           AS HANDLE    NO-UNDO.

  DEFINE VARIABLE hDoc   AS HANDLE      NO-UNDO.
  DEFINE VARIABLE lc-xml AS LONGCHAR    NO-UNDO.

  IF SEARCH(pc-nome-arquivo) = ? THEN do:
      RETURN "NOK".
  END.
  
  FILE-INFO:FILE-NAME = pc-nome-arquivo.
  SET-SIZE(m-aux) = FILE-INFO:FILE-SIZE.
  INPUT FROM VALUE(pc-nome-arquivo) BINARY NO-CONVERT.
  IMPORT UNFORMATTED m-aux.
  
  COPY-LOB m-aux TO lc-xml.
  RUN pi-retiraTag(INPUT-OUTPUT lc-xml).
  ASSIGN lc-aux = lc-xml.

  
  CREATE X-DOCUMENT hDoc.
  CREATE X-NODEREF  hRoot.
  
  hDoc:LOAD("longchar",lc-xml,FALSE) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN 
      RETURN "ERROR-01".

  hDoc:GET-DOCUMENT-ELEMENT(hRoot). 

  RETURN "OK".

END PROCEDURE.


PROCEDURE pi-retiraTag :

  DEFINE INPUT-OUTPUT PARAMETER pc-xml AS LONGCHAR.
  
  DEFINE VARIABLE c-xml-aux AS LONGCHAR       NO-UNDO.
  DEFINE VARIABLE c-tag AS CHARACTER          NO-UNDO.
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

PROCEDURE obtemnode:                

  def input parameter vh as handle.
  DEFINE VARIABLE c-xml-aux AS LONGCHAR            NO-UNDO.
  DEFINE VARIABLE c1-xml-aux AS LONGCHAR           NO-UNDO.
  DEFINE VARIABLE c-tag      AS CHARACTER          NO-UNDO.
  DEFINE VARIABLE i-ini      AS INTEGER INITIAL 0  NO-UNDO.
  DEFINE VARIABLE i-fim      AS INTEGER INITIAL 0  NO-UNDO.
  DEF VAR c-nome-arquivo     AS CHAR               NO-UNDO.
  def var hc                 as handle             no-undo.
  def var loop               as INT                no-undo.
 
  create x-noderef hc.
  
  IF vh:NAME = '#cdata-section' THEN DO:
      
      
     ASSIGN l-xml = vh:NODE-VALUE NO-ERROR.
     c-xml = vh:NODE-VALUE NO-ERROR.
                 
                 
     //MESSAGE STRING(l-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE 'l-xml'.

     RUN pi-retiraTag(INPUT-OUTPUT l-xml).

     IF INDEX(l-xml, '<![CDATA') > 1 THEN do:

         
        ASSIGN c-xml-aux  = SUBSTRING(l-xml,INDEX(l-xml, '<![CDATA') + 8).
               c-xml-aux  = REPLACE(REPLACE(c-xml-aux, '[',""), ']',"").
               c1-xml-aux = SUBSTRING(l-xml,1,INDEX(l-xml, '<![CDATA')).
               c1-xml-aux = SUBSTRING(c1-xml-aux,INDEX(c1-xml-aux, '=') + 2 ).
               c1-xml-aux = SUBSTRING(c1-xml-aux,1,INDEX(c1-xml-aux, '.xml') + 3).
  
        ASSIGN l-xml = c-xml-aux
               c-arqaux = SESSION:TEMP-DIRECTORY + trim(string(c1-xml-aux)) //SESSION:TEMP-DIRECTOR + trim(string(c1-xml-aux))
               c-nome-arquivo = trim(string(c1-xml-aux)).
  
        //MESSAGE c-nome-arquivo VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        FIND FIRST tt-evento-xml-retornado
             WHERE tt-evento-xml-retornado.nome-arquivo = c-nome-arquivo 
             NO-ERROR.
  
        IF NOT AVAIL tt-evento-xml-retornado THEN DO:
           CREATE tt-evento-xml-retornado.
           ASSIGN tt-evento-xml-retornado.seq          = no-1
                  tt-evento-xml-retornado.nome-arquivo = c-nome-arquivo 
                  tt-evento-xml-retornado.arquivo      = c-arqaux.
                  
                  no-1 = no-1 + 1.

                  //MESSAGE STRING(l-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE '005 l-xml'.
           COPY-LOB l-xml TO FILE c-arqaux NO-ERROR.
        END.
     END. //IF INDEX(l-xml, '<![CDATA') > 1 THEN
  END. //IF vh:NAME = '#cdata-section' THEN

  //MESSAGE 300 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  do loop = 1 to vh:num-children.
      
     vh:get-child(hc,loop).
     
     if vh:NAME = 'nProt'   then do:
         CREATE X-NODEREF  h1c.
        vh:GET-CHILD(h1c,1).
        assign protocolo  = IF h1c:NODE-VALUE <> '' THEN h1c:NODE-VALUE ELSE protocolo . 
        DELETE OBJECT  h1c.
     END.

     if vh:NAME = 'cStat'   then do: 
         CREATE X-NODEREF  h1c.
        vh:GET-CHILD(h1c,1). 
        assign c-status   = h1c:node-value. 
        DELETE OBJECT  h1c.
     END.

     if vh:NAME = 'xMotivo'   then do: 
         CREATE X-NODEREF  h1c.
        vh:GET-CHILD(h1c,1). 
        assign v-xmotivo   = h1c:node-value. 
        DELETE OBJECT  h1c.
     END.

     //MESSAGE 'vh:NAME ' vh:NAME VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
     if loop = 1 AND lookup(vh:name,tabelas) > 0   then do:

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
  END. //do loop
  
  if valid-handle(vh) and lookup(vh:name,tabelas) > 0 then 
     ASSIGN importar = no.
  
END PROCEDURE.


PROCEDURE process-children:
    DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.

    DEFINE VARIABLE hChild AS HANDLE NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.

    ASSIGN iLevel = iLevel + 1.

    IF iLevel = 2 THEN do:
       ASSIGN c-nome-temp-table = hParent:NAME
              i-sequencia       = 0.
    END.

    
    CREATE X-NODEREF hChild.
    
    ASSIGN i-sequencia = i-sequencia + IF iLevel > 2 THEN 1 ELSE 0.
    CREATE nodes.
    ASSIGN nodes.NAME            = hParent:NAME
           nodes.PARENT          = Parentname
           nodes.level           = iLevel
           nodes.name-temp-table = IF iLevel > 2 THEN c-nome-temp-table ELSE ""
           nodes.seq-taq         = i-sequencia.
    RUN processAttributes( INPUT hParent ).

    DO i = 1 TO hParent:NUM-CHILDREN :
      
       hParent:GET-CHILD(hChild,i).
       IF hChild:NAME = "#text" THEN DO:
            ASSIGN nodes.nodevalue = hChild:NODE-VALUE. 
            
            CASE hParent:NAME:
               when "SituacaoOperacao" THEN ASSIGN tt-nota-aux.SituacaoOperacao = hChild:NODE-VALUE. 
               when "Status"           THEN ASSIGN tt-nota-aux.situacao         = hChild:NODE-VALUE. 
               WHEN "Descricao"        THEN ASSIGN tt-nota-aux.Descricao        = hChild:NODE-VALUE. 
               WHEN "ChaveDaNota"      THEN ASSIGN tt-nota-aux.ChaveDaNota      = hChild:NODE-VALUE. 
               WHEN 'xmotivo'          THEN ASSIGN tt-nota-aux.xmotivo          = hChild:NODE-VALUE. 
               WHEN 'nProt'            THEN ASSIGN tt-nota-aux.nProt           = hChild:NODE-VALUE. 
               WHEN 'cStat'            THEN ASSIGN tt-nota-aux.cstat            = hChild:NODE-VALUE.  
           END CASE.
          
       END.
       ELSE DO:
          parentname = hParent:NAME.
         RUN process-children( INPUT hChild ).
       END.
    END.

    ASSIGN iLevel = iLevel - 1.
    DELETE OBJECT hChild.
END PROCEDURE.

PROCEDURE processAttributes.

  DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
  DEFINE VARIABLE cAttribute AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i AS INTEGER NO-UNDO.
  DEFINE BUFFER nodes FOR nodes.

  DO i = 1 TO NUM-ENTRIES(hParent:ATTRIBUTE-NAMES) TRANSACTION:
     cAttribute = entry(i,hParent:ATTRIBUTE-NAMES).
     ASSIGN i-sequencia = i-sequencia + IF iLevel > 3 THEN 1 ELSE 0.
     CREATE nodes.
     ASSIGN nodes.NAME = cAttribute
            nodes.PARENT = hParent:NAME
            nodes.nodevalue = hParent:GET-ATTRIBUTE(cAttribute)
            /*nodes.name-temp-table = IF iLevel > 2 THEN c-nome-temp-table ELSE ""
            nodes.seq-taq  = i-sequencia.*/
            nodes.level    = iLevel + 1.
  END.
END PROCEDURE.

PROCEDURE pi-atualiza:

    FIND FIRST nota-fiscal  
         WHERE rowid(nota-fiscal) = p-rowid-nota-fiscal 
         NO-LOCK NO-ERROR.

    IF AVAIL nota-fiscal THEN do:

       FIND FIRST ext-nota-fiscal-danfe
            WHERE ext-nota-fiscal-danfe.cod-estabel = nota-fiscal.cod-estabel
            AND   ext-nota-fiscal-danfe.serie       = nota-fiscal.serie      
            AND   ext-nota-fiscal-danfe.nr-nota-fis = nota-fiscal.nr-nota-fis
            EXCLUSIVE-LOCK NO-ERROR.
       
       IF NOT AVAIL ext-nota-fiscal-danfe THEN DO:
       
          CREATE ext-nota-fiscal-danfe.
          ASSIGN ext-nota-fiscal-danfe.cod-estabel = nota-fiscal.cod-estabel
                 ext-nota-fiscal-danfe.serie       = nota-fiscal.serie      
                 ext-nota-fiscal-danfe.nr-nota-fis = nota-fiscal.nr-nota-fis.
       END.
       COPY-LOB lc-aux TO mem-aux.
       ASSIGN lc-aux = BASE64-ENCODE(mem-aux).
       COPY-LOB lc-aux TO ext-nota-fiscal-danfe.doc-danfe.
       COPY-LOB lc-aux TO ext-nota-fiscal-danfe.doc-xml.
       RELEASE ext-nota-fiscal.

       IF protocolo <> ""  THEN DO:

            FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
                WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.

            IF AVAIL b-nota-fiscal THEN DO:
       
                ASSIGN b-nota-fiscal.cod-protoc  = protocolo.

            END.

            RELEASE b-nota-fiscal.

       END.
       FOR EACH infprot:

           //DISP infprot WITH 1 COL SCROLLABLE.

           FOR EACH int_ndd_envio
               where /*int_ndd_envio.STATUSNUMBER = 0 
               and */  int_ndd_envio.cod_estabel = nota-fiscal.cod-estabel     
               and   int_ndd_envio.serie       = nota-fiscal.serie          
               and   int_ndd_envio.nr_nota_fis = nota-fiscal.nr-nota-fis    
               EXCLUSIVE-LOCK:

               IF int_ndd_envio.protocolo = ""  OR  int_ndd_envio.protocolo = ? THEN
                  ASSIGN int_ndd_envio.protocolo = infprot.nprot.

               ASSIGN int_ndd_envio.STATUSNUMBER = 10.
               // run pi-consultarProtocolo. ver essa rotina depois

           END.
           RELEASE int_ndd_envio.

           ASSIGN cMensagem = trim(infprot.cstat) + " - " + infprot.xmotivo
                  cCodigoErro = trim(infprot.cstat).

           IF cCodigoErro = '' THEN
          ASSIGN cCodigoErro = c-status.
                 cMensagem   = TRIM(c-status)  + " - " + v-xmotivo.
           

            FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
                WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.

            IF AVAIL b-nota-fiscal THEN DO:

               ASSIGN b-nota-fiscal.cod-protoc               = IF infprot.nprot <> "" THEN infprot.nprot ELSE protocolo.
                      //nota-fiscal.idi-sit-nf-eletro        = 3 //autorizada
                    //  b-nota-fiscal.cod-chave-aces-nf-eletro = infprot.chNFe.

            END.
            RELEASE b-nota-fiscal.

           if nota-fiscal.ind-tip-nota = 8 then 
              RUN pi-atualiza-recebimento.
           
           CREATE  tt1-protocolo.
           ASSIGN  tt1-protocolo.protocolo = protocolo 
                   tt1-protocolo.c-status  = c-status 
                   tt1-protocolo.v-xmotivo = v-xmotivo.

           RUN pi-cria-ret-nf-eletro(input nota-fiscal.cod-estabel,
                                     input nota-fiscal.serie,       
                                     input nota-fiscal.nr-nota-fis,
                                     INPUT nota-fiscal.cod-protoc).
           l-atualizou = YES.
       END. //FOR EACH infprot

       /*trata os eventos da tt-nota-aux*/
       FOR EACH infEvento 
           WHERE infEvento.cstat <> "":
       
           FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
               WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.

           IF AVAIL b-nota-fiscal THEN DO:

                ASSIGN b-nota-fiscal.cod-protoc               = IF infEvento.nprot <> "" THEN infEvento.nprot ELSE protocolo.
                       //b-nota-fiscal.cod-chave-aces-nf-eletro = infEvento.chNFe.
           END.

           RELEASE b-nota-fiscal.

           if nota-fiscal.ind-tip-nota = 8 then 
              RUN pi-atualiza-recebimento.
           

           FOR EACH int_ndd_envio
               where /*int_ndd_envio.STATUSNUMBER <= 1 
               and*/ int_ndd_envio.cod_estabel = nota-fiscal.cod-estabel  
               and int_ndd_envio.serie       = nota-fiscal.serie        
               and int_ndd_envio.nr_nota_fis = nota-fiscal.nr-nota-fis  
               EXCLUSIVE-LOCK:

               IF int_ndd_envio.protocolo = ""  OR  int_ndd_envio.protocolo = ? THEN
                  ASSIGN int_ndd_envio.protocolo = infprot.nprot.

               
                  ASSIGN int_ndd_envio.STATUSNUMBER = 10.
                  // run pi-consultarProtocolo. ver essa rotina depois
               

           END. //FOR EACH int_ndd_envio
           RELEASE int_ndd_envio.

           ASSIGN cMensagem = trim(infEvento.cstat) + " - " + infEvento.tpEvento + " - " + infEvento.xEvento + " - " + infEvento.xmotivo
                  cCodigoErro =  trim(infEvento.cstat).

           IF cCodigoErro = '' THEN
             ASSIGN cCodigoErro = c-status.
                    cMensagem   = TRIM(c-status) + " - " + v-xmotivo.

           CREATE  tt1-protocolo.
           ASSIGN  tt1-protocolo.protocolo = protocolo 
                   tt1-protocolo.c-status  = c-status 
                   tt1-protocolo.v-xmotivo = v-xmotivo.

           RUN pi-cria-ret-nf-eletro(input nota-fiscal.cod-estabel,
                                     input nota-fiscal.serie,       
                                     input nota-fiscal.nr-nota-fis,
                                     INPUT nota-fiscal.cod-protoc).
           l-atualizou = YES.
       END. //FOR EACH infprot
       IF cCodigoErro = '' THEN
          ASSIGN cCodigoErro = c-status.
                 cMensagem   = TRIM(c-status) + " - " + v-xmotivo.
    END. //AVAIL nota-fiscal

    //MESSAGE 'protocolo  ' protocolo skip 
    //        'c-status   ' c-status  skip 
    //        'v-xmotivo  ' v-xmotivo skip 
    //        'l-atualizou ' l-atualizou 
    //        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    FOR EACH  tt1-protocolo
        BREAK BY tt1-protocolo.c-status:

       FIND FIRST b-nota-fiscal EXCLUSIVE-LOCK
           WHERE ROWID(b-nota-fiscal) = ROWID(nota-fiscal) NO-ERROR.

       IF AVAIL b-nota-fiscal THEN DO:

            ASSIGN cCodigoErro = tt1-protocolo.c-status.
                   cMensagem   = TRIM(tt1-protocolo.c-status) + " - " + tt1-protocolo.v-xmotivo.
                   b-nota-fiscal.cod-protoc = tt1-protocolo.protocolo.

       END.

        RUN pi-cria-ret-nf-eletro(input nota-fiscal.cod-estabel,
                                  input nota-fiscal.serie,       
                                  input nota-fiscal.nr-nota-fis,
                                  INPUT nota-fiscal.cod-protoc).

    END.
    //IF protocolo <>  "" THEN do:
    //   IF nota-fiscal.idi-sit-nf-eletro <> 3 AND c-status <> '100' THEN do:
    //      ASSIGN cCodigoErro = c-status
    //             cMensagem   = TRIM(c-status) + " - " + v-xmotivo
    //             nota-fiscal.cod-protoc = protocolo.
    //      
    //      CREATE  tt1-protocolo.
    //      ASSIGN  tt1-protocolo.protocolo = protocolo 
    //              tt1-protocolo.c-status  = c-status 
    //              tt1-protocolo.v-xmotivo = v-xmotivo.
    //
    //    RUN pi-cria-ret-nf-eletro(input nota-fiscal.cod-estabel,
    //                                  input nota-fiscal.serie,       
    //                                  input nota-fiscal.nr-nota-fis,
    //                                  INPUT nota-fiscal.cod-protoc).
    //   END.
    //END.

    RELEASE nota-fiscal.
END.

PROCEDURE pi-atualiza-recebimento:
    for each docum-est 
        where  docum-est.serie-docto  = nota-fiscal.serie                     
        and    docum-est.nro-docto    = nota-fiscal.nr-nota-fis  
        and    docum-est.cod-emitente = nota-fiscal.cod-emitente 
        and    docum-est.nat-operacao = nota-fiscal.nat-operacao
        query-tuning(no-lookahead): 
        assign  &if '{&bf_dis_versao_ems}' >= '2.07':U &then docum-est.cod-chave-aces-nf-eletro 
                &else overlay(docum-est.char-1,93,60) &endif = nota-fiscal.cod-chave-aces-nf-eletro.
    END.
    RELEASE  docum-est .
END PROCEDURE.


PROCEDURE pi-desatualiza-ft2100. 

    empty temp-table tt-raw-digita.
    empty temp-table tt-param-FT2100.
    DEFINE VARIABLE l-erro AS LOGICAL     NO-UNDO.

    create  tt-param-FT2100.
    assign  tt-param-FT2100.usuario           = c-seg-usuario
            tt-param-FT2100.destino           = 2
            tt-param-FT2100.tipo-atual        = 2  /* 1 - Atualiza | 2 - Desatualiza*/
            tt-param-FT2100.c-desc-tipo-atual = ""
            tt-param-FT2100.da-emissao-ini    = nota-fiscal.dt-emis-nota
            tt-param-FT2100.da-emissao-fim    = nota-fiscal.dt-emis-nota
            tt-param-FT2100.da-saida          = nota-fiscal.dt-emis-nota
            tt-param-FT2100.da-vencto-ipi     = today 
            tt-param-FT2100.da-vencto-icms    = today 
            tt-param-FT2100.c-estabel-ini     = nota-fiscal.cod-estabel
            tt-param-FT2100.c-estabel-fim     = nota-fiscal.cod-estabel
            tt-param-FT2100.c-serie-ini       = nota-fiscal.serie
            tt-param-FT2100.c-serie-fim       = nota-fiscal.serie
            tt-param-FT2100.c-nr-nota-ini     = nota-fiscal.nr-nota-fis
            tt-param-FT2100.c-nr-nota-fim     = nota-fiscal.nr-nota-fis
            tt-param-FT2100.de-embarque-ini   = nota-fiscal.cdd-embarq
            tt-param-FT2100.de-embarque-fim   = nota-fiscal.cdd-embarq
            tt-param-FT2100.c-preparador      = ""
            tt-param-FT2100.arquivo           = SESSION:TEMP-DIRECTORY + "ft2100.tmp"
            tt-param-FT2100.l-disp-men        = no.

    raw-transfer tt-param-FT2100 to raw-param.

    run ftp/ft2100rp.p (input raw-param,
                        input table tt-raw-digita).

    .MESSAGE "depois do ft2100" SKIP
            nota-fiscal.dt-cancel
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    l-erro = no.
    for each fat-ser-lote no-lock of nota-fiscal:
        for each movto-estoq USE-INDEX documento no-lock where 
            movto-estoq.cod-estabel     = fat-ser-lote.cod-estabel  and
            movto-estoq.cod-depos       = fat-ser-lote.cod-depos    and
            movto-estoq.it-codigo       = fat-ser-lote.it-codigo    and
            movto-estoq.lote            = fat-ser-lote.nr-serlote   and
            movto-estoq.cod-localiz     = fat-ser-lote.cod-localiz  and
            movto-estoq.serie-docto     = fat-ser-lote.serie        and
            movto-estoq.nro-docto       = fat-ser-lote.nr-nota-fis  and
            movto-estoq.cod-emitente    = nota-fiscal.cod-emitente  AND
            movto-estoq.sequen-nf       = fat-ser-lote.nr-seq-fat:
            l-erro = yes.
            leave.
        end.
        if l-erro then leave.
    end.

end PROCEDURE. 

PROCEDURE pi-altera-docum-est:
    if nota-fiscal.ind-tip-nota = 8 then do:
        for first docum-est where 
            docum-est.serie-docto  = nota-fiscal.serie and
            docum-est.nro-docto    = nota-fiscal.nr-nota-fis and
            docum-est.cod-emitente = nota-fiscal.cod-emitente and
            docum-est.nat-operacao = nota-fiscal.nat-operacao: 
            assign docum-est.idi-sit-nf-eletro = nota-fiscal.idi-sit-nf-eletro
                   docum-est.log-1 = NO.
        end.
    end.
end.




                                                                          
