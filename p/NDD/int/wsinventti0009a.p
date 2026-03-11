DEF INPUT  PARAMETER p-ChaveNFe           AS CHAR NO-UNDO.
DEF INPUT  PARAMETER p-retonro-integracao AS LONGCHAR NO-UNDO.
DEF OUTPUT PARAMETER p-ok                 AS LOGICAL NO-UNDO.

{utp/ut-glob.i}
{cdp/cdcfgman.i}
{int\wsinventti0000.i}
{int\wsinventti0005.i}
/*{intprg/int002b.i}*/
/*{intprg/int500.i}*/

DEF VAR succes AS LOGICAL  NO-UNDO.
DEF VAR my-nodeval AS LONGCHAR NO-UNDO.
DEF VAR pos as int no-undo.  
DEF VAR len as int no-undo. 


find first param-global no-lock no-error.
find first mgadm.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.
DEF VAR v-arquivo AS CHAR NO-UNDO.
create tt-param.
ASSIGN tt-param.arquivo         = "INT002brp.txt"
       tt-param.usuario         = c-seg-usuario
       tt-param.destino         = 3
       tt-param.classifica      = 1
       tt-param.data-exec       = TODAY
       tt-param.hora-exec       = TIME
       tt-param.dt-trans-ini    = TODAY - 180
       tt-param.dt-trans-fin    = TODAY 
       tt-param.i-nro-docto-ini = "0"  
       tt-param.i-nro-docto-fim = "999999999" 
       tt-param.i-cod-emit-ini  = 0 
       tt-param.i-cod-emit-fin  = 999999999. 

DEF BUFFER b-es-nota-rec-inventi FOR es-nota-rec-inventi.

    
DEFINE TEMP-TABLE tt-cfop NO-UNDO
FIELD cod-cfop LIKE int_ds_it_docto_xml.cfop
FIELD indice   AS INTEGER.

DEF TEMP-TABLE tt-dist-emitente NO-UNDO
FIELD cod-emitente LIKE emitente.cod-emitente
FIELD situacao     AS  INTEGER.


DEF VAR v-xml  AS LONGCHAR  NO-UNDO.
DEF VAR v1-xml AS LONGCHAR NO-UNDO.
    
DEF VAR hDoc  AS HANDLE.
DEF VAR i-cont-item AS INT.
DEF VAR hBuf            AS HANDLE   NO-UNDO.
DEF VAR nome            AS CHAR     NO-UNDO.
DEF VAR c-campo         AS CHAR     NO-UNDO.
DEF VAR c-log           AS CHAR     NO-UNDO.
DEF VAR i-cod-emitente  AS INT      NO-UNDO.
DEF VAR c-nome-abrev    AS CHAR     NO-UNDO.
DEF VAR c-dir-xml-entr  AS CHAR     NO-UNDO.
DEF VAR c-dir-xml-saida AS CHAR     NO-UNDO.
DEF VAR c-xml           AS CHAR     NO-UNDO.
DEF VAR m-valid-xml     AS LOG      NO-UNDO     INIT NO.
DEFINE VARIABLE c-time  AS CHAR     NO-UNDO.
DEF VAR v-arquivo-xml       AS CHAR     NO-UNDO.

def var bh          as handle. 
def var fh          as handle. 
def var hc          as handle.
DEF VAR no-1        AS INT NO-UNDO.
def var tabelas     as char.
DEF VAR nprod       AS INT NO-UNDO.
def var vTabela     as CHAR        no-undo.
DEF VAR Importar AS  LOGICAL.
def var rid                   AS ROWID       no-undo.
DEFINE VARIABLE m-aux         AS MEMPTR      NO-UNDO.

def var c-acompanha     as char    no-undo.
DEF VAR h-acomp    AS HANDLE  NO-UNDO.
DEF VAR c-nom-arq  AS CHAR    NO-UNDO.
DEF VAR c-data     AS CHAR    NO-UNDO.
DEF VAR i-seq-item AS INTEGER NO-UNDO.
DEF VAR c-comando  AS CHAR    NO-UNDO.
DEF VAR c-lista    AS CHAR INITIAL "1,2,3,4,5,6,7,8,9,10".
DEF VAR i-cont     AS INTEGER.
DEF VAR i-linha    AS INTEGER.
DEF VAR l-altera   AS LOGICAL INITIAL NO.
DEF VAR l-valida   AS LOGICAL INITIAL NO.
DEF VAR dt-ini         AS DATE FORMAT "99/99/9999".
DEF VAR de-fator       AS DECIMAL NO-UNDO.
DEF VAR l-gera-nota    AS LOGICAL NO-UNDO. 
DEF VAR L-GRAVA        AS LOGICAL NO-UNDO.
DEF VAR L-DESCARTA     AS LOGICAL NO-UNDO.
DEF VAR h-niveis       AS HANDLE  NO-UNDO.
DEF VAR c-item_do_forn AS CHAR    NO-UNDO.
DEF VAR c-nat-operacao AS CHAR    NO-UNDO.
DEF VAR c-cfop         AS CHAR    NO-UNDO.
DEF VAR l-estab        AS LOGICAL NO-UNDO.
DEF VAR l-ok              AS LOGICAL NO-UNDO.
DEF VAR i-ativo           AS INTEGER NO-UNDO.
DEF VAR c-valida-emitente AS CHAR NO-UNDO.

DEF VAR i-orig-icms    like  int_ds_it_docto_xml.orig_icms. 
DEF VAR i-cst-icms     like  int_ds_it_docto_xml.cst_icms. 
DEF VAR i-modBC        like  int_ds_it_docto_xml.modBC.     
DEF VAR i-modbcst      like  int_ds_it_docto_xml.modbcst.   
DEF VAR de-vbc-icms    like  int_ds_it_docto_xml.vbc_icms.  
DEF VAR de-picms       like  int_ds_it_docto_xml.picms.     
DEF VAR de-vicms       like  int_ds_it_docto_xml.vicms. 
DEF VAR de-valor_fcp         like int_ds_it_docto_xml.vicms.  
DEF VAR de-valor_fcp_st      like int_ds_it_docto_xml.vicms.
DEF VAR de-valor-base-fcp-st like int_ds_it_docto_xml.vicms.
DEF VAR de-perc-fcp-st       like int_ds_it_docto_xml.ppis.
DEF VAR de-valor_fcp_st_ret  like int_ds_it_docto_xml.vicms.
DEF VAR de-valor_ipi_devol   like int_ds_it_docto_xml.vicms.
DEF VAR de-vbc-cst-fcp       LIKE int_ds_it_docto_xml.vicms.
DEF VAR de-pmvast      like  int_ds_it_docto_xml.pmvast.    
DEF VAR de-vbcst       like  int_ds_it_docto_xml.vbcst.     
DEF VAR de-picmsst     like  int_ds_it_docto_xml.picmsst.   
DEF VAR de-vicmsst     like  int_ds_it_docto_xml.vicmsst.   
DEF VAR de-vbcstret    like  int_ds_it_docto_xml.vbcstret.  
DEF VAR de-vicmsstret  like  int_ds_it_docto_xml.vicmsstret.
DEF VAR de-vICMSSubs   LIKE  int_ds_it_docto_xml.vICMSSubs.
DEF VAR de-vicmsDeson  like  int_ds_it_docto_xml.vicmsstret.
DEF VAR de-aliq-pis    LIKE  int_ds_it_docto_xml.ppis.
DEF VAR de-aliq-cofins LIKE int_ds_it_docto_xml.pcofins.
DEF VAR de-tot-bicms   LIKE it-nota-fisc.vl-bicms-it.
DEF VAR de-tot-icms    LIKE it-nota-fisc.vl-icms-it.
DEF VAR de-tot-bsubs   LIKE it-nota-fisc.vl-bsubs-it.
DEF VAR de-tot-icmst   LIKE it-nota-fisc.vl-icmsub-it.
DEF VAR de-predbc-icms LIKE it-nota-fisc.perc-red-icm no-undo.
DEF VAR de-pRedBCST    like it-nota-fisc.perc-red-icm no-undo.
DEF VAR de-tot-pis     LIKE int_ds_docto_xml.valor_pis no-undo.       
DEF VAR de-tot-cofins  LIKE int_ds_docto_xml.valor_cofins no-undo.
DEF VAR c-versao-xml   AS CHAR NO-UNDO.
DEF VAR c-anvisa       AS CHAR NO-UNDO.
DEF VAR l-chave-nfe    AS LOG  NO-UNDO.

DEFINE VARIABLE de-base-st-calc  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-perc-st-calc  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor-st-calc AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor-st-tmp  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE c-tabela-pauta   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-tabela-pauta  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-per-sub-tri   AS DECIMAL     NO-UNDO.

DEF VAR i-num-pedido  AS     INTEGER.
DEF VAR c-doc         AS     LONGCHAR NO-UNDO.
def var c-un-for      as     char.
//DEF VAR i-cod-emitente AS INT NO-UNDO.

//DEF BUFFER b-tt-digita             FOR tt-digita.
DEF BUFFER b-int_ds_it_docto_xml   FOR int_ds_it_docto_xml.
DEF BUFFER b-int_ds_docto_xml      FOR int_ds_docto_xml. 
DEF BUFFER b-NDD_ENTRYINTEGRATION  FOR NDD_ENTRYINTEGRATION. 
DEF BUFFER b-estab                 FOR estabelec.
//DEF BUFFER b-tt-xml-dup            FOR tt-xml-dup.
//DEF BUFFER b-tt-docto-xml          FOR tt-docto-xml.

v-arquivo-xml =  'c:\temp\teste-' + TRIM(p-ChaveNFe) + "_" + STRING(TIME) + ".XML".

//DEF VAR h-boin176         AS HANDLE.
//RUN inbo/boin176.p PERSISTENT SET h-boin176. /*  calcula fator de convers∆o */

FIX-CODEPAGE(v-xml)  = "utf-8".
FIX-CODEPAGE(v1-xml) = "utf-8".

ASSIGN tabelas = 'Ide,InfNFe,Emit,EnderEmit,Dest,EnderDest,Det,Prod,DI,Adi,VeicProd,Icms,ICMS00,ICMS10,ICMS20,ICMS30,ICMS40,ICMS51,ICMS60,ICMS70,ICMS90,ICMSSN101,ICMSSN102,ICMSSN201,ICMSSN202,ICMSSN500,ICMSSN900,IPI,IPITrib,IPINT,II,PIS,PISAliq,PISNT,PISOutr,COFINS,COFINSAliq,COFINSNT,COFINSOutr,ISSQN,Total,ICMSTot,RetTrib,Transp,Transporta,VeicTransp,Reboque,Vol,Cobr,Fat,Dup,pag,detpag,InfAdic,Exporta,rastro,med,infprot,compra,infEvento,sefaz,nota' //Imposto,.
       no-1  = 1.
CREATE X-DOCUMENT hDoc.
CREATE X-NODEREF hRoot.

hDoc:LOAD("LONGCHAR",p-retonro-integracao,FALSE).

hDoc:GET-DOCUMENT-ELEMENT(hRoot).
//MESSAGE 5 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
//MESSAGE 1 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
RUN GetChildren(hRoot, 1).
ASSIGN v1-xml = v-xml.

DELETE OBJECT hDoc.
DELETE OBJECT hRoot.


CREATE X-DOCUMENT hDoc.
CREATE X-NODEREF hRoot.
hDoc:LOAD("LONGCHAR",v-xml,FALSE).
hDoc:GET-DOCUMENT-ELEMENT(hRoot).
DO transaction:
  RUN pi-limpa-temp-table.
 RUN GetChildren-1(hRoot, 1).
END.

find first ide           no-error. 
find first emit          no-error. 
find first dest          no-error. 
find first prod          no-error. 
find first icms          no-error. 
find first ipi           no-error. 
find first pis           no-error. 
find first cofins        no-error. 
find first total         no-error. 
find first transporta    no-error. 
find first vol           no-error. 
find first dup           no-error. 
find first infProt       no-error. 
find first infAdic       no-error. 
find first transp        no-error. 
find first ICMSUFDest    no-error. 
find first infEvento     no-error. 

IF avail ide and avail emit  and avail dest and avail prod THEN do:
    RUN pi-integra.
    p-ok  = YES.
   /*
   FIND FIRST tt-docto-xml.
   MESSAGE 'tt-docto-xml.tipo_estab ' tt-docto-xml.tipo_estab VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
   RUN pi-grava-nota.
   */
END.
ELSE DO:
  p-ok = NO.
END.

release int_ds_it_docto_xml.   
release int_ds_docto_xml.      
release NDD_ENTRYINTEGRATION.  
release estabelec.
RUN pi-limpa-temp-table.

PROCEDURE GetChildren:
  
    DEF INPUT PARAM hParent     AS HANDLE   .
    DEF INPUT PARAM level       AS INT      .

    DEF VAR  i-cont      AS INT      .
    DEF VAR  hNoderef    AS HANDLE   .
    DEF VAR  hDBFld      AS HANDLE   .
    DEF VAR  good        AS LOG      .
    //DEF VAR  texto       AS CHAR     NO-UNDO.

    CREATE X-NODEREF hNoderef.
    
    REPEAT i-cont = 1 TO hParent:NUM-CHILDREN:
       
       ASSIGN good = hParent:GET-CHILD(hNoderef,i-cont).
       IF NOT good THEN LEAVE.
       
        IF hNoderef:NAME <> '#Text'  THEN
         ASSIGN nome = hNoderef:NAME.       
        
        IF hNoderef:SUBTYPE = "text"          AND
           hParent:NAME     = nome            OR
           hNoderef:NAME    = '#CDATA-SECTION' AND
           hNoderef:SUBTYPE = 'CDATA-SECTION' THEN DO:

           IF hNoderef:NAME    = '#CDATA-SECTION' AND
              hNoderef:SUBTYPE = 'CDATA-SECTION' THEN
              nome = hParent:NAME.

           IF hParent:NAME  = 'XmlNota' AND hNoderef:NAME = '#cdata-section' THEN do: 
               ASSIGN succes = hNoderef:NODE-VALUE-TO-MEMPTR(m-aux) NO-ERROR.
               
               //MESSAGE 'hParent:NAME ' hParent:NAME SKIP   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

              hNoderef:NODE-VALUE-TO-LONGCHAR(v-xml).

              //MESSAGE LENGTH(v-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
              /*
              IF LENGTH(hNoderef:NODE-VALUE, "RAW") > 32000 THEN DO:
                 ASSIGN succes = hNoderef:NODE-VALUE-TO-MEMPTR(m-aux)
                        pos    = 1
                        len    = 32000.

                 DO WHILE pos < GET-SIZE(m-aux):
                     v-xml = GET-STRING(m-aux, pos, len).
                     /* Do something with my-nodeval */
                     pos = pos + len.

                     MESSAGE 'pos '  pos SKIP
                             'len '  len

                         VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                     MESSAGE  STRING(v-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                 END.
                 SET-SIZE(m-aux) = 0.

              END.
              ELSE 
              ASSIGN v-xml = hNoderef:NODE-VALUE.  
              **/
           END.
        END.
        
        RUN GetChildren(hNoderef, (level + 1)).
    END.

    DELETE OBJECT hNoderef.
END PROCEDURE. 



PROCEDURE GetChildren-1:

    DEF INPUT PARAM vh     AS HANDLE   .
    DEF INPUT PARAM level       AS INT      .
    def var hc as handle.
    def var loop  as int.
    
    create x-noderef hc.

    do loop = 1 to vh:num-children.
        
        vh:get-child(hc,loop).
        
        if loop = 1
        and lookup(vh:name,tabelas) > 0 then 
        do:
            //MESSAGE 'vh:NAME ' vh:NAME VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            create buffer bh for table vh:name.
            bh:buffer-create.
            assign
                vTabela = vh:name
                Importar = yes
                rid = bh:rowid.
        end.
        
        if importar
        and hc:subtype = "text" then 
        do:
            if bh:find-by-rowid(rid) then 
            do:
                fh = bh:buffer-field(vh:name) no-error.
                if valid-handle(fh) then 
                    fh:buffer-value = hc:node-value.
            end.
        end.
        RUN GetChildren-1(hc:handle, (level + 1)).
        
    end.
    
    if valid-handle(vh)
    and lookup(vh:name,tabelas) > 0 then 
        importar = no.


END PROCEDURE.


PROCEDURE pi-integra:

   //empty temp-table tt-docto-xml.
   //empty temp-table tt-it-docto-xml.
   //empty temp-table tt-xml-dup.
   //empty temp-table tt-digita.

   def var  pGrava as logical no-undo.
   def var  pok as logical initial no no-undo.
   def var cSerie  as char no-undo.
   def var cNF     as char no-undo.
   def var cEmit   as char no-undo.
   def var cDest   as char no-undo.
   def var iCont   as integer no-undo.
   def var cAux    as char no-undo.

   ASSIGN cSerie = TRIM(ide.serie)
          cNF    = TRIM(ide.nnf)
          dhEmi  = substring(ide.dhEmi,1,10)
          cEmit  = TRIM(emit.cnpj).
          cDest  = IF TRIM(dest.cnpj)<> "" THEN TRIM(dest.cnpj) ELSE TRIM(dest.cpf).

   IF cSerie = "" THEN cSerie = "1".


   //MESSAGE  'int64(cSerie)' int64(cSerie)   skip 
   //         'int64(cNF)   ' int64(cNF)      skip 
   //         'int64(cEmit) ' int64(cEmit)    skip 
   //         'int64(cDest) ' int64(cDest)    skip 
   //
   //    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

   find first NDD_ENTRYINTEGRATION           
        where NDD_ENTRYINTEGRATION.KIND           = 0             
        and   NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) 
        and   NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    
        and   NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  
        and   NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest) 
        EXCLUSIVE-LOCK no-error.

   IF NOT AVAIL NDD_ENTRYINTEGRATION THEN DO:
      ASSIGN iCont = 1.
      for last NDD_ENTRYINTEGRATION no-lock use-index id:
           assign iCont = NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID + 1.
      END.
      CREATE NDD_ENTRYINTEGRATION.
      assign  NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID = iCont
              NDD_ENTRYINTEGRATION.STATUS_            = 0
              NDD_ENTRYINTEGRATION.KIND               = 0
              NDD_ENTRYINTEGRATION.EMISSIONDATE       = date( int(substring(ide.dhEmi,6,2)),int(substring(ide.dhEmi,9,2)),int(substring(ide.dhEmi,1,4)))
              NDD_ENTRYINTEGRATION.CNPJEMIT           = int64(cEmit)
              NDD_ENTRYINTEGRATION.CNPJDEST           = int64(cDest)
              NDD_ENTRYINTEGRATION.SERIE              = int64(cSerie)
              NDD_ENTRYINTEGRATION.DOCUMENTNUMBER     = int64(cNF)
              NDD_ENTRYINTEGRATION.NSU                = 1.
   END.
   COPY-LOB v1-xml TO NDD_ENTRYINTEGRATION.DOCUMENTDATA.
   release NDD_ENTRYINTEGRATION.
END.



PROCEDURE pi-limpa-temp-table:
   empty temp-table ide.
   empty temp-table InfNFe.
   empty temp-table Emit. 
   empty temp-table EnderEmit.
   empty temp-table Dest.
   empty temp-table EnderDest.
   empty temp-table Det.
   empty temp-table Prod.
   empty temp-table DI.
   empty temp-table Adi.
   empty temp-table VeicProd.
   empty temp-table Icms.
   empty temp-table ICMS00.
   empty temp-table ICMS10.
   empty temp-table ICMS20.
   empty temp-table ICMS30.
   empty temp-table ICMS40.
   empty temp-table ICMS51.
   empty temp-table ICMS60.
   empty temp-table ICMS70.
   empty temp-table ICMS90.
   empty temp-table ICMSSN101.
   empty temp-table ICMSSN102.
   empty temp-table ICMSSN201.
   empty temp-table ICMSSN202.
   empty temp-table ICMSSN500.
   empty temp-table ICMSSN900.
   empty temp-table IPI.
   empty temp-table IPITrib.
   empty temp-table IPINT.
   empty temp-table II.
   empty temp-table PIS.
   empty temp-table PISAliq.
   empty temp-table PISNT.
   empty temp-table PISOutr.
   empty temp-table COFINS.
   empty temp-table COFINSAliq.
   empty temp-table COFINSNT.
   empty temp-table COFINSOutr.
   empty temp-table ISSQN.
   empty temp-table Total.
   empty temp-table ICMSTot.
   empty temp-table RetTrib.
   empty temp-table Transp.
   empty temp-table Transporta.
   empty temp-table VeicTransp.
   empty temp-table Reboque.
   empty temp-table Fat.
   empty temp-table Dup.
   empty temp-table pag.
   empty temp-table detpag .
   empty temp-table InfAdic.
   empty temp-table Exporta.
   empty temp-table rastro .
   empty temp-table med.
   empty temp-table infprot.
   empty temp-table compra.
   empty temp-table infEvento.
   empty temp-table sefaz.
   empty temp-table nota .

   release ide.
   release InfNFe.
   release Emit. 
   release EnderEmit.
   release Dest.
   release EnderDest.
   release Det.
   release Prod.
   release DI.
   release Adi.
   release VeicProd.
   release Icms.
   release ICMS00.
   release ICMS10.
   release ICMS20.
   release ICMS30.
   release ICMS40.
   release ICMS51.
   release ICMS60.
   release ICMS70.
   release ICMS90.
   release ICMSSN101.
   release ICMSSN102.
   release ICMSSN201.
   release ICMSSN202.
   release ICMSSN500.
   release ICMSSN900.
   release IPI.
   release IPITrib.
   release IPINT.
   release II.
   release PIS.
   release PISAliq.
   release PISNT.
   release PISOutr.
   release COFINS.
   release COFINSAliq.
   release COFINSNT.
   release COFINSOutr.
   release ISSQN.
   release Total.
   release ICMSTot.
   release RetTrib.
   release Transp.
   release Transporta.
   release VeicTransp.
   release Reboque.
   release Fat.
   release Dup.
   release pag.
   release detpag .
   release InfAdic.
   release Exporta.
   release rastro .
   release med.
   release infprot.
   release compra.
   release infEvento.
   release sefaz.
   release nota.

END PROCEDURE.
