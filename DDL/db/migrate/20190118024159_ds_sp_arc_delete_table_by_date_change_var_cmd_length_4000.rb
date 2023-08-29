class DsSpArcDeleteTableByDateChangeVarCmdLength4000 < ActiveRecord::Migration
  def self.up
     execute("DROP PROCEDURE ds_sp_arc_delete_table_by_date;")
     sql_file = Rails.root.join('db/stored_procedure/20190118024159_ds_sp_arc_delete_table_by_date_change_var_cmd_length_4000.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end

  def self.down
     execute("DROP PROCEDURE ds_sp_arc_delete_table_by_date;")
     sql_file = Rails.root.join('db/stored_procedure/20180711021522_create_ds_sp_arc_delete_table_by_date.sql')
     sqlstatement = File.read(sql_file)
     execute(sqlstatement)
  end
end
