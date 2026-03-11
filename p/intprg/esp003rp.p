/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i esp003RP 2.06.00.000}  /*** 010000 ***/



&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i esp003rp cdp }
&ENDIF

{cdp/cdcfgdis.i}
  
define temp-table TT-PARAM NO-UNDO
       FIELD DESTINO            AS INTEGER 
       FIELD ARQUIVO            AS CHAR FORMAT "x(35)"
       FIELD USUARIO            AS CHAR FORMAT "x(12)"
       FIELD DATA-EXEC          AS DATE 
       FIELD HORA-EXEC          AS INTEGER 
       FIELD L-IMP-PARAM        AS LOG 
       FIELD L-EXCEL            AS LOG 
       FIELD it-codigo-ini      as character FORMAT "x(16)"
       FIELD it-codigo-fim      as character FORMAT "x(16)"
       FIELD estado-origem-ini  as character FORMAT "x(4)"
       FIELD estado-origem-fim  as character FORMAT "x(4)"
       FIELD estado-destino-ini as character FORMAT "x(04)"
       FIELD estado-destino-fim as character FORMAT "x(04)"
       FIELD planilha           AS CHAR.

define temp-table tt-msg
    FIELD tipo              AS CHAR FORMAT "x(1)"
    FIELD cd-trib-icm       LIKE ITEM.cd-trib-icm       
    field it-codigo         like item-uf.it-codigo
    field cod-estado-orig   like item-uf.cod-estado-orig
    field estado            like item-uf.estado
    field descricao         as char format "x(100)" .

DEFINE TEMP-TABLE tt-imp
    FIELD col-a       AS CHAR    /* item */
    field col-b       as CHAR    /* descricao item */
/*  field col-c       as INT  */ /* grupo estoque */
/*  field col-d       as CHAR */ /* ean */
    field col-e       as CHAR    /* uf.origem */
    field col-f       as CHAR    /* uf.destino */
    field col-g       as INT     /* TR */
/*  field col-h       as dec */  /* ALIQ */
/*  field col-i       as dec */  /* RED */
/*  field col-j       as dec */  /* TR.E */
    field col-k       as dec     /* AL.E */
/*  field col-l       as dec */  /* RED.E */
/*  field col-m       as dec */  /* TR.I */
/*  field col-n       as dec */  /* AL.I */
/*  field col-o       as dec */  /* RED.I */
    field col-p       as dec     /* ST.E */
    field col-q       as dec     /* ST.I */
    field col-r       as dec     /* ICMS */
    field col-s       as dec     /* RBST */
/*  field col-t       as dec */  /* RAST */
/*  field col-u       as dec */  /* RBEST */
    field col-v       as DEC    /* IPI */
    field col-w       as CHAR    /* LISTA */
    field col-x       as CHAR    /* NCM */
    field col-y       as INT     /* CSTA */
/*  field COL-Z       AS DEC */  /* IES */
    FIELD col-aa      AS CHAR    /* codigo familia */
/*  FIELD col-ab      AS CHAR */ /* descricao familia **********************nao importa*****************************************/
    FIELD col-ac      AS CHAR    /* tributa pis */
    FIELD col-ad      AS DEC     /* aliquota pis */ 
    FIELD col-ae      AS CHAR    /* tributa cofins */ 
    FIELD COL-af      AS DEC     /* aliquota cofins */
    FIELD col-ai      AS DEC     /* valor pauta */
    FIELD COL-aj      AS DEC     /* Cest ENT */
    FIELD COL-ak      AS DEC     /* Cest SAI */
    FIELD col-al      AS CHAR    /* Regime especial */
    FIELD col-am      AS CHAR    /* Regime especial */
    FIELD col-an      AS CHAR    /* Cesta Basica */ 
    FIELD col-ao     AS CHAR    /* status            **********************nao importa*****************************************/ 
    FIELD DESCricao   AS CHAR    FORMAT "x(100)"
    INDEX id col-a col-e col-f.

def temp-table tt-raw-digita
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

DEF VAR h-excel       AS HANDLE      NO-UNDO.
DEF VAR chExcel       AS office.iface.excel.ExcelWrapper NO-UNDO.
DEF VAR c-arq-csv     AS CHAR        NO-UNDO.
DEF VAR i-atualizados AS INT         NO-UNDO.     

DEFINE STREAM s-import.

def var h-acomp         as handle       no-undo.
def var c-selecao       as char no-undo format "x(20)" init "SELE€ÇO".
def var c-impressao     as char no-undo format "x(20)" init "IMPRESSÇO". 
def var c-msg           as char no-undo format "X(10)".
def var l-atualizou     as logical INIT NO no-undo.
DEF VAR l-alterou       AS LOGICAL NO-UNDO.
DEF VAR i-seq-int_ds_item AS INT NO-UNDO.
DEF VAR i-zeros         AS INT NO-UNDO.
DEF VAR c-class         AS CHAR FORMAT "X(8)" NO-UNDO.
DEF VAR c-zeros         AS CHAR FORMAT "X(8)" NO-UNDO.
DEF VAR i-cont          AS INT NO-UNDO.
def var h-cdapi995      as handle no-undo.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Aguarde !").

{include/i-rpvar.i}

{utp/ut-liter.i SELE€ÇO *}
assign c-selecao = return-value.

{utp/ut-liter.i IMPRESSÇO *}
assign c-impressao = return-value.

create tt-param.
raw-transfer raw-param to tt-param.                    
find first param-global no-lock no-error.

form
    c-impressao                colon 10 no-label skip(1)
    destino                    colon 10 LABEL "Destino"
    tt-param.arquivo           colon 10 label "Arquivo" format "x(40)" skip
    tt-param.usuario           colon 10 LABEL "Usu rio"
    with stream-io side-labels width 132 frame f-impressao.

/*              "Tipo Codigo Item             Uf.Orig Uf.Dest Descricao " SKIP                                                                                            */
/*              "---- ------ ---------------- ------- ------- ----------------------------------------------------------------------------------------------------" SKIP. */


form
    tt-msg.tipo             COLUMN-LABEL "Tipo"       AT 2
    tt-msg.cd-trib-icm      COLUMN-LABEL "Codigo"     AT 8
    tt-msg.it-codigo        column-label "Item"       at 13 
    tt-msg.cod-estado-orig  column-label "UF Origem"  at 32 
    tt-msg.estado           column-label "UF Destino" at 41 
    tt-msg.descricao        column-label "Descricao"  AT 46  
    WITH STREAM-IO  WIDTH 200 NO-LABELS NO-BOX FRAME f-nok.
    

assign c-empresa  = param-global.grupo
       c-programa = "ESP003"
       c-versao   = "2.06"
       c-revisao  = "000".

assign c-titulo-relat = "IMPORTACAO EXCEL".
assign c-sistema      = "CADASTROS".

{utp/ut-glob.i}

RUN pi-importa-excel.

{include/i-rpcab.i}
{include/i-rpout.i}

IF NOT VALID-HANDLE (h-cdapi995)  THEN
   RUN cdp/cdapi995.p PERSISTENT SET h-cdapi995.

RUN pi-atualiza.
RUN closeExcel.

IF VALID-HANDLE(h-cdapi995) THEN DO:
   RUN pi-finalizar in h-cdapi995.
   ASSIGN h-cdapi995 = ?.
END.

{include/i-rpclo.i}

return "OK":U.

/*******************************************************************************************************************************************************************************************/

PROCEDURE pi-importa-excel:



    DEFINE VARIABLE i-linha AS INTEGER    NO-UNDO.

    DEFINE VARIABLE l-erro-linha AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE l-erro       AS LOGICAL    NO-UNDO.

    DEFINE VARIABLE ch-arquivo        AS office.iface.excel.Workbook NO-UNDO. 
    DEFINE VARIABLE ch-planilha       AS office.iface.excel.WorkSheet NO-UNDO. 
    DEFINE VARIABLE c-arquivo         AS CHARACTER   NO-UNDO.

    IF VALID-HANDLE(h-acomp) THEN DO:
        {utp/ut-liter.i Importando * l}
        RUN pi-acompanhar IN h-acomp (INPUT TRIM(RETURN-VALUE) + "...":U).
    END.

    EMPTY TEMP-TABLE tt-imp.

    ASSIGN i-linha = 1
           l-erro  = NO.

    //CREATE 'excel.application' chExcel NO-ERROR.
    ASSIGN chExcel     = NEW office.libre.excel.ExcelWrapper().
    ASSIGN //chExcel     =  chExcel:APPLICATION 
           ch-arquivo  =  chExcel:workBooks:open(tt-param.planilha)
           ch-planilha =  ch-arquivo:Sheets(1).

     REPEAT ON ENDKEY UNDO, LEAVE:

        ASSIGN i-linha      = i-linha + 1
               l-erro-linha = NO.

        IF i-linha <= 1 THEN NEXT.

        IF chExcel:Range("A"  + STRING(i-linha)):TEXT = "" THEN LEAVE. /* item branco nao importa */

        RUN pi-acompanhar IN h-acomp (INPUT "Registros Lidos : " + STRING(i-linha) ).

        ASSIGN i-atualizados = 0.

        IF chExcel:Range("A"  + STRING(i-linha)):TEXT  >= tt-param.it-codigo-ini      AND  /* item */
           chExcel:Range("A"  + STRING(i-linha)):TEXT  <= tt-param.it-codigo-fim      AND 
           chExcel:Range("E"  + STRING(i-linha)):TEXT  >= tt-param.estado-origem-ini  AND  /* uf origem */
           chExcel:Range("E"  + STRING(i-linha)):TEXT  <= tt-param.estado-origem-fim  and
           chExcel:Range("F"  + STRING(i-linha)):TEXT  >= tt-param.estado-destino-ini and  /* uf destino */
           chExcel:Range("F"  + STRING(i-linha)):TEXT  <= tt-param.estado-destino-fim AND  /* a-alteracao, e-exclusao, i-inclusao */
           chExcel:Range("AL" + STRING(i-linha)):TEXT  <> ""                          THEN DO:   

           
           
            CREATE tt-imp.
            ASSIGN tt-imp.col-a                       = chExcel        :Range("A"  + STRING(i-linha)):TEXT.   /* 1 - coluna a - Codigo item - chave */   
                   tt-imp.col-b                       = chExcel        :Range("B"  + STRING(i-linha)):TEXT.   /* 2 - coluna b - Descricao item - nao sera importado */    
               /*  tt-imp.col-c                       = INT    (chExcel:range("C"  + STRING(i-linha)):TEXT)  /* 3 - coluna c - grupo de estoque do item - nao sera importado */    */
               /*  tt-imp.col-d                       = chExcel        :Range("D"  + STRING(i-linha)):TEXT   /* 4 - coluna d - ean-item.codigo-ean      - nao sera importado */    */
                   tt-imp.col-e                       = chExcel        :Range("E"  + STRING(i-linha)):TEXT.   /* 5 - coluna e - uf estado origem         - chave */                    
                   tt-imp.col-f                       = chExcel        :Range("F"  + STRING(i-linha)):TEXT.   /* 6 - coluna f - uf estado destino        - chave */
                   tt-imp.col-g                       = INT(chExcel    :Range("G"  + STRING(i-linha)):TEXT).  /* 7 - coluna g - TR */ 
               /*  tt-imp.col-h                       = decimal(chExcel:Range("H"  + STRING(i-linha)):TEXT)  /* 8 - coluna H - ALIQ */   */                                                                                            
               /*  tt-imp.col-i                       = decimal(chExcel:Range("I"  + STRING(i-linha)):TEXT)  /* 9 - coluna I - RED */    */
               /*  tt-imp.col-j                       = decimal(chExcel:Range("J"  + STRING(i-linha)):TEXT)  /* 10- coluna J - TR.E  */  */                           
                   tt-imp.col-k                       = decimal(chExcel:Range("K"  + STRING(i-linha)):TEXT).  /* 11- coluna K - AL.E  */                              
               /*  tt-imp.col-l                       = decimal(chExcel:Range("L"  + STRING(i-linha)):TEXT)  /* 12- coluna L - RED.E */  */                           
               /*  tt-imp.col-m                       = decimal(chExcel:Range("M"  + STRING(i-linha)):TEXT)  /* 13- coluna M - TR.I */   */                           
               /*  tt-imp.col-n                       = decimal(chExcel:Range("N"  + STRING(i-linha)):TEXT)  /* 14- coluna N - AL.I */   */                         
               /*  tt-imp.col-o                       = decimal(chExcel:Range("O"  + STRING(i-linha)):TEXT)  /* 15- coluna O - RED.I */  */                           
                   tt-imp.col-p                       = decimal(chExcel:Range("P"  + STRING(i-linha)):TEXT).  /* 16- coluna P - ST.E */                              
                   tt-imp.col-q                       = decimal(chExcel:Range("Q"  + STRING(i-linha)):TEXT).  /* 17- coluna Q - ST.I */                              
                   tt-imp.col-r                       = decimal(chExcel:Range("R"  + STRING(i-linha)):TEXT).  /* 18- coluna R - ICMS */                             
                   tt-imp.col-s                       = decimal(chExcel:Range("S"  + STRING(i-linha)):TEXT).  /* 19- coluna S - RBST */                              
               /*  tt-imp.col-t                       = decimal(chExcel:Range("T"  + STRING(i-linha)):TEXT)  /* 20- coluna T - RAST */   */                          
               /*  tt-imp.col-u                       = decimal(chExcel:Range("U"  + STRING(i-linha)):TEXT)  /* 21- coluna U - RBEST */  */                          
                   tt-imp.col-v                       = DECIMAL(chExcel:Range("V"  + STRING(i-linha)):TEXT).  /* 22- coluna V - IPI */                               
                   tt-imp.col-w                       =         chExcel:Range("W"  + STRING(i-linha)):TEXT.   /* 23- coluna W - lista */                           
                   tt-imp.col-x                       =         chExcel:Range("X"  + STRING(i-linha)):TEXT.   /* 24- coluna X - NCM */                               
                   tt-imp.col-y                       =     INT(chExcel:Range("Y"  + STRING(i-linha)):TEXT).  /* 25- coluna Y - CSTA */                              
               /*  tt-imp.col-z                       = decimal(chExcel:Range("Z"  + STRING(i-linha)):TEXT)  /* 26- coluna Z - IES */    */
                   tt-imp.col-AA                      =         chExcel:Range("AA" + STRING(i-linha)):TEXT.   /* 27- coluna AA- Familia */                           
               /*  tt-imp.col-AB                      =         chExcel:Range("AB" + STRING(i-linha)):TEXT   /* 28- coluna AB- Descricao */  */
                   tt-imp.col-AC                      =         chExcel:Range("AC" + STRING(i-linha)):TEXT.   /* 29- coluna AC- Tributa PIS */                                                                                                                                  
                   tt-imp.col-AD                      = decimal(chExcel:Range("AD" + STRING(i-linha)):TEXT).  /* 30- coluna AD- Aliquota Pis */                                                                                                                               
                   tt-imp.col-AE                      =         chExcel:Range("AE" + STRING(i-linha)):TEXT.   /* 31- coluna AE- Tributa Cofins */                                                                                                                               
                   tt-imp.col-AF                      = decimal(chExcel:Range("AF" + STRING(i-linha)):TEXT).  /* 32- coluna AF- Aliquota Cofins */                                                                                                                            
                   tt-imp.col-AI                      =     INT(chExcel:Range("AI" + STRING(i-linha)):TEXT).   /* 35- coluna AI- Valor Pauta */                                                                                                                               
                   tt-imp.col-AJ                      =     INT(chExcel:Range("AJ" + STRING(i-linha)):TEXT).   /* 36- coluna AJ- Cest ENT */                                                                                                                            
                   tt-imp.col-AK                      =     int(chExcel:Range("AK" + STRING(i-linha)):TEXT).   /* 37- coluna AK- Cest SAI */                                                                                                                            
                   tt-imp.col-AL                      =         chExcel:Range("AL" + STRING(i-linha)):TEXT.   /* 38- coluna AL- Regime Especial */ 
                   tt-imp.col-AM                      =         chExcel:Range("AM" + STRING(i-linha)):TEXT.   /* 38- coluna AL- Regime Especial */
                   tt-imp.col-AN                      =         chExcel:Range("AN" + STRING(i-linha)):TEXT. /* 39-Coluna AM -Cesta Basica*/
                   tt-imp.col-AO                      =         chExcel:Range("AO" + STRING(i-linha)):TEXT. /* 40- coluna AN- STATUS a-alteracao, e-exclusao, i-inclusao */

                                                                                                                                                                                                                                           
            ASSIGN i-atualizados = i-atualizados + 1.  

        END.                                                                                                                                                                                                                                                                                              
    END.   

 END PROCEDURE.                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
/**************************************************************************************************************************************                                                                                                                                                                   *****************************************************/

 PROCEDURE pi-atualiza :

     view frame f-rodape.
     view frame f-cabec.

     for each tt-imp:

     
         run pi-acompanhar in h-acomp (input tt-imp.col-a).

         ASSIGN tt-imp.COL-x =  STRING(int(tt-imp.COL-x), "99999999").

         FOR FIRST classif-fisc WHERE
                   classif-fisc.class-fiscal = tt-imp.COL-x NO-LOCK:
         END.
         IF NOT AVAIL classif-fisc THEN DO:
            RUN pi-cria-msg(INPUT "Classificacao Fiscal nao cadastrada: " + STRING(tt-imp.COL-x) + ". Registro nao atualizado.").
            DELETE tt-imp.
            NEXT.
         END.


         
         /************************************************************************************************************************************************/
         IF tt-imp.col-ao = "A" THEN DO: /* Alteracao */

            
            FIND FIRST ITEM WHERE
                       ITEM.it-codigo = tt-imp.col-a EXCLUSIVE-LOCK NO-ERROR. 
            IF AVAIL   ITEM THEN DO:      

               ASSIGN ITEM.aliquota-ipi           = tt-imp.col-v                    /* aliquota ipi */
                      item.cd-trib-ipi            = 3                               /* outros */
                      ITEM.class-fiscal           = tt-imp.COL-x
                      item.codigo-orig            = tt-imp.col-y                    /* csta */
                      OVERLAY(ITEM.char-2,31,5)   = string(tt-imp.col-ad,"99.99")   /* coluna AD -Aliquota Pis     */
                      OVERLAY(ITEM.char-2,36,5)   = string(tt-imp.col-af,"99.99")   /* Coluna AF -Aliquota Cofins  */
                      //OVERLAY(ITEM.char-2,60,1)   = tt-imp.col-al
                      .
               //kml
               
.
               
               IF tt-imp.col-f = "PR" THEN
               DO:
                    FOR EACH item-uni-estab 
                        WHERE  item-uni-estab.cod-estabel = "973"
                          AND item-uni-estab.it-codigo   = tt-imp.col-a:
                          

                        ASSIGN SUBSTRING(item-uni-estab.char-2, 60, 1) = tt-imp.col-AL.
           
                   END. 
 
               END.
               
               IF tt-imp.col-f = "SP" THEN
               DO:
                    FOR EACH item-uni-estab 
                        WHERE  item-uni-estab.cod-estabel = "977"
                          AND item-uni-estab.it-codigo   = tt-imp.col-a:
                          

                        ASSIGN SUBSTRING(item-uni-estab.char-2, 60, 1) = tt-imp.col-AM.

                   END. 
 
               END.
                
               /* KML - Altera‡Æo para importar o CEST dos Itens */

                FOR EACH sit-tribut-relacto EXCLUSIVE-LOCK
                    WHERE sit-tribut-relacto.cod-item = ITEM.it-codigo
                      AND sit-tribut.cdn-tribut = 11:

                    IF int(tt-imp.col-aj) <> 0 THEN DO:
                
                       IF idi-tip-docto = 1 THEN DO:
                            ASSIGN sit-tribut-relacto.cdn-sit-tribut = int(tt-imp.col-aj). /* CEST Entrada */
                       END.
                       ELSE DO:
                            ASSIGN sit-tribut-relacto.cdn-sit-tribut = int(tt-imp.col-ak). /* CEST Saida */
                       END.

                        FIND FIRST sit-tribut
                            WHERE sit-tribut.cdn-sit-tribut  = sit-tribut-relacto.cdn-sit-tribut 
                              AND sit-tribut.cdn-tribut      = sit-tribut-relacto.cdn-tribut 
                            NO-ERROR.
                        
                        IF NOT AVAIL sit-tribut THEN DO:
                        
                            CREATE sit-tribut.
                            assign sit-tribut.cdn-sit-tribut   = sit-tribut-relacto.cdn-sit-tribut   
                                   sit-tribut.cdn-tribut       = sit-tribut-relacto.cdn-tribut       
                                   sit-tribut.dsl-sit-tribut   = string(sit-tribut-relacto.cdn-sit-tribut) 
                                   sit-tribut.dat-valid-inic   = 01/01/2018.
                        END.
                    END.
               END.

            /*    FOR FIRST unid-feder no-lock 
                    WHERE unid-feder.pais   = "Brasil" 
                      AND unid-feder.estado = tt-imp.col-e: END.

                IF AVAIL unid-feder THEN DO:

                    FIND FIRST preco-item 
                        WHERE preco-item.nr-tabpre  = unid-feder.nr-tb-pauta 
                          AND preco-item.dt-inival <= today 
                          AND preco-item.it-codigo  = ITEM.it-codigo 
                          AND preco-item.situacao   = 1 NO-ERROR.

                     IF AVAIL preco-item THEN DO:

                         ASSIGN preco-item.preco-venda = tt-imp.col-AI
                                preco-item.preco-fob   = tt-imp.col-AI.

                     END.
                     ELSE DO:

                        CREATE preco-item.
                        ASSIGN preco-item.nr-tabpre             = unid-feder.nr-tb-pauta 
                               preco-item.it-codigo             = ITEM.it-codigo
                               preco-item.preco-venda           = dec(tt-imp.col-AI)
                               preco-item.user-alter            = "RPW"
                               preco-item.dt-useralt            = TODAY
                               preco-item.situacao              = 1
                               preco-item.cod-refer             = ""
                               preco-item.dt-inival             = TODAY
                               preco-item.cod-unid-med          = ITEM.un
                               preco-item.preco-fob             = dec(tt-imp.col-AI)
                               preco-item.preco-min-cif         = 0
                               preco-item.preco-min-fob         = 0.

                     END.
                                        
    
                END.*/
               /* KML - Fim da altera‡Æo */

               RUN grava-aliquotas IN h-cdapi995 (INPUT "item",
                                                  INPUT ITEM.it-codigo,
                                                  INPUT DEC(tt-imp.col-ad),
                                                  INPUT DEC(tt-imp.col-af)).

               /*verificar caracteristicas tecnicas 90 - coluna 23 - W*/
               ASSIGN l-alterou = NO.
               FIND FIRST it-carac-tec
                    WHERE it-carac-tec.it-codigo = tt-imp.col-a  and
                          it-carac-tec.cd-folha  = "CADITEM"     AND
                          it-carac-tec.cd-comp   = "90"          EXCLUSIVE-LOCK NO-ERROR.
               IF NOT AVAIL it-carac-tec THEN DO:
                  RUN pi-cria-msg( INPUT "Caracteristica Tecnica do item " + tt-imp.col-a + " - Folha: CADITEM - Comp. 90 nao cadastrado." ).
               END.
               ELSE DO:
                  FIND FIRST c-tab-res WHERE
                             c-tab-res.nr-tabela = 90 AND
                             c-tab-res.descricao BEGINS SUBSTR(STRING(tt-imp.col-w),1,1) NO-LOCK NO-ERROR.
                  IF AVAIL c-tab-res THEN DO:
                     FIND FIRST it-res-carac WHERE
                                it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                                it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                                it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                                it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
                     IF NOT AVAIL it-res-carac THEN DO:
                        create it-res-carac.
                        assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                               it-res-carac.cd-folha   = it-carac-tec.cd-folh
                               it-res-carac.it-codigo  = it-carac-tec.it-codigo
                               it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                               it-res-carac.sequencia  = c-tab-res.sequencia.
                     END.
                     ELSE
                        ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

                     IF it-carac-tec.observacao <> c-tab-res.descricao THEN
                        ASSIGN l-alterou = YES.

                     ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).
                     RELEASE it-carac-tec.

                  END.
               END.

               /* verificar caracteristicas tecnicas 290 - coluna 23 - ac - tributa pis */
               FIND FIRST it-carac-tec
                    WHERE it-carac-tec.it-codigo = tt-imp.col-a AND
                          it-carac-tec.cd-folha  = "CADITEM"    AND
                          it-carac-tec.cd-comp   = "290"        EXCLUSIVE-LOCK NO-ERROR.
               IF NOT AVAIL it-carac-tec THEN DO:
                  RUN pi-cria-msg( INPUT "Caracteristica Tecnica do item " + tt-imp.col-a + " - Folha: CADITEM - Comp. 290 nao cadastrado." ).
               END.
               ELSE DO:
                  FIND FIRST c-tab-res WHERE
                             c-tab-res.nr-tabela = 290 AND
                             c-tab-res.descricao BEGINS SUBSTR(STRING(tt-imp.col-ac),1,1) NO-LOCK NO-ERROR.
                  IF AVAIL c-tab-res THEN DO:
                     FIND FIRST it-res-carac WHERE
                                it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                                it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                                it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                                it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
                     IF NOT AVAIL it-res-carac THEN DO:
                        create it-res-carac.
                        assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                               it-res-carac.cd-folha   = it-carac-tec.cd-folh
                               it-res-carac.it-codigo  = it-carac-tec.it-codigo
                               it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                               it-res-carac.sequencia  = c-tab-res.sequencia.
                     END.
                     ELSE
                        ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

                     IF it-carac-tec.observacao <> c-tab-res.descricao THEN
                        ASSIGN l-alterou = YES.

                     ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).
                     RELEASE it-carac-tec.
                       
                  END.                                                                                         
               END.

               /* verificar caracteristicas tecnicas 300 - coluna 31 - ae - tributa cofins*/
               FIND FIRST it-carac-tec
                    WHERE it-carac-tec.it-codigo = tt-imp.col-a AND
                          it-carac-tec.cd-folha  = "CADITEM"    AND
                          it-carac-tec.cd-comp   = "300"        EXCLUSIVE-LOCK NO-ERROR.
               IF NOT AVAIL it-carac-tec THEN DO:
                  RUN pi-cria-msg( INPUT "Caracteristica Tecnica do item " + tt-imp.col-a + " - Folha: CADITEM - Comp. 300 nao cadastrado." ).
               END.
               ELSE DO:
                  FIND FIRST c-tab-res WHERE
                             c-tab-res.nr-tabela = 300 AND
                             c-tab-res.descricao BEGINS SUBSTR(STRING(tt-imp.col-ae),1,1) NO-LOCK NO-ERROR.
                  IF AVAIL c-tab-res THEN DO:
                     FIND FIRST it-res-carac WHERE
                                it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                                it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                                it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                                it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
                     IF NOT AVAIL it-res-carac THEN DO:
                        create it-res-carac.
                        assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                               it-res-carac.cd-folha   = it-carac-tec.cd-folh
                               it-res-carac.it-codigo  = it-carac-tec.it-codigo
                               it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                               it-res-carac.sequencia  = c-tab-res.sequencia.
                     END.
                     ELSE
                        ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

                     IF it-carac-tec.observacao <> c-tab-res.descricao THEN
                        ASSIGN l-alterou = YES.

                     ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).
                     RELEASE it-carac-tec.

                  END.
               END.
                            
               IF l-alterou = YES THEN DO:
                  IF AVAIL ITEM THEN DO:
                     RUN pi-integracao /*(INPUT ITEM.it-codigo)*/. /* Integra a it-carac-tec alterada com o Sysfarma */
                  END.
               END.

               IF ITEM.cd-trib-icm <> tt-imp.col-g THEN DO: /* se houve alteracao do codigo de tributacao, 1,2,3,4 ou 5 */

                  IF tt-imp.col-g = 5 THEN DO:

                     FIND FIRST item-uf WHERE
                                item-uf.cod-estab           = ""            AND                      /* cfe informado item-uf.cod-estab sempre branco */    
                                item-uf.it-codigo           = tt-imp.col-a  AND                      /* item */                                             
                                item-uf.cod-estado-orig     = tt-imp.col-e  AND                      /* estado origem  */                                   
                                item-uf.estado              = tt-imp.col-f  EXCLUSIVE-LOCK NO-ERROR. /* estado destino */                                   
                     IF NOT AVAIL item-uf THEN do:
                     
                        CREATE  item-uf.
                        ASSIGN  item-uf.cod-estab                = ""
                                item-uf.it-codigo                = tt-imp.col-a
                                item-uf.cod-estado-orig          = tt-imp.col-e
                                item-uf.estado                   = tt-imp.col-f                     
                                item-uf.dec-1                    = tt-imp.col-r               /* 18 - icms */ 
                                item-uf.val-icms-est-sub         = tt-imp.col-r               /* 18 - icms */
                                item-uf.perc-red-sub             = tt-imp.col-s
                                item-uf.val-perc-reduc-tab-pauta = tt-imp.col-s.              /* 19 - rbst */ 

                        IF tt-imp.col-e = tt-imp.col-f THEN /* estado origem = estado destino */
                          ASSIGN item-uf.per-sub-tri        = tt-imp.col-P.              /* 16 - st.e */
                        
                        IF tt-imp.col-e <> tt-imp.col-f THEN  /* estado origem <> estado destino */
                          ASSIGN item-uf.per-sub-tri        = tt-imp.col-q.              /* 17 - st.i   */          

                        /* para item tributado = 2 isento , familia 203-isento foi solicitado michel inclusao da tabela icms-it-uf ft0312 */
                        IF ITEM.cd-trib-icm  = 1 /* tributado */ OR ITEM.cd-trib-icm  = 2 /* isento */ THEN DO:  

                           /* ft0312 */
                           FIND FIRST familia WHERE
                                      familia.fm-codigo = tt-imp.col-aa NO-LOCK NO-ERROR.
                           IF AVAIL   familia THEN DO:
                              
                               /* se FOR alterado de 5 para 1 ou 2 */
                               FIND FIRST icms-it-uf WHERE
                                          icms-it-uf.it-codigo = tt-imp.col-a AND
                                          icms-it-uf.estado    = tt-imp.col-f EXCLUSIVE-LOCK NO-ERROR.
                               IF AVAIL icms-it-uf THEN 
                                  DELETE icms-it-uf.                        
                                       
                           END.
                        END.
                     END.
                     ELSE RUN pi-cria-msg( INPUT "Item-uf ja cadastrado." ).

                  END.
                  ELSE DO: /* alteracao de 5 para 1,2,3,4 iremos retirar do cadastro cd0904a item-uf */

                     FIND FIRST item-uf WHERE
                                item-uf.cod-estab           = ""            AND /* cfe informado item-uf.cod-estab sempre branco */
                                item-uf.it-codigo           = tt-imp.col-a  AND /* item */
                                item-uf.cod-estado-orig     = tt-imp.col-e  AND /* estado origem  */
                                item-uf.estado              = tt-imp.col-f      /* estado destino */ EXCLUSIVE-LOCK NO-ERROR.
                     IF AVAIL   item-uf THEN 
                        DELETE item-uf.
                     ELSE DO:
                         IF tt-imp.col-g <> 1 THEN
                            RUN pi-cria-msg( INPUT "Item-uf nao encontrado. " ).
                     END.
                      
                     /* para item tributado = 2 isento , familia 203-isento foi solicitado michel inclusao da tabela icms-it-uf ft0312 */
                     IF tt-imp.col-g = 1 /* tributado */ OR 
                        tt-imp.col-g = 2 /* isento    */ THEN DO:  
                         
                        IF (tt-imp.col-f = "PR" AND tt-imp.col-k <> 18) OR    /* estado destino utilizado + coluna K - Al.E */
                           (tt-imp.col-f = "SP" AND tt-imp.col-k <> 18) OR
                           (tt-imp.col-f = "SC" AND tt-imp.col-k <> 17) THEN DO:

                           /* ft0312 */
                           FIND FIRST icms-it-uf WHERE
                                      icms-it-uf.it-codigo = tt-imp.col-a AND
                                      icms-it-uf.estado    = tt-imp.col-f EXCLUSIVE-LOCK NO-ERROR.
                           IF NOT AVAIL icms-it-uf THEN DO:
    
                              CREATE  icms-it-uf.
                              ASSIGN  icms-it-uf.it-codigo                    = tt-imp.col-a
                                      icms-it-uf.estado                       = tt-imp.col-f
                                      icms-it-uf.aliquota-icm                 = tt-imp.col-k.

                              IF tt-imp.col-g = 2 /* isento    */ THEN DO:  

                                  FIND FIRST familia WHERE
                                             familia.fm-codigo = tt-imp.col-aa NO-LOCK NO-ERROR.
                                  IF AVAIL familia AND familia.fm-codigo = "203" THEN
                                     ASSIGN icms-it-uf.log-descons-para-nao-contrib = YES.
                              END.
    
                           END.
                           ELSE do:
                               
                              ASSIGN   icms-it-uf.aliquota-icm                 = tt-imp.col-k.

                              IF tt-imp.col-g = 2 /* isento    */ THEN DO:  

                                  FIND FIRST familia WHERE
                                             familia.fm-codigo = tt-imp.col-aa NO-LOCK NO-ERROR.
                                  IF AVAIL familia AND 
                                           familia.fm-codigo = "203" THEN
                                     ASSIGN icms-it-uf.log-descons-para-nao-contrib = YES.
                              END.
                           END.
                        END.
                     END.                      
                  END.
               END.
                
               ELSE DO: /* nao houve alteracao codigo tributacao 1,2,3,4,5 */

                   IF tt-imp.col-g = 1 THEN DO:

                      FIND FIRST item-uf WHERE
                                 item-uf.cod-estab           = ""            AND                      /* cfe informado item-uf.cod-estab sempre branco */ 
                                 item-uf.it-codigo           = tt-imp.col-a  AND                      /* item */                                          
                                 item-uf.cod-estado-orig     = tt-imp.col-e  AND                      /* estado origem  */                                
                                 item-uf.estado              = tt-imp.col-f  EXCLUSIVE-LOCK NO-ERROR. /* estado destino */                                
                      IF AVAIL item-uf THEN DO:
                          DELETE item-uf.
                      END.

                   END.

                   IF tt-imp.col-g = 5 THEN DO:

                      FIND FIRST item-uf WHERE
                                 item-uf.cod-estab           = ""            AND                      /* cfe informado item-uf.cod-estab sempre branco */ 
                                 item-uf.it-codigo           = tt-imp.col-a  AND                      /* item */                                          
                                 item-uf.cod-estado-orig     = tt-imp.col-e  AND                      /* estado origem  */                                
                                 item-uf.estado              = tt-imp.col-f  EXCLUSIVE-LOCK NO-ERROR. /* estado destino */                                
                      IF AVAIL item-uf THEN DO:

                         IF tt-imp.col-e = tt-imp.col-f THEN /* estado origem = estado destino */
                           ASSIGN item-uf.per-sub-tri        = tt-imp.col-P.              /* 16 - st.e */
  
                         IF tt-imp.col-e <> tt-imp.col-f THEN  /* estado origem <> estado destino */
                           ASSIGN item-uf.per-sub-tri        = tt-imp.col-q.              /* 17 - st.i   */  
    
                      END.
                      ELSE 
                          IF tt-imp.col-g <> 1 THEN
                              RUN pi-cria-msg( INPUT "Item-uf nao encontrado." ).
                   END.

                   /* para item tributado = 2 isento , familia 203-isento foi solicitado michel inclusao da tabela icms-it-uf ft0312 */
                   IF tt-imp.col-g = 1 /* tributado */ OR
                      tt-imp.col-g = 2 /* isento    */ THEN DO:
              
                      IF (tt-imp.col-f = "PR" AND tt-imp.col-k <> 18) OR    /* estado destino utilizado + coluna K - Al.E */
                         (tt-imp.col-f = "SP" AND tt-imp.col-k <> 18) OR
                         (tt-imp.col-f = "SC" AND tt-imp.col-k <> 17) THEN DO:

                         /* ft0312 */
                         FIND FIRST icms-it-uf WHERE
                                    icms-it-uf.it-codigo = tt-imp.col-a AND
                                    icms-it-uf.estado    = tt-imp.col-f EXCLUSIVE-LOCK NO-ERROR.
                         IF NOT AVAIL icms-it-uf THEN DO:
        
                            CREATE  icms-it-uf.
                            ASSIGN  icms-it-uf.it-codigo                    = tt-imp.col-a
                                    icms-it-uf.estado                       = tt-imp.col-f
                                    icms-it-uf.aliquota-icm                 = tt-imp.col-k.
        
                            IF tt-imp.col-g = 2 /* isento    */ THEN DO:
        
                                FIND FIRST familia WHERE
                                           familia.fm-codigo = tt-imp.col-aa NO-LOCK NO-ERROR.
                                IF AVAIL familia AND familia.fm-codigo = "203" THEN
                                   ASSIGN icms-it-uf.log-descons-para-nao-contrib = YES.
                            END.
                         END.
                      END.
                      ELSE DO:

                          IF (tt-imp.col-f = "PR" AND (tt-imp.col-k = 18 OR tt-imp.col-k = 0)) OR    /* estado destino utilizado + coluna K - Al.E */
                             (tt-imp.col-f = "SP" AND (tt-imp.col-k = 18 OR tt-imp.col-k = 0)) OR
                             (tt-imp.col-f = "SC" AND (tt-imp.col-k = 17 OR tt-imp.col-k = 0)) THEN DO:

                             /* ft0312 */
                             FIND FIRST icms-it-uf WHERE
                                        icms-it-uf.it-codigo = tt-imp.col-a AND
                                        icms-it-uf.estado    = tt-imp.col-f EXCLUSIVE-LOCK NO-ERROR.
                             IF AVAIL icms-it-uf THEN 
                                DELETE icms-it-uf.

                          END.
                      END.
                   END.
               END.               
            END.
          
            /* alteracao do campo char-2 tabela item - coluna 30 - AD e coluna 32 - AF */
            FIND FIRST ITEM WHERE
                       ITEM.it-codigo = tt-imp.col-a EXCLUSIVE-LOCK NO-ERROR.
            IF AVAIL   ITEM THEN DO: 
               ASSIGN OVERLAY(ITEM.char-2,31,5) = string(tt-imp.col-ad,"99.99")
                      OVERLAY(ITEM.char-2,36,5) = STRING(tt-imp.col-af,"99.99"). 

               RUN grava-aliquotas IN h-cdapi995 (INPUT "item",
                                   INPUT ITEM.it-codigo,
                                   INPUT DEC(tt-imp.col-ad),
                                   INPUT DEC(tt-imp.col-af)).
            END.
            ELSE RUN pi-cria-msg( INPUT "Item nao encontrado." ).

            /* alteracao do campo item.fm-codigo conforme informado na planilha , somente quando for alteracao */
            IF tt-imp.col-AA <> "" AND      /* familia */
               tt-imp.col-a  <> "" THEN DO: /* item */

               FIND FIRST familia WHERE
                          familia.fm-codigo = tt-imp.col-aa NO-LOCK NO-ERROR.
               IF AVAIL   familia THEN DO:

                  FIND FIRST ITEM WHERE
                             ITEM.it-codigo = tt-imp.col-a EXCLUSIVE-LOCK NO-ERROR.
                  IF AVAIL   ITEM THEN  
                     ASSIGN ITEM.fm-codigo = tt-imp.col-aa. /* alterando o codigo da familia do item, caso ele esteja corretamente cadastrado */

               END.
               ELSE RUN pi-cria-msg( INPUT "Familia nao cadastrada: " + STRING(tt-imp.col-aa) ).

            END. 
           
            /* alteracao diversos campos item-uf (cd0904a) cfe informado planilha exportacao , gerado pelo esp002  (.csv)  */ 
            FIND FIRST item-uf WHERE
                       item-uf.cod-estab           = ""            AND                      /* cfe informado item-uf.cod-estab sempre branco */
                       item-uf.it-codigo           = tt-imp.col-a  AND                      /* item */                                         
                       item-uf.cod-estado-orig     = tt-imp.col-e  AND                      /* estado origem  */                               
                       item-uf.estado              = tt-imp.col-f  EXCLUSIVE-LOCK NO-ERROR. /* estado destino */                               
                       
            IF AVAIL   item-uf THEN DO:
   
               ASSIGN  item-uf.perc-red-sub             = tt-imp.col-s               /* 19 - rbst */ 
                       item-uf.val-perc-reduc-tab-pauta = tt-imp.col-s. 

               IF tt-imp.col-g = 5 THEN DO:

                  ASSIGN item-uf.val-icms-est-sub   = tt-imp.col-r.              /* 18 - icms */
                  ASSIGN item-uf.dec-1              = tt-imp.col-r.              /* 18 - icms */
                  
                  IF tt-imp.col-e = tt-imp.col-f THEN /* estado origem = estado destino */
                    ASSIGN item-uf.per-sub-tri        = tt-imp.col-P.              /* 16 - st.e */

                  IF tt-imp.col-e <> tt-imp.col-f THEN  /* estado origem <> estado destino */
                    ASSIGN item-uf.per-sub-tri        = tt-imp.col-q.              /* 17 - st.i   */

               END.
            END.
            ELSE IF tt-imp.col-g <> 1 THEN
                RUN pi-cria-msg( INPUT "Item-uf nao encontrado." ).
            
         END.
         /************************************************************************************************************************************************/
         ELSE IF tt-imp.col-ao = "E" THEN DO: /* exclusao do registro na tabela item-uf  */

            FIND FIRST item-uf WHERE
                       item-uf.cod-estab           = ""            AND                      /* cfe informado item-uf.cod-estab sempre branco */
                       item-uf.it-codigo           = tt-imp.col-a  AND                      /* item */
                       item-uf.cod-estado-orig     = tt-imp.col-e  AND                      /* estado origem  */
                       item-uf.estado              = tt-imp.col-f  EXCLUSIVE-LOCK NO-ERROR. /* estado destino */
            IF AVAIL   item-uf THEN
               DELETE item-uf.
            ELSE IF tt-imp.col-g <> 1 THEN RUN pi-cria-msg( INPUT "Item-uf nao encontrado." ).
              
         END.
         /************************************************************************************************************************************************/
         ELSE IF tt-imp.col-ao = "I" THEN DO: /* inclusao do registro na tabela item-uf */

            /*verificar caracteristicas tecnicas 90 - coluna 23 - W*/
            ASSIGN l-alterou = NO.
            FIND FIRST it-carac-tec
                 WHERE it-carac-tec.it-codigo = tt-imp.col-a  and
                       it-carac-tec.cd-folha  = "CADITEM"     AND
                       it-carac-tec.cd-comp   = "90"          EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAIL it-carac-tec THEN DO:
               CREATE it-carac-tec.                                                               
               ASSIGN it-carac-tec.it-codigo  = tt-imp.col-a
                      it-carac-tec.cd-folha   = "CADITEM"
                      it-carac-tec.cd-comp    = "90"
                      it-carac-tec.tipo-resul = 2 /* tabela */
                      it-carac-tec.nr-tabela  = 90.
            END.
            FIND FIRST c-tab-res WHERE
                       c-tab-res.nr-tabela = 90 AND
                       c-tab-res.descricao BEGINS SUBSTR(STRING(tt-imp.col-w),1,1) NO-LOCK NO-ERROR.
            IF AVAIL c-tab-res THEN DO:
               FIND FIRST it-res-carac WHERE
                          it-res-carac.cd-comp    = "90"         AND
                          it-res-carac.cd-folha   = "CADITEM"    AND
                          it-res-carac.it-codigo  = tt-imp.col-a AND
                          it-res-carac.nr-tabela  = 90 NO-ERROR.
               IF NOT AVAIL it-res-carac THEN DO:
                  create it-res-carac.
                  assign it-res-carac.cd-comp    = "90"
                         it-res-carac.cd-folha   = "CADITEM"
                         it-res-carac.it-codigo  = tt-imp.col-a
                         it-res-carac.nr-tabela  = 90
                         it-res-carac.sequencia  = c-tab-res.sequencia.
               END.
               ELSE
                  ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

               IF it-carac-tec.observacao <> c-tab-res.descricao THEN
                  ASSIGN l-alterou = YES.

               ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).
               RELEASE it-carac-tec.

            END.

            /* verificar caracteristicas tecnicas 290 - coluna 23 - ac - tributa pis */
            FIND FIRST it-carac-tec
                 WHERE it-carac-tec.it-codigo = tt-imp.col-a AND
                       it-carac-tec.cd-folha  = "CADITEM"    AND
                       it-carac-tec.cd-comp   = "290"        EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAIL it-carac-tec THEN DO:
               CREATE it-carac-tec.                                                               
               ASSIGN it-carac-tec.it-codigo  = tt-imp.col-a
                      it-carac-tec.cd-folha   = "CADITEM"
                      it-carac-tec.cd-comp    = "290"
                      it-carac-tec.tipo-resul = 2 /* tabela */
                      it-carac-tec.nr-tabela  = 290.
            END.
            FIND FIRST c-tab-res WHERE
                       c-tab-res.nr-tabela = 290 AND
                       c-tab-res.descricao BEGINS SUBSTR(STRING(tt-imp.col-ac),1,1) NO-LOCK NO-ERROR.
            IF AVAIL c-tab-res THEN DO:
               FIND FIRST it-res-carac WHERE
                          it-res-carac.cd-comp    = "290"        AND
                          it-res-carac.cd-folha   = "CADITEM"    AND
                          it-res-carac.it-codigo  = tt-imp.col-a AND
                          it-res-carac.nr-tabela  = 290 NO-ERROR.
               IF NOT AVAIL it-res-carac THEN DO:
                  create it-res-carac.
                  assign it-res-carac.cd-comp    = "290"
                         it-res-carac.cd-folha   = "CADITEM"
                         it-res-carac.it-codigo  = tt-imp.col-a 
                         it-res-carac.nr-tabela  = 290
                         it-res-carac.sequencia  = c-tab-res.sequencia.
               END.
               ELSE
                  ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

               IF it-carac-tec.observacao <> c-tab-res.descricao THEN
                  ASSIGN l-alterou = YES.

               ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).
               RELEASE it-carac-tec.

            END.                                                                                         

            /* verificar caracteristicas tecnicas 300 - coluna 31 - ae - tributa cofins*/
            FIND FIRST it-carac-tec
                 WHERE it-carac-tec.it-codigo = tt-imp.col-a AND
                       it-carac-tec.cd-folha  = "CADITEM"    AND
                       it-carac-tec.cd-comp   = "300"        EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAIL it-carac-tec THEN DO:
               CREATE it-carac-tec.                                                               
               ASSIGN it-carac-tec.it-codigo  = tt-imp.col-a
                      it-carac-tec.cd-folha   = "CADITEM"
                      it-carac-tec.cd-comp    = "300"
                      it-carac-tec.tipo-resul = 2 /* tabela */
                      it-carac-tec.nr-tabela  = 300.
            END.
            FIND FIRST c-tab-res WHERE
                       c-tab-res.nr-tabela = 300 AND
                       c-tab-res.descricao BEGINS SUBSTR(STRING(tt-imp.col-ae),1,1) NO-LOCK NO-ERROR.
            IF AVAIL c-tab-res THEN DO:
               FIND FIRST it-res-carac WHERE
                          it-res-carac.cd-comp    = "300"        AND
                          it-res-carac.cd-folha   = "CADITEM"    AND
                          it-res-carac.it-codigo  = tt-imp.col-a AND
                          it-res-carac.nr-tabela  = 300 NO-ERROR.
               IF NOT AVAIL it-res-carac THEN DO:
                  create it-res-carac.
                  assign it-res-carac.cd-comp    = "300"
                         it-res-carac.cd-folha   = "CADITEM"
                         it-res-carac.it-codigo  = tt-imp.col-a
                         it-res-carac.nr-tabela  = 300
                         it-res-carac.sequencia  = c-tab-res.sequencia.
               END.
               ELSE
                  ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

               IF it-carac-tec.observacao <> c-tab-res.descricao THEN
                  ASSIGN l-alterou = YES.

               ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).
               RELEASE it-carac-tec.

            END.

            IF NOT AVAIL ITEM THEN DO:
               FIND FIRST ITEM WHERE 
                          ITEM.it-codigo = tt-imp.col-a NO-LOCK NO-ERROR.
            END.
                      
            IF l-alterou = YES THEN DO:
               IF AVAIL ITEM THEN DO:
                  RUN pi-integracao /*(INPUT ITEM.it-codigo)*/. /* Integra a it-carac-tec alterada com o Sysfarma */
               END.
            END.

            IF tt-imp.col-g = 5 THEN DO: /* 7-g-tr */

                FIND FIRST item-uf WHERE
                           item-uf.cod-estab           = ""            AND                         /* cfe informado item-uf.cod-estab sempre branco */
                           item-uf.it-codigo           = tt-imp.col-a  AND                         /* item */
                           item-uf.cod-estado-orig     = tt-imp.col-e  AND                         /* estado origem  */
                           item-uf.estado              = tt-imp.col-f  EXCLUSIVE-LOCK NO-ERROR.    /* estado destino */ 
                IF NOT AVAIL item-uf THEN do:
                
                   CREATE  item-uf.
                   ASSIGN  item-uf.cod-estab                 = ""
                           item-uf.it-codigo                 = tt-imp.col-a
                           item-uf.cod-estado-orig           = tt-imp.col-e
                           item-uf.estado                    = tt-imp.col-f
                           item-uf.dec-1                     = tt-imp.col-r               /* 18 - icms */ 
                           item-uf.val-icms-est-sub          = tt-imp.col-r               /* 18 - icms */
                           item-uf.perc-red-sub              = tt-imp.col-s               /* 19 - rbst */   
                           item-uf.val-perc-reduc-tab-pauta  = tt-imp.col-s. 

                   IF tt-imp.col-e = tt-imp.col-f THEN /* estado origem = estado destino */
                     ASSIGN item-uf.per-sub-tri        = tt-imp.col-P.              /* 16 - st.e */

                   IF tt-imp.col-e <> tt-imp.col-f THEN  /* estado origem <> estado destino */
                     ASSIGN item-uf.per-sub-tri        = tt-imp.col-q.              /* 17 - st.i   */

                END.
                ELSE RUN pi-cria-msg( INPUT "Item-uf ja cadastrado." ).                 
            END.

            /* para item tributado = 2 isento , familia 203-isento foi solicitado michel inclusao da tabela icms-it-uf ft0312 */
            IF tt-imp.col-g = 1 /* tributado */ OR
               tt-imp.col-g = 2 /* isento    */ THEN DO:

               IF tt-imp.col-f = "PR" AND tt-imp.col-k <> 18 OR    /* estado destino utilizado + coluna K - Al.E */
                  tt-imp.col-f = "SP" AND tt-imp.col-k <> 18 OR
                  tt-imp.col-f = "SC" AND tt-imp.col-k <> 17 THEN DO:

                  /* ft0312 */
                  FIND FIRST icms-it-uf WHERE
                             icms-it-uf.it-codigo = tt-imp.col-a AND
                             icms-it-uf.estado    = tt-imp.col-f EXCLUSIVE-LOCK NO-ERROR.
                  IF NOT AVAIL icms-it-uf THEN DO:

                     CREATE  icms-it-uf.
                     ASSIGN  icms-it-uf.it-codigo                    = tt-imp.col-a
                             icms-it-uf.estado                       = tt-imp.col-f
                             icms-it-uf.aliquota-icm                 = tt-imp.col-k.

                     IF tt-imp.col-g = 2 /* isento    */ THEN DO:

                         FIND FIRST familia WHERE
                                    familia.fm-codigo = tt-imp.col-aa NO-LOCK NO-ERROR.
                         IF AVAIL familia AND familia.fm-codigo = "203" THEN
                            ASSIGN icms-it-uf.log-descons-para-nao-contrib = YES.
                     END.
                  END.
               END.
            END.
         END.

         FIND FIRST item WHERE
                    item.it-codigo = tt-imp.col-a EXCLUSIVE-LOCK NO-ERROR.
         IF AVAIL item THEN DO:            
            ASSIGN ITEM.aliquota-ipi           = tt-imp.col-v                   /* aliquota ipi */
                   item.cd-trib-ipi            = 3                              /* outros */
                   ITEM.class-fiscal           = tt-imp.COL-x
                   item.codigo-orig            = tt-imp.col-y                   /* csta */
                   OVERLAY(ITEM.char-2,31,5)   = string(tt-imp.col-ad,"99.99")  /* coluna AD -Aliquota Pis     */
                   OVERLAY(ITEM.char-2,36,5)   = string(tt-imp.col-af,"99.99")  /* Coluna AF -Aliquota Cofins  */
                   //OVERLAY(ITEM.char-2,60,1)   = tt-imp.col-al
                   .


            IF tt-imp.col-f = "PR" THEN
               DO:
                    FOR EACH item-uni-estab 
                        WHERE  item-uni-estab.cod-estabel = "973"
                          AND item-uni-estab.it-codigo   = tt-imp.col-a:
                          

                        ASSIGN SUBSTRING(item-uni-estab.char-2, 60, 1) = tt-imp.col-AL.
           
                   END. 
 
               END.
               
               IF tt-imp.col-f = "SP" THEN
               DO:
                    FOR EACH item-uni-estab
                        WHERE  item-uni-estab.cod-estabel = "977"
                          AND item-uni-estab.it-codigo   = tt-imp.col-a:
                          

                        ASSIGN SUBSTRING(item-uni-estab.char-2, 60, 1) = tt-imp.col-AM.

           
                   END. 
 
               END.    
                   
            RUN grava-aliquotas IN h-cdapi995 (INPUT "item",
                                               INPUT ITEM.it-codigo,
                                               INPUT DEC(tt-imp.col-ad),
                                               INPUT DEC(tt-imp.col-af)).

            /* KML - Altera‡Æo para importar o CEST dos Itens */
            
            FIND FIRST sit-tribut-relacto EXCLUSIVE-LOCK
                WHERE sit-tribut-relacto.cod-item = ITEM.it-codigo NO-ERROR.

            IF AVAIL sit-tribut-relacto THEN DO:


                IF int(tt-imp.col-aj) <> 0 THEN DO:
                
                   IF idi-tip-docto = 1  THEN DO:
                        ASSIGN sit-tribut-relacto.cdn-sit-tribut = int(tt-imp.col-aj). /* CEST Entrada */
                   END.
                   ELSE DO:
                        ASSIGN sit-tribut-relacto.cdn-sit-tribut = int(tt-imp.col-ak). /* CEST Saida */
                   END.
                END.
            END.
            ELSE DO:

                IF int(tt-imp.col-aj) <> 0 THEN DO:
    
                    CREATE sit-tribut-relacto.
                    ASSIGN sit-tribut-relacto.cdn-tribut        = 11
                           sit-tribut-relacto.cdn-sit-tribut    = int(tt-imp.col-aj)
                           sit-tribut-relacto.cod-estab         = "*"
                           sit-tribut-relacto.cod-natur-operac  = "*"
                           sit-tribut-relacto.cod-ncm           = ITEM.class-fiscal
                           sit-tribut-relacto.cod-item          = ITEM.it-codigo
                           sit-tribut-relacto.cdn-grp-emit      = 0
                           sit-tribut-relacto.cdn-emitente      = 0
                           sit-tribut-relacto.dat-valid-inic    = TODAY
                           sit-tribut-relacto.idi-tip-docto     = 1.
    
                    RELEASE sit-tribut-relacto.
    
                    CREATE sit-tribut-relacto.
                    ASSIGN sit-tribut-relacto.cdn-tribut        = 11
                           sit-tribut-relacto.cdn-sit-tribut    = int(tt-imp.col-ak)
                           sit-tribut-relacto.cod-estab         = "*"
                           sit-tribut-relacto.cod-natur-operac  = "*"
                           sit-tribut-relacto.cod-ncm           = ITEM.class-fiscal
                           sit-tribut-relacto.cod-item          = ITEM.it-codigo
                           sit-tribut-relacto.cdn-grp-emit      = 0
                           sit-tribut-relacto.cdn-emitente      = 0
                           sit-tribut-relacto.dat-valid-inic    = TODAY
                           sit-tribut-relacto.idi-tip-docto     = 2.
                END.

            END.

            RELEASE sit-tribut-relacto.
            
            /* KML - Fim da altera‡Æo */


         END.
         RELEASE item.
         /************************************************************************************************************************************************/
     end.

     /* atualizacao do codigo da tributacao ao final do processo , para os registros de alteracao */
     for EACH tt-imp NO-LOCK:

        IF tt-imp.col-ao = "A" THEN DO: /* Alteracao */

            FIND FIRST ITEM WHERE
                       ITEM.it-codigo = tt-imp.col-a EXCLUSIVE-LOCK NO-ERROR. 
            IF AVAIL ITEM THEN DO:
                
               IF ITEM.cd-trib-icm <> tt-imp.col-g THEN  /* se houve alteracao do codigo de tributacao, 1,2,3,4 ou 5 */
                  ASSIGN ITEM.cd-trib-icm = tt-imp.col-g.  

               IF ITEM.fm-codigo = "102"
               OR ITEM.fm-codigo = "202"
               OR ITEM.fm-codigo = "402" THEN DO:
                  ASSIGN ITEM.cd-trib-icm = 2. /* Isento */
               END.
               ELSE DO:
                  IF ITEM.fm-codigo >= "900" THEN DO:
                     ASSIGN ITEM.cd-trib-icm = 3. /* Outros */
                  END.
                  ELSE DO:
                     ASSIGN ITEM.cd-trib-icm = 1. /* Tributado */
                  END.
               END.
            END.
        END.
     END.
     /* fim termino atualizacao do codigo de tributacao */

     FIND FIRST tt-msg NO-LOCK NO-ERROR.
     IF AVAIL   tt-msg THEN DO:

         PUT UNFORMATTED "" SKIP(1).
     
         put unformatted 
             "                                                      Registros nao atualizados":U SKIP
             "                                                      -------------------------"   skip(2).

         PUT UNFORMATTED
             "Tipo Codigo Item             Uf.Orig Uf.Dest Descricao " SKIP
             "---- ------ ---------------- ------- ------- ----------------------------------------------------------------------------------------------------" SKIP.
         
         for each tt-msg  :
    
             DISP tt-msg.tipo
                  tt-msg.cd-trib-icm
                  tt-msg.it-codigo       
                  tt-msg.cod-estado-orig 
                  tt-msg.estado          
                  tt-msg.descricao
                  WITH FRAME f-nok. 
             down with frame f-nok.
         end.
     END.

     DISP tt-param.destino                 
          tt-param.arquivo          
          tt-param.usuario WITH FRAME f-impressao.  
     down with frame f-impressao.

     run pi-finalizar in h-acomp.   

 END PROCEDURE.
/*******************************************************************************************************************************************************************************************/
 
PROCEDURE pi-cria-msg:

DEF INPUT PARAM msg AS CHAR NO-UNDO.

   create tt-msg.
   assign tt-msg.tipo            = tt-imp.col-al
          tt-msg.cd-trib-icm     = tt-imp.col-g
          tt-msg.it-codigo       = tt-imp.col-a
          tt-msg.cod-estado-orig = tt-imp.col-e
          tt-msg.estado          = tt-imp.col-f
          tt-msg.descricao       = msg.

END PROCEDURE.

PROCEDURE pi-integracao:

    ASSIGN i-seq-int_ds_item = NEXT-VALUE(seq-int-ds-item). /* Prepara‡Æo para integra‡Æo com Procfit */

    CREATE int_ds_item.
    ASSIGN int_ds_item.envio_status               = 0
           int_ds_item.tipo_movto                 = 2 /* Altera‡Æo */                 
           int_ds_item.dt_geracao                 = TODAY
           int_ds_item.hr_geracao                 = STRING(TIME,"hh:mm:ss") 
           int_ds_item.cod_usuario                = c-seg-usuario
           int_ds_item.situacao                   = 1 /* Pendente */
           int_ds_item.pro_codigo_n               = int(item.it-codigo) 
           int_ds_item.pro_descricaocupomfiscal_s = item.desc-item 
           int_ds_item.pro_datacadastro_d         = item.data-implant
           int_ds_item.pro_ncm_s                  = substr(item.class-fiscal,1,8)
           int_ds_item.pro_grupocomercial_n       = INT(item.fm-cod-com)
           int_ds_item.id_sequencial              = i-seq-int_ds_item. /* Prepara‡Æo para integra‡Æo com Procfit */
    
    FIND FIRST int_ds_ext_item WHERE
               int_ds_ext_item.it_codigo = item.it-codigo NO-LOCK NO-ERROR.
    IF AVAIL int_ds_ext_item THEN DO:
       ASSIGN int_ds_item.pro_ncmipi_n = int_ds_ext_item.ncmipi.
    END.
    
    /*
    /* Atualiza‡Æo da tabela de integra‡Æo Datasul -> Sysfarma */
    /*           C¢digos de Barra dos Itens - EAN              */  
    
    FOR EACH int-ds-ean-item WHERE
             int-ds-ean-item.it-codigo = item.it-codigo NO-LOCK:
    
        CREATE int_ds_item-compl.
        ASSIGN int_ds_item-compl.tipo-movto          = 2 /* Altera‡Æo */
               int_ds_item-compl.dt-geracao          = TODAY
               int_ds_item-compl.hr-geracao          = STRING(TIME,"hh:mm:ss") 
               int_ds_item-compl.cod-usuario         = c-seg-usuario
               int_ds_item-compl.situacao            = 1 /* Pendente */
               int_ds_item-compl.cba-produto-n       = INT(int-ds-ean-item.it-codigo)        
               int_ds_item-compl.cba-ean-n           = int-ds-ean-item.codigo-ean          
               int_ds_item-compl.cba-lotemultiplo-n  = int-ds-ean-item.lote-multiplo       
               int_ds_item-compl.cba-altura-n        = int-ds-ean-item.altura              
               int_ds_item-compl.cba-largura-n       = int-ds-ean-item.largura             
               int_ds_item-compl.cba-profundidade-n  = int-ds-ean-item.profundidade        
               int_ds_item-compl.cba-peso-n          = int-ds-ean-item.peso                
               int_ds_item-compl.cba-data-cadastro-d = int-ds-ean-item.data-cadastro       
               int_ds_item-compl.cba-principal-s     = IF int-ds-ean-item.principal = YES THEN
                                                          "S"
                                                       ELSE 
                                                          "N"
               int_ds_item-compl.id_cabecalho        = i-seq-int_ds_item
               int_ds_item-compl.id_sequencial       = NEXT-VALUE(seq-int_ds_item-compl). /* Prepara‡Æo para integra‡Æo com Procfit */

    END.*/
    
    IF item.cd-folh-item = "CADITEM" THEN DO:
       FOR EACH it-carac-tec WHERE
                it-carac-tec.it-codigo = item.it-codigo AND
                it-carac-tec.cd-folha = "CADITEM" NO-LOCK:
       
           IF it-carac-tec.cd-comp = "10" THEN
              ASSIGN int_ds_item.pro_descricaoetiqueta_s = substr(it-carac-tec.observacao,1,30).
       
           IF it-carac-tec.cd-comp = "20" THEN
              ASSIGN int_ds_item.pro_descricaoweb_s = it-carac-tec.observacao.
           
           IF it-carac-tec.cd-comp = "25" THEN
              ASSIGN int_ds_item.pro_divisao_n = INT(substr(it-carac-tec.observacao,1,3)).          
       
           IF it-carac-tec.cd-comp = "30" THEN
              ASSIGN int_ds_item.pro_tipoproduto_n = INT(substr(it-carac-tec.observacao,1,1)).
       
           IF it-carac-tec.cd-comp = "40" THEN
              ASSIGN int_ds_item.pro_categoriaconvenio_n = INT(substr(it-carac-tec.observacao,1,2)).
           
           IF it-carac-tec.cd-comp = "45" THEN
              ASSIGN int_ds_item.pro_sazonalidade_n = INT(substr(it-carac-tec.observacao,1,1)).                   
       
           IF it-carac-tec.cd-comp = "60" THEN
              ASSIGN int_ds_item.pro_subgrupocomercial_n = INT(substr(it-carac-tec.observacao,1,3)).
       
           IF it-carac-tec.cd-comp = "65" THEN
              ASSIGN int_ds_item.pro_sigla_pdv_s = substr(it-carac-tec.observacao,1,15). 
       
           IF it-carac-tec.cd-comp = "70" THEN
              ASSIGN int_ds_item.pro_gerapedido_s = substr(it-carac-tec.observacao,1,1). 
       
           IF item.cod-obsoleto = 1 THEN
              ASSIGN int_ds_item.pro_situacaoproduto_s = "A".
    
           IF item.cod-obsoleto = 2 OR item.cod-obsoleto = 3 THEN
              ASSIGN int_ds_item.pro_situacaoproduto_s = "E".
    
           IF item.cod-obsoleto = 4 THEN
              ASSIGN int_ds_item.pro_situacaoproduto_s = "I".
       
           IF it-carac-tec.cd-comp = "90" THEN
              ASSIGN int_ds_item.pro_lista_s = substr(it-carac-tec.observacao,1,1).                
       
           IF it-carac-tec.cd-comp = "100" THEN
              ASSIGN int_ds_item.pro_fracionado_s = substr(it-carac-tec.observacao,1,1).
       
           IF it-carac-tec.cd-comp = "110" THEN
              ASSIGN int_ds_item.pro_lastro_n = it-carac-tec.vl-result.
       
           IF it-carac-tec.cd-comp = "120" THEN
              ASSIGN int_ds_item.pro_camada_n = it-carac-tec.vl-result.         
       
           IF it-carac-tec.cd-comp = "140" THEN
              ASSIGN int_ds_item.pro_publicoalvo_n = INT(substr(it-carac-tec.observacao,1,1)).
       
           IF it-carac-tec.cd-comp = "150" THEN
              ASSIGN int_ds_item.pro_informaprescricao_s = substr(it-carac-tec.observacao,1,1).
           
           IF it-carac-tec.cd-comp = "170" THEN
              ASSIGN int_ds_item.pro_monitorado_s = substr(it-carac-tec.observacao,1,1).
       
           IF it-carac-tec.cd-comp = "180" THEN
              ASSIGN int_ds_item.pro_tarjado_s = substr(it-carac-tec.observacao,1,1).
       
           IF it-carac-tec.cd-comp = "190" THEN
              ASSIGN int_ds_item.pro_sngpc_n  = INT(substr(it-carac-tec.observacao,1,1)).
       
           IF it-carac-tec.cd-comp = "200" THEN DO:
              IF substr(it-carac-tec.observacao,1,2) = "  " THEN
                 ASSIGN int_ds_item.pro_portaria_s = "".
              ELSE
                 ASSIGN int_ds_item.pro_portaria_s = substr(it-carac-tec.observacao,1,2).
           END.
    
           IF it-carac-tec.cd-comp = "210" THEN
              ASSIGN int_ds_item.pro_apresentacao_n = it-carac-tec.vl-result.
       
           IF it-carac-tec.cd-comp = "225" THEN
              ASSIGN int_ds_item.pro_dosagemapresentacao_n = INT(substr(it-carac-tec.observacao,1,2)).
       
           IF it-carac-tec.cd-comp = "230" THEN
              ASSIGN int_ds_item.pro_concentracao_n = it-carac-tec.vl-result.
       
           IF it-carac-tec.cd-comp = "240" THEN
              ASSIGN int_ds_item.pro_dosagemconcentracao_n = INT(substr(it-carac-tec.observacao,1,2)).
       
           IF it-carac-tec.cd-comp = "250" THEN
              ASSIGN int_ds_item.pro_nomecomercial_s = it-carac-tec.observacao. 
       
           IF it-carac-tec.cd-comp = "255" THEN
              ASSIGN int_ds_item.pro_datasngpc_d = it-carac-tec.dt-result. 
                      
           IF it-carac-tec.cd-comp = "260" THEN
              ASSIGN int_ds_item.pro_csta_n = INT(substr(it-carac-tec.observacao,1,1)).
       
           IF it-carac-tec.cd-comp = "270" THEN
              ASSIGN int_ds_item.pro_unidademedidamedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
            
           IF it-carac-tec.cd-comp = "280" THEN
              ASSIGN int_ds_item.pro_excecaopiscofinsncm_s = substr(it-carac-tec.observacao,1,1).
       
           IF it-carac-tec.cd-comp = "290" THEN
              ASSIGN int_ds_item.pro_tributapis_s = substr(it-carac-tec.observacao,1,1).
       
           IF it-carac-tec.cd-comp = "300" THEN
              ASSIGN int_ds_item.pro_tributacofins_s = substr(it-carac-tec.observacao,1,1).
       
           IF it-carac-tec.cd-comp = "310" THEN
              ASSIGN int_ds_item.pro_classificacaomedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
           
           IF it-carac-tec.cd-comp = "330" THEN
              ASSIGN int_ds_item.pro_utilizapautafiscal_s = substr(it-carac-tec.observacao,1,1).
       
           IF it-carac-tec.cd-comp = "340" THEN
              ASSIGN int_ds_item.pro_valorpautafiscal_n = it-carac-tec.vl-result.
       
           IF it-carac-tec.cd-comp = "350" THEN
              ASSIGN int_ds_item.pro_emiteetiqueta_s = substr(it-carac-tec.observacao,1,1).
       
           IF it-carac-tec.cd-comp = "360" THEN
              ASSIGN int_ds_item.pro_pbm_s = substr(it-carac-tec.observacao,1,1).
       
           IF it-carac-tec.cd-comp = "370" THEN
              ASSIGN int_ds_item.pro_cestabasica_s = substr(it-carac-tec.observacao,1,1).  
       
           IF it-carac-tec.cd-comp = "380" THEN
              ASSIGN int_ds_item.pro_reposicaopbm_s = substr(it-carac-tec.observacao,1,1).
                     
           IF it-carac-tec.cd-comp = "390" THEN
              ASSIGN int_ds_item.pro_quantidadeembarque_n = DEC(it-carac-tec.observacao).          
           
           IF it-carac-tec.cd-comp = "400" THEN
              ASSIGN int_ds_item.pro_circuladeposito_s = substr(it-carac-tec.observacao,1,1).  
       
           IF it-carac-tec.cd-comp = "410" THEN
              ASSIGN int_ds_item.pro_aceitadevolucao_s = substr(it-carac-tec.observacao,1,1).     
           
           IF it-carac-tec.cd-comp = "420" THEN
              ASSIGN int_ds_item.pro_mercadologica_s = substr(it-carac-tec.observacao,1,2).          
    
           IF it-carac-tec.cd-comp = "430" THEN 
              ASSIGN int_ds_item.pro_registroms_n = DEC(it-carac-tec.observacao).
       END.
    END.

    ASSIGN int_ds_item.envio_status = 1.

    RELEASE int_ds_item.
  
END PROCEDURE.


/*  Fecha o Objeto Excel ********************************************************************************************************************************************************************/  

PROCEDURE closeExcel:

    chexcel:QUIT().

    ASSIGN chExcel     = ? NO-ERROR.
    //ASSIGN ch-arquivo  = ? NO-ERROR.
    //ASSIGN ch-Planilha = ? NO-ERROR.

END PROCEDURE.
