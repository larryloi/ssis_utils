class CreateDsSpEtlDataProcessCompletedAt < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20180711021504_create_ds_sp_etl_data_process_completed_at.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE ds_sp_etl_data_process_completed_at;")
  end
end
