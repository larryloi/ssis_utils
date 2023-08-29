CREATE PROCEDURE ds_sp_etl_job_ssis_config_list (@ENV NVARCHAR(85))
AS
BEGIN
SELECT LEFT(e.environment_folder_name, 45) AS ssis_folder, LEFT(p.name,45) AS ssis_project
FROM SSISDB.[catalog].environment_references e
JOIN SSISDB.[catalog].projects p ON p.project_id = e.project_id
WHERE e.environment_name = @ENV
END;
