class CreateEtlJobSchedules < ActiveRecord::Migration
  def self.up
    create_table :etl_job_schedules, :id => false do |t|
       t.column    :id, "INT NOT NULL IDENTITY(1,1)", :references => nil
       t.integer   :etl_job_id, null: false
       t.column    :enabled, "TINYINT NOT NULL"
       t.integer   :freq_type, null: false
       t.integer   :freq_interval, null: false
       t.integer   :freq_subday_type, null: false
       t.integer   :freq_subday_interval, null: false
       t.integer   :freq_relative_interval, null: false
       t.integer   :freq_recurrence_factor, null: false
       t.integer   :active_start_date, null: false
       t.integer   :active_end_date, null: false
       t.integer   :active_start_time, null: false
       t.integer   :active_end_time, null: false

       t.timestamps null: false
    end
    execute("ALTER TABLE etl_job_schedules ADD CONSTRAINT pk_etl_job_schedule_id PRIMARY KEY (id)")
    add_index :etl_job_schedules, [:etl_job_id], :unique =>true, :name=>'uk1_etl_job_schedules_etl_job_id'
  end

  def self.down
    drop_table :etl_job_schedules
  end
end
