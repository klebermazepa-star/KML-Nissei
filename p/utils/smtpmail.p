DEF INPUT PARAMETER mailhub         as char no-undo.
DEF INPUT PARAMETER EmailTo         AS CHAR NO-UNDO.
DEF INPUT PARAMETER EmailFrom       AS CHAR NO-UNDO.
DEF INPUT PARAMETER EmailCC         AS CHAR NO-UNDO.
DEF INPUT PARAMETER Attachments     AS CHAR NO-UNDO.
DEF INPUT PARAMETER LocalFiles      AS CHAR NO-UNDO.
DEF INPUT PARAMETER Subject         AS CHAR NO-UNDO.
DEF INPUT PARAMETER Body            AS CHAR NO-UNDO.
DEF INPUT PARAMETER MIMEHeader      AS CHAR NO-UNDO.
DEF INPUT PARAMETER BodyType        as char no-undo.

DEF OUTPUT PARAMETER oSuccessful    AS LOGICAL NO-UNDO.
DEF OUTPUT PARAMETER vMessage       AS CHAR NO-UNDO.

{system/Error.i}

do {&throws}:
    run utils/smtpMailAuth.p
        (mailhub
         , EmailTo
         , 25
         , EmailFrom
         , EmailCC
         , Attachments
         , LocalFiles
         , Subject
         , Body
         , MIMEHeader
         , BodyType
         , false /* SmtpReqAuth */
         , '':u /* SmtpUser */
         , '':u /* SmtpPasswd */
         , output oSuccessful
         , output vMessage).
end.
