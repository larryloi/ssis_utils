class CreateArcLogs < ActiveRecord::Migration
     def self.up
        create_table :arc_logs, :id => false  do |t|
            t.column    :id, "BIGINT NOT NULL IDENTITY(1,1)", :references => nil
            t.string    :job_id, :limit => 36, null: false
            t.string    :arc_database_name, :limit => 128, null: false
            t.string    :schema_name, :limit => 128, null: false
            t.string    :arc_table_name, :limit => 128, null: false
            t.string    :arc_action, :limit => 45, null: false
            t.string    :state, :limit => 45, null: false
            t.datetime  :data_start_at, null: false
            t.datetime  :data_end_at, null: false
            t.datetime  :logged_at, null: false
            t.string    :message, :limit => 4000, null: true
        end
        execute("ALTER TABLE arc_logs ADD CONSTRAINT pk_arc_log_id PRIMARY KEY (id)")
        add_index :arc_logs, [:job_id], :name => 'idx1_job_id'
        add_index :arc_logs, [:data_start_at, :data_end_at], :name => 'idx2_data_start_at_data_end_at'
        add_index :arc_logs, [:logged_at], :name => 'idx3_logged_at'

     end

     def self.down
        drop_table :arc_logs
     end

end
