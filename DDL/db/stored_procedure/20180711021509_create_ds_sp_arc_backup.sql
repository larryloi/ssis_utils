CREATE PROCEDURE ds_sp_arc_backup
AS 
BEGIN

DECLARE @server_name NVARCHAR(128) = REPLACE(@@SERVERNAME,'\','$');
DECLARE @feature NVARCHAR(45) = NULL;
DECLARE @parameter NVARCHAR(128) = NULL;
DECLARE @backup_root NVARCHAR(512) = NULL;
DECLARE @os_cmd NVARCHAR(4000) = NULL;

-- Get backup path
SET @feature = 'arc';
SET @parameter = 'backup_root';
SELECT @backup_root = dbo.ds_fn_system_parameters_get_value(@feature,@parameter)
-- exception handling
PRINT 'Backup Path: ' + @backup_root
	IF @backup_root IS NULL
      BEGIN
          RAISERROR('BackupPathSystemParameterNotFound',0,1);
		  RETURN;
       END;


--    Get backup table configuration
DECLARE @base_database NVARCHAR(218) = DB_NAME();
DECLARE @database_name NVARCHAR(128) = NULL;
DECLARE @schema_name NVARCHAR(128) = NULL;
DECLARE @table_name NVARCHAR(128) = NULL;
DECLARE @date_key NVARCHAR(128) = NULL;
DECLARE @backup_batch_interval_hour INT = NULL;
DECLARE @backup_delay_interval_hour INT = NULL;



DECLARE arc_table_cursor CURSOR FOR
SELECT d.name AS database_name, t.schema_name, t.name AS table_name, t.date_key, t.backup_delay_interval_hour
FROM arc_databases d (nolock)
JOIN arc_tables t (nolock) ON d.id= t.arc_database_id AND d.state=1 AND t.state IN (1,2)
ORDER BY d.id, t.id;
-- arc_tables.state (1 - backup enabled only, 2 - backup and delete enabled)

OPEN arc_table_cursor;

FETCH NEXT FROM arc_table_cursor
INTO @database_name, @schema_name, @table_name, @date_key, @backup_delay_interval_hour


WHILE @@FETCH_STATUS = 0  
    BEGIN

	    DECLARE @sql NVARCHAR(4000) = NULL;
        DECLARE @backup_target_date DATETIME = NULL;
        DECLARE @etl_data_process_completed_at DATETIME = NULL;
	    DECLARE @object_exists TINYINT = 0;
	    DECLARE @config_check_pass TINYINT = NULL;

	    -- CHECK OBJECT EXISTS
        EXEC [ds_sp_check_object_exists] @database_name, @schema_name, @table_name, @date_key, @object_exists OUTPUT;
        SELECT @object_exists;

	    IF @object_exists = 1
			BEGIN
                -- DETERMINE BACKUP TARGET DATE
                EXEC [ds_sp_etl_data_process_completed_at] @database_name, @schema_name, @table_name, @etl_data_process_completed_at OUTPUT;
			END

		IF (@object_exists = 1 AND @etl_data_process_completed_at IS NOT NULL)
		    SET @config_check_pass=1
		ELSE
		    SET @config_check_pass=0;

		-- Start backup
		IF @config_check_pass = 1
		    BEGIN
			    -- CREATE BACKUP PATH
		        EXEC [ds_sp_arc_prepare_backup_path] @backup_root, @server_name, @database_name, @schema_name, @table_name;
		        
				-- SET target date
		        SET @backup_target_date = DATEADD(HOUR, - @backup_delay_interval_hour, @etl_data_process_completed_at)

		        -- Backup data
		        EXEC [ds_sp_arc_export_table_by_date] @backup_root, @server_name, @database_name, @schema_name, @table_name, @backup_target_date 
		    END
		
		
		IF @config_check_pass = 0
		BEGIN
		    PRINT 'Object does not existed OR DataProcessCompletedAtNotFound'
			GOTO EXIT_ABNORMALLY
		END
			  
		-- arc_logging
		FETCH NEXT FROM arc_table_cursor
        INTO @database_name, @schema_name, @table_name, @date_key, @backup_delay_interval_hour

    END
CLOSE arc_table_cursor;
DEALLOCATE arc_table_cursor;

EXIT_ABNORMALLY:
   IF @config_check_pass = 0
      BEGIN
         CLOSE arc_table_cursor;
         DEALLOCATE arc_table_cursor;
	     RETURN;
      END
      
END
