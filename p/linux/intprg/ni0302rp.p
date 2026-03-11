/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ni0302rp 2.00.00.018 } /*** 010018 ***/
 
&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i ni0302rp MOF}
&ENDIF
 

{include/i_fnctrad.i}
/* ---------------------[ VERSAO ]-------------------- */
/******************************************************************************
**
**  Programa: ni0302rp.P
**  Data....: 
**  Objetivo: RelatΩrio de Apuracao do ICMS Global (Seleá∆o de Estabelecimentos)
**
*******************************************************************************/
{cdp/cdcfgdis.i}  /* pre-processadores */
{intprg/ni0302.i4 "new shared"}

{include/i-epc200.i ni0302RP}

DEF TEMP-TABLE tt-doctos-excluidos NO-UNDO
    FIELD rw-reg AS ROWID.
DEF TEMP-TABLE tt-itens-excluidos  NO-UNDO
    FIELD rw-reg AS ROWID.
/** EPC ****************************/

def new shared var h-acomp       as handle no-undo.

def var l-impr-sep               as logical  init yes             no-undo.
DEF VAR l-tem-icms-st            as logical  init NO              no-undo.
def var c-sepa                   like c-sep.
def var de-deb-1                 as decimal                       no-undo.
def var de-cred-1                as decimal                       no-undo.
def var de-vl-conv1              as decimal  extent 4    init 0   no-undo.
def var tp-natur                 as logical                       no-undo.
def var codigo-nat               as integer                       no-undo.
def var da-docto                 like doc-fiscal.dt-docto         no-undo.
def var credito-1                as decimal                       NO-UNDO.
DEF VAR i-last-page              AS INTEGER                       NO-UNDO.

def var c-vl-tot-item-3    like it-doc-fisc.vl-tot-item  no-undo.               
def var c-vl-bicms-it-3    like it-doc-fisc.vl-bicms-it  no-undo.
def var c-vl-icms-it-3     like it-doc-fisc.vl-icms-it   no-undo. 
def var c-vl-icmsnt-it-3   like it-doc-fisc.vl-icmsnt-it no-undo. 
def var c-vl-icmsou-it-3   like it-doc-fisc.vl-icmsou-it no-undo.
def var c-vl-icmsub-it-3   like it-doc-fisc.vl-icmsub-it no-undo.
def VAR c-vl-dec-2         like it-doc-fisc.DEC-2        no-undo. 

&if '{&bf_dis_versao_ems}' >= '2.06' &THEN
    DEF VAR c-vl-icms-subst-entr LIKE it-doc-fisc.val-icms-subst-entr NO-UNDO.
&endif

def var de-icmsnt-serv     as decimal format ">>>>>>,>>>,>>>,>>9.99" no-undo.
def var de-icmsou-serv     as decimal format ">>>>>>,>>>,>>>,>>9.99" no-undo.
def var de-icmsnt-serv-tot as decimal format ">>>>>>,>>>,>>>,>>9.99" no-undo.
def var de-icmsou-serv-tot as decimal format ">>>>>>,>>>,>>>,>>9.99" no-undo.

def var c-descricao as char no-undo.
def var i-livro     as INT  no-undo.
/*DEF VAR c-grupo     LIKE estabelec.cod-estabel.*/

def var i-pag-print  as integer   no-undo. /*Variavel usada para contar o n£mero de pagina 
a ser impresso*/


form c-natur    at 01
     de-contab
     de-base
     de-imposto
     de-trib
     de-outras
     with stream-io width 132 no-box no-labels frame f-linha.

def buffer b-contr-livros for contr-livros.
def buffer b-termo for termo. 

DEF TEMP-TABLE tt-estab
    FIELD cod-estabel LIKE estabelec.cod-estabel.

{intprg/ni0302.i3 "new"}

{include/i-rpvar.i}

/*{pdp/pd9200.i} /* Relativo a conversao do Real */ */

{include/tt-edit.i}  /** definiªío da tabela p/ impressío do campo editor */

def temp-table tt-raw-digita
    field raw-digita as raw.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

define temp-table tt-param no-undo
    field destino           as integer
    field arquivo           as char
    field usuario           as char format "x(12)"
    field data-exec         as date
    field hora-exec         as integer
    field cod-estabel       like apur-imposto.cod-estabel
    field cod-estabel-fim   like apur-imposto.cod-estabel
    field dt-emissao-ini    like apur-imposto.dt-apur-ini
    field dt-emissao-fim    like apur-imposto.dt-apur-fim
    field estado-ini        like estabelec.estado
    field estado-fim        like estabelec.estado
    field termo-ab          like termo.te-codigo
    field termo-en          like termo.te-codigo
    field moeda             like moeda.mo-codigo
    field tp-emissao        as integer
    field l-separadores     as logical
    field l-resumo-aliq     as logical
    field l-incentivado     as logical
    field l-icms-st         as LOGICAL
    FIELD l-considera-cfops AS LOGICAL
    field imp-cab           AS CHARACTER.

define temp-table tt-natur-oper no-undo
    field nat-operacao   like natur-oper.nat-operacao 
    field c-formato-cfop as char 
    field c-cfop         as char format "x(07)"
    field i-formato-cfop as integer 
    index cfop is primary nat-operacao.

define temp-table tt-itens-validos no-undo
    FIELD cod-estabel    LIKE it-doc-fisc.cod-estabel
    FIELD serie          LIKE it-doc-fisc.serie
    FIELD nr-doc-fis     LIKE it-doc-fisc.nr-doc-fis
    FIELD cod-emitente   LIKE it-doc-fisc.cod-emitente
    field nat-operacao   like it-doc-fisc.nat-operacao 
    FIELD natur          AS CHAR FORMAT "x(01)"
    FIELD nr-seq-doc     LIKE it-doc-fisc.nr-seq-doc
    field c-formato-cfop as char 
    field c-cfop         as char format "x(07)"
    field i-formato-cfop as integer 
    FIELD vl-cont-doc    LIKE doc-fisc.vl-cont-doc /* Estes 2 ultimos campos s∆o utilizados para o calculo do ISS */
    FIELD rw-doc-fisc    AS ROWID
    index cfop is primary UNIQUE cod-estabel
                          serie
                          nr-doc-fis
                          cod-emitente
                          nat-operacao
                          nr-seq-doc
                          c-cfop
    INDEX docto rw-doc-fisc.

def temp-table tt-data no-undo
    field dt-docto like doc-fiscal.dt-docto.

DEF BUFFER b-tt-itens-validos FOR tt-itens-validos.
DEF BUFFER b-tt-estab         FOR tt-estab.

create tt-param.
raw-transfer raw-param to tt-param.

def var l-tem-funcao         as log     no-undo.

assign l-tem-funcao = can-find(funcao where funcao.cd-funcao = "considera-termo" and funcao.ativo).

DEF VAR l-tem-consolidado         AS LOG NO-UNDO.
DEF VAR l-tem-grupo               AS LOG NO-UNDO.
DEF VAR l-possui-item-incentivado AS LOG NO-UNDO.


assign l-tem-consolidado = can-find(funcao where funcao.cd-funcao = "spp-of-consolida" and funcao.ativo)
       l-tem-grupo      = NO.

/**** Tratamento para Estabelecimento Consolidado *****/

EMPTY TEMP-TABLE tt-estab.

FIND FIRST tt-param NO-ERROR.

FOR EACH estabelec NO-LOCK WHERE
         estabelec.cod-estabel >= tt-param.cod-estabel     AND 
         estabelec.cod-estabel <= tt-param.cod-estabel-fim AND 
         estabelec.estado      >= tt-param.estado-ini      AND 
         estabelec.estado      <= tt-param.estado-fim  
    BREAK BY estabelec.cod-estabel:

    create tt-estab.
    assign tt-estab.cod-estabel = estabelec.cod-estabel.   

    assign c-estabel = c-estabel + estabelec.cod-estabel. 

    IF NOT LAST(estabelec.cod-estabel) THEN
       ASSIGN c-estabel = c-estabel + " - ".

END.

run utp/ut-trfrrp.p (input frame f-linha:handle).
{include/i-rpout.i}

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Imprimindo...").

FOR EACH b-tt-estab 
    BREAK BY b-tt-estab.cod-estabel:

    /* Separadores */
    assign l-separadores  = tt-param.l-separadores
           c-sep          = if  l-separadores 
                            then "|" 
                            else ""
           c-linha-branco = c-sep + fill(" ",22) +
                            c-sep + fill(" ",20) + c-sep + fill(" ",21) + c-sep + fill(" ",21) +
                            c-sep + fill(" ",21) + c-sep + fill(" ",20) + c-sep
           c-sepa         = if  c-sep <> "" 
                            then c-sep 
                            else "-"
           c-cod-est      = b-tt-estab.cod-estabel
           c-estab-param  = b-tt-estab.cod-estabel
           da-iniper      = tt-param.dt-emissao-ini
           da-fimper      = tt-param.dt-emissao-fim
           i-teren        = tt-param.termo-en
           i-terab        = tt-param.termo-ab
           i-moeda        = tt-param.moeda
           l-previa       = if  tt-param.tp-emissao = 1 
                            then yes
                            else no
           l-resumo-aliq  = tt-param.l-resumo-aliq
           c-impres-cab   = if tt-param.imp-cab = "1" then "FOLHA: " else "PµGINA: ".    
      
    {utp/ut-liter.i Saldo_credor_a_transportar_para_o_per°odo_seguinte * r}
    assign c-descricao = return-value.
    
    for first estabelec fields ( nome cgc ins-estadual estado )
        where estabelec.cod-estabel = c-cod-est no-lock.
    end.
    
    
    
    for first param-global fields ( formato-id-federal ) no-lock.
    end.
    
    if  avail param-global then
        assign c-cgc       = if  param-global.formato-id-federal <> "" 
                             then string(estabelec.cgc, param-global.formato-id-federal)
                             else estabelec.cgc
               c-inscricao = estabelec.ins-estadual.
    else 
        assign c-cgc       = estabelec.cgc
               c-inscricao = estabelec.ins-estadual.
    
    IF l-incentivado = TRUE THEN
        ASSIGN i-livro = 10.
    ELSE
        ASSIGN i-livro = 4.

    find last  contr-livros
         where contr-livros.cod-estabel = c-cod-est
         and   contr-livros.dt-ult-emi <= da-iniper
         and   contr-livros.livro       = i-livro
         no-lock no-error.
    
    if  avail contr-livros then
        assign i-num-pag = contr-livros.nr-ult-pag.
    
    for first param-of fields ( cod-estabel reinicia-icms nr-pag-ap-icms reinicia-fecha )
        where param-of.cod-estabel = c-cod-est no-lock.
    end.
    
    find termo where 
         termo.te-codigo = i-terab no-lock no-error.

    find b-termo where 
         b-termo.te-codigo = i-teren no-lock no-error.
    
    if  param-of.reinicia-icms
    and (   day(da-iniper) = 1
         or (    day(da-iniper) <> 1 
             and i-num-pag = (param-of.nr-pag-ap-icms +
                                    if l-tem-funcao
                                    then 1
                                    else 0 ))) then 
    do:
        IF FIRST(b-tt-estab.cod-estab) 
        THEN DO:
           {intprg/ni0302.i1 termo}
        END.  
             
        assign i-num-pag = 2.
        if l-tem-funcao then assign i-num-pag = 1.
    end.
    else
        if  not param-of.reinicia-icms
        and (   (    (param-of.nr-pag-ap-icms +
                                    if l-tem-funcao
                                    then 1
                                    else 0 ) = i-num-pag
                 and param-of.reinicia-fecha)
             or  i-num-pag = 0) then 
        do:
           IF FIRST(b-tt-estab.cod-estab) 
           THEN DO:
             {intprg/ni0302.i1 termo}
           END.

            assign i-num-pag = 2.
            if l-tem-funcao then assign i-num-pag = 1.
        end.
        else
            assign i-num-pag = i-num-pag + 1.
    
    if  i-num-pag modulo (param-of.nr-pag-ap-icms +
                                    if l-tem-funcao
                                    then 1
                                    else 0 ) = 0 then do:
    
         IF FIRST(b-tt-estab.cod-estab) 
         THEN DO:
           {intprg/ni0302.i1 "b-termo"}
           {intprg/ni0302.i1 termo}
         END.

         if l-tem-funcao 
         then if  param-of.reinicia-icms
             and day(da-iniper) <> 1 then
                 assign i-num-pag = i-num-pag.
             else
                 assign i-num-pag = 1.
         else if  param-of.reinicia-icms
             and day(da-iniper) <> 1 then
                 assign i-num-pag = i-num-pag + 2.
             else
                 assign i-num-pag = 2.
    end.
    
    IF FIRST(b-tt-estab.cod-estab) 
    THEN DO:
        assign c-tipo = "                ENTRADAS".
        
        if  l-separadores then do:
            assign c-tit1 = "OPERAÄÂES COM CRêDITO DO IMPOSTO"
                   c-tit2 = "OPERAÄÂES SEM CRêDITO DO IMPOSTO"
                   c-tit3 = "CREDITADO".
            view frame f-diag.
            disp c-tipo c-tit1 c-tit2 c-tit3 with frame f-sdiag.
            view frame f-bottom.
        end.
        else do:
            view frame f-cabec.
            disp c-tipo with frame f-cab-2.
        end. 
    
        assign l-resuf    = no
               i-aux-tipo = 1
               tp-natur   = yes.
        
        do  da-docto = da-iniper to da-fimper:
            create tt-data.
            assign tt-data.dt-docto = da-docto.
        end.    

        /** EPC INSIDE **/
       /* Colocado o processamento principal do programa em procedure pois estava ocorrendo estouro de tamanho do programa em base Oracle */

        RUN pi-processa. 
    
        run pi-imprime-termo ( line-counter, page-size + 1).
    
        assign de-imp-cre = de-acm-ip1
               i-aux-tipo = 2
               c-tipo     = "                 SA÷DAS".
        
        if  l-separadores then do:
            assign c-tit1 = "OPERAÄÂES COM DêBITO DO IMPOSTO"
                   c-tit2 = "OPERAÄÂES SEM DêBITO DO IMPOSTO"
                   c-tit3 = "DEBITADO".
            disp c-tipo c-tit1 c-tit2 c-tit3 with frame f-sdiag.
        end.
        else do:
            hide frame f-cab-2.
            disp c-tipo with frame f-cab-3.
        end. 
        
        assign tp-natur = no.
        
        /** EPC INSIDE **/
        /* Colocado o processamento principal do programa em procedure pois estava ocorrendo estouro de tamanho do programa em base Oracle */
        RUN pi-processa.  /*{intprg/ni0302.i}*/
        
        run pi-imprime-termo ( line-counter, page-size + 1 ).
        
        assign de-imp-deb = de-acm-ip1
               i-aux-tipo = 0.
        
        /*---------- Resumo por Aliquotas -----------*/
        if l-resumo-aliq then
           run intprg/ni0302f.p (input 1).
        
        if  l-resumo-aliq then do:
            hide frame f-diag.
            run intprg/ni0302f.p (input 2).
            run pi-imprime-termo ( line-counter, page-size + 1 ).
        end.
        /*--------------------------------------------*/
        
        if  l-separadores then do:
            view frame f-diag.
            hide frame f-sdiag.
        end.    
        else do:
            hide frame f-cab-2.
            hide frame f-cab-3.      
            view frame f-cabec.
        end.      
        
        assign c-moeda = "".
        if  i-moeda <> 0 then do:
            for first moeda fields ( descricao )
                where moeda.mo-codigo = i-moeda no-lock.
            end.
            if avail moeda then
               assign c-moeda = fill(" ",(12 - length(trim(moeda.descricao))))
                              + trim(moeda.descricao).
        end.
        
        assign de-cotacao = 1
               de-conv    = 1.

    END.

    for first doc-fiscal fields ( dt-docto estado ) use-index ch-apuracao
        where doc-fiscal.cod-estabel = c-cod-est
        and   doc-fiscal.ind-sit-doc = 1
        and   doc-fiscal.dt-docto   >= da-iniper
        and   doc-fiscal.dt-docto   <= da-fimper no-lock.
    end.
    
    {cdp/cd9600.i "i-moeda" "doc-fiscal.dt-docto" "de-cotacao"}
    
    assign de-conv = de-conv * de-cotacao.
    
    /*ASSIGN c-cod-est = (IF l-tem-consolidado THEN c-grupo ELSE c-cod-est).*/
    
    IF LAST(b-tt-estab.cod-estab) 
    THEN DO:
       run intprg/ni0302a.p (input l-incentivado, input tt-param.tp-emissao).
    END.

    for first imp-valor fields ( vl-lancamento )
        where imp-valor.cod-estabel =  c-cod-est 
        and   imp-valor.tp-imposto  = 4 
        and   imp-valor.dt-apur-ini = da-iniper 
        and   imp-valor.dt-apur-fim = da-fimper NO-LOCK.
    end.
    IF l-resuf OR AVAIL imp-valor THEN
    DO:
    
        /* SUBSTITUICAO TRIBUTARIA - OPERACOES INTERNAS */
    
        for first estabelec fields ( estado )
            where estabelec.cod-estabel = c-cod-est no-lock.
        end.
    
        for first apur-imposto fields ( cod-estabel tp-imposto dt-apur-ini
                                        dt-apur-fim dt-entrega loc-entrega observacao )
             where apur-imposto.cod-estabel = c-cod-est 
             and   apur-imposto.dt-apur-ini = da-iniper 
             and   apur-imposto.dt-apur-fim = da-fimper 
             and   apur-imposto.tp-imposto  = 4 no-lock.
        end.
    
        ASSIGN l-possui-item-incentivado = NO.
    
        IF estabelec.estado = "PE" AND NOT l-incentivado THEN DO:
            FOR FIRST it-doc-fisc FIELDS() NO-LOCK
                WHERE it-doc-fisc.cod-estabel  = estabelec.cod-estabel
                AND CAN-FIND(FIRST item
                             WHERE item.it-codigo = it-doc-fisc.it-codigo
                             AND   item.incentivado):
    
                ASSIGN l-possui-item-incentivado = YES.
    
            END.
        END.
    
        IF  AVAIL apur-imposto 
        AND (   NOT(estabelec.estado = "PE" AND NOT l-incentivado)
             OR NOT l-possui-item-incentivado) THEN DO:
                  
            ASSIGN l-tem-icms-st = YES.
            run pi-acompanhar in h-acomp (input apur-imposto.cod-estabel ).
            assign i-num-pag = i-num-pag + 1.
            assign c-tit = "  RESUMO DA"
                   c-uf  = "- SUBSTITUICAO TRIBUTARIA - OPER.INTERNAS"
                   da-iniper  = da-inimes
                   de-imp-deb = 0
                   de-imp-cre = 0.
    
    
            if  estabelec.estado = "MG" 
            then assign c-titimposto = "IMPOSTO".
            else assign c-titimposto = "ICMS".
    
            /* INICIO */
            for each res-uf-e1 EXCLUSIVE-LOCK break by res-uf-e1.uf :
                run pi-acompanhar in h-acomp (input res-uf-e1.uf ).
    
                accumulate res-uf-e1.vl-bsubs (total by res-uf-e1.uf)
                           res-uf-e1.vl-icmsub (total by res-uf-e1.uf).
                if last-of(res-uf-e1.uf) then
                   assign de-imp-cre =     
                        accum total by res-uf-e1.uf res-uf-e1.vl-icmsub.
            end.
    
            for each res-uf-s1 EXCLUSIVE-LOCK break by res-uf-s1.uf :
                run pi-acompanhar in h-acomp (input res-uf-s1.uf ).
                accumulate res-uf-s1.vl-bsubs (total by res-uf-s1.uf)
                           res-uf-s1.vl-icmsub (total by res-uf-s1.uf).
    
                if last-of(res-uf-s1.uf) then
                   assign de-imp-deb = 
                          accum total by res-uf-s1.uf res-uf-s1.vl-icmsub.
            end.                   
            /* FIM */
    
            /*ASSIGN c-cod-est = (IF l-tem-consolidado THEN c-grupo ELSE c-cod-est). */
             
             ASSIGN i-last-page = i-num-pag + 1.
             RUN intprg/ni0302c.p(INPUT-OUTPUT c-sepa, INPUT 4, OUTPUT credito-1).
             
            /**  Geraá∆o autom†tica do C¢digo 014
            **/
            if  tt-param.tp-emissao = 2 
            and credito-1 >= 0 then do:
    
                for first imp-valor fields ( vl-lancamento )
                    where imp-valor.cod-estabel = c-cod-est  
                    and   imp-valor.tp-imposto  = 4 
                    and   imp-valor.cod-lanc    = 014 
                    and   imp-valor.dt-apur-ini = da-iniper 
                    and   imp-valor.dt-apur-fim = da-fimper exclusive-lock.
                end.
    
                if  not available imp-valor then do:
                    create imp-valor.
                    assign imp-valor.cod-estabel   = c-cod-est
                           imp-valor.cod-lanc      = 014
                           imp-valor.descricao     = c-descricao
                           imp-valor.dt-apur-fim   = da-fimper
                           imp-valor.dt-apur-ini   = da-iniper
                           imp-valor.nr-sequencia  = 1
                           imp-valor.tp-imposto    = 4
                           imp-valor.vl-lancamento = credito-1.
                end.
                else do:
                    assign imp-valor.vl-lancamento = credito-1.
                    release imp-valor.    
                end.               
            end.
        end.
        ELSE DO:
           IF LAST(b-tt-estab.cod-estab) 
           THEN DO:
               RUN pi-imprime-icms-st-zerado.
           END.
        END.
            
        IF LAST(b-tt-estab.cod-estab) 
        THEN DO:

            /* SUBSTITUICAO TRIBUTARIA - OPERACOES INTERESTADUAIS */
            assign c-tit        = "REGISTRO DE"
                   c-titimposto = "ICMS"
                   c-uf         = "- SUBSTITUIÄ«O TRIBUTµRIA - OPER.INTEREST" 
                   c-tipo       = "                   ENTRADAS"
                   c-tit1       = "OPERAÄÂES COM CRêDITOS DO IMPOSTO"
                   c-tit2       = "OPERAÄÂES SEM CRêDITOS DO IMPOSTO"
                   c-tit3       = "CREDITADO".
        
            if  l-separadores then do:
                /*assign i-num-pag = i-num-pag + 1.*/
                view frame f-diag.
                disp c-tipo c-tit1 c-tit2 c-tit3 with frame f-sdiag.
            end.
            else do:
                /*assign i-num-pag = i-num-pag + 1.*/
                hide frame f-cab-3.
                view frame f-cabec-2.
                HIDE FRAME f-cabec.
                view frame f-cab-2.
            end.
        

            find first res-uf-e2 EXCLUSIVE-LOCK NO-ERROR.
            if  not avail res-uf-e2 then
        
                run pi-imprime-termo ( line-counter, 5 ).
        
                /* Inicio -- Projeto Internacional */
                {utp/ut-liter.i "TOTAL" *}
                put c-sep at 1  
                    c-sep at 16
                    c-sep at 24
                    c-sep at 45
                    c-sep at 67
                    c-sep at 89                                       
                    c-sep at 111
                    c-sep at 132 skip
                    c-sep at 1  
                    c-sep at 16
                    c-sep at 24
                    TRIM(RETURN-VALUE) FORMAT "X(7)"         at 33
                    c-sep at 45
                    0      format ">>>>,>>>,>>>,>>9.99"      at 48
                    c-sep
                    0      format ">>>>,>>>,>>>,>>9.99"      at 70
                    c-sep
                    c-sep at 111
                    c-sep at 132 skip
                    c-sep at 1  
                    c-sep at 16
                    c-sep at 24
                    c-sep at 45
                    c-sep at 67
                    c-sep at 89                                       
                    c-sep at 111
                    c-sep at 132 skip
                    c-sep at 1  
                    c-sep at 16
                    c-sep at 24
                    c-sep at 45
                    c-sep at 67
                    c-sep at 89                                       
                    c-sep at 111
                    c-sep at 132 skip
                    c-sep at 1  
                    c-sep at 16
                    c-sep at 24
                    c-sep at 45
                    c-sep at 67
                    c-sep at 89                                       
                    c-sep at 111
                    c-sep at 132 skip.
        
                RUN piImprimeInf.

        END.

    END.
    
    if  not l-previa then do:
    
        if  i-num-pag + 1  = (param-of.nr-pag-ap-icms +
                                    if l-tem-funcao
                                    then 1
                                    else 0 )
        and param-of.reinicia-icms = no then do:

            IF LAST(b-tt-estab.cod-estab) 
            THEN DO:
              
                {intprg/ni0302.i1 "b-termo"}

            END.

            assign i-num-pag = 0.
        end.
    
        if  param-of.reinicia-icms
        and ((i-num-pag + 1) modulo (param-of.nr-pag-ap-icms +
                                    if l-tem-funcao
                                    then 1
                                    else 0 ) = 0
        or  month(da-fimper + 1) <> month(da-fimper)) then do:

            IF LAST(b-tt-estab.cod-estab) 
            THEN DO:
              {intprg/ni0302.i1 "b-termo"}
            END.

            assign i-num-pag = 0.
        end.
    
        /*------- Reinicializa numeracao de livro ao final do ano --------*/
        if  month(da-iniper) = 12
        and day(da-fimper) = 31
        and i-num-pag <> 0 then do:
              
            IF LAST(b-tt-estab.cod-estab) 
            THEN DO:
                find b-termo 
                    where b-termo.te-codigo = i-teren no-lock.
        
                {intprg/ni0302.i1 "b-termo"}
            END.
    
            assign i-num-pag = 0.
        end.
    
        for each contr-livros fields ()
            where contr-livros.cod-estabel =  c-cod-est
            and   contr-livros.dt-ult-emi >= da-iniper
            and   contr-livros.livro       = i-livro exclusive-lock:
            delete contr-livros.
        end.
    
        create contr-livros.
        assign contr-livros.cod-estabel = c-cod-est 
               contr-livros.dt-ult-emi  = da-fimper
               contr-livros.livro       = i-livro
               contr-livros.nr-ult-pag  = i-num-pag.
    end.

END.

for each res-uf-s1 EXCLUSIVE-LOCK:
    delete res-uf-s1.
end.

for each res-uf-s2 EXCLUSIVE-LOCK:
    delete res-uf-s2.
end.

for each res-uf-e1 EXCLUSIVE-LOCK:
    delete res-uf-e1.
end.

for each res-uf-e2 EXCLUSIVE-LOCK:
    delete res-uf-e2.
end.

run pi-finalizar in h-acomp.

{include/i-rpclo.i}

return "OK".

{include/pi-edit.i}

{intprg/ni0302.i8} /* procedure pi-imprime-termo */

/* Colocado o processamento principal do programa em procedure pois estava ocorrendo estouro de tamanho do programa em base Oracle */
PROCEDURE pi-processa:

    {intprg/ni0302.i}

END PROCEDURE.

procedure pi-gera-resumo-uf:

    if  tp-natur then do:

        if  (it-doc-fisc.vl-bsubs-it > 0
        or   it-doc-fisc.vl-icmsub-it > 0) then do:

            if  doc-fiscal.estado = estabelec.estado then do:

                find first res-uf-e1
                     where res-uf-e1.uf       = doc-fiscal.estado EXCLUSIVE-LOCK NO-ERROR .

                if  not avail res-uf-e1 then do:
                    create res-uf-e1.
                    assign res-uf-e1.uf        = doc-fiscal.estado
                           l-resuf             = yes.
                end. 

                assign res-uf-e1.vl-bsubs  = res-uf-e1.vl-bsubs  + it-doc-fisc.vl-bsubs-it
                       res-uf-e1.vl-icmsub = res-uf-e1.vl-icmsub + it-doc-fisc.vl-icmsub-it.
            end.
            else do:
                find first res-uf-e2
                     where res-uf-e2.uf       = doc-fiscal.estado EXCLUSIVE-LOCK NO-ERROR .

                if  not avail res-uf-e2 then do:
                    create res-uf-e2.
                    assign res-uf-e2.uf        = doc-fiscal.estado
                           l-resuf             = yes.
                end.

                assign res-uf-e2.vl-bsubs  = res-uf-e2.vl-bsubs  + it-doc-fisc.vl-bsubs-it
                       res-uf-e2.vl-icmsub = res-uf-e2.vl-icmsub + it-doc-fisc.vl-icmsub-it.
            end.
        end.
    end.
    else 
        if  not tp-natur then do:
            if  it-doc-fisc.vl-bsubs-it > 0
            or  it-doc-fisc.vl-icmsub-it > 0 then do:
                if  doc-fiscal.estado = estabelec.estado then do:

                    find first res-uf-s1
                         where res-uf-s1.uf       = doc-fiscal.estado EXCLUSIVE-LOCK NO-ERROR .

                    if  not avail res-uf-s1 then do:
                       create res-uf-s1.
                        assign res-uf-s1.uf        = doc-fiscal.estado
                               l-resuf             = yes.
                    end.

                    assign res-uf-s1.vl-bsubs  = res-uf-s1.vl-bsubs  + it-doc-fisc.vl-bsubs-it
                           res-uf-s1.vl-icmsub = res-uf-s1.vl-icmsub + it-doc-fisc.vl-icmsub-it.
                end.
                else do:
                    find first res-uf-s2
                         where res-uf-s2.uf       = doc-fiscal.estado EXCLUSIVE-LOCK NO-ERROR .

                    if  not avail res-uf-s2 then do:
                        create res-uf-s2.
                        assign res-uf-s2.uf        = doc-fiscal.estado
                               l-resuf             = yes.
                    end.

                    assign res-uf-s2.vl-bsubs  = res-uf-s2.vl-bsubs  + it-doc-fisc.vl-bsubs-it
                           res-uf-s2.vl-icmsub = res-uf-s2.vl-icmsub + it-doc-fisc.vl-icmsub-it.
                end.
            end.
        end.

end procedure. /* procedure pi-gera-resumo-uf */



PROCEDURE pi-imprime-icms-st-zerado:
    assign c-uf       = "- SUBSTITUIÄ«O TRIBUTµRIA - OPER.INTERNAS"
           da-iniper  = da-inimes
           de-imp-deb = 0
           de-imp-cre = 0.
  
    for each res-uf-e1 EXCLUSIVE-LOCK break by res-uf-e1.uf :
        run pi-acompanhar in h-acomp (input res-uf-e1.uf ).

        accumulate res-uf-e1.vl-bsubs (total by res-uf-e1.uf)
                   res-uf-e1.vl-icmsub (total by res-uf-e1.uf).
        if last-of(res-uf-e1.uf) then
           assign de-imp-cre =     
                accum total by res-uf-e1.uf res-uf-e1.vl-icmsub.
    end.

    for each res-uf-s1 EXCLUSIVE-LOCK break by res-uf-s1.uf :
        run pi-acompanhar in h-acomp (input res-uf-s1.uf ).
        accumulate res-uf-s1.vl-bsubs (total by res-uf-s1.uf)
                   res-uf-s1.vl-icmsub (total by res-uf-s1.uf).

        if last-of(res-uf-s1.uf) then
           assign de-imp-deb = 
                  accum total by res-uf-s1.uf res-uf-s1.vl-icmsub.
    end.                    

    assign de-imposto     = 0
           de-deb-1       = de-imp-deb - de-imp-cre
           de-deb-1       = if de-deb-1 <= 0 
                            then 0
                            else de-deb-1
           de-imposto     = de-deb-1
           de-cred-1      = de-imp-cre - de-imp-deb 
           de-cred-1      = if de-cred-1 <= 0
                            then 0
                            else de-cred-1
           de-vl-conv1[1] = if  de-imp-deb > 0 
                            then round(de-imp-deb / de-conv,3)
                            else 0
           de-vl-conv1[2] = if  de-imp-cre > 0 
                            then round(de-imp-cre / de-conv,3)
                            else 0
           de-vl-conv1[3] = round(de-deb-1 / de-conv,3)
           de-vl-conv1[4] = round(de-cred-1 / de-conv,3).

    run pi-imprime-termo ( line-counter, page-size + 1 ).

    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-debito-do-imposto AS CHARACTER FORMAT "X(19)" NO-UNDO.
    {utp/ut-liter.i "DêBITO_DO_IMPOSTO" *}
    ASSIGN c-lbl-liter-debito-do-imposto = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-valores AS CHARACTER FORMAT "X(9)" NO-UNDO.
    {utp/ut-liter.i "VALORES" *}
    ASSIGN c-lbl-liter-valores = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-coluna-auxiliar AS CHARACTER FORMAT "X(17)" NO-UNDO.
    {utp/ut-liter.i "COLUNA_AUXILIAR" *}
    ASSIGN c-lbl-liter-coluna-auxiliar = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-somas AS CHARACTER FORMAT "X(7)" NO-UNDO.
    {utp/ut-liter.i "SOMAS" *}
    ASSIGN c-lbl-liter-somas = TRIM(RETURN-VALUE).
    put c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip                           
        c-sep at 1 
        c-sep at 4 
        c-lbl-liter-debito-do-imposto
        c-sep at 82                                       
        c-lbl-liter-valores                                                
        at (if c-moeda <> "" then 90 else 104) 
        c-sep at 132 skip
        c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip
        c-sep at 1 "|" at 4
        c-sep at (if c-moeda <> "" then 65 else 82) c-lbl-liter-coluna-auxiliar
        at (if c-moeda <> "" then 66 else 87)
        c-sep at (if c-moeda <> "" then 102 else 107)
        c-lbl-liter-somas      
        at (if c-moeda <> "" then 103 else 117).
                                           
    if  c-moeda <> "" then    
        put c-moeda        format "x(12)"                            to 132 skip.
    else
        put c-sep at 132 skip         
            c-sep at 1
            "|" at 4
            c-sep at 82
            fill("-",24) format "x(24)" 
            c-sep
            fill("-",24) format "x(24)"
            c-sep.

    /* Inicio -- Projeto Internacional */
    {utp/ut-liter.i "D_|_001_-_POR_SA÷DAS/PRESTAÄÂES_COM_DêBITO_DO_IMPOSTO" *}
    put c-sep at 1
        TRIM(RETURN-VALUE) FORMAT "X(55)"
        c-sep at 82
        c-sep at (if c-moeda <> "" then 87 else 107)
        de-imp-deb              format ">>>>>,>>>,>>>,>>9.99"    
        at (if c-moeda <> "" then 88 else 112).

    if  i-moeda <> 0 and de-vl-conv1[1] > 0 then
        put de-vl-conv1[1]           format ">>>>,>>>,>>>,>>9.999" to 131.

    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-e-002-outros-debitos-discri AS CHARACTER FORMAT "X(47)" NO-UNDO.
    {utp/ut-liter.i "ê_|_002_-_OUTROS_DêBITOS_(DISCRIMINAR_ABAIXO)" *}
    ASSIGN c-lbl-liter-e-002-outros-debitos-discri = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-i-003-estorno-de-creditos-d AS CHARACTER FORMAT "X(52)" NO-UNDO.
    {utp/ut-liter.i "I_|_003_-_ESTORNO_DE_CRêDITOS_(DISCRIMINAR_ABAIXO)" *}
    ASSIGN c-lbl-liter-i-003-estorno-de-creditos-d = TRIM(RETURN-VALUE).
    put c-sep at 132 skip
        c-sep at 1
        c-lbl-liter-e-002-outros-debitos-discri             
        c-sep at 82
        c-sep at 107
        c-sep at 132 skip
        c-sep at 1
        "B |"  
        c-sep at 82
        c-sep at 107 
        c-sep at 132 skip
        c-sep at 1
        c-lbl-liter-i-003-estorno-de-creditos-d     
        c-sep at 82
        c-sep at 107
        c-sep at 132 skip
        c-sep at 1
        "T |"  
        c-sep at 82
        c-sep at 107 
        c-sep at 132 skip
        c-sep at 1.
                                  
    /* Inicio -- Projeto Internacional */
    {utp/ut-liter.i "O_|_004_-_SUBTOTAL" *}
    put TRIM(RETURN-VALUE) FORMAT "X(20)".

    put c-sep at 82
        c-sep at (if c-moeda <> "" then 87 else 107)  
        de-imp-deb 
        format ">>>>>,>>>,>>>,>>9.99" 
        at (if c-moeda <> "" then 88 else 112).

    if  i-moeda <> 0 then
        put de-vl-conv1[1]         format ">>>>,>>>,>>>,>>9.999" to 131.

    assign i-pag-print = 13.

    {intprg/ni0302.i7}.

    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-credito-do-imposto AS CHARACTER FORMAT "X(20)" NO-UNDO.
    {utp/ut-liter.i "CRêDITO_DO_IMPOSTO" *}
    ASSIGN c-lbl-liter-credito-do-imposto = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-005-por-entradasaquisicoes AS CHARACTER FORMAT "X(56)" NO-UNDO.
    {utp/ut-liter.i "|_005_-_POR_ENTRADAS/AQUISIÄÂES_COM_CRêDITO_DO_IMPOSTO" *}
    ASSIGN c-lbl-liter-005-por-entradasaquisicoes = TRIM(RETURN-VALUE).
    put c-sep at 132 skip
        c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip                           
        c-sep at 1  
        c-sep at 4
        c-lbl-liter-credito-do-imposto                                     at 30  
        c-sep at 82                                       
        c-sep at 107
        c-sep at 132 skip
        c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip                           
        c-sep at 1
        c-lbl-liter-005-por-entradasaquisicoes at 4
        c-sep at 82
        c-sep at (if c-moeda <> "" then 87 else 107)       
        de-imp-cre                 format ">>>>>,>>>,>>>,>>9.99" 
        at (if c-moeda <> "" then 88 else 112).

    if i-moeda <> 0 then
        put de-vl-conv1[2]        format ">>>>,>>>,>>>,>>9.999" to 131.

    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-c-006-outros-creditos-discr AS CHARACTER FORMAT "X(48)" NO-UNDO.
    {utp/ut-liter.i "C_|_006_-_OUTROS_CRêDITOS_(DISCRIMINAR_ABAIXO)" *}
    ASSIGN c-lbl-liter-c-006-outros-creditos-discr = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-e-007-estorno-de-debitos-di AS CHARACTER FORMAT "X(51)" NO-UNDO.
    {utp/ut-liter.i "ê_|_007_-_ESTORNO_DE_DêBITOS_(DISCRIMINAR_ABAIXO)" *}
    ASSIGN c-lbl-liter-e-007-estorno-de-debitos-di = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-i-008-subtotal AS CHARACTER FORMAT "X(20)" NO-UNDO.
    {utp/ut-liter.i "I_|_008_-_SUBTOTAL" *}
    ASSIGN c-lbl-liter-i-008-subtotal = TRIM(RETURN-VALUE).
    put c-sep at 132 skip 
        c-sep at 1
        c-lbl-liter-c-006-outros-creditos-discr                
        c-sep at 82
        c-sep at 107
        c-sep at 132 skip
        c-sep at 1
        "R |"  
        c-sep at 82
        c-sep at 107 
        c-sep at 132 skip
        c-sep at 1
        c-lbl-liter-e-007-estorno-de-debitos-di       
        c-sep at 82
        c-sep at 107
        c-sep at 132 skip
        c-sep at 1
        "D |"  
        c-sep at 82
        c-sep at 107 
        c-sep at 132 skip
        c-sep at 1
        c-lbl-liter-i-008-subtotal  
        c-sep at 82
        c-sep at (if c-moeda <> "" then 87 else 107)
        de-imp-cre 
        format ">>>>>,>>>,>>>,>>9.99" 
        at (if c-moeda <> "" then 88 else 112).

    if  i-moeda <> 0 then
        put de-vl-conv1[2]           format ">>>>,>>>,>>>,>>9.999" to 131.

    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-o-009-saldo-credor-do-perio AS CHARACTER FORMAT "X(44)" NO-UNDO.
    {utp/ut-liter.i "O_|_009_-_SALDO_CREDOR_DO_PER÷ODO_ANTERIOR" *}
    ASSIGN c-lbl-liter-o-009-saldo-credor-do-perio = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-010-total AS CHARACTER FORMAT "X(15)" NO-UNDO.
    {utp/ut-liter.i "|_010_-_TOTAL" *}
    ASSIGN c-lbl-liter-010-total = TRIM(RETURN-VALUE).
    put c-sep at 1
        "T |"  
        c-sep at 82
        c-sep at 107
        c-sep at 132 skip
        c-sep at 1  
        c-lbl-liter-o-009-saldo-credor-do-perio 
        c-sep at 82
        c-sep at 107
        c-sep at 132 skip
        c-sep at 1
        c-lbl-liter-010-total  at 4            
        c-sep at 82
        c-sep at (if c-moeda <> "" then 87 else 107)
        de-imp-cre 
        format ">>>>>,>>>,>>>,>>9.99" 
        at (if c-moeda <> "" then 88 else 112).

    if  i-moeda <> 0 then
        put de-vl-conv1[2]           format ">>>>,>>>,>>>,>>9.999" to 131.

    assign i-pag-print = 10.

    {intprg/ni0302.i7}.

    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-apuracao-do-saldo AS CHARACTER FORMAT "X(19)" NO-UNDO.
    {utp/ut-liter.i "APURAÄ«O_DO_SALDO" *}
    ASSIGN c-lbl-liter-apuracao-do-saldo = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-011-saldo-devedordebito-men AS CHARACTER FORMAT "X(45)" NO-UNDO.
    {utp/ut-liter.i "|_011_-_SALDO_DEVEDOR(DêBITO_MENOS_CRêDITO)" *}
    ASSIGN c-lbl-liter-011-saldo-devedordebito-men = TRIM(RETURN-VALUE).
    put c-sep at 132 skip
        c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip                           
        c-sep at 1 
        c-sep at 4 
        c-lbl-liter-apuracao-do-saldo
        c-sep at 82                                       
        c-sep at 107
        c-sep at 132 skip
        c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip
        c-sep at 1                           
        c-lbl-liter-011-saldo-devedordebito-men at 4
        c-sep at 82
        c-sep at (if c-moeda <> "" then 87 else 107)
        de-deb-1                 format ">>>>>,>>>,>>>,>>9.99" 
        at (if c-moeda <> "" then 88 else 112). 

    if i-moeda <> 0 and de-vl-conv1[3] > 0 then
        put de-vl-conv1[3]            format ">>>>,>>>,>>>,>>9.999" to 131.

    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-s-012-deducoes-discriminar AS CHARACTER FORMAT "X(41)" NO-UNDO.
    {utp/ut-liter.i "S_|_012_-_DEDUÄÂES_(DISCRIMINAR_ABAIXO)" *}
    ASSIGN c-lbl-liter-s-012-deducoes-discriminar = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-l-013-imposto-a-recolher AS CHARACTER FORMAT "X(30)" NO-UNDO.
    {utp/ut-liter.i "L_|_013_-_IMPOSTO_A_RECOLHER" *}
    ASSIGN c-lbl-liter-l-013-imposto-a-recolher = TRIM(RETURN-VALUE).
    put c-sep at 132 skip
        c-sep at 1
        c-lbl-liter-s-012-deducoes-discriminar                    
        c-sep at 82
        c-sep at 107
        c-sep at 132 skip
        c-sep at 1
        "A |" 
        c-sep at 82
        c-sep at 107 
        c-sep at 132 skip
        c-sep at 1 
        c-lbl-liter-l-013-imposto-a-recolher  
        c-sep at 82
        c-sep at (if c-moeda <> "" then 87 else 107)
        de-imposto                format ">>>>>,>>>,>>>,>>9.99" 
        at (if c-moeda <> "" then 88 else 112).

    if i-moeda <> 0 then
        put de-vl-conv1[3]            format ">>>>,>>>,>>>,>>9.999" to 131.

    /* Inicio -- Projeto Internacional */
    DEFINE VARIABLE c-lbl-liter-d-014-saldo-credorcredito-m AS CHARACTER FORMAT "X(46)" NO-UNDO.
    {utp/ut-liter.i "D_|_014_-_SALDO_CREDOR(CRêDITO_MENOS_DêBITO)" *}
    ASSIGN c-lbl-liter-d-014-saldo-credorcredito-m = TRIM(RETURN-VALUE).
    DEFINE VARIABLE c-lbl-liter-o-a-transportar-para-o-period AS CHARACTER FORMAT "X(49)" NO-UNDO.
    {utp/ut-liter.i "O_|_______A_TRANSPORTAR_PARA_O_PER÷ODO_SEGUINTE" *}
    ASSIGN c-lbl-liter-o-a-transportar-para-o-period = TRIM(RETURN-VALUE).
    put c-sep at 132 skip
        c-sep at 1
        c-lbl-liter-d-014-saldo-credorcredito-m  
        c-sep at 82            
        c-sep at 107
        c-sep at 132
        c-sep at 1
        c-lbl-liter-o-a-transportar-para-o-period 
        c-sep at 82
        c-sep at (if c-moeda <> "" then 87 else 107)
        de-cred-1                format ">>>>>,>>>,>>>,>>9.99" 
        at (if c-moeda <> "" then 88 else 112).  

    if  i-moeda <> 0 then
        put de-vl-conv1[4]            format ">>>>,>>>,>>>,>>9.999" to 131.

    put c-sep at 132 skip 
        c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip.

    if  l-separadores then
        assign c-linha-branco = c-sep + fill(" ",130) + c-sep
               c-sepa = if c-sep <> "" then c-sep else "-".
    ELSE
        assign c-linha-branco = "".

    do  i-aux = line-counter to page-size:
        put c-linha-branco at 1 format "x(132)" skip.
    end.  
    run pi-imprime-termo ( line-counter,0 ).
END PROCEDURE.

/* OFP/ni0302rp.P */        
/** EPC ****************************/
PROCEDURE piCreateEpcParameters:
    DEF VAR cEvent AS CHAR NO-UNDO.
    ASSIGN cEvent = "Parametros":U.

    FOR EACH tt-epc
       WHERE tt-epc.cod-event = cEvent:
        DELETE tt-epc.
    END.
    FOR EACH tt-natur-oper:
        CREATE tt-epc.
        ASSIGN tt-epc.cod-event     = cEvent
               tt-epc.cod-parameter = "natur-oper":U
               tt-epc.val-parameter = tt-natur-oper.nat-operacao.
    END.
    FOR EACH tt-data:
        CREATE tt-epc.
        ASSIGN tt-epc.cod-event     = cEvent
               tt-epc.cod-parameter = "data":U
               tt-epc.val-parameter = STRING(tt-data.dt-docto).
    END.
    CREATE tt-epc.
    ASSIGN tt-epc.cod-event     = cEvent
           tt-epc.cod-parameter = "cod-estabel":U
           tt-epc.val-parameter = string(c-cod-est).
    CREATE tt-epc.
    ASSIGN tt-epc.cod-event     = cEvent
           tt-epc.cod-parameter = "tipo-nat":U
           tt-epc.val-parameter = STRING(codigo-nat).
    CREATE tt-epc.
    ASSIGN tt-epc.cod-event     = cEvent
           tt-epc.cod-parameter = "ind-sit-doc":U
           tt-epc.val-parameter = "1".
    CREATE tt-epc.
    ASSIGN tt-epc.cod-event     = cEvent
           tt-epc.cod-parameter = "l-incentivado":U
           tt-epc.val-parameter = IF tt-param.l-incentivado THEN "YES":U ELSE "NO":U.

END PROCEDURE.

PROCEDURE piSendEpcParameters:
    {include/i-epc201.i "Parametros"}
END PROCEDURE.

PROCEDURE piCreateInitializePoint:
    DEF INPUT PARAMETER pPoint AS INT NO-UNDO.

    DEF VAR cEvent AS CHAR NO-UNDO.

    IF pPoint = 1 THEN DO:
       ASSIGN cEvent = "doc-fiscal-file":U.

       FOR EACH tt-epc
          WHERE tt-epc.cod-event = cEvent:
           DELETE tt-epc.
       END.
       CREATE tt-epc.
       ASSIGN tt-epc.cod-event     = cEvent
              tt-epc.cod-parameter = "all-doc-fiscal":U
              tt-epc.val-parameter = "*":U.
    END.

    IF pPoint = 2 THEN DO:
       ASSIGN cEvent = "doc-fiscal-reg":U.
       FOR EACH tt-epc
          WHERE tt-epc.cod-event = cEvent:
          DELETE tt-epc.
       END.
       CREATE tt-epc.
       ASSIGN tt-epc.cod-event     = cEvent
              tt-epc.cod-parameter = "rowid-doc-fiscal":U
              tt-epc.val-parameter = STRING(ROWID(doc-fiscal)).
    END.
END PROCEDURE. 

PROCEDURE piSendInitializePoint:
    DEF INPUT PARAMETER pPoint AS INT NO-UNDO.
    IF pPoint = 1 THEN DO:
       {include/i-epc201.i "doc-fiscal-file"}
    END.
    IF pPoint = 2 THEN DO:
       {include/i-epc201.i "doc-fiscal-reg"}
    END.
END PROCEDURE.

PROCEDURE piReadReceivedDataFromEpc:
    DEF INPUT PARAMETER pPoint AS INT NO-UNDO.
    DEF VAR raw-aux-1 AS RAW NO-UNDO.

    IF pPoint = 1 THEN DO:
        FOR EACH tt-doctos-excluidos:
           DELETE tt-doctos-excluidos.
        END.
        FOR EACH tt-epc
           WHERE tt-epc.cod-event     = "doc-fiscal-file":U 
             AND tt-epc.cod-parameter = "raw-doc-fiscal":U:
             RUN btb/btb928za.p (INPUT  tt-epc.val-parameter, 
                                 OUTPUT raw-aux-1).
             CREATE tt-doctos-excluidos.
             RAW-TRANSFER raw-aux-1 to tt-doctos-excluidos.
        END.
    END.

    IF pPoint = 2 THEN DO:
        FOR EACH tt-itens-excluidos:
            DELETE tt-itens-excluidos.
        END.
        FOR EACH tt-epc
           WHERE tt-epc.cod-event     = "doc-fiscal-reg":U 
             AND tt-epc.cod-parameter = "raw-it-doc-fisc":U:
             RUN btb/btb928za.p (INPUT  tt-epc.val-parameter, 
                                 OUTPUT raw-aux-1).
             CREATE tt-itens-excluidos.
             RAW-TRANSFER raw-aux-1 to tt-itens-excluidos.
        END.
    END.

END PROCEDURE.
/** EPC ****************************/    
PROCEDURE piImprimeInf:
    for each res-uf-e2 EXCLUSIVE-LOCK break by res-uf-e2.uf :

        accumulate res-uf-e2.vl-bsubs (total by res-uf-e2.uf)
                   res-uf-e2.vl-icmsub (total by res-uf-e2.uf).

        if  last-of(res-uf-e2.uf) then
            put c-sep at 1  
                c-sep at 16
                c-sep at 24
                res-uf-e2.uf                          at  35
                c-sep at 45
                accum total by res-uf-e2.uf res-uf-e2.vl-bsubs 
                           format ">>>>,>>>,>>>,>>9.99"      at 48
                c-sep
                accum total by res-uf-e2.uf res-uf-e2.vl-icmsub 
                           format ">>>>,>>>,>>>,>>9.99"      at 70
                c-sep
                c-sep at 111
                c-sep at 132 skip.

        if  last(res-uf-e2.uf) then DO:
            /* Inicio -- Projeto Internacional */
            {utp/ut-liter.i "TOTAL" *}
            put c-sep at 1  
                c-sep at 16
                c-sep at 24
                c-sep at 45
                c-sep at 67
                c-sep at 89                                       
                c-sep at 111
                c-sep at 132 skip
                c-sep at 1  
                c-sep at 16
                c-sep at 24
                TRIM(RETURN-VALUE) FORMAT "X(7)"             at 33
                c-sep at 45
                accum total res-uf-e2.vl-bsubs 
                           format ">>>>,>>>,>>>,>>9.99"      at 48
                c-sep
                accum total res-uf-e2.vl-icmsub 
                           format ">>>>,>>>,>>>,>>9.99"      at 70
                c-sep
                c-sep at 111
                c-sep at 132 skip
                c-sep at 1  
                c-sep at 16
                c-sep at 24
                c-sep at 45
                c-sep at 67
                c-sep at 89                                       
                c-sep at 111
                c-sep at 132 skip
                c-sep at 1  
                c-sep at 16
                c-sep at 24
                c-sep at 45
                c-sep at 67
                c-sep at 89                                       
                c-sep at 111
                c-sep at 132 skip.
        END. 

    end.
    assign c-tipo = "                  SA÷DAS"
           c-tit1 = "OPERACOES COM DEBITOS DO IMPOSTO"
           c-tit2 = "OPERACOES SEM DEBITOS DO IMPOSTO"
           c-tit3 = "DEBITADO".

    if  l-separadores then
        disp c-tipo c-tit1 c-tit2 c-tit3 with frame f-sdiag.
    else do:
        hide frame f-cab-2.
        disp c-tipo with frame f-cab-3.
    end.

    find first res-uf-s2 EXCLUSIVE-LOCK NO-ERROR .

    if  not avail res-uf-s2 then DO:
        /* Inicio -- Projeto Internacional */
        {utp/ut-liter.i "TOTAL" *}
        put c-sep at 1  
            c-sep at 16
            c-sep at 24
            c-sep at 45
            c-sep at 67
            c-sep at 89                                       
            c-sep at 111
            c-sep at 132 skip
            c-sep at 1  
            c-sep at 16
            c-sep at 24
            TRIM(RETURN-VALUE) FORMAT "X(7)"         at 33
            c-sep at 45
            0      format ">>>>,>>>,>>>,>>9.99"      at 48
            c-sep
            0      format ">>>>,>>>,>>>,>>9.99"      at 70
            c-sep
            c-sep at 111
            c-sep at 132 skip.
    END. 

    for each res-uf-s2 EXCLUSIVE-LOCK break by res-uf-s2.uf :

        accumulate res-uf-s2.vl-bsubs (total by res-uf-s2.uf)
                   res-uf-s2.vl-icmsub (total by res-uf-s2.uf).   

        if  last-of(res-uf-s2.uf) THEN DO:
            run pi-imprime-termo ( line-counter, 2 ).
            put c-sep at 1  
                c-sep at 16
                c-sep at 24
                res-uf-s2.uf                          at  35
                c-sep at 45
                accum total by res-uf-s2.uf res-uf-s2.vl-bsubs 
                           format ">>>>,>>>,>>>,>>9.99"      at 48
                c-sep
                accum total by res-uf-s2.uf res-uf-s2.vl-icmsub 
                           format ">>>>,>>>,>>>,>>9.99"      at 70
                c-sep 
                c-sep at 111
                c-sep at 132 skip.
        END.

        if  last(res-uf-s2.uf) THEN DO:
            run pi-imprime-termo ( line-counter, 2 ).
            /* Inicio -- Projeto Internacional */
            {utp/ut-liter.i "TOTAL" *}
            put c-sep at 1  
                c-sep at 16
                c-sep at 24
                c-sep at 45
                c-sep at 67
                c-sep at 89                                       
                c-sep at 111
                c-sep at 132 skip
                c-sep at 1  
                c-sep at 16
                c-sep at 24
                TRIM(RETURN-VALUE) FORMAT "X(7)"             at 33
                c-sep at 45
                accum total res-uf-s2.vl-bsubs 
                           format ">>>>,>>>,>>>,>>9.99"      at 48
                c-sep
                accum total res-uf-s2.vl-icmsub 
                           format ">>>>,>>>,>>>,>>9.99"      at 70 
                c-sep
                c-sep at 111
                c-sep at 132 skip.
        END.
    end.

    if  l-separadores then
        assign c-linha-branco = c-sep + fill(" ",22) +
               c-sep + fill(" ",20) + c-sep + fill(" ",21) + c-sep + fill(" ",21) +
               c-sep + fill(" ",21) + c-sep + fill(" ",20) + c-sep
               c-sepa = if c-sep <> "" then c-sep else "-".
    else
        assign c-linha-branco = "".

    do  i-aux = line-counter to page-size:
        put c-linha-branco at 1 format "x(132)" skip.
    end.  
END.

PROCEDURE piTrataSeparadores:
    IF TRIM(c-tipo) = "ENTRADAS" THEN DO:
        ASSIGN c-tit1 = "OPERAÄÂES COM CRêDITO DO IMPOSTO"
               c-tit2 = "OPERAÄÂES SEM CRêDITO DO IMPOSTO"
               c-tit3 = "CREDITADO".

    END.
    ELSE
        IF TRIM(c-tipo) = "SA÷DAS" THEN DO:
            ASSIGN c-tit1 = "OPERAÄÂES COM DêBITO DO IMPOSTO"
                   c-tit2 = "OPERAÄÂES SEM DêBITO DO IMPOSTO"
                   c-tit3 = "DEBITADO".
        END.


    RETURN "OK":U.
END PROCEDURE.
