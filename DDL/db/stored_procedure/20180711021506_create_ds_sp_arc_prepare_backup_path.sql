CREATE PROCEDURE ds_sp_arc_prepare_backup_path(@backup_root NVARCHAR(512), @server_name NVARCHAR(128), @database_name NVARCHAR(128), @schema_name NVARCHAR(128), @table_name NVARCHAR(128))
    AS
    BEGIN
        DECLARE @cmd  NVARCHAR(1024)=NULL;
        DECLARE @Result INT=NULL;
        SELECT @cmd = 'dir ' + @backup_root + '\' + @server_name +'\'+ @database_name +'\'+ @schema_name +'\'+ @table_name
        -- Run the dir command, put output of xp_cmdshell into @Result
        EXEC @Result = master.dbo.xp_cmdshell @cmd, NO_OUTPUT
        -- If the directory does not exist, we must create it
        IF @Result <> 0
            BEGIN
                -- Build the mkdir command  
                SELECT @cmd = 'mkdir ' + @backup_root + '\' + @server_name + '\' + @database_name +'\'+ @schema_name +'\'+ @table_name
                -- Create the directory
                EXEC master.dbo.xp_cmdshell @cmd, NO_OUTPUT
            END
   END
