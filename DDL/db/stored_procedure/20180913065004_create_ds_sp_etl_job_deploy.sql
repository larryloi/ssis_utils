CREATE PROCEDURE ds_sp_etl_job_deploy (@ENV NVARCHAR(85), @SSIS_FOLDER NVARCHAR(85), @SSIS_PROJECT NVARCHAR(85))
AS 
BEGIN

    PRINT ''
    DECLARE @SSIS_ENV_REF_ID INT = NULL;
    --- Check SSIS configs
    EXEC [ds_sp_etl_job_ssis_config_check] @ENV, @SSIS_FOLDER, @SSIS_PROJECT, @SSIS_ENV_REF_ID OUTPUT
    IF (@@ERROR <> 0) 
       BEGIN
          PRINT 'Exit...'
          GOTO EndSave
       END

    DECLARE @ReturnCode INT=0;

    EXEC @ReturnCode = ds_sp_etl_job_create @ENV, @SSIS_FOLDER, @SSIS_PROJECT
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

GOTO EndSave
QuitWithRollback:
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION  
EndSave:

END
