/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser  feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i tgr-d-docum-est 2.06.00.001}  
/****************************************************************************************************
**  Programa ........: intprg/tgr-d-docum-est.p
**  Data ............: Janeiro/2016
*****************************************************************************************************/
DEFINE PARAMETER BUFFER b-docum-est FOR docum-est.


for first emitente no-lock where 
    emitente.cod-emitente = b-docum-est.cod-emitente 
    :
    for each int_ds_nota_entrada where
        int_ds_nota_entrada.nen_cnpj_origem_s = trim(emitente.cgc) and
        int_ds_nota_entrada.nen_serie_s = trim(b-docum-est.serie-docto) and
        int_ds_nota_entrada.nen_notafiscal_n = int(b-docum-est.nro-docto) :

        for first estabelec fields (cod-estabel cgc)
            where estabelec.cod-estabel = b-docum-est.cod-estabel 
            : 

            for first cst_estabelec where cst_estabelec.cod_estabel = estabelec.cod-estabel 
                :

                /* nota destino procfit */
                if cst_estabelec.dt_inicio_oper <> ? and
                   cst_estabelec.dt_inicio_oper <= b-docum-est.dt-trans then do:
                    assign int_ds_nota_entrada.nen_conferida_n = 0
                           int_ds_nota_entrada.situacao = 2.
                end.
                /* nota destino Oblak */
                else do:
                    assign int_ds_nota_entrada.nen_conferida_n = 1
                           int_ds_nota_entrada.situacao = 5.
                end.
            end.
        end.
    end.
end.
def var l-ok as logical no-undo.
/* eliminar duplicatas de devolução */

if b-docum-est.esp-docto = 20 /* NFD */ and b-docum-est.cod-estabel <> "973" then 
do-1: do:
    for first estabelec fields (cod-estabel cgc)
        where estabelec.cod-estabel = b-docum-est.cod-estabel: 

        /* nota procfit */
        for first cst_estabelec
            where cst_estabelec.cod_estabel = estabelec.cod-estabel
            :
            if cst_estabelec.dt_inicio_oper <> ? and
               cst_estabelec.dt_inicio_oper <= b-docum-est.dt-emissao then do:
                assign l-ok = no.
                /* documentos ainda sem nota fiscal */
               for each cst_fat_devol WHERE
                        cst_fat_devol.cod_estabel  = b-docum-est.cod-estabel  AND
                        cst_fat_devol.serie_docto  = b-docum-est.serie-docto  AND
                        cst_fat_devol.nro_docto    = b-docum-est.nro-docto    AND
                        cst_fat_devol.cod_emitente = b-docum-est.cod-emitente AND 
                        cst_fat_devol.nat_operacao = b-docum-est.nat-operacao :
                    for each int_dp_nota_devolucao where
                        int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s = estabelec.cgc and
                        int_dp_nota_devolucao.ndv_serie_s       = cst_fat_devol.serie_docto and
                        int_dp_nota_devolucao.ndv_notafiscal_n  = int(cst_fat_devol.numero_dev)
                        :
                        assign int_dp_nota_devolucao.situacao = 1.
                        assign l-ok = yes.
                    end.                
                    if l-ok then do:
                        delete cst_fat_devol.
                        leave do-1.
                    end.
                end.
            end.
        end.

        /* notas oblak */
        assign l-ok = no.
        /* documentos ainda sem nota fiscal */
        for each cst_fat_devol WHERE
                 cst_fat_devol.cod_estabel  = b-docum-est.cod-estabel  AND
                 cst_fat_devol.serie_docto  = b-docum-est.serie-docto  AND
                 cst_fat_devol.nro_docto    = b-docum-est.nro-docto    AND
                 cst_fat_devol.cod_emitente = b-docum-est.cod-emitente AND 
                 cst_fat_devol.nat_operacao = b-docum-est.nat-operacao :
            for each int_ds_devolucao_cupom where
                int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc and
                int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev
                :
                assign int_ds_devolucao_cupom.situacao = 1.
                assign l-ok = yes.
            end.                
            if l-ok then delete cst_fat_devol.
        end.
        if not l-ok then
        /* documentos com nota fiscal - alterou o número */
        for each item-doc-est of b-docum-est
            :
            for each cst_fat_devol where 
                cst_fat_devol.cod_estabel = b-docum-est.cod-estabel and
                cst_fat_devol.serie_docto = item-doc-est.serie-docto and
                cst_fat_devol.nro_docto   = item-doc-est.nr-pedcli
                : /* numero anterior do documento */
                if not can-find(first docum-est no-lock where
                                docum-est.cod-estabel = cst_fat_devol.cod_estabel and
                                docum-est.serie-docto = cst_fat_devol.serie_docto and
                                docum-est.nro-docto   = cst_fat_devol.nro_docto   and
                                docum-est.nro-docto  <> b-docum-est.nro-docto) then do:
                    for each int_ds_devolucao_cupom where
                        int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc and
                        int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev
                        :
                        assign int_ds_devolucao_cupom.situacao = 1.
                        assign l-ok = yes.
                    end.                
                end.
                if l-ok then delete cst_fat_devol.
            end.
            if not l-ok then
            for each cst_fat_devol where 
                cst_fat_devol.cod_estabel = b-docum-est.cod-estabel and
                cst_fat_devol.serie_docto = item-doc-est.serie-docto and
                cst_fat_devol.nro_comp    = item-doc-est.nro-comp
                 :
                if not can-find(first docum-est no-lock where
                                docum-est.cod-estabel = cst_fat_devol.cod_estabel and
                                docum-est.serie-docto = cst_fat_devol.serie_docto and
                                docum-est.nro-docto   = cst_fat_devol.nro_docto   and
                                docum-est.nro-docto  <> b-docum-est.nro-docto) then do:
                    for each int_ds_devolucao_cupom where
                        int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc and
                        int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev
                        :
                        assign int_ds_devolucao_cupom.situacao = 1.
                    end.                
                end.
                if l-ok then delete cst_fat_devol.
            end.
        end.
    end.
end.

IF b-docum-est.esp-docto <> 23 /* NFT */ OR b-docum-est.cod-estabel = "973" THEN 
FOR EACH int_ds_docto_xml NO-LOCK WHERE
    int_ds_docto_xml.serie        = b-docum-est.serie          AND
    int_ds_docto_xml.tipo_nota    = b-docum-est.tipo-nota      AND 
    int_ds_docto_xml.cod_emitente = b-docum-est.cod-emitente   AND
    int_ds_docto_xml.nNF          = trim(string(int(b-docum-est.nro-docto))) AND 
    int_ds_docto_xml.cod_estab    = b-docum-est.cod-estabel
    :
    
  //  IF int(int_ds_docto_xml.nNF) <> int(b-docum-est.nro-docto) THEN NEXT.

    FIND CURRENT int_ds_docto_xml EXCLUSIVE-LOCK.

   /* Novo recebimento CD */
   
   assign int_ds_docto_xml.situacao = 1 /* Liberado */.

   FOR EACH int_ds_it_docto_xml EXCLUSIVE-LOCK WHERE 
            int_ds_it_docto_xml.serie         =  int_ds_docto_xml.serie         AND
            int_ds_it_docto_xml.nNF           =  int_ds_docto_xml.nNF           AND
            int_ds_it_docto_xml.cod_emitente  =  int_ds_docto_xml.cod_emitente  AND
            int_ds_it_docto_xml.tipo_nota     =  int_ds_docto_xml.tipo_nota     AND
            int_ds_it_docto_xml.situacao      =  3 /* Atualizado */             AND  
            int_ds_it_docto_xml.tipo_contr    =  4 /* Debito Direto */ 
            :                              
        
        ASSIGN int_ds_it_docto_xml.situacao = int_ds_docto_xml.situacao. 

    END.

    RELEASE int_ds_it_docto_xml.

    FOR EACH int_ds_doc EXCLUSIVE-LOCK WHERE
             int_ds_doc.tipo_nota      = b-docum-est.tipo-nota      AND 
             int_ds_doc.nro_docto      = b-docum-est.nro-docto      AND
             int_ds_doc.cod_emitente = b-docum-est.cod-emitente     AND
             int_ds_doc.nat_operacao = b-docum-est.nat-operacao     AND  
             int_ds_doc.serie_docto  = b-docum-est.serie-docto  
            :
                       
        FOR EACH int_ds_it_doc EXCLUSIVE-LOCK OF int_ds_doc :

            DELETE int_ds_it_doc.
                  
        END.

        RELEASE  int_ds_it_doc.

        DELETE int_ds_doc.
             
    END.
    RELEASE int_ds_doc.

    FOR EACH int_ds_doc_erro EXCLUSIVE-LOCK WHERE
             int_ds_doc_erro.serie_docto  = b-docum-est.serie-docto  AND 
             int_ds_doc_erro.cod_emitente = b-docum-est.cod-emitente AND
             int_ds_doc_erro.nro_docto    = b-docum-est.nro-docto    AND 
             int_ds_doc_erro.tipo_nota    = b-docum-est.tipo-nota    AND
             int_ds_doc_erro.nat_operacao = b-docum-est.nat-operacao :
             
        DELETE int_ds_doc_erro.

    END.
    RELEASE int_ds_docto_xml.
END.

for each cst_docum_est_custo EXCLUSIVE where 
    cst_docum_est_custo.serie_docto  = b-docum-est.serie-docto   and
    cst_docum_est_custo.nro_docto    = b-docum-est.nro-docto     and
    cst_docum_est_custo.cod_emitente = b-docum-est.cod-emitente  and
    cst_docum_est_custo.nat_operacao = b-docum-est.nat-operacao:
    delete cst_docum_est_custo.
end.

RETURN "OK":U.

