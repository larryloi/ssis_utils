class CreateDsSpEtlJobSsisConfigList < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20180913065005_create_ds_sp_etl_job_ssis_config_list.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end
  
  def self.down
     execute("DROP PROCEDURE ds_sp_etl_job_ssis_config_list;")
  end
end
