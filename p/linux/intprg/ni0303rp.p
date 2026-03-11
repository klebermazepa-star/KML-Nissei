/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i NI0303 2.00.00.000}  /*** 010010 ***/

define temp-table tt-param
    field destino     as integer
    field arquivo     as char
    field usuario     as char format "x(12)"
    field data-exec   as date
    field hora-exec   as integer
    field uf-orig-ini as CHAR
    field uf-orig-fim as CHAR
    field uf-dest-ini as CHAR
    field uf-dest-fim as CHAR
    field tipo        as INT
    field periodo     as CHAR.

def temp-table tt-raw-digita
    field raw-digita as raw.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

def var h-acomp    as handle  no-undo.

DEF VAR de-vl-tot-item  LIKE it-doc-fisc.vl-tot-item  NO-UNDO.
DEF VAR de-vl-bicms-it  LIKE it-doc-fisc.vl-bicms-it  NO-UNDO.
DEF VAR de-vl-icms-it   LIKE it-doc-fisc.vl-icms-it   NO-UNDO.
DEF VAR de-vl-bsubs-it  LIKE it-doc-fisc.vl-bsubs-it  NO-UNDO.
DEF VAR de-vl-icmsub-it LIKE it-doc-fisc.vl-icmsub-it NO-UNDO.

DEF VAR de-total-item      LIKE it-doc-fisc.vl-tot-item   NO-UNDO.
DEF VAR de-total-bicms-it  LIKE it-doc-fisc.vl-bicms-it   NO-UNDO.
DEF VAR de-total-icms-it   LIKE it-doc-fisc.vl-icms-it    NO-UNDO.
DEF VAR de-total-bsubs-it  LIKE it-doc-fisc.vl-bsubs-it   NO-UNDO.
DEF VAR de-total-icmsub-it LIKE it-doc-fisc.vl-icmsub-it  NO-UNDO.
DEF VAR de-quantidade      AS DECIMAL FORMAT ">>>,>>9.99" NO-UNDO.

DEF VAR da-emis-ini     AS DATE FORMAT "99/99/9999"   NO-UNDO.
DEF VAR da-emis-fim     AS DATE FORMAT "99/99/9999"   NO-UNDO.
DEF VAR da-movto-ini    AS DATE FORMAT "99/99/9999"   NO-UNDO.
DEF VAR dt-ult-ent      LIKE movto-estoq.dt-trans     NO-UNDO.
DEF VAR i-cod-emit      LIKE movto-estoq.cod-emitente NO-UNDO.
DEF VAR c-nro-docto     LIKE movto-estoq.nro-docto    NO-UNDO.
DEF VAR c-serie-docto   LIKE movto-estoq.serie-docto  NO-UNDO.
DEF VAR c-natur-oper    LIKE movto-estoq.nat-operacao NO-UNDO.
DEF VAR c-uf-emit       LIKE emitente.estado          NO-UNDO.
DEF VAR de-perc-sub-tri LIKE item-uf.per-sub-tri      NO-UNDO.        
DEF VAR de-perc-red-sub LIKE item-uf.perc-red-sub     NO-UNDO.        
DEF VAR de-icm-est-subs AS DEC FORMAT ">>9.9999"      NO-UNDO.                   
DEF VAR de-val-perc-reduc-tab-pauta LIKE item-uf.val-perc-reduc-tab-pauta NO-UNDO.
DEF VAR de-preco-unit   AS DECIMAL FORMAT ">>,>>9.99999" NO-UNDO.
DEF VAR de-base-icm     AS DECIMAL FORMAT ">,>>>,>>9.99" NO-UNDO.  
DEF VAR de-valor-icm    AS DECIMAL FORMAT ">>>,>>9.99"   NO-UNDO.
DEF VAR de-base-subs    AS DECIMAL FORMAT ">,>>>,>>9.99" NO-UNDO.
DEF VAR de-vl-subs      AS DECIMAL FORMAT ">>>>,>>9.99"  NO-UNDO.  
DEF VAR de-icms-unit-ent AS DECIMAL FORMAT ">>>,>>9.99"   NO-UNDO.
DEF VAR de-icms-st-unit-ent AS DECIMAL FORMAT ">>>,>>9.99"   NO-UNDO.
DEF VAR de-icms-unit    AS DECIMAL FORMAT ">>>,>>9.99"   NO-UNDO.
DEF VAR de-icms-st-unit AS DECIMAL FORMAT ">>>,>>9.99"   NO-UNDO.
DEF VAR de-vl-unit      AS DECIMAL FORMAT ">>>,>>9.99"   NO-UNDO.
DEF VAR i-linha         AS INT NO-UNDO.
DEF VAR l-entrou        AS LOGICAL NO-UNDO.

def buffer b-estabelec for estabelec.
def buffer b-emitente  for emitente.

{include/i-rpvar.i}

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp ("Ressarcimento ICMS ST").

create tt-param.
raw-transfer raw-param to tt-param.

{include/i-rpcab.i}

find first param-global no-lock no-error.
if  avail param-global then
    assign c-empresa = param-global.grupo.

{include/i-rpout.i}

assign c-programa     = "NI0303"
       c-versao       = "2.00"
       c-revisao      = "000".
       c-sistema      = "Espec°fico".
       c-titulo-relat = "Relat¢rio de Ressarcimento ICMS ST".

view frame f-cabec.
view frame f-rodape.

ASSIGN da-emis-ini        = DATE(INT(SUBSTR(tt-param.periodo,1,2)),01,INT(SUBSTR(tt-param.periodo,3,4)))
       da-emis-fim        = da-emis-ini + 45
       da-emis-fim        = DATE(MONTH(da-emis-fim),01,YEAR(da-emis-fim)) - 1
       de-vl-tot-item     = 0
       de-vl-bicms-it     = 0
       de-vl-icms-it      = 0
       de-vl-bsubs-it     = 0
       de-vl-icmsub-it    = 0
       de-total-item      = 0
       de-total-bicms-it  = 0
       de-total-icms-it   = 0
       de-total-bsubs-it  = 0
       de-total-icmsub-it = 0
       l-entrou           = NO
       da-movto-ini       = da-emis-fim - 340
       da-movto-ini       = DATE(MONTH(da-movto-ini),01,YEAR(da-movto-ini)).

IF tt-param.tipo = 1 THEN DO:
   FOR EACH doc-fiscal WHERE 
            doc-fiscal.dt-docto >= da-emis-ini AND 
            doc-fiscal.dt-docto <= da-emis-fim NO-LOCK,
       EACH estabelec WHERE 
            estabelec.cod-estabel = doc-fiscal.cod-estabel AND
            estabelec.estado     >= tt-param.uf-orig-ini   AND
            estabelec.estado     <= tt-param.uf-orig-fim   NO-LOCK,
       EACH emitente WHERE
            emitente.cod-emitente = doc-fiscal.cod-emitente AND 
            emitente.estado      >= tt-param.uf-dest-ini    AND
            emitente.estado      <= tt-param.uf-dest-fim    NO-LOCK,
       EACH b-estabelec WHERE                              
            b-estabelec.cod-emitente = doc-fiscal.cod-emitente NO-LOCK BREAK BY doc-fiscal.cod-estabel:

       FIND FIRST nota-fiscal WHERE 
                  nota-fiscal.cod-estabel  = doc-fiscal.cod-estabel  AND
                  nota-fiscal.serie        = doc-fiscal.serie        AND
                  nota-fiscal.nr-nota-fis  = doc-fiscal.nr-doc-fis   AND 
                  nota-fiscal.cod-emitente = doc-fiscal.cod-emitente AND 
                  nota-fiscal.nat-operacao = doc-fiscal.nat-operacao NO-LOCK NO-ERROR.
       IF AVAIL nota-fiscal THEN DO:
          IF nota-fiscal.idi-sit-nf-eletro <> 3 THEN
             NEXT.
       END.

       RUN pi-acompanhar IN h-acomp (INPUT "Docto.: " + doc-fiscal.nr-doc-fis + "  Emiss∆o: " + string(doc-fiscal.dt-docto)).

       ASSIGN de-vl-tot-item  = 0
              de-vl-bicms-it  = 0
              de-vl-icms-it   = 0
              de-vl-bsubs-it  = 0
              de-vl-icmsub-it = 0.

       FOR EACH it-doc-fisc OF doc-fiscal NO-LOCK:

           FIND FIRST natur-oper WHERE
                      natur-oper.nat-operacao = it-doc-fisc.nat-operacao NO-LOCK NO-ERROR.
           IF NOT AVAIL natur-oper THEN
              NEXT.
           
           IF  natur-oper.especie-doc = "NFT" 
           AND natur-oper.tipo        = 2 
           AND natur-oper.subs-trib   = YES THEN DO:
               ASSIGN de-vl-tot-item  = de-vl-tot-item  + it-doc-fisc.vl-tot-item  
                      de-vl-bicms-it  = de-vl-bicms-it  + it-doc-fisc.vl-bicms-it  
                      de-vl-icms-it   = de-vl-icms-it   + it-doc-fisc.vl-icms-it   
                      de-vl-bsubs-it  = de-vl-bsubs-it  + it-doc-fisc.vl-bsubs-it  
                      de-vl-icmsub-it = de-vl-icmsub-it + it-doc-fisc.vl-icmsub-it. 
           END.
       END.
          
       IF de-vl-tot-item  <> 0
       OR de-vl-bicms-it  <> 0 
       OR de-vl-icms-it   <> 0
       OR de-vl-bsubs-it  <> 0
       OR de-vl-icmsub-it <> 0 THEN DO: 
          DISP doc-fiscal.cod-estabel  COLUMN-LABEL "Estab Orig" 
               estabelec.estado        COLUMN-LABEL "UF Orig"
               doc-fiscal.cod-emitente COLUMN-LABEL "Emit Dest"
               b-estabelec.cod-estabel COLUMN-LABEL "Estab Dest"
               emitente.estado         COLUMN-LABEL "UF Dest"
               doc-fiscal.dt-docto     COLUMN-LABEL "Emiss∆o"
               doc-fiscal.nr-doc-fis   COLUMN-LABEL "Docto"
               doc-fiscal.serie        COLUMN-LABEL "SÇrie"
               doc-fiscal.nat-operacao COLUMN-LABEL "Nat Oper"
               de-vl-tot-item(TOTAL)   COLUMN-LABEL "Vl Tot Item"
               de-vl-bicms-it(TOTAL)   COLUMN-LABEL "Base ICMS Item"
               de-vl-icms-it(TOTAL)    COLUMN-LABEL "Vl ICMS Item"
               de-vl-bsubs-it(TOTAL)   COLUMN-LABEL "BICMS Item Subst"
               de-vl-icmsub-it(TOTAL)  COLUMN-LABEL "Vl ICMS Subst"
               WITH STREAM-IO NO-BOX WIDTH 300 DOWN FRAME f-resumido.
          ASSIGN l-entrou = YES.
       END.

       ASSIGN de-total-item      = de-total-item      + de-vl-tot-item  
              de-total-bicms-it  = de-total-bicms-it  + de-vl-bicms-it  
              de-total-icms-it   = de-total-icms-it   + de-vl-icms-it   
              de-total-bsubs-it  = de-total-bsubs-it  + de-vl-bsubs-it  
              de-total-icmsub-it = de-total-icmsub-it + de-vl-icmsub-it. 

       IF LAST-OF(doc-fiscal.cod-estabel) AND l-entrou = YES THEN DO: 
          PUT "                                                                                           ---------------- ---------------- ---------------- ---------------- ----------------" SKIP
              SPACE(91)
              de-total-item
              SPACE(1)
              de-total-bicms-it 
              SPACE(1)
              de-total-icms-it
              SPACE(1)
              de-total-bsubs-it 
              SPACE(1)
              de-total-icmsub-it
              SKIP(1).

          ASSIGN de-total-item      = 0
                 de-total-bicms-it  = 0
                 de-total-icms-it   = 0
                 de-total-bsubs-it  = 0
                 de-total-icmsub-it = 0
                 l-entrou           = NO.
       END.
   END.
END.

IF tt-param.tipo = 2 THEN DO:
   ASSIGN i-linha = 0.
   FOR EACH it-doc-fisc WHERE 
            it-doc-fisc.dt-docto >= da-emis-ini AND 
            it-doc-fisc.dt-docto <= da-emis-fim NO-LOCK,
       EACH estabelec WHERE 
            estabelec.cod-estabel = it-doc-fisc.cod-estabel AND 
            estabelec.estado     >= tt-param.uf-orig-ini    AND
            estabelec.estado     <= tt-param.uf-orig-fim    NO-LOCK,
       EACH emitente WHERE
            emitente.cod-emitente = it-doc-fisc.cod-emitente AND
            emitente.estado      >= tt-param.uf-dest-ini     AND
            emitente.estado      <= tt-param.uf-dest-fim     NO-LOCK,
       EACH b-estabelec WHERE 
            b-estabelec.cod-emitente = it-doc-fisc.cod-emitente NO-LOCK:
 
       FIND FIRST nota-fiscal WHERE 
                  nota-fiscal.cod-estabel  = it-doc-fisc.cod-estabel  AND
                  nota-fiscal.serie        = it-doc-fisc.serie        AND
                  nota-fiscal.nr-nota-fis  = it-doc-fisc.nr-doc-fis   AND 
                  nota-fiscal.cod-emitente = it-doc-fisc.cod-emitente AND 
                  nota-fiscal.nat-operacao = it-doc-fisc.nat-operacao NO-LOCK NO-ERROR.
       IF AVAIL nota-fiscal THEN DO:
          IF nota-fiscal.idi-sit-nf-eletro <> 3 THEN
             NEXT.
       END.
       
       RUN pi-acompanhar IN h-acomp (INPUT "Docto.: " + it-doc-fisc.nr-doc-fis + "  Emiss∆o: " + string(it-doc-fisc.dt-docto ,"99/99/9999")).

       FIND FIRST natur-oper WHERE
                  natur-oper.nat-operacao = it-doc-fisc.nat-operacao NO-LOCK NO-ERROR.
       IF NOT AVAIL natur-oper THEN
          NEXT.
       
       ASSIGN dt-ult-ent    = ?
              i-cod-emit    = 0
              c-nro-docto   = ""
              c-serie-docto = ""
              c-natur-oper  = "".

       FOR EACH movto-estoq USE-INDEX item-data WHERE 
                movto-estoq.it-codigo     = it-doc-fisc.it-codigo AND
                movto-estoq.cod-estabel   = "973" AND 
                movto-estoq.dt-trans     >= da-movto-ini AND 
                movto-estoq.dt-trans     <= da-emis-fim  AND 
                movto-estoq.dt-trans      < it-doc-fisc.dt-docto AND
                movto-estoq.tipo-trans    = 1 AND 
                movto-estoq.esp-docto     = 21 AND 
                movto-estoq.nat-operacao <> "" AND
                movto-estoq.cod-emitente <> 9356 NO-LOCK
           BY movto-estoq.dt-trans:
           ASSIGN dt-ult-ent    = movto-estoq.dt-trans
                  i-cod-emit    = movto-estoq.cod-emitente
                  c-nro-docto   = movto-estoq.nro-docto
                  c-serie-docto = movto-estoq.serie-docto
                  c-natur-oper  = movto-estoq.nat-operacao.
       END.

       ASSIGN c-uf-emit                   = ""
              de-perc-sub-tri             = 0
              de-perc-red-sub             = 0
              de-icm-est-subs             = 0
              de-val-perc-reduc-tab-pauta = 0.

       IF i-cod-emit <> 0 THEN DO:
          FIND FIRST b-emitente WHERE
                     b-emitente.cod-emitente = i-cod-emit NO-LOCK NO-ERROR.
          IF AVAIL b-emitente THEN DO:
             ASSIGN c-uf-emit = b-emitente.estado.
             FIND FIRST item-uf WHERE
                        item-uf.it-codigo       = it-doc-fisc.it-codigo AND
                        item-uf.cod-estado-orig = b-emitente.estado     AND
                        item-uf.estado          = "PR" NO-LOCK NO-ERROR.
             IF AVAIL item-uf THEN DO:
                ASSIGN de-perc-sub-tri             = item-uf.per-sub-tri             
                       de-perc-red-sub             = item-uf.perc-red-sub            
                       de-icm-est-subs             = item-uf.dec-1                   
                       de-val-perc-reduc-tab-pauta = item-uf.val-perc-reduc-tab-pauta.
             END.
          END.
       END.

       ASSIGN de-preco-unit = 0
              de-base-icm   = 0
              de-valor-icm  = 0
              de-base-subs  = 0
              de-vl-subs    = 0
              de-quantidade = 0.

       FOR FIRST item-doc-est WHERE
                 item-doc-est.serie-docto  = c-serie-docto AND
                 item-doc-est.nro-docto    = c-nro-docto   AND
                 item-doc-est.cod-emitente = i-cod-emit    AND    
                 item-doc-est.nat-operacao = c-natur-oper  AND
                 item-doc-est.it-codigo    = it-doc-fisc.it-codigo NO-LOCK:
       END.
       IF AVAIL item-doc-est THEN DO:
          ASSIGN de-preco-unit = item-doc-est.preco-unit[1]
                 de-base-icm   = item-doc-est.base-icm[1]  
                 de-valor-icm  = item-doc-est.valor-icm[1] 
                 de-base-subs  = item-doc-est.base-subs[1] 
                 de-vl-subs    = item-doc-est.vl-subs[1]
                 de-quantidade = item-doc-est.quantidade.
       END.

       FOR FIRST int_ds_it_docto_xml WHERE
                 int_ds_it_docto_xml.cod_emitente   = i-cod-emit         AND
                 int(int_ds_it_docto_xml.serie)     = int(c-serie-docto) AND 
                 int(int_ds_it_docto_xml.nnf)       = INT(c-nro-docto)   AND
                 int(int_ds_it_docto_xml.it_codigo) = int(it-doc-fisc.it-codigo) NO-LOCK:
       END.
       IF AVAIL int_ds_it_docto_xml THEN DO:
          ASSIGN de-valor-icm  = int_ds_it_docto_xml.vicms
                 de-base-icm   = int_ds_it_docto_xml.vbc_icms
                 de-base-subs  = int_ds_it_docto_xml.vbcst
                 de-vl-subs    = int_ds_it_docto_xml.vicmsst.
       END.

       IF  natur-oper.especie-doc = "NFT" 
       AND natur-oper.tipo        = 2 
       AND natur-oper.subs-trib   = YES THEN DO:
           IF it-doc-fisc.vl-tot-item  <> 0
           OR it-doc-fisc.vl-bicms-it  <> 0
           OR it-doc-fisc.vl-icms-it   <> 0
           OR it-doc-fisc.vl-bsubs-it  <> 0
           OR it-doc-fisc.vl-icmsub-it <> 0 THEN DO:
              IF i-linha = 0 
              OR i-linha = 56 THEN DO:
                 PUT "                                                                                                                                                                                                                                                 *------------------------------------------------------------------------------------- ÈLTIMA ENTRADA ------------------------------------------------------------------------------------*" SKIP                                                                          
                     "Estab Orig UF Orig Emit Dest Estab Dest UF Dest Emiss∆o    Docto            SÇrie Nat Oper Item             Quantidade Vl Unit†rio      Vl Tot Item   Base ICMS Item     Vl ICMS Item BICMS Item Subst    Vl ICMS Subst ICMS Unit. ICMS ST Unit. Dt Ult Ent UF Forn Fornecedor Doc Ult Ent        Pr Ult Ent Quantidade    Base ICMS   Vlr ICMS Base ICMS ST Vlr ICMS ST ICMS Unit. ICMS ST Unit. % Sub Tri % Red ST  ICMS ST % Red ST Pauta" SKIP
                     "---------- ------- --------- ---------- ------- ---------- ---------------- ----- -------- ---------------- ---------- ----------- ---------------- ---------------- ---------------- ---------------- ---------------- ---------- ------------- ---------- ------- ---------- ---------------- ------------ ---------- ------------ ---------- ------------ ----------- ---------- ------------- --------- -------- -------- --------------" SKIP.
                 ASSIGN i-linha = 0.
              END.

              ASSIGN de-icms-unit        = 0
                     de-icms-st-unit     = 0
                     de-icms-unit-ent    = 0
                     de-icms-st-unit-ent = 0.

              IF it-doc-fisc.quantidade <> 0 THEN DO:
                 ASSIGN de-icms-unit    = it-doc-fisc.vl-icms-it   / it-doc-fisc.quantidade
                        de-icms-st-unit = it-doc-fisc.vl-icmsub-it / it-doc-fisc.quantidade.
              END.
              IF de-icms-unit = ? THEN
                 ASSIGN de-icms-unit = 0.
              IF de-icms-st-unit = ? THEN
                 ASSIGN de-icms-st-unit = 0.

              ASSIGN de-vl-unit = it-doc-fisc.vl-tot-item / it-doc-fisc.quantidade.
              IF de-vl-unit = ? THEN
                 ASSIGN de-vl-unit = 0.

              IF de-quantidade <> 0 THEN DO:
                 ASSIGN de-icms-unit-ent    = de-valor-icm / de-quantidade
                        de-icms-st-unit-ent = de-vl-subs   / de-quantidade.
              END.
              IF de-icms-unit-ent = ? THEN
                 ASSIGN de-icms-unit-ent = 0.
              IF de-icms-st-unit-ent = ? THEN
                 ASSIGN de-icms-st-unit-ent = 0.

              PUT it-doc-fisc.cod-estabel   
                  SPACE(6)
                  estabelec.estado
                  SPACE(4)
                  it-doc-fisc.cod-emitente
                  SPACE(1)
                  b-estabelec.cod-estabel
                  SPACE(6)
                  emitente.estado     
                  SPACE(4)
                  it-doc-fisc.dt-docto 
                  SPACE(1)
                  it-doc-fisc.nr-doc-fis
                  SPACE(1)
                  it-doc-fisc.serie
                  SPACE(1)
                  it-doc-fisc.nat-operacao
                  SPACE(3)
                  it-doc-fisc.it-codigo   
                  SPACE(1)
                  it-doc-fisc.quantidade FORMAT ">>>,>>9.99"
                  SPACE(2)
                  de-vl-unit
                  SPACE(1)
                  it-doc-fisc.vl-tot-item 
                  SPACE(1)
                  it-doc-fisc.vl-bicms-it 
                  SPACE(1)
                  it-doc-fisc.vl-icms-it 
                  SPACE(1)
                  it-doc-fisc.vl-bsubs-it 
                  SPACE(1)
                  it-doc-fisc.vl-icmsub-it
                  SPACE(1)
                  de-icms-unit
                  SPACE(4)
                  de-icms-st-unit
                  SPACE(1)
                  dt-ult-ent 
                  SPACE(1)
                  c-uf-emit
                  SPACE(5)
                  i-cod-emit
                  SPACE(1)
                  c-nro-docto
                  SPACE(1)
                  de-preco-unit
                  SPACE(1)
                  de-quantidade
                  SPACE(1)
                  de-base-icm
                  SPACE(1)
                  de-valor-icm
                  SPACE(1)
                  de-base-subs 
                  SPACE(1)
                  de-vl-subs
                  SPACE(1)
                  de-icms-unit-ent
                  SPACE(4)
                  de-icms-st-unit-ent
                  SPACE(1)
                  de-perc-sub-tri
                  SPACE(1)
                  de-perc-red-sub
                  SPACE(1)
                  de-icm-est-subs      
                  SPACE(7)
                  de-val-perc-reduc-tab-pauta SKIP.
              ASSIGN i-linha = i-linha + 1.
           END.
       END.
   END.
END.

run pi-finalizar in h-acomp.

{include/i-rpclo.i}
