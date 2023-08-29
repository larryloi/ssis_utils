class CreateSpArchiveDataBackupCheckDelay < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20190905173469_create_sp_archive_data_backup_check_delay.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE sp_archive_data_backup_check_delay;")
  end
end
