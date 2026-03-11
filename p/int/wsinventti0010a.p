/********************************************************************************************************        
*Programa.: wsinventti0008.p                                                                            * 
*Descricao: gera‡Æo XML MDFe                                                                            *
*Autor....:                                                                                             * 
*Data.....: 05/2023                                                                                     * 
*********************************************************************************************************/

DEFINE INPUT  PARAMETER p-rowid-mdfe AS ROWID       NO-UNDO.
DEFINE OUTPUT PARAMETER plcXMLMDFe   AS LONGCHAR    NO-UNDO.

{adapters/xml/ep2/axsep031.i}
{adapters/xml/ep2/axsep031ExtraDeclarations.i}
{adapters/xml/ep2/axsep006extradeclarations.i}

{cdp/cd0666.i}
{cdp/cdcfgdis.i}
{include/i-epc200.i AXSEP031}

DEFINE VARIABLE hXMLMDFe     AS HANDLE    NO-UNDO.
DEFINE VARIABLE c-id-mdfe    AS CHARACTER NO-UNDO.
DEFINE VARIABLE c-qrcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE CNPJ         AS CHARACTER NO-UNDO.
DEFINE VARIABLE xContato     AS CHARACTER NO-UNDO.
DEFINE VARIABLE email        AS CHARACTER NO-UNDO.
DEFINE VARIABLE fone         AS CHARACTER NO-UNDO.
DEFINE VARIABLE idCSRT       AS CHARACTER NO-UNDO.
DEFINE VARIABLE hashCSRT     AS CHARACTER NO-UNDO.
DEFINE VARIABLE PcVersLayout AS CHARACTER   NO-UNDO.

{xmlinc/xmlloadgenxml.i &GenXml="hGenXml" &GXReturnValue="cReturnValue"}

{adapters/xml/ep2/axsep031Upsert.i}

RUN pi-limpa-temp-tables.
    
FIND FIRST mdfe-docto NO-LOCK WHERE rowid(mdfe-docto) = p-rowid-mdfe NO-ERROR.

IF AVAILABLE mdfe-docto THEN DO:

    FIND FIRST mdfe-param NO-LOCK WHERE mdfe-param.cod-estabel = mdfe-docto.cod-estab NO-ERROR.

    RUN pi-carrega-docto.
END.

IF NOT CAN-FIND(FIRST ttMDFe) THEN
    RETURN "NOK".

/* RESETA OS VALORES */
RUN reset IN hGenXml.

/* SETA VALOR DE ENCODING */
RUN setEncoding IN hGenXml ("UTF-8").

/*FOR FIRST ttstack: END.

ASSIGN c-id-mdfe  = ""
       iId        = ?
       lLayoutXML = YES
       idCSRT     = ?
       hashCSRT   = ?
       PcVersLayout = "3.00".

FOR EACH ttMDFe:

    RUN addNode IN hGenXml (getStack(), "IntegracaoMDFe", "", OUTPUT iId).

    addStack(iId).
        ASSIGN c-id-mdfe = "MDFe" + ttMDFe.cMDF.
    
        RUN addNode IN hGenXml (getStack(), "MDFe", "", OUTPUT iId).
        RUN setAttribute IN hGenXml (INPUT iId,  "xmlns",   "http://www.portalfiscal.inf.br/mdfe").
    
        addStack(iId).
            RUN addNode IN hGenXml (getStack(), "infMDFe", "", OUTPUT iId).
            addStack(iId).
                RUN setAttribute IN hGenXml (INPUT iId, "versao", PcVersLayout).
                RUN setAttribute IN hGenXml (INPUT iId, "Id",     c-id-mdfe).
    
                RUN addNode IN hGenXml (getStack(), "ide", "", OUTPUT iId).
                addStack(iId).
                    {adapters/xml/ep2/axsep017nodechar.i "cUF"      ttMDFe.cUF      "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "tpAmb"    ttMDFe.tpAmb    "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "tpEmit"   ttMDFe.tpEmit   "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "tpTransp" ttMDFe.tpTransp "NO"}
                    {adapters/xml/ep2/axsep017nodechar.i "mod"      ttMDFe.mod      "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "serie"    ttMDFe.serie    "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "nMDF"     ttMDFe.nMDF     "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "cMDF"     ttMDFe.cMDFE    "NO"}
                    {adapters/xml/ep2/axsep017nodechar.i "cDV"      ttMDFe.cDV      "NO"}
                    {adapters/xml/ep2/axsep017nodechar.i "modal"    ttMDFe.modal    "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "dhEmi"    ttMDFe.dhEmi    "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "tpEmis"   ttMDFe.tpEmis   "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "procEmi"  ttMDFe.procEmi  "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "verProc"  ttMDFe.verProc  "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "UFIni"    ttMDFe.UFIni    "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i "UFFim"    ttMDFe.UFFim    "YES"}
                               /*infMunCarrega*/
                    FOR EACH ttinfMunCarrega OF ttMDFe:
                        RUN addNode IN hGenXml (getStack(), "infMunCarrega", "", OUTPUT iId).
                        addStack(iId).
                            {adapters/xml/ep2/axsep017nodechar.i  "cMunCarrega"    ttinfMunCarrega.cMunCarrega    "YES"}
                            IF ttinfMunCarrega.xMunCarrega = "Exterior" THEN DO:
                                {adapters/xml/ep2/axsep017nodechar.i  "xMunCarrega"    ttinfMunCarrega.xMunCarrega    "YES"}
                            END.
                            ELSE DO:
                                {adapters/xml/ep2/axsep017nodechar.i  "xMunCarrega"    ttinfMunCarrega.xMunCarrega    "YES"}
                            END.
                        delStack().
                    END.
                    FOR EACH ttinfPercurso OF ttMDFe:
                        RUN addNode IN hGenXml (getStack(), "infPercurso", "", OUTPUT iId).
                        addStack(iId).
                            {adapters/xml/ep2/axsep017nodechar.i "UFPer" ttinfPercurso.UFPer "YES"}
                        delStack().
                    END.
    
                delStack().
    
                RUN addNode IN hGenXml (getStack(), "emit", "", OUTPUT iId).
                addStack(iId).
    
                IF  ttMDFe.CPF <> "" THEN DO:
                    {adapters/xml/ep2/axsep017nodechar.i "CPF"  ttMDFe.CPF  "YES"}
                END.
                ELSE DO:
                    {adapters/xml/ep2/axsep017nodechar.i "CNPJ" ttMDFe.CNPJ "YES"}
                END.
    
                {adapters/xml/ep2/axsep017nodechar.i "IE"    ttMDFe.IE     "YES"}
                {adapters/xml/ep2/axsep017nodechar.i "xNome" ttMDFe.xNome  "YES"}
                {adapters/xml/ep2/axsep017nodechar.i "xFant" ttMDFe.xFant  "NO" }
    
                    RUN addNode IN hGenXml (getStack(), "enderEmit", "", OUTPUT iId).
                    addStack(iId).
    
                        {adapters/xml/ep2/axsep017nodechar.i  "xLgr"    ttMDFe.xLgr    "YES"}
                        {adapters/xml/ep2/axsep017nodechar.i  "nro"     ttMDFe.nro     "YES"}
                        {adapters/xml/ep2/axsep017nodechar.i  "xCpl"    ttMDFe.xCpl    "NO" }
                        {adapters/xml/ep2/axsep017nodechar.i  "xBairro" ttMDFe.xBairro "YES"}
                        {adapters/xml/ep2/axsep017nodechar.i  "cMun"    ttMDFe.cMun    "YES"}
    
                        IF ttMDFe.xMun = "Exterior" THEN DO:
                            {adapters/xml/ep2/axsep017nodechar2.i "xMun"    ttMDFe.xMun    "YES"}
                        END.
                        ELSE DO:
                            {adapters/xml/ep2/axsep017nodechar.i  "xMun"    ttMDFe.xMun    "YES"}
                        END.
    
                        {adapters/xml/ep2/axsep017nodechar.i  "CEP"     ttMDFe.CEP     "NO" }
                        {adapters/xml/ep2/axsep017nodechar.i  "UF"      ttMDFe.UF      "YES"}
                        {adapters/xml/ep2/axsep017nodechar.i  "fone"    ttMDFe.fone    "NO" }
                    delStack().
                delStack().
    
                RUN addNode IN hGenXml (getStack(), "infModal", "", OUTPUT iId).
                addStack(iId).
    
                    RUN setAttribute IN hGenXml (INPUT iId, "versaoModal", PcVersLayout).
    
                    CASE ttMdfe.modal:
                        WHEN "1" THEN DO:
                            RUN addNode IN hGenXml (getStack(), "rodo", "", OUTPUT iId).
                            addStack(iId).
                            
                            IF (INT(ttMDFe.RNTRC) <> 0 AND (ttMDFe.cgcProp = "" OR ttMDFe.cgcProp = ?)) /* RNTRC */
                                OR CAN-FIND(FIRST ttciot OF ttMDFe)                                         /* infCIOT */
                                OR CAN-FIND(FIRST ttdisp OF ttMDFe)                                         /* valePed */ 
                                OR CAN-FIND(FIRST ttinf_contratante OF ttMDFe)                              /* infContratante */
                                OR CAN-FIND(FIRST ttinfPag OF ttMDFe)                                       /* infPag */
                                THEN DO:
                                
                                    RUN addNode IN hGenXml (getStack(), "infANTT", "", OUTPUT iId).
                                    addStack(iId).
                                        IF INT(ttMDFe.RNTRC) <> 0 AND (ttMDFe.cgcProp = "" OR ttMDFe.cgcProp = ?) THEN DO:
                                            {adapters/xml/ep2/axsep017nodechar.i  "RNTRC" ttMDFe.RNTRC "YES"}
                                        END.
        
                                        FOR EACH ttciot OF ttMDFe:
                                            RUN addNode IN hGenXml (getStack(), "infCIOT", "", OUTPUT iId).
                                            addStack(iId).
                                                {adapters/xml/ep2/axsep017nodechar.i "CIOT" ttciot.CIOT "YES"}
                                                IF LENGTH(TRIM(ttciot.cgcCIOT)) > 11 THEN DO:
                                                    {adapters/xml/ep2/axsep017nodechar.i  "CNPJ"  ttciot.cgcCIOT "YES"}
                                                END.
                                                ELSE DO:
                                                    {adapters/xml/ep2/axsep017nodechar.i  "CPF"   ttciot.cgcCIOT "YES"}
                                                END.
                                            delStack().
                                        END.
        
                                        IF CAN-FIND(FIRST ttdisp OF ttMdfe) THEN DO:
                                            RUN addNode IN hGenXml (getStack(), "valePed", "", OUTPUT iId).
                                            addStack(iId).
                                                FOR EACH ttdisp OF ttMDFe:
                                                    RUN addNode IN hGenXml (getStack(), "disp", "", OUTPUT iId).
                                                    addStack(iId).
                                                        {adapters/xml/ep2/axsep017nodechar.i  "CNPJForn"  ttdisp.CNPJForn  "YES"}
                                                        {adapters/xml/ep2/axsep017nodechar.i  "CNPJPg"    ttdisp.CNPJPg    "YES"}
                                                        {adapters/xml/ep2/axsep017nodechar.i  "nCompra"   ttdisp.nCompra   "YES"}
                                                        {adapters/xml/ep2/axsep017nodedec.i   "vValePed"  ttdisp.vValePed  "YES"  "2"  "YES"}
                                                        {adapters/xml/ep2/axsep017nodechar.i  "tpValePed" Ttdisp.tpValePed "NO"}        
                                                    delStack().
                                                END.
                                                {adapters/xml/ep2/axsep017nodechar.i  "categCombVeic" ttMdfe.categCombVeic "NO"} 
                                            delStack().
                                        END.
                                        FOR EACH ttinf_contratante OF ttMDFe:
                                            RUN addNode IN hGenXml (getStack(), "infContratante", "", OUTPUT iId).
                                            addStack(iId).
    
                                                IF  TRIM(ttinf_contratante.nomeContratante) <> "":U
                                                AND TRIM(ttinf_contratante.nomeContratante) <> ? THEN DO:
                                                    {adapters/xml/ep2/axsep017nodechar.i "xNome" ttinf_contratante.nomeContratante  "YES"}
                                                END.
    
                                                IF LENGTH(TRIM(ttinf_contratante.cgcContratante)) = 14 THEN DO:
                                                    {adapters/xml/ep2/axsep017nodechar.i  "CNPJ"  ttinf_contratante.cgcContratante "YES"}
                                                END.
                                                ELSE DO:
                                                    IF LENGTH(TRIM(ttinf_contratante.cgcContratante)) = 11 THEN DO:
                                                        {adapters/xml/ep2/axsep017nodechar.i  "CPF"   ttinf_contratante.cgcContratante "YES"}
                                                    END.
                                                    ELSE DO:
                                                        {adapters/xml/ep2/axsep017nodechar.i  "idEstrangeiro"   ttinf_contratante.cgcContratante "YES"}
                                                    END.
                                                END.
                                            delStack().
                                        END.
    				    
                                        FOR EACH ttinfPag OF ttMDFe:
                                            RUN addNode IN hGenXml (getStack(), "infPag", "", OUTPUT iId).
                                            addStack(iId).                                      
                                                {adapters/xml/ep2/axsep017nodechar.i  "xNome" ttinfPag.xNome "NO"}
                                                {adapters/xml/ep2/axsep017nodechar.i  "CPF" ttinfPag.CPF "NO"}
                                                {adapters/xml/ep2/axsep017nodechar.i  "CNPJ" ttinfPag.CNPJ "NO"}
                                                {adapters/xml/ep2/axsep017nodechar.i  "idEstrangeiro" ttinfPag.idEstrangeiro  "NO"}
                                                
                                                FOR EACH ttComp OF ttMDFe
                                                   WHERE ttComp.id = ttinfPag.id:
                                                    RUN addNode IN hGenXml (getStack(), "Comp", "", OUTPUT iId).
                                                    addStack(iId). 
                                                        {adapters/xml/ep2/axsep017nodechar.i  "tpComp" ttComp.tpComp  "YES"}
                                                        {adapters/xml/ep2/axsep017nodedec.i   "vComp" ttComp.vComp "YES" 2 "YES"}
                                                        {adapters/xml/ep2/axsep017nodechar.i  "xComp" ttComp.xComp  "NO"}                                                    
                                                    delStack().                                                 
                                                END.
                                                
                                                {adapters/xml/ep2/axsep017nodedec.i  "vContrato" ttinfPag.vContrato  "YES" 2 "YES"}
    
                                                If Ttinfpag.IndAltoDesemp = "1" then  /*so enviar se = 1 conforme NT*/
                                                    {adapters/xml/ep2/axsep017nodechar.i  "indAltoDesemp" Ttinfpag.IndAltoDesemp "NO"}
    
                                                {adapters/xml/ep2/axsep017nodechar.i  "indPag" ttinfPag.indPag  "YES"}                                            
                                               
                                                IF ttinfPag.indPag = "1" AND l-NTMDFE2021002 THEN
                                                    {adapters/xml/ep2/axsep017nodedec.i "vAdiant" ttinfPag.vAdiant "NO" 2 "NO"}
                                                
                                                FOR EACH ttinfPrazo OF ttMDFe
                                                   WHERE ttinfPrazo.id = ttinfPag.id:
                                                    RUN addNode IN hGenXml (getStack(), "infPrazo", "", OUTPUT iId).
                                                    addStack(iId).                                                 
                                                        {adapters/xml/ep2/axsep017nodechar.i "nParcela" ttinfPrazo.nParcela "NO"}
                                                        {adapters/xml/ep2/axsep017nodechar.i "dVenc" ttinfPrazo.dVenc "NO"}
                                                        {adapters/xml/ep2/axsep017nodedec.i "vParcela" ttinfPrazo.vParcela "YES" 2 "YES"}                                                    
                                                    delStack().
                                                END.                                             
                                               
                                                RUN addNode IN hGenXml (getStack(), "infBanc", "", OUTPUT iId).
                                                addStack(iId).
                                                    IF  ttinfPag.codBanco <> ? AND ttinfPag.codBanco <> "" 
                                                    AND ttinfPag.codAgencia <> ? AND ttinfPag.codAgencia <> "" THEN DO: 
                                                        {adapters/xml/ep2/axsep017nodechar.i  "codBanco" ttinfPag.codBanco "NO"}
                                                        {adapters/xml/ep2/axsep017nodechar.i  "codAgencia" ttinfPag.codAgencia "NO"}                                                    
                                                    END.
                                                    ELSE DO:
                                                       IF ttinfpag.CNPJIPEF <> "" AND ttinfpag.CNPJIPEF <> ? THEN DO:
                                                         {adapters/xml/ep2/axsep017nodechar.i  "CNPJIPEF" ttinfPag.CNPJIPEF "NO"}                                                   
                                                       END.
                                                       ELSE DO:
                                                          IF ttinfPag.PIX <> "" AND ttinfPag.PIX <> ?  THEN
                                                            {adapters/xml/ep2/axsep017nodechar.i  "PIX" ttinfPag.PIX "NO"}     
                                                       END.
                                                 
                                                    END.
                                                delStack().
                                                
                                            delStack().
                                        END.
    				    
                                    delStack().
                                END.
    
                                RUN addNode IN hGenXml (getStack(), "veicTracao", "", OUTPUT iId).
                                addStack(iId).
    
                                    {adapters/xml/ep2/axsep017nodechar.i  "cInt"    ttMDFe.cInt    "NO"}
                                    {adapters/xml/ep2/axsep017nodechar.i  "placa"   ttMDFe.placa   "YES"}
                                    {adapters/xml/ep2/axsep017nodechar.i  "RENAVAM" ttMDFe.renavam "NO"}
                                    {adapters/xml/ep2/axsep017nodechar.i  "tara"    ttMDFe.tara    "YES"}
                                    {adapters/xml/ep2/axsep017nodechar.i  "capKG"   ttMDFe.capKG   "NO"}
                                    {adapters/xml/ep2/axsep017nodechar.i  "capM3"   ttMDFe.capM3   "NO"}
                                    
                                    /*Valida s½ o cpf/cnpj pq se for informado, todos os outros campos precisam ser informados*/
                                    IF ttMDFe.cgcProp <> "" AND ttMDFe.cgcProp <> ? THEN DO:  
                                        RUN addNode IN hGenXml (getStack(), "prop", "", OUTPUT iId).
                                        addStack(iId).
                                            /*Novas TAGS*/
                                            IF LENGTH(TRIM(ttMDFe.cgcProp)) = 11 THEN DO:
                                                {adapters/xml/ep2/axsep017nodechar.i  "CPF"  ttMDFe.cgcProp "YES"}
                                            END.
                                            ELSE DO:
                                                {adapters/xml/ep2/axsep017nodechar.i  "CNPJ" ttMDFe.cgcProp "YES"}
                                            END.
                                            
                                            {adapters/xml/ep2/axsep017nodechar.i  "RNTRC"  ttMDFe.RNTRC    "YES"}
                                            {adapters/xml/ep2/axsep017nodechar.i  "xNome"  ttMDFe.nomeProp "YES"}
                                            {adapters/xml/ep2/axsep017nodechar.i  "IE"     ttMDFe.ieProp   "YES"}
                                            {adapters/xml/ep2/axsep017nodechar.i  "UF"     ttMDFe.ufProp   "NO"}
                                            {adapters/xml/ep2/axsep017nodechar.i  "tpProp" ttMDFe.tpProp   "YES"}
                                             
                                        delStack().
                                    END.
                                    
                                    FOR EACH ttcondutor OF ttMDFe:
                                        RUN addNode IN hGenXml (getStack(), "condutor", "", OUTPUT iId).
                                        addStack(iId).
                                    
                                            {adapters/xml/ep2/axsep017nodechar.i  "xNome" ttcondutor.xNome "YES"}
                                            {adapters/xml/ep2/axsep017nodechar.i  "CPF"   ttcondutor.CPF   "YES"}
                                    
                                        delStack().
                                    END.
    
                                    {adapters/xml/ep2/axsep017nodechar.i  "tpRod"   ttMDFe.tpRod         "YES"}
                                    {adapters/xml/ep2/axsep017nodechar.i  "tpCar"   ttMDFe.tpCar         "YES"}
                                    {adapters/xml/ep2/axsep017nodechar.i  "UF"      ttMDFe.ufVeicLicenc  "NO"}
                                    
                                delStack().
    
                                FOR EACH ttveicReboque OF ttMDFe:
                                    RUN addNode IN hGenXml (getStack(), "veicReboque", "", OUTPUT iId).
                                    addStack(iId).
                                    
                                        {adapters/xml/ep2/axsep017nodechar.i  "cInt"    ttveicReboque.cInt    "NO"}
                                        {adapters/xml/ep2/axsep017nodechar.i  "placa"   ttveicReboque.placa   "YES"}
                                        {adapters/xml/ep2/axsep017nodechar.i  "RENAVAM" ttveicReboque.renavam "NO"}
                                        {adapters/xml/ep2/axsep017nodechar.i  "tara"    ttveicReboque.tara    "YES"}
                                        {adapters/xml/ep2/axsep017nodechar.i  "capKG"   ttveicReboque.capKG   "NO"}
                                        {adapters/xml/ep2/axsep017nodechar.i  "capM3"   ttveicReboque.capM3   "NO"}
                                        
                                        /*Valida s½ o cpf/cnpj pq se for informado, todos os outros campos precisam ser informados*/
                                        IF ttveicReboque.cgcProp <> "" AND ttveicReboque.cgcProp <> ? THEN DO:
                                            RUN addNode IN hGenXml (getStack(), "prop", "", OUTPUT iId).
                                            addStack(iId).
                                                IF LENGTH(TRIM(ttveicReboque.cgcProp)) = 11 THEN DO:
                                                    {adapters/xml/ep2/axsep017nodechar.i  "CPF" ttveicReboque.cgcProp  "YES"}
                                                END.
                                                ELSE DO:
                                                    {adapters/xml/ep2/axsep017nodechar.i  "CNPJ" ttveicReboque.cgcProp "YES"}
                                                END.
                                                
                                                {adapters/xml/ep2/axsep017nodechar.i  "RNTRC"  ttveicReboque.RNTRC     "YES"}
                                                
                                                {adapters/xml/ep2/axsep017nodechar.i  "xNome"  ttveicReboque.nomeProp  "YES"}
                                                {adapters/xml/ep2/axsep017nodechar.i  "IE"     ttveicReboque.ieProp    "YES"}
                                                {adapters/xml/ep2/axsep017nodechar.i  "UF"     ttveicReboque.ufProp    "YES"}
                                                {adapters/xml/ep2/axsep017nodechar.i  "tpProp" ttveicReboque.tpProp    "YES"}
                                            delStack().
                                        END.
                                        
                                        {adapters/xml/ep2/axsep017nodechar.i  "tpCar"   ttveicReboque.tpCar "YES"}
                                        {adapters/xml/ep2/axsep017nodechar.i  "UF"      ttveicReboque.ufVeicLicenc "YES"}
                                    
                                    delStack().
                                END.
    
                                
                            delStack(). /*fim rodo*/
                        END.
                        WHEN "4" THEN DO:
    
                            RUN addNode IN hGenXml (getStack(), "ferrov", "", OUTPUT iId).
                            addStack(iId).
    
                                RUN addNode IN hGenXml (getStack(), "trem", "", OUTPUT iId).
                                addStack(iId).
                                    {adapters/xml/ep2/axsep017nodechar.i   "xPref"   ttMDFe.xPref    "YES"}
                                    {adapters/xml/ep2/axsep017nodechar.i   "dhTrem"  ttMDFe.dhTrem   "NO"}
                                    {adapters/xml/ep2/axsep017nodechar.i   "xOri"    ttMDFe.xOri     "YES"}
                                    {adapters/xml/ep2/axsep017nodechar.i   "xDest"   ttMDFe.xDest    "YES"}
                                    {adapters/xml/ep2/axsep017nodechar.i   "qVag"    ttMDFe.qVag     "YES"}
                                delStack().
                                
                                FOR EACH ttvag OF ttMDFe:
                                     RUN addNode IN hGenXml (getStack(), "vag", "", OUTPUT iId).
                                    addStack(iId).
                                    
                                        {adapters/xml/ep2/axsep017nodechar.i   "serie"  ttvag.serie    "YES"}
                                        {adapters/xml/ep2/axsep017nodechar.i   "nVag"   ttvag.nVag     "YES"}
                                        {adapters/xml/ep2/axsep017nodechar.i   "nSeq"   ttvag.nSeq     "NO"}
                                        {adapters/xml/ep2/axsep017nodedec.i    "TU"     ttvag.TU       "YES"  "3"  "NO"}
                                    
                                    delStack().
                                
                                END.
                            delStack(). /*fim ferrov*/
                        END.
                        WHEN "2" THEN DO:
    
                            RUN addNode IN hGenXml (getStack(), "aereo", "", OUTPUT iId).
                            addStack(iId).
                                {adapters/xml/ep2/axsep017nodechar.i   "nac"      ttMDFe.nac         "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "matr"     ttMDFe.matr        "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "nVoo"     ttMDFe.nVoo        "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "cAerEmb"  ttMDFe.cAerEmb     "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "cAerDes"  ttMDFe.cAerDes     "YES"}
                                {adapters/xml/ep2/axsep017nodedate.i   "dVoo"     ttMDFe.dVoo        "YES"}
                            delStack(). /*fim aereo*/
                        END.
                        WHEN "3" THEN DO:
    
                            RUN addNode IN hGenXml (getStack(), "aquav", "", OUTPUT iId).
                            addStack(iId).
    
                                {adapters/xml/ep2/axsep017nodechar.i   "CNPJAgeNav"  ttMDFe.CNPJAgeNav  "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "tpEmb"       ttMDFe.tpEmb       "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "cEmbar"      ttMDFe.cEmbar      "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "xEmbar"      ttMDFe.xEmbar      "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "nViag"       ttMDFe.nViag       "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "cPrtEmb"     ttMDFe.cPrtEmb     "YES"}
                                {adapters/xml/ep2/axsep017nodechar.i   "cPrtDest"    ttMDFe.cPrtDest    "YES"}
                                FOR EACH ttinfTermCarreg OF ttMDFe:
                                    RUN addNode IN hGenXml (getStack(), "infTermCarreg", "", OUTPUT iId).
                                    addStack(iId).
                                        {adapters/xml/ep2/axsep017nodechar.i   "cTermCarreg"  ttinfTermCarreg.cTermCarreg   "YES"}
                                        {adapters/xml/ep2/axsep017nodechar.i   "xTermCarreg"  ttinfTermCarreg.cTermCarreg   "YES"}
                                    delStack().
                                END.
                                FOR EACH ttinfTermDescarreg OF ttMDFe:
                                    RUN addNode IN hGenXml (getStack(), "infTermDescarreg", "", OUTPUT iId).
                                    addStack(iId).
                                        {adapters/xml/ep2/axsep017nodechar.i   "cTermDescarreg"  ttinfTermDescarreg.cTermDescarreg   "YES"}
                                        {adapters/xml/ep2/axsep017nodechar.i   "xTermDescarreg"  ttinfTermDescarreg.cTermDescarreg   "YES"}
                                    delStack().
                                END.
                                FOR EACH ttinfEmbComb OF ttMDFe:
                                    RUN addNode IN hGenXml (getStack(), "infEmbComb", "", OUTPUT iId).
                                    addStack(iId).
                                        {adapters/xml/ep2/axsep017nodechar.i   "cEmbComb"   ttinfEmbComb.cEmbComb   "YES"}
                                    delStack().
                                END.
                            delStack(). /*fim aquav*/
                        END.
                    END CASE.
                delStack().
    
                RUN addNode IN hGenXml (getStack(), "infDoc", "", OUTPUT iId).
                addStack(iId).
    
                    FOR EACH ttinfMunDescarga OF ttMDFe:
                        RUN addNode IN hGenXml (getStack(), "infMunDescarga", "", OUTPUT iId).
                        addStack(iId).
                            RUN addNode IN hGenXml (getStack(), "cMunDescarga", ttinfMunDescarga.cMunDescarga, OUTPUT iId).
                            IF ttinfMunDescarga.xMunDescarga = "Exterior" THEN DO:
                                {adapters/xml/ep2/axsep017nodechar2.i "xMunDescarga"    ttinfMunDescarga.xMunDescarga    "YES"}
                            END.
                            ELSE DO:
                                {adapters/xml/ep2/axsep017nodechar.i  "xMunDescarga"    ttinfMunDescarga.xMunDescarga    "YES"}
                            END.
    
                            /*CT-e*/
                            FOR EACH ttinfCTe OF ttinfMunDescarga:
                                RUN addNode IN hGenXml (getStack(), "infCTe", "", OUTPUT iId).
                                addStack(iId).
                                    {adapters/xml/ep2/axsep017nodechar2.i "chCTe"        ttinfCTe.chCTe        "YES"}
                                delStack().
                            END.
                        
                        delStack().
                    END.
                delStack().
    
                /* seg */
                FOR EACH ttseg OF ttMDFe:
                    IF ttseg.respSeg <> "" AND ttseg.cgcSeguro <> "" THEN DO:
                        RUN addNode IN hGenXml (getStack(), "seg", "", OUTPUT iId).
                        addStack(iId).
                            
                            RUN addNode IN hGenXml (getStack(), "infResp", "", OUTPUT iId).
                            addStack(iId).
                                {adapters/xml/ep2/axsep017nodechar.i "respSeg" ttseg.respSeg "YES"}
                                IF LENGTH(TRIM(ttseg.cgcSeguro)) > 11 THEN DO:
                                    {adapters/xml/ep2/axsep017nodechar.i "CNPJ" ttseg.cgcSeguro "YES"}
                                END.
                                ELSE DO:
                                    {adapters/xml/ep2/axsep017nodechar.i "CPF"  ttseg.cgcSeguro "YES"}
                                END.
                            delStack().
                            
                            IF TRIM(ttseg.xSeg) <> "" AND TRIM(ttseg.CNPJSeguradora) <> "" THEN DO:
                                RUN addNode IN hGenXml (getStack(), "infSeg", "", OUTPUT iId).
                                addStack(iId).
                                    {adapters/xml/ep2/axsep017nodechar.i     "xSeg"  ttseg.xSeg           "YES"}
                                    {adapters/xml/ep2/axsep017nodechar.i     "CNPJ"  ttseg.CNPJSeguradora "YES"}
                                delStack().
                            END.
        
                            {adapters/xml/ep2/axsep017nodechar.i     "nApol" ttseg.nApol          "NO"}
                            FOR EACH ttseg_averb OF ttseg:
                                {adapters/xml/ep2/axsep017nodechar.i "nAver" ttseg_averb.nAver    "NO"}
                            END.
        
                        delStack().
                    END.
                END.
                
                /*tot*/
                RUN addNode IN hGenXml (getStack(), "tot", "", OUTPUT iId).
                addStack(iId).
                    IF int(ttMDFe.qCTe) > 0 THEN {adapters/xml/ep2/axsep017nodechar.i  "qCTe"  ttMDFe.qCTe  "NO"}
                    IF int(ttMDFe.qNFe) > 0 THEN {adapters/xml/ep2/axsep017nodechar.i  "qNFe"  ttMDFe.qNFe  "NO"}
                    
                    {adapters/xml/ep2/axsep017nodedec.i   "vCarga"  ttMDFe.vCarga "YES" 2 "YES"}
                    {adapters/xml/ep2/axsep017nodechar.i  "cUnid"   ttMDFe.cUnid  "YES"}
                    {adapters/xml/ep2/axsep017nodedec.i   "qCarga"  ttMDFe.qCarga "YES" 4 "YES"}
                delStack().
    
            delStack().
    
        delStack().
    delStack().

END.

RUN generateXML IN hGenXml (OUTPUT hXMLMDFe).

/* retirar o inicio do XML "<?xml version="1.0" encoding="utf-8" ?>" */
/* para nao gerar erro na integra»’o com o TSS                       */
hXMLMDFe:SAVE("LONGCHAR",lcXMLMDFe).*/


RUN adapters/xml/ep2/axsep031imprimexml.p (INPUT hGenXml,
										   INPUT mdfe-param.cod-vers-mdfe,
										   INPUT-OUTPUT TABLE ttStack,
										   INPUT TABLE ttcondutor,
										   INPUT TABLE ttdisp,
										   INPUT TABLE ttinfCTe,
										   INPUT TABLE ttinfEmbComb,
										   INPUT TABLE ttinfMunCarrega,
										   INPUT TABLE ttinfMunDescarga,
										   INPUT TABLE ttinfNFe,
										   INPUT TABLE ttinfMDFeTransp,
										   INPUT TABLE ttinfPercurso,
										   INPUT TABLE ttinfTermCarreg,
										   INPUT TABLE ttinfTermDescarreg,
										   INPUT TABLE ttinfUnidCarga_CTe,
										   INPUT TABLE ttinfUnidCarga_NFe,
										   INPUT TABLE ttinfUnidCarga_MDFe,
										   INPUT TABLE ttinfUnidTransp_CTe,
										   INPUT TABLE ttinfUnidTransp_NFe,
										   INPUT TABLE ttinfUnidTransp_MDFe,
										   INPUT TABLE ttlacres,
										   INPUT TABLE ttlacUnidCarga_CTe,
										   INPUT TABLE ttlacUnidCarga_NFe,
										   INPUT TABLE ttlacUnidCarga_MDFe,
										   INPUT TABLE ttlacUnidTransp_CTe,
										   INPUT TABLE ttlacUnidTransp_NFe,
										   INPUT TABLE ttlacUnidTransp_MDFe,
										   INPUT TABLE ttMDFe,
										   INPUT TABLE ttvag,
										   INPUT TABLE ttveicReboque,
										   INPUT TABLE ttCGCAutoriza,
										   INPUT TABLE ttperi_CTe,
										   INPUT TABLE ttperi_NFe,
										   INPUT TABLE ttperi_MDFeTransp,
										   INPUT TABLE ttseg,
										   INPUT TABLE ttseg_averb,
										   INPUT TABLE ttinf_contratante,
										   INPUT TABLE ttciot,
										   INPUT TABLE ttInfPag,
										   INPUT TABLE ttComp,
										   INPUT TABLE ttInfPrazo).

RUN generateXML IN hGenXml (OUTPUT hXMLMDFe).

/* retirar o inicio do XML "<?xml version="1.0" encoding="utf-8" ?>" */
/* para nao gerar erro na integra‡Æo com o TSS                       */
hXMLMDFe:SAVE("LONGCHAR",lcXMLMDFe).

//ASSIGN plcXMLMDFe = SUBSTR(lcXMLMDFe, INDEX(lcXMLMDFe, "<IntegracaoMDFe>")).

ASSIGN plcXMLMDFe = SUBSTR(lcXMLMDFe, INDEX(lcXMLMDFe, "<MDFe")).


ASSIGN plcXMLMDFe = replace( plcXMLMDFe, "<cMDF/><cDV/>", "").

ASSIGN plcXMLMDFe = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><RecepcionarMDFe xmlns="http://localhost/MDFePack.IntegracaoWebServices"><mdfe><![CDATA[<IntegracaoMDFe>'
                  + plcXMLMDFe
                  + '</IntegracaoMDFe>]]></mdfe></RecepcionarMDFe></soap:Body></soap:Envelope>'.


hXMLMDFe:LOAD("LONGCHAR",plcXMLMDFe,FALSE).
hXMLMDFe:SAVE("FILE","C:\temp\kleber\teste_envio.xml").

RETURN "OK".
