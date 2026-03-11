/********************************************************************************
** Programa: int011-c - Exporta‡Æo de Notas de Sa¡da p/ Toturial/PRS
**
** Versao : 12 - 09/02/2016 - Alessandro V Baccin
**
********************************************************************************/
{utp/ut-glob.i}
/* include de controle de versÆo */
{include/i-prgvrs.i int011rp-c 2.12.01.AVB}
{cdp/cdcfgdis.i}


/*** Defini‡äes atualiza documento no recebimento */
 define temp-table tt-digita-re
    field r-docum-est        as rowid.

def temp-table tt-raw-digita-re
   field raw-digita   as raw.

DEF TEMP-TABLE tt-arquivo-erro
    FIELD c-linha AS CHAR.

DEF TEMP-TABLE tt-erro-nota NO-UNDO
    FIELD serie        AS CHAR FORMAT "x(03)"
    FIELD nro-docto    AS CHAR FORMAT "9999999"
    FIELD cod-emitente AS INTEGER FORMAT ">>>>>>>>9"
    FIELD cod-erro     AS INTEGER FORMAT ">>>>>9"
    FIELD descricao    AS CHAR.

define temp-table tt-param-re
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.

DEF VAR i-pos-arq            AS INTEGER                   NO-UNDO.
DEF VAR c-nr-nota            AS CHAR FORMAT "x(10)"       NO-UNDO.
DEF VAR c-linha              AS CHAR.
DEF VAR i-cont               AS INTEGER.
DEF VAR i-erro               AS INTEGER.
def var c-informacao         as char format "X(100)" no-undo.
def var c-origem             as char no-undo.

DEFINE BUFFER b-docum-est   FOR docum-est.
DEFINE BUFFER b-nota-fiscal FOR nota-fiscal.

/* defini‡Æo das temp-tables para recebimento de parƒmetros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-estabel-ini  as char format "x(5)"
    field cod-estabel-fim  as char format "x(5)"
    field dt-cancela-ini   as date format "99/99/9999"
    field dt-cancela-fim   as date format "99/99/9999"
    field dt-emis-nota-ini as date format "99/99/9999"
    field dt-emis-nota-fim as date format "99/99/9999".

def temp-table tt-raw-digita
    	field raw-digita	as raw.

/* recebimento de parƒmetros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.
create tt-param.
raw-transfer raw-param to tt-param NO-ERROR.

if tt-param.dt-emis-nota-ini = ? then
    assign tt-param.dt-emis-nota-ini = today - 7
           tt-param.dt-emis-nota-fim = today.

if tt-param.dt-cancela-ini   = ? then
    assign tt-param.dt-cancela-ini   = today - 7
           tt-param.dt-cancela-fim   = today.

if tt-param.cod-estabel-fim  = "" then
    assign tt-param.cod-estabel-ini  = ""
           tt-param.cod-estabel-fim  = "ZZZZZ".

/* include padrÆo para vari veis de relat¢rio  */
{include/i-rpvar.i}

/* defini‡Æo de vari veis  */
def var h-acomp as handle no-undo.
DEF VAR i-nr-pedido AS INT NO-UNDO.
/* defini‡Æo de frames do relat¢rio */


IF tt-param.arquivo <> "" THEN DO:
    /* include padrÆo para output de relat¢rios */
    {include/i-rpout.i}

    /* include com a defini‡Æo da frame de cabe‡alho e rodap‚ */
    {include/i-rpcab.i}
END.


for first param-global fields (empresa-prin) no-lock
    query-tuning(no-lookahead): end.
for first mguni.empresa fields (razao-social) no-lock where
    empresa.ep-codigo = param-global.empresa-prin 
    query-tuning(no-lookahead): end.

/* bloco principal do programa */
assign  c-programa 	    = "int011rp-c"
	    c-versao	    = "2.12"
	    c-revisao	    = ".01.AVB"
        c-empresa       = mguni.empresa.razao-social
	    c-sistema	    = "Faturamento"
	    c-titulo-relat  = "Integra‡Æo Notas Fiscais Sa¡da - Tutorial/PRS".

IF tt-param.arquivo <> "" THEN DO:
    view frame f-cabec.
    view frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Imprimindo").

for each nota-fiscal no-lock use-index nfftrm-20 where 
    nota-fiscal.dt-emis-nota >= tt-param.dt-emis-nota-ini and
    nota-fiscal.dt-emis-nota <= tt-param.dt-emis-nota-fim and
    (nota-fiscal.cod-estabel = "973" OR nota-fiscal.cod-estabel = "977")    /* KML - acrecentado um OR para vericar os dois CDs */
    on stop undo, leave
    query-tuning(no-lookahead):

      if nota-fiscal.idi-sit-nf-eletro <> 3 AND 
         nota-fiscal.idi-sit-nf-eletro <> 6 THEN NEXT.

    assign i-nr-pedido = 0.

    for first natur-oper 
        fields (cod-cfop tipo tp-oper-terc char-2
                log-ipi-contrib-social log-ipi-outras-contrib-social) 
        no-lock where 
        natur-oper.nat-operacao = nota-fiscal.nat-operacao
        query-tuning(no-lookahead): end.

      IF nota-fiscal.dt-confirma        = ? THEN NEXT.

    /* transferˆncia de impostos */
    if nota-fiscal.nat-operacao begins "5605" then next.
    /*if nota-fiscal.nat-operacao begins "5929" then next.*/
  
    for first ser-estab no-lock where 
        ser-estab.serie = nota-fiscal.serie and
        ser-estab.cod-estabel = nota-fiscal.cod-estabel 
        &if "{&bf_dis_versao_ems}" >= "2.07" &then
        and ser-estab.log-nf-eletro = yes
        &endif
        and ser-estab.forma-emis = 1 /* automatica */
        query-tuning(no-lookahead): end.
    if not avail ser-estab then next.
    
    run pi-acompanhar in h-acomp (input nota-fiscal.cod-estabel + "/" +
                                        nota-fiscal.serie + "/" +
                                        nota-fiscal.nr-nota-fis).
    
    /* AVB 26/06/2018 - retirado para atender chamado 0618-001911 
    for each cst_estabelec no-lock of estabelec where
        cst_estabelec.dt_fim_operacao >= nota-fiscal.dt-emis-nota
        query-tuning(no-lookahead):
        if  cst_estabelec.cod_estabel <> "973" and 
           (cst_estabelec.dt_inicio_oper = ? or
            cst_estabelec.dt_inicio_oper > nota-fiscal.dt-emis-nota) then c-origem = "OBLAK".
        else c-origem = "PROCFIT".
    end.
    */

    /* AVB 26/06/2018 - Determinar Sistema Origem do Pedido - Chamado 0618-001911*/
    c-origem = "OBLAK".
    for each cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = nota-fiscal.cod-estabel and
        cst_estabelec.dt_fim_operacao >= nota-fiscal.dt-emis-nota
        query-tuning(no-lookahead):
        if  cst_estabelec.dt_inicio_oper <> ? and
            cst_estabelec.dt_inicio_oper <= nota-fiscal.dt-emis-nota then c-origem = "PROCFIT".
        if  cst_estabelec.cod_estabel <> "973" and 
            cst_estabelec.cod_estabel <> "014" and 
            cst_estabelec.cod_estabel <> "247" and 
            cst_estabelec.cod_estabel <> "192" and 
            cst_estabelec.cod_estabel <> "199" and 
            cst_estabelec.cod_estabel <> "193" AND
            cst_estabelec.cod_estabel <> "977" and  /* KML - acrecentado 977 */
           (cst_estabelec.dt_inicio_oper = ? or
            cst_estabelec.dt_inicio_oper > nota-fiscal.dt-emis-nota) then c-origem = "OBLAK".
    end.

    RUN pi-trata-entradas.
    RUN pi-trata-saidas.
   

   /*{intprg/int011rp.i}  /* Notas de Sa¡da/entrada balan‡o lojas */*/
          
end.

IF tt-param.arquivo <> "" THEN DO:
    /* fechamento do output do relat¢rio  */
    {include/i-rpclo.i}
END.
run pi-finalizar in h-acomp.
return "OK":U.


{intprg/int038.i} /* Procedure pi-atualizaDocumento e pi-atualizaEstoquePRS */
/* Chamado 0618-001911
{intprg/int011rp.i} /* procedures pi-saidas pi-entradas pi-transferencia-cd */*/
{intprg/int011rp-proc.i} /* procedures pi-saidas pi-entradas pi-transferencia-cd */


procedure pi-trata-entradas:


    for first estabelec fields (cod-estabel cgc cod-emitente) no-lock where 
        estabelec.cgc = nota-fiscal.cgc
        query-tuning(no-lookahead): END.

    IF NOT AVAIL estabelec THEN NEXT.


    /* Balan‡o */
    if natur-oper.tipo = 1 /* entradas */ then do:
        /* Notas de entrada , precisam desatualizar o PRS */
        &if "{&bf_dis_versao_ems}" >= "2.07" &then
            if (nota-fiscal.idi-sit-nf-eletro = 6 or      /* Cancelamento */ 
                nota-fiscal.idi-sit-nf-eletro = 7) and    /* Inutiliza‡Æo */
        &else
            if (sit-nf-eletro.idi-sit-nf-eletro = 6 or      /* Cancelamento */ 
                sit-nf-eletro.idi-sit-nf-eletro = 7) and    /* Inutiliza‡Æo */
        &endif
            nota-fiscal.dt-cancel <> ? 
        then do:
            RUN pi-cancela-entradas (1,1).
        end. /* Fim Cancelamento Entradas */

        /* emissoes de entrada para o CD */    /* KML - acrecentado um OR para vericar os dois CDs */
        else if (nota-fiscal.cod-estabel = "973" OR nota-fiscal.cod-estabel = "977") /* Notas de entrada do CD */ then do:
            &if "{&bf_dis_versao_ems}" >= "2.07" &then
                if nota-fiscal.idi-sit-nf-eletro = 3 /* autorizada */  then
            &else
                if sit-nf-eletro.idi-sit-nf-eletro = 3 /* autorizada */  then
            &endif
            for first docum-est no-lock where
                docum-est.nro-docto    = nota-fiscal.nr-nota-fis  and 
                docum-est.serie        = nota-fiscal.serie        and 
                docum-est.cod-emitente = nota-fiscal.cod-emitente and  
                docum-est.nat-operacao = nota-fiscal.nat-operacao 
                query-tuning(no-lookahead):
                if index(docum-est.observacao ,"Pedido Balan") > 0 
                then do:
                    /*
                    if docum-est.ce-atual = no then
                        run pi-atualizaDocumento.   /* Notas de entrada */  /* int038.i */
                    if docum-est.ce-atual = yes then 
                        run pi-atualizaEstoquePRS.  /* Trigger nÆo funciona */ /* int038.i */
                        */
                    RUN pi-entrada-cd (1,1).
                end.
            end.
        end.
        /* entradas novas de de balan‡o lojas */
        else if nota-fiscal.cgc = estabelec.cgc and
                 nota-fiscal.esp-docto <> 20 /* NFD */ then do:
            run pi-entradas-balanco (c-origem,1,1).
        end.

    end. /* Fim Entradas */
end.

procedure pi-trata-saidas:

    if natur-oper.tipo = 2 then do:
        i-pedido = 0.
        for first estabelec fields (cod-estabel cgc cod-emitente) no-lock where 
            estabelec.cod-estabel = nota-fiscal.cod-estabel
            query-tuning(no-lookahead):

            /* cancelamento */
            if nota-fiscal.dt-cancel <> ? then do:
                RUN pi-cancela-saidas (c-origem,1,1,1,1).
            end. /* Fim Cancelamento - dt-cancel <> ? */

            /* Emissäes */
            /* sa¡das novas normais */
            else if (nota-fiscal.nat-operacao begins "5" or
                     nota-fiscal.nat-operacao begins "6" or
                     nota-fiscal.nat-operacao begins "7") and
                     nota-fiscal.esp-docto <> 21 /* NFE */ then do: /* saidas */

                i-cont = 0.
                /* transferencias */
                for each b-estabelec no-lock where 
                    b-estabelec.cgc = nota-fiscal.cgc
                    query-tuning(no-lookahead):
                    for each cst_estabelec no-lock WHERE 
                             cst_estabelec.cod_estabel = b-estabelec.cod-estabel AND
                             cst_estabelec.dt_fim_operacao >= nota-fiscal.dt-emis-nota
                        query-tuning(no-lookahead):
                        i-cont = i-cont + 1.
                        /* Destino Loja Oblak */
                        if cst_estabelec.dt_inicio_oper = ? or 
                           cst_estabelec.dt_inicio_oper > nota-fiscal.dt-emis-nota then
                            RUN pi-saidas(c-origem,
                                          1, /* situacao saida Oblak - Deixar ativo pois eles usam saida e entrada para dar entrada */
                                          1, /* situacao saida Procfit - NÆo integrar pois eles mesmo emitiram a nota */
                                          1, /* situacao entrada Oblak */
                                          1  /* situacao entrada Procfit - NÆo integrar pois eles mesmo emitiram a nota  */).

                        /* Destino Loja Procfit */
                        if cst_estabelec.dt_inicio_oper <= nota-fiscal.dt-emis-nota then
                            RUN pi-saidas(c-origem,
                                          1, /* situacao saida Oblak - evita integrar nota na Oblak */
                                          1, /* situacao saida Procfit - evita integrar nota na Procfit - eles emitiram a nota*/
                                          2, /* situacao entrada Oblak - evita integrar nota na Oblak */                                
                                          1  /* situacao entrada Procfit */). 
                    end.
                end.
                /* notas de fornecedores */
                if i-cont = 0 then
                    RUN pi-saidas(c-origem,
                                  1, /* situacao saida Oblak - Deixar ativo pois eles usam saida e entrada para dar entrada */
                                  1, /* situacao saida Procfit - NÆo integrar pois eles mesmo emitiram a nota */
                                  1, /* situacao entrada Oblak */
                                  1  /* situacao entrada Procfit - NÆo integrar pois eles mesmo emitiram a nota  */).
            end.

        end. /* estabelec */
    end.
end.

