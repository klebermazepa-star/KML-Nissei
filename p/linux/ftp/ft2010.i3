/******************************************************************************
**
** ftp/ft2010.i3 - Copiar campos: tt-it-docto para it-nota-fisc 
**
******************************************************************************/

/***Devolu‡Æo Simb¢lica***/
def var l-devol-consig  as int no-undo.
def buffer b-natur-oper for natur-oper.
def buffer b-nota-fiscal  for nota-fiscal.

create it-nota-fisc.
assign i-nr-seq-fat                   = i-nr-seq-fat + 10
       it-nota-fisc.nr-seq-fat        = i-nr-seq-fat
       it-nota-fisc.cod-estabel       = nota-fiscal.cod-estabel               
       it-nota-fisc.nr-nota-fis       = nota-fiscal.nr-nota-fis
       it-nota-fisc.serie             = nota-fiscal.serie.

assign it-nota-fisc.dt-cancela        = nota-fiscal.dt-cancela
       it-nota-fisc.baixa-estoq       = tt-it-docto.baixa-estoq
       it-nota-fisc.class-fiscal      = tt-it-docto.class-fiscal              
       it-nota-fisc.cod-refer         = tt-it-docto.cod-refer                 
       it-nota-fisc.ind-componen      = tt-it-docto.ind-componen
       it-nota-fisc.it-codigo         = tt-it-docto.it-codigo                 
       it-nota-fisc.nat-operacao      = tt-it-docto.nat-operacao              
       it-nota-fisc.emite-duplic      = if  natur-oper.tipo = 1 /* entrada */
                                        then no
                                        else b-natur-oper-it.emite-duplic
       it-nota-fisc.nr-pedcli         = tt-it-docto.nr-pedcli                 
       it-nota-fisc.nr-seq-ped        = tt-it-docto.nr-sequencia              
       it-nota-fisc.nr-entrega        = tt-it-docto.nr-entrega
       it-nota-fisc.per-des-item      = tt-it-docto.per-des-item              
       it-nota-fisc.peso-liq-fat      = tt-it-docto.peso-liq-it-inf
       it-nota-fisc.qt-faturada[1]    = tt-it-docto.quantidade[1]
       it-nota-fisc.qt-faturada[2]    = tt-it-docto.quantidade[2]
       it-nota-fisc.un[1]             = tt-it-docto.un[1]
       it-nota-fisc.un[2]             = tt-it-docto.un[2]
       it-nota-fisc.vl-despes-it      = tt-it-docto.vl-despes-it              
       it-nota-fisc.vl-merc-liq       = tt-it-docto.vl-merc-liq               
       it-nota-fisc.vl-merc-ori       = tt-it-docto.vl-merc-ori               
       it-nota-fisc.vl-merc-tab       = tt-it-docto.vl-merc-tab               
       it-nota-fisc.vl-preori         = tt-it-docto.vl-preori                 
       it-nota-fisc.vl-pretab         = tt-it-docto.vl-pretab                 
       it-nota-fisc.vl-preuni         = tt-it-docto.vl-preuni                 
       it-nota-fisc.vl-tot-item       = tt-it-docto.vl-tot-item
       
       it-nota-fisc.vl-merc-sicm      = if  nota-fiscal.ind-tip-nota <> 11     /* Nota nÆo foi Importada */
                                        then tt-it-docto.vl-merc-s-icms
                                        else /* Nota Importada */
                                            if  tt-it-imposto.cd-trib-icm = 2  /* ICMS Isento */
                                            then tt-it-docto.vl-merc-liq
                                            else (  tt-it-docto.vl-merc-liq    /* ICMS Trib, Reduz, Outros */
                                                  * (1 - (tt-it-imposto.aliquota-icm / 100)))
       
       it-nota-fisc.ct-cuscon         = tt-it-docto.ct-cuscon     
       it-nota-fisc.sc-cuscon         = tt-it-docto.sc-cuscon
       it-nota-fisc.ind-fat-qtfam     = tt-it-docto.fat-qtfam                 
       it-nota-fisc.ind-imprenda      = tt-it-docto.ind-imprenda              
       it-nota-fisc.nivel-restituicao = tt-it-docto.nivel-rest                
       it-nota-fisc.pc-restituicao    = tt-it-docto.pc-rest                   
       it-nota-fisc.peso-bruto        = tt-it-docto.peso-bru-it-inf
       it-nota-fisc.tipo-atend        = tt-it-docto.tipo-atend                
       it-nota-fisc.atual-estat       = if  natur-oper.tipo = 1 /* entrada */
                                        then no
                                        else b-natur-oper-it.atual-est
       it-nota-fisc.cd-emitente       = tt-docto.cod-emitente
       it-nota-fisc.cod-est-ven       = c-cod-estabel
       it-nota-fisc.dt-emis-nota      = tt-docto.dt-emis-nota
       it-nota-fisc.ind-imp-desc      = item.ind-imp-desc
       it-nota-fisc.ind-imprenda      = tt-it-docto.ind-imprenda
       it-nota-fisc.ind-sit-nota      = if  nota-fiscal.ind-tip-nota = 2 /* NF Manual */
                                        then 2
                                        else 1 
       it-nota-fisc.manut-icm-it      = b-natur-oper-it.manut-icm
       it-nota-fisc.manut-ipi-it      = b-natur-oper-it.manut-ipi
       it-nota-fisc.nome-ab-cli       = tt-docto.nome-abrev

       /* Nas notas de devolucao os campos it-nota-fisc.cod-ord-compra e
          it-nota-fisc.nr-parcela possuem respectivamente o numero
          da ordem de compra e a parcela de ordem de compra.
          Para as demais notas, o conteudo desses campos sera
          numero da ordem de compra e numero da parcela informado 
          para o pedido de venda. */
          
       it-nota-fisc.cod-ord-compra    = string(tt-it-docto.numero-ordem)
       it-nota-fisc.parcela           = tt-it-docto.parcela
 
       /* Determina se a parcela da ordem de compra deve ser ou nao reaberta */
       it-nota-fisc.log-1             = tt-it-docto.encerra-pa

       it-nota-fisc.nr-ord-prod       = tt-it-docto.nr-ord-prod
       it-nota-fisc.nr-pedido         = i-nr-pedido
       it-nota-fisc.tipo-con-est      = item.tipo-con-est
       it-nota-fisc.tipo-contr        = item.tipo-contr
       it-nota-fisc.nr-docum          = tt-it-docto.nro-comp
       it-nota-fisc.serie-docum       = tt-it-docto.serie-comp
       it-nota-fisc.nat-docum         = tt-it-docto.nat-comp
       it-nota-fisc.int-1             = tt-it-docto.seq-comp.
 

       /*Atualiza‡Æo da data de confirma‡Æo do item da nota de acordo com a 
         data de atualiza‡Æo do estoque pelo remito  */
assign it-nota-fisc.data-1            = tt-it-docto.data-comp

       /* Atualiza‡Æo das informa‡äes da reserva da ordem de produ‡Æo */
       overlay(it-nota-fisc.char-2,1) = string(tt-it-docto.item-pai,    'x(16)') +
                                        string(tt-it-docto.cod-roteiro, 'x(16)') +
                                        string(tt-it-docto.op-codigo,   '>>>>9') + 
                                        substr(tt-it-docto.char-1,90,9) /* Cod Emitente doct entrada ciap 102 */
       

       /* Valor do Frete para o it-nota-fisc */
       it-nota-fisc.vl-despesit-e[2]  = tt-it-docto.vl-frete
       it-nota-fisc.vl-frete-it       = tt-it-docto.vl-frete   /* a partir de 23/11/1999 */
       
       /* Descontos por valor */
       it-nota-fisc.char-1            = string(tt-it-docto.vl-desconto-per)
       it-nota-fisc.vl-desconto        = tt-it-docto.vl-desconto
       it-nota-fisc.val-desconto-total = tt-it-docto.desconto
       /* TRATAMENTO LEI COMPLEMENTAR 102 */
       substr(it-nota-fisc.char-1,15,7)  = substr(tt-it-docto.char-1,33,7) /* CIAP102 */
       substr(it-nota-fisc.char-1,22,50) = substr(tt-it-docto.char-1,40,50). /* motivo da venda/devolu‡Æo */
       
/* ------ Grava informacoes sobre PIS e COFINS ------ */
       run atualizaDadosPISCOFINS.
       
/* -------------------------------------------------- */
/* Gravacao do vl-cuscontab */

        /*---- GRAVA ORIGEM DO ITEM----*/
    
        &IF '{&bf_dis_versao_ems}' >= '2.09' &THEN
            assign it-nota-fisc.num-origem   = item.codigo-orig.
        &ELSE
            assign overlay(it-nota-fisc.char-1,180,3) = string(item.codigo-orig).
        &ENDIF
        
        /*Segunda Busca - Relacionamento Item x Estab Fat - CD0147*/
        FOR FIRST item-uni-estab NO-LOCK
            WHERE item-uni-estab.it-codigo   = tt-it-docto.it-codigo  
              AND item-uni-estab.cod-estabel = nota-fiscal.cod-estabel:
              
            IF &IF "{&bf_dis_versao_ems}" >= "2.09"
               &THEN TRIM(STRING   (item-uni-estab.num-origem))
               &ELSE TRIM(SUBSTRING(item-uni-estab.char-2,18,3)) &ENDIF
            <> "" THEN DO:
      
                &IF "{&bf_dis_versao_ems}" >= "2.09" &THEN
                    ASSIGN it-nota-fisc.num-origem            = item-uni-estab.num-origem.
                &ELSE
                    ASSIGN OVERLAY(it-nota-fisc.char-1,180,3) = TRIM(SUBSTRING(item-uni-estab.char-2,18,3)).
                &ENDIF
            END.
        end.
        /*----*/

assign it-nota-fisc.vl-cuscontab      = dec(substr(tt-it-docto.char-1,21,12)) no-error.

       /* +------------------------------  BOM SABER ------------------------------------+
          |Significado dos campos TT-IT-DOCTO.VL-DESCONTO-PER e TT-IT-DOCTO.REABRE-PD:    |
          |                                                                               |
          | TT-IT-DOCTO.VL-DESCONTO-PER: Este campo contem o valor do desconto unitario   |
          | que sera concedido para o item da nota. Na grava‡Æo do item da nota fiscal,   |
          | ele ser  gravado no campo it-nota-fisc.char-1.                                |
          |                                                                               |
          | TT-IT-DOCTO.VL-DESCONTO: Este campo cont‚m o valor do desconto total          |
          | que sera concedido para o item da nota. Na grava‡Æo do item da nota fiscal,   |
          | ele ser  gravado no campo it-nota-fisc.vl-desconto.                           |
          |                                                                               |
          | TT-IT-DOCTO.REABRE-PD: Este campo possui o conte£do do parƒmetro que indica   |
          | se utiliza ou nao o desconto da relacÆo Item X Cliente. Ele nÆo ser  gravado  |
          | no momento da grava‡Æo do item da nota fiscal.                                |
          +-------------------------------------------------------------------------------+ */

/* Valores referente a entrega futura */
assign it-nota-fisc.vl-bicmsit-e[3] = tt-it-imposto.vl-bicms-ent-fut
       it-nota-fisc.vl-icmsit-e[3]  = tt-it-imposto.vl-icms-ent-fut
       it-nota-fisc.vl-bipiit-e[3]  = tt-it-imposto.vl-bipi-ent-fut
       it-nota-fisc.vl-ipiit-e[3]   = tt-it-imposto.vl-ipi-ent-fut
       it-nota-fisc.vl-bicmsit-e[2] = tt-it-imposto.vl-bsubs-ent-fut
       it-nota-fisc.vl-icmsit-e[2]  = tt-it-imposto.vl-icmsub-ent-fut.
       

/***Devolu‡Æo Simb¢lica***/
assign l-devol-consig = 0.
&IF "{&bf_dis_versao_ems}" >= "2.04" &THEN
     FIND FIRST param-of 
          WHERE param-of.cod-estabel = it-nota-fisc.cod-estabel
     &IF "{&bf_dis_versao_ems}" < "2.08" &THEN 
            AND SUBSTRING(param-of.char-2,57,1) = "S" NO-LOCK NO-ERROR.
     &ELSE
            AND param-of.log-devol-consig = YES NO-LOCK NO-ERROR.
     &ENDIF
     
     IF AVAIL param-of THEN
        FOR FIRST b-natur-oper 
            WHERE b-natur-oper.nat-operacao = it-nota-fisc.nat-operacao NO-LOCK:
        END.
            
        IF AVAIL b-natur-oper
        AND b-natur-oper.tp-oper-terc = 5 THEN DO: 
           &if '{&mguni_version}' >= '2.08' &then
                 IF  b-natur-oper.idi-tip-devol-consig = 1 THEN
                     ASSIGN l-devol-consig = 1.
                 ELSE
                     IF  b-natur-oper.idi-tip-devol-consig = 2 THEN
                         ASSIGN l-devol-consig = 2.
           &else
                 IF  substring(b-natur-oper.char-1, 140, 1) = "1" THEN
                     ASSIGN l-devol-consig = 1.
                 ELSE
                     IF  substring(b-natur-oper.char-1, 140, 1) = "2" THEN
                         ASSIGN l-devol-consig = 2.
           &endif
        END.   
&ENDIF   
    

if  b-natur-oper-it.terceiros
and b-natur-oper-it.tp-oper-terc = 4                                 /* consignacao mercantil */
 or (b-natur-oper-it.tp-oper-terc = 5 and l-devol-consig = 1) then   /* Devolu‡Æo Simb¢lica */
    assign it-nota-fisc.vl-bicmsit-e[3]  = it-nota-fisc.vl-bicms-it
           it-nota-fisc.vl-icmsit-e[3]   = it-nota-fisc.vl-icms-it
           it-nota-fisc.vl-icmsntit-e[3] = it-nota-fisc.vl-icmsnt-it
           it-nota-fisc.vl-icmsouit-e[3] = it-nota-fisc.vl-icmsou-it
           it-nota-fisc.vl-bipiit-e[3]   = it-nota-fisc.vl-bipi-it
           it-nota-fisc.vl-ipiit-e[3]    = it-nota-fisc.vl-ipi-it
           it-nota-fisc.vl-ipintit-e[3]  = it-nota-fisc.vl-ipint-it
           it-nota-fisc.vl-ipiouit-e[3]  = it-nota-fisc.vl-ipiou-it
           it-nota-fisc.vl-bsubsit-e[3]  = it-nota-fisc.vl-bsubs-it
           it-nota-fisc.vl-icmsubit-e[3] = it-nota-fisc.vl-icmsub-it
           it-nota-fisc.vl-bicms-it      = 0
           it-nota-fisc.vl-icms-it       = 0
           it-nota-fisc.vl-icmsnt-it     = 0
           it-nota-fisc.vl-icmsou-it     = 0
           it-nota-fisc.vl-bipi-it       = 0
           it-nota-fisc.vl-ipi-it        = 0
           it-nota-fisc.vl-ipint-it      = 0
           it-nota-fisc.vl-ipiou-it      = 0
           it-nota-fisc.vl-bsubs-it      = 0
           it-nota-fisc.vl-icmsub-it     = 0
           it-nota-fisc.cd-trib-icm      = 2
           it-nota-fisc.aliquota-icm     = 0
           it-nota-fisc.cd-trib-ipi      = 2
           it-nota-fisc.aliquota-ipi     = 0.
           
if b-natur-oper-it.tp-oper-terc = 5 and l-devol-consig = 1 then      /* Devolu‡Æo Simb¢lica */
   assign it-nota-fisc.vl-tot-item       = 0.
       
           
if  nota-fiscal.ind-tip-nota = 3 then /* Diferenca de Preco */
    assign it-nota-fisc.serie-ant   = tt-docto.serie-base
           it-nota-fisc.nr-nota-ant = tt-docto.nr-nota-base.
else
    assign it-nota-fisc.serie-ant   = tt-docto.serie-ent-fut
           it-nota-fisc.nr-nota-ant = tt-docto.nr-nota-ent-fut.

    &if defined(bf_dis_ciap) &then 
        
        if  substr(it-nota-fisc.char-1,15,7) = "" 
        and natur-oper.venda-ativo then

            for each  tt-it-nota-doc
                where tt-it-nota-doc.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto:
            
               create it-nota-doc.
               assign it-nota-doc.cod-estabel  = tt-it-nota-doc.cod-estabel
                      it-nota-doc.serie        = tt-it-nota-doc.serie
                      it-nota-doc.nr-nota-fis  = it-nota-fisc.nr-nota-fis
                      it-nota-doc.nr-seq-fat   = tt-it-nota-doc.nr-seq-fat
                      it-nota-doc.it-codigo    = tt-it-nota-doc.it-codigo
                      it-nota-doc.sequencia    = tt-it-nota-doc.sequencia
                      it-nota-doc.serie-doc    = tt-it-nota-doc.serie-doc
                      it-nota-doc.nr-nota-doc  = tt-it-nota-doc.nr-nota-doc
                      it-nota-doc.nr-seq-doc   = tt-it-nota-doc.nr-seq-doc
                      it-nota-doc.cod-emitente = tt-it-nota-doc.cod-emitente
                      it-nota-doc.nat-operacao = tt-it-nota-doc.nat-operacao         
                      it-nota-doc.dt-saida     = tt-it-nota-doc.dt-saida
                      it-nota-doc.dec-1        = tt-it-nota-doc.dec-1
                      it-nota-doc.vl-estorno   = tt-it-nota-doc.vl-estorno.
            end.
    &endif
                    
if  substr(tt-docto.char-1,1,20) <> "????????????????????" 
and (    tt-docto.esp-docto = 20    /* NFD */ 
     or  b-natur-oper-it.terceiros  
     or  b-natur-oper-it.transf   ) 
then DO:
    
    IF (param-global.modulo-ex OR param-global.modulo-07) THEN DO:
        FOR FIRST emitente FIELDS(natureza)
            WHERE emitente.cod-emitente = it-nota-fisc.cd-emitente NO-LOCK:
        END.
        IF AVAIL emitente 
             AND (emitente.natureza = 3 OR emitente.natureza = 4) THEN DO:
                
                FOR FIRST b-nota-fiscal FIELDS(char-1)
                    WHERE b-nota-fiscal.serie        = it-nota-fisc.serie-docum   
                      AND b-nota-fiscal.nr-nota-fis  = it-nota-fisc.nr-docum
                      AND b-nota-fiscal.nat-operacao = it-nota-fisc.nat-docum   NO-LOCK:
                    
                    ASSIGN it-nota-fisc.ct-cusven = substr(b-nota-fiscal.char-1,1,17). 
                END.
        END.
        ELSE
            assign it-nota-fisc.ct-cusven = substr(tt-docto.char-1,1,17). 
    END.
    ELSE
        assign it-nota-fisc.ct-cusven = substr(tt-docto.char-1,1,17). 
END.

/* Totaliza o Pis e Cofins Substituto para gravar nas observa‡äes */
assign de-tot-pis-subst    = de-tot-pis-subst
                           + it-nota-fisc.vl-pis
       de-tot-cofins-subst = de-tot-cofins-subst
                           + it-nota-fisc.vl-finsocial.

/* INTERNACIONAL: Nota de Cr‚dito */
    
if  i-pais-impto-usuario <> 1
and tt-docto.ind-tip-nota = 4 then do:
    
    create devol-cli.
    assign devol-cli.cod-emitente = nota-fiscal.cod-emitente
           devol-cli.cod-estabel  = nota-fiscal.cod-estabel
           devol-cli.dt-devol     = nota-fiscal.dt-emis-nota
           devol-cli.identific    = emitente.identific
           devol-cli.ind-atu-est  = no
           devol-cli.it-codigo    = it-nota-fisc.it-codigo
           devol-cli.cod-refer    = it-nota-fisc.cod-refer
           devol-cli.nat-operacao = it-nota-fisc.nat-operacao
           devol-cli.nome-ab-emi  = emitente.nome-abrev
           devol-cli.serie        = tt-docto.serie-dif
           devol-cli.nr-nota-fis  = tt-docto.nr-nota-dif
           devol-cli.nr-sequencia = tt-it-docto.nr-sequencia
           devol-cli.nro-docto    = nota-fiscal.nr-nota-fis
           devol-cli.qt-devolvida = if  tt-docto.vl-acres-dif = 0 
                                    and tt-docto.perc-acres-dif = 0 
                                    and tt-it-docto.baixa-estoq then
                                        it-nota-fisc.qt-faturada[1]
                                    else 0
           devol-cli.serie-docto  = nota-fiscal.serie
           devol-cli.sequencia    = it-nota-fisc.nr-seq-fat
           devol-cli.vl-devol     = it-nota-fisc.vl-merc-liq.
           
    &if defined(bf_dis_nota_credito) &then 
        assign devol-cli.serie        = tt-it-docto.serie-comp
               devol-cli.nr-nota-fis  = tt-it-docto.nro-comp
               devol-cli.nr-sequencia = tt-it-docto.seq-comp
               devol-cli.qt-devolvida = it-nota-fisc.qt-faturada[1]
               it-nota-fisc.ct-cusven = "".  
    &endif         
           
end.

/*----Grava Descontos de ICMS, PIS e COFINS para Opera‡Æo Zona Franca - ZFM----*/

/*ICMS*/
ASSIGN it-nota-fisc.dec-1 = tt-it-docto.desconto-zf.

/*PIS/COFINS*/
ASSIGN OVERLAY(it-nota-fisc.char-1,128,16) = STRING(DEC(SUBSTRING(tt-it-docto.char-2,140,16)))
       OVERLAY(it-nota-fisc.char-1,145,16) = STRING(DEC(SUBSTRING(tt-it-docto.char-2,156,16))).
       
/*----FIM - Grava Descontos de ICMS, PIS e COFINS para Opera‡Æo Zona Franca - ZFM----*/

/*---- Simples Nacional - Grava as aliquotas do simples nacional ----*/

ASSIGN c-cod-csosn      = SUBSTRING(tt-it-docto.char-2,245,10)                        
       de-base-icms-sn  = (DEC(SUBSTRING(tt-it-docto.char-2,255,13)) / 10000)  
       de-cred-sn       = (DEC(SUBSTRING(tt-it-docto.char-2,268,13)) / 10000). 

&IF "{&bf_dis_versao_ems}" >= "2.09" &THEN
assign it-nota-fisc.cod-csosn                 = c-cod-csosn
       it-nota-fisc.val-base-icms-simples-nac = STRING(de-base-icms-sn)
       it-nota-fisc.val-cr-icms-simples-nac   = STRING(de-cred-sn) no-error.
&ELSE
assign OVERLAY(it-nota-fisc.char-1,227,08) = c-cod-csosn
       OVERLAY(it-nota-fisc.char-1,187,20) = STRING(de-base-icms-sn)
       OVERLAY(it-nota-fisc.char-1,207,20) = STRING(de-cred-sn) no-error.
&ENDIF

/*----*/

/*---- GRAVA NRO DA FCI RECEBIDO NA IMPORTACAO DE NOTAS FT2015 ----*/
RUN pi-grava-FCI-notas-importadas IN h-bodi538 (INPUT TRIM(SUBSTRING(tt-it-docto.char-2,281,36)),  /*Nro FCI importado via txt no FT2015*/
                                                INPUT ROWID(it-nota-fisc)). 
/*----*/

/*---- eSocial - Grava informa‡äes do INSS para o eSocial ----*/

assign OVERLAY(it-nota-fisc.char-2,270,2)  = TRIM(SUBSTRING(tt-it-docto.char-2,317,02))
       OVERLAY(it-nota-fisc.char-2,272,16) = TRIM(SUBSTRING(tt-it-docto.char-2,319,16)).
       
/*--- eSocial ---*/

/*---- ISS RETIDO ----*/
ASSIGN OVERLAY(it-nota-fisc.char-2,190,14) = SUBSTR(tt-it-imposto.char-1,65,14) /* base de calculo */
       OVERLAY(it-nota-fisc.char-2,204,14) = SUBSTR(tt-it-imposto.char-1,79,14) /* percentual */
       OVERLAY(it-nota-fisc.char-2,218,14) = SUBSTR(tt-it-imposto.char-1,93,14). /* valor da reten»ao */
/*---- ISS RETIDO ----*/
               
/*  FT2010.I3  */
