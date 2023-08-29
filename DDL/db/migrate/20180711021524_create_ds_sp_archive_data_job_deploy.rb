class CreateDsSpArchiveDataJobDeploy < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20180711021524_create_ds_sp_archive_data_job_deploy.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE ds_sp_archive_data_job_deploy;")
  end
end
