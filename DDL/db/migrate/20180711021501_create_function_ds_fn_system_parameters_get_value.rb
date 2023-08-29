class CreateFunctionDsFnSystemParametersGetValue < ActiveRecord::Migration
  def self.up
    execute ("
CREATE FUNCTION ds_fn_system_parameters_get_value ( @feature NVARCHAR(45), @parameter NVARCHAR(128))
RETURNS NVARCHAR(512)
AS
BEGIN
  DECLARE @return_value NVARCHAR(512);
 SELECT @return_value = [value]
  FROM system_parameters
  WHERE feature=@feature
  AND parameter=@parameter;
  RETURN @return_value
END;
    ")
  end

  def self.down
    execute ("
DROP FUNCTION ds_fn_system_parameters_get_value
    ")
  end
end
