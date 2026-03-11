/*-------------------------------------------------------------------
File........: smtpmail.p
Version.....: 5.1a - 1/11/02
Description : Opens up an SMTP connection and sends an email message  
               to multiple recipients.
Input Param : 
     mailhub     char - settable SMTP server name/IP address
     EmailTo     CHAR - list of email addresses separated by 
                 semicolons or commas (All semicolons will 
                 be replaced by commas so don't include stuff
                 like Smith, John)
     EmailFrom   CHAR - email address of user originating the email, 
                 the SMTP server should require that this user 
                 is real. Format looks like:
                 <user>@<host>[;<descriptive name>]
                 Example:
                 foo@bar.com[;Mr. Foo Bar]
     EmailCC     CHAR - list of email addresses separated by 
                 semicolons or commas (All semicolons will 
                 be replaced by commas so don't include stuff
                 like Smith, John)
     Attachments CHAR - Comma separated list of attachment descriptions 
                 Format looks like: 
       file[:type=<mimetype>][:charset=<charset>][:filetype=<filetype>]
     LocalFiles  CHAR - comma separated list of filenames to the files 
                 described in Attachments.  The filenames in this  
                 parameter must either be in the Progress path or 
                 have the entire path specified.  In contrast to 
                 filenames in the Attachments are the filenames to 
                 show for the Attachments.
     Subject     CHAR - Subject line
     Body        CHAR - Actual text of the message can be whatever you  
                 want as long as you include the correct Header 
                 information in the MIMEHeader. 
                 If you are just sending plaintext you can leave 
                 the MIMEHeader blank, this is default setting 
                 If you wanted to send HTML you might use: 
                 type=text/html:charset=us-ascii:filetype=ascii
     MIMEHeader  CHAR - [type=<mimetype>][:charset=<chrset>][:filetype=<type>]
     BodyType    char - File/text.  Determines whether a file or text 
                 goes into the message body.

Output Param: 
     oSuccessful  LOGICAL - Yes the message was succesfully generated
                  No there was some error that prevented message from
          being successful generated.
                  ? there may have been a problem with a recipient
                  or format of the email.
     vMessage    CHAR - Any error messages from the server

Author......: Paul C. Keary - plk@cpec.com - Coe Press Equipment Corp.
Contributors: 
                Scott Auge          - Amduus
                Mario Paranhos      - BravePoint, Inc. (770) 449-9696
                Sam Schroeder       - sschroeder@mn.rr.com 
                Geoff Crawford      - Innovative Client Servers
                Steven Lichtenberg  - Safemasters, Inc.
                Mark Bremmeyr       - I S Solutions, LTD.
                S.E. Southwell      - BravePoint, Inc. (770) 449-9696
                
Copyright...: FreeFramework 2001 - http://www.freeframework.org
Created.....: 6/26/01
Notes.......: 
            This program was adapted from a combination of the work of  
            Scott Auge and distributed as part of his mailsdk           
            Scott had laid the groundwork for sending an email with     
            attachments. But his original code did not verify the
        servers response to make sure the data was being sent
        properly.  
            Mario's original work smtpmail.p was a big help in
        developing an understanding of how SMTP works.  His
        program was very elegant in the way it deals with Sockets
        however Scott's work had done much more in the area of 
        including attachments.
            
            SMTP Protocols taken from RFC821
            MIME Protocols taken from RFC1521

Disclaimer..: This program is not fully tested especially with  
              regard to the Reading of the Server Responses, and
          encoding   of the MIME message body . Also the logging
          and server params are not completely developed.  
              
Modifications:
 Sam Schroeder - sschroeder@mn.rr.com                          
 Changed "~n" to CHR(13) + CHR(10) as RFC821 calls for         
 commands to end in <CRLF>, as carriage return and line feed.  
 NOTE: This is not fixed in the MIME section as I was not able
       to test this section.                                   
                                                               
                                                               
                                                               
 6/20/01 Geoff Crawford - for most robustness, it is           
         necessary to loop through the WRITE() on the          
         socket in case if the underlying transport            
         does the write in more than one step.  A              
         simple loop was added.                                
 6/28/01 Steven Lichtenberg - Added checks for server response 
         to ensure the conversation happens.  On initial       
         connection, there may be a significant lag before the 
         server responds. Looping through to recheck for       
         response was necessary                                
 7/3/01  Steven Lichtenberg - Modifications to more fully      
         incorporate Mario's original code andto make the      
         routine more modular.  Added robustness features to   
         ensure the complete/correct delivery of binary        
         attachments through the use of MEMPTR.  Also added    
         the ability to use either                             
         a file or passed text for the message body.  This     
         allows for the options of sending a file as an        
         attachment or as the message body.  Reworked to use   
         event driven principles for cleaner code and easier   
         maintenance.                                          
 7/9/01  Paul Keary - Replaced CHR(13) + CHR(10) with crlf     
         Decreased indentation of some of code to 2 spaces for 
         better readability on character screens.              
         Added code to set Encodedirectory based on OPSYS      
         Capitalized most of the Progress Keywords(anal,I know)
         Found a line with a single period just after the line 
         where cBoundary = "MAIL_BOUNDARY", it appears to have 
         been introduced when the ~n were orginally changed to 
         to CHR(13) + CHR(10).                                 
         Added alternative API that is activated by removing   
         preprocesser PublicVersion                            
         Found logic errors surrounding getsocket code and what
         happens if getsocket doesnot succeed.                 
 7/12/01 Found a problem with the filename used for binary file
         if the input file name is a full path.  On a Unix box 
         it tried to write a file like /tmp//u/htmldocs/...    
         Notice the 2 /'s after tmp.  Modified the code to use 
         a unique filename like en78422  instead of added a #  
         onto the end of the original local file               
         Also found attachbinlist was being delimited with a   
         '<' for binaryfiles instead of a ',' This appeared to 
         a typing error, I am surprised it wasn't noticed b4now
 7/12/01 Mario Paranhos - fixed some tiny bugs in the mime type
 8/30/01 Mark Bremmeyr - Found a problem when body is from a   
         file. Changed GetFile to process attachments and body 
         differently. Body text needed ~n before and after     
         the content of input file.                           
 9/19/01 Paul Keary - Fixed 2 reported problems 
         1. Sending a File as the Body of the message had a bug  
         where a blank line was not inserted before the body of
         the message.                                          
         2. Added a workaround for running in batch-mode based on
         Simon Prinsloo's suggestion of using a DO WHILE loop  
         Also added a secondary mechanism to leave the loop if 
         WriteData has not been called in the last 60 seconds  
         just in case the logical sending is not set to NO by  
         the Read-Handler.                                     
 9/20/01 Steve Southwell - Added the ability to have a descriptive 
         "from".  Reformatted header in FFW format.      
 10/3/01 Steve Southwell - Merged in some changes - did some cleanup
 1/11/02 Steve Southwell - Changed Error with newstate being set to 3 
         instead of 4.   Thanks to "Anonymous" for the fix.
 8/29/02 Leandro Johann - passa a chamar o procedimento b64encode.p
                          de utils/ ao inv²s de ffw/procs/
                        - no loop principal (que efetivamente faz o
                          envio), comentado o PAUSE 1, para agilizar
                          um pouco o envio (para mais detalhes, ver
                          comentÿrios no local da altera»’o)           
                        - tradu»’o das mensagens atribu­das a vMessage
                        - antes de tratar (verificar barras) a variÿvel 
                          EncodeDirectory, troca "\" por "/"
                        - quando o SO for <> de UNIX, grava o arquivo
                          de log no caminho apontado por EncodeDirectory
                          
 4/2/03 Marcio Fuckner  - Inclusao do parametro que identifica se o servidor
                          requer ou n’o autentica»’o.
                        - Tratamento da autentica»’o do tipo PLAIN (base64)
                          
---------------------------------------------------------------*/


/********** forward declare functions ***********/

FUNCTION newstate RETURNS INTEGER
  (INPUT newstate AS INTEGER,
   INPUT pstring AS CHARACTER,
   INPUT hSocket AS HANDLE) FORWARD.
FUNCTION getfile RETURNS MEMPTR(INPUT filnm AS CHAR) FORWARD.

/******************** Variable definitions **************/

/* 7/9/01 PK - to support 2 API's for calling this procedure */
/* Uncomment the following line to use the defactor API as set on the
   FreeFrameWork, alternate version uses mailhub defined within this 
   program and does not use BodyType or vMessage */
DEF INPUT PARAMETER mailhub         as char no-undo.
DEF INPUT PARAMETER mailPort        as integer no-undo.
DEF INPUT PARAMETER EmailTo         AS CHAR NO-UNDO.
DEF INPUT PARAMETER EmailFrom       AS CHAR NO-UNDO.
DEF INPUT PARAMETER EmailCC         AS CHAR NO-UNDO.
DEF INPUT PARAMETER Attachments     AS CHAR NO-UNDO.
DEF INPUT PARAMETER LocalFiles      AS CHAR NO-UNDO.
DEF INPUT PARAMETER Subject         AS CHAR NO-UNDO.
DEF INPUT PARAMETER Body            AS CHAR NO-UNDO.
DEF INPUT PARAMETER MIMEHeader      AS CHAR NO-UNDO.
DEF INPUT PARAMETER BodyType        as char no-undo.
DEF INPUT PARAMETER SmtpReqAuth     AS LOGICAL NO-UNDO.
DEF INPUT PARAMETER SmtpUser        AS CHAR NO-UNDO.
DEF INPUT PARAMETER SmtpPasswd      AS CHAR NO-UNDO.

DEF OUTPUT PARAMETER oSuccessful    AS LOGICAL NO-UNDO.
DEF OUTPUT PARAMETER vMessage       AS CHAR NO-UNDO.

/*****************************************************************
   Added by Paul Keary on 7/9/01 
   This code can be used to simplify calls to smtpmail.p 
   Note the version that appeared on FreeFramework.org had EmailTo as
   the first Parameter, This version has EmailFrom as First Parameter
   to coincide with the default format in Outlook, either way is fine 
   this is more to be capatible with older code 
 ****************************************************************/
/* End of Alternate API call definition */


/* Configure These Parameters per your specific needs */
DEF VAR loglevel                    AS INTEGER NO-UNDO.
DEF VAR LogFile                     AS CHARACTER NO-UNDO.
DEF VAR EncodeDirectory             AS CHAR NO-UNDO.
DEF VAR localTimezone               AS CHAR NO-UNDO.

DEF VAR cLocalFile                  AS CHARACTER NO-UNDO.
DEF VAR cBinaryFile                 AS CHARACTER NO-UNDO.

/* Used to communicate with SMTP Socket */
DEF VAR hSocket                     AS HANDLE NO-UNDO.

DEF VAR ServResponse                AS CHAR FORMAT "x(40)" NO-UNDO.
DEF VAR ServerCode                  AS INTEGER NO-UNDO.
DEF VAR vState                      AS INTEGER  NO-UNDO.
DEF VAR crlf                        AS CHAR NO-UNDO.


/* SWL 07/03/2001 counter for looping */
DEF VAR icnt                        AS INTEGER   NO-UNDO.
DEF VAR icnt1                       AS INTEGER   NO-UNDO.
DEF VAR filcnt                      AS INTEGER   NO-UNDO.
DEF VAR rcptcnt                     AS INTEGER   NO-UNDO.
DEF VAR rspcnt                      AS INTEGER   NO-UNDO.
DEF VAR AttachBinlist               AS CHARACTER NO-UNDO.
DEF VAR sending                AS LOGICAL NO-UNDO.
DEF VAR start-etime            AS INTEGER NO-UNDO.
/****************************************************************/
/* Only Log attachments if debug level = 1                      */
/*   modify log locations as required                           */
/****************************************************************/

/* Closest we come to a Constant Variable in Progress.
   DO NOT change the value of crlf */
crlf = CHR(13) + CHR(10).

loglevel = 1.  /* Minimal logging = 3 Verbose loggin = 1 */
/* 7/9/01 PK - Eliminate need to configure for most users */
&IF OPSYS = "UNIX" &THEN
EncodeDirectory = "/tmp/".
LogFile = "/tmp/socketemail.log".
&ELSE
EncodeDirectory = SESSION:TEMP-DIRECTORY.
LogFile = "socketemail.log". /* Write to default directory */
&ENDIF

/* 27/08/02 LJ Verifica se o caminho tem "\" ao inv²s de "/" */
IF INDEX(EncodeDirectory, "\") > 0 THEN
    ASSIGN EncodeDirectory = REPLACE(EncodeDirectory, "\", "/").

/* Make sure EncodeDirectory ends in a /  */
IF SUBSTRING(EncodeDirectory,LENGTH(EncodeDirectory),1) <> "/" THEN
  EncodeDirectory = EncodeDirectory + "/".

/* 29/08/02 LJ Se o SO n’o for UNIX, acrescenta o diret½rio temporÿrio ao nome do
   arquivo de log. Caso contrÿrio, o Progress tentarÿ gravar o log
   no diret½rio corrente, o que ocasiona problemas se o usuÿrio
   n’o tiver privil²gios de escrita no mesmo. */
&IF OPSYS <> "UNIX" &THEN
LogFile = EncodeDirectory + LogFile.
&ENDIF

/* Determine which timezone we are in so that the Mail will have the
   correct SENT Time
   Calling all programmers!!!
   IF Anyone has a better way to set the TimeZone on a Non-Unix 
   platform please submit the code to the freeframework. */
&IF OPSYS = "UNIX"
&THEN
  INPUT THROUGH date +%Z NO-ECHO.
  SET localTimezone.
  INPUT CLOSE.
&ELSE localTimezone = "EST".
&ENDIF

DEFINE STREAM sLogfile.
&GLOBAL-DEFINE Stream STREAM sLogFile
&GLOBAL-DEFINE LOGGER PUT {&Stream} UNFORMATTED TODAY " " STRING (TIME, "hh:mm:ss") " "

/* No Point in doing anything if EmailFrom and EmailTo Not Known */
IF EmailFrom = "" or
   EmailTo = "" THEN DO:
  vmessage = "'De' ou 'Para' em branco.".
  RETURN.
END. /* if emailfrom = "" or emailto = "" */

OUTPUT {&Stream} TO VALUE(LogFile) UNBUFFERED APPEND.

IF loglevel <= 2 THEN
  {&Logger} SKIP "************** ****** New Group ******* ************"
      SKIP
      "Socket email started" SKIP
          "Input Parameters" SKIP
          "SMTP Req Auth = " SmtpReqAuth SKIP
          "SMTP User = " SmtpUser SKIP
          "EmailFrom = " EmailFrom SKIP
          "EmailTo = " EmailTo SKIP
          "EmailCC = " EmailCC SKIP
          "Attachments = " Attachments SKIP
          "LocalFiles = " LocalFiles SKIP
          "Subject = " Subject SKIP
          "Body = " Body SKIP
          "MIMEHeader = " MIMEHeader SKIP.

ELSE {&Logger} "Send Mail From " EmailFrom " to " EmailTo SKIP.
/* process attachments and generate a comma separated list of
   file names for the output of base64encode.p . This is done prior
   to opening the socket to minimize the impact on resources
   (you do not need to have a socket open doing nothing for hours */
IF localfiles <> "" THEN DO filcnt =  1 TO NUM-ENTRIES(localfiles):
  IF loglevel <= 2 THEN
    {&logger} " processing Attachement " ENTRY(filcnt,localfiles) skip.

  RUN dofiles(INPUT ENTRY(filcnt,localfiles),
              INPUT ENTRY(filcnt,attachments),
              INPUT-OUTPUT attachbinlist) NO-ERROR.

  IF vMessage <> "" THEN DO:
    RUN cleanup.
    RETURN.
  END. /* if return value <> "" then */
END. /* do icnt = 1 to num-entries(attachments) */

/****************************************************************/
/* Create the socket, log in the log file that it was succes-   */
/* ful or not.                                                  */
/****************************************************************/
sending = YES.
IF loglevel <= 2 then {&logger} "opening socket" skip.
RUN getsocket(input loglevel,input mailhub,output hSocket).
IF vMessage <> "" THEN RETURN.

IF NOT THIS-PROCEDURE:PERSISTENT AND 
   NOT SESSION:BATCH-MODE THEN WAIT-FOR CLOSE OF THIS-PROCEDURE.
ELSE IF SESSION:BATCH-MODE THEN DO:
  /*********************************************************
    9/19/2001 by Paul Keary
    Progress will not wait-for input on a Socket while running in
    batch mode.  Simon Prinsloo [simonp@qbcon.com] proposed this
    simple code to workaround this problem. 
    ******************************************************/
  start-etime = ETIME.
  DO WHILE sending:
    PROCESS EVENTS.
    /* A pausa de 1 segundo abaixo foi retirada para deixar o
       envio um pouco mais rÿpido. O PROCESS EVENTS por si s½
       jÿ faz uma pausa, pois vai dispender recursos para
       executar outras tarefas pendentes. */

    PAUSE 1 NO-MESSAGE.

    /* Build in timer in case sending is never set to NO 
       this will terminate the program after 60 seconds
       start-Etime will be reset by WriteData each time there
       is activity on the socket to allow for long transmissions */
    IF start-etime + 60000 < ETIME THEN DO:
      sending = NO.
      RUN Cleanup.
    END.
  END.
END.

/****************************************************************/
/*  used a readhandler to avoid timing ut issues with running   */
/*  in a non-event driven mode.  Also more fully complies with  */
/*  Mario's original program design.                            */
/****************************************************************/
PROCEDURE readhandler:
  DEF VAR vlength     AS INTEGER   NO-UNDO.
  DEF VAR str         AS CHARACTER NO-UNDO.
  DEF VAR v                              AS INTEGER   NO-UNDO.
  DEF VAR idx                            AS INTEGER   NO-UNDO.
  DEF VAR mData                          AS MEMPTR    NO-UNDO.
  DEF VAR vbuffer                        AS MEMPTR    NO-UNDO.
  DEF VAR Base64String                   AS CHAR      NO-UNDO.
 
 /* Used to Build MIME Message Body */
  DEF VAR cTempValue                      AS CHARACTER NO-UNDO.
  DEF VAR cBoundary                       AS CHARACTER NO-UNDO.
  DEF VAR cMimeType                       AS CHARACTER NO-UNDO.
  DEF VAR cCharSet                        AS CHARACTER NO-UNDO.
  DEF VAR cFileType                       AS CHARACTER NO-UNDO.
  DEF VAR cFile                           AS CHARACTER NO-UNDO.
  DEF VAR cImportData                     AS CHARACTER NO-UNDO.
 
  DEF VAR smtpcmd                   AS CHAR FORMAT "x(90)" NO-UNDO.
  DEF VAR teststr                   AS CHARACTER NO-UNDO.

  DEF VAR cMonth                          AS CHARACTER NO-UNDO
         INIT "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec".

  IF NOT VALID-HANDLE(hSocket) THEN RETURN.

  vlength = hSocket:GET-BYTES-AVAILABLE().
  IF vlength > 0 THEN DO:
    SET-SIZE(vbuffer) = vlength + 1.
    hSocket:READ(vbuffer, 1, vlength, 1).
    str = GET-STRING(vbuffer,1).
    if loglevel <= 2 then 
      {&logger} "vstate " vstate skip "str " str skip.
    SET-SIZE(vbuffer) = 0.
    v = INTEGER(ENTRY(1, str," ")).

    CASE vState:
        /********************** Build message ***************/
      WHEN 1 THEN DO:
        if loglevel <= 2 then {&logger} vstate " " v " "  "HELO" skip.
        IF v = 220 THEN  /* send helo */
          vstate = newState(if SmtpReqAuth then 8 else 2, "HELO how are you?" + crlf,hsocket).
        ELSE vState = -1.
      END. /* when 1 */

        /********************** Authentication ***************/
      WHEN 8 THEN DO:
        if loglevel <= 2 then {&logger} vstate " " v " "  "AUTH" skip.
        IF v = 250 THEN DO:
           /* gera string de usuario e senha no formato user\0user\0passwd convertido para base64 */
           RUN utils/authbase64.p (SmtpUser,SmtpPasswd, OUTPUT Base64String).
           vstate = newState(2,"AUTH PLAIN " + Base64String + crlf,hsocket).
        END.
        ELSE vState = -1.
      END. /* when 8 */

        /************************ build From **************/
      WHEN 2 THEN DO:
        IF loglevel <= 2 then 
          {&logger} vstate " " v " "  "Mail From" skip.
        IF v = 250 OR v = 235 THEN do:
          ASSIGN
          EmailTo = REPLACE(EmailTo,";",",").
          EmailCC = REPLACE(EmailCC,";",",").
          vstate =  newState(3, "MAIL From: " + ENTRY(1,EmailFrom,";") +
                             crlf,hsocket).
        END. /* if v = 250 */
        ELSE vState = -1.
      END. /* when 2 */
        /********************assign to and cc **************/
      WHEN 3 THEN DO:
        ASSIGN
        icnt    = if icnt = 0 then 1 else
                  (if icnt = ? then 1 else icnt)
        icnt1   = if icnt1 = 0 then 1 else
                  (if icnt1 = ? then 1 else icnt1)
        rcptcnt = num-entries(emailto) + num-entries(emailcc)
        smtpcmd = "".
        /************************************************************
         *** in case we get multiple responses back in the same packet,
         *** we need to parse the return string to determine how many
         *** responses we get back
         ***********************************************************/

        IF loglevel <= 2 THEN 
           {&logger} vstate " " v " "  "Mail to/CC" skip 
                    "rcptcnt " rcptcnt skip
                    "rspcnt " rspcnt " emailto " NUM-ENTRIES(emailto) 
                    " cc " NUM-ENTRIES(emailcc) skip.
        IF v = 250 THEN do:       /* loop through all to's and cc's  */
          DO icnt = icnt to NUM-ENTRIES(EmailTo):
            if loglevel <= 2 THEN 
              {&logger} icnt "email to " ENTRY(icnt,emailto) skip.
            vstate = newState(4, "RCPT TO: " + ENTRY(icnt,EmailTo) + 
                                 crlf,hsocket). 
          END.  /*  do icnt = 1 to num-entries(EmailTo): */
          IF emailcc <> "" THEN DO icnt1 = icnt1 to NUM-ENTRIES(Emailcc):
            IF loglevel <= 2 then 
              {&logger} icnt1 " email to " ENTRY(icnt1,emailcc) skip.
            vstate = newState(4, "RCPT TO: " + ENTRY(icnt1,EmailCC) +
                                  crlf,hsocket). 
          END. /* if emailcc <> "" then do*/
        END. /*  IF v = 250 THEN */

        teststr = str.
        rpt-bl:
        REPEAT:
          IF INDEX(teststr,"Recipient") = 0 THEN LEAVE rpt-bl.
          ELSE rspcnt = rspcnt + 1.
          teststr = SUBSTR(teststr,INDEX(teststr,"Recipient") + 9).
        END. /* repeat */
        IF loglevel <= 2 THEN
          {&logger} "end of 3: " str skip  "rspcnt " rspcnt 
                    "rcptcnt " rcptcnt skip.
        if rspcnt = rcptcnt then
          vstate = newstate(5,"DATA " + crlf, hsocket).
      end. /* when 3 */
      /*************** build header ********************/
      WHEN 4 THEN DO:
        if loglevel <= 2 then {&logger} vstate " " v " "  "Data" skip.
        IF v = 250 THEN
          vstate = newState(5, "DATA " + crlf,hsocket).
        ELSE vState = -1.
      END. /* when 4 */
      WHEN 5 THEN DO:
        IF loglevel <= 2 then {&logger} vstate " " v " "
                               "build header/send data" skip.
        IF v = 354 THEN do:
          /* Build Email Header */
          smtpcmd = "From: " 
          + (IF NUM-ENTRIES(EmailFrom,";") > 1 THEN ENTRY(2,emailfrom,";") + " <" + ENTRY(1,emailfrom,";") + ">"
          ELSE EmailFrom) + crlf.
          /**************************************/
          /* Loop through all To's              */
          /**************************************/
          IF EmailTo <> "" THEN DO idx = 1 TO NUM-ENTRIES(EmailTo):
            smtpcmd = smtpcmd + "To: " + ENTRY(idx,EmailTo) + "~n".
          END.  /* IF EmailTo <> "" THEN DO idx = 1 */

          /*****************************/
          /* Loop through all CC's     */
          /*****************************/
          IF EmailCC <> "" THEN DO idx = 1 TO NUM-ENTRIES(EmailCC):
            smtpcmd = smtpcmd + "Cc: " + ENTRY(idx,EmailCC) + "~n".
          END.  /* IF EmailCC <> "" THEN  */
               
          ASSIGN
          smtpcmd = smtpcmd + "Subject: " + Subject + "~n" 
          /* Sample format    Date: 27 March 2001 10:30:00 EST */
          smtpcmd = smtpcmd + "Date: " + STRING(DAY(TODAY)) + " " +
                    entry(MONTH(TODAY),cMonth) + " " +
                    STRING(YEAR(TODAY),"9999") + " " +
                    STRING(TIME,"hh:mm:ss") + " " + localTimezone + "~n".

          SET-SIZE(mData) = LENGTH(smtpcmd) + 1.
          PUT-STRING(mData,1) = smtpcmd.
          RUN WriteData(input mData, input hsocket).
          SET-SIZE(mData) = 0.

          /********************************************************/
          /* Begin sending message                                */
          /********************************************************/
          /* Done building Email Hdr, Now do body of the message */
          /** Set up a boundary value if we have file attachments **/
          /** Create multi mime header for email **/
          IF Attachments <> "" THEN DO:
            ASSIGN
            cBoundary = "MAIL_BOUNDARY"
            smtpcmd = "MIME-Version: 1.0" + "~n" +
                      'Content-type: multipart/mixed;~n' +
              '        boundary="' + cBoundary + '"~n' + 
                      "Content-Transfer-Encoding: 7bit~n".
            smtpcmd = smtpcmd + "This is a multi-part MIME Encoded message" +
                      "~n~n--" + cBoundary + "~n".
            SET-SIZE(mData) = LENGTH(smtpcmd) + 1.
            PUT-STRING(mData,1) = smtpcmd.
            RUN WriteData(input mData, input hsocket).
            SET-SIZE(mData) = 0.
          END. /* IF Attachments <> "" THEN DO: */

          /** Do we have a MIME Type for this messsage **/
          IF MIMEHeader <> "" THEN DO:
            RUN ParseParm(INPUT MIMEHeader,
                          OUTPUT cMimetype,
                          OUTPUT cCharset,
                          OUTPUT cfiletype).
            smtpcmd = IF Attachments = "" THEN "Mime-Version: 1.0~n"
                                           ELSE "".
            smtpcmd = smtpcmd + "Content-Type: " + cMimeType +
                      "; charset=" + cCharSet + "~n" +
                      "Content-Transfer-Encoding: 7bit~n".
            SET-SIZE(mData) = LENGTH(smtpcmd) + 1.
            PUT-STRING(mData,1) = smtpcmd.
            RUN WriteData(INPUT mData, INPUT hsocket).
            SET-SIZE(mData) = 0.
          END.  /* IF MIMEHeader <> "" THEN DO: */

          /*********************************************************/
          /* Output the Message                                    */
          /*********************************************************/
          smtpcmd = "~n".
          IF bodytype = "file" THEN DO:
        /************************************************
          9/19/01 PK
          Write the blank line to the Socket to indicate the 
          start of the Body of the message. Bug was discovered
          by David De Beule [david@mips.be] on 8/28/2001 
          10/3/01 SES - Also was addressed by Mike Bremmeyr, but
          this was found to be a better fix.
        *****************************************************/
        SET-SIZE(mdata) = LENGTH(smtpcmd) + 1.
        PUT-STRING(mData,1) = smtpcmd.
        RUN WriteData(INPUT mData, INPUT hSocket).
        SET-SIZE(mData) = 0.
            IF loglevel <= 2 THEN
              {&logger} "before getfile " GET-SIZE(mdata) skip.
            mData = getfile(body).
           IF loglevel <= 2 THEN DO:
              {&logger} "after getfile " GET-SIZE(mdata) skip.
            END.

            RUN WriteData(INPUT mData, INPUT hsocket).
            SET-SIZE(mData) = 0.
          END. /* if bodytype = "file" */
          ELSE DO:
            smtpcmd = smtpcmd + Body + "~n".
            SET-SIZE(mData) = length(smtpcmd) + 1.
            PUT-STRING(mData,1) = smtpcmd.
            RUN WriteData(input mData, input hsocket).
            SET-SIZE(mData) = 0.
          END.  /*  else */
          /*******************************************************/
          /* Process any files attachments.                      */
          /*******************************************************/
          /* LocalFiles holds comma separated list of files that are 
         in the Progress path or contain an fullpath.
             Attachments holds colon separated list of parameters of
             to use in sending file. The 1st parameter is the name of 
         file to use in generating a temporary file, the remaining
         parameters are all optional: 
         Type=text/plain   Charset=US-ASCII   FileType=ASCII
          */
          DO idx = 1 TO NUM-ENTRIES(LocalFiles):
            ASSIGN
            cFile = ENTRY(1,ENTRY(idx,Attachments),":")
            cLocalFile = ENTRY(idx,LocalFiles).
            
            /** set up the mime header **/
            /* Content-Type: <mimetype>; charset=<charset> */
            RUN parseParm(input entry(idx,attachments),
                          output cMimetype,
                          output cCharset,
                          output cfiletype).

            smtpcmd = "~n--" + cBoundary + "~n" +
                      "Content-type: " + cMimeType + "; ".
            IF cFileType <> "Binary" THEN
              smtpcmd = smtpcmd + "charset=" + cCharSet.
            smtpcmd = smtpcmd + '~n        name="' + cFile + '"~n'.


            IF cFileType = "Binary" THEN
              smtpcmd = smtpcmd + 'Content-Transfer-Encoding: base64~n'.

            smtpcmd = smtpcmd + 'Content-Disposition: attachment;~n' +
                      '        filename="' + cFile + '"~n~n'.
            SET-SIZE(mData) = LENGTH(smtpcmd) + 1.
            PUT-STRING(mData,1) = smtpcmd.
            RUN WriteData(INPUT mData, INPUT hsocket).
            SET-SIZE(mData) = 0.

            /** now do the file **/
           mData = getfile(ENTRY(idx,attachbinlist)).
           RUN WriteData(INPUT mData, INPUT hsocket).
            SET-SIZE(mData) = 0.

        smtpcmd = "~n".
        SET-SIZE(mData) = LENGTH(smtpcmd) + 1.
        PUT-STRING(mData,1) = smtpcmd.
        RUN WriteData(INPUT mData, INPUT hsocket).
        SET-SIZE(mData) = 0.

            /** if we have a "Binary" file then try to delete 
                the encoded version **/
            IF cFileType = "Binary" THEN
              OS-DELETE VALUE(entry(idx,attachbinlist)) NO-ERROR.
          END. /** process each attachment  do idx - 1 to num-entries **/

          IF Attachments <> "" THEN DO:
            smtpcmd = '~n--' + cBoundary + '--~n~n'.
            SET-SIZE(mData) = length(smtpcmd) + 1.
            PUT-STRING(mData,1) = smtpcmd.
            RUN WriteData(input mData, input hsocket).
            SET-SIZE(mData) = 0.
          END. /* IF Attachments <> "" THEN DO: */
          vstate = newstate(6, crlf + "." + crlf, hsocket).
        END. /* if v = 354 */
        ELSE vState = -1.
      END. /* when 5 */
      WHEN 6 THEN DO:
        IF loglevel <= 2 THEN
          {&logger} vstate " " v " "  "send quit" skip.
        IF v = 250 THEN
          vstate = newState(7,"QUIT" + crlf,hsocket).
        ELSE vState = -1.
      END. /* when 6 */
    END CASE. /* vstate */
  END. /* IF vlength > 0 THEN DO: */
  IF loglevel <= 2 THEN {&logger}   "Finish up " vstate skip.
  IF vState = 7 THEN vMESSAGE = "E-mail aceito para envio.".
  IF vState < 0 THEN vMESSAGE = "E-mail abortado.".
  IF vstate < 0 OR vstate = 7 THEN DO:
    RUN cleanup.
    if vstate = 7 then oSuccessful = YES.
    /* If running in batch mode then tell the WHILE loop to exit */
    sending = NO.
    APPLY 'CLOSE' TO THIS-PROCEDURE.
  END.  /* IF vstate < 0 OR vstate = 7 THEN DO: */
END PROCEDURE.   /* readhandler */

PROCEDURE Cleanup.
  {&Logger} "End SMTP Session" SKIP.
  OUTPUT {&Stream} CLOSE. 

  IF VALID-HANDLE(hSocket) THEN DO:
    IF hSocket:CONNECTED() THEN hSocket:DISCONNECT() NO-ERROR.
    DELETE OBJECT hSocket.
  END.
END PROCEDURE. /* cleanup */

PROCEDURE WriteData:
  DEF INPUT PARAMETER mdata       AS memptr NO-UNDO.
  DEF INPUT PARAMETER hsocket     AS handle NO-UNDO.
  DEF VAR DataBytesWritten        AS INTEGER NO-UNDO.
  DEF VAR WriteSuccess            AS LOGICAL NO-UNDO.
  DEF VAR MessageSize             AS INTEGER NO-UNDO.
  DEF VAR mystring        AS CHARACTER NO-UNDO.

  ASSIGN
  MessageSize = GET-SIZE(mdata)
  DataBytesWritten = 0.
  IF messagesize = 0 THEN RETURN.

  /* 7/10/01 PK - Chomp off the Null at the end of the memptr data */
  IF GET-BYTE(mData,messagesize) = 0 OR
     GET-BYTE(mData,messagesize) = 255 THEN DO:  /* ||| Is this I18N compatible? - SES */
    IF loglevel <=2 THEN
      {&logger} "1 writedata chomp data" GET-BYTE(mData,messagesize) skip.
    messagesize = messagesize - 1.
  END.

  /* 6/20/01 GC - Loop continuously until the number of bytes
                  written is greater or equal to the message size */
  IF loglevel <= 1 THEN DO:
    {&logger} "writedata = before " DataBytesWritten " " 
              MessageSize " " hSocket:BYTES-WRITTEN skip
              /*GET-STRING(mdata,1,messagesize)*/ SKIP. 
  END.
  DO WHILE DataBytesWritten < MessageSize:
    IF loglevel <= 1 THEN
      {&logger} "writedata = in " DataBytesWritten " " 
                MessageSize " " hSocket:BYTES-WRITTEN skip.
    WriteSuccess = hSocket:WRITE(mdata, DataBytesWritten + 1,
                                 MessageSize - DataBytesWritten).
    /*IF NOT WriteSuccess THEN LEAVE. */
    IF WriteSuccess THEN 
      DataBytesWritten = DataBytesWritten + hSocket:BYTES-WRITTEN.
  END. /* DO WHILE */
  IF loglevel <= 1 THEN 
    {&logger} "writedata = after " DataBytesWritten " " MessageSize " "
              hSocket:BYTES-WRITTEN skip.
  SET-SIZE(mData) = 0.
END procedure. /* writeData */

/*******************************************************************/
/** Parse mime type and char set out of header                    **/
/** If nothing there, return the default                          **/
/*******************************************************************/
PROCEDURE ParseParm:
  DEF INPUT PARAMETER cString         AS CHARACTER NO-UNDO.
  DEF OUTPUT parameter cMimetype      as character no-undo.
  DEF OUTPUT parameter cCharset       as character no-undo.
  DEF OUTPUT parameter cFiletype      as character no-undo.

  DEF VAR c               AS CHARACTER NO-UNDO.
  DEF VAR i               AS INTEGER  NO-UNDO.

  ASSIGN
  cMimeType = "text/plain"
  cCharSet  = "US-ASCII"
  cFileType = "ASCII".

  DO i = 1 TO NUM-ENTRIES(cString,":"):
    c = ENTRY(i,cString,":").
    CASE ENTRY(1,c,"="):
      WHEN "Type" THEN DO:
        cMimeType = ENTRY(2,c,"=").
      END.  /*  WHEN "Type" THEN DO: */
      WHEN "CharSet" THEN DO:
        cCharSet = ENTRY(2,c,"=").
      END.  /*   WHEN "CharSet" THEN DO: */
      WHEN "FileType" THEN DO:
        cFileType = ENTRY(2,c,"=").
      END.  /* WHEN "FileType" THEN DO: */
    END CASE. /*  CASE ENTRY(1,c,"="): */
  END.  /* DO i = 1 TO NUM-ENTRIES(cString,":"): */
END PROCEDURE. /** ParseParm **/

/*****************************************************************/
/*  Generate base 64 encoded binary files                       **/
/*****************************************************************/
PROCEDURE dofiles:
  DEF INPUT parameter localfile            as char no-undo.
  DEF INPUT parameter cattachment           as char no-undo.
  DEF INPUT-OUTPUT parameter attachbinlist as char no-undo.

  DEF VAR cLocalFile                       as char no-undo.
  DEF VAR Mimetype                     as character no-undo.
  DEF VAR ccharset                      as character no-undo.
  DEF VAR cFileType                       AS CHARACTER NO-UNDO.

  FILE-INFO:FILE-NAME = localfile.
  /***** file-info returns "F" + "RW" if the file is read/writable etc)
         check to be sure it is a valid file    ************/
  IF INDEX(FILE-INFO:FILE-TYPE,"F") = 0 THEN DO:
    vMessage = localfile + " n’o ² um arquivo vÿlido.".
    RETURN.
  END.

  RUN ParseParm(INPUT cAttachment,
                OUTPUT mimetype,
                OUTPUT cCHARSET,
                OUTPUT cfiletype).

  IF cFileType = "Binary" THEN DO:
    /* 7/12/02 PK if localfile includes a file path it will cause
       some problems trying to write the file in /tmp           
       Generate a unique file to use for the encoded version */

    /* cBinaryFile is used in this loop to check for existence of
       the new encoded file.  It must be reset to the desired value
       after the loop. */
    cBinaryFile = localfile.
    DO while cBinaryFile <> ?:
      /* Use of ETIME in the name is to further minimize the 
     likelihood that the same RANDOM # could be generated by
     2 processes at once, since there is a possibility that 
     between the time search runs and the encoded file is actually
         created the same filename could be generated */
      cLocalFile = EncodeDirectory + "en" + STRING(ETIME) + 
           STRING(RANDOM(1,99999),"99999").
      cBinaryFile = SEARCH(cLocalFile). /* Check for existence */
    END.

    ASSIGN
    cBinaryFile = LocalFile. /* FILE-INFO:FULL-PATHNAME better? */
    /* 7/12/01 PK The delimiter in the else statement was a '<' */
    attachbinlist = IF attachbinlist = "" THEN cLocalFile
                    ELSE attachbinlist + "," + cLocalFile.
      /*RUN ffw/procs/b64encode.p(cBinaryFile, cLocalFile) NO-ERROR.*/
      RUN utils/b64encode.p(cBinaryFile, cLocalFile) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN {&LOGGER} ERROR-STATUS:GET-MESSAGE(1).
  END.  /* IF cFileType = "Binary" THEN  */
  ELSE attachbinlist = IF attachbinlist = "" THEN localfile
                       ELSE attachbinlist + "," + localfile.
END PROCEDURE. /* dofiles */

PROCEDURE getsocket:
  DEF INPUT PARAMETER loglevel AS INTEGER NO-UNDO.
  DEF INPUT PARAMETER mailhub  AS CHAR NO-UNDO.
  DEF OUTPUT PARAMETER hSocket AS HANDLE NO-UNDO.

  /*message mailhub view-as alert-box.*/

  CREATE SOCKET hSocket.
  hSocket:SET-SOCKET-OPTION ("TCP-NODELAY", "FALSE").
  hSocket:SET-SOCKET-OPTION ("SO-LINGER", "FALSE").
  hSocket:SET-READ-RESPONSE-PROCEDURE ("readHandler",THIS-PROCEDURE).

  hSocket:CONNECT(substitute('-H &1 -S &2':u, mailHub, mailPort)) no-error.

  IF hSocket:CONNECTED() = FALSE THEN DO:
    {&LOGGER} "Unable to Connect to " + Mailhub + "~n".
    RUN CleanUp.
    vmessage = "Imposs­vel conectar ao servidor.".
    RETURN.
  END.  /* Cannot make a connection to mail server */
  IF loglevel <= 2 THEN {&LOGGER} "Socket Connection Established.~n".
  vstate = 1.

END PROCEDURE. /* getsocket */

/******************* Functions ********************************/
FUNCTION newstate RETURNS INTEGER
  (INPUT newstate AS INTEGER,
   INPUT pstring AS CHARACTER,
   INPUT hSocket AS HANDLE):
  DEF VAR vState              AS INTEGER NO-UNDO.
  DEF VAR vbuffer             AS MEMPTR  NO-UNDO.
  DEF VAR DataBytesWritten    AS INTEGER NO-UNDO.
  DEF VAR WriteSuccess        AS LOGICAL NO-UNDO.
  DEF VAR MessageSize         AS INTEGER NO-UNDO.
  
  IF loglevel <= 2 THEN
     {&logger} "newstate " newstate " pstring " pstring skip .
  
  ASSIGN 
  DataBytesWritten = 0
  MessageSize = LENGTH(pstring).
        
  SET-SIZE(vbuffer) = 0.
  vState = newState.
  IF pstring = "" THEN RETURN -1.
  SET-SIZE(vbuffer) = LENGTH(pstring) + 1.
  PUT-STRING(vbuffer,1) = pstring.
     /* 6/20/01 GC - Loop continuously until the number of bytes
                     written is greater or equal to the message size */
  IF loglevel <= 2 THEN 
    {&logger} "newstate - before loop " DataBytesWritten " " 
              MessageSize " " hSocket:BYTES-WRITTEN skip.
  DO WHILE DataBytesWritten < MessageSize:
     WriteSuccess = hSocket:WRITE(vbuffer, DataBytesWritten + 1, 
                                  MessageSize - DataBytesWritten).
     IF NOT WriteSuccess THEN LEAVE.
     DataBytesWritten = DataBytesWritten + hSocket:BYTES-WRITTEN.
  END. /* DO WHILE */
  IF loglevel <= 2 THEN
    {&logger} "newstate - after loop " DataBytesWritten " "
             hSocket:BYTES-WRITTEN " " MessageSize skip.
  SET-SIZE(vbuffer) = 0.
  RETURN vstate.
END function.  /* newstate */

FUNCTION getfile RETURNS MEMPTR(INPUT filnm AS CHAR):
  DEF VAR hdata AS MEMPTR NO-UNDO.
    
  FILE-INFO:FILE-NAME = filnm.
  IF loglevel <= 2 THEN 
    {&logger} "in getfile " FILE-INFO:FILE-NAME skip 
              FILE-INFO:FULL-PATHNAME skip
              FILE-INFO:FILE-TYPE skip
              FILE-INFO:FILE-SIZE skip.
    
  IF INDEX(FILE-INFO:FILE-TYPE,"f") = 0 THEN DO:
    SET-SIZE(hdata) = 0.
    RETURN hdata.
  END. /*     if file-info:file-type <> "f" then */
  ELSE DO:
    SET-SIZE(hdata) = 0.
    INPUT FROM VALUE(FILE-INFO:FILE-NAME) BINARY NO-MAP NO-CONVERT.
    SET-SIZE(hdata) = FILE-INFO:FILE-SIZE + 1.
    IMPORT UNFORMATTED hdata NO-ERROR.
    INPUT CLOSE.
    IF ERROR-STATUS:ERROR THEN
      SET-SIZE(hdata) = 0.
    RETURN hdata.
  END. /* else */
  /*  set-size(hdata) = 0. */
END FUNCTION. /* getfile */

