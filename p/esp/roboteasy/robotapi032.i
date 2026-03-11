
/** TT INPUT **/
DEF TEMP-TABLE tt-cria-pedido NO-UNDO
    FIELD cod_prog_dtsul           LIKE ped_exec.cod_prog_dtsul                 SERIALIZE-NAME "codPrograma"
    FIELD dat_criac_ped_exec       LIKE ped_exec.dat_criac_ped_exec             SERIALIZE-NAME "dataPedido"
    FIELD hra_criac_ped_exec       LIKE ped_exec.hra_criac_ped_exec             SERIALIZE-NAME "horaPedido"
    FIELD cod_servid_exec          LIKE ped_exec.cod_servid_exec                SERIALIZE-NAME "servidor"
    FIELD nom_prog_ext             LIKE ped_exec.nom_prog_ext                   SERIALIZE-NAME "programaExterno"
    FIELD cdn_estil_dwb            LIKE ped_exec.cdn_estil_dwb                  SERIALIZE-NAME "estiloDwb"
    FIELD cod_dwb_output           LIKE ped_exec_param.cod_dwb_output           SERIALIZE-NAME "destino"
    FIELD nom_dwb_printer          LIKE ped_exec_param.nom_dwb_printer          SERIALIZE-NAME "nomeArquivo"
    FIELD log_dwb_print_parameters LIKE ped_exec_param.log_dwb_print_parameters SERIALIZE-NAME "imprimeParam"
    FIELD cod_empresa              LIKE ped_exec_param.cod_empresa              SERIALIZE-NAME "empresa"
    FIELD cod_estab                LIKE ped_exec_param.cod_estab                SERIALIZE-NAME "estabelecimento"
    FIELD cod_usuario              LIKE ped_exec.cod_usuario                    SERIALIZE-NAME "codigoUsuario"
    FIELD cod_unid_negoc           LIKE ped_exec_param.cod_unid_negoc           SERIALIZE-NAME "unidNegocio"
    FIELD cod_funcao_negoc_empres  LIKE ped_exec_param.cod_funcao_negoc_empres  SERIALIZE-NAME "funcaoNegocEmpresa"
    FIELD cod_plano_ccusto         LIKE ped_exec_param.cod_plano_ccusto         SERIALIZE-NAME "planoCusto"
    FIELD cod_ccusto               LIKE ped_exec_param.cod_ccusto               SERIALIZE-NAME "centroCusto"
    FIELD cod_agrpdor              LIKE ped_exec.cod_agrpdor                    SERIALIZE-NAME "codigoAgrupador"
    .

DEFINE TEMP-TABLE tt-param-ce0403 NO-UNDO
    FIELD destino           AS INTEGER FORMAT "99"      SERIALIZE-NAME "destino"          
    FIELD arquivo           AS CHAR    FORMAT "x(90)"   SERIALIZE-NAME "arquivo"          
    FIELD usuario           AS CHAR    FORMAT "x(90)"   SERIALIZE-NAME "usuario"          
    FIELD data-exec         AS DATE                     SERIALIZE-NAME "data-exec"        
    FIELD hora-exec         AS INTEGER                  SERIALIZE-NAME "hora-exec"        
    FIELD dt-ini            AS DATE                     SERIALIZE-NAME "dt-ini"           
    FIELD dt-fim            AS DATE                     SERIALIZE-NAME "dt-fim"           
    FIELD c-conta-ini       AS CHAR    FORMAT "x(20)"   SERIALIZE-NAME "c-conta-ini"      
    FIELD c-conta-fim       AS CHAR    FORMAT "x(20)"   SERIALIZE-NAME "c-conta-fim"      
    FIELD c-ccusto-ini      AS CHAR    FORMAT "x(20)"   SERIALIZE-NAME "c-ccusto-ini"     
    FIELD c-ccusto-fim      AS CHAR    FORMAT "x(20)"   SERIALIZE-NAME "c-ccusto-fim"     
    FIELD i-ge-ini          AS INTEGER                  SERIALIZE-NAME "i-ge-ini"         
    FIELD i-ge-fim          AS INTEGER                  SERIALIZE-NAME "i-ge-fim"         
    FIELD c-estab-ini       AS CHAR                     SERIALIZE-NAME "c-estab-ini"      
    FIELD c-estab-fim       AS CHAR                     SERIALIZE-NAME "c-estab-fim"      
    FIELD c-unid-neg-ini    AS CHAR                     SERIALIZE-NAME "c-unid-neg-ini"   
    FIELD c-unid-neg-fim    AS CHAR                     SERIALIZE-NAME "c-unid-neg-fim"   
    FIELD i-nr-page         AS INTEGER                  SERIALIZE-NAME "i-nr-page"        
    FIELD i-abertura        AS INTEGER                  SERIALIZE-NAME "i-abertura"       
    FIELD i-fechamento      AS INTEGER                  SERIALIZE-NAME "i-fechamento"     
    FIELD i-tipo-custo      AS INTEGER                  SERIALIZE-NAME "i-tipo-custo"     
    FIELD i-impr-cabecalho  AS INTEGER                  SERIALIZE-NAME "i-impr-cabecalho" 
    FIELD c-tipo-custo      AS CHAR                     SERIALIZE-NAME "c-tipo-custo"     
    FIELD i-cenario         AS INTEGER                  SERIALIZE-NAME "i-cenario"        
    FIELD c-cenario         AS CHAR                     SERIALIZE-NAME "c-cenario"        
    FIELD c-destino         AS CHAR                     SERIALIZE-NAME "c-destino"        
    FIELD l-imp-param       AS LOGICAL                  SERIALIZE-NAME "l-imp-param"      
    FIELD nao-formata-excel AS LOGICAL                  SERIALIZE-NAME "nao-formata-excel".

DEFINE TEMP-TABLE tt-param-ft0708
    field destino                 as integer
    field arquivo                 as char
    field usuario                 as char format "x(12)"
    field data-exec               as date
    field hora-exec               as integer
    field classifica              as integer
    field desc-classifica         as char format "x(40)"
    field c-estabel-ini           as char
    field c-estabel-fim           as char
    field da-emissao-ini          as date
    field da-emissao-fim          as date
    field c-conta-ini             as char
    field c-conta-fim             as char
    field c-cc-conta-ini          as char
    field c-cc-conta-fim          as char
    field c-pais-ini              as char
    field c-pais-fim              as char
    field c-uf-ini                as char
    field c-uf-fim                as char
    field l-vcto-impostos         as logical
    field da-ipi                  as date
    field da-icms                 as date
    field da-iss                  as date
    field da-irrf                 as date
    field da-pis                  as date
    field da-cofins               as date
    field da-icms-subs            as date
    field da-inss-ret             as date
    field da-fet                  as date
    field rs-tipo                 as integer
    field rs-moeda                as integer
    field rs-vencimento           as integer
    field rs-cotacao              as integer
    field l-notas-fisc            as logical
    field l-proc-exp              as logical
    FIELD l-processa-ifrs         AS LOGICAL
    field desc-tipo               as char format "x(40)"
    FIELD rs-execucao             AS INTEGER
    field l-imprime-centro-custo  as logical
    FIELD l-valida-conta          AS LOGICAL.

DEFINE TEMP-TABLE tt-param-ft0709
    FIELD destino          AS INTEGER
    FIELD arquivo          AS CHAR
    FIELD usuario          AS CHAR FORMAT "x(12)"
    FIELD data-exec        AS DATE
    FIELD hora-exec        AS INTEGER
    FIELD classifica       AS INTEGER
    FIELD desc-classifica  AS CHAR FORMAT "x(40)"
    FIELD c-estabel-ini    AS CHAR
    FIELD c-estabel-fim    AS CHAR
    FIELD da-emissao-ini   AS DATE
    FIELD da-emissao-fim   AS DATE
    FIELD c-conta-ini      AS CHAR FORMAT "x(20)"
    FIELD c-conta-fim      AS CHAR FORMAT "x(20)"
    FIELD c-cc-conta-ini   AS CHAR FORMAT "x(20)"
    FIELD c-cc-conta-fim   AS CHAR FORMAT "x(20)"
	FIELD c-unid-negoc-ini AS CHAR FORMAT "x(03)"
	FIELD c-unid-negoc-fim AS CHAR FORMAT "x(03)"
    FIELD i-termo-abe      AS INTEGER
    FIELD i-termo-enc      AS INTEGER
    FIELD i-pag-ini        AS INTEGER
    FIELD elimina-sumario  AS LOGICAL
    FIELD elimina-fat-ant  AS LOGICAL
    FIELD sumariar         AS LOGICAL
    FIELD quebra-pagina    AS LOGICAL
    FIELD l-diario-normal  AS LOGICAL
    FIELD l-diario-ifrs    AS LOGICAL
    FIELD i-nome-pag       AS INT.

define temp-table tt-param-of0410 no-undo
    FIELD destino          AS INTEGER
    FIELD arquivo          AS CHAR FORMAT "x(35)":U
    FIELD usuario          AS CHAR FORMAT "x(12)":U
    FIELD data-exec        AS DATE
    FIELD hora-exec        AS INTEGER
    FIELD classifica       AS INTEGER
    FIELD desc-classifica  AS CHAR FORMAT "x(40)":U
    FIELD modelo           AS CHAR FORMAT "x(35)":U
    FIELD cEstab           AS CHAR FORMAT "x(05)":U
    FIELD cDtIni           AS DATE
    FIELD cDtFim           AS DATE
    FIELD cEstadoIni       AS CHARACTER FORMAT "x(02)":U
    FIELD cEstadoFim       AS CHARACTER FORMAT "x(02)":U
    FIELD cEmitIni         AS INTEGER FORMAT ">>>>>>>>9"
    FIELD cEmitFim         AS INTEGER FORMAT ">>>>>>>>9"
    FIELD cDocIni          AS CHARACTER 
    FIELD cDocFim          AS CHARACTER
    FIELD cModIni          AS CHARACTER
    FIELD cModFim          AS CHARACTER.

define temp-table tt-param-of0520 no-undo
	field destino           as integer
	field arquivo           as char 
	field usuario           as char 
	field data-exec         as date
	field hora-exec         as integer
	field cod-estabel-ini   as char
	field cod-estabel-fim   as char
	field dt-docto-ini      as date
	field dt-docto-fim      as date
	field resumo            as log
	field resumo-mes        as log
	field tot-icms          as log
	field imp-for           as log
	field periodo-ant       as log
	field imp-ins           as log
	field conta-contabil    as log
	field at-perm           as log
	field separadores       as log
	field previa            as char
	field documentos        as char
	field da-icms-ini       as date
	field da-icms-fim       as date
	field incentivado       as log
	field relat             as char
	field eliqui            as log
	field c-nomest          like estabelec.nome
	field c-estado          like estabelec.estado
	field c-cgc             like estabelec.cgc
	field c-insestad        as char
	field c-cgc-1           as char
	field c-fornecedor      as char
	field c-ins-est         as char
	field c-titulo          as char
	field imp-cnpj          as log
    field considera-icms-st as logical
	field imp-cab           as char
	field l-cfop-serv       as log.

define temp-table tt-param-of0620 no-undo
    field destino        as integer
    field arquivo        as char
    field usuario        as char format "x(12)"
    field data-exec      as date
    field hora-exec      as integer
    field c-est-ini      LIKE estabelec.cod-estabel
    field c-est-fim      LIKE estabelec.cod-estabel
    field da-est-ini     as date
    field da-est-fim     as date
    field da-icm-ini     as date
    field da-icm-fim     as date
    field c-importacao   as char
    field l-resumo       as logical
    field l-resumo-mes   as logical
    field l-tot-icm      as logical
    field l-sumario      as logical
    field l-periodo-ant  as logical
    field l-conta-contab as logical
    field l-separadores  as logical
    field l-incentivado  as logical
    field l-eliqui       as logical
    field l-linha-st     as logical
    field i-documentos   as integer
    field i-relat        as integer
    field i-previa       as integer
    FIELD l-icms-subst   AS logical
    field c-destino      as char format "x(40)"
    field i-imp-cab      as integer
    field l-cfop-serv    as logical
    field l-subs         as logical 
    field de-aliq-subs-trib-ant   as decimal decimals 2 extent 4.

define temp-table tt-param-of0770  no-undo
    field destino            as integer
    field arquivo            as char format "x(35)":U
    field usuario            as char format "x(12)":U
    field data-exec          as date
    field hora-exec          as integer
    FIELD dt-periodo-ini     AS DATE FORMAT "99/99/9999"
    FIELD dt-periodo-fim     AS DATE FORMAT "99/99/9999"
&IF "{&mguni_version}" >= "2.071" &THEN
    FIELD cod-estabel        AS CHAR format "x(05)"
&ELSE                       
    FIELD cod-estabel        AS CHAR FORMAT "x(03)"
&ENDIF                      
    FIELD rs-modo            AS INTEGER
    FIELD rs-relatorio       AS INTEGER.

DEFINE TEMP-TABLE tt-param-re0530 NO-UNDO
    FIELD destino                AS INTEGER
    FIELD arquivo                AS CHARACTER FORMAT "x(35)":U
    FIELD usuario                AS CHARACTER FORMAT "x(12)":U
    FIELD data-exec              AS DATE
    FIELD hora-exec              AS INTEGER
    FIELD cod-emitente-ini       AS INTEGER
    FIELD cod-emitente-fim       AS INTEGER
    FIELD dt-trans-ini           AS DATE
    FIELD dt-trans-fim           AS DATE
    FIELD dt-emiss-ini           AS DATE
    FIELD dt-emiss-fim           AS DATE
    FIELD cod-estab-ini          AS CHARACTER FORMAT "X(5)":U
    FIELD cod-estab-fim          AS CHARACTER FORMAT "X(5)":U
    FIELD nro-docto-ini          AS CHARACTER FORMAT "X(20)":U
    FIELD nro-docto-fim          AS CHARACTER FORMAT "X(20)":U
    FIELD serie-docto-ini        AS CHARACTER FORMAT "X(5)":U
    FIELD serie-docto-fim        AS CHARACTER FORMAT "X(5)":U
    FIELD nat-operacao-ini       AS CHARACTER FORMAT "X(6)":U
    FIELD nat-operacao-fim       AS CHARACTER FORMAT "X(6)":U
    FIELD imp-param              AS LOGICAL
    FIELD tg-doc-pendente        AS LOGICAL
    FIELD tg-doc-atualizado      AS LOGICAL.

DEF TEMP-TABLE tt-campos
    FIELD campo AS CHARACTER SERIALIZE-NAME "campo"
    FIELD tipo  AS CHARACTER SERIALIZE-NAME "tipo"
    FIELD valor AS CHARACTER SERIALIZE-NAME "valor".
    
DEF TEMP-TABLE tt-consulta-pedido NO-UNDO
    FIELD num-ped-exec LIKE ped_exec.num_ped_exec SERIALIZE-NAME "numPedido".

DEF TEMP-TABLE tt-move-arquivo NO-UNDO
    FIELD num-ped-exec LIKE ped_exec.num_ped_exec SERIALIZE-NAME "numPedido"
    FIELD origem         AS CHAR                  SERIALIZE-NAME "arquivoOrigem"
    FIELD destino        AS CHAR                  SERIALIZE-NAME "arquivoDestino".

/** TT OUTPUT **/
DEFINE TEMP-TABLE tt-resultado-criacao NO-UNDO
    FIELD cod-status   AS INTE
    FIELD desc-retorno AS CHAR
    FIELD num-pedido   AS INTE
    FIELD situacao     AS CHAR.

DEFINE TEMP-TABLE tt-resultado-consulta NO-UNDO
    FIELD cod-status             AS INTE
    FIELD desc-retorno           AS CHAR
    FIELD cod_usuario          LIKE ped_exec.cod_usuario
    FIELD cod_prog_dtsul       LIKE ped_exec.cod_prog_dtsul
    FIELD dat_criac_ped_exec   LIKE ped_exec.dat_criac_ped_exec
    FIELD hra_criac_ped_exec   LIKE ped_exec.hra_criac_ped_exec
    FIELD dat_exec_ped_exec    LIKE ped_exec.dat_exec_ped_exec
    FIELD hra_exec_ped_exec    LIKE ped_exec.hra_exec_ped_exec
    FIELD situacao               AS CHAR
    FIELD motivo-situacao        AS CHAR
    FIELD descricao-erro       LIKE ped_exec.des_text_erro
    FIELD num_ped_exec         LIKE ped_exec.num_ped_exec
    FIELD cod_servid_exec      LIKE ped_exec.cod_servid_exec
    FIELD nom_prog_ext         LIKE ped_exec.nom_prog_ext
    FIELD diretorio              AS CHARACTER.

DEFINE TEMP-TABLE tt-resultado-arquivo NO-UNDO
    FIELD cod-status     AS INTE
    FIELD desc-retorno   AS CHAR
    FIELD num-ped-exec LIKE ped_exec.num_ped_exec
    FIELD origem         AS CHAR
    FIELD destino        AS CHAR.
