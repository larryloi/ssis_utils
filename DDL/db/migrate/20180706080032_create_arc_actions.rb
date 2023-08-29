class CreateArcActions < ActiveRecord::Migration
     def self.up
        create_table :arc_actions, :id => false  do |t|
            t.column    :id, "INT NOT NULL IDENTITY(1,1)", :references => nil
            t.string    :name, :limit => 45, null: false
            t.string    :description, :limit => 128, null: false
            t.timestamps null: false
        end

        execute("ALTER TABLE arc_actions ADD CONSTRAINT pk_arc_actions_id PRIMARY KEY (id)")
        execute("ALTER TABLE arc_actions ADD CONSTRAINT uk1_arc_actions_name UNIQUE (name)")
     end

     def self.down
        drop_table :arc_actions
     end

end
