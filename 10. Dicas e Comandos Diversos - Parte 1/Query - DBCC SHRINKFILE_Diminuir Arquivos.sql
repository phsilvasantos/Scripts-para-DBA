BACKUP LOG Etiqueta
WITH TRUNCATE_ONLY

-- No Shrink deve usar o Logical Name, no exemplo abaixo é Etiqueta_Log, vejo em:
-- Clicando no banco > propriety > files
DBCC SHRINKFILE (N'Etiqueta_Log' , 0, TRUNCATEONLY)


--Shrink direto na Base
DBCC SHRINKFILE (N'Etiqueta' , 0, TRUNCATEONLY)
