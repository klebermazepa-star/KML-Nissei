{utils/class/ClassGeneratorDefine.i ttAttributes}

define input  parameter table for ttAttributes.
define output parameter table for ttIndex.

empty temp-table ttIndex.

for first ttAttributes,
    first dictdb._file no-lock where
          dictdb._file._file-name = ttAttributes.tableName,
    each dictdb._index of dictdb._file no-lock where
         recid(dictdb._index) = dictdb._file._prime-index,
    each dictdb._index-field of dictdb._index no-lock,
    first dictdb._field no-lock where
          recid(dictdb._field) = dictdb._index-field._field-recid:

    create ttIndex.
    assign ttIndex.tableName = dictdb._file._file-name
           ttIndex.indexName = dictdb._index._index-name
           ttIndex.indexSeq  = dictdb._index-field._index-seq
           ttIndex.fieldName = dictdb._field._field-name
           ttIndex.fieldType = dictdb._field._data-type.
end.
