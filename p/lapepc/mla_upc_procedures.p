/*******************************************************************************************************
** 14/04/2024 - Rafael Andrade - Criaá∆o desta UPC de aprovaá∆o do documento 7 (Pedido de compra)
********************************************************************************************************/ 
{include/i-prgvrs.i mla_doc7_aprova 2.00.00.001 } /*** 010003 ***/

{cdp/cd0666.i}                    /* definiá∆o da temp-table de erros */
{inbo/boin090.i tt-docum-est} 
{inbo/boin366.i tt-rat-docum}
{inbo/boin176.i tt-item-doc-est}
{inbo/boin092.i tt-dupli-apagar}
{inbo/boin567.i tt-dupli-imp}

DEF VAR valorTotalNF AS DECIMAL.
DEF VAR valorTotalNF_2 AS DECIMAL.
DEF VAR qtdeTotalFornecedor AS DECIMAL.
DEF VAR d-dt-validade  AS DATE .
DEF BUFFER OrdemCompra FOR ordem-compra.


DEF TEMP-TABLE tt-erro-316b    NO-UNDO
	      FIELD identif-segment AS CHAR
	      FIELD cd-erro         AS INTEGER
	      FIELD desc-erro       AS CHAR FORMAT "x(80)".
         
DEF VAR h-acomp AS HANDLE NO-UNDO.  

PROCEDURE gerarDocumEstMedicao.
   DEF INPUT  PARAMETER p-cod-usuar-aprov  AS CHAR    NO-UNDO.
   DEF INPUT  PARAMETER NumeroOrdem        AS INTEGER NO-UNDO.
   DEF INPUT  PARAMETER numerodocumento    AS CHAR    NO-UNDO.
   DEF INPUT  PARAMETER qtdeFornecedor     AS INTEGER NO-UNDO.
   DEF INPUT  PARAMETER valorNF            AS DEC     NO-UNDO.
   DEF INPUT  PARAMETER dt-validade        AS DATE    NO-UNDO.
   DEF OUTPUT PARAMETER EstaOK             AS LOGICAL NO-UNDO INIT TRUE.
   
   valorTotalNF_2 = valorNF.
   qtdeTotalFornecedor = qtdeFornecedor.
   d-dt-validade = dt-validade.
   
   FIND FIRST ordem-compra 
        WHERE ordem-compra.numero-ordem = NumeroOrdem NO-LOCK NO-ERROR.
        
   IF AVAIL ordem-compra THEN
   DO:
    
    
    FIND FIRST ITEM WHERE ITEM.it-codigo = ordem-compra.it-codigo NO-LOCK NO-ERROR.
         
    //LOG-MANAGER:write-message("KML - TESTE LOG PAZOE - Antes do IF AVAIL  - "  + STRING(ITEM.it-codigo)) NO-ERROR.
         
    FIND FIRST esp_item_gera_receb_mla WHERE esp_item_gera_receb_mla.it-codigo = ITEM.it-codigo AND  esp_item_gera_receb_mla.gera_receb_MLA = YES  NO-LOCK NO-ERROR. 

    IF AVAIL esp_item_gera_receb_mla THEN
    DO:
        
        RUN gerarDocumEst(INPUT p-cod-usuar-aprov,
                          INPUT NumeroOrdem,
                          INPUT numerodocumento,
                          OUTPUT EstaOK).
                     
    END.        
   END.
   
   ELSE LEAVE.
   
                                    
END PROCEDURE.


PROCEDURE gerarDocumEstPedVenda.
   DEF INPUT  PARAMETER p-cod-usuar-aprov  AS CHAR    NO-UNDO.
   DEF INPUT  PARAMETER NrPedCompra        AS INTEGER NO-UNDO.
   DEF OUTPUT PARAMETER EstaOK             AS LOGICAL NO-UNDO INIT TRUE.
   
   FIND FIRST pedido-compr WHERE pedido-compr.num-pedido =  NrPedCompra NO-LOCK NO-ERROR.
   
   FIND FIRST ordem-compra OF pedido-compr NO-LOCK NO-ERROR.
   
   FIND FIRST ITEM WHERE ITEM.it-codigo = ordem-compra.it-codigo NO-LOCK NO-ERROR.
         
         //LOG-MANAGER:write-message("KML - TESTE LOG PAZOE - Antes do IF AVAIL  - "  + STRING(ITEM.it-codigo)) NO-ERROR.
         
   FIND FIRST esp_item_gera_receb_mla WHERE esp_item_gera_receb_mla.it-codigo = ITEM.it-codigo AND  esp_item_gera_receb_mla.gera_receb_MLA = YES  NO-LOCK NO-ERROR. 

   IF AVAIL esp_item_gera_receb_mla THEN
   DO:
   
    RUN gerarDocumEst(INPUT p-cod-usuar-aprov,
                 INPUT ordem-compra.numero-ordem,
                 INPUT STRING(ordem-compra.numero-ordem),
                 OUTPUT EstaOK).
    END.
    
    ELSE LEAVE.
   
END PROCEDURE.


PROCEDURE gerarDocumEst.
   DEF INPUT  PARAMETER p-cod-usuar-aprov  AS CHAR    NO-UNDO.
   DEF INPUT  PARAMETER NumeroOrdem        AS INTEGER NO-UNDO.
   DEF INPUT  PARAMETER Numerodoc          AS CHAR NO-UNDO.
   DEF OUTPUT PARAMETER EstaOK             AS LOGICAL NO-UNDO INIT TRUE.
   
   LOG-MANAGER:write-message("KML - TESTE LOG PAZOE - ESTABELCIMENTO  - "  + STRING(EstaOK)) NO-ERROR.
   
   RUN utp/ut-acomp.r PERSISTENT SET h-acomp.
   
   RUN pi-inicializar IN h-acomp (INPUT "Gerando Doc. Receb. (RE1001)...").
   RUN pi-acompanhar IN h-acomp (INPUT "Aguarde...").
   
   TMaior:
   DO TRANS:
      DO ON QUIT UNDO TMaior, LEAVE:
         DO ON STOP UNDO TMaior, LEAVE:
     
            RUN pi-acompanhar IN h-acomp (INPUT "Preparando dados...").
           
            RUN gravarTempTables(INPUT p-cod-usuar-aprov,
                                 INPUT NumeroOrdem,
                                 INPUT Numerodoc,
                                 INPUT qtdeTotalFornecedor,
                                 INPUT valorTotalNF,
                                 OUTPUT EstaOK).
                                 
            IF NOT EstaOK THEN DO:
               run pi-finalizar in h-acomp.
               UNDO TMaior, LEAVE.
            END.
            
            RUN pi-acompanhar IN h-acomp (INPUT "Gerando documento...").
            
            RUN rep/reapi316b.p (INPUT  "ADD",
                                 INPUT  TABLE tt-docum-est,
                                 INPUT  TABLE tt-rat-docum,
                                 INPUT  TABLE tt-item-doc-est,
                                 INPUT  TABLE tt-dupli-apagar,
                                 INPUT  TABLE tt-dupli-imp,
                                 OUTPUT TABLE tt-erro-316b).
                                 
            RUN pi-acompanhar IN h-acomp (INPUT "Geraá∆o finalizada...").
            run pi-finalizar in h-acomp.
                                 
            FIND FIRST tt-erro-316b NO-LOCK NO-ERROR.
            
            IF AVAIL tt-erro-316b THEN DO:
               RUN utp/ut-msgs.p(INPUT "show",
                                 INPUT 17242,
                                 INPUT "Falha na criaá∆o do documento~~Erro: " + STRING(tt-erro-316b.cd-erro) + CHR(13) + tt-erro-316b.desc-erro).                       
               EstaOK = FALSE.
               UNDO TMaior, LEAVE.
            END.
            
            RUN utp/ut-msgs.p(INPUT "show",
                              INPUT 15825,
                              INPUT "Doc. Recebimento gerado com sucesso~~Nro.Docto: " + tt-docum-est.nro-docto + CHR(13) + "SÇrie: " + tt-docum-est.serie-docto + CHR(13) + "Cod.Estabel.: " + tt-docum-est.cod-estabel). 
            
         END.
      END.
   END.
END PROCEDURE.


PROCEDURE gravarTempTables.
    DEF INPUT  PARAMETER codUsuario     AS CHAR.
    DEF INPUT  PARAMETER NumeroOrdem    AS INTEGER.
    DEF INPUT  PARAMETER NumeroDoc      AS CHAR.
    DEF INPUT  PARAMETER qtdeFornecedor AS DECIMAL.
    DEF INPUT  PARAMETER valorNF        AS DECIMAL.
    DEF OUTPUT PARAMETER TudoOK         AS LOGICAL INIT TRUE.
    
    DEF VAR SeriePadrao         AS CHAR INIT "001".
    DEF VAR NatOperPadrao       AS CHAR INIT "1949x3".
    DEF VAR ContaTransitPadrao  AS CHAR INIT "91103005".
    DEF VAR DepositoPadrao      AS CHAR INIT "973".
    DEF VAR ParcelaPadrao       AS CHAR INIT "01".
    DEF VAR CodEspPadrao        AS CHAR INIT "NT".
    DEF VAR d-aliq-ipi-aux      LIKE item-doc-est.aliquota-ipi  NO-UNDO.
    DEF VAR NrSequencia         AS INTEGER.
    DEF VAR de-pc-pis           AS DECIMAL.
    DEF VAR de-pc-cofins        AS DECIMAL.
    DEF VAR c-desc-aux          AS CHARACTER.
    DEF VAR de-base-icm-compl   AS CHARACTER.
    DEF VAR h-boin176           AS HANDLE NO-UNDO.
    
    EMPTY TEMP-TABLE tt-docum-est.
    EMPTY TEMP-TABLE tt-item-doc-est.
    EMPTY TEMP-TABLE tt-dupli-apagar.
    EMPTY TEMP-TABLE tt-dupli-imp.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-rat-docum .
    
    FIND FIRST ordem-compra WHERE ordem-compra.numero-ordem = NumeroOrdem NO-LOCK NO-ERROR.
    
    IF NOT AVAIL ordem-compra THEN DO:
       MESSAGE "Ordem de compra n∆o encontrada " + STRING(NumeroOrdem) + "!"
               VIEW-AS ALERT-BOX ERROR TITLE "Erro".
       TudoOK = FALSE.
       RETURN.
    END.
    
    FIND FIRST OrdemCompra WHERE ROWID(OrdemCompra) = ROWID(ordem-compra) NO-LOCK NO-ERROR.
    
    FIND FIRST pedido-compr OF ordem-compra NO-LOCK NO-ERROR.
    
    IF NOT AVAIL pedido-compr THEN DO:
       MESSAGE "Pedido de compra " + STRING(ordem-compra.num-pedido) + " n∆o foi encontrado!"
               VIEW-AS ALERT-BOX ERROR TITLE "Erro".
       TudoOK = FALSE.
       RETURN.
    END.
    
    FIND FIRST emitente WHERE emitente.cod-emitente = pedido-compr.cod-emitente NO-LOCK NO-ERROR.
    
    IF NOT AVAIL emitente THEN DO:
       MESSAGE "Emitente " + STRING(pedido-compr.cod-emitente) + " n∆o foi encontrado!"
               VIEW-AS ALERT-BOX ERROR TITLE "Erro".
       TudoOK = FALSE.
       RETURN.
    END.
    
    
    
    
         IF ordem-compra.ct-codigo = "41101165" THEN ASSIGN CodEspPadrao = "CT".
    ELSE IF ordem-compra.ct-codigo = "41108056" THEN ASSIGN CodEspPadrao = "CG".
    ELSE IF ordem-compra.ct-codigo = "12101005" THEN ASSIGN CodEspPadrao = "FJ".
    
    FIND FIRST cond-especif WHERE cond-especif.num-pedido = pedido-compr.num-pedido NO-LOCK NO-ERROR.
    
    RUN inbo/boin176.p PERSISTENT SET h-boin176.
    
    CREATE  tt-dupli-apagar.
    ASSIGN  tt-dupli-apagar.parcela        = ParcelaPadrao
            tt-dupli-apagar.nr-duplic      = NumeroDoc
            tt-dupli-apagar.cod-esp        = CodEspPadrao
            tt-dupli-apagar.tp-despesa     = ordem-compra.tp-despesa
            tt-dupli-apagar.dt-vencim      = d-dt-validade
            
            tt-dupli-apagar.vl-desconto    = 0
            tt-dupli-apagar.dt-venc-desc   = ?
            tt-dupli-apagar.serie-docto    = SeriePadrao
            tt-dupli-apagar.nro-docto      = NumeroDoc
            tt-dupli-apagar.cod-emitente   = emitente.cod-emitente
            tt-dupli-apagar.nat-operacao   = NatOperPadrao.
            
     /*CREATE tt-dupli-imp.
     ASSIGN tt-dupli-imp.cod-esp               = "ST"
            tt-dupli-imp.dt-venc-imp           = date(int(entry(2,int_ds_docto_xml_dup.dVenc,"/")),
                                                      int(entry(1,int_ds_docto_xml_dup.dVenc,"/")),
                                                      int(entry(3,int_ds_docto_xml_dup.dVenc,"/")))
            tt-dupli-imp.rend-trib             = tt-movto.base_guia_st
            tt-dupli-imp.aliquota              = (int_ds_docto_xml_dup.vDup / tt-movto.base_guia_st) * 100
            tt-dupli-imp.vl-imposto            = int_ds_docto_xml_dup.vDup
            tt-dupli-imp.tp-codigo             = 399
            tt-dupli-imp.cod-retencao          = 9999
            tt-dupli-imp.serie-docto           = tt-dupli-apagar.serie-docto      
            tt-dupli-imp.nro-docto             = tt-dupli-apagar.nro-docto        
            tt-dupli-imp.cod-emitente          = tt-dupli-apagar.cod-emitente     
            tt-dupli-imp.nat-operacao          = tt-dupli-apagar.nat-operacao     
            tt-dupli-imp.parcela               = tt-dupli-apagar.parcela.
     ASSIGN tt-dupli-apagar.vl-a-pagar         = tt-dupli-apagar.vl-a-pagar + tt-dupli-imp.vl-imposto.   */
     
     CREATE tt-docum-est.
     ASSIGN tt-docum-est.serie-docto          = "001"
            tt-docum-est.nro-docto            = NumeroDoc
            tt-docum-est.cod-emitente         = pedido-compr.cod-emitente
            tt-docum-est.nat-operacao         = NatOperPadrao
            tt-docum-est.tot-valor            = valorTotalNF            
            tt-docum-est.cod-observa          = 4 //1 = INDÈSTRIA, 2 = COMêRCIO, 3 = DEVOLUÄ«O CLIENTE, 4 = SERVIÄOS
            tt-docum-est.tipo-docto           = 1
            tt-docum-est.tipo-nota            = 1
            tt-docum-est.atualiza-cr          = TRUE
            tt-docum-est.esp-fiscal           = "DEB"
            tt-docum-est.ok-fornec            = qtdeFornecedor
            tt-docum-est.ind-orig-entrada     = 1
            tt-docum-est.ind-via-envio        = 1
            tt-docum-est.cotacao-dia          = 1
            tt-docum-est.ind-tipo-rateio      = TRUE
            tt-docum-est.cod-estabel          = pedido-compr.cod-estabel
            tt-docum-est.estab-fisc           = pedido-compr.cod-estabel
            tt-docum-est.ct-transit           = ContaTransitPadrao                           
            tt-docum-est.sc-transit           = ""
            tt-docum-est.dt-emissao           = TODAY
            tt-docum-est.dt-trans             = TODAY
            tt-docum-est.usuario              = codUsuario
            tt-docum-est.uf                   = emitente.estado 
            tt-docum-est.via-transp           = 1 //1 = RODOVIµRIO, 2 = AEROVIµRIO, 3 = MAR÷TIMO, 4 = FERROVIµRIO, 5 = RODOFERROVIµRIO, 6 = RODOFLUVIAL, 7 = RODOAEROVIµRIO, 8 = OUTROS
            tt-docum-est.mod-frete            = 1 //1 = CIF, 2 = FOB, 3 = OUTROS
            tt-docum-est.cod-ibge             = 1
            tt-docum-est.rateia-frete         = 1
            tt-docum-est.idi-nf-simples-remes = 3
            tt-docum-est.idi-bxa-devol        = 1
            tt-docum-est.idi-tip-operac       = 1
            tt-docum-est.cod-entrega          = "Padr∆o"
            tt-docum-est.nff                  = NO
            tt-docum-est.tot-desconto         = 0
            tt-docum-est.valor-frete          = 0
            tt-docum-est.valor-seguro         = 0
            tt-docum-est.valor-embal          = 0
            tt-docum-est.valor-outras         = 0
            
            tt-docum-est.dt-venc-ipi          = tt-docum-est.dt-emissao
            tt-docum-est.dt-venc-icm          = tt-docum-est.dt-emissao
            tt-docum-est.dt-venc-iss          = tt-docum-est.dt-emissao
            tt-docum-est.esp-docto            = 21 //if tt-movto.tipo_nota = 1 then 21 /* NFE */ else 23 /* NFT */
            tt-docum-est.rec-fisico           = no
            tt-docum-est.origem               = "RE1001" /* verificar*/
            tt-docum-est.pais-origem          = emitente.pais
            tt-docum-est.embarque             = "".
            
            /*&if "{&bf_dis_versao_ems}" < "2.07" &THEN
                 substring(tt-docum-est.char-1,93,60)  = tt-movto.chave-acesso.
            &else
                 tt-docum-est.cod-chave-aces-nf-eletro = tt-movto.chave-acesso.
            &endif   */
     
     IF pedido-compr.cod-estabel <> "973" THEN DepositoPadrao = "LOJ".
     ELSE DepositoPadrao = "973".
     
     NrSequencia = 0.
     FOR EACH ordem-compra OF pedido-compr NO-LOCK:
         NrSequencia = NrSequencia + 10.
         
         IF OrdemCompra.nr-contrato <> 0 THEN DO: //Se a ordem Ç de mediá∆o/contrato
            IF ordem-compra.numero-ordem <> OrdemCompra.numero-ordem THEN NEXT.
         END.
         
         LOG-MANAGER:write-message("KML - TESTE LOG PAZOE - ORDEM-NUMERO ORDEM  - "  + STRING(OrdemCompra.numero-ordem)) NO-ERROR.
         MESSAGE "OrdemCompra.numero-ordem: " + STRING(OrdemCompra.numero-ordem) VIEW-AS ALERT-BOX.
         
         FIND FIRST ITEM WHERE ITEM.it-codigo = ordem-compra.it-codigo NO-LOCK NO-ERROR.
         
         LOG-MANAGER:write-message("KML - TESTE LOG PAZOE - Antes do IF AVAIL  - "  + STRING(ITEM.it-codigo)) NO-ERROR.
         
         ASSIGN valorTotalNF = 0 
           qtdeFornecedor = 0. 
    
        

        
        IF valorTotalNF = 0 THEN ASSIGN valorTotalNF = ordem-compra.pre-unit-for.
        IF qtdeFornecedor = 0 THEN ASSIGN qtdeFornecedor = ordem-compra.qt-solic.
        


                   
        ASSIGN valorTotalNF_2 = valorTotalNF_2 + valorTotalNF .
        

        CREATE tt-item-doc-est.
        ASSIGN tt-item-doc-est.serie-docto          = tt-docum-est.serie-docto
               tt-item-doc-est.nro-docto            = tt-docum-est.nro-docto
               tt-item-doc-est.cod-emitente         = tt-docum-est.cod-emitente
               tt-item-doc-est.nat-operacao         = tt-docum-est.nat-operacao /* natureza da nota - chave */
               tt-item-doc-est.nat-of               = tt-docum-est.nat-operacao /* natureza do item */
               tt-item-doc-est.it-codigo            = ordem-compra.it-codigo
               tt-item-doc-est.un                   = ITEM.un
               tt-item-doc-est.cod-refer            = ""
               tt-item-doc-est.num-pedido           = ordem-compra.num-pedido
               tt-item-doc-est.numero-ordem         = ordem-compra.numero-ordem
               tt-item-doc-est.cod-depos            = DepositoPadrao
               tt-item-doc-est.cod-localiz          = ""
               tt-item-doc-est.parcela              = 1
               tt-item-doc-est.encerra-pa           = NO
               tt-item-doc-est.nr-ord-prod          = 0
               tt-item-doc-est.cod-roteiro          = ""
               tt-item-doc-est.op-codigo            = 0
               tt-item-doc-est.item-pai             = ""
               tt-item-doc-est.baixa-ce             = yes
               tt-item-doc-est.etiquetas            = 0
               tt-item-doc-est.qt-do-forn           = qtdeFornecedor
               tt-item-doc-est.quantidade           = qtdeFornecedor
               tt-item-doc-est.preco-total          = valorTotalNF
               tt-item-doc-est.preco-unit           = valorTotalNF
               tt-item-doc-est.val-base-calc-cofins = valorTotalNF
               tt-item-doc-est.desconto             = 0
               tt-item-doc-est.despesas             = 0
               tt-item-doc-est.peso-liquido         = 0
               tt-item-doc-est.flag-atu             = 2
               tt-item-doc-est.dec-1                = 1                
               tt-item-doc-est.lote                 = ""
               tt-item-doc-est.dt-retorno           = TODAY
               tt-item-doc-est.atualiza-pa          = TRUE
               tt-item-doc-est.dt-vali-lote         = ?
               tt-item-doc-est.class-fiscal         = ITEM.class-fiscal 
               tt-item-doc-est.cd-trib-iss          = 2  //Copiado do padr∆o dos documentos j† gerados anteriormente
               tt-item-doc-est.cd-trib-icm          = 2  //Copiado do padr∆o dos documentos j† gerados anteriormente
               tt-item-doc-est.cd-trib-ipi          = 2  //Copiado do padr∆o dos documentos j† gerados anteriormente
               tt-item-doc-est.idi-tributac-cofins  = 2  //Copiado do padr∆o dos documentos j† gerados anteriormente
               tt-item-doc-est.idi-tributac-pis     = 2  //Copiado do padr∆o dos documentos j† gerados anteriormente
               tt-item-doc-est.origem               = 9  //Copiado do padr∆o dos documentos j† gerados anteriormente
               tt-item-doc-est.aliquota-ipi         = ordem-compra.aliquota-ipi
               tt-item-doc-est.aliquota-icm         = ordem-compra.aliquota-icm
               tt-item-doc-est.aliquota-iss         = ordem-compra.aliquota-iss
               /*tt-item-doc-est.base-ipi             = 0   
               tt-item-doc-est.ipi-outras           = 0                      
               tt-item-doc-est.ipi-ntrib            = 0                     
               tt-item-doc-est.valor-ipi            = 0                   
               tt-item-doc-est.base-icm             = 0     
               tt-item-doc-est.valor-icm            = 0     
               tt-item-doc-est.base-subs            = 0     
               tt-item-doc-est.icm-complem          = 0                     
               tt-item-doc-est.icm-outras           = 0     
               tt-item-doc-est.iss-outras           = 0   
               tt-item-doc-est.iss-ntrib            = 0 */
               tt-item-doc-est.icm-ntrib            = valorTotalNF
               tt-item-doc-est.narrativa            = ordem-compra.it-codigo
               tt-item-doc-est.sequencia            = NrSequencia
               tt-item-doc-est.nr-proc-imp          = ""
               tt-item-doc-est.nr-ato-concessorio   = ""
               tt-item-doc-est.val-perc-red-icm     = 0
               tt-item-doc-est.ct-codigo            = ordem-compra.ct-codigo
               tt-item-doc-est.sc-codigo            = ordem-compra.sc-codigo.

            assign tt-item-doc-est.base-pis             = valorTotalNF         
                   tt-item-doc-est.valor-pis            = 0           
                   tt-item-doc-est.base-cofins          = 0.
                   
           LOG-MANAGER:write-message("KML - TESTE LOG PAZOE -   FIM PROGRAMA  - "  + "FINAL") NO-ERROR. 
          
         
     END.
     ASSIGN tt-dupli-apagar.vl-a-pagar     = valorTotalNF_2
            tt-docum-est.valor-mercad         = valorTotalNF_2.
      
END PROCEDURE.
