/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i CC0305RP 2.00.02.019 } /*** 010219 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i cc0305rp MCC}
&ENDIF
{include/i_fnctrad.i}
/*****************************************************************************
**
**       PROGRAMA: CC0305
**
**       DATA....: 02/2016
**
**       OBJETIVO: Emissao de Pedido de Compras
**
**       VERSAO..: 2.00.001 - ResultPro
**
******************************************************************************/
{cdp/cdcfgmat.i}
{cdp/cdcfgdis.i}
{include/i-epc200.i cc0305rp}

/* --- Operacional Textil --- */
DEF NEW GLOBAL SHARED VAR v_log_eai_habilit AS LOG NO-UNDO.
DEF VAR c-business-to-business AS CHAR NO-UNDO.
def var l-erro as logical no-undo.
def temp-table tt-b2b no-undo
    field nr-pedido          like ordem-compra.num-pedido
    field cod-emitente       like pedido-compr.cod-emitente
    field nome-abrev         like emitente.nome-abrev
    field numero-ordem       like ordem-compra.numero-ordem
    field it-codigo          like ordem-compra.it-codigo
    index pedido-emitente is primary 
          nr-pedido
          cod-emitente.

define temp-table tt-param no-undo
    field destino           as integer
    field arquivo           as char
    field diretorio         as char
    field usuario           as char
    field data-exec         as date
    field hora-exec         as integer
    field i-pedi-i          as integer
    field i-pedi-f          as integer
    field l-narrativa-item  as logical
    field l-narrativa-ordem as logical
    field l-bus-to-bus      as logical
    field l-descricao       as logical
    field l-impressao       as logical
    field i-param-c         as integer
    field i-ordem-ini       like ordem-compra.numero-ordem
    field i-ordem-fim       like ordem-compra.numero-ordem
    field l-envia           as logical
    field c-destino         as char  
    field l-eprocurement    as LOGICAL
    FIELD l-integra-portal  AS LOGICAL
    FIELD l-ped-compra      AS LOG
    FIELD l-gera-arq-local  AS LOG
    FIELD c-arq-ped-compra  AS CHAR.

/* temp-table para envio dos paramentros para o multiplanta */
define temp-table tt-param-mp no-undo
    field i-ordem-ini       like ordem-compra.numero-ordem
    field i-ordem-fim       like ordem-compra.numero-ordem
    field sit-ordem-contrat like ordem-compra.sit-ordem-contrat.

define temp-table tt_log_erro no-undo
     field ttv_num_cod_erro  as integer   initial ?
     field ttv_des_msg_ajuda as character initial ?
     field ttv_des_msg_erro  as character initial ?.

define temp-table tt_log_erro_aux no-undo like tt_log_erro
       field ttv_tipo as integer initial ?.

def temp-table tt-raw-digita no-undo
    field raw-digita as raw.

DEF TEMP-TABLE tt-pedido 
FIELD num-pedido   LIKE pedido-compr.num-pedido
FIELD cod-emitente LIKE pedido-compr.cod-emitente
FIELD natureza      AS CHAR
FIELD desc-frete    AS CHAR
FIELD desc-cond-pag AS CHAR EXTENT 2
FIELD cnpj-estab    LIKE estabelec.cgc
FIELD cnpj-emit     LIKE emitente.cgc
FIELD desc-contrato AS CHAR
FIELD tipo-compra   AS CHAR
FIELD nome-ass      AS CHAR EXTENT 2
FIELD cargo-ass     AS CHAR EXTENT 2
FIELD incoterm      AS CHAR
FIELD arquivo       AS CHAR
FIELD comprador     AS CHAR
FIELD contato       LIKE cotacao-item.contato
FIELD observacao    LIKE pedido-compr.comentarios
field vlr-frete     LIKE cotacao-item.valor-descto
INDEX ind-pedido 
      num-pedido    ASCENDING. 
     
DEF TEMP-TABLE tt-it-pedido
FIELD num-pedido   LIKE pedido-compr.num-pedido
FIELD cod-ean      LIKE ITEM.it-codigo
FIELD it-codigo    LIKE ordem-compra.it-codigo
FIELD descricao    LIKE item.desc-item     
field un           LIKE prazo-compra.un
field qtd-forn     LIKE prazo-compra.qtd-sal-forn
field preco-un     LIKE cotacao-item.valor-descto
field vlr-liquido  LIKE cotacao-item.valor-descto
field aliquota-ipi LIKE ordem-compra.aliquota-ipi
field vlr-ipi      LIKE cotacao-item.valor-descto
field vlr-st       LIKE cotacao-item.valor-descto
field vlr-total    LIKE cotacao-item.valor-descto
field data-entrega LIKE prazo-compra.data-entrega. 
                                                 
DEFINE TEMP-TABLE tt-cond-pagto NO-UNDO 
FIELD num-pedido              AS   INTEGER 
FIELD descricao               AS   CHARACTER 
INDEX ind-condped
      num-pedido              ASCENDING 
      descricao               ASCENDING. 
                          
{include/tt-edit.i}

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

/* {ccp/ccapi201.i}
{ccp/ccapi202.i}
{ccp/ccapi203.i}
{ccp/ccapi204.i}
{ccp/ccapi205.i}
{ccp/ccapi206.i}
{ccp/ccapi207.i}
*/

{cdp/cd0666.i}

DEF VAR l-envio-ped AS LOGICAL INITIAL NO NO-UNDO.
DEF VAR i-condicao  AS INTEGER            NO-UNDO.
DEF VAR c-diretorio AS CHAR               NO-UNDO.

/*Variaveis para o bloqueio do fornecedor na 2.05*/
&IF defined(bf_mat_bloqueio_fornec) &THEN
    DEFINE VARIABLE h-api029 AS HANDLE       NO-UNDO.
    DEFINE VARIABLE i-situacao AS INTEGER    NO-UNDO.
    DEFINE VARIABLE dt-vig-ini AS DATE       NO-UNDO.
    DEFINE VARIABLE dt-vig-fim AS DATE       NO-UNDO.

    def temp-table tt-erro-2 no-undo
        field i-sequen as int             
        field cd-erro  as int
        field mensagem as char format "x(255)"
        field c-param  as char.

&ENDIF

DEFINE VARIABLE h-ccapi036 AS HANDLE NO-UNDO.

def buffer b-ped for pedido-compr.
def buffer b-ord for ordem-compra.

/* {utp/ut-glob.i} */

/************* Multi-Planta ***************/
def var i-tipo-movto        as integer no-undo.
def var l-cria              as logical no-undo.
def var c-cgc               as char format "x(18)".
def var c-cgc-emit          as char format "x(19)".
def var l-primeiro-emitente as logical no-undo initial no.
def var l-ultimo-emitente   as logical no-undo initial no.
def var l-ultimo-cod-emit   as logical no-undo initial no.
DEF VAR c-comprador         AS CHAR FORMAT "x(20)".

{cdp/cd7300.i1}
{cdp/cd7300.i2}
/* {mpp/mpapi011.i} */
/**************** Fim *********************/

create tt-param.
raw-transfer raw-param to tt-param.

{include/i-rpvar.i}
{ccp/cc0305.i2}
{ccp/cc0305.i6}


{utp/ut-liter.i Sim/NÆo}
ASSIGN c-format = TRIM(RETURN-VALUE).
{utp/ut-liter.i Erro * r}
assign c-lb-erro = return-value.
{utp/ut-liter.i Ajuda * r}
assign c-lb-ajuda = return-value.
{utp/ut-liter.i Erros_ocorridos_durante_o_envio_da_mensagem * r}
assign c-erro-eai = return-value.

find first param-compra no-lock no-error.
find first param-global no-lock no-error.

assign c-empresa  = (if avail param-global then param-global.grupo else "")
       l-branco   = no.

{utp/ut-liter.i COMPRAS * r}
assign c-sistema = trim(return-value).
{utp/ut-liter.i EmissÆo_de_Pedido_de_Compras * r}
assign c-titulo-relat = trim(return-value).

{include~/i-rpcab.i}
{include~/i-rpout.i}

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i "EmissÆo_de_Pedidos" *}


EMPTY TEMP-TABLE tt-erro.

for each b-ped NO-LOCK where 
         b-ped.num-pedido >= tt-param.i-pedi-i and  
         b-ped.num-pedido <= tt-param.i-pedi-f
    break by b-ped.cod-emitente:
     
    run pi-inicializar in h-acomp (input return-value).

    &IF defined(bf_mat_bloqueio_fornec) &THEN
        run cdp/cdapi029.p (input b-ped.responsavel,
                            input 1,
                            input b-ped.data-pedido,
                            input b-ped.cod-emitente,
                            output i-situacao,
                            output dt-vig-ini,
                            output dt-vig-fim,
                            output table tt-erro-2).
        
        FOR EACH  tt-erro-2:
                   
            CREATE tt-erro.
            BUFFER-COPY tt-erro-2 TO tt-erro.
            ASSIGN tt-erro.mensagem = tt-erro.mensagem + "Pedido: " + STRING(b-ped.num-pedido).

        END.

        EMPTY TEMP-TABLE tt-erro-2.
              
        /*--- NÆo imprime pedido quando a api retornar "NOK" ---*/
        if return-value = "NOK":U THEN 
        next.
       
           
    &ENDIF

    assign l-first-emitente = first-of (b-ped.cod-emitente).
    
    /* if not (b-ped.impr-pedido  or
            &if defined(bf_mat_contratos) &then
                b-ped.nr-contrato <> 0)
            &else
                b-ped.nr-contrato <> "")
            &endif 
    then do:
                
        CREATE tt-erro.
        ASSIGN tt-erro.cd-erro  = 9001
               tt-erro.mensagem = "Pedido: " + STRING(b-ped.num-pedido) + " est  parametrizado para nÆo imprimir pedido ou contrato do pedido nÆo relacionado".
        
        NEXT.
        
    END. */

    find pedido-compr where rowid(pedido-compr) = rowid(b-ped) no-lock no-error no-wait.
    if  locked pedido-compr then DO: 

        CREATE tt-erro.
        ASSIGN tt-erro.cd-erro  = 9002
               tt-erro.mensagem = "Pedido: " + STRING(b-ped.num-pedido) + " est  sendo atualizado por outro usu rio. Tente imprimir novamente".

        next.
    END.

    find emitente where emitente.cod-emitente = pedido-compr.cod-emitente no-lock no-error.
    &if '{&BF_DIS_VERSAO_EMS}' >= '2.05' &then
        find dist-emitente where dist-emitente.cod-emitente = pedido-compr.cod-emitente no-lock no-error.
    &endif
       

        /**
        ***   Aprova‡Æo Eletr“nica
        **/
        assign l-pendente  = NO
               l-envio-ped = NO.

        if param-compra.log-1 then do:
            for each  b-ord
                where b-ord.num-pedido = pedido-compr.num-pedido no-lock:
                if  pedido-compr.emergencial then
                    run cdp/cdapi172 (6, rowid(b-ord), output l-pendente).
                else
                    run cdp/cdapi172 (4, rowid(b-ord), output l-pendente).

                if  l-pendente then
                    if  tt-param.l-bus-to-bus   = yes
                    or  tt-param.l-eprocurement = yes then do:
                           
                        ASSIGN l-envio-ped = YES.
                        
                        CREATE tt-erro.
                        ASSIGN tt-erro.cd-erro  = 9003
                               tt-erro.mensagem = "Pedido: " + STRING(b-ped.num-pedido) + " nÆo enviado por estar pendente de Aprova‡Æo Eletr“nica!".
                                           
                        leave.
                    end.
                    else
                        leave.
            end.
        end.

        if  l-pendente then do:
            
            IF l-envio-ped = NO THEN DO:

               CREATE tt-erro.
               ASSIGN tt-erro.cd-erro  = 9004
                      tt-erro.mensagem = "Pedido: " + STRING(b-ped.num-pedido) + " est  com a situa‡Æo pendente de aprova‡Æo.".

            END.

            next.
        END.
        
        /* Vari veis alimentadas para serem utilizadas nas integra‡äes B2B */
        if  first-of(b-ped.cod-emitente) then
            assign l-primeiro-emitente = yes.
        else
            assign l-primeiro-emitente = no.

        if  last-of(b-ped.cod-emitente) then
            assign l-ultimo-emitente = yes.
        else
            assign l-ultimo-emitente = no.

        if  last(b-ped.cod-emitente) then
            assign l-ultimo-cod-emit = yes.
        else
            assign l-ultimo-cod-emit = no.

        run pi-acompanhar in h-acomp (input string(pedido-compr.num-pedido)).
        
        run pi-integracoes.         

        ASSIGN c-diretorio = SESSION:TEMP-DIRECTORY.
                                                   
        CREATE tt-pedido.
        ASSIGN tt-pedido.num-pedido   = pedido-compr.num-pedido
               tt-pedido.cod-emitente = pedido-compr.cod-emitente
               tt-pedido.incoterm     = IF   pedido-compr.frete = 1  
                                      THEN 'CIF'
                                      ELSE 'FOB'
               tt-pedido.arquivo     = TRIM (c-diretorio)                                       + 
                                       'PEDIDO-'                                               + 
                                       TRIM (CAPS (emitente.nome-abrev))                       + 
                                       '-'                                                     + 
                                       TRIM (STRING (pedido-compr.num-pedido, '>>>>>>>>>>>9')) + 
                                       '-'                                                     + 
                                       STRING (DAY   (TODAY), '99')                            + 
                                       STRING (MONTH (TODAY), '99')                            +
                                       STRING (YEAR  (TODAY), '9999')                          + 
                                       SUBSTRING (STRING (TIME, 'HH:MM:SS'), 01, 02)           + 
                                       SUBSTRING (STRING (TIME, 'HH:MM:SS'), 04, 02)           + 
                                       SUBSTRING (STRING (TIME, 'HH:MM:SS'), 07, 02)           + 
                                       '.PDF'
               tt-pedido.observacao    = pedido-compr.comentarios.

        assign c-pe-aux        = pedido-compr.num-pedido
               de-tot-ger      = 0
               de-total        = 0
               de-total-pedido = 0
               c-desc-var-1    = ""
               c-desc-var-2    = "".

        &if "{&FNC_MULTI_IDIOMA}" = "Yes" &then
            DEFINE VARIABLE cAuxTraducao001 AS CHARACTER NO-UNDO.
            ASSIGN cAuxTraducao001 = {ininc/i01in274.i 04 pedido-compr.natureza}.
            run utp/ut-liter.p (INPUT REPLACE(TRIM(cAuxTraducao001)," ","_"),
                                INPUT "",
                                INPUT "").
            ASSIGN c-natureza   = RETURN-VALUE.
        &else
            ASSIGN c-natureza   = {ininc/i01in274.i 04 pedido-compr.natureza}.
        &endif
        
        ASSIGN tt-pedido.natureza = c-natureza.
        
        &if "{&FNC_MULTI_IDIOMA}" = "Yes" &then
            DEFINE VARIABLE cAuxTraducao002 AS CHARACTER NO-UNDO.
            ASSIGN cAuxTraducao002 = {ininc/i01in274.i 04 pedido-compr.frete}.
            run utp/ut-liter.p (INPUT REPLACE(TRIM(cAuxTraducao002)," ","_"),
                                INPUT "",
                                INPUT "").
            ASSIGN c-desc-frete   = RETURN-VALUE.
        &else
            ASSIGN c-desc-frete   = {ininc/i01in274.i 04 pedido-compr.frete}.
        &endif
        
        ASSIGN tt-pedido.desc-frete = c-desc-frete.

        find transporte where transporte.cod-transp   = pedido-compr.cod-transp   no-lock no-error.
        find cond-pagto where cond-pagto.cod-cond-pag = pedido-compr.cod-cond-pag no-lock no-error.

        if  avail cond-pagto then do:
            if  cond-pagto.cod-cond-pag = 0 then do:
                {utp/ut-liter.i Espec­fica * r}
                assign c-desc-var-1 = trim(return-value)
                       c-desc-var-2 = "".
            end.
            if  cond-pagto.cod-vencto = 1 then
                assign c-desc-var-1 = string(prazos[1]) + " "
                                    + string(prazos[2]) + " "
                                    + string(prazos[3])
                       c-desc-var-2 = string(prazos[4]) + " "
                                    + string(prazos[5]) + " "
                                    + string(prazos[6]) + " DD".
            if  cond-pagto.cod-vencto = 2 then do:
                {utp/ut-liter.i A_Vista * r}
                assign c-desc-var-1 = trim(return-value)
                       c-desc-var-2 = "".
            end.
            if  cond-pagto.cod-vencto = 3 then do:
                {utp/ut-liter.i Antecipado * r}
                assign c-desc-var-1 = trim(return-value)
                       c-desc-var-2 = "".
            end.
            if  cond-pagto.cod-vencto = 4 then do:
                {utp/ut-liter.i Contra_Entrega * r}
                assign c-desc-var-1 = trim(return-value)
                       c-desc-var-2 = "".
            end.
            if  cond-pagto.cod-vencto = 5 then
                assign c-desc-var-1 = string(prazos[1]) + " "
                                    + string(prazos[2]) + " "
                                    + string(prazos[3])
                       c-desc-var-2 = string(prazos[4]) + " "
                                    + string(prazos[5]) + " "
                                    + string(prazos[6]) + " FD".
            if  cond-pagto.cod-vencto = 6 then
                assign c-desc-var-1 = string(prazos[1]) + " "
                                    + string(prazos[2]) + " "
                                    + string(prazos[3])
                       c-desc-var-2 = string(prazos[4]) + " "
                                    + string(prazos[5]) + " "
                                    + string(prazos[6]) + " FQ".
            if  cond-pagto.cod-vencto = 7 then
                assign c-desc-var-1 = string(prazos[1]) + " "
                                    + string(prazos[2]) + " "
                                    + string(prazos[3])
                       c-desc-var-2 = string(prazos[4]) + " "
                                    + string(prazos[5]) + " "
                                    + string(prazos[6]) + " FM".
            if  cond-pagto.cod-vencto = 8 then
                assign c-desc-var-1 = string(prazos[1]) + " "
                                    + string(prazos[2]) + " "
                                    + string(prazos[3])
                       c-desc-var-2 = string(prazos[4]) + " "
                                    + string(prazos[5]) + " "
                                    + string(prazos[6]) + " FS".
            if  cond-pagto.cod-vencto = 9 then do:
                {utp/ut-liter.i Apresenta‡Æo * r}
                assign c-desc-var-2 = string(prazos[4]) + " "
                                    + string(prazos[5]) + " "
                                    + string(prazos[6]) + trim(return-value)
                       c-desc-var-1 = string(prazos[1]) + " "
                                    + string(prazos[2]) + " "
                                    + string(prazos[3]).
            end.
        end.

        ASSIGN tt-pedido.desc-cond-pag[1] = c-desc-var-1
               tt-pedido.desc-cond-pag[2] = c-desc-var-2.    

        find emitente  where emitente.cod-emitente = pedido-compr.cod-emitente no-lock no-error.
        find estabelec where estabelec.cod-estabel = pedido-compr.end-entrega  no-lock no-error.
        
        IF AVAIL emitente
            AND AVAIL estabelec THEN
            assign c-cgc      = if param-global.formato-id-federal <> "" 
                                    then string(estabelec.cgc, param-global.formato-id-federal)
                                else estabelec.cgc
                   c-cgc-emit = if param-global.formato-id-federal <> ""
                                    then string(emitente.cgc,param-global.formato-id-federal)
                                else emitente.cgc.

        ASSIGN tt-pedido.cnpj-estab = c-cgc
               tt-pedido.cnpj-emit  = c-cgc-emit.  
         
        IF pedido-compr.cod-cond-pag <> 00 
        THEN DO:
    
            FOR FIRST cond-pagto 
                WHERE cond-pagto.cod-cond-pag = pedido-compr.cod-cond-pag
                NO-LOCK:
            END.
    
            CREATE tt-cond-pagto. 
            ASSIGN tt-cond-pagto.num-pedido = pedido-compr.num-pedido 
                   tt-cond-pagto.descricao  = IF   AVAILABLE cond-pagto 
                                              THEN cond-pagto.descricao 
                                              ELSE 'N’o Cadastradas'. 
    
        END.
        ELSE DO: 
    
            FOR FIRST cond-especif NO-LOCK WHERE 
                      cond-especif.num-pedido = pedido-compr.num-pedido: 
            END.
    
            IF  NOT AVAILABLE cond-especif 
            THEN DO:
    
                CREATE tt-cond-pagto. 
                ASSIGN tt-cond-pagto.num-pedido = pedido-compr.num-pedido 
                       tt-cond-pagto.descricao  = 'N’o Cadastradas'. 
    
            END.
            ELSE DO:
    
                DO  i-condicao = 01 TO 12: 
        
                    IF  cond-especif.data-pagto [i-condicao] <> ? THEN DO:
    
                        CREATE tt-cond-pagto. 
                        ASSIGN tt-cond-pagto.num-pedido = pedido-compr.num-pedido 
                               tt-cond-pagto.descricao  = STRING (cond-especif.data-pagto [i-condicao], '99/99/9999')    + 
                                                          ' - '                                                          + 
                                                          TRIM (STRING (cond-especif.perc-pagto [i-condicao], '>>9.99')) + 
                                                          '%'. 
    
                    END.
        
                END.
    
            END.
    
        END.
        
        assign c-comprador = "".
        find first comprador where 
                   comprador.cod-comprado = pedido-compr.responsavel no-lock no-error.
        if available comprador then 
           assign c-comprador = comprador.nome.
        if c-comprador = "" then 
           assign c-comprador = pedido-compr.responsavel.

        ASSIGN tt-pedido.comprador = c-comprador.

        ASSIGN l-ordem    = no
               l-imprimiu = no.

        for each ordem-compra
            where ordem-compra.num-pedido = pedido-compr.num-pedido
            and   ordem-compra.situacao  <> 4
            and   ordem-compra.situacao  <> 6 no-lock:

            /* Integra‡Æo M¢dulo de Contratos */

            &if defined(bf_mat_contratos) &then
            if param-global.modulo-cn and ordem-compra.nr-contrato <> 0 then do:
            &else
            if param-global.modulo-cn and ordem-compra.nr-contrato <> "" then do:
            &endif
            
                if  ordem-compra.numero-ordem < tt-param.i-ordem-ini
                or  ordem-compra.numero-ordem > tt-param.i-ordem-fim then next.
            
                find contrato-for 
                    where contrato-for.nr-contrato = ordem-compra.nr-contrato exclusive-lock no-error.
               
                if  avail contrato-for then do:
                    assign c-desc-contrato              = contrato-for.des-contrat.       
               
                    if  tt-param.i-param-c = 1
                    and ordem-compra.sit-ordem-contrat <> 2 then next.
                    else
                        if  tt-param.i-param-c = 2
                        and ordem-compra.sit-ordem-contrat <> 1 then next.
                        else      
                            if  tt-param.i-param-c = 3
                            and ordem-compra.sit-ordem-contrat = 3 then next.           
                END.
            END.

            ASSIGN tt-pedido.desc-contrato = c-desc-contrato
                   tt-pedido.vlr-frete     = tt-pedido.vlr-frete + ordem-compra.valor-frete. 
            
            /* Fim Integra‡Æo Contratos */
            find first cotacao-item
                 where cotacao-item.numero-ordem = ordem-compra.numero-ordem
                 and   cotacao-item.cod-emitente = ordem-compra.cod-emitente
                 and   cotacao-item.cot-aprovada no-lock no-error.
            IF AVAIL cotacao-item THEN
               ASSIGN tt-pedido.contato = cotacao-item.contato.
                              
            find item-fornec
                 where item-fornec.it-codigo    = ordem-compra.it-codigo
                 and   item-fornec.cod-emitente = pedido-compr.cod-emitente
                 no-lock no-error.

            find item      where item.it-codigo      = ordem-compra.it-codigo no-lock no-error.
            find narrativa where narrativa.it-codigo = ordem-compra.it-codigo no-lock no-error.
           
            if  ordem-compra.mo-codigo > 0 then do:
                run cdp/cd0812.p (input  ordem-compra.mo-codigo,
                                  input  0,
                                  input  ordem-compra.preco-fornec,
                                  input  pedido-compr.data-pedido,
                                  output de-preco-conv).
                if  de-preco-conv = ? then
                    assign de-preco-conv = ordem-compra.preco-fornec.
            end.
            else
                assign de-preco-conv = ordem-compra.preco-fornec.

            assign de-preco-unit = de-preco-conv
                   de-ipi-tot    = 0.

            for each  prazo-compra
                where prazo-compra.numero-ordem  = ordem-compra.numero-ordem
                and   prazo-compra.situacao     <> 4
                and   prazo-compra.situacao     <> 6 no-lock:
                assign de-preco-tot-aux = de-preco-conv * prazo-compra.qtd-sal-forn
                       de-preco-calc    = 0
                       de-desc          = 0
                       de-enc           = 0
                       de-ipi           = 0.

                if  param-compra.ipi-sobre-preco = 2 then do:
                    if  ordem-compra.perc-descto > 0 then
                        assign de-desc = round(de-preco-tot-aux
                                       * ordem-compra.perc-descto / 100,2).
                    if  ordem-compra.taxa-financ = no then do:
                        assign de-enc = de-preco-tot-aux - de-desc.
                        run ccp/cc9020.p (input  yes,
                                          input  ordem-compra.cod-cond-pag,
                                          input  ordem-compra.valor-taxa,
                                          input  ordem-compra.nr-dias-taxa,
                                          input  de-enc,
                                          output de-preco-calc).
                        assign de-enc = round(de-preco-calc - de-enc,2).
                    end.
                    else
                        assign de-preco-calc = de-preco-tot-aux - de-desc.

                    if  ordem-compra.aliquota-ipi > 0
                    and ordem-compra.codigo-ipi   = no then
                        assign de-ipi     = de-preco-calc
                                          * ordem-compra.aliquota-ipi / 100
                               de-ipi-tot = de-ipi-tot + de-ipi.
                end.
                else do:
                    if  ordem-compra.taxa-financ = no then do:
                        run ccp/cc9020.p (input  yes,
                                          input  ordem-compra.cod-cond-pag,
                                          input  ordem-compra.valor-taxa,
                                          input  ordem-compra.nr-dias-taxa,
                                          input  de-preco-tot-aux,
                                          output de-preco-calc).
                        assign de-enc = round(de-preco-calc - de-preco-tot-aux,2).
                    end.
                    else
                        assign de-preco-calc = de-preco-tot-aux.

                    if  ordem-compra.aliquota-ipi > 0
                    and ordem-compra.codigo-ipi   = no then
                        assign de-ipi = de-preco-calc
                                      * ordem-compra.aliquota-ipi / 100
                               de-ipi-tot = de-ipi-tot + de-ipi.
                    if  ordem-compra.perc-descto > 0 then
                        assign de-desc = round((de-preco-calc + de-ipi)
                                       * ordem-compra.perc-descto / 100,2).
                end.
                assign de-preco-total  = de-preco-tot-aux + de-enc + de-ipi - de-desc
                       de-total-pedido = de-total-pedido  + de-preco-total.
            end.

            for each  prazo-compra
                where prazo-compra.numero-ordem =  ordem-compra.numero-ordem
                and   prazo-compra.situacao    <> 4
                and   prazo-compra.situacao    <> 6 no-lock:

                if  ordem-compra.taxa-financ  then
                    assign c-tax-aux = "%"
                           de-enc    = 0.
                else
                    assign c-tax-aux = "%".

                assign de-preco-tot-aux = de-preco-conv * prazo-compra.qtd-sal-forn
                       de-preco-calc    = 0
                       de-desc          = 0
                       de-enc           = 0
                       de-ipi           = 0.
                if  param-compra.ipi-sobre-preco = 2 then do:
                    if  ordem-compra.perc-descto > 0 then
                        assign de-desc = round(de-preco-tot-aux
                                       * ordem-compra.perc-descto / 100,2).
                    if  ordem-compra.taxa-financ = no then do:
                        assign de-enc = de-preco-tot-aux - de-desc.
                        run ccp/cc9020.p (input  yes,
                                          input  ordem-compra.cod-cond-pag,
                                          input  ordem-compra.valor-taxa,
                                          input  ordem-compra.nr-dias-taxa,
                                          input  de-enc,
                                          output de-preco-calc).
                        assign de-enc = round(de-preco-calc - de-enc,2).
                    end.
                    else
                        assign de-preco-calc = de-preco-tot-aux - de-desc.

                    if  ordem-compra.aliquota-ipi > 0
                    and ordem-compra.codigo-ipi = no then
                        assign de-ipi = de-preco-calc
                                      * ordem-compra.aliquota-ipi / 100.
                end.
                else do:
                    if  ordem-compra.taxa-financ = no then do:
                        run ccp/cc9020.p (input  yes,
                                          input  ordem-compra.cod-cond-pag,
                                          input  ordem-compra.valor-taxa,
                                          input  ordem-compra.nr-dias-taxa,
                                          input  de-preco-tot-aux,
                                          output de-preco-calc).
                        assign de-enc = round(de-preco-calc
                                      - de-preco-tot-aux,2).
                    end.
                    else
                        assign de-preco-calc = de-preco-tot-aux.

                    if  ordem-compra.aliquota-ipi > 0
                    and ordem-compra.codigo-ipi = no then
                        assign de-ipi = de-preco-calc
                                      * ordem-compra.aliquota-ipi / 100.
                    if  ordem-compra.perc-descto > 0 then
                        assign de-desc = round((de-preco-calc + de-ipi)
                                       * ordem-compra.perc-descto / 100,2).
                end.

                {utp/ut-liter.i Continua * r}
                assign c-msg = trim(return-value)
                       de-preco-total = de-preco-tot-aux + de-enc + de-ipi - de-desc.
                       de-tot-ger = de-tot-ger + de-preco-total.

                CREATE tt-it-pedido.
                ASSIGN tt-it-pedido.num-pedido   = pedido-compr.num-pedido
                       tt-it-pedido.it-codigo    = ordem-compra.it-codigo
                       tt-it-pedido.un           = prazo-compra.un
                       tt-it-pedido.qtd-forn     = prazo-compra.qtd-sal-forn
                       tt-it-pedido.preco-un     = de-preco-unit
                       tt-it-pedido.vlr-liquido  = tt-it-pedido.qtd-forn * tt-it-pedido.preco-un
                       tt-it-pedido.aliquota-ipi = ordem-compra.aliquota-ipi
                       tt-it-pedido.vlr-ipi      = de-ipi
                       tt-it-pedido.vlr-st       = 0
                       tt-it-pedido.vlr-total    = de-preco-total 
                       tt-it-pedido.data-entrega = prazo-compra.data-entrega.
                 
                IF AVAIL ITEM THEN        
                   ASSIGN tt-it-pedido.descricao = item.desc-item.  

            end.

            assign c-pe-aux = pedido-compr.num-pedido
                   l-ordem  = no.
            
            run ccp/cc0305b.p (input rowid(ordem-compra)). /* atualiza ordem */                

            if  avail contrato-for
            and ordem-compra.nr-contrato = contrato-for.nr-contrato
            and ordem-compra.sit-ordem-contrat = 1 then 
                assign ordem-compra.sit-ordem-contrat = 2.

        end. /* Ordem-compra */ 
        
        find mensagem where 
             mensagem.cod-mensagem = pedido-compr.cod-mensagem   no-lock no-error.
        
        &if "{&FNC_MULTI_IDIOMA}" = "Yes" &then
             DEFINE VARIABLE cAuxTraducao003 AS CHARACTER NO-UNDO.
             ASSIGN cAuxTraducao003 = {ininc/i01in274.i 04 cotacao-item.codigo-icm}.
             run utp/ut-liter.p (INPUT REPLACE(TRIM(cAuxTraducao003)," ","_"),
                                 INPUT "",
                                 INPUT "").
             ASSIGN c-desc-destino   = RETURN-VALUE.
        &else
            ASSIGN c-desc-destino   = {ininc/i01in274.i 04 cotacao-item.codigo-icm}.
        &endif
             
        ASSIGN tt-pedido.tipo-compra = c-desc-destino.
               
        assign l-r2 = (de-total-pedido > param-compra.limite[1]).
               l-r3 = (de-total-pedido > param-compra.limite[2]).
            
        assign c-nome[1]  = ""
               c-nome[2]  = ""
               c-nome[3]  = ""
               c-cargo[1] = ""
               c-cargo[2] = ""
               c-cargo[3] = "".
                                    
        RUN utp/ut-liter.p(INPUT REPLACE(param-compra.cargo-ass[2]," ","_"),"","").

        if  l-r2 = yes then
            assign c-nome[2]  = (fill(" ", integer((30
                              - length(param-compra.nome-ass[2])) /  2))
                              + param-compra.nome-ass[2])
                   c-cargo[2] = (fill(" ", integer((30
                              - length(RETURN-VALUE)) / 2))
                              + RETURN-VALUE).
        RUN utp/ut-liter.p(INPUT REPLACE(param-compra.cargo-ass[3]," ","_"),"","").
        if  l-r3 = yes then
            assign c-nome[3]  = (fill(" ", integer((30
                              - length(param-compra.nome-ass[3])) /  2))
                              + param-compra.nome-ass[3])
                   c-cargo[3] = (fill(" ", integer((30
                              - length(RETURN-VALUE)) / 2))
                              + RETURN-VALUE).
        
        RUN utp/ut-liter.p(INPUT REPLACE(param-compra.cargo-ass[1]," ","_"),"","").
        assign c-nome[1]  = (fill(" ", integer((30
                          - length(param-compra.nome-ass[1])) / 2))
                          + param-compra.nome-ass[1])
               c-cargo[1] = (fill(" ", integer((30
                          - length(RETURN-VALUE)) / 2))
                          + RETURN-VALUE ).
                               
        ASSIGN tt-pedido.nome-ass[1]  = c-nome[1]
               tt-pedido.nome-ass[2]  = c-nome[2]       
               tt-pedido.cargo-ass[1] = c-cargo[1]
               tt-pedido.cargo-ass[2] = c-cargo[2].
              
        assign c-msg        = ""
               de-total     = de-total-pedido
               i-tipo-movto = 0.
        
        if not can-find(first tt_log_erro_aux where tt_log_erro_aux.ttv_tipo = 2) then
           run ccp/cc0305a.p (rowid(pedido-compr)).
            
     
     RUN PI-Acompanhar IN h-acomp (INPUT 'Pedido: ' + TRIM (STRING (pedido-compr.num-pedido, '>>>,>>>,>>9')) + ' - Gerando PDF...'). 
      
     RUN ccp/cc0305rpa.p (INPUT  TABLE tt-pedido, 
                          INPUT  TABLE tt-cond-pagto, 
                          INPUT  TABLE tt-it-pedido).
end.



    /* &if "{&bf_mat_versao_ems}":U >= "2.062":U  &then
        if v_log_eai_habilit then do:
            page.
            run pi-imprime-erros(input 1).
            run pi-imprime-erros(input 2).
        end.
    &else 
      if then do:
         page. 
         run pi-imprime-erros(input 2).   
      end.   
    &endif */

    IF VALID-HANDLE(h-acomp) THEN
     run pi-finalizar in h-acomp.

    /* if valid-handle(h-ccapi036) then do:
       run disconnecTss in h-ccapi036. 
       delete procedure h-ccapi036.
       assign h-ccapi036 = ?.
    end. */


    {include~/i-rpclo.i}
    {include/pi-edit.i}
    /* {cdp/cdcolab01.i} */

    IF CAN-FIND(FIRST tt-erro) THEN DO:

       RUN cdp/cd0666.w(INPUT TABLE tt-erro).

    END.


PROCEDURE pi-imprime-erros:

    define input parameter piEaiColab as integer no-undo.  
    
    if can-find (first tt_log_erro_aux) then do:            
        if piEaiColab = 1 then put c-erro-eai format "x(130)".   
        else if piEaiColab = 2 then put c-erro-totvs-colab format "x(130)". 
        put skip.
        put "-----------------------------------------------------------------".
    end.

    for each tt_log_erro_aux 
       where tt_log_erro_aux.ttv_tipo = piEaiColab no-lock:
        if tt_log_erro_aux.ttv_des_msg_erro <> "" and tt_log_erro_aux.ttv_des_msg_erro <> ? then do:
            empty temp-table tt-editor.
            run pi-print-editor (input tt_log_erro_aux.ttv_des_msg_erro, input 60).
    
            assign l-primeira = yes.
            for each tt-editor no-lock:
                if l-primeira then 
                    put c-lb-erro + ": " + STRING(tt_log_erro_aux.ttv_num_cod_erro) + " - "  + tt-editor.conteudo at 1 format "x(130)".
                else 
                    put tt-editor.conteudo at 8 format "x(130)".
    
                assign l-primeira = no.
                if line-counter > (page-size - 4) then page.
            end.                       
        end.        
        if tt_log_erro_aux.ttv_des_msg_ajuda <> "" and tt_log_erro_aux.ttv_des_msg_ajuda <> ? then do:
            empty temp-table tt-editor.
            run pi-print-editor (input tt_log_erro_aux.ttv_des_msg_ajuda, input 60).
    
            assign l-primeira = yes.
            for each tt-editor no-lock:
                if l-primeira then 
                    put trim(c-lb-ajuda) + ": " + tt-editor.conteudo at 1 format "x(130)".
                else 
                    put tt-editor.conteudo at 8 format "x(130)".
    
                assign l-primeira = no.
                if line-counter > (page-size - 4) then page.
            end.
        end.
    end.
END PROCEDURE.

/* PROCEDURE pi-imprime-narrativa:
    if  tt-param.l-narrativa-item  then do:
        find first narrativa where narrativa.it-codigo = item.it-codigo no-lock no-error. 
        if  avail narrativa 
        and narrativa.descricao <> "" then do:
            put unformatted    
                fill("-", 10) at 4 format "x(10)"
                c-lb-narra-it  
                fill("-", 10) format "x(10)".
            run pi-print-editor (input narrativa.descricao, input 60).
            for each tt-editor with stream-io frame f-narrativa:
                disp tt-editor.conteudo with stream-io frame f-narrativa.
                down  with stream-io frame f-narrativa.
                if line-counter > (page-size - 4) then do:
                   page.
                   run pi-mostra-dados.
                end.   
            end.                                               
        end.
    end.
    if  tt-param.l-narrativa-ordem
    and ordem-compra.narrativa <> "" then do:
        put unformatted 
            fill("-", 14) at 4 format "x(14)"
            c-lb-narra-ord  
            fill("-", 14) format "x(14)".
        run pi-print-editor (input ordem-compra.narrativa, input 60).
        for each tt-editor with stream-io frame f-narrativa:
            disp tt-editor.conteudo with stream-io frame f-narrativa.
            down  with frame f-narrativa.

            if line-counter > (page-size - 3) then do:
               page.
               run pi-mostra-dados.
            end.   
        end.                    
    end.                               
END PROCEDURE. 

PROCEDURE pi-mostra-dados:
    if line-counter < 15 then do:
        &if defined(bf_mat_contratos) &then
        if pedido-compr.nr-contrato <> 0 then
        &else
        if pedido-compr.nr-contrato <> "" then
        &endif
            {ccp/cc0305.i3} /* Display do cabe‡alho do pedido */
        else
            {ccp/cc0305.i1} /* Display do cabe‡alho do pedido */
        assign l-imprimiu = yes.

        disp c-lb-ordem   c-lb-item
             c-lb-ct-cont c-lb-c-custo
             c-lb-desc    c-lb-taxa
             c-lb-ipi     c-lb-vl-ipi
             c-lb-item-for c-lb-pa       
             c-lb-qtde    c-lb-un      
             c-lb-prc-unit c-lb-vl-desc 
             c-lb-vl-enc   c-lb-prc-tot 
             c-lb-ref c-lb-data
             with frame f-labels.
    end.
    {utp/ut-liter.i Continua * r}
    assign c-msg = trim(return-value).
    if  de-ipi-tot > 0 then
        assign de-ipi1 = round(de-ipi-tot,2).
    else
        assign de-ipi1 = 0.

    disp ordem-compra.numero-ordem   space(1)         
         item.it-codigo              space(1)
         ordem-compra.ct-codigo      space(1)
         ordem-compra.sc-codigo      space(1)
         ordem-compra.perc-descto    space(0) "% "    space(0)
         ordem-compra.valor-taxa     format ">>9.99"
                    when not ordem-compra.taxa-financ  space(0)
                    "      "  when ordem-compra.taxa-financ @
                        ordem-compra.valor-taxa space(0)
         c-tax-aux when not ordem-compra.taxa-financ  space(1)
         " "       when ordem-compra.taxa-financ @ c-tax-aux  space(1)
         ordem-compra.aliquota-ipi space(0) "%" space(1)         
         de-ipi1   format ">>>>>>>>,>>9.99"
                   when not ordem-compra.codigo-ipi
         c-lb-inc  format "x(15)"
                   when ordem-compra.codigo-ipi @ de-ipi1
         item-fornec.item-do-forn  when avail item-fornec AT 11
         with no-box no-label width 132 stream-io frame f-ordem.

    if  tt-param.l-descricao then
        disp c-descricao with stream-io frame f-descricao.
END PROCEDURE.

         */

PROCEDURE pi-cria-tt-maq-ep-est:

/* find estabelec where estabelec.cod-estabel = c-estabel-dest no-lock no-error.
if avail estabelec and estabelec.cod-estabel <> " " then do: 

    create tt-param-maq-ep-est.
    assign tt-param-maq-ep-est.cod-versao-integracao = 1
           tt-param-maq-ep-est.cod-estabel = c-estabel-dest
           tt-param-maq-ep-est.opcao = 2.

    run mpp/mpapi011.p (input-output table tt-param-maq-ep-est,
                        input-output table tt-maq-ep-est).    
 end.
 */
END PROCEDURE.


PROCEDURE pi-integracoes:

    &if "{&bf_mat_versao_ems}":U < "2.05":U  &then
       ASSIGN c-business-to-business = substring(emitente.char-1,11,1) .
    &else
        ASSIGN c-business-to-business = IF dist-emitente.parceiro-b2b = YES THEN '1' ELSE '0'.     
    &endif
    if  tt-param.l-bus-to-bus = yes
    and avail emitente
    and c-business-to-business = "1" then do:  /* parceiro business-to-business */
        
        {ccp/cc0305.i5}
        assign c-changecode = if  pedido-compr.situacao = 1 /* IMPRESSO */
                              then "CHANGE"
                              else "INSERT".
        run ccp/cc0305d.p (input rowid(pedido-compr),
                           c-changecode,
                           input-output table tt-b2b).
        run ccp/cc0305a.p (rowid(pedido-compr)).
        &if "{&bf_mat_versao_ems}":U >= "2.04":U  &then
            if v_log_eai_habilit then 
                run piAdapter.            
        &endif
        next.            
    end.
    else
    if  tt-param.l-envia then do:
        run ccp/cc0305c.p (input raw-param,
                           input rowid(pedido-compr),
                           input l-primeiro-emitente,
                           input l-ultimo-emitente,
                           input l-ultimo-cod-emit).
        next.
    end.
    /** 
    *** e-Procurement
    **/
    
    if  avail emitente 
    &if '{&BF_DIS_VERSAO_EMS}' >= '2.05' &then
    and dist-emitente.log-datasulnet
    &else
    and substring(emitente.char-1,12,1) = "1"
    &endif
    and tt-param.l-eprocurement then do:  /* parceiro de neg¢cios no Portal */
        {ccp/cc0305.i5}
        assign i-status = if  l-pendente
                          then 2
                          else 1
               c-status = ""
               c-changecode = if pedido-compr.situacao = 1  /* IMPRESSO */
                              then "CHANGE"
                              else "INSERT".

        if  i-status <> 2 then do:
            run ccp/cc0305d.p (input rowid(pedido-compr),
                               input c-changecode,
                               input-output table tt-b2b).
            for each tt-b2b: /* NÆo imprimir nada que retornou do cc0305d */
                delete tt-b2b.
            end.
            run ccp/cc0305a.p(input rowid(pedido-compr)).
        end.

        assign c-status = c-valid-status[i-status].

        /* cabe‡alho */
        
        assign pedido-compr.ind-via-envio = &if '{&bf_dis_versao_ems}' >= '2.04' 
                                            &then 10
                                            &else 9
                                            &endif. /* Portal Datasul */

        next. /* para evitar de imprimir o formul rio para o pedido, mesmo
                
                 j  tendo enviado o mesmo eletronicamente para o Portal */
    end. /* fim e-Procurement */

    /* Integra‡Æo com portal de compras */
    &IF "{&bf_mat_versao_ems}" >= "2.062" &THEN 
        IF tt-param.l-integra-portal THEN DO:

            IF CAN-FIND(funcao WHERE funcao.cd-funcao = "SPP-INTEGRA-PORTAL-COMPRA":U AND funcao.ativo) THEN DO: 
                &IF  "{&bf_mat_versao_ems}"  <  "2.09"  &THEN
                IF (AVAIL param-compra AND substring(param-compra.char-2,102,1) = "S":U) THEN DO:
                &ELSE
                IF (AVAIL param-compra AND param-compra.log-integr-portal) THEN DO:
                &ENDIF
                
                    &IF "{&bf_mat_versao_ems}" < "2.09" &THEN                    
                        IF substring(pedido-compr.CHAR-1,2,1) <> "S":U THEN DO:                  
                    &ELSE  
                        IF pedido-compr.log-integr-portal THEN DO:
                    &ENDIF
                            RUN pi-integra-portal-compras(INPUT 1). /* 1 - Webb, 2 - Paradigma */
                        END.
    
                END.
            END.
            ELSE DO:
                IF CAN-FIND(FIRST funcao NO-LOCK
                            WHERE funcao.cd-funcao = "spp-portal-paradigma":U
                              AND funcao.ativo) THEN DO: 
                    IF &IF  "{&bf_mat_versao_ems}"  <  "2.09" &THEN
                           (AVAIL param-compra AND substring(param-compra.char-2,103,1) = "S":U)
                       &ELSE
                           (AVAIL param-compra AND param-compra.log-portal-paradigma)
                       &ENDIF
                    THEN DO:
                        IF &IF "{&bf_mat_versao_ems}" < "2.09" &THEN                    
                               substring(pedido-compr.CHAR-1,2,1) <> "S":U
                           &ELSE  
                               pedido-compr.log-integr-portal
                           &ENDIF
                        THEN DO:
                            RUN pi-integra-portal-compras(INPUT 2). /* 1 - Webb, 2 - Paradigma */
                        END.
                    END.
                END.
            END.
        END.
    &ENDIF

	/************************* INTEGRA€ÇO TOTVS COLABORA€ÇO ****************************/
	IF l-ped-compra THEN DO:
        run pValidaTotvsColab(input 2, 
                              input pedido-compr.end-entrega, 
                              input pedido-compr.cod-emitente). 
            
        if return-value = "OK":U then do:             
                                             
            empty temp-table tt_log_erro.
            
            if not valid-handle(h-ccapi036) then
                run ccp/ccapi036.p persistent set h-ccapi036 (output table tt_log_erro).
                                                  
            IF l-gera-arq-local = NO THEN
                ASSIGN c-arq-ped-compra = "".

            RUN pi-remessa-totvs-colab in h-ccapi036 (input rowid(pedido-compr),
                                             input c-arq-ped-compra,
                                             output table tt_log_erro).   
                                                                                                                   
            for each tt_log_erro no-lock:                    
                create tt_log_erro_aux.
                buffer-copy tt_log_erro to tt_log_erro_aux.
                assign tt_log_erro_aux.ttv_tipo = 2.
            end.
    	end.
    END.
    /************************* FIM INTEGRA€ÇO TOTVS COLABORA€ÇO ************************/
	
END PROCEDURE.

PROCEDURE pi-integra-portal-compras:
    DEF INPUT PARAM p-tipo-integ AS INT NO-UNDO.

    RUN adapters/xml/su2/axssu004.p PERSISTENT SET h-axssu004(OUTPUT TABLE tt_log_erro).
    
    IF p-tipo-integ = 1 THEN /* 1 - Webb, 2 - Paradigma */
        RUN piDestinationPartner IN h-axssu004(INPUT "Webb":U). 
    ELSE
        RUN piDestinationPartner IN h-axssu004(INPUT "Paradigma":U). 
    
    run PITransUpsert in h-axssu004 (input rowid(pedido-compr),
                                     output table tt_log_erro).
    DELETE procedure h-axssu004. 
   
    IF CAN-FIND(FIRST tt_log_erro) THEN DO:
        for each tt_log_erro no-lock:
            create tt_log_erro_aux.
            buffer-copy tt_log_erro to tt_log_erro_aux.
            assign tt_log_erro_aux.ttv_tipo = 1.
        end.
    END.
    ELSE DO: /*Se for enviada com sucesso congela e coloca como integrada o pedido, a ordem e a cota‡Æo*/
        run ccp/cc0305f.p (ROWID(pedido-compr)).
    END.
    RETURN "OK":U.
END PROCEDURE.

procedure piAdapter:
    /* Operacional Textil - de: 2.062 p/: 2.04 */
    &if "{&bf_mat_versao_ems}":U >= "2.04":U  &then
        &if "{&bf_mat_versao_ems}":U >= "2.062":U  &then    
            find first dist-emitente no-lock where dist-emitente.cod-emitente = pedido-compr.cod-emitente no-error.
            if v_log_eai_habilit or (avail dist-emitente and dist-emitente.parceiro-b2b and tt-param.l-bus-to-bus) then do:    
                run adapters/xml/su2/axssu004.p persistent set h-axssu004 (output table tt_log_erro).
                run PITransUpsert in h-axssu004 (input rowid(pedido-compr), output table tt_log_erro).                
                for each tt_log_erro no-lock:
                    create tt_log_erro_aux.
                    buffer-copy tt_log_erro to tt_log_erro_aux.
                    assign tt_log_erro_aux.ttv_tipo = 1.
                end.
                delete procedure h-axssu004.    
            end.
        &else       
            if v_log_eai_habilit or tt-param.l-bus-to-bus then do:
                run adapters/xml/su2/axssu004.p persistent set h-axssu004 (output table tt_log_erro).
                run PITransUpsert in h-axssu004 (input rowid(pedido-compr), output table tt_log_erro).
                for each tt_log_erro no-lock:
                    
                    create tt_log_erro_aux.
                    buffer-copy tt_log_erro to tt_log_erro_aux.
                    assign tt_log_erro_aux.ttv_tipo = 1.
                end.
                delete procedure h-axssu004.
            end.
        &endif
    &endif
end procedure.

