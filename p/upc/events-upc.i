

OUTPUT TO VALUE ("{1}") APPEND .

PUT UNFORMATTED 'p-ind-event: ' p-ind-event SKIP
    'p-ind-object: ' p-ind-object SKIP
    'p-wgh-object: ' p-wgh-object SKIP
    'object-name: ' IF p-wgh-object <> ? THEN p-wgh-object:NAME ELSE "" SKIP
    'p-wgh-frame: ' p-wgh-frame SKIP
    'frame-name: ' p-wgh-frame:NAME SKIP
    'p-cod-table: ' p-cod-table SKIP
    'p-row-table: ' STRING(p-row-table) SKIP(2)
    .

OUTPUT CLOSE.
