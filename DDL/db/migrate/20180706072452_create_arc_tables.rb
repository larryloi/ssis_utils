class CreateArcTables < ActiveRecord::Migration
     def self.up
         create_table :arc_tables, :id => false  do |t|
            t.column    :id, "INT NOT NULL IDENTITY(1,1)", :references => nil
            t.integer   :arc_database_id, null: false
            t.string    :schema_name, :limit => 128, null: false
            t.string    :name, :limit => 128, null: false
            t.integer   :state, null: false
            t.string    :date_key, :limit => 128, null: false
            t.integer   :backup_batch_interval_hour, null: false
            t.integer   :backup_delay_interval_hour, null: false
            t.datetime  :backup_data_start_at, null: false
            t.datetime  :backup_data_end_at, null: false
            t.integer   :delete_batch_interval_hour, null: true
            t.integer   :delete_delay_interval_day, null: true
            t.datetime  :delete_data_start_at, null: true
            t.datetime  :delete_data_end_at, null: true

            t.timestamps null: false
         end
         execute("ALTER TABLE arc_tables ADD CONSTRAINT pk_arc_table_id PRIMARY KEY (id)")
         execute("ALTER TABLE arc_tables ADD CONSTRAINT fk1_arc_tables_arc_database_id FOREIGN KEY (arc_database_id) REFERENCES arc_databases (id) ON DELETE CASCADE ON UPDATE CASCADE;")
         execute("ALTER TABLE arc_tables ADD CONSTRAINT uk1_arc_table_arc_database_id_schema_name_name UNIQUE (arc_database_id, schema_name, name)")
     end

    def self.down
        drop_table :arc_tables
    end

end
