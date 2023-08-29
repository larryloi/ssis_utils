class CreateDsSpEtlJobCreate < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20180913065003_create_ds_sp_etl_job_create.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end
  
  def self.down
     execute("DROP PROCEDURE ds_sp_etl_job_create ;")
  end
end
