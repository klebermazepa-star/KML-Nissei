/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i FT0603RP 2.00.00.011 } /*** 010011 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i ft0603rp MFT}
&ENDIF


{include/i_fnctrad.i}
/******************************************************************************
**
**  Programa: FT0603RP.P
**
**  Data....: Outubro de 1990
**
**  Autor...: DATASUL DESENVOLVIMENTO DE SISTEMAS S.A.
**
**  Objetivo: Atualizacao de Contas a Receber
**
**  OBS.....: Qualquer alteracao feita neste programa, deve ser feita tambem
**            na api de efetivacao do multiplanta ( ftapi307.p ).
**
******************************************************************************/


{include/i-rpvar.i}
{utp/ut-glob.i}
{btb/btb009za.i}

/* Include i-epc200.i: Definiá∆o Temp-Table tt-epc e dos programas de EPCs */
{include/i-epc200.i ft0603rp}

{cdp/cdcfgdis.i} /* Include com prÇ-processadores de vers∆o */

/**/
{include/tt-edit.i}
/**/

&scoped-define TTONLY YES    
{include/i-estab-security.i}

/* Campos livres - RMA */
&IF DEFINED(bf_dis_versao_ems) &THEN
    &IF {&bf_dis_versao_ems} >= 2.05 &THEN
       &GLOBAL-DEFINE TRUE-log-nota-debito-rma  log-nota-debito-rma  = YES
    &ELSE
       &GLOBAL-DEFINE TRUE-log-nota-debito-rma  SUBSTRING(rma.cod-livre-1,2,1) = "1"
    &ENDIF
&ENDIF

def buffer b-estabelec   for estabelec.
def buffer b-nota-fisc   for nota-fiscal.
def buffer b2-nota-fiscal   for nota-fiscal.
def buffer b-nota-debito for nota-fiscal. /*RMA*/

define temp-table tt-param
    field destino             as integer
    field arquivo             as char
    field usuario             as char
    field data-exec           as date
    field hora-exec           as integer
    field classifica          as integer
    field da-emissao-ini      as date
    field da-emissao-fim      as date
    field c-estabel-ini       as char
    field c-serie-ini         as char
    field c-serie-fim         as char
    field c-nota-fis-ini      as char
    field c-nota-fis-fim      as char
    field de-embarque-ini     like nota-fiscal.cdd-embarq
    field de-embarque-fim     like nota-fiscal.cdd-embarq
    field i-cod-portador      as integer
    field rs-gera-titulo      as integer
    field desc-titulo         as char format "x(35)"
    field i-pais              as int
    field c-estabel-fim       as char
    field c-arquivo-exp       as char
    FIELD l-processa-convenio AS LOG
    FIELD l-processa-servico  AS LOG
    FIELD l-processa-cheque   AS LOG .

def temp-table tt-raw-digita 
    field raw-digita as raw.

def temp-table tt-nota-fiscal no-undo
    field atualizar     as log  init yes
    field referencia    as char format "x(10)"
    field r-nota-fiscal as rowid
    field emite-duplic  like nota-fiscal.emite-duplic
    field cod-estabel   like nota-fiscal.cod-estabel
    field serie         like nota-fiscal.serie
    field nr-fatura     like nota-fiscal.nr-fatura.

def temp-table tt-nota-fiscal-aux NO-UNDO LIKE tt-nota-fiscal.
   
def temp-table tt-retorno-nota-fiscal no-undo
    field tipo       as integer   /* 1- Nota Fiscal 2- T°tulo 3- Nota de DÇbito/CrÇdito */
    field cod-erro   as character format "x(10)"
    field referencia as character format "x(10)"
    field desc-erro  as character format "x(60)"
                        view-as editor max-chars 2000 
                        scrollbar-vertical size 50 by 4
    field situacao   as LOGICAL format "Sim/N∆o"
    field cod-chave  as character
    INDEX ch-codigo  IS PRIMARY tipo
                                cod-erro
                                cod-chave.

def temp-table tt-erro NO-UNDO like tt-retorno-nota-fiscal.

def temp-table tt-total-refer no-undo
    field referencia     as char format "x(10)"
    field nr-doctos      as int
    field vendas-a-vista as dec format '->>>,>>>,>>9.99'
    field vendas-a-prazo as dec format '->>>,>>>,>>9.99'
    field vl-total       as dec format '->>>,>>>,>>9.99'
    INDEX ch-codigo      IS PRIMARY referencia.

def temp-table tt-total-refer-aux no-undo LIKE tt-total-refer.

DEFINE TEMP-TABLE tt-nf-ja-impressa NO-UNDO
    FIELD cod-estabel LIKE nota-fiscal.cod-estabel
    FIELD serie       LIKE nota-fiscal.serie
    FIELD nr-fatura   LIKE fat-duplic.nr-fatura
    FIELD parcela     LIKE fat-duplic.parcela
    FIELD cod-erro    AS CHARACTER FORMAT "x(10)"
    INDEX ch-parcel IS PRIMARY UNIQUE
          cod-estabel
          serie
          nr-fatura
          parcela
          cod-erro.

def input parameter raw-param as raw no-undo.   
def input parameter table for tt-raw-digita.

def var c-sit            as char format "x(05)"  no-undo.
DEF VAR c-referencia     AS CHAR                 NO-UNDO.
DEF VAR c-cod-esp        AS CHAR                 NO-UNDO.
DEF VAR c-nr-docto       AS CHAR                 NO-UNDO.
DEF VAR i-port           AS INT                  NO-UNDO.
DEF VAR i-modalidade     AS INT                  NO-UNDO.
DEF VAR c-conta-contabil AS CHAR format "x(20)"  NO-UNDO.
DEF VAR c-centro-custo AS CHAR format "x(20)"  NO-UNDO.
def var i-parcela        as int  format "99"     no-undo.
DEF VAR c-desc-erro      AS CHAR FORMAT "x(153)" NO-UNDO.
DEF VAR c-cgc         AS CHAR NO-UNDO.

def var h-acomp as handle                 no-undo.
DEFINE VARIABLE i-time        AS INTEGER                    NO-UNDO.

DEF VAR h_bodi135     AS HANDLE  NO-UNDO.
DEF VAR l-cons-nota   AS LOGICAL NO-UNDO.
DEF VAR c-msg-retorno AS CHAR    NO-UNDO.

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Atualizando_Contas_a_Receber *}
run pi-inicializar in h-acomp (input  Return-value ).

create tt-param.
raw-transfer raw-param to tt-param.

FOR EACH fat-duplic
   WHERE fat-duplic.cod-esp = "CE" 
/*           OR fat-duplic.cod-esp = "CV" ) */
     AND fat-duplic.flag-atualiz = NO EXCLUSIVE-LOCK,
   FIRST cst_fat_duplic
   WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
     AND cst_fat_duplic.serie       = fat-duplic.serie
     AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
     AND cst_fat_duplic.parcela     = fat-duplic.parcela NO-LOCK,
   FIRST nota-fiscal
   WHERE nota-fiscal.cod-estabel = fat-duplic.cod-estabel
     AND nota-fiscal.serie       = fat-duplic.serie
     AND nota-fiscal.nr-nota-fis = fat-duplic.nr-fatura NO-LOCK
   BREAK BY nota-fiscal.cod-estabel
         BY nota-fiscal.serie
         BY nota-fiscal.nr-nota-fis   :

   ASSIGN fat-duplic.ind-fat-nota = 1. 
END.

def var c-campo as char no-undo.
def var c-tipo  as char no-undo.
def var c-valor as char no-undo.

find first param-global no-lock no-error.
find first para-ped     no-lock no-error.
find first b-estabelec where b-estabelec.cons-cent-vend no-lock no-error.

/*   "Cliente"        at 1
     "Estab"          AT 14
     "Serie"          AT 20
     "Esp"            at 26 
     "Docto"          at 30
     "Pa"             at 40
     "Valor Bruto"    at 49
     "Vencimento"     at 61
     "CV"             at 72
     "Port"           at 75
     "M"              at 81
     "Nat Ope"        at 83 
     "Mensagem"       at 93 skip
     "Descricao"      at 01 skip
     "--------------------------------------------------------------------------------------------------------------" at 1
     "----------------------" at 111 SKIP
     with width 159 no-attr-space page-top frame f-rotina. */

form nota-fiscal.nome-ab-cli          at 1                         COLUMN-LABEL "Cliente"       
     nota-fiscal.cod-estabel          /* AT 14  */                 COLUMN-LABEL "Estab"
      nota-fiscal.serie               /* AT 20  */                 COLUMN-LABEL "Serie"
     c-cod-esp                        /* AT 26  */  FORMAT "x(02)" COLUMN-LABEL "Esp"
     c-nr-docto                       /* AT 30  */                 COLUMN-LABEL "Docto"
     i-parcela                        /* AT 40  */                 COLUMN-LABEL "Pa"
     fat-duplic.vl-parcela            /*        */                 COLUMN-LABEL "Valor Bruto"
     fat-duplic.dt-venciment          /*        */                 COLUMN-LABEL "Vencimento"
     fat-duplic.cod-vencto            /* AT 72  */ FORMAT "99"     COLUMN-LABEL "CV"
     i-port                           /* AT 75  */ FORMAT ">>>>9"  COLUMN-LABEL "Port"
     i-modalidade                     /* AT 81  */ FORMAT "9"      COLUMN-LABEL "M"
     nota-fiscal.nat-operacao         /* AT 83  */                 COLUMN-LABEL "Nat Ope"
     tt-retorno-nota-fiscal.cod-erro  /* AT 93  */                 COLUMN-LABEL "Mensagem"
     c-desc-erro                      /* AT 120 */                 COLUMN-LABEL "Descricao"
     with width 255 stream-io DOWN frame f-consitencia.

form emitente.nome-abrev         at 1                              COLUMN-LABEL "Nome Abrev"       
     nota-fiscal.cod-estabel          /* AT 14  */                 COLUMN-LABEL "Estab"
      nota-fiscal.serie               /* AT 20  */                 COLUMN-LABEL "Serie"
     c-cod-esp                        /* AT 26  */  FORMAT "x(02)" COLUMN-LABEL "Esp"
     c-nr-docto                       /* AT 30  */                 COLUMN-LABEL "Docto"
     i-parcela                        /* AT 40  */                 COLUMN-LABEL "Pa"
     fat-duplic.vl-parcela            /*        */                 COLUMN-LABEL "Valor Bruto"
     fat-duplic.dt-venciment          /*        */                 COLUMN-LABEL "Vencimento"
     fat-duplic.cod-vencto            /* AT 72  */ FORMAT "99"     COLUMN-LABEL "CV"
     i-port                           /* AT 75  */ FORMAT ">>>>9"  COLUMN-LABEL "Port"
     i-modalidade                     /* AT 81  */ FORMAT "9"      COLUMN-LABEL "M"
     nota-fiscal.nat-operacao         /* AT 83  */                 COLUMN-LABEL "Nat Ope"
     tt-retorno-nota-fiscal.cod-erro  /* AT 93  */                 COLUMN-LABEL "Mensagem"
     c-desc-erro                      /* AT 120 */                 COLUMN-LABEL "Descricao"
     with width 255 stream-io DOWN frame f-consitencia-emit.
                          
find first para-fat no-lock no-error.

{utp/ut-liter.i Atualizaá∆o_do_Contas_a_Receber * R}
assign c-titulo-relat = return-value.

{utp/ut-liter.i Faturamento * R}
assign c-sistema = return-value.

def var c-selecao             as char format "x(10)"        no-undo.
def var c-param               as char format "x(14)"        no-undo.
def var c-imp                 as char format "x(15)"        no-undo.
def var c-destino             as char format "x(1)"         no-undo.
def var c-usuario             as char format "x(1)"         no-undo.
def var c-destino-impressao   as char format "x(15)"        no-undo.
def var da-cont               as date                       no-undo.
def var i-versao-api          as int                        no-undo.
def var i-cont                as int                        no-undo.
def var c-referencia-aux      as char                       no-undo.
def var de-tot-geral-a-vista  as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-geral-a-prazo  as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-geral-vl-total as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-a-vista-NFOK   as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-a-prazo-NFOK   as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-vl-total-NFOK  as dec form "->>>,>>>,>>9.99" no-undo.
def var i-empresa             like param-global.empresa-prin no-undo.
def var l-ems5                as logical                    no-undo.
def var l-ja-conec-emsfin     as logical                    no-undo.
def var h-btb009za            as handle.
def var l-conec-bas           as logical                    no-undo.
def var l-conec-fin           as logical                    no-undo.
def var l-conec-uni           as logical                    no-undo.
def var l-conecta             as logical                    no-undo.   
def var l-erro                as logical                    no-undo.
def var l-ja-conec-emsuni     as logical                    no-undo.
def var l-ja-conec-emsbas     as logical                    no-undo.


/*Inicio Unificaá∆o de Conceitos CONTA CONTABIL 2011*/
DEF VAR i-empresaCtContabel LIKE param-global.empresa-prin NO-UNDO.
def var h_api_cta          as handle no-undo.
def var h_api_ccust        as handle no-undo.
def var v_cod_cta          as char   no-undo.
def var v_des_cta          as char   no-undo.
def var v_cod_ccust        as char   no-undo.
def var v_des_ccust        as char   no-undo.
def var v_cod_format_cta   as char   no-undo.
def var v_cod_format_ccust as char   no-undo.
def var v_cod_format_inic  as char   no-undo.
def var v_cod_format_fim   as char   no-undo.
def var v_ind_finalid_cta  as char   no-undo.
def var v_num_tip_cta      as int    no-undo.
def var v_num_sit_cta      as int    no-undo.
def var v_log_utz_ccust    as log    no-undo.

def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro  as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_msg_ajuda as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro  as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància".

/*Fim Unificaá∆o de Conceitos CONTA CONTABIL 2011*/


form
      skip(3)
      c-selecao                no-label at 30          skip(1)
      da-emissao-ini           colon 50 " |< >| "  at 80  da-emissao-fim    no-label skip
      c-serie-ini              colon 50 " |< >| "  at 80  c-serie-fim   no-label skip
      c-nota-fis-ini           colon 50 " |< >| "  at 80  c-nota-fis-fim no-label skip
      de-embarque-ini          colon 50 " |< >| "  at 80  de-embarque-fim no-label skip
      c-estabel-ini            colon 50 " |< >| "  at 80  c-estabel-fim no-label skip(2)
      c-param                  no-label at 30          skip(1)  
      i-cod-portador           colon 50   skip
      desc-titulo              colon 50   skip(1)
      c-imp                    no-label at 30    skip(1)
      c-destino                colon 50
      c-destino-impressao      no-label
      " - "
      arquivo format "x(40)"   no-label  skip
      c-usuario                colon 50
      tt-param.usuario                  no-label skip(1) 
      with stream-io frame f-param attr-space side-labels no-box width 132 .
/* Inicio -- Projeto Internacional -- ut-trfrrp.p adicionado */
RUN utp/ut-trfrrp.p (INPUT FRAME f-param:HANDLE).


&if "{&FNC_MULTI_IDIOMA}" = "Yes" &then
    DEFINE VARIABLE cAuxTraducao001 AS CHARACTER NO-UNDO.
    ASSIGN cAuxTraducao001 = {varinc/var00002.i 04 tt-param.destino}.
    run utp/ut-liter.p (INPUT REPLACE(TRIM(cAuxTraducao001)," ","_"),
                        INPUT "",
                        INPUT "").
    ASSIGN  c-destino-impressao = RETURN-VALUE.
&else
    ASSIGN c-destino-impressao = {varinc/var00002.i 04 tt-param.destino}.
&endif

{utp/ut-liter.i Dt_Emiss∆o * L}
assign da-emissao-ini:label in frame f-param = return-value.

{utp/ut-field.i mgadm portador cod-portador 1}
assign i-cod-portador:label in frame f-param = return-value.

{utp/ut-field.i mgdis nota-fiscal serie 1} 
assign c-serie-ini:label in frame f-param = return-value.

{utp/ut-table.i mgdis nota-fiscal 1}
assign c-nota-fis-ini:label in frame f-param = return-value.

{utp/ut-field.i mgdis nota-fiscal cdd-embarq 1}
assign de-embarque-ini:label in frame f-param = return-value.

{utp/ut-field.i mgdis nota-fiscal cod-estabel 1}
assign c-estabel-ini:label in frame f-param = return-value.

{utp/ut-liter.i Forma_de_Geraá∆o_dos_T°tulos * L}
assign desc-titulo:label in frame f-param = return-value.

{utp/ut-liter.i SELEÄ«O * L} 
assign c-selecao = return-value.

{utp/ut-liter.i PAR∂METROS * L} 
assign c-param = return-value.

{utp/ut-liter.i IMPRESS«O * L} 
assign c-imp = return-value.                  

{utp/ut-liter.i Destino * L} 
assign c-destino:label in frame f-param = return-value.

{utp/ut-liter.i Usu†rio * L} 
assign c-usuario:label in frame f-param = return-value.

find first param-global no-lock no-error.
assign c-programa         = "FT/0603"
       c-empresa          = param-global.grupo.

run utp/ut-trfrrp.p (input frame f-consitencia:handle).

/* run utp/ut-trfrrp.p (input frame f-rotina:handle).
   */

{include/i-rpc255.i}
{include/i-rpout.i}

/* Trecho retirado: antiga tÇcnica da seguranáa por estabelecimento */
/* {cdp/cd0019.i MFT YES} /* inicializaá∆o da seguranáa por estabelecimento */ */

view frame f-cabec-255.
/* view frame f-rotina. */
view frame f-rodape-255.

for each tt-nota-fiscal:
    delete tt-nota-fiscal.
end.

FOR EACH tt-nota-fiscal-aux:
    DELETE tt-nota-fiscal-aux.
END.

assign i-empresa = param-global.empresa-prin .

if can-find(funcao where funcao.cd-funcao = "adm-acr-ems-5.00" 
                     and funcao.ativo     = yes
                     and funcao.log-1     = yes) then 
    assign l-ems5 = yes.

IF param-global.ind-cons-conta = 1 THEN
    assign i-empresa = param-global.empresa-prin.

RUN dibo/bodi135.p PERSISTENT SET h_bodi135.

IF l-estab-security-active = YES THEN DO:
   {ftp/ft0603.i5 "and nota-fiscal.cod-estabel = {&ESTAB-SEC-TT-FIELD} "}
END.
ELSE DO:
    {ftp/ft0603.i5 " "}
END. 

IF NOT VALID-HANDLE(h-btb009za) THEN
    RUN btb/btb009za.p PERSISTENT SET h-btb009za. 

if l-ems5 then do:
    assign l-conecta = yes.
    run pi-conecta-ems-5 (input l-conecta,
                          input i-empresa,
                          output l-erro). /* EMS5 */
end.

{utp/ut-liter.i Atualizando_Contas_Receber *}
run pi-acompanhar in h-acomp (input trim(return-value)).
assign i-versao-api = 3.

IF NOT l-erro THEN DO:

    FOR EACH tt-nota-fiscal,
        FIRST nota-fiscal WHERE 
              ROWID(nota-fiscal) = r-nota-fiscal:

        IF nota-fiscal.cod-portador <> 99501 AND 
           nota-fiscal.cod-portador <> 99801 /* Convenio */ 
        THEN DO: 

           CREATE tt-nota-fiscal-aux.
           BUFFER-COPY tt-nota-fiscal TO tt-nota-fiscal-aux.

           DELETE tt-nota-fiscal.
        END. 
         
    END.
             
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-total-refer-aux.

    IF CAN-FIND(FIRST tt-nota-fiscal) 
    THEN DO: 

        run ftp/ftapi001esp.p (input  i-versao-api,
                            input  tt-param.i-pais,
                            input  tt-param.i-cod-portador,             /* Apenas Convànio */
                            input  tt-param.rs-gera-titulo,
                            input  tt-param.c-arquivo-exp,
                            input  table tt-nota-fiscal,
                            output table tt-retorno-nota-fiscal,
                            output table tt-total-refer).

        FOR EACH tt-retorno-nota-fiscal:
            CREATE tt-erro.
            BUFFER-COPY tt-retorno-nota-fiscal TO tt-erro.
        END.
    
        FOR EACH tt-total-refer:
            CREATE tt-total-refer-aux.
            BUFFER-COPY tt-total-refer TO tt-total-refer-aux.
        END.
        
        EMPTY TEMP-TABLE tt-retorno-nota-fiscal.
        EMPTY TEMP-TABLE tt-total-refer.
    END.

    IF CAN-FIND(FIRST tt-nota-fiscal-aux) 
    THEN DO:

        run ftp/ftapi001.p (input  i-versao-api,
                            input  tt-param.i-pais,
                            input  tt-param.i-cod-portador,             /* Notas Normais */
                            input  tt-param.rs-gera-titulo,
                            input  tt-param.c-arquivo-exp,
                            input  table tt-nota-fiscal-aux,
                            output table tt-retorno-nota-fiscal,
                            output table tt-total-refer).
     
        FOR EACH tt-retorno-nota-fiscal:
            CREATE tt-erro.
            BUFFER-COPY tt-retorno-nota-fiscal TO tt-erro.
        END.
    
        FOR EACH tt-total-refer:
            CREATE tt-total-refer-aux.
            BUFFER-COPY tt-total-refer TO tt-total-refer-aux.
        END.
        
        EMPTY TEMP-TABLE tt-retorno-nota-fiscal.
        EMPTY TEMP-TABLE tt-total-refer.

    END.

    FOR EACH tt-erro:
        
        CREATE tt-retorno-nota-fiscal.
        BUFFER-COPY tt-erro TO tt-retorno-nota-fiscal.

    END.

    FOR EACH tt-total-refer-aux:

        CREATE tt-total-refer.
        BUFFER-COPY tt-total-refer-aux TO tt-total-refer.

    END.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-total-refer-aux.


/*     MESSAGE 'depois api' VIEW-AS ALERT-BOX. */
    /*************** INICIO EPC ********************/
    if  c-nom-prog-dpc-mg97  <> "" 
    or  c-nom-prog-appc-mg97 <> "" 
    or  c-nom-prog-upc-mg97  <> "" then do:

        for each tt-epc:
            delete tt-epc.
        end.

        create tt-epc.
        assign tt-epc.cod-event     = "AFTER_FTAPI001"
               tt-epc.cod-parameter = "handle_tt-retorno-nota-fiscal"
               tt-epc.val-parameter = STRING(TEMP-TABLE tt-retorno-nota-fiscal:HANDLE).

        {include/i-epc201.i "AFTER_FTAPI001"}

    end.
    /***************** FIM EPC *********************/

end.

if l-ems5 then do:
    assign l-conecta = no.
    run pi-conecta-ems-5 (input l-conecta,
                          input i-empresa,
                          output l-erro). /* EMS5 */
end.


FOR EACH tt-retorno-nota-fiscal
    WHERE tt-retorno-nota-fiscal.cod-erro <> "9999"
    AND   tt-retorno-nota-fiscal.cod-erro <> "0000"
    AND   tt-retorno-nota-fiscal.situacao  = YES:
/*     IF entry(7, tt-retorno-nota-fiscal.cod-chave, ",") = "0037004" THEN */
/*        MESSAGE 'ponto A' skip                                     */
/*                tt-retorno-nota-fiscal.cod-erro SKIP               */
/*                tt-retorno-nota-fiscal.situacao VIEW-AS ALERT-BOX. */
    DELETE tt-retorno-nota-fiscal.
END.
if valid-handle(h-btb009za) then
    delete procedure h-btb009za.
for each tt-erro :
  create tt-retorno-nota-fiscal.
  buffer-copy tt-erro to tt-retorno-nota-fiscal.  
end.  

assign c-referencia-aux      = ""
       /* Total de todas as notas fiscais lidas  */
       de-tot-geral-a-vista  = 0
       de-tot-geral-a-prazo  = 0
       de-tot-geral-vl-total = 0
       /* Totais das notas que foram atualizadas */
       de-tot-a-vista-NFOK   = 0
       de-tot-a-prazo-NFOK   = 0
       de-tot-vl-total-NFOK  = 0.

for each tt-total-refer:
    /* Totalizaá∆o de todas as notas fiscais lidas  */
    assign de-tot-geral-a-vista  = de-tot-geral-a-vista  + tt-total-refer.vendas-a-vista
           de-tot-geral-a-prazo  = de-tot-geral-a-prazo  + tt-total-refer.vendas-a-prazo
           de-tot-geral-vl-total = de-tot-geral-vl-total + tt-total-refer.vl-total.
end.

for each tt-retorno-nota-fiscal
    break by tt-retorno-nota-fiscal.tipo
          by entry(1, tt-retorno-nota-fiscal.cod-chave, ","):
/* IF entry(7, tt-retorno-nota-fiscal.cod-chave, ",") = "0037004" THEN */
/*    MESSAGE 'ponto A' skip                                       */
/*            tt-retorno-nota-fiscal.cod-erro SKIP                 */
/*            tt-retorno-nota-fiscal.desc-erro SKIP                */
/*            entry(4, tt-retorno-nota-fiscal.cod-chave, ",") SKIP */
/*            entry(6, tt-retorno-nota-fiscal.cod-chave, ",") SKIP */
/*            entry(7, tt-retorno-nota-fiscal.cod-chave, ",") SKIP */
/*                                                                 */
/*            tt-retorno-nota-fiscal.situacao VIEW-AS ALERT-BOX.   */

   if  tt-retorno-nota-fiscal.situacao then
       {utp/ut-liter.i Sim *}
   else
       {utp/ut-liter.i Nao *}
   assign c-sit = trim(return-value).

   if  tt-retorno-nota-fiscal.situacao 
   and tt-retorno-nota-fiscal.cod-erro = "0" then 
       next.

   /* Totais das notas que foram atualizadas */
   if  tt-retorno-nota-fiscal.cod-erro = "9999" then
       for each tt-total-refer
           where tt-total-refer.referencia = entry(1, tt-retorno-nota-fiscal.cod-chave, ","):
           assign de-tot-a-vista-NFOK   = de-tot-a-vista-NFOK  + tt-total-refer.vendas-a-vista
                  de-tot-a-prazo-NFOK   = de-tot-a-prazo-NFOK  + tt-total-refer.vendas-a-prazo
                  de-tot-vl-total-NFOK  = de-tot-vl-total-NFOK + tt-total-refer.vl-total.
       end.

   if  num-entries(tt-retorno-nota-fiscal.cod-chave,",") < 10 then
       assign tt-retorno-nota-fiscal.cod-chave = tt-retorno-nota-fiscal.cod-chave + ", , , , , , , , ,".

   if first-of(entry(1, tt-retorno-nota-fiscal.cod-chave, ","))
   OR entry(1, tt-retorno-nota-fiscal.cod-chave, ",") = "" then DO:
      ASSIGN c-referencia = entry(1, tt-retorno-nota-fiscal.cod-chave, ","). 
   /*   Put skip(2)
          "Referencia :" at 1 
          c-referencia   at 14 skip.*/
   END.

   assign c-referencia-aux = entry(1, tt-retorno-nota-fiscal.cod-chave, ",").

   for first nota-fiscal fields(nome-ab-cli nat-operacao cod-rep cod-portador modalidade no-ab-reppri cod-estabel serie nr-fatura nr-nota-fis cod-emitente) 
       where nota-fiscal.cod-estabel = entry(4, tt-retorno-nota-fiscal.cod-chave, ",")
         and nota-fiscal.serie = entry(6, tt-retorno-nota-fiscal.cod-chave, ",")
         and nota-fiscal.nr-fatura = entry(7, tt-retorno-nota-fiscal.cod-chave, ",") NO-LOCK:     
   end.
   IF NOT AVAIL nota-fiscal THEN
       for first nota-fiscal fields(nome-ab-cli nat-operacao cod-rep cod-portador modalidade no-ab-reppri cod-estabel serie nr-fatura nr-nota-fis cod-emitente) 
           where nota-fiscal.cod-estabel = entry(4, tt-retorno-nota-fiscal.cod-chave, ",")
             and nota-fiscal.serie       = entry(6, tt-retorno-nota-fiscal.cod-chave, ",")
             and nota-fiscal.nr-nota-fis = entry(7, tt-retorno-nota-fiscal.cod-chave, ",") NO-LOCK:     
       end.

   for first fat-repre fields(perc-comis comis-emis)
       where fat-repre.cod-estabel = entry(4, tt-retorno-nota-fiscal.cod-chave, ",")
         and fat-repre.serie       = entry(6, tt-retorno-nota-fiscal.cod-chave, ",")
         and fat-repre.nr-fatura   = entry(7, tt-retorno-nota-fiscal.cod-chave, ",")
         and fat-repre.nome-ab-rep = nota-fiscal.no-ab-reppri NO-LOCK:
   end.

   ASSIGN c-cod-esp  = entry(5, tt-retorno-nota-fiscal.cod-chave, ",")
          c-nr-docto = entry(7, tt-retorno-nota-fiscal.cod-chave, ",").

   ASSIGN i-port = 0.

   IF AVAIL nota-fiscal AND  nota-fiscal.cod-portador = 99501 THEN DO:
        for first fat-duplic 
        where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          and fat-duplic.serie = nota-fiscal.serie
          and fat-duplic.nr-fatura = nota-fiscal.nr-fatura
          AND fat-duplic.cod-esp = "CV":
    
        end.
    END.
    ELSE IF AVAIL nota-fiscal AND nota-fiscal.cod-portador = 99999 THEN DO:
        for first fat-duplic 
        where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          and fat-duplic.serie = nota-fiscal.serie
          and fat-duplic.nr-fatura = nota-fiscal.nr-fatura
          AND fat-duplic.cod-esp = "NF":

        end.
    END.
    ELSE IF AVAIL nota-fiscal THEN DO:
        for first fat-duplic 
        where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          and fat-duplic.serie = nota-fiscal.serie
          and fat-duplic.nr-fatura = nota-fiscal.nr-fatura
          AND fat-duplic.cod-esp = "CE":

        end.
    END.

    ASSIGN i-modalidade = 0.
    IF AVAIL fat-duplic THEN DO:
        ASSIGN i-modalidade = IF tt-param.i-cod-portador <> 0 AND fat-duplic.cod-vencto = 3 THEN 1
                              ELSE
                                 IF nota-fiscal.modalidade <> 0 THEN nota-fiscal.modalidade
                                 ELSE 1.
    END.

   ASSIGN c-conta-contabil = "".
   ASSIGN c-centro-custo = "".
   assign i-parcela = if avail fat-duplic then int(fat-duplic.parcela) else 0.

   
   IF AVAIL fat-duplic AND fat-duplic.flag-atualiz = YES THEN DO: 
        FOR EACH fat-duplic 
        where  fat-duplic.cod-estabel  = nota-fiscal.cod-estabel
          and  fat-duplic.serie        = nota-fiscal.serie
          AND  fat-duplic.nr-fatura    = nota-fiscal.nr-fatura
          AND (fat-duplic.cod-esp      = "CV" OR
               fat-duplic.cod-esp      = "CE" OR
               fat-duplic.cod-esp      = "NF")
          AND  fat-duplic.flag-atualiz = YES  NO-LOCK:  
    
    /*       IF fat-duplic.int-1 <> 99501 THEN DO:   /* portador convenio */             */
    /*                                                                                   */
    /*           FIND FIRST natur-oper NO-LOCK WHERE                                     */
    /*                      natur-oper.nat-operacao = nota-fiscal.nat-operacao NO-ERROR. */
    /*                                                                                   */
    /*           IF natur-oper.cod-cfop <> '6933' AND                                    */
    /*              natur-oper.cod-cfop <> '5933' THEN NEXT.                             */
    /*                                                                                   */
    /*       END.                                                                        */
    
          FIND FIRST tt-nf-ja-impressa NO-LOCK
               WHERE tt-nf-ja-impressa.cod-estabel = nota-fiscal.cod-estabel
               AND   tt-nf-ja-impressa.serie       = nota-fiscal.serie
               AND   tt-nf-ja-impressa.nr-fatura   = nota-fiscal.nr-fatura
               AND   tt-nf-ja-impressa.parcela     = fat-duplic.parcela
               AND   tt-nf-ja-impressa.cod-erro    = tt-retorno-nota-fiscal.cod-erro NO-ERROR.
    
          IF  AVAIL tt-nf-ja-impressa THEN
              NEXT.
    
          CREATE tt-nf-ja-impressa.
          ASSIGN tt-nf-ja-impressa.cod-estabel = nota-fiscal.cod-estabel
                 tt-nf-ja-impressa.serie       = nota-fiscal.serie
                 tt-nf-ja-impressa.nr-fatura   = nota-fiscal.nr-fatura
                 tt-nf-ja-impressa.parcela     = fat-duplic.parcela
                 tt-nf-ja-impressa.cod-erro    = tt-retorno-nota-fiscal.cod-erro.
    
          ASSIGN i-port = IF NOT fat-duplic.log-1 THEN
                             IF tt-param.i-cod-portador <> 0 AND fat-duplic.cod-vencto = 3 THEN tt-param.i-cod-portador
                             ELSE nota-fiscal.cod-portador
                          ELSE fat-duplic.int-1.
    
    
            ASSIGN c-conta-contabil = fat-duplic.ct-recven
                   c-centro-custo   = fat-duplic.sc-recven.
    
            ASSIGN i-cont = 1.
            RUN pi-print-editor (tt-retorno-nota-fiscal.desc-erro, 153).
            FOR EACH tt-editor WHERE
                     tt-editor.linha > 0:
                IF i-cont = 1 THEN
                   ASSIGN c-desc-erro = tt-editor.conteudo. 
                ASSIGN i-cont = i-cont + 1.
            END.
            /**/
    
            IF AVAIL nota-fiscal AND AVAIL fat-duplic AND (fat-duplic.cod-esp = "CV" AND fat-duplic.int-1 = 99501) THEN DO:
    
                FIND FIRST emitente WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-LOCK NO-ERROR.
    
                ASSIGN c-cgc = ''.
         
                FIND FIRST cst_nota_fiscal 
                     WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
                       AND cst_nota_fiscal.serie       = nota-fiscal.serie
                       AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis  NO-LOCK  NO-ERROR.
                IF AVAIL cst_nota_fiscal THEN DO:
                    ASSIGN c-cgc = replace(cst_nota_fiscal.cpf_cupom,".","").
                           c-cgc = replace(c-cgc,"/","").
                           c-cgc = replace(c-cgc,"-","").
                           
                   IF emitente.cgc <> c-cgc THEN DO:
                       FIND FIRST emitente WHERE emitente.cgc =  c-cgc NO-LOCK NO-ERROR.
                   END.
                   ELSE DO:
                       FIND FIRST emitente WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-LOCK NO-ERROR.
                   END.
                END.
    
    
    
                DISP emitente.nome-abrev WHEN AVAIL emitente
                     fat-duplic.cod-esp @ c-cod-esp
                     c-nr-docto
                     int(fat-duplic.parcela) FORMAT "99" @ i-parcela 
                     fat-duplic.vl-parcela  
                     fat-duplic.dt-venciment
                     fat-duplic.cod-vencto  
                     i-port
                     i-modalidade 
                     nota-fiscal.nat-operacao when avail nota-fiscal
                     tt-retorno-nota-fiscal.cod-erro
                     nota-fiscal.cod-estabel  WHEN avail nota-fiscal
                     nota-fiscal.serie        WHEN avail nota-fiscal  
                     c-desc-erro
                     with frame f-consitencia-emit.
                     down with frame f-consitencia-emit. 
    
    
    
            END.
            ELSE DO:
                DISP nota-fiscal.nome-ab-cli  WHEN avail nota-fiscal
                     fat-duplic.cod-esp @ c-cod-esp
                     c-nr-docto
                     int(fat-duplic.parcela) FORMAT "99" @ i-parcela 
                     fat-duplic.vl-parcela  
                     fat-duplic.dt-venciment
                     fat-duplic.cod-vencto  
                     i-port
                     i-modalidade 
                     nota-fiscal.nat-operacao when avail nota-fiscal
                     tt-retorno-nota-fiscal.cod-erro
                     nota-fiscal.cod-estabel  WHEN avail nota-fiscal
                     nota-fiscal.serie        WHEN avail nota-fiscal  
                     c-desc-erro
                     with frame f-consitencia.
                     down with frame f-consitencia. 
            END.
       END.
   END.
   ELSE DO:

        /**/
        ASSIGN i-cont = 1.
        RUN pi-print-editor (tt-retorno-nota-fiscal.desc-erro, 153).
        FOR EACH tt-editor WHERE
                 tt-editor.linha > 0:
            IF i-cont = 1 THEN
               ASSIGN c-desc-erro = tt-editor.conteudo. 
            ASSIGN i-cont = i-cont + 1.
        END.
        /**/

        IF c-cod-esp = "CV" OR c-cod-esp = "CE"   THEN DO:

            FIND FIRST emitente WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-LOCK NO-ERROR.
    
            ASSIGN c-cgc = ''.
     
            FIND FIRST cst_nota_fiscal
                 WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
                   AND cst_nota_fiscal.serie       = nota-fiscal.serie
                   AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK  NO-ERROR.
            IF AVAIL cst_nota_fiscal THEN DO:
                ASSIGN c-cgc = replace(cst_nota_fiscal.cpf_cupom,".","").
                       c-cgc = replace(c-cgc,"/","").
                       c-cgc = replace(c-cgc,"-","").
                       
               IF emitente.cgc <> c-cgc THEN DO:
                   FIND FIRST emitente WHERE emitente.cgc =  c-cgc NO-LOCK NO-ERROR.
               END.
               ELSE DO:
                   FIND FIRST emitente WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-LOCK NO-ERROR.
               END.
            END.

            DISP emitente.nome-abrev WHEN AVAIL emitente
                 c-cod-esp
                 c-nr-docto
                 i-parcela
                 fat-duplic.vl-parcela    when avail fat-duplic
                 fat-duplic.dt-venciment  when avail fat-duplic
                 fat-duplic.cod-vencto    when avail fat-duplic
                 i-port
                 i-modalidade 
                 nota-fiscal.nat-operacao when avail nota-fiscal
                 tt-retorno-nota-fiscal.cod-erro
                 nota-fiscal.cod-estabel  WHEN avail nota-fiscal
                 nota-fiscal.serie        WHEN avail nota-fiscal
                 c-desc-erro
                 with frame f-consitencia-emit.
            down with frame f-consitencia-emit.
        END.
        ELSE DO:
           DISP nota-fiscal.nome-ab-cli  WHEN avail nota-fiscal
                c-cod-esp
                c-nr-docto
                i-parcela
                fat-duplic.vl-parcela    when avail fat-duplic
                fat-duplic.dt-venciment  when avail fat-duplic
                fat-duplic.cod-vencto    when avail fat-duplic
                i-port
                i-modalidade 
                nota-fiscal.nat-operacao when avail nota-fiscal
                tt-retorno-nota-fiscal.cod-erro
                nota-fiscal.cod-estabel  WHEN avail nota-fiscal
                nota-fiscal.serie        WHEN avail nota-fiscal
                c-desc-erro
                with frame f-consitencia.
           down with frame f-consitencia.
        END.

   END.
end.

if  de-tot-geral-a-vista  <> 0
or  de-tot-geral-a-prazo  <> 0 then do:
    if  line-counter > page-size - 10 then
        page.
    put skip(2).
    {utp/ut-liter.i Notas_Atualizadas * R}
    put trim(return-value) form "x(22)" at 20.
    {utp/ut-liter.i Notas_com_Problemas * R}
    put trim(return-value) form "x(22)" at 43
        skip
        "---------------------- ----------------------" at 20
        skip.
     {utp/ut-liter.i Vendas_π_Vista * R}
    assign de-tot-geral-a-vista = de-tot-geral-a-vista - de-tot-a-vista-NFOK.
    put (trim(return-value) + ":") form "x(18)" to 18
        de-tot-a-vista-NFOK at 20
        de-tot-geral-a-vista at 43
        skip.
    {utp/ut-liter.i Vendas_a_Prazo * R}
    assign de-tot-geral-a-prazo = de-tot-geral-a-prazo - de-tot-a-prazo-NFOK.
    put (trim(return-value) + ":") form "x(18)" to 18
        de-tot-a-prazo-NFOK at 20
        de-tot-geral-a-prazo at 43
        skip.
    {utp/ut-liter.i Total * R}
    assign de-tot-geral-vl-total = de-tot-geral-vl-total - de-tot-vl-total-NFOK.
    put (trim(return-value) + ":") form "x(18)" to 18
        de-tot-vl-total-NFOK at 20
        de-tot-geral-vl-total at 43.
end.

/* hide frame f-rotina. */

if  page-number > 0 then
    page.

disp 
    c-selecao                
    da-emissao-ini    format "99/99/9999"              
    da-emissao-fim    format "99/99/9999"
    c-serie-ini    
    c-serie-fim   
    c-nota-fis-ini
    c-nota-fis-fim 
    de-embarque-ini 
    de-embarque-fim 
    c-param        
    c-estabel-ini
    c-estabel-fim  
    i-cod-portador     
    desc-titulo
    c-imp          
    c-destino      
    c-destino-impressao
    arquivo 
    c-usuario
    tt-param.usuario  
    with frame f-param.

    if  c-nom-prog-upc-mg97 <> "" then do:
        /* EPC */
        for each tt-epc where 
                 tt-epc.cod-event = "cond-pagto-especif".
            delete tt-epc.
        end.

        ASSIGN c-campo = "destino;arquivo;usuario;datas-exec;hora-exec;classifica;da-emis-ini;da-emis-fim;" +
                         "c-estabel-ini;c-serie-ini;c-serie-fim;c-nota-fis-ini;c-nota-fis-fim;de-embarque-ini;de-embarque-fim;" +
                         "i-cod-portador;rs-gera-titulo;desc-titulo;i-pais.c-estabel-fim;c-arquivo-exp".

        ASSIGN c-tipo = "integer;char;char;date;integer;integer;date;date;char;char;char;char;char;integer;integer;integer;integer;char;integer;char;char".

        ASSIGN c-valor = string(tt-param.destino)         + ";" + tt-param.arquivo                 + ";" +
                         tt-param.usuario                 + ";" + string(tt-param.data-exec)       + ";" +
                         string(tt-param.hora-exec)       + ";" + string(tt-param.classifica)      + ";" +
                         string(tt-param.da-emissao-ini)  + ";" + string(tt-param.da-emissao-fim)  + ";" +
                         tt-param.c-estabel-ini           + ";" + tt-param.c-serie-ini             + ";" +
                         tt-param.c-serie-fim             + ";" + tt-param.c-nota-fis-ini          + ";" +
                         tt-param.c-nota-fis-fim          + ";" + string(tt-param.de-embarque-ini) + ";" +
                         string(tt-param.de-embarque-fim) + ";" + string(tt-param.i-cod-portador)  + ";" +
                         string(tt-param.rs-gera-titulo)  + ";" + tt-param.desc-titulo             + ";" +
                         string(tt-param.i-pais)          + ";" + tt-param.c-estabel-fim           + ";" +
                         tt-param.c-arquivo-exp.

        /* Include i-epc200.i2: Criaá∆o de registro para Temp-Table tt-epc */
        {include/i-epc200.i2 &CodEvent='"fim ft0603rp"'
                             &CodParameter='"Campo"'
                             &ValueParameter="c-campo"}

        /* Include i-epc200.i2: Criaá∆o de registro para Temp-Table tt-epc */
        {include/i-epc200.i2 &CodEvent='"fim ft0603rp"'
                             &CodParameter='"Tipo"'
                             &ValueParameter="c-tipo"}

        /* Include i-epc200.i2: Criaá∆o de registro para Temp-Table tt-epc */
        {include/i-epc200.i2 &CodEvent='"fim ft0603rp"'
                             &CodParameter='"Valor"'
                             &ValueParameter="c-valor"}                         

        /* Include i-epc201.i: Chamada do programa de EPC */
        {include/i-epc201.i "fim ft0603rp"}

        /* Fim EPC */
    /* ------------------ INICIO UPC PARA EXITUS ---------------------- */
    /* Gilvane - 06/04/2005 */

    if  l-erro = no
    and l-ja-conec-emsuni = yes
    and l-ja-conec-emsbas = yes
    and l-ja-conec-emsfin = yes
    then do:

        for each tt-epc where tt-epc.cod-event = "atualizacao-nosso-numero":U:
           delete tt-epc.
        end.

        create tt-epc.
        assign tt-epc.cod-event     = "atualizacao-nosso-numero":U
               tt-epc.cod-parameter = "tt-param.destino":U
               tt-epc.val-parameter = string(tt-param.destino).

        {include/i-epc201.i "atualizacao-nosso-numero":U}
    end.
    /* ------------------ FIM UPC PARA EXITUS ---------------------- */
    END.

run pi-finalizar in h-acomp.
IF VALID-HANDLE(h_bodi135) THEN
    DELETE PROCEDURE h_bodi135.

{include/i-rpclo.i}
    
/* Trecho retirado: antiga tÇcnica da seguranáa por estabelecimento */
/* {cdp/cd0019.i1} /* finalizaá∆o da seguranáa por estabelecimento */ */

return "OK".

/**/
{include/pi-edit.i}
/**/

procedure pi-conecta-ems-5:

    def input param l-conecta as logical no-undo.
    def input param p-empresa like param-global.empresa-prin no-undo.
    def output param l-erro   as logical no-undo.

    assign l-erro = no.

    if  l-conecta then do:

        if  search("prgfin/acr/acr900zf.r":U)  = ? 
        and search("prgfin/acr/acr900zf.py":U) = ? then do:

            run utp/ut-msgs.p (input "msg":U,
                               input 6246,
                               input "prgfin/acr/acr900zf.py":U).
            create tt-retorno-nota-fiscal.
            assign tt-retorno-nota-fiscal.tipo         = 1
                   tt-retorno-nota-fiscal.cod-erro  = "6246":U
                   tt-retorno-nota-fiscal.cod-chave = ",,,,,,,,,"
                   tt-retorno-nota-fiscal.desc-erro = return-value
                   tt-retorno-nota-fiscal.situacao  = no.
            assign l-erro = yes.                                

        end.
        else do:
            if  connected("emsuni") 
                then assign l-ja-conec-emsuni = yes.
                else assign l-ja-conec-emsuni = no.

            if  connected("emsbas") 
                then assign l-ja-conec-emsbas = yes.
                else assign l-ja-conec-emsbas = no.

            if  connected("emsfin") 
                then assign l-ja-conec-emsfin = yes.
                else assign l-ja-conec-emsfin = no.

            if  l-ja-conec-emsuni = no or 
                l-ja-conec-emsbas = no or
                l-ja-conec-emsfin = no then do:

                {utp/ut-liter.i Conex∆o_Bancos_Externos_EMS5 *}
                run pi-acompanhar in h-acomp (input  Return-value ).
                IF VALID-HANDLE(h-btb009za) THEN
                    run pi-conecta-bco IN h-btb009za (Input 1, /* Versao API  */
                                                      input 1, /* 1 - conexao, 2 - Desconexao */
                                                      input p-empresa, /* Codigo da empresa */
                                                      input "all":U, /* nome do banco */
                                                      output table tt_erros_conexao). /* temp-table de erros */
                if  return-value <> "OK":U then do:
                    find first tt_erros_conexao no-lock no-error.
                    if avail tt_erros_conexao then do:
                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo   = 1
                            tt-retorno-nota-fiscal.cod-erro  = string(tt_erros_conexao.cd-erro)
                            tt-retorno-nota-fiscal.desc-erro = tt_erros_conexao.param-1
                            tt-retorno-nota-fiscal.cod-chave = ",":U + ",":U + ",":U + ",":U + ",":U + ",":U + ",":U + ",":U
                            tt-retorno-nota-fiscal.situacao  = no.
                        assign l-erro = yes.                                              
                    end.               
                end.                
            end. 
        end.
    end.

    if  not l-conecta or l-erro then do:
        if l-ja-conec-emsuni = no 
        or l-ja-conec-emsbas = no 
        or l-ja-conec-emsfin = no then do: 

            {utp/ut-liter.i Desconex∆o_Bancos_Externos_EMS5 *}
            run pi-acompanhar in h-acomp (input  Return-value ).
            IF VALID-HANDLE(h-btb009za) THEN
                run pi-conecta-bco IN h-btb009za (Input 1, /* Versao API  */
                                                  input 2, /* 1 - conexao, 2 - Desconexao */
                                                  input p-empresa, /* Codigo da empresa */
                                                  input "all":U, /* nome do banco */
                                                  output table tt_erros_conexao). /* temp-table de erros */
            if return-value <> "OK":U then do:
                find first tt_erros_conexao no-lock no-error.
                if avail tt_erros_conexao then do:
                    create tt-retorno-nota-fiscal.
                    assign tt-retorno-nota-fiscal.tipo   = 1
                        tt-retorno-nota-fiscal.cod-erro  = string(tt_erros_conexao.cd-erro)
                        tt-retorno-nota-fiscal.desc-erro = tt_erros_conexao.param-1
                        tt-retorno-nota-fiscal.cod-chave = ",":U + ",":U + ",":U + ",":U + ",":U + ",":U + ",":U + ",":U
                        tt-retorno-nota-fiscal.situacao  = no.
                    assign l-erro = yes.                                              
                end.
            end.
        end.
    end.   
    if l-erro = no then do:
        if  c-nom-prog-upc-mg97 <> "" then do:
            /* ------------------ INICIO UPC ---------------------- */
            for each tt-epc where tt-epc.cod-event = "api_tit_cr_cria":U:
               delete tt-epc.
            end.

            create tt-epc.
            assign tt-epc.cod-event     = "api_tit_cr_cria":U 
                   tt-epc.cod-parameter = "rowid(doc-i-cr)":U
                   tt-epc.val-parameter = string(rowid(doc-i-cr)).

            {include/i-epc201.i "api_tit_cr_cria":U}

            /* ------------------ FIM UPC ---------------------- */                 
        END.
    end.
end.          

PROCEDURE pi-valida-rma:

    /* Verifica se Ç Nota de CrÇdito vinculada a um RMA */
    if  nota-fiscal.ind-tip-nota              = 4 and
        substr(nota-fiscal.nr-nota-ant,4,12) <> "" then do:

        /* Se for ent∆o localiza o RMA que gerou a NC */
        find first rma where
                   rma.cod-rma     = substr(nota-fiscal.nr-nota-ant,4,12) and
                   rma.cod-estabel = nota-fiscal.cod-estabel no-lock no-error.
        if  avail rma then

            /* Verifica se o RMA gerou ND */
            if  {&TRUE-log-nota-debito-rma} then do:

                /* Procura a nota de dÇbito vinculada ao RMA */
                find first b-nota-debito where
                           b-nota-debito.cod-estabel              = nota-fiscal.cod-estabel and
                           b-nota-debito.ind-tip-nota             = 4                       and
                           substr(b-nota-debito.nr-nota-ant,4,12) = rma.cod-rma no-lock no-error.
                if  avail b-nota-debito then

                    /* Se a ND n∆o estiver atualizada no CR ent∆o a NC n∆o pode ser
                       atualizada*/

                    if  b-nota-debito.dt-atual-cr = ? then do:

                        run utp/ut-msgs.p (input "msg",
                                           input 27147,
                                           input "").

                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo       = 3
                               tt-retorno-nota-fiscal.cod-erro   = "27147"
                               tt-retorno-nota-fiscal.desc-erro  = return-value
                               tt-retorno-nota-fiscal.situacao   = no
                               tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia
                               tt-retorno-nota-fiscal.cod-chave  = "" + ",," +
                                                                   string(i-empresa) + "," +
                                                                   nota-fiscal.cod-estabel + ",," +
                                                                   nota-fiscal.serie + "," +
                                                                   if nota-fiscal.nr-fatura = "" then
                                                                      nota-fiscal.nr-nota-fis 
                                                                    else 
                                                                      nota-fiscal.nr-fatura + ",".
                        next.
                    end.
            end.
            else do:

                /* Se n∆o gerou, ent∆o verifica se existe valor ou % de restocagem a ser atualizado */
                find first rma-item where
                           rma-item.cod-rma     = rma.cod-rma     and
                           rma-item.cod-estabel = rma.cod-estabel and
                           (rma-item.val-perc-restocagem <> 0 or
                            rma-item.val-restocagem      <> 0) no-lock no-error.

                /* Se n∆o encontrar, procura por alguma despesa adicional vinculada ao RMA */
                if  not avail rma-item then do:

                    find first rma-desp where
                               rma-desp.cod-rma = rma.cod-rma and
                               rma-desp.cod-estabel = rma.cod-estabel no-lock no-error.
                    if  avail rma-desp then do:

                        /* Se encontrar ent∆o a nota n∆o pode ser atualizada */

                        run utp/ut-msgs.p (input "msg",
                                           input 27148,
                                           input "").                                

                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo       = 3
                               tt-retorno-nota-fiscal.cod-erro   = "27148"
                               tt-retorno-nota-fiscal.desc-erro  = return-value
                               tt-retorno-nota-fiscal.situacao   = no
                               tt-retorno-nota-fiscal.referencia = tt-nota-fiscal.referencia
                               tt-retorno-nota-fiscal.cod-chave  = "" + ",," +
                                                                   string(i-empresa) + "," +
                                                                   nota-fiscal.cod-estabel + ",," +
                                                                   nota-fiscal.serie + "," +
                                                                   if nota-fiscal.nr-fatura = "" then
                                                                      nota-fiscal.nr-nota-fis 
                                                                    else 
                                                                      nota-fiscal.nr-fatura + ",".
                       next.
                    end.
                end.
            end.
    end.        

END PROCEDURE. 

