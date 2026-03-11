
define temp-table ttAttributes no-undo
    field dbaseName     as character
    field tableName     as character
    field fieldName     as character
    field attributeName as character
    field typeField     as character
    field numExtent     as integer
    field labelField    as character
    index pq_field is primary tableName fieldName ascending
    index si_field fieldName tableName ascending.

define temp-table ttIndex no-undo
    field tableName  as character
    field indexName  as character
    field indexSeq   as integer 
    field fieldName  as character
    field fieldType  as character 
    index pq_index is primary tableName indexName indexSeq.
