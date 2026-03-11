/*********************************************************************************
**                                                                              **
**      Copyright TOTVS S.A. (2013)                                             **
**      Todos os Direitos Reservados.                                           **
**                                                                              **
**      Este fonte e de propriedade exclusiva da TOTVS, sua reprodu‡Æo          **
**      parcial ou total por qualquer meio, so podera ser feita mediante        **
**      autoriza‡Æo expressa.                                                   **
**                                                                              **
**********************************************************************************
**                                                                              **
**      Programa : cd9701.i                                                     **
**      Include para definir e atribuir valor … vari vel l-mult-natur-receb,    **
**      com base no valor da fun‡Æo USA-MULT-NAT-RECEB.                         **
**      Esta vari vel ‚ utilizada principalmente em programas dos m¢dulos de    **
**      Recebimento (MRE) e de Obriga‡äes Fiscais (MOF) para indicar se ‚       **
**      utilizada m£ltiplas naturezas de opera‡Æo no recebimento ou nÆo.        **
**      (Naturezas … n¡vel de item - Naturezas Fiscais).                        **
**                                                                              **
**      OBS: Para criar ou alterar o valor da fun‡Æo USA-MULT-NAT-RECEB         **
**      utilizar o programa re0103 (Parƒmetros do recebimento).                 **
**                                                                              **
*********************************************************************************/

DEFINE VARIABLE l-mult-natur-receb AS LOGICAL INITIAL FALSE NO-UNDO.

/* Verifica se existe a fun‡Æo USA-MULT-NAT-RECEB ativa */
FOR funcao FIELD (ativo) WHERE funcao.cd-funcao = "USA-MULT-NAT-RECEB" NO-LOCK:
    ASSIGN l-mult-natur-receb = funcao.ativo.
END.
