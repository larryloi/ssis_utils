CREATE PROCEDURE ds_sp_etl_job_ssis_config_check ( @ENV NVARCHAR(85), @SSIS_FOLDER NVARCHAR(85), @SSIS_PROJECT NVARCHAR(85), @SSIS_ENV_REF_ID INT OUTPUT)
AS
BEGIN
        IF @ENV IS NULL
        RAISERROR('Null values not allowed for @ENV', 16, 1); 
        IF @SSIS_FOLDER IS NULL
        RAISERROR('Null values not allowed for @SSIS_FOLDER', 16, 1);
        IF @SSIS_PROJECT IS NULL
        RAISERROR('Null values not allowed for @SSIS_PROJECT', 16, 1);

        IF @ENV IS NOT NULL AND @SSIS_FOLDER IS NOT NULL AND @SSIS_PROJECT IS NOT NULL
        BEGIN
            IF NOT EXISTS 
               (SELECT name FROM SSISDB.[catalog].folders (NOLOCK) WHERE name=@SSIS_FOLDER)
            BEGIN
               RAISERROR('SSIS folder "%s" Does not existed.', 16, 1, @SSIS_FOLDER);
               RETURN;
            END

            IF NOT EXISTS 
               (SELECT * FROM SSISDB.[catalog].projects p
                JOIN SSISDB.[catalog].folders f ON p.folder_id = f.folder_id
                WHERE f.name=@SSIS_FOLDER AND p.name=@SSIS_PROJECT)
            BEGIN
               RAISERROR('SSIS project "%s" Does not existed.', 16, 1, @SSIS_PROJECT)
               RETURN;
            END
            
            SELECT @SSIS_ENV_REF_ID = reference_id 
            FROM SSISDB.[catalog].environment_references er 
            JOIN SSISDB.[catalog].projects p ON p.project_id = er.project_id
            WHERE er.environment_folder_name = @SSIS_FOLDER AND er.environment_name = @ENV AND p.name = @SSIS_PROJECT
            IF @SSIS_ENV_REF_ID IS NULL
            BEGIN
               RAISERROR('SSIS environment "%s" Does not existed.', 16, 1, @ENV)
               RETURN;
            END;
            ELSE 
            BEGIN
               RETURN @SSIS_ENV_REF_ID;
            END
        END;
END
;
