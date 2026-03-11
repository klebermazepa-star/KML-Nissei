/**********************************************************************************************
**
**  Programa: int090rp - Gera‡Æo e integra‡Æo dos dados fiscais dos itens - Datasul -> Procfit
**
**********************************************************************************************/
                          
DISABLE TRIGGERS FOR LOAD OF ITEM. 

.MESSAGE "v3"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                                                                                                                                                           
/******** Variaveis utilizadas na planilha excel *********************************/   
                                                                                      
DEF VAR i-linha       AS INT              NO-UNDO.                                    
DEF VAR c-lista       AS CHAR             NO-UNDO.    
DEF VAR l-primeiro    AS LOG              NO-UNDO.

DEF BUFFER b-item-uf     FOR item-uf.


/* KML - 16/01/2025 - Funcc…o para retornar aliquota interestadual de forma for‡ada */

FUNCTION fn-aliq-interestadual RETURNS DECIMAL
  ( fc-origem AS CHAR, fc-destino AS CHAR) : 
    
    DEFINE VARIABLE de-aliquota AS DECIMAL     NO-UNDO.
    
    IF fc-origem = fc-destino THEN
    DO:
    
        FIND FIRST unid-feder
            WHERE unid-feder.pais = "BRASIL"
              AND unid-feder.estado = fc-origem NO-ERROR.
            
        IF AVAIL unid-feder THEN
            ASSIGN de-aliquota = unid-feder.pc-icms-st.
        
    END.
    ELSE DO:
    
        ASSIGN de-aliquota = 12. 
            
        IF fc-origem = "MG" OR 
           fc-origem = "PR" OR 
           fc-origem = "RS" OR 
           fc-origem = "RJ" OR 
           fc-origem = "SC" OR 
           fc-origem = "SP" THEN DO:
           
            IF fc-destino = "MG" OR
               fc-destino = "PR" OR
               fc-destino = "RS" OR
               fc-destino = "RJ" OR
               fc-destino = "SC" OR 
               fc-destino = "SP" THEN 
                ASSIGN de-aliquota = 12.
            ELSE 
                ASSIGN de-aliquota = 7.     
            
        END.
    END.
    
    RETURN de-aliquota.
  
END.

/*******************************************************************************************************************************************************************************************/      
 
{include/i-prgvrs.i "INT090RP" 2.00.00.000}
  
{utp/ut-glob.i}

define temp-table tt-digita NO-UNDO
       FIELD cod-estabel AS CHAR FORMAT "x(3)"
       index id is primary UNIQUE
       cod-estabel.
 
define temp-table TT-PARAM NO-UNDO
       FIELD DESTINO            AS INTEGER 
       FIELD ARQUIVO            AS CHAR FORMAT "x(35)"
       FIELD USUARIO            AS CHAR FORMAT "x(12)"
       FIELD DATA-EXEC          AS DATE 
       FIELD HORA-EXEC          AS INTEGER 
       FIELD L-IMP-PARAM        AS LOG 
       FIELD L-EXCEL            AS LOG 
       FIELD cod-estab-ini      as character FORMAT "x(3)"
       FIELD cod-estab-fim      as character FORMAT "x(3)"
       FIELD it-codigo-ini      as character FORMAT "x(16)"
       FIELD it-codigo-fim      as character FORMAT "x(16)"
       FIELD tg-pr              AS LOG       
       FIELD tg-sp              AS LOG
       FIELD tg-sc              AS LOG
       FIELD tg-go              AS LOG
       FIELD tg-df              AS LOG
       FIELD tg-pr-dest         AS LOG       
       FIELD tg-sp-dest         AS LOG
       FIELD tg-sc-dest         AS LOG
       FIELD tg-go-dest         AS LOG
       FIELD tg-df-dest         AS LOG
       FIELD ge-codigo-ini      AS INTEGER   FORMAT ">9"
       FIELD ge-codigo-fim      AS INTEGER   FORMAT ">9"
       FIELD fm-codigo-ini      AS CHARACTER FORMAT "x(8)"
       FIELD fm-codigo-fim      AS CHARACTER FORMAT "x(8)"
       FIELD clas-fiscal-ini    AS CHARACTER FORMAT "9999.99.99" /* ncm */
       FIELD clas-fiscal-fim    AS CHARACTER FORMAT "9999.99.99"
       FIELD cst-ini            AS INTEGER   FORMAT ">9"
       FIELD cst-fim            AS INTEGER   FORMAT ">9"
       FIELD com-subst-tribut   AS LOG         
       FIELD sem-subst-tribut   AS LOG
       FIELD forc-integ         AS LOG.

define temp-table tt-processo NO-UNDO
    FIELD it-codigo                     LIKE ITEM.it-codigo                /* 1-a  */
    FIELD desc-item                     LIKE ITEM.desc-item                /* 2-b  */
    FIELD ge-codigo                     LIKE ITEM.ge-codigo                /* 3-c  */
    FIELD codigo-ean                    LIKE int_ds_ean_item.codigo_ean    /* 4-d  */
    FIELD cod-estado-orig               LIKE item-uf.cod-estado-orig       /* 5-e  */
    FIELD estado                        LIKE item-uf.estado                /* 6-f  */
    FIELD cd-trib-icm                   LIKE Item.cd-trib-icm              /* 7-g  */
    FIELD aliquota-icm                  LIKE Icms-it-uf.aliquota-icm       /* 8-h  */
    FIELD red                           AS DEC                             /* 9-i  */
    FIELD cd-trib-icm-tre               LIKE Item.cd-trib-icm              /* 10-j */
    FIELD aliquota-icm-ale              LIKE Icms-it-uf.aliquota-icm       /* 11-k */
    FIELD rede                          AS DEC                             /* 12-l */
    FIELD cd-trib-icm-tri               LIKE ITEM.cd-trib-icm              /* 13-m */
    FIELD aliquota-icm-ali              LIKE icms-it-uf.aliquota-icm       /* 14-n */
    FIELD redi                          AS DEC                             /* 15-o */
    FIELD per-sub-tri-ste               LIKE Item-uf.per-sub-tri           /* 16-p */
    FIELD per-sub-tri-sti               LIKE item-uf.per-sub-tri           /* 17-q */
    FIELD val-icms-est-sub              LIKE item-uf.val-icms-est-sub      /* 18-r */
    FIELD per-red-sub                   LIKE item-uf.perc-red-sub          /* 19-s */
    FIELD rast                          AS DEC                             /* 20-t */
    FIELD rbest                         AS DEC                             /* 21-u */
    FIELD aliquota-ipi                  LIKE ITEM.aliquota-ipi             /* 22-v */
    FIELD observacao                    LIKE it-carac-tec.observacao       /* 23-w */
    FIELD class-fiscal                  LIKE ITEM.class-fiscal             /* 24-x */
    FIELD csta                          AS INT                             /* 25-y */
    FIELD ies                           AS INT                             /* 26-z */
    FIELD fm-codigo                     LIKE ITEM.fm-codigo                /* 27-aa */
    FIELD descricao                     LIKE familia.descricao             /* 28-ab */
    FIELD tributa-pis                   AS CHAR                            /* 29-ac */
    FIELD aliq-pis                      AS DEC                             /* 30-ad */
    FIELD tributa-cofins                AS CHAR                            /* 31-ae */
    FIELD aliq-cofins                   AS DEC                             /* 32-af */
    FIELD utiliza-pauta-fiscal          AS CHAR FORMAT "X(1)"              /* 33-ag */
    FIELD utiliza-mva-ajustada          AS CHAR FORMAT "X(1)"              /* 34-ah */
    FIELD valor-pauta-fiscal            AS DEC FORMAT "->>>,>>9.99"        /* 35-ai */
    FIELD valor-pmpf                    AS DEC FORMAT "->>>,>>9.99"        /* 35-aj */
    FIELD alterado                      AS LOGICAL
    FIELD tipo-reg                      AS LOGICAL FORMAT "Criado/Alterado"
    FIELD trans_tr_estadual             LIKE int_dp_item_fiscal.trans_tr_estadual         
    FIELD trans_tr_estadual_aliquota    LIKE int_dp_item_fiscal.trans_tr_estadual_aliquota
    FIELD trans_tr_estadual_reducao     LIKE int_dp_item_fiscal.trans_tr_estadual_reducao 
    FIELD trans_tr_interestadual        LIKE int_dp_item_fiscal.trans_tr_interestadual    
    FIELD trans_tr_inter_aliquota       LIKE int_dp_item_fiscal.trans_tr_inter_aliquota   
    FIELD trans_tr_inter_reducao        LIKE int_dp_item_fiscal.trans_tr_inter_reducao    
    FIELD tr_perda                      LIKE int_dp_item_fiscal.tr_perda                  
    FIELD tr_perda_aliquota             LIKE int_dp_item_fiscal.tr_perda_aliquota         
    FIELD cest                          LIKE int_dp_item_fiscal.cest //AS INTEGER FORMAT ">>,>>>,>9" 
    FIELD subs_trib_transf_inter        LIKE int_dp_item_fiscal.subs_trib_transf_inter
    FIELD cst-pis                       LIKE int_dp_item_fiscal.cst_pis
    FIELD cst-cofins                    LIKE int_dp_item_fiscal.cst_cofins
    FIELD aliq-int-uf-dest              AS DEC
    FIELD dif-aliq                      AS DEC
    FIELD part-icms-uf-orig             AS DEC
    FIELD part-icms-uf-dest             AS DEC
    INDEX id it-codigo estado cod-estado-orig
    INDEX est-trib
             cod-estado-orig
             cd-trib-icm
    INDEX est-orig
             cod-estado-orig
    INDEX ITEM
             it-codigo.
            
DEF BUFFER b-tt-processo FOR tt-processo.

DEFINE TEMP-TABLE tt-processo-aux LIKE tt-processo.

def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.
 
define buffer b-tt-digita for tt-digita.
DEFINE BUFFER b-item FOR ITEM.
 
DEF VAR l-alterou AS LOGICAL NO-UNDO.
DEF VAR de-aliquota-icm LIKE natur-oper.aliquota-icm NO-UNDO. 
DEF VAR de-perc-red-icm LIKE natur-oper.perc-red-icm NO-UNDO. 
DEF VAR i-cd-trib-icm   LIKE natur-oper.cd-trib-icm  NO-UNDO. 
DEF VAR de-per-icms-int LIKE unid-feder.per-icms-int NO-UNDO. 
DEF VAR de-per-icms-ext LIKE unid-feder.per-icms-ext NO-UNDO. 
def var c-natur         like ped-venda.nat-operacao  NO-UNDO.
def var c-nat-devol     like ped-venda.nat-operacao  NO-UNDO.
def var r-rowid         as rowid                     no-undo.
DEF VAR l-criou         AS LOGICAL                   NO-UNDO.

/* Transfer Definitions */

def temp-table tt-raw-digita NO-UNDO
field raw-digita      as raw.
 
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param. 
ASSIGN tt-param.forc-integ = YES.

IF v_cdn_empres_usuar = ""  THEN   v_cdn_empres_usuar = "1". 


FIND ems2mult.empresa no-lock where ems2mult.empresa.ep-codigo = v_cdn_empres_usuar no-error.
if not avail ems2mult.empresa THEN DO:
   return.
END.

 
def var h-acomp as handle no-undo.

{include/i-rpvar.i}
    
{include/i-rpcab.i}

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
 
assign c-programa     = "INT090RP"
       c-versao       = "2.00"
       c-revisao      = "000"
       c-empresa      = empresa.razao-social
       c-sistema      = "Especifico"
       c-titulo-relat = "Integra‡Æo Dados Fiscais Itens".
 
EMPTY TEMP-TABLE tt-processo.     
EMPTY TEMP-TABLE tt-processo-aux.
    
RUN pi-inicializar IN h-acomp (INPUT "Processando...").

RUN cria-tt-processo.

RUN atualiza-UF.

RUN atualiza-tt-processo.

RUN atualiza-DIFAL.

RUN cria-integracao.
    
/*{include/i-rpout.i}

view frame f-cabec.
view frame f-rodape.

FOR EACH tt-processo WHERE tt-processo.alterado = YES BREAK BY tt-processo.it-codigo QUERY-TUNING(NO-LOOKAHEAD):
    DISP tt-processo.it-codigo       COLUMN-LABEL "Item"       
         tt-processo.desc-item       COLUMN-LABEL "Descri‡Æo"  
         tt-processo.cod-estado-orig COLUMN-LABEL "UF Orig"     
         tt-processo.estado          COLUMN-LABEL "UF Dest" 
         tt-processo.tipo-reg        COLUMN-LABEL "Registro"   
         WITH WIDTH 640 NO-BOX STREAM-IO DOWN FRAME f-dados.
END.  */

run pi-finalizar in h-acomp.

{include/i-rpclo.i}

return "OK".
                                                                                                                                                                            
PROCEDURE atualiza-UF:

    FOR EACH tt-processo
        WHERE tt-processo.cod-estado-orig = "" :
    
        run pi-acompanhar IN h-acomp ("Item: " + string(tt-processo.it-codigo)).
    
        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "PR" THEN DO:
            FOR FIRST b-tt-processo WHERE
                      b-tt-processo.cod-estado-orig = "SP" AND
                      b-tt-processo.estado          = "PR" NO-LOCK:
            END.
            IF AVAIL b-tt-processo THEN DO:
               CREATE tt-processo-aux.
               BUFFER-COPY b-tt-processo TO tt-processo-aux.
               ASSIGN tt-processo-aux.cod-estado-orig = ""
                      tt-processo-aux.estado          = "PR".
               DELETE tt-processo.
               NEXT.
            END.
        END.
    
        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "SC" THEN DO:
            FOR FIRST b-tt-processo WHERE
                      b-tt-processo.cod-estado-orig = "PR" AND
                      b-tt-processo.estado          = "SC" NO-LOCK:
            END.
            IF AVAIL b-tt-processo THEN DO:
               CREATE tt-processo-aux.
               BUFFER-COPY b-tt-processo TO tt-processo-aux.
               ASSIGN tt-processo-aux.cod-estado-orig = ""
                      tt-processo-aux.estado          = "SC".
               DELETE tt-processo.
               NEXT.
            END.
        END.
    
        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "SP" THEN DO:
            FOR FIRST b-tt-processo WHERE
                      b-tt-processo.cod-estado-orig = "PR" AND
                      b-tt-processo.estado          = "SP" NO-LOCK:
            END.
            IF AVAIL b-tt-processo THEN DO:
               CREATE tt-processo-aux.
               BUFFER-COPY b-tt-processo TO tt-processo-aux.
               ASSIGN tt-processo-aux.cod-estado-orig = ""
                      tt-processo-aux.estado          = "SP".
               DELETE tt-processo.
               NEXT.
            END.
        END.
        
        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "GO" THEN DO:
            FOR FIRST b-tt-processo WHERE
                      b-tt-processo.cod-estado-orig = "PR" AND
                      b-tt-processo.estado          = "GO" NO-LOCK:
            END.
            IF AVAIL b-tt-processo THEN DO:
               CREATE tt-processo-aux.
               BUFFER-COPY b-tt-processo TO tt-processo-aux.
               ASSIGN tt-processo-aux.cod-estado-orig = ""
                      tt-processo-aux.estado          = "GO".
               DELETE tt-processo.
               NEXT.
            END.
        END.
        
        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "DF" THEN DO:
            FOR FIRST b-tt-processo WHERE
                      b-tt-processo.cod-estado-orig = "PR" AND
                      b-tt-processo.estado          = "DF" NO-LOCK:
            END.
            IF AVAIL b-tt-processo THEN DO:
               CREATE tt-processo-aux.
               BUFFER-COPY b-tt-processo TO tt-processo-aux.
               ASSIGN tt-processo-aux.cod-estado-orig = ""
                      tt-processo-aux.estado          = "DF".
               DELETE tt-processo.
               NEXT.
            END.
        END.         
        
        .MESSAGE "ATUALIZA UF 2 " SKIP
                "tt-processo.estado - " tt-processo.estado  SKIP
                "tt-processo.cod-estado-orig - " tt-processo.cod-estado-orig  SKIP
                "tt-processo.cd-trib-icm-tre - " tt-processo.cd-trib-icm-tre
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.          
    END.
        
    FOR EACH tt-processo-aux :
        CREATE tt-processo.
        BUFFER-COPY tt-processo-aux TO tt-processo.
    END.
        
    EMPTY TEMP-TABLE tt-processo-aux.

    FOR EACH tt-processo USE-INDEX est-trib WHERE
             tt-processo.cod-estado-orig = "" :   
             
        .MESSAGE "ATUALIZA UF 3" SKIP
                "tt-processo.estado - " tt-processo.estado  SKIP
                "tt-processo.cod-estado-orig - " tt-processo.cod-estado-orig  SKIP
                "tt-processo.cd-trib-icm-tre - " tt-processo.cd-trib-icm-tre
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.               
             
        IF tt-processo.estado = "PR" THEN DO:
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "PR" AND
                      b-tt-processo.cod-estado-orig = "SC" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "SC"
                     tt-processo-aux.estado          = "PR".
           END.
                      
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "PR" AND
                      b-tt-processo.cod-estado-orig = "SP" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "SP"
                     tt-processo-aux.estado          = "PR".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "PR" AND
                      b-tt-processo.cod-estado-orig = "GO" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "GO"
                     tt-processo-aux.estado          = "PR".
           END.   
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "PR" AND
                      b-tt-processo.cod-estado-orig = "DF" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "DF"
                     tt-processo-aux.estado          = "PR".
           END.           
           
           ASSIGN tt-processo.cod-estado-orig = "PR".
        END.

        IF tt-processo.estado = "SC" THEN DO:
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "SC" AND
                      b-tt-processo.cod-estado-orig = "PR" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "PR"
                     tt-processo-aux.estado          = "SC".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "SC" AND
                      b-tt-processo.cod-estado-orig = "SP" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "SP"
                     tt-processo-aux.estado          = "SC".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "SC" AND
                      b-tt-processo.cod-estado-orig = "GO" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "GO"
                     tt-processo-aux.estado          = "SC".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "SC" AND
                      b-tt-processo.cod-estado-orig = "DF" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "DF"
                     tt-processo-aux.estado          = "SC".
           END.           
           ASSIGN tt-processo.cod-estado-orig = "SC".
        END.
        
        IF tt-processo.estado = "SP" THEN DO:
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "SP" AND
                      b-tt-processo.cod-estado-orig = "PR" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "PR"
                     tt-processo-aux.estado          = "SP".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "SP" AND
                      b-tt-processo.cod-estado-orig = "SC" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "SC"
                     tt-processo-aux.estado          = "SP".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "SP" AND
                      b-tt-processo.cod-estado-orig = "GO" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "GO"
                     tt-processo-aux.estado          = "SP".
           END.   
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "SP" AND
                      b-tt-processo.cod-estado-orig = "DF" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "DF"
                     tt-processo-aux.estado          = "SP".
           END.           
           
           ASSIGN tt-processo.cod-estado-orig = "SP".
        END.
        IF tt-processo.estado = "GO" THEN DO:
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "GO" AND
                      b-tt-processo.cod-estado-orig = "PR" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "PR"
                     tt-processo-aux.estado          = "GO".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "GO" AND
                      b-tt-processo.cod-estado-orig = "SC" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "SC"
                     tt-processo-aux.estado          = "GO".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "GO" AND
                      b-tt-processo.cod-estado-orig = "SP" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "SP"
                     tt-processo-aux.estado          = "GO".
           END.   
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "GO" AND
                      b-tt-processo.cod-estado-orig = "DF" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "DF"
                     tt-processo-aux.estado          = "GO".
           END.           
           
           ASSIGN tt-processo.cod-estado-orig = "GO".
        END.
        IF tt-processo.estado = "DF" THEN DO:
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "DF" AND
                      b-tt-processo.cod-estado-orig = "PR" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "PR"
                     tt-processo-aux.estado          = "DF".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "DF" AND
                      b-tt-processo.cod-estado-orig = "SC" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "SC"
                     tt-processo-aux.estado          = "DF".
           END.
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "DF" AND
                      b-tt-processo.cod-estado-orig = "SP" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "SP"
                     tt-processo-aux.estado          = "DF".
           END.   
           FIND FIRST b-tt-processo WHERE
                      b-tt-processo.it-codigo       = tt-processo.it-codigo AND
                      b-tt-processo.estado          = "DF" AND
                      b-tt-processo.cod-estado-orig = "GO" NO-LOCK NO-ERROR.
           IF NOT AVAIL b-tt-processo THEN DO:
              CREATE tt-processo-aux.
              BUFFER-COPY tt-processo TO tt-processo-aux.
              ASSIGN tt-processo-aux.cod-estado-orig = "GO"
                     tt-processo-aux.estado          = "DF".
           END.           
           
           ASSIGN tt-processo.cod-estado-orig = "DF".
        END.    

    END.

    FOR EACH tt-processo-aux query-tuning(no-lookahead):
        CREATE tt-processo.
        BUFFER-COPY tt-processo-aux TO tt-processo.
    END.

END PROCEDURE.

PROCEDURE atualiza-tt-processo:


    DEFINE VARIABLE c-cest       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-cst-pis    AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cst-cofins AS INTEGER     NO-UNDO.

    
   
    FOR EACH tt-processo 
        BREAK BY tt-processo.it-codigo:
        
        IF FIRST-OF (tt-processo.it-codigo) THEN DO:
                                  //kml5
            FIND FIRST ITEM NO-LOCK
                WHERE ITEM.it-codigo = tt-processo.it-codigo NO-ERROR.
            IF tt-processo.tributa-pis = "S" THEN DO:
            
                ASSIGN tt-processo.cst-pis = 1
                       tt-processo.cst-cofins = 1.
            END.
            ELSE DO:
                ASSIGN tt-processo.cst-pis = 4
                       tt-processo.cst-cofins = 4.
            END.
                   
            RUN p-sit-tribut-relacto.
            ASSIGN c-cest       = tt-processo.cest   
                   c-cst-pis    = tt-processo.cst-pis
                   c-cst-cofins = tt-processo.cst-cofins.
            
        END.
        
        ASSIGN tt-processo.cest        = c-cest       
               tt-processo.cst-pis     = c-cst-pis   
               tt-processo.cst-cofins  = c-cst-cofins.

    
        run pi-acompanhar IN h-acomp ("Atualiza tt-processo - Item: " + string(tt-processo.it-codigo)).

        /************** Nacional ************/
        IF tt-processo.fm-codigo = "100" 
        OR tt-processo.fm-codigo = "105" 
        OR tt-processo.fm-codigo = "200"
        OR tt-processo.fm-codigo = "400"
        OR tt-processo.fm-codigo = "401"
        OR tt-processo.fm-codigo = "403"
        OR tt-processo.fm-codigo = "404"
        OR tt-processo.fm-codigo = "405"
        OR tt-processo.fm-codigo = "406"
        OR tt-processo.fm-codigo = "407"
        OR tt-processo.fm-codigo = "408"
        OR tt-processo.fm-codigo = "409"
        OR tt-processo.fm-codigo = "410"
        OR tt-processo.fm-codigo = "411"
        OR tt-processo.fm-codigo = "412"
        OR tt-processo.fm-codigo = "413" 
        /************* Importado ************/
        OR tt-processo.fm-codigo = "101" 
        OR tt-processo.fm-codigo = "201"
        OR tt-processo.fm-codigo = "300"
        OR tt-processo.fm-codigo = "301"
        OR tt-processo.fm-codigo = "302"
        OR tt-processo.fm-codigo = "303"
        OR tt-processo.fm-codigo = "304"
        OR tt-processo.fm-codigo = "305"
        OR tt-processo.fm-codigo = "306"
        OR tt-processo.fm-codigo = "307"
        OR tt-processo.fm-codigo = "308"
        OR tt-processo.fm-codigo = "309" THEN DO:

           IF tt-processo.cd-trib-icm = 1 THEN
              ASSIGN tt-processo.aliquota-icm-ali = tt-processo.ies. 
           IF tt-processo.cd-trib-icm <> 1 THEN
              ASSIGN tt-processo.aliquota-icm-ali = 0. 
        END.

        IF tt-processo.fm-codigo = "203" THEN DO: /* Cesta B sica */
           ASSIGN tt-processo.aliquota-icm-ali = tt-processo.ies
                  tt-processo.cd-trib-icm      = 2 
                  tt-processo.cd-trib-icm-tre  = 1 
                  tt-processo.aliquota-icm     = 0.
           FIND FIRST icms-it-uf WHERE 
                     icms-it-uf.it-codigo = tt-processo.it-codigo AND
                     icms-it-uf.estado    = tt-processo.estado  NO-LOCK NO-ERROR.
           IF AVAIL icms-it-uf THEN
              ASSIGN tt-processo.aliquota-icm-ale = icms-it-uf.aliquota-icm.
        END.

        FIND FIRST ITEM WHERE 
            ITEM.it-codigo = tt-processo.it-codigo NO-LOCK NO-ERROR.

        IF AVAIL ITEM THEN DO :
        
            // KML - Kleber Mazepa 29/01/2025 - Incluido na atualiza‡Æo da tt-processo a busca de pis/cofins
            
            IF SUBSTRING(item.char-2,52,1) = "1" THEN   /* campo origem aliquota Pis = 1-item, 2-Natureza */  
                 ASSIGN tt-processo.aliq-pis = dec(SUBSTRING(item.char-2,31,5)).             /* 30-ad */         
            ELSE ASSIGN tt-processo.aliq-pis = 0 .                                           /* 30-ad */

            IF SUBSTRING(item.char-2,53,1) = "1" THEN   /* campo origem aliquota cofins = 1-item, 2-Natureza */ 
                 ASSIGN tt-processo.aliq-cofins = dec(SUBSTRING(item.char-2,36,5)) .          /* 31-af */         
            ELSE ASSIGN tt-processo.aliq-cofins = 0 .                                         /* 31-af */      

            IF tt-processo.aliq-pis > 0 THEN
               ASSIGN tt-processo.tributa-pis = "S".
            ELSE 
               ASSIGN tt-processo.tributa-pis = "N".

            IF tt-processo.aliq-cofins > 0 THEN
               ASSIGN tt-processo.tributa-cofins = "S".
            ELSE 
               ASSIGN tt-processo.tributa-cofins = "N".          
        
           IF ITEM.fm-codigo = "102" OR
              ITEM.fm-codigo = "202" OR
              ITEM.fm-codigo = "402" THEN DO:
              
              
                      
               /* KML - Kleber Mazepa 29/01/2025 - NÆo alterar mais o dado, ajustar via esp002
                IF ITEM.cd-trib-icm <> 2 THEN DO:

                      FIND FIRST b-item EXCLUSIVE-LOCK
                          WHERE ROWID(b-item) = ROWID(ITEM) NO-ERROR.
                      IF AVAIL b-item THEN
                        ASSIGN b-item.cd-trib-icm = 2. /* Isento */ 
                      RELEASE b-item.
                END. */                                              

                ASSIGN tt-processo.cd-trib-icm       = 2                       /*  7-g */ 
                       tt-processo.cd-trib-icm-tre   = 2                       /* 10-j */            
                       tt-processo.cd-trib-icm-tri   = 2                       /* 13-m */  
                       tt-processo.aliquota-icm      = 0                       /* H */   
                       tt-processo.aliquota-icm-ale  = 0                       /* K */   
                       tt-processo.aliquota-icm-ali  = 0                       /* N */
                       tt-processo.rast              = 0.                      /* T */
                       
            END.
            ELSE DO:
                IF ITEM.fm-codigo >= "500" THEN DO:
                   
                   /* KML - Kleber Mazepa 29/01/2025 - NÆo alterar mais o dado, ajustar via esp002
                   IF ITEM.cd-trib-icm <> 3 THEN DO:
                        FIND FIRST b-item EXCLUSIVE-LOCK
                            WHERE ROWID(b-item) = ROWID(ITEM) NO-ERROR.
                        IF AVAIL b-item THEN
                            ASSIGN b-item.cd-trib-icm = 3. /* Outros */   
                        RELEASE b-item.                                   
                    END.  */                                                 

                    ASSIGN tt-processo.cd-trib-icm       = 3                    /*  7-g */
                           tt-processo.cd-trib-icm-tre   = 3                    /* 10-j */              
                           tt-processo.cd-trib-icm-tri   = 3                    /* 13-m */   
                           tt-processo.aliquota-icm      = 0                    /* H */
                           tt-processo.aliquota-icm-ale  = 0                    /* K */
                           tt-processo.aliquota-icm-ali  = 0                    /* N */
                           tt-processo.rast              = 0.                   /* T */
                END.
                ELSE DO:
                    /* KML - Kleber Mazepa 29/01/2025 - NÆo alterar mais o dado, ajustar via esp002
                     IF ITEM.cd-trib-icm <> 1 THEN DO:
                        FIND FIRST b-item EXCLUSIVE-LOCK
                            WHERE ROWID(b-item) = ROWID(ITEM) NO-ERROR.
                        IF AVAIL b-item THEN
                            ASSIGN b-item.cd-trib-icm = 1. /* Tributado */
                        RELEASE b-item.   
                     END. */
                END.
            END.
          /* FOR FIRST int_ds_ncm_produto WHERE 
                     int_ds_ncm_produto.ncm     = item.class-fiscal  AND
                     int_ds_ncm_produto.estado  = tt-processo.estado AND
                     int_ds_ncm_produto.produto = int(tt-processo.it-codigo) query-tuning(no-lookahead):
           END.
           IF AVAIL int_ds_ncm_produto THEN DO:
              ASSIGN tt-processo.utiliza-pauta-fiscal = int_ds_ncm_produto.utiliza_pauta_fiscal
                     tt-processo.utiliza-mva-ajustada = int_ds_ncm_produto.utiliza_mva_ajustada
                     tt-processo.valor-pauta-fiscal   = int_ds_ncm_produto.valor_pauta_fiscal.  
           END. */

           ASSIGN tt-processo.utiliza-pauta-fiscal = "N"
                    tt-processo.valor-pauta-fiscal   = 0. 

           FOR FIRST ems2dis.preco-item NO-LOCK
               WHERE preco-item.nr-tabpre   = string("PAUTA " + trim(tt-processo.estado))
                 AND preco-item.it-codigo   = trim(tt-processo.it-codigo)
                 AND preco-item.cod-refer   = ""
                 AND preco-item.situacao    = 1 /*ativo */
               BY preco-item.dt-inival DESC :
                    
                  ASSIGN tt-processo.utiliza-pauta-fiscal = "S"
                         tt-processo.utiliza-mva-ajustada = "N"
                         tt-processo.valor-pauta-fiscal   = preco-item.preco-venda. 
           END.
  
         
           ASSIGN tt-processo.valor-pmpf   = 0.
           
           IF tt-processo.estado = "SP" THEN
           DO: 
               FOR FIRST preco-item NO-LOCK
                   WHERE preco-item.nr-tabpre   = "PMPF"
                     AND preco-item.it-codigo   = tt-processo.it-codigo
                     AND preco-item.cod-refer   = ""
                     AND preco-item.situacao    = 1 /*ativo */
                   BY preco-item.dt-inival DESC : 
                   ASSIGN tt-processo.valor-pmpf   = preco-item.preco-venda.
               END.
           END.
           
           IF tt-processo.estado = "PR" THEN
           DO: 
               FOR FIRST preco-item NO-LOCK
                   WHERE preco-item.nr-tabpre   = "PMPF PR"
                     AND preco-item.it-codigo   = tt-processo.it-codigo
                     AND preco-item.cod-refer   = ""
                     AND preco-item.situacao    = 1 /*ativo */
                   BY preco-item.dt-inival DESC : 
                   ASSIGN tt-processo.valor-pmpf   = preco-item.preco-venda.
               END.
           END.           

           RELEASE b-ITEM.
        END.
        RELEASE b-ITEM.
        

        IF  tt-processo.cod-estado-orig = "PR" 
        AND tt-processo.estado          = "PR" THEN DO: 
            IF tt-processo.cd-trib-icm-tre = 1 THEN
               ASSIGN tt-processo.rede = tt-processo.rast
                      tt-processo.rast = 0.
            FIND FIRST item-uf  NO-LOCK 
                WHERE item-uf.it-codigo       = tt-processo.it-codigo 
                  AND item-uf.cod-estado-orig = "SP" 
                  AND item-uf.estado          = "PR" NO-ERROR.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.

        IF  tt-processo.cod-estado-orig = "SC" 
        AND tt-processo.estado          = "SC" THEN DO:
            FIND FIRST item-uf NO-LOCK where 
                  item-uf.it-codigo       = tt-processo.it-codigo AND
                  item-uf.cod-estado-orig = "PR"                  AND
                  item-uf.estado          = "SC" NO-ERROR.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.

        IF  tt-processo.cod-estado-orig = "SP" 
        AND tt-processo.estado          = "SP" THEN DO:
            FIND FIRST item-uf NO-LOCK where 
                  item-uf.it-codigo       = tt-processo.it-codigo AND
                  item-uf.cod-estado-orig = "PR"                  AND
                  item-uf.estado          = "SP" NO-ERROR.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.
        IF  tt-processo.cod-estado-orig = "GO" 
        AND tt-processo.estado          = "GO" THEN DO:
            FIND FIRST item-uf  NO-LOCK where 
                  item-uf.it-codigo       = tt-processo.it-codigo AND
                  item-uf.cod-estado-orig = "PR"                  AND
                  item-uf.estado          = "GO" NO-ERROR.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END. 
        IF  tt-processo.cod-estado-orig = "DF" 
        AND tt-processo.estado          = "DF" THEN DO:
            FIND FIRST item-uf  NO-LOCK where 
                  item-uf.it-codigo       = tt-processo.it-codigo AND
                  item-uf.cod-estado-orig = "PR"                  AND
                  item-uf.estado          = "DF" NO-ERROR.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.          

        IF tt-processo.estado = "SC" THEN DO:
        
            IF tt-processo.cd-trib-icm = 2 
            OR tt-processo.cd-trib-icm = 5 
            OR tt-processo.cd-trib-icm = 3 THEN // Mike: Acrescentado valida‡Æo de cd-trib-icm 3 (outros), chamado #0924-023201             
                ASSIGN tt-processo.aliquota-icm     = 0 
                       tt-processo.aliquota-icm-ale = 0 
                       tt-processo.rast             = 0.
            ELSE
                ASSIGN tt-processo.aliquota-icm     = 17
                       tt-processo.aliquota-icm-ale = 17
                       tt-processo.rast             = 0.
              
            IF tt-processo.cd-trib-icm = 1 THEN
                FIND FIRST ICMS-IT-UF 
                    WHERE ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO 
                      AND ICMS-IT-UF.ESTADO    = "SC" NO-LOCK NO-ERROR. //inclusÆo kml                     
            IF AVAIL icms-it-uf THEN DO:
                ASSIGN tt-processo.aliquota-icm     = Icms-it-uf.aliquota-icm       /* 8-h  */
                       tt-processo.aliquota-icm-ale = Icms-it-uf.aliquota-icm.      /* 11-k */         
                         
            END.
        END.

        /* campos novos - GAP 3 */

        ASSIGN de-aliquota-icm                        = 0
               de-perc-red-icm                        = 0
               i-cd-trib-icm                          = 0 
               de-per-icms-int                        = 0
               de-per-icms-ext                        = 0
               tt-processo.trans_tr_estadual          = "" 
               tt-processo.trans_tr_estadual_aliquota = 0  
               tt-processo.trans_tr_estadual_reducao  = 0  
               tt-processo.trans_tr_interestadual     = ""  
               tt-processo.trans_tr_inter_aliquota    = 0
               tt-processo.trans_tr_inter_reducao     = 0
               tt-processo.tr_perda                   = ""
               tt-processo.tr_perda_aliquota          = 0.

        /* determina natureza de operacao - TRANSF LJ */
        run intprg/int115a.p (input  "2",
                              input  tt-processo.estado,
                              input  tt-processo.cod-estado-orig,
                              input  "",  
                              input  9356,
                              input  tt-processo.class-fiscal,
			                  input  tt-processo.it-codigo,   /* item */
                              INPUT "" , //estabel
                              output c-natur,
                              output c-nat-devol,
                              output r-rowid).
            
        FIND FIRST natur-oper WHERE 
                  natur-oper.nat-operacao = c-natur NO-LOCK  NO-ERROR.
        IF AVAIL natur-oper THEN DO:
           ASSIGN de-aliquota-icm                    = natur-oper.aliquota-icm   
                  de-perc-red-icm                    = natur-oper.perc-red-icm //momento da altera‡Æo  
                  i-cd-trib-icm                      = natur-oper.cd-trib-icm
                  tt-processo.subs_trib_transf_inter = IF natur-oper.subs-trib = YES THEN "S" ELSE "N".
           IF natur-oper.subs-trib = YES then 
              ASSIGN i-cd-trib-icm = 5.
        END.

        FIND FIRST unid-feder WHERE
                  unid-feder.pais   = "Brasil" AND
                  unid-feder.estado = tt-processo.cod-estado-orig NO-LOCK  NO-ERROR.
                  
        IF AVAIL unid-feder THEN DO:
           ASSIGN de-per-icms-int = unid-feder.per-icms-int  
                  de-per-icms-ext = unid-feder.per-icms-ext.  
        END.

        IF AVAIL ITEM THEN DO:
           IF tt-processo.estado = tt-processo.cod-estado-orig THEN DO:
              if tt-processo.cd-trib-icm = 5 then do: 
                  ASSIGN tt-processo.trans_tr_estadual          = string(tt-processo.cd-trib-icm)
                         tt-processo.trans_tr_estadual_aliquota = tt-processo.aliquota-icm
                         tt-processo.trans_tr_estadual_reducao  = tt-processo.red.
              end.
              else do:
                  ASSIGN tt-processo.trans_tr_estadual          = string(i-cd-trib-icm)
                         tt-processo.trans_tr_estadual_aliquota = IF item.codigo-orig = 0 THEN de-per-icms-int ELSE 4  // KML - Se for importado sempre sera 4%
                         tt-processo.trans_tr_estadual_reducao  = de-perc-red-icm. //Leitura
              end.
           END.
           ELSE DO:
              ASSIGN tt-processo.trans_tr_interestadual     = string(i-cd-trib-icm)
                     tt-processo.trans_tr_inter_aliquota    = IF item.codigo-orig = 0 THEN de-per-icms-ext ELSE 4 // KML - Se for importado sempre sera 4%
                     tt-processo.trans_tr_inter_reducao     = de-perc-red-icm. // terceira Leitura
           END.
        END.

        ASSIGN de-aliquota-icm = 0
               de-perc-red-icm = 0
               i-cd-trib-icm   = 0 
               de-per-icms-int = 0
               de-per-icms-ext = 0.

        /* determina natureza de operacao - RETIRADA */
        run intprg/int115a.p (input  "33",
                              input  tt-processo.estado,
                              input  tt-processo.cod-estado-orig,
                              input  "",  
                              input  9356,
                              input  tt-processo.class-fiscal,
			                  INPUT  tt-processo.it-codigo , /* item */
                              INPUT "", //estabel
                              output c-natur,
                              output c-nat-devol,
                              output r-rowid).
        
        FIND FIRST natur-oper WHERE 
                  natur-oper.nat-operacao = c-natur NO-LOCK  NO-ERROR.
        IF AVAIL natur-oper THEN DO:
           ASSIGN de-aliquota-icm = natur-oper.aliquota-icm   
                  i-cd-trib-icm   = natur-oper.cd-trib-icm.
        END.

        FIND FIRST unid-feder WHERE
                  unid-feder.pais   = "Brasil" AND
                  unid-feder.estado = tt-processo.cod-estado-orig NO-LOCK  NO-ERROR.
        IF AVAIL unid-feder THEN DO:
           ASSIGN de-per-icms-int = unid-feder.per-icms-int. 
        END.

        IF AVAIL ITEM THEN DO:
           ASSIGN tt-processo.tr_perda          = string(i-cd-trib-icm)
                  tt-processo.tr_perda_aliquota = IF item.codigo-orig = 0 THEN de-per-icms-int ELSE de-aliquota-icm.
        END.
        

        IF (tt-processo.estado = "PR" AND tt-processo.cod-estado-orig = "PR")
        OR (tt-processo.estado = "PR" AND tt-processo.cod-estado-orig = "") THEN
           ASSIGN tt-processo.trans_tr_estadual_aliquota = 19.5
                  tt-processo.tr_perda_aliquota          = 19.5.

        IF (tt-processo.estado = "SP" AND tt-processo.cod-estado-orig = "SP")
        OR (tt-processo.estado = "SP" AND tt-processo.cod-estado-orig = "") THEN
            ASSIGN tt-processo.trans_tr_estadual_aliquota = 18
                   tt-processo.tr_perda_aliquota          = 18.

        IF (tt-processo.estado = "SC" AND tt-processo.cod-estado-orig = "SC")
        OR (tt-processo.estado = "SC" AND tt-processo.cod-estado-orig = "") THEN
            ASSIGN tt-processo.trans_tr_estadual_aliquota = 17
                   tt-processo.tr_perda_aliquota          = 17.

        IF (tt-processo.estado = "GO" AND tt-processo.cod-estado-orig = "GO")
        OR (tt-processo.estado = "GO" AND tt-processo.cod-estado-orig = "") THEN
            ASSIGN tt-processo.trans_tr_estadual_aliquota = 19
                   tt-processo.tr_perda_aliquota          = 19.
                   
        IF (tt-processo.estado = "DF" AND tt-processo.cod-estado-orig = "DF")
        OR (tt-processo.estado = "DF" AND tt-processo.cod-estado-orig = "") THEN
            ASSIGN tt-processo.trans_tr_estadual_aliquota = 20
                   tt-processo.tr_perda_aliquota          = 20.                   

        IF tt-processo.cod-estado-orig = "" THEN DO:
           IF tt-processo.trans_tr_estadual = "" THEN 
              ASSIGN tt-processo.trans_tr_estadual = string(tt-processo.cd-trib-icm-tre).
         
           IF tt-processo.trans_tr_estadual_aliquota = 0 THEN 
              ASSIGN tt-processo.trans_tr_estadual_aliquota = tt-processo.aliquota-icm-ale.

           IF tt-processo.estado = "PR" THEN DO:         
              IF tt-processo.cd-trib-icm-tre = 1 THEN
                 ASSIGN tt-processo.rede = tt-processo.rast.
           END.

           FIND FIRST unid-feder WHERE
                      unid-feder.pais   = "Brasil" AND
                      unid-feder.estado = tt-processo.estado NO-LOCK NO-ERROR.
           IF AVAIL unid-feder THEN DO:
              ASSIGN tt-processo.trans_tr_inter_aliquota = unid-feder.per-icms-ext.  
           END.
        END.
        
        IF SUBSTRING(item.char-2,52,1) = "1" THEN   /* campo origem aliquota Pis = 1-item, 2-Natureza */  
            ASSIGN tt-processo.aliq-pis = dec(SUBSTRING(item.char-2,31,5)).             /* 30-ad */         
        ELSE ASSIGN tt-processo.aliq-pis = 0 .                                           /* 30-ad */
          
        IF SUBSTRING(item.char-2,53,1) = "1" THEN   /* campo origem aliquota cofins = 1-item, 2-Natureza */ 
            ASSIGN tt-processo.aliq-cofins = dec(SUBSTRING(item.char-2,36,5)) .          /* 31-ae */         
        ELSE ASSIGN tt-processo.aliq-cofins = 0 .                                       /* 31-ae */      
                                                   
        IF tt-processo.aliq-pis > 0 THEN
            ASSIGN tt-processo.tributa-pis = "S".
        else 
            ASSIGN tt-processo.tributa-pis = "N".

        IF tt-processo.aliq-cofins > 0 THEN
            ASSIGN tt-processo.tributa-cofins = "S".
        ELSE 
            ASSIGN tt-processo.tributa-cofins = "N".
     
 
    END.

                                                                                      
END PROCEDURE.    

PROCEDURE p-sit-tribut-relacto:

    DEFINE VARIABLE l-sit-tribut    AS LOGICAL     NO-UNDO.
    ASSIGN l-sit-tribut = NO.
                                                                            
    IF AVAIL ITEM THEN DO:
    
        FOR LAST sit-tribut-relacto USE-INDEX sttrbtrl-item WHERE 
                  sit-tribut-relacto.cdn-tribut       = 11 AND 
                  sit-tribut-relacto.idi-tip-docto    = 1   AND
                  sit-tribut-relacto.cod-estab        = "*" AND
                  /*sit-tribut-relacto.cod-nat-operac   =  */
                  sit-tribut-relacto.cod-ncm          = ITEM.class-fiscal AND
                  sit-tribut-relacto.cod-item         = ITEM.it-codigo NO-LOCK:
            
            ASSIGN l-sit-tribut = YES.
            assign tt-processo.cest = string(sit-tribut-relacto.cdn-sit-tribut, "9999999").
                  
        END.          
       
        IF l-sit-tribut = NO THEN DO:
        
            FOR LAST sit-tribut-relacto NO-LOCK USE-INDEX sttrbtrl-ncm  WHERE 
                      sit-tribut-relacto.cdn-tribut       = 11 and
                      sit-tribut-relacto.cod-estab     = "*" and
                      sit-tribut-relacto.cod-item      = "*" AND
                      sit-tribut-relacto.cod-ncm       = ITEM.class-fiscal and
                      sit-tribut-relacto.idi-tip-docto = 1:
                      
                assign tt-processo.cest = string(sit-tribut-relacto.cdn-sit-tribut, "9999999").
                
            END.   
        END. 
        
        ASSIGN l-sit-tribut = NO.
        
        FOR LAST sit-tribut-relacto USE-INDEX sttrbtrl-item WHERE 
                  sit-tribut-relacto.cdn-tribut       = 2 AND 
                  sit-tribut-relacto.idi-tip-docto    = 2   AND
                  sit-tribut-relacto.cod-estab        = "*" AND
                  /*sit-tribut-relacto.cod-nat-operac   =  */
                  sit-tribut-relacto.cod-ncm          = ITEM.class-fiscal AND
                  sit-tribut-relacto.cod-item         = ITEM.it-codigo NO-LOCK:
            
            ASSIGN l-sit-tribut = YES.
            assign tt-processo.cst-pis = sit-tribut-relacto.cdn-sit-tribut.
                  
        END.          
       
        IF l-sit-tribut = NO THEN DO:
        
            FOR LAST sit-tribut-relacto NO-LOCK USE-INDEX sttrbtrl-ncm  WHERE 
                      sit-tribut-relacto.cdn-tribut       = 2 and
                      sit-tribut-relacto.cod-estab     = "*" and
                      sit-tribut-relacto.cod-item      = "*" AND
                      sit-tribut-relacto.cod-ncm       = ITEM.class-fiscal and
                      sit-tribut-relacto.idi-tip-docto = 2:
                      
                assign tt-processo.cst-pis = sit-tribut-relacto.cdn-sit-tribut.
                
            END.   
        END.   
        
        FOR LAST sit-tribut-relacto USE-INDEX sttrbtrl-item WHERE 
                  sit-tribut-relacto.cdn-tribut       = 3 AND 
                  sit-tribut-relacto.idi-tip-docto    = 1   AND
                  sit-tribut-relacto.cod-estab        = "*" AND
                  /*sit-tribut-relacto.cod-nat-operac   =  */
                  sit-tribut-relacto.cod-ncm          = ITEM.class-fiscal AND
                  sit-tribut-relacto.cod-item         = ITEM.it-codigo NO-LOCK:
            
            ASSIGN l-sit-tribut = YES.
            ASSIGN tt-processo.cst-cofins = sit-tribut-relacto.cdn-sit-tribut.
                  
        END.          
       
        IF l-sit-tribut = NO THEN DO:
        
            FOR LAST sit-tribut-relacto NO-LOCK USE-INDEX sttrbtrl-ncm  WHERE 
                      sit-tribut-relacto.cdn-tribut       = 3 and
                      sit-tribut-relacto.cod-estab     = "*" and
                      sit-tribut-relacto.cod-item      = "*" AND
                      sit-tribut-relacto.cod-ncm       = ITEM.class-fiscal and
                      sit-tribut-relacto.idi-tip-docto = 2:
                      
                ASSIGN tt-processo.cst-cofins = sit-tribut-relacto.cdn-sit-tribut.
                
            END.   
        END.         
          
    END.
    
END. 
                                                                                      
PROCEDURE atualiza-DIFAL:
    
   FOR EACH tt-processo :
       ASSIGN tt-processo.aliq-int-uf-dest  = 0
              tt-processo.dif-aliq          = 0
              tt-processo.part-icms-uf-orig = 0
              tt-processo.part-icms-uf-dest = 0.
   END.

   FOR EACH tt-processo USE-INDEX est-orig WHERE
            tt-processo.cod-estado-orig = "PR" :
            
       IF tt-processo.estado = "SC" THEN DO:
          ASSIGN tt-processo.aliq-int-uf-dest  = 17
                 tt-processo.dif-aliq          = 5
                 tt-processo.part-icms-uf-orig = 1
                 tt-processo.part-icms-uf-dest = 4.
       END.
       IF tt-processo.estado = "SP" THEN DO:
          ASSIGN tt-processo.aliq-int-uf-dest  = 18
                 tt-processo.dif-aliq          = 6
                 tt-processo.part-icms-uf-orig = 1.2
                 tt-processo.part-icms-uf-dest = 4.8.
       END.
       IF tt-processo.estado = "GO" THEN DO:          // KML - arrumar DIFAL e PARTILHA aqui...
          ASSIGN tt-processo.aliq-int-uf-dest  = 19
                 tt-processo.dif-aliq          = 7
                 tt-processo.part-icms-uf-orig = 1.4
                 tt-processo.part-icms-uf-dest = 5.6.
       END.
       IF tt-processo.estado = "DF" THEN DO:
          ASSIGN tt-processo.aliq-int-uf-dest  = 20
                 tt-processo.dif-aliq          = 8
                 tt-processo.part-icms-uf-orig = 1.6
                 tt-processo.part-icms-uf-dest = 6.4.
       END.       
   END.

END PROCEDURE.

/*********************************************************************************************************************************************************************************************/                                                                                      
PROCEDURE cria-tt-processo: 

    FOR EACH ITEM 
        WHERE ITEM.it-codigo      >= TT-PARAM.it-codigo-ini   AND 
             ITEM.it-codigo      <= TT-PARAM.it-codigo-fim   AND
             ITEM.ge-codigo      >= tt-param.ge-codigo-ini   AND
             ITEM.ge-codigo      <= tt-param.ge-codigo-fim   AND
             ITEM.fm-codigo      >= tt-param.fm-codigo-ini   AND
             ITEM.fm-codigo      <= tt-param.fm-codigo-fim   and
             item.class-fiscal   >= tt-param.clas-fiscal-ini AND
             item.class-fiscal   <= tt-param.clas-fiscal-fim AND 
             item.codigo-orig    >= tt-param.cst-ini         AND
             item.codigo-orig    <= tt-param.cst-fim         AND 
             item.cod-obsoleto   < 4 /* Totalmente Obsoleto */ AND 
             item.fm-codigo      < "900" USE-INDEX codigo NO-LOCK:

        run pi-acompanhar IN h-acomp ("Cria tt-processo - Item: " + string(ITEM.it-codigo)).

        ASSIGN l-primeiro = YES.  
        
        .MESSAGE "1" SKIP
                "item - " ITEM.it-codigo 
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        /* INICIO ITEM-UF ******************************************************************************************************************************************************************/
        for each item-uf  NO-LOCK where 
                 ITEM-UF.IT-CODIGO        = ITEM.IT-CODIGO              AND
                 item-uf.cod-estab       >= TT-PARAM.cod-estab-ini      AND 
                 item-uf.cod-estab       <= TT-PARAM.cod-estab-fim      AND 
                 ITEM-UF.ESTADO          <> ""                          AND
                 ITEM-UF.COD-ESTADO-ORIG <> ""                          AND
                 ( ( tt-param.tg-pr-dest = YES and item-uf.estado  = "PR" ) OR
                   ( tt-param.tg-sp-dest = YES and item-uf.estado  = "SP" ) OR
                   ( tt-param.tg-sc-dest = YES and item-uf.estado  = "SC" ) OR
                   ( tt-param.tg-go-dest = YES and item-uf.estado  = "GO" ) OR
                   ( tt-param.tg-df-dest = YES and item-uf.estado  = "DF" )) AND
                 ( ( tt-param.tg-pr      = YES and item-uf.cod-estado-orig  = "PR" ) OR
                   ( tt-param.tg-sp      = YES and item-uf.cod-estado-orig  = "SP" ) OR
                   ( tt-param.tg-sc      = YES and item-uf.cod-estado-orig  = "SC" ) OR
                   ( tt-param.tg-go      = YES and item-uf.cod-estado-orig  = "GO" ) OR
                   ( tt-param.tg-df      = YES and item-uf.cod-estado-orig  = "DF" ))  USE-INDEX ch-item-uf :               

           RUN pi-grava-item (INPUT NO).

           FIND FIRST unid-feder WHERE 
                      unid-feder.pais   = item-uf.pais AND
                      unid-feder.estado = item-uf.estado NO-LOCK NO-ERROR.                          

           ASSIGN tt-processo.cod-estado-orig = item-uf.cod-estado-orig  /* 5-e */
                  tt-processo.estado          = item-uf.estado.          /* 6-f */
                   
                                                
           IF ITEM.CD-TRIB-ICM = 1 THEN  
              ASSIGN tt-processo.aliquota-icm     = 0   /* 8-h  */   /* CFE MICHEL CODIGO TRIBUTACAO = 5 (CD0904A ) MOSTRAR FIXO 0 INDEPENDENTE DO ESTADO */     
                     tt-processo.aliquota-icm-ale = 0.  /* 11-k */   /* CFE MICHEL CODIGO TRIBUTACAO = 5 (CD0904A ) MOSTRAR FIXO 0 INDEPENDENTE DO ESTADO */     
              
           ASSIGN tt-processo.cd-trib-icm     = ITEM.cd-trib-icm         /* 7-g  */ 
                  tt-processo.cd-trib-icm-tre = ITEM.cd-trib-icm         /* 10-j */  
                  tt-processo.cd-trib-icm-tri = ITEM.cd-trib-icm.        /* 13-m */                  

           IF tt-param.com-subst-tribut = YES THEN DO:            
              IF AVAIL UNID-FEDER AND unid-feder.ind-uf-subs = YES THEN DO: 
    
                  IF item-uf.per-sub-tri    > 0  THEN DO:
                  
                      ASSIGN tt-processo.cd-trib-icm     = 5         /* 7-g  */     /*  fixo 5 */                      
                             tt-processo.cd-trib-icm-tre = 5         /* 10-j */     /*  fixo 5 */
                             tt-processo.cd-trib-icm-tri = 5.        /* 13-m */     /*  Fixo 5 */  

                     IF item-uf.estado = item-uf.cod-estado-orig THEN
                        ASSIGN tt-processo.per-sub-tri-ste = ITEM-uf.per-sub-tri.          /* 16-p */ 
                     ELSE DO:

                         FOR FIRST b-item-uf FIELDS (  it-codigo cod-estab per-sub-tri ) NO-LOCK where 
                                   b-ITEM-UF.IT-CODIGO        = ITEM.IT-CODIGO              AND
                                   b-item-uf.cod-estab       >= tt-param.cod-estab-ini      AND 
                                   b-item-uf.cod-estab       <= tt-param.cod-estab-fim      AND 
                                   b-ITEM-UF.ESTADO           = item-uf.estado              AND   /* estado destino igual, estado origem diferente */
                                   b-ITEM-UF.COD-ESTADO-ORIG  = item-uf.estado              :

                              ASSIGN tt-processo.per-sub-tri-ste = B-item-uf.per-sub-tri.   /* 16-p */ 
                              
                         END.
                     END.

                     FOR FIRST b-item-uf FIELDS (it-codigo cod-estab per-sub-tri ) NO-LOCK where 
                               b-ITEM-UF.IT-CODIGO        = ITEM.IT-CODIGO              AND
                               b-item-uf.cod-estab       >= tt-param.cod-estab-ini      AND 
                               b-item-uf.cod-estab       <= tt-param.cod-estab-fim      AND 
                               b-ITEM-UF.ESTADO           = item-uf.estado              AND   /* estado destino igual, estado origem diferente */
                               b-ITEM-UF.COD-ESTADO-ORIG /*<>*/ = item-uf.cod-estado-orig :

                           ASSIGN tt-processo.per-sub-tri-sti = b-item-uf.per-sub-tri. /* 17-q */
                             
                     END.
                  END.

              END.
           END.

            .MESSAGE "4" SKIP
                    "item - " ITEM.it-codigo SKIP
                    "tt-processo.estado - " tt-processo.estado  SKIP
                    "tt-processo.cod-estado-orig - " tt-processo.cod-estado-orig  SKIP
                    "tt-processo.cd-trib-icm-tre - " tt-processo.cd-trib-icm-tre
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.  
                
                
           ASSIGN tt-processo.val-icms-est-sub  = item-uf.dec-1         /* 18-r */ //POssivel altera‡Æo
                  tt-processo.per-red-sub       = item-uf.perc-red-sub  /* 19-s */  
                  tt-processo.rast              = 0                     /* 20-t */              
                  tt-processo.rbest             = 0.                    /* 21-u */
         
          IF item-uf.perc-red-sub /* 19-s */ <>  0 THEN DO: 
             
               IF ITEM-UF.ESTADO          = "PR" AND
                  ITEM-UF.COD-ESTADO-ORIG = "PR" THEN DO:
    
                  IF      item-uf.dec-1      = 19.5 THEN ASSIGN tt-processo.rbest = 38.46.   /* 21-u */
                  ELSE IF item-uf.dec-1      = 25 THEN ASSIGN tt-processo.rbest = 52.      /* 21-u */ 
                                
    
               END.


           END.
           ELSE DO:

               IF ITEM-UF.ESTADO          = "PR" AND
                  ITEM-UF.COD-ESTADO-ORIG = "PR" THEN DO:
    
                  IF      item-uf.dec-1      = 19.5 THEN ASSIGN tt-processo.rast = 38.46.   /* 20-t */
                  ELSE IF item-uf.dec-1      = 25 THEN ASSIGN tt-processo.rast = 52.      /* 20-t */                             
    
               END.

           END.

         /*  ASSIGN l-primeiro = NO.  */                                                              
        
        END.  
        /* FINAL ITEM-UF **********************************************************************************************************************************************************************/

        
        IF L-PRIMEIRO = YES THEN DO: /* NAO ENCONTROU REGISTRO DO ITEM CADASTRADO NO CD0904A - ITEM-UF */ /* PRECISAMOS DUPLICAR O REGISTRO CASO TENHA SIDO FLEGADO MAIS DE UM ESTADO DESTINO */

           
           RUN pi-grava-item (INPUT YES ) . 
           
           .MESSAGE "antes repete" SKIP AVAIL tt-processo
               VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        /* KML - Kleber Mazepa - 29/01/2025 retirado filtro de estados */  
        /*
           IF tt-param.tg-pr-dest      = YES AND
              tt-param.tg-sp-dest      = NO  AND
              tt-param.tg-sc-dest      = NO  AND
              tt-param.tg-go-dest      = NO  AND
              tt-param.tg-df-dest      = NO THEN ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

           ELSE IF tt-param.tg-pr-dest = NO  AND
                   tt-param.tg-sp-dest = YES AND 
                   tt-param.tg-sc-dest = NO  AND
                   tt-param.tg-go-dest = NO  AND
                   tt-param.tg-df-dest = NO THEN ASSIGN tt-processo.estado = "SP". /*  6- uf estado destino */

           ELSE IF tt-param.tg-pr-dest = NO  AND
                   tt-param.tg-sp-dest = NO  AND 
                   tt-param.tg-sc-dest = YES AND
                   tt-param.tg-go-dest = NO  AND
                   tt-param.tg-df-dest = NO THEN ASSIGN tt-processo.estado = "SC". /*  6- uf estado destino */
                   
           ELSE IF tt-param.tg-pr-dest = NO  AND
                   tt-param.tg-sp-dest = NO  AND 
                   tt-param.tg-sc-dest = NO  AND
                   tt-param.tg-go-dest = YES  AND
                   tt-param.tg-df-dest = NO THEN ASSIGN tt-processo.estado = "GO". /*  6- uf estado destino */
                   
           ELSE IF tt-param.tg-pr-dest = NO  AND
                   tt-param.tg-sp-dest = NO  AND 
                   tt-param.tg-sc-dest = NO  AND
                   tt-param.tg-go-dest = NO  AND
                   tt-param.tg-df-dest = YES THEN ASSIGN tt-processo.estado = "DF". /*  6- uf estado destino */  
                   
           ELSE IF tt-param.tg-pr-dest = YES AND
                   tt-param.tg-sp-dest = YES AND 
                   tt-param.tg-sc-dest = NO  AND
                   tt-param.tg-go-dest = NO  AND
                   tt-param.tg-df-dest = NO  THEN DO:
                   
                   .MESSAGE "1"
                       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

               ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "SP" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  

           END. */
           IF tt-param.tg-pr-dest = YES THEN DO:
           
                
                   .MESSAGE "2"
                       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.           

              // ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               IF tt-param.tg-sc-dest = YES THEN
                    RUN pi-repete-item( INPUT "SC" , INPUT "PR"  ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-sp-dest = YES THEN
                    RUN pi-repete-item( INPUT "SP" , INPUT "PR"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-go-dest = YES THEN
                    RUN pi-repete-item( INPUT "GO" , INPUT "PR"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-df-dest = YES THEN
                    RUN pi-repete-item( INPUT "DF" , INPUT "PR"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
                 IF tt-param.tg-pr-dest = YES THEN
                    RUN pi-repete-item( INPUT "PR" , INPUT "PR"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
                      
           END. 
           IF tt-param.tg-sc-dest = YES THEN DO:
                                    
              // ASSIGN tt-processo.estado = "SC". /*  6- uf estado destino */

               IF tt-param.tg-pr-dest = YES THEN
                    RUN pi-repete-item( INPUT "PR" , INPUT "SC"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-sp-dest = YES THEN
                    RUN pi-repete-item( INPUT "SP" , INPUT "SC"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-go-dest = YES THEN
                    RUN pi-repete-item( INPUT "GO" , INPUT "SC"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-df-dest = YES THEN
                    RUN pi-repete-item( INPUT "DF" , INPUT "SC"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-sc-dest = YES THEN
                    RUN pi-repete-item( INPUT "SC" , INPUT "SC"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
                  
            
           END.   
           IF tt-param.tg-sp-dest = YES THEN DO:
                     

              // ASSIGN tt-processo.estado = "SP". /*  6- uf estado destino */

               IF tt-param.tg-sc-dest = YES THEN
                    RUN pi-repete-item( INPUT "SC", INPUT "SP" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-pr-dest = YES THEN
                    RUN pi-repete-item( INPUT "PR" , INPUT "SP"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-go-dest = YES THEN
                    RUN pi-repete-item( INPUT "GO" , INPUT "SP"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-df-dest = YES THEN
                    RUN pi-repete-item( INPUT "DF" , INPUT "SP"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-sp-dest = YES THEN
                    RUN pi-repete-item( INPUT "SP" , INPUT "SP"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
                          
           END.
           IF tt-param.tg-go-dest = YES THEN DO:
                    

               //ASSIGN tt-processo.estado = "GO". /*  6- uf estado destino */

               IF tt-param.tg-sc-dest = YES THEN
                    RUN pi-repete-item( INPUT "SC" , INPUT "GO"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-sp-dest = YES THEN
                    RUN pi-repete-item( INPUT "SP" , INPUT "GO"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-pr-dest = YES THEN
                    RUN pi-repete-item( INPUT "PR" , INPUT "GO"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-df-dest = YES THEN
                    RUN pi-repete-item( INPUT "DF" , INPUT "GO"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
                IF tt-param.tg-go-dest = YES THEN
                    RUN pi-repete-item( INPUT "GO" , INPUT "GO"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
                    
           END. 
           IF tt-param.tg-df-dest = YES THEN DO:              

           //    ASSIGN tt-processo.estado = "DF". /*  6- uf estado destino */

               IF tt-param.tg-sc-dest = YES THEN
                    RUN pi-repete-item( INPUT "SC" , INPUT "DF"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-sp-dest = YES THEN
                    RUN pi-repete-item( INPUT "SP" , INPUT "DF"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-pr-dest = YES THEN
                    RUN pi-repete-item( INPUT "PR" , INPUT "DF"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-go-dest = YES THEN
                    RUN pi-repete-item( INPUT "GO" , INPUT "DF"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               IF tt-param.tg-df-dest = YES THEN
                    RUN pi-repete-item( INPUT "DF" , INPUT "DF"). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
                        
           END.  
                    
        END. 
        
        /*  KML - Kleber Mazepa - comentado pois estava impactando a performance e erro no campo ies preenchido conforme tabela do estado
        //Lohan KML bloco de altera‡Æo ICMS DIFERIM 13/12/2024
               
        FOR EACH tt-processo:
            
            FIND FIRST unid-feder WHERE 
                       unid-feder.pais      = "BRASIL" AND
                       unid-feder.estado    = tt-processo.estado NO-LOCK NO-ERROR.
            IF AVAIL UNID-FEDER THEN DO:
           
                ASSIGN tt-processo.ies = unid-feder.per-icms-ext.
            END.
            
           IF ITEM.codigo-orig <> 0 AND        
              ITEM.codigo-orig <> 4 AND
              ITEM.codigo-orig <> 5 THEN DO:
              
                ASSIGN tt-processo.ies = 4.
                
           END.
           
           IF ITEM.FM-CODIGO =  "101" OR
              ITEM.FM-CODIGO =  "201" OR
              ITEM.FM-CODIGO >= "300" AND
              ITEM.FM-CODIGO <= "309" THEN DO:
              
              
                ASSIGN tt-processo.ies = 4.
                
           END.
                          

          /*FIND FIRST diferim-parcial-icms NO-LOCK
               WHERE diferim-parcial-icms.cod-item = ITEM.it-codigo
               AND   diferim-parcial-icms.cod-estado = tt-processo.estado NO-ERROR.
                
            IF AVAIL diferim-parcial-icms THEN DO:
                   
                ASSIGN tt-processo.rast = diferim-parcial-icms.val-perc-icms-diferim.
                
            END. */
           
        END. */

    END.
    
    
    

END PROCEDURE.                                                                        

PROCEDURE pi-repete-item:  /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a = 5 - item-uf , ou seja 1,2,3,4 */  



    DEF INPUT PARAM p-estado        AS CHAR NO-UNDO.
    DEF INPUT PARAM p-estado-origem AS CHAR NO-UNDO.
    
    find first unid-feder 
       where unid-feder.pais = "BRASIL"
         and unid-feder.estado = p-estado-origem no-error.    
    
    FIND FIRST tt-processo NO-LOCK
        WHERE tt-processo.it-codigo     = ITEM.it-codigo
          AND tt-processo.estado        = p-estado
          AND tt-processo.COD-ESTADO-ORIG = p-estado-origem NO-ERROR.
    IF NOT AVAIL tt-processo THEN
    DO:
    
        CREATE tt-processo.
        ASSIGN tt-processo.it-codigo   = ITEM.it-codigo                  /* 1-a  */ 
               tt-processo.desc-item   = ITEM.desc-item                  /* 2-b  */  
               tt-processo.ge-codigo   = ITEM.ge-codigo                  /* 3-c  */            
               tt-processo.alterado    = NO
               tt-processo.tipo-reg    = NO.

        FIND FIRST int_ds_ean_item WHERE
                   int_ds_ean_item.it_codigo = ITEM.it-codigo NO-LOCK NO-ERROR.
        IF AVAIL   int_ds_ean_item THEN  
           ASSIGN tt-processo.codigo-ean  =  int_ds_ean_item.codigo_ean. /* 4-d  */

        ASSIGN tt-processo.estado          = p-estado
               tt-processo.COD-ESTADO-ORIG   = p-estado-origem
               tt-processo.cd-trib-icm     = ITEM.cd-trib-icm            /* 7-g  */ 
               tt-processo.cd-trib-icm-tre = ITEM.cd-trib-icm            /* 10-j */  
               tt-processo.cd-trib-icm-tri = ITEM.cd-trib-icm.           /* 13-m */  
    END.
    IF ITEM.CD-TRIB-ICM = 1 THEN DO: /* tributado */ // momento correto de altera‡Æo

       /* ft0312 */
       FIND FIRST ICMS-IT-UF WHERE
                  ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                  ICMS-IT-UF.ESTADO    = p-estado NO-LOCK NO-ERROR.
       IF AVAIL   icms-it-uf THEN DO:

          ASSIGN tt-processo.aliquota-icm     = Icms-it-uf.aliquota-icm       /* 8-h  */
                 tt-processo.aliquota-icm-ale = Icms-it-uf.aliquota-icm.      /* 11-k */ 
          
          IF p-estado = "PR" THEN DO: 

              IF      ICMS-IT-UF.ALIQUOTA-ICM = 19.5 THEN ASSIGN tt-processo.rast         = 38.46.                        /* 20-t */
              ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .                        /* 20-t */  

          END.

       END. 
       ELSE DO:
           /* CD0904 */
           FIND FIRST unid-feder WHERE                                             
                      unid-feder.pais      = "BRASIL" AND
                      unid-feder.estado    = p-estado NO-LOCK NO-ERROR.
           IF AVAIL UNID-FEDER THEN DO:

              ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                     tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */  

              IF p-estado = "PR" THEN DO:
                 

                      IF      unid-feder.pc-icms-st = 19.5 THEN ASSIGN tt-processo.rast    = 38.46.                        /* 20-t */
                      ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .                        /* 20-t */   

              END.
           END.
       END.

       /* observacao michel colunas 25 e 26  */    
        IF ITEM.codigo-orig = 0 OR        
           ITEM.codigo-orig = 4 OR
           ITEM.codigo-orig = 5 THEN DO:

           /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */

           ASSIGN tt-processo.csta =  12                                           /* 25-y */              
                  tt-processo.ies  =  12                                           /* 26-z */  
                  tt-processo.aliquota-icm-ali  = unid-feder.per-icms-ext.                              /* 14-n */              
          
        END.
        ELSE DO:
    
           /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
    
           ASSIGN tt-processo.csta =  4                                           /* 25-y */              
                  tt-processo.ies  =  4                                          /* 26-z */ 
                  tt-processo.aliquota-icm-ali  = 4  .                            /* 14-n */
    
        END.

        ASSIGN tt-processo.rast              = 0                     /* 20-t */              
               tt-processo.rbest             = 0.                    /* 21-u */              

        IF tt-processo.per-red-sub /* 19-s */  <> 0 THEN DO: 
        
            IF TT-PROCESSO.ESTADO          = "PR" AND
               TT-PROCESSO.COD-ESTADO-ORIG = "PR" THEN DO:
        
               IF      item-uf.dec-1      = 19.5 THEN ASSIGN tt-processo.rast = 38.46.   /* 20-t */
               ELSE IF item-uf.dec-1      = 25 THEN ASSIGN tt-processo.rast = 52.      /* 20-t */                             
        
            END.
        
        END.

    END.
    ELSE IF ITEM.CD-TRIB-ICM = 2 THEN DO: /* isento */

        ASSIGN
           tt-processo.cd-trib-icm     = ITEM.cd-trib-icm            /* 7-g  */ 
           tt-processo.cd-trib-icm-tre = ITEM.cd-trib-icm            /* 10-j */  
           tt-processo.cd-trib-icm-tri = ITEM.cd-trib-icm.           /* 13-m */     

         ASSIGN tt-processo.aliquota-icm-ale  = 0.                      /* 11-k */              

         IF ITEM.fm-codigo = "203" THEN DO: /* familia de isentos */
                                  
            ASSIGN tt-processo.cd-trib-icm  = 2       /* 7-g */   
                   tt-processo.aliquota-icm = 0.      /* 8-h */ 

            /* ft0312 */
            FIND FIRST ICMS-IT-UF WHERE
                       ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                       ICMS-IT-UF.ESTADO    = p-estado NO-LOCK NO-ERROR.
            IF AVAIL   icms-it-uf THEN DO:
         
               ASSIGN tt-processo.cd-trib-icm-tre   = 1                       /* 10-j */              
                      tt-processo.cd-trib-icm-tri   = 1.                      /* 13-m */ 

               ASSIGN tt-processo.aliquota-icm-ale  = ICMS-IT-UF.ALIQUOTA-ICM. /* 11-k */              

               
               
               IF ITEM.codigo-orig = 0 OR                  
                  ITEM.codigo-orig = 4 OR
                  ITEM.codigo-orig = 5 THEN DO:
               
              
               
                  ASSIGN tt-processo.aliquota-icm-ali = unid-feder.per-icms-ext.      /* 14-n */  
               
               /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */

/*                       ASSIGN tt-processo.csta =  12                                           /* 25-y */ */
/*                              tt-processo.ies  =  12.                                          /* 26-z */ */
               
               END.
               ELSE DO:
               
                   ASSIGN tt-processo.aliquota-icm-ali = 4.      /* 14-n */  
    
                   /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
    
    /*                       ASSIGN tt-processo.csta =  4                                           /* 25-y */ */
    /*                              tt-processo.ies  =  4.                                          /* 26-z */ */
               
               END.
               
            END. 
         END.
    END.
    ELSE IF ITEM.CD-TRIB-ICM = 3 THEN DO: /* OUTROS  */

       ASSIGN
           tt-processo.cd-trib-icm     = ITEM.cd-trib-icm            /* 7-g  */
           tt-processo.cd-trib-icm-tre = ITEM.cd-trib-icm            /* 10-j */
           tt-processo.cd-trib-icm-tri = ITEM.cd-trib-icm.           /* 13-m */

       IF ITEM.fm-codigo >= "500" AND
          ITEM.FM-CODIGO <= "999" THEN DO: /* familia DE MANUTENCAO, ATIVO, CONSUMO */

            /* ft0312 */
            FIND FIRST ICMS-IT-UF WHERE
                       ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND
                       ICMS-IT-UF.ESTADO    = p-estado NO-LOCK NO-ERROR.
            IF AVAIL   icms-it-uf THEN DO:

               ASSIGN tt-processo.cd-trib-icm       = 0                       /* 7-g  */
                      tt-processo.cd-trib-icm-tre   = 0                       /* 10-j */
                      tt-processo.cd-trib-icm-tri   = 0.                      /* 13-m */
            END.
       END.

    END.
    ELSE IF ITEM.CD-TRIB-ICM = 4 THEN DO: /* REDUZIDO  */

       ASSIGN tt-processo.cd-trib-icm       = 0                       /* 7-g  */ 
              tt-processo.cd-trib-icm-tre   = 0                       /* 10-j */              
              tt-processo.cd-trib-icm-tri   = 0.                      /* 13-m */ 
    END.

    ASSIGN tt-processo.aliquota-ipi = ITEM.aliquota-ipi
           tt-processo.fm-codigo    = ITEM.fm-codigo.

    ASSIGN c-lista = "".
    FOR FIRST it-carac-tec fields(observacao)
        WHERE it-carac-tec.it-codigo = ITEM.it-codigo and
              it-carac-tec.cd-folha  = "CADITEM"      AND
              it-carac-tec.cd-comp   = "90" NO-LOCK :
       ASSIGN c-lista = it-carac-tec.observacao.
         
    END.
    ASSIGN tt-processo.observacao    = substr(c-lista,1,1)            /* 23-w */  
           tt-processo.class-fiscal  = ITEM.class-fiscal.             /* 24-x */ 

    IF ITEM.FM-CODIGO =  "101" OR
       ITEM.FM-CODIGO =  "201" OR
       ITEM.FM-CODIGO >= "300" AND
       ITEM.FM-CODIGO <= "309" THEN DO:

       ASSIGN tt-processo.csta = 1       /* 25-y */              
              tt-processo.ies  = 4.      /* 26-z */   


       IF ITEM.cd-trib-icm = 1 THEN /* tributado */
          ASSIGN tt-processo.aliquota-icm-ali  = 4  .               /* 14-n */

    END.
    ELSE DO: /* FAIXA ITENS NACIONAL */

       ASSIGN tt-processo.csta = 0        /* 25-y */              
              tt-processo.ies  = 12.      /* 26-z */  
              
      
              
       IF ITEM.cd-trib-icm = 1 THEN /* tributado */
          ASSIGN tt-processo.aliquota-icm-ali  = unid-feder.per-icms-ext.              /* 14-n */

    END.

    FOR FIRST familia fields(descricao) WHERE
              familia.fm-codigo = ITEM.fm-codigo NO-LOCK:
        ASSIGN tt-processo.descricao = familia.descricao.
    END.

    IF SUBSTRING(item.char-2,52,1) = "1" THEN   /* campo origem aliquota Pis = 1-item, 2-Natureza */  
         ASSIGN tt-processo.aliq-pis = dec(SUBSTRING(item.char-2,31,5)).             /* 30-ad */         
    ELSE ASSIGN tt-processo.aliq-pis = 0 .                                           /* 30-ad */

    IF SUBSTRING(item.char-2,53,1) = "1" THEN   /* campo origem aliquota cofins = 1-item, 2-Natureza */ 
         ASSIGN tt-processo.aliq-cofins = dec(SUBSTRING(item.char-2,36,5)) .          /* 31-af */         
    ELSE ASSIGN tt-processo.aliq-cofins = 0 .                                         /* 31-af */      

    IF tt-processo.aliq-pis > 0 THEN
       ASSIGN tt-processo.tributa-pis = "S".
    ELSE 
       ASSIGN tt-processo.tributa-pis = "N".

    IF tt-processo.aliq-cofins > 0 THEN
       ASSIGN tt-processo.tributa-cofins = "S".
    ELSE 
       ASSIGN tt-processo.tributa-cofins = "N".  
       
    
 

END.



/**********************************************************************************************************************************************************************************/
PROCEDURE pi-grava-item:

   DEF INPUT PARAM l-item-uf AS LOG NO-UNDO.

   CREATE tt-processo.
   ASSIGN tt-processo.it-codigo   = ITEM.it-codigo                  /* 1-a  */ 
          tt-processo.desc-item   = ITEM.desc-item                  /* 2-b  */  
          tt-processo.ge-codigo   = ITEM.ge-codigo                  /* 3-c  */
          tt-processo.alterado    = NO
          tt-processo.tipo-reg    = NO.
          
   FIND FIRST int_ds_ean_item WHERE
              int_ds_ean_item.it_codigo = ITEM.it-codigo NO-LOCK NO-ERROR.
   IF AVAIL   int_ds_ean_item THEN  
      ASSIGN tt-processo.codigo-ean  =  int_ds_ean_item.codigo_ean. /* 4-d  */

   ASSIGN tt-processo.cd-trib-icm     = ITEM.cd-trib-icm         /* 7-g  */
          tt-processo.cd-trib-icm-tre = ITEM.cd-trib-icm         /* 10-j */
          tt-processo.cd-trib-icm-tri = ITEM.cd-trib-icm.        /* 13-m */

   IF ITEM.CD-TRIB-ICM = 1 THEN DO: /* tributado */

       ASSIGN tt-processo.cd-trib-icm     = ITEM.cd-trib-icm         /* 7-g  */
              tt-processo.cd-trib-icm-tre = ITEM.cd-trib-icm         /* 10-j */
              tt-processo.cd-trib-icm-tri = ITEM.cd-trib-icm.        /* 13-m */

      
       /* ft0312 */
       IF tt-param.tg-pr = YES THEN DO:

          /* ft0312 */
          FIND FIRST ICMS-IT-UF WHERE
                     ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                     ICMS-IT-UF.ESTADO    = "PR" NO-LOCK NO-ERROR.
          IF AVAIL   icms-it-uf THEN DO:

             ASSIGN tt-processo.aliquota-icm     = Icms-it-uf.aliquota-icm       /* 8-h  */
                    tt-processo.aliquota-icm-ale = Icms-it-uf.aliquota-icm.      /* 11-k */             

             IF      ICMS-IT-UF.ALIQUOTA-ICM = 19.5 THEN ASSIGN tt-processo.rast         = 38.46.                        /* 20-t */
             ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .                        /* 20-t */                

          END. 
          ELSE DO:
              /* CD0904 */
              FIND FIRST unid-feder WHERE 
                         unid-feder.pais      = "BRASIL" AND
                         unid-feder.estado    = "PR" NO-LOCK NO-ERROR.
              IF AVAIL UNID-FEDER THEN DO:

                 ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                        tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */   

                 IF      unid-feder.pc-icms-st = 19.5 THEN ASSIGN tt-processo.rast    = 38.46.                        /* 20-t */
                 ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .                        /* 20-t */     

              END.

          END.
       END.
       ELSE IF tt-param.tg-SP = YES THEN DO:

          /* ft0312 */
          FIND FIRST ICMS-IT-UF WHERE
                     ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                     ICMS-IT-UF.ESTADO    = "SP" NO-LOCK NO-ERROR.
          IF AVAIL   icms-it-uf THEN DO:

             ASSIGN tt-processo.aliquota-icm     = Icms-it-uf.aliquota-icm       /* 8-h  */
                    tt-processo.aliquota-icm-ale = Icms-it-uf.aliquota-icm.      /* 11-k */   

          /*   IF      ICMS-IT-UF.ALIQUOTA-ICM = 18 THEN ASSIGN tt-processo.rast         = 33.33.                        /* 20-t */
             ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .  */                      /* 20-t */               
   
          END. 
          /* CD0904 */
          ELSE DO:

              FIND FIRST unid-feder WHERE 
                         unid-feder.pais      = "BRASIL" AND
                         unid-feder.estado    = "SP" NO-LOCK NO-ERROR.
              IF AVAIL UNID-FEDER THEN DO:

                 ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                        tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */   

                /* IF      unid-feder.pc-icms-st = 18 THEN ASSIGN tt-processo.rast    = 33.33.                        /* 20-t */
                 ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .     */                   /* 20-t */  

              END.

          END.
       END.
       ELSE IF tt-param.tg-SC = YES THEN DO:

          /* ft0312 */
          FIND FIRST ICMS-IT-UF WHERE
                     ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                     ICMS-IT-UF.ESTADO    = "SC" NO-LOCK NO-ERROR.
          IF AVAIL   icms-it-uf THEN DO:
       
             ASSIGN tt-processo.aliquota-icm     = Icms-it-uf.aliquota-icm       /* 8-h  */
                    tt-processo.aliquota-icm-ale = Icms-it-uf.aliquota-icm.      /* 11-k */
            

            /*  IF      ICMS-IT-UF.ALIQUOTA-ICM = 17 THEN ASSIGN tt-processo.rast         = 33.33.                        /* 20-t */  //altera‡Æo KML para teste de valida‡Æo FT0312
              ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .   */                     /* 20-t */ 
                                                                                                                                  
          END.                                                                                                                    
          ELSE DO:
             /* CD0904 */ 
             FIND FIRST unid-feder WHERE 
                        unid-feder.pais      = "BRASIL" AND
                        unid-feder.estado    = "SC" NO-LOCK NO-ERROR.
             IF AVAIL UNID-FEDER THEN DO:
                 ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                        tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */   

              /*   IF      unid-feder.pc-icms-st = 17 THEN ASSIGN tt-processo.rast    = 33.33.                        /* 20-t */
                 ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .  */                      /* 20-t */                                                                                                                                                

             END.
          END.
       END.
       
       ELSE IF tt-param.tg-GO = YES THEN DO:

          /* ft0312 */
          FIND FIRST ICMS-IT-UF WHERE
                     ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                     ICMS-IT-UF.ESTADO    = "GO" NO-LOCK NO-ERROR.
          IF AVAIL   icms-it-uf THEN DO:
       
             ASSIGN tt-processo.aliquota-icm     = Icms-it-uf.aliquota-icm       /* 8-h  */
                    tt-processo.aliquota-icm-ale = Icms-it-uf.aliquota-icm.      /* 11-k */
            

           /*   IF      ICMS-IT-UF.ALIQUOTA-ICM = 19 THEN ASSIGN tt-processo.rast         = 33.33.                        /* 20-t */  //altera‡Æo KML para teste de valida‡Æo FT0312
              ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .   */                     /* 20-t */ 
                                                                                                                                  
          END.                                                                                                                    
          ELSE DO:
             /* CD0904 */ 
             FIND FIRST unid-feder WHERE 
                        unid-feder.pais      = "BRASIL" AND
                        unid-feder.estado    = "GO" NO-LOCK NO-ERROR.
             IF AVAIL UNID-FEDER THEN DO:
                 ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                        tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */   

              /*   IF      unid-feder.pc-icms-st = 19 THEN ASSIGN tt-processo.rast    = 33.33.                        /* 20-t */
                 ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .    */                    /* 20-t */                                                                                                                                                

             END.
          END.
       END.   
       ELSE IF tt-param.tg-DF = YES THEN DO:

          /* ft0312 */
          FIND FIRST ICMS-IT-UF WHERE
                     ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                     ICMS-IT-UF.ESTADO    = "DF" NO-LOCK NO-ERROR.
          IF AVAIL   icms-it-uf THEN DO:
       
             ASSIGN tt-processo.aliquota-icm     = Icms-it-uf.aliquota-icm       /* 8-h  */
                    tt-processo.aliquota-icm-ale = Icms-it-uf.aliquota-icm.      /* 11-k */
            

            /*  IF      ICMS-IT-UF.ALIQUOTA-ICM = 20 THEN ASSIGN tt-processo.rast         = 33.33.                        /* 20-t */  //altera‡Æo KML para teste de valida‡Æo FT0312
              ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .*/                       /* 20-t */ 
                                                                                                                                  
          END.                                                                                                                    
          ELSE DO:
             /* CD0904 */ 
             FIND FIRST unid-feder WHERE 
                        unid-feder.pais      = "BRASIL" AND
                        unid-feder.estado    = "DF" NO-LOCK NO-ERROR.
             IF AVAIL UNID-FEDER THEN DO:
                 ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                        tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */   

               /*  IF      unid-feder.pc-icms-st = 20 THEN ASSIGN tt-processo.rast    = 33.33.                        /* 20-t */
                 ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .  */                      /* 20-t */                                                                                                                                                
                                                                                             
             END.
          END.
       END.         

       /* observacao michel colunas 25 e 26  */    
   
       IF ITEM.codigo-orig = 0 OR
          ITEM.codigo-orig = 4 OR
          ITEM.codigo-orig = 5 THEN DO:

          /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
          
          
      
          ASSIGN tt-processo.csta =  12                                           /* 25-y */
                 tt-processo.ies  =  12                                           /* 26-z */
                 tt-processo.aliquota-icm-ali  = 12.                              /* 14-n */

       END.
       ELSE DO:

          /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */

          ASSIGN tt-processo.csta =  4                                           /* 25-y */
                 tt-processo.ies  =  4.                                          /* 26-z */
          
            ASSIGN tt-processo.aliquota-icm-ali  = 4  .                            /* 14-n */

       END.

       IF  ITEM.FM-CODIGO =  "101" OR
           ITEM.FM-CODIGO =  "201" OR
           ITEM.FM-CODIGO >= "300" AND
           ITEM.FM-CODIGO <= "309" THEN DO:
    
           ASSIGN tt-processo.csta = 1       /* 25-y */              
                  tt-processo.ies  = 4.      /* 26-z */           

           /* KML - Alterado pois nÆo tem mais regime especial para Santa Catarina */ 

/*            IF l-item-uf = NO THEN   /* NAO ESTA CADASTRADO NO CD0904A  */             */
/*                  ASSIGN TT-PROCESSO.ALIQUOTA-ICM-ALI  = 0  .               /* 14-n */ */
/*            ELSE  ASSIGN tt-processo.aliquota-icm-ali  = 4  .               /* 14-n */ */

           ASSIGN tt-processo.aliquota-icm-ali  = 4  . 
           
    
        END.
        ELSE DO: /* FAIXA ITENS NACIONAL */
    
           ASSIGN tt-processo.csta = 0        /* 25-y */              
                  tt-processo.ies  = 12.      /* 26-z */  
    
           IF ITEM.cd-trib-icm = 1 THEN /* tributado */
              ASSIGN tt-processo.aliquota-icm-ali  = 12  . /* 14-n */
    
        END.


   END.
      
   ELSE IF ITEM.cd-trib-icm = 2 THEN DO: /* isento */

       IF ITEM.fm-codigo = "203" THEN DO: /* familia de isentos */

            ASSIGN tt-processo.cd-trib-icm  = 2       /* 7-g */
                   tt-processo.aliquota-icm = 0.      /* 8-h */

          IF tt-param.tg-pr = YES THEN DO:

              /* ft0312 */
              FIND FIRST ICMS-IT-UF WHERE
                         ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                         ICMS-IT-UF.ESTADO    = "PR" NO-LOCK NO-ERROR.
              IF AVAIL   icms-it-uf THEN DO:

                 ASSIGN                                                         
                        tt-processo.cd-trib-icm-tre   = 1                       /* 10-j */              
                        tt-processo.cd-trib-icm-tri   = 1.                      /* 13-m */   

                 ASSIGN tt-processo.aliquota-icm-ale  = ICMS-IT-UF.ALIQUOTA-ICM. /* 11-k */              

                   IF ITEM.codigo-orig = 0 OR 
                      ITEM.codigo-orig = 4 OR
                      ITEM.codigo-orig = 5 THEN DO:

                      ASSIGN tt-processo.aliquota-icm-ali = 12.      /* 14-n */ 
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  12                                           /* 25-y */ */
/*                              tt-processo.ies  =  12.                                          /* 26-z */ */
               
                   END.
                   ELSE DO:
               
                      ASSIGN tt-processo.aliquota-icm-ali = 4.      /* 14-n */  
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  4                                           /* 25-y */ */
/*                              tt-processo.ies  =  4.                                          /* 26-z */ */
               
                   END.
              
              END. 
          END.
          ELSE IF tt-param.tg-sp = YES THEN DO:

              /* ft0312 */
              FIND FIRST ICMS-IT-UF WHERE
                         ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                         ICMS-IT-UF.ESTADO    = "SP" NO-LOCK NO-ERROR.
              IF AVAIL   icms-it-uf THEN DO:

                 ASSIGN                                                         
                        tt-processo.cd-trib-icm-tre   = 1                       /* 10-j */              
                        tt-processo.cd-trib-icm-tri   = 1.                      /* 13-m */  

                 ASSIGN tt-processo.aliquota-icm-ale  = ICMS-IT-UF.ALIQUOTA-ICM. /* 11-k */              

                   IF ITEM.codigo-orig = 0 OR
                      ITEM.codigo-orig = 4 OR
                      ITEM.codigo-orig = 5 THEN DO:
               
                      ASSIGN tt-processo.aliquota-icm-ali = 12.      /* 14-n */  
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  12                                           /* 25-y */ */
/*                              tt-processo.ies  =  12.                                          /* 26-z */ */
               
                   END.
                   ELSE DO:                  
                      ASSIGN tt-processo.aliquota-icm-ali = 4.      /* 14-n */                 
                   END.
              END. 
          END.
          ELSE IF tt-param.tg-sc = YES THEN DO:

              /* ft0312 */
              FIND FIRST ICMS-IT-UF WHERE
                         ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                         ICMS-IT-UF.ESTADO    = "SC" NO-LOCK NO-ERROR.
              IF AVAIL   icms-it-uf THEN DO:

                 ASSIGN                                                          
                        tt-processo.cd-trib-icm-tre   = 1                       /* 10-j */              
                        tt-processo.cd-trib-icm-tri   = 1.                      /* 13-m */  

                 ASSIGN tt-processo.aliquota-icm-ale  = ICMS-IT-UF.ALIQUOTA-ICM. /* 11-k */ 

                   IF ITEM.codigo-orig = 0 OR
                      ITEM.codigo-orig = 4 OR
                      ITEM.codigo-orig = 5 THEN DO:
               
                      ASSIGN tt-processo.aliquota-icm-ali = 12.      /* 14-n */  
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  12                                           /* 25-y */ */
/*                              tt-processo.ies  =  12.                                          /* 26-z */ */
               
                   END.
                   ELSE DO:
               
                      ASSIGN tt-processo.aliquota-icm-ali = 4.      /* 14-n */ 
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  4                                           /* 25-y */ */
/*                              tt-processo.ies  =  4.                                          /* 26-z */ */
               
                   END.
              END.              
          END.
          ELSE IF tt-param.tg-go = YES THEN DO:

              /* ft0312 */
              FIND FIRST ICMS-IT-UF WHERE
                         ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                         ICMS-IT-UF.ESTADO    = "GO" NO-LOCK NO-ERROR.
              IF AVAIL   icms-it-uf THEN DO: 
    
                 ASSIGN                                                          
                        tt-processo.cd-trib-icm-tre   = 1                       /* 10-j */              
                        tt-processo.cd-trib-icm-tri   = 1.                      /* 13-m */  

                 ASSIGN tt-processo.aliquota-icm-ale  = ICMS-IT-UF.ALIQUOTA-ICM. /* 11-k */    

                   IF ITEM.codigo-orig = 0 OR
                      ITEM.codigo-orig = 4 OR
                      ITEM.codigo-orig = 5 THEN DO:             
               
               
                      ASSIGN tt-processo.aliquota-icm-ali = 7.      /* 14-n */  
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  12                                           /* 25-y */ */
/*                              tt-processo.ies  =  12.                                          /* 26-z */ */
               
                   END.
                   ELSE DO:
               
                      ASSIGN tt-processo.aliquota-icm-ali = 4.      /* 14-n */ 
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  4                                           /* 25-y */ */
/*                              tt-processo.ies  =  4.                                          /* 26-z */ */
               
                   END.
              END. 
          END.  
          
          ELSE IF tt-param.tg-df = YES THEN DO:

              /* ft0312 */
              FIND FIRST ICMS-IT-UF WHERE
                         ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                         ICMS-IT-UF.ESTADO    = "DF" NO-LOCK NO-ERROR.
              IF AVAIL   icms-it-uf THEN DO:
    
                 ASSIGN                                                          
                        tt-processo.cd-trib-icm-tre   = 1                       /* 10-j */              
                        tt-processo.cd-trib-icm-tri   = 1.                      /* 13-m */  

                 ASSIGN tt-processo.aliquota-icm-ale  = ICMS-IT-UF.ALIQUOTA-ICM. /* 11-k */ 


                   IF ITEM.codigo-orig = 0 OR
                      ITEM.codigo-orig = 4 OR
                      ITEM.codigo-orig = 5 THEN DO:
               
                      
               
                      ASSIGN tt-processo.aliquota-icm-ali = 7.      /* 14-n */  
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  12                                           /* 25-y */ */
/*                              tt-processo.ies  =  12.                                          /* 26-z */ */
               
                   END.
                   ELSE DO:
               
                      ASSIGN tt-processo.aliquota-icm-ali = 4.      /* 14-n */ 
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  4                                           /* 25-y */ */
/*                              tt-processo.ies  =  4.                                          /* 26-z */ */
               
                   END.
              END.
           END.
       END.
       ELSE IF ITEM.FM-CODIGO = "102" OR
               ITEM.FM-CODIGO = "202" OR
               ITEM.FM-CODIGO = "402" THEN DO:  /* ISENTO */

             ASSIGN tt-processo.cd-trib-icm       = 2                       /*  7-g */
                    tt-processo.cd-trib-icm-tre   = 2                       /* 10-j */              
                    tt-processo.cd-trib-icm-tri   = 2.                      /* 13-m */   

       END.
   END.

   ASSIGN tt-processo.aliquota-ipi  = ITEM.aliquota-ipi.             /* 22-v */

   ASSIGN c-lista = "".
   FOR FIRST it-carac-tec fields(observacao)
       WHERE it-carac-tec.it-codigo = ITEM.it-codigo and
             it-carac-tec.cd-folha  = "CADITEM"      AND
             it-carac-tec.cd-comp   = "90" NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
      ASSIGN c-lista = it-carac-tec.observacao.
   END.

   ASSIGN tt-processo.observacao    = substr(c-lista,1,1)            /* 23-w */  
          tt-processo.class-fiscal  = ITEM.class-fiscal.             /* 24-x */ 
   
   IF ITEM.FM-CODIGO =  "101" OR
      ITEM.FM-CODIGO =  "201" OR
      ITEM.FM-CODIGO >= "300" AND
      ITEM.FM-CODIGO <= "309" THEN DO:

      ASSIGN tt-processo.csta = 1       /* 25-y */              
             tt-processo.ies  = 4.      /* 26-z */              

   END.
   ELSE DO: /* FAIXA ITENS NACIONAL */

      ASSIGN tt-processo.csta = 0        /* 25-y */              
             tt-processo.ies  = 12.      /* 26-z */  

   END.

   ASSIGN tt-processo.fm-codigo = ITEM.fm-codigo.                    /* 27-aa */
   
   FOR FIRST familia fields(descricao) WHERE
             familia.fm-codigo = ITEM.fm-codigo NO-LOCK :
       ASSIGN tt-processo.descricao = familia.descricao.             /* 28-ab */            
   END.

   /* 28-Busca campo Aliquota PIS no programa CD0903 se campo Origem Aliquota = Item, se n’o, busca o campo % Interno PIS no programa CD0606 aba Outros */
     

END PROCEDURE. 

PROCEDURE cria-integracao:

    FOR EACH tt-processo:
    
    
        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = tt-processo.it-codigo NO-ERROR.
            
        // Corre‡Æo PIS/Cofins
        IF SUBSTRING(item.char-2,52,1) = "1" THEN   /* campo origem aliquota Pis = 1-item, 2-Natureza */  
            ASSIGN tt-processo.aliq-pis = dec(SUBSTRING(item.char-2,31,5)).             /* 30-ad */         
        ELSE ASSIGN tt-processo.aliq-pis = 0 .                                           /* 30-ad */
          
        IF SUBSTRING(item.char-2,53,1) = "1" THEN   /* campo origem aliquota cofins = 1-item, 2-Natureza */ 
            ASSIGN tt-processo.aliq-cofins = dec(SUBSTRING(item.char-2,36,5)) .          /* 31-ae */         
        ELSE ASSIGN tt-processo.aliq-cofins = 0 .                                       /* 31-ae */      
                                                   
        IF tt-processo.aliq-pis > 0 THEN
            ASSIGN tt-processo.tributa-pis = "S".
        else 
            ASSIGN tt-processo.tributa-pis = "N".

        IF tt-processo.aliq-cofins > 0 THEN
            ASSIGN tt-processo.tributa-cofins = "S".
        ELSE 
            ASSIGN tt-processo.tributa-cofins = "N".
         
         // KML - 23/01/2025 - Corre‡…o icms diferenciado somente deve ser pro parana

         ASSIGN tt-processo.rast = 0.
         
         IF tt-processo.estado      = "PR" AND 
            tt-processo.cod-estado-orig = "PR"  THEN DO:  
         
            FIND FIRST icms-it-uf NO-LOCK USE-INDEX codigo
                WHERE icms-it-uf.it-codigo  = tt-processo.it-codigo
                  AND icms-it-uf.estado     = tt-processo.cod-estado NO-ERROR.
             IF AVAIL icms-it-uf AND
                icms-it-uf.aliquota-icm = 25 THEN
             DO:
                ASSIGN tt-processo.rast = 52. 
             END.
             ELSE DO:
                FIND FIRST Diferim-parcial-icms NO-LOCK
                    WHERE Diferim-parcial-icms.cod-item     = tt-processo.it-codigo
                      AND Diferim-parcial-icms.cod-estado   = tt-processo.estado NO-ERROR.
                IF AVAIL Diferim-parcial-icms THEN
                DO:
                    ASSIGN tt-processo.rast = Diferim-parcial-icms.val-perc-icms-diferim.
                    
                END.
                 
             END.
         END. 
        
        /* KML Consultoria - Kleber Mazepa - 16/01/2025 - Ajuste  ICMS interestadual*/ 
        IF tt-processo.cd-trib-icm = 1 OR tt-processo.cd-trib-icm = 5  THEN DO: /* Somente itens tributados e com dados de interestadual*/
        
            ASSIGN tt-processo.ies = fn-aliq-interestadual( tt-processo.cod-estado-orig , tt-processo.estado).
            IF tt-processo.trans_tr_inter_aliquota <> 4  THEN
                ASSIGN tt-processo.trans_tr_inter_aliquota          = fn-aliq-interestadual( tt-processo.cod-estado-orig , tt-processo.estado)
                       tt-processo.aliquota-icm-ali                 = fn-aliq-interestadual( tt-processo.cod-estado-orig , tt-processo.estado)
                       .
            
        END. 
        
       
        IF tt-processo.cd-trib-icm = 5 THEN
        DO:
            ASSIGN tt-processo.aliquota-icm = 0.   
        END.
        

        run pi-acompanhar IN h-acomp ("Integra‡Æo - Item: " + string(tt-processo.it-codigo) ).

        FIND FIRST int_dp_item_fiscal  EXCLUSIVE-LOCK WHERE
                  int_dp_item_fiscal.produto        = tt-processo.it-codigo       AND
                  int_dp_item_fiscal.estado_origem  = tt-processo.cod-estado-orig AND
                  int_dp_item_fiscal.estado_destino = tt-processo.estado NO-ERROR.
        
        ASSIGN l-criou = NO.
        IF NOT AVAIL int_dp_item_fiscal THEN DO:
           CREATE int_dp_item_fiscal.
           ASSIGN int_dp_item_fiscal.produto         = tt-processo.it-codigo
                  int_dp_item_fiscal.estado_origem   = tt-processo.cod-estado-orig   
                  int_dp_item_fiscal.estado_destino  = tt-processo.estado
                  int_dp_item_fiscal.id_sequencial   = NEXT-VALUE(seq_int_dp_item_fiscal)
                  int_dp_item_fiscal.envio_data_hora = DATETIME(TODAY, TIME)
                  int_dp_item_fiscal.envio_status    = 0
                  tt-processo.tipo-reg               = YES
                  l-criou                            = YES.
        END.

        ASSIGN l-alterou = NO. 
        IF int_dp_item_fiscal.descricao <> tt-processo.desc-item THEN 
           ASSIGN int_dp_item_fiscal.descricao = tt-processo.desc-item
                  l-alterou                    = YES.          
        IF int_dp_item_fiscal.grupo_estoque <> tt-processo.ge-codigo THEN 
           ASSIGN int_dp_item_fiscal.grupo_estoque = tt-processo.ge-codigo
                  l-alterou                        = YES.
        
        IF int_dp_item_fiscal.ean <> tt-processo.codigo-ean THEN 
           ASSIGN int_dp_item_fiscal.ean = tt-processo.codigo-ean
                  l-alterou              = YES.
        
        IF int_dp_item_fiscal.venda_tr <> tt-processo.cd-trib-icm THEN 
           ASSIGN int_dp_item_fiscal.venda_tr = tt-processo.cd-trib-icm
                  l-alterou                   = YES.
        
        IF int_dp_item_fiscal.venda_icms <> tt-processo.aliquota-icm THEN 
           ASSIGN int_dp_item_fiscal.venda_icms = tt-processo.aliquota-icm
                  l-alterou                     = YES.
        
        IF int_dp_item_fiscal.venda_red_base_icms <> tt-processo.red THEN 
           ASSIGN int_dp_item_fiscal.venda_red_base_icms = tt-processo.red
                  l-alterou                              = YES.
        
        IF int_dp_item_fiscal.compra_estadual_tr <> tt-processo.cd-trib-icm-tre THEN 
           ASSIGN int_dp_item_fiscal.compra_estadual_tr = tt-processo.cd-trib-icm-tre
                  l-alterou                             = YES.
       
        IF int_dp_item_fiscal.compra_estadual_icms_credito <> tt-processo.aliquota-icm-ale THEN
           ASSIGN int_dp_item_fiscal.compra_estadual_icms_credito = tt-processo.aliquota-icm-ale
                  l-alterou                                       = YES.
       
        IF int_dp_item_fiscal.compra_estadual_icms_credito_red <> tt-processo.rede THEN 
           ASSIGN int_dp_item_fiscal.compra_estadual_icms_credito_red = tt-processo.rede
                  l-alterou                                           = YES.
        
        IF int_dp_item_fiscal.compra_inter_estadual_tr <> tt-processo.cd-trib-icm-tri THEN 
           ASSIGN int_dp_item_fiscal.compra_inter_estadual_tr = tt-processo.cd-trib-icm-tri
                  l-alterou                                   = YES.
        
        IF int_dp_item_fiscal.compra_interestad_icms_credito <> tt-processo.aliquota-icm-ali THEN 
           ASSIGN int_dp_item_fiscal.compra_interestad_icms_credito = tt-processo.aliquota-icm-ali
                  l-alterou                                         = YES.
                
        IF int_dp_item_fiscal.compra_inter_icms_cred_red_base <> tt-processo.redi THEN 
           ASSIGN int_dp_item_fiscal.compra_inter_icms_cred_red_base = tt-processo.redi
                  l-alterou                                          = YES.
                
        IF int_dp_item_fiscal.compra_estadual_iva <> tt-processo.per-sub-tri-ste THEN DO:
           IF tt-processo.per-sub-tri-ste > 999.99 THEN
              ASSIGN tt-processo.per-sub-tri-ste = 999.99.
           ASSIGN int_dp_item_fiscal.compra_estadual_iva = tt-processo.per-sub-tri-ste     
                  l-alterou                              = YES.
        END.
        
        IF int_dp_item_fiscal.compra_interestad_iva_ajustado <> tt-processo.per-sub-tri-sti THEN DO:
           IF tt-processo.per-sub-tri-sti > 999.99 THEN
              ASSIGN tt-processo.per-sub-tri-sti = 999.99.
           ASSIGN int_dp_item_fiscal.compra_interestad_iva_ajustado = tt-processo.per-sub-tri-sti
                  l-alterou                                         = YES.
        END.
        
        IF int_dp_item_fiscal.icms_substituto <> tt-processo.val-icms-est-sub THEN 
           ASSIGN int_dp_item_fiscal.icms_substituto = tt-processo.val-icms-est-sub
                  l-alterou                          = YES.
        

        IF int_dp_item_fiscal.fator_reducao_st_01 <> tt-processo.per-red-sub THEN 
           ASSIGN int_dp_item_fiscal.fator_reducao_st_01 = tt-processo.per-red-sub
                  l-alterou                              = YES.
        
        IF int_dp_item_fiscal.fator_reducao_st_02 <> tt-processo.rast THEN 
           ASSIGN int_dp_item_fiscal.fator_reducao_st_02 = tt-processo.rast
                  l-alterou                              = YES.
                
        IF int_dp_item_fiscal.fator_reducao_st_03 <> tt-processo.rbest THEN 
           ASSIGN int_dp_item_fiscal.fator_reducao_st_03 = tt-processo.rbest
                  l-alterou                              = YES.
        
        IF int_dp_item_fiscal.ipi <> tt-processo.aliquota-ipi THEN 
           ASSIGN int_dp_item_fiscal.ipi = tt-processo.aliquota-ipi
                  l-alterou              = YES.
        
        IF int_dp_item_fiscal.lista <> tt-processo.observacao THEN 
           ASSIGN int_dp_item_fiscal.lista = tt-processo.observacao 
                  l-alterou                = YES.
        
        IF int_dp_item_fiscal.ncm <> tt-processo.class-fiscal THEN 
           ASSIGN int_dp_item_fiscal.ncm = tt-processo.class-fiscal
                  l-alterou              = YES.
        
        IF int_dp_item_fiscal.origem <> tt-processo.csta THEN 
           ASSIGN int_dp_item_fiscal.origem = tt-processo.csta
                  l-alterou                 = YES.
        
        IF int_dp_item_fiscal.compra_estadual_icms <> tt-processo.ies THEN 
           ASSIGN int_dp_item_fiscal.compra_estadual_icms = tt-processo.ies
                  l-alterou                               = YES.
        
        IF int_dp_item_fiscal.familia <> tt-processo.fm-codigo THEN 
           ASSIGN int_dp_item_fiscal.familia = tt-processo.fm-codigo
                  l-alterou                  = YES.
        
        IF int_dp_item_fiscal.familia_descricao <> tt-processo.descricao THEN
           ASSIGN int_dp_item_fiscal.familia_descricao = tt-processo.descricao
                  l-alterou = YES.
        
        IF int_dp_item_fiscal.tributa_pis <> tt-processo.tributa-pis THEN 
           ASSIGN int_dp_item_fiscal.tributa_pis = tt-processo.tributa-pis
                  l-alterou                      = YES.
        
        IF int_dp_item_fiscal.pis <> tt-processo.aliq-pis THEN 
           ASSIGN int_dp_item_fiscal.pis = tt-processo.aliq-pis
                  l-alterou              = YES.
        
        IF int_dp_item_fiscal.tributa_cofins <> tt-processo.tributa-cofins THEN 
           ASSIGN int_dp_item_fiscal.tributa_cofins = tt-processo.tributa-cofins      
                  l-alterou                         = YES.
        
        IF int_dp_item_fiscal.cofins <> tt-processo.aliq-cofins THEN 
           ASSIGN int_dp_item_fiscal.cofins = tt-processo.aliq-cofins         
                  l-alterou                 = YES.
        
        IF int_dp_item_fiscal.calc_pauta <> tt-processo.utiliza-pauta-fiscal THEN 
           ASSIGN int_dp_item_fiscal.calc_pauta = tt-processo.utiliza-pauta-fiscal
                  l-alterou                     = YES.
        
        IF int_dp_item_fiscal.calc_mva <> tt-processo.utiliza-mva-ajustada THEN 
           ASSIGN int_dp_item_fiscal.calc_mva = tt-processo.utiliza-mva-ajustada  
                  l-alterou                = YES.
        
        IF int_dp_item_fiscal.pauta <> tt-processo.valor-pauta-fiscal THEN 
          ASSIGN int_dp_item_fiscal.pauta = tt-processo.valor-pauta-fiscal  
                  l-alterou                = YES.
               
        IF int_dp_item_fiscal.vl_pmpf <> tt-processo.valor-pmpf THEN 
          ASSIGN int_dp_item_fiscal.vl_pmpf = tt-processo.valor-pmpf  
                  l-alterou                = YES.
        
        IF int_dp_item_fiscal.trans_tr_estadual <> tt-processo.trans_tr_estadual THEN 
           ASSIGN int_dp_item_fiscal.trans_tr_estadual = tt-processo.trans_tr_estadual
                  l-alterou                            = YES.
        
        IF int_dp_item_fiscal.trans_tr_estadual_aliquota <> tt-processo.trans_tr_estadual_aliquota THEN 
           ASSIGN int_dp_item_fiscal.trans_tr_estadual_aliquota = tt-processo.trans_tr_estadual_aliquota
                  l-alterou                                     = YES.
        
        
        IF int_dp_item_fiscal.trans_tr_estadual_reducao <> tt-processo.trans_tr_estadual_reducao THEN 
           ASSIGN int_dp_item_fiscal.trans_tr_estadual_reducao = tt-processo.trans_tr_estadual_reducao
                  l-alterou                                    = YES.    
                
        IF int_dp_item_fiscal.trans_tr_interestadual <> tt-processo.trans_tr_interestadual THEN 
           ASSIGN int_dp_item_fiscal.trans_tr_interestadual = tt-processo.trans_tr_interestadual
                  l-alterou                                 = YES.
        
        IF int_dp_item_fiscal.trans_tr_inter_aliquota <> tt-processo.trans_tr_inter_aliquota THEN 
           ASSIGN int_dp_item_fiscal.trans_tr_inter_aliquota = tt-processo.trans_tr_inter_aliquota
                  l-alterou                                  = YES.
               
        IF int_dp_item_fiscal.trans_tr_inter_reducao <> tt-processo.trans_tr_inter_reducao THEN
           ASSIGN int_dp_item_fiscal.trans_tr_inter_reducao = tt-processo.trans_tr_inter_reducao
                  l-alterou                                 = YES.  
                     
        IF int_dp_item_fiscal.tr_perda <> tt-processo.tr_perda THEN 
           ASSIGN int_dp_item_fiscal.tr_perda = tt-processo.tr_perda
                  l-alterou                   = YES. 
                        
        IF int_dp_item_fiscal.tr_perda_aliquota <> tt-processo.tr_perda_aliquota THEN 
           ASSIGN int_dp_item_fiscal.tr_perda_aliquota = tt-processo.tr_perda_aliquota
                  l-alterou                            = YES.
        
        IF int_dp_item_fiscal.cest <> tt-processo.cest THEN 
           ASSIGN int_dp_item_fiscal.cest = STRING(tt-processo.cest, "9999999")
                  l-alterou               = YES.
        
        IF int_dp_item_fiscal.subs_trib_transf_inter <> tt-processo.subs_trib_transf_inter THEN 
           ASSIGN int_dp_item_fiscal.subs_trib_transf_inter = tt-processo.subs_trib_transf_inter
                  l-alterou                                 = YES.
        
        IF int_dp_item_fiscal.cst_pis <> tt-processo.cst-pis 
        OR int_dp_item_fiscal.cst_pis = ? THEN DO:
           IF tt-processo.cst-pis <> ? THEN
              ASSIGN int_dp_item_fiscal.cst_pis = tt-processo.cst-pis
                     l-alterou                  = YES.
        END.

        IF int_dp_item_fiscal.cst_cofins <> tt-processo.cst-cofins 
        OR int_dp_item_fiscal.cst_cofins = ? THEN DO:
           IF tt-processo.cst-cofins <> ? THEN
              ASSIGN int_dp_item_fiscal.cst_cofins = tt-processo.cst-cofins
                     l-alterou                     = YES.
        END.

        IF int_dp_item_fiscal.aliq_int_uf_dest <> tt-processo.aliq-int-uf-dest THEN 
           ASSIGN int_dp_item_fiscal.aliq_int_uf_dest = tt-processo.aliq-int-uf-dest
                  l-alterou                           = YES.
        
        IF int_dp_item_fiscal.dif_aliq <> tt-processo.dif-aliq THEN 
           ASSIGN int_dp_item_fiscal.dif_aliq = tt-processo.dif-aliq
                  l-alterou                           = YES.
        
        IF int_dp_item_fiscal.part_icms_uf_orig <> tt-processo.part-icms-uf-orig THEN 
           ASSIGN int_dp_item_fiscal.part_icms_uf_orig = tt-processo.part-icms-uf-orig
                  l-alterou                           = YES.
        
        IF int_dp_item_fiscal.part_icms_uf_dest <> tt-processo.part-icms-uf-dest THEN 
           ASSIGN int_dp_item_fiscal.part_icms_uf_dest = tt-processo.part-icms-uf-dest
                  l-alterou                           = YES.
        
        IF tt-param.forc-integ = YES THEN
            ASSIGN l-alterou = YES.

        IF l-alterou = YES THEN DO:
           ASSIGN int_dp_item_fiscal.envio_data_hora = DATETIME(TODAY, TIME)
                  int_dp_item_fiscal.envio_status    = 1
                  int_dp_item_fiscal.id_sequencial   = NEXT-VALUE(seq_int_dp_item_fiscal)
                  tt-processo.alterado               = YES.
        END.
        IF l-criou = YES THEN
           ASSIGN int_dp_item_fiscal.envio_status = 1.

        RELEASE int_dp_item_fiscal.
    END.
    RELEASE int_dp_item_fiscal.

END PROCEDURE.


