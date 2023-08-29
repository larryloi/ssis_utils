class DsSpArcPrepareBackupPathChangeVarCmdLength4000 < ActiveRecord::Migration
  def self.up
     execute("DROP PROCEDURE ds_sp_arc_prepare_backup_path;")
     sql_file = Rails.root.join('db/stored_procedure/20190118022207_ds_sp_arc_prepare_backup_path_change_var_cmd_length_4000.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE ds_sp_arc_prepare_backup_path;")
     sql_file = Rails.root.join('db/stored_procedure/20180711021506_create_ds_sp_arc_prepare_backup_path.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end
end
