/*
Descriá∆o: Prefeitura de Curitiba
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE program_name         CSAP008A2197
&SCOPED-DEFINE program_version      1.00.00.000

{include/i-prgvrs.i {&program_name} {&program_version} }

{cstp/csap008i01.i}

/*Parameters Definitions*/
DEF INPUT PARAM TABLE FOR tt-param .
DEF INPUT PARAM TABLE FOR tt-docto .

FIND FIRST tt-param NO-LOCK .

/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp AS HANDLE NO-UNDO.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

DEF BUFFER bf-emitente FOR emitente .

DEF VAR v_linha             AS CHAR NO-UNDO .

DEF VAR i-count             AS INT NO-UNDO .
DEF VAR d-soma-val          AS DECIMAL NO-UNDO .

FIND FIRST bf-emitente NO-LOCK WHERE bf-emitente.cod-emitente = tt-param.cod-prefeitura .

FOR EACH tt-docto NO-LOCK
    BREAK BY tt-docto.cod-estabel
    :
    FIND FIRST estabelec NO-LOCK OF tt-docto .
    FIND FIRST emitente NO-LOCK OF tt-docto .

    IF FIRST-OF(tt-docto.cod-estabel) THEN DO:
        OUTPUT TO VALUE(tt-param.dir-arquivos + "/" +
                        estabelec.cidade + "_" + 
                        estabelec.estado + "_" +
                        STRING(tt-param.mes-transacao , "99") + "_" +
                        STRING(tt-param.ano-transacao , "9999") + "_" + 
                        SUBSTR(estabelec.cgc,9,6) +
                        ".txt" )
        NO-CONVERT .
        /**/

        ASSIGN d-soma-val = 0 .
        ASSIGN i-count = i-count + 1 .

        ASSIGN v_linha = "" .
        OVERLAY(v_linha, 1, 1)        = 'H'.                                                /* 001,001 - C¢digo do registro ?H? */
        OVERLAY(v_linha, 2, 10)       = STRING(INT(estabelec.ins-municipal),'9999999999') . /* 002,011 - N£mero da Inscriá∆o Municipal do Declarante  */
        OVERLAY(v_linha, 12, 14)      = STRING(estabelec.cgc, '99999999999999') .           /* 012,025 - N£mero do CNPJ do Declarante no caso de pessoa jur°dica */
        OVERLAY(v_linha, 26, 11)      = ''.                                                 /* 026,036 - N£mero do CPF do Declarante no caso de pessoa f°sica. */
        OVERLAY(v_linha, 37, 100)     = estabelec.nome .                                     /* 037,136 - Nome/Raz∆o Social do Declarante */
        OVERLAY(v_linha, 137, 1)      = IF tt-param.l-teste = YES THEN 'T' ELSE 'N'.        /* 137,137 - Tipo do Arquivo enviado para a Prefeitura, podendo ser: N ? normal ou       T ? Teste */
        OVERLAY(v_linha, 138, 2)      = STRING(tt-param.mes-transacao , '99') .             /* 138,139 - Màs de referància dos documentos declarados */
        OVERLAY(v_linha, 140, 4)      = STRING(tt-param.ano-transacao , '9999') .           /* 140,143 - Ano de referància dos documentos declarados */
        OVERLAY(v_linha, 144, 252)    = ''.                                                 /* 144,395 - Brancos ? reservado para futuro */
        OVERLAY(v_linha, 396, 1)      = '.'.                                                /* 396,396 - Caracter fixo = . (ponto)  */
        PUT UNFORMATTED v_linha skip.
    END.

    ASSIGN v_linha = "" .
    OVERLAY(v_linha, 1, 1)        = 'R'.                                                                /* 001,001  - C¢digo do registro ?R? */
    OVERLAY(v_linha, 2, 8)        = STRING(tt-docto.dt-emissao,'99999999').                             /* 002,009  - Data de emiss∆o do documento recebido.  */
    OVERLAY(v_linha, 10, 8)       = tt-docto.nro-docto .                                                /* 010,017  - N£mero do documento recebido */
    OVERLAY(v_linha, 18, 8)       = ''.                                                                 /* 018,025  - Deixar com brancos */
    OVERLAY(v_linha, 26, 1)       = IF tt-docto.cod-esp = 'NF' THEN '1' ELSE '3'.                       /* 026,026  - Identificaá∆o do Tipo de Documento recebido. (1. Nota Fiscal, 2. Recibo Comum, 3. RPA - Recibo Pagamento Autìnomo, 4. Cupom Fiscal, 5. Outros, 6. Conhecimento de Transporte) */
    OVERLAY(v_linha, 27, 3)       = IF tt-docto.cod-esp = 'NF' THEN tt-docto.serie-docto ELSE '' .      /* 027,029  - SÇrie do Documento recebido quando o campo R.05 = Nota Fiscal */
    OVERLAY(v_linha, 30, 1)       = IF tt-docto.cod-imposto <> 0 THEN 'S' ELSE 'N'.                     /* 030,030  - Identificaá∆o do Serviáo Tomado caracterizando Substituiá∆o Tribut†ria */
    OVERLAY(v_linha, 31, 1)       = 'D'.                                                                /* 031,031  - Indicador do Local de Prestaá∆o do Serviáo quando o serviáo tomado caracterizar substituiá∆o tribut†ria / retená∆o ¢rg∆o p£blico, de acordo com o campo R.07. D ? Dentro do Munic°pio F ? Fora do Munic°pio */
    OVERLAY(v_linha, 32, 4)       = STRING(tt-docto.cod-retencao , "9999") .                            /* 032,033  - C¢digo do Item da Lista de Serviáos (Lei Complementar 116/2003). */
    OVERLAY(v_linha, 36, 15)      = STRING((tt-docto.vl-a-pagar * 100),'999999999999999') .             /* 036,050  - Valor do documento recebido.  */
    OVERLAY(v_linha, 51, 15)      = '000000000000000'.                                                  /* 051,065  - Valor de deduá∆o do documento emitido conforme legislaá∆o tribut†ria municipal pertinente. */
    OVERLAY(v_linha, 66, 10)      = emitente.ins-municipal .                                            /* 066,075  - N£mero da inscriá∆o municipal do prestador de serviáo. */
    OVERLAY(v_linha, 76, 14)      = IF emitente.natureza <> 1 THEN STRING(DECIMAL(emitente.cgc) , "99999999999999") ELSE '' .   /* 076,089  - N£mero do CNPJ do prestador de serviáo quando este for Pessoa Jur°dica */
    OVERLAY(v_linha, 90, 11)      = IF emitente.natureza = 1 THEN STRING(DECIMAL(emitente.cgc) , "99999999999") ELSE '' .       /* 090,100  - N£mero do CPF do prestador de serviáo quando este for Pessoa F°sica */
    OVERLAY(v_linha, 101, 100)    = emitente.nome-emit .                                                /* 101,200  - Nome ou Raz∆o Social do prestador de serviáo  */
    OVERLAY(v_linha, 201, 5)      = ''.                                                                 /* 201,205  - Identificaá∆o do Tipo do Logradouro do Endereáo do prestador de serviáo */
    OVERLAY(v_linha, 206, 50)     = ''.                                                                 /* 206,255  - Nome do Logradouro do Endereáo do prestador de serviáo  */
    OVERLAY(v_linha, 256, 6)      = ''.                                                                 /* 256,261  - N£mero do Endereáo do prestador de serviáo  */
    OVERLAY(v_linha, 262, 20)     = ''.                                                                 /* 262,281  - Complemento do Endereáo do prestador  de serviáo  */
    OVERLAY(v_linha, 282, 50)     = ''.                                                                 /* 282,331  - Bairro do Endereáo do prestador de serviáo  */
    OVERLAY(v_linha, 332, 44)     = ''.                                                                 /* 332,375  - Cidade do Endereáo do prestador de serviáo  */
    OVERLAY(v_linha, 376, 2)      = ''.                                                                 /* 376,377  - Estado da Cidade do Endereáo do prestador de serviáo */
    OVERLAY(v_linha, 378, 8)      = ''.                                                                 /* 378,385  - Cep do Endereáo do prestador de serviáo  */
    OVERLAY(v_linha, 386, 6)      = string(i-count,'99999999').                                         /* 386,391  - N£mero seqÅencial do registro dentro do arquivo */
    OVERLAY(v_linha, 392, 4)      = string((tt-docto.aliquota * 100), '9999').                          /* 392,395  - Valor percentual da al°quota */
    OVERLAY(v_linha, 396, 1)      = '.'.                                                                /* 396,396  - Caracter fixo = . (ponto) */
    PUT UNFORMATTED v_linha SKIP .

    ASSIGN d-soma-val = d-soma-val + (tt-docto.vl-a-pagar * 100).

    IF LAST-OF(tt-docto.cod-estabel) THEN DO:
        ASSIGN i-count = i-count + 1 .

        ASSIGN v_linha = "" .
        OVERLAY(v_linha, 1, 1)        = 'T'.                                    /* 001,001      C¢digo do registro ?T? */
        OVERLAY(v_linha, 002,  8)     = STRING(i-count,'99999999').             /* 002,009      Quantidade total de registros do arquivo, incluindo o header (H) e trailler (T) */
        OVERLAY(v_linha, 010, 15)     = '000000000000000'.                      /* 010,024      Valor Total dos Documentos emitidos  pelo Prestador de Serviáos. Soma de todos os valores descritos nos campos E.11 */
        OVERLAY(v_linha, 025, 15)     = '000000000000000'.                      /* 025,039      Valor Total das Deduá‰es dos Documentos emitidos pelo Prestador de Serviáos. Soma de todos os valores descritos nos campos E.12 */
        OVERLAY(v_linha, 040, 15)     = STRING(d-soma-val,'999999999999999').   /* 040,054      Valor Total dos Documentos recebidos  pelo tomador de Serviáos. Soma de todos os valores descritos nos campos R.11 */
        OVERLAY(v_linha, 055, 15)     = '000000000000000'.                      /* 055,069      Valor Total das Deduá‰es dos Documentos recebidos  pelo tomador de Serviáos. Soma de todos os valores descritos nos campos R.12 */
        OVERLAY(v_linha, 070, 326)    = ''.                                     /* 070,395      Brancos ? reservado para futuro */
        OVERLAY(v_linha, 396, 1)      = '.'.                                    /* 396,396      Caracter fixo = . (ponto) */
        PUT UNFORMATTED v_linha SKIP .
        OUTPUT CLOSE .
    END.
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .


