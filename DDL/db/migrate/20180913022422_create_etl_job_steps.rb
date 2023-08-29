class CreateEtlJobSteps < ActiveRecord::Migration
  def self.up
    create_table :etl_job_steps, :id => false do |t|
       t.column    :id, "INT NOT NULL IDENTITY(1,1)", :references => nil
       t.integer   :etl_job_id, null: false
       t.string    :name, :limit => 128, null: false
       t.integer   :cmdexec_success_code, null: false
       t.column    :on_success_action, "TINYINT NOT NULL"
       t.integer   :on_success_step_id, null: false
       t.column    :on_fail_action, "TINYINT NOT NULL"
       t.integer   :on_fail_step_id, null: false
       t.integer   :retry_attempts, null: false
       t.integer   :retry_interval, null: false
       t.integer   :os_run_priority, null: false
       t.string    :subsystem, :limit => 40, null: false
       t.column    :command, "NVARCHAR(MAX) DEFAULT NULL"
       t.string    :database_name, :limit => 128, null: false
       t.integer   :flags, null:false
       t.string    :ssis_package, :limit => 260, null: true
       
       t.timestamps null: false
    end
    execute("ALTER TABLE etl_job_steps ADD CONSTRAINT pk_etl_job_step_id PRIMARY KEY (id)")
    add_index :etl_job_steps, [:etl_job_id, :name], :unique =>true, :name=>'uk1_etl_job_steps_etl_job_id_name'
  end

  def self.down
      drop_table :etl_job_steps
  end
end
