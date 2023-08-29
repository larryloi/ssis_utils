CREATE PROCEDURE ds_sp_arc_export_table_by_date (@backup_root NVARCHAR(512) ,@server_name NVARCHAR(128), @database_name NVARCHAR(128), @schema_name NVARCHAR(128), @table_name NVARCHAR(128), @backup_target_date DATETIME)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @cmd  NVARCHAR(4000)=NULL;
DECLARE @sql  NVARCHAR(4000)=NULL;
DECLARE @result INT=NULL;
DECLARE @date_key NVARCHAR(128)=NULL;
DECLARE @backup_data_start_at DATETIME=NULL;
DECLARE @backup_data_end_at DATETIME=NULL;
DECLARE @next_backup_data_start_at DATETIME=NULL;
DECLARE @next_backup_data_end_at DATETIME=NULL;
DECLARE @backup_batch_interval_hour INT=NULL;
DECLARE @ParmDefinition NVARCHAR(512) = NULL;
DECLARE @column_list NVARCHAR(4000) = NULL;
DECLARE @feature NVARCHAR(45) = 'arc';
DECLARE @parameter NVARCHAR(128) = 'backup_wait_delay';
DECLARE @backup_wait_delay NVARCHAR(8)=NULL;
DECLARE @job_id NVARCHAR(36) = NULL;
DECLARE @arc_action NVARCHAR(45) = 'backup';
DECLARE @state NVARCHAR(45) = NULL;
DECLARE @message NVARCHAR(4000) = NULL;
DECLARE @cmd_return INT = NULL;
DECLARE @cmd_return_message NVARCHAR(4000) = NULL;
DECLARE @ErrorMessage   NVARCHAR(4000);
DECLARE @ErrorState     INT;
DECLARE @ErrorSeverity  INT;
DECLARE @ErrorLevel INT;


    SELECT @backup_wait_delay = dbo.ds_fn_system_parameters_get_value(@feature,@parameter)
    IF @backup_wait_delay IS NULL
      BEGIN
          RAISERROR('BackupDelaySystemParameterNotFound',0,1);
          RETURN;
       END;

    -- Get column list from table
    SET @sql = 'SELECT @columns=COALESCE( @columns+'+''''+', '+''''+','+''''+''''+')+COLUMN_NAME FROM ' + 
               QUOTENAME(@database_name) + '.[INFORMATION_SCHEMA].[COLUMNS] (nolock) ' + 
               ' WHERE TABLE_CATALOG=N'+'''' + @database_name + '''' + ' AND TABLE_SCHEMA=N' + '''' + @schema_name + '''' + 
               ' AND TABLE_NAME=N' + '''' + @table_name + '''' ;
    
    EXEC sp_executesql @sql, N'@columns NVARCHAR(4000) OUTPUT', @columns=@column_list OUTPUT;
    

    -- Get the date key and export data date range
    EXEC [ds_sp_arc_tables_get_backup_time] @database_name, @schema_name, @table_name, @date_key OUTPUT, @backup_batch_interval_hour OUTPUT, @backup_data_start_at OUTPUT, @backup_data_end_at OUTPUT
    IF (@date_key IS NULL OR @backup_batch_interval_hour IS NULL OR @backup_data_start_at IS NULL OR @backup_data_end_at IS NULL)
        BEGIN
            RAISERROR('ArcTablesDataNotFound',0,1);
            RETURN;
    END
    IF (@backup_data_start_at >= @backup_data_end_at )
        BEGIN
            RAISERROR('BackupDataStartEndTimeInCorrect',0,1);
            RETURN;
        END


    WHILE @backup_data_end_at <= @backup_target_date
    BEGIN 
        PRINT '';
        PRINT '>>>>> ' + CONVERT(NVARCHAR(19),GETUTCDATE(),120);
        PRINT 'KEY:     ' + @date_key
        PRINT 'START:   ' + CONVERT(NVARCHAR(19),@backup_data_start_at,120);
        PRINT 'END:     ' + CONVERT(NVARCHAR(19),@backup_data_end_at,120);
        PRINT 'TARGET:  ' + CONVERT(NVARCHAR(19),@backup_target_date,120);
        PRINT ''

        --Export Table definition xml
        SET @cmd = 'bcp '  + @database_name +'.'+ @schema_name +'.'+ @table_name + ' format nul -S ' + @server_name + ' -T -c -t #@#@, -r \n -x -f ' + 
           @backup_root  + '\' + @server_name +'\'+ @database_name +'\'+ @schema_name + '\' + @table_name + '\' + 
           @table_name + '_' + CONVERT(NVARCHAR(19),@backup_data_start_at,112) + '_' + REPLACE(CONVERT(NVARCHAR(19),@backup_data_start_at,108),':','') + 
           '__' + CONVERT(NVARCHAR(19), @backup_data_end_at,112) + '_' + REPLACE(CONVERT(NVARCHAR(19), @backup_data_end_at,108),':','') + '.xml'
        --PRINT @cmd
        -- Log
        SET @job_id = NEWID();
        SET @state = 'start'
        SET @message = 'execute: ' + @cmd
        EXEC ds_sp_arc_logs_insert @job_id, @database_name, @schema_name, @table_name, @arc_action, @state, @backup_data_start_at, @backup_data_end_at, @message

        --EXEC @cmd_return = master.dbo.xp_cmdshell @cmd
        EXEC ds_sp_os_cmd @cmd, @cmd_return_message OUTPUT

        -- Log
        SET @state = 'end'
        EXEC ds_sp_arc_logs_insert @job_id, @database_name, @schema_name, @table_name, @arc_action, @state, @backup_data_start_at, @backup_data_end_at, @cmd_return_message

        BEGIN TRY
                --Export Table data
                SET @cmd = 'bcp ' + '"SELECT ' + @column_list + ' FROM ' + QUOTENAME(@database_name) +'.'+ QUOTENAME(@schema_name) +'.'+ QUOTENAME(@table_name)  + ' (nolock) ' +
                           ' WHERE '+ QUOTENAME(@date_key) +' >= '+ '''' +  CONVERT(NVARCHAR(19),@backup_data_start_at,120) + '''' +
                           ' AND ' + QUOTENAME(@date_key) +' < '+ '''' +  CONVERT(NVARCHAR(19),@backup_data_end_at,120) + '''' + '"' + 
                           ' queryout ' + 
                           @backup_root  + '\' + @server_name +'\'+ @database_name +'\'+ @schema_name + '\' + @table_name + '\' + 
                           @table_name + '_' + CONVERT(NVARCHAR(19),@backup_data_start_at,112) + '_' + REPLACE(CONVERT(NVARCHAR(19),@backup_data_start_at,108),':','') + 
                           '__' + CONVERT(NVARCHAR(19), @backup_data_end_at,112) + '_' + REPLACE(CONVERT(NVARCHAR(19), @backup_data_end_at,108),':','') + '.csv' +
                           ' -S ' + @server_name + ' -T -t #@#@ -f ' +
                           @backup_root  + '\' + @server_name +'\'+ @database_name +'\'+ @schema_name + '\' + @table_name + '\' + 
                           @table_name + '_' + CONVERT(NVARCHAR(19),@backup_data_start_at,112) + '_' + REPLACE(CONVERT(NVARCHAR(19),@backup_data_start_at,108),':','') + 
                           '__' + CONVERT(NVARCHAR(19), @backup_data_end_at,112) + '_' + REPLACE(CONVERT(NVARCHAR(19), @backup_data_end_at,108),':','') + '.xml'
               
                SET @job_id = NEWID();
                SET @state = 'start' 
                SET @message = 'execute: ' + @cmd
                 EXEC ds_sp_arc_logs_insert @job_id, @database_name, @schema_name, @table_name, @arc_action, @state, @backup_data_start_at, @backup_data_end_at, @message
        
                --EXEC master.dbo.xp_cmdshell @cmd, NO_OUTPUT
                EXEC ds_sp_os_cmd @cmd, @cmd_return_message OUTPUT;

                -- Log
                SET @state = 'end'
                EXEC ds_sp_arc_logs_insert @job_id, @database_name, @schema_name, @table_name, @arc_action, @state, @backup_data_start_at, @backup_data_end_at, @cmd_return_message

                 -- SET NEXT BACKUP TIME
                 SET @next_backup_data_start_at = @backup_data_end_at;
                 SET @next_backup_data_end_at = DATEADD(HOUR, @backup_batch_interval_hour, @backup_data_end_at)
          
                 -- UPDATE arc_tables
                 UPDATE t
                 SET t.backup_data_start_at=@next_backup_data_start_at, t.backup_data_end_at=@next_backup_data_end_at, t.updated_at=GETUTCDATE()
                 FROM arc_tables t
                 JOIN arc_databases d ON d.id = t.arc_database_id
                 WHERE d.name = @database_name AND t.schema_name = @schema_name AND t.name= @table_name

        END TRY


        BEGIN CATCH 
             SELECT @ErrorMessage  = ERROR_MESSAGE(),
                    @ErrorState     = ERROR_STATE(),
                    @ErrorSeverity  = ERROR_SEVERITY();

             RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
             RETURN;
         END CATCH;

         -- WAIT FOR DELAY A BIT
         WAITFOR DELAY @backup_wait_delay;
         
         -- Get arc_tables backup time
         EXEC [ds_sp_arc_tables_get_backup_time] @database_name, @schema_name, @table_name, @date_key OUTPUT, @backup_batch_interval_hour OUTPUT, @backup_data_start_at OUTPUT, @backup_data_end_at OUTPUT
    END

END

