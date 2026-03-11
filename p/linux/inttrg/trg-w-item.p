/****************************************************************************************************
**   Programa: trg-w-item.p - Trigger de write para a tabela item
**             Atualiza a tabela de integraá∆o de Itens entre Datasul e Sysfarma
**   Data....: Novembro/2015
*****************************************************************************************************/

def new global shared var c-seg-usuario as char no-undo.
 
DEF PARAM BUFFER b-item     FOR ITEM.
DEF PARAM BUFFER b-old-item FOR ITEM.

DEF BUFFER b-int_ds_item FOR int_ds_item.

DEF VAR de-saldo LIKE saldo-estoq.qtidade-atu NO-UNDO.
DEF VAR i-seq-int_ds_item AS INT NO-UNDO.
DEF VAR c-retorno AS CHAR NO-UNDO.
DEF VAR l-difer AS LOG NO-UNDO.
DEF VAR l-novo  AS LOG NO-UNDO.
DEF VAR i-tipo-movto AS INT NO-UNDO.

ASSIGN de-saldo = 0.

IF b-item.cod-obsoleto = 4 THEN DO:
   FOR EACH saldo-estoq WHERE
            saldo-estoq.it-codigo = b-item.it-codigo NO-LOCK:
       ASSIGN de-saldo = de-saldo + saldo-estoq.qtidade-atu - 
                         (saldo-estoq.qt-alocada + saldo-estoq.qt-aloc-ped + saldo-estoq.qt-aloc-prod).
   END.
   
   IF de-saldo > 0 THEN DO:
      MESSAGE "Item possui saldo e n∆o pode ser alterado para Totalmente Obsoleto."
          VIEW-AS ALERT-BOX INFO BUTTONS OK.    
      RETURN "NOK".
   END.
END.

IF PROGRAM-NAME(5) = "dispatch invwr/v34in172.w" THEN DO:

   IF  b-item.fm-codigo < "900" THEN DO:
       ASSIGN l-novo    = NO
              l-difer   = NO
              c-retorno = "".

       IF NEW(b-item) THEN DO:
          ASSIGN l-novo = YES
                 i-tipo-movto = 1.
       END.

       IF l-novo = NO THEN DO:
          BUFFER-COMPARE b-item TO b-old-item SAVE RESULT IN c-retorno.
          IF TRIM(c-retorno) <> "char-1,char-2" THEN DO: 
             ASSIGN l-difer      = YES
                    i-tipo-movto = 2.
          END.
       END.

       IF  l-novo  = YES
       OR  l-difer = YES THEN DO:
           ASSIGN i-seq-int_ds_item = NEXT-VALUE(seq-int-ds-item). /* Preparaá∆o para integraá∆o com Procfit */
           CREATE int_ds_item.
           ASSIGN int_ds_item.tipo_movto                 = i-tipo-movto               
                  int_ds_item.dt_geracao                 = TODAY
                  int_ds_item.hr_geracao                 = STRING(TIME,"hh:mm:ss") 
                  int_ds_item.cod_usuario                = c-seg-usuario
                  int_ds_item.situacao                   = 1 /* Pendente */
                  int_ds_item.pro_codigo_n               = int(b-item.it-codigo) 
                  int_ds_item.pro_descricaocupomfiscal_s = b-item.desc-item 
                  int_ds_item.pro_datacadastro_d         = b-item.data-implant
                  int_ds_item.pro_ncm_s                  = substr(b-item.class-fiscal,1,8)
                  int_ds_item.pro_grupocomercial_n       = INT(b-item.fm-cod-com)
                  int_ds_item.id_sequencial              = i-seq-int_ds_item. /* Preparaá∆o para integraá∆o com Procfit */
        
           FIND FIRST int_ds_ext_item WHERE
                      int_ds_ext_item.it_codigo = b-item.it-codigo NO-LOCK NO-ERROR.
           IF AVAIL int_ds_ext_item THEN DO:
              ASSIGN int_ds_item.pro_ncmipi_n = int_ds_ext_item.ncmipi.
           END.
        
           /*
           /* Atualizaá∆o da tabela de integraá∆o Datasul -> Sysfarma */
           /*           C¢digos de Barra dos Itens - EAN              */  
        
           FOR EACH int-ds-ean-item WHERE
                    int-ds-ean-item.it-codigo = b-item.it-codigo NO-LOCK:
        
               CREATE int_ds_item-compl.
               ASSIGN int_ds_item-compl.tipo-movto          = i-tipo-movto
                      int_ds_item-compl.dt-geracao          = TODAY
                      int_ds_item-compl.hr-geracao          = STRING(TIME,"hh:mm:ss") 
                      int_ds_item-compl.cod-usuario         = c-seg-usuario
                      int_ds_item-compl.situacao            = 1 /* Pendente */
                      int_ds_item-compl.cba-produto-n       = INT(int-ds-ean-item.it-codigo)        
                      int_ds_item-compl.cba-ean-n           = int-ds-ean-item.codigo-ean          
                      int_ds_item-compl.cba-lotemultiplo-n  = int-ds-ean-item.lote-multiplo       
                      int_ds_item-compl.cba-altura-n        = int-ds-ean-item.altura              
                      int_ds_item-compl.cba-largura-n       = int-ds-ean-item.largura             
                      int_ds_item-compl.cba-profundidade-n  = int-ds-ean-item.profundidade        
                      int_ds_item-compl.cba-peso-n          = int-ds-ean-item.peso                
                      int_ds_item-compl.cba-data-cadastro-d = int-ds-ean-item.data-cadastro       
                      int_ds_item-compl.cba-principal-s     = IF int-ds-ean-item.principal = YES THEN
                                                                 "S"
                                                              ELSE 
                                                                 "N"
                      int_ds_item-compl.id_cabecalho        = i-seq-int_ds_item
                      int_ds_item-compl.id_sequencial       = NEXT-VALUE(seq-int_ds_item-compl). /* Preparaá∆o para integraá∆o com Procfit */
           END.
           */
        
           IF b-item.cd-folh-item = "CADITEM" THEN DO:
              FOR EACH it-carac-tec WHERE
                       it-carac-tec.it-codigo = b-item.it-codigo AND
                       it-carac-tec.cd-folha = "CADITEM" NO-LOCK:
              
                  IF it-carac-tec.cd-comp = "10" THEN
                     ASSIGN int_ds_item.pro_descricaoetiqueta_s = substr(it-carac-tec.observacao,1,30).
              
                  IF it-carac-tec.cd-comp = "20" THEN
                     ASSIGN int_ds_item.pro_descricaoweb_s = it-carac-tec.observacao.
                  
                  IF it-carac-tec.cd-comp = "25" THEN
                     ASSIGN int_ds_item.pro_divisao_n = INT(substr(it-carac-tec.observacao,1,3)).          
              
                  IF it-carac-tec.cd-comp = "30" THEN
                     ASSIGN int_ds_item.pro_tipoproduto_n = INT(substr(it-carac-tec.observacao,1,1)).
              
                  IF it-carac-tec.cd-comp = "40" THEN
                     ASSIGN int_ds_item.pro_categoriaconvenio_n = INT(substr(it-carac-tec.observacao,1,2)).
                  
                  IF it-carac-tec.cd-comp = "45" THEN
                     ASSIGN int_ds_item.pro_sazonalidade_n = INT(substr(it-carac-tec.observacao,1,1)).                   
              
                  IF it-carac-tec.cd-comp = "60" THEN
                     ASSIGN int_ds_item.pro_subgrupocomercial_n = INT(substr(it-carac-tec.observacao,1,3)).
              
                  IF it-carac-tec.cd-comp = "65" THEN
                     ASSIGN int_ds_item.pro_sigla_pdv_s = substr(it-carac-tec.observacao,1,15). 
              
                  IF it-carac-tec.cd-comp = "70" THEN
                     ASSIGN int_ds_item.pro_gerapedido_s = substr(it-carac-tec.observacao,1,1). 
              
                  IF b-item.cod-obsoleto = 1 THEN
                     ASSIGN int_ds_item.pro_situacaoproduto_s = "A".
           
                  IF b-item.cod-obsoleto = 2 OR b-item.cod-obsoleto = 3 THEN
                     ASSIGN int_ds_item.pro_situacaoproduto_s = "E".
           
                  IF b-item.cod-obsoleto = 4 THEN
                     ASSIGN int_ds_item.pro_situacaoproduto_s = "I".
              
                  IF it-carac-tec.cd-comp = "90" THEN
                     ASSIGN int_ds_item.pro_lista_s = substr(it-carac-tec.observacao,1,1).                
              
                  IF it-carac-tec.cd-comp = "100" THEN
                     ASSIGN int_ds_item.pro_fracionado_s = substr(it-carac-tec.observacao,1,1).
              
                  IF it-carac-tec.cd-comp = "110" THEN
                     ASSIGN int_ds_item.pro_lastro_n = it-carac-tec.vl-result.
              
                  IF it-carac-tec.cd-comp = "120" THEN
                     ASSIGN int_ds_item.pro_camada_n = it-carac-tec.vl-result.         
              
                  IF it-carac-tec.cd-comp = "140" THEN
                     ASSIGN int_ds_item.pro_publicoalvo_n = INT(substr(it-carac-tec.observacao,1,1)).
              
                  IF it-carac-tec.cd-comp = "150" THEN
                     ASSIGN int_ds_item.pro_informaprescricao_s = substr(it-carac-tec.observacao,1,1).
                  
                  IF it-carac-tec.cd-comp = "170" THEN
                     ASSIGN int_ds_item.pro_monitorado_s = substr(it-carac-tec.observacao,1,1).
              
                  IF it-carac-tec.cd-comp = "180" THEN
                     ASSIGN int_ds_item.pro_tarjado_s = substr(it-carac-tec.observacao,1,1).
              
                  IF it-carac-tec.cd-comp = "190" THEN
                     ASSIGN int_ds_item.pro_sngpc_n  = INT(substr(it-carac-tec.observacao,1,1)).
              
                  IF it-carac-tec.cd-comp = "200" THEN DO:
                     IF substr(it-carac-tec.observacao,1,2) = "  " THEN
                        ASSIGN int_ds_item.pro_portaria_s = "".
                     ELSE
                        ASSIGN int_ds_item.pro_portaria_s = substr(it-carac-tec.observacao,1,2).
                  END.
           
                  IF it-carac-tec.cd-comp = "210" THEN
                     ASSIGN int_ds_item.pro_apresentacao_n = it-carac-tec.vl-result.
              
                  IF it-carac-tec.cd-comp = "225" THEN
                     ASSIGN int_ds_item.pro_dosagemapresentacao_n = INT(substr(it-carac-tec.observacao,1,2)).
              
                  IF it-carac-tec.cd-comp = "230" THEN
                     ASSIGN int_ds_item.pro_concentracao_n = it-carac-tec.vl-result.
              
                  IF it-carac-tec.cd-comp = "240" THEN
                     ASSIGN int_ds_item.pro_dosagemconcentracao_n = INT(substr(it-carac-tec.observacao,1,2)).
              
                  IF it-carac-tec.cd-comp = "250" THEN
                     ASSIGN int_ds_item.pro_nomecomercial_s = it-carac-tec.observacao. 
              
                  IF it-carac-tec.cd-comp = "255" THEN
                     ASSIGN int_ds_item.pro_datasngpc_d = it-carac-tec.dt-result. 
                             
                  IF it-carac-tec.cd-comp = "260" THEN
                     ASSIGN int_ds_item.pro_csta_n = INT(substr(it-carac-tec.observacao,1,1)).
              
                  IF it-carac-tec.cd-comp = "270" THEN
                     ASSIGN int_ds_item.pro_unidademedidamedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
                   
                  IF it-carac-tec.cd-comp = "280" THEN
                     ASSIGN int_ds_item.pro_excecaopiscofinsncm_s = substr(it-carac-tec.observacao,1,1).
              
                  IF it-carac-tec.cd-comp = "290" THEN
                     ASSIGN int_ds_item.pro_tributapis_s = substr(it-carac-tec.observacao,1,1).
              
                  IF it-carac-tec.cd-comp = "300" THEN
                     ASSIGN int_ds_item.pro_tributacofins_s = substr(it-carac-tec.observacao,1,1).
              
                  IF it-carac-tec.cd-comp = "310" THEN
                     ASSIGN int_ds_item.pro_classificacaomedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
                  
                  IF it-carac-tec.cd-comp = "330" THEN
                     ASSIGN int_ds_item.pro_utilizapautafiscal_s = substr(it-carac-tec.observacao,1,1).
              
                  IF it-carac-tec.cd-comp = "340" THEN
                     ASSIGN int_ds_item.pro_valorpautafiscal_n = it-carac-tec.vl-result.
              
                  IF it-carac-tec.cd-comp = "350" THEN
                     ASSIGN int_ds_item.pro_emiteetiqueta_s = substr(it-carac-tec.observacao,1,1).
              
                  IF it-carac-tec.cd-comp = "360" THEN
                     ASSIGN int_ds_item.pro_pbm_s = substr(it-carac-tec.observacao,1,1).
              
                  IF it-carac-tec.cd-comp = "370" THEN
                     ASSIGN int_ds_item.pro_cestabasica_s = substr(it-carac-tec.observacao,1,1).  
              
                  IF it-carac-tec.cd-comp = "380" THEN
                     ASSIGN int_ds_item.pro_reposicaopbm_s = substr(it-carac-tec.observacao,1,1).
                            
                  IF it-carac-tec.cd-comp = "390" THEN
                     ASSIGN int_ds_item.pro_quantidadeembarque_n = DEC(it-carac-tec.observacao).          
                  
                  IF it-carac-tec.cd-comp = "400" THEN
                     ASSIGN int_ds_item.pro_circuladeposito_s = substr(it-carac-tec.observacao,1,1).  
              
                  IF it-carac-tec.cd-comp = "410" THEN
                     ASSIGN int_ds_item.pro_aceitadevolucao_s = substr(it-carac-tec.observacao,1,1).     
                  
                  IF it-carac-tec.cd-comp = "420" THEN
                     ASSIGN int_ds_item.pro_mercadologica_s = substr(it-carac-tec.observacao,1,2).          
           
                  IF it-carac-tec.cd-comp = "430" THEN 
                     ASSIGN int_ds_item.pro_registroms_n = DEC(it-carac-tec.observacao).
              END.
           END.
       END.
   END.
END.

RETURN "OK".

