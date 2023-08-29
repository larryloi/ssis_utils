class CreateDsSpArcDeleteTableByDate < ActiveRecord::Migration
  def self.up
     sql_file = Rails.root.join('db/stored_procedure/20180711021522_create_ds_sp_arc_delete_table_by_date.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE ds_sp_arc_delete_table_by_date;")
  end
end
