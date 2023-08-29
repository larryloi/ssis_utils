CREATE PROCEDURE ds_sp_check_object_exists (@database_name NVARCHAR(128), @schema_name NVARCHAR(128), @table_name NVARCHAR(128), @date_key NVARCHAR(128), @object_exists TINYINT OUTPUT)
AS
BEGIN
    DECLARE @target_database_exists INT = 0;
	DECLARE @target_schema_exists INT = 0;
    DECLARE @target_table_exists INT = 0;
    DECLARE @target_column_exists INT = 0;
	DECLARE @sql NVARCHAR(4000) = NULL;

	    -- CHECK DATABASE EXISTS
		-- PRINT db_name();
	    IF db_id(@database_name) IS NOT NULL
		BEGIN
		    SET @target_database_exists = 1;

			-- CHECK SCHEMA EXISTS
            SET @sql = 'SELECT @cnt=COUNT(1) FROM ' + QUOTENAME(@database_name) + '.[INFORMATION_SCHEMA].[SCHEMATA] (nolock) ' + 
			           ' WHERE CATALOG_NAME=N'+'''' + @database_name + '''' + ' AND SCHEMA_NAME=N' + '''' + @schema_name + '''' ; 

            EXEC sp_executesql @sql, N'@cnt INT OUTPUT', @cnt=@target_schema_exists OUTPUT;


			-- CHECK TABLE EXISTS
			IF @target_schema_exists = 1
			BEGIN
               SET @sql = 'SELECT @cnt=COUNT(1) FROM ' + QUOTENAME(@database_name) + '.[INFORMATION_SCHEMA].[TABLES] (nolock) ' + 
			              ' WHERE TABLE_CATALOG=N'+'''' + @database_name + '''' + ' AND TABLE_SCHEMA=N' + '''' + @schema_name + '''' + 
					      ' AND TABLE_NAME=N' + '''' + @table_name + '''';

               EXEC sp_executesql @sql, N'@cnt INT OUTPUT', @cnt=@target_table_exists OUTPUT;
			END

            -- CHECK COLUMN EXISTS
			IF @target_table_exists = 1
			BEGIN
                SET @sql = 'SELECT @cnt=COUNT(1) FROM ' + QUOTENAME(@database_name) + '.[INFORMATION_SCHEMA].[COLUMNS] (nolock) ' + 
				           ' WHERE TABLE_CATALOG=N'+'''' + @database_name + '''' + ' AND TABLE_SCHEMA=N' + '''' + @schema_name + '''' + 
						   ' AND TABLE_NAME=N' + '''' + @table_name + '''' + ' AND COLUMN_NAME=N' + '''' + @date_key + '''';

                EXEC sp_executesql @sql, N'@cnt INT OUTPUT', @cnt=@target_column_exists OUTPUT;
			END

		END ;
		
		IF (@target_database_exists = 1 AND @target_schema_exists = 1 AND @target_table_exists =1 AND @target_column_exists=1 )
		    SET  @object_exists = 1
		ELSE
		    SET  @object_exists = 0;

		PRINT ''
        PRINT 'OBJECT:   ' + @database_name +'.'+ @schema_name +'.'+ @table_name+'.'+ @date_key
		PRINT 'DATABASE: ' + CONVERT(NVARCHAR(1),@target_database_exists)
		PRINT 'SCHEMA:   ' + CONVERT(NVARCHAR(1),@target_schema_exists)
		PRINT 'TABLE:    ' + CONVERT(NVARCHAR(1),@target_table_exists)
		PRINT 'COLUMN    ' + CONVERT(NVARCHAR(1),@target_column_exists) 

END
