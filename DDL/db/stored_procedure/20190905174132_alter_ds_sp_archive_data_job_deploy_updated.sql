ALTER PROCEDURE [dbo].[ds_sp_archive_data_job_deploy] (@ENV NVARCHAR(85))
AS BEGIN

    --DECLARE @ENV NVARCHAR(45) = 'staging0';
    DECLARE @CATEGROY_NAME NVARCHAR(85) = '_Data_Maintenance';
    DECLARE @JOB_NAME NVARCHAR(85) = '_Archive_Data';
    DECLARE @OWNER_LOGIN_NAME NVARCHAR(85) = 'ssis';
    DECLARE @DATABASE_NAME NVARCHAR(85) = 'ssis_utils_';
    DECLARE @SCHEDULE_UID NVARCHAR(36) = NEWID();

    SET @CATEGROY_NAME = @ENV +  @CATEGROY_NAME;
    SET @JOB_NAME = @ENV +  @JOB_NAME;
    SET @DATABASE_NAME = @DATABASE_NAME + @ENV;

    BEGIN TRANSACTION
    DECLARE @ReturnCode INT
    SELECT @ReturnCode = 0

    IF EXISTS (SELECT name FROM msdb.dbo.sysjobs WHERE name=@JOB_NAME)
       BEGIN
         EXEC @ReturnCode=msdb.dbo.sp_delete_job  @job_name = @JOB_NAME;
         IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
       END

    IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@CATEGROY_NAME AND category_class=1)
    BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@CATEGROY_NAME
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    END

    DECLARE @jobId BINARY(16)
    EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@JOB_NAME, 
            @enabled=0, 
            @notify_level_eventlog=0, 
            @notify_level_email=0, 
            @notify_level_netsend=0, 
            @notify_level_page=0, 
            @delete_level=0, 
            @description=@JOB_NAME, 
            @category_name=@CATEGROY_NAME, 
            @owner_login_name=@OWNER_LOGIN_NAME, @job_id = @jobId OUTPUT
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ds_sp_arc_backup', 
            @step_id=1, 
            @cmdexec_success_code=0, 
            @on_success_action=3, 
            @on_success_step_id=0, 
            @on_fail_action=2, 
            @on_fail_step_id=0, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, @subsystem=N'TSQL', 
            @command=N'EXEC ds_sp_arc_backup', 
            @database_name=@DATABASE_NAME, 
            @flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ds_sp_arc_delete', 
            @step_id=2, 
            @cmdexec_success_code=0, 
            @on_success_action=3, 
            @on_success_step_id=0, 
            @on_fail_action=2, 
            @on_fail_step_id=0, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, @subsystem=N'TSQL', 
            @command=N'EXEC ds_sp_arc_delete', 
            @database_name=@DATABASE_NAME, 
            @flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'archive_data_backup_check_delay', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [sp_archive_data_backup_check_delay]', 
		@database_name=@DATABASE_NAME, 
		@flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=@JOB_NAME, 
            @enabled=1, 
            @freq_type=4, 
            @freq_interval=1, 
            @freq_subday_type=8, 
            @freq_subday_interval=1, 
            @freq_relative_interval=0, 
            @freq_recurrence_factor=0, 
            @active_start_date=20181010, 
            @active_end_date=99991231, 
            @active_start_time=700, 
            @active_end_time=235959, 
            @schedule_uid=@SCHEDULE_UID
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    COMMIT TRANSACTION
    GOTO EndSave
    QuitWithRollback:
        IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    EndSave:

END
