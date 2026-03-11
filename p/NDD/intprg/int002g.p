/********************************************************************************
**  Programa ........: intprg/int002g.p
**  Data ............: Abril/2016
**  Objetivo ........: Integraá∆o com o PRS
*****************************************************************************************************/

{intprg/int002b.i}

define temp-table tt-param no-undo
field destino          as integer
field arquivo          as char format "x(35)":U
field usuario          as char format "x(12)":U
field data-exec        as date
field hora-exec        as integer
field classifica       as integer
field desc-classifica  as char format "x(40)":U
field modelo           AS char format "x(35)":U
field l-habilitaRtf    as LOG
FIELD dt-trans-ini     LIKE docum-est.dt-trans
FIELD dt-trans-fin     LIKE docum-est.dt-trans
FIELD i-nro-docto-ini  LIKE docum-est.nro-docto
FIELD i-nro-docto-fin  LIKE docum-est.nro-docto
FIELD i-cod-emit-ini   LIKE docum-est.cod-emitente
FIELD i-cod-emit-fin   LIKE docum-est.cod-emitente.


DEF INPUT  PARAMETER TABLE FOR tt-param.
DEF INPUT  PARAMETER TABLE FOR tt-docto-xml.
DEF INPUT  PARAMETER TABLE FOR tt-it-docto-xml.
def input  parameter table for TT-XML-DUP.
DEF OUTPUT PARAMETER p-log-ok AS LOG NO-UNDO.
                     
DEF VAR de-tot-quantidade         LIKE int_ds_it_docto_xml.qCom.
DEF VAR de-tot-base-ipi           LIKE int_ds_it_docto_xml.vbc_ipi.
DEF VAR de-tot-vlr-ipi            LIKE int_ds_it_docto_xml.vipi. 
DEF VAR de-tot-base-icms-isento   LIKE int_ds_it_docto_xml.vbc_icms.
DEF VAR de-tot-base-icms-diferido LIKE int_ds_it_docto_xml.vbc_icms.
def var de-tot-valor-produtos     like int_ds_nota_entrada.nen_valortotalprodutos_n.
DEF VAR de-vl-liquido             LIKE it-nota-fisc.vl-merc-liq.
DEF VAR i-cfop                    LIKE tt-it-docto-xml.cfop.
DEF VAR i-num-pedido              LIKE tt-it-docto-xml.num_pedido. 
DEF VAR c-item-do-forn            AS CHAR.
DEF VAR c-it-codigo               AS CHAR.
DEF VAR i-pos                     AS INTEGER.
DEF VAR c-num-pedido              AS CHAR.
def var l-sem-item                as logical no-undo.
def var l-vendavel                as logical no-undo.
DEF VAR de-vbc-cst-fcp            LIKE int_ds_it_docto_xml.vicms.
DEFINE VARIABLE de-vl-liquido-fri AS DECIMAL     NO-UNDO.

find first tt-param no-error.      

DEFINE BUFFER b-item-fornec FOR item-fornec.
DEFINE BUFFER b-item-fornec-umd FOR item-fornec-umd.

/* tratar notas de entrada nas lojas */
FOR EACH tt-docto-xml WHERE
         tt-docto-xml.dEmi         >= tt-param.dt-trans-ini    AND 
         tt-docto-xml.dEmi         <= tt-param.dt-trans-fin    AND 
         tt-docto-xml.NNF          >= tt-param.i-nro-docto-ini AND 
         tt-docto-xml.NNF          <= tt-param.i-nro-docto-fin AND
         tt-docto-xml.cod_emitente >= tt-param.i-cod-emit-ini  AND 
         tt-docto-xml.cod_emitente <= tt-param.i-cod-emit-fin  AND 
         tt-docto-xml.cod_estab    <> "973"                    AND 
         tt-docto-xml.tipo_estab    = 2 /* Loja */             and
         tt-docto-xml.tipo_docto   <> 5 /* balanco - vai pelo int011 */       
    BREAK BY tt-docto-xml.arquivo query-tuning(no-lookahead):  
                
    ASSIGN l-vendavel = NO.
    FIND FIRST emitente NO-LOCK WHERE 
               emitente.cod-emitente = tt-docto-xml.cod_emitente NO-ERROR.
    IF emitente.cod-gr-forn = 5 
    OR emitente.cod-gr-forn = 6 THEN
       ASSIGN l-vendavel = YES.

    ASSIGN de-tot-quantidade = 0
           de-tot-base-ipi   = 0
           de-tot-vlr-ipi    = 0
           de-tot-base-icms-isento   = 0
           de-tot-base-icms-diferido = 0
           i-num-pedido              = 0
           p-log-ok                  = NO
           de-vbc-cst-fcp            = 0.
                            
    FIND first int_ds_nota_entrada where 
        int_ds_nota_entrada.nen_cnpj_origem_s = tt-docto-xml.CNPJ      and
        int_ds_nota_entrada.nen_serie_s       = tt-docto-xml.serie     and  
        int_ds_nota_entrada.nen_notafiscal_n  = int(tt-docto-xml.nnf)  NO-ERROR.
    
    if avail int_ds_nota_entrada then next.            
    
    /*
    IF tt-docto-xml.tipo-docto = 5    /* Notas de Balanáo Atualiza o Estoque autom†tico */
    THEN*/ DO:
       ASSIGN i-num-pedido = int(tt-docto-xml.num_pedido) NO-ERROR.
    END.

    /* notas j† integradas e processadas n∆o ser∆o alteradas 
    for first int_ds_nota_entrada where 
        int_ds_nota_entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ      and
        int_ds_nota_entrada.nen-serie-s       = tt-docto-xml.serie     and  
        int_ds_nota_entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf)  and
        int_ds_nota_entrada.nen-datamovimentacao-d <> ?:               end.
    if avail int_ds_nota_entrada then next.            
    
    for first int_ds_nota_entrada where 
        int_ds_nota_entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ      and
        int_ds_nota_entrada.nen-serie-s       = tt-docto-xml.serie     and  
        int_ds_nota_entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf): 
        assign int_ds_nota_entrada.situacao = 0. /* evitanto processamento paralelo pelo PRS */
        for each int_ds_nota_entrada_produto of int_ds_nota_entrada:
            delete int_ds_nota_entrada_produt.
        end.
    end.
    */
    i-cfop = 0.
    de-tot-valor-produtos = 0.
    for each tt-it-docto-xml where 
             tt-it-docto-xml.tipo_nota  = tt-docto-xml.tipo_nota AND
             tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ      AND
             tt-it-docto-xml.nNF        = tt-docto-xml.nNF       AND
             tt-it-docto-xml.serie      = tt-docto-xml.serie     and
             tt-it-docto-xml.arquivo    = tt-docto-xml.arquivo
        break by tt-it-docto-xml.CNPJ       
              by tt-it-docto-xml.serie         
              by tt-it-docto-xml.nNF
              by tt-it-docto-xml.item_do_forn query-tuning(no-lookahead):
              
        LOG-MANAGER:WRITE-MESSAGE("KML - 10 - dentro int002g - achou tt-it-docto-xml" + 
                                  " - tt-it-docto-xml.vbc_pis - "   + string(tt-it-docto-xml.vbc_pis) + 
                                  " - tt-it-docto-xml.ppis - "      + string(tt-it-docto-xml.ppis) + 
                                  " - tt-it-docto-xml.vpis - "      + string(tt-it-docto-xml.vpis)  ) NO-ERROR.              


          /*  Alteraá∆o Kleber Mazepa - Validar se a nota de entrada Ç por unidade de medida diferente de CX ou UN para utilizar fator de convers∆o
        OBS: Alteraá∆o tempor†ria atÇ a virada da OBLAK para o PROCFIT   */


        if tt-docto-xml.tipo_nota = 3 then 
           assign de-vl-liquido-fri   = tt-it-docto-xml.vtottrib.
        else
           assign de-vl-liquido-fri   = tt-it-docto-xml.vprod - tt-it-docto-xml.vDesc. 

        IF      tt-it-docto-xml.uCom_forn <> "UN" 
            AND tt-it-docto-xml.uCom_forn <> "CX"   THEN DO:

            FIND FIRST b-item-fornec NO-LOCK
                WHERE b-item-fornec.item-do-forn  = trim(tt-it-docto-xml.item_do_forn)
                  AND b-item-fornec.cod-emitente  = tt-docto-xml.cod_emitente NO-ERROR.

            IF AVAIL b-item-fornec THEN DO:

                IF b-item-fornec.unid-med-for  = tt-it-docto-xml.uCom_forn THEN DO:

                    ASSIGN tt-it-docto-xml.qcom = tt-it-docto-xml.qcom / (b-item-fornec.fator-conver / EXP(10, b-item-fornec.num-casa-dec)).
                    ASSIGN tt-it-docto-xml.vUnCom = dec(de-vl-liquido-fri / tt-it-docto-xml.qcom).
    
                END.
                ELSE DO:

                    FIND FIRST b-item-fornec-umd NO-LOCK
                        WHERE b-item-fornec-umd.it-codigo     = b-item-fornec.it-codigo
                          AND b-item-fornec-umd.cod-emitente  = tt-docto-xml.cod_emitente
                          AND b-item-fornec-umd.unid-med-for  = tt-it-docto-xml.uCom_forn
                    NO-ERROR.
                    
                    IF AVAIL b-item-fornec-umd THEN DO:

                        ASSIGN tt-it-docto-xml.qcom   = tt-it-docto-xml.qcom / (b-item-fornec-umd.fator-conver / EXP(10, b-item-fornec-umd.num-casa-dec)).
                        ASSIGN tt-it-docto-xml.vUnCom = dec(de-vl-liquido-fri / tt-it-docto-xml.qcom).
    
                    END.

                END.
            END.
            ELSE DO:

                FIND FIRST b-item-fornec-umd NO-LOCK
                    WHERE b-item-fornec-umd.cod-livre-1   = trim(tt-it-docto-xml.item_do_forn)
                      AND b-item-fornec-umd.cod-emitente  = tt-docto-xml.cod_emitente
                      AND b-item-fornec-umd.unid-med-for  = tt-it-docto-xml.uCom_forn
                NO-ERROR.
                
                IF AVAIL b-item-fornec-umd THEN DO:

                    ASSIGN tt-it-docto-xml.qcom   = tt-it-docto-xml.qcom / (b-item-fornec-umd.fator-conver / EXP(10, b-item-fornec-umd.num-casa-dec)).
                    ASSIGN tt-it-docto-xml.vUnCom = dec(de-vl-liquido-fri / tt-it-docto-xml.qcom).

                END.


            END.

        END.
    
         /* Fim alteraá∆o Kleber Mazepa*/

        /*assign l-vendavel = no
               l-sem-item = no.*/
        assign de-tot-quantidade = de-tot-quantidade + tt-it-docto-xml.qCom
               de-tot-base-ipi   = de-tot-base-ipi   + tt-it-docto-xml.vbc_ipi
               de-tot-vlr-ipi    = de-tot-vlr-ipi    + tt-it-docto-xml.vipi
               i-cfop            = tt-it-docto-xml.cfop.

        assign c-item-do-forn = trim(tt-it-docto-xml.item_do_forn).
        FIND first item-fornec NO-LOCK 
            WHERE item-fornec.cod-emitente = tt-docto-xml.cod_emitente 
              AND item-fornec.item-do-forn = c-item-do-forn 
              AND item-fornec.ativo = YES NO-ERROR. 


        if not avail item-fornec then do:
            assign c-item-do-forn = string(int(tt-it-docto-xml.item_do_forn)) no-error.
            if error-status:error then 
               assign c-item-do-forn = string(tt-it-docto-xml.item_do_forn).
            FIND first item-fornec 
                no-lock where
                item-fornec.cod-emitente = tt-docto-xml.cod_emitente and
                item-fornec.item-do-forn = c-item-do-forn and
                item-fornec.ativo = YES NO-ERROR.

        end.
            
        c-it-codigo = "".
        if avail item-fornec THEN DO:

           assign c-it-codigo = item-fornec.it-codigo.

        END.
        ELSE DO:

             FIND FIRST item-fornec-umd NO-LOCK
                WHERE item-fornec-umd.cod-livre-1   = trim(tt-it-docto-xml.item_do_forn)
                  AND item-fornec-umd.cod-emitente  = tt-docto-xml.cod_emitente
                  AND item-fornec-umd.unid-med-for  = tt-it-docto-xml.uCom_forn NO-ERROR.
             IF AVAIL item-fornec-umd THEN DO:
                
                 assign c-it-codigo = item-fornec-umd.it-codigo.

             END.
             ELSE DO:
             
                 IF tt-it-docto-xml.it_codigo <> "" THEN
                    assign c-it-codigo = tt-it-docto-xml.it_codigo.
             END.
             /*
             ELSE 
                ASSIGN c-it-codigo = tt-it-docto-xml.item-do-forn.
                */
        END.

        if tt-it-docto-xml.lote = ? then tt-it-docto-xml.lote = "".
        FIND first int_ds_nota_entrada_produt where 
                  int_ds_nota_entrada_produt.nen_cnpj_origem_s = tt-it-docto-xml.CNPJ           and 
                  int_ds_nota_entrada_produt.nen_serie_s       = tt-docto-xml.serie             and 
                  int_ds_nota_entrada_produt.nen_notafiscal_n  = int(tt-it-docto-xml.nNF)       and 
                  int_ds_nota_entrada_produt.nep_sequencia_n   = tt-it-docto-xml.sequencia      and 
                  int_ds_nota_entrada_produt.nep_produto_n     = int(c-it-codigo)               and
                  int_ds_nota_entrada_produt.alternativo_fornecedor  = tt-it-docto-xml.item_do_forn and
                  int_ds_nota_entrada_produt.nep_lote_s        = tt-it-docto-xml.lote NO-ERROR.        
        
        IF i-num-pedido = 0 AND tt-it-docto-xml.num_pedido <> 0 THEN
             ASSIGN i-num-pedido = tt-it-docto-xml.num_pedido.

        if not avail int_ds_nota_entrada_produt 
        then do:
        
            LOG-MANAGER:WRITE-MESSAGE("KML - 11 - antes create int_ds_produto - achou tt-it-docto-xml" + 
                                      " - tt-it-docto-xml.vbc_pis - "   + string(tt-it-docto-xml.vbc_pis) + 
                                      " - tt-it-docto-xml.ppis - "      + string(tt-it-docto-xml.ppis) + 
                                      " - tt-it-docto-xml.vpis - "      + string(tt-it-docto-xml.vpis)  ) NO-ERROR.              
        
        

            create int_ds_nota_entrada_produt.
            assign int_ds_nota_entrada_produt.nen_cnpj_origem_s       = tt-it-docto-xml.CNPJ          
                   int_ds_nota_entrada_produt.nen_serie_s             = tt-docto-xml.serie            
                   int_ds_nota_entrada_produt.nen_notafiscal_n        = int(tt-it-docto-xml.nNF)      
                   int_ds_nota_entrada_produt.nen_cfop_n              = tt-it-docto-xml.cfop          
                   int_ds_nota_entrada_produt.nep_sequencia_n         = tt-it-docto-xml.sequencia     
                   int_ds_nota_entrada_produt.nep_produto_n           = int(c-it-codigo) 
                   int_ds_nota_entrada_produt.nep_lote_s              = tt-it-docto-xml.lote
                   int_ds_nota_entrada_produt.nep_quantidade_n        = tt-it-docto-xml.qcom 
                   int_ds_nota_entrada_produt.nep_redutorbaseicms_n   = tt-it-docto-xml.predBc
                   int_ds_nota_entrada_produt.alternativo_fornecedor  = tt-it-docto-xml.item_do_forn
                   int_ds_nota_entrada_produt.ped_codigo_n            = /*IF tt-docto-xml.tipo-docto = 5 then */ i-num-pedido.

            assign int_ds_nota_entrada_produt.nep_ncm_n               = tt-it-docto-xml.ncm.
            assign int_ds_nota_entrada_produt.npx_descricaoproduto_s  = tt-it-docto-xml.xProd
                   int_ds_nota_entrada_produt.npx_ean_n               = tt-it-docto-xml.dEan.
            
            assign int_ds_nota_entrada_produt.nep_percentualicms_n   = tt-it-docto-xml.picms
                   int_ds_nota_entrada_produt.nep_percentualipi_n    = tt-it-docto-xml.pipi      
                   int_ds_nota_entrada_produt.nep_percentualpis_n    = tt-it-docto-xml.ppis 
                   int_ds_nota_entrada_produt.nep_percentualcofins_n = tt-it-docto-xml.pcofins 
                   int_ds_nota_entrada_produt.nep_datavalidade_d     = tt-it-docto-xml.dval
                   int_ds_nota_entrada_produt.nep_csta_n             = tt-it-docto-xml.orig_icms  /* nacional 0 importado 1 */ 
                   int_ds_nota_entrada_produt.nep_cstb_icm_n         = /*tt-it-docto-xml.vbcst*/ tt-it-docto-xml.cst_icm
                   int_ds_nota_entrada_produt.nep_cstb_ipi_n         = /*tt-it-docto-xml.vbc-ipi*/ tt-it-docto-xml.cst_ipi
                   int_ds_nota_entrada_produt.de-vbcstret            = tt-it-docto-xml.vbcstret
                   int_ds_nota_entrada_produt.de-vicmsstret          = tt-it-docto-xml.vicmsstret.

        end. 
        /*if c-it-codigo <> "" then do:
            for first item no-lock where item.it-codigo = c-it-codigo query-tuning(no-lookahead): 
            end.
            if avail item and item.ge-codigo <= 80 then do:
                assign l-vendavel = yes.
            end.
            else do:
                assign l-sem-item = yes.
            end.
        end.
        else do:
            assign l-sem-item = yes.
        END.*/

        if tt-it-docto-xml.cst_icms = 40 then
           assign de-tot-base-icms-isento = de-tot-base-icms-isento + tt-it-docto-xml.vbc_icms
                  int_ds_nota_entrada_produt.nep_baseisenta_n = /*int_ds_nota_entrada_produt.nep-baseisenta-n +*/ tt-it-docto-xml.vbc_icms.

        if tt-it-docto-xml.cst_icms = 51 then 
           assign de-tot-base-icms-diferido = de-tot-base-icms-diferido + tt-it-docto-xml.vbc_icms
                  int_ds_nota_entrada_produt.nep_basediferido_n = /*int_ds_nota_entrada_produt.nep-basediferido-n +*/ tt-it-docto-xml.vbc_icms.
        if tt-docto-xml.tipo_nota = 3 then 
           assign de-vl-liquido   = tt-it-docto-xml.vtottrib.
        else
           assign de-vl-liquido   = tt-it-docto-xml.vprod - tt-it-docto-xml.vDesc.  
        assign int_ds_nota_entrada_produt.nep_valorliquido_n     = /*int_ds_nota_entrada_produt.nep-valorliquido-n    +   */  de-vl-liquido.
        
        assign int_ds_nota_entrada_produt.nep_valorbruto_n       = /* int_ds_nota_entrada_produt.nep-valorbruto-n      +  */ tt-it-docto-xml.vProd
               int_ds_nota_entrada_produt.nep_valordesconto_n    = /* int_ds_nota_entrada_produt.nep-valordesconto-n   +  */ tt-it-docto-xml.vDesc
               int_ds_nota_entrada_produt.nep_baseicms_n         = /* int_ds_nota_entrada_produt.nep-baseicms-n        +  */ tt-it-docto-xml.vbc_icms
               int_ds_nota_entrada_produt.nep_valoricms_n        = /* int_ds_nota_entrada_produt.nep-valoricms-n       +  */ tt-it-docto-xml.vicms
               int_ds_nota_entrada_produt.nep_baseipi_n          = /* int_ds_nota_entrada_produt.nep-baseipi-n         +  */ tt-it-docto-xml.vbc_ipi
               int_ds_nota_entrada_produt.nep_valoripi_n         = /* int_ds_nota_entrada_produt.nep-valoripi-n        +  */ tt-it-docto-xml.vipi
               int_ds_nota_entrada_produt.valor_fcp_st           = IF tt-it-docto-xml.valor_fcp_st = ? THEN 0 ELSE tt-it-docto-xml.valor_fcp_st     /* novo 4.0 */
               int_ds_nota_entrada_produt.nep_icmsst_n           = /* int_ds_nota_entrada_produt.nep-icmsst-n          +  */ tt-it-docto-xml.vicmsst + int_ds_nota_entrada_produt.valor_fcp_st
               int_ds_nota_entrada_produt.nep_basest_n           = /* int_ds_nota_entrada_produt.nep-basest-n          +  */ tt-it-docto-xml.vbcst
               int_ds_nota_entrada_produt.nep_valordespesa_n     = /* int_ds_nota_entrada_produt.nep-valordespesa-n    +  */ tt-it-docto-xml.vOutro
               int_ds_nota_entrada_produt.nep_basepis_n          = /* int_ds_nota_entrada_produt.nep-basepis-n         +  */ tt-it-docto-xml.vbc_pis
               int_ds_nota_entrada_produt.nep_valorpis_n         = /* int_ds_nota_entrada_produt.nep-valorpis-n        +  */ tt-it-docto-xml.vpis
               int_ds_nota_entrada_produt.nep_basecofins_n       = /* int_ds_nota_entrada_produt.nep-basecofins-n      +  */ tt-it-docto-xml.vbc_cofins
               int_ds_nota_entrada_produt.nep_valorcofins_n      = /* int_ds_nota_entrada_produt.nep-valorcofins-n     +  */ tt-it-docto-xml.vcofins
               int_ds_nota_entrada_produt.nep_valor_icms_des_n   = /* int_ds_nota_entrada_produt.nep-valor-icms-des-n  +  */ tt-it-docto-xml.vicmsdeson

               int_ds_nota_entrada_produt.CEST                   = tt-it-docto-xml.CEST             /* novo 4.0 */
               int_ds_nota_entrada_produt.EANTrib                = tt-it-docto-xml.EANTrib          /* novo 4.0 */
               int_ds_nota_entrada_produt.anvisa                 = tt-it-docto-xml.anvisa           /* novo 4.0 */
               int_ds_nota_entrada_produt.valor_fcp              = IF tt-it-docto-xml.valor_fcp        = ? THEN 0 ELSE tt-it-docto-xml.valor_fcp        /* novo 4.0 */
               int_ds_nota_entrada_produt.valor_fcp_st_ret       = IF tt-it-docto-xml.valor_fcp_st_ret = ? THEN 0 ELSE tt-it-docto-xml.valor_fcp_st_ret /* novo 4.0 */
               int_ds_nota_entrada_produt.valor_ipi_devol        = IF tt-it-docto-xml.valor_ipi_devol  = ? THEN 0 ELSE tt-it-docto-xml.valor_ipi_devol  /* novo 4.0 */
               int_ds_nota_entrada_produt.vbcst_fcp              = IF tt-it-docto-xml.vbcst_fcp        = ? THEN 0 ELSE tt-it-docto-xml.vbcst_fcp        /* novo 4.0 */
               int_ds_nota_entrada_produt.picmsst_fcp            = IF tt-it-docto-xml.picmsst_fcp      = ? THEN 0 ELSE tt-it-docto-xml.picmsst_fcp.     /* novo 4.0 */

        /* capos dicionais solicitados pela PROCFIT - AVB Produá∆o em 17/04/2018 */
        assign int_ds_nota_entrada_produt.nep_modbcicms_n        = tt-it-docto-xml.modbc
               int_ds_nota_entrada_produt.nep_modbcst_n          = tt-it-docto-xml.modbcst
               int_ds_nota_entrada_produt.nep_pmvast_n           = tt-it-docto-xml.pmvast
               int_ds_nota_entrada_produt.nep_cenq_n             = tt-it-docto-xml.cenq
               int_ds_nota_entrada_produt.nep_cstpis_n           = tt-it-docto-xml.cst_pis
               int_ds_nota_entrada_produt.nep_cstcofins_n        = tt-it-docto-xml.cst_cofins
               int_ds_nota_entrada_produt.nep_vpmc_n             = tt-it-docto-xml.vPMC
               int_ds_nota_entrada_produt.nep_uComForn_s         = tt-it-docto-xml.uCom_forn
               int_ds_nota_entrada_produt.nep_qComForn_n         = tt-it-docto-xml.qCom_forn
               int_ds_nota_entrada_produt.nep_uCom_s             = tt-it-docto-xml.uCom
               int_ds_nota_entrada_produt.nep_vUnCom_n           = tt-it-docto-xml.vUnCom
               int_ds_nota_entrada_produt.nep_picmsst            = tt-it-docto-xml.picmsst
               INT_Ds_nota_entrada_produt.vICMSSubs              = tt-it-docto-xml.vICMSSubs.
               
        LOG-MANAGER:WRITE-MESSAGE("KML - 12 - depois create int_ds_produto - achou tt-it-docto-xml" + 
                                  " - int_ds_nota_entrada_produt.nep_percentualpis_n - "   + string(int_ds_nota_entrada_produt.nep_percentualpis_n) + 
                                  " - int_ds_nota_entrada_produt.nep_basepis_n - "      + string(int_ds_nota_entrada_produt.nep_basepis_n) + 
                                  " - int_ds_nota_entrada_produt.nep_valorpis_n - "      + string(int_ds_nota_entrada_produt.nep_valorpis_n)  ) NO-ERROR.               

        assign i-cfop = tt-it-docto-xml.cfop.
        assign de-tot-valor-produtos = de-tot-valor-produtos + int_ds_nota_entrada_produt.nep_valorbruto_n
               de-vbc-cst-fcp        = de-vbc-cst-fcp + int_ds_nota_entrada_produt.vbcst_fcp.
        release int_ds_nota_entrada_produt.

    end. /* tt-it-docto-xml */

    /* duplicatas da nota se for de compra */
    def var dt-valida as date no-undo.
    def var l-valida as logical no-undo.
    l-valida = yes.
    for each tt-xml-dup query-tuning(no-lookahead):
        dt-valida = date(int(substring(tt-xml-dup.dVenc,6,2)),
                         int(substring(tt-xml-dup.dVenc,9,2)),
                         int(substring(tt-xml-dup.dVenc,1,4))) no-error.
        if error-status:error then l-valida = no.
    end.
    if l-valida then
    for each tt-xml-dup query-tuning(no-lookahead):
        FIND first int_ds_nota_entrada_dup where 
            int_ds_nota_entrada_dup.nen_cnpj_origem_s = tt-docto-xml.CNPJ       and
            int_ds_nota_entrada_dup.nen_serie_s       = tt-docto-xml.serie      and
            int_ds_nota_entrada_dup.nen_notafiscal_n  = int(tt-docto-xml.nnf)   and
            int_ds_nota_entrada_dup.nen_data_vencto_d = date(int(substring(tt-xml-dup.dVenc,6,2)),
                                                             int(substring(tt-xml-dup.dVenc,9,2)),
                                                             int(substring(tt-xml-dup.dVenc,1,4))) NO-ERROR.
        
        if not avail int_ds_nota_entrada_dup then do:
            create  int_ds_nota_entrada_dup.
            assign  int_ds_nota_entrada_dup.nen_cnpj_origem_s = tt-docto-xml.CNPJ    
                    int_ds_nota_entrada_dup.nen_serie_s       = tt-docto-xml.serie   
                    int_ds_nota_entrada_dup.nen_notafiscal_n  = int(tt-docto-xml.nnf)
                    int_ds_nota_entrada_dup.nen_cfop_n        = i-cfop      
                    int_ds_nota_entrada_dup.nen_data_vencto_d = date(int(substring(tt-xml-dup.dVenc,6,2)),
                                                                     int(substring(tt-xml-dup.dVenc,9,2)),
                                                                     int(substring(tt-xml-dup.dVenc,1,4))).
        end.
        assign  int_ds_nota_entrada_dup.nen_duplicata_s = trim(tt-xml-dup.nDup)
                int_ds_nota_entrada_dup.nen_valor_duplicata_n = tt-xml-dup.vDup.
            
    end.


    FIND first int_ds_nota_entrada where 
        int_ds_nota_entrada.nen_cnpj_origem_s = tt-docto-xml.CNPJ      and
        int_ds_nota_entrada.nen_serie_s       = tt-docto-xml.serie     and  
        int_ds_nota_entrada.nen_notafiscal_n  = int(tt-docto-xml.nnf)  NO-ERROR.
 
    if not avail int_ds_nota_entrada 
    then do:
       IF tt-docto-xml.tipo_docto = 5 THEN DO:
           ASSIGN l-vendavel = NO.
       END.

       create int_ds_nota_entrada.
       assign int_ds_nota_entrada.envio_status       = 0
              int_ds_nota_entrada.nen_cnpj_origem_s  = tt-docto-xml.CNPJ          /* CNPJ fornecedor/estabelecimento origem */
              int_ds_nota_entrada.nen_serie_s        = tt-docto-xml.serie         /*  Serie da nota fiscal */    
              int_ds_nota_entrada.nen_notafiscal_n   = int(tt-docto-xml.nnf)      /*  Numero da nota fiscal  */
              int_ds_nota_entrada.nen_cfop_n         = i-cfop                     /*  CFOP da nota fiscal Ç por item */
              int_ds_nota_entrada.tipo_movto         = 1                          /* 1 - Inclus∆o 2 - Alteraá∆o 3 - Exclus∆o */ 
              int_ds_nota_entrada.id_sequencial      = NEXT-VALUE(seq-int-ds-nota-entrada) /* Preparaá∆o para integraá∆o com Procfit */.

    end.
    else assign int_ds_nota_entrada.tipo_movto   = 2
                int_ds_nota_entrada.envio_status = 0.

    assign int_ds_nota_entrada.dt_geracao               =  today
           int_ds_nota_entrada.hr_geracao               =  string(time,"HH:MM:SS").
                                                           /* nao vendaveis n∆o passam por conferencia */
    assign int_ds_nota_entrada.situacao                 =  if l-vendavel = YES THEN 1 ELSE 2 /* 1 - Pendente 2 - Integrado */     
           int_ds_nota_entrada.nen_conferida_n          =  if l-vendavel = YES THEN 0 ELSE 1 /* 1 - Conferida, 0 - A conferir */
           int_ds_nota_entrada.nen_datamovimentacao_d   =  if l-vendavel = YES THEN ? ELSE tt-docto-xml.demi 
           int_ds_nota_entrada.nen_cnpj_destino_s       =  tt-docto-xml.cnpj_dest      /* CNPJ estabelecimento de destino */
           int_ds_nota_entrada.nen_dataemissao_d        =  tt-docto-xml.demi           /*  Data emissao da nota fiscal */   
           int_ds_nota_entrada.nen_quantidade_n         =  de-tot-quantidade            /*  Quantidde total da nota fiscal */
           int_ds_nota_entrada.nen_desconto_n           =  tt-docto-xml.tot_desconto   /*  Desconto total da nota fiscal  */
           int_ds_nota_entrada.nen_baseicms_n           =  tt-docto-xml.vbc            /*  Base ICMS total nota fiscal    */
           int_ds_nota_entrada.nen_valoricms_n          =  tt-docto-xml.valor_icms     /*  Valor total do ICMS da nota fiscal    */  
           int_ds_nota_entrada.nen_basediferido_n       =  de-tot-base-icms-diferido    /*  Base de icms diferido da nota fiscal  */
           int_ds_nota_entrada.nen_baseisenta_n         =  de-tot-base-icms-isento      /*  Base total ICMS isento da nota fiscal */
           int_ds_nota_entrada.nen_baseipi_n            =  de-tot-base-ipi              /*  Base IPI  */
           int_ds_nota_entrada.nen_valoripi_n           =  de-tot-vlr-ipi               /*  Valor total do IPI da nota fiscal */
           int_ds_nota_entrada.nen_basest_n             =  tt-docto-xml.vbc_cst        /*  Base ICMS ST */
           int_ds_nota_entrada.valor_fcp_st             =  IF tt-docto-xml.valor_fcp_st = ? THEN 0 ELSE tt-docto-xml.valor_fcp_st     /* novo 4.0 */
           int_ds_nota_entrada.nen_icmsst_n             =  tt-docto-xml.valor_st + int_ds_nota_entrada.valor_fcp_st /*  Valor do ICMS ST total da nota */
           int_ds_nota_entrada.nen_chaveacesso_s        =  tt-docto-xml.chnfe          /* Chave de acesso NFe */ 
           int_ds_nota_entrada.nen_frete_n              =  tt-docto-xml.valor_frete    /* Frete total da nota */
           int_ds_nota_entrada.nen_seguro_n             =  tt-docto-xml.valor_seguro   /* Seguro total da nota  */
           int_ds_nota_entrada.nen_despesas_n           =  tt-docto-xml.valor_outras   /* Despesas total da nota */
           int_ds_nota_entrada.ped_procfit              =  i-num-pedido                 /* Num pedido dos itens p/ procfit */
           int_ds_nota_entrada.tipo_nota                =  tt-docto-xml.tipo_nota
           int_ds_nota_entrada.nen_observacao_s         =  tt-docto-xml.observacao  + chr(13) + "NDDID: " + trim(STRING(tt-docto-xml.arquivo))   /* Observacao da nota fiscal */
           int_ds_nota_entrada.nen_modalidade_frete_n   =  tt-docto-xml.modFrete    /* Modalidade do frete (0-FOB 1-CIF) */
           int_ds_nota_entrada.nen_valortotalprodutos_n =  /*tt-docto-xml.valor-mercad  /*  Valor total da mercadoria */.*/ de-tot-valor-produtos /* armazenando para comparar depois com o total terornado pelo Sisfarma. */

           int_ds_nota_entrada.valor_fcp                = IF tt-docto-xml.valor_fcp        = ? THEN 0 ELSE tt-docto-xml.valor_fcp        /* novo 4.0 */
           int_ds_nota_entrada.valor_fcp_st_ret         = IF tt-docto-xml.valor_fcp_st_ret = ? THEN 0 ELSE tt-docto-xml.valor_fcp_st_ret /* novo 4.0 */
           int_ds_nota_entrada.valor_ipi_devol          = IF tt-docto-xml.valor_ipi_devol  = ? THEN 0 ELSE tt-docto-xml.valor_ipi_devol  /* novo 4.0 */
           int_ds_nota_entrada.tpag                     = tt-docto-xml.tpag                                                              /* novo 4.0 */
           int_ds_nota_entrada.vpag                     = IF tt-docto-xml.vpag             = ? THEN 0 ELSE tt-docto-xml.vpag             /* novo 4.0 */
           int_ds_nota_entrada.vbc_cst_fcp              = de-vbc-cst-fcp.                                                                /* novo 4.0 */
   
    ASSIGN int_ds_nota_entrada.ped_codigo_n = 0.

    /* PEPSICO preenche pedido - PROCFIT X OLBAK */
    FOR EACH estabelec NO-LOCK WHERE 
        estabelec.cgc = int_ds_nota_entrada.nen_cnpj_origem_s AND
        estabelec.cod-estabel = "973" query-tuning(no-lookahead):
        FOR EACH emitente NO-LOCK WHERE 
            emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s query-tuning(no-lookahead):
            FIND int_ds_ext_emitente NO-LOCK WHERE
                 int_ds_ext_emitente.cod_emitente = emitente.cod-emitente NO-ERROR.

            IF (AVAIL int_ds_ext_emitente AND  
                      int_ds_ext_emitente.gera_nota) OR 
                      tt-docto-xml.tipo_docto = 0
            THEN DO:

                ASSIGN int_ds_nota_entrada.ped_codigo_n = i-num-pedido.                                

            END.
        END.
    END.

    /* notas do estabelecimento 500 n∆o passam por conferencia */
    for first estabelec no-lock where estabelec.cgc = int_ds_nota_entrada.nen_cnpj_destino_s and
        estabelec.cod-estabel = "500" query-tuning(no-lookahead):
        assign int_ds_nota_entrada.situacao                 =  2
               int_ds_nota_entrada.nen_conferida_n          =  1
               int_ds_nota_entrada.nen_datamovimentacao_d   =  tt-docto-xml.demi.
    end.
    /*
    IF int_ds_nota_entrada.tipo-movto = 1 AND 
       tt-docto-xml.tipo-docto = 5    /* Notas de Balanáo Atualiza o Estoque autom†tico */
    THEN DO:

       CREATE int_ds_docto_wms.
       ASSIGN int_ds_docto_wms.doc_numero_n   = INT(tt-docto-xml.nnf)
              int_ds_docto_wms.doc_serie_s    = tt-docto-xml.serie   
              int_ds_docto_wms.doc_origem_n   = tt-docto-xml.cod-emitente
              int_ds_docto_wms.situacao       = 1. /* Inclus∆o */
              int_ds_docto_wms.id_sequencial  = next-value(seq-int-ds-docto-wms) /* Preparaá∆o para integraá∆o com Procfit */
    
       FIND FIRST emitente WHERE
                  emitente.cod-emitente = tt-docto-xml.cod-emitente NO-LOCK NO-ERROR.
       IF AVAIL emitente THEN 
          ASSIGN int_ds_docto_wms.cnpj_cpf        = emitente.cgc 
                 int_ds_docto_wms.tipo_fornecedor = IF emitente.natureza = 1 THEN "F" ELSE "J".

    END.
    */
    ASSIGN int_ds_nota_entrada.envio_status = 1.

    release int_ds_nota_entrada.
    ASSIGN p-log-ok = YES.
    RETURN "OK".
end. /* TT-DOCTO-XML */

empty temp-table tt-xml-dup.
empty temp-table tt-docto-xml.
empty temp-table tt-it-docto-xml.



