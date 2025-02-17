UPDATE "library"
SET "target" = array_remove("target", 'ADE')
WHERE "docName" = 'CY-47';