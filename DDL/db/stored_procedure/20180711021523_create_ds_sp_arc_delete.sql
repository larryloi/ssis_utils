CREATE PROCEDURE ds_sp_arc_delete
AS 
BEGIN

DECLARE @server_name NVARCHAR(128) = REPLACE(@@SERVERNAME,'\','$');
DECLARE @feature NVARCHAR(45) = NULL;
DECLARE @parameter NVARCHAR(128) = NULL;
DECLARE @os_cmd NVARCHAR(4000) = NULL;


--    Get configuration
DECLARE @base_database NVARCHAR(218) = DB_NAME();
DECLARE @database_name NVARCHAR(128) = NULL;
DECLARE @schema_name NVARCHAR(128) = NULL;
DECLARE @table_name NVARCHAR(128) = NULL;
DECLARE @date_key NVARCHAR(128) = NULL;
DECLARE @delete_batch_interval_hour INT = NULL;
DECLARE @delete_delay_interval_day INT = NULL;



DECLARE arc_table_cursor CURSOR FOR
SELECT d.name AS database_name, t.schema_name, t.name AS table_name, t.date_key, t.delete_delay_interval_day
FROM arc_databases d (nolock)
JOIN arc_tables t (nolock) ON d.id= t.arc_database_id AND d.state=1 AND t.state IN (2,3)
ORDER BY d.id, t.id;
-- arc_tables.state (1 - backup enabled only, 2 - backup and delete enabled, 3 - delete enabled only)

OPEN arc_table_cursor;

FETCH NEXT FROM arc_table_cursor
INTO @database_name, @schema_name, @table_name, @date_key, @delete_delay_interval_day


WHILE @@FETCH_STATUS = 0  
    BEGIN

        DECLARE @sql NVARCHAR(4000) = NULL;
        DECLARE @delete_target_date DATETIME = NULL;
        DECLARE @etl_data_process_completed_at DATETIME = NULL;
        DECLARE @object_exists TINYINT = 0;
        DECLARE @config_check_pass TINYINT = NULL;

        -- CHECK OBJECT EXISTS
        EXEC [ds_sp_check_object_exists] @database_name, @schema_name, @table_name, @date_key, @object_exists OUTPUT;
        SELECT @object_exists;

/*        IF @object_exists = 1
            BEGIN
                -- DETERMINE DELETE TARGET DATE
                EXEC [ds_sp_etl_data_process_completed_at] @database_name, @schema_name, @table_name, @etl_data_process_completed_at OUTPUT;
            END
*/
--        IF (@object_exists = 1 AND @etl_data_process_completed_at IS NOT NULL)
        IF (@object_exists = 1 )
            SET @config_check_pass=1
        ELSE
            SET @config_check_pass=0;

        -- Start delete
        IF @config_check_pass = 1
            BEGIN
                -- SET target date
                SET @delete_target_date = DATEADD(hh, DATEDIFF(hh, 0, DATEADD(DAY, - @delete_delay_interval_day, GETUTCDATE())), 0)

                -- delete data
                EXEC [ds_sp_arc_delete_table_by_date] @database_name, @schema_name, @table_name, @delete_target_date 
            END
        
        
        IF @config_check_pass = 0
        BEGIN
--            PRINT 'Object does not existed OR DataProcessCompletedAtNotFound'
            PRINT 'Object does not existed.'
            GOTO EXIT_ABNORMALLY
        END
              
        -- arc_logging
        FETCH NEXT FROM arc_table_cursor
        INTO @database_name, @schema_name, @table_name, @date_key, @delete_delay_interval_day

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

