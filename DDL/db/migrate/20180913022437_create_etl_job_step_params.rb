class CreateEtlJobStepParams < ActiveRecord::Migration
  def self.up
    create_table :etl_job_step_params, :id => false do |t|
       t.column    :id, "INT NOT NULL IDENTITY(1,1)", :references => nil
       t.integer   :etl_job_step_id, null: false
       t.string    :parameter, :limit => 256, null: false
       t.string    :value, :limit => 256, null: false

       t.timestamps null: false
    end
    execute("ALTER TABLE etl_job_step_params ADD CONSTRAINT pk_etl_job_step_param_id PRIMARY KEY (id)")
    add_index :etl_job_step_params, [:etl_job_step_id, :parameter], :unique =>true, :name=>'uk1_etl_job_step_params_etl_job_step_id_parameter'
  end

  def self.down
    drop_table :etl_job_step_params
  end
end
