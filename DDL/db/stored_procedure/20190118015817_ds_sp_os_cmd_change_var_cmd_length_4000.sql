CREATE PROCEDURE ds_sp_os_cmd @os_cmd NVARCHAR(4000), @return_message NVARCHAR(4000) OUTPUT
AS BEGIN
   DECLARE @ErrorMessage   NVARCHAR(4000);
   DECLARE @ErrorState     INT;
   DECLARE @ErrorSeverity  INT;
   DECLARE @ErrorLevel INT;
   DECLARE @out_tbl TABLE (line NVARCHAR(4000))

   SET @return_message = NULL;
   BEGIN TRY
      INSERT INTO @out_tbl
      EXEC @ErrorLevel = master.dbo.xp_cmdshell @os_cmd;
      SELECT @return_message = COALESCE(@return_message+'; ','') + line FROM @out_tbl WHERE line IS NOT NULL;
      
      IF (@ErrorLevel > 0)
         BEGIN
            RAISERROR(N'Error # %d in Export Error', 16, 1, @ErrorLevel);
         END;
	  RETURN;
   END TRY

   BEGIN CATCH 
       SELECT @ErrorMessage  = ERROR_MESSAGE(),
              @ErrorState     = ERROR_STATE(),
              @ErrorSeverity  = ERROR_SEVERITY();

       RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
       RETURN;
   END CATCH;

END
