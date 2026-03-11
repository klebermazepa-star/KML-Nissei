/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int033RP 2.12.00.001 } /* */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i int033RP MOF}
&ENDIF
 
{include/i_fnctrad.i}
/********************************************************************************
** Copyright DATASUL S.A. (2004)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

/****************************************************************************
**
**  Programa: int033RP.P
**
**  Data....: Junho de 2016
**
**  Autor...: ResultPro 
**
**  Objetivo: Demonstrativo Auxiliar de PIS e Cofins
**
******************************************************************************/

/*** definiá∆o de pre-processador ***/
{cdp/cdcfgdis.i} 

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    FIELD dt-periodo-ini   AS DATE FORMAT "99/99/9999"
    FIELD dt-periodo-fim   AS DATE FORMAT "99/99/9999"
    FIELD cod-estabel-ini  AS CHAR format "x(05)"
    FIELD cod-estabel-fim  AS CHAR FORMAT "x(03)"
    FIELD rs-modo          AS INTEGER
    FIELD rs-relatorio     AS INTEGER.

DEF TEMP-TABLE tt-doc-fiscal NO-UNDO LIKE doc-fiscal 
    FIELD tipo-nota          AS INTEGER
    FIELD tipo-apuracao      AS INTEGER 
    FIELD estab              AS CHARACTER
    FIELD l-valor            AS LOGICAL /* Variavel que define se o documento possui valor de pis ou cofins */
    FIELD cfop-ini           AS CHAR FORMAT "x(01)"
    FIELD cd-trib-pis        AS CHAR FORMAT "x(01)"
    FIELD cd-trib-cofins     AS CHAR FORMAT "x(01)"
    INDEX selecao estab 
                  serie       
                  nr-doc-fis 
                  cod-emitente    
                  nat-operacao  
                  tipo-apuracao.

/*** definiá∆o de vari†veis locais ***/
DEF VAR h-acomp             AS HANDLE                                              NO-UNDO. 
def var c-cod-fisc          as char format "x(27)"                                 no-undo.
def var de-vl-contab        as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-base-pis         as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-base-cofins      as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-vl-pis           as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-vl-cofins        as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var c-desc-nat          as char format "x(40)"                                 no-undo.
def var c-inscricao         as char format "x(19)"                                 no-undo.
def var c-cgc               like estabelec.cgc                                     no-undo.
def var c-iniper            as char format "99/99"                                 no-undo.
def var c-fimper            as char format "x(10)"                                 no-undo.
def var c-cod-est           like estabelec.cod-estabel                             no-undo.
def var de-acm-ct1          as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-acm-bsipi        as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-acm-bcof         as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-acm-vlipi        as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-acm-vlcof        as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-acm-vlipi-ent    as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-acm-vlcof-ent    as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-saldo-cre-pi     as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-saldo-de-pi      as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-saldo-cre-cof    as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
def var de-saldo-de-cof     as dec  format '->,>>>,>>>,>>9.99'                     no-undo.
DEF VAR d-vl-tot-item       LIKE it-doc-fisc.vl-tot-item                           NO-UNDO.
DEF VAR d-vl-base-calc-pis  LIKE it-doc-fisc.val-base-calc-pis                     NO-UNDO.
DEF VAR d-vl-pis            LIKE it-doc-fisc.val-pis                               NO-UNDO.
DEF VAR d-vl-base-calc-cofins      LIKE it-doc-fisc.val-base-calc-cofins           NO-UNDO.
DEF VAR d-vl-cofins                LIKE it-doc-fisc.val-cofins                     NO-UNDO.
DEF VAR d-vl-tot-item-cfop         LIKE it-doc-fisc.vl-tot-item                    NO-UNDO.
DEF VAR d-vl-base-calc-pis-cfop    LIKE it-doc-fisc.val-base-calc-pis              NO-UNDO.
DEF VAR d-vl-pis-cfop              LIKE it-doc-fisc.val-pis                        NO-UNDO.
DEF VAR d-vl-base-calc-cofins-cfop LIKE it-doc-fisc.val-base-calc-cofins           NO-UNDO.
DEF VAR d-vl-cofins-cfop           LIKE it-doc-fisc.val-cofins                     NO-UNDO.
DEF VAR d-vl-tot-item-bq           LIKE it-doc-fisc.vl-tot-item                    NO-UNDO.
DEF VAR d-vl-base-calc-pis-bq      LIKE it-doc-fisc.val-base-calc-pis              NO-UNDO.
DEF VAR d-vl-pis-bq                LIKE it-doc-fisc.val-pis                        NO-UNDO.
DEF VAR d-vl-base-calc-cofins-bq   LIKE it-doc-fisc.val-base-calc-cofins           NO-UNDO.
DEF VAR d-vl-cofins-bq             LIKE it-doc-fisc.val-cofins                     NO-UNDO.
                       

DEFINE VARIABLE c-lbl-liter-total   AS CHARACTER FORMAT "X(16)" NO-UNDO.
DEFINE VARIABLE c-lbl-liter-total-3 AS CHARACTER FORMAT "X(16)" NO-UNDO.
DEFINE VARIABLE c-label-1           AS CHARACTER FORMAT "X(34)" NO-UNDO.
DEFINE VARIABLE c-label-2           AS CHARACTER FORMAT "X(34)" NO-UNDO.

def var de-cotacao          as dec decimals 4 format ">>>,>>>,>>9.9999" init 1     no-undo.
def var de-conv             as dec init 1                                          no-undo.
def var c-estabel           like estabelec.nome                                    no-undo.
def var c-saida             as char format "x(40)"                                 no-undo.
def var c-des               as char format "x(40)"                                 no-undo.                  
def var c-modo              as char format "x(25)"                                 no-undo.
def var c-rel               as char format "x(25)"                                 no-undo.
def var l-mostra            as logical initial YES                                 no-undo.
def var da-dt-cfop          as date                                                no-undo.
def var c-desc-cfop-nat     as char                                                no-undo.
def var l-cabec             as logical initial no                                  no-undo.
def var n-val-pis           as decimal                                             no-undo.
def var n-val-cofins        as decimal                                             no-undo.
def var n-val-retenc-pis    as dec                                                 no-undo.
def var n-val-retenc-cofins as dec                                                 no-undo.
def var dt-cont             as date                                                no-undo.                                                                                
def var c-lb-cof            as char format "x(10)"                                 no-undo.
def var c-lb-pis            as char format "x(10)"                                 no-undo.
def var c-lb-tot-entr       as char format "x(24)"                                 no-undo.
def var c-lb-tot-sai        as char format "x(24)"                                 no-undo.
def var c-lb-sal-cre        as char format "x(24)"                                 no-undo. 
def var c-lb-sal-dev        as char format "x(24)"                                 no-undo.
def var c-resumo            as char format "x(24)"                                 no-undo.
def var c-lb-tot-entradas   as char format "x(24)"                                 no-undo.
def var c-lb-tot-saidas     as char format "x(24)"                                 no-undo.
DEF VAR tipo                AS INTEGER                                             NO-UNDO.

def buffer b-natur-oper for natur-oper.
/* Transfer Definitions */

def temp-table tt-raw-digita NO-UNDO
    field raw-digita as raw.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

{include/i-rpvar.i}

/*** Definiá∆o de Forms ***/
form 
   SKIP(1)
   /*tt-doc-fiscal.cod-estab  FORMAT "x(03)" at 01 */
   /*SKIP (1)*/
   c-cod-fisc               at 01
   de-vl-contab             at 35 
   de-base-pis              at 55 
   de-base-cofins           at 75 
   de-vl-pis                at 095
   de-vl-cofins             at 115 SKIP
   c-desc-nat               at 01  skip(1) 
   with DOWN stream-io width 132 no-box no-labels frame f-FORM. /* layout normal */

form
   SKIP(1)
   c-cod-fisc             at 01
   de-vl-contab           at 35
   de-vl-pis              at 55
   de-vl-cofins           at 75 skip
   c-desc-nat             at 01 skip(1)
   with DOWN stream-io width 132 no-box no-labels frame f-FORM2. /* layout retido */

form
   SKIP(1)
   c-cod-fisc             at 01
   de-vl-contab           at 35
   de-vl-pis              at 55
   de-vl-cofins           at 75 SKIP(01)
   with DOWN stream-io width 132 no-box no-labels frame f-FORM3. /* layout retido */

form
   SKIP(1)
   c-cod-fisc             at 01
   de-vl-contab           at 35
   de-vl-pis              at 55
   de-vl-cofins           at 75 SKIP(1)
   with DOWN stream-io width 132 no-box no-labels frame f-FORM4. /* layout retido */

form
   tt-doc-fiscal.cod-estab  FORMAT "x(03)" at 01
   tt-doc-fiscal.nr-doc-fis FORMAT "X(9)"  AT 05 
   "-"
   tt-doc-fiscal.serie        at 17
   "-"
   tt-doc-fiscal.cod-emitente at 24
   de-vl-contab            at 35
   de-base-pis             at 55
   de-base-cofins          at 75
   de-vl-pis               at 095
   de-vl-cofins            at 115 skip
   with DOWN stream-io width 132 no-box no-labels frame f-docto. /* layout normal */

form
   tt-doc-fiscal.cod-estab  FORMAT "x(03)" at 01
   it-doc-fisc.class-fiscal
   it-doc-fisc.it-codigo    FORMAT "X(11)"   
   tt-doc-fiscal.nr-doc-fis FORMAT "X(7)"   
   de-vl-contab            at 35
   de-base-pis             at 55
   de-base-cofins          at 75
   de-vl-pis               at 095
   de-vl-cofins            at 115 skip
   with DOWN stream-io width 132 no-box no-labels frame f-docto-item. /* layout normal item */

form
   SKIP
   tt-doc-fiscal.cod-estab  FORMAT "x(03)" at 01  
   tt-doc-fiscal.nr-doc-fis FORMAT "X(9)"  at 05 
   "-"
   tt-doc-fiscal.serie        at 17
   "-"
   tt-doc-fiscal.cod-emitente at 24
   de-vl-contab            at 35
   de-vl-pis               at 55
   de-vl-cofins            at 75 SKIP
   with stream-io width 132 no-box no-labels frame f-docto2. /* layout retido */ 

form header
   skip
   "FIRMA" at 01 space ":"  space   c-estabel 
   "INSCR. EST." at 55 space "-" space  c-inscricao 
   "C.N.P.J." at 89 space "-" space  c-cgc 
   "FOLHA"         at 121 page-number format ">>>>>9" skip(1)
    with stream-io width 132 no-labels no-box page-top frame f-cab.

form header
   skip(1)
   "PER÷ODO" at 01 space(02) "-" space(01) c-iniper space(01) "A"  space(01) c-fimper 
   "APURAÄ«O DE PIS/COFINS NAS ENTRADAS" at 52  space "-" space "NORMAL"  SKIP
   "ESTABEL." AT 01 SPACE(01) "-" SPACE(01) tt-param.cod-estabel-ini SPACE(01) "A" SPACE(01) tt-param.cod-estabel-fim SKIP(1)
   /*"ESTAB "  AT 01 */
   c-label-1 at 07 space(11) "VALOR" space(13) "BASE DE" space(13) "BASE DE" space(5) "VALOR PIS/PASEP" space(08) "VALOR COFINS"  
   c-label-2 at 07 space(08) "CONTµBIL" space(09) "CµLCULO PIS" space(06) "CµLCULO COFINS"   skip(1)
   with stream-io width 162 no-labels no-box page-top frame f-cabDoc.

form header
   skip(1)
    "PER÷ODO" at 01 space(02) "-" space(01) c-iniper space(01) "A"  space(01) c-fimper 
    "APURAÄ«O DE PIS/COFINS NAS SA÷DAS" at 52  space "-" space "NORMAL"  skip(1)
    "C‡DIGO" at 01 space(36) "VALOR" space(13) "BASE DE" space(13) "BASE DE" space(5) "VALOR PIS/PASEP" space(08) "VALOR COFINS"  
    "FISCAL" at 01 space(33) "CONTµBIL" space(09) "CµLCULO PIS" space(06) "CµLCULO COFINS"   skip(1)
   with stream-io width 162 no-labels no-box page-top frame f-cabDoc2.


form header
   skip(1)
   "PER÷ODO" at 01 space(2) "-" space(01)  c-iniper space(01) "A" space(01) c-fimper 
   "APURAÄ«O DE PIS/COFINS NAS ENTRADAS" at 52 space "-" space "RETIDO"  skip(1)
   "C‡DIGO" at 01 space(36) "VALOR"  space(05) "VALOR PIS/PASEP" space(08) "VALOR COFINS"  
   "FISCAL" at 01 space(33) "CONTµBIL" SKIP(01)
   with stream-io width 132 no-labels no-box page-top frame f-Retido. 

form header
   skip(1)
    "PER÷ODO" at 01 space(2) "-" space(01)  c-iniper space(01) "A" space(01) c-fimper 
    "APURAÄ«O DE PIS/COFINS NAS SA÷DAS" at 52 space "-" space "RETIDO"  skip(1)
    "C‡DIGO" at 01 space(36) "VALOR"  space(05) "VALOR PIS/PASEP" space(08) "VALOR COFINS"  
    "FISCAL" at 01 space(33) "CONTµBIL" SKIP(01)
   with stream-io width 132 no-labels no-box page-top frame f-Retido2. 

form   
    skip (04)
    "SELEÄ«O"  at 10  skip(01)
    tt-param.dt-periodo-ini    label "Per°odo."         at 30 "|<    >|" at 50
    tt-param.dt-periodo-fim    no-label                 at 63 skip(1)
    "PAR∂METROS" at 10 skip(1)
    tt-param.cod-estabel-ini label "Estabelecimento"  colon 34 "|<    >|" AT 50
    tt-param.cod-estabel-fim NO-LABEL                          SKIP
    tt-param.rs-modo        label "Modo Execuá∆o"     colon 34 skip
    skip(1)
    "IMPRESS«O" at 10  skip(1)
    c-saida label "Destino"                        colon 34  
    tt-param.usuario  label "Usu†rio"              colon 34 
    with side-labels stream-io frame f-resumo.

/*** traduá∆o dos textos ***/
run utp/ut-trfrrp.p (input frame f-resumo:handle).
run utp/ut-trfrrp.p (input frame f-retido2:handle).
run utp/ut-trfrrp.p (input frame f-retido:handle).
run utp/ut-trfrrp.p (input frame f-cab:handle).

{utp/ut-liter.i RESUMO_FINAL  * r }
assign c-resumo  = return-value.
{utp/ut-liter.i PIS  * r }
assign c-lb-pis  = return-value.
{utp/ut-liter.i COFINS  * r }
assign c-lb-cof  = return-value.
{utp/ut-liter.i Total_das_Entradas...: * r }
assign c-lb-tot-entr  = return-value.
{utp/ut-liter.i Total_das_Sa°das.....: * r }
assign c-lb-tot-sai  = return-value.
{utp/ut-liter.i Saldo_Credor.........: * r }
assign c-lb-sal-cre  = return-value.
{utp/ut-liter.i Saldo_Devedor........: * r }
assign c-lb-sal-dev  = return-value.

{utp/ut-liter.i Total_Entradas * r }
assign c-lb-tot-entradas  = return-value.
{utp/ut-liter.i Total_Sa°das * r }
assign c-lb-tot-saidas  = return-value.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Int033 - Demonstrativo Auxiliar de PIS/COFINS").

FIND FIRST param-global NO-ERROR.

FIND FIRST ems2mult.empresa NO-LOCK WHERE
           empresa.ep-codigo = param-global.empresa-prin NO-ERROR.

if AVAIL empresa then 
   assign c-cod-est   = string(empresa.ep-codigo) 
          c-estabel   = empresa.razao-social
          c-inscricao = empresa.inscr-estad
          c-cgc       = empresa.cgc.


{utp/ut-liter.i OBRIGAÄÂES FISCAIS  * r }
assign c-sistema  = return-value.

assign c-programa       = "int/033"
       de-acm-ct1       = 0
       de-acm-bsipi     = 0
       de-acm-bcof      = 0
       de-acm-vlipi     = 0
       de-acm-vlcof     = 0
       de-saldo-cre-pi  = 0   
       de-saldo-de-pi   = 0
       de-saldo-de-cof  = 0
       de-saldo-cre-cof = 0
       c-iniper         = string(day(tt-param.dt-periodo-ini),"99")
                        + string(month(tt-param.dt-periodo-ini),"99")
       c-fimper         = substring(string(tt-param.dt-periodo-fim,"99/99/9999"),1,2)
                        + "/" + substring(string(tt-param.dt-periodo-fim,"99/99/9999"),4,2)
                        + "/" + substring(string(tt-param.dt-periodo-fim,"99/99/9999"),7,4).

{include/i-rpout.i}
/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i}

view frame f-cab.
view frame f-rodape.

RUN pi-seleciona-doctos.

if tt-param.rs-relatorio = 1 then do: /*** PIS/COFINS NORMAL ***/
    case tt-param.rs-modo: 
         when 1 then do: 
             ASSIGN c-label-1 = "CFOP"
                    c-label-2 = "".
                             
             view frame f-cabDoc.

             /* DOCUMENTOS DE ENTRADA e Sa°da */
             {intprg/int033rp.i tt-doc-fiscal.cfop-ini tt-doc-fiscal.cod-cfop tt-doc-fiscal.nat-operacao tt-doc-fiscal.nr-doc-fis}  
             
             run pi-imprime-resumo.
        end.
        when 2 then do: /*** NATUREZA DE OPERAÄ«O ***/

            ASSIGN c-label-1 = "NATUREZA DE"
                   c-label-2 = "OPERAÄ«O".

             view frame f-cabDoc.

             /* DOCUMENTOS DE ENTRADA */
            
             {intprg/int033rp.i  tt-doc-fiscal.cfop-ini tt-doc-fiscal.cod-cfop tt-doc-fiscal.nat-operacao tt-doc-fiscal.nr-doc-fis} 

             run pi-imprime-resumo. 
        end.
        when 3 then do:  /*** DOCUMENTO FISCAL ***/

             ASSIGN c-label-1 = "EST DOCUMENTO  SERIE   FORNECEDOR"
                    c-label-2 = "    FISCAL".

             view frame f-cabDoc.

             {intprg/int033rp.i tt-doc-fiscal.cfop-ini tt-doc-fiscal.cod-cfop tt-doc-fiscal.nat-operacao tt-doc-fiscal.nr-doc-fis}
             
             run pi-imprime-resumo.
        end.
           
         when 4 then do:  /*** Classificaá∆o Fiscal ***/

             ASSIGN c-label-1 = "EST CLASSIFICAÄ«O  ITEM   DOCTO"
                    c-label-2 = "    FISCAL".

             view frame f-cabDoc.

             {intprg/int033rp.i tt-doc-fiscal.cfop-ini tt-doc-fiscal.cod-cfop tt-doc-fiscal.nat-operacao it-doc-fisc.class-fiscal} 
             
             run pi-imprime-resumo.
        end.

       
   end case. 
end. 

run pi-imprime-param.

{include/i-rpclo.i}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U.

/* Procedure Modo CFOP - Relat¢rio Normal */
procedure pi-normal-cfop:



/* if  p-tipo-nat = 3 then do:
    hide frame f-cabDoc.

    if l-mostra = yes and l-cabec = yes
        then view frame f-cabDoc2.
    else
        /* Inicio -- Projeto Internacional */
        DO:
        DEFINE VARIABLE c-lbl-liter-apuracao-de-piscofins-nas-said AS CHARACTER FORMAT "X(44)" NO-UNDO.
        {utp/ut-liter.i "APURAÄ«O_DE_PIS/COFINS_NAS_SA÷DAS_-_NORMAL" *}
        ASSIGN c-lbl-liter-apuracao-de-piscofins-nas-said = RETURN-VALUE.
        put skip(1) c-lbl-liter-apuracao-de-piscofins-nas-said at 52 skip(02).
        END. 
end.
*/


end procedure.

/* Procedure Modo Nat Operaá∆o - Relat¢rio Normal 
procedure pi-normal-nat-operacao:
    {ofp/of0770.i8}
end procedure.

/* Procedure Modo Documento - Relat¢rio Normal */
procedure pi-normal-docto:
    {ofp/of0770.i9}
end procedure. 

/* Procedure Modo CFOP - Relat¢rio Retido */
procedure pi-retido-cfop:
    {ofp/of0770.i10}
end procedure.

/* Procedure Modo Nat Operaá∆o - Relat¢rio Retido */
procedure pi-retido-nat-operacao:
    {ofp/of0770.i11}  
end procedure. 

/* Procedure Modo Documento - Relat¢rio Retido */
procedure pi-retido-docto:
    {ofp/of0770.i12}
end procedure.

*/

procedure pi-imprime-resumo:

    if (de-acm-vlipi - de-acm-vlipi-ent) > 0 then 
        assign de-saldo-de-pi  = (de-acm-vlipi - de-acm-vlipi-ent).
    else if (de-acm-vlipi - de-acm-vlipi-ent) < 0 THEN 
        assign de-saldo-cre-pi = (de-acm-vlipi - de-acm-vlipi-ent).

    if (de-acm-vlcof - de-acm-vlcof-ent) > 0 then 
        assign de-saldo-de-cof  = (de-acm-vlcof - de-acm-vlcof-ent).
    else if (de-acm-vlcof - de-acm-vlcof-ent) < 0 then
        assign de-saldo-cre-cof = (de-acm-vlcof - de-acm-vlcof-ent).

    IF  de-saldo-cre-pi  < 0 THEN
        ASSIGN de-saldo-cre-pi  = de-saldo-cre-pi  * -1.

    IF  de-saldo-cre-cof < 0 THEN
        ASSIGN de-saldo-cre-cof = de-saldo-cre-cof * -1.

    if  line-counter + 4 > page-size then page.

    put skip c-resumo  at 78                                              skip(01).
    put  c-lb-pis      at 90 SPACE(06) c-lb-cof                           skip
         c-lb-tot-entr at 52  de-acm-vlipi-ent SPACE(02) de-acm-vlcof-ent skip
         c-lb-tot-sai  at 52  de-acm-vlipi     SPACE(02) de-acm-vlcof     skip
         c-lb-sal-cre  at 52  de-saldo-cre-pi  SPACE(02) de-saldo-cre-cof skip
         c-lb-sal-dev  at 52  de-saldo-de-pi   SPACE(02) de-saldo-de-cof.

end procedure.

procedure pi-imprime-param:

    case tt-param.rs-modo:
        when 1  then do:
            {utp/ut-liter.i Por_CFOP  * r }
            assign c-modo  = return-value.
        end.
        when 2 then do:
            {utp/ut-liter.i Por_Natureza_de_Operaá∆o  * r }
            assign c-modo  = return-value.
        end.
        when 3  then
        do:
            {utp/ut-liter.i Por_Documento_Fiscal  * r }
            assign c-modo  = return-value.
        end.
        when 4  then
        do:
            {utp/ut-liter.i Por_Classificaá∆o_Fiscal  * r }
            assign c-modo  = return-value.
        end.

    end case.

    case tt-param.rs-relatorio:
        when 1  then do:
            {utp/ut-liter.i PIS/COFINS_Normal  * r }
            assign c-rel  = return-value.
        end.
        when 2 then do:
            {utp/ut-liter.i PIS/COFINS_Retido  * r }
            assign c-rel  = return-value.
        end.
    end case.

    case tt-param.destino:
       when 1 then do:
          {utp/ut-liter.i Impressora  * r }
          assign c-des  = return-value.
       end.        

       when 2 then do:
          {utp/ut-liter.i Arquivo  * r }
          assign c-des  = return-value.
       end.

       when 3 then do:
           {utp/ut-liter.i Terminal  * r }
           assign c-des  = return-value.
       end.
    end. 

    page.

    hide frame f-cabDoc.
    hide frame f-cabDoc2.
    hide frame f-retido.
    hide frame f-retido2.

    disp tt-param.dt-periodo-ini    
         tt-param.dt-periodo-fim    
         tt-param.cod-estabel-ini    
         tt-param.cod-estabel-fim
         c-modo @ tt-param.rs-modo
         trim(c-des) + '   -   ' + tt-param.arquivo @ c-saida
         tt-param.usuario
         with frame f-resumo.

end procedure. 

procedure pi-desc-cfop:
    def output param p-data  as date.
    def output param p-natur as CHAR FORMAT "x(200)".


    {cdp/of0770.i1 "tt-doc-fiscal.cod-estabel"}
    {cdp/of0770.i3 "tt-doc-fiscal" "tt-doc-fiscal.dt-docto"}    
    
    assign p-data  = da-dt-cfop     
           p-natur = c-desc-cfop-nat.

end procedure.

PROCEDURE pi-seleciona-doctos:
    
    DEF VAR l-considera-apuracao-normal AS LOGICAL  NO-UNDO.
    DEF VAR l-considera-apuracao-retido AS LOGICAL  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-doc-fiscal.

   for each doc-fiscal use-index ch-notas where 
            doc-fiscal.dt-docto    >= tt-param.dt-periodo-ini  and 
            doc-fiscal.dt-docto    <= tt-param.dt-periodo-fim  and     
            doc-fiscal.cod-estabel >= tt-param.cod-estabel-ini and
            doc-fiscal.cod-estabel <= tt-param.cod-estabel-fim AND  
            doc-fiscal.ind-sit-doc <> 2 NO-LOCK, /* cancelado */
    first natur-oper where 
          natur-oper.nat-operacao = doc-fiscal.nat-operacao no-lock:
       
    /* VERIFICA CAMPOS PIS/CPOFINS NORMAL */    
    ASSIGN l-considera-apuracao-normal = 
               CAN-FIND(FIRST it-doc-fisc
                        WHERE it-doc-fisc.cod-estabel  = doc-fiscal.cod-estabel
                        AND   it-doc-fisc.nat-operacao = doc-fiscal.nat-operacao
                        AND   it-doc-fisc.cod-emitente = doc-fiscal.cod-emitente
                        AND   it-doc-fisc.serie        = doc-fiscal.serie
                        AND   it-doc-fisc.nr-doc-fis   = doc-fiscal.nr-doc-fis
                        AND  (it-doc-fisc.val-pis    <> 0 OR 
                              it-doc-fisc.val-cofins <> 0)).
    
    /* VERIFICA CAMPOS PIS/CPOFINS RETIDO */    
    ASSIGN l-considera-apuracao-retido =
               CAN-FIND(FIRST it-doc-fisc
                        WHERE it-doc-fisc.cod-estabel  = doc-fiscal.cod-estabel
                        AND   it-doc-fisc.nat-operacao = doc-fiscal.nat-operacao
                        AND   it-doc-fisc.cod-emitente = doc-fiscal.cod-emitente
                        AND   it-doc-fisc.serie        = doc-fiscal.serie
                        AND   it-doc-fisc.nr-doc-fis   = doc-fiscal.nr-doc-fis
                        AND   (it-doc-fisc.val-retenc-pis    <> 0 OR 
                               it-doc-fisc.val-retenc-cofins <> 0 )).
                                
    IF  l-considera-apuracao-normal
    OR  l-considera-apuracao-retido THEN DO:
        FIND FIRST tt-doc-fiscal                                           
            where  tt-doc-fiscal.estab         = doc-fiscal.cod-estabel  
            and    tt-doc-fiscal.serie         = doc-fiscal.serie        
            and    tt-doc-fiscal.nr-doc-fis    = doc-fiscal.nr-doc-fis   
            and    tt-doc-fiscal.cod-emitente  = doc-fiscal.cod-emitente 
            and    tt-doc-fiscal.nat-operacao  = doc-fiscal.nat-operacao NO-LOCK NO-ERROR.
      
        IF NOT AVAIL tt-doc-fiscal 
        THEN DO:
            CREATE tt-doc-fiscal.
            BUFFER-COPY doc-fiscal TO tt-doc-fiscal.
            ASSIGN tt-doc-fiscal.l-valor       = NO
                   tt-doc-fiscal.cfop-ini      = trim(substring(doc-fiscal.cod-cfop,1,1))
                   tt-doc-fiscal.tipo-apuracao = IF  l-considera-apuracao-normal
                                                 AND l-considera-apuracao-retido
                                                     THEN 2       /* ambos */
                                                     ELSE IF l-considera-apuracao-normal
                                                          THEN 1  /* normal */
                                                          ELSE 3. /* retido */

            
            RUN pi-tipo-nota.

        END.
    END.
    /* Documento Fiscal n∆o possui valor de PIS/COFINS */
    ELSE DO:
        FIND FIRST tt-doc-fiscal                                           
            where  tt-doc-fiscal.estab         = doc-fiscal.cod-estabel  
            and    tt-doc-fiscal.serie         = doc-fiscal.serie        
            and    tt-doc-fiscal.nr-doc-fis    = doc-fiscal.nr-doc-fis   
            and    tt-doc-fiscal.cod-emitente  = doc-fiscal.cod-emitente 
            and    tt-doc-fiscal.nat-operacao  = doc-fiscal.nat-operacao NO-LOCK NO-ERROR.
      
        IF NOT AVAIL tt-doc-fiscal 
        THEN DO:
            CREATE tt-doc-fiscal.
            BUFFER-COPY doc-fiscal TO tt-doc-fiscal.
            ASSIGN tt-doc-fiscal.cfop-ini      = trim(substring(doc-fiscal.cod-cfop,1,1))
                   tt-doc-fiscal.l-valor       = YES 
                   tt-doc-fiscal.tipo-apuracao = 1.

            RUN pi-tipo-nota.

        END. 
    END.
END. /* FOR EACH doc-fiscal */

END PROCEDURE.

PROCEDURE pi-tipo-nota:

    IF int(tt-doc-fiscal.cfop-ini) < 4 THEN 
       ASSIGN tt-doc-fiscal.tipo-nota = 1. /* Entrada */
    ELSE 
       ASSIGN tt-doc-fiscal.tipo-nota = 2. /* Sa°da */ 

    ASSIGN tt-doc-fiscal.cd-trib-pis     = trim(SUBSTR(natur-oper.char-1,86,1)) 
           tt-doc-fiscal.cd-trib-cofins  = trim(SUBSTR(natur-oper.char-1,87,1)).
                                        
    /***** Verifica documentos de entrada/serviáo  ***/

    if  tt-doc-fiscal.tipo-nota = 1 then do: /* entrada */

        if (doc-fiscal.tipo-nat <> 1 and 
            doc-fiscal.tipo-nat <> 3) 
        then 
            ASSIGN tt-doc-fiscal.tipo-nota = 0. 

        IF  doc-fiscal.tipo-nat = 3 AND 
            natur-oper.tipo    <> 1 
        THEN 
            ASSIGN tt-doc-fiscal.tipo-nota = 0.
    end.
    else do: /*** Verifica documentos de Sa°da ***/
        if  doc-fiscal.tipo-nat <> 2 and 
            doc-fiscal.tipo-nat <> 3 
        then 
            ASSIGN tt-doc-fiscal.tipo-nota = 0. 

        IF doc-fiscal.tipo-nat  = 3 
         THEN DO:
           IF natur-oper.tipo <> 2 and 
              natur-oper.tipo <> 3 
           THEN
              ASSIGN tt-doc-fiscal.tipo-nota = 0.  
        END.
    end.  


END PROCEDURE.




