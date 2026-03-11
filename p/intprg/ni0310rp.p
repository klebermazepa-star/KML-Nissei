/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i NI0310RP 2.00.00.000}  /*** 010000 ***/

{utp/ut-glob.i}

/***Defini‡äes***/
def var h-acomp         as handle    no-undo.
DEF VAR l-re1001        AS LOGICAL   NO-UNDO.
DEF VAR i-sit-re1001    AS INT       NO-UNDO.
DEF VAR l-re2001        AS LOGICAL   NO-UNDO.
DEF VAR i-sit-re2001    AS INT       NO-UNDO.
DEF VAR l-duplic        AS LOGICAL   NO-UNDO.
DEF VAR i-parc          AS INT  FORMAT "99" NO-UNDO.
DEF VAR da-dt-trans     AS DATE FORMAT "99/99/9999" NO-UNDO.
DEF VAR da-dt-conf      AS DATE FORMAT "99/99/9999" NO-UNDO.
DEF VAR l-int520        AS LOGICAL  NO-UNDO.
DEF VAR i-tot-notas     AS INT      NO-UNDO.
DEF VAR i-tot-nao-atu   AS INT      NO-UNDO.
DEF VAR i-tot-atu       AS INT      NO-UNDO.
DEF VAR i-tot-nao-integ AS INT      NO-UNDO.
DEF VAR dt-emis         AS DATE     NO-UNDO.
DEF VAR da-atualiza     AS DATE     NO-UNDO.

DEF TEMP-TABLE tt-notas 
    FIELD cod-estabel    LIKE estabelec.cod-estabel                                
    FIELD cod-emitente   LIKE emitente.cod-emitente               
    FIELD serie          LIKE int_ds_docto_xml.serie              
    FIELD nr-nota        LIKE int_ds_docto_xml.nnf                
    FIELD parcela        AS CHAR FORMAT "x(2)"                                    
    FIELD valor-nf       LIKE int_ds_docto_xml.vnf   
    FIELD valor-dup      LIKE dupli-apagar.vl-a-pagar
    FIELD dt-emissao-nf  AS DATE FORMAT "99/99/9999"     
    FIELD dt-emissao-dup AS DATE FORMAT "99/99/9999"
    FIELD dt-vencto      AS DATE FORMAT "99/99/9999"                                   
    FIELD cd-loja        AS CHAR FORMAT "x(4)"                                
    FIELD re2001         AS LOGICAL FORMAT "Sim/NÆo"     
    FIELD sit-re2001     AS CHAR FORMAT "x(14)"
    FIELD re1001         AS LOGICAL FORMAT "Sim/NÆo"                  
    FIELD sit-re1001     AS CHAR FORMAT "x(14)"
    FIELD confer         AS LOGICAL FORMAT "Sim/NÆo"                                  
    FIELD int520         AS LOGICAL FORMAT "Sim/NÆo"                                  
    FIELD financeiro     AS LOGICAL FORMAT "Sim/NÆo"
    FIELD nr-pedido      AS INT FORMAT ">>>>>>>>9"
    FIELD dt-trans       AS DATE FORMAT "99/99/9999"
    FIELD dt-conf        AS DATE FORMAT "99/99/9999"
    FIELD dt-atualiza    AS DATE FORMAT "99/99/9999"
    INDEX codigo
            cod-estabel 
            cod-emitente
            serie       
            nr-nota.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field estab-ini        as char 
    field estab-fim        as char 
    field emit-ini         as INT 
    field emit-fim         as INT
    FIELD emiss-ini        AS DATE
    FIELD emiss-fim        AS DATE
    FIELD vencto-ini       AS DATE
    FIELD vencto-fim       AS DATE.

def temp-table tt-digita
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id is primary unique
        ordem. 

def temp-table tt-raw-digita                   
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

find first param-global no-lock no-error.

find first tt-param NO-LOCK NO-ERROR.

{include/i-rpvar.i}

assign c-titulo-relat = "Relat¢rio para PrevisÆo de Fluxo de Caixa"
       c-sistema      = "Espec¡fico"
       c-empresa      = param-global.grupo.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Gerando Informa‡äes").
                        
/* {include/i-rpcab.i} */

{include/i-rpc255.i}
{include/i-rpout.i}

view frame f-cabec-255.
view frame f-rodape-255.
   
EMPTY TEMP-TABLE tt-notas.

IF tt-param.estab-ini >= "973"
OR tt-param.estab-fim >= "973" THEN DO:
   DO dt-emis = tt-param.emiss-ini TO tt-param.emiss-fim:
      FOR EACH int_ds_docto_xml WHERE
               int_ds_docto_xml.demi      = dt-emis AND
               int_ds_docto_xml.cnpj_dest = "79430682025540" /* 973 */ AND
               int_ds_docto_xml.tipo_nota = 1 NO-LOCK:

          FOR FIRST emitente WHERE 
                    emitente.cgc = int_ds_docto_xml.cnpj NO-LOCK :
          END.
          IF NOT AVAIL emitente THEN 
             NEXT.

          IF tt-param.emit-ini > emitente.cod-emitente  
          OR tt-param.emit-fim < emitente.cod-emitente THEN 
             NEXT.

          RUN pi-acompanhar IN h-acomp (INPUT "Fornec. -> CD: " + int_ds_docto_xml.nnf + "  Data: " + string(int_ds_docto_xml.demi,"99/99/9999")). 

          ASSIGN l-re2001     = NO
                 l-re1001     = NO
                 l-duplic     = NO
                 i-sit-re1001 = 1
                 i-sit-re2001 = 1
                 da-dt-trans  = ?
                 l-int520     = NO
                 da-dt-conf   = ?
                 da-atualiza  = ?.

          FOR FIRST int_ds_docto_wms WHERE
                    int_ds_docto_wms.doc_numero_n = int_ds_docto_xml.nNF        AND 
                    int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie      AND 
                    int_ds_docto_wms.cnpj_cpf     = int_ds_docto_xml.CNPJ       AND 
                    int_ds_docto_wms.doc_origem_n = int_ds_docto_xml.cod_emitente NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
              ASSIGN da-dt-conf = int_ds_docto_wms.datamovimentacao_d.
          END.

          FOR FIRST doc-fisico WHERE 
                        doc-fisico.nro-docto    = int_ds_docto_xml.nNF       AND  
                        doc-fisico.serie-docto  = int_ds_docto_xml.serie     AND                                
                        doc-fisico.tipo-nota    = int_ds_docto_xml.tipo_nota AND     
                        doc-fisico.cod-emitente = emitente.cod-emitente NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
          END.
          IF AVAIL doc-fisico THEN DO:
             ASSIGN l-re2001     = YES
                    i-sit-re2001 = IF doc-fisico.situacao = 1 THEN 1 ELSE 2
                    da-dt-trans  = doc-fisico.dt-trans
                    da-atualiza  = doc-fisico.dt-atualiza
                    l-int520     = YES.

          END.
          ELSE 
             ASSIGN i-sit-re2001 = 9.

          FOR FIRST docum-est WHERE
                    docum-est.nro-docto    = int_ds_docto_xml.nNF     AND 
                    docum-est.serie        = int_ds_docto_xml.serie   AND
                    docum-est.tipo-nota    = int_ds_docto_xml.tipo_nota    AND 
                    docum-est.cod-emitente = emitente.cod-emitente NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
          END.
          IF AVAIL docum-est THEN DO:
             ASSIGN l-re1001     = YES
                    i-sit-re1001 = IF docum-est.ce-atual = YES THEN 2 ELSE 1
                    da-dt-trans  = docum-est.dt-trans
                    da-atualiza  = docum-est.dt-atualiza
                    l-int520     = YES.

            IF da-atualiza = ?  THEN 
                ASSIGN da-atualiza = docum-est.ok-data.
                                                          
             FOR EACH dupli-apagar OF docum-est WHERE 
                      dupli-apagar.dt-vencim >= tt-param.vencto-ini AND 
                      dupli-apagar.dt-vencim <= tt-param.vencto-fim NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):

                 CREATE tt-notas.
                 ASSIGN tt-notas.cod-estabel    = "973"
                        tt-notas.cod-emitente   = emitente.cod-emitente
                        tt-notas.serie          = int_ds_docto_xml.serie
                        tt-notas.nr-nota        = int_ds_docto_xml.nnf
                        tt-notas.valor-nf       = docum-est.tot-valor
                        tt-notas.nr-pedido      = int_ds_docto_xml.num_pedido
                        tt-notas.parcela        = dupli-apagar.parcela
                        tt-notas.valor-dup      = dupli-apagar.vl-a-pagar
                        tt-notas.dt-emissao-nf  = int_ds_docto_xml.demi
                        tt-notas.dt-emissao-dup = dupli-apagar.dt-emissao
                        tt-notas.dt-vencto      = dupli-apagar.dt-vencim
                        tt-notas.cd-loja        = "CD"
                        tt-notas.re2001         = l-re2001
                        tt-notas.sit-re2001     = IF i-sit-re2001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re2001 = 2 THEN "Atualizado" ELSE ""
                        tt-notas.re1001         = l-re1001
                        tt-notas.sit-re1001     = IF i-sit-re1001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re1001 = 2 THEN "Atualizado" ELSE ""
                        tt-notas.confer         = YES
                        tt-notas.int520         = l-int520
                        tt-notas.financeiro     = YES
                        tt-notas.dt-trans       = da-dt-trans
                        tt-notas.dt-conf        = da-dt-conf
                        tt-notas.dt-atualiza    = da-atualiza
                        l-duplic                = YES.
             END.
          END.
          ELSE
             ASSIGN i-sit-re1001 = 9.
      
          IF l-duplic = NO THEN DO:
             CREATE tt-notas.
             ASSIGN tt-notas.cod-estabel    = "973"
                    tt-notas.cod-emitente   = emitente.cod-emitente
                    tt-notas.serie          = int_ds_docto_xml.serie
                    tt-notas.nr-nota        = int_ds_docto_xml.nnf
                    tt-notas.parcela        = ""
                    tt-notas.nr-pedido      = int_ds_docto_xml.num_pedido
                    tt-notas.valor-nf       = IF AVAIL docum-est THEN docum-est.tot-valor ELSE IF AVAIL doc-fisico THEN doc-fisico.valor-mercad ELSE int_ds_docto_xml.vnf
                    tt-notas.valor-dup      = 0
                    tt-notas.dt-emissao-nf  = int_ds_docto_xml.demi
                    tt-notas.dt-emissao-dup = ? 
                    tt-notas.dt-vencto      = ?
                    tt-notas.cd-loja        = "CD"
                    tt-notas.re2001         = l-re2001
                    tt-notas.sit-re2001     = IF i-sit-re2001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re2001 = 2 THEN "Atualizado" ELSE ""
                    tt-notas.re1001         = l-re1001
                    tt-notas.sit-re1001     = IF i-sit-re1001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re1001 = 2 THEN "Atualizado" ELSE ""
                    tt-notas.confer         = IF l-re1001 = YES OR l-re2001 = YES THEN YES ELSE NO
                    tt-notas.int520         = l-int520
                    tt-notas.financeiro     = NO
                    tt-notas.dt-trans       = da-dt-trans
                    tt-notas.dt-conf        = da-dt-conf
                    tt-notas.dt-atualiza    = da-atualiza.
          END.
      END.
   END.
END.

DO dt-emis = tt-param.emiss-ini TO tt-param.emiss-fim:
   FOR EACH int_ds_nota_entrada WHERE
            int_ds_nota_entrada.nen_dataemissao_d   = dt-emis AND
            int_ds_nota_entrada.nen_cnpj_destino_s <> "79430682025540" /* 973 */ AND
            int_ds_nota_entrada.tipo_nota           = 1 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):

       FOR FIRST emitente WHERE 
                 emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
       END.
       IF NOT AVAIL emitente THEN 
          NEXT.

       IF tt-param.emit-ini > emitente.cod-emitente  
       OR tt-param.emit-fim < emitente.cod-emitente THEN
          NEXT.

       FOR FIRST estabelec WHERE 
                 estabelec.cgc = int_ds_nota_entrada.nen_cnpj_destino_s NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
       END.
       IF NOT AVAIL estabelec THEN
          NEXT.

       IF tt-param.estab-ini > estabelec.cod-estabel  
       OR tt-param.estab-fim < estabelec.cod-estabel THEN
          NEXT.

       RUN pi-acompanhar IN h-acomp (INPUT "Fornec. -> Lojas: " + string(int_ds_nota_entrada.nen_notafiscal_n) + "  Data: " + string(int_ds_nota_entrada.nen_dataemissao_d,"99/99/9999")). 

       ASSIGN l-re2001     = NO
              l-re1001     = NO
              l-duplic     = NO
              i-parc       = 0
              i-sit-re1001 = 1
              i-sit-re2001 = 1
              da-dt-trans  = ?
              l-int520     = NO
              da-dt-conf   = IF int_ds_nota_entrada.nen_conferida_n >= 1 THEN
                                int_ds_nota_entrada.nen_datamovimentacao_d ELSE ?.

       FOR FIRST doc-fisico WHERE 
                 doc-fisico.nro-docto    = string(int_ds_nota_entrada.nen_notafiscal_n, "9999999") AND  
                 doc-fisico.serie-docto  = int_ds_nota_entrada.nen_serie_s           AND                                
                 doc-fisico.tipo-nota    = int_ds_nota_entrada.tipo_nota             AND     
                 doc-fisico.cod-emitente = emitente.cod-emitente NO-LOCK:
       END.
       IF AVAIL doc-fisico THEN DO:
          ASSIGN l-re2001     = YES
                 i-sit-re2001 = IF doc-fisico.situacao = 1 THEN 1 ELSE 2
                 da-dt-trans  = doc-fisico.dt-trans
                 l-int520     = YES.
       END.
       ELSE 
          ASSIGN i-sit-re2001 = 9.

       FOR FIRST docum-est WHERE
                 docum-est.nro-docto    = string(int_ds_nota_entrada.nen_notafiscal_n, "9999999")  AND 
                 docum-est.serie        = int_ds_nota_entrada.nen_serie_s      AND
                 docum-est.tipo-nota    = int_ds_nota_entrada.tipo_nota             AND 
                 docum-est.cod-emitente = emitente.cod-emitente NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
       END.
       IF AVAIL docum-est THEN DO:
          ASSIGN l-re1001     = YES
                 i-sit-re1001 = IF docum-est.ce-atual = YES THEN 2 ELSE 1
                 da-dt-trans  = docum-est.dt-trans
                 da-atualiza  = docum-est.dt-atualiza
                 l-int520     = YES.

            IF da-atualiza = ?  THEN 
                ASSIGN da-atualiza = docum-est.ok-data.
          
            FOR EACH dupli-apagar OF docum-est WHERE 
                   dupli-apagar.dt-vencim >= tt-param.vencto-ini AND 
                   dupli-apagar.dt-vencim <= tt-param.vencto-fim NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):

              CREATE tt-notas.
              ASSIGN tt-notas.cod-estabel    = estabelec.cod-estabel
                     tt-notas.cod-emitente   = emitente.cod-emitente
                     tt-notas.serie          = int_ds_nota_entrada.nen_serie_s
                     tt-notas.nr-nota        = string(int_ds_nota_entrada.nen_notafiscal_n)
                     tt-notas.valor-nf       = docum-est.tot-valor
                     tt-notas.nr-pedido      = int_ds_nota_entrada.ped_codigo_n
                     tt-notas.parcela        = dupli-apagar.parcela
                     tt-notas.valor-dup      = dupli-apagar.vl-a-pagar
                     tt-notas.dt-emissao-nf  = int_ds_nota_entrada.nen_dataemissao_d
                     tt-notas.dt-emissao-dup = dupli-apagar.dt-emissao
                     tt-notas.dt-vencto      = dupli-apagar.dt-vencim
                     tt-notas.cd-loja        = "LOJA"
                     tt-notas.re2001         = l-re2001
                     tt-notas.sit-re2001     = IF i-sit-re2001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re2001 = 2 THEN "Atualizado" ELSE ""
                     tt-notas.re1001         = l-re1001
                     tt-notas.sit-re1001     = IF i-sit-re1001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re1001 = 2 THEN "Atualizado" ELSE ""
                     tt-notas.confer         = YES
                     tt-notas.int520         = l-int520
                     tt-notas.financeiro     = YES
                     tt-notas.dt-trans       = da-dt-trans
                     tt-notas.dt-conf        = da-dt-conf
                     tt-notas.dt-atualiza    = da-atualiza
                     l-duplic                = YES.
          END.
       END.
       ELSE
          ASSIGN i-sit-re1001 = 9.

       IF l-duplic = NO THEN DO:
          FOR EACH int_ds_nota_entrada_dup OF int_ds_nota_entrada WHERE 
                   int_ds_nota_entrada_dup.nen_data_vencto_d >= tt-param.vencto-ini AND 
                   int_ds_nota_entrada_dup.nen_data_vencto_d <= tt-param.vencto-fim NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
              CREATE tt-notas.
              ASSIGN i-parc                  = i-parc + 1
                     tt-notas.cod-estabel    = estabelec.cod-estabel
                     tt-notas.cod-emitente   = emitente.cod-emitente
                     tt-notas.serie          = int_ds_nota_entrada.nen_serie_s
                     tt-notas.nr-nota        = string(int_ds_nota_entrada.nen_notafiscal_n)
                     tt-notas.valor-nf       = IF AVAIL docum-est THEN docum-est.tot-valor ELSE IF AVAIL doc-fisico THEN doc-fisico.valor-mercad ELSE int_ds_nota_entrada.nen_valortotalprodutos_n               
                     tt-notas.nr-pedido      = int_ds_nota_entrada.ped_codigo_n
                     tt-notas.parcela        = string(i-parc,"99")                                  
                     tt-notas.valor-dup      = int_ds_nota_entrada_dup.nen_valor_duplicata_n 
                     tt-notas.dt-emissao-nf  = int_ds_nota_entrada.nen_dataemissao_d    
                     tt-notas.dt-emissao-dup = int_ds_nota_entrada.nen_dataemissao_d
                     tt-notas.dt-vencto      = int_ds_nota_entrada_dup.nen_data_vencto_d
                     tt-notas.cd-loja        = "LOJA"  
                     tt-notas.re2001         = l-re2001
                     tt-notas.sit-re2001     = IF i-sit-re2001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re2001 = 2 THEN "Atualizado" ELSE ""
                     tt-notas.re1001         = l-re1001
                     tt-notas.sit-re1001     = IF i-sit-re1001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re1001 = 2 THEN "Atualizado" ELSE ""
                     tt-notas.confer         = IF l-re1001 = YES OR l-re2001 = YES THEN YES ELSE NO
                     tt-notas.int520         = l-int520
                     tt-notas.financeiro     = NO
                     tt-notas.dt-trans       = da-dt-trans
                     tt-notas.dt-conf        = da-dt-conf
                     tt-notas.dt-atualiza    = da-atualiza
                     l-duplic                = YES.
          END.
       END.
       
       IF l-duplic = NO THEN DO:
          CREATE tt-notas.
          ASSIGN tt-notas.cod-estabel    = estabelec.cod-estabel
                 tt-notas.cod-emitente   = emitente.cod-emitente
                 tt-notas.serie          = int_ds_nota_entrada.nen_serie_s
                 tt-notas.nr-nota        = string(int_ds_nota_entrada.nen_notafiscal_n)
                 tt-notas.valor-nf       = IF AVAIL docum-est THEN docum-est.tot-valor ELSE IF AVAIL doc-fisico THEN doc-fisico.valor-mercad ELSE int_ds_nota_entrada.nen_valortotalprodutos_n               
                 tt-notas.nr-pedido      = int_ds_nota_entrada.ped_codigo_n
                 tt-notas.parcela        = ""                                  
                 tt-notas.valor-dup      = 0
                 tt-notas.dt-emissao-nf  = int_ds_nota_entrada.nen_dataemissao_d    
                 tt-notas.dt-emissao-dup = ?
                 tt-notas.dt-vencto      = ?
                 tt-notas.cd-loja        = "LOJA"  
                 tt-notas.re2001         = l-re2001
                 tt-notas.sit-re2001     = IF i-sit-re2001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re2001 = 2 THEN "Atualizado" ELSE ""
                 tt-notas.re1001         = l-re1001
                 tt-notas.sit-re1001     = IF i-sit-re1001 = 1 THEN "NÆo Atualizado" ELSE IF i-sit-re1001 = 2 THEN "Atualizado" ELSE ""
                 tt-notas.confer         = IF l-re1001 = YES OR l-re2001 = YES THEN YES ELSE NO
                 tt-notas.int520         = l-int520
                 tt-notas.financeiro     = NO
                 tt-notas.dt-trans       = da-dt-trans
                 tt-notas.dt-conf        = da-dt-conf
                 tt-notas.dt-atualiza    = da-atualiza.
       END.
   END.
END.
                    
ASSIGN i-tot-notas     = 0
       i-tot-nao-atu   = 0
       i-tot-atu       = 0
       i-tot-nao-integ = 0.

FOR EACH tt-notas USE-INDEX codigo NO-LOCK 
    BREAK BY tt-notas.cod-estabel 
          BY tt-notas.cod-emitente
          BY tt-notas.serie       
          BY tt-notas.nr-nota:

    RUN pi-acompanhar IN h-acomp (INPUT "Imprimindo Nota: " + tt-notas.nr-nota). 
    
    DISP tt-notas.cod-estabel    COLUMN-LABEL "Estab"           WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.cod-emitente   COLUMN-LABEL "Fornecedor"      WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.serie          COLUMN-LABEL "S‚rie"           WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.nr-nota        COLUMN-LABEL "Documento"       WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.nr-pedido      COLUMN-LABEL "Num Pedido"      WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.valor-nf       COLUMN-LABEL "Valor Nota"      WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.dt-emissao-nf  COLUMN-LABEL "EmissÆo NF"      WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.dt-conf        COLUMN-LABEL "Data Movto"      WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.dt-trans       COLUMN-LABEL "Data Totvs"      WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.parcela        COLUMN-LABEL "Parc"       
         tt-notas.valor-dup      COLUMN-LABEL "Valor Duplic"
         tt-notas.dt-emissao-dup COLUMN-LABEL "EmissÆo Dup"
         tt-notas.dt-vencto      COLUMN-LABEL "Vencto Dup"
         tt-notas.cd-loja        COLUMN-LABEL "CD/LOJA"         WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.re2001         COLUMN-LABEL "RE2001"          WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.sit-re2001     COLUMN-LABEL "Situa‡Æo RE2001" WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.re1001         COLUMN-LABEL "RE1001"          WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.sit-re1001     COLUMN-LABEL "Situa‡Æo RE1001" WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.confer         COLUMN-LABEL "Confer"          WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.int520         COLUMN-LABEL "INT520"          WHEN FIRST-OF(tt-notas.nr-nota)
         tt-notas.dt-atualiza    COLUMN-LABEL "Data Atualiza"  
         WITH WIDTH 250 STREAM-IO NO-BOX DOWN FRAME f-notas.

   ASSIGN i-tot-notas = i-tot-notas + 1.
   IF tt-notas.sit-re1001 = "NÆo Atualizado" THEN 
      ASSIGN i-tot-nao-atu = i-tot-nao-atu + 1.
   IF tt-notas.sit-re1001 = "Atualizado" THEN
      ASSIGN i-tot-atu = i-tot-atu + 1.
   IF tt-notas.sit-re1001 = "" THEN
      ASSIGN i-tot-nao-integ = i-tot-nao-integ + 1.
END.

PUT SKIP(1)
    "Total de Notas....................: " i-tot-notas   SKIP
    "Notas Atualizadas no Datasul......: " i-tot-atu     SKIP
    "Notas NÆo Atualizadas no Datasul..: " i-tot-nao-atu SKIP
    "Notas NÆo Integradas com o Datasul: " i-tot-nao-integ.

{include/i-rpclo.i}

run pi-finalizar in h-acomp.

return 'OK'.

