UPDATE "library"
SET "target" = CASE
    WHEN NOT ('NEWGROUP' = ANY("target")) THEN "target" || '{"NEWGROUP"}'
    ELSE "target"
END
WHERE "docName" = 'CY-47';