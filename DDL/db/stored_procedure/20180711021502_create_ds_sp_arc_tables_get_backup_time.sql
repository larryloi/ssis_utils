CREATE PROCEDURE [ds_sp_arc_tables_get_backup_time] (@database_name NVARCHAR(128), @schema_name NVARCHAR(128), @table_name NVARCHAR(128), @date_key NVARCHAR(128) OUTPUT, @backup_batch_interval_hour INT OUTPUT, @backup_data_start_at DATETIME OUTPUT, @backup_data_end_at DATETIME OUTPUT)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql  NVARCHAR(4000)=NULL;
    DECLARE @ParmDefinition NVARCHAR(512) = NULL;

    SET @ParmDefinition = N'@key NVARCHAR(45) OUTPUT, @batch_interval_hour INT OUTPUT, @start_at DATETIME OUTPUT, @end_at DATETIME OUTPUT';
	SET @sql = 
	   'SELECT @key=t.date_key, ' +
	   '@batch_interval_hour=t.backup_batch_interval_hour, ' +
       '@start_at=t.backup_data_start_at, ' +
	   '@end_at=t.backup_data_end_at ' +
       'FROM arc_databases d (nolock) ' + 
       'JOIN arc_tables t (nolock) ON d.id= t.arc_database_id AND d.state=1 AND t.state IN (1,2) ' +
       'WHERE d.name = ' + '''' + @database_name + '''' + ' AND t.schema_name=  ' + '''' +@schema_name + '''' + ' AND t.name=' + '''' + @table_name + ''''

	EXEC sp_executesql @sql, @ParmDefinition, @key=@date_key OUTPUT, @batch_interval_hour=@backup_batch_interval_hour OUTPUT, @start_at=@backup_data_start_at OUTPUT, @end_at=@backup_data_end_at OUTPUT;

END
