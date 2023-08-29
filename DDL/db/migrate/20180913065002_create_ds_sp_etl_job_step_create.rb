class CreateDsSpEtlJobStepCreate < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20180913065002_create_ds_sp_etl_job_step_create.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end
  
  def self.down
     execute("DROP PROCEDURE ds_sp_etl_job_step_create;")
  end
end
