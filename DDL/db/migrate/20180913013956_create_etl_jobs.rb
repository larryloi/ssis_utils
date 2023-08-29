class CreateEtlJobs < ActiveRecord::Migration
  def self.up
    create_table :etl_jobs, :id => false do |t|
       t.column    :id, "INT NOT NULL IDENTITY(1,1)", :references => nil
       t.string    :name, :limit => 128, null: false
       t.column    :enabled, "TINYINT NOT NULL"
       t.integer   :notify_level_eventlog, null: false
       t.integer   :notify_level_email, null: false
       t.integer   :notify_level_netsend, null: false
       t.integer   :notify_level_page, null: false
       t.integer   :delete_level, null: false
       t.string    :description, :limit => 512, null: false
       t.string    :category_name, :limit => 128, null: false
       t.string    :owner_login_name, :limit => 128, null: false
       t.string    :ssis_folder, :limit => 128, null: false
       t.string    :ssis_project, :limit => 128, null: false

       t.timestamps null: false
    end
    execute("ALTER TABLE etl_jobs ADD CONSTRAINT pk_etl_job_id PRIMARY KEY (id)")
    add_index :etl_jobs, [:name], :unique =>true, :name=>'uk1_etl_jobs_name'
    add_index :etl_jobs, [:ssis_folder, :ssis_project], :unique =>false, :name=>'idx1_etl_jobs_ssis_folder_ssis_project'
  end

  def self.down
    drop_table :etl_jobs
  end
end
