class DsSpOsCmdChangeVarCmdLength4000 < ActiveRecord::Migration
  def self.up
    execute("DROP PROCEDURE ds_sp_os_cmd;")
    sql_file = Rails.root.join('db/stored_procedure/20190118015817_ds_sp_os_cmd_change_var_cmd_length_4000.sql')
    sqlstatement = File.read(sql_file)
    execute(sqlstatement)
  end

  def self.down
    execute("DROP PROCEDURE ds_sp_os_cmd;")
    sql_file = Rails.root.join('db/stored_procedure/20180711021505_create_ds_sp_os_cmd.sql')
    sqlstatement = File.read(sql_file)
    execute(sqlstatement)
  end
end
