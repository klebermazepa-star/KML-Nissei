/*****************************************************************************
**
** Programa : FT0904l.I
**
** Autor    : DATASUL S.A.
**
** Objetivo : Comum ao programa FT0904l.P, criar o tt-ped-curva.
**
*****************************************************************************/
find first param-global no-lock no-error.
ASSIGN c-conta-param = {1}.
ASSIGN c-ccusto-param = {4}.

/*** Se a fun»’o de unidade de neg½cio estiver ativa, gera tt-ped-curva com base na unidade de negocio. ***/
IF  l-unidade-negocio THEN
    FIND tt-ped-curva
        WHERE tt-ped-curva.it-codigo      = nota-fiscal.cod-estabel 
          AND tt-ped-curva.serie          = nota-fiscal.serie
          AND tt-ped-curva.nr-nota-fis    = nota-fiscal.nr-nota-fis
          AND tt-ped-curva.codigo         = c-conta-param
          AND tt-ped-curva.ccusto         = c-ccusto-param
          AND tt-ped-curva.cod-unid-negoc = {3} NO-LOCK NO-ERROR.
ELSE
find tt-ped-curva 
    where tt-ped-curva.it-codigo    = nota-fiscal.cod-estabel  
      and tt-ped-curva.serie        = nota-fiscal.serie                
      and tt-ped-curva.nr-nota-fis  = nota-fiscal.nr-nota-fis 
      and tt-ped-curva.codigo       = c-conta-param
      and tt-ped-curva.ccusto       = c-ccusto-param no-lock no-error.

if not avail tt-ped-curva then do: 
   create tt-ped-curva.
   assign tt-ped-curva.it-codigo   = nota-fiscal.cod-estabel
          tt-ped-curva.serie       = nota-fiscal.serie
          tt-ped-curva.nr-nota-fis = nota-fiscal.nr-nota-fis
          tt-ped-curva.codigo      = c-conta-param
          tt-ped-curva.ccusto      = c-ccusto-param
          i-empresa                = param-global.empresa-prin.
        
    /*** Se a fun»’o de unidade de neg½cio estiver ativa, gera tt-ped-curva com base na unidade de negocio. ***/
    IF  l-unidade-negocio THEN
        ASSIGN tt-ped-curva.cod-unid-negoc = {3}.

    &IF DEFINED (bf_dis_consiste_conta) &then
       FIND FIRST estabelec where estabelec.cod-estabel = nota-fiscal.cod-estabel no-lock no-error.
       run cdp/cd9970.p (input rowid(estabelec), output i-empresa). 
    &endif
   
   /* INICIO UNIFICACAO - CONTA CONTABIL*/

   IF  NOT VALID-HANDLE(h_api_cta_ctbl) THEN
       run prgint/utb/utb743za.py persistent set h_api_cta_ctbl.
   IF  NOT VALID-HANDLE(h_api_ccusto) THEN
       run prgint/utb/utb742za.py persistent set h_api_ccusto.
   RUN pi_valida_cta_ctbl_integr IN h_api_cta_ctbl (INPUT  STRING(i-empresa),           /* EMPRESA EMS2 */
                                                    INPUT  "FTP",                       /* MODULO */
                                                    INPUT  "",                          /* PLANO CONTAS */ 
                                                    INPUT  c-conta-param,               /* CONTA */
                                                    INPUT  "(nenhum)",                  /* FINALIDADES */
                                                    INPUT  nota-fiscal.dt-emis-nota,    /* DATA DE TRANSACAO */  
                                                    OUTPUT TABLE tt_log_erro).          /* ERROS */

   IF  RETURN-VALUE = "OK":U THEN DO:
       ASSIGN v_cod_cta_ctbl = c-conta-param.
       run pi_busca_dados_cta_ctbl in h_api_cta_ctbl (input        STRING(i-empresa),           /* EMPRESA EMS2 */
                                                      input        "",                          /* PLANO DE CONTAS */
                                                      input-output v_cod_cta_ctbl,              /* CONTA */
                                                      input        nota-fiscal.dt-emis-nota,    /* DATA TRANSACAO */   
                                                      output       v_des_cta_ctbl,              /* DESCRICAO CONTA */
                                                      output       v_num_tip_cta_ctbl,          /* TIPO DA CONTA */
                                                      output       v_num_sit_cta_ctbl,          /* SITUA€ÇO DA CONTA */
                                                      output       v_ind_finalid_cta,           /* FINALIDADES DA CONTA */
                                                      output table tt_log_erro).                /* ERROS */ 
       
       IF  RETURN-VALUE = "OK" THEN DO:
           ASSIGN tt-ped-curva.desc-conta = v_des_cta_ctbl.

           IF  {4} <> "" THEN DO:
               run pi_busca_dados_ccusto in h_api_ccusto (input  STRING(i-empresa),           /* EMPRESA EMS2 */
                                                          input  "",                          /* CODIGO DO PLANO CCUSTO */
                                                          input  {4},                         /* CCUSTO */
                                                          input  nota-fiscal.dt-emis-nota,    /* DATA DE TRANSACAO */
                                                          output v_des_ccusto,                /* DESCRICAO DO CCUSTO */
                                                          output table tt_log_erro).          /* ERROS */ 
           
               IF RETURN-VALUE = "OK" THEN 
                 ASSIGN tt-ped-curva.desc-centro = v_des_ccusto.
           END.
       END.
   END.

     if valid-handle (h_api_ccusto) then do:
        delete procedure h_api_ccusto.
        assign h_api_ccusto = ?.    
     end.
     
     if valid-handle (h_api_cta_ctbl) then do:
        delete procedure h_api_cta_ctbl.
        assign h_api_cta_ctbl = ?.    
     end.
END.

ASSIGN tt-ped-curva.dec-1 = tt-ped-curva.dec-1 + {2}.
IF tt-ped-curva.dec-1 < 0 THEN
   ASSIGN tt-ped-curva.vl-debito  = -(tt-ped-curva.dec-1)
          tt-ped-curva.vl-credito = 0.
ELSE 
   ASSIGN tt-ped-curva.vl-credito = tt-ped-curva.dec-1
          tt-ped-curva.vl-debito  = 0.
/* FT0904l.I */
