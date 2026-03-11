/********************************************************************************
**
**  Programa: int092rp.p - API - Faturamento
**
********************************************************************************/                                                                

/* include de controle de versÆo */
{include/i-prgvrs.i INT092API 1.00.00.000}  /*** 010000 ***/

{utp/ut-glob.i}
{cdp/cdcfgdis.i}


def new global shared var c-seg-usuario as char no-undo.
DEF new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.


FUNCTION fnDeParaCodEsp RETURNS CHAR (INPUT p-cond-pagto AS CHAR):
   
    FIND FIRST esp-cond-pagto NO-LOCK
         WHERE esp-cond-pagto.cond-pagto = p-cond-pagto NO-ERROR.
         
         IF AVAIL esp-cond-pagto THEN DO:
         
         RETURN esp-cond-pagto.especie.      
         END.
    

    RETURN "NOK".
END FUNCTION.

FUNCTION fnDeParaCodPortador RETURN INT (INPUT p-cond-pagto AS CHAR):
    
    FIND FIRST esp-cond-pagto NO-LOCK
         WHERE esp-cond-pagto.cond-pagto = p-cond-pagto NO-ERROR.
         
         IF AVAIL esp-cond-pagto THEN DO:
         
         RETURN int(esp-cond-pagto.portador).      
         END.
    

    RETURN 0.
END FUNCTION.

DEFINE TEMP-TABLE tt-bo-erro NO-UNDO
    FIELD i-sequen     AS INT 
    FIELD cd-erro      AS INT
    FIELD mensagem     AS CHAR      FORMAT "x(255)"
    FIELD parametros   AS CHAR      FORMAT "x(255)" INIT ""
    FIELD errortype    AS CHAR      FORMAT "x(20)"
    FIELD errorhelp    AS CHAR      FORMAT "x(20)"
    FIELD errorsubtype AS CHARACTER.

DEFINE TEMP-TABLE tt-cliente NO-UNDO
    FIELD CNPJ          AS CHAR
    FIELD nome          AS CHAR
    FIELD natureza      AS INT // 1 - Fisica ** 2 - Juridica
    FIELD nome-abrev    AS CHAR
    FIELD ins-estadual  AS CHAR
    FIELD cep           AS CHAR 
    FIELD endereco      AS CHAR
    FIELD numero        AS CHAR
    FIELD complemento   AS CHAR
    FIELD bairro        AS CHAR
    FIELD cidade        AS CHAR
    FIELD cod-ibge      AS CHAR
    FIELD estado        AS CHAR
    FIELD pais          AS CHAR
    FIELD telefone      AS CHAR
    FIELD email         AS CHAR.


DEFINE TEMP-TABLE tt-pedido NO-UNDO
    FIELD pedcodigo         AS DEC
    FIELD DtEmissao         AS DATE
    FIELD DtEntrega         AS DATE
    FIELD cnpj_estab        AS CHAR 
    FIELD cnpj_emitente     AS CHAR
    FIELD valorTotal        AS DEC
    FIELD desconto          AS DEC
    FIELD frete             AS DEC
    FIELD observacao        AS CHAR
    FIELD tipopedido        AS INT
    FIELD cnpj_transp       AS CHAR
    FIELD comissao              AS DEC
    FIELD cnpj-representante    AS CHAR .

DEFINE TEMP-TABLE tt-pedido-item NO-UNDO
    FIELD cod-item          AS CHAR
    FIELD quantidade        AS DEC
    FIELD valor-unit        AS DEC
    FIELD desconto          AS DEC
    FIELD valor-liq         AS DEC
    FIELD preco-bruto       AS DEC
    FIELD valor-total       AS DEC
    FIELD lote              AS CHAR
    FIELD dt-validade       AS DATE
    FIELD observacao        AS CHAR.

DEFINE TEMP-TABLE tt-cond-pagto-esp NO-UNDO
    FIELD cond-pagto    AS CHAR
    FIELD dt-vencto     AS DATE
    FIELD vl-parcela    AS DEC
    FIELD parcela       AS DEC
    FIELD nsu           AS CHAR
    FIELD autorizacao   AS CHAR
    FIELD adquirente    AS CHAR
    FIELD origem-pagto  AS CHAR
    FIELD CNPJ_CONVENIO AS CHAR.

DEFINE TEMP-TABLE tt-nota-fiscal NO-UNDO
    FIELD l-gerada      AS LOGICAL
    FIELD desc-erro     AS CHAR
    FIELD cod-estabel   LIKE nota-fiscal.cod-estabel
    FIELD serie         LIKE nota-fiscal.serie
    FIELD nr-nota-fis   LIKE nota-fiscal.nr-nota-fis
    FIELD chave-acesso  LIKE nota-fiscal.cod-chave-aces-nf-eletro.


DEF INPUT PARAMETER TABLE FOR tt-cliente.
DEF INPUT PARAMETER TABLE FOR tt-pedido.
DEF INPUT PARAMETER TABLE FOR tt-pedido-item.
DEF INPUT PARAMETER TABLE FOR tt-cond-pagto-esp.
DEF OUTPUT PARAMETER TABLE FOR tt-nota-fiscal.


DEF VAR h-acomp             AS HANDLE   NO-UNDO.
DEF VAR l-movto-com-erro    AS LOGICAL  NO-UNDO.
def var i-erro              as integer init 0 NO-UNDO.
def var c-informacao        as char format "x(256)" NO-UNDO.

def var c-natur              like ped-venda.nat-operacao.
DEF VAR c-natur-ent          LIKE natur-oper.nat-operacao.
def var r-rowid              as rowid no-undo.


def var de-tot-bicms  as decimal no-undo.
def var de-tot-icms   as decimal no-undo.
def var de-tot-bsubs  as decimal no-undo.
def var de-tot-icmst  as decimal no-undo.
def var l-sub as logical no-undo.										 
DEFINE VARIABLE tth-emitente    AS HANDLE        NO-UNDO.
DEFINE VARIABLE bhtt-emitente   AS HANDLE        NO-UNDO.
DEF    VAR      h-bo            AS HANDLE        NO-UNDO.
DEFINE VARIABLE i-emitente      AS INTEGER     NO-UNDO.
DEF    VAR      r-chave         AS ROWID         NO-UNDO.
DEFINE VARIABLE i-identific     AS INTEGER NO-UNDO.
DEFINE VARIABLE hb-emitente     AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h-query         AS WIDGET-HANDLE NO-UNDO.


/* In¡cio do programa que calcula uma nota complementar */

DEF VAR c-hora-ini AS CHAR FORMAT "x(12)" NO-UNDO.
DEF VAR c-hora-fim AS CHAR FORMAT "x(12)" NO-UNDO.

/* DefiniÆo da vari veis */
def var h-bodi317pr                   as handle no-undo.
def var h-bodi317sd                   as handle no-undo.
def var h-bodi317im1bra               as handle no-undo.
def var h-bodi317va                   as handle no-undo.
def var h-bodi317in                   as handle no-undo.
def var h-bodi317ef                   as handle no-undo.
def var l-proc-ok-aux                 as log    no-undo.
def var c-ultimo-metodo-exec          as char   no-undo.
def var c-cod-estabel                 as char   no-undo.
def var c-serie                       as char   no-undo.
def var da-dt-emis-nota               as date   no-undo.
def var da-dt-base-dup                as date   no-undo.
def var da-dt-prvenc                  as date   no-undo.
//def var c-seg-usuario                 as char   no-undo.
def var c-nome-abrev                  as char   no-undo.   
def var c-nr-pedcli                   as char   no-undo.
def var c-nat-operacao                as char   no-undo.
def var c-cod-canal-venda             as char   no-undo.
DEF VAR d-vl-frete                    AS DEC    NO-UNDO.
def var i-seq-wt-docto                as int    no-undo.
def var i-seq-wt-it-docto             as int    no-undo.
def var i-cont-itens                  as int    no-undo. 
def var c-it-codigo                   as char   no-undo.
def var c-cod-refer                   as char   no-undo.
def var de-quantidade                 as dec    no-undo.
def var de-vl-preori-ped              as dec    no-undo.
def var de-val-pct-desconto-tab-preco as dec    no-undo.
def var de-per-des-item               as dec    no-undo.
DEFINE VARIABLE c-tipo-pedido         AS INT   NO-UNDO.

DEFINE VARIABLE i-parcela AS INTEGER     NO-UNDO.

DEFINE VARIABLE i-pedido AS INTEGER                 NO-UNDO.
DEFINE VARIABLE i-ped-nota-saida-item  AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-origem AS CHARACTER               NO-UNDO. 
DEFINE VARIABLE l-ok AS LOGICAL                     NO-UNDO.
DEFINE VARIABLE c-cfop AS CHARACTER                 NO-UNDO.
DEFINE VARIABLE de-despesas AS DECIMAL              NO-UNDO.
DEFINE VARIABLE c-custo-loja AS DECIMAL             NO-UNDO.
DEFINE VARIABLE portador_convenio AS CHARACTER      NO-UNDO.
DEFINE VARIABLE c-convenio        AS CHARACTER   NO-UNDO.


ASSIGN p-origem = "VNDA".


DEFINE BUFFER b-estabelec FOR estabelec.															
/* Def temp-table de erros. Ela tbm est  definida na include dbotterr.i */
def temp-table rowerrors no-undo
    field errorsequence    as int
    field errornumber      as int
    field errordescription as char
    field errorparameters  as char
    field errortype        as char
    field errorhelp        as char
    field errorsubtype     as char.

/* Definicao da tabela temporaria tt-notas-geradas, include {dibo/bodi317ef.i1} */
def temp-table tt-notas-geradas no-undo
    field rw-nota-fiscal as   rowid
    field nr-nota        like nota-fiscal.nr-nota-fis
    field seq-wt-docto   like wt-docto.seq-wt-docto.

/* DefiniÆo de um buffer para tt-notas-geradas */
def buffer b-tt-notas-geradas for tt-notas-geradas.
DEFINE BUFFER b-emitente FOR ems2mult.emitente.
DEFINE BUFFER b_int_ds_loja_cond_pag FOR int_ds_loja_cond_pag.




log-manager:write-message("dentro da API") no-error.
// CADASTRO DE CLIENTE

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Processando").
FOR EACH tt-cliente:


  //  ASSIGN tt-cliente.natureza = 1. // forando cliente pessoa fisica

    FIND FIRST tt-pedido NO-LOCK NO-ERROR.
    
    log-manager:write-message("CNPJ do EMITENTE" + string(tt-pedido.cnpj_emitente)) no-error.
    log-manager:write-message("TIPO DE PEDIDO 0 - " + string(tt-pedido.tipopedido)) no-error.
    
    IF tt-pedido.tipopedido = 19 THEN
    DO:
    
        log-manager:write-message("TIPO DE PEDIDO 1 - " + string(tt-pedido.tipopedido)) no-error.
    
        FIND FIRST emitente NO-LOCK
            WHERE emitente.cgc = tt-cliente.cnpj NO-ERROR.
            
            log-manager:write-message("CNPJ do EMITENTE" + string(tt-pedido.cnpj_estab)) no-error.
            
        IF AVAIL emitente THEN
            RUN p_gera_pedido(INPUT emitente.cod-emitente).
        
    END.
    
    ELSE IF tt-pedido.tipopedido = 2   THEN
    DO:
        LOG-MANAGER:write-message("TIPO DE PEDIDO 3 - " + string(tt-pedido.tipopedido)) no-error.
    
        FIND FIRST emitente NO-LOCK
            WHERE emitente.cgc = tt-cliente.cnpj NO-ERROR.   // era tt-pedido.cnpj_estab NO-ERROR.
            
            log-manager:write-message("CNPJ do EMITENTE - " + string(tt-pedido.cnpj_estab)) no-error.
            
        IF AVAIL emitente THEN
            RUN p_gera_pedido(INPUT emitente.cod-emitente).
             
    END.
    
    ELSE IF tt-pedido.tipopedido = 22   THEN
    DO:
        LOG-MANAGER:write-message("TIPO DE PEDIDO 4 - " + string(tt-pedido.tipopedido)) no-error.
    
        FIND FIRST emitente NO-LOCK
            WHERE emitente.cgc = tt-cliente.cnpj NO-ERROR.   // era tt-pedido.cnpj_estab NO-ERROR.
            
            log-manager:write-message("CNPJ do EMITENTE - " + string(tt-pedido.cnpj_estab)) no-error.
            
        IF AVAIL emitente THEN
            RUN p_gera_pedido(INPUT emitente.cod-emitente).
             
    END.
    
    ELSE DO:  // nota de venda
    
        //  ASSIGN tt-cliente.natureza = 1. // for‡ando cliente pessoa fisica
        
        log-manager:write-message("TIPO DE PEDIDO 2 - " + string(tt-pedido.tipopedido)) no-error.
        log-manager:write-message("encontrou tt-cliente") no-error.										  																   

		RUN p_valida_cliente (OUTPUT l-movto-com-erro).

		FIND FIRST ems2mult.emitente NO-LOCK
			WHERE emitente.cgc = tt-cliente.cnpj NO-ERROR.

		IF AVAIL emitente THEN DO:         

			MESSAGE "ANTES ALTERAÇO CLIENTE"
				VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
			RUN p_altera_cliente ( INPUT ems2mult.emitente.cod-emitente,
								   OUTPUT l-movto-com-erro).
			log-manager:write-message("cliente ja existe, gera pedido") no-error.

			IF l-movto-com-erro = NO THEN DO:

				FIND FIRST ems2mult.emitente NO-LOCK
					WHERE emitente.cgc = tt-cliente.cnpj NO-ERROR.
				IF AVAIL emitente THEN
					RUN p_gera_pedido(INPUT emitente.cod-emitente).
			END.
		END.
		ELSE DO:

			log-manager:write-message("clientenÆo existe, criar cliente") no-error.
			
			IF l-movto-com-erro = NO THEN DO:
				ASSIGN i-emitente = 0.
				RUN p_cria_cliente ( OUTPUT i-emitente).
				IF i-emitente <> 0 THEN DO:
					log-manager:write-message("criou cliente, antes gera pedido") no-error.
					RUN p_gera_pedido(INPUT i-emitente).
				END.
			END.
		END.
	END.
END.

run pi-finalizar in h-acomp.



PROCEDURE p_gera_pedido:

    DEFINE INPUT PARAMETER i-cod-emitente AS INTEGER NO-UNDO.

    def VAR l-nf-man-dev-terc-dif as log no-undo.
    def var l-recal-apenas-totais as log no-undo.

    FIND FIRST ems2mult.emitente NO-LOCK
        WHERE emitente.cod-emitente     = i-cod-emitente NO-ERROR.

    IF NOT AVAIL emitente THEN DO:
        ASSIGN l-proc-ok-aux = NO.
                                                      
        CREATE tt-nota-fiscal.
        ASSIGN tt-nota-fiscal.cod-estabel = ""
               tt-nota-fiscal.nr-nota-fis = ""
               tt-nota-fiscal.serie       = ""
               tt-nota-fiscal.chave-acesso = ""
               tt-nota-fiscal.l-gerada    = NO
               tt-nota-fiscal.desc-erro   = "Emitente nao foi cadastrado corretamente, verificar dados do cliente".
        
        undo, leave.

    END.

    FOR EACH tt-pedido:
        /* Informaäes do embarque para c lculo */
        
        PAUSE 3 NO-MESSAGE.
        
        FIND FIRST nota-fiscal NO-LOCK
            WHERE nota-fiscal.nome-ab-cli = emitente.nome-abrev
              AND nota-fiscal.nr-pedcli   = string(tt-pedido.pedcodigo) NO-ERROR.
        
        IF AVAIL nota-fiscal THEN DO:

            ASSIGN l-proc-ok-aux = NO.
                                                          
            CREATE tt-nota-fiscal.
            ASSIGN tt-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel
                   tt-nota-fiscal.nr-nota-fis = nota-fiscal.nr-nota-fis
                   tt-nota-fiscal.serie       = nota-fiscal.serie
                   tt-nota-fiscal.chave-acesso = nota-fiscal.cod-chave-aces-nf-eletro
                   tt-nota-fiscal.l-gerada    = NO
                   tt-nota-fiscal.desc-erro   = "Ja existe uma nota fiscal para esse pedido".
            
            undo, leave.

        END.

        FIND FIRST ems2mult.estabelec NO-LOCK
            WHERE estabelec.cgc = tt-pedido.cnpj_estab NO-ERROR.

	if not avail estabelec then do: 

                ASSIGN l-proc-ok-aux = NO.
                                                          
    		  CREATE tt-nota-fiscal.
                  ASSIGN tt-nota-fiscal.cod-estabel = ""
                         tt-nota-fiscal.nr-nota-fis = ""
                         tt-nota-fiscal.serie       = ""
                         tt-nota-fiscal.chave-acesso = ""
                         tt-nota-fiscal.l-gerada    = NO
                         tt-nota-fiscal.desc-erro   = "Estabelecimento invalido, CNPJ: " + tt-pedido.cnpj_estab.

                  undo, leave.

	end.
	IF (tt-pedido.tipopedido = 19 OR tt-pedido.tipopedido = 2) THEN DO: // Apenas transferencias
    
    
        FIND FIRST b-estabelec NO-LOCK
            WHERE b-estabelec.cgc = tt-pedido.cnpj_emitente NO-ERROR.
            
            MESSAGE "Estabelec emitente"
                     b-estabelec.cod-estabel    
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
        IF NOT AVAIL b-estabelec THEN DO:
        
            ASSIGN l-proc-ok-aux = NO.
                                                  
            CREATE tt-nota-fiscal.
            ASSIGN tt-nota-fiscal.cod-estabel = ""
                   tt-nota-fiscal.nr-nota-fis = ""
                   tt-nota-fiscal.serie       = ""
                   tt-nota-fiscal.chave-acesso = ""
                   tt-nota-fiscal.l-gerada    = NO
                   tt-nota-fiscal.desc-erro   = "O campo CNPJ-CPF-CLIENTE deve ser cnpj de uma filial".

            undo, leave.
            
        END.
           
        
    END.

        MESSAGE "antes tt-pedido-item" skip
                "tt-pedido.cnpj_estab " tt-pedido.cnpj_estab
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
			
		IF tt-pedido.tipopedido <> 19 AND tt-pedido.tipopedido <> 2 AND tt-pedido.tipopedido <> 22  THEN DO:   // Valida condi‡Æo de pagamento somente se nÆo for transferencia	

			FIND FIRST tt-cond-pagto-esp NO-ERROR.

			IF NOT AVAIL tt-cond-pagto-esp THEN DO:

				ASSIGN l-proc-ok-aux = NO.
                                                      
				CREATE tt-nota-fiscal.
				ASSIGN tt-nota-fiscal.cod-estabel = ""
						tt-nota-fiscal.nr-nota-fis = ""
						tt-nota-fiscal.serie       = ""
						tt-nota-fiscal.chave-acesso = ""
						tt-nota-fiscal.l-gerada    = NO
						tt-nota-fiscal.desc-erro   = "Condi   o de pagamento   obrigat ria".
                
                RETURN "NOK".
				//undo, leave.


			END.
		END.

        FOR FIRST tt-cond-pagto-esp:
            IF fnDeParaCodEsp(tt-cond-pagto-esp.cond-pagto) = "NOK" THEN DO:

                ASSIGN l-proc-ok-aux = NO.
                                                          
    			  CREATE tt-nota-fiscal.
                  ASSIGN tt-nota-fiscal.cod-estabel = ""
                         tt-nota-fiscal.nr-nota-fis = ""
                         tt-nota-fiscal.serie       = ""
                         tt-nota-fiscal.chave-acesso = ""
                         tt-nota-fiscal.l-gerada    = NO
                         tt-nota-fiscal.desc-erro   = "Condi   o de pagamento " + tt-cond-pagto-esp.cond-pagto + "   inv lida".

                    RETURN "NOK".     
                  //undo, leave.
            END.
        END.


        FOR FIRST tt-pedido-item:

            MESSAGE "antes procura item"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

            FIND FIRST ITEM NO-LOCK
                WHERE ITEM.it-codigo = tt-pedido-item.cod-item NO-ERROR.
            IF AVAIL ITEM THEN DO:

                MESSAGE "achou item"
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                run intprg/int115a.p ( input tt-pedido.tipopedido,  
                                       input emitente.estado  ,
                                       input estabelec.estado   ,
                                       input "" /*nat or*/ ,
                                       input IF AVAIL emitente THEN emitente.cod-emitente ELSE 0,
                                       input item.class-fiscal,
                                       input ITEM.it-codigo   , /* item */
                                       INPUT estabelec.cod-estabel, 
                                       output c-natur      ,
                                       output c-natur-ent  ,
                                       output r-rowid).
                MESSAGE "natureza - " c-natur
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            END.
            ELSE DO:

                ASSIGN l-proc-ok-aux = NO.
                                                          
    			  CREATE tt-nota-fiscal.
                  ASSIGN tt-nota-fiscal.cod-estabel = ""
                         tt-nota-fiscal.nr-nota-fis = ""
                         tt-nota-fiscal.serie       = ""
                         tt-nota-fiscal.chave-acesso = ""
                         tt-nota-fiscal.l-gerada    = NO
                         tt-nota-fiscal.desc-erro   = "Item nÆo cadastrado".

                  undo, leave.
            END. 

            IF c-natur = "" THEN DO:


                ASSIGN l-proc-ok-aux = NO.
                                                          
    			  CREATE tt-nota-fiscal.
                  ASSIGN tt-nota-fiscal.cod-estabel = ""
                         tt-nota-fiscal.nr-nota-fis = ""
                         tt-nota-fiscal.serie       = ""
                         tt-nota-fiscal.chave-acesso = ""
                         tt-nota-fiscal.l-gerada    = NO
                         tt-nota-fiscal.desc-erro   = "NÆo encontrado natureza de operacao, validar parametros do int115 - Datasul".

                  undo, leave.


            END.
            

        END.  
		
		FIND FIRST int_ds_tipo_pedido no-lock
            where int_ds_tipo_pedido.tp_pedido = string(tt-pedido.tipopedido) no-error.
            
         MESSAGE "ANTES DOS ELSE IF" SKIP
                  c-serie
             VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
        IF AVAIL int_ds_tipo_pedido AND
           int_ds_tipo_pedido.serie <> "" THEN DO:
            ASSIGN c-serie = int_ds_tipo_pedido.serie.
            
            MESSAGE "dentro do if" SKIP
                     c-serie
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
           
        END.
        
        ELSE IF (tt-pedido.tipopedido = 19 OR tt-pedido.tipopedido = 2 OR tt-pedido.tipopedido = 22)  THEN DO:
            ASSIGN c-serie = "20".
            
            MESSAGE  "DEPOIS TIPO 19"
                 c-serie
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
        END.
        
        
        
        ELSE IF tt-pedido.tipopedido = 95 THEN
        DO:
            ASSIGN c-serie = "403".
            
        END.
        ELSE DO:        
            ASSIGN c-serie = "402".
        END.
        
        MESSAGE "Antes dar assign " SKIP
                 c-serie
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        assign //c-seg-usuario     = "super"  /* Usu rio                    */
               c-tipo-pedido     = tt-pedido.tipopedido
               c-cod-estabel     = estabelec.cod-estabel /* Estabelecimento do pedido  */
             //  c-serie           = "402"    /* Srie das notas            */
               c-nome-abrev      = emitente.nome-abrev /* Nome abreviado do cliente  */
               c-nr-pedcli       = string(tt-pedido.pedcodigo)   /* Nr pedido do cliente       */
               da-dt-emis-nota   = today    /* Data de emissÆo da nota    */
               c-nat-operacao    = c-natur /* Quando  ? busca do pedido */
               c-cod-canal-venda = ?       /* Quando  ? busca do pedido */
               c-hora-ini        = STRING(TIME,"hh:mm:ss")
               d-vl-frete        = tt-pedido.frete.

       /* KML - 11/12/2023 - Cria comissÆo para repasse marketplace */
    
/*         IF tt-pedido.comissao > 0 THEN                                            */
/*             ASSIGN c-serie           = "403".    /* S rie das notas            */ */
/*         ELSE                                                                      */
/*             ASSIGN c-serie           = "402" .   /* S rie das notas            */ */

        LOG-MANAGER:WRITE-MESSAGE("Antes gera nota - " + string(c-serie) ) NO-ERROR.
        LOG-MANAGER:WRITE-MESSAGE("tt-pedido.frete = " + STRING(tt-pedido.frete)) NO-ERROR.


    END.
    /* InicializaÆo das BOS para C lculo */
    run dibo/bodi317in.p persistent set h-bodi317in.
    run inicializaBOS in h-bodi317in(output h-bodi317pr,
                                     output h-bodi317sd,     
                                     output h-bodi317im1bra,
                                     output h-bodi317va).

    /* In¡cio da transaÆo */
    repeat trans:
        /* Limpar a tabela de erros em todas as BOS */
        run emptyRowErrors        in h-bodi317in.
    
        
        MESSAGE "antes criar nota" SKIP
                 c-serie
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
        run criaWtDocto in h-bodi317sd
                (input  c-seg-usuario,
                 input  c-cod-estabel,
                 input  c-serie,
                 input  "",
                 input  c-nome-abrev,
                 input  "",  // pedido
                 input  4,
                 input  120,
                 input  da-dt-emis-nota,
                 input  0,
                 input  c-nat-operacao,
                 input  c-cod-canal-venda,
                 output i-seq-wt-docto,
                 output l-proc-ok-aux).

        LOG-MANAGER:WRITE-MESSAGE("KML - depois criawtdocto") NO-ERROR.
        
        /* Busca poss¡veis erros que ocorreram nas validaäes */
        run devolveErrosbodi317sd in h-bodi317sd(output c-ultimo-metodo-exec,
                                                 output table RowErrors).
    
        /* Pesquisa algum erro ou advertncia que tenha ocorrido */
        find first RowErrors no-lock no-error.
        
        /* Caso tenha achado algum erro ou advertncia, mostra em tela */
        if  avail RowErrors then
            for each RowErrors:

                IF not l-proc-ok-aux THEN DO:
                
    			  CREATE tt-nota-fiscal.
                  ASSIGN tt-nota-fiscal.cod-estabel = ""
                         tt-nota-fiscal.nr-nota-fis = ""
                         tt-nota-fiscal.serie       = ""
                         tt-nota-fiscal.chave-acesso = ""
                         tt-nota-fiscal.l-gerada    = NO
                         tt-nota-fiscal.desc-erro   = RowErrors.errordescription.
                END.
            end.
        
        /* Caso ocorreu problema nas validaäes, nÆo continua o processo */
        if  not l-proc-ok-aux then
            undo, leave.

         FOR FIRST wt-docto 
             WHERE wt-docto.seq-wt-docto = i-seq-wt-docto:
             
             LOG-MANAGER:WRITE-MESSAGE("depois gera wt-docto ") NO-ERROR.
             LOG-MANAGER:WRITE-MESSAGE("wt-docto.vl-frete-inf = " + STRING(wt-docto.vl-frete-inf)) NO-ERROR.
             LOG-MANAGER:WRITE-MESSAGE("wt-docto.vl-frete     = " + STRING(wt-docto.vl-frete    )) NO-ERROR.
             LOG-MANAGER:WRITE-MESSAGE("d-vl-frete            = " + STRING(d-vl-frete    )) NO-ERROR.
             
             // KML - Comentado a linha de tipo frete pois agora ser  buscado via produto padrÆo do CD0705

             ASSIGN wt-docto.ind-tp-frete = if d-vl-frete = 0 then 9 else 1 // fixando modalidade sem frete para nÆo precisar informar o transportador
                    wt-docto.nome-transp  = if d-vl-frete = 0 then "" else ""
                    wt-docto.vl-frete-inf = d-vl-frete
                    wt-docto.vl-frete     = d-vl-frete.
             
             LOG-MANAGER:WRITE-MESSAGE("wt-docto.vl-frete-inf = " + STRING(wt-docto.vl-frete-inf)) NO-ERROR.
             LOG-MANAGER:WRITE-MESSAGE("wt-docto.vl-frete     = " + STRING(wt-docto.vl-frete    )) NO-ERROR.
         END.
    
        /* Bloco a ser repetido para cada item da nota */
             
        bloco-cria-item:
        FOR EACH tt-pedido-item:

            FIND FIRST ITEM NO-LOCK
                WHERE ITEM.it-codigo = tt-pedido-item.cod-item NO-ERROR.
             
            FIND FIRST ems2mult.estabelec NO-LOCK
                WHERE estabelec.cod-estabel = c-cod-estabel NO-ERROR.
                           
            IF NOT AVAIL emitente THEN
                FIND FIRST ems2mult.emitente NO-LOCK
                    WHERE emitente.cod-emitente     = i-cod-emitente NO-ERROR.
                    
            LOG-MANAGER:WRITE-MESSAGE("KML - antes busca natureza item") NO-ERROR.            
            
            run intprg/int115a.p ( input c-tipo-pedido,  
                       input emitente.estado  ,
                       input estabelec.estado   ,
                       input "" /*nat or*/ ,
                       input emitente.cod-emitente,
                       input item.class-fiscal,
                       input ITEM.it-codigo   , /* item */
                       INPUT estabelec.cod-estabel, 
                       output c-natur      ,
                       output c-natur-ent  ,
                       output r-rowid).
                       
                  
            // inicio bloco para obeder ao valor de ultima entrada do item      
            
            de-vl-preori-ped = 0.
            c-custo-loja     = 0.
            
            FIND FIRST tt-pedido NO-LOCK NO-ERROR.
            
            IF AVAIL tt-pedido AND  (tt-pedido.tipopedido = 19 OR tt-pedido.tipopedido = 2 OR tt-pedido.tipopedido = 22)  THEN
            DO:
            
                
                MESSAGE "Passou 2x" SKIP
                        ITEM.it-codigo SKIP
                        c-custo-loja
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
                FIND FIRST ITEM-uni-estab NO-LOCK
                    WHERE item-uni-estab.it-codigo   = ITEM.it-codigo
                    AND   item-uni-estab.cod-estabel = estabelec.cod-estabel NO-ERROR.
                
                ASSIGN c-custo-loja = item-uni-estab.preco-ul-ent. 
                
                
            END.
            // fim ultima entrada
            
            

            assign c-it-codigo                   = ITEM.it-codigo /* C¢digo do item     */ 
                   c-cod-refer                   = ""  /* Referncia do item */
                   de-quantidade                 = tt-pedido-item.quantidade
                   de-vl-preori-ped              = IF (tt-pedido.tipopedido = 19 OR tt-pedido.tipopedido = 2 OR tt-pedido.tipopedido = 22 )  THEN de-vl-preori-ped + c-custo-loja ELSE tt-pedido-item.preco-bruto   //alteracao realizada , obedecendo ultima entrada para transferencias
                   de-val-pct-desconto-tab-preco = 0   /* Desconto de tabela */
                   de-per-des-item               = (tt-pedido-item.desconto * 100) / tt-pedido-item.preco-bruto .  /* Desconto do item   */
     
            LOG-MANAGER:WRITE-MESSAGE("KML - antes busca natureza item - " + "c-natur - "  + c-natur) NO-ERROR.            
            MESSAGE "KML" skip
                     "de-quantidade - " de-quantidade SKIP
                    "de-vl-preori-ped - " de-vl-preori-ped SKIP
                    "de-per-des-item - " de-per-des-item SKIP
                    "tt-pedido-item.preco-bruto - " tt-pedido-item.preco-bruto SKIP
                    "tt-pedido-item.desconto - " tt-pedido-item.desconto SKIP
                    "de-val-pct-desconto-tab-preco - " de-val-pct-desconto-tab-preco SKIP
                    "c-natur - " c-natur SKIP
                    "c-custo-loja" c-custo-loja 
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

            /* Limpar a tabela de erros em todas as BOS */
            run emptyRowErrors        in h-bodi317in.
        
            /* Disponibilizar o registro WT-DOCTO na bodi317sd */
            run localizaWtDocto in h-bodi317sd(input  i-seq-wt-docto,
                                               output l-proc-ok-aux). 
        
            /* Cria um item para nota fiscal. */
            run criaWtItDocto in h-bodi317sd  (input  ?,
                                               input  "",
                                               input  10,
                                               input  c-it-codigo,
                                               input  c-cod-refer,
                                               input  c-natur,
                                               output i-seq-wt-it-docto,
                                               output l-proc-ok-aux).
        
            LOG-MANAGER:WRITE-MESSAGE("KML - depois busca natureza item - " + "c-natur - "  + c-natur) NO-ERROR.            
            /* Busca poss¡veis erros que ocorreram nas validaäes */
            run devolveErrosbodi317sd in h-bodi317sd(output c-ultimo-metodo-exec,
                                                     output table RowErrors). 
        
            /* Pesquisa algum erro ou advertncia que tenha ocorrido */
            find first RowErrors no-lock no-error.
            
            /* Caso tenha achado algum erro ou advertncia, mostra em tela */
            if  avail RowErrors then
                for each RowErrors:
                    
                    IF not l-proc-ok-aux THEN DO:
                    
        			  CREATE tt-nota-fiscal.
                      ASSIGN tt-nota-fiscal.cod-estabel = ""
                             tt-nota-fiscal.nr-nota-fis = ""
                             tt-nota-fiscal.serie       = ""
                             tt-nota-fiscal.chave-acesso = ""
                             tt-nota-fiscal.l-gerada    = NO
                             tt-nota-fiscal.desc-erro   = RowErrors.errordescription.
                    END.
                end.

            /* Caso ocorreu problema nas validaäes, nÆo continua o processo */
            if  not l-proc-ok-aux then
                undo, leave.

            /* Grava informaäes gerais para o item da nota */
            run gravaInfGeraisWtItDocto in h-bodi317sd 
                   (input i-seq-wt-docto,
                    input i-seq-wt-it-docto,
                    input de-quantidade,
                    input de-vl-preori-ped,
                    input de-val-pct-desconto-tab-preco,
                    input de-per-des-item).
        
            /* Limpar a tabela de erros em todas as BOS */
            run emptyRowErrors        in h-bodi317in.
        
            /* Disp. registro WT-DOCTO, WT-IT-DOCTO e WT-IT-IMPOSTO na bodi317pr */
            run localizaWtDocto       in h-bodi317pr(input  i-seq-wt-docto,
                                                     output l-proc-ok-aux).

            run localizaWtItDocto     in h-bodi317pr(input  i-seq-wt-docto,
                                                     input  i-seq-wt-it-docto,
                                                     output l-proc-ok-aux).
            run localizaWtItImposto   in h-bodi317pr(input  i-seq-wt-docto,
                                                     input  i-seq-wt-it-docto,
                                                     output l-proc-ok-aux).

            RUN calculaPrecos IN h-bodi317pr (INPUT NO,
                                              OUTPUT l-proc-ok-aux).

            run localizaWtDocto       in h-bodi317pr(input  i-seq-wt-docto,
                                                     output l-proc-ok-aux).

            run localizaWtItDocto     in h-bodi317pr(input  i-seq-wt-docto,
                                                     input  i-seq-wt-it-docto,
                                                     output l-proc-ok-aux).
            run localizaWtItImposto   in h-bodi317pr(input  i-seq-wt-docto,
                                                     input  i-seq-wt-it-docto,
                                                     output l-proc-ok-aux).
        
            /* Atualiza dados c lculados do item */
            run atualizaDadosItemNota in h-bodi317pr(output l-proc-ok-aux).
        
            /* Busca poss¡veis erros que ocorreram nas validaäes */
            run devolveErrosbodi317pr in h-bodi317pr(output c-ultimo-metodo-exec,
                                                     output table RowErrors).
        
            /* Pesquisa algum erro ou advertncia que tenha ocorrido */
            find first RowErrors no-lock no-error.
            
            /* Caso tenha achado algum erro ou advertncia, mostra em tela */
            if  avail RowErrors then
                for each RowErrors:
                    
                    IF not l-proc-ok-aux THEN DO:
                    
        			  CREATE tt-nota-fiscal.
                      ASSIGN tt-nota-fiscal.cod-estabel = ""
                             tt-nota-fiscal.nr-nota-fis = ""
                             tt-nota-fiscal.serie       = ""
                             tt-nota-fiscal.chave-acesso = ""
                             tt-nota-fiscal.l-gerada    = NO
                             tt-nota-fiscal.desc-erro   = RowErrors.errordescription.
                    END.
                end.
            
            /* Caso ocorreu problema nas validaäes, nÆo continua o processo */
            if  not l-proc-ok-aux then
                undo, leave.
        
            /* Limpar a tabela de erros em todas as BOS */
            run emptyRowErrors        in h-bodi317in.
        
            /* Valida informaäes do item */
            run validaItemDaNota      in h-bodi317va(input  i-seq-wt-docto,
                                                     input  i-seq-wt-it-docto,
                                                     output l-proc-ok-aux).
            /* Busca poss¡veis erros que ocorreram nas validaäes */
            run devolveErrosbodi317va in h-bodi317va(output c-ultimo-metodo-exec,
                                                     output table RowErrors).

            /* Pesquisa algum erro ou advertncia que tenha ocorrido */
            find first RowErrors no-lock no-error.
            
            /* Caso tenha achado algum erro ou advertncia, mostra em tela */
            if  avail RowErrors then
                for each RowErrors:
                        
                    IF not l-proc-ok-aux THEN DO:
                    
        			  CREATE tt-nota-fiscal.
                      ASSIGN tt-nota-fiscal.cod-estabel = ""
                             tt-nota-fiscal.nr-nota-fis = ""
                             tt-nota-fiscal.serie       = ""
                             tt-nota-fiscal.chave-acesso = ""
                             tt-nota-fiscal.l-gerada    = NO
                             tt-nota-fiscal.desc-erro   = RowErrors.errordescription.
                    END.



                end.
            
            /* Caso ocorreu problema nas validaäes, nÆo continua o processo */
            if  not l-proc-ok-aux then
                undo, leave.
        end.

        /*run localizaWtDocto       in h-bodi317pr(input  i-seq-wt-docto,
                                                     output l-proc-ok-aux).*/
    
        IF CAN-FIND(FIRST tt-cond-pagto-esp) THEN DO:
            FOR FIRST wt-it-docto NO-LOCK
                WHERE wt-it-docto.seq-wt-docto = i-seq-wt-docto,
                EACH tt-cond-pagto-esp:
                create wt-fat-duplic.
                assign wt-fat-duplic.seq-wt-docto            = wt-it-docto.seq-wt-docto
                       wt-fat-duplic.nr-seq-nota             = wt-it-docto.nr-seq-nota
                       wt-fat-duplic.parcela                 = string(tt-cond-pagto-esp.parcela, "99":U)
                       wt-fat-duplic.cod-vencto              = 1
                       wt-fat-duplic.dt-venciment            = tt-cond-pagto-esp.dt-vencto
                       wt-fat-duplic.dt-desconto             = ?
                       wt-fat-duplic.vl-desconto             = 0
                       wt-fat-duplic.vl-parcela              = tt-cond-pagto-esp.vl-parcela
                       wt-fat-duplic.vl-acum-dup             = 0
                       wt-fat-duplic.cod-esp                 = fnDeParaCodEsp(tt-cond-pagto-esp.cond-pagto)
                       wt-fat-duplic.val-base-contrib-social = 0
                       wt-fat-duplic.int-1                   = fnDeParaCodPortador(tt-cond-pagto-esp.cond-pagto)
                       .

                IF wt-fat-duplic.int-1 <> 0 THEN
                    FOR FIRST wt-docto EXCLUSIVE-LOCK
                        WHERE wt-docto.seq-wt-docto = i-seq-wt-docto:
                        ASSIGN wt-docto.cod-portador = wt-fat-duplic.int-1.
                    END.
            END.
        END.
        ELSE DO:
            run geraCondpagto in h-bodi317pr (input  1,
                                              output l-proc-ok-aux).
    
            run geraDuplicatas in h-bodi317pr (input  i-seq-wt-docto,
                                               output l-proc-ok-aux).
        END.

        /* FinalizaÆo das BOS utilizada no c lculo */
        run finalizaBOS in h-bodi317in.

        /* ReinicializaÆo das BOS para C lculo */
        run dibo/bodi317in.p persistent set h-bodi317in.
        run inicializaBOS in h-bodi317in(output h-bodi317pr,
                                         output h-bodi317sd,     
                                         output h-bodi317im1bra,
                                         output h-bodi317va).

        LOG-MANAGER:WRITE-MESSAGE("Antes calculaImpostosBrasil") NO-ERROR.
        FOR FIRST wt-docto no-lock
            WHERE wt-docto.seq-wt-docto = i-seq-wt-docto,
            EACH wt-it-docto NO-LOCK
            WHERE wt-it-docto.seq-wt-docto = i-seq-wt-docto,
            FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wt-it-docto.it-codigo:
            
            LOG-MANAGER:WRITE-MESSAGE("wt-docto.vl-frete-inf = " + STRING(wt-docto.vl-frete-inf)) NO-ERROR.
            LOG-MANAGER:WRITE-MESSAGE("wt-docto.vl-frete     = " + STRING(wt-docto.vl-frete    )) NO-ERROR.

            LOG-MANAGER:WRITE-MESSAGE("wt-it-docto.vl-frete-inf = " + STRING(wt-it-docto.vl-frete-inf)) NO-ERROR.
            LOG-MANAGER:WRITE-MESSAGE("wt-it-docto.vl-frete     = " + STRING(wt-it-docto.vl-frete    )) NO-ERROR.

        END.
    
        /* Limpar a tabela de erros em todas as BOS */
        run emptyRowErrors        in h-bodi317in.
    
        RUN calculaImpostosBrasil    IN h-bodi317im1bra(INPUT  i-seq-wt-docto,
                                                        OUTPUT l-proc-ok-aux).
    
        /* Pesquisa algum erro ou advertncia que tenha ocorrido */
        find first RowErrors no-lock no-error.
        
        /* Caso tenha achado algum erro ou advertncia, mostra em tela */
        if  avail RowErrors then
            for each RowErrors:
                 
               /* IF not l-proc-ok-aux THEN DO:
                
    			  CREATE tt-nota-fiscal.
                  ASSIGN tt-nota-fiscal.cod-estabel = ""
                         tt-nota-fiscal.nr-nota-fis = ""
                         tt-nota-fiscal.serie       = ""
                         tt-nota-fiscal.l-gerada    = NO
                         tt-nota-fiscal.desc-erro   = RowErrors.errordescription.
                END. */
            end.
        
        /* Caso ocorreu problema nas validaäes, nÆo continua o processo */
      //  if  not l-proc-ok-aux then
      //      undo, leave.

        LOG-MANAGER:WRITE-MESSAGE("depois  calculaImpostosBrasil") NO-ERROR.
        FOR FIRST wt-docto no-lock
            WHERE wt-docto.seq-wt-docto = i-seq-wt-docto,
            EACH wt-it-docto EXCLUSIVE-LOCK
            WHERE wt-it-docto.seq-wt-docto = i-seq-wt-docto,
            FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = wt-it-docto.it-codigo:

            LOG-MANAGER:WRITE-MESSAGE("wt-docto.vl-frete-inf = " + STRING(wt-docto.vl-frete-inf)) NO-ERROR.
            LOG-MANAGER:WRITE-MESSAGE("wt-docto.vl-frete     = " + STRING(wt-docto.vl-frete    )) NO-ERROR.

            LOG-MANAGER:WRITE-MESSAGE("wt-it-docto.vl-frete-inf = " + STRING(wt-it-docto.vl-frete-inf)) NO-ERROR.
            LOG-MANAGER:WRITE-MESSAGE("wt-it-docto.vl-frete     = " + STRING(wt-it-docto.vl-frete    )) NO-ERROR.

            if  wt-it-docto.fat-qtfam = ? then 
                for first item-cli
                    where item-cli.nome-abrev = wt-docto.nome-abrev
                    and   item-cli.it-codigo  = wt-it-docto.it-codigo no-lock:
                end.
        
            for first familia no-lock
                where familia.fm-codigo = item.fm-codigo:
            end.

             assign wt-it-docto.quantidade[2]   = if wt-it-docto.fat-qtfam = ?             
                                                  and avail item-cli
                                                  then wt-it-docto.quantidade[1] * 
                                                       (item-cli.fator-conversao / exp(10,item-cli.num-casa-dec))
                                                  else wt-it-docto.quantidade[1] * 
                                                       (item.ft-conversao / exp(10,item.dec-ftcon))
                    wt-it-docto.un[2]           = if wt-it-docto.fat-qtfam = ? 
                                                  and avail item-cli 
                                                  then item-cli.unid-med-cli
                                                  else if avail familia 
                                                       then familia.un
                                                       else item.un.
        END.

        /* Efetiva os pedidos e cria a nota */
        run dibo/bodi317ef.p persistent set h-bodi317ef.
        run emptyRowErrors           in h-bodi317in.
        run inicializaAcompanhamento in h-bodi317ef.
        run setaHandlesBOS           in h-bodi317ef(h-bodi317pr,     
                                                    h-bodi317sd, 
                                                    h-bodi317im1bra, 
                                                    h-bodi317va).
        run efetivaNota              in h-bodi317ef(input  i-seq-wt-docto,
                                                    input  yes,
                                                    output l-proc-ok-aux).
        run finalizaAcompanhamento   in h-bodi317ef.
    
        /* Busca poss¡veis erros que ocorreram nas validaäes */
        run devolveErrosbodi317ef    in h-bodi317ef(output c-ultimo-metodo-exec,
                                                    output table RowErrors).
    
        /* Pesquisa algum erro ou advertncia que tenha ocorrido */
        find first RowErrors
             where RowErrors.ErrorSubType = "ERROR":U no-error.
    
        /* Caso tenha achado algum erro ou advertncia, mostra em tela */
        if  avail RowErrors then
            for each RowErrors:
                
                IF not l-proc-ok-aux THEN DO:
                
    			  CREATE tt-nota-fiscal.
                  ASSIGN tt-nota-fiscal.cod-estabel = ""
                         tt-nota-fiscal.nr-nota-fis = ""
                         tt-nota-fiscal.serie       = ""
                         tt-nota-fiscal.chave-acesso = ""
                         tt-nota-fiscal.l-gerada    = NO
                         tt-nota-fiscal.desc-erro   = RowErrors.errordescription.
                END.
                


            end.
        
        /* Caso ocorreu problema nas validaäes, nÆo continua o processo */
        if  not l-proc-ok-aux then do:
            delete procedure h-bodi317ef.
            undo, leave.
        end.

        /* Busca as notas fiscais geradas */
        run buscaTTNotasGeradas in h-bodi317ef(output l-proc-ok-aux,
                                               output table tt-notas-geradas).
    
        /* Elimina o handle do programa bodi317ef */
        delete procedure h-bodi317ef.
        
        leave.
    end.
            
    /* FinalizaÆo das BOS utilizada no c lculo */
    run finalizaBOS in h-bodi317in.
    
    ASSIGN c-hora-fim = STRING(TIME,"hh:mm:ss").
    
    /* Mostrar as notas geradas */
    
    for each tt-notas-geradas:

        for first nota-fiscal exclusive-lock where 
            rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal:

            //liberar para atualizaÆo de estoque e fiscal
            ASSIGN nota-fiscal.int-2      = 9999
                   nota-fiscal.nr-pedcli  = c-nr-pedcli.

            FIND first cst_nota_fiscal WHERE
                      cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel AND
                      cst_nota_fiscal.serie       = nota-fiscal.serie AND
                      cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK NO-ERROR.
        
            if not avail cst_nota_fiscal then do:
                 create cst_nota_fiscal.
                 assign cst_nota_fiscal.cod_estabel       = nota-fiscal.cod-estabel
                        cst_nota_fiscal.serie             = nota-fiscal.serie
                        cst_nota_fiscal.nr_nota_fis       = nota-fiscal.nr-nota-fis.
        
                 assign cst_nota_fiscal.condipag            = "01"
                        cst_nota_fiscal.convenio            = "n"
                        cst_nota_fiscal.cupom_ecf           = "0"
                        cst_nota_fiscal.nfce_chave          = "0"
                        cst_nota_fiscal.valor_chq           = 0.
                 
                 ASSIGN cst_nota_fiscal.valor_chq_pre       = 0
                        cst_nota_fiscal.valor_convenio      = 0
                        cst_nota_fiscal.valor_dinheiro      = 0
                        cst_nota_fiscal.valor_ticket        = 0
                        cst_nota_fiscal.valor_vale          = 0
                        cst_nota_fiscal.valor_cartao        = 0
                        cst_nota_fiscal.nfce_dt_transmissao = TODAY
                        cst_nota_fiscal.nfce_protocolo      = ""
                        cst_nota_fiscal.nfce_transmissao    = ""
                        cst_nota_fiscal.cpf_cupom           = "" 
                        cst_nota_fiscal.cartao_manual       = NO
                        cst_nota_fiscal.orgao               = ""
                        cst_nota_fiscal.categoria           = ""
                        .
            end.

            FIND FIRST nota-fisc-adc EXCLUSIVE-LOCK
                WHERE nota-fisc-adc.cod-estab        = nota-fiscal.cod-estabel
                AND   nota-fisc-adc.cod-serie        = nota-fiscal.serie
                AND   nota-fisc-adc.cod-nota-fisc    = nota-fiscal.nr-nota-fis
                AND   nota-fisc-adc.cdn-emitente     = nota-fiscal.cod-emitente
                AND   nota-fisc-adc.cod-natur-operac = nota-fiscal.nat-operacao
                AND   nota-fisc-adc.idi-tip-dado     = 20 NO-ERROR.
        
        
            IF AVAIL nota-fisc-adc THEN DO:
            
                ASSIGN nota-fisc-adc.cod-livre-1      = "0".
        
            END.
            IF NOT AVAIL nota-fisc-adc THEN DO:
        
                CREATE nota-fisc-adc.
                ASSIGN nota-fisc-adc.cod-estab        = nota-fiscal.cod-estabel  
                       nota-fisc-adc.cod-serie        = nota-fiscal.serie        
                       nota-fisc-adc.cod-nota-fisc    = nota-fiscal.nr-nota-fis  
                       nota-fisc-adc.cdn-emitente     = nota-fiscal.cod-emitente
                       nota-fisc-adc.cod-natur-operac = nota-fiscal.nat-operacao
                       nota-fisc-adc.idi-tip-dado     = 20
                       nota-fisc-adc.cod-livre-1      = "0"
                    .
                
            END.


            log-manager:write-message("gerou nota fiscal") no-error.

            run pi-acompanhar in h-acomp (input "Altera Duplicata: " + nota-fiscal.nr-nota-fis).

            for each fat-duplic EXCLUSIVE-LOCK where 
                fat-duplic.cod-estabel  = nota-fiscal.cod-estabel  and
                fat-duplic.serie        = nota-fiscal.serie       and
                fat-duplic.nr-fatura    = nota-fiscal.nr-fatura:

/*  kml - alterado pois estava criando pedidos com o mesmo portador na fat-duplic  */


                /* KML - 11/12/2023 - Cria comissÆo para repasse marketplace */

                FIND FIRST tt-pedido NO-LOCK NO-ERROR.
    
                IF tt-pedido.cnpj-representante <> "" THEN DO:
    
                    FIND FIRST repres NO-LOCK
                        WHERE repres.cgc = tt-pedido.cnpj-representante NO-ERROR.
                    IF AVAIL repres THEN DO:
                        ASSIGN nota-fiscal.cod-rep          = repres.cod-rep
                               nota-fiscal.no-ab-reppri     = repres.nome-abrev
                               nota-fiscal.vl-comis-nota-me = nota-fiscal.vl-tot-nota * tt-pedido.comissao / 100
                               nota-fiscal.vl-comis-nota    = nota-fiscal.vl-tot-nota * tt-pedido.comissao / 100
                               fat-duplic.vl-comis          = nota-fiscal.vl-tot-nota * tt-pedido.comissao / 100
                               fat-duplic.vl-comis-e        = nota-fiscal.vl-tot-nota * tt-pedido.comissao / 100
                               fat-duplic.vl-comis-me       = nota-fiscal.vl-tot-nota * tt-pedido.comissao / 100.


                        CREATE fat-repre.
                        ASSIGN fat-repre.cod-estabel            = nota-fiscal.cod-estabel    
                               fat-repre.serie                  = nota-fiscal.serie
                               fat-repre.nr-fatura              = fat-duplic.nr-fatura
                               fat-repre.nome-ab-rep            = repres.nome-abrev
                               fat-repre.perc-comis             = tt-pedido.comissao
                               fat-repre.comis-emis             = 0
                               fat-repre.vl-base-calc-comis     = nota-fiscal.vl-tot-nota
                               fat-repre.val-comis              = nota-fiscal.vl-tot-nota * tt-pedido.comissao / 100
                               fat-repre.val-comis-emis         = 0
                            .
    
                    END.
                END.

                FIND FIRST tt-cond-pagto-esp
                    WHERE tt-cond-pagto-esp.parcela = int(fat-duplic.parcela) NO-ERROR.

                IF AVAIL tt-cond-pagto-esp THEN DO: 
                    assign fat-duplic.int-1 = fnDeParaCodPortador(tt-cond-pagto-esp.cond-pagto) 
                           fat-duplic.int-2 = nota-fiscal.modalidade   .

                END.
                ELSE DO:
                    assign fat-duplic.int-1 = nota-fiscal.cod-portador  
                           fat-duplic.int-2 = nota-fiscal.modalidade   .

                END.

                       
                       
               ASSIGN fat-duplic.ind-fat-nota = 1. /* Gerar contas a receber */
                       
                       

                FIND FIRST cst_fat_duplic
                    WHERE cst_fat_duplic.cod_estabel   = fat-duplic.cod-estabel 
                      AND cst_fat_duplic.serie         = fat-duplic.serie       
                      AND cst_fat_duplic.nr_fatura     = fat-duplic.nr-fatura   
                      AND cst_fat_duplic.parcela       = fat-duplic.parcela NO-ERROR.
        
                log-manager:write-message("int092 ANTES IF NOT AVAIL - CST_FAT_DUPLIC - " + cst_fat_duplic.nr_fatura) no-error.
                
                IF NOT AVAIL cst_fat_duplic THEN DO:
                
                    MESSAGE "Dentro do if not avail"
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                                                                                        
                    IF tt-cond-pagto-esp.CNPJ_CONVENIO = " " OR (tt-cond-pagto-esp.CNPJ_CONVENIO = ?) OR (tt-cond-pagto-esp.CNPJ_CONVENIO = "none") THEN
                    DO:
                    
                        log-manager:write-message("int092 entrou IF NOT AVAIL 2 -") no-error.
 
                        FIND FIRST int_ds_loja_cond_pag NO-LOCK  // KML ALTERA
                            WHERE int_ds_loja_cond_pag.cod_portador = fat-duplic.int-1
                            AND   int_ds_loja_cond_pag.cod_esp      = fat-duplic.cod-esp NO-ERROR.
                            
                        //IF AVAIL int_ds_loja_cond_pag  THEN
                        //DO: 
                        
                        
                            create cst_fat_duplic.
                            assign cst_fat_duplic.cod_portador  = fat-duplic.int-1
                                   cst_fat_duplic.modalidade    = 6
                                   cst_fat_duplic.cod_cond_pag  = IF AVAIL int_ds_loja_cond_pag THEN int(int_ds_loja_cond_pag.condipag) ELSE ?
                                   cst_fat_duplic.condipag      = string(1,"99")
                                   cst_fat_duplic.cod_estabel   = nota-fiscal.cod-estabel
                                   cst_fat_duplic.serie         = nota-fiscal.serie
                                   cst_fat_duplic.nr_fatura     = nota-fiscal.nr-nota-fis
                                   cst_fat_duplic.parcela       = fat-duplic.parcela.
                                   
                                   
                            MESSAGE "CST_FAT_DUPLIC" 
                                    cst_fat_duplic.cod_portador
                                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                   
                                   
                            FIND FIRST tt-cond-pagto-esp
                                WHERE tt-cond-pagto-esp.parcela = INT(fat-duplic.parcela) NO-ERROR.

                            assign cst_fat_duplic.adm_cartao    = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.adquirente   else ""
                                   cst_fat_duplic.autorizacao   = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.autorizacao  else ""
                                   cst_fat_duplic.nsu_admin     = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.nsu          else ""
                                   cst_fat_duplic.nsu_numero    = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.nsu          else ""
                                   cst_fat_duplic.taxa_admin    = 0.         
                                   
       
                        //END.
                    END.      
                        
                    ELSE DO:
                    
                        ASSIGN portador_convenio = " ".
                        ASSIGN c-convenio        = "n".
                                                              //GOLDEN                 //KML - 13/01/2026 - ITAIPU convertida para Medme 
                        IF tt-cond-pagto-esp.CNPJ_CONVENIO = "58480872000184" THEN //OR (tt-cond-pagto-esp.CNPJ_CONVENIO = "00395988001298")  THEN
                        DO:
                        
                            ASSIGN portador_convenio = "99501".
 
                        END.
                        
                        IF portador_convenio = " " THEN
                        DO:
                            ASSIGN portador_convenio = string(fat-duplic.int-1).
                            
                        END.
                        
                        ASSIGN nota-fiscal.cod-portador = int(portador_convenio).
                        
                        //LOG-MANAGER:write-message("int092 entrou convenio -" + tt-cond-pagto-esp.CNPJ_CONVENIO) no-error.
                        
                        MESSAGE "Entrou ELSE convenio - 1" SKIP
                                "ABAIXO CNPJ_CONVENIO - 1"
                                tt-cond-pagto-esp.CNPJ_CONVENIO 
                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                    
                        FIND FIRST b-emitente NO-LOCK
                            WHERE  b-emitente.cgc =  tt-cond-pagto-esp.CNPJ_CONVENIO NO-ERROR.
                            
                        IF NOT AVAIL b-emitente THEN
                        DO:
                        
                            log-manager:write-message("int092 entrou ELSE DO: - 1") no-error.    
                        
                            FIND FIRST b_int_ds_loja_cond_pag NO-LOCK  // KML ALTERA
                                WHERE b_int_ds_loja_cond_pag.cod_portador = int(portador_convenio)
                                AND   b_int_ds_loja_cond_pag.cod_esp      = fat-duplic.cod-esp 
                                AND   b_int_ds_loja_cond_pag.cod_emitente = 9806582 NO-ERROR.
                                
                            IF AVAIL b_int_ds_loja_cond_pag THEN
                            DO:
                            
                                log-manager:write-message("int092 entrou IF COND-PAG: - 1") no-error. 
                            
                                create cst_fat_duplic.
                                assign cst_fat_duplic.cod_portador  = int(portador_convenio)
                                       cst_fat_duplic.modalidade    = 6
                                       cst_fat_duplic.cod_cond_pag  = IF AVAIL b_int_ds_loja_cond_pag THEN int(b_int_ds_loja_cond_pag.condipag) ELSE ?
                                       cst_fat_duplic.condipag      = string(1,"99")
                                       cst_fat_duplic.cod_estabel   = nota-fiscal.cod-estabel
                                       cst_fat_duplic.serie         = nota-fiscal.serie
                                       cst_fat_duplic.nr_fatura     = nota-fiscal.nr-nota-fis
                                       cst_fat_duplic.parcela       = fat-duplic.parcela.

                                FIND FIRST tt-cond-pagto-esp
                                    WHERE tt-cond-pagto-esp.parcela = INT(fat-duplic.parcela) NO-ERROR.

                                assign cst_fat_duplic.adm_cartao    = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.adquirente   else ""
                                       cst_fat_duplic.autorizacao   = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.autorizacao  else ""
                                       cst_fat_duplic.nsu_admin     = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.nsu          else ""
                                       cst_fat_duplic.nsu_numero    = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.nsu          else ""
                                       cst_fat_duplic.taxa_admin    = 0.
                                       
                                
                                IF b_int_ds_loja_cond_pag.CONDIPAG = "12" THEN
                
                                    ASSIGN c-convenio = "".
                                       
                                IF (b_int_ds_loja_cond_pag.CONDIPAG = "12" OR b_int_ds_loja_cond_pag.CONDIPAG = "83" OR b_int_ds_loja_cond_pag.CONDIPAG = "17")  THEN
                                DO:
                                
                              
                                    assign cst_nota_fiscal.condipag     = b_int_ds_loja_cond_pag.condipag
                                           cst_nota_fiscal.convenio     = c-convenio
                                           cst_nota_fiscal.cupom_ecf    = "49554562000176"
                                           cst_nota_fiscal.nfce_chave   = "0"
                                           cst_nota_fiscal.valor_chq    =  0
                                           cst_nota_fiscal.cpf_cupom    = "49554562000176".
                                           
                                END.                      
                            END.
                        END.
                            
                        ELSE DO:
                                         
                            log-manager:write-message("int092 entrou ELSE DO: - 2") no-error.    
                        
                            FIND FIRST b_int_ds_loja_cond_pag NO-LOCK  // KML ALTERA
                                WHERE b_int_ds_loja_cond_pag.cod_portador = int(portador_convenio)
                                AND   b_int_ds_loja_cond_pag.cod_esp      = fat-duplic.cod-esp 
                                AND   b_int_ds_loja_cond_pag.cod_emitente = b-emitente.cod-emitente NO-ERROR.
                                
                            IF AVAIL b_int_ds_loja_cond_pag THEN
                            DO:
                            
                                log-manager:write-message("int092 entrou IF COND-PAG: - 2") no-error. 
                            
                                create cst_fat_duplic.
                                assign cst_fat_duplic.cod_portador  = int(portador_convenio)
                                       cst_fat_duplic.modalidade    = 6
                                       cst_fat_duplic.cod_cond_pag  = IF AVAIL b_int_ds_loja_cond_pag THEN int(b_int_ds_loja_cond_pag.condipag) ELSE ?
                                       cst_fat_duplic.condipag      = string(1,"99")
                                       cst_fat_duplic.cod_estabel   = nota-fiscal.cod-estabel
                                       cst_fat_duplic.serie         = nota-fiscal.serie
                                       cst_fat_duplic.nr_fatura     = nota-fiscal.nr-nota-fis
                                       cst_fat_duplic.parcela       = fat-duplic.parcela.

                                FIND FIRST tt-cond-pagto-esp
                                    WHERE tt-cond-pagto-esp.parcela = INT(fat-duplic.parcela) NO-ERROR.

                                assign cst_fat_duplic.adm_cartao    = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.adquirente   else ""
                                       cst_fat_duplic.autorizacao   = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.autorizacao  else ""
                                       cst_fat_duplic.nsu_admin     = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.nsu          else ""
                                       cst_fat_duplic.nsu_numero    = if avail tt-cond-pagto-esp then tt-cond-pagto-esp.nsu          else ""
                                       cst_fat_duplic.taxa_admin    = 0.
                                       
                                
                                IF b_int_ds_loja_cond_pag.CONDIPAG = "12" THEN
                
                                    ASSIGN c-convenio = "".
                                    
                                ELSE IF b_int_ds_loja_cond_pag.CONDIPAG = "83" THEN
                                
                                    ASSIGN c-convenio = "000985".
                                     
                                //KML - 13/01/2026 - ITAIPU convertida para Medme 
                                //ELSE IF b_int_ds_loja_cond_pag.CONDIPAG = "65" THEN 
                                //
                                //    ASSIGN c-convenio = "007934".
                                    
                               
                               
                                IF b_int_ds_loja_cond_pag.CONDIPAG = "65"  THEN
                                DO:
                                
                              
                                    assign cst_nota_fiscal.condipag     = b_int_ds_loja_cond_pag.condipag
                                           cst_nota_fiscal.convenio     = c-convenio
                                           cst_nota_fiscal.cupom_ecf    = emitente.cgc
                                           cst_nota_fiscal.nfce_chave   = "0"
                                           cst_nota_fiscal.valor_chq    = 0
                                           cst_nota_fiscal.cpf_cupom    = emitente.cgc.
                                           
                                END.    
       
                                       
                                IF (b_int_ds_loja_cond_pag.CONDIPAG = "12" OR b_int_ds_loja_cond_pag.CONDIPAG = "83" OR b_int_ds_loja_cond_pag.CONDIPAG = "17")  THEN
                                DO:
                                
                              
                                    assign cst_nota_fiscal.condipag     = b_int_ds_loja_cond_pag.condipag
                                           cst_nota_fiscal.convenio     = c-convenio
                                           cst_nota_fiscal.cupom_ecf    = b-emitente.cgc
                                           cst_nota_fiscal.nfce_chave   = "0"
                                           cst_nota_fiscal.valor_chq    = 0
                                           cst_nota_fiscal.cpf_cupom    = b-emitente.cgc.
                                           
                                END.                     
                            END.      
                        END.
                    END.                                   
                END.
            END.

            RELEASE fat-duplic.


			for first ems2mult.estabelec fields (cgc cod-estabel ) no-lock where 
				estabelec.cod-estabel = nota-fiscal.cod-estabel: 


                log-manager:write-message("criou tt-nota-fiscal") no-error.

			  CREATE tt-nota-fiscal.
              ASSIGN tt-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel
                     tt-nota-fiscal.nr-nota-fis = nota-fiscal.nr-nota-fis
                     tt-nota-fiscal.serie       = nota-fiscal.serie
                     tt-nota-fiscal.chave-acesso = nota-fiscal.cod-chave-aces-nf-eletro
                     tt-nota-fiscal.l-gerada    = YES.
                 
			end.
			FIND FIRST tt-pedido NO-ERROR.
            
            IF tt-pedido.tipopedido = 19 AND tt-pedido.tipopedido = 2 THEN DO:  // se or nota de transferencia cria saida e entrada caso contraio somente saida
         
                // KML - envio datahub de notas               
                .RUN intprg/int301rp.p ( INPUT "Saida"  ,
                                        INPUT "Saida-Transferencia" ,
                                        INPUT ROWID(nota-fiscal) ).
         
            END.							 		 				
        end.

	    FIND FIRST tt-pedido NO-ERROR.
        
        LOG-MANAGER:write-message("KML - Transferencia - tipo do pedido  - " + string(tt-pedido.tipopedido) ) no-error.
        
        IF (tt-pedido.tipopedido = 19 OR tt-pedido.tipopedido = 2) THEN DO:  // se or nota de transferencia cria saida e entrada caso contraio somente saida
            RUN p-gera_entrada.
            
        END.
        ELSE DO:
            RUN pi-cria-int-ds-nota.
        
        END.	
        RELEASE nota-fiscal.
    end.
    
END PROCEDURE.

PROCEDURE p_cria_cliente:

    log-manager:write-message("Entrou Cria Cliente" + tt-cliente.cnpj) no-error.

    DEFINE OUTPUT PARAMETER i-cod-emitente AS INTEGER NO-UNDO.

    CREATE BUFFER bhtt-emitente FOR TABLE "emitente".
    CREATE TEMP-TABLE tth-emitente.        
    tth-emitente:CREATE-LIKE(bhtt-emitente).        
    tth-emitente:ADD-NEW-FIELD("r-rowid","rowid").         
    tth-emitente:TEMP-TABLE-PREPARE("tt-emitente").        
    bhtt-emitente = tth-emitente:DEFAULT-BUFFER-HANDLE. 
    
    bhtt-emitente:BUFFER-CREATE.
    
    RUN cdp/cd9960.p (OUTPUT i-emitente).
    
    IF NOT VALID-HANDLE(h-bo) THEN
        RUN adbo/boad098.p PERSISTENT SET h-bo.

    FIND FIRST ems2dis.cidade NO-LOCK
        WHERE cidade.cdn-munpio-ibge = int(tt-cliente.cod-ibge) NO-ERROR.
    IF AVAIL cidade THEN DO:
        ASSIGN tt-cliente.cidade = cidade.cidade.
    END.

    ASSIGN bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE  = i-emitente
           bhtt-emitente:BUFFER-FIELD("end-cobranca"):BUFFER-VALUE  = i-emitente
           bhtt-emitente:BUFFER-FIELD("nome-abrev"):BUFFER-VALUE    = tt-cliente.nome-abrev
           bhtt-emitente:BUFFER-FIELD("nome-matriz"):BUFFER-VALUE   = tt-cliente.nome-abrev
           bhtt-emitente:BUFFER-FIELD("cgc"):BUFFER-VALUE           = tt-cliente.cnpj
           bhtt-emitente:BUFFER-FIELD("identific"):BUFFER-VALUE     = 1 /* sempre cliente */
           bhtt-emitente:BUFFER-FIELD("natureza"):BUFFER-VALUE      = tt-cliente.natureza 
           bhtt-emitente:BUFFER-FIELD("nome-emit"):BUFFER-VALUE     = tt-cliente.nome
           bhtt-emitente:BUFFER-FIELD("endereco"):BUFFER-VALUE      = tt-cliente.endereco + "," + tt-cliente.numero
           bhtt-emitente:BUFFER-FIELD("bairro"):BUFFER-VALUE        = SUBSTRING(tt-cliente.bairro,1,30)
           bhtt-emitente:BUFFER-FIELD("cidade"):BUFFER-VALUE        = tt-cliente.cidade
           bhtt-emitente:BUFFER-FIELD("estado"):BUFFER-VALUE        = tt-cliente.estado
           bhtt-emitente:BUFFER-FIELD("cep"):BUFFER-VALUE           = tt-cliente.cep 
           bhtt-emitente:BUFFER-FIELD("pais"):BUFFER-VALUE          = tt-cliente.pais 
           bhtt-emitente:BUFFER-FIELD("cod-gr-cli"):BUFFER-VALUE    = 5 // fixo at que seja pensado cliente convenio para e-commerce
           bhtt-emitente:BUFFER-FIELD("portador"):BUFFER-VALUE      = 99999 
           bhtt-emitente:BUFFER-FIELD("modalidade"):BUFFER-VALUE    = 6
           bhtt-emitente:BUFFER-FIELD("cod-rep"):BUFFER-VALUE       = 1
           bhtt-emitente:BUFFER-FIELD("cod-transp"):BUFFER-VALUE    = 99999
           bhtt-emitente:BUFFER-FIELD("tp-rec-padrao"):BUFFER-VALUE = 208
           bhtt-emitente:BUFFER-FIELD("endereco-cob"):BUFFER-VALUE  = tt-cliente.endereco + "," + tt-cliente.numero
           bhtt-emitente:BUFFER-FIELD("bairro-cob"):BUFFER-VALUE    = SUBSTRING(tt-cliente.bairro,1,30)
           bhtt-emitente:BUFFER-FIELD("cidade-cob"):BUFFER-VALUE    = tt-cliente.cidade
           bhtt-emitente:BUFFER-FIELD("estado-cob"):BUFFER-VALUE    = tt-cliente.estado
           bhtt-emitente:BUFFER-FIELD("cep-cob"):BUFFER-VALUE       = tt-cliente.cep 
           bhtt-emitente:BUFFER-FIELD("pais-cob"):BUFFER-VALUE      = tt-cliente.pais 
           bhtt-emitente:BUFFER-FIELD("cgc-cob"):BUFFER-VALUE       = tt-cliente.cnpj
           bhtt-emitente:BUFFER-FIELD("ins-estadual"):BUFFER-VALUE  = IF tt-cliente.natureza = 1 THEN "ISENTO" ELSE tt-cliente.ins-estadual
           bhtt-emitente:BUFFER-FIELD("contrib-icms"):BUFFER-VALUE  = NO
           bhtt-emitente:BUFFER-FIELD("ins-est-cob"):BUFFER-VALUE   = IF tt-cliente.natureza = 1 THEN "ISENTO" ELSE tt-cliente.ins-estadual
           bhtt-emitente:BUFFER-FIELD("modalidade-ap"):BUFFER-VALUE = 6
           bhtt-emitente:BUFFER-FIELD("tp-desp-padrao"):BUFFER-VALUE = 407
           bhtt-emitente:BUFFER-FIELD("cod-gr-forn"):BUFFER-VALUE   = 10.

    RUN validateCreate IN h-bo (INPUT TABLE-HANDLE tth-emitente, OUTPUT TABLE tt-bo-erro, OUTPUT r-chave).


    FIND FIRST ems2mult.emitente NO-LOCK
        WHERE emitente.cod-emitente = bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE NO-ERROR.

    IF AVAIL emitente THEN DO:
        
        run cdp/cd1608.p (input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                      input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                      input 1,
                      input yes,
                      input 1,
                      input 0,
                      input session:temp-dir + "integracaoEMS5.txt",
                      input "Arquivo",
                      input "").
        ASSIGN i-cod-emitente = emitente.cod-emitente.

        RUN pi-cria-int-ds-cliente.
    END.
/*     FOR FIRST tt-bo-erro:                                                                                        */
/*                                                                                                                  */
/*         RUN intprg/int999.p (INPUT "CLI",                                                                        */
/*                             INPUT STRING(tt-cliente.cnpj),                                                       */
/*                             INPUT string(tt-bo-erro.mensagem) + " - CPF/CNPJ: " + string(tt-cliente.cnpj) + ".", */
/*                             INPUT 1, /* 2 - Integrado */                                                         */
/*                             INPUT c-seg-usuario,                                                                 */
/*                             INPUT "int092api.p").                                                                */
/*                                                                                                                  */
/*     END.                                                                                                         */

    run cdp/cd1608.p (input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                  input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                  input i-identific,
                  input yes,
                  input 1,
                  input 0,
                  input session:temp-dir + "integracaoEMS5.txt",
                  input "Arquivo",
                  input "").
    
    FIND FIRST loc-entr EXCLUSIVE-LOCK
        WHERE loc-entr.nome-abrev  = emitente.nome-abrev 
          AND loc-entr.cod-entrega = "Padr��o" NO-ERROR.

    IF AVAIL emitente THEN DO:
        
        IF NOT AVAIL loc-entr THEN DO:
            CREATE loc-entr.
            ASSIGN loc-entr.nome-abrev  = emitente.nome-abrev  
                    loc-entr.cod-entrega = "Padr��o".            
        END.
        ASSIGN loc-entr.endereco     = emitente.endereco
               loc-entr.bairro       = emitente.bairro
               loc-entr.cidade       = emitente.cidade
               loc-entr.estado       = emitente.estado
               loc-entr.pais         = emitente.pais
               loc-entr.cep          = emitente.cep
               loc-entr.ins-estadual = emitente.ins-estadual
               loc-entr.cgc          = emitente.cgc.
    END.

    RELEASE loc-entr.

/*     RUN intprg/int999.p (INPUT "CLI",                                                                       */
/*                         INPUT STRING(tt-cliente.cnpj),                                                      */
/*                         INPUT "Cliente integrado com sucesso - CPF/CNPJ: " + string(tt-cliente.cnpj) + ".", */
/*                         INPUT 2, /* 2 - Integrado */                                                        */
/*                         INPUT c-seg-usuario,                                                                */
/*                         INPUT "int092api.p").                                                               */

       log-manager:write-message("FIM PROCEDURE") no-error.
    
END PROCEDURE.

PROCEDURE p_altera_cliente:

    DEFINE INPUT PARAMETER i-cod-emitente AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER l-movto-erro AS LOGICAL NO-UNDO.

    ASSIGN l-movto-erro = NO.


    FIND FIRST ems2mult.emitente NO-LOCK
        WHERE emitente.cod-emitente = i-cod-emitente NO-ERROR.
    IF AVAIL emitente THEN DO:
    
        FIND FIRST ems2dis.cidade NO-LOCK
            WHERE cidade.cdn-munpio-ibge = int(tt-cliente.cod-ibge) NO-ERROR.
        IF AVAIL cidade THEN DO:
            ASSIGN tt-cliente.cidade = cidade.cidade.
        END.
            // kml
        MESSAGE "ALTERANDO CLIENTE" SKIP
                "ENDERECO - " tt-cliente.endereco
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        FIND FIRST b-emitente EXCLUSIVE-LOCK
            WHERE b-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.

        IF LOCKED b-emitente THEN DO:

           CREATE tt-nota-fiscal.
           ASSIGN tt-nota-fiscal.cod-estabel = ""
                  tt-nota-fiscal.nr-nota-fis = ""
                  tt-nota-fiscal.serie       = ""
                  tt-nota-fiscal.chave-acesso = ""
                  tt-nota-fiscal.l-gerada    = NO
                  tt-nota-fiscal.desc-erro   = "Tabela emitente em lock NO banco".
    
    
           ASSIGN l-movto-erro = YES.

           undo, leave.

        END.
        IF AVAIL b-emitente THEN DO:
        
            ASSIGN b-emitente.natureza      = tt-cliente.natureza 
                   b-emitente.nome-emit     = tt-cliente.nome
                   b-emitente.endereco      = tt-cliente.endereco + "," + tt-cliente.numero
                   b-emitente.bairro        = SUBSTRING(tt-cliente.bairro,1,30)
                   //b-emitente.cod-gr-cli    = 05 // InclusÆo KML para corrigir erro na integraÆo com o Financeiro
                   b-emitente.cidade        = tt-cliente.cidade
                   b-emitente.estado        = tt-cliente.estado
                   b-emitente.cep           = tt-cliente.cep 
                   b-emitente.pais          = tt-cliente.pais 
                   b-emitente.endereco-cob  = tt-cliente.endereco + "," + tt-cliente.numero
                   b-emitente.bairro-cob    = SUBSTRING(tt-cliente.bairro,1,30)
                   b-emitente.cidade-cob    = tt-cliente.cidade
                   b-emitente.estado-cob    = tt-cliente.estado
                   b-emitente.cep-cob       = tt-cliente.cep 
                   b-emitente.pais-cob      = tt-cliente.pais
                   b-emitente.contrib-icms  = NO .
        END.
        RELEASE b-emitente.

        RUN pi-cria-int-ds-cliente.
                    
        FIND FIRST loc-entr EXCLUSIVE-LOCK
            WHERE loc-entr.nome-abrev  = emitente.nome-abrev 
              AND loc-entr.cod-entrega = "Padr��o" NO-ERROR.

    
        IF NOT AVAIL loc-entr THEN DO:
            CREATE loc-entr.
            ASSIGN loc-entr.nome-abrev  = emitente.nome-abrev  
                    loc-entr.cod-entrega = "Padr��o".            
        END.
        
        ASSIGN loc-entr.endereco     = emitente.endereco
               loc-entr.bairro       = emitente.bairro
               loc-entr.cidade       = emitente.cidade
               loc-entr.estado       = emitente.estado
               loc-entr.pais         = emitente.pais
               loc-entr.cep          = emitente.cep
               loc-entr.ins-estadual = emitente.ins-estadual
               loc-entr.cgc          = emitente.cgc.
            
    END.
    RELEASE emitente.
    RELEASE loc-entr.
    
END PROCEDURE.

PROCEDURE p_valida_cliente:

    DEFINE OUTPUT PARAMETER l-movto-erro AS LOGICAL NO-UNDO.

    ASSIGN l-movto-erro = NO.

    // Retornar erro se o CPF/CNPJ estiver em branco
    IF tt-cliente.cnpj = ?
    OR tt-cliente.cnpj = "?" 
    OR tt-cliente.cnpj = "" THEN DO:

       CREATE tt-nota-fiscal.
       ASSIGN tt-nota-fiscal.cod-estabel = ""
              tt-nota-fiscal.nr-nota-fis = ""
              tt-nota-fiscal.serie       = ""
              tt-nota-fiscal.chave-acesso = ""
              tt-nota-fiscal.l-gerada    = NO
              tt-nota-fiscal.desc-erro   = "CNPJ/CPF est� branco ou desconhecido".


       ASSIGN l-movto-erro = YES.
      // LEAVE.
    END.
    
    // Ajustando formato do CNPJ e CPF

    IF tt-cliente.natureza = 1 /*Pessoa Fisica */ THEN DO:
        ASSIGN tt-cliente.cnpj = string(int64(tt-cliente.cnpj), "99999999999").
    END.
    ELSE DO:
        ASSIGN tt-cliente.cnpj = string(int64(tt-cliente.cnpj), "99999999999999").
    END.

    ASSIGN tt-cliente.nome-abrev = STRING( "CL" + substring(trim(string(DEC(tt-cliente.cnpj))),1,10)).

    /*
    FIND FIRST emitente NO-LOCK
        WHERE emitente.nome-abrev = tt-cliente.nome-abrev NO-ERROR.

    IF AVAIL emitente THEN DO:

        CREATE tt-nota-fiscal.
        ASSIGN tt-nota-fiscal.cod-estabel = ""
               tt-nota-fiscal.nr-nota-fis = ""
               tt-nota-fiscal.serie       = ""
               tt-nota-fiscal.l-gerada    = NO
               tt-nota-fiscal.desc-erro   = "Nome abreviado ja existe na base".


       ASSIGN l-movto-erro = YES.
       MESSAGE "nome abreviado ja existe"
           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       //LEAVE.
                                                     

    END.
      */
    // Retornar erro se o nome do cliente inv lido

    IF tt-cliente.nome = ?
    OR tt-cliente.nome = "?" 
    OR tt-cliente.nome = "" THEN DO:

       CREATE tt-nota-fiscal.
       ASSIGN tt-nota-fiscal.cod-estabel = ""
              tt-nota-fiscal.nr-nota-fis = ""
              tt-nota-fiscal.serie       = ""
              tt-nota-fiscal.chave-acesso = ""
              tt-nota-fiscal.l-gerada    = NO
              tt-nota-fiscal.desc-erro   = "Nome do Cliente esta branco ou desconhecido".



       ASSIGN l-movto-erro = YES.
      // LEAVE.
    END.
  
    // Retornar erro se o CEP estiver em branco

    IF tt-cliente.cep = ?
    OR tt-cliente.cep = "?" 
    OR tt-cliente.cep = "" THEN DO:

        CREATE tt-nota-fiscal.
        ASSIGN tt-nota-fiscal.cod-estabel = ""
               tt-nota-fiscal.nr-nota-fis = ""
               tt-nota-fiscal.serie       = ""
               tt-nota-fiscal.chave-acesso = ""
               tt-nota-fiscal.l-gerada    = NO
               tt-nota-fiscal.desc-erro   = "CEP do Cliente est� branco ou desconhecido".

       ASSIGN l-movto-erro = YES.
      // LEAVE.
    END.

END PROCEDURE.

PROCEDURE pi-cria-int-ds-cliente:

    FIND FIRST ems2dis.cidade NO-LOCK
        WHERE cidade.cidade = emitente.cidade
        AND   cidade.estado = emitente.estado
        AND   cidade.pais   = emitente.pais NO-ERROR.


    CREATE INT_DS_CLIENTE.
    ASSIGN int_ds_cliente.bairro            = emitente.bairro
           int_ds_cliente.cep               = emitente.cep   
           int_ds_cliente.cgc               = emitente.cgc   
           int_ds_cliente.cidade            = emitente.cidade
           int_ds_cliente.estado            = emitente.estado
           int_ds_cliente.pais              = emitente.pais
           int_ds_cliente.cod_emitente      = emitente.cod-emitente
           int_ds_cliente.cod_gr_cli        = emitente.cod-gr-cli
           int_ds_cliente.cod_mun_ibge      = cidade.cdn-munpio-ibge
           int_ds_cliente.cod_usuario       = c-seg-usuario
           int_ds_cliente.dt_geracao        = TODAY
           int_ds_cliente.endereco          = emitente.endereco
           int_ds_cliente.hr_geracao        = ""
           int_ds_cliente.identific         = emitente.identific
           int_ds_cliente.ins_estadual      = emitente.ins-estadual
           int_ds_cliente.natureza          = emitente.natureza
           int_ds_cliente.nome_abrev        = emitente.nome-abrev
           int_ds_cliente.nome_emit         = emitente.nome-emit
           int_ds_cliente.origem_cli        = 3
           int_ds_cliente.cnpj_emp_conv     = ""
           int_ds_cliente.ENVIO_DATA_HORA   = NOW
           int_ds_cliente.ENVIO_ERRO        = ""
           int_ds_cliente.ENVIO_STATUS      = 1
           int_ds_cliente.ID_SEQUENCIAL     = NEXT-VALUE(seq_int_ds_cliente)
           int_ds_cliente.retorno_validacao = ""
           int_ds_cliente.situacao          = 2
           int_ds_cliente.tipo_movto        = 1.

    RELEASE INT_DS_CLIENTE. 

END PROCEDURE.

PROCEDURE pi-cria-int-ds-nota:

log-manager:write-message("dentro da procedure pi-cria-int-ds-nota ") no-error.

    DEFINE VARIABLE l-sub       AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE l-ok        AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE de-valor    AS DECIMAL     NO-UNDO.

    FOR FIRST ems2mult.estabelec NO-LOCK
        WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel: END.

    for each it-nota-fisc no-lock of nota-fiscal:

        FIND first ITEM no-lock where 
            item.it-codigo = it-nota-fisc.it-codigo NO-ERROR.
                
        IF NOT AVAIL ITEM THEN NEXT.
          
        log-manager:write-message("DEpois if not avail" + item.it-codigo) no-error.

        create  int_ds_nota_saida_item.                        
        assign  int_ds_nota_saida_item.nsa_cnpj_origem_s       = estabelec.cgc      
                int_ds_nota_saida_item.nsa_notafiscal_n        = integer(nota-fiscal.nr-nota-fis)                      
                int_ds_nota_saida_item.nsa_serie_s             = nota-fiscal.serie                                     
                int_ds_nota_saida_item.nsp_sequencia_n         = it-nota-fisc.nr-seq-fat
                int_ds_nota_saida_item.nsp_produto_n           = int(it-nota-fisc.it-codigo)
                int_ds_nota_saida_item.nsp_quantidade_n        = it-nota-fisc.qt-faturada[1]
                int_ds_nota_saida_item.nsp_valorbruto_n        = it-nota-fisc.vl-merc-ori
                int_ds_nota_saida_item.nsp_desconto_n          = it-nota-fisc.vl-desconto
                int_ds_nota_saida_item.nsp_valorliquido_n      = it-nota-fisc.vl-merc-liq
                int_ds_nota_saida_item.nsp_baseicms_n          = if it-nota-fisc.cd-trib-icm = 1 or  /*tributado*/
                                                                 it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                 it-nota-fisc.cd-trib-icm = 3     /*Outros*/
                                                                 then it-nota-fisc.vl-bicms-it else 0
                int_ds_nota_saida_item.nsp_valoricms_n         = it-nota-fisc.vl-icms-it
                int_ds_nota_saida_item.nsp_basediferido_n      = if it-nota-fisc.cd-trib-icm = 5     /*diferido*/
                                                                 then it-nota-fisc.vl-bicms-it else 0
                int_ds_nota_saida_item.nsp_baseisenta_n        = if it-nota-fisc.cd-trib-icm = 2 or
                                                                 it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                 it-nota-fisc.cd-trib-icm = 3     /*isento*/
                                                                 then it-nota-fisc.vl-icmsnt-it else 0.

        assign  int_ds_nota_saida_item.nsp_valoripi_n          = 0 /*it-nota-fisc.vl-ipi-it*/
                int_ds_nota_saida_item.nsp_icmsst_n            = it-nota-fisc.vl-icmsub-it
                int_ds_nota_saida_item.nsp_basest_n            = it-nota-fisc.vl-bsubs-it
                int_ds_nota_saida_item.nsp_valortotalproduto_n = it-nota-fisc.vl-tot-item.

        assign  int_ds_nota_saida_item.nsp_percentualicms_n    = it-nota-fisc.aliquota-icm
                int_ds_nota_saida_item.nsp_percentualipi_n     = 0 /*it-nota-fisc.aliquota-ipi*/
                int_ds_nota_saida_item.nsp_redutorbaseicms_n   = it-nota-fisc.perc-red-icm.
        assign  int_ds_nota_saida_item.nsp_valordespesa_n      = it-nota-fisc.vl-despes-it
                int_ds_nota_saida_item.nsp_valorpis_n          = it-nota-fisc.vl-pis
                int_ds_nota_saida_item.nsp_valorcofins_n       = it-nota-fisc.vl-finsocial
                int_ds_nota_saida_item.nsp_peso_n              = it-nota-fisc.peso-bruto
                int_ds_nota_saida_item.nsp_baseipi_n           = 0 /*it-nota-fisc.vl-bipi-it*/.
        assign  int_ds_nota_saida_item.nsp_ncm_s               = if   it-nota-fisc.class-fiscal <> ""
                                                                 then it-nota-fisc.class-fiscal
                                                                 else item.class-fiscal
                int_ds_nota_saida_item.nsp_csta_n              = item.codigo-orig
                int_ds_nota_saida_item.nsp_valortributos_n     = int_ds_nota_saida_item.nsp_valoricms_n 
                                                               + int_ds_nota_saida_item.nsp_valoripi_n
                                                               + int_ds_nota_saida_item.nsp_icmsst_n
                                                               + int_ds_nota_saida_item.nsp_valorpis_n
                                                               + int_ds_nota_saida_item.nsp_valorcofins_n.
                                                               
        //log-manager:write-message("int_ds_nota_saida_item CRIADO" + string(int_ds_nota_saida_item.nsp_produto_n)) no-error.                                                       

        RUN pi-custo-grade (OUTPUT int_ds_nota_saida_item.nsp_valorgrade_n).

        run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                           output int_ds_nota_saida_item.nsp_cstb_n,
                           output l-sub).
                           
        log-manager:write-message("DEPOIS FTP" + string(int_ds_nota_saida_item.nsp_produto_n)) no-error.
        
        for first natur-oper NO-LOCK 
            WHERE natur-oper.nat-operacao = it-nota-fisc.nat-operacao:
   
            assign  int_ds_nota_saida_item.nsp_cfop_n = int(replace(natur-oper.cod-cfop,".","")).
        end.
        
        log-manager:write-message("Antes dos ASSIGN" + string(int_ds_nota_saida_item.nsp_produto_n)) no-error. 

        IF AVAIL ITEM THEN
        DO:
            
        
            assign  int_ds_nota_saida_item.ped_codigo_n            = 0
                    int_ds_nota_saida_item.nsp_basepis_n           = it-nota-fisc.vl-tot-item
                                                                    - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                       or  substr(item.char-1,50,5) = "Sim"
                                                                       then   it-nota-fisc.vl-pis
                                                                            + it-nota-fisc.vl-finsocial
                                                                         else 0)
                                                                    - (if natur-oper.tp-oper-terc = 4
                                                                       then it-nota-fisc.vl-icmsubit-e[3]
                                                                       else it-nota-fisc.vl-icmsub-it)
                    int_ds_nota_saida_item.nsp_basecofins_n        = it-nota-fisc.vl-tot-item
                                                                    - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                       or  substr(item.char-1,50,5) = "Sim"
                                                                       then   it-nota-fisc.vl-pis
                                                                            + it-nota-fisc.vl-finsocial
                                                                       else 0)
                                                                    - (if natur-oper.tP-oper-terc = 4
                                                                       then it-nota-fisc.vl-icmsubit-e[3]
                                                                       else it-nota-fisc.vl-icmsub-it) NO-ERROR.
             
            log-manager:write-message("MEIO PASSOU") no-error.
        END.                                                              
            
            /*Nao inclui o valor no IPI na base das contrib sociais*/    
            if  it-nota-fisc.cd-trib-ipi <> 3
            and not natur-oper.log-ipi-contrib-social then do:
                 assign int_ds_nota_saida_item.nsp_basepis_n = int_ds_nota_saida_item.nsp_basepis_n
                                                               /*- it-nota-fisc.vl-ipi-it*/
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                 assign int_ds_nota_saida_item.nsp_basecofins_n = int_ds_nota_saida_item.nsp_basecofins_n
                                                                /*- it-nota-fisc.vl-ipi-it*/
                                                                - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                   then it-nota-fisc.vl-ipiit-e[3]
                                                                   else 0) NO-ERROR.
            end.
        
        log-manager:write-message("02 MEIO PASSOU") no-error.
        
        /*Nao inclui o valor no IPI OUTRAS na base das contrib sociais*/
        if  it-nota-fisc.cd-trib-ipi = 3 
        and substring(natur-oper.char-2,16,1) = "1":U
        and not natur-oper.log-ipi-outras-contrib-social then do:
            assign int_ds_nota_saida_item.nsp_basepis_n = int_ds_nota_saida_item.nsp_basepis_n
                                                       /*- it-nota-fisc.vl-ipi-it*/
                                                       - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                          then it-nota-fisc.vl-ipiit-e[3]
                                                          else 0).
            assign int_ds_nota_saida_item.nsp_basecofins_n = int_ds_nota_saida_item.nsp_basecofins_n
                                                       /*- it-nota-fisc.vl-ipi-it*/
                                                       - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                          then it-nota-fisc.vl-ipiit-e[3]
                                                          else 0).
        end.
        
        log-manager:write-message("03 MEIO PASSOU") no-error.
        
        assign  int_ds_nota_saida_item.nsp_cstbpis_s           = if substr(it-nota-fisc.char-2,96,1) = "1" then "01"
                                                                 else if substr(it-nota-fisc.char-2,96,1) = "1" then "07"
                                                                 else if substr(it-nota-fisc.char-2,96,1) = "3" then "02"
                                                                 else if it-nota-fisc.idi-forma-calc-pis = 2 then "03" else "99"
                int_ds_nota_saida_item.nsp_cstbcofins_s        = if substr(it-nota-fisc.char-2,97,1) = "1" then "01"
                                                                 else if substr(it-nota-fisc.char-2,97,1) = "1" then "07"
                                                                 else if substr(it-nota-fisc.char-2,97,1) = "3" then "02"
                                                                 else if it-nota-fisc.idi-forma-calc-cofins = 2 then "03" else "99"
                int_ds_nota_saida_item.nsp_percentualpis_n     = decimal(substr(it-nota-fisc.char-2,76,5))
                                                               * (100 - if substr(it-nota-fisc.char-2,96,1) = "3"  /* Reduzido */
                                                                        or substr(it-nota-fisc.char-2,96,1) = "4"  /* Outros   */
                                                                        then decimal(substr(it-nota-fisc.char-2,86,5))
                                                                        else 0)
                                                               / 100.
                int_ds_nota_saida_item.nsp_percentualcofins_n  = decimal(substr(it-nota-fisc.char-2,81,5))
                                                               * (100 - if substr(it-nota-fisc.char-2,97,1) = "3"  /* Reduzido */
                                                                        or substr(it-nota-fisc.char-2,97,1) = "4"  /* Outros   */
                                                                        then decimal(substr(it-nota-fisc.char-2,91,5))
                                                                        else 0)
                                                               / 100.
                                                               
        log-manager:write-message(" 04 MEIO PASSOU") no-error.                                                      
                                                               
        for first fat-ser-lote no-lock of it-nota-fisc:
            assign  int_ds_nota_saida_item.nsp_lote_s  = substring(fat-ser-lote.nr-serlote,1,10)
                    int_ds_nota_saida_item.nsp_datavalidade_d = fat-ser-lote.dt-vali-lote.
        end.
        
        log-manager:write-message(" 05 MEIO PASSOU") no-error. 

        assign  int_ds_nota_saida_item.nen_notafiscal_n = integer(it-nota-fisc.nr-docum)
                int_ds_nota_saida_item.nen_serie_s      = it-nota-fisc.serie-docum.
        if it-nota-fisc.nr-docum <> "" then do:
            for first rat-lote no-lock where 
                rat-lote.serie-docto  = it-nota-fisc.nr-docum and    
                rat-lote.nro-docto    = it-nota-fisc.serie-docum and 
                rat-lote.nat-operacao = it-nota-fisc.nat-docum and   
                rat-lote.cod-emitente = nota-fiscal.cod-emitente and 
                rat-lote.sequencia    > 0 and 
                rat-lote.it-codigo    = it-nota-fisc.it-codigo and
                rat-lote.lote = int_ds_nota_saida_item.nsp_lote_s
                :
                assign int_ds_nota_saida_item.nep_sequencia_n  = rat-lote.sequencia.
            end.
        end.
        
        LOG-MANAGER:write-message("FIM CRIA  O ITEM" + STRING(int_ds_nota_saida_item.nsp_produto)) no-error.

        assign int_ds_nota_saida_item.nsp_caixa_n = int(it-nota-fisc.nr-seq-ped).

        release int_ds_nota_saida_item.
        
        
    end.  /* it-nota-fisc */
    
    
    log-manager:write-message(" 06 MEIO PASSOU") no-error. 

    create  int_ds_nota_saida.
    assign  int_ds_nota_saida.ENVIO_STATUS       = 8 //ERA 1
            int_ds_nota_saida.ORIGEM_PEDIDO      = 2
            int_ds_nota_saida.nsa_cnpj_origem_s  = estabelec.cgc
            int_ds_nota_saida.nsa_notafiscal_n   = integer(nota-fiscal.nr-nota-fis)
            int_ds_nota_saida.nsa_serie_s        = nota-fiscal.serie
            int_ds_nota_saida.nsa_cnpj_destino_s = nota-fiscal.cgc
            int_ds_nota_saida.nsa_dataemissao_d  = nota-fiscal.dt-emis-nota
            int_ds_nota_saida.nsa_chaveacesso_s  = &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                                        trim(substring(nota-fiscal.cod-chave-aces-nf-eletro,1,44))
                                                   &else
                                                        trim(substring(nota-fiscal.char-2,3,44))
                                                   &endif
            int_ds_nota_saida.ped_codigo_n       = 0 
            int_ds_nota_saida.ped_procfit        = 0
            int_ds_nota_saida.id_sequencial      = next-VALUE(seq-int-ds-nota-saida)
            int_ds_nota_saida.ENVIO_DATA_HORA    = datetime(today).

    for first natur-oper no-lock where 
        natur-oper.nat-operacao = nota-fiscal.nat-operacao
        :
        assign int_ds_nota_saida.nsa_cfop_n       = integer(replace(natur-oper.cod-cfop,".","")).
    end.
    assign  int_ds_nota_saida.tipo_movto          = 1 /* inclusao */
            int_ds_nota_saida.nsa_cnpj_destino_s  = nota-fiscal.cgc
            int_ds_nota_saida.nsa_dataemissao_d   = nota-fiscal.dt-emis-nota
            int_ds_nota_saida.nsa_placaveiculo_s  = substring(replace(nota-fiscal.placa," ",""),1,7)
            int_ds_nota_saida.nsa_estadoveiculo_s = substring(replace(nota-fiscal.uf-placa," ",""),1,2)
            int_ds_nota_saida.nsa_observacao_s    = substring(nota-fiscal.observ-nota,1,4000).
            
     log-manager:write-message(" 07 MEIO PASSOU") no-error.        

    /*
    for first transporte fields (cgc) no-lock where 
        transporte.nome-abrev = nota-fiscal.nome-transp:
        assign  int_ds_nota_saida.nsa-cnpj-transportadora-s = transporte.cgc.
    end.
    */
    for each int_ds_nota_saida_item no-lock of int_ds_nota_saida:

        assign  int_ds_nota_saida.nsa_valortotalprodutos_n     = int_ds_nota_saida.nsa_valortotalprodutos_n
                                                               + int_ds_nota_saida_item.nsp_valortotalproduto_n
                int_ds_nota_saida.nsa_quantidade_n             = int_ds_nota_saida.nsa_quantidade_n 
                                                               + int_ds_nota_saida_item.nsp_quantidade_n
                int_ds_nota_saida.nsa_desconto_n               = int_ds_nota_saida.nsa_desconto_n 
                                                               + int_ds_nota_saida_item.nsp_desconto_n
                int_ds_nota_saida.nsa_baseicms_n               = int_ds_nota_saida.nsa_baseicms_n
                                                               + int_ds_nota_saida_item.nsp_baseicms_n
                int_ds_nota_saida.nsa_valoricms_n              = int_ds_nota_saida.nsa_valoricms_n
                                                               + int_ds_nota_saida_item.nsp_valoricms_n
                int_ds_nota_saida.nsa_basediferido_n           = int_ds_nota_saida.nsa_basediferido_n 
                                                               + int_ds_nota_saida_item.nsp_basediferido_n
                int_ds_nota_saida.nsa_baseisenta_n             = int_ds_nota_saida.nsa_baseisenta_n
                                                               + int_ds_nota_saida_item.nsp_baseisenta_n
                int_ds_nota_saida.nsa_baseipi_n                = int_ds_nota_saida.nsa_baseipi_n
                                                               + int_ds_nota_saida_item.nsp_baseipi_n
                int_ds_nota_saida.nsa_valoripi_n               = int_ds_nota_saida.nsa_valoripi_n 
                                                               + int_ds_nota_saida_item.nsp_valoripi_n
                int_ds_nota_saida.nsa_basest_n                 = int_ds_nota_saida.nsa_basest_n
                                                               + int_ds_nota_saida_item.nsp_basest_n
                int_ds_nota_saida.nsa_icmsst_n                 = int_ds_nota_saida.nsa_icmsst_n
                                                               + int_ds_nota_saida_item.nsp_icmsst_n.

    end. /* int_ds_nota_saida_item */

    assign  int_ds_nota_saida.dt_geracao   = today
            int_ds_nota_saida.hr_geracao   = string(time,"HH:MM:SS")
            //int_ds_nota_saida.situacao     = p-sit-oblak-s
            //int_ds_nota_saida.ENVIO_STATUS = p-sit-procfit-s 
        .

    ASSIGN de-valor = 0.
        
    FOR EACH int_ds_nota_saida_item OF int_ds_nota_saida:

        ASSIGN de-valor = de-valor + int_ds_nota_saida_item.nsp_valorbruto_n + int_ds_nota_saida_item.nsp_icmsst_n.

    END.

    FOR EACH fat-duplic NO-LOCK
        WHERE fat-duplic.nr-fatura      = nota-fiscal.nr-nota-fis
          AND fat-duplic.serie          = nota-fiscal.serie
          AND fat-duplic.cod-estabel    = nota-fiscal.cod-estabel:

        FIND FIRST int_ds_loja_cond_pag NO-LOCK
            WHERE int_ds_loja_cond_pag.cod_portador = fat-duplic.int-1 NO-ERROR.


        LOG-MANAGER:write-message("KML - 4 PARCELAS - tt-cond-pagto-esp.origem-pagto  - " + tt-cond-pagto-esp.origem-pagto ) no-error.
        LOG-MANAGER:write-message("KML - 4 PARCELAS - int_ds_loja_cond_pag.CONDIPAG  - " + int_ds_loja_cond_pag.CONDIPAG ) no-error.
        LOG-MANAGER:write-message("KML - 4 PARCELAS - fat-duplic.int-1  - " + STRING(fat-duplic.int-1) ) no-error.
       
        
        CREATE INT_DS_NOTA_SAIDA_PARCELAS.
        ASSIGN INT_DS_NOTA_SAIDA_PARCELAS.NSA_CNPJ_ORIGEM_S = estabelec.cgc
               INT_DS_NOTA_SAIDA_PARCELAS.NSA_NOTAFISCAL_N  = int(nota-fiscal.nr-nota-fis)
               INT_DS_NOTA_SAIDA_PARCELAS.NSA_SERIE_S       = nota-fiscal.serie
               INT_DS_NOTA_SAIDA_PARCELAS.VENCIMENTO        = fat-duplic.dt-venciment
               INT_DS_NOTA_SAIDA_PARCELAS.VALOR             = fat-duplic.vl-parcela
               INT_DS_NOTA_SAIDA_PARCELAS.ORIGEM_PAGTO      = tt-cond-pagto-esp.origem-pagto 
               INT_DS_NOTA_SAIDA_PARCELAS.PARCELA           = int(fat-duplic.parcela)
               INT_DS_NOTA_SAIDA_PARCELAS.nsu               = tt-cond-pagto-esp.nsu
               INT_DS_NOTA_SAIDA_PARCELAS.cod-autorizacao   = tt-cond-pagto-esp.autorizacao
            .
            
        // KML - 02/08/2024 - For ando envio de adquirente e forma de pagamento - Projeto Nexxera
        
        IF tt-cond-pagto-esp.cond-pagto = "Credito" THEN
            assign INT_DS_NOTA_SAIDA_PARCELAS.FORMA_PAGAMENTO   = IF AVAIL int_ds_loja_cond_pag THEN int_ds_loja_cond_pag.CONDIPAG ELSE "" 
                   INT_DS_NOTA_SAIDA_PARCELAS.cod-adquirente    = 450.
                   
        ELSE IF tt-cond-pagto-esp.cond-pagto = "tef_credito" THEN
            assign INT_DS_NOTA_SAIDA_PARCELAS.FORMA_PAGAMENTO   = IF AVAIL int_ds_loja_cond_pag THEN int_ds_loja_cond_pag.CONDIPAG ELSE "" 
                   INT_DS_NOTA_SAIDA_PARCELAS.cod-adquirente    = 450.
        
        
        ELSE IF tt-cond-pagto-esp.cond-pagto = "ifood" THEN
            assign INT_DS_NOTA_SAIDA_PARCELAS.FORMA_PAGAMENTO   = "90"
                   INT_DS_NOTA_SAIDA_PARCELAS.cod-adquirente    = 998.
        ELSE IF tt-cond-pagto-esp.cond-pagto = "pos" THEN
            assign INT_DS_NOTA_SAIDA_PARCELAS.FORMA_PAGAMENTO   = IF AVAIL int_ds_loja_cond_pag THEN int_ds_loja_cond_pag.CONDIPAG ELSE ""
                   INT_DS_NOTA_SAIDA_PARCELAS.cod-adquirente    = 60.
        ELSE IF tt-cond-pagto-esp.cond-pagto = "picpay" THEN
            assign INT_DS_NOTA_SAIDA_PARCELAS.FORMA_PAGAMENTO   = "29"
                   INT_DS_NOTA_SAIDA_PARCELAS.cod-adquirente    = 889.
                   
        ELSE 
            ASSIGN INT_DS_NOTA_SAIDA_PARCELAS.FORMA_PAGAMENTO   = IF AVAIL int_ds_loja_cond_pag THEN int_ds_loja_cond_pag.CONDIPAG ELSE ""
                   INT_DS_NOTA_SAIDA_PARCELAS.cod-adquirente    = ?.

    END.
    
    IF v_cdn_empres_usuar = "1" THEN DO:  // Apenas usuario conectado aos bancos Nissei
          
        IF nota-fiscal.serie = "402" THEN
        DO:
        
            RUN intprg/int301rp.r (INPUT "Saida" ,
                                   INPUT "Saida-Ecommerce" ,
                                   INPUT ROWID(nota-fiscal)). // Envio de notas para datahub
                                   
        END.
    END. 


END PROCEDURE.

PROCEDURE pi-custo-grade:
    DEFINE OUTPUT PARAMETER de-vl-custo-grade AS DECIMAL     NO-UNDO.
    def var i-mo        as int init 1                               no-undo.
    def var i-mo-fasb   as int                                      no-undo.
    def var i-mo-cmi    as int                                      no-undo.
    def var i-moeda     as int format 9                             no-undo.
    DEF VAR l-moed-ifrs-1 AS LOG                                    NO-UNDO.
    DEF VAR l-moed-ifrs-2 AS LOG                                    NO-UNDO.
    DEF VAR de-vl-ipi         AS DEC /*LIKE movto-estoq.valor-ipi */ NO-UNDO.
    DEF VAR de-vl-icms        AS DEC /*LIKE movto-estoq.valor-icm */ NO-UNDO.
    DEF VAR de-vl-pis         AS DEC /*LIKE movto-estoq.valor-pis */ NO-UNDO.
    DEF VAR de-vl-cofins      AS DEC /*LIKE movto-estoq.val-cofins*/ NO-UNDO.
    DEF VAR de-vl-icms-stret  AS DEC /*LIKE movto-estoq.valor-icm */ NO-UNDO.
    
    find first param-global no-lock no-error.
    find first param-estoq  no-lock no-error.
    find first param-fasb   
       where param-fasb.ep-codigo = i-ep-codigo-usuario no-lock no-error.
    
    assign i-mo-fasb = if avail param-fasb
                       then if param-estoq.moeda1 = param-fasb.moeda-fasb 
                            then 2
                            else if param-estoq.moeda2 = param-fasb.moeda-fasb 
                                 then 3
                                 else 0
                       else 0
           i-mo-cmi  = if avail param-fasb
                       then if param-estoq.moeda1 = param-fasb.moeda-cmi 
                            then 2                     
                            else if param-estoq.moeda2 = param-fasb.moeda-cmi 
                                 then 3
                                 else 0
                       else 0.
    IF can-find(first funcao 
                where funcao.cd-funcao = "spp-ifrs-contab-estoq":U 
                  and funcao.ativo     = yes) THEN
        ASSIGN l-moed-ifrs-1 = param-estoq.log-moed-ifrs-1 
               l-moed-ifrs-2 = param-estoq.log-moed-ifrs-2.

    ASSIGN de-vl-custo-grade = 0.

    FOR FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = it-nota-fisc.it-codigo,
        EACH movto-estoq NO-LOCK
        WHERE movto-estoq.cod-estabel  = it-nota-fisc.cod-estabel
        AND   movto-estoq.serie-docto  = it-nota-fisc.serie      
        AND   movto-estoq.nro-docto    = it-nota-fisc.nr-nota-fis
        AND   movto-estoq.cod-emitente = nota-fiscal.cod-emitente
        AND   movto-estoq.sequen-nf    = it-nota-fisc.nr-seq-fat
        AND   movto-estoq.it-codigo    = it-nota-fisc.it-codigo:
    
        ASSIGN de-vl-ipi        = it-nota-fisc.vl-ipi-it  
               de-vl-icms       = it-nota-fisc.vl-icms-it 
               de-vl-pis        = dec(substr(item.char-2,31,5)) * it-nota-fisc.vl-merc-liq / 100
               de-vl-cofins     = dec(substr(item.char-2,36,5)) * it-nota-fisc.vl-merc-liq / 100
               de-vl-icms-stret = 0.

        FOR FIRST esp-item-nfs-st NO-LOCK
            WHERE esp-item-nfs-st.cod-estab-nfs = it-nota-fisc.cod-estabel
            AND   esp-item-nfs-st.cod-ser-nfs   = it-nota-fisc.serie      
            AND   esp-item-nfs-st.cod-docto-nfs = it-nota-fisc.nr-nota-fis
            AND   esp-item-nfs-st.num-seq-nfs   = it-nota-fisc.nr-seq-fat
            AND   esp-item-nfs-st.cod-item      = it-nota-fisc.it-codigo,
            FIRST ems2mult.emitente NO-LOCK
            WHERE emitente.cod-emitente = INT(esp-item-nfs-st.cod-emitente-entr),
            FIRST int_ds_nota_entrada_produt NO-LOCK
            WHERE int_ds_nota_entrada_produt.nen_cnpj_origem_s      = emitente.cgc
            AND   int_ds_nota_entrada_produt.nen_notafiscal_n       = INT(esp-item-nfs-st.cod-nota-entr)
            AND   int_ds_nota_entrada_produt.nen_serie_s            = esp-item-nfs-st.cod-ser-entr
            AND   int_ds_nota_entrada_produt.nep_sequencia_n        = esp-item-nfs-st.num-seq-item-entr
            AND   int_ds_nota_entrada_produt.nep_produto_n          = int(esp-item-nfs-st.cod-item):

            ASSIGN de-vl-icms-stret = int_ds_nota_entrada_produt.de-vicmsstret.
        END.
    
        IF (i-mo = 2 AND l-moed-ifrs-1)
        OR (i-mo = 3 AND l-moed-ifrs-2) THEN DO:
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-ipi,
                              input  movto-estoq.dt-trans,
                              output de-vl-ipi).
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-icms,
                              input  movto-estoq.dt-trans,
                              output de-vl-icms).
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-pis,
                              input  movto-estoq.dt-trans,
                              output de-vl-pis).
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-cofins,
                              input  movto-estoq.dt-trans,
                              output de-vl-cofins).
    
            if  de-vl-ipi    = ? then de-vl-ipi    = 0.
            if  de-vl-icms   = ? then de-vl-icms   = 0.
            if  de-vl-pis    = ? then de-vl-pis    = 0.
            if  de-vl-cofins = ? then de-vl-cofins = 0.
        END.

        if  movto-estoq.tipo-trans = 1 then  do:
            if  movto-estoq.valor-nota > 0 then do:
                assign de-vl-custo-grade = de-vl-custo-grade 
                                         - if  i-mo = 1 then 
                                               movto-estoq.valor-nota
                                           else 
                                                 ( movto-estoq.valor-mat-m[i-mo] 
                                                 + movto-estoq.valor-mob-m[i-mo] 
                                                 + movto-estoq.valor-ggf-m[i-mo]) +
        
                                               if  i-mo = i-mo-fasb then
                                                   (movto-estoq.vl-ipi-fasb[1] +
                                                    movto-estoq.vl-icm-fasb[1] +
                                                    DEC(movto-estoq.vl-pis-fasb) +
                                                    DEC(movto-estoq.val-cofins-fasb) )
                                               else
                                                   if  i-mo = i-mo-cmi then
                                                       (movto-estoq.vl-ipi-fasb[2] +
                                                        movto-estoq.vl-icm-fasb[2] +
                                                        DEC(movto-estoq.vl-pis-cmi) +
                                                        DEC(movto-estoq.val-cofins-cmi) )
                                                   ELSE
                                                       IF (i-mo = 2 AND l-moed-ifrs-1)
                                                       OR (i-mo = 3 AND l-moed-ifrs-2) THEN
                                                           ( de-vl-ipi   
                                                           + de-vl-icms  
                                                           + de-vl-pis   
                                                           + de-vl-cofins)
                                                       else 0.
            end.
            else do:
                assign de-vl-custo-grade = de-vl-custo-grade 
                                         - (  movto-estoq.valor-mat-m[i-mo] 
                                            + movto-estoq.valor-mob-m[i-mo] 
                                            + movto-estoq.valor-ggf-m[i-mo]).
            END.
        
        end.
        
        else do:
            if  movto-estoq.valor-nota > 0 then
                assign de-vl-custo-grade = de-vl-custo-grade 
                                         + if  i-mo = 1 then 
                                               movto-estoq.valor-nota
                                           else 
                                               if  i-mo = i-mo-fasb then
                                                   movto-estoq.vl-nota-fasb[1]
                                               else
                                                   if  i-mo = i-mo-cmi then
                                                       movto-estoq.vl-nota-fasb[2] 
                                                   else
                                                       ( movto-estoq.valor-mat-m[i-mo] 
                                                       + movto-estoq.valor-mob-m[i-mo] 
                                                       + movto-estoq.valor-ggf-m[i-mo]) + 
        
                                                       IF (i-mo = 2 AND l-moed-ifrs-1)
                                                       OR (i-mo = 3 AND l-moed-ifrs-2) THEN
                                                           ( de-vl-ipi   
                                                           + de-vl-icms  
                                                           + de-vl-pis   
                                                           + de-vl-cofins)
                                                       else 0.
            else do:
              assign de-vl-custo-grade = de-vl-custo-grade 
                                       + (  movto-estoq.valor-mat-m[i-mo] 
                                          + movto-estoq.valor-mob-m[i-mo] 
                                          + movto-estoq.valor-ggf-m[i-mo]).
            END.
    
        end.

        IF it-nota-fisc.nat-operacao = "5409a5" or
           it-nota-fisc.nat-operacao = "6409a5" or
		   it-nota-fisc.nat-operacao BEGINS "6152" THEN
            assign de-vl-custo-grade = de-vl-custo-grade 
                                     - de-vl-pis
                                     - de-vl-cofins.

        ASSIGN de-vl-custo-grade = de-vl-custo-grade
                                 - (((int_ds_it_docto_xml.vicmsstret + int_ds_it_docto_xml.vICMSSubs) / int_ds_it_docto_xml.qCom) * it-nota-fisc.qt-faturada[1]).
    END.

    IF it-nota-fisc.nat-operacao BEGINS "6152" THEN DO:
        assign de-vl-custo-grade = de-vl-custo-grade     
                             + it-nota-fisc.vl-icmsub-it.

    END.
    ELSE DO:
        assign de-vl-custo-grade = de-vl-custo-grade 
                             + it-nota-fisc.vl-icms-it
                             + it-nota-fisc.vl-icmsub-it.
    END.
    RETURN "NOK".
END PROCEDURE.

PROCEDURE p-gera_entrada:

    log-manager:write-message("KML - int092api - gera entrada" ) NO-ERROR.

    for each it-nota-fisc no-lock of nota-fiscal:

        for first int_ds_nota_saida_item of int_ds_nota_saida where
            int_ds_nota_saida_item.nsp_sequencia_n = it-nota-fisc.nr-seq-fat and
            int_ds_nota_saida_item.nsp_produto_n   = int(it-nota-fisc.it-codigo): end.

        if not avail int_ds_nota_saida_item then do:

            for first item fields (codigo-orig class-fiscal fm-codigo char-1) no-lock where 
                item.it-codigo = it-nota-fisc.it-codigo: end.

            IF NOT AVAIL ITEM THEN NEXT.
            
            log-manager:write-message("KML - int092api - criando item saida" ) NO-ERROR.

            create  int_ds_nota_saida_item.                        
            assign  int_ds_nota_saida_item.nsa_cnpj_origem_s       = estabelec.cgc      
                    int_ds_nota_saida_item.nsa_notafiscal_n        = integer(nota-fiscal.nr-nota-fis)                      
                    int_ds_nota_saida_item.nsa_serie_s             = nota-fiscal.serie                                     
                    int_ds_nota_saida_item.nsp_sequencia_n         = it-nota-fisc.nr-seq-fat
                    int_ds_nota_saida_item.nsp_produto_n           = int(it-nota-fisc.it-codigo)
                    int_ds_nota_saida_item.nsp_quantidade_n        = it-nota-fisc.qt-faturada[1]
                    int_ds_nota_saida_item.nsp_valorbruto_n        = it-nota-fisc.vl-merc-ori
                    int_ds_nota_saida_item.nsp_desconto_n          = it-nota-fisc.vl-desconto
                    int_ds_nota_saida_item.nsp_valorliquido_n      = it-nota-fisc.vl-merc-liq
                    int_ds_nota_saida_item.nsp_baseicms_n          = if it-nota-fisc.cd-trib-icm = 1 or  /*tributado*/
                                                                     it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                     it-nota-fisc.cd-trib-icm = 3     /*Outros*/
                                                                     then it-nota-fisc.vl-bicms-it else 0
                    int_ds_nota_saida_item.nsp_valoricms_n         = it-nota-fisc.vl-icms-it
                    int_ds_nota_saida_item.nsp_basediferido_n      = if it-nota-fisc.cd-trib-icm = 5     /*diferido*/
                                                                     then it-nota-fisc.vl-bicms-it else 0
                    int_ds_nota_saida_item.nsp_baseisenta_n        = if it-nota-fisc.cd-trib-icm = 2 or
                                                                     it-nota-fisc.cd-trib-icm = 4 or  /*reduzido*/
                                                                     it-nota-fisc.cd-trib-icm = 3     /*isento*/
                                                                     then it-nota-fisc.vl-icmsnt-it else 0.

            assign  int_ds_nota_saida_item.nsp_valoripi_n          = 0 /*it-nota-fisc.vl-ipi-it*/
                    int_ds_nota_saida_item.nsp_icmsst_n            = it-nota-fisc.vl-icmsub-it
                    int_ds_nota_saida_item.nsp_basest_n            = it-nota-fisc.vl-bsubs-it
                    int_ds_nota_saida_item.nsp_valortotalproduto_n = it-nota-fisc.vl-tot-item.

            assign  int_ds_nota_saida_item.nsp_percentualicms_n    = it-nota-fisc.aliquota-icm
                    int_ds_nota_saida_item.nsp_percentualipi_n     = 0 /*it-nota-fisc.aliquota-ipi*/
                    int_ds_nota_saida_item.nsp_redutorbaseicms_n   = it-nota-fisc.perc-red-icm.
            assign  int_ds_nota_saida_item.nsp_valordespesa_n      = it-nota-fisc.vl-despes-it
                    int_ds_nota_saida_item.nsp_valorpis_n          = it-nota-fisc.vl-pis
                    int_ds_nota_saida_item.nsp_valorcofins_n       = it-nota-fisc.vl-finsocial
                    int_ds_nota_saida_item.nsp_peso_n              = it-nota-fisc.peso-bruto
                    int_ds_nota_saida_item.nsp_baseipi_n           = 0 /*it-nota-fisc.vl-bipi-it*/.
            assign  int_ds_nota_saida_item.nsp_ncm_s               = if   it-nota-fisc.class-fiscal <> ""
                                                                     then it-nota-fisc.class-fiscal
                                                                     else item.class-fiscal
                    int_ds_nota_saida_item.nsp_csta_n              = item.codigo-orig
                    int_ds_nota_saida_item.nsp_valortributos_n     = int_ds_nota_saida_item.nsp_valoricms_n 
                                                                   + int_ds_nota_saida_item.nsp_valoripi_n
                                                                   + int_ds_nota_saida_item.nsp_icmsst_n
                                                                   + int_ds_nota_saida_item.nsp_valorpis_n
                                                                   + int_ds_nota_saida_item.nsp_valorcofins_n.
           for first natur-oper 
                fields (cod-cfop tipo tp-oper-terc char-2
                        log-ipi-contrib-social log-ipi-outras-contrib-social) 
                no-lock where 
                natur-oper.nat-operacao = it-nota-fisc.nat-operacao:
                assign  int_ds_nota_saida_item.nsp_cfop_n = int(replace(natur-oper.cod-cfop,".","")).
            end.


            assign  i-ped-nota-saida-item                          =  integer(replace(nota-fiscal.nr-pedcli,".",""))                                 
                    int_ds_nota_saida_item.ped_codigo_n            = /*if it-nota-fisc.nr-pedcli <> "" then integer(replace(it-nota-fisc.nr-pedcli,".","")) 
                                                                     else if nota-fiscal.nr-pedcli <> "" then integer(replace(nota-fiscal.nr-pedcli,".","")) 
                                                                     else integer(replace(nota-fiscal.docto-orig,".",""))*/ 0
                    int_ds_nota_saida_item.nsp_basepis_n           = it-nota-fisc.vl-tot-item
                                                                    - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                       or  substr(item.char-1,50,5) = "Sim"
                                                                       then   it-nota-fisc.vl-pis
                                                                            + it-nota-fisc.vl-finsocial
                                                                         else 0)
                                                                    - (if natur-oper.tp-oper-terc = 4
                                                                       then it-nota-fisc.vl-icmsubit-e[3]
                                                                       else it-nota-fisc.vl-icmsub-it)
                    int_ds_nota_saida_item.nsp_basecofins_n        = it-nota-fisc.vl-tot-item
                                                                    - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                       or  substr(item.char-1,50,5) = "Sim"
                                                                       then   it-nota-fisc.vl-pis
                                                                            + it-nota-fisc.vl-finsocial
                                                                       else 0)
                                                                    - (if natur-oper.tP-oper-terc = 4
                                                                       then it-nota-fisc.vl-icmsubit-e[3]
                                                                       else it-nota-fisc.vl-icmsub-it).
            /*Nao inclui o valor no IPI na base das contrib sociais*/    
            if  it-nota-fisc.cd-trib-ipi <> 3
            and not natur-oper.log-ipi-contrib-social then do:
                 assign int_ds_nota_saida_item.nsp_basepis_n = int_ds_nota_saida_item.nsp_basepis_n
                                                               /*- it-nota-fisc.vl-ipi-it*/
                                                               - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                  then it-nota-fisc.vl-ipiit-e[3]
                                                                  else 0).
                 assign int_ds_nota_saida_item.nsp_basecofins_n = int_ds_nota_saida_item.nsp_basecofins_n
                                                                /*- it-nota-fisc.vl-ipi-it*/
                                                                - (if  it-nota-fisc.vl-bipiit-e[3] <> 0 
                                                                   then it-nota-fisc.vl-ipiit-e[3]
                                                                   else 0).
            end.
            /*Nao inclui o valor no IPI OUTRAS na base das contrib sociais*/
            if  it-nota-fisc.cd-trib-ipi = 3 
            and substring(natur-oper.char-2,16,1) = "1":U
            and not natur-oper.log-ipi-outras-contrib-social then do:
                assign int_ds_nota_saida_item.nsp_basepis_n = int_ds_nota_saida_item.nsp_basepis_n
                                                           /*- it-nota-fisc.vl-ipi-it*/
                                                           - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                              then it-nota-fisc.vl-ipiit-e[3]
                                                              else 0).
                assign int_ds_nota_saida_item.nsp_basecofins_n = int_ds_nota_saida_item.nsp_basecofins_n
                                                           /*- it-nota-fisc.vl-ipi-it*/
                                                           - (if  it-nota-fisc.vl-bipiit-e[3] = 0 
                                                              then it-nota-fisc.vl-ipiit-e[3]
                                                              else 0).
            end.
            assign  int_ds_nota_saida_item.nsp_cstbpis_s           = if substr(it-nota-fisc.char-2,96,1) = "1" then "01"
                                                                     else if substr(it-nota-fisc.char-2,96,1) = "1" then "07"
                                                                     else if substr(it-nota-fisc.char-2,96,1) = "3" then "02"
                                                                     else if it-nota-fisc.idi-forma-calc-pis = 2 then "03" else "99"
                    int_ds_nota_saida_item.nsp_cstbcofins_s        = if substr(it-nota-fisc.char-2,97,1) = "1" then "01"
                                                                     else if substr(it-nota-fisc.char-2,97,1) = "1" then "07"
                                                                     else if substr(it-nota-fisc.char-2,97,1) = "3" then "02"
                                                                     else if it-nota-fisc.idi-forma-calc-cofins = 2 then "03" else "99"
                    int_ds_nota_saida_item.nsp_percentualpis_n     = decimal(substr(it-nota-fisc.char-2,76,5))
                                                                   * (100 - if substr(it-nota-fisc.char-2,96,1) = "3"  /* Reduzido */
                                                                            or substr(it-nota-fisc.char-2,96,1) = "4"  /* Outros   */
                                                                            then decimal(substr(it-nota-fisc.char-2,86,5))
                                                                            else 0)
                                                                   / 10000.
                    int_ds_nota_saida_item.nsp_percentualcofins_n  = decimal(substr(it-nota-fisc.char-2,81,5))
                                                                   * (100 - if substr(it-nota-fisc.char-2,97,1) = "3"  /* Reduzido */
                                                                            or substr(it-nota-fisc.char-2,97,1) = "4"  /* Outros   */
                                                                            then decimal(substr(it-nota-fisc.char-2,91,5))
                                                                            else 0)
                                                                   / 10000.
            for first fat-ser-lote no-lock of it-nota-fisc:
                assign  int_ds_nota_saida_item.nsp_lote_s  = substring(fat-ser-lote.nr-serlote,1,10)
                        int_ds_nota_saida_item.nsp_datavalidade_d = fat-ser-lote.dt-vali-lote.
            end.

            assign  int_ds_nota_saida_item.nen_notafiscal_n = integer(it-nota-fisc.nr-docum)
                    int_ds_nota_saida_item.nen_serie_s      = it-nota-fisc.serie-docum.
            if it-nota-fisc.nr-docum <> "" then do:
                for first rat-lote fields (sequencia) no-lock where 
                    rat-lote.serie-docto  = it-nota-fisc.nr-docum and    
                    rat-lote.nro-docto    = it-nota-fisc.serie-docum and 
                    rat-lote.nat-operacao = it-nota-fisc.nat-docum and   
                    rat-lote.cod-emitente = nota-fiscal.cod-emitente and 
                    rat-lote.sequencia    > 0 and 
                    rat-lote.it-codigo    = it-nota-fisc.it-codigo and
                    rat-lote.lote = int_ds_nota_saida_item.nsp_lote_s
                    query-tuning(no-lookahead):
                    assign int_ds_nota_saida_item.nep_sequencia_n  = rat-lote.sequencia.
                end.
            end.

            if /*int_ds_nota_saida_item.ped_codigo_n*/ i-ped-nota-saida-item <> 0 then 
               assign i-pedido = i-ped-nota-saida-item.
            
           assign int_ds_nota_saida_item.nsp_caixa_n = int(it-nota-fisc.nr-seq-ped).
           for first cst_ped_item no-lock where
               cst_ped_item.nome_abrev     = nota-fiscal.nome-ab-cli and
               cst_ped_item.nr_pedcli      = it-nota-fisc.nr-pedcli  and
               cst_ped_item.nr_sequencia   = it-nota-fisc.nr-seq-ped and
               cst_ped_item.it_codigo      = it-nota-fisc.it-codigo  and
               cst_ped_item.cod_refer      = it-nota-fisc.cod-refer:
               assign int_ds_nota_saida_item.nsp_lote_s = cst_ped_item.numero_lote.
           end.
        end.
        release int_ds_nota_saida_item.
    end.  /* it-nota-fisc */

    
    log-manager:write-message("KML - int092api - cria nota saida" ) NO-ERROR.
    
    create  int_ds_nota_saida.
    assign  int_ds_nota_saida.ENVIO_STATUS       = 0
            int_ds_nota_saida.nsa_cnpj_origem_s  = estabelec.cgc
            int_ds_nota_saida.nsa_notafiscal_n   = integer(nota-fiscal.nr-nota-fis)
            int_ds_nota_saida.nsa_serie_s        = nota-fiscal.serie
            int_ds_nota_saida.nsa_cnpj_destino_s = nota-fiscal.cgc
            int_ds_nota_saida.nsa_dataemissao_d  = nota-fiscal.dt-emis-nota
            int_ds_nota_saida.nsa_chaveacesso_s  = &if "{&bf_dis_versao_ems}" >= "2.07" &then
                                                        trim(substring(nota-fiscal.cod-chave-aces-nf-eletro,1,44))
                                                   &else
                                                        trim(substring(nota-fiscal.char-2,3,44))
                                                   &endif
            int_ds_nota_saida.ped_codigo_n       = int(nota-fiscal.nr-pedcli)
            int_ds_nota_saida.ped_procfit        = int(nota-fiscal.nr-pedcli)
            int_ds_nota_saida.id_sequencial      = next-VALUE(seq-int-ds-nota-saida)
            int_ds_nota_saida.ENVIO_DATA_HORA    = datetime(today).


    for first natur-oper 
        fields (cod-cfop tipo tp-oper-terc char-2
                log-ipi-contrib-social log-ipi-outras-contrib-social) 
        no-lock where 
        natur-oper.nat-operacao = nota-fiscal.nat-operacao:
        assign int_ds_nota_saida.nsa_cfop_n       = integer(replace(natur-oper.cod-cfop,".","")).
    end.
    assign  int_ds_nota_saida.tipo_movto          = 1 /* inclusao */
            int_ds_nota_saida.nsa_cnpj_destino_s  = nota-fiscal.cgc
            int_ds_nota_saida.nsa_dataemissao_d   = nota-fiscal.dt-emis-nota
            int_ds_nota_saida.nsa_placaveiculo_s  = substring(replace(nota-fiscal.placa," ",""),1,7)
            int_ds_nota_saida.nsa_estadoveiculo_s = substring(replace(nota-fiscal.uf-placa," ",""),1,2)
            int_ds_nota_saida.nsa_observacao_s    = substring(nota-fiscal.observ-nota,1,4000).

    assign  int_ds_nota_saida.dt_geracao   = today
            int_ds_nota_saida.hr_geracao   = string(time,"HH:MM:SS")
            int_ds_nota_saida.situacao     = 2
            int_ds_nota_saida.ENVIO_STATUS = 02.

    if  (nota-fiscal.nat-operacao begins "5" or
         nota-fiscal.nat-operacao begins "6" or
         nota-fiscal.nat-operacao begins "7") and 
         nota-fiscal.esp-docto = 23 and
         avail int_ds_nota_saida and
         int_ds_nota_saida.nsa_cnpj_destino_s <> int_ds_nota_saida.nsa_cnpj_origem_s then do: /* Balan»o os CNPJ s’o iguais -> tratado em outro ponto */
         for FIRST b-estabelec fields (cgc cod-estabel cod-emitente) no-lock where 
             b-estabelec.cgc = nota-fiscal.cgc and
             b-estabelec.cod-estabel <> "973":

            c-cfop = "".
            de-despesas = 0.
            for each int_ds_nota_saida_item no-lock of int_ds_nota_saida:
                de-despesas = de-despesas + int_ds_nota_saida_item.nsp_valordespesa_n.
                for first int_ds_nota_entrada_produt where 
                    int_ds_nota_entrada_produt.nen_cnpj_origem_s = int_ds_nota_saida.nsa_cnpj_origem_s     and
                    int_ds_nota_entrada_produt.nen_serie_s       = int_ds_nota_saida.nsa_serie_s           and
                    int_ds_nota_entrada_produt.nen_notafiscal_n  = int_ds_nota_saida.nsa_notafiscal_n      and
                    int_ds_nota_entrada_produt.nep_sequencia_n   = int_ds_nota_saida_item.nsp_sequencia_n  and
                    int_ds_nota_entrada_produt.nep_produto_n     = int_ds_nota_saida_item.nsp_produto_n    and
                    int_ds_nota_entrada_produt.nep_lote_s        = int_ds_nota_saida_item.nsp_lote_s:      end.
                if not avail int_ds_nota_entrada_produt then do:

                    /*
                    put int_ds_nota_saida.nsa_cnpj_origem_s    " " 
                        int_ds_nota_saida.nsa_serie_s          " " 
                        int_ds_nota_saida.nsa_notafiscal_n     " " 
                        int_ds_nota_saida_item.nsp-sequencia-n " " 
                        int_ds_nota_saida_item.nsp_produto_n   " " 
                        int_ds_nota_saida_item.nsp_lote_s
                        skip.
                     */
                     
                     
                     log-manager:write-message("KML - int092api - cria item entrada" ) NO-ERROR.

                    create  int_ds_nota_entrada_produt.
                    assign  int_ds_nota_entrada_produt.nen_cnpj_origem_s       = int_ds_nota_saida.nsa_cnpj_origem_s   
                            int_ds_nota_entrada_produt.nen_serie_s             = int_ds_nota_saida.nsa_serie_s         
                            int_ds_nota_entrada_produt.nen_notafiscal_n        = int_ds_nota_saida.nsa_notafiscal_n    
                            int_ds_nota_entrada_produt.nep_sequencia_n         = int_ds_nota_saida_item.nsp_sequencia_n
                            int_ds_nota_entrada_produt.nep_produto_n           = int_ds_nota_saida_item.nsp_produto_n  
                            int_ds_nota_entrada_produt.nep_lote_s              = int_ds_nota_saida_item.nsp_lote_s.
                    assign  int_ds_nota_entrada_produt.nep_basecofins_n        = int_ds_nota_saida_item.nsp_basecofins_n
                            int_ds_nota_entrada_produt.nep_basediferido_n      = int_ds_nota_saida_item.nsp_basediferido_n
                            int_ds_nota_entrada_produt.nep_baseicms_n          = int_ds_nota_saida_item.nsp_baseicms_n
                            int_ds_nota_entrada_produt.nep_baseipi_n           = int_ds_nota_saida_item.nsp_baseipi_n
                            int_ds_nota_entrada_produt.nep_baseisenta_n        = int_ds_nota_saida_item.nsp_baseisenta_n
                            int_ds_nota_entrada_produt.nep_basepis_n           = int_ds_nota_saida_item.nsp_basepis_n
                            int_ds_nota_entrada_produt.nep_basest_n            = int_ds_nota_saida_item.nsp_basest_n
                            int_ds_nota_entrada_produt.nep_csta_n              = int_ds_nota_saida_item.nsp_csta_n
                            int_ds_nota_entrada_produt.nep_cstb_icm_n          = int_ds_nota_saida_item.nsp_cstb_n
                            int_ds_nota_entrada_produt.nep_cstb_ipi_n          = 0
                            int_ds_nota_entrada_produt.nep_datavalidade_d      = int_ds_nota_saida_item.nsp_datavalidade_d
                            int_ds_nota_entrada_produt.nep_icmsst_n            = int_ds_nota_saida_item.nsp_icmsst_n
                            int_ds_nota_entrada_produt.nep_percentualcofins_n  = int_ds_nota_saida_item.nsp_percentualcofins_n
                            int_ds_nota_entrada_produt.nep_percentualicms_n    = int_ds_nota_saida_item.nsp_percentualicms_n
                            int_ds_nota_entrada_produt.nep_percentualipi_n     = int_ds_nota_saida_item.nsp_percentualipi_n
                            int_ds_nota_entrada_produt.nep_percentualpis_n     = int_ds_nota_saida_item.nsp_percentualpis_n
                            int_ds_nota_entrada_produt.nep_quantidade_n        = int_ds_nota_saida_item.nsp_quantidade_n
                            int_ds_nota_entrada_produt.nep_redutorbaseicms_n   = int_ds_nota_saida_item.nsp_redutorbaseicms_n
                            int_ds_nota_entrada_produt.nep_valorbruto_n        = int_ds_nota_saida_item.nsp_valorbruto_n
                            int_ds_nota_entrada_produt.nep_valorcofins_n       = int_ds_nota_saida_item.nsp_valorcofins_n
                            int_ds_nota_entrada_produt.nep_valordesconto_n     = int_ds_nota_saida_item.nsp_desconto_n
                            int_ds_nota_entrada_produt.nep_valordespesa_n      = int_ds_nota_saida_item.nsp_valordespesa_n
                            int_ds_nota_entrada_produt.nep_valoricms_n         = int_ds_nota_saida_item.nsp_valoricms_n
                            int_ds_nota_entrada_produt.nep_valoripi_n          = int_ds_nota_saida_item.nsp_valoripi_n
                            int_ds_nota_entrada_produt.nep_valorliquido_n      = int_ds_nota_saida_item.nsp_valorliquido_n
                            int_ds_nota_entrada_produt.nep_valorpis_n          = int_ds_nota_saida_item.nsp_valorpis_n
                            int_ds_nota_entrada_produt.ped_codigo_n            = /*int_ds_nota_saida_item.ped_codigo_n*/ 0.

                    for first item fields (codigo-orig class-fiscal fm-codigo) no-lock where 
                        item.it-codigo = trim(string(int_ds_nota_saida_item.nsp_produto_n)): end.

                    IF NOT AVAIL ITEM THEN NEXT.

                    assign  int_ds_nota_entrada_produt.nep_ncm_n               = if   int_ds_nota_saida_item.nsp_ncm_s <> ""
                                                                                  then int(int_ds_nota_saida_item.nsp_ncm_s)
                                                                                  else int(item.class-fiscal)
                            int_ds_nota_entrada_produt.nep_csta_n              = item.codigo-orig.

                    for first natur-oper 
                        fields (cod-cfop tipo tp-oper-terc char-2
                                log-ipi-contrib-social log-ipi-outras-contrib-social) 
                        no-lock where 
                        natur-oper.nat-operacao = nota-fiscal.nat-operacao: end.

                    c-cfop = STRING(int_ds_nota_saida.nsa_cfop_n).
                    assign int_ds_nota_entrada_produt.nen_cfop_n = int(c-cfop).
                    release int_ds_nota_entrada_produt.
                end. /* not avail int_ds_nota_saida-produto */
            end. /* int_ds_nota_saida-produto */
            for first int_ds_nota_entrada where 
                int_ds_nota_entrada.nen_cnpj_origem_s = int_ds_nota_saida.nsa_cnpj_origem_s     and
                int_ds_nota_entrada.nen_serie_s       = int_ds_nota_saida.nsa_serie_s           and
                int_ds_nota_entrada.nen_notafiscal_n  = int_ds_nota_saida.nsa_notafiscal_n:     end.
            if not avail int_ds_nota_entrada then do:
            
            
                log-manager:write-message("KML - int092api - cria nota entrada" ) NO-ERROR.
                
                
                create  int_ds_nota_entrada.
                assign  int_ds_nota_entrada.dt_geracao          = today
                        int_ds_nota_entrada.hr_geracao          = string(time,"HH:MM:SS")
                        int_ds_nota_entrada.nen_basediferido_n  = int_ds_nota_saida.nsa_basediferido_n
                        int_ds_nota_entrada.nen_baseicms_n      = int_ds_nota_saida.nsa_baseicms_n
                        int_ds_nota_entrada.nen_baseipi_n       = int_ds_nota_saida.nsa_baseipi_n
                        int_ds_nota_entrada.nen_baseisenta_n    = int_ds_nota_saida.nsa_baseisenta_n
                        int_ds_nota_entrada.nen_basest_n        = int_ds_nota_saida.nsa_basest_n
                        int_ds_nota_entrada.nen_cfop_n          = int_ds_nota_saida.nsa_cfop_n
                        int_ds_nota_entrada.nen_chaveacesso_s   = &if "{&bf_dis_versao_ems}" >= "2.07" &then    
                                                                       trim(substring(nota-fiscal.cod-chave-aces-nf-eletro,1,44)) 
                                                                  &else                                         
                                                                       trim(substring(nota-fiscal.char-2,3,44)) 
                                                                  &endif                                        
                        int_ds_nota_entrada.nen_cnpj_destino_s  = int_ds_nota_saida.nsa_cnpj_destino_s
                        int_ds_nota_entrada.nen_cnpj_origem_s   = int_ds_nota_saida.nsa_cnpj_origem_s
                        int_ds_nota_entrada.nen_conferida_n     = 0
                        int_ds_nota_entrada.nen_dataemissao_d   = int_ds_nota_saida.nsa_dataemissao_d
                        int_ds_nota_entrada.nen_desconto_n      = int_ds_nota_saida.nsa_desconto_n
                        int_ds_nota_entrada.nen_despesas_n      = de-despesas
                        int_ds_nota_entrada.nen_frete_n         = nota-fiscal.vl-frete
                        int_ds_nota_entrada.nen_icmsst_n        = int_ds_nota_saida.nsa_icmsst_n
                        int_ds_nota_entrada.nen_modalidade_frete_n   = nota-fiscal.ind-tp-frete
                        int_ds_nota_entrada.nen_notafiscal_n         = int_ds_nota_saida.nsa_notafiscal_n
                        int_ds_nota_entrada.nen_observacao_s         = int_ds_nota_saida.nsa_observacao_s
                        int_ds_nota_entrada.nen_quantidade_n         = int_ds_nota_saida.nsa_quantidade_n
                        int_ds_nota_entrada.nen_seguro_n             = 0
                        int_ds_nota_entrada.nen_serie_s              = int_ds_nota_saida.nsa_serie_s
                        int_ds_nota_entrada.nen_valoricms_n          = int_ds_nota_saida.nsa_valoricms_n
                        int_ds_nota_entrada.nen_valoripi_n           = int_ds_nota_saida.nsa_valoripi_n
                        int_ds_nota_entrada.nen_valortotalprodutos_n = int_ds_nota_saida.nsa_valortotalprodutos_n
                        int_ds_nota_entrada.situacao                 = 1
                        int_ds_nota_entrada.tipo_movto               = 1
                        int_ds_nota_entrada.tipo_nota                = 3
                        int_ds_nota_entrada.ped_codigo_n             = int_ds_nota_saida.ped_codigo_n
                        int_ds_nota_entrada.ped_procfit              = int_ds_nota_saida.ped_procfit
                        int_ds_nota_entrada.id_sequencial            = next-VALUE(seq-int-ds-nota-entrada) /* Prepara»’o para integra»’o com Procfit */
                        int_ds_nota_entrada.ENVIO_STATUS             = 02
                        int_ds_nota_entrada.ENVIO_DATA_HORA          = datetime(today).

                for first ndd_entryintegration where
                    NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int_ds_nota_entrada.nen_notafiscal_n  and
                    NDD_ENTRYINTEGRATION.SERIE          = int(int_ds_nota_entrada.nen_serie_s)  and
                    NDD_ENTRYINTEGRATION.CNPJEMIT       = int(int_ds_nota_entrada.nen_cnpj_origem_s) and
                    NDD_ENTRYINTEGRATION.CNPJDEST       = int(int_ds_nota_entrada.nen_cnpj_origem_s)
                    query-tuning(no-lookahead):
                    assign status_ = 1.
                end.
                

                release int_ds_nota_entrada.
            end. /* avail int_ds_nota_entrada */
         end. /* avail b-estabelec */

         
         log-manager:write-message("KML - int092api - fim cria tabelas" ) NO-ERROR.
         /* notas de transferencia Lj->CD - Retirado do INT500 */
         for FIRST b-estabelec fields (cgc cod-estabel cod-emitente) no-lock where 
             b-estabelec.cgc = nota-fiscal.cgc and
             b-estabelec.cod-estabel = "973"
             query-tuning(no-lookahead):
             if substring(nota-fiscal.nat-operacao,1,4) <> "5605" /* Transferencia de saldo de ICMS */ and
                not nota-fiscal.nat-operacao begins "5929" /* outras */ then 
               run pi-entrada-cd (1,1).
         end.
     
     END.

END PROCEDURE.

procedure pi-entrada-cd:
    define input param p-sit-oblak as integer.
    define input param p-sit-procfit as integer.

    define buffer bemitente for emitente.

    assign de-tot-bicms = 0
           de-tot-icms  = 0
           de-tot-bsubs = 0
           de-tot-icmst = 0.

    for first estabelec no-lock where estabelec.cod-estabel = nota-fiscal.cod-estabel
        query-tuning(no-lookahead): end.

    for first int_ds_docto_xml NO-LOCK where 
              int_ds_docto_xml.CNPJ         = estabelec.cgc             and
              /*int_ds_docto_xml.CNPJ_dest    = emitente.cgc            and
              int_ds_docto_xml.ep_codigo    = int(estabelec.ep-codigo)  and*/
              int_ds_docto_xml.serie        = nota-fiscal.serie         and
              int_ds_docto_xml.nNF          = nota-fiscal.nr-nota-fis:  end.
    if avail int_ds_docto_xml then return.

    /* destino */
    for first emitente no-lock where emitente.cod-emitente = nota-fiscal.cod-emitente
        query-tuning(no-lookahead): end.

    /* origem */
    for first bemitente no-lock where bemitente.cod-emitente = estabelec.cod-emitente
        query-tuning(no-lookahead): end.

    if not avail natur-oper then 
        for first natur-oper no-lock 
        WHERE
        natur-oper.nat-operacao = nota-fiscal.nat-operacao
            query-tuning(no-lookahead). end.

    /*
    display 
        nota-fiscal.cod-estabel
        nota-fiscal.serie
        nota-fiscal.nr-nota-fis
        nota-fiscal.dt-emis-nota
        nota-fiscal.dt-cancela
        AVAIL int_ds_nota_saida
        with frame f-rel.
    down with frame f-rel.
    */

    create  int_ds_docto_xml.
    assign  int_ds_docto_xml.envio_status = 0
            int_ds_docto_xml.CNPJ         = estabelec.cgc
            int_ds_docto_xml.CNPJ_dest    = emitente.cgc 
            int_ds_docto_xml.ep_codigo    = int(estabelec.ep-codigo)
            int_ds_docto_xml.serie        = nota-fiscal.serie
            int_ds_docto_xml.nNF          = nota-fiscal.nr-nota-fis
            int_ds_docto_xml.cod_emitente = bemitente.cod-emitente
            int_ds_docto_xml.dEmi         = nota-fiscal.dt-emis-nota
            int_ds_docto_xml.VNF          = nota-fiscal.vl-tot-nota             /* Valor total da nota fiscal */
            int_ds_docto_xml.observacao   = if trim(nota-fiscal.observ-nota) <> ? 
                                            then trim(nota-fiscal.observ-nota) else ""
            int_ds_docto_xml.valor_frete  = nota-fiscal.vl-frete                /* Frete total da nota */
            int_ds_docto_xml.valor_seguro = nota-fiscal.vl-seguro               /* Seguro total da nota  */
            int_ds_docto_xml.valor_outras = nota-fiscal.val-desp-outros         /* Despesas total da nota */
            int_ds_docto_xml.tot_desconto = nota-fiscal.vl-desconto   /*  Desconto total da nota fiscal  */          
            int_ds_docto_xml.valor_mercad = nota-fiscal.vl-mercad
            int_ds_docto_xml.vbc          = de-tot-bicms              /*  Base ICMS total nota fiscal    */          
            int_ds_docto_xml.valor_icms   = de-tot-icms               /*  Valor total do ICMS da nota fiscal    */ 
            int_ds_docto_xml.vbc_cst      = de-tot-bsubs              /*  Base ICMS ST */                   
            int_ds_docto_xml.valor_st     = de-tot-icmst              /*  Valor do ICMS ST total da nota */ 
            int_ds_docto_xml.modFrete     = nota-fiscal.ind-tp-frete  /*  Modalidade do frete (0-FOB 1-Cif) */
            int_ds_docto_xml.dt_trans     = nota-fiscal.dt-emis-nota
            int_ds_docto_xml.volume       = nota-fiscal.nr-volumes
            int_ds_docto_xml.cod_usuario  = nota-fiscal.user-calc
            int_ds_docto_xml.despesa_nota = nota-fiscal.val-desp-outros
            int_ds_docto_xml.estab_de_or  = nota-fiscal.cod-estabel
            int_ds_docto_xml.tipo_docto   = 1
            int_ds_docto_xml.tipo_estab   = 1
            int_ds_docto_xml.situacao     = p-sit-oblak
            int_ds_docto_xml.tipo_nota    = if nota-fiscal.esp-docto = 23 /*NFT*/ then 3 else 1
            int_ds_docto_xml.xNome        = emitente.nome-emit
            int_ds_docto_xml.chnfe        = &if "{&bf_dis_versao_ems}" >= "2.07" &then    
                                                 nota-fiscal.cod-chave-aces-nf-eletro
                                            &else                                         
                                                 trim(substring(nota-fiscal.char-2,3,44)) 
                                            &endif                                        
            int_ds_docto_xml.chnft        = &if "{&bf_dis_versao_ems}" >= "2.07" &then     
                                                 nota-fiscal.cod-chave-aces-nf-eletro      
                                            &else                                          
                                                 trim(substring(nota-fiscal.char-2,3,44))  
                                            &endif                                         
            int_ds_docto_xml.cfop         = int(replace(natur-oper.cod-cfop,".",""))
            int_ds_docto_xml.num_pedido   = int64(nota-fiscal.nr-pedcli)
            int_ds_docto_xml.valor_mercad = 0.

    for each estabelec no-lock where estabelec.cgc = trim(int_ds_docto_xml.CNPJ_dest),
        each cst_estabelec no-lock WHERE
             cst_estabelec.cod_estabel = estabelec.cod-estabel AND
             cst_estabelec.dt_fim_operacao >= nota-fiscal.dt-emis-nota 
        query-tuning(no-lookahead):
        assign int_ds_docto_xml.cod_estab = estabelec.cod-estabel.
        leave.
    end.

    for each it-nota-fisc of nota-fiscal no-lock query-tuning(no-lookahead):

        if VALID-HANDLE(h-acomp) then
            RUN pi-acompanhar IN h-acomp(INPUT "Nota: " + string(nota-fiscal.nr-nota-fis)).

        for first int_ds_nota_saida_item of int_ds_nota_saida NO-LOCK where
                  int_ds_nota_saida_item.nsp_sequencia_n = it-nota-fisc.nr-seq-fat     and
                  int_ds_nota_saida_item.nsp_produto_n   = int(it-nota-fisc.it-codigo) 
            query-tuning(no-lookahead): 
        end.
        for first int_dp_nota_saida_item NO-LOCK where
                  int_dp_nota_saida_item.nsa_cnpj_origem_s       = int_ds_docto_xml.CNPJ          and
                  int_dp_nota_saida_item.nsa_serie_s             = int_ds_docto_xml.serie         and
                  int64(int_dp_nota_saida_item.nsa_notafiscal_n) = INT64(int_ds_docto_xml.nnf)    AND
                  int_dp_nota_saida_item.nsi_sequencia_n         = (it-nota-fisc.nr-seq-fat / 10) and
                  int_dp_nota_saida_item.nsi_produto_n           = int64(IT-NOTA-FISC.it-codigo) 
            query-tuning(no-lookahead): 
        end.

        if not avail int_ds_nota_saida_item and
           not avail int_dp_nota_saida_item then next.

        for first ITEM fields (item.codigo-orig 
                               char-1
                               char-2)
            no-lock where item.it-codigo = it-nota-fisc.it-codigo
            query-tuning(no-lookahead): end.

        IF NOT AVAIL ITEM THEN NEXT.

        assign  de-tot-bicms   = de-tot-bicms   + it-nota-fisc.vl-bicms-it
                de-tot-icms    = de-tot-icms    + it-nota-fisc.vl-icms-it
                de-tot-bsubs   = de-tot-bsubs   + it-nota-fisc.vl-bsubs-it
                de-tot-icmst   = de-tot-icmst   + it-nota-fisc.vl-icmsub-it.
        
        for first natur-oper 
            fields (cod-cfop
                    tp-oper-terc) NO-LOCK
            WHERE
            natur-oper.nat-operacao = it-nota-fisc.nat-operacao
            query-tuning(no-lookahead): end.

        
        for first int_ds_it_docto_xml where
            int_ds_it_docto_xml.tipo_nota  = int_ds_docto_xml.tipo_nota and 
            int_ds_it_docto_xml.CNPJ       = int_ds_docto_xml.CNPJ      and 
            int_ds_it_docto_xml.nNF        = int_ds_docto_xml.nNF       and 
            int_ds_it_docto_xml.serie      = int_ds_docto_xml.serie     and
            int_ds_it_docto_xml.sequencia  = it-nota-fisc.nr-seq-fat    and
            int_ds_it_docto_xml.it_codigo  = it-nota-fisc.it-codigo
            query-tuning(no-lookahead): end.

        if not avail int_ds_it_docto_xml then do:
            create int_ds_it_docto_xml.
            assign int_ds_it_docto_xml.arquivo      = int_ds_docto_xml.arquivo
                   int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota 
                   int_ds_it_docto_xml.CNPJ         = int_ds_docto_xml.CNPJ
                   int_ds_it_docto_xml.cod_emitente = bemitente.cod-emitente
                   int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF
                   int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie
                   int_ds_it_docto_xml.sequencia    = it-nota-fisc.nr-seq-fat 
                   int_ds_it_docto_xml.item_do_forn = it-nota-fisc.it-codigo
                   int_ds_it_docto_xml.it_codigo    = it-nota-fisc.it-codigo
                   int_ds_it_docto_xml.cfop         = int(replace(natur-oper.cod-cfop,".",""))
                   int_ds_it_docto_xml.qCom         = it-nota-fisc.qt-faturada[1]
                   int_ds_it_docto_xml.qCom_Forn    = it-nota-fisc.qt-faturada[1]
                   int_ds_it_docto_xml.vProd        = it-nota-fisc.vl-tot-item   
                   int_ds_it_docto_xml.vuncom       = it-nota-fisc.vl-preuni    
                   int_ds_it_docto_xml.vtottrib     = it-nota-fisc.vl-merc-liq                       
                   int_ds_it_docto_xml.vbc_icms     = it-nota-fisc.vl-bicms-it                       
                   int_ds_it_docto_xml.vDesc        = it-nota-fisc.vl-desconto                       
                   int_ds_it_docto_xml.vicms        = it-nota-fisc.vl-icms-it                        
                   int_ds_it_docto_xml.vbc_ipi      = it-nota-fisc.vl-bipi-it                        
                   int_ds_it_docto_xml.vipi         = it-nota-fisc.vl-ipi-it                         
                   int_ds_it_docto_xml.vicmsst      = it-nota-fisc.vl-icmsub-it                      
                   int_ds_it_docto_xml.vbcst        = it-nota-fisc.vl-bsubs-it                       
                   int_ds_it_docto_xml.picmsst      = it-nota-fisc.aliquota-icm                      
                   int_ds_it_docto_xml.pipi         = it-nota-fisc.aliquota-ipi
                   int_ds_it_docto_xml.ppis         = decimal(substr(it-nota-fisc.char-2,76,5))
                                                                         * (100 - if substr(it-nota-fisc.char-2,96,1) = "3"  /* Reduzido */
                                                                                  or substr(it-nota-fisc.char-2,96,1) = "4"  /* Outros   */
                                                                                  then decimal(substr(it-nota-fisc.char-2,86,5))
                                                                                  else 0)
                                                                         / 10000
                   int_ds_it_docto_xml.pcofins      = decimal(substr(it-nota-fisc.char-2,81,5))
                                                                         * (100 - if substr(it-nota-fisc.char-2,97,1) = "3"  /* Reduzido */
                                                                                  or substr(it-nota-fisc.char-2,97,1) = "4"  /* Outros   */
                                                                                  then decimal(substr(it-nota-fisc.char-2,91,5))
                                                                                  else 0)
                                                                         / 10000
                   int_ds_it_docto_xml.vbc_pis      = it-nota-fisc.vl-tot-item
                                                                          - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                             or  substr(item.char-1,50,5) = "Sim"
                                                                             then   it-nota-fisc.vl-pis
                                                                                  + it-nota-fisc.vl-finsocial
                                                                               else 0)
                                                                          - (if natur-oper.tp-oper-terc = 4
                                                                             then it-nota-fisc.vl-icmsubit-e[3]
                                                                             else it-nota-fisc.vl-icmsub-it)
                   int_ds_it_docto_xml.vpis         = it-nota-fisc.vl-pis
                   int_ds_it_docto_xml.vbc_cofins   = it-nota-fisc.vl-tot-item
                                                                          - (if  substr(item.char-1,50,5) = " "    /* Retira PIS/Cofins Subst incorporado */
                                                                             or  substr(item.char-1,50,5) = "Sim"
                                                                             then   it-nota-fisc.vl-pis
                                                                                  + it-nota-fisc.vl-finsocial
                                                                             else 0)
                                                                          - (if natur-oper.tP-oper-terc = 4
                                                                             then it-nota-fisc.vl-icmsubit-e[3]
                                                                             else it-nota-fisc.vl-icmsub-it)
                   int_ds_it_docto_xml.vcofins      = it-nota-fisc.vl-finsocial
                   int_ds_it_docto_xml.num_pedido   = int64(nota-fiscal.nr-pedcli)
                   int_ds_it_docto_xml.orig_icms    = item.codigo-orig
                   int_ds_it_docto_xml.vbcst        = it-nota-fisc.vl-bsubs-it
                   int_ds_it_docto_xml.vbc_ipi      = it-nota-fisc.vl-bipi-it                   
                   int_ds_it_docto_xml.vbcstret     = 0
                   int_ds_it_docto_xml.item_do_forn = it-nota-fisc.it-codigo                  
                   int_ds_it_docto_xml.vOutro       = it-nota-fisc.vl-despes-it.

            if avail int_dp_nota_saida_item then do:
                  assign  int_ds_it_docto_xml.lote         = if int_dp_nota_saida_item.nsi_lote_s <> ? 
                                                             then int_dp_nota_saida_item.nsi_lote_s else ""
                          int_ds_it_docto_xml.dval         = int_dp_nota_saida_item.nsi_datavalidade_d.
            end.
            else if avail int_ds_nota_saida_item then do:

                  assign  int_ds_it_docto_xml.lote         = if int_ds_nota_saida_item.nsp_lote_s <> ? 
                                                             then int_ds_nota_saida_item.nsp_lote_s else ""
                          int_ds_it_docto_xml.dval         = int_ds_nota_saida_item.nsp_datavalidade_d.
            end.
            run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                               output int_ds_it_docto_xml.cst_icms,
                               output l-sub).

            if it-nota-fisc.cd-trib-icm = 2 then assign int_ds_it_docto_xml.cst_icms = 40.
            if it-nota-fisc.cd-trib-icm = 3 then assign int_ds_it_docto_xml.cst_icms = 41.
            else if it-nota-fisc.cd-trib-icm = 5 then assign int_ds_it_docto_xml.cst_icms = 51.
        end.
    end.
    assign int_ds_docto_xml.vbc          = de-tot-bicms              /*  Base ICMS total nota fiscal    */          
           int_ds_docto_xml.valor_icms   = de-tot-icms               /*  Valor total do ICMS da nota fiscal    */ 
           int_ds_docto_xml.vbc_cst      = de-tot-bsubs              /*  Base ICMS ST */                   
           int_ds_docto_xml.valor_st     = de-tot-icmst              /*  Valor do ICMS ST total da nota */
           int_ds_docto_xml.envio_status = 1.

    for first emitente no-lock where emitente.cod-emitente = estabelec.cod-emitente
        query-tuning(no-lookahead):
        CREATE int_ds_docto_wms.
        ASSIGN int_ds_docto_wms.doc_numero_n    = nota-fiscal.nr-nota-fis
               int_ds_docto_wms.doc_serie_s     = int_ds_docto_xml.serie
               int_ds_docto_wms.cnpj_cpf        = int_ds_docto_xml.CNPJ
               int_ds_docto_wms.situacao        = /*1. /* InclusÆo */*/ 10 /* novos status */
               int_ds_docto_wms.tipo_nota       = if nota-fiscal.esp-docto = 23 /*NFT*/ then 3 else 2
               int_ds_docto_wms.ENVIO_STATUS    = p-sit-procfit
               int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today).
               int_ds_docto_wms.id_sequencial   = NEXT-VALUE(seq-int-ds-docto-wms). /* Prepara‡Æo para integra‡Æo com Procfit */ .

        IF AVAIL bemitente THEN 
           ASSIGN int_ds_docto_wms.doc_origem_n    = bemitente.cod-emitente
                  int_ds_docto_wms.tipo_fornecedor = IF bemitente.natureza = 1 THEN "F" ELSE "J".
    end.

end procedure.						 
