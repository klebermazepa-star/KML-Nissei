/*****************  Variÿveis Padr’o Datasul para todas as upc's ***************************** */
def input param p-ind-event  as char          no-undo.  /* Nome do evento em que est  passando */
def input param p-ind-object as char          no-undo.  /* Nome do objeto Ex: Container, viewer, etc... */
def input param p-wgh-object as handle        no-undo.  /* handle window, viewer, folder, ou browser */ 
def input param p-wgh-frame  as widget-handle no-undo.  /* handle da frame da viewer */
def input param p-cod-table  as char          no-undo.  /* Nome da tabela */
def input param p-row-table  as rowid         no-undo.  /* Rowid da tabela */

DEF NEW GLOBAL SHARED VAR wgh-nr-pedcli         AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-nome-abrev        AS WIDGET-HANDLE NO-UNDO.

DEF NEW GLOBAL SHARED VAR wgh-estab-central      AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-dt-inivig          AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-fi-crm             AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-lb-crm             AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-nat-operacao       AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-flag-cross         AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-cod-estabel         AS WIDGET-HANDLE NO-UNDO.

/*****  Vari veis que guardam os handle(s), conforme vai achando os objetos na tela ********* */
def var c-objeto as char no-undo.

assign c-objeto = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

IF c-Objeto = ? AND CAN-QUERY(p-wgh-object, 'Name') THEN
   ASSIGN c-Objeto = entry(num-entries(p-wgh-object:NAME, "~\"), p-wgh-object:NAME, "~\")
          c-Objeto = entry(num-entries(p-wgh-object:NAME, "~/"), p-wgh-object:NAME, "~/").

 /* MESSAGE "Evento......: " p-ind-event         SKIP
           "Objeto......: " p-ind-object        SKIP
           "Nome objeto.: " c-objeto            SKIP
           "Frame.......: " p-wgh-frame         SKIP
           "Tabela......: " p-cod-table         SKIP
           "Rowid.......: " string(p-row-table)
           VIEW-AS ALERT-BOX INFO BUTTONS OK. */


           
           
IF p-ind-event  = 'AFTER-INITIALIZE' AND p-ind-object = 'CONTAINER':U THEN DO:
    RUN utils/FindWidget.p (INPUT 'nome-abrev',
                            INPUT 'fill-in', 
                            INPUT  p-wgh-frame, 
                            OUTPUT wgh-nome-abrev).
        
    RUN utils/FindWidget.p (INPUT 'nr-pedcli',
                            INPUT 'fill-in', 
                            INPUT  p-wgh-frame, 
                            OUTPUT wgh-nr-pedcli).

    RUN utils/FindWidget.p (INPUT 'estab-central',
                            INPUT 'fill-in', 
                            INPUT  p-wgh-frame, 
                            OUTPUT wgh-estab-central).
       
    RUN utils/FindWidget.p (INPUT 'dt-inivig',
                            INPUT 'fill-in', 
                            INPUT  p-wgh-frame, 
                            OUTPUT wgh-dt-inivig).
                            
    RUN utils/FindWidget.p (INPUT 'nat-operacao',
                            INPUT 'fill-in', 
                            INPUT  p-wgh-frame, 
                            OUTPUT wgh-nat-operacao).
                            
    RUN utils/FindWidget.p (INPUT 'cod-estabel',
                            INPUT 'fill-in', 
                            INPUT  p-wgh-frame, 
                            OUTPUT wgh-cod-estabel).                        
                            
    
    IF VALID-HANDLE(wgh-nat-operacao) THEN DO:             
                
         CREATE toggle-box wgh-flag-cross
         ASSIGN NAME      = "wgh-flag-cross"
                FRAME     = wgh-nat-operacao:FRAME
                ROW       = wgh-nat-operacao:ROW 
                COL       = wgh-nat-operacao:COL + 35
                VISIBLE   = YES
                SENSITIVE = no
                LABEL     = "Modal. Cross". 
                
    END.

    IF VALID-HANDLE(wgh-estab-central) THEN DO:
        CREATE TEXT wgh-lb-crm
            ASSIGN
                FRAME        = wgh-estab-central:FRAME
                FORMAT       = "X(12)"
                WIDTH        = 10
                SCREEN-VALUE = "CRM:"
                ROW          = wgh-estab-central:ROW + 1
                COL          = wgh-estab-central:COL - 4
                FGCOLOR      = 1
                VISIBLE      = YES 
                .

        CREATE FILL-IN wgh-fi-crm
            ASSIGN
                FRAME             = wgh-estab-central:FRAME
                DATA-TYPE         = "CHARACTER"
                WIDTH             = 20
                HEIGHT            = wgh-estab-central:HEIGHT 
                ROW               = wgh-estab-central:ROW + 0.9
                COL               = wgh-estab-central:COL
                VISIBLE           = YES
                SENSITIVE         = NO
                FORMAT            = "x(12)"
                SIDE-LABEL-HANDLE = wgh-lb-crm
                NAME              = "fi-crm"
                .

    END.
END.

.MESSAGE p-ind-event
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

IF  p-ind-event = "pi-enable" THEN  DO:

    ASSIGN wgh-flag-cross:SENSITIVE    = YES.
    
    IF wgh-cod-estabel:SCREEN-VALUE = "10004" THEN
    DO:
        ASSIGN wgh-flag-cross:SENSITIVE    = YES.
    
        .MESSAGE wgh-nr-pedcli:SCREEN-VALUE
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        FIND FIRST esp-modalidade-cross 
            WHERE  esp-modalidade-cross.cod-ped-venda   =  wgh-nr-pedcli:SCREEN-VALUE NO-ERROR. 
        
        IF NOT AVAIL esp-modalidade-cross THEN
        DO:
            CREATE esp-modalidade-cross.
            ASSIGN esp-modalidade-cross.cod-ped-venda   = wgh-nr-pedcli:SCREEN-VALUE.  
            
        END.
        
    END.
    ELSE DO:
        ASSIGN //wgh-flag-cross:SENSITIVE    = NO
               wgh-flag-cross:CHECKED = NO.
    
    END.

END.


IF p-ind-event = "before-DISPLAY"  THEN
DO:

    IF VALID-HANDLE(wgh-flag-cross) THEN DO:
    
        IF wgh-cod-estabel:SCREEN-VALUE = "10004" THEN
        DO:
        
            FIND FIRST esp-modalidade-cross 
                WHERE  esp-modalidade-cross.cod-ped-venda   =  wgh-nr-pedcli:SCREEN-VALUE NO-ERROR. 
            
            IF NOT AVAIL esp-modalidade-cross THEN
            DO:
                CREATE esp-modalidade-cross.
                ASSIGN esp-modalidade-cross.cod-ped-venda   = wgh-nr-pedcli:SCREEN-VALUE.
                IF wgh-flag-cross:CHECKED = YES THEN
                DO:
                   
                    ASSIGN esp-modalidade-cross.flag-cross  = YES.
                    
                END.
                ELSE DO:
                
                    ASSIGN esp-modalidade-cross.flag-cross  = NO.
                
                END.
                
                
            END.
            ELSE DO:
                IF wgh-flag-cross:CHECKED = YES THEN
                DO:
                   
                    ASSIGN esp-modalidade-cross.flag-cross  = YES.
                    
                END.
                ELSE DO:
                
                    ASSIGN esp-modalidade-cross.flag-cross  = NO.
                
                END.
      
            END.
            
        END.
        ELSE DO:
   
    
            ASSIGN wgh-flag-cross:CHECKED = NO.
            
            .MESSAGE "Modalidade Cross s¢ se aplica no Estabelecimento 10004" 
                VIEW-AS ALERT-BOX ERROR BUTTONS OK.
        
        END.

    END.

END.    



IF p-ind-event = "AFTER-DISPLAY" THEN
DO:

    IF VALID-HANDLE(wgh-nat-operacao) THEN DO:
        ASSIGN wgh-flag-cross:SENSITIVE = NO.

        
        
        FIND FIRST esp-modalidade-cross NO-LOCK
             WHERE esp-modalidade-cross.cod-ped-venda = wgh-nr-pedcli:SCREEN-VALUE NO-ERROR.

        IF AVAIL esp-modalidade-cross THEN DO:
 
            ASSIGN wgh-flag-cross:CHECKED = esp-modalidade-cross.flag-cross.
        
        END.
        ELSE DO:
            
            ASSIGN wgh-flag-cross:CHECKED = NO.    
        END.
    
    
    END.
    
    
    
END.

IF p-ind-event  = "btSaveOrder"  THEN DO:

    IF wgh-cod-estabel:SCREEN-VALUE = "10004" THEN
    DO:
        FIND FIRST esp-modalidade-cross 
            WHERE  esp-modalidade-cross.cod-ped-venda   =  wgh-nr-pedcli:SCREEN-VALUE NO-ERROR. 
        
        IF NOT AVAIL esp-modalidade-cross THEN
        DO:
            CREATE esp-modalidade-cross.
            ASSIGN esp-modalidade-cross.cod-ped-venda   = wgh-nr-pedcli:SCREEN-VALUE.  
            
        END.
        

        IF wgh-flag-cross:CHECKED = YES THEN
        DO:
           
            
            ASSIGN esp-modalidade-cross.flag-cross  = YES.
            
        END.
        ELSE DO:
        
            ASSIGN esp-modalidade-cross.flag-cross  = NO.
        
        END.
        
    END.
    ELSE DO:
    
        IF wgh-flag-cross:CHECKED = YES THEN
        DO:
            ASSIGN wgh-flag-cross:CHECKED = NO.
        
            MESSAGE "Modalidade Cross s¢ se aplica no Estabelecimento 10004" 
                VIEW-AS ALERT-BOX ERROR BUTTONS OK.
            
        END.
    
    END.

END.

IF p-ind-event = "AFTER-DESTROY-INTERFACE":U THEN DO:
    IF VALID-HANDLE(wgh-nome-abrev) THEN DO:    
        //DELETE WIDGET wgh-nome-abrev.        
        ASSIGN wgh-nome-abrev = ?.
        
    END.

    IF VALID-HANDLE(wgh-nr-pedcli) THEN DO:   
        //DELETE WIDGET wgh-nr-pedcli.        
        ASSIGN wgh-nr-pedcli = ?.        
    END.
    
    IF VALID-HANDLE(wgh-fi-crm) THEN DO:    
        //DELETE WIDGET wgh-fi-crm.        
        ASSIGN wgh-fi-crm = ?.
        
    END.

    IF VALID-HANDLE(wgh-dt-inivig) THEN DO:
        ASSIGN wgh-dt-inivig = ?.   
    END.
    
    IF VALID-HANDLE(wgh-lb-crm) THEN DO:   
        //DELETE WIDGET wgh-lb-crm.        
        ASSIGN wgh-lb-crm = ?.        
    END.
END.

IF p-ind-event = 'After-Display' THEN DO:
    IF VALID-HANDLE(wgh-nr-pedcli) AND VALID-HANDLE(wgh-nr-pedcli) AND
       VALID-HANDLE(wgh-fi-crm) THEN DO:

       FIND FIRST ext-ped-venda NO-LOCK
           WHERE ext-ped-venda.nome-abrev = wgh-nome-abrev:SCREEN-VALUE
           AND   ext-ped-venda.nr-pedcli  = wgh-nr-pedcli:SCREEN-VALUE NO-ERROR.
       IF AVAILABLE ext-ped-venda THEN
           ASSIGN wgh-fi-crm:SCREEN-VALUE = ext-ped-venda.crm.
       ELSE
           ASSIGN wgh-fi-crm:SCREEN-VALUE = "".
    END.
END.

IF  p-ind-event = "pi-enable" AND VALID-HANDLE(wgh-dt-inivig) THEN  DO:
    ASSIGN wgh-fi-crm:SENSITIVE    = wgh-dt-inivig:SENSITIVE.
END.  

IF p-ind-event  = "btSaveOrder"  THEN DO:
    IF VALID-HANDLE(wgh-fi-crm) THEN
        ASSIGN wgh-fi-crm:SENSITIVE = NO.

    IF VALID-HANDLE(wgh-nome-abrev) AND VALID-HANDLE(wgh-nr-pedcli) THEN DO:
        FIND FIRST ped-venda NO-LOCK
            WHERE ped-venda.nome-abrev = wgh-nome-abrev:SCREEN-VALUE
            AND   ped-venda.nr-pedcli  = wgh-nr-pedcli:SCREEN-VALUE NO-ERROR.
        IF AVAILABLE ped-venda THEN DO:

            FIND FIRST ext-ped-venda EXCLUSIVE-LOCK
                WHERE ext-ped-venda.nr-pedido   = ped-venda.nr-pedido NO-ERROR.

            IF NOT AVAILABLE ext-ped-venda THEN DO:
                CREATE ext-ped-venda.
                ASSIGN
                    ext-ped-venda.nr-pedido   = ped-venda.nr-pedido
                    ext-ped-venda.nome-abrev  = ped-venda.nome-abrev
                    ext-ped-venda.nr-pedcli   = ped-venda.nr-pedcli
                    .
            END.

            FOR FIRST ems2mult.emitente FIELDS(cod-emitente) NO-LOCK
                WHERE emitente.nome-abrev = ped-venda.nome-abrev:
                
                ASSIGN
                    ext-ped-venda.cod-emitente = emitente.cod-emitente
                    .
            END.
            
            ASSIGN
                ext-ped-venda.crm = wgh-fi-crm:SCREEN-VALUE
                .
                
            RELEASE ext-ped-venda.
        END.
    END.       
END.
RETURN "OK".
