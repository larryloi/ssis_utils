class CreateSystemParameters < ActiveRecord::Migration
  def self.up
    create_table :system_parameters, :id => false do |t|
      t.column :id, "INT NOT NULL IDENTITY(1,1)"
      t.string :feature, :limit => 45, null: false
      t.string :parameter, :limit => 128, null: false
      t.string :value, :limit => 512, null: false
      t.string :description, :limit => 512, null: false
      t.timestamps null: false
    end
    execute("ALTER TABLE system_parameters ADD CONSTRAINT pk_system_parameters_id PRIMARY KEY (id)")
    execute("ALTER TABLE system_parameters ADD CONSTRAINT uk1_system_parameters_feature_parameter UNIQUE (feature, parameter)")
  end
  def self.down
    drop_table :system_parameters
  end
end
