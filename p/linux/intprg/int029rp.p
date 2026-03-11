/********************************************************************************
** Programa: int029 - Relat¢rio Concilia‡Æo Notas de Entrada Loja
**
** Versao : 12 - 09/02/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versÆo */
{include/i-prgvrs.i int029RP 2.12.06.AVB}
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

define temp-table tt-int_ds_nota_entrada like int_ds_nota_entrada.
define temp-table tt-docum-est like docum-est.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-movto-fim as date
    field dt-movto-ini as date
    field nro-docto-fim    as integer
    field nro-docto-ini    as integer
    field serie-docto-fim  as char
    field serie-docto-ini  as char
    field estado-fim       as char
    field estado-ini       as char
    field i-tipo-nota      as integer
    FIELD l-pendentes      AS LOG.

def temp-table tt-raw-digita
    	field raw-digita	as raw.

/* recebimento de parƒmetros */
def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int029.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padrÆo para vari veis de relat¢rio  */
{include/i-rpvar.i}

/* defini‡Æo de vari veis  */
def var h-acomp    as handle no-undo.
def var i-cont as integer.
def var i-atualiz as integer.
def var i-it-docum as integer.
def var i-it-entrada as integer.
def var i-faltantes as integer no-undo.
def var i-docum as integer no-undo.
def var i-emit as integer no-undo.
def var i-conferida as integer no-undo.
def var i-zero as integer no-undo.
def var c-cod-estabel like estabelec.cod-estabel no-undo.
def var c-sistema-origem   as char no-undo.
def var c-sistema-destino  as char no-undo.

FUNCTION fnSistema RETURNS CHARACTER
  ( p-cnpj as char,
    p-dt-referencia as date ) :

    if can-find(first estabelec no-lock where estabelec.cgc = p-cnpj) then do:
        for each estabelec no-lock where estabelec.cgc = p-cnpj,
            first cst_estabelec no-lock WHERE
                  cst_estabelec.cod_estabel = estabelec.cod-estabel AND
                  cst_estabelec.dt_fim_operacao >= p-dt-referencia:
            if cst_estabelec.dt_inicio_oper <= p-dt-referencia 
            then 
                return "PROCFIT".
            else 
                return "OBLAK".
        end.
        RETURN "OBLAK".
    end.
    else RETURN "FORNECEDOR".

END FUNCTION.

/* defini‡Æo de frames do relat¢rio */

/* include com a defini‡Æo da frame de cabe‡alho e rodap‚ */
{include/i-rpcab.i &STREAM="str-rp"}
/* bloco principal do programa */

FIND FIRST tt-param NO-LOCK NO-ERROR. 
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i &stream = "stream str-rp"}
END.

assign c-programa     = "int029"
       c-versao       = "2.13"
       c-revisao      = ".06.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "Posi‡Æo Notas Fiscais do Recebimento".

IF tt-param.arquivo <> "" THEN DO:
    view stream str-rp frame f-cabec.
    view stream str-rp frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin ct-format sc-format) no-lock: end.
for first mgadm.empresa fields (razao-social) no-lock where
     empresa.ep-codigo = param-global.empresa-prin: end.
assign c-empresa = mgadm.empresa.razao-social.

if tt-param.dt-movto-ini = ? then
    assign tt-param.dt-movto-ini = today - 7
           tt-param.dt-movto-fim = today.

if tt-param.cod-estabel-fim  = "" then
    assign tt-param.cod-estabel-ini  = ""
           tt-param.cod-estabel-fim  = "ZZZZZ".

if tt-param.serie-docto-fim  = "" then
    assign tt-param.serie-docto-ini  = ""
           tt-param.serie-docto-fim  = "ZZZZZ".

if tt-param.nro-docto-fim  = 0 then
    assign tt-param.nro-docto-ini  = 0
           tt-param.nro-docto-fim  = 999999999.

if tt-param.cod-emitente-fim  = 0 then
    assign tt-param.cod-emitente-ini  = 0
           tt-param.cod-emitente-fim  = 999999999.

i-cont = 0.
i-atualiz = 0.
i-it-docum = 0.
i-it-entrada = 0.
i-faltantes = 0.
i-docum = 0.
i-emit = 0.
i-conferida = 0.
i-zero = 0.
for each estabelec no-lock where 
    estabelec.estado >= tt-param.estado-ini and
    estabelec.estado <= tt-param.estado-fim and
    estabelec.cod-estabel >= tt-param.cod-estabel-ini and 
    estabelec.cod-estabel <= tt-param.cod-estabel-fim:
    if estabelec.cod-estabel = "500" or
       estabelec.cod-estabel = "604" then next.
    run pi-leitura.
end.
put stream str-rp skip(2).
display stream str-rp
        i-cont      LABEL "Notas Integracao"
        i-conferida LABEL "Conferidas"
        i-docum     LABEL "Importadas RE1001"
        i-atualiz   LABEL "Atualizadas Estoque"
        i-faltantes       LABEL "Faltantes"
        i-emit      LABEL "Fornecedor NAO Cadastrado"
        i-zero      LABEL "Item Zero"
    WITH  STREAM-IO down width 300.

put stream str-rp skip(2)
    "Notas Pendentes de Importa‡Æo:"
    skip(2).

for each tt-int_ds_nota_entrada where 
    tt-int_ds_nota_entrada.situacao = 2:
    for first emitente no-lock where emitente.cgc = tt-int_ds_nota_entrada.nen_cnpj_origem_s: end.

    c-sistema-destino = "".
    c-cod-estabel = "".
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = tt-int_ds_nota_entrada.nen_cnpj_destino_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= tt-int_ds_nota_entrada.nen_dataemissao_d:
        c-cod-estabel = estabelec.cod-estabel.

        if tt-int_ds_nota_entrada.nen_datamovimentacao_d <> ? then 
            if cst_estabelec.dt_inicio_oper <= tt-int_ds_nota_entrada.nen_datamovimentacao_d 
            then 
                c-sistema-destino = "PROCFIT".
            else 
                c-sistema-destino = "OBLAK".
        else
            if tt-int_ds_nota_entrada.nen_dataemissao_d <> ? then 
                if cst_estabelec.dt_inicio_oper <= tt-int_ds_nota_entrada.nen_dataemissao_d
                then 
                    c-sistema-destino = "PROCFIT".
                else 
                    c-sistema-destino = "OBLAK".
        leave.
    end.

    display stream str-rp
        fnSistema(tt-int_ds_nota_entrada.nen_cnpj_origem_s,tt-int_ds_nota_entrada.nen_dataemissao_d) @ c-sistema-origem column-label "Origem"
        c-sistema-destino column-label "Destino"
        tt-int_ds_nota_entrada.nen_cnpj_origem_s
        emitente.nome-abrev when avail emitente
        tt-int_ds_nota_entrada.nen_cnpj_destino_s
        c-cod-estabel 
        tt-int_ds_nota_entrada.nen_notafiscal_n
        tt-int_ds_nota_entrada.nen_serie_s
        tt-int_ds_nota_entrada.nen_cfop_n
        tt-int_ds_nota_entrada.nen_dataemissao_d
        tt-int_ds_nota_entrada.nen_datamovimentacao_d
        tt-int_ds_nota_entrada.situacao
        tt-int_ds_nota_entrada.nen_conferida_n
        tt-int_ds_nota_entrada.tipo_nota
        tt-int_ds_nota_entrada.nen_observacao_s format "X(55)"
        with width 550 stream-io down.
end.

put stream str-rp skip(2)
    "Notas Pendentes em INT520:"
    skip(2).

for each tt-int_ds_nota_entrada where 
    tt-int_ds_nota_entrada.situacao = 5:

    for first emitente no-lock where emitente.cgc = tt-int_ds_nota_entrada.nen_cnpj_origem_s: end.
    c-cod-estabel = "".
    c-sistema-destino = "".
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = tt-int_ds_nota_entrada.nen_cnpj_destino_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= tt-int_ds_nota_entrada.nen_dataemissao_d:
        c-cod-estabel = estabelec.cod-estabel.

        if tt-int_ds_nota_entrada.nen_datamovimentacao_d <> ? then 
            if cst_estabelec.dt_inicio_oper <= tt-int_ds_nota_entrada.nen_datamovimentacao_d 
            then 
                c-sistema-destino = "PROCFIT".
            else 
                c-sistema-destino = "OBLAK".
        else
            if tt-int_ds_nota_entrada.nen_dataemissao_d <> ? then 
                if cst_estabelec.dt_inicio_oper <= tt-int_ds_nota_entrada.nen_dataemissao_d
                then 
                    c-sistema-destino = "PROCFIT".
                else 
                    c-sistema-destino = "OBLAK".
        leave.
    end.

    display stream str-rp
        fnSistema(tt-int_ds_nota_entrada.nen_cnpj_origem_s,tt-int_ds_nota_entrada.nen_dataemissao_d) @ c-sistema-origem column-label "Origem"
        c-sistema-destino column-label "Destino"
        tt-int_ds_nota_entrada.nen_cnpj_origem_s
        emitente.nome-abrev when avail emitente
        tt-int_ds_nota_entrada.nen_cnpj_destino_s
        c-cod-estabel 
        tt-int_ds_nota_entrada.nen_notafiscal_n
        tt-int_ds_nota_entrada.nen_serie_s
        tt-int_ds_nota_entrada.nen_cfop_n
        tt-int_ds_nota_entrada.nen_dataemissao_d
        tt-int_ds_nota_entrada.nen_datamovimentacao_d
        tt-int_ds_nota_entrada.situacao
        tt-int_ds_nota_entrada.nen_conferida_n
        tt-int_ds_nota_entrada.tipo_nota
        tt-int_ds_nota_entrada.nen_observacao_s format "X(55)"
        with width 550 stream-io down.
end.

put stream str-rp skip(2)
    "Notas Pendentes em RE1001:"
    skip(2).

for each tt-docum-est no-lock
    by tt-docum-est.cod-estabel
      by tt-docum-est.cod-emitente
        by tt-docum-est.serie-docto
          by tt-docum-est.nro-docto:

    c-sistema-destino = "".
    for first emitente no-lock where emitente.cod-emitente = tt-docum-est.cod-emitente: end.
    for each estabelec no-lock where 
        estabelec.cod-estabel = tt-docum-est.cod-estabel: 
        for each cst_estabelec no-lock WHERE
                 cst_estabelec.cod_estabel = estabelec.cod-estabel:
            if cst_estabelec.dt_inicio_oper <= tt-docum-est.dt-trans
            then 
                c-sistema-destino = "PROCFIT".
            else 
                c-sistema-destino = "OBLAK".
        end.
    end.
    display STREAM str-RP
            fnSistema(emitente.cgc,tt-docum-est.dt-emissao) @ c-sistema-origem column-label "Origem"
            c-sistema-destino column-label "Destino"
            tt-docum-est.cod-estabel 
            tt-docum-est.serie-docto
            tt-docum-est.nro-docto
            tt-docum-est.cod-emitente
            emitente.nome-abrev when avail emitente
            tt-docum-est.nat-operacao
            tt-docum-est.dt-atualiza
            tt-docum-est.CE-atual
            tt-docum-est.cr-atual
            tt-docum-est.ap-atual
            tt-docum-est.of-atual
        with width 550 stream-io.

end.

/* fechamento do output do relat¢rio  */
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpclo.i &STREAM="stream str-rp"}
END.
run pi-finalizar in h-acomp.
empty temp-table tt-int_ds_nota_entrada.
empty temp-table tt-docum-est.

return "OK":U.

procedure pi-leitura:

    /******* LE NOTA E GERA TEMP TABLES  *************/
    for-nota:
    for each int_ds_nota_entrada no-lock where
        int_ds_nota_entrada.situacao >= 0 and
        int_ds_nota_entrada.nen_conferida_n >= 0 and 
        int_ds_nota_entrada.nen_datamovimentacao_d >= tt-param.dt-movto-ini and
        int_ds_nota_entrada.nen_datamovimentacao_d <= tt-param.dt-movto-fim and
        int_ds_nota_entrada.nen_serie_s >= tt-param.serie-docto-ini and
        int_ds_nota_entrada.nen_serie_s <= tt-param.serie-docto-fim and
        int_ds_nota_entrada.nen_notafiscal_n >= tt-param.nro-docto-ini and
        int_ds_nota_entrada.nen_notafiscal_n <= tt-param.nro-docto-fim and
        int_ds_nota_entrada.nen_cnpj_destino_s = estabelec.cgc and
        /*int_ds_nota_entrada.tipo-movto = 1 and*/
        int_ds_nota_entrada.tipo_nota = if i-tipo-nota <> 5 
                                        then i-tipo-nota 
                                        else int_ds_nota_entrada.tipo_nota
        on stop undo, leave:

        run pi-acompanhar in h-acomp (input "Nota: " + string(int_ds_nota_entrada.nen_notafiscal_n) + "/" + int_ds_nota_entrada.nen_serie_s).

        if int_ds_nota_entrada.nen_cfop_n = 6949 or 
           int_ds_nota_entrada.nen_cfop_n = 5949 then next.

        /* notas recusadas */
        if int_ds_nota_entrada.situacao = 9 then next.

        IF  tt-param.l-pendentes          = YES AND
            int_ds_nota_entrada.situacao <> 1 /* Pendente */
        THEN DO:
            IF  int_ds_nota_entrada.situacao <> 2 AND
                int_ds_nota_entrada.situacao <> 5
            THEN
                NEXT for-nota.
            ELSE
                IF  int_ds_nota_entrada.nen_conferida_n <> 1
                THEN
                    NEXT for-nota.
        END.

        for first cst_estabelec no-lock WHERE 
                  cst_estabelec.cod_estabel = estabelec.cod-estabel: 
        end.
        if cst_estabelec.dt_fim_operacao < int_ds_nota_entrada.nen_datamovimentacao_d then next.

        for first tt-int_ds_nota_entrada where
            tt-int_ds_nota_entrada.nen_cnpj_origem_s = int_ds_nota_entrada.nen_cnpj_origem_s and
            tt-int_ds_nota_entrada.nen_serie_s = int_ds_nota_entrada.nen_serie_s and
            tt-int_ds_nota_entrada.nen_notafiscal_n = int_ds_nota_entrada.nen_notafiscal_n: end.
        if not avail tt-int_ds_nota_entrada then do:
            create tt-int_ds_nota_entrada.
            buffer-copy int_ds_nota_entrada to tt-int_ds_nota_entrada.
            i-cont = i-cont + 1.
        end.
    
        if int_ds_nota_entrada.situacao >= 2 and
           int_ds_nota_entrada.nen_conferida_n >= 1 and
           int_ds_nota_entrada.nen_datamovimentacao_d <> ? then do:
            i-conferida = i-conferida + 1.
            assign tt-int_ds_nota_entrada.nen_observacao = "Conferida".
        end.
        for first emitente NO-LOCK WHERE emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s: end.
        if not avail emitente then do:
            assign i-emit = i-emit + 1.
            assign tt-int_ds_nota_entrada.nen_observacao = "Fornecedor nao cadastrado".
        end.
        for first docum-est where 
            docum-est.serie-docto = trim(int_ds_nota_entrada.nen_serie_s) and
            docum-est.nro-docto = trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>9999999")) and
            docum-est.cod-emitente = emitente.cod-emitente:
            i-docum = i-docum + 1.
            assign tt-int_ds_nota_entrada.nen_observacao = "Pendente RE1001".
    
            if docum-est.dt-atualiza <> ? and
              (docum-est.CE-atual or
               docum-est.cr-atual or
               docum-est.ap-atual or
               docum-est.of-atual) then do:
                i-atualiz = i-atualiz + 1.
                assign tt-int_ds_nota_entrada.nen_observacao = "Atualizada".
            end.
            else do:
                for first tt-docum-est of docum-est: end.
                if not avail tt-docum-est then do:
                    create tt-docum-est.
                    buffer-copy docum-est to tt-docum-est.
                end.
            end.
            /*
            i-it-docum = 0.
            for each item-doc-est no-lock of docum-est:
                assign i-it-docum = i-it-docum + item-doc-est.quantidade.
            end.
            i-it-entrada = 0.
            for each int_ds_nota_entrada_produto no-lock of int_ds_nota_entrada:
                assign i-it-entrada = i-it-entrada + int_ds_nota_entrada_produt.nep-quantidade-n.
            end.
            if i-it-docum <> i-it-entrada then do:
                /*
                display docum-est.cod-estabel 
                        docum-est.serie-docto
                        docum-est.nro-docto
                        docum-est.cod-emitente
                        docum-est.nat-operacao
                        i-it-docum
                        i-it-entrada
                    with width 300 stream-io.
                    */
            end.
            */
        end. /* docum-est */
        if not avail docum-est and int_ds_nota_entrada.situacao >= 2 AND
           int_ds_nota_entrada.nen_conferida_n = 1 AND    
           int_ds_nota_entrada.nen_datamovimentacao_d <> ? then do:
            i-faltantes = i-faltantes + 1.
            if int_ds_nota_entrada.situacao = 2 then 
                assign tt-int_ds_nota_entrada.nen_observacao = "Pendente Importa‡Æo".
    
            if int_ds_nota_entrada.situacao = 5 then 
                assign tt-int_ds_nota_entrada.nen_observacao = "Pendente INT520".
        end.
        for first int_ds_nota_entrada_produt no-lock of int_ds_nota_entrada where
            int_ds_nota_entrada_produt.nep_produto_n = 0:
            assign i-zero = i-zero + 1.
        end.
    end.
end. /* pi-leitura */

