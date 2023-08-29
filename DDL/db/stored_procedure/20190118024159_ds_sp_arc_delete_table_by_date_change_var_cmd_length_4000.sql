CREATE PROCEDURE ds_sp_arc_delete_table_by_date (@database_name NVARCHAR(128), @schema_name NVARCHAR(128), @table_name NVARCHAR(128), @delete_target_date DATETIME)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @cmd  NVARCHAR(4000)=NULL;
DECLARE @sql  NVARCHAR(4000)=NULL;
DECLARE @result INT=NULL;
DECLARE @date_key NVARCHAR(128)=NULL;
DECLARE @delete_data_start_at DATETIME=NULL;
DECLARE @delete_data_end_at DATETIME=NULL;
DECLARE @next_delete_data_start_at DATETIME=NULL;
DECLARE @next_delete_data_end_at DATETIME=NULL;
DECLARE @delete_batch_interval_hour INT=NULL;
DECLARE @ParmDefinition NVARCHAR(512) = NULL;
DECLARE @column_list NVARCHAR(4000) = NULL;
DECLARE @feature NVARCHAR(45) = 'arc';
DECLARE @parameter NVARCHAR(128) = NULL;
DECLARE @delete_rows_pre_batch INT=NULL;
DECLARE @delete_wait_delay NVARCHAR(8)=NULL;
DECLARE @job_id NVARCHAR(36) = NULL;
DECLARE @arc_action NVARCHAR(45) = 'delete';
DECLARE @state NVARCHAR(45) = NULL;
DECLARE @message NVARCHAR(4000) = NULL;
DECLARE @cmd_return INT = NULL;
DECLARE @cmd_return_message NVARCHAR(4000) = NULL;
DECLARE @ErrorMessage   NVARCHAR(4000);
DECLARE @ErrorState     INT;
DECLARE @ErrorSeverity  INT;
DECLARE @ErrorLevel INT;
DECLARE @deleted_rows INT = NULL;


    -- Get parameters
    SET @parameter = 'delete_rows_pre_batch';
    SELECT @delete_rows_pre_batch = dbo.ds_fn_system_parameters_get_value(@feature,@parameter)
    -- exception handling
        IF @delete_rows_pre_batch IS NULL
          BEGIN
              RAISERROR('DeleteRowsPreBatchSystemParameterNotFound',0,1);
              RETURN;
           END;

    SET @parameter = 'delete_wait_delay';
    SELECT @delete_wait_delay = dbo.ds_fn_system_parameters_get_value(@feature,@parameter)
    IF @delete_wait_delay IS NULL
      BEGIN
          RAISERROR('DeleteWaitDelaySystemParameterNotFound',0,1);
          RETURN;
       END;

    -- Get the date key and export data date range
    EXEC [ds_sp_arc_tables_get_delete_time] @database_name, @schema_name, @table_name, @date_key OUTPUT, @delete_batch_interval_hour OUTPUT, @delete_data_start_at OUTPUT, @delete_data_end_at OUTPUT
    IF (@date_key IS NULL OR @delete_batch_interval_hour IS NULL OR @delete_data_start_at IS NULL OR @delete_data_end_at IS NULL)
        BEGIN
            RAISERROR('ArcTablesDataNotFound',0,1);
            RETURN;
    END
    IF (@delete_data_start_at >= @delete_data_end_at )
        BEGIN
            RAISERROR('DeleteDataStartEndTimeInCorrect',0,1);
            RETURN;
        END


    WHILE @delete_data_end_at <= @delete_target_date
    BEGIN 
        PRINT '';
        PRINT '>>>>> ' + CONVERT(NVARCHAR(19),GETUTCDATE(),120);
        PRINT 'KEY:     ' + @date_key
        PRINT 'START:   ' + CONVERT(NVARCHAR(19),@delete_data_start_at,120);
        PRINT 'END:     ' + CONVERT(NVARCHAR(19),@delete_data_end_at,120);
        PRINT 'TARGET:  ' + CONVERT(NVARCHAR(19),@delete_target_date,120);
        --PRINT '@delete_rows_pre_batch: ' + CAST(@delete_rows_pre_batch AS NVARCHAR(10));
        --PRINT '@delete_wait_delay: ' + CAST(@delete_wait_delay AS NVARCHAR(10));
        PRINT ''

        -- Compose delete SQL statement
        SET @sql = 'DELETE TOP (' + CAST(@delete_rows_pre_batch AS NVARCHAR(45)) + ') FROM ' + QUOTENAME(@database_name) + '.' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) + ' WHERE ' + QUOTENAME(@date_key) + ' >= ' + '''' + CONVERT(NVARCHAR(19),@delete_data_start_at,120) + '''' + ' AND ' + QUOTENAME(@date_key) + ' < ' + '''' + CONVERT(NVARCHAR(19),@delete_data_end_at,120) + ''''
        PRINT 'Executing: ' + @sql

        SET @job_id = NEWID();
        SET @state = 'start' 
        SET @message = 'execute: ' + @sql
         EXEC ds_sp_arc_logs_insert @job_id, @database_name, @schema_name, @table_name, @arc_action, @state, @delete_data_start_at, @delete_data_end_at, @message

        SET NOCOUNT OFF;
        SET @deleted_rows = 1;        
            WHILE (@deleted_rows > 0)
            BEGIN
                BEGIN TRY
                    -- Delete records
                    EXEC sp_executesql @sql
                    SET @deleted_rows = @@ROWCOUNT;
                    
                    PRINT '>>> deleted rows: ' + CAST(@deleted_rows AS NVARCHAR(10));
                END TRY
                
                BEGIN CATCH 
                    SELECT @ErrorMessage  = ERROR_MESSAGE(),
                           @ErrorState     = ERROR_STATE(),
                           @ErrorSeverity  = ERROR_SEVERITY();

                    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
                    SET @cmd_return_message = @ErrorMessage
                    SET @state = 'end'
                    EXEC ds_sp_arc_logs_insert @job_id, @database_name, @schema_name, @table_name, @arc_action, @state, @delete_data_start_at, @delete_data_end_at, @cmd_return_message
                    RETURN;
                END CATCH;
            END
            
        -- SET NEXT DELETE TIME SLOT
        SET @next_delete_data_start_at = @delete_data_end_at;
        SET @next_delete_data_end_at = DATEADD(HOUR, @delete_batch_interval_hour, @delete_data_end_at)
  
        -- UPDATE arc_tables
        UPDATE t
        SET t.delete_data_start_at=@next_delete_data_start_at, t.delete_data_end_at=@next_delete_data_end_at, t.updated_at=GETUTCDATE()
        FROM arc_tables t
        JOIN arc_databases d ON d.id = t.arc_database_id
        WHERE d.name = @database_name AND t.schema_name = @schema_name AND t.name= @table_name
        
        -- Log
        SET @state = 'end'
        EXEC ds_sp_arc_logs_insert @job_id, @database_name, @schema_name, @table_name, @arc_action, @state, @delete_data_start_at, @delete_data_end_at, @cmd_return_message

         -- WAIT FOR DELAY A BIT
         WAITFOR DELAY @delete_wait_delay;
         
         -- Get arc_tables delete time
         EXEC [ds_sp_arc_tables_get_delete_time] @database_name, @schema_name, @table_name, @date_key OUTPUT, @delete_batch_interval_hour OUTPUT, @delete_data_start_at OUTPUT, @delete_data_end_at OUTPUT
    END

END

