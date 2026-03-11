/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i trg-d-doc-fisico 2.06.00.001}  
/****************************************************************************************************
**  Programa ........: intprg/trg-d-doc-fisico.p
**  Data ............: Janeiro/2016
*****************************************************************************************************/
DEFINE PARAMETER BUFFER b-doc-fisico FOR doc-fisico.

{utp/ut-glob.i}

FOR FIRST int_ds_docto_wms WHERE
          int_ds_docto_wms.doc_numero_n = b-doc-fisico.nro-docto   AND
          int_ds_docto_wms.doc_serie_s  = b-doc-fisico.serie-docto AND
          int_ds_docto_wms.doc_origem_n = b-doc-fisico.cod-emitente query-tuning(no-lookahead):
       
    DELETE int_ds_docto_wms.
END.

FOR FIRST int_ds_docto_xml WHERE
           int(int_ds_docto_xml.nNF)     = int(b-doc-fisico.nro-docto) AND
           int_ds_docto_xml.serie        = b-doc-fisico.serie-docto    AND
           int_ds_docto_xml.tipo_nota    = b-doc-fisico.tipo-nota AND 
           int_ds_docto_xml.cod_emitente = b-doc-fisico.cod-emitente 
        query-tuning(no-lookahead):
END.

IF AVAIL int_ds_docto_xml 
THEN DO:

    /*
   ASSIGN int_ds_docto_xml.situacao = 2 /* Liberado */
          int_ds_docto_xml.sit-re   = 1.
   */
    /* novo recebimento CD */
    for first int_ds_docto_wms fields (situacao datamovimentacao_d) no-lock where 
        int_ds_docto_wms.doc_numero_n = int_ds_docto_xml.nNF   and
        int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie and
        int_ds_docto_wms.cnpj_cpf     = int_ds_docto_xml.CNPJ
        query-tuning(no-lookahead): 
        
        end.
    if not avail int_ds_docto_wms then do:
        create int_ds_docto_wms.
        assign int_ds_docto_wms.doc_numero_n  = int_ds_docto_xml.nNF 
               int_ds_docto_wms.doc_serie_s   = int_ds_docto_xml.serie
               int_ds_docto_wms.cnpj_cpf      = int_ds_docto_xml.CNPJ
               int_ds_docto_wms.id_sequencial = NEXT-VALUE(seq-int-ds-docto-wms) /* Prepara‡Æo para integra‡Æo com Procfit */
               int_ds_docto_wms.situacao      = 0.
        for first emitente fields (cgc natureza)
            no-lock where 
            emitente.cod-emitente = b-doc-fisico.cod-emitente:
            assign int_ds_docto_wms.cnpj_cpf        = emitente.cgc 
                   int_ds_docto_wms.tipo_fornecedor = if emitente.natureza = 1 then "F" else "J".
        end.
    end.
    if int_ds_docto_wms.datamovimentacao_d = ? then
        assign int_ds_docto_wms.datamovimentacao_d = b-doc-fisico.dt-trans.
               int_ds_docto_wms.horamovimentacao_s = "00:00:01".

    assign int_ds_docto_wms.situacao = 40.
    assign int_ds_docto_xml.situacao = 2 /* Liberado */
           int_ds_docto_xml.sit_re   = int_ds_docto_wms.situacao.

   FOR EACH int_ds_it_docto_xml EXCLUSIVE-LOCK WHERE 
            int_ds_it_docto_xml.serie         =  int_ds_docto_xml.serie         AND
            int(int_ds_it_docto_xml.nNF)      =  int(int_ds_docto_xml.nNF)      AND
            int_ds_it_docto_xml.cod_emitente  =  int_ds_docto_xml.cod_emitente  AND
            int_ds_it_docto_xml.tipo_nota     =  int_ds_docto_xml.tipo_nota     AND
            int_ds_it_docto_xml.situacao      =  3 /* Atualizado */               AND  
            int_ds_it_docto_xml.tipo_contr    =  1 /* Fisico   */ 
       query-tuning(no-lookahead):                              
        
        ASSIGN int_ds_it_docto_xml.situacao = int_ds_docto_xml.situacao. 

    END.

    FOR EACH int_ds_doc WHERE
             int_ds_doc.tipo_nota      = b-doc-fisico.tipo-nota       AND 
             int(int_ds_doc.nro_docto) = int(b-doc-fisico.nro-docto)  AND
             int_ds_doc.cod_emitente = b-doc-fisico.cod-emitente  AND
             int_ds_doc.nat_operacao = ""                         AND  
             int_ds_doc.serie_docto  = b-doc-fisico.serie-docto  query-tuning(no-lookahead) :
                       
        FOR EACH int_ds_it_doc OF int_ds_doc query-tuning(no-lookahead):

            DELETE int_ds_it_doc.
                  
        END.

        DELETE int_ds_doc.
             
    END.

    FOR EACH int_ds_doc_erro WHERE
             int_ds_doc_erro.serie_docto  = b-doc-fisico.serie-docto  AND 
             int_ds_doc_erro.cod_emitente = b-doc-fisico.cod-emitente AND
             int(int_ds_doc_erro.nro_docto) = int(b-doc-fisico.nro-docto)    AND 
             int_ds_doc_erro.tipo_nota    = b-doc-fisico.tipo-nota  query-tuning(no-lookahead) :
             
        DELETE int_ds_doc_erro.

    END.
    RELEASE int_ds_docto_xml.

END.


RETURN "OK":U.

