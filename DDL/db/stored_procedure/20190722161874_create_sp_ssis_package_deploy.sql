CREATE PROCEDURE sp_ssis_package_deploy (@ssis_folder_name varchar(128),@ssis_project_name varchar(128),@tag_version varchar(128))
AS
BEGIN
DECLARE @ProjectBinary AS varbinary(max)
DECLARE @operation_id AS bigint
DECLARE @deploy_full_path AS varchar(MAX)
DECLARE @command nvarchar(MAX)
DECLARE @deploy_path nvarchar(max)
DECLARE @temp_binary table (
BulkColumn varbinary(max)
)

--Get deploy path
SELECT @deploy_path=value from system_parameters where parameter='deploy_path'
SET @deploy_full_path =@deploy_path+'\'+@ssis_folder_name+'\'+@tag_version+'\'+@ssis_project_name+'.ispac'

--Get the binary
SET @command=N'(SELECT BulkColumn FROM OPENROWSET(BULK ''' + @deploy_full_path + ''', SINGLE_BLOB) AS BinaryData)'
INSERT INTO @temp_binary EXEC sp_executesql @command, N'@ProjectBinary_out varbinary(max) OUT', @ProjectBinary_out = @ProjectBinary OUT
SELECT @ProjectBinary=BulkColumn FROM @temp_binary

--Main
EXEC SSISDB.catalog.deploy_project @folder_name = @ssis_folder_name,
    @project_name = @ssis_project_name,
    @Project_Stream = @ProjectBinary,
    @operation_id = @operation_id out
END
