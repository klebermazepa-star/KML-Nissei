DEFINE VARIABLE i-excecao       AS INTEGER     NO-UNDO.
DEFINE VARIABLE c-cod-ean       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cest-entrada    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cest-saida      AS CHARACTER   NO-UNDO.

{cdp/cdapi1001.i}
DEF VAR h-cdapi1001             AS WIDGET-HANDLE NO-UNDO.



define temp-table TT-PARAM NO-UNDO
       field destino                AS INTEGER
        field execucao               as INTEGER
        field arquivo                as char format "x(35)"
        field usuario                as char format "x(12)"
        field data-exec              as date
        field hora-exec              as integer
        field classifica             as integer
        field desc-classifica        as char format "x(40)"
        field modelo                 AS char format "x(35)"
        field l-habilitaRtf          as log
        FIELD EstabelecOrigInicial  as char 
        FIELD EstabelecOrigFinal    as char 
        FIELD ItemIni               as char 
        FIELD ItemFinal             as char 
        FIELD GrupoEstIni           AS INTEGER   
        FIELD GrupoEstFinal         AS INTEGER   
        FIELD FamMatIni             AS char 
        FIELD FamMatFinal           AS char 
        FIELD NcmIni                AS INT 
        FIELD NcmFinal              AS INT 
        FIELD CstIni                AS INTEGER   
        FIELD CstFinal              AS INTEGER   
        FIELD com-subst-tribut       AS LOG         
        FIELD sem-subst-tribut       AS LOG. 



DEFINE TEMP-TABLE tt-itemFiscal NO-UNDO
    FIELD it-codigo         AS CHAR    
    FIELD descricao         AS CHAR 
    FIELD estado-origem     AS CHAR    
    FIELD estado-destino    AS CHAR     
    FIELD itemFaturavel     AS CHAR
    FIELD unidadeMedida     AS CHAR
    FIELD origem            AS INT 
    FIELD codigoTR          AS INT  // codigo tributo icms
    FIELD aliquotaICMS      AS DEC  // ja contempla interno e externo de acordo com o estado
    FIELD ncm               AS CHAR 
    FIELD CestEntrada       AS CHAR    
    FIELD CestSaida         AS CHAR    
    FIELD registroAnvisa    AS CHAR
    FIELD ge-codigo         AS INT 
    FIELD mvaOriginal       AS DEC
    FIELD mvaAjustada       AS DEC
    FIELD percST-est        AS DEC     
    FIELD percST-int        AS DEC 
    FIELD RBEST             AS DEC     
    FIELD rast              AS DEC  // icms diferimento   
    FIELD codigoEAN         AS CHAR    
    FIELD familia           AS CHAR    
    FIELD desc-familia      AS CHAR    
    FIELD aliquotaPis       AS DEC     
    FIELD aliquotaCofins    AS DEC     
    FIELD pmc               AS DEC
    FIELD fornec         AS CHAR
    FIELD lista             AS CHAR.
   
   /*
    FIELD reducaoICMS       AS DEC     
    FIELD codigoTR-externo  AS INT     
    FIELD aliquotaST-est    AS DEC     
    FIELD reducaoST-est     AS DEC     
    FIELD codigoTR-inter    AS DEC     
    FIELD aliquota-inter    AS DEC     
    FIELD reducaoST-inter   AS DEC     
    
    FIELD aliquotaST-inter  AS DEC     
    FIELD reducaoST         AS DEC     
   
    
    FIELD aliq-ipi          AS DEC     
    FIELD lista             AS CHAR    
      
        
    FIELD IES               AS DEC     
  
   
    FIELD utilizaPauta      AS CHAR    
    FIELD utilizMva         AS CHAR    
    FIELD valorPauta        AS DEC     
   
    FIELD itemFaturavel     AS CHAR    
    FIELD c-status          AS CHAR   */ 
    

    
define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.

/* Transfer Definitions */
def temp-table tt-raw-digita
   field raw-digita      as raw.
   

    
/* Recebimentro de Parametros */   
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.
                                                                  
create tt-param.
raw-transfer raw-param to tt-param.    


def var h-acomp as handle no-undo.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Processando...').

    
DEFINE BUFFER b-unid-feder FOR ems2mult.unid-feder.

FOR EACH ITEM  NO-LOCK
     WHERE item.cod-obsoleto   = 1     // Somente itens ativos
       AND ITEM.it-codigo      >= TT-PARAM.ItemIni
       AND ITEM.it-codigo      <= TT-PARAM.ItemFinal
       AND ITEM.ge-codigo      >= tt-param.GrupoEstIni  
       AND ITEM.ge-codigo      <= tt-param.GrupoEstFinal
       AND ITEM.fm-codigo      >= tt-param.FamMatIni    
       AND ITEM.fm-codigo      <= tt-param.FamMatFinal  
       AND item.class-fiscal   >= string(tt-param.NcmIni)       
       AND item.class-fiscal   <= string(tt-param.NcmFinal)     
       AND item.codigo-orig    >= tt-param.CstIni       
       AND item.codigo-orig    <= tt-param.CstFinal     
       :

    run pi-acompanhar IN h-acomp ( "Item:" + string(ITEM.it-codigo) ).
       
    FIND FIRST familia NO-LOCK
        WHERE familia.fm-codigo = ITEM.fm-codigo NO-ERROR.
        
    // Busca do EAN na tabela item-mat
    FIND FIRST item-mat NO-LOCK 
        WHERE item-mat.it-codigo = item.it-codigo NO-ERROR.
        
    IF AVAIL item-mat THEN DO:
        assign c-cod-ean = item-mat.cod-ean.
    END.
    ELSE DO:
        ASSIGN c-cod-ean = SUBSTR(ITEM.char-1,133,16).
    END.
    
    IF NOT VALID-HANDLE(h-cdapi1001) THEN
        RUN cdp/cdapi1001.p     PERSISTENT SET h-cdapi1001.
    
    EMPTY TEMP-TABLE tt-sit-tribut.
    RUN pi-seta-tributos IN h-cdapi1001 (input "11").
    RUN pi-retorna-sit-tribut IN h-cdapi1001 (INPUT  1,
                                            INPUT  "*",
                                            INPUT  "*",
                                            INPUT  ITEM.class-fiscal,
                                            INPUT  ITEM.it-codigo,
                                            INPUT  "*",
                                            INPUT  0,
                                            INPUT  TODAY,
                                            OUTPUT TABLE tt-sit-tribut).

    FOR FIRST tt-sit-tribut:
        IF string(tt-sit-tribut.cdn-sit-tribut) <> "0" THEN  
            ASSIGN cest-entrada = string(tt-sit-tribut.cdn-sit-tribut).
    END. 
    
    EMPTY TEMP-TABLE tt-sit-tribut.
    RUN pi-seta-tributos IN h-cdapi1001 (input "11").
    RUN pi-retorna-sit-tribut IN h-cdapi1001 (INPUT  2,
                                            INPUT  "*",
                                            INPUT  "*",
                                            INPUT  ITEM.class-fiscal,
                                            INPUT  ITEM.it-codigo,
                                            INPUT  "*",
                                            INPUT  "0",
                                            INPUT  TODAY,
                                            OUTPUT TABLE tt-sit-tribut).  
                                            
    FOR FIRST tt-sit-tribut:
        IF string(tt-sit-tribut.cdn-sit-tribut) <> "0" THEN 
            ASSIGN cest-saida = string(tt-sit-tribut.cdn-sit-tribut).
    END.    
    
    // Busca por estado
    FOR EACH ems2mult.estabelec NO-LOCK
        WHERE estabelec.ep-codigo = "10"  // Somente merco
        BREAK BY estabelec.estado:
        
        IF FIRST-OF(estabelec.estado) THEN
        DO:
        
            FIND FIRST b-unid-feder NO-LOCK
                WHERE b-unid-feder.estado = estabelec.estado NO-ERROR.
        
            FOR EACH ems2mult.unid-feder NO-LOCK
                WHERE unid-feder.pais = "BRASIL":  // Somente estados do brasil
                
                CREATE tt-itemFiscal.
                ASSIGN tt-itemFiscal.it-codigo      = item.it-codigo
                       tt-itemFiscal.descricao      = item.desc-item 
                       tt-itemFiscal.ge-codigo      = ITEM.ge-codigo
                       tt-itemFiscal.unidadeMedida  = ITEM.un
                       tt-itemFiscal.codigoEAN      = c-cod-ean
                       tt-itemFiscal.estado-origem  = estabelec.estado
                       tt-itemFiscal.estado-destino = unid-feder.estado
                       // tt-itemFiscal.aliq-ipi       = ITEM.aliquota-ipi
                       tt-itemFiscal.ncm            = ITEM.class-fiscal
                       tt-itemFiscal.origem           = item.codigo-orig
                       tt-itemFiscal.familia        = item.fm-codigo
                       tt-itemFiscal.desc-familia   = IF AVAIL familia THEN familia.descricao ELSE ""
                       tt-itemFiscal.CestEntrada    = cest-entrada
                       tt-itemFiscal.CestSaida      = cest-saida
                       tt-itemFiscal.registroAnvisa = ""
                       tt-itemFiscal.itemFaturavel  = IF ind-item-fat = YES THEN "S" ELSE "N"
                       .
                
                run pi-acompanhar IN h-acomp ( "Item:" + string(tt-itemFiscal.it-codigo)) .
                
                ASSIGN tt-itemFiscal.aliquotaPIS    = dec(SUBSTRING(item.char-2,31,5)) .
                ASSIGN tt-itemFiscal.aliquotaCofins = dec(SUBSTRING(item.char-2,36,5)) .

                // Busca PMC na tabela de pre»o CD1508
                FIND LAST ems2dis.preco-item
                    WHERE preco-item.nr-tabpre = "PMC 17%"  // Ideal criar cadastro para informar a tabela PMC
                      AND preco-item.it-codigo  = ITEM.it-codigo NO-ERROR.
                
                IF AVAIL preco-item THEN
                      ASSIGN tt-itemFiscal.pmc = preco-item.preco-venda.
                ELSE 
                      ASSIGN tt-itemFiscal.pmc = 0.                 
                
                //Busca RAST
                
                FOR EACH item-fornec    NO-LOCK
                    WHERE item-fornec.it-codigo =  ITEM.it-codigo :
                    
                    ASSIGN tt-itemFiscal.fornec = string(item-fornec.cod-emitente).  
                    
                END.
                
                
                FIND FIRST diferim-parcial-icms NO-LOCK
                    WHERE diferim-parcial-icms.cod-item = ITEM.it-codigo
                    AND   diferim-parcial-icms.cod-estado = b-unid-feder.estado NO-ERROR.

                IF AVAIL diferim-parcial-icms THEN
                DO:
                   
                    ASSIGN tt-itemFiscal.rast          = diferim-parcial-icms.val-perc-icms-diferim
                         //  tt-itemFiscal.reducaoST-est = diferim-parcial-icms.val-perc-icms-diferim
                           
                        .   

                END.
                
                // Busca c½digo TR
                FIND FIRST item-uf NO-LOCK
                    WHERE item-uf.it-codigo         = ITEM.it-codigo
                      AND item-uf.cod-estado-orig   = estabelec.estado
                      AND item-uf.estado            = unid-feder.estado 
                      AND item-uf.cod-estab         >= TT-PARAM.EstabelecOrigInicial
                      AND item-uf.cod-estab         <= TT-PARAM.EstabelecOrigFinal
                      NO-ERROR.
                
                IF AVAIL item-uf THEN
                DO:
                
                    IF item-uf.cod-estado-orig = item-uf.estado THEN DO:
                    
                        ASSIGN tt-itemFiscal.codigoTR           = 5
                             //  tt-itemFiscal.reducaoICMS        = item-uf.perc-red-sub
                             // tt-itemFiscal.reducaoST          = item-uf.perc-red-sub
                               tt-itemFiscal.mvaOriginal        = IF item-uf.cod-estado-orig = item-uf.estado 
                                                                    THEN item-uf.per-sub-tri ELSE 0
                              // tt-itemFiscal.aliquota-inter     = IF item-uf.cod-estado-orig = item-uf.estado 
                              //                                      THEN 0 ELSE item-uf.per-sub-tri
                               tt-itemFiscal.aliquotaICMS         = IF item-uf.cod-estado-orig = item-uf.estado
                                                                                    THEN item-uf.dec-1 ELSE 0 //item-uf.per-sub-tri
                               tt-itemFiscal.percST-int         = IF item-uf.cod-estado-orig = item-uf.estado 
                                                                    THEN 0 ELSE item-uf.per-sub-tri.                    
                               tt-itemFiscal.mvaAjustada        = IF item-uf.cod-estado-orig = item-uf.estado 
                                                                    THEN 0 ELSE item-uf.per-sub-tri.
                                                                    
                                                                    
                               tt-itemFiscal.RBEST              = IF item-uf.cod-estado-orig = item-uf.estado 
                                                                    THEN item-uf.val-perc-reduc-tab-pauta ELSE 0.                                     
                       
                        
                    END.
                    ELSE DO:
                        
                        
                        ASSIGN tt-itemFiscal.aliquotaICMS         = IF item-uf.cod-estado-orig <> item-uf.estado
                                                                                    THEN item-uf.dec-1 ELSE 0. //item-uf.per-sub-tri
                    
                    
                    END.

                    
                END.
                ELSE DO:  //Caso n’o tenha ST pegar tributo conforme CD0903
                
                    ASSIGN tt-itemFiscal.codigoTR = ITEM.cd-trib-icm.
                END.
                
                
                DEF VAR c-lista AS CHAR NO-UNDO.
                
                ASSIGN c-lista = "".
                
                FOR FIRST it-carac-tec 
                    WHERE it-carac-tec.it-codigo = ITEM.it-codigo and
                      it-carac-tec.cd-folha  = "CADITEM"      AND
                      it-carac-tec.cd-comp   = "90"
                    NO-LOCK :
                    
                   ASSIGN c-lista = it-carac-tec.observacao.
                     
                END.
                
                ASSIGN tt-itemFiscal.lista    = substr(c-lista,1,1).

                
                
                // Busca Aliquota ICMS
                
                IF  estabelec.estado = unid-feder.estado THEN DO: // Opera»¹o interna
                
                    ASSIGN //tt-itemFiscal.aliquotaICMS = unid-feder.per-icms-int
                           tt-itemFiscal.percST-est   = unid-feder.per-icms-int.
                    
                END.
                ELSE DO: // Opera»¹o externa
                
                    ASSIGN //tt-itemFiscal.aliquotaICMS = b-unid-feder.per-icms-ext
                           tt-itemFiscal.percST-int   = b-unid-feder.per-icms-ext.
                    
                    // Atribuir estados com exce»’o
                    ASSIGN i-excecao = 1.
                    DO WHILE i-excecao <= 12:

                        IF b-unid-feder.est-exc[i-excecao] = unid-feder.estado THEN DO:
                         
                            ASSIGN //tt-itemFiscal.aliquotaICMS = b-unid-feder.perc-exc[i-excecao] 
                                   tt-itemFiscal.percST-int   = b-unid-feder.perc-exc[i-excecao] .
                            
                        END.
                        ASSIGN i-excecao = i-excecao + 1.
                        
                    END.              
                
                END.
                
                // Busca TR Externo
                /*
                IF b-unid-feder.ind-uf-subs = YES THEN DO:
                
                    IF AVAIL item-uf AND item-uf.per-sub-tri > 0 THEN 
                        ASSIGN codigoTR-externo = 5.
                        
                END. */
                
                // Busca IES 
                /*
                IF item.codigo-orig = 1 THEN
                    ASSIGN tt-itemFiscal.IES = 4.
                ELSE 
                    ASSIGN tt-itemFiscal.IES = tt-itemFiscal.aliquotaICMS.
                 */
            END.
 
        END.
        
    END.     
     
END.

DEF VAR cDataHora AS CHAR NO-UNDO.

ASSIGN
    cDataHora = STRING(TODAY, "99999999").

if tt-param.execucao <> 2 then do:

    output to value ("U:\espfi001.csv").
	
END.	
ELSE DO:

	OUTPUT TO VALUE ("D:\Shares\Nissei\RPW\prod\rpw-fila-Merco1\espfi001-" + cDataHora + ".csv").
	
end.

PUT UNFORMATTED
    "Item;" 
    "Fornecedor;" 
    "Descricao;" 
    "item Faturavel;" 
    "UN item;" 
    "Origem;" 
    "Cod. Trib. ICMS;" 
    "%ICMS int;" 
    "%ICMS interestadual;" 
    "Class fiscal;" 
    "CEST Entrada;" 
    "CEST Saida;" 
    "Registro Anvisa;" 
    "Grupo Est;"
    "Percentual ICMS Diferimento;"
    "UF Origem;" 
    "UF Destino;" 
    "MVA Original;" 
    "MVA Ajustada;" 
    "%ICMS (ST);" 
    "RBST;" 
    "EAN;"
    "Lista PIS/COFINS;"
    "Familia;" 
    "Descricao Familia;" 
    "PMC;" 
    "Aliquota PIS;" 
    "Aliquota COFINS;" SKIP.



FOR EACH tt-itemFiscal:
    
    run pi-acompanhar IN  h-acomp ( "Excel - Item:" + string(tt-itemFiscal.it-codigo) ).
    
    EXPORT DELIMITER ";" 
         tt-itemFiscal.it-codigo 
         tt-itemFiscal.fornec
         tt-itemFiscal.descricao
         tt-itemFiscal.itemFaturavel
         tt-itemFiscal.unidadeMedida
         tt-itemFiscal.origem
         tt-itemFiscal.codigoTR
         tt-itemFiscal.percST-est
         tt-itemFiscal.percST-int
         tt-itemFiscal.ncm
         tt-itemFiscal.CestEntrada
         tt-itemFiscal.CestSaida 
         tt-itemFiscal.registroAnvisa
         tt-itemFiscal.ge-codigo
         tt-itemFiscal.rast
         tt-itemFiscal.estado-origem  
         tt-itemFiscal.estado-destino 
         tt-itemFiscal.mvaOriginal    
         tt-itemFiscal.mvaAjustada
         tt-itemFiscal.aliquotaICMS
         tt-itemFiscal.RBEST 
         tt-itemFiscal.codigoEAN
         tt-itemFiscal.lista
         tt-itemFiscal.familia        
         tt-itemFiscal.desc-familia
         tt-itemFiscal.pmc
         tt-itemFiscal.aliquotaPis    
         tt-itemFiscal.aliquotaCofins 
         .

         
         
         
END.

if tt-param.execucao <> 2 then do:

	OS-COMMAND NO-WAIT VALUE("U:\espfi001.csv").

end.


run pi-finalizar in h-acomp.

return "OK":U.


