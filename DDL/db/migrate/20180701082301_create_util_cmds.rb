class CreateUtilCmds < ActiveRecord::Migration
  def self.up
    create_table :util_cmds, :id => false do |t|
      t.column :id, "INT NOT NULL IDENTITY(1,1)"
      t.string :name, :limit => 85, null: false
      t.string :description, :limit => 512, null: false
      t.column :cmd_text, "NTEXT NOT NULL"
      t.timestamps null: false
    end

    add_index :util_cmds, [:name], :unique =>true, :name=>'uk_util_cmds_name'
  end
  def self.down
    drop_table :util_cmds
  end
end
