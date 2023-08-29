CREATE PROCEDURE ds_sp_arc_logs_insert (@job_id VARCHAR(36), @database_name VARCHAR(128), @schema_name VARCHAR(128), @table_name VARCHAR(128), @arc_action VARCHAR(45), @state VARCHAR(45), @data_start_at DATETIME, @data_end_at DATETIME, @message VARCHAR(4000))
AS
    BEGIN
    INSERT INTO arc_logs 
    (job_id, arc_database_name, schema_name, arc_table_name, arc_action, state, data_start_at, data_end_at, logged_at, message)
    VALUES
    (@job_id, @database_name, @schema_name, @table_name, @arc_action, @state, @data_start_at, @data_end_at, GETUTCDATE(), @message);

END
