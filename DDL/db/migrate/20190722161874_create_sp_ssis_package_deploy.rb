class CreateSpSsisPackageDeploy < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20190722161874_create_sp_ssis_package_deploy.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE sp_ssis_package_deploy;")
  end
end
