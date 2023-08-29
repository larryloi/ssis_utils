CREATE PROCEDURE ds_sp_etl_job_step_check (@ETL_JOB_ID INT)
AS
BEGIN
   DECLARE @STEP_CNT INT=0;
    
   SELECT @STEP_CNT = COUNT(js.name)
   FROM etl_job_steps js (NOLOCK)
   WHERE js.etl_job_id = @ETL_JOB_ID;
    --PRINT '>>>'
    --PRINT @STEP_CNT
    IF @STEP_CNT = 0
       BEGIN
          PRINT 'No job steps defined @ETL_JOB_ID: ' + CAST(@ETL_JOB_ID AS NVARCHAR(10))
          RETURN (1)
       END

    -- CREATE DATABASE EXISTED
    DECLARE @DBNAME NVARCHAR(128);
    DECLARE dbname_cursor CURSOR FOR
    SELECT DISTINCT database_name
    FROM etl_job_steps js (NOLOCK)
    WHERE js.etl_job_id = @ETL_JOB_ID;

    OPEN dbname_cursor
    FETCH NEXT FROM dbname_cursor
    INTO @DBNAME

    WHILE @@FETCH_STATUS = 0  
    BEGIN
       IF db_id(@DBNAME) IS NULL
          BEGIN
              PRINT 'Database: "' + @DBNAME + '" Does not existed, PLEASE CHECK THE CONFIG DATA.'
              RETURN (1)
          END
       FETCH NEXT FROM dbname_cursor
       INTO @DBNAME
    END
    CLOSE dbname_cursor;
    DEALLOCATE dbname_cursor;
END
