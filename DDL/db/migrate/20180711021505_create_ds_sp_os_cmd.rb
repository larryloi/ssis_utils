class CreateDsSpOsCmd < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20180711021505_create_ds_sp_os_cmd.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE ds_sp_os_cmd;")
  end
end
