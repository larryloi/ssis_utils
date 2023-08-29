ALTER PROCEDURE [dbo].[ds_sp_etl_data_process_completed_at] (@database_name NVARCHAR(128), @schema_name NVARCHAR(128), @table_name NVARCHAR(128), @data_process_completed_at DATETIME = NULL OUTPUT)
AS 
BEGIN
SET NOCOUNT ON;
DECLARE @sql NVARCHAR(4000) = NULL;
DECLARE @ParmDefinition nvarchar(512) = NULL;
DECLARE @return_value DATETIME =NULL;
DECLARE @rowcount INT = 0;
SET @ParmDefinition = N'@mtime DATETIME OUTPUT';
SET @sql = N'SELECT @mtime = MIN(etl_table_maps.data_process_completed_at) FROM '+quotename(@database_name)+'.'+quotename(@schema_name)+'.etl_table_maps (nolock) ' + 
           N'JOIN '+ quotename(@database_name)+'.'+quotename(@schema_name)+'.etl_dest_tables ON etl_table_maps.id = etl_dest_tables.etl_table_map_id ' + 
		   N'WHERE etl_dest_tables.table_name=' + '''' + @table_name + '''';
		   
EXECUTE @rowcount = sp_executesql @sql, @ParmDefinition, @mtime=@data_process_completed_at OUTPUT;
    IF @data_process_completed_at IS NULL
       BEGIN
          RAISERROR('DataProcessCompletedAtNotFound',0,1);
          RETURN;
       END
	ELSE
	  BEGIN
	     PRINT ''
	     PRINT 'ETL DATA COMPLETED AT: ' + CONVERT(NVARCHAR(19),@data_process_completed_at,120);
	  END
END
