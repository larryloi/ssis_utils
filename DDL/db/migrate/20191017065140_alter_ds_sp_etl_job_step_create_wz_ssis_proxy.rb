class AlterDsSpEtlJobStepCreateWzSsisProxy < ActiveRecord::Migration
  def self.up
     execute("IF OBJECT_ID('ds_sp_etl_job_step_create', 'P') IS NOT NULL DROP PROCEDURE ds_sp_etl_job_step_create;")
     sql_file = Rails.root.join('db/stored_procedure/20191017065140_alter_ds_sp_etl_job_step_create_wz_ssis_proxy.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("IF OBJECT_ID('ds_sp_etl_job_step_create', 'P') IS NOT NULL DROP PROCEDURE ds_sp_etl_job_step_create;")
     sql_file = Rails.root.join('db/stored_procedure/20180913065002_create_ds_sp_etl_job_step_create.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end
end
