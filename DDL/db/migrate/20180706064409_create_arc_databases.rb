class CreateArcDatabases < ActiveRecord::Migration
    def self.up
        create_table :arc_databases, :id => false  do |t|
            t.column    :id, "INT NOT NULL IDENTITY(1,1)", :references => nil
            t.string    :name, :limit => 128, null: false
            t.integer   :state, null: false
            t.timestamps null: false
        end
        execute("ALTER TABLE arc_databases ADD CONSTRAINT pk_arc_database_id PRIMARY KEY (id)")
        execute("ALTER TABLE arc_databases ADD CONSTRAINT uk1_arc_database_name UNIQUE (name)")
    end

    def self.down
        drop_table :arc_databases
    end
end
