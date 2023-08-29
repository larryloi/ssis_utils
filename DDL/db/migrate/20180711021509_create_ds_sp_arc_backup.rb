class CreateDsSpArcBackup < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20180711021509_create_ds_sp_arc_backup.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE ds_sp_arc_backup;")
  end
end
