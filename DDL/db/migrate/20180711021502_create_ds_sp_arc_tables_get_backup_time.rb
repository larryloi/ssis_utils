class CreateDsSpArcTablesGetBackupTime < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20180711021502_create_ds_sp_arc_tables_get_backup_time.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE ds_sp_arc_tables_get_backup_time;")
  end
end
