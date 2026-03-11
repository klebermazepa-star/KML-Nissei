/********************************************************************************
** Programa: INT020 - Gera‡Æo notas fiscais a partir de Cupom Fiscal PRS
**
** Versao : 12 - 20/03/2016 - Alessandro V Baccin
**
********************************************************************************/
{include/i-prgvrs.i int020RP 2.00.00.039 } /*** 010039 ***/

/*
&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i int020rp MFT}
&ENDIF
*/

{include/i_fnctrad.i}

{utp/ut-glob.i}

/* Definicoes de temp-tables */
{cdp/cdcfgdis.i} /* Preprocessadores funï¿½ï¿½es distribuiï¿½ï¿½o                   */
{cdp/cd4305.i1}  /* Definicao da temp-table tt-docto e tt-it-doc            */
{cdp/cd4314.i2}  /* Definicao da temp-table tt-nota-trans                   */
{cdp/cd4401.i3}  /* Definicao da temp-table tt-saldo-estoq                  */
{cdp/cd4313.i1}  /* Def da temp-table tt-cond-pag e tt-fat-duplic           */
{ftp/ft2070.i1}  /* Definicao da temp-table tt-fat-repre                    */
{ftp/ft2073.i1}  /* Definicao das temp-tables tt-nota-embal e tt-item-embal */
{ftp/ft2010.i1}  /* Definicao da temp-table tt-notas-geradas                */
{ftp/ftapi060.i} /* Temp-Table de Erros                                     */
{cdp/cd4313.i4}  /* Temp-table unidade de negï¿½cio                           */
{ftp/ft2015.i}   /* Temp-table tt-docto-bn e tt-it-docto-bn                 */
{cdp/cd4305.i2}  /* Temp-table tt-it-nota-doc                               */
{ftp/ft2015.i2}  /* Temp-table tt-desp-nota-fisc                            */
{include/i-epc200.i ft2015rp}

/*--- Definiï¿½ï¿½o temp-table global (para nï¿½o ser necessï¿½rio alterar a definiï¿½ï¿½o da tt-fat-duplic e nem alterar passagem de parï¿½metro) Liziane FO 1547110 --*/
&IF '{&BF_DIS_VERSAO_EMS}' >= '2.04' &THEN
    IF  i-pais-impto-usuario = 1 THEN DO:
        DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-fat-duplic-boleto LIKE tt-fat-duplic
            FIELD nro-boleto AS CHAR FORMAT "x(20)".
    END.
&ENDIF
/*---*/


def temp-table tt-raw-digita
    field raw-digita  as raw.

def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".
/*
define temp-table tt-param
    field destino          as integer
    field arq-destino      as char
    field arq-entrada      as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer
    field l-importa        as logical.
*/

def temp-table tt-erros-aux no-undo
    field seq-tt-docto  as integer
    field cod-estabel   like nota-fiscal.cod-estabel
    field serie         like nota-fiscal.serie
    field nr-nota-fis   like nota-fiscal.nr-nota-fis.

form                             
    tt-erros-aux.cod-estabel
    tt-erros-aux.serie
    tt-erros-aux.nr-nota
    tt-erros.tabela      label '    '
    tt-erros.cod-erro    label '    '
    tt-erros.desc-erro   label '    ' format "x(70)"
    with width 130 frame f-erro stream-io.         

def var text-cancela     as char no-undo.

/*********** A T E N ï¿½ ï¿½ O ***********************************/ 
/* Include uso de pre-processador  para modulo BN e FT
   - Usado no assign do nr-siscomex */

   {cdp/cdcfgdis.i}
/*************************************************************/

form
    nota-fiscal.cod-estabel    
    nota-fiscal.serie     
    nota-fiscal.nr-nota-fis
    text-cancela label '          '  
    with width 80 frame f-4 stream-io.
run utp/ut-trfrrp.p (input frame f-erro:handle).
run utp/ut-trfrrp.p (input frame f-4:handle).

{utp/ut-liter.i Tabela *} 
assign tt-erros.tabela:label in frame f-erro = trim(return-value).

{utp/ut-liter.i Erro *}
assign tt-erros.cod-erro:label in frame f-erro = trim(return-value).

{utp/ut-liter.i Descri‡Æo *}
assign tt-erros.desc-erro:label in frame f-erro = trim(return-value).

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

def stream s-entrada.
def var c-linha          as character.
def var i-cont           as integer.
def var l-cabec          as logical.
def var l-num-automatica as log initial no.
def var l-erro           as log.
def var c-text-aux       as char no-undo.
def var c-cancela        as char no-undo.
def var h-acomp          as handle no-undo.

def var cont1 as int init 0 no-undo.
def var cont2 as int init 0 no-undo.
def var cont4 as int init 0 no-undo.
def var cont5 as int init 0 no-undo.
def var cont6 as int init 0 no-undo.
def var cont7 as int init 0 no-undo.
def var cont8 as int init 0 no-undo.
def var cont9 as int init 0 no-undo.

def var h-bo                   as handle  no-undo.
DEF VAR h-cdapi024             AS HANDLE  NO-UNDO.
DEF VAR c-cod-unid-negoc       AS CHAR    NO-UNDO.
def var p-de-ft-conver         as decimal no-undo.
def var p-i-num-casa-dec       as integer no-undo.
def var p-de-qtdade-convertida as decimal no-undo.
def var p-l-procedimento-ok    as logical no-undo.

/* retidos */
def var de-base-calculo    like nota-fiscal.vl-tot-nota  no-undo.
DEF VAR de-aliq-retpis     AS DEC NO-UNDO.
DEF VAR de-aliq-retcofins  AS DEC NO-UNDO.
DEF VAR de-aliq-retcsll    AS DEC NO-UNDO.
def var de-vl-pisretido    like nota-fiscal.vl-tot-nota  no-undo. 
def var de-vl-cofinsretido like nota-fiscal.vl-tot-nota  no-undo. 
def var de-vl-csslretido   like nota-fiscal.vl-tot-nota  no-undo. 
def var de-vl-csllr-a      like it-nota-fisc.vl-merc-liq no-undo.
def var de-vl-pisr-a       like it-nota-fisc.vl-merc-liq no-undo.
def var de-vl-cofr-a       like it-nota-fisc.vl-merc-liq no-undo.
def var de-vl-csllr-5      as dec                        no-undo.
def var de-vl-pisr-5       as dec                        no-undo.
def var de-vl-cofr-5       as dec                        no-undo.

DEF VAR l-spp-nfe AS LOG NO-UNDO.
ASSIGN l-spp-nfe = CAN-FIND(FIRST funcao WHERE
                                  funcao.cd-funcao = "spp-nfe":U AND 
                                  funcao.ativo).

create tt-param.
raw-transfer raw-param to tt-param.
find first param-global no-lock no-error.
find first para-fat no-lock no-error.
FIND FIRST para-dis NO-LOCK NO-ERROR.

/*{cdp/cd0019.i MFT YES} /* inicializaï¿½ï¿½o da seguranï¿½a por estabelecimento */*/


/**** Inicio ****/   
run pi-elimina-nota.

for each tt-erros:
    delete tt-erros.
end.
for each tt-erros-aux:
    delete tt-erros-aux.
end.

{utp/ut-liter.i Cancelada * R}
assign c-cancela = return-value.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp ('Processando Cupons').

{include/i-rpvar.i}

{include/i-rpcab.i &stream="str-rp"}

for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

assign c-programa       = "INT020RP"
       c-versao         = "2.12"
       c-revisao        = ".01.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Importa‡Æo de Notas Fiscais - Cupons - PRS".

view stream str-rp frame f-cabec.
view stream str-rp frame f-rodape.    

IF  AVAIL para-dis AND para-dis.log-unid-neg THEN
    RUN cdp/cdapi024.p PERSISTENT SET h-cdapi024.

{include/i-rpout.i &stream = "stream str-rp"}

        when '4' then do: /* Registro 4 */

            assign cont4 = cont4 + 1.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = cont4
                   tt-fat-duplic.seq-tt-docto      = cont1
                   tt-fat-duplic.cod-vencto        = int(substr(c-linha,2,2))
                   tt-fat-duplic.dt-venciment      = if substr(c-linha,4,1) <> ""
                                                     then date(substr(c-linha,4,8))
                                                     else ?
                   tt-fat-duplic.dt-desconto       = if substr(c-linha,12,1) <> ""
                                                     then date(substr(c-linha,12,8))
                                                     else ?
                   tt-fat-duplic.vl-desconto       = dec(substr(c-linha,20,13)) / 100
                   tt-fat-duplic.parcela           = substr(c-linha,33,2)
                   tt-fat-duplic.vl-parcela        = dec(substr(c-linha,35,13)) / 100
                   tt-fat-duplic.vl-comis          = dec(substr(c-linha,48,13)) / 100
                   tt-fat-duplic.vl-acum-dup       = dec(substr(c-linha,61,13)) / 100
                   tt-fat-duplic.cod-esp           = trim(substr(c-linha,74,2)).
            
            &IF '{&BF_DIS_VERSAO_EMS}' >= '2.04' &THEN
                IF  i-pais-impto-usuario = 1 THEN DO:
                
                    CREATE tt-fat-duplic-boleto.
                    ASSIGN tt-fat-duplic-boleto.seq-tt-fat-duplic = tt-fat-duplic.seq-tt-fat-duplic
                           tt-fat-duplic-boleto.seq-tt-docto      = tt-fat-duplic.seq-tt-docto
                           tt-fat-duplic-boleto.parcela           = tt-fat-duplic.parcela
                           tt-fat-duplic-boleto.nro-boleto        = trim(substr(c-linha,76,20)). /* Nï¿½mero do Boleto */
                END.
            &ENDIF
        end.

        when '5' then do: /* Registro 5 */

            assign cont5 = cont5 + 1.
            create tt-fat-repre.
            assign tt-fat-repre.seq-tt-docto = cont1
                   tt-fat-repre.sequencia    = cont5
                   tt-fat-repre.cod-rep      = int(substr(c-linha,2,5))
                   tt-fat-repre.nome-ab-rep  = trim(substr(c-linha,7,12))
                   tt-fat-repre.perc-comis   = dec(substr(c-linha,19,11)) / 100000000
                   tt-fat-repre.comis-emis   = int(substr(c-linha,30,3))
                   tt-fat-repre.vl-comis     = dec(substr(c-linha,33,13)) / 100
                   tt-fat-repre.vl-emis      = dec(substr(c-linha,46,13)) / 100.

        end.

        when '6' then do: /* Registro 6 */

            assign cont6 = cont6 + 1.
            create tt-nota-embal.
            assign tt-nota-embal.seq-tt-docto      = cont1
                   tt-nota-embal.seq-tt-nota-embal = cont6
                   &IF "{&mguni_version}" >= "2.071" &THEN
                   tt-nota-embal.cod-estabel       = trim(substr(c-linha,2112,5))
                   &ELSE
                   tt-nota-embal.cod-estabel       = trim(substr(c-linha,2,3)) 
                   &ENDIF
                   tt-nota-embal.serie             = &if "{&ems_dbtype}" <> "progress":U &then
                                                         trim(substr(c-linha,5,5))
                                                     &else substr(c-linha,5,5)
                                                     &endif
                   tt-nota-embal.nr-nota-fis       = if i-pais-impto-usuario = 1 
                                                     then string(DEC(substr(c-linha,11,16)), &IF '{&bf_libera_15_posicoes}' = 'yes' 
                                                                                             &THEN ">>>>>>>>9999999"
                                                                                             &ELSE ">>>9999999"
                                                                                             &ENDIF)
                                                     else trim(substr(c-linha,11,16))
                   tt-nota-embal.sigla-emb         = trim(substr(c-linha,27,3))
                   tt-nota-embal.qt-volumes        = int(substr(c-linha,30,6))
                   tt-nota-embal.desc-vol          = substr(c-linha,36,76)
                   tt-nota-embal.narrativa         = trim(substr(c-linha,112,2000)).

        end.

        when '7' then do: /* Registro 7 */

            assign cont7 = cont7 + 1.
            create tt-item-embal.
            assign tt-item-embal.seq-tt-nota-embal = cont6
                   tt-item-embal.seq-tt-item-embal = cont7
                   tt-item-embal.volume            = int(substr(c-linha,2,6))
                   tt-item-embal.nr-sequencia      = int(substr(c-linha,8,5))
                   tt-item-embal.it-codigo         = trim(substr(c-linha,13,16))
                   tt-item-embal.qt-embalada       = dec(substr(c-linha,29,11)) / 10000.

        end.

    end case.       

find first tt-docto no-error.
if avail tt-docto then
   run pi-grava-nota.

if  can-find (first tt-erros) then do:       
    {utp/ut-liter.i NOTAS_REJEITADAS MFT R}
    disp return-value                    at 25 format "x(40)" 
         fill('-',length(trim(return-value))) at 25 format "x(40)" 
         with frame f-1 width 80 stream-io.

    for each tt-erros by int(tt-erros.identifi-msg):            
        FOR FIRST tt-erros-aux where
             	  tt-erros-aux.seq-tt-docto = int(tt-erros.identifi-msg):
            disp tt-erros-aux.cod-estabel
                 tt-erros-aux.serie
                 tt-erros-aux.nr-nota-fis
                 tt-erros.tabela
                 tt-erros.cod-erro
                 tt-erros.desc-erro 
                 with down frame f-erro stream-io.    
            down with frame f-erro.
        END.
    end.               
end.

assign l-cabec = yes.
for each tt-notas-geradas:
    if  l-cabec then do:
        {utp/ut-liter.i NOTAS_IMPORTADAS MFT R}
        disp return-value                    at 25 format "x(40)" 
             fill('-',length(trim(return-value))) at 25 format "x(40)" 
             with frame f-2 width 80 stream-io.
        assign l-cabec = no.
    end.            

    for first nota-fiscal fields(cod-estabel serie nr-nota-fis ind-sit-nota)
        where rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal no-lock:
        if nota-fiscal.dt-cancela <> ? then  /* Cancelada */
           assign text-cancela = c-cancela.
        else assign text-cancela = "".

        disp nota-fiscal.cod-estabel
             nota-fiscal.serie
             nota-fiscal.nr-nota-fis
             text-cancela format "x(10)"
             with down frame f-4 stream-io.
        down with frame f-4.
    end.
end.

run pi-finalizar in h-acomp.

IF  VALID-HANDLE(h-cdapi024) THEN DO:
    RUN pi-finalizar IN h-cdapi024.
    ASSIGN h-cdapi024 = ?.
END.

{include/i-rpclo.i}

/*{cdp/cd0019.i1} /* finalizaï¿½ï¿½o da seguranï¿½a por estabelecimento */*/


RETURN "OK":U.

/*****************  Procedures Internas *******************************/

Procedure pi-grava-nota:

    def var h-api as handle.
    /***** Consistï¿½ncias da nota **********/
    run ftp/ftapi060a.p persistent set h-api.
    run pi-execucao in h-api 
                    (input table tt-docto,
                     input table tt-it-docto,
                     input table tt-nota-trans,
                     input table tt-saldo-estoq,
                     input table tt-fat-duplic,
                     input table tt-fat-repre,
                     input table tt-nota-embal,
                     input table tt-item-embal,
                     input table tt-it-docto-imp,
                     input table tt-it-imposto,
                     input table tt-desp-nota-fisc,
                     input tt-param.l-importa,                     
                     input-output table tt-erros).

    delete procedure h-api.

    for each tt-erros break by tt-erros.identifi-msg:
       find tt-docto 
            where tt-docto.seq-tt-docto = int(tt-erros.identifi-msg) no-error.
       if avail tt-docto then do:
          create tt-erros-aux.
          assign tt-erros-aux.seq-tt-docto = tt-docto.seq-tt-docto
                 tt-erros-aux.cod-estabel  = tt-docto.cod-estabel
                 tt-erros-aux.serie        = tt-docto.serie
                 tt-erros-aux.nr-nota-fis  = tt-docto.nr-nota.

          /*if tt-erros.l-erro then       */
             run pi-elimina-nota.

       end.
       else 
          if int(tt-erros.identifi-msg) = 0 then do:
             find first tt-docto no-error.
             create tt-erros-aux.
             assign tt-erros.identifi-msg     = string(tt-docto.seq-tt-docto)
                    tt-erros-aux.seq-tt-docto = tt-docto.seq-tt-docto
                    tt-erros-aux.cod-estabel  = tt-docto.cod-estabel
                    tt-erros-aux.serie        = tt-docto.serie
                    tt-erros-aux.nr-nota-fis  = tt-docto.nr-nota.
          end.
    end.
    /* Tratamento PIS/COFINS/CSLL Retidos */
    RUN pi-trataAjusteContSociais.

    /********************** Chamada EPC ******************************/                                
    if  c-nom-prog-dpc-mg97  <> "" 
    or  c-nom-prog-appc-mg97 <> ""
    or  c-nom-prog-upc-mg97  <> "" then do:
    
        for each tt-epc 
            where tt-epc.cod-event = "CREATE-NOTA-FISC-ADC":U: 
            delete tt-epc. 
        end.

        if avail tt-docto then
            if tt-docto.esp-docto <> 23 then do:
            create tt-epc.
            assign tt-epc.cod-event     = "CREATE-NOTA-FISC-ADC":U
                   tt-epc.cod-parameter = "CREATE-NOTA-FISC-ADC":U
                   tt-epc.val-parameter = "1"                             + "," +
                                          tt-docto.nr-nota                + "," +
                                          tt-it-docto.nro-comp            + "," + 
                                          tt-docto.cod-estabel            + "," + 
                                          tt-docto.serie                  + "," +
                                   string(tt-docto.cod-emitente)          + "," +
                                          tt-docto.nat-operacao           + "," +
                                   substr(tt-docto.char-1,112,1)
                                          .

            create tt-epc.
            assign tt-epc.cod-event     = "CREATE-NOTA-FISC-ADC":U
                   tt-epc.cod-parameter = "CREATE-NOTA-FISC-ADC":U
                   tt-epc.val-parameter = "2"                             + "," +
                                          tt-docto.nr-nota                + "," +
                                          tt-it-docto.nro-comp            + "," +     
                                          tt-it-docto.serie-comp          + "," +     
                                   string(tt-it-docto.seq-comp)           + "," +
                                   string(tt-it-docto.data-comp)
                                          .  
           {include/i-epc201.i "CREATE-NOTA-FISC-ADC"}
            if return-value = 'NOK' then do:
               undo,leave.
            end.
        end.
    end.

    /******************* Fim chamada EPC *****************************/
        
    find first tt-docto no-lock no-error.
    if avail tt-docto then do:

       run ftp/ft2010.p (input  l-num-automatica,
                         output l-erro,
                         input  table tt-docto,
                         input  table tt-it-docto,
                         input  table tt-it-imposto,
                         input  table tt-nota-trans,
                         input  table tt-saldo-estoq,
                         input  table tt-fat-duplic,
                         input  table tt-fat-repre,
                         input  table tt-nota-embal,
                         input  table tt-item-embal,
                         input  table tt-it-docto-imp,
                         &IF DEFINED(bf_dis_desc_bonif) &THEN
                         input  table tt-docto-bn,
                         input  table tt-it-docto-bn,
                         &ENDIF
                         &IF DEFINED(bf_dis_unid_neg) &THEN
                             input table tt-rateio-it-duplic,
                         &ENDIF
                         input-output table tt-notas-geradas
                         &IF DEFINED(bf_dis_ciap) &THEN
                             ,
                             input table tt-it-nota-doc
                         &ENDIF
                         ,
                         input table tt-desp-nota-fisc).                         

            /*----------------- UPC Atualiza Unidade de Neg¢cio ext-nota-fiscal -------------------*/
            IF  c-nom-prog-dpc-mg97  <> "" OR  
                c-nom-prog-appc-mg97 <> "" OR  
                c-nom-prog-upc-mg97  <> "" THEN DO:
                FOR EACH  tt-epc
                    WHERE tt-epc.cod-event = "FinalizaImportacao":U :
                    DELETE tt-epc.
                END.
                CREATE tt-epc.
                ASSIGN tt-epc.cod-event     = "FinalizaImportacao":U
                       tt-epc.cod-parameter = "FinalizaImportacao":U
                       tt-epc.val-parameter = tt-docto.cod-estabel            + "," +  /*Cod Estabelecimento*/
                                              tt-docto.serie                  + "," +  /*Serie*/
                                              tt-docto.nr-nota                + ",".  /*Nota Fiscal*/
                {include/i-epc201.i "FinalizaImportacao"}
                IF RETURN-VALUE = 'NOK' THEN DO:
                    UNDO,LEAVE.
                END.
            END.
            /*----------------------------------------------------------------------------*/
       run pi-elimina-nota.       
    end.
end procedure.

Procedure pi-elimina-nota:
   for each tt-docto:
       delete tt-docto.
   end.
   for each tt-it-docto:
       delete tt-it-docto.
   end.
   for each tt-it-imposto:
       delete tt-it-imposto.
   end.
   for each tt-saldo-estoq:
       delete tt-saldo-estoq.
   end.
   for each tt-nota-trans:
       delete tt-nota-trans.
   end.
   for each tt-fat-duplic:
       delete tt-fat-duplic.
   end.

   &IF '{&BF_DIS_VERSAO_EMS}' >= '2.04' &THEN
       IF  i-pais-impto-usuario = 1 THEN DO:

           for each tt-fat-duplic-boleto:
               delete tt-fat-duplic-boleto.
           end.
       END.
   &ENDIF
   
   for each tt-fat-repre:
       delete tt-fat-repre.
   end.
   for each tt-nota-embal:
       delete tt-nota-embal.
   end.
   for each tt-item-embal:
       delete tt-item-embal.
   end.

End procedure.

PROCEDURE pi-trataAjusteContSociais:
    def var de-imposto     as decimal no-undo.

    /* verifica diferenca entre valores com 5 decimais e arredondados para 2 decimais */
    assign de-vl-csllr-a = round((de-vl-csllr-5 - de-vl-csllr-a),2)
           de-vl-pisr-a  = round((de-vl-pisr-5 - de-vl-pisr-a),2)
           de-vl-cofr-a  = round((de-vl-cofr-5 - de-vl-cofr-a),2).

    /* acerta valores */
    for each tt-it-docto                                               
        where tt-it-docto.cod-estabel = tt-docto.cod-estabel           
        and   tt-it-docto.serie       = tt-docto.serie                 
        and   tt-it-docto.nr-nota     = tt-docto.nr-nota
        and   tt-it-docto.calcula
        break by tt-it-docto.vl-merc-liq descending:  /* descending para jogar diferenca nos maiores valores */

        /* acerto CSLL */
        if dec(substr(tt-it-docto.char-2,98,14)) > 0 then
            if de-vl-csllr-a > 0 then
                assign de-imposto = dec(substr(tt-it-docto.char-2,98,14))
                       de-imposto = de-imposto + 0.01
                       de-vl-csllr-a = de-vl-csllr-a - 0.01
                       OVERLAY(tt-it-docto.char-2,98,14) = STRING(de-imposto,"99999999.99999").
            else
                if de-vl-csllr-a < 0 then
                    assign de-imposto = dec(substr(tt-it-docto.char-2,98,14))
                           de-imposto = de-imposto - 0.01
                           de-vl-csllr-a = de-vl-csllr-a + 0.01
                           OVERLAY(tt-it-docto.char-2,98,14) = STRING(de-imposto,"99999999.99999").

        /* acerto PIS */
        if dec(substr(tt-it-docto.char-2,112,14)) > 0 then
            if de-vl-pisr-a > 0 then
                assign de-imposto = dec(substr(tt-it-docto.char-2,112,14))
                       de-imposto = de-imposto + 0.01
                       de-vl-pisr-a = de-vl-pisr-a - 0.01
                       OVERLAY(tt-it-docto.char-2,112,14) = STRING(de-imposto,"99999999.99999").
            else
                if de-vl-pisr-a < 0 then
                    assign de-imposto = dec(substr(tt-it-docto.char-2,112,14))
                           de-imposto = de-imposto - 0.01
                           de-vl-pisr-a = de-vl-pisr-a + 0.01
                           OVERLAY(tt-it-docto.char-2,112,14) = STRING(de-imposto,"99999999.99999").

        /* acerto COFINS */
        if dec(substr(tt-it-docto.char-2,126,14)) > 0 then
            if de-vl-cofr-a > 0 then
                assign de-imposto = dec(substr(tt-it-docto.char-2,126,14))
                       de-imposto = de-imposto + 0.01
                       de-vl-cofr-a = de-vl-cofr-a - 0.01
                       OVERLAY(tt-it-docto.char-2,126,14) = STRING(de-imposto,"99999999.99999").
            else
                if de-vl-cofr-a < 0 then
                    assign de-imposto = dec(substr(tt-it-docto.char-2,126,14))
                           de-imposto = de-imposto - 0.01
                           de-vl-cofr-a = de-vl-cofr-a + 0.01
                           OVERLAY(tt-it-docto.char-2,126,14) = STRING(de-imposto,"99999999.99999").        

    end.

    ASSIGN de-vl-csllr-a = 0 
           de-vl-pisr-a  = 0 
           de-vl-cofr-a  = 0 
           de-vl-csllr-5 = 0 
           de-vl-pisr-5  = 0 
           de-vl-cofr-5  = 0.

END PROCEDURE.
