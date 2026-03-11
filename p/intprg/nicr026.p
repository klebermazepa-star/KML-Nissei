/****************************************************************************
**
**    Programa: nicr025.p - Atualizar Tabela Oracle - Fatura Site
**                         Sysfarma/PRS X Datasul 
**  Tabela Int: int-ds-fat-convenio
*****************************************************************************/

/********************* Temporary Table Definition Begin *********************/

/*{intprg/int-rpw.i}  Se for rodar manual deixar em coment rio */

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR FORMAT "x(12)" NO-UNDO.

/* CONNECT -db /totvs/database/convenio/shconvenio -RO -ld shconvenio -db convenio -ld convenio -U emscustom/emscustom@totvsprod  -c 25000 NO-ERROR. */

/* FIND FIRST int_ds_fat_convenio NO-LOCK                                        */
/*      WHERE int_ds_fat_convenio.dat_emissao  = 11/20/2018                      */
/*        AND int_ds_fat_convenio.situacao     = 1                               */
/* /*      AND int_ds_fat_convenio.nro_fatura  = "0000505392" */ NO-ERROR.       */
/* IF NOT AVAIL int_ds_fat_convenio THEN DO:                                     */
/*     RUN intprg/int999.p (INPUT "FATSIT",                                      */
/*                          INPUT STRING(""),                                    */
/*                          INPUT "Nao existe registro pendente de atualizacao", */
/*                          INPUT 1, /* 2 - Integrado */                         */
/*                          INPUT c-seg-usuario,                                 */
/*                          INPUT "nicr026.p").                                  */
/* END.                                                                          */



FOR EACH int_ds_fat_convenio 
   WHERE int_ds_fat_convenio.dat_emissao  >= TODAY - 50
     AND int_ds_fat_convenio.situacao     = 1
/*      AND int_ds_fat_convenio.nro_fatura  = "0000505392" */
    NO-LOCK:

    FIND FIRST int-ds-fat-convenio EXCLUSIVE-LOCK USE-INDEX pk-data
         WHERE int-ds-fat-convenio.cod-convenio = int_ds_fat_convenio.cod_convenio
           AND int-ds-fat-convenio.nro-fatura   = int_ds_fat_convenio.nro_fatura  NO-ERROR.
    IF NOT AVAIL int-ds-fat-convenio THEN DO:
        

        FOR EACH int_ds_fat_conv_site
           WHERE int_ds_fat_conv_site.nro_fatura  = int_ds_fat_convenio.nro_fatura :

/*             FIND FIRST int-ds-fat-conv-site EXCLUSIVE-LOCK                                            */
/*                  WHERE int-ds-fat-conv-site.cod-estabel = int_ds_fat_conv_site.cod_estabel            */
/*                    AND int-ds-fat-conv-site.nro-fatura  = int_ds_fat_conv_site.nro_fatura             */
/*                    AND int-ds-fat-conv-site.cnpj-filial = int_ds_fat_conv_site.cnpj_filial            */
/*                    AND int-ds-fat-conv-site.nro-cupom   = int_ds_fat_conv_site.nro_cupom              */
/*                    AND int-ds-fat-conv-site.serie       = int_ds_fat_conv_site.serie                  */
/*                    AND int-ds-fat-conv-site.parcela     = int_ds_fat_conv_site.parcela      NO-ERROR. */
/*             IF NOT AVAIL int-ds-fat-conv-site THEN DO:                                                */

            FIND FIRST int-ds-fat-conv-site EXCLUSIVE-LOCK USE-INDEX pk-int-ds-fat-conv-site
                 WHERE int-ds-fat-conv-site.id-fat-conv-site = int_ds_fat_conv_site.id_fat_conv_site 
                   
/*                    AND int-ds-fat-conv-site.nro-cupom   = int_ds_fat_conv_site.nro_cupom */
/*                    AND int-ds-fat-conv-site.serie       = int_ds_fat_conv_site.serie     */
/*                    AND int-ds-fat-conv-site.parcela     = int_ds_fat_conv_site.parcela   */
                NO-ERROR.
            IF NOT AVAIL int-ds-fat-conv-site THEN DO:

                CREATE int-ds-fat-conv-site.
                ASSIGN int-ds-fat-conv-site.categoria           = int_ds_fat_conv_site.categoria         
                       int-ds-fat-conv-site.cnpj                = int_ds_fat_conv_site.cnpj              
                       int-ds-fat-conv-site.cnpj-filial         = int_ds_fat_conv_site.cnpj_filial       
                       int-ds-fat-conv-site.cod-banco           = int_ds_fat_conv_site.cod_banco         
                       int-ds-fat-conv-site.cod-convenio        = int_ds_fat_conv_site.cod_convenio      
                       int-ds-fat-conv-site.cod-estabel         = int_ds_fat_conv_site.cod_estabel       
                       int-ds-fat-conv-site.dat-cupom           = int_ds_fat_conv_site.dat_cupom         
                       int-ds-fat-conv-site.dig-nosso-num-banc  = int_ds_fat_conv_site.dig_nosso_num_banc
                       int-ds-fat-conv-site.id-fat-conv-site    = int_ds_fat_conv_site.id_fat_conv_site  
                       int-ds-fat-conv-site.indterminal         = int_ds_fat_conv_site.indterminal       
                       int-ds-fat-conv-site.nosso-numero-banc   = int_ds_fat_conv_site.nosso_numero_banc 
                       int-ds-fat-conv-site.nro-cupom           = int_ds_fat_conv_site.nro_cupom         
                       int-ds-fat-conv-site.nro-fatura          = int_ds_fat_conv_site.nro_fatura        
                       int-ds-fat-conv-site.orgao               = int_ds_fat_conv_site.orgao             
                       int-ds-fat-conv-site.parcela             = int_ds_fat_conv_site.parcela           
                       int-ds-fat-conv-site.serie               = int_ds_fat_conv_site.serie             
                       int-ds-fat-conv-site.situacao            = int_ds_fat_conv_site.situacao          .
            END.
            ELSE DO:
                ASSIGN int-ds-fat-conv-site.categoria           = int_ds_fat_conv_site.categoria         
                       int-ds-fat-conv-site.cnpj                = int_ds_fat_conv_site.cnpj              
                       int-ds-fat-conv-site.cnpj-filial         = int_ds_fat_conv_site.cnpj_filial       
                       int-ds-fat-conv-site.cod-banco           = int_ds_fat_conv_site.cod_banco         
                       int-ds-fat-conv-site.cod-convenio        = int_ds_fat_conv_site.cod_convenio      
                       int-ds-fat-conv-site.cod-estabel         = int_ds_fat_conv_site.cod_estabel       
                       int-ds-fat-conv-site.dat-cupom           = int_ds_fat_conv_site.dat_cupom         
                       int-ds-fat-conv-site.dig-nosso-num-banc  = int_ds_fat_conv_site.dig_nosso_num_banc
                       int-ds-fat-conv-site.id-fat-conv-site    = int_ds_fat_conv_site.id_fat_conv_site  
                       int-ds-fat-conv-site.indterminal         = int_ds_fat_conv_site.indterminal       
                       int-ds-fat-conv-site.nosso-numero-banc   = int_ds_fat_conv_site.nosso_numero_banc 
                       int-ds-fat-conv-site.nro-cupom           = int_ds_fat_conv_site.nro_cupom         
                       int-ds-fat-conv-site.nro-fatura          = int_ds_fat_conv_site.nro_fatura        
                       int-ds-fat-conv-site.orgao               = int_ds_fat_conv_site.orgao             
                       int-ds-fat-conv-site.parcela             = int_ds_fat_conv_site.parcela           
                       int-ds-fat-conv-site.serie               = int_ds_fat_conv_site.serie             
                       int-ds-fat-conv-site.situacao            = int_ds_fat_conv_site.situacao          .
            END.
        END.


        CREATE int-ds-fat-convenio.
        ASSIGN int-ds-fat-convenio.cnpj                = int_ds_fat_convenio.cnpj                
               int-ds-fat-convenio.cnpj-filial         = int_ds_fat_convenio.cnpj_filial         
               int-ds-fat-convenio.cod-banco           = int_ds_fat_convenio.cod_banco           
               int-ds-fat-convenio.cod-convenio        = int_ds_fat_convenio.cod_convenio        
               int-ds-fat-convenio.cod-estabel         = int_ds_fat_convenio.cod_estabel         
               int-ds-fat-convenio.dat-emissao         = int_ds_fat_convenio.dat_emissao         
               int-ds-fat-convenio.dat-liquidacao      = int_ds_fat_convenio.dat_liquidacao      
               int-ds-fat-convenio.dat-vencto          = int_ds_fat_convenio.dat_vencto          
               int-ds-fat-convenio.dig-nosso-num-banc  = int_ds_fat_convenio.dig_nosso_num_banc  
               int-ds-fat-convenio.nosso-numero-banc   = int_ds_fat_convenio.nosso_numero_banc   
               int-ds-fat-convenio.nro-fatura          = int_ds_fat_convenio.nro_fatura          
               int-ds-fat-convenio.situacao            = int_ds_fat_convenio.situacao            
               int-ds-fat-convenio.tipo-movto          = int_ds_fat_convenio.tipo_movto          
               int-ds-fat-convenio.vl-original         = int_ds_fat_convenio.vl_original         
               int-ds-fat-convenio.vl-saldo            = int_ds_fat_convenio.vl_saldo           .  

        /* Verificar Se a tabela FILHA estiver Vazia, apagar a Tabela PAI */
        IF NOT CAN-FIND(FIRST int_ds_fat_conv_site
                        WHERE int_ds_fat_conv_site.nro_fatura  = int_ds_fat_convenio.nro_fatura ) THEN DO:
            DELETE int-ds-fat-convenio.
        END.
    END.
    ELSE DO:

        IF int-ds-fat-convenio.tipo-movto <> int_ds_fat_convenio.tipo_movto THEN DO:

            OUTPUT TO "c:\temp\cleyton\FaturasModificadas_.txt" NO-CONVERT APPEND.
                PUT UNFORMATTED int_ds_fat_convenio.nro_fatura
                                int-ds-fat-convenio.tipo-movto
                                int_ds_fat_convenio.tipo_movto  SKIP.
            OUTPUT CLOSE.

            IF int_ds_fat_convenio.tipo_movto = 2 THEN DO:
                ASSIGN int-ds-fat-convenio.tipo-movto         = 2 
                       int-ds-fat-convenio.dat-vencto         = int_ds_fat_convenio.dat_vencto  
                       int-ds-fat-convenio.vl-original        = int_ds_fat_convenio.vl_original    
                       int-ds-fat-convenio.vl-saldo           = int_ds_fat_convenio.vl_saldo   
                       int-ds-fat-convenio.situacao           = int_ds_fat_convenio.situacao.   
            END.
            IF int_ds_fat_convenio.tipo_movto = 3 THEN DO:
                ASSIGN int-ds-fat-convenio.tipo-movto  = 3 
                       int-ds-fat-convenio.situacao    = int_ds_fat_convenio.situacao.
            END.
            ELSE IF int_ds_fat_convenio.tipo_movto = 4 THEN DO:
                ASSIGN int-ds-fat-convenio.tipo-movto         = 4 
                       int-ds-fat-convenio.situacao           = int_ds_fat_convenio.situacao
                       int-ds-fat-convenio.dat-liquidacao     = int_ds_fat_convenio.dat_liquidacao.
            END.

        END.

    END.
END.


RETURN "OK".
