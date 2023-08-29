class AlterDsSpArchiveDataJobDeployUpdated < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20190905174132_alter_ds_sp_archive_data_job_deploy_updated.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end
	def self.down
	 sql_file = Rails.root.join('db/stored_procedure/20190905173921_alter_ds_sp_archive_data_job_deploy_original.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
	end
end