class AlterSpEtlDataProcessCompletedAtUpdated < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20190704154723_alter_sp_etl_data_process_completed_at_updated.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end
	def self.down
	 sql_file = Rails.root.join('db/stored_procedure/20190704154956_alter_sp_etl_data_process_completed_at_original.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
	end
end	