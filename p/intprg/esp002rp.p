/************************************************************************************
 EverSoft Systems do Brasil - Todos os direitos Reservados. ( 2010 )
*************************************************************************************
 Empresa...: Administrador
 Programa..: c:\temp\cdp\esp002rp.p
 Titulo....: 
 Autor.....: Everton
 Nome......: Everton Luiz Henn
 Data......: 01/02/2017
*************************************************************************************
 Alteraá∆o.: 12/08/2023
 Autor.....: Eduardo Barth (KML)
 Descriá∆o.: Implementada coluna AM: Cesta B†sica (S/N) caso o item conste no INT121.
*************************************************************************************/

DISABLE TRIGGERS FOR LOAD OF ITEM. 

                             
/* Propriedade : WindowState (Estado da Janela) ********************************/
&global-define xlMaximized -4137    /* 01 - Maximinizada */                           
&global-define xlMinimized -4140    /* 02 - Minimizada */                             
&global-define xlNormal    -4143    /* 03 - Normal */                                 
                                                                                      
/* Propriedade : Cursor (Ponteiro do Mouse) ************************************/     
&global-define xlDefault        -4143   /* 01 - Padr∆o */                             
&global-define xlIBeam          3       /* 02 - Seleá∆o de Texto */                   
&global-define xlNorthwestArrow 1       /* 03 - Ponteiro */                           
&global-define xlWait           2       /* 04 - Espera */                             
                                                                                      
/* Propriedade : HorizontalAlignment (Alinhamento Horizontal) ******************/     
&global-define xlHAlignCenter       -4108  /* 01 - Centralizado */                    
&global-define xlHAlignDistributed  -4117  /* 02 - Distribu≠do */                     
&global-define xlHAlignJustify      -4130  /* 03 - Justificado */                     
&global-define xlHAlignLeft         -4131  /* 04 - Esquerda */                        
&global-define xlHAlignRight        -4152  /* 05 - Direita */                         
                                                                                      
/* Propriedade : LineStyle  (Estilo de Linha) **********************************/     
&global-define xlContinuous     1       /* 01 - Continua */                           
&global-define xlDash           -4115   /* 02 - Pontilhado */                         
&global-define xlDashDot        4       /* 03 - Ponto-Tra+o */                        
&global-define xlDashDotDot     5       /* 04 - Ponto-Ponto-Tra+o */                  
&global-define xlDot            -4118   /* 05 - Tra+o */                              
&global-define xlDouble         -4119   /* 06 - Dupla */                              
&global-define xlLineStyleNone  -4142   /* 07 - Vazio */                              
&global-define xlSlantDashDot   13      /* 08 - Ponto-Tra+o */                        
                                                                                      
/******** Variaveis utilizadas na planilha excel *********************************/   
                                                                                      
DEF VAR ch-Excel      AS office.iface.excel.ExcelWrapper NO-UNDO.                                   
DEF VAR ch-Arquivo    AS office.iface.excel.Workbook     NO-UNDO.                                 
DEF VAR ch-Planilha   AS office.iface.excel.WorkSheet    NO-UNDO.                                 
//DEF VAR ProcessHandle AS INTEGER          NO-UNDO.                                    
DEF VAR c-path-excel  AS CHAR             NO-UNDO FORMAT "x(256)".          
DEF VAR path          AS CHAR             NO-UNDO FORMAT "x(256)".          
DEF VAR c-titulo      AS CHAR             NO-UNDO.                                    
DEF VAR c-diretorio-destino    AS CHAR    NO-UNDO.                                    
DEF VAR i-cont-colun  AS INT              NO-UNDO.                                    
DEF VAR P-LABEL-REL2  AS CHAR             NO-UNDO.                                    
DEF VAR i-linha       AS INT              NO-UNDO.                                    
DEF VAR i-linha-atual AS INT              NO-UNDO.                                    
DEF VAR p-campo-rel2  AS CHAR             NO-UNDO.  
DEF VAR d-aliq        AS INT              NO-UNDO.
DEF VAR c-lista       AS CHAR             NO-UNDO.    
DEF VAR c-nome-novo   AS CHAR             NO-UNDO.
DEF VAR l-primeiro    AS LOG              NO-UNDO.
def var h-cdapi995    as handle           no-undo.
DEF VAR de-ali-pis    AS DEC              NO-UNDO.
DEF VAR de-ali-cofins AS DEC              NO-UNDO.
DEF VAR c-item-cesta  AS CHAR             NO-UNDO.
DEF VAR d-diferimento AS DEC              NO-UNDO.

DEF BUFFER b-item-uf  FOR item-uf.

{cdp/cdapi1001.i}
DEF VAR h-cdapi1001             AS WIDGET-HANDLE NO-UNDO.

/* KML - 16/01/2025 - FunccÖo para retornar aliquota interestadual de forma foráada */

FUNCTION fn-aliq-interestadual RETURNS DECIMAL
  ( fc-origem AS CHAR, fc-destino AS CHAR) : 
    
    DEFINE VARIABLE de-aliquota AS DECIMAL     NO-UNDO.
    
    IF fc-origem = fc-destino THEN
    DO:
    
        FIND FIRST unid-feder
            WHERE unid-feder.estado = fc-origem NO-ERROR.
            
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
 
{include/i-prgvrs.i "esp002rp.p" 2.00.00.001}
 
{include/i-rpvar.i }
 
define temp-table tt-digita NO-UNDO
       FIELD cod-estabel AS CHAR FORMAT "x(3)"
       index id is primary UNIQUE
       cod-estabel.
 
define temp-table TT-PARAM NO-UNDO
       field execucao           as INTEGER
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
       FIELD sem-subst-tribut   AS LOG.

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
    FIELD ies                           AS DEC                             /* 26-z */
    FIELD fm-codigo                     LIKE ITEM.fm-codigo                /* 27-aa */
    FIELD descricao                     LIKE familia.descricao             /* 28-ab */
    FIELD tributa-pis                   AS CHAR                            /* 29-ac */
    FIELD aliq-pis                      AS DEC                             /* 30-ad */
    FIELD tributa-cofins                AS CHAR                            /* 31-ae */
    FIELD aliq-cofins                   AS DEC                             /* 32-af */
    FIELD utiliza-pauta-fiscal          AS CHAR FORMAT "X(1)"              /* 33-ag */
    FIELD utiliza-mva-ajustada          AS CHAR FORMAT "X(1)"              /* 34-ah */
    FIELD valor-pauta-fiscal            AS DEC FORMAT "->>>,>>9.99"        /* 35-ai */
    FIELD cest-entrada                  AS CHAR                            /* 36-aj */
    FIELD cest-saida                    AS CHAR                            /* 37-ak */
    FIELD regime-especial-PR            AS CHAR                            /* 38-al */
    FIELD regime-especial-SP            AS CHAR                            /* 39-am */
    FIELD cesta-basica                  AS CHAR                            /* 40-am */
    INDEX id it-codigo estado cod-estado-orig.

def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.
 
define buffer b-tt-digita for tt-digita.

/* Transfer Definitions */
 
def temp-table tt-raw-digita NO-UNDO
field raw-digita      as raw.
 
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.
 
create tt-param.
raw-transfer raw-param to tt-param. 
 
def new global shared var I-EMPRESA as int no-undo.
find ems2mult.empresa no-lock where ems2mult.empresa.ep-codigo = v_cdn_empres_usuar no-error.
if  not avail ems2mult.empresa THEN return.
 
def var h-acomp as handle no-undo.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Processando...').
 
assign c-programa     = 'esp002rp.p'
       c-versao       = '2.00'
       c-revisao      = '000'
       c-empresa      = empresa.razao-social
       c-sistema      = 'Especifico'
       c-titulo-relat = 'Relatorio Excel '.
 
assign c-diretorio-destino = tt-param.ARQUIVO.

ASSIGN c-nome-novo =   "-" + string( TIME ) + ".xlsx" .

ASSIGN c-diretorio-destino = replace(c-diretorio-destino, ".tmp",   c-nome-novo ). 

IF NOT VALID-HANDLE (h-cdapi995)  THEN
   RUN cdp/cdapi995.p PERSISTENT SET h-cdapi995.

//run pi-exporta-excel.

run pi-exporta-csv.
                                                                                      
IF VALID-HANDLE(h-cdapi995) THEN DO:
   RUN pi-finalizar in h-cdapi995.
   ASSIGN h-cdapi995 = ?.
END.

if tt-param.execucao <> 2 then do:

	OS-COMMAND NO-WAIT VALUE("U:\ESP002.csv").
	
	
end.

run pi-finalizar in h-acomp.

return 'OK'.

/********************************************************************************************************************************************************************************************/
PROCEDURE pi-exporta-excel:                                                           
                                                                                      
/* find ems2log.empresa where ems2log.empresa.ep-codigo = param-global.empresa-prin no-lock no-error. */
/* if  avail ems2log.empresa then                                                                   */
/*     assign c-empresa = ems2log.empresa.razao-social.                                             */

FOR EACH tt-processo: DELETE tt-processo. END.
                                                                                      
RUN cria-tt-processo.

RUN openExcellApplication.

RUN novaPlanilha.

RUN gerarcabecalho.

RUN dadosplanilha.

//RUN fechaPlanilha (input c-diretorio-destino).

run closeExcelApplication.

//RUN WinExec (input string(c-path-excel + "\excel.exe " + c-diretorio-destino ), input 1 ).
                                                                                      
END PROCEDURE.



/* Exporta em CSV - Guilherme Nichele KML - 16/12/2024 *******************************************************************************************************************************************************************************************/

procedure pi-exporta-csv:

FOR EACH tt-processo: DELETE tt-processo. END.

RUN cria-tt-processo.

RUN pi-inicializar IN h-acomp (INPUT 'Excel...').


if tt-param.execucao <> 2 then do:

    output to value ("U:\ESP002.csv").
	
END.	
ELSE DO:

	output to value ("/mnt/shares/p/cjem8f/rpw/prod/rpw-fila2/ESP002.csv").
	
end.





FOR EACH tt-processo:
    
        .MESSAGE tt-processo.cod-estado-orig  SKIP
                tt-processo.estado           SKIP
                tt-processo.it-codigo        SKIP
                tt-processo.ies
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        run pi-acompanhar IN  h-acomp ( "Item:" + string(tt-processo.it-codigo) ).

        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "PR" THEN DO:
            find FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "PR"                  AND
                      item-uf.estado          = "PR" no-lock no-error.

            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.
        END.

        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "SC" THEN DO:
        
            find FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "SC"                  AND
                      item-uf.estado          = "SC" no-lock no-error.
                      
            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.
        END.

        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "SP" THEN DO:
        
            find FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "SP"                  AND
                      item-uf.estado          = "SP" no-lock no-error.
                      
            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.        
        END.
        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "GO" THEN DO:
        
            find FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "GO"                  AND
                      item-uf.estado          = "GO" no-lock no-error.
                      
            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.        
        END.
        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "DF" THEN DO:
            find FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "DF"                  AND
                      item-uf.estado          = "DF" no-lock no-error.
                      
            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.        
        END.

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

        IF tt-processo.fm-codigo = "203" THEN DO: /* Cesta B†sica */
           ASSIGN tt-processo.aliquota-icm-ali = tt-processo.ies
                  tt-processo.cd-trib-icm      = 2 
                  tt-processo.cd-trib-icm-tre  = 1 
                  tt-processo.aliquota-icm     = 0.
           find FIRST icms-it-uf WHERE 
                     icms-it-uf.it-codigo = tt-processo.it-codigo AND
                     icms-it-uf.estado    = tt-processo.estado no-lock no-error.
           IF AVAIL icms-it-uf THEN
              ASSIGN tt-processo.aliquota-icm-ale = icms-it-uf.aliquota-icm.
        END.

        FIND FIRST ITEM WHERE 
                  ITEM.it-codigo = tt-processo.it-codigo NO-ERROR.
                  
        IF AVAIL ITEM THEN DO:
           IF ITEM.fm-codigo = "102"
           OR ITEM.fm-codigo = "202"
           OR ITEM.fm-codigo = "402" THEN DO:
              ASSIGN ITEM.cd-trib-icm              = 2 /* Isento */
                     tt-processo.cd-trib-icm       = 2                       /*  7-g */ 
                     tt-processo.cd-trib-icm-tre   = 2                       /* 10-j */            
                     tt-processo.cd-trib-icm-tri   = 2                       /* 13-m */  
                     tt-processo.aliquota-icm      = 0                       /* H */   
                     tt-processo.aliquota-icm-ale  = 0                       /* K */   
                     tt-processo.aliquota-icm-ali  = 0                       /* N */
                     tt-processo.rast              = 0.                      /* T */
           END.
           ELSE DO:
              IF ITEM.fm-codigo >= "900" THEN DO:
                 ASSIGN ITEM.cd-trib-icm              = 3 /* Outros */
                        tt-processo.cd-trib-icm       = 3                    /*  7-g */
                        tt-processo.cd-trib-icm-tre   = 3                    /* 10-j */              
                        tt-processo.cd-trib-icm-tri   = 3                    /* 13-m */   
                        tt-processo.aliquota-icm      = 0                    /* H */
                        tt-processo.aliquota-icm-ale  = 0                    /* K */
                        tt-processo.aliquota-icm-ali  = 0                    /* N */
                        tt-processo.rast              = 0.                   /* T */
              END.
              ELSE DO:
                 ASSIGN ITEM.cd-trib-icm = 1. /* Tributado */
              END.
           END.
           find FIRST int_ds_ncm_produto WHERE 
                     int_ds_ncm_produto.ncm     = item.class-fiscal  AND
                     int_ds_ncm_produto.estado  = tt-processo.estado AND
                     int_ds_ncm_produto.produto = int(tt-processo.it-codigo) no-lock no-error.
           IF AVAIL int_ds_ncm_produto THEN DO:
              ASSIGN tt-processo.utiliza-pauta-fiscal = int_ds_ncm_produto.utiliza_pauta_fiscal
                     tt-processo.utiliza-mva-ajustada = int_ds_ncm_produto.utiliza_mva_ajustada.
           END.
           ASSIGN tt-processo.valor-pauta-fiscal = 0.
           
           
           find FIRST unid-feder no-lock where 
                     unid-feder.pais   = "Brasil" and
                     unid-feder.estado = tt-processo.estado no-error.
                     
           IF AVAIL unid-feder THEN DO:
              for each ems2mult.preco-item  use-index ch-tabitem no-lock where 
                       preco-item.nr-tabpre  = unid-feder.nr-tb-pauta and
                       preco-item.dt-inival <= today and
                       preco-item.it-codigo  = ITEM.it-codigo AND 
                       preco-item.situacao   = 1
                  break by preco-item.it-codigo
                        by preco-item.dt-inival:
                  if last-of(preco-item.dt-inival) THEN 
                     assign tt-processo.valor-pauta-fiscal = preco-item.preco-venda.
              end.
           END.
           RELEASE ITEM.
        END.

        IF (tt-processo.cod-estado-orig = "PR" AND tt-processo.estado = "PR") 
        OR (tt-processo.cod-estado-orig = ""   AND tt-processo.estado = "PR") THEN DO:         
           IF tt-processo.cd-trib-icm-tre = 1 THEN
              ASSIGN tt-processo.rede = tt-processo.rast.
                     //tt-processo.rast = 0.
        END.

        IF  tt-processo.cod-estado-orig = "PR" 
        AND tt-processo.estado          = "PR" THEN DO:
            find FIRST item-uf NO-LOCK where 
                 item-uf.it-codigo       = tt-processo.it-codigo AND
                 item-uf.cod-estado-orig = "SP"                  AND
                 item-uf.estado          = "PR" no-error.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.

        IF  tt-processo.cod-estado-orig = "SC" 
        AND tt-processo.estado          = "SC" THEN DO:
            find FIRST item-uf NO-LOCK where 
                 item-uf.it-codigo       = tt-processo.it-codigo AND
                 item-uf.cod-estado-orig = "PR"                  AND
                 item-uf.estado          = "SC" no-error.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.

        IF  tt-processo.cod-estado-orig = "SP" 
        AND tt-processo.estado          = "SP" THEN DO:
            find FIRST item-uf  NO-LOCK where 
                 item-uf.it-codigo       = tt-processo.it-codigo AND
                 item-uf.cod-estado-orig = "PR"                  AND
                 item-uf.estado          = "SP" no-error.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.

         IF  tt-processo.cod-estado-orig = "GO" 
        AND tt-processo.estado          = "GO" THEN DO:
            find FIRST item-uf  NO-LOCK where 
                 item-uf.it-codigo       = tt-processo.it-codigo AND
                 item-uf.cod-estado-orig = "PR"                  AND
                 item-uf.estado          = "GO" no-error.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END. 
        IF  tt-processo.cod-estado-orig = "DF" 
        AND tt-processo.estado          = "DF" THEN DO:
            find FIRST item-uf  NO-LOCK where 
                 item-uf.it-codigo       = tt-processo.it-codigo AND
                 item-uf.cod-estado-orig = "PR"                  AND
                 item-uf.estado          = "DF" no-error.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.
        
        IF  tt-processo.cod-estado-orig = ""     //Mike: Acrescentado validaá∆o de cd-trib-icm 3 (outros), chamado #0924-023201
        AND tt-processo.estado          = "SC" THEN DO:
            IF tt-processo.cd-trib-icm = 2 THEN
               ASSIGN tt-processo.aliquota-icm      = 0 
                       tt-processo.aliquota-icm-ale = 0 
                       tt-processo.rast             = 0.
            ELSE DO:
                   IF tt-processo.cd-trib-icm = 3 THEN
                   DO:
                     ASSIGN tt-processo.aliquota-icm  = 0 
                       tt-processo.aliquota-icm-ale   = 0 
                       tt-processo.rast               = 0.
                       
                   END.
/*                     ELSE                                            */
/*                                                                     */
/*                       MESSAGE "Antes ASSIGN"                        */
/*                           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
/*                ASSIGN tt-processo.aliquota-icm      = 17            */
/*                        tt-processo.aliquota-icm-ale = 17            */
/*                        tt-processo.rast             = 0.            */
           END.
        END.
    END.

    // CAMPO 39-Cesta B†sica? S/N
    FOR EACH tt-processo use-index id
        BREAK BY tt-processo.it-codigo
              BY tt-processo.cod-estado-orig
              BY tt-processo.estado:
        IF  FIRST-OF(tt-processo.estado) THEN DO:
            IF  tt-processo.cod-estado-orig = "" 
            OR  tt-processo.estado          = ""
            OR  tt-processo.it-codigo       = "" THEN
                ASSIGN c-item-cesta = "N".
            ELSE DO:
                IF  CAN-FIND(FIRST es-cesta-basica-item NO-LOCK USE-INDEX id_item_uf
                             WHERE es-cesta-basica-item.it-codigo  = tt-processo.it-codigo
                             AND   es-cesta-basica-item.uf-destino = tt-processo.estado
                             AND   es-cesta-basica-item.uf-origem  = tt-processo.cod-estado-orig) THEN
                    ASSIGN c-item-cesta = "S".
                ELSE
                    ASSIGN c-item-cesta = "N".
            END.
        END.
        ASSIGN tt-processo.cesta-basica = c-item-cesta.
    END.
 
    assign i-linha = 1.   

    PUT UNFORMATTED '"Codigo";"Descricao";"Grupo Estoque";"EAN";"Uf Origem";"Uf Destino";"TR";"ALIQ";"RED";"TR.E";"AL.E";"RED.E";"TR.I";"AL.I";"RED.I";"ST.E";"ST.I";"ICMS";"RBST";"RAST";"RBEST";"IPI";"LISTA";"NCM";"CSTA";"IES";"Familia";"Descricao";"Tributa PIS";"Aliq.PIS";"Tributa COFINS";"Aliq.COFINS";"Pauta Fiscal";"MVA Ajustada";"Valor Pauta";"CEST Ent";"CEST Sai";"Regime Especial PR";"Regime Especial SP";"Cesta Basica";"Status"' SKIP.

    
    FOR EACH tt-processo NO-LOCK USE-INDEX id:
    
        .MESSAGE tt-processo.it-codigo SKIP
                tt-processo.cod-estado-orig SKIP
                tt-processo.estado SKIP
                tt-processo.rast  
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        /* KML Consultoria - Kleber Mazepa - 16/01/2025 - Ajuste  ICMS interestadual*/ 
        IF tt-processo.cd-trib-icm = 1 OR tt-processo.cd-trib-icm = 5  THEN DO: /* Somente itens tributados e com dados de interestadual*/
        
            ASSIGN tt-processo.ies = fn-aliq-interestadual( tt-processo.cod-estado-orig , tt-processo.estado).
            
        END.
        
        //KML Consultoria - Guilherme Nichele - 14/04/2025 - 0125-013717 - ESP002, Ajuste campo ÀIESÃ 
        IF tt-processo.cod-estado-orig  = tt-processo.estado THEN
        DO:
            .MESSAGE "cod-estado-orig " tt-processo.cod-estado-orig SKIP "estado " tt-processo.estado
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
            ASSIGN tt-processo.ies  =   0.
            
        END.
        
        IF tt-processo.cod-estado-orig  = " " THEN
        DO:
                
            ASSIGN tt-processo.ies  =   0.
            
        END.
        
        IF tt-processo.csta = 1 
        AND tt-processo.ies <> 0 THEN
        DO:
        
            ASSIGN tt-processo.ies = 4.
            
        END.
        
        ASSIGN tt-processo.rast = 0.
        // KML Consultoria - Guilherme Nichele - 22/04/2025 - 0125-007554 - O campo apresenta valor incorreto "RED. E." ao gerar o ESP002 em massa
        FIND FIRST diferim-parcial-icms NO-LOCK
           WHERE diferim-parcial-icms.cod-item = tt-processo.it-codigo
           AND   diferim-parcial-icms.cod-estado = tt-processo.estado NO-ERROR.

        IF AVAIL diferim-parcial-icms THEN
        DO:
           
            ASSIGN tt-processo.rast = diferim-parcial-icms.val-perc-icms-diferim.

        END.
        
        //kml nichele
        
        DEFINE VARIABLE cRegimeEsp AS CHARACTER   NO-UNDO.
        
        IF tt-processo.estado = "PR" THEN
        DO:

            FOR EACH item-uni-estab NO-LOCK
                WHERE  item-uni-estab.cod-estabel = "973"
                  AND item-uni-estab.it-codigo   = tt-processo.it-codigo:
                  
                ASSIGN cRegimeEsp = SUBSTRING(item-uni-estab.char-2, 60, 1).

                /* Se estiver vazio, assume "N" */
                IF cRegimeEsp = "" THEN ASSIGN cRegimeEsp = "N".



                    
                ASSIGN tt-processo.regime-especial-PR = cRegimeEsp
                           tt-processo.regime-especial-SP = "N".
   
           END. 

        END.

        IF tt-processo.estado = "SP" THEN
        DO:

            FOR EACH item-uni-estab NO-LOCK
                WHERE  item-uni-estab.cod-estabel = "977"
                  AND item-uni-estab.it-codigo   = tt-processo.it-codigo:
                  
                ASSIGN cRegimeEsp = SUBSTRING(item-uni-estab.char-2, 60, 1).

                /* Se estiver vazio, assume "N" */
                IF cRegimeEsp = "" THEN ASSIGN cRegimeEsp = "N".

                ASSIGN tt-processo.regime-especial-SP = cRegimeEsp
                           tt-processo.regime-especial-PR = "N".

           END. 

        END. 
        
        

        run pi-acompanhar IN h-acomp ( "Item:" + string(tt-processo.it-codigo) ).

        ASSIGN i-linha = i-linha + 1. 
        
        
        
        export delimiter ";"
            tt-processo.it-codigo             /* 1-a  */
            tt-processo.desc-item             /* 2-b  */   
            tt-processo.ge-codigo             /* 3-c  */   
            tt-processo.codigo-ean            /* 4-d  */   
            tt-processo.cod-estado-orig       /* 5-e  */   
            tt-processo.estado                /* 6-f  */   
            tt-processo.cd-trib-icm           /* 7-g  */   
            tt-processo.aliquota-icm          /* 8-h  */   
            tt-processo.red                   /* 9-i  */   
            tt-processo.cd-trib-icm-tre       /* 10-j */   
            tt-processo.aliquota-icm-ale      /* 11-k */   
            tt-processo.rast                  /* 12-l */    
            tt-processo.cd-trib-icm-tri       /* 13-m */   
            tt-processo.aliquota-icm-ali      /* 14-n */   
            tt-processo.redi                  /* 15-o */   
            tt-processo.per-sub-tri-ste       /* 16-p */   
            tt-processo.per-sub-tri-sti       /* 17-q */   
            tt-processo.val-icms-est-sub      /* 18-r */   
            tt-processo.per-red-sub           /* 19-s */   
            tt-processo.rast                  /* 20-t */ // era tt-processo.rede   
            tt-processo.rbest                 /* 21-u */   
            tt-processo.aliquota-ipi          /* 22-v */   
            tt-processo.observacao            /* 23-w */   
            tt-processo.class-fiscal          /* 24-x */   
            tt-processo.csta                  /* 25-y */   
            tt-processo.ies                   /* 26-z */   
            tt-processo.fm-codigo             /* 27-aa */  
            tt-processo.descricao             /* 28-ab */  
            tt-processo.tributa-pis           /* 29-ac */  
            tt-processo.aliq-pis              /* 30-ad */  
            tt-processo.tributa-cofins        /* 31-ae */  
            tt-processo.aliq-cofins           /* 32-af */  
            tt-processo.utiliza-pauta-fiscal  /* 33-ag */  
            tt-processo.utiliza-mva-ajustada  /* 34-ah */  
            tt-processo.valor-pauta-fiscal    /* 35-ai */  
            tt-processo.cest-entrada          /* 36-aj */  
            tt-processo.cest-saida            /* 37-ak */  
            tt-processo.regime-especial-PR    /* 38-al */
            tt-processo.regime-especial-SP    /* 39-am */
            tt-processo.cesta-basica        .  /* 40-an */

    END.
    
end procedure.

                                                                                      
/* Abre um Objeto Excel para a Gera+ío do arquivo .xls **************************************************************************************************************************************/  
PROCEDURE openExcellApplication:                                                      
                                                                                      
    ASSIGN ch-Excel    = NEW office.libre.excel.ExcelWrapper().
           //ch-arquivo  = ch-Excel:workbooks:ADD().
    //ASSIGN Ch-planilha = ch-Excel:ActiveSheet.
          
                                                                                     
    //ASSIGN c-path-excel = ch-Excel:Path.  
                                                                                      
    //ASSIGN ProcessHandle = ch-Excel.                                                  
                                                                                      
    assign                                                                            
        ch-Excel:ScreenUpdating = NO.                                                 
        //ch-Excel:WindowState    = {&xlMinimized}.                         
        ch-Excel:Visible        = NO.                                                        
        //ch-Excel:Cursor         = {&xlWait}. 

                                                                                    
END PROCEDURE.                                                                        
                                                                                      
/* cria uma Nova Planilha Excel para a Gera+ío do arquivo .xlsx *******************************************************************************************************************************/  
PROCEDURE novaPlanilha:                                                               
                                                                                      
    DEF VAR iCol       AS DEC  NO-UNDO EXTENT 23.                                     
    DEF VAR i-contador AS INTE NO-UNDO.                                               
                                                                                      
    assign
        //ch-Excel    = NEW office.libre.excel.ExcelWrapper().
        ch-Excel:SheetsInNewWorkbook = 1.
        ch-Arquivo = ch-Excel:WorkBooks:Add().
                                                                                      
    assign                                                                            
        ch-Planilha                            = ch-Arquivo:Sheets:Item(1)        
        ch-Planilha:Name                       = 'esp002'.
                                                                                      
    //ch-Planilha:Activate().    

                                                                                   
END PROCEDURE.                                                                        
                                                                                      
/*  Gera a Planilha no Excel ****************************************************************************************************************************************************************/   
PROCEDURE gerarCabecalho:                                                             
                                                                                      
 RUN addCellPlan(1,  1 , "Codigo", yes, 2,10,1,2). 
 ch-planilha:cells(1,1):FONT:bold = YES.

 RUN addCellPlan(1,  2 , "Descricao", yes, 2,10,1,2). 
 ch-planilha:cells(1,2):FONT:bold = YES.

 RUN addCellPlan(1,  3 , "Grupo Estoque", yes, 2,10,1,2). 
 ch-planilha:cells(1,3):FONT:bold = YES.

 RUN addCellPlan(1,  4 , "EAN", yes, 2,10,1,2). 
 ch-planilha:cells(1,4):FONT:bold = YES.

 RUN addCellPlan(1,  5 , "Uf Origem", yes, 2,10,1,2). 
 ch-planilha:cells(1,5):FONT:bold = YES.

 RUN addCellPlan(1,  6 , "Uf Destino", yes, 2,10,1,2). 
 ch-planilha:cells(1,6):FONT:bold = YES.

 RUN addCellPlan(1,  7 , "TR", yes, 2,10,1,2). 
 ch-planilha:cells(1,7):FONT:bold = YES.

 RUN addCellPlan(1,  8 , "ALIQ", yes, 2,10,1,2). 
 ch-planilha:cells(1,8):FONT:bold = YES.

 RUN addCellPlan(1,  9 , "RED", yes, 2,10,1,2). 
 ch-planilha:cells(1,9):FONT:bold = YES.

 RUN addCellPlan(1,  10 , "TR.E", yes, 2,10,1,2). 
 ch-planilha:cells(1,10):FONT:bold = YES.

 RUN addCellPlan(1,  11 , "AL.E", yes, 2,10,1,2). 
 ch-planilha:cells(1,11):FONT:bold = YES.

 RUN addCellPlan(1,  12 , "RED.E", yes, 2,10,1,2). 
 ch-planilha:cells(1,12):FONT:bold = YES.
 
 RUN addCellPlan(1,  13 , "TR.I", yes, 2,10,1,2). 
 ch-planilha:cells(1,13):FONT:bold = YES.

 RUN addCellPlan(1,  14 , "AL.I", yes, 2,10,1,2). 
 ch-planilha:cells(1,14):FONT:bold = YES.

 RUN addCellPlan(1,  15 , "RED.I", yes, 2,10,1,2). 
 ch-planilha:cells(1,15):FONT:bold = YES.

 RUN addCellPlan(1,  16 , "ST.E", yes, 2,10,1,2). 
 ch-planilha:cells(1,16):FONT:bold = YES.

 RUN addCellPlan(1,  17 , "ST.I", yes, 2,10,1,2). 
 ch-planilha:cells(1,17):FONT:bold = YES.

 RUN addCellPlan(1,  18 , "ICMS", yes, 2,10,1,2). 
 ch-planilha:cells(1,18):FONT:bold = YES.

 RUN addCellPlan(1,  19 , "RBST", yes, 2,10,1,2). 
 ch-planilha:cells(1,19):FONT:bold = yes .

 RUN addCellPlan(1,  20 , "RAST", yes, 2,10,1,2). 
 ch-planilha:cells(1,20):FONT:bold = yes .

 RUN addCellPlan(1,  21 , "RBEST", yes, 2,10,1,2). 
 ch-planilha:cells(1,21):FONT:bold = yes .

 RUN addCellPlan(1,  22 , "IPI", yes, 2,10,1,2). 
 ch-planilha:cells(1,22):FONT:bold = yes . 
                                                                                      
 RUN addCellPlan(1,  23 , "LISTA", yes, 2,10,1,2). 
 ch-planilha:cells(1,23):FONT:bold = yes . 

 RUN addCellPlan(1,  24 , "NCM", yes, 2,10,1,2). 
 ch-planilha:cells(1,24):FONT:bold = yes . 

 RUN addCellPlan(1,  25 , "CSTA", yes, 2,10,1,2). 
 ch-planilha:cells(1,25):FONT:bold = yes . 

 RUN addCellPlan(1,  26 , "IES", yes, 2,10,1,2). 
 ch-planilha:cells(1,26):FONT:bold = yes . 

 RUN addCellPlan(1,  27 , "Familia", yes, 2,10,1,2). 
 ch-planilha:cells(1,27):FONT:bold = yes . 

 RUN addCellPlan(1,  28 , "Descricao", yes, 2,10,1,2). 
 ch-planilha:cells(1,28):FONT:bold = yes . 

 RUN addCellPlan(1,  29 , "Tributa PIS", yes, 2,10,1,2). 
 ch-planilha:cells(1,29):FONT:bold = yes .

 RUN addCellPlan(1,  30 , "Aliq.PIS", yes, 2,10,1,2). 
 ch-planilha:cells(1,30):FONT:bold = yes . 

 RUN addCellPlan(1,  31 , "Tributa COFINS", yes, 2,10,1,2). 
 ch-planilha:cells(1,31):FONT:bold = yes . 

 RUN addCellPlan(1,  32 , "Aliq.COFINS", yes, 2,10,1,2). 
 ch-planilha:cells(1,32):FONT:bold = yes . 

 RUN addCellPlan(1,  33 , "Pauta Fiscal", yes, 2,10,1,2). 
 ch-planilha:cells(1,33):FONT:bold = yes . 

 RUN addCellPlan(1,  34 , "MVA Ajustada", yes, 2,10,1,2). 
 ch-planilha:cells(1,34):FONT:bold = yes . 

 RUN addCellPlan(1,  35 , "Valor Pauta", yes, 2,10,1,2). 
 ch-planilha:cells(1,35):FONT:bold = yes . 

 RUN addCellPlan(1,  36 , "CEST Ent", yes, 2,10,1,2). 
 ch-planilha:cells(1,36):FONT:bold = yes . 

 RUN addCellPlan(1,  37 , "CEST Sai", yes, 2,10,1,2). 
 ch-planilha:cells(1,37):FONT:bold = yes . 

 RUN addCellPlan(1,  38 , "Regime Especial", yes, 2,10,1,2). 
 ch-planilha:cells(1,38):FONT:bold = yes . 

 RUN addCellPlan(1,  39 , "Cesta B†sica", yes, 2,10,1,2). 
 ch-planilha:cells(1,39):FONT:bold = yes . 
 
 RUN addCellPlan(1,  40 , "Status", yes, 2,10,1,2).  /*  a-Alteracao,  e-Exclusao ,  i-inclusao */
 ch-planilha:cells(1,40):FONT:bold = yes . 

END PROCEDURE.                                                                        
                                                                                      
/**Gera Linha na Planilha Excel***************************************************************************************************************************************************************/                                                                                      
PROCEDURE addCellPlan:                                                                
                                                                                      
    DEF INPUT PARAM iCelLinha      AS INTE NO-UNDO.                                   
    DEF INPUT PARAM iCelColun      AS INTE NO-UNDO.                                   
    DEF INPUT PARAM celValor       AS CHAR NO-UNDO.                                   
    DEF INPUT PARAM lNegrito       AS LOG  NO-UNDO.                                   
    DEF INPUT PARAM iAlinhaHoriz   AS INTE NO-UNDO.                                   
    DEF INPUT PARAM iFontSize      AS INTE NO-UNDO.                                   
    DEF INPUT PARAM iCorInterior   as INTE NO-UNDO.                                   
    DEF INPUT PARAM iCorFonte      as INTE NO-UNDO.                                   
                                                                                      
    ASSIGN ch-Planilha:Cells(iCelLinha, iCelColun ):NumberFormat = "@"
           ch-Planilha:Cells(iCelLinha, iCelColun ):Value = celValor.                 
                                                                                      
    ch-Planilha:Cells(iCelLinha, iCelColun):Font:Name = "Arial".            
    ch-Planilha:Cells(iCelLinha, iCelColun):Font:Size = iFontSize.                    
                                                                                      
    IF lNegrito THEN                                                                  
       ch-Planilha:Cells(iCelLinha, iCelColun):Font:Bold = YES.                       
                                                                                      
    case iAlinhaHoriz:                                                                
        when 1 then ch-Planilha:Cells(iCelLinha, iCelColun):HorizontalAlignment = {&xlHAlignLeft}.
        when 2 then ch-Planilha:Cells(iCelLinha, iCelColun):HorizontalAlignment = {&xlHAlignCenter}.
        when 3 then ch-Planilha:Cells(iCelLinha, iCelColun):HorizontalAlignment = {&xlHAlignRight}.
    end case.                                                                         
                                                                                      
    assign ch-Planilha:Cells(iCelLinha, iCelColun):Interior:ColorIndex = iCorInterior 
           ch-Planilha:Cells(iCelLinha, iCelColun):Font:ColorIndex = iCorFonte.       
                                                                                      
END PROCEDURE.                                                                        

/*********************************************************************************************************************************************************************************************/                                                                                      
PROCEDURE dadosplanilha:                                                              
                                                                                      
    RUN pi-inicializar IN h-acomp (INPUT 'Excel...').

    FOR EACH tt-processo:
    
        .MESSAGE tt-processo.cod-estado-orig  SKIP
                tt-processo.estado           SKIP
                tt-processo.it-codigo        SKIP
                tt-processo.ies
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        run pi-acompanhar IN  h-acomp ( "Item:" + string(tt-processo.it-codigo) ).

        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "PR" THEN DO:
            FOR FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "PR"                  AND
                      item-uf.estado          = "PR" NO-LOCK:
            END.
            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.
        END.

        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "SC" THEN DO:
            FOR FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "SC"                  AND
                      item-uf.estado          = "SC" NO-LOCK:
            END.
            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.
        END.

        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "SP" THEN DO:
            FOR FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "SP"                  AND
                      item-uf.estado          = "SP" NO-LOCK:
            END.
            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.        
        END.
        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "GO" THEN DO:
            FOR FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "GO"                  AND
                      item-uf.estado          = "GO" NO-LOCK:
            END.
            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.        
        END.
        IF  tt-processo.cod-estado-orig = "" 
        AND tt-processo.estado          = "DF" THEN DO:
            FOR FIRST item-uf WHERE   
                      item-uf.it-codigo       = tt-processo.it-codigo AND
                      item-uf.cod-estado-orig = "DF"                  AND
                      item-uf.estado          = "DF" NO-LOCK:
            END.
            IF AVAIL item-uf THEN DO:
               DELETE tt-processo.
               NEXT.
            END.        
        END.

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

        IF tt-processo.fm-codigo = "203" THEN DO: /* Cesta B†sica */
           ASSIGN tt-processo.aliquota-icm-ali = tt-processo.ies
                  tt-processo.cd-trib-icm      = 2 
                  tt-processo.cd-trib-icm-tre  = 1 
                  tt-processo.aliquota-icm     = 0.
           FOR FIRST icms-it-uf WHERE 
                     icms-it-uf.it-codigo = tt-processo.it-codigo AND
                     icms-it-uf.estado    = tt-processo.estado NO-LOCK:
           END.
           IF AVAIL icms-it-uf THEN
              ASSIGN tt-processo.aliquota-icm-ale = icms-it-uf.aliquota-icm.
        END.

        FIND FIRST ITEM WHERE 
                  ITEM.it-codigo = tt-processo.it-codigo NO-ERROR.
                  
        IF AVAIL ITEM THEN DO:
           IF ITEM.fm-codigo = "102"
           OR ITEM.fm-codigo = "202"
           OR ITEM.fm-codigo = "402" THEN DO:
              ASSIGN ITEM.cd-trib-icm              = 2 /* Isento */
                     tt-processo.cd-trib-icm       = 2                       /*  7-g */ 
                     tt-processo.cd-trib-icm-tre   = 2                       /* 10-j */            
                     tt-processo.cd-trib-icm-tri   = 2                       /* 13-m */  
                     tt-processo.aliquota-icm      = 0                       /* H */   
                     tt-processo.aliquota-icm-ale  = 0                       /* K */   
                     tt-processo.aliquota-icm-ali  = 0                       /* N */
                     tt-processo.rast              = 0.                      /* T */
           END.
           ELSE DO:
              IF ITEM.fm-codigo >= "900" THEN DO:
                 ASSIGN ITEM.cd-trib-icm              = 3 /* Outros */
                        tt-processo.cd-trib-icm       = 3                    /*  7-g */
                        tt-processo.cd-trib-icm-tre   = 3                    /* 10-j */              
                        tt-processo.cd-trib-icm-tri   = 3                    /* 13-m */   
                        tt-processo.aliquota-icm      = 0                    /* H */
                        tt-processo.aliquota-icm-ale  = 0                    /* K */
                        tt-processo.aliquota-icm-ali  = 0                    /* N */
                        tt-processo.rast              = 0.                   /* T */
              END.
              ELSE DO:
                 ASSIGN ITEM.cd-trib-icm = 1. /* Tributado */
              END.
           END.
           FOR FIRST int_ds_ncm_produto WHERE 
                     int_ds_ncm_produto.ncm     = item.class-fiscal  AND
                     int_ds_ncm_produto.estado  = tt-processo.estado AND
                     int_ds_ncm_produto.produto = int(tt-processo.it-codigo) NO-LOCK:
           END.
           IF AVAIL int_ds_ncm_produto THEN DO:
              ASSIGN tt-processo.utiliza-pauta-fiscal = int_ds_ncm_produto.utiliza_pauta_fiscal
                     tt-processo.utiliza-mva-ajustada = int_ds_ncm_produto.utiliza_mva_ajustada.
           END.
           ASSIGN tt-processo.valor-pauta-fiscal = 0.
           FOR FIRST unid-feder no-lock where 
                     unid-feder.pais   = "Brasil" and
                     unid-feder.estado = tt-processo.estado:
           END.
           IF AVAIL unid-feder THEN DO:
              for each ems2mult.preco-item no-lock where 
                       preco-item.nr-tabpre  = unid-feder.nr-tb-pauta and
                       preco-item.dt-inival <= today and
                       preco-item.it-codigo  = ITEM.it-codigo AND 
                       preco-item.situacao   = 1
                  break by preco-item.it-codigo
                        by preco-item.dt-inival:
                  if last-of(preco-item.dt-inival) THEN 
                     assign tt-processo.valor-pauta-fiscal = preco-item.preco-venda.
              end.
           END.
           RELEASE ITEM.
        END.

        IF (tt-processo.cod-estado-orig = "PR" AND tt-processo.estado = "PR") 
        OR (tt-processo.cod-estado-orig = ""   AND tt-processo.estado = "PR") THEN DO:         
           IF tt-processo.cd-trib-icm-tre = 1 THEN
              ASSIGN tt-processo.rede = tt-processo.rast.
                     //tt-processo.rast = 0.
        END.

        IF  tt-processo.cod-estado-orig = "PR" 
        AND tt-processo.estado          = "PR" THEN DO:
            FOR FIRST item-uf FIELDS (item-uf.it-codigo item-uf.per-sub-tri) NO-LOCK where 
                                      item-uf.it-codigo       = tt-processo.it-codigo AND
                                      item-uf.cod-estado-orig = "SP"                  AND
                                      item-uf.estado          = "PR":
            END.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.

        IF  tt-processo.cod-estado-orig = "SC" 
        AND tt-processo.estado          = "SC" THEN DO:
            FOR FIRST item-uf FIELDS (item-uf.it-codigo item-uf.per-sub-tri) NO-LOCK where 
                                      item-uf.it-codigo       = tt-processo.it-codigo AND
                                      item-uf.cod-estado-orig = "PR"                  AND
                                      item-uf.estado          = "SC":
            END.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.

        IF  tt-processo.cod-estado-orig = "SP" 
        AND tt-processo.estado          = "SP" THEN DO:
            FOR FIRST item-uf FIELDS (item-uf.it-codigo item-uf.per-sub-tri) NO-LOCK where 
                                      item-uf.it-codigo       = tt-processo.it-codigo AND
                                      item-uf.cod-estado-orig = "PR"                  AND
                                      item-uf.estado          = "SP":
            END.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.

         IF  tt-processo.cod-estado-orig = "GO" 
        AND tt-processo.estado          = "GO" THEN DO:
            FOR FIRST item-uf FIELDS (item-uf.it-codigo item-uf.per-sub-tri) NO-LOCK where 
                                      item-uf.it-codigo       = tt-processo.it-codigo AND
                                      item-uf.cod-estado-orig = "PR"                  AND
                                      item-uf.estado          = "GO":
            END.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END. 
        IF  tt-processo.cod-estado-orig = "DF" 
        AND tt-processo.estado          = "DF" THEN DO:
            FOR FIRST item-uf FIELDS (item-uf.it-codigo item-uf.per-sub-tri) NO-LOCK where 
                                      item-uf.it-codigo       = tt-processo.it-codigo AND
                                      item-uf.cod-estado-orig = "PR"                  AND
                                      item-uf.estado          = "DF":
            END.
            IF AVAIL item-uf THEN
               ASSIGN tt-processo.per-sub-tri-sti = item-uf.per-sub-tri. /* 17-q */
        END.
        
        IF  tt-processo.cod-estado-orig = ""     //Mike: Acrescentado validaá∆o de cd-trib-icm 3 (outros), chamado #0924-023201
        AND tt-processo.estado          = "SC" THEN DO:
            IF tt-processo.cd-trib-icm = 2 THEN
               ASSIGN tt-processo.aliquota-icm      = 0 
                       tt-processo.aliquota-icm-ale = 0 
                       tt-processo.rast             = 0.
            ELSE DO:
                   IF tt-processo.cd-trib-icm = 3 THEN
                   DO:
                     ASSIGN tt-processo.aliquota-icm  = 0 
                       tt-processo.aliquota-icm-ale   = 0 
                       tt-processo.rast               = 0.
                       
                   END.
/*                     ELSE                                            */
/*                                                                     */
/*                       MESSAGE "Antes ASSIGN"                        */
/*                           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
/*                ASSIGN tt-processo.aliquota-icm      = 17            */
/*                        tt-processo.aliquota-icm-ale = 17            */
/*                        tt-processo.rast             = 0.            */
           END.
        END.
    END.

    // CAMPO 39-Cesta B†sica? S/N
    FOR EACH tt-processo
        BREAK BY tt-processo.it-codigo
              BY tt-processo.cod-estado-orig
              BY tt-processo.estado:
        IF  FIRST-OF(tt-processo.estado) THEN DO:
            IF  tt-processo.cod-estado-orig = "" 
            OR  tt-processo.estado          = ""
            OR  tt-processo.it-codigo       = "" THEN
                ASSIGN c-item-cesta = "N".
            ELSE DO:
                IF  CAN-FIND(FIRST es-cesta-basica-item NO-LOCK USE-INDEX id_item_uf
                             WHERE es-cesta-basica-item.it-codigo  = tt-processo.it-codigo
                             AND   es-cesta-basica-item.uf-destino = tt-processo.estado
                             AND   es-cesta-basica-item.uf-origem  = tt-processo.cod-estado-orig) THEN
                    ASSIGN c-item-cesta = "S".
                ELSE
                    ASSIGN c-item-cesta = "N".
            END.
        END.
        ASSIGN tt-processo.cesta-basica = c-item-cesta.
    END.
    

    assign i-linha = 1.   

    FOR EACH tt-processo USE-INDEX id:
    
    
        .MESSAGE tt-processo.it-codigo SKIP
                tt-processo.cod-estado-orig SKIP
                tt-processo.estado SKIP
                tt-processo.ies  SKIP
                fn-aliq-interestadual( tt-processo.cod-estado-orig , tt-processo.estado)
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        /* KML Consultoria - Kleber Mazepa - 16/01/2025 - Ajuste  ICMS interestadual*/ 
        IF tt-processo.cd-trib-icm = 1  THEN DO: /* Somente itens tributados e com dados de interestadual*/
        
            ASSIGN tt-processo.ies = fn-aliq-interestadual( tt-processo.cod-estado-orig , tt-processo.estado).
            
        END.

        run pi-acompanhar IN h-acomp ( "Item:" + string(tt-processo.it-codigo) ).

        ASSIGN i-linha = i-linha + 1. 
        
        RUN addCellPlan(i-linha, 1  , tt-processo.it-codigo           ,NO, 1,9,2,1).  /* 1-a  */
        run addCellPlan(i-linha, 2  , tt-processo.desc-item           ,no, 1,9,2,1).  /* 2-b  */   
        run addCellPlan(i-linha, 3  , tt-processo.ge-codigo           ,no, 1,9,2,1).  /* 3-c  */   
        run addCellPlan(i-linha, 4  , tt-processo.codigo-ean          ,no, 1,9,2,1).  /* 4-d  */   
        run addCellPlan(i-linha, 5  , tt-processo.cod-estado-orig     ,no, 1,9,2,1).  /* 5-e  */   
        run addCellPlan(i-linha, 6  , tt-processo.estado              ,no, 1,9,2,1).  /* 6-f  */   
        run addCellPlan(i-linha, 7  , tt-processo.cd-trib-icm         ,no, 1,9,2,1).  /* 7-g  */   
        run addCellPlan(i-linha, 8  , tt-processo.aliquota-icm        ,no, 1,9,2,1).  /* 8-h  */   
        run addCellPlan(i-linha, 9  , tt-processo.red                 ,no, 1,9,2,1).  /* 9-i  */   
        run addCellPlan(i-linha, 10 , tt-processo.cd-trib-icm-tre     ,no, 1,9,2,1).  /* 10-j */   
        run addCellPlan(i-linha, 11 , tt-processo.aliquota-icm-ale    ,no, 1,9,2,1).  /* 11-k */   
        run addCellPlan(i-linha, 12 , tt-processo.rast                ,no, 1,9,2,1).  /* 12-l */    
        run addCellPlan(i-linha, 13 , tt-processo.cd-trib-icm-tri     ,no, 1,9,2,1).  /* 13-m */   
        run addCellPlan(i-linha, 14 , tt-processo.aliquota-icm-ali    ,no, 1,9,2,1).  /* 14-n */   
        run addCellPlan(i-linha, 15 , tt-processo.redi                ,no, 1,9,2,1).  /* 15-o */   
        run addCellPlan(i-linha, 16 , tt-processo.per-sub-tri-ste     ,no, 1,9,2,1).  /* 16-p */   
        run addCellPlan(i-linha, 17 , tt-processo.per-sub-tri-sti     ,no, 1,9,2,1).  /* 17-q */   
        run addCellPlan(i-linha, 18 , tt-processo.val-icms-est-sub    ,no, 1,9,2,1).  /* 18-r */   
        run addCellPlan(i-linha, 19 , tt-processo.per-red-sub         ,no, 1,9,2,1).  /* 19-s */   
        run addCellPlan(i-linha, 20 , tt-processo.rast                ,no, 1,9,2,1).  /* 20-t */ // era tt-processo.rede   
        run addCellPlan(i-linha, 21 , tt-processo.rbest               ,no, 1,9,2,1).  /* 21-u */   
        run addCellPlan(i-linha, 22 , tt-processo.aliquota-ipi        ,no, 1,9,2,1).  /* 22-v */   
        run addCellPlan(i-linha, 23 , tt-processo.observacao          ,no, 1,9,2,1).  /* 23-w */   
        run addCellPlan(i-linha, 24 , tt-processo.class-fiscal        ,no, 1,9,2,1).  /* 24-x */   
        run addCellPlan(i-linha, 25 , tt-processo.csta                ,no, 1,9,2,1).  /* 25-y */   
        run addCellPlan(i-linha, 26 , tt-processo.ies                 ,no, 1,9,2,1).  /* 26-z */   
        run addCellPlan(i-linha, 27 , tt-processo.fm-codigo           ,no, 1,9,2,1).  /* 27-aa */  
        run addCellPlan(i-linha, 28 , tt-processo.descricao           ,no, 1,9,2,1).  /* 28-ab */  
        run addCellPlan(i-linha, 29 , tt-processo.tributa-pis         ,no, 1,9,2,1).  /* 29-ac */  
        run addCellPlan(i-linha, 30 , tt-processo.aliq-pis            ,no, 1,9,2,1).  /* 30-ad */  
        run addCellPlan(i-linha, 31 , tt-processo.tributa-cofins      ,no, 1,9,2,1).  /* 31-ae */  
        run addCellPlan(i-linha, 32 , tt-processo.aliq-cofins         ,no, 1,9,2,1).  /* 32-af */  
        run addCellPlan(i-linha, 33 , tt-processo.utiliza-pauta-fiscal,no, 1,9,2,1).  /* 33-ag */  
        run addCellPlan(i-linha, 34 , tt-processo.utiliza-mva-ajustada,no, 1,9,2,1).  /* 34-ah */  
        run addCellPlan(i-linha, 35 , tt-processo.valor-pauta-fiscal  ,no, 1,9,2,1).  /* 35-ai */  
        run addCellPlan(i-linha, 36 , tt-processo.cest-entrada        ,no, 1,9,2,1).  /* 36-aj */  
        run addCellPlan(i-linha, 37 , tt-processo.cest-saida          ,no, 1,9,2,1).  /* 37-ak */  
        //run addCellPlan(i-linha, 38 , tt-processo.regime-especial     ,no, 1,9,2,1).  /* 38-al */
        run addCellPlan(i-linha, 39 , tt-processo.cesta-basica        ,no, 1,9,2,1).  /* 39-am */

    END.
                                                                                      
END PROCEDURE.                                                                        
                                                                                      
/*********************************************************************************************************************************************************************************************/                                                                                      
PROCEDURE cria-tt-processo: 

    IF NOT VALID-HANDLE(h-cdapi1001) THEN
        RUN cdp/cdapi1001.p     PERSISTENT SET h-cdapi1001.

    FOR EACH item WHERE 
             ITEM.it-codigo      >= TT-PARAM.it-codigo-ini   AND 
             ITEM.it-codigo      <= TT-PARAM.it-codigo-fim   AND
             ITEM.ge-codigo      >= tt-param.ge-codigo-ini   AND
             ITEM.ge-codigo      <= tt-param.ge-codigo-fim   AND
             ITEM.fm-codigo      >= tt-param.fm-codigo-ini   AND
             ITEM.fm-codigo      <= tt-param.fm-codigo-fim   and
             item.class-fiscal   >= tt-param.clas-fiscal-ini AND
             item.class-fiscal   <= tt-param.clas-fiscal-fim AND 
             item.codigo-orig    >= tt-param.cst-ini         AND
             item.codigo-orig    <= tt-param.cst-fim         AND 
             item.cod-obsoleto   = 1  USE-INDEX codigo  NO-LOCK:
                
                
        run pi-acompanhar IN h-acomp ( "Item:" + string(ITEM.it-codigo) ).

        ASSIGN l-primeiro = YES.
                       

        /* INICIO ITEM-UF ******************************************************************************************************************************************************************/
        for each item-uf  NO-LOCK where 
                 ITEM-UF.IT-CODIGO        = ITEM.IT-CODIGO              AND
                 ITEM-UF.COD-ESTADO-ORIG <> ""                          AND
                 ITEM-UF.ESTADO          <> ""                          AND
                 item-uf.cod-estab       >= TT-PARAM.cod-estab-ini      AND 
                 item-uf.cod-estab       <= TT-PARAM.cod-estab-fim      and             
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
                   
           RUN pi-grava-item (INPUT NO ) .
           
                   
           FIND FIRST unid-feder WHERE 
                      unid-feder.pais      = item-uf.pais AND
                      unid-feder.estado    = item-uf.estado  NO-LOCK NO-ERROR.

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
                                   b-item-uf.cod-estab       >= TT-PARAM.cod-estab-ini      AND 
                                   b-item-uf.cod-estab       <= TT-PARAM.cod-estab-fim      AND 
                                   b-ITEM-UF.ESTADO           = item-uf.estado              AND   /* estado destino igual, estado origem diferente */
                                   b-ITEM-UF.COD-ESTADO-ORIG  = item-uf.estado              :

                              ASSIGN tt-processo.per-sub-tri-ste = B-item-uf.per-sub-tri.   /* 16-p */ 
                              
                         END.
                     END.

                     FOR FIRST b-item-uf FIELDS (  it-codigo cod-estab per-sub-tri ) NO-LOCK where 
                               b-ITEM-UF.IT-CODIGO        = ITEM.IT-CODIGO              AND
                               b-item-uf.cod-estab       >= TT-PARAM.cod-estab-ini      AND 
                               b-item-uf.cod-estab       <= TT-PARAM.cod-estab-fim      AND 
                               b-ITEM-UF.ESTADO           = item-uf.estado              AND   /* estado destino igual, estado origem diferente */
                               b-ITEM-UF.COD-ESTADO-ORIG /*<>*/ = item-uf.cod-estado-orig:

                           ASSIGN tt-processo.per-sub-tri-sti = b-item-uf.per-sub-tri. /* 17-q */
                             
                     END.
                  END.

              END.
           END.
               
           //VERIFICAR SE REALMENTE O PONTO ê ESTE KML LOHAN
          
             
             ASSIGN tt-processo.val-icms-est-sub  = item-uf.dec-1         /* 18-r */
                    tt-processo.per-red-sub       = item-uf.perc-red-sub  /* 19-s */  
                    tt-processo.rast              = 0 //ERA 0             /* 20-t */              
                    tt-processo.rbest             = 0.                    /* 21-u */
           
           
          
           
                 
                     
/*            IF item-uf.perc-red-sub /* 19-s */  <> 0 THEN DO:                                          */
/*                                                                                                       */
/*                IF ITEM-UF.ESTADO          = "PR" AND                                                  */
/*                   ITEM-UF.COD-ESTADO-ORIG = "PR" THEN DO:                                             */
/*                                                                                                       */
/*                   IF      item-uf.dec-1      = 18 THEN ASSIGN tt-processo.rbest = 33.33.   /* 21-u */ */
/*                   ELSE IF item-uf.dec-1      = 25 THEN ASSIGN tt-processo.rbest = 52.      /* 21-u */ */
/*                                                                                                       */
/*                END.                                                                                   */
/*                                                                                                       */
/*                                                                                                       */
/*            END.                                                                                       */
/*            ELSE DO:                                                                                   */
/*                                                                                                       */
/*                IF ITEM-UF.ESTADO          = "PR" AND                                                  */
/*                   ITEM-UF.COD-ESTADO-ORIG = "PR" THEN DO:                                             */
/*                                                                                                       */
/*                   IF      item-uf.dec-1      = 18 THEN ASSIGN tt-processo.rast = 33.33.   /* 20-t */  */
/*                   ELSE IF item-uf.dec-1      = 25 THEN ASSIGN tt-processo.rast = 52.      /* 20-t */  */
/*                                                                                                       */
/*                END.                                                                                   */
/*                                                                                                       */
/*            END.                                                                                       */

           ASSIGN l-primeiro = YES. /* era NO - foi alterado */                                                                 
        
        END.  
        /* FINAL ITEM-UF **********************************************************************************************************************************************************************/

        IF L-PRIMEIRO = YES THEN DO: /* NAO ENCONTROU REGISTRO DO ITEM CADASTRADO NO CD0904A - ITEM-UF */ /* PRECISAMOS DUPLICAR O REGISTRO CASO TENHA SIDO FLEGADO MAIS DE UM ESTADO DESTINO */

           RUN pi-grava-item (INPUT YES ) . 

           
           
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

               ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "SP" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */

           END.
            ELSE IF tt-param.tg-pr-dest = YES AND
                   tt-param.tg-sp-dest = NO  AND
                   tt-param.tg-sc-dest = YES AND
                   tt-param.tg-go-dest = NO  AND
                   tt-param.tg-df-dest = NO   THEN DO:

               ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "SC" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */

           END.
           ELSE IF tt-param.tg-pr-dest = NO  AND
                   tt-param.tg-sp-dest = YES AND
                   tt-param.tg-sc-dest = YES AND
                   tt-param.tg-go-dest = NO  AND
                   tt-param.tg-df-dest = NO  THEN DO:

               ASSIGN tt-processo.estado = "SP". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "SC" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */

           END.
           ELSE IF tt-param.tg-pr-dest = YES AND
                   tt-param.tg-sp-dest = YES AND
                   tt-param.tg-sc-dest = YES AND
                   tt-param.tg-go-dest = NO  AND
                   tt-param.tg-df-dest = NO  THEN DO:

               ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "SP" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */
               RUN pi-repete-item( INPUT "SC" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */

           END.
           ELSE IF tt-param.tg-pr-dest = YES  AND
                   tt-param.tg-sp-dest = NO   AND
                   tt-param.tg-sc-dest = NO   AND
                   tt-param.tg-go-dest = YES  AND
                   tt-param.tg-df-dest = NO   THEN DO:

               ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "GO" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */

           END.
           ELSE IF tt-param.tg-pr-dest = YES  AND
                   tt-param.tg-sp-dest = NO   AND
                   tt-param.tg-sc-dest = NO   AND
                   tt-param.tg-go-dest = NO   AND
                   tt-param.tg-df-dest = YES  THEN DO:

               ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "DF" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */

           END.
           ELSE IF tt-param.tg-pr-dest = NO  AND
                   tt-param.tg-sp-dest = YES AND
                   tt-param.tg-sc-dest = YES AND
                   tt-param.tg-go-dest = NO  AND
                   tt-param.tg-df-dest = NO  THEN DO:

               ASSIGN tt-processo.estado = "SP". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "SC" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */

           END.
           ELSE IF tt-param.tg-pr-dest = YES AND
                   tt-param.tg-sp-dest = YES AND
                   tt-param.tg-sc-dest = YES AND
                   tt-param.tg-go-dest = NO  AND
                   tt-param.tg-df-dest = NO  THEN DO:

               ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "SP" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */
               RUN pi-repete-item( INPUT "SC" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */

           END.
           ELSE IF tt-param.tg-pr-dest = YES AND
                   tt-param.tg-sp-dest = YES AND
                   tt-param.tg-sc-dest = YES AND
                   tt-param.tg-go-dest = YES AND
                   tt-param.tg-df-dest = NO  THEN DO:

               ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "SP" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */
               RUN pi-repete-item( INPUT "SC" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */
               RUN pi-repete-item( INPUT "GO" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */

           END.
           ELSE IF tt-param.tg-pr-dest = YES AND
                   tt-param.tg-sp-dest = YES AND 
                   tt-param.tg-sc-dest = YES AND 
                   tt-param.tg-go-dest = YES AND
                   tt-param.tg-df-dest = YES THEN DO:
                   
  
               ASSIGN tt-processo.estado = "PR". /*  6- uf estado destino */

               RUN pi-repete-item( INPUT "SP" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */  
               RUN pi-repete-item( INPUT "SC" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */ 
               RUN pi-repete-item( INPUT "GO" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */ 
               RUN pi-repete-item( INPUT "DF" ). /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a - item-uf , ou seja 1,2,3,4 e nunca 5 */ 

           
           
               
               
               
           END. 
           
           
           
        END.
        
        
        
        //Lohan KML bloco de alteraá∆o ICMS DIFERIM 13/12/2024
               
        FOR EACH tt-processo use-index id:
        
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

           
           
            /*FOR EACH item-uni-estab NO-LOCK
                WHERE  item-uni-estab.cod-estabel >= TT-PARAM.cod-estab-ini
                  AND item-uni-estab.cod-estabel <= TT-PARAM.cod-estab-fim
                  AND item-uni-estab.it-codigo   = tt-processo.it-codigo:
                  
                ASSIGN cRegimeEsp = SUBSTRING(item-uni-estab.char-2, 60, 1).

                /* Se estiver vazio, assume "N" */
                IF cRegimeEsp = "" THEN ASSIGN cRegimeEsp = "N".
                
                .MESSAGE item-uni-estab.cod-estabel
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
                IF item-uni-estab.cod-estabel = "973" THEN
                DO:
                    MESSAGE "entrou 973"
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                    
                    ASSIGN tt-processo.regime-especial-PR = cRegimeEsp
                               tt-processo.regime-especial-SP = "N".
                    
                END.
                 
                  
           END. */
           
        END.
        
    END. 

END PROCEDURE.                                                                        


/*  Fecha o Objeto Excel ********************************************************************************************************************************************************************/  
PROCEDURE closeExcelApplication:

     FIND FIRST tt-param NO-LOCK NO-ERROR.

     IF tt-param.execucao <> 2 THEN DO:
	    ch-Excel:VISIBLE = YES.
		ch-Excel:ScreenUpdating = TRUE.
     END.
     ELSE DO:
        ch-Excel:VISIBLE = FALSE.
        ch-Excel:ScreenUpdating = TRUE.
		ch-Excel:ActiveWorkbook:SaveAs("D:\Shares\Nissei\RPW\prod\rpw-fila3\" + "ESP002.xlsx",51).
     END.	 
     //ch-Excel:QUIT().

    ASSIGN ch-Excel    = ? NO-ERROR.                                                                                                                                                  
                                                                                      
/*     ASSIGN ch-Excel    = ? NO-ERROR. */
/*     ASSIGN ch-arquivo  = ? NO-ERROR. */
/*     ASSIGN ch-Planilha = ? NO-ERROR. */

   
    //ASSIGN path = c-path-excel + "\EXCEL.EXE".  
                                                                                        
END PROCEDURE.                                                                        
                                                                                      
/*  Fecha Planilha **************************************************************************************************************************************************************************/     
PROCEDURE fechaPlanilha:                                                              
                                                                                      
    DEF INPUT PARAM pArquivo AS CHAR NO-UNDO.  
      
    ASSIGN ch-arquivo = ? NO-ERROR.

    if search(pArquivo) <> ? THEN OS-DELETE VALUE(pArquivo).
                                                                                      
    ch-Arquivo:CLOSE(YES, pArquivo). 
                                                                                                                                                                                                                                       
END PROCEDURE.    

/********************************************************************************************************************************************************************************************/

PROCEDURE pi-repete-item:  /* pi-repete-item e executado somente quando nao esta cadastrado no cd0904a = 5 - item-uf , ou seja 1,2,3,4 */  
    
    DEF INPUT PARAM p-estado AS CHAR NO-UNDO.
    DEF VAR cRegimeEsp AS CHAR NO-UNDO.

    CREATE tt-processo.
    ASSIGN tt-processo.it-codigo   = ITEM.it-codigo                  /* 1-a  */ 
           tt-processo.desc-item   = ITEM.desc-item                  /* 2-b  */  
           tt-processo.ge-codigo   = ITEM.ge-codigo.                 /* 3-c  */    

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
        IF string(tt-sit-tribut.cdn-sit-tribut) <> "0" THEN DO:
             ASSIGN tt-processo.cest-entrada = string(tt-sit-tribut.cdn-sit-tribut).
        END.
        ELSE DO:

            FOR FIRST sit-tribut-relacto NO-LOCK
                WHERE sit-tribut-relacto.cod-item = ITEM.it-codigo
                  AND sit-tribut-relacto.idi-tip-docto = 1:
            
                ASSIGN tt-processo.cest-entrada = string(sit-tribut-relacto.cdn-sit-tribut).
           END.
        END.
       
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
        IF string(tt-sit-tribut.cdn-sit-tribut) <> "0" THEN DO:
            ASSIGN tt-processo.cest-saida = string(tt-sit-tribut.cdn-sit-tribut).
        END.
     /*   ELSE DO:

            FOR FIRST sit-tribut-relacto NO-LOCK
                WHERE sit-tribut-relacto.cod-item = ITEM.it-codigo
                  AND sit-tribut-relacto.idi-tip-docto = 2:

                ASSIGN tt-processo.cest-saida = string(sit-tribut-relacto.cdn-sit-tribut).
           END.
        END.*/
    END.

    FIND FIRST int_ds_ean_item WHERE
               int_ds_ean_item.it_codigo = ITEM.it-codigo NO-LOCK NO-ERROR.
    IF AVAIL   int_ds_ean_item THEN  
       ASSIGN tt-processo.codigo-ean  =  int_ds_ean_item.codigo_ean. /* 4-d  */
       
   // FIND FIRST item-uni-estab NO-LOCK
   //     WHERE  item-uni-estab.it-codigo   = ITEM.it-codigo NO-ERROR.
         

    ASSIGN tt-processo.estado          = p-estado           
           tt-processo.cd-trib-icm     = ITEM.cd-trib-icm            /* 7-g  */ 
           tt-processo.cd-trib-icm-tre = ITEM.cd-trib-icm            /* 10-j */  
           tt-processo.cd-trib-icm-tri = ITEM.cd-trib-icm            /* 13-m */     
                      
           . /* 37-al */

           
    //kml
      
   IF tt-processo.estado = "PR" THEN
   DO:
   
        FOR EACH item-uni-estab NO-LOCK
            WHERE  item-uni-estab.cod-estabel = "973"
              AND item-uni-estab.it-codigo   = tt-processo.it-codigo:
              
            ASSIGN cRegimeEsp = SUBSTRING(item-uni-estab.char-2, 60, 1).

            /* Se estiver vazio, assume "N" */
            IF cRegimeEsp = "" THEN ASSIGN cRegimeEsp = "N".



                
            ASSIGN tt-processo.regime-especial-PR = cRegimeEsp
                       tt-processo.regime-especial-SP = "N".
                

             
              
       END. 

   END.
   
   IF tt-processo.estado = "SP" THEN
   DO:
   
        FOR EACH item-uni-estab NO-LOCK
            WHERE  item-uni-estab.cod-estabel = "977"
              AND item-uni-estab.it-codigo   = tt-processo.it-codigo:
              
            ASSIGN cRegimeEsp = SUBSTRING(item-uni-estab.char-2, 60, 1).

            /* Se estiver vazio, assume "N" */
            IF cRegimeEsp = "" THEN ASSIGN cRegimeEsp = "N".

            ASSIGN tt-processo.regime-especial-SP = cRegimeEsp
                       tt-processo.regime-especial-PR = "N".
  
       END. 

   END.       
 
    /*   
             
    IF AVAIL item-uni-estab THEN
    DO:
        IF item-uni-estab.cod-estabel = "977" THEN
        DO:
           IF SUBSTRING(item-uni-estab.char-2,60,1) <> "" THEN
           DO:
                ASSIGN tt-processo.regime-especial-SP = SUBSTRING(item-uni-estab.char-2,60,1).  
           END.
           ELSE DO:
           
                ASSIGN tt-processo.regime-especial-SP = "N".
           END.
            
        END.
        
        IF item-uni-estab.cod-estabel = "973" THEN
        DO:
           IF SUBSTRING(item-uni-estab.char-2,60,1) <> "" THEN
           DO:
                ASSIGN tt-processo.regime-especial-PR = SUBSTRING(item-uni-estab.char-2,60,1).  
           END.
           ELSE DO:
           
                ASSIGN tt-processo.regime-especial-PR = "N".
           END.
            
            
        END.
        
        IF item-uni-estab.cod-estabel <> "973" OR item-uni-estab.cod-estabel <> "977" THEN
        DO:
           IF SUBSTRING(item-uni-estab.char-2,60,1) <> "" THEN
           DO:
                ASSIGN tt-processo.regime-especial-PR = SUBSTRING(item-uni-estab.char-2,60,1).  
           END.
           ELSE DO:
           
                ASSIGN tt-processo.regime-especial-PR = "N".
           END.
           
           IF SUBSTRING(item-uni-estab.char-2,60,1) <> "" THEN
           DO:
                ASSIGN tt-processo.regime-especial-SP = SUBSTRING(item-uni-estab.char-2,60,1).  
           END.
           ELSE DO:
           
                ASSIGN tt-processo.regime-especial-SP = "N".
           END.
            
            
        END.
        
    END.
    ELSE DO:
    
        ASSIGN tt-processo.regime-especial-PR = "N"
               tt-processo.regime-especial-SP = "N". 
    
    END.  */

    
        
    IF ITEM.CD-TRIB-ICM = 1 THEN DO: /* tributado */
    

       /* ft0312 */
       FIND FIRST ICMS-IT-UF WHERE
                  ICMS-IT-UF.IT-CODIGO = ITEM.IT-CODIGO AND 
                  ICMS-IT-UF.ESTADO    = p-estado NO-LOCK NO-ERROR.
       IF AVAIL   icms-it-uf THEN DO:

          ASSIGN tt-processo.aliquota-icm     = Icms-it-uf.aliquota-icm       /* 8-h  */
                 tt-processo.aliquota-icm-ale = Icms-it-uf.aliquota-icm.      /* 11-k */ 
               //teste
/*           IF p-estado = "PR" THEN DO:                                                                                         */
/*                                                                                                                               */
/*                                                                                                                               */
/*               IF      ICMS-IT-UF.ALIQUOTA-ICM = 19.5 THEN ASSIGN tt-processo.rast  = 38.46.                        /* 20-t */ */
/*               ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast    = 52   .                        /* 20-t */ */
/*                                                                                                                               */
/*           END.                                                                                                                */

       END.
       
       ELSE DO:
           /* CD0904 */
           FIND FIRST unid-feder WHERE 
                      unid-feder.pais      = "BRASIL" AND
                      unid-feder.estado    = p-estado NO-LOCK NO-ERROR.
           IF AVAIL UNID-FEDER THEN DO:

              ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                     tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */  
                //teste
/*               IF p-estado = "PR" THEN DO:                                                                                             */
/*                                                                                                                                       */
/*                                                                                                                                       */
/*                       IF      unid-feder.pc-icms-st = 19.5 THEN ASSIGN tt-processo.rast    = 38.46.                        /* 20-t */ */
/*                       ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .                        /* 20-t */   */
/*                                                                                                                                       */
/*               END.                                                                                                                    */
           END.
       END.

       /* observacao michel colunas 25 e 26  */    
        IF ITEM.codigo-orig = 0 OR        
           ITEM.codigo-orig = 4 OR
           ITEM.codigo-orig = 5 THEN DO:
            
            FIND FIRST unid-feder WHERE 
                      unid-feder.pais      = "BRASIL" AND
                      unid-feder.estado    = p-estado NO-LOCK NO-ERROR.
           IF AVAIL UNID-FEDER THEN DO:
                
               
           /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */

               ASSIGN tt-processo.csta =  12                       /* 25-y */              
                      tt-processo.ies  = unid-feder.per-icms-ext.                         /* 26-z */  
                      tt-processo.aliquota-icm-ali  = 12.        /* 14-n */              
          
    
            END.
        END.
        ELSE DO:
    
           /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
    
           ASSIGN tt-processo.csta =  4                       /* 25-y */              
                  tt-processo.ies  =  4                      /* 26-z */ 
                  tt-processo.aliquota-icm-ali  = 4 .        /* 14-n */
    
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
               
                  ASSIGN tt-processo.aliquota-icm-ali = 12 .      /* 14-n */  
               
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

       ASSIGN tt-processo.csta = ITEM.codigo-orig      /* 25-y */   //kml          
              tt-processo.ies  = 4.      /* 26-z */   


       IF ITEM.cd-trib-icm = 1 THEN /* tributado */
          ASSIGN tt-processo.aliquota-icm-ali  = unid-feder.per-icms-ext. //era 4  .               /* 14-n */

    END.
    ELSE DO: /* FAIXA ITENS NACIONAL */
    
        FIND FIRST unid-feder WHERE 
                   unid-feder.pais      = "BRASIL" AND
                   unid-feder.estado    = p-estado NO-LOCK NO-ERROR.
        IF AVAIL UNID-FEDER THEN DO:
    
           ASSIGN tt-processo.csta = ITEM.codigo-orig       /* 25-y */              
                  tt-processo.ies  = unid-feder.per-icms-ext. //era 12.      /* 26-z */  

           IF ITEM.cd-trib-icm = 1 THEN /* tributado */
              ASSIGN tt-processo.aliquota-icm-ali  = 12  .              /* 14-n */
            
            
            
       END.
    END.

    FOR FIRST familia fields(descricao) WHERE
              familia.fm-codigo = ITEM.fm-codigo NO-LOCK :
        ASSIGN tt-processo.descricao = familia.descricao.
    END.

    RUN recupera-aliquotas IN h-cdapi995 (INPUT  "item",
                                          INPUT  ITEM.it-codigo,
                                          OUTPUT de-ali-pis,
                                          OUTPUT de-ali-cofins).

    IF SUBSTRING(item.char-2,52,1) = "1" THEN DO:  /* campo origem aliquota Pis = 1-item, 2-Natureza */
       ASSIGN tt-processo.aliq-pis = dec(SUBSTRING(item.char-2,31,5)).             /* 30-ad */         
       IF tt-processo.aliq-pis = 0 THEN
          ASSIGN tt-processo.aliq-pis = de-ali-pis.
    END.
    ELSE ASSIGN tt-processo.aliq-pis = 0 .                                           /* 30-ad */

    IF SUBSTRING(item.char-2,53,1) = "1" THEN DO:  /* campo origem aliquota cofins = 1-item, 2-Natureza */ 
       ASSIGN tt-processo.aliq-cofins = dec(SUBSTRING(item.char-2,36,5)) .          /* 31-af */         
       IF tt-processo.aliq-cofins = 0 THEN 
          ASSIGN tt-processo.aliq-cofins = de-ali-cofins.
    END.
    ELSE ASSIGN tt-processo.aliq-cofins = 0.                                         /* 31-af */
    
    FOR FIRST  it-carac-tec FIELDS ( observacao )
         WHERE it-carac-tec.it-codigo = ITEM.it-codigo and
               it-carac-tec.cd-folha  = "CADITEM"      AND
               it-carac-tec.cd-comp   = "290" NO-LOCK :

        ASSIGN tt-processo.tributa-pis =  substr(it-carac-tec.observacao,1,1) .    /* 29-ac */ 

    END.

    /* 29-Busca campo Aliquota COFINS no programa CD0903 se campo Origem Aliquota = Item, se nío, busca o campo % Interno COFINS no programa CD0606 aba Outros */            
    FOR FIRST it-carac-tec FIELDS ( observacao )
        WHERE it-carac-tec.it-codigo = ITEM.it-codigo and
              it-carac-tec.cd-folha  = "CADITEM"      AND
              it-carac-tec.cd-comp   = "300" NO-LOCK :

       ASSIGN tt-processo.tributa-cofins =  substr(it-carac-tec.observacao,1,1) . /* 32-ae */ 

    END.

END.

/**********************************************************************************************************************************************************************************/
PROCEDURE pi-grava-item :

   DEF INPUT PARAM l-item-uf AS LOG NO-UNDO.

   CREATE tt-processo.
   ASSIGN tt-processo.it-codigo   = ITEM.it-codigo                  /* 1-a  */ 
          tt-processo.desc-item   = ITEM.desc-item                  /* 2-b  */  
          tt-processo.ge-codigo   = ITEM.ge-codigo.                 /* 3-c  */


    EMPTY TEMP-TABLE tt-sit-tribut.
    RUN pi-seta-tributos IN h-cdapi1001 (input "11").
    RUN pi-retorna-sit-tribut IN h-cdapi1001 (INPUT  1,
                                            INPUT  "*",
                                            INPUT  "*",
                                            INPUT  ITEM.class-fiscal,
                                            INPUT  ITEM.it-codigo,
                                            INPUT  "*",
                                            INPUT  "0",
                                            INPUT  TODAY,
                                            OUTPUT TABLE tt-sit-tribut).
    
    FOR FIRST tt-sit-tribut:
        IF string(tt-sit-tribut.cdn-sit-tribut) <> "0" THEN DO:
             ASSIGN tt-processo.cest-entrada = string(tt-sit-tribut.cdn-sit-tribut).
        END.
        ELSE DO:

            FOR FIRST sit-tribut-relacto NO-LOCK
                WHERE sit-tribut-relacto.cod-item = ITEM.it-codigo
                  AND sit-tribut-relacto.idi-tip-docto = 1:

                ASSIGN tt-processo.cest-entrada = string(sit-tribut-relacto.cdn-sit-tribut).
           END.
        END.
       
    END.

    EMPTY TEMP-TABLE tt-sit-tribut.
    ASSIGN tt-processo.cest-saida = "".
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
        IF string(tt-sit-tribut.cdn-sit-tribut) <> "0" THEN DO:
             ASSIGN tt-processo.cest-saida = string(tt-sit-tribut.cdn-sit-tribut).
        END.
        /*ELSE DO:
            FOR FIRST sit-tribut-relacto NO-LOCK
                WHERE sit-tribut-relacto.cod-item = ITEM.it-codigo
                  AND sit-tribut-relacto.idi-tip-docto = 2: END.

                ASSIGN tt-processo.cest-saida = string(sit-tribut-relacto.cdn-sit-tribut).
           END.
        END.*/
       
    END.
           
   FIND FIRST int_ds_ean_item WHERE
              int_ds_ean_item.it_codigo = ITEM.it-codigo NO-LOCK NO-ERROR.
              
   IF AVAIL   int_ds_ean_item THEN  
      ASSIGN tt-processo.codigo-ean  =  int_ds_ean_item.codigo_ean. /* 4-d  */
  

   ASSIGN tt-processo.cd-trib-icm     = ITEM.cd-trib-icm            /* 7-g  */
          tt-processo.cd-trib-icm-tre = ITEM.cd-trib-icm            /* 10-j */
          tt-processo.cd-trib-icm-tri = ITEM.cd-trib-icm            /* 13-m */
          //tt-processo.regime-especial = IF AVAIL item-uni-estab THEN substring(item-uni-estab.char-2,60,1) ELSE  "N"
          . /* 37-al*/
    
   DEF VAR cRegimeEsp AS CHAR NO-UNDO.
   
   IF tt-processo.estado = "PR" THEN
   DO:
   
        FOR EACH item-uni-estab NO-LOCK
            WHERE  item-uni-estab.cod-estabel = "973"
              AND item-uni-estab.it-codigo   = tt-processo.it-codigo:
              
            ASSIGN cRegimeEsp = SUBSTRING(item-uni-estab.char-2, 60, 1).

            /* Se estiver vazio, assume "N" */
            IF cRegimeEsp = "" THEN ASSIGN cRegimeEsp = "N".



                
            ASSIGN tt-processo.regime-especial-PR = cRegimeEsp
                       tt-processo.regime-especial-SP = "N".
                

             
              
       END. 

   END.
   
   IF tt-processo.estado = "SP" THEN
   DO:
   
        FOR EACH item-uni-estab NO-LOCK
            WHERE  item-uni-estab.cod-estabel = "977"
              AND item-uni-estab.it-codigo   = tt-processo.it-codigo:
              
            ASSIGN cRegimeEsp = SUBSTRING(item-uni-estab.char-2, 60, 1).

            /* Se estiver vazio, assume "N" */
            IF cRegimeEsp = "" THEN ASSIGN cRegimeEsp = "N".

            ASSIGN tt-processo.regime-especial-SP = cRegimeEsp
                       tt-processo.regime-especial-PR = "N".
  
       END. 

   END.
  
          
   /*       //kml
   IF AVAIL item-uni-estab THEN
    DO:
    
        ASSIGN cRegimeEsp = SUBSTRING(item-uni-estab.char-2, 60, 1).

        /* Se estiver vazio, assume "N" */
        IF cRegimeEsp = "" THEN ASSIGN cRegimeEsp = "N".
        
        MESSAGE item-uni-estab.cod-estabel 
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        CASE trim(item-uni-estab.cod-estabel):
            WHEN "973" THEN 
                ASSIGN tt-processo.regime-especial-PR = cRegimeEsp
                       tt-processo.regime-especial-SP = "N".
            WHEN "977" THEN 
                ASSIGN tt-processo.regime-especial-SP = cRegimeEsp
                       tt-processo.regime-especial-PR = "N".
            OTHERWISE 
                ASSIGN tt-processo.regime-especial-PR = "N"
                       tt-processo.regime-especial-SP = "N". 
        END CASE.
        
    END.
    ELSE DO:
    
        ASSIGN tt-processo.regime-especial-PR = "N"
               tt-processo.regime-especial-SP = "N". 
    
    END.       
 
    IF AVAIL item-uni-estab THEN
    DO:
        IF item-uni-estab.cod-estabel = "977" THEN
        DO:
           IF SUBSTRING(item-uni-estab.char-2,60,1) <> "" THEN
           DO:
                ASSIGN tt-processo.regime-especial-SP = SUBSTRING(item-uni-estab.char-2,60,1).  
           END.
           ELSE DO:
           
                ASSIGN tt-processo.regime-especial-SP = "N".
           END.
            
        END.
        
        IF item-uni-estab.cod-estabel = "973" THEN
        DO:
           IF SUBSTRING(item-uni-estab.char-2,60,1) <> "" THEN
           DO:
                ASSIGN tt-processo.regime-especial-PR = SUBSTRING(item-uni-estab.char-2,60,1).  
           END.
           ELSE DO:
           
                ASSIGN tt-processo.regime-especial-PR = "N".
           END.
            
            
        END.
        
        IF item-uni-estab.cod-estabel <> "973" OR item-uni-estab.cod-estabel <> "977" THEN
        DO:
           IF SUBSTRING(item-uni-estab.char-2,60,1) <> "" THEN
           DO:
                ASSIGN tt-processo.regime-especial-PR = SUBSTRING(item-uni-estab.char-2,60,1).  
           END.
           ELSE DO:
           
                ASSIGN tt-processo.regime-especial-PR = "N".
           END.
           
           IF SUBSTRING(item-uni-estab.char-2,60,1) <> "" THEN
           DO:
                ASSIGN tt-processo.regime-especial-SP = SUBSTRING(item-uni-estab.char-2,60,1).  
           END.
           ELSE DO:
           
                ASSIGN tt-processo.regime-especial-SP = "N".
           END.
            
            
        END.
        
    END.
    ELSE DO:
    
        ASSIGN tt-processo.regime-especial-PR = "N"
               tt-processo.regime-especial-SP = "N". 
    
    END.  */
           
          
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

             IF      ICMS-IT-UF.ALIQUOTA-ICM = 18 THEN ASSIGN tt-processo.rast         = 33.33.                        /* 20-t */
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

                 IF      unid-feder.pc-icms-st = 18 THEN ASSIGN tt-processo.rast    = 33.33.                        /* 20-t */
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

             IF      ICMS-IT-UF.ALIQUOTA-ICM = 18 THEN ASSIGN tt-processo.rast         = 33.33.                        /* 20-t */
             ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .                        /* 20-t */

          END.
          /* CD0904 */
          ELSE DO:

              FIND FIRST unid-feder WHERE 
                         unid-feder.pais      = "BRASIL" AND
                         unid-feder.estado    = "SP" NO-LOCK NO-ERROR.
              IF AVAIL UNID-FEDER THEN DO:

                 ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                        tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */   

                 IF      unid-feder.pc-icms-st = 18 THEN ASSIGN tt-processo.rast    = 33.33.                        /* 20-t */
                 ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .                        /* 20-t */  

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

             IF      ICMS-IT-UF.ALIQUOTA-ICM = 18 THEN ASSIGN tt-processo.rast         = 33.33.                        /* 20-t */
             ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .                        /* 20-t */

          END.
          ELSE DO:
             /* CD0904 */
             FIND FIRST unid-feder WHERE 
                        unid-feder.pais      = "BRASIL" AND
                        unid-feder.estado    = "SC" NO-LOCK NO-ERROR.
             IF AVAIL UNID-FEDER THEN DO:
                 ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                        tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */   

                 IF      unid-feder.pc-icms-st = 18 THEN ASSIGN tt-processo.rast    = 33.33.                        /* 20-t */
                 ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .                        /* 20-t */                                                                                                                                                

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


              IF      ICMS-IT-UF.ALIQUOTA-ICM = 19 THEN ASSIGN tt-processo.rast         = 33.33.                        /* 20-t */  //alteraá∆o KML para teste de validaá∆o FT0312
              ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .                        /* 20-t */

          END.
          ELSE DO:
             /* CD0904 */ 
             FIND FIRST unid-feder WHERE 
                        unid-feder.pais      = "BRASIL" AND
                        unid-feder.estado    = "GO" NO-LOCK NO-ERROR.
             IF AVAIL UNID-FEDER THEN DO:
                 ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                        tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */   

                 IF      unid-feder.pc-icms-st = 19 THEN ASSIGN tt-processo.rast    = 33.33.                        /* 20-t */
                 ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .                        /* 20-t */                                                                                                                                                

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


              IF      ICMS-IT-UF.ALIQUOTA-ICM = 20 THEN ASSIGN tt-processo.rast         = 33.33.                        /* 20-t */  //alteraá∆o KML para teste de validaá∆o FT0312
              ELSE IF ICMS-IT-UF.ALIQUOTA-ICM = 25 THEN ASSIGN tt-processo.rast         = 52   .                        /* 20-t */

          END.
          ELSE DO:
             /* CD0904 */ 
             FIND FIRST unid-feder WHERE 
                        unid-feder.pais      = "BRASIL" AND
                        unid-feder.estado    = "DF" NO-LOCK NO-ERROR.
             IF AVAIL UNID-FEDER THEN DO:
                 ASSIGN tt-processo.aliquota-icm     = unid-feder.pc-icms-st       /* 8-h  */
                        tt-processo.aliquota-icm-ale = unid-feder.pc-icms-st.      /* 11-k */   

                 IF      unid-feder.pc-icms-st = 20 THEN ASSIGN tt-processo.rast    = 33.33.                        /* 20-t */
                 ELSE IF unid-feder.pc-icms-st = 25 THEN ASSIGN tt-processo.rast    = 52   .                        /* 20-t */                                                                                                                                                

             END.
          END.
       END. 

       /* observacao michel colunas 25 e 26  */    
   
       IF ITEM.codigo-orig = 0 OR
          ITEM.codigo-orig = 4 OR
          ITEM.codigo-orig = 5 OR
          ITEM.codigo-orig = 8 THEN DO:
          
          .MESSAGE   "1" SKIP
                   tt-processo.cod-estado-orig SKIP
                  tt-processo.estado
              VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

          /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */

          ASSIGN tt-processo.csta = ITEM.codigo-orig                                           /* 25-y */
                 tt-processo.ies  =  12                                           /* 26-z */
                 tt-processo.aliquota-icm-ali  = 12.                              /* 14-n */

       END.
       ELSE DO:

          /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */

          ASSIGN tt-processo.csta = ITEM.codigo-orig                                           /* 25-y */
                 tt-processo.ies  =  4.                                          /* 26-z */
          
            ASSIGN tt-processo.aliquota-icm-ali  = 4  .                            /* 14-n */

       END.

       IF  ITEM.FM-CODIGO =  "101" OR
           ITEM.FM-CODIGO =  "201" OR
           ITEM.FM-CODIGO >= "300" AND
           ITEM.FM-CODIGO <= "309" THEN DO:
    
           ASSIGN tt-processo.csta = ITEM.codigo-orig      /* 25-y */              
                  tt-processo.ies  = 4.      /* 26-z */           

           IF l-item-uf = NO THEN   /* NAO ESTA CADASTRADO NO CD0904A  */ 
                 ASSIGN TT-PROCESSO.ALIQUOTA-ICM-ALI  = 0  .               /* 14-n */
           ELSE  ASSIGN tt-processo.aliquota-icm-ali  = 4  .               /* 14-n */
           
    
        END.
        ELSE DO: /* FAIXA ITENS NACIONAL */
        
         .MESSAGE  "2" SKIP 
                  tt-processo.cod-estado-orig SKIP
                  tt-processo.estado
              VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
           ASSIGN tt-processo.csta = ITEM.codigo-orig       /* 25-y */              
                  tt-processo.ies  = 12.      /* 26-z */  
    
           IF ITEM.cd-trib-icm = 1 THEN /* tributado */
              ASSIGN tt-processo.aliquota-icm-ali  = 12  .              /* 14-n */
    
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
               
                      /* regra para ser retirada quando o cadastro estiver ok, retirar tratamento familia */
               
/*                       ASSIGN tt-processo.csta =  4                                           /* 25-y */ */
/*                              tt-processo.ies  =  4.                                          /* 26-z */ */
               
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
       ELSE IF ITEM.FM-CODIGO = '102' or
               ITEM.FM-CODIGO = '202' OR
               ITEM.FM-CODIGO = '402' THEN DO:  /* ISENTO */

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
             it-carac-tec.cd-comp   = "90" NO-LOCK :
      ASSIGN c-lista = it-carac-tec.observacao.
   END.

   ASSIGN tt-processo.observacao    = substr(c-lista,1,1)            /* 23-w */  
          tt-processo.class-fiscal  = ITEM.class-fiscal.             /* 24-x */ 
   
   IF ITEM.FM-CODIGO =  "101" OR
      ITEM.FM-CODIGO =  "201" OR
      ITEM.FM-CODIGO >= "300" AND
      ITEM.FM-CODIGO <= "309" THEN DO:

      ASSIGN tt-processo.csta = ITEM.codigo-orig       /* 25-y */              
             tt-processo.ies  = 4.      /* 26-z */              

   END.
   ELSE DO: /* FAIXA ITENS NACIONAL */
   
       .MESSAGE "3" SKIP
               tt-processo.cod-estado-orig SKIP
               tt-processo.estado
          VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

      ASSIGN tt-processo.csta = ITEM.codigo-orig       /* 25-y */              
             tt-processo.ies  = 12.      /* 26-z */  

   END.

   ASSIGN tt-processo.fm-codigo = ITEM.fm-codigo.                    /* 27-aa */
   
   FOR FIRST familia fields(descricao) WHERE
             familia.fm-codigo = ITEM.fm-codigo NO-LOCK :
       ASSIGN tt-processo.descricao = familia.descricao.             /* 28-ab */            
   END.

   /* 28-Busca campo Aliquota PIS no programa CD0903 se campo Origem Aliquota = Item, se nío, busca o campo % Interno PIS no programa CD0606 aba Outros */

   RUN recupera-aliquotas IN h-cdapi995 (INPUT  "item",
                                         INPUT  ITEM.it-codigo,
                                         OUTPUT de-ali-pis,
                                         OUTPUT de-ali-cofins).

   IF SUBSTRING(item.char-2,52,1) = "1" THEN DO:  /* campo origem aliquota Pis = 1-item, 2-Natureza */
      ASSIGN tt-processo.aliq-pis = dec(SUBSTRING(item.char-2,31,5)).             /* 30-ad */         
      IF tt-processo.aliq-pis = 0 THEN
         ASSIGN tt-processo.aliq-pis = de-ali-pis.
   END.
   ELSE ASSIGN tt-processo.aliq-pis = 0 .                                           /* 30-ad */
  
   IF SUBSTRING(item.char-2,53,1) = "1" THEN DO:   /* campo origem aliquota cofins = 1-item, 2-Natureza */
      ASSIGN tt-processo.aliq-cofins = dec(SUBSTRING(item.char-2,36,5)) .          /* 31-ae */         
      IF tt-processo.aliq-cofins = 0 THEN
         ASSIGN tt-processo.aliq-cofins = de-ali-cofins.
   END.
   ELSE ASSIGN tt-processo.aliq-cofins = 0 .                                         /* 31-ae */
    
   FOR FIRST  it-carac-tec FIELDS ( observacao )
        WHERE it-carac-tec.it-codigo = ITEM.it-codigo and
              it-carac-tec.cd-folha  = "CADITEM"      AND
              it-carac-tec.cd-comp   = "290" NO-LOCK :

       ASSIGN tt-processo.tributa-pis =  substr(it-carac-tec.observacao,1,1) .    /* 29-ac */ 

   END.
   
   /* 29-Busca campo Aliquota COFINS no programa CD0903 se campo Origem Aliquota = Item, se nío, busca o campo % Interno COFINS no programa CD0606 aba Outros */            
   FOR FIRST it-carac-tec FIELDS ( observacao )
       WHERE it-carac-tec.it-codigo = ITEM.it-codigo and
             it-carac-tec.cd-folha  = "CADITEM"      AND
             it-carac-tec.cd-comp   = "300" NO-LOCK :

      ASSIGN tt-processo.tributa-cofins =  substr(it-carac-tec.observacao,1,1) . /* 32-af */ 

   END.




END PROCEDURE.    
procedure WinExec external "kernel32.dll":

define input parameter prog_name    as character.                                     
define input parameter visual_style as short.    

end procedure.                                                                        


