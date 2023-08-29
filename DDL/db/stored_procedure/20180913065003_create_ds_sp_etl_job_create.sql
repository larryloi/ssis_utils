CREATE PROCEDURE ds_sp_etl_job_create (@ENV NVARCHAR(85), @SSIS_FOLDER NVARCHAR(85), @SSIS_PROJECT NVARCHAR(85))
AS 
BEGIN
    DECLARE @JOB_ID BINARY(16) = NULL;
    DECLARE @ETL_JOB_ID INT = NULL;
    DECLARE @JOB_NAME NVARCHAR(85) = NULL;
    DECLARE @J_ENABLED INT = NULL;
    DECLARE @NOTIFY_LEVEL_EVENTLOG INT = NULL;
    DECLARE @NOTIFY_LEVEL_EMAIL INT = NULL;
    DECLARE @NOTIFY_LEVEL_NETSEND INT = NULL;
    DECLARE @NOTIFY_LEVEL_PAGE INT = NULL;
    DECLARE @DELETE_LEVEL INT = NULL;
    DECLARE @DESCRIPTION NVARCHAR(512) = NULL;
    DECLARE @CATEGORY_NAME NVARCHAR(85) = NULL;
    DECLARE @OWNER_LOGIN_NAME NVARCHAR(85) = NULL;
    DECLARE @S_ENABLED INT = NULL; 
    DECLARE @FREQ_TYPE INT = NULL;
    DECLARE @FREQ_INTERVAL INT = NULL;
    DECLARE @FREQ_SUBDAY_TYPE INT = NULL;
    DECLARE @FREQ_SUBDAY_INTERVAL INT = NULL;
    DECLARE @FREQ_RELATIVE_INTERVAL INT = NULL;
    DECLARE @FREQ_RECURRENCE_FACTOR INT = NULL;
    DECLARE @ACTIVE_START_DATE INT = NULL;
    DECLARE @ACTIVE_END_DATE INT = NULL;
    DECLARE @ACTIVE_START_TIME INT = NULL;
    DECLARE @ACTIVE_END_TIME INT = NULL;
    DECLARE @SCHEDULE_UID NVARCHAR(36) = NULL;
    DECLARE @ReturnCode INT=0;
    
    
    DECLARE etl_job_cursor CURSOR FOR
    SELECT j.id, j.name, j.enabled, j.notify_level_eventlog, j.notify_level_email, j.notify_level_netsend, j.notify_level_page, 
          j.delete_level, j.description, j.category_name, j.owner_login_name,
          s.enabled, s.freq_type, s.freq_interval, s.freq_subday_type, s.freq_subday_interval, s.freq_relative_interval, s.freq_recurrence_factor,
          s.active_start_date, s.active_end_date, s.active_start_time, s.active_end_time
    FROM etl_jobs j (NOLOCK)
    LEFT JOIN etl_job_schedules s (NOLOCK) ON j.id=s.etl_job_id
    WHERE j.ssis_folder=@SSIS_FOLDER AND j.ssis_project=@SSIS_PROJECT
    OPEN etl_job_cursor
    FETCH NEXT FROM etl_job_cursor 
    INTO @ETL_JOB_ID, @JOB_NAME, @J_ENABLED, @NOTIFY_LEVEL_EVENTLOG, @NOTIFY_LEVEL_EMAIL, @NOTIFY_LEVEL_NETSEND, @NOTIFY_LEVEL_PAGE, 
         @DELETE_LEVEL, @DESCRIPTION, @CATEGORY_NAME, @OWNER_LOGIN_NAME,
         @S_ENABLED, @FREQ_TYPE, @FREQ_INTERVAL, @FREQ_SUBDAY_TYPE, @FREQ_SUBDAY_INTERVAL, @FREQ_RELATIVE_INTERVAL, @FREQ_RECURRENCE_FACTOR,
         @ACTIVE_START_DATE, @ACTIVE_END_DATE, @ACTIVE_START_TIME, @ACTIVE_END_TIME;


    WHILE @@FETCH_STATUS = 0  
    BEGIN 
        
        BEGIN TRANSACTION
            SET @CATEGORY_NAME=@ENV+'_'+@CATEGORY_NAME;
            IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@CATEGORY_NAME AND category_class=1)
               BEGIN
                  EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@CATEGORY_NAME
                  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
               END
            PRINT '';
            PRINT '========================================================================';
            PRINT 'Category: ' + @CATEGORY_NAME
            PRINT '';

            --- Remove job
            SET @JOB_ID=NULL;
            SET @JOB_NAME=@ENV+'_'+@JOB_NAME;
            IF EXISTS (SELECT name FROM msdb.dbo.sysjobs WHERE name=@JOB_NAME)
               BEGIN
                  PRINT '- Job existed: ' + @JOB_NAME
                  PRINT '- Deleting job: ' + @JOB_NAME
                  EXEC @ReturnCode=msdb.dbo.sp_delete_job  @job_name = @JOB_NAME; 
                  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
               END
            ELSE
               BEGIN
                  PRINT '- Job does not existed: ' + @JOB_NAME
               END

            PRINT '- Creating job: ' + @JOB_NAME
            EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@JOB_NAME, 
                @enabled=@J_ENABLED, 
                @notify_level_eventlog=@NOTIFY_LEVEL_EVENTLOG, 
                @notify_level_email=@NOTIFY_LEVEL_EMAIL, 
                @notify_level_netsend=@NOTIFY_LEVEL_NETSEND, 
                @notify_level_page=@NOTIFY_LEVEL_PAGE, 
                @delete_level=@DELETE_LEVEL, 
                @description=@DESCRIPTION, 
                @category_name=@CATEGORY_NAME, 
                @owner_login_name=@OWNER_LOGIN_NAME, @job_id = @JOB_ID OUTPUT
            IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
            PRINT '  - Done.';

            -- CREATE JOB STEPS
            EXEC @ReturnCode = ds_sp_etl_job_step_check @ETL_JOB_ID
            IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
               BEGIN
                  PRINT 'No job steps defined OR default database does not exist, @JOB_NAME: ' + @JOB_NAME
                  PRINT 'Skip job steps creation...'
                  GOTO QuitWithRollback
               END
            ELSE
               BEGIN
                  PRINT '';
                  EXEC @ReturnCode = ds_sp_etl_job_step_create @ENV, @ETL_JOB_ID, @JOB_ID
                  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
                  PRINT '';
               END

            -- SET Start steps id
            EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @JOB_ID, @start_step_id = 1
            IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

            -- SET JOB SCHEDULE
            SET @SCHEDULE_UID=NEWID();
            EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@JOB_ID, @name=@JOB_NAME, 
                   @enabled=@S_ENABLED,
                   @freq_type=@FREQ_TYPE,
                   @freq_interval=@FREQ_INTERVAL,
                   @freq_subday_type=@FREQ_SUBDAY_TYPE,
                   @freq_subday_interval=@FREQ_SUBDAY_INTERVAL,
                   @freq_relative_interval=@FREQ_RELATIVE_INTERVAL,
                   @freq_recurrence_factor=@FREQ_RECURRENCE_FACTOR,
                   @active_start_date=@ACTIVE_START_DATE,
                   @active_end_date=@ACTIVE_END_DATE,
                   @active_start_time=@ACTIVE_START_TIME,
                   @active_end_time=@ACTIVE_END_TIME,
                   @schedule_uid=@SCHEDULE_UID
            IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
            PRINT '- Created job schedule for job: ' + @JOB_NAME

            EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JOB_ID, @server_name = N'(local)'
            IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
            PRINT '- Added job into job server.'

        COMMIT TRANSACTION

        PRINT '========================================================================';
        PRINT '';
        
        FETCH NEXT FROM etl_job_cursor 
        INTO @ETL_JOB_ID, @JOB_NAME, @J_ENABLED, @NOTIFY_LEVEL_EVENTLOG, @NOTIFY_LEVEL_EMAIL, @NOTIFY_LEVEL_NETSEND, @NOTIFY_LEVEL_PAGE, 
        @DELETE_LEVEL, @DESCRIPTION, @CATEGORY_NAME, @OWNER_LOGIN_NAME,
        @S_ENABLED, @FREQ_TYPE, @FREQ_INTERVAL, @FREQ_SUBDAY_TYPE, @FREQ_SUBDAY_INTERVAL, @FREQ_RELATIVE_INTERVAL, @FREQ_RECURRENCE_FACTOR,
        @ACTIVE_START_DATE, @ACTIVE_END_DATE, @ACTIVE_START_TIME, @ACTIVE_END_TIME;
        
    END

    CLOSE etl_job_cursor;  
    DEALLOCATE etl_job_cursor;  

    GOTO EndSave
    QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION  
       CLOSE etl_job_cursor;  
       DEALLOCATE etl_job_cursor; 
    EndSave:
END
