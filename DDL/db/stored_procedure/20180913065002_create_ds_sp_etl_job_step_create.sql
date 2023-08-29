CREATE PROCEDURE ds_sp_etl_job_step_create (@ENV NVARCHAR(85), @ETL_JOB_ID INT, @JOB_ID BINARY(16))
AS 
BEGIN
    DECLARE @JOB_STEP_ID INT = NULL;
    DECLARE @STEP_NAME NVARCHAR(128) = NULL;
    DECLARE @STEP_ID INT = NULL;
    DECLARE @CMDEXEC_SUCCESS_CODE INT = NULL;
    DECLARE @ON_SUCCESS_ACTION TINYINT = NULL;
    DECLARE @ON_SUCCESS_STEP_ID INT = NULL;
    DECLARE @ON_FAIL_ACTION TINYINT = NULL;
    DECLARE @ON_FAIL_STEP_ID INT = NULL;
    DECLARE @RETRY_ATTEMPTS INT = NULL;
    DECLARE @RETRY_INTERVAL INT = NULL;
    DECLARE @OS_RUN_PRIORITY INT = NULL;
    DECLARE @SUBSYSTEM NVARCHAR(40)=NULL;
    DECLARE @COMMAND NVARCHAR(MAX)=NULL;
    DECLARE @DATABASE_NAME NVARCHAR(85)=NULL;
    DECLARE @FLAGS INT=NULL;
    DECLARE @ETL_TABLE_MAP_ID NVARCHAR(128)=NULL;
    DECLARE @ETL_TABLE_MAP_ID_CHECKLIST NVARCHAR(128)=NULL;
    DECLARE @SSIS_FOLDER NVARCHAR(128)=NULL;
    DECLARE @SSIS_PROJECT NVARCHAR(128)=NULL;
    DECLARE @SSIS_PACKAGE NVARCHAR(128)=NULL;
    DECLARE @TTL_STEPS INT=NULL;
    DECLARE @ReturnCode INT=0;
            
            -- GET TOTAL number of step for the particular job; to determine the last step for assign report success on Success
            SELECT @TTL_STEPS = COUNT(js.id)
			FROM etl_job_steps js (NOLOCK)
            JOIN etl_jobs j (NOLOCK) ON j.id = js.etl_job_id
            WHERE etl_job_id = @ETL_JOB_ID;

            DECLARE etl_job_step_cursor CURSOR FOR
            SELECT  
            js.id, js.name, js.cmdexec_success_code, js.on_success_action, js.on_success_step_id, js.on_fail_action, js.on_fail_step_id
            ,js.retry_attempts, js.retry_interval, js.os_run_priority, js.subsystem, js.command, js.database_name, js.flags
            ,j.ssis_folder, j.ssis_project, js.ssis_package
            FROM etl_job_steps js (NOLOCK)
            JOIN etl_jobs j (NOLOCK) ON j.id = js.etl_job_id
            WHERE etl_job_id = @ETL_JOB_ID ORDER BY js.id;

            OPEN etl_job_step_cursor
            FETCH NEXT FROM etl_job_step_cursor
            INTO @JOB_STEP_ID, @STEP_NAME, @CMDEXEC_SUCCESS_CODE, @ON_SUCCESS_ACTION, @ON_SUCCESS_STEP_ID, @ON_FAIL_ACTION, 
            @ON_FAIL_STEP_ID, @RETRY_ATTEMPTS ,@RETRY_INTERVAL, @OS_RUN_PRIORITY, @SUBSYSTEM, @COMMAND, @DATABASE_NAME, @FLAGS, 
            @SSIS_FOLDER, @SSIS_PROJECT, @SSIS_PACKAGE

            -- INITIAL the first step id
            SET @STEP_ID=1
            
            WHILE @@FETCH_STATUS = 0  
            BEGIN
                    -- To determine the last step for assign report success on Success
                    IF @STEP_ID = @TTL_STEPS
                    BEGIN
                       SET @ON_SUCCESS_ACTION = 1
                    END
                    ELSE
                    BEGIN
                       SET @ON_SUCCESS_ACTION = 3
                    END 
                    
                    
                    PRINT '  - Creating job step: ' + @STEP_NAME
                    SET @SUBSYSTEM = UPPER(@SUBSYSTEM)
                    PRINT '    - Step id: '+ CAST(@STEP_ID AS NVARCHAR(10)) +' - Subsystem: ' + @SUBSYSTEM + ' - ON_SUCCESS_ACTION: ' + CAST(@ON_SUCCESS_ACTION AS NVARCHAR(10));
                    IF @SUBSYSTEM = 'SSIS'
                    BEGIN
                        -- VERIFY @SSIS_PACKAGE EXISTS
                        IF @SSIS_PACKAGE IS NULL
                          BEGIN
                             PRINT '    SSIS_PACKAGE is Null, step name: "' + @STEP_NAME + '", it cannot be Null, PLEASE CHECK THE CONFIG DATA.'
                             GOTO QuitWithRollback
                          END
                          
                        -- GET @SSIS_ENV_REF_ID
                        DECLARE @SSIS_ENV_REF_ID INT=NULL;
                        EXEC [ds_sp_etl_job_ssis_config_check] @ENV, @SSIS_FOLDER, @SSIS_PROJECT, @SSIS_ENV_REF_ID OUTPUT

                        -- COMPOSE SSIS parameters
                        DECLARE @param NVARCHAR(128)=NULL;
                        DECLARE @value NVARCHAR(128)=NULL;
                        DECLARE @ssis_params NVARCHAR(1024)='';
                        DECLARE etl_job_step_param_cursor CURSOR FOR
                        SELECT parameter, [value] from etl_job_step_params 
                        WHERE etl_job_step_id=@JOB_STEP_ID

                        OPEN etl_job_step_param_cursor
                        FETCH NEXT FROM etl_job_step_param_cursor INTO @param, @value
            
                        WHILE @@FETCH_STATUS = 0  
                        BEGIN
                           SET @ssis_params = @ssis_params + '/Par "\"' + @param + '\"";' + @value + ' '

                           FETCH NEXT FROM etl_job_step_param_cursor INTO @param, @value
                        END
                        CLOSE etl_job_step_param_cursor;
                        DEALLOCATE etl_job_step_param_cursor;


                        SET @COMMAND = N'/ISSERVER "\"\SSISDB\' + @SSIS_FOLDER + N'\' + @SSIS_PROJECT + N'\' + @SSIS_PACKAGE + N'\"" /SERVER "\"' + @@SERVERNAME + N'\"" /ENVREFERENCE ' + CAST(@SSIS_ENV_REF_ID AS NVARCHAR(10)) + ' ' + @ssis_params + N' /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";0 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'
                        
                        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@JOB_ID, @step_name=@STEP_NAME, 
                        @step_id=@STEP_ID, 
                        @cmdexec_success_code=@CMDEXEC_SUCCESS_CODE, 
                        @on_success_action=@ON_SUCCESS_ACTION, 
                        @on_success_step_id=@ON_SUCCESS_STEP_ID, 
                        @on_fail_action=@ON_FAIL_ACTION, 
                        @on_fail_step_id=@ON_FAIL_STEP_ID, 
                        @retry_attempts=@RETRY_ATTEMPTS, 
                        @retry_interval=@RETRY_INTERVAL, 
                        @os_run_priority=@OS_RUN_PRIORITY, 
                        @subsystem=@SUBSYSTEM, 
                        @command=@COMMAND, 
                        @database_name=@DATABASE_NAME, 
                        @flags=0
                        IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
                    END
                    ELSE IF @SUBSYSTEM = 'TSQL'
                    BEGIN
                        EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@JOB_ID, @step_name=@STEP_NAME, 
                        @step_id=@STEP_ID, 
                        @cmdexec_success_code=@CMDEXEC_SUCCESS_CODE, 
                        @on_success_action=@ON_SUCCESS_ACTION, 
                        @on_success_step_id=@ON_SUCCESS_STEP_ID, 
                        @on_fail_action=@ON_FAIL_ACTION, 
                        @on_fail_step_id=@ON_FAIL_STEP_ID, 
                        @retry_attempts=@RETRY_ATTEMPTS, 
                        @retry_interval=@RETRY_INTERVAL, 
                        @os_run_priority=@OS_RUN_PRIORITY, 
                        @subsystem=@SUBSYSTEM, 
                        @command=@COMMAND, 
                        @database_name=@DATABASE_NAME, 
                        @flags=0
                        IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
                    END
                    
                    PRINT '    - Created. ';
                    
                    SET @STEP_ID = @STEP_ID + 1;
                    FETCH NEXT FROM etl_job_step_cursor
                    INTO @JOB_STEP_ID, @STEP_NAME, @CMDEXEC_SUCCESS_CODE, @ON_SUCCESS_ACTION, @ON_SUCCESS_STEP_ID, @ON_FAIL_ACTION, 
                    @ON_FAIL_STEP_ID, @RETRY_ATTEMPTS ,@RETRY_INTERVAL, @OS_RUN_PRIORITY, @SUBSYSTEM, @COMMAND, @DATABASE_NAME, @FLAGS, 
                    @SSIS_FOLDER, @SSIS_PROJECT, @SSIS_PACKAGE
            END

            CLOSE etl_job_step_cursor;
            DEALLOCATE etl_job_step_cursor;
            
            GOTO EndSave
            QuitWithRollback:
            RETURN (1)
            EndSave:

END
